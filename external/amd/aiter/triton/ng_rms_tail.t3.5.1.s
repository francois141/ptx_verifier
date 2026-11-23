	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1 ; -- Begin function _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
	.p2align	8
	.type	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1,@function
_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1: ; @_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.31:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/normalization" "rmsnorm.py"
	.loc	1 55 0 prologue_end             ; rmsnorm.py:55:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_load_dword s14, s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.32:
.LBB0_0:
.Ltmp1:
	.loc	1 93 67 is_stmt 1               ; rmsnorm.py:93:67
	s_cmp_ge_i32 s15, s12
	s_cbranch_scc1 .LBB0_30
; %bb.1:                                ; %.lr.ph20
	.loc	1 0 67 is_stmt 0                ; rmsnorm.py:0:67
	s_mov_b32 s24, s15
	.loc	1 88 37 is_stmt 1               ; rmsnorm.py:88:37
	s_load_dword s15, s[0:1], 0x58
	s_load_dword s16, s[0:1], 0x48
	.loc	1 89 31                         ; rmsnorm.py:89:31
	v_and_b32_e32 v2, 63, v0
	.loc	1 118 40                        ; rmsnorm.py:118:40
	v_cvt_f32_i32_e32 v3, s13
	v_mov_b32_e32 v9, 0
	.loc	1 88 37                         ; rmsnorm.py:88:37
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s0, s15, 16
	s_cmp_lg_u32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lg_u64 s[0:1], 0
	s_addc_u32 s15, s16, 0
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 41 22                         ; standard.py:41:22 @[ rmsnorm.py:98:42 ]
	s_add_i32 s16, s13, 63
	.loc	2 41 28 is_stmt 0               ; standard.py:41:28 @[ rmsnorm.py:98:42 ]
	s_ashr_i32 s0, s16, 31
	s_lshr_b32 s0, s0, 26
	s_add_i32 s0, s16, s0
	s_ashr_i32 s25, s0, 6
.Ltmp3:
	.loc	1 108 33 is_stmt 1              ; rmsnorm.py:108:33
	s_andn2_b32 s0, s0, 63
	s_sub_i32 s0, s0, 64
	s_cmpk_gt_i32 s16, 0x7f
	.loc	1 108 46 is_stmt 0              ; rmsnorm.py:108:46
	v_or_b32_e32 v4, s0, v2
	s_cselect_b64 s[18:19], -1, 0
	s_cmpk_gt_i32 s16, 0xbf
	v_lshlrev_b32_e32 v8, 2, v2
	.loc	1 143 29 is_stmt 1              ; rmsnorm.py:143:29
	v_ashrrev_i32_e32 v5, 31, v4
	s_cselect_b64 s[16:17], -1, 0
	v_cmp_eq_u32_e64 s[22:23], 0, v0
	v_and_b32_e32 v0, 0xc0, v0
	v_cndmask_b32_e64 v16, 0, 1, s[18:19]
	.loc	1 93 67                         ; rmsnorm.py:93:67
	v_or_b32_e32 v14, 0x100, v8
	v_mov_b32_e32 v15, v9
	.loc	1 109 26                        ; rmsnorm.py:109:26
	v_cmp_gt_i32_e64 s[0:1], s13, v4
	.loc	1 143 29                        ; rmsnorm.py:143:29
	v_lshl_add_u64 v[6:7], v[4:5], 2, s[6:7]
	v_lshl_add_u64 v[10:11], s[6:7], 0, v[8:9]
	v_cmp_eq_u32_e64 s[20:21], 0, v0
	.loc	1 93 67                         ; rmsnorm.py:93:67
	s_max_i32 s13, s25, 3
	v_lshl_add_u64 v[0:1], s[2:3], 0, v[14:15]
	v_lshl_add_u64 v[14:15], s[6:7], 0, v[14:15]
	v_cmp_ne_u32_e64 s[6:7], 1, v16
	v_cndmask_b32_e64 v16, 0, 1, s[16:17]
	s_and_b64 s[26:27], s[20:21], s[18:19]
	s_and_b64 s[28:29], s[20:21], s[0:1]
	s_add_i32 s13, s13, -2
	s_mul_i32 s30, s24, s10
	s_mul_i32 s33, s10, s15
	v_lshl_add_u64 v[12:13], s[4:5], 0, v[8:9]
	s_mul_i32 s34, s24, s11
	s_mul_i32 s42, s11, s15
	v_lshlrev_b32_e32 v8, 2, v2
	v_cmp_ne_u32_e64 s[16:17], 1, v16
	s_mov_b64 s[36:37], 0x100
	s_branch .LBB0_3
.LBB0_2:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 67 is_stmt 0                ; rmsnorm.py:0:67
	s_or_b64 exec, exec, s[40:41]
	.loc	1 93 67 is_stmt 1               ; rmsnorm.py:93:67
	s_add_i32 s24, s15, s24
	s_add_i32 s30, s30, s33
	s_add_i32 s34, s34, s42
	s_cmp_lt_i32 s24, s12
	s_cbranch_scc0 .LBB0_30
.LBB0_3:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_7 Depth 2
                                        ;     Child Loop BB0_17 Depth 2
	.loc	1 94 50                         ; rmsnorm.py:94:50
	s_mul_i32 s38, s24, s10
	.loc	1 94 40 is_stmt 0               ; rmsnorm.py:94:40
	s_ashr_i32 s39, s38, 31
	s_lshl_b64 s[38:39], s[38:39], 2
	s_add_u32 s38, s2, s38
	s_addc_u32 s39, s3, s39
	.loc	1 102 45 is_stmt 1              ; rmsnorm.py:102:45
	v_lshl_add_u64 v[20:21], s[38:39], 0, v[8:9]
	.loc	1 104 28                        ; rmsnorm.py:104:28
	s_and_b64 vcc, exec, s[6:7]
	v_mov_b32_e32 v23, 0
	s_cbranch_vccnz .LBB0_5
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v23, v[20:21], off
.LBB0_5:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 94 50                         ; rmsnorm.py:94:50
	s_ashr_i32 s31, s30, 31
	s_waitcnt vmcnt(0)
	v_lshl_add_u64 v[16:17], s[30:31], 2, v[0:1]
	.loc	1 100 52                        ; rmsnorm.py:100:52
	s_and_b64 vcc, exec, s[16:17]
	v_mov_b32_e32 v22, 0
	s_cbranch_vccnz .LBB0_8
; %bb.6:                                ; %.lr.ph.preheader
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	v_mov_b32_e32 v22, 0
	v_mov_b64_e32 v[18:19], v[16:17]
	s_mov_b32 s25, s13
.LBB0_7:                                ; %.lr.ph
                                        ;   Parent Loop BB0_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v24, v23
	.loc	1 104 28 is_stmt 1              ; rmsnorm.py:104:28
	global_load_dword v23, v[18:19], off
	.loc	1 105 42                        ; rmsnorm.py:105:42
	v_mul_f32_e32 v25, v24, v24
	.loc	1 100 52                        ; rmsnorm.py:100:52
	s_add_i32 s25, s25, -1
	s_cmp_lg_u32 s25, 0
.Ltmp4:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	v_mov_b32_dpp v25, v25 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:105:38 ]
	v_fmac_f32_e32 v25, v24, v24
.Ltmp5:
	.loc	1 100 52                        ; rmsnorm.py:100:52
	v_lshl_add_u64 v[18:19], v[18:19], 0, s[36:37]
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:105:38 ]
	s_nop 0
	v_add_f32_dpp v24, v25, v25 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	v_mov_b32_e32 v25, v24
	s_nop 1
	v_mov_b32_dpp v25, v25 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:105:38 ]
	v_add_f32_e32 v24, v24, v25
	s_nop 1
	v_add_f32_dpp v24, v24, v24 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	s_nop 0
	v_readlane_b32 s31, v24, 63
.Ltmp7:
	.loc	1 105 31                        ; rmsnorm.py:105:31
	s_nop 1
	v_add_f32_e32 v22, s31, v22
	.loc	1 100 52                        ; rmsnorm.py:100:52
	s_cbranch_scc1 .LBB0_7
.LBB0_8:                                ; %._crit_edge
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 105 42                        ; rmsnorm.py:105:42
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v18, v23, v23
.Ltmp8:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	s_nop 1
	v_mov_b32_dpp v18, v18 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:105:38 ]
	v_fmac_f32_e32 v18, v23, v23
	v_mov_b32_e32 v23, 0
	s_nop 0
	v_add_f32_dpp v18, v18, v18 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v18, v18, v18 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v18, v18, v18 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	v_mov_b32_e32 v19, v18
	s_nop 1
	v_mov_b32_dpp v19, v19 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:105:38 ]
	v_add_f32_e32 v18, v18, v19
	s_nop 1
	v_add_f32_dpp v18, v18, v18 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:105:38 ]
	s_nop 0
	v_readlane_b32 s25, v18, 63
.Ltmp9:
	.loc	1 110 41                        ; rmsnorm.py:110:41
	v_lshl_add_u64 v[18:19], v[4:5], 2, s[38:39]
	.loc	1 112 24                        ; rmsnorm.py:112:24
	s_and_saveexec_b64 s[38:39], s[0:1]
	s_cbranch_execz .LBB0_10
; %bb.9:                                ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v23, v[18:19], off nt
.LBB0_10:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[38:39]
	.loc	1 105 31 is_stmt 1              ; rmsnorm.py:105:31
	v_add_f32_e32 v24, s25, v22
	.loc	1 100 52                        ; rmsnorm.py:100:52
	v_cndmask_b32_e64 v22, v22, v24, s[18:19]
	.loc	1 115 38                        ; rmsnorm.py:115:38
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v24, v23, v23
.Ltmp10:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:115:34 ]
	s_nop 1
	v_mov_b32_dpp v24, v24 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:115:34 ]
	v_fmac_f32_e32 v24, v23, v23
	s_nop 1
	v_add_f32_dpp v23, v24, v24 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:115:34 ]
	v_mov_b32_e32 v24, v23
	s_nop 1
	v_mov_b32_dpp v24, v24 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:115:34 ]
	v_add_f32_e32 v23, v24, v23
	s_nop 1
	v_add_f32_dpp v23, v23, v23 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:115:34 ]
	s_nop 0
	v_readlane_b32 s25, v23, 63
.Ltmp11:
	.loc	1 115 27                        ; rmsnorm.py:115:27
	s_nop 1
	v_add_f32_e32 v22, s25, v22
	.loc	1 118 40                        ; rmsnorm.py:118:40
	v_div_scale_f32 v23, s[38:39], v3, v3, v22
	v_rcp_f32_e32 v24, v23
	s_nop 0
	v_fma_f32 v25, -v23, v24, 1.0
	v_fmac_f32_e32 v24, v25, v24
	v_div_scale_f32 v25, vcc, v22, v3, v22
	v_mul_f32_e32 v26, v25, v24
	v_fma_f32 v27, -v23, v26, v25
	v_fmac_f32_e32 v26, v27, v24
	v_fma_f32 v23, -v23, v26, v25
	v_div_fmas_f32 v23, v23, v24, v26
	v_div_fixup_f32 v22, v23, v3, v22
	.loc	1 119 49                        ; rmsnorm.py:119:49
	v_add_f32_e32 v22, s14, v22
	.loc	1 119 35 is_stmt 0              ; rmsnorm.py:119:35
	v_rsq_f32_e32 v26, v22
	.loc	1 122 43 is_stmt 1              ; rmsnorm.py:122:43
	s_and_saveexec_b64 s[38:39], s[22:23]
	s_cbranch_execz .LBB0_12
; %bb.11:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_ashr_i32 s25, s24, 31
	s_lshl_b64 s[40:41], s[24:25], 2
	s_add_u32 s40, s8, s40
	s_addc_u32 s41, s9, s41
	.loc	1 122 43                        ; rmsnorm.py:122:43
	global_store_dword v9, v26, s[40:41]
.LBB0_12:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 43                          ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[38:39]
	v_mov_b32_e32 v29, 0
	.loc	1 129 28 is_stmt 1              ; rmsnorm.py:129:28
	s_and_b64 vcc, exec, s[6:7]
	v_mov_b32_e32 v30, 0
	s_cbranch_vccz .LBB0_19
; %bb.13:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 131 28                        ; rmsnorm.py:131:28
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccz .LBB0_20
.LBB0_14:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 125 52                        ; rmsnorm.py:125:52
	s_and_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_21
.LBB0_15:                               ; %.lr.ph14.preheader
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 94 50                         ; rmsnorm.py:94:50
	s_ashr_i32 s35, s34, 31
	v_lshl_add_u64 v[22:23], s[34:35], 2, v[12:13]
	v_mov_b64_e32 v[24:25], v[14:15]
	v_mov_b32_e32 v20, v2
	s_mov_b32 s25, s13
	.loc	1 129 28                        ; rmsnorm.py:129:28
	global_load_dword v28, v[16:17], off
	.loc	1 131 28                        ; rmsnorm.py:131:28
	global_load_dword v27, v[24:25], off
	.loc	1 134 38                        ; rmsnorm.py:134:38
	s_and_saveexec_b64 s[38:39], s[20:21]
	s_cbranch_execz .LBB0_17
.LBB0_16:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38 is_stmt 0                ; rmsnorm.py:0:38
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v21, v26, v30
	v_mul_f32_e32 v21, v21, v29
	.loc	1 134 38                        ; rmsnorm.py:134:38
	global_store_dword v[22:23], v21, off
.LBB0_17:                               ;   Parent Loop BB0_3 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	.loc	1 0 38                          ; rmsnorm.py:0:38
	s_or_b64 exec, exec, s[38:39]
	.loc	1 125 52 is_stmt 1              ; rmsnorm.py:125:52
	s_add_i32 s25, s25, -1
	v_lshl_add_u64 v[22:23], v[22:23], 0, s[36:37]
	v_add_u32_e32 v20, 64, v20
	v_lshl_add_u64 v[24:25], v[24:25], 0, s[36:37]
	s_cmp_lg_u32 s25, 0
	v_lshl_add_u64 v[16:17], v[16:17], 0, s[36:37]
	s_cbranch_scc0 .LBB0_22
; %bb.18:                               ;   in Loop: Header=BB0_17 Depth=2
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v29, v27
	v_mov_b32_e32 v30, v28
	.loc	1 129 28 is_stmt 1              ; rmsnorm.py:129:28
	global_load_dword v28, v[16:17], off
	.loc	1 131 28                        ; rmsnorm.py:131:28
	global_load_dword v27, v[24:25], off
	.loc	1 134 38                        ; rmsnorm.py:134:38
	s_and_saveexec_b64 s[38:39], s[20:21]
	s_cbranch_execnz .LBB0_16
	s_branch .LBB0_17
.LBB0_19:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 129 28                        ; rmsnorm.py:129:28
	global_load_dword v30, v[20:21], off
	.loc	1 131 28                        ; rmsnorm.py:131:28
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB0_14
.LBB0_20:                               ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v29, v[10:11], off
	.loc	1 125 52                        ; rmsnorm.py:125:52
	s_and_b64 vcc, exec, s[16:17]
	s_cbranch_vccz .LBB0_15
.LBB0_21:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 52 is_stmt 0                ; rmsnorm.py:0:52
	v_mov_b32_e32 v20, v2
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v27, v29
	v_mov_b32_e32 v28, v30
.LBB0_22:                               ; %._crit_edge15
                                        ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 95 52 is_stmt 1               ; rmsnorm.py:95:52
	s_mul_i32 s38, s24, s11
	.loc	1 95 42 is_stmt 0               ; rmsnorm.py:95:42
	s_ashr_i32 s39, s38, 31
	s_lshl_b64 s[38:39], s[38:39], 2
	s_add_u32 s38, s4, s38
	s_addc_u32 s39, s5, s39
	.loc	1 134 38 is_stmt 1              ; rmsnorm.py:134:38
	s_and_saveexec_b64 s[40:41], s[26:27]
	s_cbranch_execz .LBB0_24
; %bb.23:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38 is_stmt 0                ; rmsnorm.py:0:38
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[16:17], v[20:21], 2, s[38:39]
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v20, v26, v28
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v20, v20, v27
	.loc	1 134 38                        ; rmsnorm.py:134:38
	global_store_dword v[16:17], v20, off
.LBB0_24:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 38                          ; rmsnorm.py:0:38
	s_or_b64 exec, exec, s[40:41]
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	.loc	1 140 24 is_stmt 1              ; rmsnorm.py:140:24
	s_and_saveexec_b64 s[40:41], s[0:1]
	s_cbranch_execnz .LBB0_27
; %bb.25:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[40:41]
	.loc	1 144 24 is_stmt 1              ; rmsnorm.py:144:24
	s_and_saveexec_b64 s[40:41], s[0:1]
	s_cbranch_execnz .LBB0_28
.LBB0_26:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[40:41]
	.loc	1 147 34 is_stmt 1              ; rmsnorm.py:147:34
	s_and_saveexec_b64 s[40:41], s[28:29]
	s_cbranch_execz .LBB0_2
	s_branch .LBB0_29
.LBB0_27:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 140 24                        ; rmsnorm.py:140:24
	global_load_dword v17, v[18:19], off nt
	s_or_b64 exec, exec, s[40:41]
	.loc	1 144 24                        ; rmsnorm.py:144:24
	s_and_saveexec_b64 s[40:41], s[0:1]
	s_cbranch_execz .LBB0_26
.LBB0_28:                               ;   in Loop: Header=BB0_3 Depth=1
	global_load_dword v16, v[6:7], off
	s_or_b64 exec, exec, s[40:41]
	.loc	1 147 34                        ; rmsnorm.py:147:34
	s_and_saveexec_b64 s[40:41], s[28:29]
	s_cbranch_execz .LBB0_2
.LBB0_29:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 34 is_stmt 0                ; rmsnorm.py:0:34
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v17, v26, v17
	v_lshl_add_u64 v[18:19], v[4:5], 2, s[38:39]
	v_mul_f32_e32 v16, v17, v16
	.loc	1 147 34                        ; rmsnorm.py:147:34
	global_store_dword v[18:19], v16, off
	s_branch .LBB0_2
.LBB0_30:                               ; %._crit_edge21
	.loc	1 91 4 is_stmt 1                ; rmsnorm.py:91:4
	s_endpgm
.Ltmp12:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
		.amdhsa_user_sgpr_count 15
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 13
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 31
		.amdhsa_next_free_sgpr 43
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
	.size	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1, .Lfunc_end0-_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
	.cfi_endproc
                                        ; -- End function
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.num_vgpr, 31
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.num_agpr, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.numbered_sgpr, 43
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.private_seg_size, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.uses_vcc, 1
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.uses_flat_scratch, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_dyn_sized_stack, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_recursion, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1592
; TotalNumSgprs: 49
; NumVgprs: 31
; NumAgprs: 0
; TotalNumVgprs: 31
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 6
; VGPRBlocks: 3
; NumSGPRsForWavesPerEU: 49
; NumVGPRsForWavesPerEU: 31
; AccumOffset: 32
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
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
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
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
	.byte	1                               ; Abbrev [1] 0xb:0x6c DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x46 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	98                              ; DW_AT_call_line
	.byte	42                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x55:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	105                             ; DW_AT_call_line
	.byte	38                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x61:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp10                         ; DW_AT_low_pc
	.long	.Ltmp11-.Ltmp10                 ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	115                             ; DW_AT_call_line
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
	.asciz	"_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1" ; string offset=77
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .max_flat_workgroup_size: 256
    .name:           _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1
    .private_segment_fixed_size: 0
    .sgpr_count:     49
    .sgpr_spill_count: 0
    .symbol:         _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_1.kd
    .uses_dynamic_stack: false
    .vgpr_count:     31
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
