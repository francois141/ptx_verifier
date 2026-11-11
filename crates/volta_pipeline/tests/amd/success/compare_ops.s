	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	compare_ops
	.globl	compare_ops
	.p2align	8
	.type	compare_ops,@function
compare_ops:
	s_load_dwordx8 s[0:7], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mul_u32_u24_e32 v0, 12, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[2:3]
	global_load_dword v1, v1, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cmp_lt_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5]
	;;#ASMSTART
	v_cmp_eq_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:4
	;;#ASMSTART
	v_cmp_le_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:8
	;;#ASMSTART
	v_cmp_gt_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:12
	;;#ASMSTART
	v_cmp_lg_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:16
	;;#ASMSTART
	v_cmp_ge_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:20
	;;#ASMSTART
	v_cmp_nge_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:24
	;;#ASMSTART
	v_cmp_nlg_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:28
	;;#ASMSTART
	v_cmp_ngt_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:32
	;;#ASMSTART
	v_cmp_nle_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:36
	;;#ASMSTART
	v_cmp_neq_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:40
	;;#ASMSTART
	v_cmp_nlt_f32_e64 s[0:1], v1, v2
	v_cndmask_b32_e64 v3, v1, v2, s[0:1]
	;;#ASMEND
	global_store_dword v0, v3, s[4:5] offset:44
	;;#ASMSTART
	v_cmp_lt_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7]
	;;#ASMSTART
	v_cmp_eq_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:4
	;;#ASMSTART
	v_cmp_le_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:8
	;;#ASMSTART
	v_cmp_gt_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:12
	;;#ASMSTART
	v_cmp_lg_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:16
	;;#ASMSTART
	v_cmp_ge_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:20
	;;#ASMSTART
	v_cmp_nge_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:24
	;;#ASMSTART
	v_cmp_nlg_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:28
	;;#ASMSTART
	v_cmp_ngt_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:32
	;;#ASMSTART
	v_cmp_nle_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:36
	;;#ASMSTART
	v_cmp_neq_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:40
	;;#ASMSTART
	v_cmp_nlt_f32_e32 vcc, v1, v2
	v_cndmask_b32_e32 v3, v1, v2, vcc
	;;#ASMEND
	global_store_dword v0, v3, s[6:7] offset:44
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel compare_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 32
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
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 4
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
	.size	compare_ops, .Lfunc_end0-compare_ops

	.set compare_ops.num_vgpr, 4
	.set compare_ops.num_agpr, 0
	.set compare_ops.numbered_sgpr, 8
	.set compare_ops.private_seg_size, 0
	.set compare_ops.uses_vcc, 1
	.set compare_ops.uses_flat_scratch, 0
	.set compare_ops.has_dyn_sized_stack, 0
	.set compare_ops.has_recursion, 0
	.set compare_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_compare_ops
	.globl	__clang_ocl_kern_imp_compare_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_compare_ops,@function
__clang_ocl_kern_imp_compare_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v10, 0x3ff, v31
	v_lshlrev_b32_e32 v8, 2, v10
	v_mov_b32_e32 v9, 0
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[8:9]
	global_load_dword v11, v[2:3], off
	global_load_dword v12, v[0:1], off
	v_mul_u32_u24_e32 v0, 12, v10
	v_lshlrev_b32_e32 v8, 2, v0
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[8:9]
	v_lshl_add_u64 v[2:3], v[6:7], 0, v[8:9]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cmp_lt_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off
	;;#ASMSTART
	v_cmp_eq_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:4
	;;#ASMSTART
	v_cmp_le_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:8
	;;#ASMSTART
	v_cmp_gt_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:12
	;;#ASMSTART
	v_cmp_lg_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:16
	;;#ASMSTART
	v_cmp_ge_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:20
	;;#ASMSTART
	v_cmp_nge_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:24
	;;#ASMSTART
	v_cmp_nlg_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:28
	;;#ASMSTART
	v_cmp_ngt_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:32
	;;#ASMSTART
	v_cmp_nle_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:36
	;;#ASMSTART
	v_cmp_neq_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:40
	;;#ASMSTART
	v_cmp_nlt_f32_e64 s[0:1], v12, v11
	v_cndmask_b32_e64 v4, v12, v11, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:44
	;;#ASMSTART
	v_cmp_lt_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off
	;;#ASMSTART
	v_cmp_eq_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:4
	;;#ASMSTART
	v_cmp_le_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:8
	;;#ASMSTART
	v_cmp_gt_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:12
	;;#ASMSTART
	v_cmp_lg_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:16
	;;#ASMSTART
	v_cmp_ge_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:20
	;;#ASMSTART
	v_cmp_nge_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:24
	;;#ASMSTART
	v_cmp_nlg_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:28
	;;#ASMSTART
	v_cmp_ngt_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:32
	;;#ASMSTART
	v_cmp_nle_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:36
	;;#ASMSTART
	v_cmp_neq_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:40
	;;#ASMSTART
	v_cmp_nlt_f32_e32 vcc, v12, v11
	v_cndmask_b32_e32 v0, v12, v11, vcc
	;;#ASMEND
	global_store_dword v[2:3], v0, off offset:44
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_compare_ops, .Lfunc_end1-__clang_ocl_kern_imp_compare_ops

	.set __clang_ocl_kern_imp_compare_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_compare_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_compare_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_compare_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_compare_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_compare_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_compare_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_compare_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_compare_ops.has_indirect_call, 0
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
      - .address_space:  global
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 32
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           compare_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         compare_ops.kd
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
