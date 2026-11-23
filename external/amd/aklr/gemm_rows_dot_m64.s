; AKLR 766a200e367f aklr/ops/gemm/impls/triton/gemm_n32_k4096/aaa261fd9041690b.json, compiled for gfx950 by
; external/amd/aklr/build.py (case gemm_rows_dot_m64).
; dynamic LDS: 32 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rows_dot_kernel                ; -- Begin function _rows_dot_kernel
	.p2align	8
	.type	_rows_dot_kernel,@function
_rows_dot_kernel:                       ; @_rows_dot_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/build/gemm_rows_dot_m64" "kernel.py"
	.loc	1 24 0 prologue_end             ; kernel.py:24:0
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
	.loc	1 53 5 is_stmt 1                ; kernel.py:53:5
	v_readfirstlane_b32 s2, v0
	s_lshr_b32 s17, s2, 6
	.loc	1 41 13                         ; kernel.py:41:13
	s_ashr_i32 s2, s16, 31
	s_lshr_b32 s2, s2, 27
	s_add_i32 s2, s16, s2
	s_ashr_i32 s3, s2, 5
	.loc	1 40 11                         ; kernel.py:40:11
	s_andn2_b32 s2, s2, 31
	.loc	1 43 10                         ; kernel.py:43:10
	v_lshlrev_b32_e32 v1, 3, v0
	.loc	1 40 11                         ; kernel.py:40:11
	s_sub_i32 s16, s16, s2
	.loc	1 41 12                         ; kernel.py:41:12
	s_lshl_b32 s14, s3, 1
	.loc	1 43 10                         ; kernel.py:43:10
	v_and_b32_e32 v2, 0x1f8, v1
	.loc	1 42 14                         ; kernel.py:42:14
	s_cmp_lt_i32 s14, s8
	.loc	1 43 10                         ; kernel.py:43:10
	v_lshl_or_b32 v18, s17, 9, v2
	.loc	1 48 13                         ; kernel.py:48:13
	s_mul_i32 s15, s9, s14
	.loc	1 47 13                         ; kernel.py:47:13
	v_add_lshl_u32 v6, v18, s15, 1
	v_bfrev_b32_e32 v48, 1
	.loc	1 42 14                         ; kernel.py:42:14
	s_cselect_b64 vcc, -1, 0
	.loc	1 48 13                         ; kernel.py:48:13
	v_add_u32_e32 v19, s9, v18
	s_mov_b64 s[12:13], s[6:7]
	.loc	1 46 25                         ; kernel.py:46:25
	s_mul_i32 s10, s10, s16
	.loc	1 46 13 is_stmt 0               ; kernel.py:46:13
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	.loc	1 47 13 is_stmt 1               ; kernel.py:47:13
	v_cndmask_b32_e32 v20, v48, v6, vcc
	v_add_lshl_u32 v6, v19, s15, 1
	.loc	1 46 13                         ; kernel.py:46:13
	s_and_b32 s5, s5, 0xffff
	v_add_lshl_u32 v2, v18, s10, 1
	.loc	1 47 13                         ; kernel.py:47:13
	s_and_b32 s1, s1, 0xffff
	s_mov_b32 s2, s6
	s_mov_b32 s3, s7
	v_cndmask_b32_e32 v6, v48, v6, vcc
	.loc	1 46 21                         ; kernel.py:46:21
	s_addk_i32 s10, 0x800
	.loc	1 48 13                         ; kernel.py:48:13
	s_addk_i32 s15, 0x800
	.loc	1 46 13                         ; kernel.py:46:13
	buffer_load_dwordx4 v[2:5], v2, s[4:7], 0 offen sc0 nt
	v_add_lshl_u32 v21, s10, v18, 1
	.loc	1 47 13                         ; kernel.py:47:13
	buffer_load_dwordx4 v[6:9], v6, s[0:3], 0 offen
	v_add_lshl_u32 v22, v18, s15, 1
	v_add_lshl_u32 v18, v19, s15, 1
	.loc	1 46 13                         ; kernel.py:46:13
	buffer_load_dwordx4 v[10:13], v21, s[4:7], 0 offen sc0 nt
	.loc	1 47 13                         ; kernel.py:47:13
	buffer_load_dwordx4 v[14:17], v20, s[0:3], 0 offen
	v_cndmask_b32_e32 v18, v48, v18, vcc
	v_cndmask_b32_e32 v22, v48, v22, vcc
	buffer_load_dwordx4 v[18:21], v18, s[0:3], 0 offen
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	v_and_b32_e32 v1, 24, v1
.Ltmp3:
	.loc	1 47 13                         ; kernel.py:47:13
	buffer_load_dwordx4 v[22:25], v22, s[0:3], 0 offen
.Ltmp4:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_lshl3_add_u32 s2, s17, 0
	v_add_u32_e32 v1, 0, v1
.Ltmp5:
	.loc	1 53 5                          ; kernel.py:53:5
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s15, s7
	.loc	1 52 35                         ; kernel.py:52:35
	s_waitcnt vmcnt(5)
	v_lshlrev_b32_e32 v26, 16, v2
	.loc	1 52 16 is_stmt 0               ; kernel.py:52:16
	v_and_b32_e32 v29, 0xffff0000, v2
	.loc	1 52 35                         ; kernel.py:52:35
	v_lshlrev_b32_e32 v2, 16, v3
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v31, 0xffff0000, v3
	.loc	1 52 35                         ; kernel.py:52:35
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v27, 0xffff0000, v6
	.loc	1 52 16                         ; kernel.py:52:16
	v_lshlrev_b32_e32 v28, 16, v6
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v3, 0xffff0000, v7
	.loc	1 52 16                         ; kernel.py:52:16
	v_lshlrev_b32_e32 v30, 16, v7
	.loc	1 52 35                         ; kernel.py:52:35
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v6, 16, v10
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v37, 0xffff0000, v10
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v39, 0xffff0000, v14
	v_lshlrev_b32_e32 v38, 16, v14
	.loc	1 52 35                         ; kernel.py:52:35
	v_lshlrev_b32_e32 v10, 16, v11
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v41, 0xffff0000, v11
	v_and_b32_e32 v43, 0xffff0000, v15
	v_lshlrev_b32_e32 v42, 16, v15
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[14:15], v[28:29], v[26:27], 0 op_sel_hi:[1,1,0]
	.loc	1 52 16                         ; kernel.py:52:16
	v_mov_b32_e32 v27, v29
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[46:47], v[30:31], v[2:3], 0 op_sel_hi:[1,1,0]
	.loc	1 52 16                         ; kernel.py:52:16
	v_mov_b32_e32 v3, v31
	.loc	1 52 35                         ; kernel.py:52:35
	v_lshlrev_b32_e32 v32, 16, v4
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v35, 0xffff0000, v4
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v33, 0xffff0000, v8
	.loc	1 52 16                         ; kernel.py:52:16
	v_lshlrev_b32_e32 v34, 16, v8
	.loc	1 52 35                         ; kernel.py:52:35
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v7, 0xffff0000, v18
	.loc	1 52 16                         ; kernel.py:52:16
	v_lshlrev_b32_e32 v36, 16, v18
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v45, 0xffff0000, v22
	v_lshlrev_b32_e32 v44, 16, v22
	v_mov_b32_e32 v28, v6
	v_mov_b32_e32 v29, v37
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v11, 0xffff0000, v19
	.loc	1 52 16                         ; kernel.py:52:16
	v_lshlrev_b32_e32 v40, 16, v19
	v_and_b32_e32 v19, 0xffff0000, v23
	v_lshlrev_b32_e32 v18, 16, v23
	v_mov_b32_e32 v22, v10
	v_mov_b32_e32 v23, v41
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[26:27], v[26:27], v[38:39], 0 op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[2:3], v[2:3], v[42:43], 0 op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[6:7], v[36:37], v[6:7], v[14:15]
	v_pk_fma_f32 v[14:15], v[28:29], v[44:45], v[26:27]
	v_pk_fma_f32 v[2:3], v[22:23], v[18:19], v[2:3]
	v_pk_fma_f32 v[18:19], v[34:35], v[32:33], 0 op_sel_hi:[1,1,0]
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v23, 0xffff0000, v20
	v_lshlrev_b32_e32 v22, 16, v12
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v27, 0xffff0000, v12
	v_lshlrev_b32_e32 v26, 16, v20
	v_and_b32_e32 v29, 0xffff0000, v16
	v_lshlrev_b32_e32 v28, 16, v16
	v_mov_b32_e32 v33, v35
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[28:29], v[32:33], v[28:29], 0 op_sel_hi:[1,1,0]
	.loc	1 52 16                         ; kernel.py:52:16
	v_mov_b32_e32 v32, v22
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[18:19], v[26:27], v[22:23], v[18:19]
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v23, 0xffff0000, v9
	v_lshlrev_b32_e32 v22, 16, v5
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v5, 0xffff0000, v5
	v_lshlrev_b32_e32 v4, 16, v9
	v_mov_b32_e32 v33, v27
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[8:9], v[4:5], v[22:23], 0 op_sel_hi:[1,1,0]
	.loc	1 52 35                         ; kernel.py:52:35
	v_and_b32_e32 v27, 0xffff0000, v21
	v_lshlrev_b32_e32 v26, 16, v13
	.loc	1 52 16                         ; kernel.py:52:16
	v_and_b32_e32 v13, 0xffff0000, v13
	v_lshlrev_b32_e32 v12, 16, v21
	v_and_b32_e32 v21, 0xffff0000, v17
	v_lshlrev_b32_e32 v20, 16, v17
	v_mov_b32_e32 v23, v5
	v_and_b32_e32 v31, 0xffff0000, v24
	v_lshlrev_b32_e32 v30, 16, v24
	v_and_b32_e32 v17, 0xffff0000, v25
	v_lshlrev_b32_e32 v16, 16, v25
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[4:5], v[22:23], v[20:21], 0 op_sel_hi:[1,1,0]
	.loc	1 52 16                         ; kernel.py:52:16
	v_mov_b32_e32 v20, v26
	v_mov_b32_e32 v21, v13
	.loc	1 52 9                          ; kernel.py:52:9
	v_pk_fma_f32 v[28:29], v[32:33], v[30:31], v[28:29]
	v_pk_fma_f32 v[4:5], v[20:21], v[16:17], v[4:5]
	v_pk_fma_f32 v[10:11], v[40:41], v[10:11], v[46:47]
	v_pk_fma_f32 v[8:9], v[12:13], v[26:27], v[8:9]
.Ltmp6:
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:53:36 ]
	v_pk_add_f32 v[2:3], v[14:15], v[2:3]
	v_pk_add_f32 v[4:5], v[28:29], v[4:5]
	s_nop 0
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	v_pk_add_f32 v[4:5], v[6:7], v[10:11]
	v_pk_add_f32 v[6:7], v[18:19], v[8:9]
	s_nop 0
	v_pk_add_f32 v[4:5], v[4:5], v[6:7]
.Ltmp7:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v4
	v_mov_b32_e32 v4, v3
	v_pk_add_f32 v[2:3], v[6:7], v[4:5]
.Ltmp8:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 1
	v_mov_b32_dpp v4, v2 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp9:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp10:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 1
	v_mov_b32_dpp v4, v2 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp11:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp12:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 1
	v_mov_b32_dpp v4, v2 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp13:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp14:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 1
	v_mov_b32_dpp v4, v2 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp15:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp16:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 0
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v3
	s_nop 0
	v_mov_b32_dpp v4, v4 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v5 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp17:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp18:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 1
	v_mov_b32_dpp v4, v2 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp19:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
.Ltmp20:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_nop 0
	v_readlane_b32 s0, v2, 63
	v_readlane_b32 s1, v3, 63
	v_mov_b32_e32 v2, s2
	v_mov_b32_e32 v4, s0
	v_mov_b32_e32 v5, s1
	ds_write_b64 v2, v[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64 v[2:3], v1
.Ltmp21:
	.loc	1 41 35                         ; kernel.py:41:35
	v_and_b32_e32 v1, 1, v0
	.loc	1 41 12 is_stmt 0               ; kernel.py:41:12
	v_or_b32_e32 v4, s14, v1
	.loc	1 42 14 is_stmt 1               ; kernel.py:42:14
	v_cmp_gt_i32_e32 vcc, s8, v4
	.loc	1 53 14                         ; kernel.py:53:14
	v_mul_lo_u32 v6, s11, v4
.Ltmp22:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_dpp v4, v2 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp23:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
.Ltmp24:
	.loc	1 53 5                          ; kernel.py:53:5
	v_cmp_eq_u32_e64 s[0:1], 0, v1
	v_and_or_b32 v0, v0, 62, s17
.Ltmp25:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:53:36 ]
	v_mov_b32_dpp v4, v2 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v5, v3 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp26:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:53:36 ] ]
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
.Ltmp27:
	.loc	1 53 5                          ; kernel.py:53:5
	v_cmp_eq_u32_e64 s[2:3], 0, v0
	.loc	1 53 36 is_stmt 0               ; kernel.py:53:36
	v_cvt_pk_bf16_f32 v2, v2, v3
	v_lshrrev_b32_e32 v3, 16, v2
	.loc	1 53 5                          ; kernel.py:53:5
	v_cndmask_b32_e64 v1, v2, v3, s[0:1]
	v_bfe_i32 v1, v1, 0, 16
	s_and_b64 vcc, vcc, s[2:3]
	s_mov_b32 s14, s6
	v_mov_b32_dpp v1, v1 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cndmask_b32_e64 v0, v1, v2, s[0:1]
	v_add_lshl_u32 v1, v6, s16, 1
	v_cndmask_b32_e32 v1, v48, v1, vcc
	buffer_store_short v0, v1, s[12:15], 0 offen
	.loc	1 24 1 is_stmt 1                ; kernel.py:24:1
	s_endpgm
.Ltmp28:
.Lfunc_end0:
	.size	_rows_dot_kernel, .Lfunc_end0-_rows_dot_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rows_dot_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 56
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
		.amdhsa_next_free_vgpr 49
		.amdhsa_next_free_sgpr 18
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
	.set .L_rows_dot_kernel.num_vgpr, 49
	.set .L_rows_dot_kernel.num_agpr, 0
	.set .L_rows_dot_kernel.numbered_sgpr, 18
	.set .L_rows_dot_kernel.num_named_barrier, 0
	.set .L_rows_dot_kernel.private_seg_size, 0
	.set .L_rows_dot_kernel.uses_vcc, 1
	.set .L_rows_dot_kernel.uses_flat_scratch, 0
	.set .L_rows_dot_kernel.has_dyn_sized_stack, 0
	.set .L_rows_dot_kernel.has_recursion, 0
	.set .L_rows_dot_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1500
; TotalNumSgprs: 24
; NumVgprs: 49
; NumAgprs: 0
; TotalNumVgprs: 49
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 6
; NumSGPRsForWavesPerEU: 24
; NumVGPRsForWavesPerEU: 49
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
	.byte	5                               ; Abbreviation Code
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
	.byte	1                               ; Abbrev [1] 0xb:0x52 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x2c DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	53                              ; DW_AT_call_line
	.byte	36                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x4d:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
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
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	.Ltmp27-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
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
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp26-.Lfunc_begin0
	.quad	.Ltmp27-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/gemm_rows_dot_m64" ; string offset=17 ; /work/build/gemm_rows_dot_m64
.Linfo_string3:
	.asciz	"_rows_dot_kernel"              ; string offset=47 ; _rows_dot_kernel
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
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 56
    .max_flat_workgroup_size: 256
    .name:           _rows_dot_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     24
    .sgpr_spill_count: 0
    .symbol:         _rows_dot_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     49
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
