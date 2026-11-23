	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1 ; -- Begin function _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
	.p2align	8
	.type	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1,@function
_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1: ; @_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
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
	s_load_dword s33, s[0:1], 0x38
.Ltmp1:
	.loc	1 470 67 is_stmt 1              ; rmsnorm.py:470:67
	s_waitcnt lgkmcnt(0)
	s_cmp_ge_i32 s16, s33
	s_cbranch_scc1 .LBB0_41
; %bb.1:                                ; %.lr.ph25
	.loc	1 465 37                        ; rmsnorm.py:465:37
	s_load_dword s17, s[0:1], 0x68
	s_load_dwordx2 s[28:29], s[0:1], 0x3c
	s_load_dword s18, s[0:1], 0x58
	.loc	1 466 31                        ; rmsnorm.py:466:31
	v_and_b32_e32 v2, 63, v0
	v_mov_b32_e32 v1, 0
	.loc	1 465 37                        ; rmsnorm.py:465:37
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s0, s17, 16
	s_cmp_lg_u32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lg_u64 s[0:1], 0
	s_addc_u32 s50, s18, 0
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 41 22                         ; standard.py:41:22 @[ rmsnorm.py:477:42 ]
	s_add_i32 s17, s28, 63
	.loc	2 41 28 is_stmt 0               ; standard.py:41:28 @[ rmsnorm.py:477:42 ]
	s_ashr_i32 s0, s17, 31
	s_lshr_b32 s0, s0, 26
	s_add_i32 s0, s17, s0
	s_ashr_i32 s20, s0, 6
.Ltmp3:
	.loc	1 496 33 is_stmt 1              ; rmsnorm.py:496:33
	s_andn2_b32 s0, s0, 63
	s_sub_i32 s0, s0, 64
	s_cmpk_gt_i32 s17, 0x7f
	.loc	1 513 40                        ; rmsnorm.py:513:40
	v_cvt_f32_i32_e32 v3, s28
	s_cselect_b64 s[24:25], -1, 0
	s_cmpk_gt_i32 s17, 0xbf
	.loc	1 496 46                        ; rmsnorm.py:496:46
	v_or_b32_e32 v4, s0, v2
	s_cselect_b64 s[22:23], -1, 0
	v_and_b32_e32 v8, 0xc0, v0
	v_cmp_eq_u32_e64 s[18:19], 0, v0
	v_lshlrev_b32_e32 v0, 2, v2
	.loc	1 497 26                        ; rmsnorm.py:497:26
	v_cmp_gt_i32_e64 s[0:1], s28, v4
	.loc	1 538 29                        ; rmsnorm.py:538:29
	v_ashrrev_i32_e32 v5, 31, v4
	v_cmp_eq_u32_e64 s[26:27], 0, v8
	v_cndmask_b32_e64 v22, 0, 1, s[24:25]
	v_lshl_add_u64 v[8:9], s[10:11], 0, v[0:1]
	.loc	1 470 67                        ; rmsnorm.py:470:67
	s_max_i32 s28, s20, 3
	v_lshl_add_u64 v[10:11], s[8:9], 0, v[0:1]
	v_or_b32_e32 v20, 0x100, v0
	v_mov_b32_e32 v21, v1
	v_lshl_add_u64 v[16:17], s[4:5], 0, v[0:1]
	v_cndmask_b32_e64 v0, 0, 1, s[22:23]
	.loc	1 538 29                        ; rmsnorm.py:538:29
	v_lshl_add_u64 v[6:7], v[4:5], 2, s[10:11]
	s_and_b64 s[30:31], s[26:27], s[24:25]
	s_and_b64 s[34:35], s[26:27], s[0:1]
	.loc	1 470 67                        ; rmsnorm.py:470:67
	s_add_i32 s28, s28, -2
	s_mul_i32 s36, s16, s14
	s_mul_i32 s51, s14, s50
	v_lshl_add_u64 v[12:13], s[6:7], 0, v[20:21]
	v_lshl_add_u64 v[14:15], s[2:3], 0, v[20:21]
	s_mul_i32 s38, s16, s15
	s_mul_i32 s52, s15, s50
	v_lshl_add_u64 v[18:19], s[10:11], 0, v[20:21]
	v_lshl_add_u64 v[20:21], s[8:9], 0, v[20:21]
	v_cmp_ne_u32_e64 s[20:21], 1, v22
	v_cmp_ne_u32_e64 s[22:23], 1, v0
	s_mov_b64 s[10:11], 0x100
	v_lshlrev_b32_e32 v0, 2, v2
	s_branch .LBB0_3
.LBB0_2:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 67 is_stmt 0                ; rmsnorm.py:0:67
	s_or_b64 exec, exec, s[42:43]
	.loc	1 470 67 is_stmt 1              ; rmsnorm.py:470:67
	s_add_i32 s16, s50, s16
	s_add_i32 s36, s36, s51
	s_add_i32 s38, s38, s52
	s_cmp_lt_i32 s16, s33
	s_cbranch_scc0 .LBB0_41
.LBB0_3:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_10 Depth 2
                                        ;     Child Loop BB0_28 Depth 2
	.loc	1 471 50                        ; rmsnorm.py:471:50
	s_mul_i32 s40, s16, s14
	.loc	1 471 40 is_stmt 0              ; rmsnorm.py:471:40
	s_ashr_i32 s41, s40, 31
	s_lshl_b64 s[46:47], s[40:41], 2
	s_add_u32 s42, s2, s46
	s_addc_u32 s43, s3, s47
	.loc	1 483 28 is_stmt 1              ; rmsnorm.py:483:28
	s_and_b64 vcc, exec, s[20:21]
	v_mov_b32_e32 v23, 0
	s_cbranch_vccnz .LBB0_5
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v23, v0, s[42:43]
.LBB0_5:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 473 42                        ; rmsnorm.py:473:42
	s_add_u32 s44, s6, s46
	s_addc_u32 s45, s7, s47
	v_mov_b32_e32 v30, 0
	.loc	1 486 33                        ; rmsnorm.py:486:33
	s_and_b64 vcc, exec, s[20:21]
	v_mov_b32_e32 v31, 0
	s_cbranch_vccnz .LBB0_7
; %bb.6:                                ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v31, v0, s[44:45]
.LBB0_7:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 471 50                        ; rmsnorm.py:471:50
	s_ashr_i32 s37, s36, 31
	.loc	1 479 52                        ; rmsnorm.py:479:52
	s_and_b64 vcc, exec, s[22:23]
	.loc	1 471 50                        ; rmsnorm.py:471:50
	s_lshl_b64 s[40:41], s[36:37], 2
	.loc	1 479 52                        ; rmsnorm.py:479:52
	s_cbranch_vccnz .LBB0_12
; %bb.8:                                ; %.lr.ph.preheader
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 471 50                        ; rmsnorm.py:471:50
	s_waitcnt vmcnt(0)
	v_lshl_add_u64 v[24:25], v[10:11], 0, s[40:41]
	v_lshl_add_u64 v[26:27], v[12:13], 0, s[40:41]
	v_lshl_add_u64 v[28:29], v[14:15], 0, s[40:41]
	v_mov_b32_e32 v30, 0
	v_mov_b32_e32 v22, v2
	s_mov_b32 s17, s28
	s_branch .LBB0_10
.LBB0_9:                                ;   in Loop: Header=BB0_10 Depth=2
	.loc	1 0 50 is_stmt 0                ; rmsnorm.py:0:50
	s_or_b64 exec, exec, s[48:49]
	.loc	1 493 42 is_stmt 1              ; rmsnorm.py:493:42
	v_mul_f32_e32 v33, v32, v32
	.loc	1 479 52                        ; rmsnorm.py:479:52
	s_add_i32 s17, s17, -1
	v_lshl_add_u64 v[24:25], v[24:25], 0, s[10:11]
.Ltmp4:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	v_mov_b32_dpp v33, v33 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_fmac_f32_e32 v33, v32, v32
.Ltmp5:
	.loc	1 479 52                        ; rmsnorm.py:479:52
	v_add_u32_e32 v22, 64, v22
	v_lshl_add_u64 v[26:27], v[26:27], 0, s[10:11]
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_add_f32_dpp v32, v33, v33 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp7:
	.loc	1 479 52                        ; rmsnorm.py:479:52
	s_cmp_lg_u32 s17, 0
	v_lshl_add_u64 v[28:29], v[28:29], 0, s[10:11]
.Ltmp8:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_add_f32_dpp v32, v32, v32 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v32, v32, v32 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	v_mov_b32_e32 v33, v32
	s_nop 1
	v_mov_b32_dpp v33, v33 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_add_f32_e32 v32, v32, v33
	s_nop 1
	v_add_f32_dpp v32, v32, v32 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	s_nop 0
	v_readlane_b32 s37, v32, 63
.Ltmp9:
	.loc	1 493 31                        ; rmsnorm.py:493:31
	s_nop 1
	v_add_f32_e32 v30, s37, v30
	.loc	1 479 52                        ; rmsnorm.py:479:52
	s_cbranch_scc0 .LBB0_13
.LBB0_10:                               ; %.lr.ph
                                        ;   Parent Loop BB0_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v32, v23
	v_mov_b32_e32 v33, v31
	.loc	1 483 28 is_stmt 1              ; rmsnorm.py:483:28
	global_load_dword v23, v[28:29], off
	.loc	1 486 33                        ; rmsnorm.py:486:33
	global_load_dword v31, v[26:27], off
	.loc	1 487 21                        ; rmsnorm.py:487:21
	v_add_f32_e32 v32, v32, v33
	.loc	1 490 39                        ; rmsnorm.py:490:39
	s_and_saveexec_b64 s[48:49], s[26:27]
	s_cbranch_execz .LBB0_9
; %bb.11:                               ;   in Loop: Header=BB0_10 Depth=2
	global_store_dword v[24:25], v32, off
	s_branch .LBB0_9
.LBB0_12:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 39 is_stmt 0                ; rmsnorm.py:0:39
	v_mov_b32_e32 v22, v2
.LBB0_13:                               ; %._crit_edge
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 474 44 is_stmt 1              ; rmsnorm.py:474:44
	s_add_u32 s46, s8, s46
	s_addc_u32 s47, s9, s47
	.loc	1 487 21                        ; rmsnorm.py:487:21
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v24, v23, v31
	.loc	1 490 39                        ; rmsnorm.py:490:39
	s_and_saveexec_b64 s[48:49], s[30:31]
	s_cbranch_execz .LBB0_15
; %bb.14:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 39 is_stmt 0                ; rmsnorm.py:0:39
	v_ashrrev_i32_e32 v23, 31, v22
	v_lshl_add_u64 v[22:23], v[22:23], 2, s[46:47]
	.loc	1 490 39                        ; rmsnorm.py:490:39
	global_store_dword v[22:23], v24, off
.LBB0_15:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 39                          ; rmsnorm.py:0:39
	s_or_b64 exec, exec, s[48:49]
	.loc	1 493 42 is_stmt 1              ; rmsnorm.py:493:42
	v_mul_f32_e32 v22, v24, v24
.Ltmp10:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	s_nop 1
	v_mov_b32_dpp v22, v22 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_fmac_f32_e32 v22, v24, v24
	s_nop 1
	v_add_f32_dpp v22, v22, v22 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v22, v22, v22 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v22, v22, v22 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	v_mov_b32_e32 v23, v22
	s_nop 1
	v_mov_b32_dpp v23, v23 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:493:38 ]
	v_add_f32_e32 v22, v22, v23
	v_mov_b32_e32 v23, 0
	s_nop 0
	v_add_f32_dpp v22, v22, v22 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:493:38 ]
	s_nop 0
	v_readlane_b32 s17, v22, 63
	v_mov_b32_e32 v22, 0
.Ltmp11:
	.loc	1 500 24                        ; rmsnorm.py:500:24
	s_and_saveexec_b64 s[48:49], s[0:1]
	s_cbranch_execz .LBB0_17
; %bb.16:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	v_lshl_add_u64 v[24:25], v[4:5], 2, s[42:43]
	.loc	1 500 24                        ; rmsnorm.py:500:24
	global_load_dword v23, v[24:25], off nt
.LBB0_17:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24                          ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[48:49]
	.loc	1 503 29 is_stmt 1              ; rmsnorm.py:503:29
	s_and_saveexec_b64 s[42:43], s[0:1]
	s_cbranch_execz .LBB0_19
; %bb.18:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 29 is_stmt 0                ; rmsnorm.py:0:29
	v_lshl_add_u64 v[24:25], v[4:5], 2, s[44:45]
	.loc	1 503 29                        ; rmsnorm.py:503:29
	global_load_dword v22, v[24:25], off nt
.LBB0_19:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 29                          ; rmsnorm.py:0:29
	s_or_b64 exec, exec, s[42:43]
	.loc	1 504 17 is_stmt 1              ; rmsnorm.py:504:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v24, v23, v22
	.loc	1 506 45                        ; rmsnorm.py:506:45
	v_lshl_add_u64 v[22:23], v[4:5], 2, s[46:47]
	.loc	1 507 35                        ; rmsnorm.py:507:35
	s_and_saveexec_b64 s[42:43], s[34:35]
	s_cbranch_execz .LBB0_21
; %bb.20:                               ;   in Loop: Header=BB0_3 Depth=1
	global_store_dword v[22:23], v24, off
.LBB0_21:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 35 is_stmt 0                ; rmsnorm.py:0:35
	s_or_b64 exec, exec, s[42:43]
	.loc	1 510 38 is_stmt 1              ; rmsnorm.py:510:38
	v_mul_f32_e32 v26, v24, v24
	.loc	1 493 31                        ; rmsnorm.py:493:31
	v_add_f32_e32 v25, s17, v30
	.loc	1 479 52                        ; rmsnorm.py:479:52
	v_cndmask_b32_e64 v25, v30, v25, s[24:25]
.Ltmp12:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:510:34 ]
	v_mov_b32_dpp v26, v26 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:510:34 ]
	v_fmac_f32_e32 v26, v24, v24
	s_nop 1
	v_add_f32_dpp v24, v26, v26 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:510:34 ]
	v_mov_b32_e32 v26, v24
	s_nop 1
	v_mov_b32_dpp v26, v26 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:510:34 ]
	v_add_f32_e32 v24, v24, v26
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:510:34 ]
	s_nop 0
	v_readlane_b32 s17, v24, 63
.Ltmp13:
	.loc	1 510 27                        ; rmsnorm.py:510:27
	s_nop 1
	v_add_f32_e32 v24, s17, v25
	.loc	1 513 40                        ; rmsnorm.py:513:40
	v_div_scale_f32 v25, s[42:43], v3, v3, v24
	v_rcp_f32_e32 v26, v25
	s_nop 0
	v_fma_f32 v27, -v25, v26, 1.0
	v_fmac_f32_e32 v26, v27, v26
	v_div_scale_f32 v27, vcc, v24, v3, v24
	v_mul_f32_e32 v28, v27, v26
	v_fma_f32 v29, -v25, v28, v27
	v_fmac_f32_e32 v28, v29, v26
	v_fma_f32 v25, -v25, v28, v27
	v_div_fmas_f32 v25, v25, v26, v28
	v_div_fixup_f32 v24, v25, v3, v24
	.loc	1 514 49                        ; rmsnorm.py:514:49
	v_add_f32_e32 v24, s29, v24
	.loc	1 514 35 is_stmt 0              ; rmsnorm.py:514:35
	v_rsq_f32_e32 v32, v24
	.loc	1 517 43 is_stmt 1              ; rmsnorm.py:517:43
	s_and_saveexec_b64 s[42:43], s[18:19]
	s_cbranch_execz .LBB0_23
; %bb.22:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[44:45], s[16:17], 2
	s_add_u32 s44, s12, s44
	s_addc_u32 s45, s13, s45
	.loc	1 517 43                        ; rmsnorm.py:517:43
	global_store_dword v1, v32, s[44:45]
.LBB0_23:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 43                          ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[42:43]
	v_mov_b32_e32 v25, 0
	.loc	1 524 28 is_stmt 1              ; rmsnorm.py:524:28
	s_and_b64 vcc, exec, s[20:21]
	v_mov_b32_e32 v35, 0
	s_cbranch_vccz .LBB0_30
; %bb.24:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 526 28                        ; rmsnorm.py:526:28
	s_and_b64 vcc, exec, s[20:21]
	s_cbranch_vccz .LBB0_31
.LBB0_25:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 520 52                        ; rmsnorm.py:520:52
	s_and_b64 vcc, exec, s[22:23]
	s_cbranch_vccnz .LBB0_32
.LBB0_26:                               ; %.lr.ph19.preheader
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 471 50                        ; rmsnorm.py:471:50
	s_ashr_i32 s39, s38, 31
	v_lshl_add_u64 v[26:27], s[38:39], 2, v[16:17]
	v_lshl_add_u64 v[28:29], v[20:21], 0, s[40:41]
	v_mov_b64_e32 v[30:31], v[18:19]
	v_mov_b32_e32 v24, v2
	s_mov_b32 s17, s28
	.loc	1 524 28                        ; rmsnorm.py:524:28
	global_load_dword v34, v[28:29], off
	.loc	1 526 28                        ; rmsnorm.py:526:28
	global_load_dword v33, v[30:31], off
	.loc	1 529 38                        ; rmsnorm.py:529:38
	s_and_saveexec_b64 s[40:41], s[26:27]
	s_cbranch_execz .LBB0_28
.LBB0_27:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38 is_stmt 0                ; rmsnorm.py:0:38
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v35, v32, v35
	v_mul_f32_e32 v25, v35, v25
	.loc	1 529 38                        ; rmsnorm.py:529:38
	global_store_dword v[26:27], v25, off
.LBB0_28:                               ;   Parent Loop BB0_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	.loc	1 0 38                          ; rmsnorm.py:0:38
	s_or_b64 exec, exec, s[40:41]
	.loc	1 520 52 is_stmt 1              ; rmsnorm.py:520:52
	s_add_i32 s17, s17, -1
	v_lshl_add_u64 v[26:27], v[26:27], 0, s[10:11]
	v_add_u32_e32 v24, 64, v24
	v_lshl_add_u64 v[30:31], v[30:31], 0, s[10:11]
	s_cmp_lg_u32 s17, 0
	v_lshl_add_u64 v[28:29], v[28:29], 0, s[10:11]
	s_cbranch_scc0 .LBB0_33
; %bb.29:                               ;   in Loop: Header=BB0_28 Depth=2
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v25, v33
	v_mov_b32_e32 v35, v34
	.loc	1 524 28 is_stmt 1              ; rmsnorm.py:524:28
	global_load_dword v34, v[28:29], off
	.loc	1 526 28                        ; rmsnorm.py:526:28
	global_load_dword v33, v[30:31], off
	.loc	1 529 38                        ; rmsnorm.py:529:38
	s_and_saveexec_b64 s[40:41], s[26:27]
	s_cbranch_execnz .LBB0_27
	s_branch .LBB0_28
.LBB0_30:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 524 28                        ; rmsnorm.py:524:28
	global_load_dword v35, v0, s[46:47]
	.loc	1 526 28                        ; rmsnorm.py:526:28
	s_and_b64 vcc, exec, s[20:21]
	s_cbranch_vccnz .LBB0_25
.LBB0_31:                               ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v25, v[8:9], off
	.loc	1 520 52                        ; rmsnorm.py:520:52
	s_and_b64 vcc, exec, s[22:23]
	s_cbranch_vccz .LBB0_26
.LBB0_32:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	v_mov_b32_e32 v24, v2
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v33, v25
	v_mov_b32_e32 v34, v35
.LBB0_33:                               ; %._crit_edge20
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 472 52 is_stmt 1              ; rmsnorm.py:472:52
	s_mul_i32 s40, s16, s15
	.loc	1 472 42 is_stmt 0              ; rmsnorm.py:472:42
	s_ashr_i32 s41, s40, 31
	s_lshl_b64 s[40:41], s[40:41], 2
	s_add_u32 s40, s4, s40
	s_addc_u32 s41, s5, s41
	.loc	1 529 38 is_stmt 1              ; rmsnorm.py:529:38
	s_and_saveexec_b64 s[42:43], s[30:31]
	s_cbranch_execz .LBB0_35
; %bb.34:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38 is_stmt 0                ; rmsnorm.py:0:38
	s_waitcnt vmcnt(2)
	v_ashrrev_i32_e32 v25, 31, v24
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v26, v32, v34
	v_lshl_add_u64 v[24:25], v[24:25], 2, s[40:41]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v26, v26, v33
	.loc	1 529 38                        ; rmsnorm.py:529:38
	global_store_dword v[24:25], v26, off
.LBB0_35:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38                          ; rmsnorm.py:0:38
	s_or_b64 exec, exec, s[42:43]
	v_mov_b32_e32 v24, 0
	s_waitcnt vmcnt(2)
	v_mov_b32_e32 v25, 0
	.loc	1 535 24 is_stmt 1              ; rmsnorm.py:535:24
	s_and_saveexec_b64 s[42:43], s[0:1]
	s_cbranch_execnz .LBB0_38
; %bb.36:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[42:43]
	.loc	1 539 24 is_stmt 1              ; rmsnorm.py:539:24
	s_and_saveexec_b64 s[42:43], s[0:1]
	s_cbranch_execnz .LBB0_39
.LBB0_37:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[42:43]
	.loc	1 542 34 is_stmt 1              ; rmsnorm.py:542:34
	s_and_saveexec_b64 s[42:43], s[34:35]
	s_cbranch_execz .LBB0_2
	s_branch .LBB0_40
.LBB0_38:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 535 24                        ; rmsnorm.py:535:24
	global_load_dword v25, v[22:23], off nt
	s_or_b64 exec, exec, s[42:43]
	.loc	1 539 24                        ; rmsnorm.py:539:24
	s_and_saveexec_b64 s[42:43], s[0:1]
	s_cbranch_execz .LBB0_37
.LBB0_39:                               ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v24, v[6:7], off
	s_or_b64 exec, exec, s[42:43]
	.loc	1 542 34                        ; rmsnorm.py:542:34
	s_and_saveexec_b64 s[42:43], s[34:35]
	s_cbranch_execz .LBB0_2
.LBB0_40:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 34 is_stmt 0                ; rmsnorm.py:0:34
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v25, v32, v25
	v_lshl_add_u64 v[22:23], v[4:5], 2, s[40:41]
	v_mul_f32_e32 v24, v25, v24
	.loc	1 542 34                        ; rmsnorm.py:542:34
	global_store_dword v[22:23], v24, off
	s_branch .LBB0_2
.LBB0_41:                               ; %._crit_edge26
	.loc	1 468 4 is_stmt 1               ; rmsnorm.py:468:4
	s_endpgm
.Ltmp14:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
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
		.amdhsa_next_free_vgpr 36
		.amdhsa_next_free_sgpr 53
		.amdhsa_accum_offset 36
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
	.size	_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1, .Lfunc_end0-_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
	.cfi_endproc
                                        ; -- End function
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.num_vgpr, 36
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.num_agpr, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.numbered_sgpr, 53
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.private_seg_size, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.uses_vcc, 1
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.uses_flat_scratch, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_dyn_sized_stack, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_recursion, 0
	.set _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1852
; TotalNumSgprs: 59
; NumVgprs: 36
; NumAgprs: 0
; TotalNumVgprs: 36
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 7
; VGPRBlocks: 4
; NumSGPRsForWavesPerEU: 59
; NumVGPRsForWavesPerEU: 36
; AccumOffset: 36
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 8
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
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
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
	.byte	1                               ; Abbrev [1] 0xb:0x6f DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x49 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.short	477                             ; DW_AT_call_line
	.byte	42                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x56:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	493                             ; DW_AT_call_line
	.byte	38                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x63:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp12                         ; DW_AT_low_pc
	.long	.Ltmp13-.Ltmp12                 ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.short	510                             ; DW_AT_call_line
	.byte	34                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
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
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"rmsnorm.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=18
.Linfo_string3:
	.asciz	"_fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1" ; string offset=77
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
    .name:           _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
    .private_segment_fixed_size: 0
    .sgpr_count:     59
    .sgpr_spill_count: 0
    .symbol:         _fused_add_rmsnorm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.kd
    .uses_dynamic_stack: false
    .vgpr_count:     36
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
