	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	scalar_ops
	.globl	scalar_ops
	.p2align	8
	.type	scalar_ops,@function
scalar_ops:
	s_load_dword s3, s[0:1], 0x28
	s_mov_b32 s2, 3
.LBB0_1:
	s_mul_i32 s2, s2, s2
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s3, -1
	s_add_i32 s2, s2, 17
	s_cmp_lg_u32 s3, 0
	s_cbranch_scc1 .LBB0_1
	s_load_dwordx8 s[4:11], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x20
	v_lshlrev_b32_e32 v3, 5, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	s_mov_b32 s3, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cbranch_scc0 .Lscalar_nonzero_0
	s_mov_b32 s3, 1
.Lscalar_nonzero_0:
	;;#ASMEND
	s_sub_i32 s12, 0, s7
	s_mul_hi_i32 s7, s6, s7
	s_mul_hi_i32 s13, s6, s12
	s_max_i32 s6, s6, s12
	v_mov_b32_e32 v0, s7
	v_mov_b32_e32 v2, s6
	s_or_b64 s[6:7], s[10:11], s[8:9]
	s_cmp_eq_u64 s[6:7], s[0:1]
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_eq_u64 s[8:9], s[10:11]
	v_mov_b32_e32 v1, s13
	s_cselect_b64 s[6:7], -1, 0
	s_add_i32 s3, s3, s2
	global_store_dwordx3 v3, v[0:2], s[4:5]
	s_nop 1
	v_cndmask_b32_e64 v1, 0, 1, s[6:7]
	v_cndmask_b32_e64 v0, 0, 1, s[0:1]
	v_mov_b32_e32 v2, s3
	global_store_dwordx3 v3, v[0:2], s[4:5] offset:12
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel scalar_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 44
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 14
		.amdhsa_accum_offset 4
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
	.size	scalar_ops, .Lfunc_end0-scalar_ops

	.set scalar_ops.num_vgpr, 4
	.set scalar_ops.num_agpr, 0
	.set scalar_ops.numbered_sgpr, 14
	.set scalar_ops.private_seg_size, 0
	.set scalar_ops.uses_vcc, 0
	.set scalar_ops.uses_flat_scratch, 0
	.set scalar_ops.has_dyn_sized_stack, 0
	.set scalar_ops.has_recursion, 0
	.set scalar_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_scalar_ops
	.globl	__clang_ocl_kern_imp_scalar_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_scalar_ops,@function
__clang_ocl_kern_imp_scalar_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_mov_b32 s2, 3
	s_mov_b64 s[0:1], 0
.LBB1_1:
	s_mul_i32 s2, s2, s2
	v_add_u32_e32 v10, -1, v10
	s_add_i32 s2, s2, 17
	v_cmp_eq_u32_e32 vcc, 0, v10
	s_or_b64 s[0:1], vcc, s[0:1]
	v_mov_b32_e32 v11, s2
	s_andn2_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB1_1
	s_or_b64 exec, exec, s[0:1]
	v_and_b32_e32 v10, 0x3ff, v31
	v_lshlrev_b32_e32 v12, 5, v10
	v_mov_b32_e32 v13, 0
	v_sub_u32_e32 v10, 0, v3
	v_lshl_add_u64 v[12:13], v[0:1], 0, v[12:13]
	v_mul_hi_i32 v0, v2, v3
	v_mul_hi_i32 v1, v2, v10
	v_max_i32_e32 v2, v2, v10
	v_readfirstlane_b32 s1, v5
	v_readfirstlane_b32 s0, v4
	;;#ASMSTART
	s_mov_b32 s2, 0
	s_cmp_eq_u64 s[0:1], 0
	s_cbranch_scc0 .Lscalar_nonzero_1
	s_mov_b32 s2, 1
.Lscalar_nonzero_1:
	;;#ASMEND
	global_store_dwordx3 v[12:13], v[0:2], off
	s_nop 1
	v_or_b32_e32 v1, v7, v5
	v_or_b32_e32 v0, v6, v4
	v_cmp_eq_u64_e32 vcc, v[0:1], v[8:9]
	v_add_u32_e32 v2, s2, v11
	s_nop 0
	v_cndmask_b32_e64 v0, 0, 1, vcc
	v_cmp_eq_u64_e32 vcc, v[4:5], v[6:7]
	s_nop 1
	v_cndmask_b32_e64 v1, 0, 1, vcc
	global_store_dwordx3 v[12:13], v[0:2], off offset:12
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_scalar_ops, .Lfunc_end1-__clang_ocl_kern_imp_scalar_ops

	.set __clang_ocl_kern_imp_scalar_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_scalar_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_scalar_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_scalar_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_scalar_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_scalar_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_scalar_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_scalar_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_scalar_ops.has_indirect_call, 0
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
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         16
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         24
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         32
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 44
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           scalar_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         scalar_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
