; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=amdgcn -mcpu=gfx90a -amdgpu-igrouplp=1 < %s | FileCheck -check-prefix=GREEDY %s
; RUN: llc -march=amdgcn -mcpu=gfx90a -amdgpu-igrouplp-exact-solver -amdgpu-igrouplp=1 < %s | FileCheck -check-prefix=EXACT %s

define amdgpu_kernel void @test_sched_group_barrier_pipeline_MFMA_interleave(<32 x float> addrspace(3)* noalias %in, <32 x float> addrspace(3)* noalias %out) #0 {
; GREEDY-LABEL: test_sched_group_barrier_pipeline_MFMA_interleave:
; GREEDY:       ; %bb.0: ; %entry
; GREEDY-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x24
; GREEDY-NEXT:    v_lshlrev_b32_e32 v33, 7, v0
; GREEDY-NEXT:    v_mov_b32_e32 v34, 1.0
; GREEDY-NEXT:    v_mov_b32_e32 v35, 2.0
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_add_u32_e32 v32, s0, v33
; GREEDY-NEXT:    ds_read_b128 v[28:31], v32 offset:112
; GREEDY-NEXT:    ds_read_b128 v[24:27], v32 offset:96
; GREEDY-NEXT:    ds_read_b128 v[20:23], v32 offset:80
; GREEDY-NEXT:    ds_read_b128 v[16:19], v32 offset:64
; GREEDY-NEXT:    ds_read_b128 v[0:3], v32
; GREEDY-NEXT:    ds_read_b128 v[4:7], v32 offset:16
; GREEDY-NEXT:    ds_read_b128 v[8:11], v32 offset:32
; GREEDY-NEXT:    ds_read_b128 v[12:15], v32 offset:48
; GREEDY-NEXT:    v_add_u32_e32 v33, s1, v33
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_mfma_f32_32x32x1f32 v[0:31], v34, v35, v[0:31]
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 2
; GREEDY-NEXT:    ds_write_b128 v33, v[28:31] offset:112
; GREEDY-NEXT:    ds_write_b128 v33, v[24:27] offset:96
; GREEDY-NEXT:    ds_write_b128 v33, v[20:23] offset:80
; GREEDY-NEXT:    ds_write_b128 v33, v[16:19] offset:64
; GREEDY-NEXT:    ds_write_b128 v33, v[12:15] offset:48
; GREEDY-NEXT:    ds_write_b128 v33, v[8:11] offset:32
; GREEDY-NEXT:    ds_write_b128 v33, v[4:7] offset:16
; GREEDY-NEXT:    ds_write_b128 v33, v[0:3]
; GREEDY-NEXT:    ds_read_b128 v[64:67], v32 offset:8304
; GREEDY-NEXT:    ds_read_b128 v[60:63], v32 offset:8288
; GREEDY-NEXT:    ds_read_b128 v[56:59], v32 offset:8272
; GREEDY-NEXT:    ds_read_b128 v[52:55], v32 offset:8256
; GREEDY-NEXT:    ds_read_b128 v[48:51], v32 offset:8240
; GREEDY-NEXT:    ds_read_b128 v[44:47], v32 offset:8224
; GREEDY-NEXT:    ds_read_b128 v[40:43], v32 offset:8208
; GREEDY-NEXT:    ds_read_b128 v[36:39], v32 offset:8192
; GREEDY-NEXT:    v_mov_b32_e32 v0, s1
; GREEDY-NEXT:    v_add_u32_e32 v1, 0x6000, v32
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 2
; GREEDY-NEXT:    ds_write_b128 v0, v[60:63] offset:8288
; GREEDY-NEXT:    ds_write_b128 v0, v[64:67] offset:8304
; GREEDY-NEXT:    ds_write_b128 v0, v[52:55] offset:8256
; GREEDY-NEXT:    ds_write_b128 v0, v[56:59] offset:8272
; GREEDY-NEXT:    ds_write_b128 v0, v[44:47] offset:8224
; GREEDY-NEXT:    ds_write_b128 v0, v[48:51] offset:8240
; GREEDY-NEXT:    ds_write_b128 v0, v[36:39] offset:8192
; GREEDY-NEXT:    ds_write_b128 v0, v[40:43] offset:8208
; GREEDY-NEXT:    ds_read_b128 v[64:67], v32 offset:24688
; GREEDY-NEXT:    ds_read_b128 v[60:63], v32 offset:24672
; GREEDY-NEXT:    ds_read_b128 v[56:59], v32 offset:24656
; GREEDY-NEXT:    ds_read_b128 v[52:55], v32 offset:24640
; GREEDY-NEXT:    ds_read_b128 v[48:51], v32 offset:24624
; GREEDY-NEXT:    ds_read_b128 v[44:47], v32 offset:24608
; GREEDY-NEXT:    ds_read_b128 v[40:43], v32 offset:24592
; GREEDY-NEXT:    ds_read_b128 v[36:39], v32 offset:24576
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 2
; GREEDY-NEXT:    ds_write_b128 v0, v[60:63] offset:16480
; GREEDY-NEXT:    ds_write_b128 v0, v[64:67] offset:16496
; GREEDY-NEXT:    ds_write_b128 v0, v[52:55] offset:16448
; GREEDY-NEXT:    ds_write_b128 v0, v[56:59] offset:16464
; GREEDY-NEXT:    ds_write_b128 v0, v[44:47] offset:16416
; GREEDY-NEXT:    ds_write_b128 v0, v[48:51] offset:16432
; GREEDY-NEXT:    ds_write_b128 v0, v[36:39] offset:16384
; GREEDY-NEXT:    ds_write_b128 v0, v[40:43] offset:16400
; GREEDY-NEXT:    ds_read_b128 v[64:67], v32 offset:49264
; GREEDY-NEXT:    ds_read_b128 v[60:63], v32 offset:49248
; GREEDY-NEXT:    ds_read_b128 v[56:59], v32 offset:49232
; GREEDY-NEXT:    ds_read_b128 v[52:55], v32 offset:49216
; GREEDY-NEXT:    ds_read_b128 v[48:51], v32 offset:49200
; GREEDY-NEXT:    ds_read_b128 v[44:47], v32 offset:49184
; GREEDY-NEXT:    ds_read_b128 v[40:43], v32 offset:49168
; GREEDY-NEXT:    ds_read_b128 v[36:39], v32 offset:49152
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 2
; GREEDY-NEXT:    ds_write_b128 v0, v[60:63] offset:24672
; GREEDY-NEXT:    ds_write_b128 v0, v[64:67] offset:24688
; GREEDY-NEXT:    ds_write_b128 v0, v[52:55] offset:24640
; GREEDY-NEXT:    ds_write_b128 v0, v[56:59] offset:24656
; GREEDY-NEXT:    ds_write_b128 v0, v[44:47] offset:24608
; GREEDY-NEXT:    ds_write_b128 v0, v[48:51] offset:24624
; GREEDY-NEXT:    ds_write_b128 v0, v[36:39] offset:24576
; GREEDY-NEXT:    ds_write_b128 v0, v[40:43] offset:24592
; GREEDY-NEXT:    ds_read_b128 v[30:33], v1 offset:57456
; GREEDY-NEXT:    ds_read_b128 v[26:29], v1 offset:57440
; GREEDY-NEXT:    ds_read_b128 v[22:25], v1 offset:57424
; GREEDY-NEXT:    ds_read_b128 v[18:21], v1 offset:57408
; GREEDY-NEXT:    ds_read_b128 v[2:5], v1 offset:57344
; GREEDY-NEXT:    ds_read_b128 v[6:9], v1 offset:57360
; GREEDY-NEXT:    ds_read_b128 v[10:13], v1 offset:57376
; GREEDY-NEXT:    ds_read_b128 v[14:17], v1 offset:57392
; GREEDY-NEXT:    s_waitcnt lgkmcnt(0)
; GREEDY-NEXT:    v_mfma_f32_32x32x1f32 v[2:33], v34, v35, v[2:33]
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 7
; GREEDY-NEXT:    s_nop 2
; GREEDY-NEXT:    ds_write_b128 v0, v[26:29] offset:32864
; GREEDY-NEXT:    ds_write_b128 v0, v[30:33] offset:32880
; GREEDY-NEXT:    ds_write_b128 v0, v[18:21] offset:32832
; GREEDY-NEXT:    ds_write_b128 v0, v[22:25] offset:32848
; GREEDY-NEXT:    ds_write_b128 v0, v[10:13] offset:32800
; GREEDY-NEXT:    ds_write_b128 v0, v[14:17] offset:32816
; GREEDY-NEXT:    ds_write_b128 v0, v[2:5] offset:32768
; GREEDY-NEXT:    ds_write_b128 v0, v[6:9] offset:32784
; GREEDY-NEXT:    s_endpgm
;
; EXACT-LABEL: test_sched_group_barrier_pipeline_MFMA_interleave:
; EXACT:       ; %bb.0: ; %entry
; EXACT-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x24
; EXACT-NEXT:    v_lshlrev_b32_e32 v33, 7, v0
; EXACT-NEXT:    v_mov_b32_e32 v34, 1.0
; EXACT-NEXT:    v_mov_b32_e32 v35, 2.0
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_add_u32_e32 v32, s0, v33
; EXACT-NEXT:    ds_read_b128 v[28:31], v32 offset:112
; EXACT-NEXT:    ds_read_b128 v[24:27], v32 offset:96
; EXACT-NEXT:    ds_read_b128 v[20:23], v32 offset:80
; EXACT-NEXT:    ds_read_b128 v[16:19], v32 offset:64
; EXACT-NEXT:    ds_read_b128 v[0:3], v32
; EXACT-NEXT:    ds_read_b128 v[4:7], v32 offset:16
; EXACT-NEXT:    ds_read_b128 v[8:11], v32 offset:32
; EXACT-NEXT:    ds_read_b128 v[12:15], v32 offset:48
; EXACT-NEXT:    v_add_u32_e32 v33, s1, v33
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_mfma_f32_32x32x1f32 v[0:31], v34, v35, v[0:31]
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 2
; EXACT-NEXT:    ds_write_b128 v33, v[28:31] offset:112
; EXACT-NEXT:    ds_write_b128 v33, v[24:27] offset:96
; EXACT-NEXT:    ds_write_b128 v33, v[20:23] offset:80
; EXACT-NEXT:    ds_write_b128 v33, v[16:19] offset:64
; EXACT-NEXT:    ds_write_b128 v33, v[12:15] offset:48
; EXACT-NEXT:    ds_write_b128 v33, v[8:11] offset:32
; EXACT-NEXT:    ds_write_b128 v33, v[4:7] offset:16
; EXACT-NEXT:    ds_write_b128 v33, v[0:3]
; EXACT-NEXT:    ds_read_b128 v[64:67], v32 offset:8304
; EXACT-NEXT:    ds_read_b128 v[60:63], v32 offset:8288
; EXACT-NEXT:    ds_read_b128 v[56:59], v32 offset:8272
; EXACT-NEXT:    ds_read_b128 v[52:55], v32 offset:8256
; EXACT-NEXT:    ds_read_b128 v[48:51], v32 offset:8240
; EXACT-NEXT:    ds_read_b128 v[44:47], v32 offset:8224
; EXACT-NEXT:    ds_read_b128 v[40:43], v32 offset:8208
; EXACT-NEXT:    ds_read_b128 v[36:39], v32 offset:8192
; EXACT-NEXT:    v_mov_b32_e32 v0, s1
; EXACT-NEXT:    v_add_u32_e32 v1, 0x6000, v32
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 2
; EXACT-NEXT:    ds_write_b128 v0, v[60:63] offset:8288
; EXACT-NEXT:    ds_write_b128 v0, v[64:67] offset:8304
; EXACT-NEXT:    ds_write_b128 v0, v[52:55] offset:8256
; EXACT-NEXT:    ds_write_b128 v0, v[56:59] offset:8272
; EXACT-NEXT:    ds_write_b128 v0, v[44:47] offset:8224
; EXACT-NEXT:    ds_write_b128 v0, v[48:51] offset:8240
; EXACT-NEXT:    ds_write_b128 v0, v[36:39] offset:8192
; EXACT-NEXT:    ds_write_b128 v0, v[40:43] offset:8208
; EXACT-NEXT:    ds_read_b128 v[64:67], v32 offset:24688
; EXACT-NEXT:    ds_read_b128 v[60:63], v32 offset:24672
; EXACT-NEXT:    ds_read_b128 v[56:59], v32 offset:24656
; EXACT-NEXT:    ds_read_b128 v[52:55], v32 offset:24640
; EXACT-NEXT:    ds_read_b128 v[48:51], v32 offset:24624
; EXACT-NEXT:    ds_read_b128 v[44:47], v32 offset:24608
; EXACT-NEXT:    ds_read_b128 v[40:43], v32 offset:24592
; EXACT-NEXT:    ds_read_b128 v[36:39], v32 offset:24576
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 2
; EXACT-NEXT:    ds_write_b128 v0, v[60:63] offset:16480
; EXACT-NEXT:    ds_write_b128 v0, v[64:67] offset:16496
; EXACT-NEXT:    ds_write_b128 v0, v[52:55] offset:16448
; EXACT-NEXT:    ds_write_b128 v0, v[56:59] offset:16464
; EXACT-NEXT:    ds_write_b128 v0, v[44:47] offset:16416
; EXACT-NEXT:    ds_write_b128 v0, v[48:51] offset:16432
; EXACT-NEXT:    ds_write_b128 v0, v[36:39] offset:16384
; EXACT-NEXT:    ds_write_b128 v0, v[40:43] offset:16400
; EXACT-NEXT:    ds_read_b128 v[64:67], v32 offset:49264
; EXACT-NEXT:    ds_read_b128 v[60:63], v32 offset:49248
; EXACT-NEXT:    ds_read_b128 v[56:59], v32 offset:49232
; EXACT-NEXT:    ds_read_b128 v[52:55], v32 offset:49216
; EXACT-NEXT:    ds_read_b128 v[48:51], v32 offset:49200
; EXACT-NEXT:    ds_read_b128 v[44:47], v32 offset:49184
; EXACT-NEXT:    ds_read_b128 v[40:43], v32 offset:49168
; EXACT-NEXT:    ds_read_b128 v[36:39], v32 offset:49152
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_mfma_f32_32x32x1f32 v[36:67], v34, v35, v[36:67]
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 2
; EXACT-NEXT:    ds_write_b128 v0, v[60:63] offset:24672
; EXACT-NEXT:    ds_write_b128 v0, v[64:67] offset:24688
; EXACT-NEXT:    ds_write_b128 v0, v[52:55] offset:24640
; EXACT-NEXT:    ds_write_b128 v0, v[56:59] offset:24656
; EXACT-NEXT:    ds_write_b128 v0, v[44:47] offset:24608
; EXACT-NEXT:    ds_write_b128 v0, v[48:51] offset:24624
; EXACT-NEXT:    ds_write_b128 v0, v[36:39] offset:24576
; EXACT-NEXT:    ds_write_b128 v0, v[40:43] offset:24592
; EXACT-NEXT:    ds_read_b128 v[30:33], v1 offset:57456
; EXACT-NEXT:    ds_read_b128 v[26:29], v1 offset:57440
; EXACT-NEXT:    ds_read_b128 v[22:25], v1 offset:57424
; EXACT-NEXT:    ds_read_b128 v[18:21], v1 offset:57408
; EXACT-NEXT:    ds_read_b128 v[2:5], v1 offset:57344
; EXACT-NEXT:    ds_read_b128 v[6:9], v1 offset:57360
; EXACT-NEXT:    ds_read_b128 v[10:13], v1 offset:57376
; EXACT-NEXT:    ds_read_b128 v[14:17], v1 offset:57392
; EXACT-NEXT:    s_waitcnt lgkmcnt(0)
; EXACT-NEXT:    v_mfma_f32_32x32x1f32 v[2:33], v34, v35, v[2:33]
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 7
; EXACT-NEXT:    s_nop 2
; EXACT-NEXT:    ds_write_b128 v0, v[26:29] offset:32864
; EXACT-NEXT:    ds_write_b128 v0, v[30:33] offset:32880
; EXACT-NEXT:    ds_write_b128 v0, v[18:21] offset:32832
; EXACT-NEXT:    ds_write_b128 v0, v[22:25] offset:32848
; EXACT-NEXT:    ds_write_b128 v0, v[10:13] offset:32800
; EXACT-NEXT:    ds_write_b128 v0, v[14:17] offset:32816
; EXACT-NEXT:    ds_write_b128 v0, v[2:5] offset:32768
; EXACT-NEXT:    ds_write_b128 v0, v[6:9] offset:32784
; EXACT-NEXT:    s_endpgm
entry:
  %idx = call i32 @llvm.amdgcn.workitem.id.x()
  %load.0.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %in, i32 %idx
  %load.0 = load <32 x float>, <32 x float> addrspace(3)* %load.0.addr
  %load.1.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %load.0.addr, i32 64
  %load.1 = load <32 x float>, <32 x float> addrspace(3)* %load.1.addr
  %load.2.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %load.1.addr, i32 128
  %load.2 = load <32 x float>, <32 x float> addrspace(3)* %load.2.addr
  %load.3.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %load.2.addr, i32 192
  %load.3 = load <32 x float>, <32 x float> addrspace(3)* %load.3.addr
  %load.4.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %load.3.addr, i32 256
  %load.4 = load <32 x float>, <32 x float> addrspace(3)* %load.4.addr
  %mai.0 = tail call <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float 1.0, float 2.0, <32 x float> %load.0, i32 0, i32 0, i32 0)
  %mai.1 = tail call <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float 1.0, float 2.0, <32 x float> %load.1, i32 0, i32 0, i32 0)
  %mai.2 = tail call <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float 1.0, float 2.0, <32 x float> %load.2, i32 0, i32 0, i32 0)
  %mai.3 = tail call <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float 1.0, float 2.0, <32 x float> %load.3, i32 0, i32 0, i32 0)
  %mai.4 = tail call <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float 1.0, float 2.0, <32 x float> %load.4, i32 0, i32 0, i32 0)
  %store.0.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %out, i32 %idx
  store <32 x float> %mai.0, <32 x float> addrspace(3)* %store.0.addr
  %store.1.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %out, i32 64
  store <32 x float> %mai.1, <32 x float> addrspace(3)* %store.1.addr
  %store.2.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %out, i32 128
  store <32 x float> %mai.2, <32 x float> addrspace(3)* %store.2.addr
  %store.3.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %out, i32 192
  store <32 x float> %mai.3, <32 x float> addrspace(3)* %store.3.addr
  %store.4.addr = getelementptr <32 x float>, <32 x float> addrspace(3)* %out, i32 256
  store <32 x float> %mai.4, <32 x float> addrspace(3)* %store.4.addr
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #2
declare void @llvm.amdgcn.sched.group.barrier(i32, i32, i32) #1
declare <32 x float> @llvm.amdgcn.mfma.f32.32x32x1f32(float, float, <32 x float>, i32, i32, i32) #1

attributes #0 = { nounwind "amdgpu-flat-workgroup-size"="1,256" }
attributes #1 = { nounwind }
attributes #2 = { nounwind readnone speculatable }