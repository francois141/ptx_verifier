	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0 ; -- Begin function _gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
	.p2align	8
	.type	_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0,@function
_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0: ; @_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.9:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/gemm/basic" "gemm_a16w16.py"
	.loc	1 46 0 prologue_end             ; gemm_a16w16.py:46:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.10:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[20:21], s[2:3]
.Ltmp1:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 43 13 is_stmt 1               ; standard.py:43:13 @[ gemm_a16w16.py:93:17 ]
	s_add_i32 s2, s10, 31
	.loc	2 43 12 is_stmt 0               ; standard.py:43:12 @[ gemm_a16w16.py:93:17 ]
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 27
	s_add_i32 s2, s2, s3
.Ltmp2:
	.loc	2 43 13                         ; standard.py:43:13 @[ gemm_a16w16.py:94:17 ]
	s_add_i32 s3, s11, 31
	s_mov_b64 s[24:25], s[6:7]
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:94:17 ]
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 27
	s_add_i32 s3, s3, s6
.Ltmp3:
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:93:17 ]
	s_ashr_i32 s2, s2, 5
.Ltmp4:
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:94:17 ]
	s_ashr_i32 s6, s3, 5
.Ltmp5:
	.loc	1 96 22 is_stmt 1               ; gemm_a16w16.py:96:22
	s_mul_i32 s2, s6, s2
.Ltmp6:
	.file	3 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "pid_preprocessing.py"
	.loc	3 32 21                         ; pid_preprocessing.py:32:21 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s3, s2, 7
	.loc	3 32 20 is_stmt 0               ; pid_preprocessing.py:32:20 @[ gemm_a16w16.py:95:19 ]
	s_ashr_i32 s7, s3, 31
	s_lshr_b32 s7, s7, 29
	s_add_i32 s3, s3, s7
	s_mov_b32 s18, s11
	s_ashr_i32 s11, s3, 3
	.loc	3 37 17 is_stmt 1               ; pid_preprocessing.py:37:17 @[ gemm_a16w16.py:95:19 ]
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 29
	s_add_i32 s3, s2, s3
	s_and_b32 s3, s3, -8
	s_sub_i32 s2, s2, s3
	.loc	3 38 5                          ; pid_preprocessing.py:38:5 @[ gemm_a16w16.py:95:19 ]
	s_cmp_lg_u32 s2, 0
	s_cselect_b32 s2, s2, 8
	.loc	3 42 17                         ; pid_preprocessing.py:42:17 @[ gemm_a16w16.py:95:19 ]
	s_ashr_i32 s3, s16, 31
	s_lshr_b32 s3, s3, 29
	s_add_i32 s7, s16, s3
	.loc	3 41 11                         ; pid_preprocessing.py:41:11 @[ gemm_a16w16.py:95:19 ]
	s_and_b32 s3, s7, -8
	s_sub_i32 s17, s16, s3
	.loc	3 47 8                          ; pid_preprocessing.py:47:8 @[ gemm_a16w16.py:95:19 ]
	s_cmp_ge_i32 s17, s2
.Ltmp7:
	.loc	1 184 13                        ; gemm_a16w16.py:184:13
	v_readfirstlane_b32 s15, v0
.Ltmp8:
	.loc	3 47 5                          ; pid_preprocessing.py:47:5 @[ gemm_a16w16.py:95:19 ]
	s_cbranch_scc0 .LBB0_2
; %bb.1:
	.loc	3 51 13                         ; pid_preprocessing.py:51:13 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s3, s2, s11
	.loc	3 52 16                         ; pid_preprocessing.py:52:16 @[ gemm_a16w16.py:95:19 ]
	s_sub_i32 s2, s17, s2
	.loc	3 52 36 is_stmt 0               ; pid_preprocessing.py:52:36 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s16, s11, -1
	.loc	3 52 15                         ; pid_preprocessing.py:52:15 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s2, s2, s16
	.loc	3 51 13 is_stmt 1               ; pid_preprocessing.py:51:13 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s16, s2, s3
	s_mov_b64 s[2:3], 0
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s2, 1
	s_cbranch_scc0 .LBB0_3
	s_branch .LBB0_4
.LBB0_2:
	.loc	3 0 13 is_stmt 0                ; pid_preprocessing.py:0:13
	s_mov_b64 s[2:3], -1
                                        ; implicit-def: $sgpr16
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s2, 1
	s_cbranch_scc1 .LBB0_4
.LBB0_3:
	.loc	3 48 15 is_stmt 1               ; pid_preprocessing.py:48:15 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s16, s11, s17
.Ltmp9:
.LBB0_4:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_abs_i32 s2, s6
	v_cvt_f32_u32_e32 v1, s2
.Ltmp10:
	.loc	1 112 8                         ; gemm_a16w16.py:112:8
	s_cmp_lt_i32 s12, 1
.Ltmp11:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s3, v1
.Ltmp12:
	.loc	1 112 5                         ; gemm_a16w16.py:112:5
	s_cbranch_scc1 .LBB0_8
; %bb.5:
.Ltmp13:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_sub_i32 s19, 0, s2
	s_ashr_i32 s7, s7, 3
	s_mul_i32 s19, s19, s3
.Ltmp14:
	.loc	3 0 0 is_stmt 0                 ; pid_preprocessing.py:0 @[ gemm_a16w16.py:0 ]
	s_add_i32 s7, s16, s7
.Ltmp15:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_mul_hi_u32 s19, s3, s19
	s_abs_i32 s17, s7
	s_add_i32 s3, s3, s19
	s_ashr_i32 s11, s7, 31
	s_ashr_i32 s16, s6, 31
	s_mul_hi_u32 s3, s17, s3
	s_xor_b32 s11, s11, s16
	s_mul_i32 s16, s3, s2
	s_sub_i32 s16, s17, s16
	s_add_i32 s17, s3, 1
	s_sub_i32 s19, s16, s2
	s_cmp_ge_u32 s16, s2
	s_cselect_b32 s3, s17, s3
	s_cselect_b32 s16, s19, s16
	s_add_i32 s17, s3, 1
	s_cmp_ge_u32 s16, s2
	s_cselect_b32 s2, s17, s3
	s_xor_b32 s2, s2, s11
	s_sub_i32 s16, s2, s11
	.loc	3 72 17 is_stmt 1               ; pid_preprocessing.py:72:17 @[ gemm_a16w16.py:102:24 ]
	s_mul_i32 s2, s16, s6
.Ltmp16:
	.loc	1 184 13                        ; gemm_a16w16.py:184:13
	s_bfe_u32 s6, s15, 0x30006
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	v_and_b32_e32 v2, 63, v0
	s_lshl_b32 s6, s6, 6
	v_or_b32_e32 v1, s6, v2
	v_lshrrev_b32_e32 v3, 2, v1
	.loc	1 120 23 is_stmt 0              ; gemm_a16w16.py:120:23
	s_abs_i32 s27, s10
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	v_and_b32_e32 v9, 28, v3
	.loc	1 120 23                        ; gemm_a16w16.py:120:23
	v_cvt_f32_u32_e32 v3, s27
	.loc	1 184 13 is_stmt 1              ; gemm_a16w16.py:184:13
	s_lshr_b32 s3, s15, 6
.Ltmp17:
	.loc	3 72 17                         ; pid_preprocessing.py:72:17 @[ gemm_a16w16.py:102:24 ]
	s_sub_i32 s2, s7, s2
.Ltmp18:
	.loc	1 120 24                        ; gemm_a16w16.py:120:24
	s_lshl_b32 s7, s16, 5
	.loc	1 120 23 is_stmt 0              ; gemm_a16w16.py:120:23
	v_rcp_f32_e32 v3, v3
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	s_bfe_u32 s29, s3, 0x20001
	.loc	1 120 24                        ; gemm_a16w16.py:120:24
	s_or_b32 s11, s7, s29
	.loc	1 120 23                        ; gemm_a16w16.py:120:23
	s_bfe_i32 s39, s16, 0x1001a
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	s_or_b32 s30, s29, 4
	s_or_b32 s31, s29, 8
	s_or_b32 s33, s29, 12
	s_or_b32 s34, s29, 16
	s_or_b32 s35, s29, 20
	s_or_b32 s36, s29, 24
	s_or_b32 s28, s29, 28
	.loc	1 120 23                        ; gemm_a16w16.py:120:23
	s_add_i32 s11, s11, s39
	.loc	1 120 24                        ; gemm_a16w16.py:120:24
	s_or_b32 s17, s7, s30
	s_or_b32 s19, s7, s31
	s_or_b32 s22, s7, s33
	s_or_b32 s23, s7, s34
	s_or_b32 s26, s7, s35
	s_or_b32 s37, s7, s36
	s_or_b32 s38, s7, s28
	.loc	1 120 23                        ; gemm_a16w16.py:120:23
	s_xor_b32 s7, s11, s39
	s_sub_i32 s11, 0, s27
	v_readfirstlane_b32 s40, v3
	s_mul_i32 s11, s11, s40
	s_mul_hi_u32 s11, s40, s11
	s_add_i32 s40, s40, s11
	s_mul_hi_u32 s11, s7, s40
	s_mul_i32 s11, s11, s27
	s_sub_i32 s7, s7, s11
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	s_and_b32 s3, s6, 0x80
	.loc	1 120 23                        ; gemm_a16w16.py:120:23
	s_sub_i32 s11, s7, s27
	s_cmp_ge_u32 s7, s27
	s_cselect_b32 s7, s11, s7
	s_sub_i32 s11, s7, s27
	s_cmp_ge_u32 s7, s27
	s_cselect_b32 s7, s11, s7
	s_add_i32 s17, s17, s39
	s_xor_b32 s11, s17, s39
	s_mul_hi_u32 s17, s11, s40
	s_mul_i32 s17, s17, s27
	s_xor_b32 s7, s7, s39
	s_sub_i32 s11, s11, s17
	s_sub_i32 s7, s7, s39
	s_sub_i32 s17, s11, s27
	s_cmp_ge_u32 s11, s27
	s_cselect_b32 s11, s17, s11
	s_sub_i32 s17, s11, s27
	s_cmp_ge_u32 s11, s27
	s_cselect_b32 s11, s17, s11
	s_add_i32 s19, s19, s39
	s_xor_b32 s17, s19, s39
	s_mul_hi_u32 s19, s17, s40
	s_mul_i32 s19, s19, s27
	s_xor_b32 s11, s11, s39
	s_sub_i32 s17, s17, s19
	s_sub_i32 s11, s11, s39
	s_sub_i32 s19, s17, s27
	s_cmp_ge_u32 s17, s27
	s_cselect_b32 s17, s19, s17
	s_sub_i32 s19, s17, s27
	s_cmp_ge_u32 s17, s27
	s_cselect_b32 s17, s19, s17
	s_add_i32 s22, s22, s39
	s_xor_b32 s19, s22, s39
	s_mul_hi_u32 s22, s19, s40
	s_mul_i32 s22, s22, s27
	s_xor_b32 s17, s17, s39
	s_sub_i32 s19, s19, s22
	s_sub_i32 s17, s17, s39
	s_sub_i32 s22, s19, s27
	s_cmp_ge_u32 s19, s27
	s_cselect_b32 s19, s22, s19
	s_sub_i32 s22, s19, s27
	s_cmp_ge_u32 s19, s27
	s_cselect_b32 s19, s22, s19
	s_add_i32 s23, s23, s39
	s_xor_b32 s22, s23, s39
	s_mul_hi_u32 s23, s22, s40
	s_mul_i32 s23, s23, s27
	s_xor_b32 s19, s19, s39
	s_sub_i32 s22, s22, s23
	s_sub_i32 s19, s19, s39
	s_sub_i32 s23, s22, s27
	s_cmp_ge_u32 s22, s27
	s_cselect_b32 s22, s23, s22
	s_sub_i32 s23, s22, s27
	s_cmp_ge_u32 s22, s27
	s_cselect_b32 s22, s23, s22
	s_add_i32 s26, s26, s39
	s_xor_b32 s23, s26, s39
	s_mul_hi_u32 s26, s23, s40
	s_mul_i32 s26, s26, s27
	s_xor_b32 s22, s22, s39
	s_sub_i32 s23, s23, s26
	s_sub_i32 s22, s22, s39
	s_sub_i32 s26, s23, s27
	s_cmp_ge_u32 s23, s27
	s_cselect_b32 s23, s26, s23
	s_sub_i32 s26, s23, s27
	s_cmp_ge_u32 s23, s27
	s_cselect_b32 s23, s26, s23
	s_add_i32 s37, s37, s39
	s_xor_b32 s26, s37, s39
	s_mul_hi_u32 s37, s26, s40
	s_mul_i32 s37, s37, s27
	s_xor_b32 s23, s23, s39
	s_sub_i32 s26, s26, s37
	s_sub_i32 s23, s23, s39
	s_sub_i32 s37, s26, s27
	s_cmp_ge_u32 s26, s27
	s_cselect_b32 s26, s37, s26
	s_sub_i32 s37, s26, s27
	s_cmp_ge_u32 s26, s27
	s_cselect_b32 s26, s37, s26
	s_add_i32 s38, s38, s39
	s_xor_b32 s37, s38, s39
	s_mul_hi_u32 s38, s37, s40
	s_mul_i32 s38, s38, s27
	s_xor_b32 s26, s26, s39
	s_sub_i32 s37, s37, s38
	s_sub_i32 s26, s26, s39
	s_sub_i32 s38, s37, s27
	s_cmp_ge_u32 s37, s27
	s_cselect_b32 s37, s38, s37
	s_sub_i32 s38, s37, s27
	s_cmp_ge_u32 s37, s27
	s_cselect_b32 s27, s38, s37
	.loc	1 121 24 is_stmt 1              ; gemm_a16w16.py:121:24
	s_lshl_b32 s37, s2, 5
	s_or_b32 s38, s37, s31
	.loc	1 121 23 is_stmt 0              ; gemm_a16w16.py:121:23
	s_abs_i32 s31, s18
	v_cvt_f32_u32_e32 v3, s31
	.loc	1 120 23 is_stmt 1              ; gemm_a16w16.py:120:23
	s_xor_b32 s27, s27, s39
	s_sub_i32 s27, s27, s39
	.loc	1 121 24                        ; gemm_a16w16.py:121:24
	s_or_b32 s29, s37, s29
	.loc	1 121 23 is_stmt 0              ; gemm_a16w16.py:121:23
	v_rcp_f32_e32 v11, v3
	.loc	1 121 24                        ; gemm_a16w16.py:121:24
	s_or_b32 s39, s37, s33
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_bfe_i32 s33, s2, 0x1001a
	.loc	1 120 47 is_stmt 1              ; gemm_a16w16.py:120:47
	v_or_b32_e32 v8, 1, v9
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	v_mul_f32_e32 v11, 0x4f7ffffe, v11
	v_cvt_u32_f32_e32 v11, v11
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	v_or_b32_e32 v7, 2, v9
	v_or_b32_e32 v6, 3, v9
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_add_i32 s29, s29, s33
	.loc	1 121 24 is_stmt 0              ; gemm_a16w16.py:121:24
	s_or_b32 s30, s37, s30
	s_or_b32 s40, s37, s34
	s_or_b32 s41, s37, s35
	s_or_b32 s42, s37, s36
	s_or_b32 s43, s37, s28
	v_or_b32_e32 v10, s37, v9
	v_or_b32_e32 v5, s37, v8
	v_or_b32_e32 v4, s37, v7
	v_or_b32_e32 v3, s37, v6
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_xor_b32 s28, s29, s33
	s_sub_i32 s29, 0, s31
	v_readfirstlane_b32 s37, v11
	s_mul_i32 s29, s29, s37
	s_mul_hi_u32 s29, s37, s29
	s_add_i32 s37, s37, s29
	s_mul_hi_u32 s29, s28, s37
	s_mul_i32 s29, s29, s31
	s_sub_i32 s28, s28, s29
	s_sub_i32 s29, s28, s31
	s_cmp_ge_u32 s28, s31
	s_cselect_b32 s28, s29, s28
	s_sub_i32 s29, s28, s31
	s_cmp_ge_u32 s28, s31
	s_cselect_b32 s28, s29, s28
	s_add_i32 s30, s30, s33
	s_xor_b32 s29, s30, s33
	s_mul_hi_u32 s30, s29, s37
	s_mul_i32 s30, s30, s31
	s_xor_b32 s28, s28, s33
	s_sub_i32 s29, s29, s30
	s_sub_i32 s28, s28, s33
	s_sub_i32 s30, s29, s31
	s_cmp_ge_u32 s29, s31
	s_cselect_b32 s29, s30, s29
	s_sub_i32 s30, s29, s31
	s_cmp_ge_u32 s29, s31
	s_cselect_b32 s29, s30, s29
	s_add_i32 s38, s38, s33
	s_xor_b32 s30, s38, s33
	s_mul_hi_u32 s34, s30, s37
	s_mul_i32 s34, s34, s31
	s_xor_b32 s29, s29, s33
	s_sub_i32 s30, s30, s34
	s_sub_i32 s29, s29, s33
	s_sub_i32 s34, s30, s31
	s_cmp_ge_u32 s30, s31
	s_cselect_b32 s30, s34, s30
	s_sub_i32 s34, s30, s31
	s_cmp_ge_u32 s30, s31
	s_cselect_b32 s30, s34, s30
	s_add_i32 s39, s39, s33
	s_xor_b32 s34, s39, s33
	s_mul_hi_u32 s35, s34, s37
	s_mul_i32 s35, s35, s31
	s_xor_b32 s30, s30, s33
	s_sub_i32 s34, s34, s35
	s_sub_i32 s30, s30, s33
	s_sub_i32 s35, s34, s31
	s_cmp_ge_u32 s34, s31
	s_cselect_b32 s34, s35, s34
	s_sub_i32 s35, s34, s31
	s_cmp_ge_u32 s34, s31
	s_cselect_b32 s34, s35, s34
	s_add_i32 s40, s40, s33
	s_xor_b32 s35, s40, s33
	s_mul_hi_u32 s36, s35, s37
	s_mul_i32 s36, s36, s31
	s_xor_b32 s34, s34, s33
	s_sub_i32 s35, s35, s36
	s_sub_i32 s34, s34, s33
	s_sub_i32 s36, s35, s31
	v_add_u32_e32 v10, s33, v10
	s_cmp_ge_u32 s35, s31
	v_xor_b32_e32 v10, s33, v10
	s_cselect_b32 s35, s36, s35
	v_mul_hi_u32 v11, v10, s37
	s_sub_i32 s36, s35, s31
	v_mul_lo_u32 v11, v11, s31
	s_cmp_ge_u32 s35, s31
	v_sub_u32_e32 v10, v10, v11
	s_cselect_b32 s35, s36, s35
	s_add_i32 s41, s41, s33
	v_cmp_le_u32_e32 vcc, s31, v10
	v_subrev_u32_e32 v11, s31, v10
	s_xor_b32 s36, s41, s33
	v_cndmask_b32_e32 v10, v10, v11, vcc
	s_mul_hi_u32 s38, s36, s37
	v_cmp_le_u32_e32 vcc, s31, v10
	v_subrev_u32_e32 v11, s31, v10
	s_mul_i32 s38, s38, s31
	v_cndmask_b32_e32 v10, v10, v11, vcc
	v_add_u32_e32 v5, s33, v5
	s_xor_b32 s35, s35, s33
	s_sub_i32 s36, s36, s38
	v_xor_b32_e32 v10, s33, v10
	v_xor_b32_e32 v5, s33, v5
	s_sub_i32 s35, s35, s33
	s_sub_i32 s38, s36, s31
	v_subrev_u32_e32 v16, s33, v10
	v_mul_hi_u32 v10, v5, s37
	s_cmp_ge_u32 s36, s31
	v_mul_lo_u32 v10, v10, s31
	s_cselect_b32 s36, s38, s36
	v_sub_u32_e32 v5, v5, v10
	s_sub_i32 s38, s36, s31
	v_cmp_le_u32_e32 vcc, s31, v5
	v_subrev_u32_e32 v10, s31, v5
	s_cmp_ge_u32 s36, s31
	v_cndmask_b32_e32 v5, v5, v10, vcc
	s_cselect_b32 s36, s38, s36
	s_add_i32 s42, s42, s33
	v_cmp_le_u32_e32 vcc, s31, v5
	v_subrev_u32_e32 v10, s31, v5
	s_xor_b32 s38, s42, s33
	v_cndmask_b32_e32 v5, v5, v10, vcc
	v_add_u32_e32 v4, s33, v4
	s_mul_hi_u32 s39, s38, s37
	v_xor_b32_e32 v5, s33, v5
	v_xor_b32_e32 v4, s33, v4
	s_mul_i32 s39, s39, s31
	v_subrev_u32_e32 v25, s33, v5
	v_mul_hi_u32 v5, v4, s37
	s_xor_b32 s36, s36, s33
	s_sub_i32 s38, s38, s39
	v_mul_lo_u32 v5, v5, s31
	s_sub_i32 s36, s36, s33
	s_sub_i32 s39, s38, s31
	v_sub_u32_e32 v4, v4, v5
	s_cmp_ge_u32 s38, s31
	v_cmp_le_u32_e32 vcc, s31, v4
	v_subrev_u32_e32 v5, s31, v4
	s_cselect_b32 s38, s39, s38
	v_cndmask_b32_e32 v4, v4, v5, vcc
	s_sub_i32 s39, s38, s31
	v_cmp_le_u32_e32 vcc, s31, v4
	v_subrev_u32_e32 v5, s31, v4
	s_cmp_ge_u32 s38, s31
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_add_u32_e32 v3, s33, v3
	s_cselect_b32 s38, s39, s38
	s_add_i32 s43, s43, s33
	v_xor_b32_e32 v4, s33, v4
	v_xor_b32_e32 v3, s33, v3
	s_xor_b32 s39, s43, s33
	v_subrev_u32_e32 v26, s33, v4
	v_mul_hi_u32 v4, v3, s37
	s_mul_hi_u32 s40, s39, s37
	v_mul_lo_u32 v4, v4, s31
	s_mul_i32 s40, s40, s31
	v_sub_u32_e32 v3, v3, v4
	s_xor_b32 s38, s38, s33
	s_sub_i32 s39, s39, s40
	v_cmp_le_u32_e32 vcc, s31, v3
	v_subrev_u32_e32 v4, s31, v3
	s_sub_i32 s38, s38, s33
	s_sub_i32 s40, s39, s31
	v_cndmask_b32_e32 v3, v3, v4, vcc
	s_cmp_ge_u32 s39, s31
	v_cmp_le_u32_e32 vcc, s31, v3
	v_subrev_u32_e32 v4, s31, v3
	s_cselect_b32 s39, s40, s39
	v_cndmask_b32_e32 v3, v3, v4, vcc
	s_sub_i32 s40, s39, s31
	v_xor_b32_e32 v3, s33, v3
	s_cmp_ge_u32 s39, s31
	v_subrev_u32_e32 v27, s33, v3
	.loc	1 124 44 is_stmt 1              ; gemm_a16w16.py:124:44
	v_mov_b32_e32 v3, 0x7f
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_cselect_b32 s39, s40, s39
	.loc	1 124 44                        ; gemm_a16w16.py:124:44
	v_bitop3_b32 v3, s6, v3, v2 bitop3:0xc8
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s7, s7, s13
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_xor_b32 s39, s39, s33
	.loc	1 154 34                        ; gemm_a16w16.py:154:34
	v_cmp_gt_u32_e32 vcc, s12, v3
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_lshl_u32 v4, s7, v3, 1
	v_bfrev_b32_e32 v2, 1
	.loc	1 121 23                        ; gemm_a16w16.py:121:23
	s_sub_i32 s39, s39, s33
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s6, s11, s13
	s_mul_i32 s31, s22, s13
	s_mul_i32 s33, s23, s13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s23, 0x27000
	s_mov_b32 s22, 0x7ffffffe
	v_cndmask_b32_e32 v5, v2, v4, vcc
	buffer_load_ushort v28, v5, s[20:23], 0 offen
	v_add_lshl_u32 v5, s6, v3, 1
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s17, s17, s13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_cndmask_b32_e32 v10, v2, v5, vcc
	buffer_load_ushort v30, v10, s[20:23], 0 offen
	v_add_lshl_u32 v10, s17, v3, 1
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s19, s19, s13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_cndmask_b32_e32 v11, v2, v10, vcc
	buffer_load_ushort v31, v11, s[20:23], 0 offen
	v_add_lshl_u32 v11, s19, v3, 1
	v_cndmask_b32_e32 v12, v2, v11, vcc
	buffer_load_ushort v29, v12, s[20:23], 0 offen
	v_add_lshl_u32 v12, s31, v3, 1
	v_cndmask_b32_e32 v13, v2, v12, vcc
	buffer_load_ushort v32, v13, s[20:23], 0 offen
	v_add_lshl_u32 v13, s33, v3, 1
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s26, s26, s13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_cndmask_b32_e32 v14, v2, v13, vcc
	buffer_load_ushort v33, v14, s[20:23], 0 offen
	v_add_lshl_u32 v14, s26, v3, 1
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s27, s27, s13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_cndmask_b32_e32 v15, v2, v14, vcc
	buffer_load_ushort v34, v15, s[20:23], 0 offen
	v_add_lshl_u32 v15, s27, v3, 1
	v_cndmask_b32_e32 v17, v2, v15, vcc
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s28, s28, s14
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	buffer_load_ushort v35, v17, s[20:23], 0 offen
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_add_lshl_u32 v17, s28, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s29, s29, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s22
	s_mov_b32 s7, s23
	v_cndmask_b32_e32 v18, v2, v17, vcc
	buffer_load_ushort v36, v18, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v18, s29, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s30, s30, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v19, v2, v18, vcc
	buffer_load_ushort v37, v19, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v19, s30, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s34, s34, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v20, v2, v19, vcc
	buffer_load_ushort v38, v20, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v20, s34, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s35, s35, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v21, v2, v20, vcc
	buffer_load_ushort v39, v21, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v21, s35, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s36, s36, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v22, v2, v21, vcc
	buffer_load_ushort v40, v22, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v22, s36, v3, 1
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s38, s38, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v23, v2, v22, vcc
	.loc	1 142 23                        ; gemm_a16w16.py:142:23
	s_min_u32 s11, s12, 0xc8
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	buffer_load_ushort v41, v23, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v23, s38, v3, 1
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	s_and_b32 s25, s25, 0xffff
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	s_lshr_b32 s13, s15, 3
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s39, s39, s14
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v24, v2, v23, vcc
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	s_mov_b32 s26, s22
	s_mov_b32 s27, s23
	v_lshlrev_b32_e32 v16, 1, v16
	v_lshlrev_b32_e32 v25, 1, v25
	v_lshlrev_b32_e32 v26, 1, v26
	v_lshlrev_b32_e32 v27, 1, v27
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cmpk_gt_u32 s12, 0x80
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	buffer_load_ushort v42, v24, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v24, s39, v3, 1
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	buffer_load_ushort v16, v16, s[24:27], 0 offen
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_cndmask_b32_e32 v43, v2, v24, vcc
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	buffer_load_ushort v25, v25, s[24:27], 0 offen
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_lshlrev_b32_e32 v1, 1, v1
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	buffer_load_ushort v26, v26, s[24:27], 0 offen
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_bitop3_b32 v1, v1, s13, 48 bitop3:0x78
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	buffer_load_ushort v27, v27, s[24:27], 0 offen
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cselect_b64 s[24:25], -1, 0
	.loc	1 154 52                        ; gemm_a16w16.py:154:52
	s_addk_i32 s11, 0xff80
	.loc	1 154 34 is_stmt 0              ; gemm_a16w16.py:154:34
	v_cmp_gt_i32_e32 vcc, s11, v3
	.loc	1 146 9 is_stmt 1               ; gemm_a16w16.py:146:9
	s_and_b64 vcc, s[24:25], vcc
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_u32_e32 v3, 0x100, v4
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v44, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v5
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v45, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v10
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v46, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v11
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v11, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v12
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v47, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v13
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v48, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v14
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v49, v3, s[20:23], 0 offen
	v_add_u32_e32 v3, 0x100, v15
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v15, v3, s[20:23], 0 offen
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_add_u32_e32 v3, 0x100, v17
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v17, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v18
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v18, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v19
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v19, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v20
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v20, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v21
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v43, v43, s[4:7], 0 offen sc0 nt
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_u32_e32 v12, 0, v1
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	buffer_load_ushort v21, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v22
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v22, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v23
	v_cndmask_b32_e32 v3, v2, v3, vcc
	buffer_load_ushort v23, v3, s[4:7], 0 offen sc0 nt
	v_add_u32_e32 v3, 0x100, v24
	v_cndmask_b32_e32 v2, v2, v3, vcc
	buffer_load_ushort v24, v2, s[4:7], 0 offen sc0 nt
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_xad_u32 v13, v1, 64, 0
	v_xor_b32_e32 v14, 0x80, v1
	v_xor_b32_e32 v1, 0xc0, v1
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	v_and_b32_e32 v10, 15, v0
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_u32_e32 v14, 0, v14
	v_add_u32_e32 v1, 0, v1
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	s_lshl_b32 s6, s15, 6
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	s_waitcnt vmcnt(35)
	ds_write_b16 v12, v28
	s_waitcnt vmcnt(31)
	ds_write_b16 v12, v32 offset:4096
	ds_write_b16 v13, v30 offset:1024
	s_waitcnt vmcnt(30)
	ds_write_b16 v13, v33 offset:5120
	ds_write_b16 v14, v31 offset:2048
	s_waitcnt vmcnt(29)
	ds_write_b16 v14, v34 offset:6144
	ds_write_b16 v1, v29 offset:3072
	s_waitcnt vmcnt(28)
	ds_write_b16 v1, v35 offset:7168
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	s_waitcnt vmcnt(27)
	ds_write_b16 v12, v36 offset:24576
	s_waitcnt vmcnt(23)
	ds_write_b16 v12, v40 offset:28672
	ds_write_b16 v13, v37 offset:25600
	s_waitcnt vmcnt(22)
	ds_write_b16 v13, v41 offset:29696
	ds_write_b16 v14, v38 offset:26624
	s_waitcnt vmcnt(21)
	ds_write_b16 v14, v42 offset:30720
	ds_write_b16 v1, v39 offset:27648
	s_waitcnt vmcnt(4)
	ds_write_b16 v1, v43 offset:31744
	s_and_b32 s6, s6, 0x1000
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_write_b16 v12, v44 offset:8192
	ds_write_b16 v12, v47 offset:12288
	ds_write_b16 v13, v45 offset:9216
	ds_write_b16 v13, v48 offset:13312
	ds_write_b16 v14, v46 offset:10240
	ds_write_b16 v14, v49 offset:14336
	ds_write_b16 v1, v11 offset:11264
	ds_write_b16 v1, v15 offset:15360
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_write_b16 v12, v17 offset:32768
	s_waitcnt vmcnt(3)
	ds_write_b16 v12, v21 offset:36864
	ds_write_b16 v13, v18 offset:33792
	s_waitcnt vmcnt(2)
	ds_write_b16 v13, v22 offset:37888
	ds_write_b16 v14, v19 offset:34816
	s_waitcnt vmcnt(1)
	ds_write_b16 v14, v23 offset:38912
	ds_write_b16 v1, v20 offset:35840
	s_waitcnt vmcnt(0)
	ds_write_b16 v1, v24 offset:39936
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_lshlrev_b32_e32 v1, 8, v10
	v_lshlrev_b32_e32 v11, 4, v10
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	v_lshlrev_b32_e32 v2, 16, v16
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_lshl_or_b32 v16, s3, 5, v1
	v_bitop3_b32 v17, v11, v0, 48 bitop3:0x78
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_or_b32_e32 v1, s6, v1
	v_or_b32_e32 v11, v1, v17
	v_add_u32_e32 v12, 0, v11
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	v_lshlrev_b32_e32 v3, 16, v25
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[22:25], v12 offset:24576
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_or_b32_e32 v0, v16, v17
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_bitop3_b32 v13, v1, 64, v17 bitop3:0x36
	v_add_u32_e32 v11, 0, v13
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_u32_e32 v14, 0, v0
	.loc	1 133 31                        ; gemm_a16w16.py:133:31
	v_lshlrev_b32_e32 v4, 16, v26
	v_lshlrev_b32_e32 v5, 16, v27
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[26:29], v11 offset:24576
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[30:33], v14
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	s_movk_i32 s4, 0x80
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_bitop3_b32 v15, v16, 64, v17 bitop3:0x36
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_bitop3_b32 v19, v1, s4, v17 bitop3:0x36
	v_add_u32_e32 v13, 0, v19
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_add_u32_e32 v15, 0, v15
	s_movk_i32 s5, 0xc0
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[34:37], v13 offset:24576
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[38:41], v15
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_bitop3_b32 v20, v1, s5, v17 bitop3:0x36
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[30:33], v[2:5]
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	v_bitop3_b32 v18, v16, s4, v17 bitop3:0x36
	v_bitop3_b32 v16, v16, s5, v17 bitop3:0x36
	v_add_u32_e32 v16, 0, v16
	v_add_u32_e32 v5, 0, v18
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	v_add_u32_e32 v4, 0, v20
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[18:21], v5
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[22:25], v4 offset:24576
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[38:41], v[0:3]
	s_load_dword s0, s[0:1], 0x38
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cmpk_lt_u32 s12, 0x81
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[34:37], v[18:21], v[0:3]
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[18:21], v16
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[18:21], v[0:3]
	s_cbranch_scc1 .LBB0_7
; %bb.6:
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[18:21], v12 offset:32768
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[22:25], v14 offset:8192
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[26:29], v11 offset:32768
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[30:33], v15 offset:8192
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[12:15], v13 offset:32768
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[18:21], v5 offset:8192
	.loc	1 156 21                        ; gemm_a16w16.py:156:21
	ds_read_b128 v[22:25], v4 offset:32768
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[30:33], v[0:3]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[12:15], v[18:21], v[0:3]
	.loc	1 153 21                        ; gemm_a16w16.py:153:21
	ds_read_b128 v[12:15], v16 offset:8192
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[12:15], v[0:3]
.LBB0_7:
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	s_lshr_b32 s1, s3, 3
.Ltmp19:
	.file	4 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "activation.py"
	.loc	4 50 12                         ; activation.py:50:12 @[ gemm_a16w16.py:168:27 ]
	s_nop 6
	v_max_f32_e32 v0, v0, v0
	v_max_f32_e32 v1, v1, v1
.Ltmp20:
	.loc	1 172 19                        ; gemm_a16w16.py:172:19
	s_ashr_i32 s17, s16, 31
	.loc	1 120 47                        ; gemm_a16w16.py:120:47
	v_or_b32_e32 v4, s1, v10
.Ltmp21:
	.loc	4 50 12                         ; activation.py:50:12 @[ gemm_a16w16.py:168:27 ]
	v_max_f32_e32 v0, 0, v0
	v_max_f32_e32 v1, 0, v1
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v3, v3, v3
.Ltmp22:
	.loc	1 172 19                        ; gemm_a16w16.py:172:19
	s_lshl_b64 s[4:5], s[16:17], 5
	.loc	1 173 19                        ; gemm_a16w16.py:173:19
	s_ashr_i32 s3, s2, 31
.Ltmp23:
	.loc	4 50 12                         ; activation.py:50:12 @[ gemm_a16w16.py:168:27 ]
	v_max_f32_e32 v2, 0, v2
	v_max_f32_e32 v3, 0, v3
.Ltmp24:
	.loc	1 171 13                        ; gemm_a16w16.py:171:13
	v_cvt_pk_bf16_f32 v14, v0, v1
	.loc	1 172 19                        ; gemm_a16w16.py:172:19
	v_or_b32_e32 v0, s4, v4
	.loc	1 173 19                        ; gemm_a16w16.py:173:19
	s_lshl_b64 s[2:3], s[2:3], 5
	.loc	1 171 13                        ; gemm_a16w16.py:171:13
	v_cvt_pk_bf16_f32 v15, v2, v3
	.loc	1 172 19                        ; gemm_a16w16.py:172:19
	v_mov_b32_e32 v1, s5
	.loc	1 173 19                        ; gemm_a16w16.py:173:19
	v_or_b32_e32 v2, s2, v9
	v_mov_b32_e32 v3, s3
	v_or_b32_e32 v4, s2, v8
	v_mov_b32_e32 v5, s3
	v_or_b32_e32 v10, s2, v7
	v_mov_b32_e32 v11, s3
	v_or_b32_e32 v12, s2, v6
	v_mov_b32_e32 v13, s3
	.loc	1 175 13                        ; gemm_a16w16.py:175:13
	v_mul_lo_u32 v16, v0, s0
	.loc	1 183 23                        ; gemm_a16w16.py:183:23
	s_ashr_i32 s11, s10, 31
	.loc	1 183 48 is_stmt 0              ; gemm_a16w16.py:183:48
	s_ashr_i32 s19, s18, 31
	.loc	1 175 13 is_stmt 1              ; gemm_a16w16.py:175:13
	v_add_u32_e32 v16, s2, v16
	.loc	1 183 23                        ; gemm_a16w16.py:183:23
	v_cmp_gt_i64_e32 vcc, s[10:11], v[0:1]
	.loc	1 183 48 is_stmt 0              ; gemm_a16w16.py:183:48
	v_cmp_gt_i64_e64 s[0:1], s[18:19], v[2:3]
	v_cmp_gt_i64_e64 s[2:3], s[18:19], v[4:5]
	v_cmp_gt_i64_e64 s[4:5], s[18:19], v[10:11]
	v_cmp_gt_i64_e64 s[6:7], s[18:19], v[12:13]
	.loc	1 183 22                        ; gemm_a16w16.py:183:22
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_b64 s[2:3], vcc, s[2:3]
	s_and_b64 s[4:5], vcc, s[4:5]
	s_and_b64 s[6:7], vcc, s[6:7]
	.loc	1 184 13 is_stmt 1              ; gemm_a16w16.py:184:13
	s_and_b32 s9, s9, 0xffff
	s_bitcmp0_b32 s15, 8
	s_cselect_b64 s[12:13], -1, 0
	v_add_lshl_u32 v0, v16, v9, 1
	v_bfrev_b32_e32 v1, 1
	s_and_b64 vcc, s[12:13], s[0:1]
	s_mov_b32 s10, s22
	s_mov_b32 s11, s23
	v_cndmask_b32_e32 v0, v1, v0, vcc
	v_add_lshl_u32 v2, v16, v8, 1
	s_and_b64 vcc, s[12:13], s[2:3]
	buffer_store_short v14, v0, s[8:11], 0 offen
	v_lshrrev_b32_e32 v0, 16, v14
	v_cndmask_b32_e32 v2, v1, v2, vcc
	buffer_store_short v0, v2, s[8:11], 0 offen
	v_add_lshl_u32 v0, v16, v7, 1
	s_and_b64 vcc, s[12:13], s[4:5]
	v_cndmask_b32_e32 v0, v1, v0, vcc
	v_add_lshl_u32 v2, v16, v6, 1
	s_and_b64 vcc, s[12:13], s[6:7]
	buffer_store_short v15, v0, s[8:11], 0 offen
	v_lshrrev_b32_e32 v0, 16, v15
	v_cndmask_b32_e32 v1, v1, v2, vcc
	buffer_store_short v0, v1, s[8:11], 0 offen
.LBB0_8:
	.loc	1 46 1                          ; gemm_a16w16.py:46:1
	s_endpgm
.Ltmp25:
.Lfunc_end0:
	.size	_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0, .Lfunc_end0-_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 80
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
		.amdhsa_next_free_vgpr 50
		.amdhsa_next_free_sgpr 44
		.amdhsa_accum_offset 52
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
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.num_vgpr, 50
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.num_agpr, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.numbered_sgpr, 44
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.num_named_barrier, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.private_seg_size, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.uses_vcc, 1
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.uses_flat_scratch, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.has_dyn_sized_stack, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.has_recursion, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 3908
; TotalNumSgprs: 50
; NumVgprs: 50
; NumAgprs: 0
; TotalNumVgprs: 50
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 6
; VGPRBlocks: 6
; NumSGPRsForWavesPerEU: 50
; NumVGPRsForWavesPerEU: 50
; AccumOffset: 52
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 12
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
	.byte	0                               ; DW_CHILDREN_no
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
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
	.byte	1                               ; Abbrev [1] 0xb:0x87 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x61 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	93                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x4d:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	94                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x59:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	95                              ; DW_AT_call_line
	.byte	19                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x65:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges3                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	102                             ; DW_AT_call_line
	.byte	24                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x71:0x13 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp14                         ; DW_AT_low_pc
	.long	.Ltmp15-.Ltmp14                 ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	0                               ; DW_AT_call_line
	.byte	4                               ; Abbrev [4] 0x84:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges4                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	168                             ; DW_AT_call_line
	.byte	27                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp1-.Lfunc_begin0
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges3:
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges4:
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"gemm_a16w16.py"                ; string offset=7 ; gemm_a16w16.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/gemm/basic" ; string offset=22 ; /work/aiter/aiter/ops/triton/_triton_kernels/gemm/basic
.Linfo_string3:
	.asciz	"_gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0" ; string offset=78 ; _gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
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
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
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
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 80
    .max_flat_workgroup_size: 512
    .name:           _gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0
    .private_segment_fixed_size: 0
    .sgpr_count:     50
    .sgpr_spill_count: 0
    .symbol:         _gemm_a16_w16_kernel_BLOCK_SIZE_M_32_BLOCK_SIZE_N_32_BLOCK_SIZE_K_128_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_200_EVEN_K_0_EVEN_MN_0_cache_modifier_CG_activation_JITFUNCTION_AITER_OPS_TRITON__TRITON_KERNELS_COMMON_ACTIVATION__RELU_use_activation_1_ADD_BIAS_1_SKIP_REDUCE_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     50
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
