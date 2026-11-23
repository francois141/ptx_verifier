; Aiter 183a6ce66ebb csrc/include/opus/rmsnorm_opus_kernel.hpp:132 (rmsnorm_opus_kernel), dispatch csrc/include/rmsnorm.h:44, compiled for gfx950 by
; external/amd/aiter/build.py (case rmsnorm).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii,"axG",@progbits,_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii,comdat
	.protected	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii
	.globl	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii
	.p2align	8
	.type	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii,@function
_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_load_dword s10, s[0:1], 0x38
	s_load_dword s17, s[0:1], 0x4c
	s_waitcnt lgkmcnt(0)
	s_cmp_eq_u32 s10, 0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cselect_b64 s[18:19], -1, 0
	s_cmp_lg_u64 s[8:9], 0
	s_cselect_b64 s[10:11], -1, 0
	v_and_b32_e32 v52, 0x3ff, v0
	s_lshr_b32 s20, s17, 16
	s_and_b32 s26, s17, 0xffff
	s_mul_i32 s16, s16, s20
	v_bfe_u32 v53, v0, 10, 10
	v_add_u32_e32 v0, s16, v53
	s_ashr_i32 s16, s14, 31
	s_lshr_b32 s16, s16, 29
	s_add_i32 s16, s14, s16
	s_ashr_i32 s27, s16, 3
	v_cmp_gt_i32_e64 s[16:17], s13, v0
	s_nop 1
	v_cndmask_b32_e64 v0, 0, v0, s[16:17]
	v_mad_i64_i32 v[8:9], s[20:21], v0, s14, 0
	v_mad_i64_i32 v[0:1], s[20:21], v0, s15, 0
	v_lshl_add_u64 v[4:5], v[0:1], 1, s[4:5]
	v_lshl_add_u64 v[6:7], v[8:9], 1, s[8:9]
	v_mov_b32_e32 v54, 0
	s_and_saveexec_b64 s[4:5], s[16:17]
	s_cbranch_execz .LBB0_34
	v_cmp_gt_i32_e32 vcc, s27, v52
	v_mov_b32_e32 v54, 0
	v_cndmask_b32_e64 v0, 0, 1, s[10:11]
	v_cmp_ne_u32_e64 s[10:11], 1, v0
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_7
	v_mov_b32_e32 v11, 0
	v_lshlrev_b32_e32 v10, 4, v52
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[10:11]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_4
	v_lshl_add_u64 v[14:15], v[6:7], 0, v[10:11]
	global_load_dwordx4 v[10:13], v[14:15], off
	v_mov_b32_e32 v23, 16
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v17, v23, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v16, v23, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v19, v23, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v18, v23, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v21, v23, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v20, v23, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v22, v23, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v23, v23, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v25, 0xffff0000, v10
	v_lshlrev_b32_e32 v24, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v12
	v_lshlrev_b32_e32 v10, 16, v12
	v_lshlrev_b32_e32 v12, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v13
	v_pk_add_f32 v[16:17], v[16:17], v[24:25]
	v_pk_add_f32 v[18:19], v[18:19], v[26:27]
	v_pk_add_f32 v[20:21], v[20:21], v[10:11]
	v_pk_add_f32 v[22:23], v[22:23], v[12:13]
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_cvt_pk_bf16_f32 v12, v20, v21
	v_cvt_pk_bf16_f32 v13, v22, v23
	v_and_b32_e32 v24, 0xffff0000, v10
	v_lshlrev_b32_e32 v25, 16, v10
	v_and_b32_e32 v26, 0xffff0000, v11
	v_lshlrev_b32_e32 v27, 16, v11
	v_and_b32_e32 v28, 0xffff0000, v12
	v_lshlrev_b32_e32 v29, 16, v12
	v_and_b32_e32 v30, 0xffff0000, v13
	v_lshlrev_b32_e32 v31, 16, v13
	global_store_dwordx4 v[14:15], v[10:13], off
	v_cndmask_b32_e64 v16, v25, v16, s[0:1]
	v_cndmask_b32_e64 v17, v24, v17, s[0:1]
	v_cndmask_b32_e64 v14, v27, v18, s[0:1]
	v_cndmask_b32_e64 v15, v26, v19, s[0:1]
	v_cndmask_b32_e64 v12, v29, v20, s[0:1]
	v_cndmask_b32_e64 v13, v28, v21, s[0:1]
	v_cndmask_b32_e64 v10, v31, v22, s[0:1]
	v_cndmask_b32_e64 v11, v30, v23, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_5
	s_branch .LBB0_6
.LBB0_4:
	s_mov_b64 vcc, 0
.LBB0_5:
	v_mov_b32_e32 v11, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v16, v11, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v17, v11, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v14, v11, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v15, v11, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v12, v11, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v13, v11, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v10, v11, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v11, v11, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB0_6:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[10:11], v[10:11]
	v_pk_mul_f32 v[2:3], v[12:13], v[12:13]
	v_pk_mul_f32 v[18:19], v[14:15], v[14:15]
	v_pk_mul_f32 v[20:21], v[16:17], v[16:17]
	s_nop 0
	v_add_f32_e32 v20, v20, v21
	v_add_f32_e32 v18, v20, v18
	v_add_f32_e32 v18, v18, v19
	v_add_f32_e32 v2, v18, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v54, v0, v1
.LBB0_7:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v26, s26, v52
	v_cmp_gt_i32_e32 vcc, s27, v26
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_13
	v_mov_b32_e32 v19, 0
	v_lshlrev_b32_e32 v18, 4, v26
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[18:19]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_10
	v_lshl_add_u64 v[22:23], v[6:7], 0, v[18:19]
	global_load_dwordx4 v[18:21], v[22:23], off
	v_mov_b32_e32 v27, 16
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v25, v27, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v24, v27, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v29, v27, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v28, v27, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v31, v27, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v30, v27, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v32, v27, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v33, v27, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v35, 0xffff0000, v18
	v_lshlrev_b32_e32 v34, 16, v18
	v_and_b32_e32 v37, 0xffff0000, v19
	v_lshlrev_b32_e32 v36, 16, v19
	v_and_b32_e32 v19, 0xffff0000, v20
	v_lshlrev_b32_e32 v18, 16, v20
	v_lshlrev_b32_e32 v20, 16, v21
	v_and_b32_e32 v21, 0xffff0000, v21
	v_pk_add_f32 v[24:25], v[24:25], v[34:35]
	v_pk_add_f32 v[28:29], v[28:29], v[36:37]
	v_pk_add_f32 v[30:31], v[30:31], v[18:19]
	v_pk_add_f32 v[32:33], v[32:33], v[20:21]
	v_cvt_pk_bf16_f32 v18, v24, v25
	v_cvt_pk_bf16_f32 v19, v28, v29
	v_cvt_pk_bf16_f32 v20, v30, v31
	v_cvt_pk_bf16_f32 v21, v32, v33
	v_and_b32_e32 v27, 0xffff0000, v18
	v_lshlrev_b32_e32 v34, 16, v18
	v_and_b32_e32 v35, 0xffff0000, v19
	v_lshlrev_b32_e32 v36, 16, v19
	v_and_b32_e32 v37, 0xffff0000, v20
	v_lshlrev_b32_e32 v38, 16, v20
	v_and_b32_e32 v39, 0xffff0000, v21
	v_lshlrev_b32_e32 v40, 16, v21
	global_store_dwordx4 v[22:23], v[18:21], off
	v_cndmask_b32_e64 v24, v34, v24, s[0:1]
	v_cndmask_b32_e64 v25, v27, v25, s[0:1]
	v_cndmask_b32_e64 v22, v36, v28, s[0:1]
	v_cndmask_b32_e64 v23, v35, v29, s[0:1]
	v_cndmask_b32_e64 v20, v38, v30, s[0:1]
	v_cndmask_b32_e64 v21, v37, v31, s[0:1]
	v_cndmask_b32_e64 v18, v40, v32, s[0:1]
	v_cndmask_b32_e64 v19, v39, v33, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_11
	s_branch .LBB0_12
.LBB0_10:
	s_mov_b64 vcc, 0
.LBB0_11:
	v_mov_b32_e32 v19, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v24, v19, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v25, v19, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v22, v19, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v23, v19, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v20, v19, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v21, v19, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v18, v19, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v19, v19, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB0_12:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[18:19], v[18:19]
	v_pk_mul_f32 v[2:3], v[20:21], v[20:21]
	v_pk_mul_f32 v[28:29], v[22:23], v[22:23]
	v_pk_mul_f32 v[30:31], v[24:25], v[24:25]
	s_nop 0
	v_add_f32_e32 v27, v54, v30
	v_add_f32_e32 v27, v27, v31
	v_add_f32_e32 v27, v27, v28
	v_add_f32_e32 v27, v27, v29
	v_add_f32_e32 v2, v27, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v54, v0, v1
.LBB0_13:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v34, s26, v26
	v_cmp_gt_i32_e32 vcc, s27, v34
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_19
	v_mov_b32_e32 v27, 0
	v_lshlrev_b32_e32 v26, 4, v34
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[26:27]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_16
	v_lshl_add_u64 v[30:31], v[6:7], 0, v[26:27]
	global_load_dwordx4 v[26:29], v[30:31], off
	v_mov_b32_e32 v35, 16
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v33, v35, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v32, v35, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v37, v35, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v36, v35, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v39, v35, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v38, v35, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v40, v35, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v41, v35, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v43, 0xffff0000, v26
	v_lshlrev_b32_e32 v42, 16, v26
	v_and_b32_e32 v45, 0xffff0000, v27
	v_lshlrev_b32_e32 v44, 16, v27
	v_and_b32_e32 v27, 0xffff0000, v28
	v_lshlrev_b32_e32 v26, 16, v28
	v_lshlrev_b32_e32 v28, 16, v29
	v_and_b32_e32 v29, 0xffff0000, v29
	v_pk_add_f32 v[32:33], v[32:33], v[42:43]
	v_pk_add_f32 v[36:37], v[36:37], v[44:45]
	v_pk_add_f32 v[38:39], v[38:39], v[26:27]
	v_pk_add_f32 v[40:41], v[40:41], v[28:29]
	v_cvt_pk_bf16_f32 v26, v32, v33
	v_cvt_pk_bf16_f32 v27, v36, v37
	v_cvt_pk_bf16_f32 v28, v38, v39
	v_cvt_pk_bf16_f32 v29, v40, v41
	v_and_b32_e32 v35, 0xffff0000, v26
	v_lshlrev_b32_e32 v42, 16, v26
	v_and_b32_e32 v43, 0xffff0000, v27
	v_lshlrev_b32_e32 v44, 16, v27
	v_and_b32_e32 v45, 0xffff0000, v28
	v_lshlrev_b32_e32 v46, 16, v28
	v_and_b32_e32 v47, 0xffff0000, v29
	v_lshlrev_b32_e32 v48, 16, v29
	global_store_dwordx4 v[30:31], v[26:29], off
	v_cndmask_b32_e64 v32, v42, v32, s[0:1]
	v_cndmask_b32_e64 v33, v35, v33, s[0:1]
	v_cndmask_b32_e64 v30, v44, v36, s[0:1]
	v_cndmask_b32_e64 v31, v43, v37, s[0:1]
	v_cndmask_b32_e64 v28, v46, v38, s[0:1]
	v_cndmask_b32_e64 v29, v45, v39, s[0:1]
	v_cndmask_b32_e64 v26, v48, v40, s[0:1]
	v_cndmask_b32_e64 v27, v47, v41, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_17
	s_branch .LBB0_18
.LBB0_16:
	s_mov_b64 vcc, 0
.LBB0_17:
	v_mov_b32_e32 v27, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v32, v27, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v33, v27, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v30, v27, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v31, v27, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v28, v27, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v29, v27, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v26, v27, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v27, v27, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB0_18:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[26:27], v[26:27]
	v_pk_mul_f32 v[2:3], v[28:29], v[28:29]
	v_pk_mul_f32 v[36:37], v[30:31], v[30:31]
	v_pk_mul_f32 v[38:39], v[32:33], v[32:33]
	s_nop 0
	v_add_f32_e32 v35, v54, v38
	v_add_f32_e32 v35, v35, v39
	v_add_f32_e32 v35, v35, v36
	v_add_f32_e32 v35, v35, v37
	v_add_f32_e32 v2, v35, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v54, v0, v1
.LBB0_19:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v42, s26, v34
	v_cmp_gt_i32_e32 vcc, s27, v42
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_25
	v_mov_b32_e32 v35, 0
	v_lshlrev_b32_e32 v34, 4, v42
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[34:35]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_22
	v_lshl_add_u64 v[38:39], v[6:7], 0, v[34:35]
	global_load_dwordx4 v[34:37], v[38:39], off
	v_mov_b32_e32 v43, 16
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v41, v43, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v40, v43, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v45, v43, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v44, v43, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v47, v43, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v46, v43, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v48, v43, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v49, v43, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v51, 0xffff0000, v34
	v_lshlrev_b32_e32 v50, 16, v34
	v_and_b32_e32 v57, 0xffff0000, v35
	v_lshlrev_b32_e32 v56, 16, v35
	v_and_b32_e32 v35, 0xffff0000, v36
	v_lshlrev_b32_e32 v34, 16, v36
	v_lshlrev_b32_e32 v36, 16, v37
	v_and_b32_e32 v37, 0xffff0000, v37
	v_pk_add_f32 v[40:41], v[40:41], v[50:51]
	v_pk_add_f32 v[44:45], v[44:45], v[56:57]
	v_pk_add_f32 v[46:47], v[46:47], v[34:35]
	v_pk_add_f32 v[48:49], v[48:49], v[36:37]
	v_cvt_pk_bf16_f32 v34, v40, v41
	v_cvt_pk_bf16_f32 v35, v44, v45
	v_cvt_pk_bf16_f32 v36, v46, v47
	v_cvt_pk_bf16_f32 v37, v48, v49
	v_and_b32_e32 v43, 0xffff0000, v34
	v_lshlrev_b32_e32 v50, 16, v34
	v_and_b32_e32 v51, 0xffff0000, v35
	v_lshlrev_b32_e32 v55, 16, v35
	v_and_b32_e32 v56, 0xffff0000, v36
	v_lshlrev_b32_e32 v57, 16, v36
	v_and_b32_e32 v58, 0xffff0000, v37
	v_lshlrev_b32_e32 v59, 16, v37
	global_store_dwordx4 v[38:39], v[34:37], off
	v_cndmask_b32_e64 v40, v50, v40, s[0:1]
	v_cndmask_b32_e64 v41, v43, v41, s[0:1]
	v_cndmask_b32_e64 v38, v55, v44, s[0:1]
	v_cndmask_b32_e64 v39, v51, v45, s[0:1]
	v_cndmask_b32_e64 v36, v57, v46, s[0:1]
	v_cndmask_b32_e64 v37, v56, v47, s[0:1]
	v_cndmask_b32_e64 v34, v59, v48, s[0:1]
	v_cndmask_b32_e64 v35, v58, v49, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_23
	s_branch .LBB0_24
.LBB0_22:
	s_mov_b64 vcc, 0
.LBB0_23:
	v_mov_b32_e32 v35, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v40, v35, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v41, v35, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v38, v35, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v39, v35, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v36, v35, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v37, v35, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v34, v35, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v35, v35, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB0_24:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[34:35], v[34:35]
	v_pk_mul_f32 v[2:3], v[36:37], v[36:37]
	v_pk_mul_f32 v[44:45], v[38:39], v[38:39]
	v_pk_mul_f32 v[46:47], v[40:41], v[40:41]
	s_nop 0
	v_add_f32_e32 v43, v54, v46
	v_add_f32_e32 v43, v43, v47
	v_add_f32_e32 v43, v43, v44
	v_add_f32_e32 v43, v43, v45
	v_add_f32_e32 v2, v43, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v54, v0, v1
.LBB0_25:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v55, s26, v42
	v_cmp_gt_i32_e32 vcc, s27, v55
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_33
	v_lshlrev_b32_e32 v42, 4, v55
	s_mov_b32 s21, 0
	v_mov_b32_e32 v43, 0
	s_lshl_b32 s20, s26, 4
	s_mov_b64 s[22:23], 0
	v_mov_b32_e32 v56, 16
	s_branch .LBB0_28
.LBB0_27:
	v_pk_mul_f32 v[0:1], v[50:51], v[50:51]
	v_pk_mul_f32 v[2:3], v[48:49], v[48:49]
	v_pk_mul_f32 v[46:47], v[46:47], v[46:47]
	v_pk_mul_f32 v[44:45], v[44:45], v[44:45]
	s_nop 0
	v_add_f32_e32 v44, v54, v44
	v_add_f32_e32 v44, v44, v45
	v_add_f32_e32 v44, v44, v46
	v_add_f32_e32 v44, v44, v47
	v_add_f32_e32 v2, v44, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v54, v0, v1
	v_add_u32_e32 v55, s26, v55
	v_cmp_le_i32_e32 vcc, s27, v55
	s_or_b64 s[22:23], vcc, s[22:23]
	v_lshl_add_u64 v[42:43], v[42:43], 0, s[20:21]
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execz .LBB0_32
.LBB0_28:
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[42:43]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_mov_b64 s[24:25], -1
	s_and_b64 vcc, exec, s[10:11]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v57, v56, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v62, v56, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v58, v56, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v63, v56, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v59, v56, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v64, v56, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v60, v56, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v61, v56, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_cbranch_vccnz .LBB0_30
	v_lshl_add_u64 v[48:49], v[6:7], 0, v[42:43]
	global_load_dwordx4 v[44:47], v[48:49], off
	v_lshlrev_b32_sdwa v51, v56, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v50, v56, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v67, v56, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v66, v56, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v1, v56, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v0, v56, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v2, v56, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v3, v56, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v69, 0xffff0000, v44
	v_lshlrev_b32_e32 v68, 16, v44
	v_and_b32_e32 v71, 0xffff0000, v45
	v_lshlrev_b32_e32 v70, 16, v45
	v_and_b32_e32 v45, 0xffff0000, v46
	v_lshlrev_b32_e32 v44, 16, v46
	v_lshlrev_b32_e32 v46, 16, v47
	v_and_b32_e32 v47, 0xffff0000, v47
	v_pk_add_f32 v[50:51], v[50:51], v[68:69]
	v_pk_add_f32 v[66:67], v[66:67], v[70:71]
	v_pk_add_f32 v[68:69], v[0:1], v[44:45]
	v_pk_add_f32 v[70:71], v[2:3], v[46:47]
	v_cvt_pk_bf16_f32 v0, v50, v51
	v_cvt_pk_bf16_f32 v1, v66, v67
	v_cvt_pk_bf16_f32 v2, v68, v69
	v_cvt_pk_bf16_f32 v3, v70, v71
	v_and_b32_e32 v45, 0xffff0000, v0
	v_lshlrev_b32_e32 v44, 16, v0
	v_and_b32_e32 v47, 0xffff0000, v1
	v_lshlrev_b32_e32 v46, 16, v1
	v_and_b32_e32 v65, 0xffff0000, v2
	v_lshlrev_b32_e32 v72, 16, v2
	v_and_b32_e32 v73, 0xffff0000, v3
	v_lshlrev_b32_e32 v74, 16, v3
	global_store_dwordx4 v[48:49], v[0:3], off
	v_cndmask_b32_e64 v44, v44, v50, s[0:1]
	v_cndmask_b32_e64 v45, v45, v51, s[0:1]
	v_cndmask_b32_e64 v46, v46, v66, s[0:1]
	v_cndmask_b32_e64 v47, v47, v67, s[0:1]
	v_cndmask_b32_e64 v48, v72, v68, s[0:1]
	v_cndmask_b32_e64 v49, v65, v69, s[0:1]
	v_cndmask_b32_e64 v50, v74, v70, s[0:1]
	v_cndmask_b32_e64 v51, v73, v71, s[0:1]
	s_mov_b64 s[24:25], 0
.LBB0_30:
	s_andn2_b64 vcc, exec, s[24:25]
	s_cbranch_vccnz .LBB0_27
	v_mov_b32_e32 v44, v62
	v_mov_b32_e32 v45, v57
	v_mov_b32_e32 v46, v63
	v_mov_b32_e32 v47, v58
	v_mov_b32_e32 v48, v64
	v_mov_b32_e32 v49, v59
	v_mov_b32_e32 v50, v60
	v_mov_b32_e32 v51, v61
	s_branch .LBB0_27
.LBB0_32:
	s_or_b64 exec, exec, s[22:23]
.LBB0_33:
	s_or_b64 exec, exec, s[8:9]
.LBB0_34:
	s_or_b64 exec, exec, s[4:5]
	v_mul_u32_u24_e32 v0, s26, v53
	s_barrier
	v_add_lshl_u32 v1, v0, v52, 2
	ds_write_b32 v1, v54
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cmp_lt_u32 s26, 2
	s_cbranch_scc1 .LBB0_39
	s_mov_b32 s8, s26
	s_branch .LBB0_37
.LBB0_36:
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cmp_gt_u32 s8, 3
	s_mov_b32 s8, s9
	s_cbranch_scc0 .LBB0_39
.LBB0_37:
	s_lshr_b32 s9, s8, 1
	v_cmp_gt_u32_e32 vcc, s9, v52
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_36
	v_lshl_add_u32 v2, s9, 2, v1
	ds_read_b32 v2, v2
	ds_read_b32 v3, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
	s_branch .LBB0_36
.LBB0_39:
	s_and_saveexec_b64 s[4:5], s[16:17]
	s_cbranch_execz .LBB0_51
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	v_cvt_f32_i32_e32 v1, s14
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v2, s[4:5], v1, v1, v0
	v_rcp_f32_e32 v3, v2
	v_div_scale_f32 v42, vcc, v0, v1, v0
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v43, -v2, v3, 1.0
	v_fmac_f32_e32 v3, v43, v3
	v_mul_f32_e32 v43, v42, v3
	v_fma_f32 v44, -v2, v43, v42
	v_fmac_f32_e32 v43, v44, v3
	v_fma_f32 v2, -v2, v43, v42
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v2, v2, v3, v43
	v_div_fixup_f32 v0, v2, v1, v0
	v_add_f32_e32 v0, s12, v0
	v_rsq_f32_e32 v0, v0
	v_lshl_add_u64 v[2:3], v[8:9], 1, s[2:3]
	v_cmp_gt_i32_e32 vcc, s27, v52
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_42
	v_lshlrev_b32_e32 v46, 4, v52
	global_load_dwordx4 v[42:45], v46, s[6:7]
	v_mov_b32_e32 v47, 0
	v_pk_mul_f32 v[8:9], v[0:1], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[0:1], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[0:1], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[0:1], v[10:11] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v1, v8, v9
	v_cvt_pk_bf16_f32 v16, v14, v15
	v_cvt_pk_bf16_f32 v17, v12, v13
	v_cvt_pk_bf16_f32 v48, v10, v11
	v_lshlrev_b32_e32 v49, 16, v1
	v_and_b32_e32 v1, 0xffff0000, v1
	v_lshlrev_b32_e32 v50, 16, v16
	v_and_b32_e32 v16, 0xffff0000, v16
	v_lshlrev_b32_e32 v51, 16, v17
	v_and_b32_e32 v17, 0xffff0000, v17
	v_lshlrev_b32_e32 v53, 16, v48
	v_and_b32_e32 v48, 0xffff0000, v48
	v_cndmask_b32_e64 v9, v1, v9, s[0:1]
	v_cndmask_b32_e64 v8, v49, v8, s[0:1]
	v_cndmask_b32_e64 v15, v16, v15, s[0:1]
	v_cndmask_b32_e64 v14, v50, v14, s[0:1]
	v_cndmask_b32_e64 v13, v17, v13, s[0:1]
	v_cndmask_b32_e64 v12, v51, v12, s[0:1]
	v_cndmask_b32_e64 v11, v48, v11, s[0:1]
	v_cndmask_b32_e64 v10, v53, v10, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v17, 0xffff0000, v42
	v_lshlrev_b32_e32 v16, 16, v42
	v_and_b32_e32 v49, 0xffff0000, v43
	v_lshlrev_b32_e32 v48, 16, v43
	v_and_b32_e32 v43, 0xffff0000, v44
	v_lshlrev_b32_e32 v42, 16, v44
	v_and_b32_e32 v51, 0xffff0000, v45
	v_lshlrev_b32_e32 v50, 16, v45
	v_pk_mul_f32 v[8:9], v[8:9], v[16:17]
	v_pk_mul_f32 v[14:15], v[14:15], v[48:49]
	v_pk_mul_f32 v[12:13], v[12:13], v[42:43]
	v_pk_mul_f32 v[16:17], v[10:11], v[50:51]
	v_cvt_pk_bf16_f32 v8, v8, v9
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v12, v13
	v_cvt_pk_bf16_f32 v11, v16, v17
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[46:47]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB0_42:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v52
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_44
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[18:19] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v20, v21
	v_cvt_pk_bf16_f32 v25, v18, v19
	v_lshlrev_b32_e32 v42, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v43, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v44, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v45, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v42, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v43, v16, s[0:1]
	v_cndmask_b32_e64 v21, v24, v21, s[0:1]
	v_cndmask_b32_e64 v20, v44, v20, s[0:1]
	v_cndmask_b32_e64 v19, v25, v19, s[0:1]
	v_cndmask_b32_e64 v18, v45, v18, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v43, 0xffff0000, v11
	v_lshlrev_b32_e32 v42, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[20:21], v[8:9]
	v_pk_mul_f32 v[18:19], v[18:19], v[42:43]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB0_44:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_46
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[26:27] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v18, v19
	v_cvt_pk_bf16_f32 v25, v20, v21
	v_lshlrev_b32_e32 v26, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v27, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v28, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v29, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v26, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v27, v16, s[0:1]
	v_cndmask_b32_e64 v19, v24, v19, s[0:1]
	v_cndmask_b32_e64 v18, v28, v18, s[0:1]
	v_cndmask_b32_e64 v21, v25, v21, s[0:1]
	v_cndmask_b32_e64 v20, v29, v20, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[18:19], v[8:9]
	v_pk_mul_f32 v[18:19], v[20:21], v[26:27]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB0_46:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_48
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[34:35] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v18, v19
	v_cvt_pk_bf16_f32 v25, v20, v21
	v_lshlrev_b32_e32 v26, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v27, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v28, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v29, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v26, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v27, v16, s[0:1]
	v_cndmask_b32_e64 v19, v24, v19, s[0:1]
	v_cndmask_b32_e64 v18, v28, v18, s[0:1]
	v_cndmask_b32_e64 v21, v25, v21, s[0:1]
	v_cndmask_b32_e64 v20, v29, v20, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[18:19], v[8:9]
	v_pk_mul_f32 v[18:19], v[20:21], v[26:27]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB0_48:
	s_or_b64 exec, exec, s[2:3]
	s_nop 0
	v_add_u32_e32 v8, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v8
	s_and_b64 exec, exec, vcc
	s_cbranch_execz .LBB0_51
	v_cndmask_b32_e64 v5, v7, v5, s[18:19]
	v_cndmask_b32_e64 v4, v6, v4, s[18:19]
	v_mov_b32_e32 v1, v0
	v_lshlrev_b32_e32 v6, 4, v8
	s_mov_b32 s3, 0
	v_mov_b32_e32 v7, 0
	s_lshl_b32 s2, s26, 4
	s_mov_b64 s[4:5], 0
.LBB0_50:
	v_lshl_add_u64 v[10:11], v[4:5], 0, v[6:7]
	v_lshl_add_u64 v[14:15], s[6:7], 0, v[6:7]
	global_load_dwordx4 v[10:13], v[10:11], off
	global_load_dwordx4 v[14:17], v[14:15], off
	v_lshl_add_u64 v[18:19], v[2:3], 0, v[6:7]
	v_add_u32_e32 v8, s26, v8
	v_lshl_add_u64 v[6:7], v[6:7], 0, s[2:3]
	v_cmp_le_i32_e32 vcc, s27, v8
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v21, 0xffff0000, v10
	v_lshlrev_b32_e32 v20, 16, v10
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v14
	v_lshlrev_b32_e32 v22, 16, v14
	v_and_b32_e32 v25, 0xffff0000, v11
	v_lshlrev_b32_e32 v24, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v12
	v_lshlrev_b32_e32 v14, 16, v12
	v_and_b32_e32 v27, 0xffff0000, v16
	v_lshlrev_b32_e32 v26, 16, v16
	v_and_b32_e32 v29, 0xffff0000, v13
	v_lshlrev_b32_e32 v28, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v17
	v_lshlrev_b32_e32 v12, 16, v17
	v_pk_mul_f32 v[16:17], v[0:1], v[20:21]
	v_pk_mul_f32 v[20:21], v[0:1], v[24:25]
	v_pk_mul_f32 v[14:15], v[0:1], v[14:15]
	v_pk_mul_f32 v[24:25], v[0:1], v[28:29]
	v_cvt_pk_bf16_f32 v9, v16, v17
	v_cvt_pk_bf16_f32 v28, v20, v21
	v_cvt_pk_bf16_f32 v29, v14, v15
	v_cvt_pk_bf16_f32 v30, v24, v25
	v_lshlrev_b32_e32 v31, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v9
	v_lshlrev_b32_e32 v32, 16, v28
	v_and_b32_e32 v28, 0xffff0000, v28
	v_lshlrev_b32_e32 v33, 16, v29
	v_and_b32_e32 v29, 0xffff0000, v29
	v_lshlrev_b32_e32 v34, 16, v30
	v_and_b32_e32 v30, 0xffff0000, v30
	v_cndmask_b32_e64 v17, v9, v17, s[0:1]
	v_cndmask_b32_e64 v16, v31, v16, s[0:1]
	v_cndmask_b32_e64 v21, v28, v21, s[0:1]
	v_cndmask_b32_e64 v20, v32, v20, s[0:1]
	v_cndmask_b32_e64 v15, v29, v15, s[0:1]
	v_cndmask_b32_e64 v14, v33, v14, s[0:1]
	v_cndmask_b32_e64 v25, v30, v25, s[0:1]
	v_cndmask_b32_e64 v24, v34, v24, s[0:1]
	v_pk_mul_f32 v[16:17], v[16:17], v[22:23]
	v_pk_mul_f32 v[20:21], v[20:21], v[10:11]
	v_pk_mul_f32 v[14:15], v[14:15], v[26:27]
	v_pk_mul_f32 v[22:23], v[24:25], v[12:13]
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v20, v21
	v_cvt_pk_bf16_f32 v12, v14, v15
	v_cvt_pk_bf16_f32 v13, v22, v23
	global_store_dwordx4 v[18:19], v[10:13], off
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB0_50
.LBB0_51:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii
		.amdhsa_group_segment_fixed_size 4096
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 320
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 75
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 76
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_tg_split 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii,"axG",@progbits,_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii,comdat
.Lfunc_end0:
	.size	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii, .Lfunc_end0-_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii

	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.num_vgpr, 75
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.num_agpr, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.numbered_sgpr, 28
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.private_seg_size, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.uses_vcc, 1
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.uses_flat_scratch, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.has_recursion, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.has_indirect_call, 0
	.section	.text._ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii,"axG",@progbits,_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii,comdat
	.protected	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii
	.globl	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii
	.p2align	8
	.type	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii,@function
_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_load_dword s17, s[0:1], 0x38
	s_load_dword s22, s[0:1], 0x4c
	s_waitcnt lgkmcnt(0)
	s_cmp_eq_u32 s17, 0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cselect_b64 s[18:19], -1, 0
	s_cmp_lg_u64 s[8:9], 0
	s_cselect_b64 s[20:21], -1, 0
	v_and_b32_e32 v54, 0x3ff, v0
	s_lshr_b32 s17, s22, 16
	s_and_b32 s26, s22, 0xffff
	s_mul_i32 s16, s16, s17
	v_bfe_u32 v55, v0, 10, 10
	v_add_u32_e32 v0, s16, v55
	s_ashr_i32 s16, s14, 31
	s_lshr_b32 s16, s16, 29
	s_add_i32 s16, s14, s16
	s_ashr_i32 s27, s16, 3
	v_cmp_gt_i32_e64 s[16:17], s13, v0
	s_nop 1
	v_cndmask_b32_e64 v0, 0, v0, s[16:17]
	v_mad_i64_i32 v[8:9], s[22:23], v0, s14, 0
	v_mad_i64_i32 v[0:1], s[22:23], v0, s15, 0
	v_lshl_add_u64 v[4:5], v[0:1], 1, s[4:5]
	v_lshl_add_u64 v[6:7], v[8:9], 1, s[10:11]
	v_mov_b32_e32 v56, 0
	s_and_saveexec_b64 s[4:5], s[16:17]
	s_cbranch_execz .LBB1_34
	v_lshl_add_u64 v[18:19], v[8:9], 1, s[8:9]
	v_cmp_gt_i32_e32 vcc, s27, v54
	v_mov_b32_e32 v56, 0
	v_cndmask_b32_e64 v0, 0, 1, s[20:21]
	v_cmp_ne_u32_e64 s[10:11], 1, v0
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_7
	v_mov_b32_e32 v11, 0
	v_lshlrev_b32_e32 v10, 4, v54
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[10:11]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB1_4
	v_lshl_add_u64 v[12:13], v[18:19], 0, v[10:11]
	global_load_dwordx4 v[12:15], v[12:13], off
	v_mov_b32_e32 v25, 16
	v_lshl_add_u64 v[16:17], v[6:7], 0, v[10:11]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v11, v25, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v10, v25, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v21, v25, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v20, v25, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v23, v25, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v22, v25, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v24, v25, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v25, v25, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v27, 0xffff0000, v12
	v_lshlrev_b32_e32 v26, 16, v12
	v_and_b32_e32 v29, 0xffff0000, v13
	v_lshlrev_b32_e32 v28, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v14
	v_lshlrev_b32_e32 v12, 16, v14
	v_lshlrev_b32_e32 v14, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v15
	v_pk_add_f32 v[26:27], v[10:11], v[26:27]
	v_pk_add_f32 v[20:21], v[20:21], v[28:29]
	v_pk_add_f32 v[22:23], v[22:23], v[12:13]
	v_pk_add_f32 v[24:25], v[24:25], v[14:15]
	v_cvt_pk_bf16_f32 v10, v26, v27
	v_cvt_pk_bf16_f32 v11, v20, v21
	v_cvt_pk_bf16_f32 v12, v22, v23
	v_cvt_pk_bf16_f32 v13, v24, v25
	v_and_b32_e32 v14, 0xffff0000, v10
	v_lshlrev_b32_e32 v15, 16, v10
	v_and_b32_e32 v28, 0xffff0000, v11
	v_lshlrev_b32_e32 v29, 16, v11
	v_and_b32_e32 v30, 0xffff0000, v12
	v_lshlrev_b32_e32 v31, 16, v12
	v_and_b32_e32 v32, 0xffff0000, v13
	v_lshlrev_b32_e32 v33, 16, v13
	global_store_dwordx4 v[16:17], v[10:13], off
	v_cndmask_b32_e64 v16, v15, v26, s[0:1]
	v_cndmask_b32_e64 v17, v14, v27, s[0:1]
	v_cndmask_b32_e64 v14, v29, v20, s[0:1]
	v_cndmask_b32_e64 v15, v28, v21, s[0:1]
	v_cndmask_b32_e64 v12, v31, v22, s[0:1]
	v_cndmask_b32_e64 v13, v30, v23, s[0:1]
	v_cndmask_b32_e64 v10, v33, v24, s[0:1]
	v_cndmask_b32_e64 v11, v32, v25, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB1_5
	s_branch .LBB1_6
.LBB1_4:
	s_mov_b64 vcc, 0
.LBB1_5:
	v_mov_b32_e32 v11, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v16, v11, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v17, v11, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v14, v11, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v15, v11, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v12, v11, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v13, v11, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v10, v11, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v11, v11, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB1_6:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[10:11], v[10:11]
	v_pk_mul_f32 v[2:3], v[12:13], v[12:13]
	v_pk_mul_f32 v[20:21], v[14:15], v[14:15]
	v_pk_mul_f32 v[22:23], v[16:17], v[16:17]
	s_nop 0
	v_add_f32_e32 v22, v22, v23
	v_add_f32_e32 v20, v22, v20
	v_add_f32_e32 v20, v20, v21
	v_add_f32_e32 v2, v20, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v56, v0, v1
.LBB1_7:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v28, s26, v54
	v_cmp_gt_i32_e32 vcc, s27, v28
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_13
	v_mov_b32_e32 v21, 0
	v_lshlrev_b32_e32 v20, 4, v28
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[20:21]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB1_10
	v_lshl_add_u64 v[22:23], v[18:19], 0, v[20:21]
	global_load_dwordx4 v[22:25], v[22:23], off
	v_mov_b32_e32 v29, 16
	v_lshl_add_u64 v[26:27], v[6:7], 0, v[20:21]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v21, v29, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v20, v29, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v31, v29, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v30, v29, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v33, v29, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v32, v29, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v34, v29, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v35, v29, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v37, 0xffff0000, v22
	v_lshlrev_b32_e32 v36, 16, v22
	v_and_b32_e32 v39, 0xffff0000, v23
	v_lshlrev_b32_e32 v38, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v24
	v_lshlrev_b32_e32 v22, 16, v24
	v_lshlrev_b32_e32 v24, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_pk_add_f32 v[36:37], v[20:21], v[36:37]
	v_pk_add_f32 v[30:31], v[30:31], v[38:39]
	v_pk_add_f32 v[32:33], v[32:33], v[22:23]
	v_pk_add_f32 v[34:35], v[34:35], v[24:25]
	v_cvt_pk_bf16_f32 v20, v36, v37
	v_cvt_pk_bf16_f32 v21, v30, v31
	v_cvt_pk_bf16_f32 v22, v32, v33
	v_cvt_pk_bf16_f32 v23, v34, v35
	v_and_b32_e32 v24, 0xffff0000, v20
	v_lshlrev_b32_e32 v25, 16, v20
	v_and_b32_e32 v29, 0xffff0000, v21
	v_lshlrev_b32_e32 v38, 16, v21
	v_and_b32_e32 v39, 0xffff0000, v22
	v_lshlrev_b32_e32 v40, 16, v22
	v_and_b32_e32 v41, 0xffff0000, v23
	v_lshlrev_b32_e32 v42, 16, v23
	global_store_dwordx4 v[26:27], v[20:23], off
	v_cndmask_b32_e64 v26, v25, v36, s[0:1]
	v_cndmask_b32_e64 v27, v24, v37, s[0:1]
	v_cndmask_b32_e64 v24, v38, v30, s[0:1]
	v_cndmask_b32_e64 v25, v29, v31, s[0:1]
	v_cndmask_b32_e64 v22, v40, v32, s[0:1]
	v_cndmask_b32_e64 v23, v39, v33, s[0:1]
	v_cndmask_b32_e64 v20, v42, v34, s[0:1]
	v_cndmask_b32_e64 v21, v41, v35, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB1_11
	s_branch .LBB1_12
.LBB1_10:
	s_mov_b64 vcc, 0
.LBB1_11:
	v_mov_b32_e32 v21, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v26, v21, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v27, v21, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v24, v21, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v25, v21, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v22, v21, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v23, v21, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v20, v21, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v21, v21, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB1_12:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[20:21], v[20:21]
	v_pk_mul_f32 v[2:3], v[22:23], v[22:23]
	v_pk_mul_f32 v[30:31], v[24:25], v[24:25]
	v_pk_mul_f32 v[32:33], v[26:27], v[26:27]
	s_nop 0
	v_add_f32_e32 v29, v56, v32
	v_add_f32_e32 v29, v29, v33
	v_add_f32_e32 v29, v29, v30
	v_add_f32_e32 v29, v29, v31
	v_add_f32_e32 v2, v29, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v56, v0, v1
.LBB1_13:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v36, s26, v28
	v_cmp_gt_i32_e32 vcc, s27, v36
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_19
	v_mov_b32_e32 v29, 0
	v_lshlrev_b32_e32 v28, 4, v36
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[28:29]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB1_16
	v_lshl_add_u64 v[30:31], v[18:19], 0, v[28:29]
	global_load_dwordx4 v[30:33], v[30:31], off
	v_mov_b32_e32 v37, 16
	v_lshl_add_u64 v[34:35], v[6:7], 0, v[28:29]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v29, v37, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v28, v37, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v39, v37, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v38, v37, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v41, v37, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v40, v37, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v42, v37, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v43, v37, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v45, 0xffff0000, v30
	v_lshlrev_b32_e32 v44, 16, v30
	v_and_b32_e32 v47, 0xffff0000, v31
	v_lshlrev_b32_e32 v46, 16, v31
	v_and_b32_e32 v31, 0xffff0000, v32
	v_lshlrev_b32_e32 v30, 16, v32
	v_lshlrev_b32_e32 v32, 16, v33
	v_and_b32_e32 v33, 0xffff0000, v33
	v_pk_add_f32 v[44:45], v[28:29], v[44:45]
	v_pk_add_f32 v[38:39], v[38:39], v[46:47]
	v_pk_add_f32 v[40:41], v[40:41], v[30:31]
	v_pk_add_f32 v[42:43], v[42:43], v[32:33]
	v_cvt_pk_bf16_f32 v28, v44, v45
	v_cvt_pk_bf16_f32 v29, v38, v39
	v_cvt_pk_bf16_f32 v30, v40, v41
	v_cvt_pk_bf16_f32 v31, v42, v43
	v_and_b32_e32 v32, 0xffff0000, v28
	v_lshlrev_b32_e32 v33, 16, v28
	v_and_b32_e32 v37, 0xffff0000, v29
	v_lshlrev_b32_e32 v46, 16, v29
	v_and_b32_e32 v47, 0xffff0000, v30
	v_lshlrev_b32_e32 v48, 16, v30
	v_and_b32_e32 v49, 0xffff0000, v31
	v_lshlrev_b32_e32 v50, 16, v31
	global_store_dwordx4 v[34:35], v[28:31], off
	v_cndmask_b32_e64 v34, v33, v44, s[0:1]
	v_cndmask_b32_e64 v35, v32, v45, s[0:1]
	v_cndmask_b32_e64 v32, v46, v38, s[0:1]
	v_cndmask_b32_e64 v33, v37, v39, s[0:1]
	v_cndmask_b32_e64 v30, v48, v40, s[0:1]
	v_cndmask_b32_e64 v31, v47, v41, s[0:1]
	v_cndmask_b32_e64 v28, v50, v42, s[0:1]
	v_cndmask_b32_e64 v29, v49, v43, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB1_17
	s_branch .LBB1_18
.LBB1_16:
	s_mov_b64 vcc, 0
.LBB1_17:
	v_mov_b32_e32 v29, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v34, v29, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v35, v29, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v32, v29, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v33, v29, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v30, v29, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v31, v29, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v28, v29, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v29, v29, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB1_18:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[28:29], v[28:29]
	v_pk_mul_f32 v[2:3], v[30:31], v[30:31]
	v_pk_mul_f32 v[38:39], v[32:33], v[32:33]
	v_pk_mul_f32 v[40:41], v[34:35], v[34:35]
	s_nop 0
	v_add_f32_e32 v37, v56, v40
	v_add_f32_e32 v37, v37, v41
	v_add_f32_e32 v37, v37, v38
	v_add_f32_e32 v37, v37, v39
	v_add_f32_e32 v2, v37, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v56, v0, v1
.LBB1_19:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v44, s26, v36
	v_cmp_gt_i32_e32 vcc, s27, v44
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_25
	v_mov_b32_e32 v37, 0
	v_lshlrev_b32_e32 v36, 4, v44
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[36:37]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB1_22
	v_lshl_add_u64 v[38:39], v[18:19], 0, v[36:37]
	global_load_dwordx4 v[38:41], v[38:39], off
	v_mov_b32_e32 v45, 16
	v_lshl_add_u64 v[42:43], v[6:7], 0, v[36:37]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_sdwa v37, v45, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v36, v45, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v47, v45, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v46, v45, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v49, v45, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v48, v45, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v50, v45, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v51, v45, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v53, 0xffff0000, v38
	v_lshlrev_b32_e32 v52, 16, v38
	v_and_b32_e32 v59, 0xffff0000, v39
	v_lshlrev_b32_e32 v58, 16, v39
	v_and_b32_e32 v39, 0xffff0000, v40
	v_lshlrev_b32_e32 v38, 16, v40
	v_lshlrev_b32_e32 v40, 16, v41
	v_and_b32_e32 v41, 0xffff0000, v41
	v_pk_add_f32 v[52:53], v[36:37], v[52:53]
	v_pk_add_f32 v[46:47], v[46:47], v[58:59]
	v_pk_add_f32 v[48:49], v[48:49], v[38:39]
	v_pk_add_f32 v[50:51], v[50:51], v[40:41]
	v_cvt_pk_bf16_f32 v36, v52, v53
	v_cvt_pk_bf16_f32 v37, v46, v47
	v_cvt_pk_bf16_f32 v38, v48, v49
	v_cvt_pk_bf16_f32 v39, v50, v51
	v_and_b32_e32 v40, 0xffff0000, v36
	v_lshlrev_b32_e32 v41, 16, v36
	v_and_b32_e32 v45, 0xffff0000, v37
	v_lshlrev_b32_e32 v57, 16, v37
	v_and_b32_e32 v58, 0xffff0000, v38
	v_lshlrev_b32_e32 v59, 16, v38
	v_and_b32_e32 v60, 0xffff0000, v39
	v_lshlrev_b32_e32 v61, 16, v39
	global_store_dwordx4 v[42:43], v[36:39], off
	v_cndmask_b32_e64 v42, v41, v52, s[0:1]
	v_cndmask_b32_e64 v43, v40, v53, s[0:1]
	v_cndmask_b32_e64 v40, v57, v46, s[0:1]
	v_cndmask_b32_e64 v41, v45, v47, s[0:1]
	v_cndmask_b32_e64 v38, v59, v48, s[0:1]
	v_cndmask_b32_e64 v39, v58, v49, s[0:1]
	v_cndmask_b32_e64 v36, v61, v50, s[0:1]
	v_cndmask_b32_e64 v37, v60, v51, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB1_23
	s_branch .LBB1_24
.LBB1_22:
	s_mov_b64 vcc, 0
.LBB1_23:
	v_mov_b32_e32 v37, 16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v42, v37, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v43, v37, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v40, v37, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v41, v37, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v38, v37, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v39, v37, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v36, v37, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v37, v37, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
.LBB1_24:
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[36:37], v[36:37]
	v_pk_mul_f32 v[2:3], v[38:39], v[38:39]
	v_pk_mul_f32 v[46:47], v[40:41], v[40:41]
	v_pk_mul_f32 v[48:49], v[42:43], v[42:43]
	s_nop 0
	v_add_f32_e32 v45, v56, v48
	v_add_f32_e32 v45, v45, v49
	v_add_f32_e32 v45, v45, v46
	v_add_f32_e32 v45, v45, v47
	v_add_f32_e32 v2, v45, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v56, v0, v1
.LBB1_25:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v57, s26, v44
	v_cmp_gt_i32_e32 vcc, s27, v57
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_33
	v_lshlrev_b32_e32 v44, 4, v57
	s_mov_b32 s21, 0
	v_mov_b32_e32 v45, 0
	s_lshl_b32 s20, s26, 4
	s_mov_b64 s[22:23], 0
	v_mov_b32_e32 v58, 16
	s_branch .LBB1_28
.LBB1_27:
	v_pk_mul_f32 v[0:1], v[52:53], v[52:53]
	v_pk_mul_f32 v[2:3], v[50:51], v[50:51]
	v_pk_mul_f32 v[48:49], v[48:49], v[48:49]
	v_pk_mul_f32 v[46:47], v[46:47], v[46:47]
	s_nop 0
	v_add_f32_e32 v46, v56, v46
	v_add_f32_e32 v46, v46, v47
	v_add_f32_e32 v46, v46, v48
	v_add_f32_e32 v46, v46, v49
	v_add_f32_e32 v2, v46, v2
	v_add_f32_e32 v2, v2, v3
	v_add_f32_e32 v0, v2, v0
	v_add_f32_e32 v56, v0, v1
	v_add_u32_e32 v57, s26, v57
	v_cmp_le_i32_e32 vcc, s27, v57
	s_or_b64 s[22:23], vcc, s[22:23]
	v_lshl_add_u64 v[44:45], v[44:45], 0, s[20:21]
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execz .LBB1_32
.LBB1_28:
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[44:45]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_mov_b64 s[24:25], -1
	s_and_b64 vcc, exec, s[10:11]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_sdwa v59, v58, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v64, v58, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v60, v58, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v65, v58, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v61, v58, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v66, v58, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v62, v58, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v63, v58, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	s_cbranch_vccnz .LBB1_30
	v_lshl_add_u64 v[46:47], v[18:19], 0, v[44:45]
	global_load_dwordx4 v[46:49], v[46:47], off
	v_lshlrev_b32_sdwa v51, v58, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v50, v58, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v53, v58, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v52, v58, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v1, v58, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshlrev_b32_sdwa v0, v58, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v2, v58, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_sdwa v3, v58, v3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
	v_lshl_add_u64 v[68:69], v[6:7], 0, v[44:45]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v71, 0xffff0000, v46
	v_lshlrev_b32_e32 v70, 16, v46
	v_and_b32_e32 v73, 0xffff0000, v47
	v_lshlrev_b32_e32 v72, 16, v47
	v_and_b32_e32 v47, 0xffff0000, v48
	v_lshlrev_b32_e32 v46, 16, v48
	v_lshlrev_b32_e32 v48, 16, v49
	v_and_b32_e32 v49, 0xffff0000, v49
	v_pk_add_f32 v[50:51], v[50:51], v[70:71]
	v_pk_add_f32 v[52:53], v[52:53], v[72:73]
	v_pk_add_f32 v[70:71], v[0:1], v[46:47]
	v_pk_add_f32 v[72:73], v[2:3], v[48:49]
	v_cvt_pk_bf16_f32 v0, v50, v51
	v_cvt_pk_bf16_f32 v1, v52, v53
	v_cvt_pk_bf16_f32 v2, v70, v71
	v_cvt_pk_bf16_f32 v3, v72, v73
	v_and_b32_e32 v47, 0xffff0000, v0
	v_lshlrev_b32_e32 v46, 16, v0
	v_and_b32_e32 v49, 0xffff0000, v1
	v_lshlrev_b32_e32 v48, 16, v1
	v_and_b32_e32 v67, 0xffff0000, v2
	v_lshlrev_b32_e32 v74, 16, v2
	v_and_b32_e32 v75, 0xffff0000, v3
	v_lshlrev_b32_e32 v76, 16, v3
	global_store_dwordx4 v[68:69], v[0:3], off
	v_cndmask_b32_e64 v46, v46, v50, s[0:1]
	v_cndmask_b32_e64 v47, v47, v51, s[0:1]
	v_cndmask_b32_e64 v48, v48, v52, s[0:1]
	v_cndmask_b32_e64 v49, v49, v53, s[0:1]
	v_cndmask_b32_e64 v50, v74, v70, s[0:1]
	v_cndmask_b32_e64 v51, v67, v71, s[0:1]
	v_cndmask_b32_e64 v52, v76, v72, s[0:1]
	v_cndmask_b32_e64 v53, v75, v73, s[0:1]
	s_mov_b64 s[24:25], 0
.LBB1_30:
	s_andn2_b64 vcc, exec, s[24:25]
	s_cbranch_vccnz .LBB1_27
	v_mov_b32_e32 v46, v64
	v_mov_b32_e32 v47, v59
	v_mov_b32_e32 v48, v65
	v_mov_b32_e32 v49, v60
	v_mov_b32_e32 v50, v66
	v_mov_b32_e32 v51, v61
	v_mov_b32_e32 v52, v62
	v_mov_b32_e32 v53, v63
	s_branch .LBB1_27
.LBB1_32:
	s_or_b64 exec, exec, s[22:23]
.LBB1_33:
	s_or_b64 exec, exec, s[8:9]
.LBB1_34:
	s_or_b64 exec, exec, s[4:5]
	v_mul_u32_u24_e32 v0, s26, v55
	s_barrier
	v_add_lshl_u32 v1, v0, v54, 2
	ds_write_b32 v1, v56
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cmp_lt_u32 s26, 2
	s_cbranch_scc1 .LBB1_39
	s_mov_b32 s8, s26
	s_branch .LBB1_37
.LBB1_36:
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cmp_gt_u32 s8, 3
	s_mov_b32 s8, s9
	s_cbranch_scc0 .LBB1_39
.LBB1_37:
	s_lshr_b32 s9, s8, 1
	v_cmp_gt_u32_e32 vcc, s9, v54
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_36
	v_lshl_add_u32 v2, s9, 2, v1
	ds_read_b32 v2, v2
	ds_read_b32 v3, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
	s_branch .LBB1_36
.LBB1_39:
	s_and_saveexec_b64 s[4:5], s[16:17]
	s_cbranch_execz .LBB1_51
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	v_cvt_f32_i32_e32 v1, s14
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v2, s[4:5], v1, v1, v0
	v_rcp_f32_e32 v3, v2
	v_div_scale_f32 v18, vcc, v0, v1, v0
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v19, -v2, v3, 1.0
	v_fmac_f32_e32 v3, v19, v3
	v_mul_f32_e32 v19, v18, v3
	v_fma_f32 v44, -v2, v19, v18
	v_fmac_f32_e32 v19, v44, v3
	v_fma_f32 v2, -v2, v19, v18
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v2, v2, v3, v19
	v_div_fixup_f32 v0, v2, v1, v0
	v_add_f32_e32 v0, s12, v0
	v_rsq_f32_e32 v0, v0
	v_lshl_add_u64 v[2:3], v[8:9], 1, s[2:3]
	v_cmp_gt_i32_e32 vcc, s27, v54
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_42
	v_lshlrev_b32_e32 v18, 4, v54
	global_load_dwordx4 v[44:47], v18, s[6:7]
	v_mov_b32_e32 v19, 0
	v_pk_mul_f32 v[8:9], v[0:1], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[0:1], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[0:1], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[0:1], v[10:11] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v1, v8, v9
	v_cvt_pk_bf16_f32 v16, v14, v15
	v_cvt_pk_bf16_f32 v17, v12, v13
	v_cvt_pk_bf16_f32 v48, v10, v11
	v_lshlrev_b32_e32 v49, 16, v1
	v_and_b32_e32 v1, 0xffff0000, v1
	v_lshlrev_b32_e32 v50, 16, v16
	v_and_b32_e32 v16, 0xffff0000, v16
	v_lshlrev_b32_e32 v51, 16, v17
	v_and_b32_e32 v17, 0xffff0000, v17
	v_lshlrev_b32_e32 v52, 16, v48
	v_and_b32_e32 v48, 0xffff0000, v48
	v_cndmask_b32_e64 v9, v1, v9, s[0:1]
	v_cndmask_b32_e64 v8, v49, v8, s[0:1]
	v_cndmask_b32_e64 v15, v16, v15, s[0:1]
	v_cndmask_b32_e64 v14, v50, v14, s[0:1]
	v_cndmask_b32_e64 v13, v17, v13, s[0:1]
	v_cndmask_b32_e64 v12, v51, v12, s[0:1]
	v_cndmask_b32_e64 v11, v48, v11, s[0:1]
	v_cndmask_b32_e64 v10, v52, v10, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v17, 0xffff0000, v44
	v_lshlrev_b32_e32 v16, 16, v44
	v_and_b32_e32 v49, 0xffff0000, v45
	v_lshlrev_b32_e32 v48, 16, v45
	v_and_b32_e32 v45, 0xffff0000, v46
	v_lshlrev_b32_e32 v44, 16, v46
	v_and_b32_e32 v51, 0xffff0000, v47
	v_lshlrev_b32_e32 v50, 16, v47
	v_pk_mul_f32 v[8:9], v[8:9], v[16:17]
	v_pk_mul_f32 v[14:15], v[14:15], v[48:49]
	v_pk_mul_f32 v[12:13], v[12:13], v[44:45]
	v_pk_mul_f32 v[16:17], v[10:11], v[50:51]
	v_cvt_pk_bf16_f32 v8, v8, v9
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v12, v13
	v_cvt_pk_bf16_f32 v11, v16, v17
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[18:19]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB1_42:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v54
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_44
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[20:21] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v18, v19
	v_cvt_pk_bf16_f32 v25, v20, v21
	v_lshlrev_b32_e32 v26, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v27, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v44, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v45, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v26, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v27, v16, s[0:1]
	v_cndmask_b32_e64 v19, v24, v19, s[0:1]
	v_cndmask_b32_e64 v18, v44, v18, s[0:1]
	v_cndmask_b32_e64 v21, v25, v21, s[0:1]
	v_cndmask_b32_e64 v20, v45, v20, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[18:19], v[8:9]
	v_pk_mul_f32 v[18:19], v[20:21], v[26:27]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB1_44:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_46
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[28:29] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v18, v19
	v_cvt_pk_bf16_f32 v25, v20, v21
	v_lshlrev_b32_e32 v26, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v27, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v28, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v29, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v26, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v27, v16, s[0:1]
	v_cndmask_b32_e64 v19, v24, v19, s[0:1]
	v_cndmask_b32_e64 v18, v28, v18, s[0:1]
	v_cndmask_b32_e64 v21, v25, v21, s[0:1]
	v_cndmask_b32_e64 v20, v29, v20, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[18:19], v[8:9]
	v_pk_mul_f32 v[18:19], v[20:21], v[26:27]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB1_46:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_48
	v_lshlrev_b32_e32 v12, 4, v1
	global_load_dwordx4 v[8:11], v12, s[6:7]
	v_mov_b32_e32 v13, 0
	v_pk_mul_f32 v[14:15], v[0:1], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[0:1], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[0:1], v[36:37] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v22, v14, v15
	v_cvt_pk_bf16_f32 v23, v16, v17
	v_cvt_pk_bf16_f32 v24, v18, v19
	v_cvt_pk_bf16_f32 v25, v20, v21
	v_lshlrev_b32_e32 v26, 16, v22
	v_and_b32_e32 v22, 0xffff0000, v22
	v_lshlrev_b32_e32 v27, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v23
	v_lshlrev_b32_e32 v28, 16, v24
	v_and_b32_e32 v24, 0xffff0000, v24
	v_lshlrev_b32_e32 v29, 16, v25
	v_and_b32_e32 v25, 0xffff0000, v25
	v_cndmask_b32_e64 v15, v22, v15, s[0:1]
	v_cndmask_b32_e64 v14, v26, v14, s[0:1]
	v_cndmask_b32_e64 v17, v23, v17, s[0:1]
	v_cndmask_b32_e64 v16, v27, v16, s[0:1]
	v_cndmask_b32_e64 v19, v24, v19, s[0:1]
	v_cndmask_b32_e64 v18, v28, v18, s[0:1]
	v_cndmask_b32_e64 v21, v25, v21, s[0:1]
	v_cndmask_b32_e64 v20, v29, v20, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_and_b32_e32 v25, 0xffff0000, v9
	v_lshlrev_b32_e32 v24, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v27, 0xffff0000, v11
	v_lshlrev_b32_e32 v26, 16, v11
	v_pk_mul_f32 v[10:11], v[14:15], v[22:23]
	v_pk_mul_f32 v[14:15], v[16:17], v[24:25]
	v_pk_mul_f32 v[16:17], v[18:19], v[8:9]
	v_pk_mul_f32 v[18:19], v[20:21], v[26:27]
	v_cvt_pk_bf16_f32 v8, v10, v11
	v_cvt_pk_bf16_f32 v9, v14, v15
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[12:13]
	global_store_dwordx4 v[12:13], v[8:11], off
.LBB1_48:
	s_or_b64 exec, exec, s[2:3]
	s_nop 0
	v_add_u32_e32 v8, s26, v1
	v_cmp_gt_i32_e32 vcc, s27, v8
	s_and_b64 exec, exec, vcc
	s_cbranch_execz .LBB1_51
	v_cndmask_b32_e64 v5, v7, v5, s[18:19]
	v_cndmask_b32_e64 v4, v6, v4, s[18:19]
	v_mov_b32_e32 v1, v0
	v_lshlrev_b32_e32 v6, 4, v8
	s_mov_b32 s3, 0
	v_mov_b32_e32 v7, 0
	s_lshl_b32 s2, s26, 4
	s_mov_b64 s[4:5], 0
.LBB1_50:
	v_lshl_add_u64 v[10:11], v[4:5], 0, v[6:7]
	v_lshl_add_u64 v[14:15], s[6:7], 0, v[6:7]
	global_load_dwordx4 v[10:13], v[10:11], off
	global_load_dwordx4 v[14:17], v[14:15], off
	v_lshl_add_u64 v[18:19], v[2:3], 0, v[6:7]
	v_add_u32_e32 v8, s26, v8
	v_lshl_add_u64 v[6:7], v[6:7], 0, s[2:3]
	v_cmp_le_i32_e32 vcc, s27, v8
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v21, 0xffff0000, v10
	v_lshlrev_b32_e32 v20, 16, v10
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v23, 0xffff0000, v14
	v_lshlrev_b32_e32 v22, 16, v14
	v_and_b32_e32 v25, 0xffff0000, v11
	v_lshlrev_b32_e32 v24, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v12
	v_lshlrev_b32_e32 v14, 16, v12
	v_and_b32_e32 v27, 0xffff0000, v16
	v_lshlrev_b32_e32 v26, 16, v16
	v_and_b32_e32 v29, 0xffff0000, v13
	v_lshlrev_b32_e32 v28, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v17
	v_lshlrev_b32_e32 v12, 16, v17
	v_pk_mul_f32 v[16:17], v[0:1], v[20:21]
	v_pk_mul_f32 v[20:21], v[0:1], v[24:25]
	v_pk_mul_f32 v[14:15], v[0:1], v[14:15]
	v_pk_mul_f32 v[24:25], v[0:1], v[28:29]
	v_cvt_pk_bf16_f32 v9, v16, v17
	v_cvt_pk_bf16_f32 v28, v20, v21
	v_cvt_pk_bf16_f32 v29, v14, v15
	v_cvt_pk_bf16_f32 v30, v24, v25
	v_lshlrev_b32_e32 v31, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v9
	v_lshlrev_b32_e32 v32, 16, v28
	v_and_b32_e32 v28, 0xffff0000, v28
	v_lshlrev_b32_e32 v33, 16, v29
	v_and_b32_e32 v29, 0xffff0000, v29
	v_lshlrev_b32_e32 v34, 16, v30
	v_and_b32_e32 v30, 0xffff0000, v30
	v_cndmask_b32_e64 v17, v9, v17, s[0:1]
	v_cndmask_b32_e64 v16, v31, v16, s[0:1]
	v_cndmask_b32_e64 v21, v28, v21, s[0:1]
	v_cndmask_b32_e64 v20, v32, v20, s[0:1]
	v_cndmask_b32_e64 v15, v29, v15, s[0:1]
	v_cndmask_b32_e64 v14, v33, v14, s[0:1]
	v_cndmask_b32_e64 v25, v30, v25, s[0:1]
	v_cndmask_b32_e64 v24, v34, v24, s[0:1]
	v_pk_mul_f32 v[16:17], v[16:17], v[22:23]
	v_pk_mul_f32 v[20:21], v[20:21], v[10:11]
	v_pk_mul_f32 v[14:15], v[14:15], v[26:27]
	v_pk_mul_f32 v[22:23], v[24:25], v[12:13]
	v_cvt_pk_bf16_f32 v10, v16, v17
	v_cvt_pk_bf16_f32 v11, v20, v21
	v_cvt_pk_bf16_f32 v12, v14, v15
	v_cvt_pk_bf16_f32 v13, v22, v23
	global_store_dwordx4 v[18:19], v[10:13], off
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB1_50
.LBB1_51:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii
		.amdhsa_group_segment_fixed_size 4096
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 320
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 77
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 80
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_tg_split 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.section	.text._ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii,"axG",@progbits,_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii,comdat
.Lfunc_end1:
	.size	_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii, .Lfunc_end1-_ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii

	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.num_vgpr, 77
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.num_agpr, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.numbered_sgpr, 28
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.private_seg_size, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.uses_vcc, 1
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.uses_flat_scratch, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.has_recursion, 0
	.set _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_92344108f1a8475b,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_92344108f1a8475b
__hip_cuid_92344108f1a8475b:
	.byte	0
	.size	__hip_cuid_92344108f1a8475b, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_92344108f1a8475b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         68
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         76
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         78
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         80
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         82
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         84
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         86
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         128
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 4096
    .kernarg_segment_align: 8
    .kernarg_segment_size: 320
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb0EEEvPvPKvS5_S3_S3_fiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     75
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         68
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         76
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         78
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         80
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         82
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         84
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         86
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         128
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 4096
    .kernarg_segment_align: 8
    .kernarg_segment_size: 320
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter19rmsnorm_opus_kernelINS_19rmsnorm_opus_traitsIDF16bLi8ELb0EEELb1EEEvPvPKvS5_S3_S3_fiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     77
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
