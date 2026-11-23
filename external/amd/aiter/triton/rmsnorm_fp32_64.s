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
; %bb.12:
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
; %bb.13:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[24:25], s[2:3]
.Ltmp1:
	.loc	1 169 13 is_stmt 1              ; rmsnorm.py:169:13
	v_readfirstlane_b32 s2, v0
	s_lshr_b32 s33, s2, 6
	.loc	1 89 19                         ; rmsnorm.py:89:19
	v_and_b32_e32 v0, 63, v0
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_cmp_lt_i32 s15, s12
	.loc	1 150 16                        ; rmsnorm.py:150:16
	v_cmp_gt_i32_e64 s[16:17], s13, v0
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 vcc, s[2:3], s[16:17]
	.loc	1 152 38                        ; rmsnorm.py:152:38
	s_mul_i32 s2, s10, s15
	s_mov_b64 s[20:21], s[6:7]
	.loc	1 157 17                        ; rmsnorm.py:157:17
	s_mov_b32 s27, 0x27000
	s_mov_b32 s26, 0x7ffffffe
	v_lshlrev_b32_e32 v6, 2, v0
	v_bfrev_b32_e32 v2, 1
	.loc	1 154 19                        ; rmsnorm.py:154:19
	v_add_lshl_u32 v3, s2, v0, 2
	.loc	1 157 17                        ; rmsnorm.py:157:17
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
	v_cndmask_b32_e32 v1, v2, v6, vcc
	.loc	1 154 19                        ; rmsnorm.py:154:19
	s_and_b32 s25, s25, 0xffff
	v_cndmask_b32_e32 v2, v2, v3, vcc
	.loc	1 157 17                        ; rmsnorm.py:157:17
	buffer_load_dword v1, v1, s[20:23], 0 offen
	.loc	1 88 22                         ; rmsnorm.py:88:22
	s_load_dword s34, s[0:1], 0x48
	.loc	1 154 19                        ; rmsnorm.py:154:19
	buffer_load_dword v2, v2, s[24:27], 0 offen sc0 nt
	v_or_b32_e32 v3, s33, v0
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s35, s12, s34
	s_cmp_lt_i32 s15, s35
	s_cbranch_scc1 .LBB0_2
; %bb.1:                                ; %.._crit_edge_crit_edge
	.loc	1 0 9 is_stmt 0                 ; rmsnorm.py:0:9
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[0:1], -1
.LBB0_3:                                ; %Flow6
	v_cvt_f32_i32_e32 v4, s13
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_cbranch_scc1 .LBB0_9
; %bb.4:                                ; %.lr.ph
	s_and_b32 s29, s5, 0xffff
	s_cmp_eq_u32 s33, 0
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[6:7], s[16:17], s[0:1]
	.loc	1 151 9 is_stmt 1               ; rmsnorm.py:151:9
	s_mul_i32 s0, s15, s11
	v_add_lshl_u32 v7, s0, v0, 2
	s_mul_i32 s0, s34, s11
	s_lshl_b32 s13, s0, 2
	s_add_i32 s0, s15, s34
	s_mul_i32 s0, s10, s0
	v_bfrev_b32_e32 v5, 1
	v_add_lshl_u32 v8, s0, v0, 2
	s_mul_i32 s0, s34, s10
	v_cndmask_b32_e64 v6, v5, v6, s[16:17]
	v_cmp_eq_u32_e64 s[2:3], 0, v3
	s_mov_b32 s31, 0x27000
	s_mov_b32 s30, 0x7ffffffe
	s_lshl_b32 s10, s0, 2
	v_mov_b32_e32 v9, 0
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
	s_mov_b32 s0, s15
	s_branch .LBB0_6
	.loc	1 0 9 is_stmt 0                 ; :0:9
.Ltmp2:
	.p2align	5
.LBB0_5:                                ;   in Loop: Header=BB0_6 Depth=1
	s_or_b64 exec, exec, s[18:19]
	.loc	1 165 24 is_stmt 1              ; rmsnorm.py:165:24
	v_mul_f32_e32 v2, v2, v10
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_add_i32 s0, s0, s34
	.loc	1 165 24                        ; rmsnorm.py:165:24
	v_mul_f32_e32 v1, v1, v2
	.loc	1 169 13                        ; rmsnorm.py:169:13
	v_cndmask_b32_e64 v2, v5, v7, s[6:7]
	s_mov_b32 s28, s4
	buffer_store_dword v1, v2, s[28:31], 0 offen
	.loc	1 151 9                         ; rmsnorm.py:151:9
	v_add_u32_e32 v7, s13, v7
	v_add_u32_e32 v8, s10, v8
	s_cmp_lt_i32 s0, s35
	s_waitcnt vmcnt(1)
	v_mov_b32_e32 v1, v12
	v_mov_b32_e32 v2, v11
	s_cbranch_scc0 .LBB0_8
.LBB0_6:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 154 19                        ; rmsnorm.py:154:19
	v_cndmask_b32_e64 v10, v5, v8, s[16:17]
	buffer_load_dword v11, v10, s[24:27], 0 offen sc0 nt
	.loc	1 157 17                        ; rmsnorm.py:157:17
	buffer_load_dword v12, v6, s[20:23], 0 offen
	.loc	1 158 24                        ; rmsnorm.py:158:24
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v10, v2, v2
.Ltmp3:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	s_nop 1
	v_mov_b32_dpp v10, v10 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp4:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_fmac_f32_e32 v10, v2, v2
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp5:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	v_mov_b32_e32 v13, v10
	s_nop 1
	v_mov_b32_dpp v13, v13 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp6:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_e32 v10, v10, v13
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp7:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	s_nop 0
	v_readlane_b32 s1, v10, 63
.Ltmp8:
	.loc	1 160 42                        ; rmsnorm.py:160:42
	s_nop 1
	v_div_scale_f32 v10, s[18:19], v4, v4, s1
	v_rcp_f32_e32 v13, v10
	s_nop 0
	v_fma_f32 v14, -v10, v13, 1.0
	v_fmac_f32_e32 v13, v14, v13
	v_div_scale_f32 v14, vcc, s1, v4, s1
	v_mul_f32_e32 v15, v14, v13
	v_fma_f32 v16, -v10, v15, v14
	v_fmac_f32_e32 v15, v16, v13
	v_fma_f32 v10, -v10, v15, v14
	v_div_fmas_f32 v10, v10, v13, v15
	v_div_fixup_f32 v10, v10, v4, s1
	.loc	1 160 41 is_stmt 0              ; rmsnorm.py:160:41
	v_add_f32_e32 v10, s14, v10
	.loc	1 160 27                        ; rmsnorm.py:160:27
	v_rsq_f32_e32 v10, v10
	.loc	1 163 13 is_stmt 1              ; rmsnorm.py:163:13
	s_and_saveexec_b64 s[18:19], s[2:3]
	s_cbranch_execz .LBB0_5
; %bb.7:                                ;   in Loop: Header=BB0_6 Depth=1
	.loc	1 0 13 is_stmt 0                ; rmsnorm.py:0:13
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[36:37], s[0:1], 2
	s_add_u32 s36, s8, s36
	s_addc_u32 s37, s9, s37
	.loc	1 163 13                        ; rmsnorm.py:163:13
	global_store_dword v9, v10, s[36:37]
	s_branch .LBB0_5
.LBB0_8:                                ; %Flow
	.loc	1 0 13                          ; rmsnorm.py:0:13
	v_mov_b32_e32 v1, v12
	v_mov_b32_e32 v2, v11
.LBB0_9:                                ; %._crit_edge
	.loc	1 151 9 is_stmt 1               ; rmsnorm.py:151:9
	s_cmp_gt_i32 s34, -1
	s_cselect_b32 s0, -1, 1
	s_abs_i32 s1, s34
	v_cvt_f32_u32_e32 v5, s1
	s_add_i32 s2, s34, s12
	s_add_i32 s2, s2, s0
	s_sub_i32 s0, 0, s1
	v_rcp_f32_e32 v5, v5
	s_sub_i32 s2, s2, s15
	s_xor_b32 s3, s2, s34
	s_abs_i32 s2, s2
	v_mul_f32_e32 v5, 0x4f7ffffe, v5
	v_cvt_u32_f32_e32 v5, v5
	s_ashr_i32 s3, s3, 31
	v_readfirstlane_b32 s6, v5
	s_mul_i32 s0, s0, s6
	s_mul_hi_u32 s0, s6, s0
	s_add_i32 s6, s6, s0
	s_mul_hi_u32 s0, s2, s6
	s_mul_i32 s6, s0, s1
	.loc	1 158 24                        ; rmsnorm.py:158:24
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v2, v2
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_sub_i32 s2, s2, s6
	s_add_i32 s7, s0, 1
.Ltmp9:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	v_mov_b32_dpp v5, v5 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp10:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_sub_i32 s6, s2, s1
.Ltmp11:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_fmac_f32_e32 v5, v2, v2
.Ltmp12:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s0, s7, s0
.Ltmp13:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_dpp v5, v5, v5 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp14:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_cselect_b32 s2, s6, s2
	s_add_i32 s6, s0, 1
.Ltmp15:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_dpp v5, v5, v5 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp16:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s0, s6, s0
.Ltmp17:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_dpp v5, v5, v5 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp18:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	v_mov_b32_e32 v6, v5
.Ltmp19:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_xor_b32 s0, s0, s3
	s_sub_i32 s2, s0, s3
.Ltmp20:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	v_mov_b32_dpp v6, v6 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp21:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_e32 v5, v5, v6
.Ltmp22:
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_add_i32 s0, s2, -1
	s_max_i32 s3, s0, 0
.Ltmp23:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ rmsnorm.py:159:24 ] ]
	v_add_f32_dpp v5, v5, v5 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp24:
	.loc	2 314 12                        ; standard.py:314:12 @[ rmsnorm.py:159:24 ]
	s_nop 0
	v_readlane_b32 s6, v5, 63
.Ltmp25:
	.loc	1 160 42                        ; rmsnorm.py:160:42
	s_nop 1
	v_div_scale_f32 v5, s[0:1], v4, v4, s6
	v_rcp_f32_e32 v6, v5
	.loc	1 151 9                         ; rmsnorm.py:151:9
	s_mul_i32 s0, s3, s34
	s_add_i32 s0, s0, s15
	s_cmp_gt_i32 s2, 0
	.loc	1 160 42                        ; rmsnorm.py:160:42
	v_fma_f32 v7, -v5, v6, 1.0
	v_fmac_f32_e32 v6, v7, v6
	v_div_scale_f32 v7, vcc, s6, v4, s6
	v_mul_f32_e32 v8, v7, v6
	v_fma_f32 v9, -v5, v8, v7
	v_fmac_f32_e32 v8, v9, v6
	v_fma_f32 v5, -v5, v8, v7
	v_div_fmas_f32 v5, v5, v6, v8
	v_div_fixup_f32 v4, v5, v4, s6
	.loc	1 160 41 is_stmt 0              ; rmsnorm.py:160:41
	v_add_f32_e32 v4, s14, v4
	.loc	1 160 27                        ; rmsnorm.py:160:27
	v_rsq_f32_e32 v4, v4
	.loc	1 151 9 is_stmt 1               ; rmsnorm.py:151:9
	s_cselect_b64 s[2:3], -1, 0
	.loc	1 163 13                        ; rmsnorm.py:163:13
	v_cmp_eq_u32_e32 vcc, 0, v3
	s_and_b64 s[12:13], vcc, s[2:3]
	s_and_saveexec_b64 s[6:7], s[12:13]
	s_cbranch_execz .LBB0_11
; %bb.10:
	.loc	1 0 13 is_stmt 0                ; rmsnorm.py:0:13
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[12:13], s[0:1], 2
	s_add_u32 s8, s8, s12
	s_addc_u32 s9, s9, s13
	v_mov_b32_e32 v3, 0
	.loc	1 163 13                        ; rmsnorm.py:163:13
	global_store_dword v3, v4, s[8:9]
.LBB0_11:
	.loc	1 0 13                          ; rmsnorm.py:0:13
	s_or_b64 exec, exec, s[6:7]
	.loc	1 169 13 is_stmt 1              ; rmsnorm.py:169:13
	s_and_b32 s5, s5, 0xffff
	s_cmp_eq_u32 s33, 0
	.loc	1 167 40                        ; rmsnorm.py:167:40
	s_mul_i32 s8, s0, s11
	.loc	1 169 13                        ; rmsnorm.py:169:13
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 165 24                        ; rmsnorm.py:165:24
	v_mul_f32_e32 v2, v2, v4
	.loc	1 169 13                        ; rmsnorm.py:169:13
	s_and_b64 s[0:1], s[16:17], s[0:1]
	.loc	1 165 24                        ; rmsnorm.py:165:24
	v_mul_f32_e32 v1, v1, v2
	.loc	1 169 13                        ; rmsnorm.py:169:13
	v_add_lshl_u32 v0, s8, v0, 2
	v_bfrev_b32_e32 v2, 1
	s_and_b64 vcc, s[0:1], s[2:3]
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	v_cndmask_b32_e32 v0, v2, v0, vcc
	buffer_store_dword v1, v0, s[4:7], 0 offen
	.loc	1 55 1                          ; rmsnorm.py:55:1
	s_endpgm
.Ltmp26:
.Lfunc_end0:
	.size	_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0, .Lfunc_end0-_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
	.cfi_endproc
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
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 38
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
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_vgpr, 17
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_agpr, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.numbered_sgpr, 38
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.num_named_barrier, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.private_seg_size, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_vcc, 1
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.uses_flat_scratch, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_dyn_sized_stack, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_recursion, 0
	.set .L_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1344
; TotalNumSgprs: 44
; NumVgprs: 17
; NumAgprs: 0
; TotalNumVgprs: 17
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 5
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 44
; NumVGPRsForWavesPerEU: 17
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
	.byte	159                             ; DW_AT_call_line
	.byte	24                              ; DW_AT_call_column
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
	.quad	.Ltmp3-.Lfunc_begin0
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
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
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
	.asciz	"rmsnorm.py"                    ; string offset=7 ; rmsnorm.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=18 ; /work/aiter/aiter/ops/triton/_triton_kernels/normalization
.Linfo_string3:
	.asciz	"_rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0" ; string offset=77 ; _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0
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
    .sgpr_count:     44
    .sgpr_spill_count: 0
    .symbol:         _rms_norm_kernel_BLOCK_SIZE_64_USE_BLOCKED_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     17
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
