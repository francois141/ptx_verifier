	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0 ; -- Begin function _gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
	.p2align	8
	.type	_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0,@function
_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0: ; @_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.10:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/gemm/basic" "gemm_a16w16.py"
	.loc	1 46 0 prologue_end             ; gemm_a16w16.py:46:0
	s_load_dwordx8 s[8:15], s[4:5], 0x0
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.11:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
.Ltmp1:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 43 13 is_stmt 1               ; standard.py:43:13 @[ gemm_a16w16.py:93:17 ]
	s_add_i32 s2, s14, 15
	.loc	2 43 12 is_stmt 0               ; standard.py:43:12 @[ gemm_a16w16.py:93:17 ]
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 28
	s_add_i32 s2, s2, s3
.Ltmp2:
	.loc	2 43 13                         ; standard.py:43:13 @[ gemm_a16w16.py:94:17 ]
	s_add_i32 s3, s15, 15
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:94:17 ]
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 28
	s_add_i32 s3, s3, s6
.Ltmp3:
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:93:17 ]
	s_ashr_i32 s2, s2, 4
.Ltmp4:
	.loc	2 43 12                         ; standard.py:43:12 @[ gemm_a16w16.py:94:17 ]
	s_ashr_i32 s7, s3, 4
.Ltmp5:
	.loc	1 96 22 is_stmt 1               ; gemm_a16w16.py:96:22
	s_mul_i32 s2, s7, s2
.Ltmp6:
	.file	3 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "pid_preprocessing.py"
	.loc	3 32 21                         ; pid_preprocessing.py:32:21 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s3, s2, 7
	.loc	3 32 20 is_stmt 0               ; pid_preprocessing.py:32:20 @[ gemm_a16w16.py:95:19 ]
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 29
	s_add_i32 s3, s3, s6
	s_mov_b64 s[0:1], s[10:11]
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
	s_add_i32 s6, s16, s3
	.loc	3 41 11                         ; pid_preprocessing.py:41:11 @[ gemm_a16w16.py:95:19 ]
	s_and_b32 s3, s6, -8
	v_and_b32_e32 v8, 0x3ff, v0
	s_sub_i32 s16, s16, s3
	.loc	3 47 8                          ; pid_preprocessing.py:47:8 @[ gemm_a16w16.py:95:19 ]
	s_cmp_ge_i32 s16, s2
.Ltmp7:
	.loc	1 181 13                        ; gemm_a16w16.py:181:13
	v_readfirstlane_b32 s10, v8
.Ltmp8:
	.loc	3 47 5                          ; pid_preprocessing.py:47:5 @[ gemm_a16w16.py:95:19 ]
	s_cbranch_scc0 .LBB0_2
; %bb.1:
	.loc	3 51 13                         ; pid_preprocessing.py:51:13 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s3, s2, s11
	.loc	3 52 16                         ; pid_preprocessing.py:52:16 @[ gemm_a16w16.py:95:19 ]
	s_sub_i32 s2, s16, s2
	.loc	3 52 36 is_stmt 0               ; pid_preprocessing.py:52:36 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s14, s11, -1
	.loc	3 52 15                         ; pid_preprocessing.py:52:15 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s2, s2, s14
	.loc	3 51 13 is_stmt 1               ; pid_preprocessing.py:51:13 @[ gemm_a16w16.py:95:19 ]
	s_add_i32 s15, s2, s3
	s_mov_b64 s[2:3], 0
	.loc	3 47 5                          ; pid_preprocessing.py:47:5 @[ gemm_a16w16.py:95:19 ]
	s_branch .LBB0_3
.LBB0_2:
	.loc	3 0 5 is_stmt 0                 ; pid_preprocessing.py:0:5
	s_mov_b64 s[2:3], -1
                                        ; implicit-def: $sgpr15
.LBB0_3:                                ; %Flow32
	s_load_dword s14, s[4:5], 0x20
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s2, 1
	s_cbranch_scc1 .LBB0_5
; %bb.4:
	.loc	3 48 15 is_stmt 1               ; pid_preprocessing.py:48:15 @[ gemm_a16w16.py:95:19 ]
	s_mul_i32 s15, s11, s16
.Ltmp9:
.LBB0_5:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_abs_i32 s2, s7
	v_cvt_f32_u32_e32 v0, s2
.Ltmp10:
	.loc	1 112 8                         ; gemm_a16w16.py:112:8
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s14, 1
.Ltmp11:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	v_rcp_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v0, 0x4f7ffffe, v0
	v_cvt_u32_f32_e32 v0, v0
	s_nop 0
	v_readfirstlane_b32 s3, v0
.Ltmp12:
	.loc	1 112 5                         ; gemm_a16w16.py:112:5
	s_cbranch_scc1 .LBB0_9
; %bb.6:
.Ltmp13:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_sub_i32 s18, 0, s2
	s_ashr_i32 s11, s6, 3
	s_mul_i32 s18, s18, s3
	s_load_dwordx2 s[16:17], s[4:5], 0x24
	s_load_dword s6, s[4:5], 0x30
.Ltmp14:
	.loc	3 0 0 is_stmt 0                 ; pid_preprocessing.py:0 @[ gemm_a16w16.py:0 ]
	s_add_i32 s4, s15, s11
.Ltmp15:
	.loc	3 71 17                         ; pid_preprocessing.py:71:17 @[ gemm_a16w16.py:102:24 ]
	s_mul_hi_u32 s18, s3, s18
	s_abs_i32 s15, s4
	s_add_i32 s3, s3, s18
	s_ashr_i32 s5, s4, 31
	s_ashr_i32 s11, s7, 31
	s_mul_hi_u32 s3, s15, s3
	s_xor_b32 s5, s5, s11
	s_mul_i32 s11, s3, s2
	s_sub_i32 s11, s15, s11
	s_add_i32 s15, s3, 1
	s_sub_i32 s18, s11, s2
	s_cmp_ge_u32 s11, s2
	s_cselect_b32 s3, s15, s3
	s_cselect_b32 s11, s18, s11
	s_add_i32 s15, s3, 1
	s_cmp_ge_u32 s11, s2
	s_cselect_b32 s2, s15, s3
	s_xor_b32 s2, s2, s5
	s_sub_i32 s2, s2, s5
.Ltmp16:
	.loc	1 181 13 is_stmt 1              ; gemm_a16w16.py:181:13
	s_bfe_u32 s5, s10, 0x20006
	.loc	1 117 46                        ; gemm_a16w16.py:117:46
	v_lshrrev_b32_e32 v0, 2, v8
	v_and_or_b32 v1, v0, 8, s5
	.loc	1 124 44                        ; gemm_a16w16.py:124:44
	v_lshlrev_b32_e32 v0, 3, v8
.Ltmp17:
	.loc	3 72 17                         ; pid_preprocessing.py:72:17 @[ gemm_a16w16.py:102:24 ]
	s_mul_i32 s3, s2, s7
.Ltmp18:
	.loc	1 117 46                        ; gemm_a16w16.py:117:46
	v_or_b32_e32 v9, 4, v1
	.loc	1 124 44                        ; gemm_a16w16.py:124:44
	v_and_b32_e32 v0, 0xf8, v0
.Ltmp19:
	.loc	3 72 17                         ; pid_preprocessing.py:72:17 @[ gemm_a16w16.py:102:24 ]
	s_sub_i32 s4, s4, s3
.Ltmp20:
	.loc	1 117 23                        ; gemm_a16w16.py:117:23
	s_lshl_b32 s7, s2, 4
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[6:7], s[2:3], v1, s16, v[0:1]
	v_mad_u64_u32 v[4:5], s[2:3], v9, s16, v[0:1]
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_mul_i32 s2, s4, s17
	.loc	1 123 18                        ; gemm_a16w16.py:123:18
	s_mul_i32 s15, s7, s16
	.loc	1 126 18                        ; gemm_a16w16.py:126:18
	s_lshl_b32 s16, s2, 4
	v_mad_u64_u32 v[2:3], s[2:3], v1, s17, v[0:1]
	v_mad_u64_u32 v[0:1], s[2:3], v9, s17, v[0:1]
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	s_mul_i32 s17, s5, 0x420
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x7ffffffe
	v_add_lshl_u32 v1, s15, v6, 1
	s_mov_b32 m0, s17
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	s_and_b32 s1, s1, 0xffff
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	buffer_load_dwordx4 v1, s[8:11], 0 offen lds
	s_add_i32 m0, s17, 0x1080
	v_add_lshl_u32 v1, s15, v4, 1
	buffer_load_dwordx4 v1, s[8:11], 0 offen lds
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	s_mov_b32 s2, s10
	s_mov_b32 s3, s11
	s_add_i32 m0, s17, 0x62e0
	v_add_lshl_u32 v1, s16, v2, 1
	; asyncmark
	buffer_load_dwordx4 v1, s[0:3], 0 offen sc0 nt lds
	s_add_i32 m0, s17, 0x7360
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cmpk_gt_u32 s14, 0x100
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	v_add_lshl_u32 v1, s16, v0, 1
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cselect_b64 vcc, -1, 0
	.loc	1 164 13                        ; gemm_a16w16.py:164:13
	s_addk_i32 s15, 0x100
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	buffer_load_dwordx4 v1, s[0:3], 0 offen sc0 nt lds
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	v_bfrev_b32_e32 v1, 1
	v_add_lshl_u32 v3, s15, v6, 1
	s_add_i32 m0, s17, 0x2100
	v_cndmask_b32_e32 v3, v1, v3, vcc
	; asyncmark
	.loc	1 165 13                        ; gemm_a16w16.py:165:13
	s_addk_i32 s16, 0x100
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	s_add_i32 s18, s17, 0x3180
	buffer_load_dwordx4 v3, s[8:11], 0 offen lds
	v_add_lshl_u32 v3, s15, v4, 1
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	s_add_i32 s19, s17, 0x83e0
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	v_cndmask_b32_e32 v3, v1, v3, vcc
	s_mov_b32 m0, s18
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	v_add_lshl_u32 v2, s16, v2, 1
	s_add_i32 s17, s17, 0x9460
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	buffer_load_dwordx4 v3, s[8:11], 0 offen lds
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	v_cndmask_b32_e32 v2, v1, v2, vcc
	s_mov_b32 m0, s19
	v_add_lshl_u32 v0, s16, v0, 1
	; asyncmark
	buffer_load_dwordx4 v2, s[0:3], 0 offen sc0 nt lds
	v_cndmask_b32_e32 v0, v1, v0, vcc
	s_mov_b32 m0, s17
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	v_lshlrev_b32_e32 v1, 6, v8
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	buffer_load_dwordx4 v0, s[0:3], 0 offen sc0 nt lds
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	v_lshlrev_b32_e32 v0, 10, v8
	.loc	1 117 46                        ; gemm_a16w16.py:117:46
	v_and_b32_e32 v4, 48, v8
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	v_and_b32_e32 v0, 0x1c00, v0
	v_and_b32_e32 v1, 0x200, v1
	v_or3_b32 v1, v1, v4, v0
	v_lshrrev_b32_e32 v0, 5, v0
	v_add_u32_e32 v0, v1, v0
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	v_add_u32_e32 v5, 0, v0
	; asyncmark
	; wait_asyncmark(2)
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	s_waitcnt vmcnt(4)
	s_barrier
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[0:3], v5 offset:25312
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[10:13], v5
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[14:17], v5 offset:25376
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[18:21], v5 offset:64
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[0:3], v[10:13], 0
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:25440
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:128
	.loc	1 146 9                         ; gemm_a16w16.py:146:9
	s_cmpk_lt_u32 s14, 0x101
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[18:21], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[14:17], v5 offset:25504
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[18:21], v5 offset:192
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[22:25], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:25568
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:256
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[18:21], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[14:17], v5 offset:25632
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[18:21], v5 offset:320
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[22:25], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:25696
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:384
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[18:21], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[14:17], v5 offset:25760
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[22:25], v[0:3]
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[10:13], v5 offset:448
	; wait_asyncmark(0)
	s_waitcnt vmcnt(0) lgkmcnt(0)
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[10:13], v[0:3]
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	s_barrier
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_cbranch_scc1 .LBB0_8
; %bb.7:
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:33760
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[14:17], v5 offset:8448
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[18:21], v5 offset:33824
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:8512
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:33888
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[14:17], v5 offset:8576
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[18:21], v5 offset:33952
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:8640
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:34016
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[14:17], v5 offset:8704
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[18:21], v5 offset:34080
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[22:25], v5 offset:8768
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[10:13], v5 offset:34144
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[14:17], v5 offset:8832
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 151 21                        ; gemm_a16w16.py:151:21
	ds_read_b128 v[18:21], v5 offset:34208
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 150 21                        ; gemm_a16w16.py:150:21
	ds_read_b128 v[10:13], v5 offset:8896
	.loc	1 162 27                        ; gemm_a16w16.py:162:27
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[10:13], v[0:3]
.LBB0_8:
	.loc	1 117 46                        ; gemm_a16w16.py:117:46
	v_lshrrev_b32_e32 v4, 2, v4
	.loc	1 171 13                        ; gemm_a16w16.py:171:13
	s_nop 6
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	.loc	1 175 13                        ; gemm_a16w16.py:175:13
	v_and_or_b32 v2, v8, 15, s7
	.loc	1 181 13                        ; gemm_a16w16.py:181:13
	s_and_b32 s13, s13, 0xffff
	.loc	1 175 13                        ; gemm_a16w16.py:175:13
	v_mad_u64_u32 v[2:3], s[0:1], v2, s6, v[4:5]
	.loc	1 181 13                        ; gemm_a16w16.py:181:13
	s_cmp_eq_u32 s5, 0
	s_cselect_b64 vcc, -1, 0
	s_lshl_b32 s0, s4, 5
	v_bfrev_b32_e32 v3, 1
	v_lshl_add_u32 v2, v2, 1, s0
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	v_cndmask_b32_e32 v2, v3, v2, vcc
	buffer_store_dwordx2 v[0:1], v2, s[12:15], 0 offen
.LBB0_9:
	.loc	1 46 1                          ; gemm_a16w16.py:46:1
	s_endpgm
.Ltmp21:
.Lfunc_end0:
	.size	_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0, .Lfunc_end0-_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 1
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 1
		.amdhsa_user_sgpr_kernarg_preload_length 8
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 2
		.amdhsa_next_free_vgpr 73
		.amdhsa_next_free_sgpr 91
		.amdhsa_accum_offset 28
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
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.num_vgpr, 26
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.num_agpr, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.numbered_sgpr, 20
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.num_named_barrier, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.private_seg_size, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.uses_vcc, 1
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.uses_flat_scratch, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.has_dyn_sized_stack, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.has_recursion, 0
	.set .L_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1600
; TotalNumSgprs: 26
; NumVgprs: 26
; NumAgprs: 0
; TotalNumVgprs: 26
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 9
; NumSGPRsForWavesPerEU: 97
; NumVGPRsForWavesPerEU: 73
; AccumOffset: 28
; Occupancy: 6
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 2
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 6
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
	.byte	1                               ; Abbrev [1] 0xb:0x7b DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x55 DW_TAG_subprogram
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
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
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
	.asciz	"_gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0" ; string offset=78 ; _gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
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
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         76
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         84
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         86
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         88
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         90
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         92
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         94
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         136
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         152
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .offset:         160
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
      - .offset:         168
        .size:           8
        .value_kind:     hidden_heap_v1
      - .offset:         176
        .size:           8
        .value_kind:     hidden_default_queue
      - .offset:         184
        .size:           8
        .value_kind:     hidden_completion_action
      - .offset:         192
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
      - .offset:         272
        .size:           8
        .value_kind:     hidden_queue_ptr
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .max_flat_workgroup_size: 256
    .name:           _gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         _gemm_a16_w16_kernel_BLOCK_SIZE_M_16_BLOCK_SIZE_N_16_BLOCK_SIZE_K_256_GROUP_SIZE_M_1_NUM_KSPLIT_1_SPLITK_BLOCK_SIZE_512_EVEN_K_1_EVEN_MN_1_cache_modifier_CG_activation_NONE_use_activation_0_ADD_BIAS_0_SKIP_REDUCE_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     26
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
