; MIOpen rocm-7.2.4 src/kernels/MIOpenNeuron.cl (MIOpenActiveFwdLite), src/solver/activ/fwd_0.cpp:ActivFwdSolver0::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case relu6_fwd).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenActiveFwdLite
	.globl	MIOpenActiveFwdLite
	.p2align	8
	.type	MIOpenActiveFwdLite,@function
MIOpenActiveFwdLite:
	s_load_dword s3, s[0:1], 0x3c
	s_load_dwordx4 s[4:7], s[0:1], 0x20
	s_load_dword s12, s[0:1], 0x58
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dword s13, s[0:1], 0x18
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s3, 0xffff
	s_mul_i32 s2, s2, s0
	s_add_i32 s12, s12, s2
	s_lshl_b64 s[0:1], s[4:5], 2
	v_add_lshl_u32 v0, s12, v0, 2
	s_add_u32 s0, s8, s0
	v_mov_b32_e32 v1, 0
	s_addc_u32 s1, s9, s1
	v_lshlrev_b64 v[4:5], 2, v[0:1]
	v_lshl_add_u64 v[0:1], s[0:1], 0, v[4:5]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_lshl_b64 s[0:1], s[6:7], 2
	s_add_u32 s0, s10, s0
	v_max_f32_e64 v6, s13, s13
	s_addc_u32 s1, s11, s1
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[4:5]
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v0, v0, v0
	v_max_f32_e32 v1, v1, v1
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v3, v3, v3
	v_max_f32_e32 v0, 0, v0
	v_max_f32_e32 v1, 0, v1
	v_max_f32_e32 v2, 0, v2
	v_max_f32_e32 v3, 0, v3
	v_min_f32_e32 v0, v6, v0
	v_min_f32_e32 v1, v6, v1
	v_min_f32_e32 v2, v6, v2
	v_min_f32_e32 v3, v6, v3
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
		.amdhsa_next_free_vgpr 7
		.amdhsa_next_free_sgpr 14
		.amdhsa_accum_offset 8
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
.Lfunc_end0:
	.size	MIOpenActiveFwdLite, .Lfunc_end0-MIOpenActiveFwdLite

	.set MIOpenActiveFwdLite.num_vgpr, 7
	.set MIOpenActiveFwdLite.num_agpr, 0
	.set MIOpenActiveFwdLite.numbered_sgpr, 14
	.set MIOpenActiveFwdLite.private_seg_size, 0
	.set MIOpenActiveFwdLite.uses_vcc, 0
	.set MIOpenActiveFwdLite.uses_flat_scratch, 0
	.set MIOpenActiveFwdLite.has_dyn_sized_stack, 0
	.set MIOpenActiveFwdLite.has_recursion, 0
	.set MIOpenActiveFwdLite.has_indirect_call, 0
	.protected	MIOpenActiveFwd2DLite
	.globl	MIOpenActiveFwd2DLite
	.p2align	8
	.type	MIOpenActiveFwd2DLite,@function
MIOpenActiveFwd2DLite:
	s_load_dword s16, s[0:1], 0x44
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dword s17, s[0:1], 0x18
	s_load_dwordx4 s[8:11], s[0:1], 0x60
	s_load_dwordx4 s[12:15], s[0:1], 0x20
	s_load_dwordx2 s[0:1], s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s9, s16, 16
	s_and_b32 s11, s16, 0xffff
	s_mul_i32 s2, s2, s11
	s_mul_i32 s3, s3, s9
	s_add_i32 s2, s8, s2
	s_add_i32 s3, s10, s3
	v_bfe_u32 v1, v0, 10, 10
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v5, s3, v1
	v_add_lshl_u32 v4, s2, v0, 2
	v_mad_u64_u32 v[6:7], s[2:3], v5, s0, v[4:5]
	s_lshl_b64 s[2:3], s[12:13], 2
	s_add_u32 s2, s4, s2
	s_addc_u32 s3, s5, s3
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[6:7], 2, s[2:3]
	global_load_dwordx4 v[0:3], v[0:1], off
	v_mad_u64_u32 v[4:5], s[0:1], v5, s1, v[4:5]
	s_lshl_b64 s[0:1], s[14:15], 2
	s_add_u32 s0, s6, s0
	v_max_f32_e64 v6, s17, s17
	s_addc_u32 s1, s7, s1
	v_mov_b32_e32 v5, v7
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[0:1]
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v0, v0, v0
	v_max_f32_e32 v1, v1, v1
	v_max_f32_e32 v2, v2, v2
	v_max_f32_e32 v3, v3, v3
	v_max_f32_e32 v0, 0, v0
	v_max_f32_e32 v1, 0, v1
	v_max_f32_e32 v2, 0, v2
	v_max_f32_e32 v3, 0, v3
	v_min_f32_e32 v0, v6, v0
	v_min_f32_e32 v1, v6, v1
	v_min_f32_e32 v2, v6, v2
	v_min_f32_e32 v3, v6, v3
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
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 18
		.amdhsa_accum_offset 8
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
.Lfunc_end1:
	.size	MIOpenActiveFwd2DLite, .Lfunc_end1-MIOpenActiveFwd2DLite

	.set MIOpenActiveFwd2DLite.num_vgpr, 8
	.set MIOpenActiveFwd2DLite.num_agpr, 0
	.set MIOpenActiveFwd2DLite.numbered_sgpr, 18
	.set MIOpenActiveFwd2DLite.private_seg_size, 0
	.set MIOpenActiveFwd2DLite.uses_vcc, 0
	.set MIOpenActiveFwd2DLite.uses_flat_scratch, 0
	.set MIOpenActiveFwd2DLite.has_dyn_sized_stack, 0
	.set MIOpenActiveFwd2DLite.has_recursion, 0
	.set MIOpenActiveFwd2DLite.has_indirect_call, 0
	.protected	MIOpenActiveBwdLite
	.globl	MIOpenActiveBwdLite
	.p2align	8
	.type	MIOpenActiveBwdLite,@function
MIOpenActiveBwdLite:
	s_load_dwordx2 s[8:9], s[0:1], 0x40
	s_load_dword s3, s[0:1], 0x5c
	s_load_dword s12, s[0:1], 0x78
	s_load_dwordx4 s[16:19], s[0:1], 0x0
	s_load_dwordx2 s[10:11], s[0:1], 0x10
	s_load_dwordx4 s[4:7], s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s12, s12, s2
	v_add_lshl_u32 v0, s12, v0, 2
	s_lshl_b64 s[2:3], s[6:7], 2
	s_add_u32 s2, s18, s2
	s_addc_u32 s3, s19, s3
	s_lshl_b64 s[6:7], s[8:9], 2
	v_ashrrev_i32_e32 v1, 31, v0
	s_add_u32 s6, s10, s6
	v_lshlrev_b64 v[8:9], 2, v[0:1]
	s_addc_u32 s7, s11, s7
	v_lshl_add_u64 v[0:1], s[6:7], 0, v[8:9]
	global_load_dwordx4 v[0:3], v[0:1], off
	v_lshl_add_u64 v[4:5], s[2:3], 0, v[8:9]
	global_load_dwordx4 v[4:7], v[4:5], off
	s_load_dword s12, s[0:1], 0x2c
	s_lshl_b64 s[14:15], s[4:5], 2
	s_waitcnt vmcnt(1)
	v_cmp_lt_f32_e64 s[0:1], 0, v0
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[4:5], s12, v0
	v_cmp_lt_f32_e64 s[6:7], 0, v3
	v_cmp_ge_f32_e64 s[10:11], s12, v3
	s_and_b64 s[0:1], s[0:1], s[4:5]
	v_cmp_lt_f32_e32 vcc, 0, v1
	v_cmp_ge_f32_e64 s[2:3], s12, v1
	v_cmp_lt_f32_e64 s[8:9], 0, v2
	v_cmp_ge_f32_e64 s[12:13], s12, v2
	v_cndmask_b32_e64 v0, 0, 1.0, s[0:1]
	s_and_b64 s[0:1], s[6:7], s[10:11]
	s_and_b64 s[2:3], vcc, s[2:3]
	v_cndmask_b32_e64 v3, 0, 1.0, s[0:1]
	s_and_b64 s[0:1], s[8:9], s[12:13]
	v_cndmask_b32_e64 v2, 0, 1.0, s[0:1]
	s_add_u32 s0, s16, s14
	v_cndmask_b32_e64 v1, 0, 1.0, s[2:3]
	s_addc_u32 s1, s17, s15
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1]
	v_pk_mul_f32 v[2:3], v[6:7], v[2:3]
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
		.amdhsa_next_free_vgpr 10
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 12
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
.Lfunc_end2:
	.size	MIOpenActiveBwdLite, .Lfunc_end2-MIOpenActiveBwdLite

	.set MIOpenActiveBwdLite.num_vgpr, 10
	.set MIOpenActiveBwdLite.num_agpr, 0
	.set MIOpenActiveBwdLite.numbered_sgpr, 20
	.set MIOpenActiveBwdLite.private_seg_size, 0
	.set MIOpenActiveBwdLite.uses_vcc, 1
	.set MIOpenActiveBwdLite.uses_flat_scratch, 0
	.set MIOpenActiveBwdLite.has_dyn_sized_stack, 0
	.set MIOpenActiveBwdLite.has_recursion, 0
	.set MIOpenActiveBwdLite.has_indirect_call, 0
	.protected	MIOpenActiveBwd2DLite
	.globl	MIOpenActiveBwd2DLite
	.p2align	8
	.type	MIOpenActiveBwd2DLite,@function
MIOpenActiveBwd2DLite:
	s_load_dwordx4 s[16:19], s[0:1], 0x0
	s_load_dwordx2 s[20:21], s[0:1], 0x10
	s_load_dword s24, s[0:1], 0x6c
	s_load_dwordx4 s[4:7], s[0:1], 0x30
	s_load_dwordx4 s[8:11], s[0:1], 0x88
	s_load_dwordx2 s[22:23], s[0:1], 0x40
	s_load_dwordx4 s[12:15], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s9, s24, 16
	s_and_b32 s11, s24, 0xffff
	s_mul_i32 s2, s2, s11
	s_mul_i32 s3, s3, s9
	s_add_i32 s2, s8, s2
	s_add_i32 s3, s10, s3
	v_bfe_u32 v1, v0, 10, 10
	v_and_b32_e32 v0, 0x3ff, v0
	v_add_u32_e32 v9, s3, v1
	v_add_lshl_u32 v8, s2, v0, 2
	v_mad_u64_u32 v[10:11], s[2:3], v9, s13, v[8:9]
	v_mad_u64_u32 v[0:1], s[2:3], v9, s14, v[8:9]
	s_lshl_b64 s[2:3], s[6:7], 2
	s_add_u32 s2, s18, s2
	s_addc_u32 s3, s19, s3
	s_lshl_b64 s[6:7], s[22:23], 2
	v_mov_b32_e32 v11, 0
	s_add_u32 s6, s20, s6
	s_addc_u32 s7, s21, s7
	v_mov_b32_e32 v1, v11
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[6:7]
	global_load_dwordx4 v[0:3], v[0:1], off
	v_lshl_add_u64 v[4:5], v[10:11], 2, s[2:3]
	global_load_dwordx4 v[4:7], v[4:5], off
	s_load_dword s13, s[0:1], 0x2c
	v_mad_u64_u32 v[8:9], s[0:1], v9, s12, v[8:9]
	s_lshl_b64 s[14:15], s[4:5], 2
	v_mov_b32_e32 v9, v11
	s_waitcnt vmcnt(1)
	v_cmp_lt_f32_e64 s[0:1], 0, v0
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[4:5], s13, v0
	v_cmp_lt_f32_e64 s[6:7], 0, v3
	v_cmp_ge_f32_e64 s[10:11], s13, v3
	s_and_b64 s[0:1], s[0:1], s[4:5]
	v_cmp_lt_f32_e32 vcc, 0, v1
	v_cmp_ge_f32_e64 s[2:3], s13, v1
	v_cmp_lt_f32_e64 s[8:9], 0, v2
	v_cmp_ge_f32_e64 s[12:13], s13, v2
	v_cndmask_b32_e64 v0, 0, 1.0, s[0:1]
	s_and_b64 s[0:1], s[6:7], s[10:11]
	s_and_b64 s[2:3], vcc, s[2:3]
	v_cndmask_b32_e64 v3, 0, 1.0, s[0:1]
	s_and_b64 s[0:1], s[8:9], s[12:13]
	v_cndmask_b32_e64 v2, 0, 1.0, s[0:1]
	s_add_u32 s0, s16, s14
	v_cndmask_b32_e64 v1, 0, 1.0, s[2:3]
	s_addc_u32 s1, s17, s15
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1]
	v_pk_mul_f32 v[2:3], v[6:7], v[2:3]
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
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 25
		.amdhsa_accum_offset 12
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
.Lfunc_end3:
	.size	MIOpenActiveBwd2DLite, .Lfunc_end3-MIOpenActiveBwd2DLite

	.set MIOpenActiveBwd2DLite.num_vgpr, 12
	.set MIOpenActiveBwd2DLite.num_agpr, 0
	.set MIOpenActiveBwd2DLite.numbered_sgpr, 25
	.set MIOpenActiveBwd2DLite.private_seg_size, 0
	.set MIOpenActiveBwd2DLite.uses_vcc, 1
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
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveFwdLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     7
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
    .sgpr_count:     24
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveFwd2DLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     8
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
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveBwdLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     10
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
    .sgpr_count:     31
    .sgpr_spill_count: 0
    .symbol:         MIOpenActiveBwd2DLite.kd
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
