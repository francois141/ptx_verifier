	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0 ; -- Begin function _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0
	.p2align	8
	.type	_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0,@function
_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0: ; @_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.42:
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
; %bb.43:
.LBB0_0:
	s_load_dwordx2 s[24:25], s[0:1], 0x38
.Ltmp1:
	.loc	1 466 31 is_stmt 1              ; rmsnorm.py:466:31
	v_and_b32_e32 v1, 0x7f, v0
	.loc	1 560 32                        ; rmsnorm.py:560:32
	v_mov_b32_e32 v3, 0
	v_lshlrev_b32_e32 v2, 2, v1
	v_lshl_add_u64 v[4:5], s[10:11], 0, v[2:3]
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_waitcnt lgkmcnt(0)
	s_cmp_gt_i32 s24, s16
	.loc	1 545 29                        ; rmsnorm.py:545:29
	v_cmp_gt_i32_e64 s[18:19], s25, v1
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[10:11], s[10:11], s[18:19]
	v_mov_b32_e32 v19, 0
	.loc	1 560 24                        ; rmsnorm.py:560:24
	s_and_saveexec_b64 s[20:21], s[10:11]
	s_cbranch_execz .LBB0_2
; %bb.1:
	global_load_dword v19, v[4:5], off
.LBB0_2:
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[20:21]
	s_load_dword s17, s[0:1], 0x68
	.loc	1 547 47 is_stmt 1              ; rmsnorm.py:547:47
	s_mul_i32 s22, s14, s16
	.loc	1 549 26                        ; rmsnorm.py:549:26
	s_and_saveexec_b64 s[20:21], s[10:11]
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_ashr_i32 s23, s22, 31
	s_lshl_b64 s[26:27], s[22:23], 2
	s_add_u32 s26, s2, s26
	s_addc_u32 s27, s3, s27
	.loc	1 549 26                        ; rmsnorm.py:549:26
	global_load_dword v3, v2, s[26:27] nt
.LBB0_4:
	.loc	1 0 26                          ; rmsnorm.py:0:26
	s_or_b64 exec, exec, s[20:21]
	s_load_dword s26, s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s27, s17, 16
	v_mov_b32_e32 v23, 0
	.loc	1 552 29 is_stmt 1              ; rmsnorm.py:552:29
	s_and_saveexec_b64 s[20:21], s[10:11]
	s_cbranch_execz .LBB0_6
; %bb.5:
	.loc	1 0 29 is_stmt 0                ; rmsnorm.py:0:29
	s_ashr_i32 s23, s22, 31
	s_lshl_b64 s[10:11], s[22:23], 2
	s_add_u32 s10, s6, s10
	s_addc_u32 s11, s7, s11
	.loc	1 552 29                        ; rmsnorm.py:552:29
	global_load_dword v23, v2, s[10:11] nt
.LBB0_6:
	.loc	1 0 29                          ; rmsnorm.py:0:29
	s_or_b64 exec, exec, s[20:21]
	s_load_dword s17, s[0:1], 0x40
	.loc	1 465 37 is_stmt 1              ; rmsnorm.py:465:37
	s_and_b32 s0, 0xffff, s27
	s_cmp_lg_u32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 563 52                        ; rmsnorm.py:563:52
	v_cvt_f32_i32_e32 v1, s25
	.loc	1 465 37                        ; rmsnorm.py:465:37
	s_cmp_lg_u64 s[0:1], 0
	s_addc_u32 s25, s26, 0
	v_cndmask_b32_e64 v6, 0, 1, s[0:1]
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_sub_i32 s33, s24, s25
	v_and_b32_e32 v18, 0x80, v0
	s_mov_b32 s23, 0
	.loc	1 465 37                        ; rmsnorm.py:465:37
	v_readfirstlane_b32 s27, v6
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_cmp_ge_i32 s16, s33
	v_cmp_eq_u32_e32 vcc, 0, v18
	v_lshrrev_b32_e32 v17, 4, v0
	v_cmp_gt_u32_e64 s[20:21], 2, v0
	v_lshl_add_u32 v16, v0, 2, 0
	v_cmp_eq_u32_e64 s[0:1], 0, v0
	s_cbranch_scc1 .LBB0_27
; %bb.7:                                ; %.lr.ph
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v6, v2
	v_lshl_add_u64 v[8:9], s[2:3], 0, v[6:7]
	v_lshl_add_u64 v[10:11], s[6:7], 0, v[6:7]
	v_lshl_add_u64 v[12:13], s[8:9], 0, v[6:7]
	v_lshl_add_u64 v[14:15], s[4:5], 0, v[6:7]
	v_and_b32_e32 v6, 0xbf, v0
	s_add_i32 s7, s16, s26
	v_cmp_eq_u32_e64 s[10:11], 0, v6
	v_and_b32_e32 v6, 4, v17
	s_add_i32 s7, s7, s27
	s_and_b64 s[2:3], vcc, s[18:19]
	v_add_u32_e32 v22, 0, v6
	s_mul_i32 s6, s16, s15
	s_mul_i32 s36, s15, s25
	s_mul_i32 s37, s14, s25
	s_mul_i32 s38, s14, s7
	s_mov_b32 s28, s22
	s_mov_b32 s26, s16
	.loc	1 549 26                        ; rmsnorm.py:549:26
	s_add_i32 s30, s38, s23
	v_mov_b32_e32 v20, 0
	s_and_saveexec_b64 s[34:35], s[18:19]
	s_cbranch_execnz .LBB0_24
.LBB0_8:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_or_b64 exec, exec, s[34:35]
	v_mov_b32_e32 v21, 0
	.loc	1 552 29 is_stmt 1              ; rmsnorm.py:552:29
	s_and_saveexec_b64 s[34:35], s[18:19]
	s_cbranch_execnz .LBB0_25
.LBB0_9:
	.loc	1 0 29 is_stmt 0                ; rmsnorm.py:0:29
	s_or_b64 exec, exec, s[34:35]
	.loc	1 553 19 is_stmt 1              ; rmsnorm.py:553:19
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v3, v23
	.loc	1 557 35                        ; rmsnorm.py:557:35
	s_and_saveexec_b64 s[30:31], s[2:3]
	s_cbranch_execnz .LBB0_26
.LBB0_10:
	.loc	1 0 35 is_stmt 0                ; rmsnorm.py:0:35
	s_or_b64 exec, exec, s[30:31]
	v_mov_b32_e32 v6, 0
	.loc	1 560 24 is_stmt 1              ; rmsnorm.py:560:24
	s_and_saveexec_b64 s[28:29], s[18:19]
	s_cbranch_execz .LBB0_12
.LBB0_11:
	global_load_dword v6, v[4:5], off
.LBB0_12:
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[28:29]
	.loc	1 561 29 is_stmt 1              ; rmsnorm.py:561:29
	v_mul_f32_e32 v23, v3, v3
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mov_b32_dpp v23, v23 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:562:30 ]
	v_fmac_f32_e32 v23, v3, v3
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	v_mov_b32_e32 v24, v23
	s_nop 1
	v_mov_b32_dpp v24, v24 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:562:30 ]
	v_add_f32_e32 v23, v23, v24
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_nop 0
	v_readlane_b32 s7, v23, 63
	s_and_saveexec_b64 s[28:29], s[10:11]
; %bb.13:
	s_nop 0
	v_mov_b32_e32 v23, s7
	ds_write_b32 v22, v23
; %bb.14:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[28:29]
	v_mov_b32_e32 v23, 0
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[28:29], s[20:21]
; %bb.15:
	ds_read_b32 v23, v16
; %bb.16:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[28:29]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v24, v23
	s_nop 1
	v_mov_b32_dpp v24, v24 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[28:29], s[0:1]
; %bb.17:
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v23, v23, v24
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	ds_write_b32 v16, v23
; %bb.18:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[28:29]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v23, v7
.Ltmp3:
	.loc	1 563 52 is_stmt 1              ; rmsnorm.py:563:52
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v24, s[28:29], v1, v1, v23
	v_rcp_f32_e32 v25, v24
	v_div_scale_f32 v26, vcc, v23, v1, v23
	v_fma_f32 v27, -v24, v25, 1.0
	v_fmac_f32_e32 v25, v27, v25
	v_mul_f32_e32 v27, v26, v25
	v_fma_f32 v28, -v24, v27, v26
	v_fmac_f32_e32 v27, v28, v25
	v_fma_f32 v24, -v24, v27, v26
	v_div_fmas_f32 v24, v24, v25, v27
	v_div_fixup_f32 v23, v24, v1, v23
	.loc	1 563 62 is_stmt 0              ; rmsnorm.py:563:62
	v_add_f32_e32 v23, s17, v23
	.loc	1 563 40                        ; rmsnorm.py:563:40
	v_rsq_f32_e32 v23, v23
	.loc	1 566 43 is_stmt 1              ; rmsnorm.py:566:43
	s_and_saveexec_b64 s[28:29], s[0:1]
	s_cbranch_execz .LBB0_20
; %bb.19:
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_ashr_i32 s27, s26, 31
	s_lshl_b64 s[30:31], s[26:27], 2
	s_add_u32 s30, s12, s30
	s_addc_u32 s31, s13, s31
	.loc	1 566 43                        ; rmsnorm.py:566:43
	global_store_dword v7, v23, s[30:31]
.LBB0_20:
	.loc	1 0 43                          ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[28:29]
	.loc	1 572 34 is_stmt 1              ; rmsnorm.py:572:34
	s_and_saveexec_b64 s[28:29], s[2:3]
	s_cbranch_execz .LBB0_22
; %bb.21:
	.loc	1 568 29                        ; rmsnorm.py:568:29
	v_mul_f32_e32 v3, v3, v23
	.loc	1 570 39                        ; rmsnorm.py:570:39
	s_ashr_i32 s7, s6, 31
	.loc	1 568 43                        ; rmsnorm.py:568:43
	v_mul_f32_e32 v3, v19, v3
	.loc	1 570 69                        ; rmsnorm.py:570:69
	v_lshl_add_u64 v[24:25], s[6:7], 2, v[14:15]
	.loc	1 572 34                        ; rmsnorm.py:572:34
	global_store_dword v[24:25], v3, off
.LBB0_22:
	.loc	1 0 34 is_stmt 0                ; rmsnorm.py:0:34
	s_or_b64 exec, exec, s[28:29]
	.loc	1 546 67 is_stmt 1              ; rmsnorm.py:546:67
	s_add_i32 s26, s26, s25
	s_add_i32 s6, s6, s36
	s_add_i32 s23, s23, s37
	s_cmp_lt_i32 s26, s33
	.loc	1 547 47                        ; rmsnorm.py:547:47
	s_mul_i32 s28, s26, s14
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_cbranch_scc0 .LBB0_28
; %bb.23:
	.loc	1 0 67 is_stmt 0                ; rmsnorm.py:0:67
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v19, v6
	v_mov_b32_e32 v23, v21
	v_mov_b32_e32 v3, v20
	.loc	1 549 26 is_stmt 1              ; rmsnorm.py:549:26
	s_add_i32 s30, s38, s23
	v_mov_b32_e32 v20, 0
	s_and_saveexec_b64 s[34:35], s[18:19]
	s_cbranch_execz .LBB0_8
.LBB0_24:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_ashr_i32 s31, s30, 31
	v_lshl_add_u64 v[20:21], s[30:31], 2, v[8:9]
	.loc	1 549 26                        ; rmsnorm.py:549:26
	global_load_dword v20, v[20:21], off nt
	s_or_b64 exec, exec, s[34:35]
	v_mov_b32_e32 v21, 0
	.loc	1 552 29 is_stmt 1              ; rmsnorm.py:552:29
	s_and_saveexec_b64 s[34:35], s[18:19]
	s_cbranch_execz .LBB0_9
.LBB0_25:
	.loc	1 0 29 is_stmt 0                ; rmsnorm.py:0:29
	s_ashr_i32 s31, s30, 31
	v_lshl_add_u64 v[24:25], s[30:31], 2, v[10:11]
	.loc	1 552 29                        ; rmsnorm.py:552:29
	global_load_dword v21, v[24:25], off nt
	s_or_b64 exec, exec, s[34:35]
	.loc	1 553 19 is_stmt 1              ; rmsnorm.py:553:19
	s_waitcnt vmcnt(1)
	v_add_f32_e32 v3, v3, v23
	.loc	1 557 35                        ; rmsnorm.py:557:35
	s_and_saveexec_b64 s[30:31], s[2:3]
	s_cbranch_execz .LBB0_10
.LBB0_26:
	.loc	1 0 35 is_stmt 0                ; rmsnorm.py:0:35
	s_ashr_i32 s29, s28, 31
	v_lshl_add_u64 v[24:25], s[28:29], 2, v[12:13]
	.loc	1 557 35                        ; rmsnorm.py:557:35
	global_store_dword v[24:25], v3, off
	s_or_b64 exec, exec, s[30:31]
	v_mov_b32_e32 v6, 0
	.loc	1 560 24 is_stmt 1              ; rmsnorm.py:560:24
	s_and_saveexec_b64 s[28:29], s[18:19]
	s_cbranch_execnz .LBB0_11
	s_branch .LBB0_12
.LBB0_27:
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v6, v19
	v_mov_b32_e32 v21, v23
	v_mov_b32_e32 v20, v3
	s_branch .LBB0_29
.LBB0_28:                               ; %Flow
	s_add_i32 s22, s22, s23
.LBB0_29:                               ; %._crit_edge
	.loc	1 546 67 is_stmt 1              ; rmsnorm.py:546:67
	s_cmp_gt_i32 s25, -1
	s_cselect_b32 s0, -1, 1
	s_abs_i32 s1, s25
	v_cvt_f32_u32_e32 v3, s1
	s_sub_i32 s2, s24, s16
	s_sub_i32 s3, 0, s1
	s_add_i32 s2, s2, s25
	v_rcp_iflag_f32_e32 v3, v3
	s_add_i32 s2, s2, s0
	s_xor_b32 s0, s2, s25
	s_abs_i32 s2, s2
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	s_ashr_i32 s0, s0, 31
	.loc	1 557 35                        ; rmsnorm.py:557:35
	v_cmp_eq_u32_e32 vcc, 0, v18
	.loc	1 546 67                        ; rmsnorm.py:546:67
	v_readfirstlane_b32 s6, v3
	s_mul_i32 s3, s3, s6
	s_mul_hi_u32 s3, s6, s3
	s_add_i32 s6, s6, s3
	s_mul_hi_u32 s3, s2, s6
	s_mul_i32 s6, s3, s1
	s_sub_i32 s2, s2, s6
	s_add_i32 s7, s3, 1
	s_sub_i32 s6, s2, s1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s3, s7, s3
	s_cselect_b32 s2, s6, s2
	s_add_i32 s6, s3, 1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s1, s6, s3
	s_xor_b32 s1, s1, s0
	s_sub_i32 s10, s1, s0
	s_cmp_gt_i32 s10, 0
	s_cselect_b64 s[6:7], -1, 0
	.loc	1 557 35                        ; rmsnorm.py:557:35
	s_and_b64 s[0:1], vcc, s[18:19]
	.loc	1 553 19                        ; rmsnorm.py:553:19
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v3, v20, v21
	.loc	1 557 35                        ; rmsnorm.py:557:35
	s_and_b64 s[2:3], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_31
; %bb.30:
	.loc	1 0 35 is_stmt 0                ; rmsnorm.py:0:35
	s_ashr_i32 s23, s22, 31
	s_lshl_b64 s[18:19], s[22:23], 2
	s_add_u32 s8, s8, s18
	s_addc_u32 s9, s9, s19
	.loc	1 557 35                        ; rmsnorm.py:557:35
	global_store_dword v2, v3, s[8:9]
.LBB0_31:
	.loc	1 0 35                          ; rmsnorm.py:0:35
	s_or_b64 exec, exec, s[0:1]
	.loc	1 561 29 is_stmt 1              ; rmsnorm.py:561:29
	v_mul_f32_e32 v4, v3, v3
.Ltmp4:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mov_b32_dpp v4, v4 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:562:30 ]
	v_fmac_f32_e32 v4, v3, v3
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	v_mov_b32_e32 v5, v4
	s_nop 1
	v_mov_b32_dpp v5, v5 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:562:30 ]
	v_add_f32_e32 v4, v4, v5
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_nop 0
	v_readlane_b32 s8, v4, 63
	v_and_b32_e32 v4, 0xbf, v0
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_and_saveexec_b64 s[0:1], vcc
; %bb.32:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	v_and_b32_e32 v4, 4, v17
	v_add_u32_e32 v4, 0, v4
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	v_mov_b32_e32 v5, s8
	ds_write_b32 v4, v5
; %bb.33:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[0:1]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	v_cmp_gt_u32_e32 vcc, 2, v0
	v_mov_b32_e32 v4, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
; %bb.34:
	ds_read_b32 v4, v16
; %bb.35:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[0:1]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v5, v4
	v_cmp_eq_u32_e64 s[0:1], 0, v0
	s_nop 0
	v_mov_b32_dpp v5, v5 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[8:9], s[0:1]
; %bb.36:
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v0, v4, v5
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	ds_write_b32 v16, v0
; %bb.37:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[8:9]
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:562:30 ]
	v_mov_b32_e32 v0, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v4, v0
.Ltmp5:
	.loc	1 546 67 is_stmt 1              ; rmsnorm.py:546:67
	s_add_i32 s10, s10, -1
	.loc	1 566 43                        ; rmsnorm.py:566:43
	s_and_b64 s[6:7], s[0:1], s[6:7]
	.loc	1 563 52                        ; rmsnorm.py:563:52
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v5, s[8:9], v1, v1, v4
	v_rcp_f32_e32 v7, v5
	.loc	1 546 67                        ; rmsnorm.py:546:67
	s_max_i32 s8, s10, 0
	s_mul_i32 s8, s8, s25
	s_add_i32 s8, s8, s16
	.loc	1 563 52                        ; rmsnorm.py:563:52
	v_fma_f32 v8, -v5, v7, 1.0
	v_fmac_f32_e32 v7, v8, v7
	v_div_scale_f32 v8, vcc, v4, v1, v4
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v10, -v5, v9, v8
	v_fmac_f32_e32 v9, v10, v7
	v_fma_f32 v5, -v5, v9, v8
	v_div_fmas_f32 v5, v5, v7, v9
	v_div_fixup_f32 v1, v5, v1, v4
	.loc	1 563 62 is_stmt 0              ; rmsnorm.py:563:62
	v_add_f32_e32 v1, s17, v1
	.loc	1 563 40                        ; rmsnorm.py:563:40
	v_rsq_f32_e32 v1, v1
	.loc	1 566 43 is_stmt 1              ; rmsnorm.py:566:43
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execnz .LBB0_40
; %bb.38:
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[0:1]
	.loc	1 572 34 is_stmt 1              ; rmsnorm.py:572:34
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execnz .LBB0_41
.LBB0_39:
	.loc	1 468 4                         ; rmsnorm.py:468:4
	s_endpgm
.LBB0_40:
	.loc	1 0 4 is_stmt 0                 ; rmsnorm.py:0:4
	s_ashr_i32 s9, s8, 31
	s_lshl_b64 s[6:7], s[8:9], 2
	s_add_u32 s6, s12, s6
	s_addc_u32 s7, s13, s7
	.loc	1 566 43 is_stmt 1              ; rmsnorm.py:566:43
	global_store_dword v0, v1, s[6:7]
	s_or_b64 exec, exec, s[0:1]
	.loc	1 572 34                        ; rmsnorm.py:572:34
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_39
.LBB0_41:
	.loc	1 570 49                        ; rmsnorm.py:570:49
	s_mul_i32 s0, s8, s15
	.loc	1 570 39 is_stmt 0              ; rmsnorm.py:570:39
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	.loc	1 568 29 is_stmt 1              ; rmsnorm.py:568:29
	v_mul_f32_e32 v0, v3, v1
	.loc	1 570 39                        ; rmsnorm.py:570:39
	s_add_u32 s0, s4, s0
	.loc	1 568 43                        ; rmsnorm.py:568:43
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v0, v6, v0
	.loc	1 570 39                        ; rmsnorm.py:570:39
	s_addc_u32 s1, s5, s1
	.loc	1 572 34                        ; rmsnorm.py:572:34
	global_store_dword v2, v0, s[0:1]
	.loc	1 468 4                         ; rmsnorm.py:468:4
	s_endpgm
.Ltmp6:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0
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
		.amdhsa_next_free_vgpr 29
		.amdhsa_next_free_sgpr 39
		.amdhsa_accum_offset 32
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
	.size	_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0, .Lfunc_end0-_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0
	.cfi_endproc
                                        ; -- End function
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.num_vgpr, 29
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.num_agpr, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.numbered_sgpr, 39
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.private_seg_size, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.uses_vcc, 1
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.uses_flat_scratch, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.has_dyn_sized_stack, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.has_recursion, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1936
; TotalNumSgprs: 45
; NumVgprs: 29
; NumAgprs: 0
; TotalNumVgprs: 29
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 5
; VGPRBlocks: 3
; NumSGPRsForWavesPerEU: 45
; NumVGPRsForWavesPerEU: 29
; AccumOffset: 32
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 7
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
	.short	562                             ; DW_AT_call_line
	.byte	30                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
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
	.asciz	"_fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0" ; string offset=77
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
      - .offset:         208
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .max_flat_workgroup_size: 256
    .name:           _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0
    .private_segment_fixed_size: 0
    .sgpr_count:     45
    .sgpr_spill_count: 0
    .symbol:         _fused_add_rmsnorm_kernel_BLOCK_SIZE_128_USE_BLOCKED_0.kd
    .uses_dynamic_stack: false
    .vgpr_count:     29
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
