	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1 ; -- Begin function _gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
	.p2align	8
	.type	_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1,@function
_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1: ; @_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "splitk_reduce.py"
	.loc	1 22 0 prologue_end             ; splitk_reduce.py:22:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.2:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[0:1], s[2:3]
.Ltmp1:
	.loc	1 56 14 is_stmt 1               ; splitk_reduce.py:56:14
	s_abs_i32 s3, s8
	v_cvt_f32_u32_e32 v1, s3
	.loc	1 56 38 is_stmt 0               ; splitk_reduce.py:56:38
	v_readfirstlane_b32 s2, v0
	.loc	1 89 5 is_stmt 1                ; splitk_reduce.py:89:5
	s_and_b32 s2, s2, 0xc0
	s_mov_b64 s[20:21], s[6:7]
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_rcp_f32_e32 v1, v1
	.loc	1 56 38 is_stmt 0               ; splitk_reduce.py:56:38
	v_and_or_b32 v2, v0, 56, s2
	.loc	1 56 15                         ; splitk_reduce.py:56:15
	s_lshl_b32 s6, s16, 5
	.loc	1 56 38                         ; splitk_reduce.py:56:38
	v_lshrrev_b32_e32 v2, 3, v2
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	.loc	1 56 15                         ; splitk_reduce.py:56:15
	v_or_b32_e32 v2, s6, v2
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	s_sub_i32 s6, 0, s3
	s_bfe_i32 s2, s16, 0x1001a
	v_mul_lo_u32 v3, s6, v1
	v_add_u32_e32 v2, s2, v2
	v_mul_hi_u32 v3, v1, v3
	v_xor_b32_e32 v2, s2, v2
	v_add_u32_e32 v1, v1, v3
	v_mul_hi_u32 v1, v2, v1
	v_mul_lo_u32 v1, v1, s3
	.loc	1 57 14 is_stmt 1               ; splitk_reduce.py:57:14
	s_abs_i32 s6, s9
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_sub_u32_e32 v1, v2, v1
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	v_cvt_f32_u32_e32 v3, s6
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_subrev_u32_e32 v2, s3, v1
	v_cmp_le_u32_e32 vcc, s3, v1
	.loc	1 56 38 is_stmt 0               ; splitk_reduce.py:56:38
	v_lshlrev_b32_e32 v0, 2, v0
	.loc	1 67 13 is_stmt 1               ; splitk_reduce.py:67:13
	s_and_b32 s1, s1, 0xffff
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_subrev_u32_e32 v2, s3, v1
	v_cmp_le_u32_e32 vcc, s3, v1
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	s_sub_i32 s3, 0, s6
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	s_lshl_b32 s7, s10, 3
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_cndmask_b32_e32 v1, v1, v2, vcc
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	v_rcp_f32_e32 v2, v3
	.loc	1 56 14                         ; splitk_reduce.py:56:14
	v_xor_b32_e32 v1, s2, v1
	v_subrev_u32_e32 v1, s2, v1
	.loc	1 57 15                         ; splitk_reduce.py:57:15
	s_lshl_b32 s2, s17, 5
	.loc	1 57 14 is_stmt 0               ; splitk_reduce.py:57:14
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	.loc	1 57 15                         ; splitk_reduce.py:57:15
	v_and_or_b32 v0, v0, 28, s2
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	s_bfe_i32 s2, s17, 0x1001a
	v_add_u32_e32 v0, s2, v0
	v_mul_lo_u32 v3, s3, v2
	v_mul_hi_u32 v3, v2, v3
	v_xor_b32_e32 v0, s2, v0
	v_add_u32_e32 v2, v2, v3
	v_mul_hi_u32 v2, v0, v2
	v_mul_lo_u32 v2, v2, s6
	v_sub_u32_e32 v0, v0, v2
	v_subrev_u32_e32 v2, s6, v0
	v_cmp_le_u32_e32 vcc, s6, v0
	.loc	1 74 16 is_stmt 1               ; splitk_reduce.py:74:16
	s_and_b32 s21, s21, 0xffff
	.loc	1 89 5                          ; splitk_reduce.py:89:5
	s_and_b32 s5, s5, 0xffff
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	v_cndmask_b32_e32 v0, v0, v2, vcc
	v_subrev_u32_e32 v2, s6, v0
	v_cmp_le_u32_e32 vcc, s6, v0
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	s_lshl_b32 s6, s10, 1
	.loc	1 57 14                         ; splitk_reduce.py:57:14
	s_nop 0
	v_cndmask_b32_e32 v0, v0, v2, vcc
	v_xor_b32_e32 v0, s2, v0
	v_subrev_u32_e32 v0, s2, v0
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_mad_u64_u32 v[2:3], s[2:3], v1, s11, v[0:1]
	v_add_u32_e32 v10, s10, v2
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	s_mov_b32 s3, 0x27000
	s_mov_b32 s2, 0x7ffffffe
	v_lshlrev_b32_e32 v11, 2, v2
	v_lshlrev_b32_e32 v12, 2, v10
	buffer_load_dwordx4 v[2:5], v11, s[0:3], 0 offen
	buffer_load_dwordx4 v[6:9], v12, s[0:3], 0 offen
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v10, s6, v10
	v_add_u32_e32 v19, s6, v10
	v_add_u32_e32 v27, s10, v19
	v_add_u32_e32 v29, s10, v27
	v_add_u32_e32 v35, s6, v29
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	v_add_u32_e32 v18, s7, v11
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v43, s10, v35
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	v_add_u32_e32 v26, s7, v18
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v45, s10, v43
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	v_lshlrev_b32_e32 v20, 2, v10
	buffer_load_dwordx4 v[10:13], v18, s[0:3], 0 offen
	buffer_load_dwordx4 v[14:17], v20, s[0:3], 0 offen
	v_lshlrev_b32_e32 v28, 2, v19
	v_lshl_add_u32 v42, s10, 4, v26
	v_lshlrev_b32_e32 v34, 2, v27
	v_lshlrev_b32_e32 v36, 2, v29
	v_lshlrev_b32_e32 v44, 2, v35
	v_lshlrev_b32_e32 v50, 2, v43
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v51, s10, v45
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	buffer_load_dwordx4 v[18:21], v26, s[0:3], 0 offen
	buffer_load_dwordx4 v[22:25], v28, s[0:3], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[26:29], v34, s[0:3], 0 offen
	buffer_load_dwordx4 v[30:33], v36, s[0:3], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[34:37], v42, s[0:3], 0 offen
	buffer_load_dwordx4 v[38:41], v44, s[0:3], 0 offen
	v_lshlrev_b32_e32 v52, 2, v45
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v54, s10, v51
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	buffer_load_dwordx4 v[42:45], v50, s[0:3], 0 offen
	buffer_load_dwordx4 v[46:49], v52, s[0:3], 0 offen
	v_lshlrev_b32_e32 v55, 2, v51
	v_lshlrev_b32_e32 v56, 2, v54
	.loc	1 60 9                          ; splitk_reduce.py:60:9
	v_add_u32_e32 v54, s10, v54
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	v_add_lshl_u32 v57, v54, s10, 2
	.loc	1 74 16                         ; splitk_reduce.py:74:16
	s_mov_b32 s22, s2
	s_mov_b32 s23, s3
	.loc	1 84 9                          ; splitk_reduce.py:84:9
	v_mul_lo_u32 v1, v1, s12
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12                        ; standard.py:314:12 @[ splitk_reduce.py:70:9 ]
	s_waitcnt vmcnt(10)
	v_pk_add_f32 v[50:51], v[2:3], v[6:7]
	v_pk_add_f32 v[52:53], v[4:5], v[8:9]
.Ltmp3:
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	buffer_load_dwordx4 v[2:5], v55, s[0:3], 0 offen
	buffer_load_dwordx4 v[6:9], v56, s[0:3], 0 offen
	v_lshlrev_b32_e32 v56, 2, v54
.Ltmp4:
	.loc	2 314 12                        ; standard.py:314:12 @[ splitk_reduce.py:70:9 ]
	s_waitcnt vmcnt(10)
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	v_pk_add_f32 v[54:55], v[12:13], v[16:17]
	s_waitcnt vmcnt(8)
	v_pk_add_f32 v[12:13], v[18:19], v[22:23]
	s_waitcnt vmcnt(6)
	v_pk_add_f32 v[14:15], v[26:27], v[30:31]
	s_waitcnt vmcnt(4)
	v_pk_add_f32 v[16:17], v[34:35], v[38:39]
	v_pk_add_f32 v[18:19], v[50:51], v[10:11]
	v_pk_add_f32 v[22:23], v[12:13], v[14:15]
	s_waitcnt vmcnt(2)
	v_pk_add_f32 v[10:11], v[42:43], v[46:47]
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	v_pk_add_f32 v[6:7], v[16:17], v[10:11]
.Ltmp5:
	.loc	1 67 13                         ; splitk_reduce.py:67:13
	buffer_load_dwordx4 v[10:13], v56, s[0:3], 0 offen
	buffer_load_dwordx4 v[14:17], v57, s[0:3], 0 offen
.Ltmp6:
	.loc	2 314 12                        ; standard.py:314:12 @[ splitk_reduce.py:70:9 ]
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	s_mov_b32 s0, 0xbfb8aa3b
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	v_pk_add_f32 v[8:9], v[12:13], v[16:17]
	v_pk_add_f32 v[2:3], v[2:3], v[10:11]
	v_pk_add_f32 v[10:11], v[18:19], v[22:23]
	v_pk_add_f32 v[2:3], v[6:7], v[2:3]
.Ltmp7:
	.loc	1 74 16                         ; splitk_reduce.py:74:16
	v_lshlrev_b32_e32 v6, 1, v0
	buffer_load_dwordx2 v[6:7], v6, s[20:23], 0 offen
.Ltmp8:
	.loc	2 314 12                        ; standard.py:314:12 @[ splitk_reduce.py:70:9 ]
	v_pk_add_f32 v[2:3], v[10:11], v[2:3]
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	v_pk_add_f32 v[10:11], v[20:21], v[24:25]
	v_pk_add_f32 v[14:15], v[28:29], v[32:33]
	v_pk_add_f32 v[18:19], v[36:37], v[40:41]
	v_pk_add_f32 v[20:21], v[44:45], v[48:49]
	v_pk_add_f32 v[12:13], v[52:53], v[54:55]
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	v_pk_add_f32 v[14:15], v[18:19], v[20:21]
	v_pk_add_f32 v[10:11], v[12:13], v[10:11]
	v_pk_add_f32 v[4:5], v[14:15], v[4:5]
.Ltmp9:
	.loc	1 89 5                          ; splitk_reduce.py:89:5
	v_add_lshl_u32 v0, v1, v0, 1
.Ltmp10:
	.loc	2 314 12                        ; standard.py:314:12 @[ splitk_reduce.py:70:9 ]
	v_pk_add_f32 v[4:5], v[10:11], v[4:5]
.Ltmp11:
	.loc	1 74 16                         ; splitk_reduce.py:74:16
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v17, 0xffff0000, v6
	v_lshlrev_b32_e32 v16, 16, v6
	.loc	1 76 9                          ; splitk_reduce.py:76:9
	v_pk_add_f32 v[2:3], v[2:3], v[16:17]
.Ltmp12:
	.file	3 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "activation.py"
	.loc	3 7 31                          ; activation.py:7:31 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	s_nop 0
	v_pk_mul_f32 v[16:17], v[2:3], s[0:1] op_sel_hi:[1,0]
	.loc	3 7 23 is_stmt 0                ; activation.py:7:23 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	s_nop 0
	v_exp_f32_e32 v16, v16
	v_exp_f32_e32 v17, v17
	.loc	3 7 17                          ; activation.py:7:17 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	s_nop 0
	v_pk_add_f32 v[8:9], v[16:17], 1.0 op_sel_hi:[1,0]
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	s_nop 0
	v_div_scale_f32 v6, s[6:7], v9, v9, v3
	v_rcp_f32_e32 v16, v6
	s_nop 0
	v_fma_f32 v10, -v6, v16, 1.0
	v_fmac_f32_e32 v16, v10, v16
	v_div_scale_f32 v10, vcc, v3, v9, v3
	v_mul_f32_e32 v11, v10, v16
	v_fma_f32 v12, -v6, v11, v10
	v_fmac_f32_e32 v11, v12, v16
	v_div_scale_f32 v12, s[6:7], v8, v8, v2
	v_rcp_f32_e32 v13, v12
	v_fma_f32 v6, -v6, v11, v10
	v_div_fmas_f32 v6, v6, v16, v11
.Ltmp13:
	.loc	1 74 16 is_stmt 1               ; splitk_reduce.py:74:16
	v_and_b32_e32 v11, 0xffff0000, v7
	v_lshlrev_b32_e32 v10, 16, v7
.Ltmp14:
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_div_fixup_f32 v3, v6, v9, v3
	v_fma_f32 v6, -v12, v13, 1.0
.Ltmp15:
	.loc	1 76 9                          ; splitk_reduce.py:76:9
	v_pk_add_f32 v[4:5], v[4:5], v[10:11]
.Ltmp16:
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_fmac_f32_e32 v13, v6, v13
	.loc	3 7 31 is_stmt 0                ; activation.py:7:31 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_pk_mul_f32 v[6:7], v[4:5], s[0:1] op_sel_hi:[1,0]
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_div_scale_f32 v9, vcc, v2, v8, v2
	.loc	3 7 23                          ; activation.py:7:23 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_exp_f32_e32 v6, v6
	v_exp_f32_e32 v7, v7
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_mul_f32_e32 v14, v9, v13
	v_fma_f32 v10, -v12, v14, v9
	v_fmac_f32_e32 v14, v10, v13
	.loc	3 7 17                          ; activation.py:7:17 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_fma_f32 v9, -v12, v14, v9
	v_div_scale_f32 v10, s[0:1], v7, v7, v5
	v_rcp_f32_e32 v11, v10
	v_div_fmas_f32 v9, v9, v13, v14
	v_div_fixup_f32 v2, v9, v8, v2
.Ltmp17:
	.loc	1 81 9 is_stmt 1                ; splitk_reduce.py:81:9
	v_cvt_pk_bf16_f32 v2, v2, v3
.Ltmp18:
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_fma_f32 v8, -v10, v11, 1.0
	v_fmac_f32_e32 v11, v8, v11
	v_div_scale_f32 v8, vcc, v5, v7, v5
	v_mul_f32_e32 v9, v8, v11
	v_fma_f32 v12, -v10, v9, v8
	v_fmac_f32_e32 v9, v12, v11
	v_fma_f32 v8, -v10, v9, v8
	v_div_scale_f32 v10, s[0:1], v6, v6, v4
	v_rcp_f32_e32 v12, v10
	v_div_fmas_f32 v8, v8, v11, v9
	v_div_fixup_f32 v5, v8, v7, v5
.Ltmp19:
	.loc	1 89 5                          ; splitk_reduce.py:89:5
	s_mov_b32 s6, s2
.Ltmp20:
	.loc	3 7 12                          ; activation.py:7:12 @[ activation.py:12:12 @[ splitk_reduce.py:79:13 ] ]
	v_fma_f32 v7, -v10, v12, 1.0
	v_fmac_f32_e32 v12, v7, v12
	v_div_scale_f32 v7, vcc, v4, v6, v4
	v_mul_f32_e32 v8, v7, v12
	v_fma_f32 v9, -v10, v8, v7
	v_fmac_f32_e32 v8, v9, v12
	v_fma_f32 v7, -v10, v8, v7
	v_div_fmas_f32 v7, v7, v12, v8
	v_div_fixup_f32 v4, v7, v6, v4
.Ltmp21:
	.loc	1 81 9                          ; splitk_reduce.py:81:9
	v_cvt_pk_bf16_f32 v3, v4, v5
	.loc	1 89 5                          ; splitk_reduce.py:89:5
	s_mov_b32 s7, s3
	buffer_store_dwordx2 v[2:3], v0, s[4:7], 0 offen
	.loc	1 22 1                          ; splitk_reduce.py:22:1
	s_endpgm
.Ltmp22:
.Lfunc_end0:
	.size	_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1, .Lfunc_end0-_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 58
		.amdhsa_next_free_sgpr 24
		.amdhsa_accum_offset 60
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
                                        ; -- End function
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.num_vgpr, 58
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.num_agpr, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.numbered_sgpr, 24
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.num_named_barrier, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.private_seg_size, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.uses_vcc, 1
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.uses_flat_scratch, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.has_dyn_sized_stack, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.has_recursion, 0
	.set .L_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1608
; TotalNumSgprs: 30
; NumVgprs: 58
; NumAgprs: 0
; TotalNumVgprs: 58
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 3
; VGPRBlocks: 7
; NumSGPRsForWavesPerEU: 30
; NumVGPRsForWavesPerEU: 58
; AccumOffset: 60
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 14
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
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
	.ascii	"\341\177"                      ; DW_AT_APPLE_optimized
	.byte	25                              ; DW_FORM_flag_present
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
	.byte	11                              ; DW_FORM_data1
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	5                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	11                              ; DW_FORM_data1
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
	.byte	1                               ; Abbrev [1] 0xb:0x5d DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
                                        ; DW_AT_APPLE_optimized
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x37 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	70                              ; DW_AT_call_line
	.byte	9                               ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x4d:0x19 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	79                              ; DW_AT_call_line
	.byte	13                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x59:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	3                               ; DW_AT_call_file
	.byte	12                              ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
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
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"splitk_reduce.py"              ; string offset=7 ; splitk_reduce.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/common" ; string offset=24 ; /work/aiter/aiter/ops/triton/_triton_kernels/common
.Linfo_string3:
	.asciz	"_gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1" ; string offset=76 ; _gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
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
    .max_flat_workgroup_size: 256
    .name:           _gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1
    .private_segment_fixed_size: 0
    .sgpr_count:     30
    .sgpr_spill_count: 0
    .symbol:         _gemm_a16w16_reduce_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_ACTUAL_KSPLIT_16_MAX_KSPLIT_16_ADD_BIAS_1_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__SILU_use_activation_1.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     58
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
