//===-- Single-precision tan function -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/math/tanf.h"
#include "src/__support/FPUtil/FEnvImpl.h"
#include "src/__support/FPUtil/FPBits.h"
#include "src/__support/FPUtil/PolyEval.h"
#include "src/__support/FPUtil/except_value_utils.h"
#include "src/__support/FPUtil/multiply_add.h"
#include "src/__support/FPUtil/nearest_integer.h"
#include "src/__support/common.h"

#include <errno.h>

#if defined(LIBC_TARGET_HAS_FMA)
#include "range_reduction_fma.h"
// using namespace __llvm_libc::fma;
using __llvm_libc::fma::FAST_PASS_BOUND;
using __llvm_libc::fma::large_range_reduction;
using __llvm_libc::fma::small_range_reduction;
#else
#include "range_reduction.h"
// using namespace __llvm_libc::generic;
using __llvm_libc::generic::FAST_PASS_BOUND;
using __llvm_libc::generic::large_range_reduction;
using __llvm_libc::generic::small_range_reduction;
#endif

namespace __llvm_libc {

// Lookup table for tan(k * pi/32) with k = -15..15 organized as follow:
//   TAN_K_OVER_32[k] = tan(k * pi/32) for k = 0..15
//   TAN_K_OVER_32[k] = tan((k - 31) * pi/32) for k = 16..31.
// This organization allows us to simply do the lookup:
//   TAN_K_OVER_32[k & 31] for k of type int(32/64) with 2-complement
// representation.
// The values of tan(k * pi/32) are generated by Sollya with:
//   for k from 0 -15 to 15 do { round(tan(k*pi/32), D, RN); };
static constexpr double TAN_K_PI_OVER_32[32] = {
    0.0000000000000000,    0x1.936bb8c5b2da2p-4,  0x1.975f5e0553158p-3,
    0x1.36a08355c63dcp-2,  0x1.a827999fcef32p-2,  0x1.11ab7190834ecp-1,
    0x1.561b82ab7f99p-1,   0x1.a43002ae4285p-1,   0x1.0000000000000p0,
    0x1.37efd8d87607ep0,   0x1.7f218e25a7461p0,   0x1.def13b73c1406p0,
    0x1.3504f333f9de6p1,   0x1.a5f59e90600ddp1,   0x1.41bfee2424771p2,
    0x1.44e6c595afdccp3,   -0x1.44e6c595afdccp3,  -0x1.41bfee2424771p2,
    -0x1.a5f59e90600ddp1,  -0x1.3504f333f9de6p1,  -0x1.def13b73c1406p0,
    -0x1.7f218e25a7461p0,  -0x1.37efd8d87607ep0,  -0x1.0000000000000p0,
    -0x1.a43002ae4285p-1,  -0x1.561b82ab7f99p-1,  -0x1.11ab7190834ecp-1,
    -0x1.a827999fcef32p-2, -0x1.36a08355c63dcp-2, -0x1.975f5e0553158p-3,
    -0x1.936bb8c5b2da2p-4, 0.0000000000000000,
};

// Exceptional cases for tanf.
static constexpr int TANF_EXCEPTS = 6;

static constexpr fputil::ExceptionalValues<float, TANF_EXCEPTS> TanfExcepts{
    /* inputs */ {
        0x531d744c, // x = 0x1.3ae898p39
        0x57d7b0ed, // x = 0x1.af61dap48
        0x65ee8695, // x = 0x1.dd0d2ap76
        0x6798fe4f, // x = 0x1.31fc9ep80
        0x6ad36709, // x = 0x1.a6ce12p86
        0x72b505bb, // x = 0x1.6a0b76p102
    },
    /* outputs (RZ, RU offset, RD offset, RN offset) */
    {
        {0x4591ea1e, 1, 0, 1}, // x = 0x1.3ae898p39, tan(x) = 0x1.23d43cp12 (RZ)
        {0x3eb068e3, 1, 0, 1}, // x = 0x1.af61dap48, tan(x) = 0x1.60d1c6p-2 (RZ)
        {0xcaa32f8e, 0, 1,
         0}, // x = 0x1.dd0d2ap76, tan(x) = -0x1.465f1cp22 (RZ)
        {0x461e09f7, 1, 0, 0}, // x = 0x1.31fc9ep80, tan(x) = 0x1.3c13eep13 (RZ)
        {0xbf62b097, 0, 1,
         0}, // x = 0x1.a6ce12p86, tan(x) = -0x1.c5612ep-1 (RZ)
        {0xbff2150f, 0, 1,
         0}, // x = 0x1.6a0b76p102, tan(x) = -0x1.e42a1ep0 (RZ)
    }};

LLVM_LIBC_FUNCTION(float, tanf, (float x)) {
  using FPBits = typename fputil::FPBits<float>;
  FPBits xbits(x);
  constexpr double SIGN[2] = {1.0, -1.0};
  double x_sign = SIGN[xbits.uintval() >> 31];

  xbits.set_sign(false);
  uint32_t x_abs = xbits.uintval();

  // Range reduction:
  //
  // Since tan(x) is an odd function,
  //   tan(x) = -tan(-x),
  // By replacing x with -x if x is negative, we can assume in the following
  // that x is non-negative.
  //
  // We perform a range reduction mod pi/32, so that we ca have a good
  // polynomial approximation of tan(x) around [-pi/32, pi/32].  Since tan(x) is
  // periodic with period pi, in the first step of range reduction, we find k
  // and y such that:
  //   x = (k + y) * pi/32,
  //   where k is an integer, and |y| <= 0.5.
  // Moreover, we only care about the lowest 5 bits of k, since
  //   tan((k + 32) * pi/32) = tan(k * pi/32 + pi) = tan(k * pi/32).
  // So after the reduction k = k & 31, we can assume that 0 <= k <= 31.
  //
  // For the second step, since tan(x) has a singularity at pi/2, we need a
  // further reduction so that:
  //   k * pi/32 < pi/2, or equivalently, 0 <= k < 16.
  // So if k >= 16, we perform the following transformation:
  //   tan(x) = tan(x - pi) = tan((k + y) * pi/32 - pi)
  //          = tan((k - 31 + y - 1) * pi/32)
  //          = tan((k - 31) * pi/32 + (y - 1) * pi/32)
  //          = tan(k' * pi/32 + y' * pi/32)
  // Notice that we only subtract k by 31, not 32, to make sure that |k'| < 16.
  // In fact, the range of k' is: -15 <= k' <= 0.
  // But the range of y' is now: -1.5 <= y' <= -0.5.
  // If we perform round to zero in the first step of finding k and y, so that
  //   0 <= y <= 1, then the range of y' would be -1 <= y' <= 0, then we can
  // reduce the degree of polynomial approximation using to approximate
  // tan(y* pi/32) by 1 or 2 terms.
  // In any case, for simplicity and to reuse the same range reduction as sinf
  // and cosf, we opted to use the former range: [-1.5, 1.5] * pi/32 for
  // the polynomial approximation step.
  //
  // Once k and y are computed, we then deduce the answer by the tangent of sum
  // formula:
  //   tan(x) = tan((k + y)*pi/32)
  //          = (tan(y*pi/32) + tan(k*pi/32)) / (1 - tan(y*pi/32)*tan(k*pi/32))
  // The values of tan(k*pi/32) for k = -15..15 are precomputed and stored using
  // a vector of 31 doubles. Tan(y*pi/32) is computed using degree-9 minimax
  // polynomials generated by Sollya.

  // |x| < pi/32
  if (unlikely(x_abs <= 0x3dc9'0fdbU)) {
    double xd = static_cast<double>(x);

    // |x| < 0x1.0p-12f
    if (unlikely(x_abs < 0x3980'0000U)) {
      if (unlikely(x_abs == 0U)) {
        // For signed zeros.
        return x;
      }
      // When |x| < 2^-12, the relative error of the approximation tan(x) ~ x
      // is:
      //   |tan(x) - x| / |tan(x)| < |x^3| / (3|x|)
      //                           = x^2 / 3
      //                           < 2^-25
      //                           < epsilon(1)/2.
      // So the correctly rounded values of tan(x) are:
      //   = x + sign(x)*eps(x) if rounding mode = FE_UPWARD and x is positive,
      //                        or (rounding mode = FE_DOWNWARD and x is
      //                        negative),
      //   = x otherwise.
      // To simplify the rounding decision and make it more efficient, we use
      //   fma(x, 2^-25, x) instead.
      // Note: to use the formula x + 2^-25*x to decide the correct rounding, we
      // do need fma(x, 2^-25, x) to prevent underflow caused by 2^-25*x when
      // |x| < 2^-125. For targets without FMA instructions, we simply use
      // double for intermediate results as it is more efficient than using an
      // emulated version of FMA.
#if defined(LIBC_TARGET_HAS_FMA)
      return fputil::multiply_add(x, 0x1.0p-25f, x);
#else
      return static_cast<float>(fputil::multiply_add(xd, 0x1.0p-25, xd));
#endif // LIBC_TARGET_HAS_FMA
    }

    // |x| < pi/32
    double xsq = xd * xd;

    // Degree-9 minimax odd polynomial of tan(x) generated by Sollya with:
    // > P = fpminimax(tan(x)/x, [|0, 2, 4, 6, 8|], [|1, D...|], [0, pi/32]);
    double result =
        fputil::polyeval(xsq, 1.0, 0x1.555555553d022p-2, 0x1.111111ce442c1p-3,
                         0x1.ba180a6bbdecdp-5, 0x1.69c0a88a0b71fp-6);
    return xd * result;
  }

  // Inf or NaN
  if (unlikely(x_abs >= 0x7f80'0000U)) {
    if (x_abs == 0x7f80'0000U) {
      errno = EDOM;
      fputil::set_except(FE_INVALID);
    }
    return x +
           FPBits::build_nan(1 << (fputil::MantissaWidth<float>::VALUE - 1));
  }

  int64_t k;
  double y;
  double xd = static_cast<double>(xbits.get_val());

  // Perform the first step of range reduction: find k and y such that
  //   x = (k + y) * pi/32,
  //   where k is an integer, and |y| <= 0.5.
  if (likely(x_abs < FAST_PASS_BOUND)) {
    k = small_range_reduction(xd, y);
  } else {

    using ExceptChecker =
        typename fputil::ExceptionChecker<float, TANF_EXCEPTS>;
    {
      float result;
      if (ExceptChecker::check_odd_func(TanfExcepts, x_abs, x_sign <= 0.0,
                                        result))
        return result;
    }

    fputil::FPBits<float> x_bits(x_abs);
    k = large_range_reduction(xd, x_bits.get_exponent(), y);
  }

  // Only care about the lowest 5 bits of k.
  k &= 31;
  // Adjust y if k >= 16.
  constexpr double ADJUSTMENT[2] = {0.0, -1.0};
  y += ADJUSTMENT[k >> 4];

  double tan_k = TAN_K_PI_OVER_32[k];

  // Degree-10 minimax odd polynomial for tan(y * pi/32)/y generated by Sollya
  // with:
  // > P = fpminimax(tan(y*pi/32)/y, [|0, 2, 4, 6, 8, 10|], [|D...|], [0, 1.5]);
  double ysq = y * y;
  double tan_y =
      y * fputil::polyeval(ysq, 0x1.921fb54442d17p-4, 0x1.4abbce625e84cp-12,
                           0x1.466bc669afd51p-20, 0x1.460013a5aae3p-28,
                           0x1.45de3dc438976p-36, 0x1.4eaeead85bef4p-44);

  // Combine the results with the tangent of sum formula:
  //   tan(x) = tan((k + y)*pi/32)
  //          = (tan(k*pi/32) + tan(k*pi/32)) / (1 - tan(y*pi/32)*tan(k*pi/32))
  return x_sign * (tan_y + tan_k) / fputil::multiply_add(tan_y, -tan_k, 1.0);
}

} // namespace __llvm_libc