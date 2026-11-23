	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0 ; -- Begin function _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
	.p2align	8
	.type	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0,@function
_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0: ; @_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.21:
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
; %bb.22:
.LBB0_0:
.Ltmp1:
	.loc	1 88 37 is_stmt 1               ; rmsnorm.py:88:37
	s_load_dword s20, s[0:1], 0x58
	.loc	1 89 31                         ; rmsnorm.py:89:31
	v_and_b32_e32 v1, 63, v0
	.loc	1 157 32                        ; rmsnorm.py:157:32
	v_mov_b32_e32 v3, 0
	v_lshlrev_b32_e32 v2, 2, v1
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cmp_gt_i32 s12, s15
	.loc	1 150 29                        ; rmsnorm.py:150:29
	v_cmp_gt_i32_e64 s[16:17], s13, v1
	.loc	1 157 32                        ; rmsnorm.py:157:32
	v_lshl_add_u64 v[4:5], s[6:7], 0, v[2:3]
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[6:7], s[6:7], s[16:17]
	v_mov_b32_e32 v13, 0
	.loc	1 157 24                        ; rmsnorm.py:157:24
	s_and_saveexec_b64 s[18:19], s[6:7]
	s_cbranch_execz .LBB0_2
; %bb.1:
	global_load_dword v13, v[4:5], off
.LBB0_2:
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[18:19]
	s_load_dword s18, s[0:1], 0x48
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s19, s20, 16
	.loc	1 154 26 is_stmt 1              ; rmsnorm.py:154:26
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_mul_i32 s6, s10, s15
	s_ashr_i32 s7, s6, 31
	s_lshl_b64 s[6:7], s[6:7], 2
	s_add_u32 s6, s2, s6
	s_addc_u32 s7, s3, s7
	.loc	1 154 26                        ; rmsnorm.py:154:26
	global_load_dword v3, v2, s[6:7] nt
.LBB0_4:
	.loc	1 0 26                          ; rmsnorm.py:0:26
	s_or_b64 exec, exec, s[0:1]
	.loc	1 88 37 is_stmt 1               ; rmsnorm.py:88:37
	s_and_b32 s0, 0xffff, s19
	s_cmp_lg_u32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 160 52                        ; rmsnorm.py:160:52
	v_cvt_f32_i32_e32 v1, s13
	.loc	1 88 37                         ; rmsnorm.py:88:37
	s_cmp_lg_u64 s[0:1], 0
	s_addc_u32 s13, s18, 0
	v_cndmask_b32_e64 v6, 0, 1, s[0:1]
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_sub_i32 s24, s12, s13
	.loc	1 88 37                         ; rmsnorm.py:88:37
	v_readfirstlane_b32 s19, v6
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cmp_ge_i32 s15, s24
	v_cmp_eq_u32_e64 s[6:7], 0, v0
	s_cbranch_scc1 .LBB0_15
; %bb.5:                                ; %.lr.ph
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v6, v2
	v_lshl_add_u64 v[8:9], s[2:3], 0, v[6:7]
	v_lshl_add_u64 v[10:11], s[4:5], 0, v[6:7]
	v_and_b32_e32 v6, 0xc0, v0
	s_add_i32 s3, s15, s18
	v_cmp_eq_u32_e32 vcc, 0, v6
	s_add_i32 s3, s3, s19
	s_and_b64 s[0:1], vcc, s[16:17]
	s_mul_i32 s2, s15, s11
	s_mul_i32 s25, s11, s13
	s_mul_i32 s18, s10, s3
	s_mul_i32 s10, s10, s13
	s_mov_b32 s20, s15
	v_mov_b32_e32 v6, 0
	.loc	1 154 26                        ; rmsnorm.py:154:26
	s_and_saveexec_b64 s[22:23], s[16:17]
	s_cbranch_execz .LBB0_7
.LBB0_6:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_ashr_i32 s19, s18, 31
	v_lshl_add_u64 v[14:15], s[18:19], 2, v[8:9]
	.loc	1 154 26                        ; rmsnorm.py:154:26
	global_load_dword v6, v[14:15], off nt
.LBB0_7:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 0 26                          ; rmsnorm.py:0:26
	s_or_b64 exec, exec, s[22:23]
	v_mov_b32_e32 v12, 0
	.loc	1 157 24 is_stmt 1              ; rmsnorm.py:157:24
	s_and_saveexec_b64 s[22:23], s[16:17]
	s_cbranch_execz .LBB0_9
; %bb.8:                                ;   in Loop: Header=BB0_7 Depth=1
	global_load_dword v12, v[4:5], off
.LBB0_9:                                ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 0 24 is_stmt 0                ; rmsnorm.py:0:24
	s_or_b64 exec, exec, s[22:23]
	.loc	1 158 29 is_stmt 1              ; rmsnorm.py:158:29
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v14, v3, v3
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	s_nop 1
	v_mov_b32_dpp v14, v14 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_fmac_f32_e32 v14, v3, v3
	s_nop 1
	v_add_f32_dpp v14, v14, v14 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v14, v14, v14 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v14, v14, v14 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	v_mov_b32_e32 v15, v14
	s_nop 1
	v_mov_b32_dpp v15, v15 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_add_f32_dpp v14, v14, v14 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	s_nop 0
	v_readlane_b32 s3, v14, 63
.Ltmp3:
	.loc	1 160 52                        ; rmsnorm.py:160:52
	s_nop 1
	v_div_scale_f32 v14, s[22:23], v1, v1, s3
	v_rcp_f32_e32 v15, v14
	v_div_scale_f32 v16, vcc, s3, v1, s3
	v_fma_f32 v17, -v14, v15, 1.0
	v_fmac_f32_e32 v15, v17, v15
	v_mul_f32_e32 v17, v16, v15
	v_fma_f32 v18, -v14, v17, v16
	v_fmac_f32_e32 v17, v18, v15
	v_fma_f32 v14, -v14, v17, v16
	v_div_fmas_f32 v14, v14, v15, v17
	v_div_fixup_f32 v14, v14, v1, s3
	.loc	1 160 62 is_stmt 0              ; rmsnorm.py:160:62
	v_add_f32_e32 v14, s14, v14
	.loc	1 160 40                        ; rmsnorm.py:160:40
	v_rsq_f32_e32 v14, v14
	.loc	1 163 43 is_stmt 1              ; rmsnorm.py:163:43
	s_and_saveexec_b64 s[22:23], s[6:7]
	s_cbranch_execz .LBB0_11
; %bb.10:                               ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_ashr_i32 s21, s20, 31
	s_lshl_b64 s[26:27], s[20:21], 2
	s_add_u32 s26, s8, s26
	s_addc_u32 s27, s9, s27
	.loc	1 163 43                        ; rmsnorm.py:163:43
	global_store_dword v7, v14, s[26:27]
.LBB0_11:                               ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 0 43                          ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[22:23]
	.loc	1 169 34 is_stmt 1              ; rmsnorm.py:169:34
	s_and_saveexec_b64 s[22:23], s[0:1]
	s_cbranch_execz .LBB0_13
; %bb.12:                               ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 165 29                        ; rmsnorm.py:165:29
	v_mul_f32_e32 v3, v3, v14
	.loc	1 167 39                        ; rmsnorm.py:167:39
	s_ashr_i32 s3, s2, 31
	.loc	1 165 43                        ; rmsnorm.py:165:43
	v_mul_f32_e32 v3, v13, v3
	.loc	1 167 69                        ; rmsnorm.py:167:69
	v_lshl_add_u64 v[14:15], s[2:3], 2, v[10:11]
	.loc	1 169 34                        ; rmsnorm.py:169:34
	global_store_dword v[14:15], v3, off
.LBB0_13:                               ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 0 34 is_stmt 0                ; rmsnorm.py:0:34
	s_or_b64 exec, exec, s[22:23]
	.loc	1 151 67 is_stmt 1              ; rmsnorm.py:151:67
	s_add_i32 s20, s20, s13
	s_add_i32 s2, s2, s25
	s_add_i32 s18, s18, s10
	s_cmp_lt_i32 s20, s24
	s_cbranch_scc0 .LBB0_16
; %bb.14:                               ;   in Loop: Header=BB0_7 Depth=1
	.loc	1 0 67 is_stmt 0                ; rmsnorm.py:0:67
	v_mov_b32_e32 v13, v12
	v_mov_b32_e32 v3, v6
	v_mov_b32_e32 v6, 0
	.loc	1 154 26 is_stmt 1              ; rmsnorm.py:154:26
	s_and_saveexec_b64 s[22:23], s[16:17]
	s_cbranch_execnz .LBB0_6
	s_branch .LBB0_7
.LBB0_15:
	.loc	1 0 26 is_stmt 0                ; rmsnorm.py:0:26
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v12, v13
	v_mov_b32_e32 v6, v3
.LBB0_16:                               ; %._crit_edge
	.loc	1 151 67 is_stmt 1              ; rmsnorm.py:151:67
	s_cmp_gt_i32 s13, -1
	s_cselect_b32 s0, -1, 1
	s_abs_i32 s1, s13
	v_cvt_f32_u32_e32 v3, s1
	s_sub_i32 s2, s12, s15
	s_sub_i32 s3, 0, s1
	s_add_i32 s2, s2, s13
	v_rcp_iflag_f32_e32 v3, v3
	s_add_i32 s2, s2, s0
	s_xor_b32 s0, s2, s13
	s_abs_i32 s2, s2
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	s_ashr_i32 s0, s0, 31
	v_readfirstlane_b32 s6, v3
	s_mul_i32 s3, s3, s6
	s_mul_hi_u32 s3, s6, s3
	s_add_i32 s6, s6, s3
	s_mul_hi_u32 s3, s2, s6
	s_mul_i32 s6, s3, s1
	.loc	1 158 29                        ; rmsnorm.py:158:29
	v_mul_f32_e32 v3, v6, v6
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_sub_i32 s2, s2, s6
	s_add_i32 s7, s3, 1
.Ltmp4:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	v_mov_b32_dpp v3, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp5:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_sub_i32 s6, s2, s1
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_fmac_f32_e32 v3, v6, v6
.Ltmp7:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s3, s7, s3
.Ltmp8:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_dpp v3, v3, v3 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp9:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cselect_b32 s2, s6, s2
	s_add_i32 s6, s3, 1
.Ltmp10:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_dpp v3, v3, v3 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp11:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s1, s6, s3
.Ltmp12:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_dpp v3, v3, v3 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	v_mov_b32_e32 v4, v3
.Ltmp13:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_xor_b32 s1, s1, s0
	s_sub_i32 s2, s1, s0
.Ltmp14:
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	v_mov_b32_dpp v4, v4 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_e32 v3, v3, v4
.Ltmp15:
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_add_i32 s0, s2, -1
	s_max_i32 s3, s0, 0
.Ltmp16:
	.loc	2 261 15                        ; standard.py:261:15 @[ rmsnorm.py:159:30 ]
	v_add_f32_dpp v3, v3, v3 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ rmsnorm.py:159:30 ]
	s_nop 0
	v_readlane_b32 s6, v3, 63
.Ltmp17:
	.loc	1 160 52                        ; rmsnorm.py:160:52
	s_nop 1
	v_div_scale_f32 v3, s[0:1], v1, v1, s6
	v_rcp_f32_e32 v4, v3
	.loc	1 151 67                        ; rmsnorm.py:151:67
	s_mul_i32 s0, s3, s13
	s_add_i32 s0, s0, s15
	s_cmp_gt_i32 s2, 0
	.loc	1 160 52                        ; rmsnorm.py:160:52
	v_fma_f32 v5, -v3, v4, 1.0
	v_fmac_f32_e32 v4, v5, v4
	v_div_scale_f32 v5, vcc, s6, v1, s6
	v_mul_f32_e32 v7, v5, v4
	v_fma_f32 v8, -v3, v7, v5
	v_fmac_f32_e32 v7, v8, v4
	v_fma_f32 v3, -v3, v7, v5
	v_div_fmas_f32 v3, v3, v4, v7
	v_div_fixup_f32 v1, v3, v1, s6
	.loc	1 160 62 is_stmt 0              ; rmsnorm.py:160:62
	v_add_f32_e32 v1, s14, v1
	.loc	1 160 40                        ; rmsnorm.py:160:40
	v_rsq_f32_e32 v1, v1
	.loc	1 151 67 is_stmt 1              ; rmsnorm.py:151:67
	s_cselect_b64 s[2:3], -1, 0
	.loc	1 163 43                        ; rmsnorm.py:163:43
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_b64 s[12:13], vcc, s[2:3]
	s_and_saveexec_b64 s[6:7], s[12:13]
	s_cbranch_execz .LBB0_18
; %bb.17:
	.loc	1 0 43 is_stmt 0                ; rmsnorm.py:0:43
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[12:13], s[0:1], 2
	s_add_u32 s8, s8, s12
	s_addc_u32 s9, s9, s13
	v_mov_b32_e32 v3, 0
	.loc	1 163 43                        ; rmsnorm.py:163:43
	global_store_dword v3, v1, s[8:9]
.LBB0_18:
	.loc	1 0 43                          ; rmsnorm.py:0:43
	s_or_b64 exec, exec, s[6:7]
	.loc	1 169 34 is_stmt 1              ; rmsnorm.py:169:34
	v_and_b32_e32 v0, 0xc0, v0
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_b64 s[6:7], vcc, s[16:17]
	s_and_b64 s[2:3], s[6:7], s[2:3]
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_20
; %bb.19:
	.loc	1 167 49                        ; rmsnorm.py:167:49
	s_mul_i32 s0, s0, s11
	.loc	1 167 39 is_stmt 0              ; rmsnorm.py:167:39
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	.loc	1 165 29 is_stmt 1              ; rmsnorm.py:165:29
	v_mul_f32_e32 v0, v6, v1
	.loc	1 167 39                        ; rmsnorm.py:167:39
	s_add_u32 s0, s4, s0
	.loc	1 165 43                        ; rmsnorm.py:165:43
	v_mul_f32_e32 v0, v12, v0
	.loc	1 167 39                        ; rmsnorm.py:167:39
	s_addc_u32 s1, s5, s1
	.loc	1 169 34                        ; rmsnorm.py:169:34
	global_store_dword v2, v0, s[0:1]
.LBB0_20:
	.loc	1 91 4                          ; rmsnorm.py:91:4
	s_endpgm
.Ltmp18:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
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
		.amdhsa_next_free_vgpr 19
		.amdhsa_next_free_sgpr 28
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
.Lfunc_end0:
	.size	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0, .Lfunc_end0-_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
	.cfi_endproc
                                        ; -- End function
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_vgpr, 19
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_agpr, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.numbered_sgpr, 28
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.private_seg_size, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_vcc, 1
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_flat_scratch, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_dyn_sized_stack, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_recursion, 0
	.set _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1320
; TotalNumSgprs: 34
; NumVgprs: 19
; NumAgprs: 0
; TotalNumVgprs: 19
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 34
; NumVGPRsForWavesPerEU: 19
; AccumOffset: 20
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
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
	.byte	1                               ; Abbrev [1] 0xb:0x44 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x1e DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	159                             ; DW_AT_call_line
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
	.asciz	"_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0" ; string offset=77
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
    .name:           _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.kd
    .uses_dynamic_stack: false
    .vgpr_count:     19
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
