; FlyDSL 304d441202a3 kernels/norm/rmsnorm_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case rmsnorm_block4_tail_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	rmsnorm_large_m_small_n_kernel_0
	.p2align	8
	.type	rmsnorm_large_m_small_n_kernel_0,@function
rmsnorm_large_m_small_n_kernel_0:
	s_load_dword s3, s[0:1], 0x50
	v_lshrrev_b32_e32 v1, 5, v0
	v_lshl_or_b32 v10, s2, 5, v1
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e32 vcc, s3, v10
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_7
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s2, s[0:1], 0x10
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, -1
	v_and_b32_e32 v12, 31, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	v_mul_lo_u32 v9, v10, s2
	v_lshlrev_b32_e32 v1, 1, v9
	buffer_load_dwordx4 v[2:5], v1, s[8:11], 0 offen
	v_cmp_eq_u32_e64 s[4:5], 0, v12
	v_cmp_gt_u32_e64 s[2:3], 6, v12
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	v_and_b32_e32 v1, 0xffff0000, v3
	v_lshlrev_b32_e32 v0, 16, v3
	v_and_b32_e32 v3, 0xffff0000, v2
	v_lshlrev_b32_e32 v2, 16, v2
	v_pk_mul_f32 v[14:15], v[4:5], v[4:5]
	v_pk_mul_f32 v[16:17], v[2:3], v[2:3]
	v_pk_mul_f32 v[18:19], v[6:7], v[6:7]
	v_pk_mul_f32 v[20:21], v[0:1], v[0:1]
	v_pk_add_f32 v[14:15], v[16:17], v[14:15]
	v_pk_add_f32 v[18:19], v[20:21], v[18:19]
	s_nop 0
	v_pk_add_f32 v[14:15], v[14:15], v[18:19]
	s_nop 0
	v_add_f32_e32 v8, v14, v15
	v_cndmask_b32_e64 v8, 0, v8, s[4:5]
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_3
	v_add_lshl_u32 v11, v9, v12, 1
	buffer_load_ushort v11, v11, s[8:11], 0 offen offset:16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v11, 16, v11
	v_mul_f32_e32 v11, v11, v11
	v_add_f32_e32 v8, v8, v11
.LBB0_3:
	s_or_b64 exec, exec, s[6:7]
	s_nop 0
	v_add_f32_dpp v8, v8, v8 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mov_b32 s14, 0x41600000
	s_nop 0
	v_add_f32_dpp v8, v8, v8 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v8, v8, v8 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v8, v8, v8 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v11, v8
	s_nop 1
	v_permlane16_swap_b32_e32 v8, v11
	v_add_f32_e32 v8, v8, v11
	v_div_scale_f32 v11, s[6:7], s14, s14, v8
	v_rcp_f32_e32 v13, v11
	s_load_dwordx2 s[16:17], s[0:1], 0x18
	s_load_dwordx2 s[12:13], s[0:1], 0x38
	s_load_dwordx2 s[6:7], s[0:1], 0x48
	v_fma_f32 v14, -v11, v13, 1.0
	v_fmac_f32_e32 v13, v14, v13
	v_div_scale_f32 v14, vcc, v8, s14, v8
	v_mul_f32_e32 v15, v14, v13
	v_fma_f32 v16, -v11, v15, v14
	v_fmac_f32_e32 v15, v16, v13
	v_fma_f32 v11, -v11, v15, v14
	v_div_fmas_f32 v11, v11, v13, v15
	v_div_fixup_f32 v8, v11, s14, v8
	v_add_f32_e32 v8, 0x3727c5ac, v8
	v_rsq_f32_e32 v8, v8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s17, s17, 0xffff
	s_and_b32 s13, s13, 0xffff
	v_mad_u64_u32 v[10:11], s[0:1], s6, v10, 0
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_5
	s_mov_b32 s18, s10
	s_mov_b32 s19, s11
	buffer_load_dwordx4 v[14:17], off, s[16:19], 0
	v_pk_mul_f32 v[6:7], v[8:9], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[8:9], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[8:9], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[8:9], v[2:3] op_sel_hi:[0,1]
	v_lshlrev_b32_e32 v11, 1, v10
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v19, 0xffff0000, v17
	v_lshlrev_b32_e32 v18, 16, v17
	v_and_b32_e32 v17, 0xffff0000, v16
	v_lshlrev_b32_e32 v16, 16, v16
	v_and_b32_e32 v21, 0xffff0000, v15
	v_lshlrev_b32_e32 v20, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v14
	v_lshlrev_b32_e32 v14, 16, v14
	v_pk_mul_f32 v[14:15], v[2:3], v[14:15]
	v_pk_mul_f32 v[0:1], v[0:1], v[20:21]
	v_pk_mul_f32 v[4:5], v[4:5], v[16:17]
	v_pk_mul_f32 v[2:3], v[6:7], v[18:19]
	v_cvt_pk_bf16_f32 v1, v0, v1
	v_cvt_pk_bf16_f32 v3, v2, v3
	v_cvt_pk_bf16_f32 v2, v4, v5
	v_cvt_pk_bf16_f32 v0, v14, v15
	buffer_store_dwordx4 v[0:3], v11, s[12:15], 0 offen
.LBB0_5:
	s_or_b64 exec, exec, s[0:1]
	s_and_b64 exec, exec, s[2:3]
	s_cbranch_execz .LBB0_7
	v_or_b32_e32 v0, 8, v12
	v_add_lshl_u32 v1, v9, v0, 1
	buffer_load_ushort v1, v1, s[8:11], 0 offen
	v_lshlrev_b32_e32 v2, 1, v0
	s_mov_b32 s18, s10
	s_mov_b32 s19, s11
	buffer_load_ushort v2, v2, s[16:19], 0 offen
	s_mov_b32 s14, s10
	v_add_lshl_u32 v0, v0, v10, 1
	s_mov_b32 s15, s11
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v1, 16, v1
	v_mul_f32_e32 v1, v8, v1
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v2, 16, v2
	v_mul_f32_e32 v1, v1, v2
	v_cvt_pk_bf16_f32 v1, v1, s0
	buffer_store_short v1, v0, s[12:15], 0 offen
.LBB0_7:
	s_endpgm
.Lfunc_end0:
	.size	rmsnorm_large_m_small_n_kernel_0, .Lfunc_end0-rmsnorm_large_m_small_n_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_large_m_small_n_kernel_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 84
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 0
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 22
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 24
		.amdhsa_reserve_vcc 1
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

	.set .Lrmsnorm_large_m_small_n_kernel_0.num_vgpr, 22
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_agpr, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.numbered_sgpr, 20
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_named_barrier, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.private_seg_size, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_vcc, 1
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_flat_scratch, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_dyn_sized_stack, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_recursion, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_indirect_call, 0
	.globl	rmsnorm_kernel_1
	.p2align	8
	.type	rmsnorm_kernel_1,@function
rmsnorm_kernel_1:
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, -1
	v_cmp_gt_u32_e64 s[6:7], 2, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	s_mul_i32 s3, s2, s3
	s_lshl_b32 s4, s3, 1
	v_mov_b32_e32 v1, s4
	buffer_load_dwordx4 v[12:15], v1, s[8:11], 0 offen
	v_or_b32_e32 v1, 8, v0
	v_add_lshl_u32 v3, s3, v1, 1
	buffer_load_ushort v2, v3, s[8:11], 0 offen
	v_cmp_eq_u32_e64 s[4:5], 0, v0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_and_b32_e32 v7, 0xffff0000, v14
	v_lshlrev_b32_e32 v6, 16, v14
	v_and_b32_e32 v5, 0xffff0000, v13
	v_lshlrev_b32_e32 v4, 16, v13
	v_and_b32_e32 v9, 0xffff0000, v12
	v_lshlrev_b32_e32 v8, 16, v12
	v_pk_mul_f32 v[12:13], v[6:7], v[6:7]
	v_pk_mul_f32 v[14:15], v[8:9], v[8:9]
	v_pk_mul_f32 v[16:17], v[10:11], v[10:11]
	v_pk_mul_f32 v[18:19], v[4:5], v[4:5]
	v_pk_add_f32 v[12:13], v[14:15], v[12:13]
	v_pk_add_f32 v[16:17], v[18:19], v[16:17]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v2, 16, v2
	v_pk_add_f32 v[12:13], v[12:13], v[16:17]
	v_mul_f32_e32 v2, v2, v2
	v_add_f32_e32 v12, v12, v13
	v_cndmask_b32_e64 v12, 0, v12, s[4:5]
	v_add_f32_e32 v2, v2, v12
	s_and_saveexec_b64 s[12:13], s[6:7]
	s_cbranch_execz .LBB1_2
	s_add_i32 s14, s3, 12
	v_add_lshl_u32 v12, s14, v0, 1
	buffer_load_ushort v12, v12, s[8:11], 0 offen
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v12, 16, v12
	v_mul_f32_e32 v12, v12, v12
	v_add_f32_e32 v2, v2, v12
.LBB1_2:
	s_or_b64 exec, exec, s[12:13]
	s_nop 0
	v_add_f32_dpp v2, v2, v2 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mov_b32 s14, 0x41600000
	s_nop 0
	v_add_f32_dpp v2, v2, v2 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_div_scale_f32 v12, s[12:13], s14, s14, v2
	v_rcp_f32_e32 v13, v12
	s_load_dwordx2 s[16:17], s[0:1], 0x18
	s_load_dwordx2 s[12:13], s[0:1], 0x38
	s_load_dword s15, s[0:1], 0x48
	v_fma_f32 v14, -v12, v13, 1.0
	v_fmac_f32_e32 v13, v14, v13
	v_div_scale_f32 v14, vcc, v2, s14, v2
	v_mul_f32_e32 v15, v14, v13
	v_fma_f32 v16, -v12, v15, v14
	v_fmac_f32_e32 v15, v16, v13
	v_fma_f32 v12, -v12, v15, v14
	v_div_fmas_f32 v12, v12, v13, v15
	v_div_fixup_f32 v2, v12, s14, v2
	v_add_f32_e32 v2, 0x3727c5ac, v2
	v_rsq_f32_e32 v2, v2
	s_waitcnt lgkmcnt(0)
	s_and_b32 s13, s13, 0xffff
	s_and_b32 s17, s17, 0xffff
	s_mul_i32 s2, s2, s15
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB1_4
	s_mov_b32 s18, s10
	s_mov_b32 s19, s11
	buffer_load_dwordx4 v[12:15], off, s[16:19], 0
	v_pk_mul_f32 v[10:11], v[2:3], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[2:3], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[2:3], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[2:3], v[8:9] op_sel_hi:[0,1]
	s_lshl_b32 s4, s2, 1
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v17, 0xffff0000, v15
	v_lshlrev_b32_e32 v16, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v14
	v_lshlrev_b32_e32 v14, 16, v14
	v_and_b32_e32 v19, 0xffff0000, v13
	v_lshlrev_b32_e32 v18, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v12
	v_lshlrev_b32_e32 v12, 16, v12
	v_pk_mul_f32 v[8:9], v[8:9], v[12:13]
	v_pk_mul_f32 v[4:5], v[4:5], v[18:19]
	v_pk_mul_f32 v[12:13], v[6:7], v[14:15]
	v_pk_mul_f32 v[6:7], v[10:11], v[16:17]
	v_cvt_pk_bf16_f32 v5, v4, v5
	v_cvt_pk_bf16_f32 v7, v6, v7
	v_cvt_pk_bf16_f32 v6, v12, v13
	v_cvt_pk_bf16_f32 v4, v8, v9
	v_mov_b32_e32 v8, s4
	buffer_store_dwordx4 v[4:7], v8, s[12:15], 0 offen
.LBB1_4:
	s_or_b64 exec, exec, s[0:1]
	buffer_load_ushort v3, v3, s[8:11], 0 offen
	v_lshlrev_b32_e32 v4, 1, v1
	s_mov_b32 s18, s10
	s_mov_b32 s19, s11
	buffer_load_ushort v4, v4, s[16:19], 0 offen
	v_add_lshl_u32 v1, s2, v1, 1
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v3, 16, v3
	v_mul_f32_e32 v3, v2, v3
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v4, 16, v4
	v_mul_f32_e32 v3, v3, v4
	v_cvt_pk_bf16_f32 v3, v3, s0
	buffer_store_short v3, v1, s[12:15], 0 offen
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB1_6
	v_or_b32_e32 v0, 12, v0
	v_add_lshl_u32 v1, s3, v0, 1
	buffer_load_ushort v1, v1, s[8:11], 0 offen
	v_lshlrev_b32_e32 v3, 1, v0
	buffer_load_ushort v3, v3, s[16:19], 0 offen
	v_add_lshl_u32 v0, s2, v0, 1
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v1, 16, v1
	v_mul_f32_e32 v1, v2, v1
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v3, 16, v3
	v_mul_f32_e32 v1, v1, v3
	v_cvt_pk_bf16_f32 v1, v1, s0
	buffer_store_short v1, v0, s[12:15], 0 offen
.LBB1_6:
	s_endpgm
.Lfunc_end1:
	.size	rmsnorm_kernel_1, .Lfunc_end1-rmsnorm_kernel_1
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_kernel_1
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 80
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 0
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 20
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 20
		.amdhsa_reserve_vcc 1
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

	.set .Lrmsnorm_kernel_1.num_vgpr, 20
	.set .Lrmsnorm_kernel_1.num_agpr, 0
	.set .Lrmsnorm_kernel_1.numbered_sgpr, 20
	.set .Lrmsnorm_kernel_1.num_named_barrier, 0
	.set .Lrmsnorm_kernel_1.private_seg_size, 0
	.set .Lrmsnorm_kernel_1.uses_vcc, 1
	.set .Lrmsnorm_kernel_1.uses_flat_scratch, 0
	.set .Lrmsnorm_kernel_1.has_dyn_sized_stack, 0
	.set .Lrmsnorm_kernel_1.has_recursion, 0
	.set .Lrmsnorm_kernel_1.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
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
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 84
    .max_flat_workgroup_size: 1024
    .name:           rmsnorm_large_m_small_n_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 1024
      - 1
      - 1
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_large_m_small_n_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     22
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 80
    .max_flat_workgroup_size: 4
    .name:           rmsnorm_kernel_1
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 4
      - 1
      - 1
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_kernel_1.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     20
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
