	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	compare64_ops
	.globl	compare64_ops
	.p2align	8
	.type	compare64_ops,@function
compare64_ops:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v6, 7, v0
	v_subrev_u32_e32 v0, 32, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_mov_b64_e32 v[2:3], 0
	;;#ASMSTART
	v_cmp_lt_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_lt_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	global_store_dwordx2 v6, v[4:5], s[0:1]
	;;#ASMSTART
	v_cmp_eq_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_eq_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:8
	;;#ASMSTART
	v_cmp_le_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_le_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:16
	;;#ASMSTART
	v_cmp_gt_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_gt_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:24
	;;#ASMSTART
	v_cmp_ne_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_ne_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:32
	;;#ASMSTART
	v_cmp_ge_i64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_ge_i64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:40
	;;#ASMSTART
	v_cmp_lt_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_lt_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:48
	;;#ASMSTART
	v_cmp_eq_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_eq_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:56
	;;#ASMSTART
	v_cmp_le_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_le_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:64
	;;#ASMSTART
	v_cmp_gt_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_gt_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:72
	;;#ASMSTART
	v_cmp_ne_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_ne_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:80
	;;#ASMSTART
	v_cmp_ge_u64_e32 vcc, v[2:3], v[0:1]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	v_cmp_ge_u64_e64 s[2:3], v[0:1], 0
	v_cndmask_b32_e64 v5, 0, 1, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v6, v[4:5], s[0:1] offset:88
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], v[0:1]
	;;#ASMEND
	global_store_dwordx2 v6, v[0:1], s[0:1] offset:96
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel compare64_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_next_free_sgpr 4
		.amdhsa_accum_offset 8
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
	.size	compare64_ops, .Lfunc_end0-compare64_ops

	.set compare64_ops.num_vgpr, 7
	.set compare64_ops.num_agpr, 0
	.set compare64_ops.numbered_sgpr, 4
	.set compare64_ops.private_seg_size, 0
	.set compare64_ops.uses_vcc, 1
	.set compare64_ops.uses_flat_scratch, 0
	.set compare64_ops.has_dyn_sized_stack, 0
	.set compare64_ops.has_recursion, 0
	.set compare64_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_compare64_ops
	.globl	__clang_ocl_kern_imp_compare64_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_compare64_ops,@function
__clang_ocl_kern_imp_compare64_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 7, v4
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_subrev_u32_e32 v2, 32, v4
	v_ashrrev_i32_e32 v3, 31, v2
	v_mov_b64_e32 v[4:5], 0
	;;#ASMSTART
	v_cmp_lt_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_lt_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off
	;;#ASMSTART
	v_cmp_eq_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_eq_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:8
	;;#ASMSTART
	v_cmp_le_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_le_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:16
	;;#ASMSTART
	v_cmp_gt_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_gt_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:24
	;;#ASMSTART
	v_cmp_ne_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_ne_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:32
	;;#ASMSTART
	v_cmp_ge_i64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_ge_i64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:40
	;;#ASMSTART
	v_cmp_lt_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_lt_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:48
	;;#ASMSTART
	v_cmp_eq_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_eq_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:56
	;;#ASMSTART
	v_cmp_le_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_le_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:64
	;;#ASMSTART
	v_cmp_gt_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_gt_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:72
	;;#ASMSTART
	v_cmp_ne_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_ne_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:80
	;;#ASMSTART
	v_cmp_ge_u64_e32 vcc, v[4:5], v[2:3]
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_cmp_ge_u64_e64 s[0:1], v[2:3], 0
	v_cndmask_b32_e64 v7, 0, 1, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[6:7], off offset:88
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], v[2:3]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:96
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_compare64_ops, .Lfunc_end1-__clang_ocl_kern_imp_compare64_ops

	.set __clang_ocl_kern_imp_compare64_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_compare64_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_compare64_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_compare64_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_compare64_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_compare64_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_compare64_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_compare64_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_compare64_ops.has_indirect_call, 0
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           compare64_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         compare64_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     7
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
