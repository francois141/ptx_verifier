	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_softmax_kernel_online_BLOCK_SIZE_128 ; -- Begin function _softmax_kernel_online_BLOCK_SIZE_128
	.p2align	8
	.type	_softmax_kernel_online_BLOCK_SIZE_128,@function
_softmax_kernel_online_BLOCK_SIZE_128:  ; @_softmax_kernel_online_BLOCK_SIZE_128
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.25:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels" "softmax.py"
	.loc	1 15 0 prologue_end             ; softmax.py:15:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.26:
.LBB0_0:
.Ltmp1:
	.loc	1 31 33 is_stmt 1               ; softmax.py:31:33
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB0_24
; %bb.1:                                ; %.lr.ph
	.loc	1 30 42                         ; softmax.py:30:42
	s_mul_i32 s0, s6, s14
	.loc	1 30 32 is_stmt 0               ; softmax.py:30:32
	s_ashr_i32 s1, s0, 31
	v_and_b32_e32 v1, 0x1bf, v0
	s_lshl_b64 s[0:1], s[0:1], 2
	v_cmp_eq_u32_e32 vcc, 0, v1
	v_lshrrev_b32_e32 v1, 4, v0
	s_add_u32 s16, s4, s0
	v_and_b32_e32 v1, 4, v1
	s_addc_u32 s17, s5, s1
	.loc	1 32 39 is_stmt 1               ; softmax.py:32:39
	v_and_b32_e32 v4, 0x7f, v0
	s_mov_b32 s6, 0
	v_add_u32_e32 v1, 0, v1
	v_cmp_gt_u32_e64 s[0:1], 2, v0
	v_mov_b32_e32 v5, 0
	v_lshl_add_u32 v6, v0, 2, 0
	v_cmp_eq_u32_e64 s[4:5], 0, v0
	v_mov_b32_e32 v10, 0xff800000
	s_mov_b32 s9, 0xc2fc0000
	v_mov_b32_e32 v7, 0x42800000
	v_not_b32_e32 v8, 63
	v_mov_b32_e32 v9, 0
.LBB0_2:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 34 29                         ; softmax.py:34:29
	v_add_u32_e32 v2, s6, v4
	v_cmp_gt_i32_e64 s[10:11], s8, v2
	v_mov_b32_e32 v3, 0xff800000
	.loc	1 36 12                         ; softmax.py:36:12
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_cbranch_execz .LBB0_4
; %bb.3:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 12 is_stmt 0                ; softmax.py:0:12
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[16:17]
	.loc	1 36 12                         ; softmax.py:36:12
	global_load_dword v3, v[2:3], off nt
.LBB0_4:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 12                          ; softmax.py:0:12
	s_or_b64 exec, exec, s[12:13]
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 189 40 is_stmt 1              ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_waitcnt vmcnt(0)
	v_mov_b32_dpp v2, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v11, v3, v3
	v_max_f32_e32 v2, v11, v2
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_barrier
	s_nop 0
	v_mov_b32_dpp v11, v2 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_nop 1
	v_mov_b32_dpp v11, v2 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_nop 1
	v_mov_b32_dpp v11, v2 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	v_mov_b32_e32 v11, v2
	s_nop 1
	v_mov_b32_dpp v11, v11 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_nop 1
	v_mov_b32_dpp v11, v2 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ softmax.py:38:21 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_nop 0
	v_readlane_b32 s12, v2, 63
	s_and_saveexec_b64 s[10:11], vcc
; %bb.5:                                ;   in Loop: Header=BB0_2 Depth=1
	s_nop 0
	v_mov_b32_e32 v2, s12
	ds_write_b32 v1, v2
; %bb.6:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 40 is_stmt 0                ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	v_mov_b32_e32 v2, 0
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[10:11], s[0:1]
; %bb.7:                                ;   in Loop: Header=BB0_2 Depth=1
	ds_read_b32 v2, v6
; %bb.8:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v11, v2
	s_nop 1
	v_mov_b32_dpp v11, v11 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[10:11], s[4:5]
; %bb.9:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v2, v2, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	ds_write_b32 v6, v2
; %bb.10:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	.loc	2 189 40                        ; standard.py:189:40 @[ softmax.py:38:21 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v2, v5
.Ltmp3:
	.loc	1 39 28 is_stmt 1               ; softmax.py:39:28
	v_max_f32_e32 v11, v10, v10
.Ltmp4:
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
.Ltmp5:
	.loc	1 39 28                         ; softmax.py:39:28
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v2, v11, v2
	.loc	1 40 39                         ; softmax.py:40:39
	v_sub_f32_e32 v10, v10, v2
	.loc	1 40 35 is_stmt 0               ; softmax.py:40:35
	v_mul_f32_e32 v11, 0x3fb8aa3b, v10
	.loc	1 42 31 is_stmt 1               ; softmax.py:42:31
	v_sub_f32_e32 v3, v3, v2
	.loc	1 40 35                         ; softmax.py:40:35
	v_cmp_gt_f32_e64 s[10:11], s9, v11
	.loc	1 42 19                         ; softmax.py:42:19
	v_mul_f32_e32 v11, 0x3fb8aa3b, v3
	v_cmp_gt_f32_e64 s[12:13], s9, v11
	.loc	1 40 35                         ; softmax.py:40:35
	s_and_b64 s[18:19], s[10:11], exec
	s_cselect_b32 s15, 0xffffffc0, 0
	.loc	1 42 19                         ; softmax.py:42:19
	v_cndmask_b32_e64 v11, 0, v7, s[12:13]
	v_fmac_f32_e32 v11, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v11
	v_cndmask_b32_e64 v11, 0, v8, s[12:13]
	v_ldexp_f32 v3, v3, v11
.Ltmp6:
	.loc	2 261 15                        ; standard.py:261:15 @[ softmax.py:42:12 ]
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	v_mov_b32_e32 v11, v3
	s_nop 1
	v_mov_b32_dpp v11, v11 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ softmax.py:42:12 ]
	v_add_f32_e32 v3, v3, v11
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	s_nop 0
	v_readlane_b32 s18, v3, 63
	s_and_saveexec_b64 s[12:13], vcc
; %bb.11:                               ;   in Loop: Header=BB0_2 Depth=1
	s_nop 0
	v_mov_b32_e32 v3, s18
	ds_write_b32 v1, v3
; %bb.12:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[12:13]
	v_mov_b32_e32 v3, 0
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[12:13], s[0:1]
; %bb.13:                               ;   in Loop: Header=BB0_2 Depth=1
	ds_read_b32 v3, v6
; %bb.14:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[12:13]
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v11, v3
	s_nop 1
	v_mov_b32_dpp v11, v11 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[12:13], s[4:5]
; %bb.15:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v3, v3, v11
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	ds_write_b32 v6, v3
.Ltmp7:
; %bb.16:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[12:13]
	v_cndmask_b32_e64 v3, 0, v7, s[10:11]
	v_fmac_f32_e32 v3, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v3
.Ltmp8:
	.loc	2 291 36                        ; standard.py:291:36 @[ softmax.py:42:12 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v3, v5
.Ltmp9:
	.loc	1 0 0                           ; softmax.py:0
	v_ldexp_f32 v10, v10, s15
	.loc	1 31 33 is_stmt 1               ; softmax.py:31:33
	s_addk_i32 s6, 0x80
	s_cmp_lt_i32 s6, s8
	.loc	1 41 19                         ; softmax.py:41:19
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v3, v9, v10
	.loc	1 31 33                         ; softmax.py:31:33
	s_cbranch_scc0 .LBB0_18
; %bb.17:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 33 is_stmt 0                ; softmax.py:0:33
	v_mov_b32_e32 v9, v3
	v_mov_b32_e32 v10, v2
	.loc	1 31 33                         ; softmax.py:31:33
	s_branch .LBB0_2
.LBB0_18:                               ; %._crit_edge
	.loc	1 46 50 is_stmt 1               ; softmax.py:46:50
	s_mul_i32 s0, s7, s14
	.loc	1 46 40 is_stmt 0               ; softmax.py:46:40
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s2, s2, s0
	v_and_b32_e32 v0, 0x180, v0
	s_addc_u32 s3, s3, s1
	s_mov_b32 s6, 0
	v_cmp_eq_u32_e64 s[0:1], 0, v0
	s_mov_b32 s7, 0xc2fc0000
	v_mov_b32_e32 v5, 0x42800000
	v_not_b32_e32 v6, 63
	s_branch .LBB0_20
.LBB0_19:                               ;   in Loop: Header=BB0_20 Depth=1
	.loc	1 0 40                          ; softmax.py:0:40
	s_or_b64 exec, exec, s[4:5]
	.loc	1 48 33 is_stmt 1               ; softmax.py:48:33
	s_addk_i32 s6, 0x80
	s_cmp_lt_i32 s6, s8
	s_cbranch_scc0 .LBB0_24
.LBB0_20:                               ; =>This Inner Loop Header: Depth=1
	.loc	1 51 29                         ; softmax.py:51:29
	v_add_u32_e32 v0, s6, v4
	v_cmp_gt_i32_e32 vcc, s8, v0
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, 0xff800000
	.loc	1 53 12                         ; softmax.py:53:12
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execnz .LBB0_22
; %bb.21:                               ;   in Loop: Header=BB0_20 Depth=1
	.loc	1 0 12 is_stmt 0                ; softmax.py:0:12
	s_or_b64 exec, exec, s[4:5]
	.loc	1 59 30 is_stmt 1               ; softmax.py:59:30
	s_and_b64 s[10:11], s[0:1], vcc
	s_and_saveexec_b64 s[4:5], s[10:11]
	s_cbranch_execz .LBB0_19
	s_branch .LBB0_23
.LBB0_22:                               ;   in Loop: Header=BB0_20 Depth=1
	.loc	1 0 30 is_stmt 0                ; softmax.py:0:30
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[8:9], v[0:1], 2, s[16:17]
	.loc	1 53 12 is_stmt 1               ; softmax.py:53:12
	global_load_dword v1, v[8:9], off nt
	s_or_b64 exec, exec, s[4:5]
	.loc	1 59 30                         ; softmax.py:59:30
	s_and_b64 s[10:11], s[0:1], vcc
	s_and_saveexec_b64 s[4:5], s[10:11]
	s_cbranch_execz .LBB0_19
.LBB0_23:                               ;   in Loop: Header=BB0_20 Depth=1
	.loc	1 56 44                         ; softmax.py:56:44
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v1, v1, v2
	.loc	1 56 32 is_stmt 0               ; softmax.py:56:32
	v_mul_f32_e32 v7, 0x3fb8aa3b, v1
	v_cmp_gt_f32_e32 vcc, s7, v7
	s_nop 1
	v_cndmask_b32_e32 v7, 0, v5, vcc
	v_fmac_f32_e32 v7, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v7
	v_cndmask_b32_e32 v7, 0, v6, vcc
	v_ldexp_f32 v1, v1, v7
	.loc	1 56 49                         ; softmax.py:56:49
	v_div_scale_f32 v7, s[10:11], v3, v3, v1
	v_rcp_f32_e32 v8, v7
	v_div_scale_f32 v9, vcc, v1, v3, v1
	v_fma_f32 v10, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v10, v8
	v_mul_f32_e32 v10, v9, v8
	v_fma_f32 v11, -v7, v10, v9
	v_fmac_f32_e32 v10, v11, v8
	v_fma_f32 v7, -v7, v10, v9
	v_div_fmas_f32 v7, v7, v8, v10
	v_div_fixup_f32 v7, v7, v3, v1
	.loc	1 58 45 is_stmt 1               ; softmax.py:58:45
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[2:3]
	.loc	1 59 30                         ; softmax.py:59:30
	global_store_dword v[0:1], v7, off
	s_branch .LBB0_19
.LBB0_24:                               ; %._crit_edge7
	.loc	1 48 4                          ; softmax.py:48:4
	s_endpgm
.Ltmp10:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _softmax_kernel_online_BLOCK_SIZE_128
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 48
		.amdhsa_user_sgpr_count 14
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 12
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 12
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
	.size	_softmax_kernel_online_BLOCK_SIZE_128, .Lfunc_end0-_softmax_kernel_online_BLOCK_SIZE_128
	.cfi_endproc
                                        ; -- End function
	.set _softmax_kernel_online_BLOCK_SIZE_128.num_vgpr, 12
	.set _softmax_kernel_online_BLOCK_SIZE_128.num_agpr, 0
	.set _softmax_kernel_online_BLOCK_SIZE_128.numbered_sgpr, 20
	.set _softmax_kernel_online_BLOCK_SIZE_128.private_seg_size, 0
	.set _softmax_kernel_online_BLOCK_SIZE_128.uses_vcc, 1
	.set _softmax_kernel_online_BLOCK_SIZE_128.uses_flat_scratch, 0
	.set _softmax_kernel_online_BLOCK_SIZE_128.has_dyn_sized_stack, 0
	.set _softmax_kernel_online_BLOCK_SIZE_128.has_recursion, 0
	.set _softmax_kernel_online_BLOCK_SIZE_128.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1376
; TotalNumSgprs: 26
; NumVgprs: 12
; NumAgprs: 0
; TotalNumVgprs: 12
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 3
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 26
; NumVGPRsForWavesPerEU: 12
; AccumOffset: 12
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 14
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 2
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
	.byte	1                               ; Abbrev [1] 0xb:0x58 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x32 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	38                              ; DW_AT_call_line
	.byte	21                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x55:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	42                              ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
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
	.asciz	"softmax.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels" ; string offset=18
.Linfo_string3:
	.asciz	"_softmax_kernel_online_BLOCK_SIZE_128" ; string offset=63
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
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 48
    .max_flat_workgroup_size: 512
    .name:           _softmax_kernel_online_BLOCK_SIZE_128
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         _softmax_kernel_online_BLOCK_SIZE_128.kd
    .uses_dynamic_stack: false
    .vgpr_count:     12
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
