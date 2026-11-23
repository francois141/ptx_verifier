; MIOpen rocm-7.2.4 src/kernels/MIOpenNeuron.cl (MIOpenActiveBwdLite), src/solver/activ/bwd_0.cpp:ActivBwdSolver0::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case sigmoid_bwd).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenActiveFwdLite
	.globl	MIOpenActiveFwdLite
	.p2align	8
	.type	MIOpenActiveFwdLite,@function
MIOpenActiveFwdLite:
	s_load_dword s3, s[0:1], 0x3c
	s_load_dword s12, s[0:1], 0x58
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx4 s[8:11], s[0:1], 0x20
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s3, 0xffff
	s_mul_i32 s2, s2, s0
	s_add_i32 s12, s12, s2
	s_lshl_b64 s[0:1], s[8:9], 2
	v_add_lshl_u32 v0, s12, v0, 2
	s_add_u32 s0, s4, s0
	s_addc_u32 s1, s5, s1
	v_lshlrev_b64 v[4:5], 2, v[0:1]
	v_lshl_add_u64 v[0:1], s[0:1], 0, v[4:5]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_mov_b32 s0, 0xbfb8aa3b
	s_mov_b32 s1, 0x42ce8ed0
	s_mov_b32 s2, 0xc2b17218
	v_mov_b32_e32 v6, 0x7f800000
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v7, 0xbfb8aa3b, v0
	v_mul_f32_e32 v8, 0xbfb8aa3b, v1
	v_fma_f32 v11, v0, s0, -v7
	v_rndne_f32_e32 v12, v7
	v_mul_f32_e32 v9, 0xbfb8aa3b, v2
	v_fma_f32 v13, v1, s0, -v8
	v_rndne_f32_e32 v14, v8
	v_fmac_f32_e32 v11, 0xb2a5705f, v0
	v_sub_f32_e32 v7, v7, v12
	v_mul_f32_e32 v10, 0xbfb8aa3b, v3
	v_fma_f32 v15, v2, s0, -v9
	v_rndne_f32_e32 v16, v9
	v_fmac_f32_e32 v13, 0xb2a5705f, v1
	v_sub_f32_e32 v8, v8, v14
	v_add_f32_e32 v7, v7, v11
	v_fma_f32 v17, v3, s0, -v10
	v_rndne_f32_e32 v18, v10
	v_cvt_i32_f32_e32 v12, v12
	v_fmac_f32_e32 v15, 0xb2a5705f, v2
	v_sub_f32_e32 v9, v9, v16
	v_add_f32_e32 v8, v8, v13
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v14, v14
	v_fmac_f32_e32 v17, 0xb2a5705f, v3
	v_sub_f32_e32 v10, v10, v18
	v_add_f32_e32 v9, v9, v15
	v_exp_f32_e32 v8, v8
	v_cvt_i32_f32_e32 v16, v16
	v_add_f32_e32 v10, v10, v17
	v_exp_f32_e32 v9, v9
	v_cvt_i32_f32_e32 v18, v18
	v_exp_f32_e32 v10, v10
	v_ldexp_f32 v7, v7, v12
	v_cmp_nlt_f32_e32 vcc, s1, v0
	v_ldexp_f32 v8, v8, v14
	v_ldexp_f32 v9, v9, v16
	v_cndmask_b32_e32 v7, 0, v7, vcc
	v_cmp_nlt_f32_e32 vcc, s1, v1
	v_ldexp_f32 v10, v10, v18
	s_nop 0
	v_cndmask_b32_e32 v8, 0, v8, vcc
	v_cmp_nlt_f32_e32 vcc, s1, v2
	s_nop 1
	v_cndmask_b32_e32 v9, 0, v9, vcc
	v_cmp_nlt_f32_e32 vcc, s1, v3
	s_nop 1
	v_cndmask_b32_e32 v10, 0, v10, vcc
	v_cmp_ngt_f32_e32 vcc, s2, v0
	s_nop 1
	v_cndmask_b32_e32 v0, v6, v7, vcc
	v_cmp_ngt_f32_e32 vcc, s2, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v6, v8, vcc
	v_cmp_ngt_f32_e32 vcc, s2, v2
	v_pk_add_f32 v[0:1], v[0:1], 1.0 op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e32 v2, v6, v9, vcc
	v_cmp_ngt_f32_e32 vcc, s2, v3
	v_div_scale_f32 v12, s[4:5], v0, v0, 1.0
	s_nop 0
	v_cndmask_b32_e32 v3, v6, v10, vcc
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_div_scale_f32 v10, s[2:3], v1, v1, 1.0
	v_div_scale_f32 v6, s[0:1], v3, v3, 1.0
	v_div_scale_f32 v8, s[0:1], v2, v2, 1.0
	v_rcp_f32_e32 v13, v6
	v_rcp_f32_e32 v14, v8
	v_rcp_f32_e32 v15, v10
	v_div_scale_f32 v7, vcc, 1.0, v3, 1.0
	v_fma_f32 v17, -v6, v13, 1.0
	v_fma_f32 v18, -v8, v14, 1.0
	v_fmac_f32_e32 v13, v17, v13
	v_div_scale_f32 v9, s[0:1], 1.0, v2, 1.0
	v_fma_f32 v19, -v10, v15, 1.0
	v_fmac_f32_e32 v14, v18, v14
	v_mul_f32_e32 v17, v7, v13
	v_div_scale_f32 v11, s[2:3], 1.0, v1, 1.0
	v_fmac_f32_e32 v15, v19, v15
	v_mul_f32_e32 v18, v9, v14
	v_fma_f32 v20, -v6, v17, v7
	v_mul_f32_e32 v19, v11, v15
	v_fma_f32 v21, -v8, v18, v9
	v_fmac_f32_e32 v17, v20, v13
	v_rcp_f32_e32 v16, v12
	v_fma_f32 v22, -v10, v19, v11
	v_fmac_f32_e32 v18, v21, v14
	v_fma_f32 v6, -v6, v17, v7
	v_fmac_f32_e32 v19, v22, v15
	v_fma_f32 v7, -v8, v18, v9
	v_div_fmas_f32 v6, v6, v13, v17
	s_mov_b64 vcc, s[0:1]
	v_fma_f32 v8, -v10, v19, v11
	v_div_fixup_f32 v3, v6, v3, 1.0
	v_div_fmas_f32 v6, v7, v14, v18
	s_mov_b64 vcc, s[2:3]
	v_div_fixup_f32 v2, v6, v2, 1.0
	v_div_fmas_f32 v6, v8, v15, v19
	v_div_fixup_f32 v1, v6, v1, 1.0
	v_fma_f32 v6, -v12, v16, 1.0
	v_fmac_f32_e32 v16, v6, v16
	v_div_scale_f32 v6, vcc, 1.0, v0, 1.0
	v_mul_f32_e32 v7, v6, v16
	v_fma_f32 v8, -v12, v7, v6
	v_fmac_f32_e32 v7, v8, v16
	s_lshl_b64 s[0:1], s[10:11], 2
	v_fma_f32 v6, -v12, v7, v6
	s_add_u32 s0, s6, s0
	v_div_fmas_f32 v6, v6, v16, v7
	s_addc_u32 s1, s7, s1
	v_div_fixup_f32 v0, v6, v0, 1.0
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[4:5]
	global_store_dwordx4 v[4:5], v[0:3], off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenActiveFwdLite
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
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
		.amdhsa_next_free_vgpr 23
		.amdhsa_next_free_sgpr 13
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
	.size	MIOpenActiveFwdLite, .Lfunc_end0-MIOpenActiveFwdLite

	.set MIOpenActiveFwdLite.num_vgpr, 23
	.set MIOpenActiveFwdLite.num_agpr, 0
	.set MIOpenActiveFwdLite.numbered_sgpr, 13
	.set MIOpenActiveFwdLite.private_seg_size, 0
	.set MIOpenActiveFwdLite.uses_vcc, 1
	.set MIOpenActiveFwdLite.uses_flat_scratch, 0
	.set MIOpenActiveFwdLite.has_dyn_sized_stack, 0
	.set MIOpenActiveFwdLite.has_recursion, 0
	.set MIOpenActiveFwdLite.has_indirect_call, 0
	.protected	MIOpenActiveFwd2DLite
	.globl	MIOpenActiveFwd2DLite
	.p2align	8
	.type	MIOpenActiveFwd2DLite,@function
MIOpenActiveFwd2DLite:
	s_load_dword s18, s[0:1], 0x44
	s_load_dwordx2 s[16:17], s[0:1], 0x30
	s_load_dwordx4 s[12:15], s[0:1], 0x60
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx4 s[8:11], s[0:1], 0x20
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s0, s18, 16
	s_and_b32 s1, s18, 0xffff
	s_mul_i32 s2, s2, s1
	s_mul_i32 s3, s3, s0
	s_add_i32 s1, s12, s2
	s_add_i32 s0, s14, s3
	v_bfe_u32 v1, v0, 10, 10
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v5, s0, v1
	v_add_lshl_u32 v4, s1, v0, 2
	v_mad_u64_u32 v[6:7], s[0:1], v5, s16, v[4:5]
	s_lshl_b64 s[0:1], s[8:9], 2
	s_add_u32 s0, s4, s0
	s_addc_u32 s1, s5, s1
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[6:7], 2, s[0:1]
	global_load_dwordx4 v[0:3], v[0:1], off
	v_mad_u64_u32 v[4:5], s[0:1], v5, s17, v[4:5]
	s_mov_b32 s2, 0xbfb8aa3b
	s_mov_b32 s3, 0x42ce8ed0
	s_mov_b32 s4, 0xc2b17218
	v_mov_b32_e32 v6, 0x7f800000
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, 0xbfb8aa3b, v0
	v_mul_f32_e32 v8, 0xbfb8aa3b, v1
	v_fma_f32 v11, v0, s2, -v5
	v_rndne_f32_e32 v12, v5
	v_mul_f32_e32 v9, 0xbfb8aa3b, v2
	v_fma_f32 v13, v1, s2, -v8
	v_rndne_f32_e32 v14, v8
	v_fmac_f32_e32 v11, 0xb2a5705f, v0
	v_sub_f32_e32 v5, v5, v12
	v_mul_f32_e32 v10, 0xbfb8aa3b, v3
	v_fma_f32 v15, v2, s2, -v9
	v_rndne_f32_e32 v16, v9
	v_fmac_f32_e32 v13, 0xb2a5705f, v1
	v_sub_f32_e32 v8, v8, v14
	v_add_f32_e32 v5, v5, v11
	v_fma_f32 v17, v3, s2, -v10
	v_rndne_f32_e32 v18, v10
	v_cvt_i32_f32_e32 v12, v12
	v_fmac_f32_e32 v15, 0xb2a5705f, v2
	v_sub_f32_e32 v9, v9, v16
	v_add_f32_e32 v8, v8, v13
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v14, v14
	v_fmac_f32_e32 v17, 0xb2a5705f, v3
	v_sub_f32_e32 v10, v10, v18
	v_add_f32_e32 v9, v9, v15
	v_exp_f32_e32 v8, v8
	v_cvt_i32_f32_e32 v16, v16
	v_add_f32_e32 v10, v10, v17
	v_exp_f32_e32 v9, v9
	v_cvt_i32_f32_e32 v18, v18
	v_exp_f32_e32 v10, v10
	v_ldexp_f32 v5, v5, v12
	v_cmp_nlt_f32_e32 vcc, s3, v0
	v_ldexp_f32 v8, v8, v14
	v_ldexp_f32 v9, v9, v16
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_nlt_f32_e32 vcc, s3, v1
	v_ldexp_f32 v10, v10, v18
	s_nop 0
	v_cndmask_b32_e32 v8, 0, v8, vcc
	v_cmp_nlt_f32_e32 vcc, s3, v2
	s_nop 1
	v_cndmask_b32_e32 v9, 0, v9, vcc
	v_cmp_nlt_f32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e32 v10, 0, v10, vcc
	v_cmp_ngt_f32_e32 vcc, s4, v0
	s_nop 1
	v_cndmask_b32_e32 v0, v6, v5, vcc
	v_cmp_ngt_f32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v6, v8, vcc
	v_cmp_ngt_f32_e32 vcc, s4, v2
	v_pk_add_f32 v[0:1], v[0:1], 1.0 op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e32 v2, v6, v9, vcc
	v_cmp_ngt_f32_e32 vcc, s4, v3
	v_div_scale_f32 v9, s[0:1], v1, v1, 1.0
	s_nop 0
	v_cndmask_b32_e32 v3, v6, v10, vcc
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_rcp_f32_e32 v12, v9
	v_div_scale_f32 v5, s[0:1], v3, v3, 1.0
	v_div_scale_f32 v8, s[0:1], v2, v2, 1.0
	v_rcp_f32_e32 v10, v5
	v_rcp_f32_e32 v11, v8
	v_div_scale_f32 v6, vcc, 1.0, v3, 1.0
	v_fma_f32 v14, -v5, v10, 1.0
	v_fma_f32 v15, -v8, v11, 1.0
	v_fmac_f32_e32 v10, v14, v10
	v_div_scale_f32 v13, s[0:1], 1.0, v2, 1.0
	v_fmac_f32_e32 v11, v15, v11
	v_mul_f32_e32 v14, v6, v10
	v_mul_f32_e32 v15, v13, v11
	v_fma_f32 v17, -v5, v14, v6
	v_fma_f32 v18, -v8, v15, v13
	v_fmac_f32_e32 v14, v17, v10
	v_fmac_f32_e32 v15, v18, v11
	v_fma_f32 v5, -v5, v14, v6
	v_fma_f32 v6, -v8, v15, v13
	v_div_fmas_f32 v5, v5, v10, v14
	s_mov_b64 vcc, s[0:1]
	v_fma_f32 v16, -v9, v12, 1.0
	v_div_fixup_f32 v3, v5, v3, 1.0
	v_div_fmas_f32 v5, v6, v11, v15
	v_div_fixup_f32 v2, v5, v2, 1.0
	v_fmac_f32_e32 v12, v16, v12
	v_div_scale_f32 v5, vcc, 1.0, v1, 1.0
	v_mul_f32_e32 v6, v5, v12
	v_fma_f32 v8, -v9, v6, v5
	v_fmac_f32_e32 v6, v8, v12
	v_div_scale_f32 v8, s[0:1], v0, v0, 1.0
	v_fma_f32 v5, -v9, v6, v5
	v_rcp_f32_e32 v9, v8
	v_div_fmas_f32 v5, v5, v12, v6
	v_div_fixup_f32 v1, v5, v1, 1.0
	s_lshl_b64 s[0:1], s[10:11], 2
	v_fma_f32 v5, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v5, v9
	v_div_scale_f32 v5, vcc, 1.0, v0, 1.0
	v_mul_f32_e32 v6, v5, v9
	v_fma_f32 v10, -v8, v6, v5
	v_fmac_f32_e32 v6, v10, v9
	v_fma_f32 v5, -v8, v6, v5
	v_div_fmas_f32 v5, v5, v9, v6
	s_add_u32 s0, s6, s0
	v_div_fixup_f32 v0, v5, v0, 1.0
	s_addc_u32 s1, s7, s1
	v_mov_b32_e32 v5, v7
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[0:1]
	global_store_dwordx4 v[4:5], v[0:3], off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenActiveFwd2DLite
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
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
		.amdhsa_next_free_vgpr 19
		.amdhsa_next_free_sgpr 19
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
.Lfunc_end1:
	.size	MIOpenActiveFwd2DLite, .Lfunc_end1-MIOpenActiveFwd2DLite

	.set MIOpenActiveFwd2DLite.num_vgpr, 19
	.set MIOpenActiveFwd2DLite.num_agpr, 0
	.set MIOpenActiveFwd2DLite.numbered_sgpr, 19
	.set MIOpenActiveFwd2DLite.private_seg_size, 0
	.set MIOpenActiveFwd2DLite.uses_vcc, 1
	.set MIOpenActiveFwd2DLite.uses_flat_scratch, 0
	.set MIOpenActiveFwd2DLite.has_dyn_sized_stack, 0
	.set MIOpenActiveFwd2DLite.has_recursion, 0
	.set MIOpenActiveFwd2DLite.has_indirect_call, 0
	.protected	MIOpenActiveBwdLite
	.globl	MIOpenActiveBwdLite
	.p2align	8
	.type	MIOpenActiveBwdLite,@function
MIOpenActiveBwdLite:
	s_load_dword s3, s[0:1], 0x5c
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x18
	s_load_dword s14, s[0:1], 0x78
	s_load_dwordx4 s[8:11], s[0:1], 0x30
	s_load_dwordx2 s[0:1], s[0:1], 0x48
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s14, s14, s2
	s_lshl_b64 s[2:3], s[10:11], 2
	s_add_u32 s2, s6, s2
	v_add_lshl_u32 v0, s14, v0, 2
	s_addc_u32 s3, s7, s3
	s_lshl_b64 s[0:1], s[0:1], 2
	v_ashrrev_i32_e32 v1, 31, v0
	s_add_u32 s0, s12, s0
	v_lshlrev_b64 v[8:9], 2, v[0:1]
	s_addc_u32 s1, s13, s1
	v_lshl_add_u64 v[0:1], s[0:1], 0, v[8:9]
	v_lshl_add_u64 v[4:5], s[2:3], 0, v[8:9]
	global_load_dwordx4 v[0:3], v[0:1], off
	global_load_dwordx4 v[4:7], v[4:5], off
	s_lshl_b64 s[0:1], s[8:9], 2
	s_add_u32 s0, s4, s0
	s_addc_u32 s1, s5, s1
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v11, 1.0, v1
	v_sub_f32_e32 v10, 1.0, v0
	v_sub_f32_e32 v13, 1.0, v3
	v_sub_f32_e32 v12, 1.0, v2
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[2:3], v[6:7], v[2:3]
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1]
	v_pk_mul_f32 v[2:3], v[12:13], v[2:3]
	v_pk_mul_f32 v[0:1], v[10:11], v[0:1]
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[8:9]
	global_store_dwordx4 v[4:5], v[0:3], off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenActiveBwdLite
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 15
		.amdhsa_accum_offset 16
		.amdhsa_reserve_vcc 0
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
.Lfunc_end2:
	.size	MIOpenActiveBwdLite, .Lfunc_end2-MIOpenActiveBwdLite

	.set MIOpenActiveBwdLite.num_vgpr, 14
	.set MIOpenActiveBwdLite.num_agpr, 0
	.set MIOpenActiveBwdLite.numbered_sgpr, 15
	.set MIOpenActiveBwdLite.private_seg_size, 0
	.set MIOpenActiveBwdLite.uses_vcc, 0
	.set MIOpenActiveBwdLite.uses_flat_scratch, 0
	.set MIOpenActiveBwdLite.has_dyn_sized_stack, 0
	.set MIOpenActiveBwdLite.has_recursion, 0
	.set MIOpenActiveBwdLite.has_indirect_call, 0
	.protected	MIOpenActiveBwd2DLite
	.globl	MIOpenActiveBwd2DLite
	.p2align	8
	.type	MIOpenActiveBwd2DLite,@function
MIOpenActiveBwd2DLite:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[20:21], s[0:1], 0x18
	s_load_dword s22, s[0:1], 0x6c
	s_load_dword s23, s[0:1], 0x5c
	s_load_dwordx4 s[12:15], s[0:1], 0x88
	s_load_dwordx4 s[8:11], s[0:1], 0x30
	s_load_dwordx4 s[16:19], s[0:1], 0x48
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s0, s22, 16
	s_and_b32 s1, s22, 0xffff
	s_mul_i32 s2, s2, s1
	s_mul_i32 s3, s3, s0
	s_add_i32 s1, s12, s2
	s_add_i32 s0, s14, s3
	v_bfe_u32 v1, v0, 10, 10
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v9, s0, v1
	v_add_lshl_u32 v8, s1, v0, 2
	v_mad_u64_u32 v[10:11], s[0:1], v9, s19, v[8:9]
	v_mad_u64_u32 v[0:1], s[0:1], v9, s23, v[8:9]
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	s_lshl_b64 s[2:3], s[16:17], 2
	v_mov_b32_e32 v11, 0
	s_add_u32 s2, s20, s2
	s_addc_u32 s3, s21, s3
	v_mov_b32_e32 v1, v11
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[2:3]
	v_lshl_add_u64 v[4:5], v[10:11], 2, s[0:1]
	global_load_dwordx4 v[0:3], v[0:1], off
	global_load_dwordx4 v[4:7], v[4:5], off
	v_mad_u64_u32 v[8:9], s[0:1], v9, s18, v[8:9]
	s_lshl_b64 s[0:1], s[8:9], 2
	s_add_u32 s0, s4, s0
	v_mov_b32_e32 v9, v11
	s_addc_u32 s1, s5, s1
	s_waitcnt vmcnt(1)
	v_sub_f32_e32 v11, 1.0, v1
	v_sub_f32_e32 v10, 1.0, v0
	v_sub_f32_e32 v13, 1.0, v3
	v_sub_f32_e32 v12, 1.0, v2
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[2:3], v[6:7], v[2:3]
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1]
	v_pk_mul_f32 v[2:3], v[12:13], v[2:3]
	v_pk_mul_f32 v[0:1], v[10:11], v[0:1]
	v_lshl_add_u64 v[4:5], v[8:9], 2, s[0:1]
	global_store_dwordx4 v[4:5], v[0:3], off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenActiveBwd2DLite
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 24
		.amdhsa_accum_offset 16
		.amdhsa_reserve_vcc 0
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
.Lfunc_end3:
	.size	MIOpenActiveBwd2DLite, .Lfunc_end3-MIOpenActiveBwd2DLite

	.set MIOpenActiveBwd2DLite.num_vgpr, 14
	.set MIOpenActiveBwd2DLite.num_agpr, 0
	.set MIOpenActiveBwd2DLite.numbered_sgpr, 24
	.set MIOpenActiveBwd2DLite.private_seg_size, 0
	.set MIOpenActiveBwd2DLite.uses_vcc, 0
	.set MIOpenActiveBwd2DLite.uses_flat_scratch, 0
	.set MIOpenActiveBwd2DLite.has_dyn_sized_stack, 0
	.set MIOpenActiveBwd2DLite.has_recursion, 0
	.set MIOpenActiveBwd2DLite.has_indirect_call, 0
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
        .name:           bot
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           top
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           gamma
        .offset:         16
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         20
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           alpha
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           bot_offset
        .offset:         32
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_offset
        .offset:         40
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenActiveFwdLite
    .private_segment_fixed_size: 0
    .sgpr_count:     19
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveFwdLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     23
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .name:           bot
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           top
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           gamma
        .offset:         16
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         20
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           alpha
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           bot_offset
        .offset:         32
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_offset
        .offset:         40
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           bot_stride
        .offset:         48
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           top_stride
        .offset:         52
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenActiveFwd2DLite
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveFwd2DLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     19
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .name:           bot_diff
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           top_diff
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           bot
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           top
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           diff_scale
        .offset:         32
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           gamma
        .offset:         36
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         40
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           alpha
        .offset:         44
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           bot_diff_offset
        .offset:         48
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_diff_offset
        .offset:         56
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           bot_offset
        .offset:         64
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_offset
        .offset:         72
        .size:           8
        .type_name:      long
        .value_kind:     by_value
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
    .name:           MIOpenActiveBwdLite
    .private_segment_fixed_size: 0
    .sgpr_count:     21
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveBwdLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .name:           bot_diff
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           top_diff
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           bot
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .name:           top
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           diff_scale
        .offset:         32
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           gamma
        .offset:         36
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         40
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           alpha
        .offset:         44
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           bot_diff_offset
        .offset:         48
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_diff_offset
        .offset:         56
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           bot_offset
        .offset:         64
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           top_offset
        .offset:         72
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           bot_diff_stride
        .offset:         80
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           top_diff_stride
        .offset:         84
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           bot_stride
        .offset:         88
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           top_stride
        .offset:         92
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenActiveBwd2DLite
    .private_segment_fixed_size: 0
    .sgpr_count:     30
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveBwd2DLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
