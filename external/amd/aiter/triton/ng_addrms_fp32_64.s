	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0 ; -- Begin function _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
	.p2align	8
	.type	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0,@function
_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0: ; @_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.12:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/normalization" "rmsnorm.py"
	.loc	1 427 0 prologue_end            ; rmsnorm.py:427:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.13:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_load_dwordx2 s[34:35], s[0:1], 0x38
.Ltmp1:
	.loc	1 465 22 is_stmt 1              ; rmsnorm.py:465:22
	s_load_dword s33, s[0:1], 0x58
	s_mov_b64 s[28:29], s[2:3]
	.loc	1 572 13                        ; rmsnorm.py:572:13
	v_readfirstlane_b32 s2, v0
	s_lshr_b32 s17, s2, 6
	.loc	1 466 19                        ; rmsnorm.py:466:19
	v_and_b32_e32 v0, 63, v0
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s16, s34
	s_mov_b64 s[24:25], s[10:11]
	.loc	1 545 16                        ; rmsnorm.py:545:16
	v_cmp_gt_i32_e64 s[18:19], s35, v0
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_cselect_b64 s[2:3], -1, 0
	.loc	1 547 38                        ; rmsnorm.py:547:38
	s_mul_i32 s10, s14, s16
	s_mov_b64 s[20:21], s[6:7]
	.loc	1 560 17                        ; rmsnorm.py:560:17
	s_mov_b32 s23, 0x27000
	s_mov_b32 s22, 0x7ffffffe
	v_lshlrev_b32_e32 v4, 2, v0
	v_bfrev_b32_e32 v2, 1
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_and_b64 vcc, s[2:3], s[18:19]
	.loc	1 549 19                        ; rmsnorm.py:549:19
	v_add_lshl_u32 v7, s10, v0, 2
	.loc	1 560 17                        ; rmsnorm.py:560:17
	s_and_b32 s25, s25, 0xffff
	s_mov_b32 s26, s22
	s_mov_b32 s27, s23
	v_cndmask_b32_e32 v1, v2, v4, vcc
	.loc	1 549 19                        ; rmsnorm.py:549:19
	s_and_b32 s29, s29, 0xffff
	s_mov_b32 s30, s22
	s_mov_b32 s31, s23
	v_cndmask_b32_e32 v2, v2, v7, vcc
	.loc	1 552 22                        ; rmsnorm.py:552:22
	s_and_b32 s21, s21, 0xffff
	.loc	1 560 17                        ; rmsnorm.py:560:17
	buffer_load_dword v1, v1, s[24:27], 0 offen
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_sub_i32 s41, s34, s33
	.loc	1 549 19                        ; rmsnorm.py:549:19
	buffer_load_dword v5, v2, s[28:31], 0 offen sc0 nt
	.loc	1 552 22                        ; rmsnorm.py:552:22
	buffer_load_dword v6, v2, s[20:23], 0 offen sc0 nt
	s_and_b32 s9, s9, 0xffff
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_cmp_lt_i32 s16, s41
	v_or_b32_e32 v2, s17, v0
	s_cbranch_scc1 .LBB0_2
; %bb.1:                                ; %.._crit_edge_crit_edge
	.loc	1 0 9 is_stmt 0                 ; rmsnorm.py:0:9
	s_mov_b64 s[2:3], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[2:3], -1
.LBB0_3:                                ; %Flow8
	s_load_dword s40, s[0:1], 0x40
	v_cvt_f32_i32_e32 v3, s35
	s_and_b64 s[0:1], s[2:3], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_9
; %bb.4:                                ; %.lr.ph
	s_cmp_eq_u32 s17, 0
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[2:3], s[18:19], s[0:1]
	.loc	1 546 9 is_stmt 1               ; rmsnorm.py:546:9
	s_mul_i32 s0, s33, s14
	s_lshl_b32 s42, s0, 2
	s_mul_i32 s0, s16, s15
	v_add_lshl_u32 v9, s0, v0, 2
	s_mul_i32 s0, s33, s15
	s_lshl_b32 s43, s0, 2
	s_add_i32 s0, s16, s33
	v_bfrev_b32_e32 v7, 1
	s_mul_i32 s14, s14, s0
	v_cndmask_b32_e64 v8, v7, v4, s[18:19]
	v_cmp_eq_u32_e64 s[6:7], 0, v2
	s_mov_b32 s39, 0x27000
	s_mov_b32 s38, 0x7ffffffe
	s_and_b32 s37, s5, 0xffff
	s_lshl_b32 s35, s10, 2
	s_lshl_b32 s14, s14, 2
	v_mov_b32_e32 v10, 0
	s_mov_b32 s30, s22
	s_mov_b32 s31, s23
	s_mov_b32 s0, s16
	s_branch .LBB0_6
.LBB0_5:                                ;   in Loop: Header=BB0_6 Depth=1
	.loc	1 0 9 is_stmt 0                 ; rmsnorm.py:0:9
	s_or_b64 exec, exec, s[10:11]
	.loc	1 568 24 is_stmt 1              ; rmsnorm.py:568:24
	v_mul_f32_e32 v5, v5, v6
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_add_i32 s0, s0, s33
	.loc	1 568 24                        ; rmsnorm.py:568:24
	v_mul_f32_e32 v1, v1, v5
	.loc	1 572 13                        ; rmsnorm.py:572:13
	v_cndmask_b32_e64 v5, v7, v9, s[2:3]
	s_mov_b32 s36, s4
	buffer_store_dword v1, v5, s[36:39], 0 offen
	.loc	1 546 9                         ; rmsnorm.py:546:9
	v_add_u32_e32 v4, s42, v4
	v_add_u32_e32 v9, s43, v9
	s_cmp_lt_i32 s0, s41
	s_waitcnt vmcnt(1)
	v_mov_b32_e32 v1, v13
	v_mov_b32_e32 v6, v12
	v_mov_b32_e32 v5, v11
	s_cbranch_scc0 .LBB0_8
.LBB0_6:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 549 19                        ; rmsnorm.py:549:19
	v_add_u32_e32 v11, s14, v4
	.loc	1 553 13                        ; rmsnorm.py:553:13
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v5, v5, v6
	.loc	1 557 13                        ; rmsnorm.py:557:13
	v_add_u32_e32 v6, s35, v4
	.loc	1 549 19                        ; rmsnorm.py:549:19
	v_cndmask_b32_e64 v13, v7, v11, s[18:19]
	.loc	1 557 13                        ; rmsnorm.py:557:13
	v_cndmask_b32_e64 v6, v7, v6, s[2:3]
	s_mov_b32 s10, s22
	s_mov_b32 s11, s23
	.loc	1 549 19                        ; rmsnorm.py:549:19
	buffer_load_dword v11, v13, s[28:31], 0 offen sc0 nt
	.loc	1 552 22                        ; rmsnorm.py:552:22
	buffer_load_dword v12, v13, s[20:23], 0 offen sc0 nt
	.loc	1 560 17                        ; rmsnorm.py:560:17
	s_mov_b32 s26, s22
	.loc	1 557 13                        ; rmsnorm.py:557:13
	buffer_store_dword v5, v6, s[8:11], 0 offen
	.loc	1 560 17                        ; rmsnorm.py:560:17
	s_mov_b32 s27, s23
	buffer_load_dword v13, v8, s[24:27], 0 offen
	.loc	1 561 24                        ; rmsnorm.py:561:24
	v_mul_f32_e32 v6, v5, v5
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	s_nop 1
	v_mov_b32_dpp v6, v6 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp3:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_fmac_f32_e32 v6, v5, v5
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp4:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	v_mov_b32_e32 v14, v6
	s_nop 1
	v_mov_b32_dpp v14, v14 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp5:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_e32 v6, v6, v14
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp6:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	s_nop 0
	v_readlane_b32 s1, v6, 63
.Ltmp7:
	.loc	1 563 42                        ; rmsnorm.py:563:42
	s_nop 1
	v_div_scale_f32 v6, s[10:11], v3, v3, s1
	v_rcp_f32_e32 v14, v6
	s_nop 0
	v_fma_f32 v15, -v6, v14, 1.0
	v_fmac_f32_e32 v14, v15, v14
	v_div_scale_f32 v15, vcc, s1, v3, s1
	v_mul_f32_e32 v16, v15, v14
	v_fma_f32 v17, -v6, v16, v15
	v_fmac_f32_e32 v16, v17, v14
	v_fma_f32 v6, -v6, v16, v15
	v_div_fmas_f32 v6, v6, v14, v16
	v_div_fixup_f32 v6, v6, v3, s1
	.loc	1 563 41 is_stmt 0              ; rmsnorm.py:563:41
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, s40, v6
	.loc	1 563 27                        ; rmsnorm.py:563:27
	v_rsq_f32_e32 v6, v6
	.loc	1 566 13 is_stmt 1              ; rmsnorm.py:566:13
	s_and_saveexec_b64 s[10:11], s[6:7]
	s_cbranch_execz .LBB0_5
; %bb.7:                                ;   in Loop: Header=BB0_6 Depth=1
	.loc	1 0 13 is_stmt 0                ; rmsnorm.py:0:13
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[26:27], s[0:1], 2
	s_add_u32 s26, s12, s26
	s_addc_u32 s27, s13, s27
	.loc	1 566 13                        ; rmsnorm.py:566:13
	global_store_dword v10, v6, s[26:27]
	s_branch .LBB0_5
.LBB0_8:                                ; %Flow
	.loc	1 0 13                          ; rmsnorm.py:0:13
	v_add_u32_e32 v7, s35, v4
	v_mov_b32_e32 v1, v13
	v_mov_b32_e32 v6, v12
	v_mov_b32_e32 v5, v11
.LBB0_9:                                ; %._crit_edge
	.loc	1 546 9 is_stmt 1               ; rmsnorm.py:546:9
	s_cmp_gt_i32 s33, -1
	s_cselect_b32 s0, -1, 1
	s_abs_i32 s1, s33
	v_cvt_f32_u32_e32 v4, s1
	s_add_i32 s2, s33, s34
	s_add_i32 s2, s2, s0
	s_sub_i32 s0, 0, s1
	v_rcp_f32_e32 v4, v4
	s_sub_i32 s2, s2, s16
	s_xor_b32 s3, s2, s33
	s_abs_i32 s2, s2
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	.loc	1 553 13                        ; rmsnorm.py:553:13
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v5, v5, v6
	.loc	1 561 24                        ; rmsnorm.py:561:24
	v_mul_f32_e32 v6, v5, v5
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_ashr_i32 s3, s3, 31
	v_readfirstlane_b32 s6, v4
	s_mul_i32 s0, s0, s6
	s_mul_hi_u32 s0, s6, s0
	s_add_i32 s6, s6, s0
	s_mul_hi_u32 s0, s2, s6
	s_mul_i32 s6, s0, s1
.Ltmp8:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	v_mov_b32_dpp v6, v6 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp9:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_sub_i32 s2, s2, s6
.Ltmp10:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_fmac_f32_e32 v6, v5, v5
.Ltmp11:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_add_i32 s7, s0, 1
	s_sub_i32 s6, s2, s1
.Ltmp12:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp13:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s0, s7, s0
.Ltmp14:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp15:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_cselect_b32 s2, s6, s2
	s_add_i32 s6, s0, 1
.Ltmp16:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp17:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	v_mov_b32_e32 v8, v6
.Ltmp18:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s0, s6, s0
.Ltmp19:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	v_mov_b32_dpp v8, v8 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp20:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_e32 v6, v6, v8
.Ltmp21:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_xor_b32 s0, s0, s3
	s_sub_i32 s0, s0, s3
.Ltmp22:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:562:24 ] ]
	v_add_f32_dpp v6, v6, v6 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp23:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_add_i32 s1, s0, -1
.Ltmp24:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:562:24 ]
	v_readlane_b32 s3, v6, 63
.Ltmp25:
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_max_i32 s1, s1, 0
	s_mul_i32 s1, s1, s33
	.loc	1 563 42                        ; rmsnorm.py:563:42
	v_div_scale_f32 v6, s[10:11], v3, v3, s3
	v_rcp_f32_e32 v8, v6
	.loc	1 546 9                         ; rmsnorm.py:546:9
	s_add_i32 s2, s1, s16
	s_cmp_gt_i32 s0, 0
	s_cselect_b64 s[6:7], -1, 0
	.loc	1 563 42                        ; rmsnorm.py:563:42
	v_fma_f32 v9, -v6, v8, 1.0
	v_fmac_f32_e32 v8, v9, v8
	v_div_scale_f32 v9, vcc, s3, v3, s3
	v_mul_f32_e32 v10, v9, v8
	v_fma_f32 v11, -v6, v10, v9
	v_fmac_f32_e32 v10, v11, v8
	v_fma_f32 v6, -v6, v10, v9
	v_div_fmas_f32 v6, v6, v8, v10
	.loc	1 557 13                        ; rmsnorm.py:557:13
	s_cmp_eq_u32 s17, 0
	.loc	1 563 42                        ; rmsnorm.py:563:42
	v_div_fixup_f32 v3, v6, v3, s3
	.loc	1 557 13                        ; rmsnorm.py:557:13
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 563 41                        ; rmsnorm.py:563:41
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v3, s40, v3
	.loc	1 557 13                        ; rmsnorm.py:557:13
	s_and_b64 s[0:1], s[18:19], s[0:1]
	.loc	1 563 27                        ; rmsnorm.py:563:27
	v_rsq_f32_e32 v3, v3
	.loc	1 557 13                        ; rmsnorm.py:557:13
	v_bfrev_b32_e32 v4, 1
	s_and_b64 s[0:1], s[0:1], s[6:7]
	v_cndmask_b32_e64 v7, v4, v7, s[0:1]
	s_mov_b32 s10, s22
	s_mov_b32 s11, s23
	.loc	1 566 13                        ; rmsnorm.py:566:13
	v_cmp_eq_u32_e32 vcc, 0, v2
	.loc	1 557 13                        ; rmsnorm.py:557:13
	buffer_store_dword v5, v7, s[8:11], 0 offen
	.loc	1 566 13                        ; rmsnorm.py:566:13
	s_and_b64 s[8:9], vcc, s[6:7]
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB0_11
; %bb.10:
	.loc	1 0 13 is_stmt 0                ; rmsnorm.py:0:13
	s_ashr_i32 s3, s2, 31
	s_lshl_b64 s[8:9], s[2:3], 2
	s_add_u32 s8, s12, s8
	s_addc_u32 s9, s13, s9
	v_mov_b32_e32 v2, 0
	.loc	1 566 13                        ; rmsnorm.py:566:13
	global_store_dword v2, v3, s[8:9]
.LBB0_11:
	.loc	1 0 13                          ; rmsnorm.py:0:13
	s_or_b64 exec, exec, s[6:7]
	.loc	1 570 40 is_stmt 1              ; rmsnorm.py:570:40
	s_mul_i32 s2, s2, s15
	.loc	1 568 24                        ; rmsnorm.py:568:24
	v_mul_f32_e32 v2, v5, v3
	.loc	1 572 13                        ; rmsnorm.py:572:13
	v_add_lshl_u32 v0, s2, v0, 2
	.loc	1 568 24                        ; rmsnorm.py:568:24
	v_mul_f32_e32 v1, v1, v2
	.loc	1 572 13                        ; rmsnorm.py:572:13
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	v_cndmask_b32_e64 v0, v4, v0, s[0:1]
	buffer_store_dword v1, v0, s[4:7], 0 offen
	.loc	1 427 1                         ; rmsnorm.py:427:1
	s_endpgm
.Ltmp26:
.Lfunc_end0:
	.size	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0, .Lfunc_end0-_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 44
		.amdhsa_accum_offset 20
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
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_vgpr, 18
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_agpr, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.numbered_sgpr, 44
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_named_barrier, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.private_seg_size, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_vcc, 1
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_flat_scratch, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_dyn_sized_stack, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_recursion, 0
	.set .L_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1476
; TotalNumSgprs: 50
; NumVgprs: 18
; NumAgprs: 0
; TotalNumVgprs: 18
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 6
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 50
; NumVGPRsForWavesPerEU: 18
; AccumOffset: 20
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 4
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
	.byte	5                               ; DW_FORM_data2
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
	.byte	1                               ; Abbrev [1] 0xb:0x53 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x2d DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x1b DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	562                             ; DW_AT_call_line
	.byte	24                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x4e:0xd DW_TAG_inlined_subroutine
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
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
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
	.asciz	"rmsnorm.py"                    ; string offset=7 ; rmsnorm.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=18 ; /work/aiter/aiter/ops/triton/_triton_kernels/normalization
.Linfo_string3:
	.asciz	"_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0" ; string offset=77 ; _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
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
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     global_buffer
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .max_flat_workgroup_size: 256
    .name:           _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
    .private_segment_fixed_size: 0
    .sgpr_count:     50
    .sgpr_spill_count: 0
    .symbol:         _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     18
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
