	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2 ; -- Begin function _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2
	.p2align	8
	.type	_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2,@function
_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2: ; @_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.55:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/normalization" "rmsnorm.py"
	.loc	1 1018 0 prologue_end           ; rmsnorm.py:1018:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.56:
.LBB0_0:
.Ltmp1:
	.loc	1 1036 28 is_stmt 1             ; rmsnorm.py:1036:28
	s_lshl_b32 s13, s16, 5
	.loc	1 1036 51 is_stmt 0             ; rmsnorm.py:1036:51
	v_lshrrev_b32_e32 v20, 7, v0
	.loc	1 1036 38                       ; rmsnorm.py:1036:38
	v_or_b32_e32 v13, s13, v20
	.loc	1 1037 33 is_stmt 1             ; rmsnorm.py:1037:33
	v_and_b32_e32 v1, 0x7f, v0
	.loc	1 1039 21                       ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e32 vcc, s8, v13
	.loc	1 1040 21                       ; rmsnorm.py:1040:21
	v_cmp_gt_i32_e64 s[18:19], s9, v1
	.loc	1 1037 43                       ; rmsnorm.py:1037:43
	v_mov_b32_e32 v8, 0
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 vcc, vcc, s[18:19]
	v_lshlrev_b32_e32 v2, 2, v1
	v_mov_b32_e32 v14, 0
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_2
; %bb.1:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[14:15], s11, v13, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v14, v[4:5], off
.LBB0_2:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v21, 4, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v12, s13, v21
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v12
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[14:15], s[0:1], s[18:19]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[14:15]
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[16:17], s11, v12, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v8, v[4:5], off
.LBB0_4:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v22, 8, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v10, s13, v22
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v10
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[22:23], s[0:1], s[18:19]
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v15, 0
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[22:23]
	s_cbranch_execz .LBB0_6
; %bb.5:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[16:17], s11, v10, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v15, v[4:5], off
.LBB0_6:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v23, 12, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v9, s13, v23
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v9
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[24:25], s[0:1], s[18:19]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[24:25]
	s_cbranch_execz .LBB0_8
; %bb.7:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[16:17], s11, v9, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v11, v[4:5], off
.LBB0_8:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v24, 16, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v7, s13, v24
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v7
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[26:27], s[0:1], s[18:19]
	v_mov_b32_e32 v28, 0
	v_mov_b32_e32 v16, 0
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[26:27]
	s_cbranch_execz .LBB0_10
; %bb.9:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[16:17], s11, v7, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v16, v[4:5], off
.LBB0_10:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v25, 20, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v6, s13, v25
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v6
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[16:17], s[0:1], s[18:19]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[16:17]
	s_cbranch_execz .LBB0_12
; %bb.11:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[4:5], s[20:21], s11, v6, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v28, v[4:5], off
.LBB0_12:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v26, 24, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v4, s13, v26
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v4
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[20:21], s[0:1], s[18:19]
	v_mov_b32_e32 v29, 0
	v_mov_b32_e32 v30, 0
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[0:1], s[20:21]
	s_cbranch_execz .LBB0_14
; %bb.13:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[18:19], s[28:29], s11, v4, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[18:19], v[18:19], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v30, v[18:19], off
.LBB0_14:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 1036 51 is_stmt 1             ; rmsnorm.py:1036:51
	v_or_b32_e32 v27, 28, v20
	.loc	1 1036 38 is_stmt 0             ; rmsnorm.py:1036:38
	v_or_b32_e32 v1, s13, v27
	.loc	1 1039 21 is_stmt 1             ; rmsnorm.py:1039:21
	v_cmp_gt_i32_e64 s[0:1], s8, v1
	.loc	1 1041 29                       ; rmsnorm.py:1041:29
	s_and_b64 s[0:1], s[0:1], s[18:19]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	s_and_saveexec_b64 s[28:29], s[0:1]
	s_cbranch_execz .LBB0_16
; %bb.15:
	.loc	1 1044 29 is_stmt 0             ; rmsnorm.py:1044:29
	v_mad_i64_i32 v[18:19], s[30:31], s11, v1, 0
	.loc	1 1044 12                       ; rmsnorm.py:1044:12
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[2:3]
	.loc	1 1044 41                       ; rmsnorm.py:1044:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[18:19], v[18:19], 0, v[2:3]
	.loc	1 1044 8                        ; rmsnorm.py:1044:8
	global_load_dword v29, v[18:19], off
.LBB0_16:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[28:29]
	v_mov_b32_e32 v5, 0
	.loc	1 1048 16 is_stmt 1             ; rmsnorm.py:1048:16
	s_and_saveexec_b64 s[2:3], s[18:19]
	s_cbranch_execz .LBB0_18
; %bb.17:
	global_load_dword v5, v2, s[6:7]
.LBB0_18:
	.loc	1 0 16 is_stmt 0                ; rmsnorm.py:0:16
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1050 26 is_stmt 1             ; rmsnorm.py:1050:26
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e32 v31, 0, v14, vcc
	v_cndmask_b32_e64 v18, 0, v15, s[22:23]
	v_cndmask_b32_e64 v15, 0, v28, s[16:17]
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v28, v31, v31
	.loc	1 1050 26                       ; rmsnorm.py:1050:26
	v_cndmask_b32_e64 v19, 0, v8, s[14:15]
	v_cndmask_b32_e64 v8, 0, v29, s[0:1]
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_dpp v28, v28 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v31, v31
.Ltmp3:
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v29, v19, v19
	.loc	1 1050 26                       ; rmsnorm.py:1050:26
	v_cndmask_b32_e64 v17, 0, v11, s[24:25]
.Ltmp4:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp5:
	.loc	1 1050 26                       ; rmsnorm.py:1050:26
	v_cndmask_b32_e64 v11, 0, v30, s[20:21]
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v30, v18, v18
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp7:
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v32, v17, v17
	.loc	1 1050 26                       ; rmsnorm.py:1050:26
	v_cndmask_b32_e64 v16, 0, v16, s[26:27]
.Ltmp8:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v31, v28
.Ltmp9:
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v33, v16, v16
	v_mul_f32_e32 v34, v15, v15
.Ltmp10:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_dpp v31, v31 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v31
.Ltmp11:
	.loc	1 1051 24                       ; rmsnorm.py:1051:24
	v_mul_f32_e32 v35, v11, v11
	v_mul_f32_e32 v36, v8, v8
.Ltmp12:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp13:
	.loc	1 1036 51                       ; rmsnorm.py:1036:51
	v_and_b32_e32 v3, 63, v0
.Ltmp14:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_readlane_b32 s30, v28, 63
	v_mov_b32_dpp v28, v29 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v19, v19
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_cmp_eq_u32_e64 s[2:3], 0, v3
	v_lshlrev_b32_e32 v3, 1, v20
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s29, v28, 63
	v_mov_b32_dpp v28, v30 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v18, v18
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s28, v28, 63
	v_mov_b32_dpp v28, v32 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v17, v17
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s19, v28, 63
	v_mov_b32_dpp v28, v33 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v16, v16
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s18, v28, 63
	v_mov_b32_dpp v28, v34 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v15, v15
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s13, v28, 63
	v_mov_b32_dpp v28, v35 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v11, v11
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s11, v28, 63
	v_mov_b32_dpp v28, v36 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_fmac_f32_e32 v28, v8, v8
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, v28
	s_nop 1
	v_mov_b32_dpp v29, v29 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:1051:20 ]
	v_add_f32_e32 v28, v28, v29
	s_nop 1
	v_add_f32_dpp v28, v28, v28 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_nop 0
	v_readlane_b32 s8, v28, 63
	v_bfe_u32 v28, v0, 6, 1
	v_lshlrev_b32_e32 v28, 2, v28
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_40
; %bb.19:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v20, 1, v21
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_41
.LBB0_20:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v21, 1, v22
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_42
.LBB0_21:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v22, 1, v23
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_43
.LBB0_22:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v23, 1, v24
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_44
.LBB0_23:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v24, 1, v25
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_45
.LBB0_24:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v25, 1, v26
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_46
.LBB0_25:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshlrev_b32_e32 v26, 1, v27
	s_and_saveexec_b64 s[6:7], s[2:3]
.LBB0_26:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v27, 2, v26
	v_add3_u32 v27, 0, v27, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v28, s8
	ds_write_b32 v27, v28
.LBB0_27:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_cmp_gt_u32_e64 s[2:3], 64, v0
	v_lshl_add_u32 v27, v0, 2, 0
	v_mov_b32_e32 v28, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[2:3]
; %bb.28:
	ds_read_b32 v28, v27
; %bb.29:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v29, v28
	v_and_b32_e32 v0, 0x1c1, v0
	v_cmp_eq_u32_e64 s[2:3], 0, v0
	v_mov_b32_dpp v29, v29 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[6:7], s[2:3]
; %bb.30:
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v0, v28, v29
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	ds_write_b32 v27, v0
; %bb.31:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshl_add_u32 v0, v20, 2, 0
	v_lshl_add_u32 v20, v21, 2, 0
	v_lshl_add_u32 v21, v22, 2, 0
	v_lshl_add_u32 v22, v23, 2, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_lshl_add_u32 v27, v24, 2, 0
	v_lshl_add_u32 v28, v25, 2, 0
	v_lshl_add_u32 v29, v26, 2, 0
	ds_read_b32 v26, v0
	ds_read_b32 v25, v20
	ds_read_b32 v24, v21
	ds_read_b32 v23, v22
	ds_read_b32 v22, v27
	ds_read_b32 v21, v28
	ds_read_b32 v0, v29
.Ltmp15:
	.loc	1 1052 19 is_stmt 1             ; rmsnorm.py:1052:19
	v_cvt_f32_i32_e32 v20, s9
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execnz .LBB0_47
; %bb.32:
	.loc	1 0 8 is_stmt 0                 ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[14:15]
	s_cbranch_execnz .LBB0_48
.LBB0_33:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[22:23]
	s_cbranch_execnz .LBB0_49
.LBB0_34:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[24:25]
	s_cbranch_execnz .LBB0_50
.LBB0_35:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[26:27]
	s_cbranch_execnz .LBB0_51
.LBB0_36:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[16:17]
	s_cbranch_execnz .LBB0_52
.LBB0_37:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[20:21]
	s_cbranch_execnz .LBB0_53
.LBB0_38:
	.loc	1 0 8                           ; rmsnorm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_54
.LBB0_39:
	.loc	1 1062 4 is_stmt 1              ; rmsnorm.py:1062:4
	s_endpgm
.LBB0_40:
	.loc	1 0 4 is_stmt 0                 ; rmsnorm.py:0:4
	v_lshlrev_b32_e32 v20, 2, v3
	v_add3_u32 v20, 0, v20, v28
.Ltmp16:
	.loc	2 291 36 is_stmt 1              ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s30
	ds_write_b32 v20, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v20, 1, v21
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_20
.LBB0_41:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	v_lshlrev_b32_e32 v21, 2, v20
	v_add3_u32 v21, 0, v21, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s29
	ds_write_b32 v21, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v21, 1, v22
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_21
.LBB0_42:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v22, 2, v21
	v_add3_u32 v22, 0, v22, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s28
	ds_write_b32 v22, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v22, 1, v23
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_22
.LBB0_43:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v23, 2, v22
	v_add3_u32 v23, 0, v23, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s19
	ds_write_b32 v23, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v23, 1, v24
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_23
.LBB0_44:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v24, 2, v23
	v_add3_u32 v24, 0, v24, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s18
	ds_write_b32 v24, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v24, 1, v25
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_24
.LBB0_45:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v25, 2, v24
	v_add3_u32 v25, 0, v25, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s13
	ds_write_b32 v25, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v25, 1, v26
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_25
.LBB0_46:
	.loc	2 0 36                          ; standard.py:0:36
	v_lshlrev_b32_e32 v26, 2, v25
	v_add3_u32 v26, 0, v26, v28
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_mov_b32_e32 v29, s11
	ds_write_b32 v26, v29
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v26, 1, v27
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execnz .LBB0_26
	s_branch .LBB0_27
.LBB0_47:
	.loc	2 291 36 is_stmt 1              ; standard.py:291:36 @[ rmsnorm.py:1051:20 ]
	v_lshl_add_u32 v3, v3, 2, 0
	ds_read_b32 v3, v3
.Ltmp17:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v27, s[6:7], v20, v20, v3
	v_rcp_f32_e32 v28, v27
	v_div_scale_f32 v29, vcc, v3, v20, v3
	v_fma_f32 v30, -v27, v28, 1.0
	v_fmac_f32_e32 v28, v30, v28
	v_mul_f32_e32 v30, v29, v28
	v_fma_f32 v31, -v27, v30, v29
	v_fmac_f32_e32 v30, v31, v28
	v_fma_f32 v27, -v27, v30, v29
	v_div_fmas_f32 v27, v27, v28, v30
	v_div_fixup_f32 v3, v27, v20, v3
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v27, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[28:29], s[6:7], s12, v13, 0
	.loc	1 1057 41 is_stmt 0             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	.loc	1 1057 12                       ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v13, v14, v27
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v13, v5, v13
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_lshl_add_u64 v[28:29], v[28:29], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[28:29], v13, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[14:15]
	s_cbranch_execz .LBB0_33
.LBB0_48:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(6)
	v_div_scale_f32 v3, s[6:7], v20, v20, v26
	v_rcp_f32_e32 v13, v3
	v_div_scale_f32 v14, vcc, v26, v20, v26
	v_fma_f32 v27, -v3, v13, 1.0
	v_fmac_f32_e32 v13, v27, v13
	v_mul_f32_e32 v27, v14, v13
	v_fma_f32 v28, -v3, v27, v14
	v_fmac_f32_e32 v27, v28, v13
	v_fma_f32 v3, -v3, v27, v14
	v_div_fmas_f32 v3, v3, v13, v27
	v_div_fixup_f32 v3, v3, v20, v26
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[12:13], s[6:7], s12, v12, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v19, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v14, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[12:13], v14, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[22:23]
	s_cbranch_execz .LBB0_34
.LBB0_49:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(5)
	v_div_scale_f32 v3, s[6:7], v20, v20, v25
	v_rcp_f32_e32 v12, v3
	v_div_scale_f32 v13, vcc, v25, v20, v25
	v_fma_f32 v14, -v3, v12, 1.0
	v_fmac_f32_e32 v12, v14, v12
	v_mul_f32_e32 v14, v13, v12
	v_fma_f32 v19, -v3, v14, v13
	v_fmac_f32_e32 v14, v19, v12
	v_fma_f32 v3, -v3, v14, v13
	v_div_fmas_f32 v3, v3, v12, v14
	v_div_fixup_f32 v3, v3, v20, v25
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[12:13], s[6:7], s12, v10, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v18, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v10, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[12:13], v10, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[24:25]
	s_cbranch_execz .LBB0_35
.LBB0_50:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(4)
	v_div_scale_f32 v3, s[6:7], v20, v20, v24
	v_rcp_f32_e32 v10, v3
	v_div_scale_f32 v12, vcc, v24, v20, v24
	v_fma_f32 v13, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v13, v10
	v_mul_f32_e32 v13, v12, v10
	v_fma_f32 v14, -v3, v13, v12
	v_fmac_f32_e32 v13, v14, v10
	v_fma_f32 v3, -v3, v13, v12
	v_div_fmas_f32 v3, v3, v10, v13
	v_div_fixup_f32 v3, v3, v20, v24
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[12:13], s[6:7], s12, v9, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v17, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v9, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[12:13], v9, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[26:27]
	s_cbranch_execz .LBB0_36
.LBB0_51:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(3)
	v_div_scale_f32 v3, s[6:7], v20, v20, v23
	v_rcp_f32_e32 v9, v3
	v_div_scale_f32 v10, vcc, v23, v20, v23
	v_fma_f32 v12, -v3, v9, 1.0
	v_fmac_f32_e32 v9, v12, v9
	v_mul_f32_e32 v12, v10, v9
	v_fma_f32 v13, -v3, v12, v10
	v_fmac_f32_e32 v12, v13, v9
	v_fma_f32 v3, -v3, v12, v10
	v_div_fmas_f32 v3, v3, v9, v12
	v_div_fixup_f32 v3, v3, v20, v23
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[12:13], s[6:7], s12, v7, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v16, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v7, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[12:13], v7, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[16:17]
	s_cbranch_execz .LBB0_37
.LBB0_52:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(2)
	v_div_scale_f32 v3, s[6:7], v20, v20, v22
	v_rcp_f32_e32 v7, v3
	v_div_scale_f32 v9, vcc, v22, v20, v22
	v_fma_f32 v10, -v3, v7, 1.0
	v_fmac_f32_e32 v7, v10, v7
	v_mul_f32_e32 v10, v9, v7
	v_fma_f32 v12, -v3, v10, v9
	v_fmac_f32_e32 v10, v12, v7
	v_fma_f32 v3, -v3, v10, v9
	v_div_fmas_f32 v3, v3, v7, v10
	v_div_fixup_f32 v3, v3, v20, v22
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[6:7], s[6:7], s12, v6, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v15, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v9, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[6:7], v[6:7], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[6:7], v9, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[20:21]
	s_cbranch_execz .LBB0_38
.LBB0_53:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(1)
	v_div_scale_f32 v3, s[6:7], v20, v20, v21
	v_rcp_f32_e32 v6, v3
	v_div_scale_f32 v7, vcc, v21, v20, v21
	v_fma_f32 v9, -v3, v6, 1.0
	v_fmac_f32_e32 v6, v9, v6
	v_mul_f32_e32 v9, v7, v6
	v_fma_f32 v10, -v3, v9, v7
	v_fmac_f32_e32 v9, v10, v6
	v_fma_f32 v3, -v3, v9, v7
	v_div_fmas_f32 v3, v3, v6, v9
	v_div_fixup_f32 v3, v3, v20, v21
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v3, s10, v3
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v3
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[6:7], s[6:7], s12, v4, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v11, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v4, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[6:7], v[6:7], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[6:7], v4, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_39
.LBB0_54:
	.loc	1 1052 19                       ; rmsnorm.py:1052:19
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v3, s[0:1], v20, v20, v0
	v_rcp_f32_e32 v4, v3
	v_div_scale_f32 v6, vcc, v0, v20, v0
	v_fma_f32 v7, -v3, v4, 1.0
	v_fmac_f32_e32 v4, v7, v4
	v_mul_f32_e32 v7, v6, v4
	v_fma_f32 v9, -v3, v7, v6
	v_fmac_f32_e32 v7, v9, v4
	v_fma_f32 v3, -v3, v7, v6
	v_div_fmas_f32 v3, v3, v4, v7
	v_div_fixup_f32 v0, v3, v20, v0
	.loc	1 1053 33                       ; rmsnorm.py:1053:33
	v_add_f32_e32 v0, s10, v0
	.loc	1 1053 27 is_stmt 0             ; rmsnorm.py:1053:27
	v_rsq_f32_e32 v3, v0
	.loc	1 1057 29 is_stmt 1             ; rmsnorm.py:1057:29
	v_mad_i64_i32 v[0:1], s[0:1], s12, v1, 0
	.loc	1 1057 12 is_stmt 0             ; rmsnorm.py:1057:12
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[4:5]
	.loc	1 1055 12 is_stmt 1             ; rmsnorm.py:1055:12
	v_mul_f32_e32 v3, v8, v3
	.loc	1 1055 30 is_stmt 0             ; rmsnorm.py:1055:30
	v_mul_f32_e32 v4, v5, v3
	.loc	1 1057 41 is_stmt 1             ; rmsnorm.py:1057:41
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	.loc	1 1058 8                        ; rmsnorm.py:1058:8
	global_store_dword v[0:1], v4, off
	.loc	1 1062 4                        ; rmsnorm.py:1062:4
	s_endpgm
.Ltmp18:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 64
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
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 37
		.amdhsa_next_free_sgpr 32
		.amdhsa_accum_offset 40
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_xnack_mask 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
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
	.text
.Lfunc_end0:
	.size	_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2, .Lfunc_end0-_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2
	.cfi_endproc
                                        ; -- End function
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.num_vgpr, 37
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.num_agpr, 0
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.numbered_sgpr, 32
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.private_seg_size, 0
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.uses_vcc, 1
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.uses_flat_scratch, 0
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.has_dyn_sized_stack, 0
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.has_recursion, 0
	.set _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 3580
; TotalNumSgprs: 38
; NumVgprs: 37
; NumAgprs: 0
; TotalNumVgprs: 37
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 4
; NumSGPRsForWavesPerEU: 38
; NumVGPRsForWavesPerEU: 37
; AccumOffset: 40
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 9
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.section	.debug_abbrev,"",@progbits
	.byte	1                               ; Abbreviation Code
	.byte	17                              ; DW_TAG_compile_unit
	.byte	1                               ; DW_CHILDREN_yes
	.byte	37                              ; DW_AT_producer
	.byte	14                              ; DW_FORM_strp
	.byte	19                              ; DW_AT_language
	.byte	5                               ; DW_FORM_data2
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	16                              ; DW_AT_stmt_list
	.byte	23                              ; DW_FORM_sec_offset
	.byte	27                              ; DW_AT_comp_dir
	.byte	14                              ; DW_FORM_strp
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	2                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	0                               ; DW_CHILDREN_no
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	32                              ; DW_AT_inline
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	3                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	1                               ; DW_CHILDREN_yes
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	4                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	0                               ; DW_CHILDREN_no
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x45 DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x1f DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	1051                            ; DW_AT_call_line
	.byte	20                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"rmsnorm.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=18
.Linfo_string3:
	.asciz	"_rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2" ; string offset=77
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 64
    .max_flat_workgroup_size: 512
    .name:           _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2
    .private_segment_fixed_size: 0
    .sgpr_count:     38
    .sgpr_spill_count: 0
    .symbol:         _rmsnorm_kernel_large_m_small_n_BLOCK_M_32_BLOCK_N_128_NUM_WARPS_8_NUM_STAGES_2.kd
    .uses_dynamic_stack: false
    .vgpr_count:     37
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa--gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
	.section	.debug_line,"",@progbits
.Lline_table_start0:
