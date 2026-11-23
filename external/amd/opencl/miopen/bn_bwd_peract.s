; MIOpen rocm-7.2.4 src/kernels/MIOpenBatchNormBwdPerAct.cl (MIOpenBatchNormBwdPerActivationSaved), src/solver/batchnorm/backward_per_activation.cpp:BnBwdTrainingPerActivation::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case bn_bwd_peract).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenBatchNormBwdPerActivationSaved
	.globl	MIOpenBatchNormBwdPerActivationSaved
	.p2align	8
	.type	MIOpenBatchNormBwdPerActivationSaved,@function
MIOpenBatchNormBwdPerActivationSaved:
	s_load_dword s30, s[0:1], 0x5c
	s_load_dwordx4 s[12:15], s[0:1], 0x10
	s_load_dwordx4 s[24:27], s[0:1], 0x78
	s_add_u32 s28, s0, 0x50
	s_addc_u32 s29, s1, 0
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s15, s30, 16
	s_mul_i32 s3, s3, s15
	v_bfe_u32 v1, v0, 10, 10
	s_add_i32 s3, s26, s3
	v_add_u32_e32 v8, s3, v1
	v_cmp_gt_u32_e32 vcc, s14, v8
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_9
	s_load_dwordx4 s[16:19], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x20
	s_load_dwordx4 s[20:23], s[0:1], 0x40
	s_and_b32 s0, s30, 0xffff
	s_mul_i32 s2, s2, s0
	s_load_dword s0, s[28:29], 0x4
	s_load_dword s1, s[28:29], 0x14
	v_cvt_f32_u32_e32 v9, s12
	s_add_i32 s2, s24, s2
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v0, s2, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s15, s0, s15
	s_and_b32 s0, s1, 0xffff
	s_add_i32 s15, s15, s0
	v_mul_lo_u32 v10, v0, s14
	v_frexp_mant_f32_e32 v0, v9
	s_cmp_lg_u32 s12, 0
	v_rcp_f32_e32 v12, v0
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v0, 0, 1, s[0:1]
	v_frexp_exp_i32_f32_e32 v11, v9
	v_add3_u32 v13, v1, v10, s3
	s_mov_b64 s[2:3], 0
	v_mov_b32_e32 v1, 0
	v_cmp_ne_u32_e64 s[0:1], 1, v0
	s_branch .LBB0_3
.LBB0_2:
	v_add_u32_e32 v8, s15, v8
	v_cmp_le_u32_e32 vcc, s14, v8
	s_waitcnt vmcnt(1)
	v_lshl_add_u64 v[14:15], s[10:11], 0, v[2:3]
	v_lshl_add_u64 v[2:3], s[8:9], 0, v[2:3]
	s_or_b64 s[2:3], vcc, s[2:3]
	v_add_u32_e32 v13, s15, v13
	global_store_dword v[14:15], v4, off
	global_store_dword v[2:3], v6, off
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execz .LBB0_9
.LBB0_3:
	v_add_u32_e32 v0, v8, v10
	v_lshlrev_b64 v[2:3], 2, v[0:1]
	v_lshl_add_u64 v[4:5], s[20:21], 0, v[2:3]
	global_load_dword v14, v[4:5], off
	v_lshl_add_u64 v[4:5], s[22:23], 0, v[2:3]
	global_load_dword v15, v[4:5], off
	v_lshl_add_u64 v[4:5], s[6:7], 0, v[2:3]
	global_load_dword v16, v[4:5], off
	s_and_b64 vcc, exec, s[0:1]
	v_mov_b32_e32 v7, v1
	v_mov_b32_e32 v6, v1
	v_mov_b32_e32 v5, v1
	v_mov_b32_e32 v4, v1
	s_cbranch_vccnz .LBB0_6
	v_mov_b32_e32 v4, 0
	s_mov_b32 s24, s12
	v_mov_b32_e32 v0, v13
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v6, v4
	v_mov_b32_e32 v7, v4
.LBB0_5:
	v_lshlrev_b64 v[18:19], 2, v[0:1]
	v_lshl_add_u64 v[20:21], s[16:17], 0, v[18:19]
	v_lshl_add_u64 v[18:19], s[18:19], 0, v[18:19]
	global_load_dword v17, v[20:21], off
	global_load_dword v18, v[18:19], off
	s_add_i32 s24, s24, -1
	v_add_u32_e32 v0, s13, v0
	s_cmp_eq_u32 s24, 0
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v17, v17, v14
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v19, v16, v18
	v_mul_f32_e32 v20, v15, v17
	v_pk_add_f32 v[4:5], v[4:5], v[18:19]
	v_pk_fma_f32 v[6:7], v[20:21], v[18:19], v[6:7] op_sel_hi:[0,1,1]
	s_cbranch_scc0 .LBB0_5
.LBB0_6:
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB0_2
	s_waitcnt vmcnt(1)
	v_frexp_exp_i32_f32_e32 v0, v15
	v_frexp_mant_f32_e32 v17, v15
	v_mul_f32_e32 v17, v17, v12
	v_sub_u32_e32 v0, v0, v11
	v_ldexp_f32 v17, v17, v0
	s_mov_b32 s24, s12
	v_mov_b32_e32 v0, v13
.LBB0_8:
	v_lshlrev_b64 v[18:19], 2, v[0:1]
	v_lshl_add_u64 v[20:21], s[16:17], 0, v[18:19]
	v_lshl_add_u64 v[22:23], s[18:19], 0, v[18:19]
	global_load_dword v20, v[20:21], off
	global_load_dword v21, v[22:23], off
	s_add_i32 s24, s24, -1
	v_add_u32_e32 v0, s13, v0
	v_lshl_add_u64 v[18:19], s[4:5], 0, v[18:19]
	s_cmp_eq_u32 s24, 0
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v20, v20, v14
	v_mul_f32_e32 v20, v15, v20
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v21, v16, v21
	v_fma_f32 v20, v20, v7, v5
	v_fma_f32 v20, v9, v21, -v20
	v_mul_f32_e32 v20, v17, v20
	global_store_dword v[18:19], v20, off
	s_cbranch_scc0 .LBB0_8
	s_branch .LBB0_2
.LBB0_9:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenBatchNormBwdPerActivationSaved
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 336
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 24
		.amdhsa_next_free_sgpr 31
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
.Lfunc_end0:
	.size	MIOpenBatchNormBwdPerActivationSaved, .Lfunc_end0-MIOpenBatchNormBwdPerActivationSaved

	.set MIOpenBatchNormBwdPerActivationSaved.num_vgpr, 24
	.set MIOpenBatchNormBwdPerActivationSaved.num_agpr, 0
	.set MIOpenBatchNormBwdPerActivationSaved.numbered_sgpr, 31
	.set MIOpenBatchNormBwdPerActivationSaved.private_seg_size, 0
	.set MIOpenBatchNormBwdPerActivationSaved.uses_vcc, 1
	.set MIOpenBatchNormBwdPerActivationSaved.uses_flat_scratch, 0
	.set MIOpenBatchNormBwdPerActivationSaved.has_dyn_sized_stack, 0
	.set MIOpenBatchNormBwdPerActivationSaved.has_recursion, 0
	.set MIOpenBatchNormBwdPerActivationSaved.has_indirect_call, 0
	.protected	MIOpenBatchNormBwdPerActivation
	.globl	MIOpenBatchNormBwdPerActivation
	.p2align	8
	.type	MIOpenBatchNormBwdPerActivation,@function
MIOpenBatchNormBwdPerActivation:
	s_load_dword s26, s[0:1], 0x54
	s_load_dwordx4 s[12:15], s[0:1], 0x10
	s_load_dwordx4 s[20:23], s[0:1], 0x70
	s_add_u32 s24, s0, 0x48
	s_addc_u32 s25, s1, 0
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s15, s26, 16
	s_mul_i32 s3, s3, s15
	s_add_i32 s3, s22, s3
	v_bfe_u32 v1, v0, 10, 10
	v_add_u32_e32 v2, s3, v1
	v_cmp_gt_u32_e32 vcc, s14, v2
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_3
	s_and_b32 s3, s26, 0xffff
	v_cvt_f32_u32_e32 v4, s12
	s_mul_i32 s2, s2, s3
	s_load_dwordx4 s[16:19], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x20
	s_load_dwordx2 s[0:1], s[0:1], 0x40
	s_load_dword s3, s[24:25], 0x4
	s_load_dword s21, s[24:25], 0x14
	s_add_i32 s2, s20, s2
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v0, s2, v0
	v_mul_lo_u32 v3, v0, s14
	v_frexp_mant_f32_e32 v0, v4
	v_add_u32_e32 v5, s13, v3
	v_rcp_f32_e32 v9, v0
	v_add_u32_e32 v6, s13, v5
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s15, s3, s15
	s_and_b32 s2, s21, 0xffff
	v_add_u32_e32 v7, s13, v6
	s_mov_b32 s12, 0
	s_add_i32 s15, s15, s2
	v_frexp_exp_i32_f32_e32 v8, v4
	s_mov_b64 s[2:3], 0
	s_mov_b32 s13, 0x3fd80000
	v_mov_b32_e32 v10, 0x180
	v_mov_b32_e32 v1, 0
.LBB1_2:
	v_add_u32_e32 v0, v3, v2
	v_lshlrev_b64 v[12:13], 2, v[0:1]
	v_add_u32_e32 v0, v5, v2
	v_lshlrev_b64 v[16:17], 2, v[0:1]
	v_add_u32_e32 v0, v6, v2
	v_lshl_add_u64 v[14:15], s[16:17], 0, v[12:13]
	v_lshl_add_u64 v[18:19], s[6:7], 0, v[12:13]
	v_lshlrev_b64 v[24:25], 2, v[0:1]
	v_lshl_add_u64 v[20:21], s[18:19], 0, v[12:13]
	v_lshl_add_u64 v[22:23], s[16:17], 0, v[16:17]
	v_add_u32_e32 v0, v7, v2
	global_load_dword v11, v[18:19], off
	global_load_dword v40, v[20:21], off
	v_lshl_add_u64 v[18:19], s[18:19], 0, v[16:17]
	global_load_dword v34, v[14:15], off
	global_load_dword v35, v[22:23], off
	v_lshl_add_u64 v[14:15], s[16:17], 0, v[24:25]
	v_lshlrev_b64 v[20:21], 2, v[0:1]
	global_load_dword v0, v[18:19], off
	v_lshl_add_u64 v[26:27], s[18:19], 0, v[24:25]
	global_load_dword v36, v[14:15], off
	v_lshl_add_u64 v[28:29], s[16:17], 0, v[20:21]
	global_load_dword v41, v[26:27], off
	v_lshl_add_u64 v[30:31], s[18:19], 0, v[20:21]
	global_load_dword v37, v[28:29], off
	global_load_dword v42, v[30:31], off
	v_lshl_add_u64 v[32:33], s[4:5], 0, v[12:13]
	v_lshl_add_u64 v[16:17], s[4:5], 0, v[16:17]
	v_add_u32_e32 v2, s15, v2
	s_waitcnt vmcnt(7)
	v_mul_f32_e32 v43, v11, v40
	s_waitcnt vmcnt(6)
	v_add_f32_e32 v38, 0, v34
	s_waitcnt vmcnt(5)
	v_add_f32_e32 v38, v38, v35
	v_add_f32_e32 v39, 0, v43
	s_waitcnt vmcnt(4)
	v_mul_f32_e32 v44, v11, v0
	v_add_f32_e32 v39, v39, v44
	s_waitcnt vmcnt(3)
	v_add_f32_e32 v38, v38, v36
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v45, v11, v41
	s_waitcnt vmcnt(1)
	v_add_f32_e32 v38, v38, v37
	v_add_f32_e32 v39, v39, v45
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v46, v11, v42
	v_frexp_exp_i32_f32_e32 v47, v38
	v_frexp_mant_f32_e32 v38, v38
	v_add_f32_e32 v48, v39, v46
	v_mul_f32_e32 v38, v38, v9
	v_sub_u32_e32 v39, v47, v8
	v_ldexp_f32 v47, v38, v39
	v_sub_f32_e32 v49, v34, v47
	v_sub_f32_e32 v50, v35, v47
	v_fma_f32 v34, v49, v49, 0
	v_sub_f32_e32 v51, v36, v47
	v_fmac_f32_e32 v34, v50, v50
	v_sub_f32_e32 v52, v37, v47
	v_fmac_f32_e32 v34, v51, v51
	v_fmac_f32_e32 v34, v52, v52
	v_frexp_exp_i32_f32_e32 v35, v34
	v_frexp_mant_f32_e32 v34, v34
	v_mul_f32_e32 v34, v34, v9
	v_sub_u32_e32 v35, v35, v8
	v_ldexp_f32 v34, v34, v35
	v_cvt_f64_f32_e32 v[34:35], v34
	v_add_f64 v[34:35], s[0:1], v[34:35]
	v_rsq_f64_e32 v[36:37], v[34:35]
	s_nop 0
	v_mul_f64 v[34:35], v[36:37], -v[34:35]
	v_fma_f64 v[34:35], v[34:35], v[36:37], 1.0
	v_mul_f64 v[38:39], v[36:37], v[34:35]
	v_fma_f64 v[34:35], v[34:35], s[12:13], 0.5
	v_fma_f64 v[34:35], v[38:39], v[34:35], v[36:37]
	v_cmp_class_f64_e32 vcc, v[36:37], v10
	s_nop 1
	v_cndmask_b32_e32 v35, v37, v35, vcc
	v_cndmask_b32_e32 v34, v36, v34, vcc
	v_cvt_f32_f64_e32 v34, v[34:35]
	v_mul_f32_e32 v35, v49, v34
	v_mul_f32_e32 v36, v50, v34
	v_fma_f32 v50, v43, v35, 0
	v_mul_f32_e32 v37, v51, v34
	v_fmac_f32_e32 v50, v44, v36
	v_mul_f32_e32 v38, v52, v34
	v_fmac_f32_e32 v50, v45, v37
	v_frexp_exp_i32_f32_e32 v39, v34
	v_frexp_mant_f32_e32 v49, v34
	v_fmac_f32_e32 v50, v46, v38
	v_mul_f32_e32 v49, v49, v9
	v_sub_u32_e32 v39, v39, v8
	v_fma_f32 v44, v35, v50, v48
	v_ldexp_f32 v39, v49, v39
	v_fma_f32 v43, v4, v43, -v44
	v_mul_f32_e32 v43, v39, v43
	global_store_dword v[32:33], v43, off
	global_load_dword v22, v[22:23], off
	global_load_dword v18, v[18:19], off
	v_cmp_le_u32_e32 vcc, s14, v2
	s_or_b64 s[2:3], vcc, s[2:3]
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v19, v22, v47
	v_mul_f32_e32 v19, v19, v34
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v18, v11, v18
	v_fma_f32 v19, v19, v50, v48
	v_fma_f32 v18, v4, v18, -v19
	v_mul_f32_e32 v18, v39, v18
	global_store_dword v[16:17], v18, off
	global_load_dword v16, v[14:15], off
	global_load_dword v17, v[26:27], off
	v_lshl_add_u64 v[14:15], s[4:5], 0, v[24:25]
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v16, v16, v47
	v_mul_f32_e32 v16, v16, v34
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v17, v11, v17
	v_fma_f32 v16, v16, v50, v48
	v_fma_f32 v16, v4, v17, -v16
	v_mul_f32_e32 v16, v39, v16
	global_store_dword v[14:15], v16, off
	global_load_dword v18, v[28:29], off
	global_load_dword v19, v[30:31], off
	v_lshl_add_u64 v[16:17], s[4:5], 0, v[20:21]
	v_add_f32_e32 v20, 0, v40
	v_fma_f32 v21, v35, v40, 0
	v_add_f32_e32 v20, v20, v0
	v_fmac_f32_e32 v21, v36, v0
	v_add_f32_e32 v20, v20, v41
	v_fmac_f32_e32 v21, v37, v41
	v_lshl_add_u64 v[14:15], s[10:11], 0, v[12:13]
	v_lshl_add_u64 v[12:13], s[8:9], 0, v[12:13]
	v_add_f32_e32 v20, v20, v42
	v_fmac_f32_e32 v21, v38, v42
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v0, v18, v47
	v_mul_f32_e32 v0, v0, v34
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v11, v11, v19
	v_fmac_f32_e32 v48, v0, v50
	v_fma_f32 v0, v4, v11, -v48
	v_mul_f32_e32 v0, v39, v0
	global_store_dword v[16:17], v0, off
	global_store_dword v[14:15], v20, off
	global_store_dword v[12:13], v21, off
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB1_2
.LBB1_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenBatchNormBwdPerActivation
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 53
		.amdhsa_next_free_sgpr 27
		.amdhsa_accum_offset 56
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
.Lfunc_end1:
	.size	MIOpenBatchNormBwdPerActivation, .Lfunc_end1-MIOpenBatchNormBwdPerActivation

	.set MIOpenBatchNormBwdPerActivation.num_vgpr, 53
	.set MIOpenBatchNormBwdPerActivation.num_agpr, 0
	.set MIOpenBatchNormBwdPerActivation.numbered_sgpr, 27
	.set MIOpenBatchNormBwdPerActivation.private_seg_size, 0
	.set MIOpenBatchNormBwdPerActivation.uses_vcc, 1
	.set MIOpenBatchNormBwdPerActivation.uses_flat_scratch, 0
	.set MIOpenBatchNormBwdPerActivation.has_dyn_sized_stack, 0
	.set MIOpenBatchNormBwdPerActivation.has_recursion, 0
	.set MIOpenBatchNormBwdPerActivation.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.ident	"Homebrew clang version 21.1.8"
	.ident	"AMD clang version 22.0.0git (https://github.com/RadeonOpenCompute/llvm-project roc-7.2.1 26084 f58b06dce1f9c15707c5f808fd002e18c2accf7e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .name:           in
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           dy_in
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           !str N
        .offset:         16
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           in_nstride
        .offset:         20
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           in_cstride
        .offset:         24
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .address_space:  global
        .name:           dx_out
        .offset:         32
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           scale
        .offset:         40
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           delta_scale
        .offset:         48
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           delta_bias
        .offset:         56
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           savedMean
        .offset:         64
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           savedInvVariance
        .offset:         72
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         84
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         92
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         94
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         96
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         98
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         100
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         102
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         144
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 336
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenBatchNormBwdPerActivationSaved
    .private_segment_fixed_size: 0
    .sgpr_count:     37
    .sgpr_spill_count: 0
    .symbol:         MIOpenBatchNormBwdPerActivationSaved.kd
    .uses_dynamic_stack: false
    .vgpr_count:     24
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .name:           in
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           dy_in
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           !str N
        .offset:         16
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           in_nstride
        .offset:         20
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           in_cstride
        .offset:         24
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .address_space:  global
        .name:           dx_out
        .offset:         32
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           scale
        .offset:         40
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           delta_scale
        .offset:         48
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           delta_bias
        .offset:         56
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           epsilon
        .offset:         64
        .size:           8
        .type_name:      double
        .value_kind:     by_value
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
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenBatchNormBwdPerActivation
    .private_segment_fixed_size: 0
    .sgpr_count:     33
    .sgpr_spill_count: 0
    .symbol:         MIOpenBatchNormBwdPerActivation.kd
    .uses_dynamic_stack: false
    .vgpr_count:     53
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
