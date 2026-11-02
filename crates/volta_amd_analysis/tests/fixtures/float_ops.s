	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	float_ops
	.globl	float_ops
	.p2align	8
	.type	float_ops,@function
float_ops:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshlrev_b32_e32 v21, 7, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v7, v1, s[4:5]
	global_load_dword v15, v1, s[6:7]
	s_waitcnt vmcnt(1)
	v_sqrt_f32_e32 v2, v7
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, v7, v15
	v_mul_f32_e32 v6, v15, v7
	v_rcp_f32_e32 v22, v15
	v_cndmask_b32_e32 v8, 2.0, v7, vcc
	v_cmp_lt_f32_e32 vcc, v15, v7
	v_rsq_f32_e32 v3, v7
	v_rcp_f32_e32 v14, v7
	v_cndmask_b32_e32 v9, v6, v7, vcc
	v_cmp_le_f32_e32 vcc, v15, v7
	v_exp_f32_e32 v12, v7
	v_log_f32_e32 v13, v7
	v_cndmask_b32_e32 v11, v6, v7, vcc
	v_cmp_le_f32_e32 vcc, v7, v15
	v_min_f32_e32 v16, v7, v15
	v_max_f32_e32 v17, v7, v15
	v_fma_f32 v18, v7, v15, v7
	v_cndmask_b32_e32 v10, v6, v7, vcc
	v_cmp_eq_f32_e32 vcc, v7, v15
	v_xor_b32_e32 v0, 0x80000000, v7
	v_and_b32_e32 v1, 0x7fffffff, v7
	global_store_dwordx3 v21, v[16:18], s[0:1] offset:44
	v_sub_f32_e32 v5, v7, v15
	v_add_f32_e32 v4, v7, v15
	v_cndmask_b32_e32 v18, v6, v7, vcc
	v_cmp_lg_f32_e32 vcc, v7, v15
	v_or_b32_e32 v20, 0x80000000, v7
	global_store_dwordx4 v21, v[8:11], s[0:1] offset:56
	v_cndmask_b32_e32 v19, v6, v7, vcc
	v_mul_f32_e32 v7, v22, v7
	global_store_dwordx4 v21, v[0:3], s[0:1]
	global_store_dwordx3 v21, v[12:14], s[0:1] offset:16
	global_store_dwordx4 v21, v[4:7], s[0:1] offset:28
	global_store_dwordx3 v21, v[18:20], s[0:1] offset:72
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel float_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 24
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
		.amdhsa_next_free_sgpr 8
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
	.size	float_ops, .Lfunc_end0-float_ops

	.set float_ops.num_vgpr, 23
	.set float_ops.num_agpr, 0
	.set float_ops.numbered_sgpr, 8
	.set float_ops.private_seg_size, 0
	.set float_ops.uses_vcc, 1
	.set float_ops.uses_flat_scratch, 0
	.set float_ops.has_dyn_sized_stack, 0
	.set float_ops.has_recursion, 0
	.set float_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_float_ops
	.globl	__clang_ocl_kern_imp_float_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_float_ops,@function
__clang_ocl_kern_imp_float_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v8, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v8
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	global_load_dword v15, v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[6:7]
	global_load_dword v19, v[0:1], off
	v_lshlrev_b32_e32 v6, 7, v8
	v_lshl_add_u64 v[22:23], v[4:5], 0, v[6:7]
	s_waitcnt vmcnt(1)
	v_sqrt_f32_e32 v2, v15
	v_rsq_f32_e32 v3, v15
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, v15, v19
	v_mul_f32_e32 v6, v19, v15
	v_rcp_f32_e32 v7, v19
	v_cndmask_b32_e32 v8, 2.0, v15, vcc
	v_cmp_lt_f32_e32 vcc, v19, v15
	v_rcp_f32_e32 v14, v15
	v_exp_f32_e32 v12, v15
	v_cndmask_b32_e32 v9, v6, v15, vcc
	v_cmp_le_f32_e32 vcc, v19, v15
	v_log_f32_e32 v13, v15
	v_min_f32_e32 v16, v15, v19
	v_cndmask_b32_e32 v11, v6, v15, vcc
	v_cmp_le_f32_e32 vcc, v15, v19
	v_max_f32_e32 v17, v15, v19
	v_fma_f32 v18, v15, v19, v15
	v_cndmask_b32_e32 v10, v6, v15, vcc
	v_cmp_eq_f32_e32 vcc, v15, v19
	v_xor_b32_e32 v0, 0x80000000, v15
	v_and_b32_e32 v1, 0x7fffffff, v15
	global_store_dwordx3 v[22:23], v[16:18], off offset:44
	v_sub_f32_e32 v5, v15, v19
	v_add_f32_e32 v4, v15, v19
	v_cndmask_b32_e32 v18, v6, v15, vcc
	v_cmp_lg_f32_e32 vcc, v15, v19
	v_or_b32_e32 v20, 0x80000000, v15
	global_store_dwordx4 v[22:23], v[8:11], off offset:56
	v_cndmask_b32_e32 v19, v6, v15, vcc
	v_mul_f32_e32 v7, v7, v15
	global_store_dwordx4 v[22:23], v[0:3], off
	global_store_dwordx3 v[22:23], v[12:14], off offset:16
	global_store_dwordx4 v[22:23], v[4:7], off offset:28
	global_store_dwordx3 v[22:23], v[18:20], off offset:72
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_float_ops, .Lfunc_end1-__clang_ocl_kern_imp_float_ops

	.set __clang_ocl_kern_imp_float_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_float_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_float_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_float_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_float_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_float_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_float_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_float_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_float_ops.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 32
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 32
	.text
	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           float_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         float_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     23
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
