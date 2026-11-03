	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	symbolic_shift
	.globl	symbolic_shift
	.p2align	8
	.type	symbolic_shift,@function
symbolic_shift:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_lshrrev_b32_e32 v1, 16, v1
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel symbolic_shift
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
	.size	symbolic_shift, .Lfunc_end0-symbolic_shift

	.set symbolic_shift.num_vgpr, 2
	.set symbolic_shift.num_agpr, 0
	.set symbolic_shift.numbered_sgpr, 4
	.set symbolic_shift.private_seg_size, 0
	.set symbolic_shift.uses_vcc, 0
	.set symbolic_shift.uses_flat_scratch, 0
	.set symbolic_shift.has_dyn_sized_stack, 0
	.set symbolic_shift.has_recursion, 0
	.set symbolic_shift.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_symbolic_shift
	.globl	__clang_ocl_kern_imp_symbolic_shift
	.p2align	2
	.type	__clang_ocl_kern_imp_symbolic_shift,@function
__clang_ocl_kern_imp_symbolic_shift:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_lshrrev_b32_e32 v6, 16, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_symbolic_shift, .Lfunc_end1-__clang_ocl_kern_imp_symbolic_shift

	.set __clang_ocl_kern_imp_symbolic_shift.num_vgpr, 32
	.set __clang_ocl_kern_imp_symbolic_shift.num_agpr, 0
	.set __clang_ocl_kern_imp_symbolic_shift.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_symbolic_shift.private_seg_size, 0
	.set __clang_ocl_kern_imp_symbolic_shift.uses_vcc, 0
	.set __clang_ocl_kern_imp_symbolic_shift.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_symbolic_shift.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_symbolic_shift.has_recursion, 0
	.set __clang_ocl_kern_imp_symbolic_shift.has_indirect_call, 0
	.protected	symbolic_negation
	.globl	symbolic_negation
	.p2align	8
	.type	symbolic_negation,@function
symbolic_negation:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_xor_b32_e32 v1, 0x80000000, v1
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel symbolic_negation
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end2:
	.size	symbolic_negation, .Lfunc_end2-symbolic_negation

	.set symbolic_negation.num_vgpr, 2
	.set symbolic_negation.num_agpr, 0
	.set symbolic_negation.numbered_sgpr, 4
	.set symbolic_negation.private_seg_size, 0
	.set symbolic_negation.uses_vcc, 0
	.set symbolic_negation.uses_flat_scratch, 0
	.set symbolic_negation.has_dyn_sized_stack, 0
	.set symbolic_negation.has_recursion, 0
	.set symbolic_negation.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_symbolic_negation
	.globl	__clang_ocl_kern_imp_symbolic_negation
	.p2align	2
	.type	__clang_ocl_kern_imp_symbolic_negation,@function
__clang_ocl_kern_imp_symbolic_negation:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_xor_b32_e32 v6, 0x80000000, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end3:
	.size	__clang_ocl_kern_imp_symbolic_negation, .Lfunc_end3-__clang_ocl_kern_imp_symbolic_negation

	.set __clang_ocl_kern_imp_symbolic_negation.num_vgpr, 32
	.set __clang_ocl_kern_imp_symbolic_negation.num_agpr, 0
	.set __clang_ocl_kern_imp_symbolic_negation.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_symbolic_negation.private_seg_size, 0
	.set __clang_ocl_kern_imp_symbolic_negation.uses_vcc, 0
	.set __clang_ocl_kern_imp_symbolic_negation.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_symbolic_negation.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_symbolic_negation.has_recursion, 0
	.set __clang_ocl_kern_imp_symbolic_negation.has_indirect_call, 0
	.protected	symbolic_add
	.globl	symbolic_add
	.p2align	8
	.type	symbolic_add,@function
symbolic_add:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_add_u32_e32 v1, 1, v1
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel symbolic_add
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end4:
	.size	symbolic_add, .Lfunc_end4-symbolic_add

	.set symbolic_add.num_vgpr, 2
	.set symbolic_add.num_agpr, 0
	.set symbolic_add.numbered_sgpr, 4
	.set symbolic_add.private_seg_size, 0
	.set symbolic_add.uses_vcc, 0
	.set symbolic_add.uses_flat_scratch, 0
	.set symbolic_add.has_dyn_sized_stack, 0
	.set symbolic_add.has_recursion, 0
	.set symbolic_add.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_symbolic_add
	.globl	__clang_ocl_kern_imp_symbolic_add
	.p2align	2
	.type	__clang_ocl_kern_imp_symbolic_add,@function
__clang_ocl_kern_imp_symbolic_add:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_u32_e32 v6, 1, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end5:
	.size	__clang_ocl_kern_imp_symbolic_add, .Lfunc_end5-__clang_ocl_kern_imp_symbolic_add

	.set __clang_ocl_kern_imp_symbolic_add.num_vgpr, 32
	.set __clang_ocl_kern_imp_symbolic_add.num_agpr, 0
	.set __clang_ocl_kern_imp_symbolic_add.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_symbolic_add.private_seg_size, 0
	.set __clang_ocl_kern_imp_symbolic_add.uses_vcc, 0
	.set __clang_ocl_kern_imp_symbolic_add.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_symbolic_add.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_symbolic_add.has_recursion, 0
	.set __clang_ocl_kern_imp_symbolic_add.has_indirect_call, 0
	.protected	divergent_store
	.globl	divergent_store
	.p2align	8
	.type	divergent_store,@function
divergent_store:
	v_and_b32_e32 v1, 1, v0
	v_cmp_eq_u32_e32 vcc, 1, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB6_2
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	global_store_dword v0, v1, s[2:3]
.LBB6_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel divergent_store
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end6:
	.size	divergent_store, .Lfunc_end6-divergent_store

	.set divergent_store.num_vgpr, 2
	.set divergent_store.num_agpr, 0
	.set divergent_store.numbered_sgpr, 4
	.set divergent_store.private_seg_size, 0
	.set divergent_store.uses_vcc, 1
	.set divergent_store.uses_flat_scratch, 0
	.set divergent_store.has_dyn_sized_stack, 0
	.set divergent_store.has_recursion, 0
	.set divergent_store.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_divergent_store
	.globl	__clang_ocl_kern_imp_divergent_store
	.p2align	2
	.type	__clang_ocl_kern_imp_divergent_store,@function
__clang_ocl_kern_imp_divergent_store:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_and_b32_e32 v5, 1, v4
	v_cmp_eq_u32_e32 vcc, 1, v5
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB7_2
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v6, v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt vmcnt(0)
	global_store_dword v[0:1], v6, off
.LBB7_2:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end7:
	.size	__clang_ocl_kern_imp_divergent_store, .Lfunc_end7-__clang_ocl_kern_imp_divergent_store

	.set __clang_ocl_kern_imp_divergent_store.num_vgpr, 32
	.set __clang_ocl_kern_imp_divergent_store.num_agpr, 0
	.set __clang_ocl_kern_imp_divergent_store.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_divergent_store.private_seg_size, 0
	.set __clang_ocl_kern_imp_divergent_store.uses_vcc, 1
	.set __clang_ocl_kern_imp_divergent_store.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_divergent_store.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_divergent_store.has_recursion, 0
	.set __clang_ocl_kern_imp_divergent_store.has_indirect_call, 0
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
        .offset:         8
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           symbolic_shift
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         symbolic_shift.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           symbolic_negation
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         symbolic_negation.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           symbolic_add
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         symbolic_add.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           divergent_store
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         divergent_store.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
