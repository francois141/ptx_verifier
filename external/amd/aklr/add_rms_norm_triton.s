; AKLR 766a200e367f aklr/ops/rms_norm/impls/triton/add_rms_norm_hidden_size6144/20cb6b303f4acc8c.json, compiled for gfx950 by
; external/amd/aklr/build.py (case add_rms_norm_triton).
; dynamic LDS: 16 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rms_kernel                     ; -- Begin function _rms_kernel
	.p2align	8
	.type	_rms_kernel,@function
_rms_kernel:                            ; @_rms_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/build/add_rms_norm_triton" "kernel.py"
	.loc	1 8 0 prologue_end              ; kernel.py:8:0
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
	s_mov_b64 s[24:25], s[2:3]
.Ltmp1:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:33:21 ]
	v_readfirstlane_b32 s2, v0
.Ltmp2:
	.loc	1 37 9                          ; kernel.py:37:9
	s_and_b32 s13, s2, 0xc0
	.loc	1 11 12                         ; kernel.py:11:12
	v_and_or_b32 v1, v0, 63, s13
	s_mov_b64 s[0:1], s[10:11]
	.loc	1 13 10                         ; kernel.py:13:10
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x7ffffffe
	v_lshlrev_b32_e32 v1, 4, v1
	.loc	1 18 10                         ; kernel.py:18:10
	s_mulk_i32 s16, 0x3000
	s_mov_b64 s[20:21], s[6:7]
	s_and_b32 s25, s25, 0xffff
	s_mov_b32 s26, s10
	s_mov_b32 s27, s11
	v_or_b32_e32 v60, s16, v1
	.loc	1 23 11                         ; kernel.py:23:11
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s10
	s_mov_b32 s7, s11
	.loc	1 18 10                         ; kernel.py:18:10
	buffer_load_dwordx4 v[10:13], v60, s[24:27], 0 offen sc0 nt
	.loc	1 23 11                         ; kernel.py:23:11
	buffer_load_dwordx4 v[14:17], v60, s[4:7], 0 offen sc0 nt
	.loc	1 13 10                         ; kernel.py:13:10
	s_and_b32 s9, s9, 0xffff
	.loc	1 24 5                          ; kernel.py:24:5
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s10
	s_mov_b32 s23, s11
	.loc	1 15 14                         ; kernel.py:15:14
	v_or_b32_e32 v22, 0x1000, v1
	.loc	1 16 14                         ; kernel.py:16:14
	v_or_b32_e32 v23, 0x2000, v1
	.loc	1 20 14                         ; kernel.py:20:14
	v_add_u32_e32 v61, 0x1000, v60
	.loc	1 13 10                         ; kernel.py:13:10
	buffer_load_dwordx4 v[18:21], v1, s[8:11], 0 offen
	.loc	1 15 14                         ; kernel.py:15:14
	buffer_load_dwordx4 v[6:9], v22, s[8:11], 0 offen
	.loc	1 16 14                         ; kernel.py:16:14
	buffer_load_dwordx4 v[2:5], v23, s[8:11], 0 offen
	.loc	1 21 14                         ; kernel.py:21:14
	v_add_u32_e32 v62, 0x2000, v60
	.loc	1 20 14                         ; kernel.py:20:14
	buffer_load_dwordx4 v[22:25], v61, s[24:27], 0 offen sc0 nt
	.loc	1 21 14                         ; kernel.py:21:14
	buffer_load_dwordx4 v[26:29], v62, s[24:27], 0 offen sc0 nt
.Ltmp3:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:33:21 ]
	v_lshlrev_b32_e32 v0, 2, v0
	v_and_b32_e32 v0, 12, v0
	v_add_u32_e32 v63, 0, v0
.Ltmp4:
	.loc	1 34 5                          ; kernel.py:34:5
	s_and_b32 s1, s1, 0xffff
	s_mov_b32 s2, s10
	s_mov_b32 s3, s11
	.loc	1 18 10                         ; kernel.py:18:10
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v31, 0xffff0000, v10
	v_lshlrev_b32_e32 v30, 16, v10
	.loc	1 23 11                         ; kernel.py:23:11
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v33, 0xffff0000, v14
	v_lshlrev_b32_e32 v32, 16, v14
	.loc	1 18 10                         ; kernel.py:18:10
	v_and_b32_e32 v35, 0xffff0000, v11
	v_lshlrev_b32_e32 v34, 16, v11
	.loc	1 23 11                         ; kernel.py:23:11
	v_and_b32_e32 v37, 0xffff0000, v15
	v_lshlrev_b32_e32 v36, 16, v15
	.loc	1 18 10                         ; kernel.py:18:10
	v_and_b32_e32 v15, 0xffff0000, v12
	v_lshlrev_b32_e32 v14, 16, v12
	.loc	1 23 11                         ; kernel.py:23:11
	v_and_b32_e32 v39, 0xffff0000, v16
	v_lshlrev_b32_e32 v38, 16, v16
	.loc	1 18 10                         ; kernel.py:18:10
	v_and_b32_e32 v41, 0xffff0000, v13
	v_lshlrev_b32_e32 v40, 16, v13
	.loc	1 23 11                         ; kernel.py:23:11
	v_and_b32_e32 v43, 0xffff0000, v17
	v_lshlrev_b32_e32 v42, 16, v17
	.loc	1 23 5 is_stmt 0                ; kernel.py:23:5
	v_pk_add_f32 v[10:11], v[30:31], v[32:33]
	v_pk_add_f32 v[12:13], v[34:35], v[36:37]
	v_pk_add_f32 v[14:15], v[14:15], v[38:39]
	v_pk_add_f32 v[16:17], v[40:41], v[42:43]
	.loc	1 24 29 is_stmt 1               ; kernel.py:24:29
	v_cvt_pk_bf16_f32 v30, v10, v11
	v_cvt_pk_bf16_f32 v31, v12, v13
	v_cvt_pk_bf16_f32 v32, v14, v15
	v_cvt_pk_bf16_f32 v33, v16, v17
	.loc	1 24 5 is_stmt 0                ; kernel.py:24:5
	buffer_store_dwordx4 v[30:33], v60, s[20:23], 0 offen sc0 sc1
	.loc	1 26 15 is_stmt 1               ; kernel.py:26:15
	buffer_load_dwordx4 v[30:33], v61, s[4:7], 0 offen sc0 nt
	.loc	1 27 15                         ; kernel.py:27:15
	s_nop 0
	buffer_load_dwordx4 v[34:37], v62, s[4:7], 0 offen sc0 nt
	.loc	1 13 10                         ; kernel.py:13:10
	s_waitcnt vmcnt(7)
	v_and_b32_e32 v39, 0xffff0000, v18
	v_lshlrev_b32_e32 v38, 16, v18
	v_and_b32_e32 v41, 0xffff0000, v19
	v_lshlrev_b32_e32 v40, 16, v19
	v_and_b32_e32 v43, 0xffff0000, v20
	v_lshlrev_b32_e32 v42, 16, v20
	v_and_b32_e32 v45, 0xffff0000, v21
	v_lshlrev_b32_e32 v44, 16, v21
	.loc	1 20 14                         ; kernel.py:20:14
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v19, 0xffff0000, v22
	v_lshlrev_b32_e32 v18, 16, v22
	v_and_b32_e32 v21, 0xffff0000, v23
	v_lshlrev_b32_e32 v20, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v24
	v_lshlrev_b32_e32 v22, 16, v24
	v_and_b32_e32 v47, 0xffff0000, v25
	v_lshlrev_b32_e32 v46, 16, v25
	.loc	1 21 14                         ; kernel.py:21:14
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v25, 0xffff0000, v26
	v_lshlrev_b32_e32 v24, 16, v26
	v_and_b32_e32 v49, 0xffff0000, v27
	v_lshlrev_b32_e32 v48, 16, v27
	v_and_b32_e32 v27, 0xffff0000, v28
	v_lshlrev_b32_e32 v26, 16, v28
	v_and_b32_e32 v51, 0xffff0000, v29
	v_lshlrev_b32_e32 v50, 16, v29
.Ltmp5:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:33:21 ]
	s_lshr_b32 s4, s13, 4
	v_mov_b32_e32 v64, s4
	s_mov_b32 s6, 0x45c00000
.Ltmp6:
	.loc	1 26 15                         ; kernel.py:26:15
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v29, 0xffff0000, v30
	v_lshlrev_b32_e32 v28, 16, v30
	v_and_b32_e32 v53, 0xffff0000, v31
	v_lshlrev_b32_e32 v52, 16, v31
	v_and_b32_e32 v31, 0xffff0000, v32
	v_lshlrev_b32_e32 v30, 16, v32
	v_and_b32_e32 v55, 0xffff0000, v33
	v_lshlrev_b32_e32 v54, 16, v33
	.loc	1 27 15                         ; kernel.py:27:15
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v33, 0xffff0000, v34
	v_lshlrev_b32_e32 v32, 16, v34
	v_and_b32_e32 v57, 0xffff0000, v35
	v_lshlrev_b32_e32 v56, 16, v35
	v_and_b32_e32 v35, 0xffff0000, v36
	v_lshlrev_b32_e32 v34, 16, v36
	v_and_b32_e32 v59, 0xffff0000, v37
	v_lshlrev_b32_e32 v58, 16, v37
	.loc	1 26 9                          ; kernel.py:26:9
	v_pk_add_f32 v[0:1], v[18:19], v[28:29]
	v_pk_add_f32 v[28:29], v[20:21], v[52:53]
	v_pk_add_f32 v[30:31], v[22:23], v[30:31]
	v_pk_add_f32 v[46:47], v[46:47], v[54:55]
	.loc	1 27 9                          ; kernel.py:27:9
	v_pk_add_f32 v[32:33], v[24:25], v[32:33]
	v_pk_add_f32 v[48:49], v[48:49], v[56:57]
	v_pk_add_f32 v[26:27], v[26:27], v[34:35]
	v_pk_add_f32 v[34:35], v[50:51], v[58:59]
	.loc	1 28 41                         ; kernel.py:28:41
	v_cvt_pk_bf16_f32 v18, v0, v1
	v_cvt_pk_bf16_f32 v19, v28, v29
	v_cvt_pk_bf16_f32 v20, v30, v31
	v_cvt_pk_bf16_f32 v21, v46, v47
	.loc	1 29 45                         ; kernel.py:29:45
	v_cvt_pk_bf16_f32 v22, v32, v33
	v_cvt_pk_bf16_f32 v23, v48, v49
	v_cvt_pk_bf16_f32 v24, v26, v27
	v_cvt_pk_bf16_f32 v25, v34, v35
	.loc	1 32 25                         ; kernel.py:32:25
	v_pk_mul_f32 v[50:51], v[32:33], v[32:33]
	v_pk_mul_f32 v[52:53], v[48:49], v[48:49]
	.loc	1 28 9                          ; kernel.py:28:9
	buffer_store_dwordx4 v[18:21], v61, s[20:23], 0 offen sc0 sc1
	.loc	1 29 9                          ; kernel.py:29:9
	buffer_store_dwordx4 v[22:25], v62, s[20:23], 0 offen sc0 sc1
	.loc	1 15 14                         ; kernel.py:15:14
	v_and_b32_e32 v37, 0xffff0000, v6
	.loc	1 32 25                         ; kernel.py:32:25
	v_pk_mul_f32 v[18:19], v[26:27], v[26:27]
	v_pk_mul_f32 v[20:21], v[34:35], v[34:35]
	.loc	1 32 15 is_stmt 0               ; kernel.py:32:15
	v_pk_fma_f32 v[22:23], v[0:1], v[0:1], v[50:51]
	v_pk_fma_f32 v[24:25], v[28:29], v[28:29], v[52:53]
	v_pk_fma_f32 v[18:19], v[30:31], v[30:31], v[18:19]
	v_pk_fma_f32 v[20:21], v[46:47], v[46:47], v[20:21]
	.loc	1 32 9                          ; kernel.py:32:9
	v_pk_fma_f32 v[22:23], v[10:11], v[10:11], v[22:23]
	v_pk_fma_f32 v[24:25], v[12:13], v[12:13], v[24:25]
	v_pk_fma_f32 v[18:19], v[14:15], v[14:15], v[18:19]
	v_pk_fma_f32 v[20:21], v[16:17], v[16:17], v[20:21]
.Ltmp7:
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:33:21 ]
	v_pk_add_f32 v[22:23], v[22:23], v[24:25]
	v_pk_add_f32 v[18:19], v[18:19], v[20:21]
.Ltmp8:
	.loc	1 15 14                         ; kernel.py:15:14
	v_lshlrev_b32_e32 v36, 16, v6
.Ltmp9:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:33:21 ]
	v_pk_add_f32 v[18:19], v[22:23], v[18:19]
.Ltmp10:
	.loc	1 15 14                         ; kernel.py:15:14
	v_and_b32_e32 v21, 0xffff0000, v9
.Ltmp11:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	v_add_f32_e32 v6, v18, v19
.Ltmp12:
	.loc	1 15 14                         ; kernel.py:15:14
	v_and_b32_e32 v19, 0xffff0000, v7
.Ltmp13:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	s_nop 0
	v_add_f32_dpp v6, v6, v6 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp14:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:33:21 ]
	v_mov_b32_e32 v18, v6
	s_nop 1
	v_mov_b32_dpp v18, v18 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp15:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	v_add_f32_e32 v6, v18, v6
.Ltmp16:
	.loc	1 15 14                         ; kernel.py:15:14
	v_lshlrev_b32_e32 v18, 16, v7
	v_and_b32_e32 v7, 0xffff0000, v8
.Ltmp17:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	v_add_f32_dpp v6, v6, v6 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp18:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:33:21 ]
	s_nop 0
	v_readlane_b32 s4, v6, 63
	s_nop 1
	v_mov_b32_e32 v6, s4
	ds_write_b32 v64, v6
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v20, v63
.Ltmp19:
	.loc	1 15 14                         ; kernel.py:15:14
	v_lshlrev_b32_e32 v6, 16, v8
.Ltmp20:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	s_waitcnt lgkmcnt(0)
	v_add_f32_dpp v8, v20, v20 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp21:
	.loc	1 15 14                         ; kernel.py:15:14
	v_lshlrev_b32_e32 v20, 16, v9
.Ltmp22:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:33:21 ] ]
	s_nop 0
	v_add_f32_dpp v8, v8, v8 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp23:
	.loc	1 33 21                         ; kernel.py:33:21
	v_div_scale_f32 v22, s[4:5], s6, s6, v8
	v_rcp_f32_e32 v23, v22
	v_div_scale_f32 v9, vcc, v8, s6, v8
	v_fma_f32 v24, -v22, v23, 1.0
	v_fmac_f32_e32 v23, v24, v23
	v_mul_f32_e32 v24, v9, v23
	v_fma_f32 v25, -v22, v24, v9
	v_fmac_f32_e32 v24, v25, v23
	v_fma_f32 v9, -v22, v24, v9
	v_div_fmas_f32 v9, v9, v23, v24
	v_div_fixup_f32 v8, v9, s6, v8
	v_add_f32_e32 v8, s12, v8
	.loc	1 33 12 is_stmt 0               ; kernel.py:33:12
	v_rsq_f32_e32 v22, v8
	.loc	1 16 14 is_stmt 1               ; kernel.py:16:14
	v_and_b32_e32 v9, 0xffff0000, v2
	v_lshlrev_b32_e32 v8, 16, v2
	v_and_b32_e32 v25, 0xffff0000, v3
	.loc	1 34 29                         ; kernel.py:34:29
	v_pk_mul_f32 v[10:11], v[10:11], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[22:23] op_sel_hi:[1,0]
	.loc	1 36 41                         ; kernel.py:36:41
	v_pk_mul_f32 v[0:1], v[0:1], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[22:23] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[22:23] op_sel_hi:[1,0]
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[32:33], v[32:33], v[22:23] op_sel_hi:[1,0]
	.loc	1 34 29                         ; kernel.py:34:29
	v_pk_mul_f32 v[10:11], v[10:11], v[38:39]
	v_pk_mul_f32 v[12:13], v[12:13], v[40:41]
	v_pk_mul_f32 v[14:15], v[14:15], v[42:43]
	v_pk_mul_f32 v[16:17], v[16:17], v[44:45]
	.loc	1 36 41                         ; kernel.py:36:41
	v_pk_mul_f32 v[0:1], v[0:1], v[36:37]
	v_pk_mul_f32 v[18:19], v[28:29], v[18:19]
	v_pk_mul_f32 v[28:29], v[30:31], v[6:7]
	v_pk_mul_f32 v[20:21], v[46:47], v[20:21]
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[30:31], v[32:33], v[8:9]
	.loc	1 34 28                         ; kernel.py:34:28
	v_cvt_pk_bf16_f32 v6, v10, v11
	v_cvt_pk_bf16_f32 v7, v12, v13
	v_cvt_pk_bf16_f32 v8, v14, v15
	v_cvt_pk_bf16_f32 v9, v16, v17
	.loc	1 36 40                         ; kernel.py:36:40
	v_cvt_pk_bf16_f32 v10, v0, v1
	.loc	1 16 14                         ; kernel.py:16:14
	v_lshlrev_b32_e32 v24, 16, v3
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[0:1], v[48:49], v[22:23] op_sel_hi:[1,0]
	.loc	1 36 40                         ; kernel.py:36:40
	v_cvt_pk_bf16_f32 v11, v18, v19
	v_cvt_pk_bf16_f32 v12, v28, v29
	v_cvt_pk_bf16_f32 v13, v20, v21
	.loc	1 34 5                          ; kernel.py:34:5
	buffer_store_dwordx4 v[6:9], v60, s[0:3], 0 offen sc0 sc1
	.loc	1 36 9                          ; kernel.py:36:9
	buffer_store_dwordx4 v[10:13], v61, s[0:3], 0 offen sc0 sc1
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[2:3], v[0:1], v[24:25]
	.loc	1 16 14                         ; kernel.py:16:14
	v_and_b32_e32 v1, 0xffff0000, v4
	v_lshlrev_b32_e32 v0, 16, v4
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[6:7], v[26:27], v[22:23] op_sel_hi:[1,0]
	s_nop 0
	v_pk_mul_f32 v[6:7], v[6:7], v[0:1]
	.loc	1 16 14                         ; kernel.py:16:14
	v_and_b32_e32 v1, 0xffff0000, v5
	v_lshlrev_b32_e32 v0, 16, v5
	.loc	1 37 45                         ; kernel.py:37:45
	v_pk_mul_f32 v[4:5], v[34:35], v[22:23] op_sel_hi:[1,0]
	s_nop 0
	v_pk_mul_f32 v[4:5], v[4:5], v[0:1]
	.loc	1 37 44 is_stmt 0               ; kernel.py:37:44
	v_cvt_pk_bf16_f32 v0, v30, v31
	v_cvt_pk_bf16_f32 v1, v2, v3
	v_cvt_pk_bf16_f32 v2, v6, v7
	v_cvt_pk_bf16_f32 v3, v4, v5
	.loc	1 37 9                          ; kernel.py:37:9
	buffer_store_dwordx4 v[0:3], v62, s[0:3], 0 offen sc0 sc1
	.loc	1 8 1 is_stmt 1                 ; kernel.py:8:1
	s_endpgm
.Ltmp24:
.Lfunc_end0:
	.size	_rms_kernel, .Lfunc_end0-_rms_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rms_kernel
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
		.amdhsa_next_free_vgpr 65
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 68
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
	.set .L_rms_kernel.num_vgpr, 65
	.set .L_rms_kernel.num_agpr, 0
	.set .L_rms_kernel.numbered_sgpr, 28
	.set .L_rms_kernel.num_named_barrier, 0
	.set .L_rms_kernel.private_seg_size, 0
	.set .L_rms_kernel.uses_vcc, 1
	.set .L_rms_kernel.uses_flat_scratch, 0
	.set .L_rms_kernel.has_dyn_sized_stack, 0
	.set .L_rms_kernel.has_recursion, 0
	.set .L_rms_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1872
; TotalNumSgprs: 34
; NumVgprs: 65
; NumAgprs: 0
; TotalNumVgprs: 65
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 8
; NumSGPRsForWavesPerEU: 34
; NumVGPRsForWavesPerEU: 65
; AccumOffset: 68
; Occupancy: 7
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 16
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
	.byte	33                              ; DW_AT_call_line
	.byte	21                              ; DW_AT_call_column
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
	.quad	.Ltmp1-.Lfunc_begin0
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
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/add_rms_norm_triton" ; string offset=17 ; /work/build/add_rms_norm_triton
.Linfo_string3:
	.asciz	"_rms_kernel"                   ; string offset=49 ; _rms_kernel
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
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
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
    .name:           _rms_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _rms_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     65
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
