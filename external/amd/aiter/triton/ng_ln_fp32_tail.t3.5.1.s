	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_layernorm_kernel_BLOCK_SIZE_64 ; -- Begin function _layernorm_kernel_BLOCK_SIZE_64
	.p2align	8
	.type	_layernorm_kernel_BLOCK_SIZE_64,@function
_layernorm_kernel_BLOCK_SIZE_64:        ; @_layernorm_kernel_BLOCK_SIZE_64
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.24:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/normalization" "norm.py"
	.loc	1 39 0 prologue_end             ; norm.py:39:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.25:
.LBB0_0:
	s_load_dword s24, s[0:1], 0x3c
.Ltmp1:
	.loc	1 74 33 is_stmt 1               ; norm.py:74:33
	s_mul_i32 s18, s14, s16
	.loc	1 74 27 is_stmt 0               ; norm.py:74:27
	s_ashr_i32 s19, s18, 31
	v_mov_b32_e32 v9, 0
	v_and_b32_e32 v10, 63, v0
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 41 22 is_stmt 1               ; standard.py:41:22 @[ norm.py:77:31 ]
	s_waitcnt lgkmcnt(0)
	s_add_i32 s17, s24, 63
	.loc	2 41 28 is_stmt 0               ; standard.py:41:28 @[ norm.py:77:31 ]
	s_ashr_i32 s14, s17, 31
	s_lshr_b32 s14, s14, 26
	s_add_i32 s14, s17, s14
	s_ashr_i32 s14, s14, 6
.Ltmp3:
	.loc	1 77 45 is_stmt 1               ; norm.py:77:45
	s_add_i32 s14, s14, -1
	.loc	1 83 19                         ; norm.py:83:19
	s_cmpk_gt_i32 s17, 0x7f
	s_cselect_b64 s[22:23], -1, 0
	s_cmpk_lt_i32 s17, 0x80
	s_cbranch_scc1 .LBB0_3
; %bb.1:                                ; %.lr.ph.preheader
	s_max_i32 s17, s14, 1
	s_lshl_b64 s[20:21], s[18:19], 2
	s_add_u32 s20, s2, s20
	v_lshlrev_b32_e32 v8, 2, v10
	v_mov_b32_e32 v9, 0
	s_addc_u32 s21, s3, s21
	v_lshl_add_u64 v[2:3], s[20:21], 0, v[8:9]
	s_mov_b64 s[20:21], 0x100
.LBB0_2:                                ; %.lr.ph
                                        ; =>This Inner Loop Header: Depth=1
	.loc	1 85 26                         ; norm.py:85:26
	global_load_dword v1, v[2:3], off
	.loc	1 83 19                         ; norm.py:83:19
	s_add_i32 s17, s17, -1
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[20:21]
	s_cmp_lg_u32 s17, 0
	.loc	1 86 17                         ; norm.py:86:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v9, v9, v1
	.loc	1 83 19                         ; norm.py:83:19
	s_cbranch_scc1 .LBB0_2
.LBB0_3:                                ; %Flow28
	.loc	1 0 19 is_stmt 0                ; norm.py:0:19
	s_load_dword s17, s[0:1], 0x40
	.loc	1 74 27 is_stmt 1               ; norm.py:74:27
	s_lshl_b64 s[20:21], s[18:19], 2
	s_add_u32 s18, s2, s20
	.loc	1 89 44                         ; norm.py:89:44
	v_lshl_or_b32 v2, s14, 6, v10
	.loc	1 74 27                         ; norm.py:74:27
	s_addc_u32 s19, s3, s21
	.loc	1 91 22                         ; norm.py:91:22
	v_ashrrev_i32_e32 v3, 31, v2
	.loc	1 91 54 is_stmt 0               ; norm.py:91:54
	v_cmp_gt_i32_e64 s[0:1], s24, v2
	.loc	1 91 22                         ; norm.py:91:22
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[18:19]
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v12, 0
	.loc	1 91 8                          ; norm.py:91:8
	s_and_saveexec_b64 s[18:19], s[0:1]
	s_cbranch_execz .LBB0_5
; %bb.4:
	global_load_dword v12, v[4:5], off
.LBB0_5:
	.loc	1 0 8                           ; norm.py:0:8
	s_or_b64 exec, exec, s[18:19]
	.loc	1 93 13 is_stmt 1               ; norm.py:93:13
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, v9, v12
	.loc	1 94 35                         ; norm.py:94:35
	v_cvt_f32_i32_e32 v11, s24
.Ltmp4:
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:94:18 ]
	s_nop 0
	v_add_f32_dpp v1, v1, v1 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:94:18 ]
	v_mov_b32_e32 v6, v1
	s_nop 1
	v_mov_b32_dpp v6, v6 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:94:18 ]
	v_add_f32_e32 v1, v6, v1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:94:18 ]
	s_nop 0
	v_readlane_b32 s24, v1, 63
.Ltmp5:
	.loc	1 94 35                         ; norm.py:94:35
	s_nop 1
	v_div_scale_f32 v1, s[18:19], v11, v11, s24
	v_rcp_f32_e32 v6, v1
	s_nop 0
	v_fma_f32 v8, -v1, v6, 1.0
	v_fmac_f32_e32 v6, v8, v6
	v_div_scale_f32 v8, vcc, s24, v11, s24
	v_mul_f32_e32 v9, v8, v6
	v_fma_f32 v13, -v1, v9, v8
	v_fmac_f32_e32 v9, v13, v6
	v_fma_f32 v1, -v1, v9, v8
	v_div_fmas_f32 v1, v1, v6, v9
	.loc	1 99 19                         ; norm.py:99:19
	v_cndmask_b32_e64 v6, 0, 1, s[22:23]
	v_cmp_ne_u32_e64 s[18:19], 1, v6
	s_andn2_b64 vcc, exec, s[22:23]
	.loc	1 94 35                         ; norm.py:94:35
	v_div_fixup_f32 v1, v1, v11, s24
	.loc	1 99 19                         ; norm.py:99:19
	s_cbranch_vccnz .LBB0_8
; %bb.6:                                ; %.lr.ph6.preheader
	s_max_i32 s24, s14, 1
	s_add_u32 s22, s2, s20
	v_lshlrev_b32_e32 v6, 2, v10
	v_mov_b32_e32 v7, 0
	s_addc_u32 s23, s3, s21
	v_lshl_add_u64 v[8:9], s[22:23], 0, v[6:7]
	s_mov_b64 s[22:23], 0x100
.LBB0_7:                                ; %.lr.ph6
                                        ; =>This Inner Loop Header: Depth=1
	.loc	1 101 26                        ; norm.py:101:26
	global_load_dword v6, v[8:9], off
	.loc	1 99 19                         ; norm.py:99:19
	s_add_i32 s24, s24, -1
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[22:23]
	s_cmp_lg_u32 s24, 0
	.loc	1 102 28                        ; norm.py:102:28
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v6, v6, v1
	.loc	1 103 16                        ; norm.py:103:16
	v_fmac_f32_e32 v7, v6, v6
	.loc	1 99 19                         ; norm.py:99:19
	s_cbranch_scc1 .LBB0_7
.LBB0_8:                                ; %._crit_edge7
	.loc	1 110 55                        ; norm.py:110:55
	v_sub_f32_e32 v6, v12, v1
	.loc	1 110 61 is_stmt 0              ; norm.py:110:61
	v_cndmask_b32_e64 v6, 0, v6, s[0:1]
	.loc	1 111 12 is_stmt 1              ; norm.py:111:12
	v_fmac_f32_e32 v7, v6, v6
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:113:17 ]
	s_nop 1
	v_add_f32_dpp v6, v7, v7 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:113:17 ]
	v_mov_b32_e32 v7, v6
	s_nop 1
	v_mov_b32_dpp v7, v7 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:113:17 ]
	v_add_f32_e32 v6, v6, v7
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:113:17 ]
	s_nop 0
	v_readlane_b32 s24, v6, 63
.Ltmp7:
	.loc	1 113 33                        ; norm.py:113:33
	s_nop 1
	v_div_scale_f32 v6, s[22:23], v11, v11, s24
	v_rcp_f32_e32 v7, v6
	v_div_scale_f32 v8, vcc, s24, v11, s24
	v_fma_f32 v9, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v9, v7
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v12, -v6, v9, v8
	v_fmac_f32_e32 v9, v12, v7
	v_fma_f32 v6, -v6, v9, v8
	v_div_fmas_f32 v6, v6, v7, v9
	v_div_fixup_f32 v6, v6, v11, s24
	.loc	1 114 26                        ; norm.py:114:26
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, s17, v6
	.loc	1 114 20 is_stmt 0              ; norm.py:114:20
	v_rsq_f32_e32 v14, v6
	.loc	1 117 29 is_stmt 1              ; norm.py:117:29
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[22:23], vcc
	s_cbranch_execz .LBB0_10
; %bb.9:
	.loc	1 0 29 is_stmt 0                ; norm.py:0:29
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[24:25], s[16:17], 2
	s_add_u32 s12, s12, s24
	s_addc_u32 s13, s13, s25
	s_add_u32 s10, s10, s24
	v_mov_b32_e32 v6, 0
	s_addc_u32 s11, s11, s25
	.loc	1 117 29                        ; norm.py:117:29
	global_store_dword v6, v1, s[10:11]
	.loc	1 118 29 is_stmt 1              ; norm.py:118:29
	global_store_dword v6, v14, s[12:13]
.LBB0_10:                               ; %.critedge
	.loc	1 0 29 is_stmt 0                ; norm.py:0:29
	s_or_b64 exec, exec, s[22:23]
	.loc	1 75 33 is_stmt 1               ; norm.py:75:33
	s_mul_i32 s10, s15, s16
	.loc	1 122 19                        ; norm.py:122:19
	s_and_b64 vcc, exec, s[18:19]
	.loc	1 75 27                         ; norm.py:75:27
	s_ashr_i32 s11, s10, 31
	.loc	1 122 19                        ; norm.py:122:19
	s_cbranch_vccnz .LBB0_15
; %bb.11:                               ; %.lr.ph9
	s_max_i32 s14, s14, 1
	s_lshl_b64 s[12:13], s[10:11], 2
	s_add_u32 s12, s4, s12
	s_addc_u32 s13, s5, s13
	s_add_u32 s2, s2, s20
	v_and_b32_e32 v6, 0xc0, v0
	v_lshlrev_b32_e32 v12, 2, v10
	v_mov_b32_e32 v13, 0
	s_addc_u32 s3, s3, s21
	v_cmp_eq_u32_e32 vcc, 0, v6
	v_lshl_add_u64 v[6:7], s[12:13], 0, v[12:13]
	v_lshl_add_u64 v[8:9], s[8:9], 0, v[12:13]
	v_lshl_add_u64 v[10:11], s[6:7], 0, v[12:13]
	v_lshl_add_u64 v[12:13], s[2:3], 0, v[12:13]
	s_mov_b64 s[2:3], 0x100
	s_branch .LBB0_13
.LBB0_12:                               ;   in Loop: Header=BB0_13 Depth=1
	.loc	1 0 19 is_stmt 0                ; norm.py:0:19
	s_or_b64 exec, exec, s[12:13]
	.loc	1 122 19 is_stmt 1              ; norm.py:122:19
	s_add_i32 s14, s14, -1
	v_lshl_add_u64 v[6:7], v[6:7], 0, s[2:3]
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[2:3]
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[2:3]
	s_cmp_lg_u32 s14, 0
	v_lshl_add_u64 v[12:13], v[12:13], 0, s[2:3]
	s_cbranch_scc0 .LBB0_15
.LBB0_13:                               ; =>This Inner Loop Header: Depth=1
	.loc	1 129 44                        ; norm.py:129:44
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB0_12
; %bb.14:                               ;   in Loop: Header=BB0_13 Depth=1
	.loc	1 126 26                        ; norm.py:126:26
	global_load_dword v15, v[12:13], off
	.loc	1 124 26                        ; norm.py:124:26
	global_load_dword v16, v[10:11], off
	.loc	1 125 26                        ; norm.py:125:26
	global_load_dword v17, v[8:9], off
	.loc	1 127 29                        ; norm.py:127:29
	s_waitcnt vmcnt(2)
	v_sub_f32_e32 v15, v15, v1
	.loc	1 127 37 is_stmt 0              ; norm.py:127:37
	v_mul_f32_e32 v15, v14, v15
	.loc	1 128 38 is_stmt 1              ; norm.py:128:38
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v17, v16, v15
	.loc	1 129 44                        ; norm.py:129:44
	global_store_dword v[6:7], v17, off
	s_branch .LBB0_12
.LBB0_15:                               ; %._crit_edge10
	.loc	1 0 44 is_stmt 0                ; norm.py:0:44
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	.loc	1 134 22 is_stmt 1              ; norm.py:134:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_22
; %bb.16:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	.loc	1 135 22 is_stmt 1              ; norm.py:135:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_23
.LBB0_17:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v8, 0
	.loc	1 136 22 is_stmt 1              ; norm.py:136:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_19
.LBB0_18:
	global_load_dword v8, v[4:5], off
.LBB0_19:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	.loc	1 139 40 is_stmt 1              ; norm.py:139:40
	v_and_b32_e32 v0, 0xc0, v0
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_21
; %bb.20:
	.loc	1 75 27                         ; norm.py:75:27
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s0, s4, s0
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v0, v8, v1
	s_addc_u32 s1, s5, s1
	v_mul_f32_e32 v0, v14, v0
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[0:1]
	v_fmac_f32_e32 v6, v7, v0
	.loc	1 139 40                        ; norm.py:139:40
	global_store_dword v[2:3], v6, off
.LBB0_21:
	.loc	1 139 4 is_stmt 0               ; norm.py:139:4
	s_endpgm
.LBB0_22:
	.loc	1 0 4                           ; norm.py:0:4
	v_lshl_add_u64 v[8:9], v[2:3], 2, s[6:7]
	.loc	1 134 22 is_stmt 1              ; norm.py:134:22
	global_load_dword v7, v[8:9], off
	s_or_b64 exec, exec, s[2:3]
	.loc	1 135 22                        ; norm.py:135:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_17
.LBB0_23:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	v_lshl_add_u64 v[8:9], v[2:3], 2, s[8:9]
	.loc	1 135 22                        ; norm.py:135:22
	global_load_dword v6, v[8:9], off
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v8, 0
	.loc	1 136 22 is_stmt 1              ; norm.py:136:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_18
	s_branch .LBB0_19
.Ltmp8:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _layernorm_kernel_BLOCK_SIZE_64
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 88
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
		.amdhsa_next_free_sgpr 26
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
	.size	_layernorm_kernel_BLOCK_SIZE_64, .Lfunc_end0-_layernorm_kernel_BLOCK_SIZE_64
	.cfi_endproc
                                        ; -- End function
	.set _layernorm_kernel_BLOCK_SIZE_64.num_vgpr, 18
	.set _layernorm_kernel_BLOCK_SIZE_64.num_agpr, 0
	.set _layernorm_kernel_BLOCK_SIZE_64.numbered_sgpr, 26
	.set _layernorm_kernel_BLOCK_SIZE_64.private_seg_size, 0
	.set _layernorm_kernel_BLOCK_SIZE_64.uses_vcc, 1
	.set _layernorm_kernel_BLOCK_SIZE_64.uses_flat_scratch, 0
	.set _layernorm_kernel_BLOCK_SIZE_64.has_dyn_sized_stack, 0
	.set _layernorm_kernel_BLOCK_SIZE_64.has_recursion, 0
	.set _layernorm_kernel_BLOCK_SIZE_64.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1424
; TotalNumSgprs: 32
; NumVgprs: 18
; NumAgprs: 0
; TotalNumVgprs: 18
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 3
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 32
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x74 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x4e DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	77                              ; DW_AT_call_line
	.byte	31                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x55:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp4                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	94                              ; DW_AT_call_line
	.byte	18                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x69:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp6                          ; DW_AT_low_pc
	.long	.Ltmp7-.Ltmp6                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	113                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"norm.py"                       ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=15
.Linfo_string3:
	.asciz	"_layernorm_kernel_BLOCK_SIZE_64" ; string offset=74
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 88
    .max_flat_workgroup_size: 256
    .name:           _layernorm_kernel_BLOCK_SIZE_64
    .private_segment_fixed_size: 0
    .sgpr_count:     32
    .sgpr_spill_count: 0
    .symbol:         _layernorm_kernel_BLOCK_SIZE_64.kd
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
