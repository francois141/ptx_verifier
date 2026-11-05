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
	.protected	symbolic_select
	.globl	symbolic_select
	.p2align	8
	.type	symbolic_select,@function
symbolic_select:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e64 v1, 2.0, 1.0, vcc
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel symbolic_select
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
	.size	symbolic_select, .Lfunc_end6-symbolic_select

	.set symbolic_select.num_vgpr, 2
	.set symbolic_select.num_agpr, 0
	.set symbolic_select.numbered_sgpr, 4
	.set symbolic_select.private_seg_size, 0
	.set symbolic_select.uses_vcc, 1
	.set symbolic_select.uses_flat_scratch, 0
	.set symbolic_select.has_dyn_sized_stack, 0
	.set symbolic_select.has_recursion, 0
	.set symbolic_select.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_symbolic_select
	.globl	__clang_ocl_kern_imp_symbolic_select
	.p2align	2
	.type	__clang_ocl_kern_imp_symbolic_select,@function
__clang_ocl_kern_imp_symbolic_select:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, 0, v0
	s_nop 1
	v_cndmask_b32_e64 v6, 2.0, 1.0, vcc
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end7:
	.size	__clang_ocl_kern_imp_symbolic_select, .Lfunc_end7-__clang_ocl_kern_imp_symbolic_select

	.set __clang_ocl_kern_imp_symbolic_select.num_vgpr, 32
	.set __clang_ocl_kern_imp_symbolic_select.num_agpr, 0
	.set __clang_ocl_kern_imp_symbolic_select.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_symbolic_select.private_seg_size, 0
	.set __clang_ocl_kern_imp_symbolic_select.uses_vcc, 1
	.set __clang_ocl_kern_imp_symbolic_select.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_symbolic_select.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_symbolic_select.has_recursion, 0
	.set __clang_ocl_kern_imp_symbolic_select.has_indirect_call, 0
	.protected	divergent_store
	.globl	divergent_store
	.p2align	8
	.type	divergent_store,@function
divergent_store:
	v_and_b32_e32 v1, 1, v0
	v_cmp_eq_u32_e32 vcc, 1, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB8_2
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	global_store_dword v0, v1, s[2:3]
.LBB8_2:
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
.Lfunc_end8:
	.size	divergent_store, .Lfunc_end8-divergent_store

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
	s_cbranch_execz .LBB9_2
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v6, v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt vmcnt(0)
	global_store_dword v[0:1], v6, off
.LBB9_2:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end9:
	.size	__clang_ocl_kern_imp_divergent_store, .Lfunc_end9-__clang_ocl_kern_imp_divergent_store

	.set __clang_ocl_kern_imp_divergent_store.num_vgpr, 32
	.set __clang_ocl_kern_imp_divergent_store.num_agpr, 0
	.set __clang_ocl_kern_imp_divergent_store.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_divergent_store.private_seg_size, 0
	.set __clang_ocl_kern_imp_divergent_store.uses_vcc, 1
	.set __clang_ocl_kern_imp_divergent_store.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_divergent_store.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_divergent_store.has_recursion, 0
	.set __clang_ocl_kern_imp_divergent_store.has_indirect_call, 0
	.protected	f64_half_as_word
	.globl	f64_half_as_word
	.p2align	8
	.type	f64_half_as_word,@function
f64_half_as_word:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v1
	v_mov_b32_e32 v4, v2
	;;#ASMEND
	global_store_dword v0, v4, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel f64_half_as_word
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
		.amdhsa_next_free_vgpr 5
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end10:
	.size	f64_half_as_word, .Lfunc_end10-f64_half_as_word

	.set f64_half_as_word.num_vgpr, 5
	.set f64_half_as_word.num_agpr, 0
	.set f64_half_as_word.numbered_sgpr, 4
	.set f64_half_as_word.private_seg_size, 0
	.set f64_half_as_word.uses_vcc, 0
	.set f64_half_as_word.uses_flat_scratch, 0
	.set f64_half_as_word.has_dyn_sized_stack, 0
	.set f64_half_as_word.has_recursion, 0
	.set f64_half_as_word.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_f64_half_as_word
	.globl	__clang_ocl_kern_imp_f64_half_as_word
	.p2align	2
	.type	__clang_ocl_kern_imp_f64_half_as_word,@function
__clang_ocl_kern_imp_f64_half_as_word:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_mov_b32_e32 v4, v2
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v2
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	v_mov_b32_e32 v5, v3
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v0
	v_mov_b32_e32 v8, v2
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[6:7]
	global_store_dword v[0:1], v8, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end11:
	.size	__clang_ocl_kern_imp_f64_half_as_word, .Lfunc_end11-__clang_ocl_kern_imp_f64_half_as_word

	.set __clang_ocl_kern_imp_f64_half_as_word.num_vgpr, 32
	.set __clang_ocl_kern_imp_f64_half_as_word.num_agpr, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_f64_half_as_word.private_seg_size, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.uses_vcc, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.has_recursion, 0
	.set __clang_ocl_kern_imp_f64_half_as_word.has_indirect_call, 0
	.protected	f64_overwritten_half
	.globl	f64_overwritten_half
	.p2align	8
	.type	f64_overwritten_half,@function
f64_overwritten_half:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v1
	v_mov_b32_e32 v3, v1
	v_cvt_f32_f64_e32 v4, v[2:3]
	;;#ASMEND
	global_store_dword v0, v4, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel f64_overwritten_half
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
		.amdhsa_next_free_vgpr 5
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end12:
	.size	f64_overwritten_half, .Lfunc_end12-f64_overwritten_half

	.set f64_overwritten_half.num_vgpr, 5
	.set f64_overwritten_half.num_agpr, 0
	.set f64_overwritten_half.numbered_sgpr, 4
	.set f64_overwritten_half.private_seg_size, 0
	.set f64_overwritten_half.uses_vcc, 0
	.set f64_overwritten_half.uses_flat_scratch, 0
	.set f64_overwritten_half.has_dyn_sized_stack, 0
	.set f64_overwritten_half.has_recursion, 0
	.set f64_overwritten_half.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_f64_overwritten_half
	.globl	__clang_ocl_kern_imp_f64_overwritten_half
	.p2align	2
	.type	__clang_ocl_kern_imp_f64_overwritten_half,@function
__clang_ocl_kern_imp_f64_overwritten_half:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_mov_b32_e32 v4, v2
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v2
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	v_mov_b32_e32 v5, v3
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v0
	v_mov_b32_e32 v3, v0
	v_cvt_f32_f64_e32 v8, v[2:3]
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[6:7]
	global_store_dword v[0:1], v8, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end13:
	.size	__clang_ocl_kern_imp_f64_overwritten_half, .Lfunc_end13-__clang_ocl_kern_imp_f64_overwritten_half

	.set __clang_ocl_kern_imp_f64_overwritten_half.num_vgpr, 32
	.set __clang_ocl_kern_imp_f64_overwritten_half.num_agpr, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_f64_overwritten_half.private_seg_size, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.uses_vcc, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.has_recursion, 0
	.set __clang_ocl_kern_imp_f64_overwritten_half.has_indirect_call, 0
	.protected	f64_from_symbolic_words
	.globl	f64_from_symbolic_words
	.p2align	8
	.type	f64_from_symbolic_words,@function
f64_from_symbolic_words:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_mov_b32_e32 v2, v1
	v_mov_b32_e32 v3, v1
	v_cvt_f32_f64_e32 v4, v[2:3]
	;;#ASMEND
	global_store_dword v0, v4, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel f64_from_symbolic_words
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
		.amdhsa_next_free_vgpr 5
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end14:
	.size	f64_from_symbolic_words, .Lfunc_end14-f64_from_symbolic_words

	.set f64_from_symbolic_words.num_vgpr, 5
	.set f64_from_symbolic_words.num_agpr, 0
	.set f64_from_symbolic_words.numbered_sgpr, 4
	.set f64_from_symbolic_words.private_seg_size, 0
	.set f64_from_symbolic_words.uses_vcc, 0
	.set f64_from_symbolic_words.uses_flat_scratch, 0
	.set f64_from_symbolic_words.has_dyn_sized_stack, 0
	.set f64_from_symbolic_words.has_recursion, 0
	.set f64_from_symbolic_words.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_f64_from_symbolic_words
	.globl	__clang_ocl_kern_imp_f64_from_symbolic_words
	.p2align	2
	.type	__clang_ocl_kern_imp_f64_from_symbolic_words,@function
__clang_ocl_kern_imp_f64_from_symbolic_words:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_mov_b32_e32 v4, v2
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v2
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	v_mov_b32_e32 v5, v3
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	v_cvt_f32_f64_e32 v8, v[2:3]
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[6:7]
	global_store_dword v[0:1], v8, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end15:
	.size	__clang_ocl_kern_imp_f64_from_symbolic_words, .Lfunc_end15-__clang_ocl_kern_imp_f64_from_symbolic_words

	.set __clang_ocl_kern_imp_f64_from_symbolic_words.num_vgpr, 32
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.num_agpr, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.private_seg_size, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.uses_vcc, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.has_recursion, 0
	.set __clang_ocl_kern_imp_f64_from_symbolic_words.has_indirect_call, 0
	.protected	f64_nan_constant
	.globl	f64_nan_constant
	.p2align	8
	.type	f64_nan_constant,@function
f64_nan_constant:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	;;#ASMSTART
	v_cvt_f32_f64_e32 v1, 0x7ff80000
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, v2, v1
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel f64_nan_constant
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
		.amdhsa_next_free_vgpr 3
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
.Lfunc_end16:
	.size	f64_nan_constant, .Lfunc_end16-f64_nan_constant

	.set f64_nan_constant.num_vgpr, 3
	.set f64_nan_constant.num_agpr, 0
	.set f64_nan_constant.numbered_sgpr, 4
	.set f64_nan_constant.private_seg_size, 0
	.set f64_nan_constant.uses_vcc, 0
	.set f64_nan_constant.uses_flat_scratch, 0
	.set f64_nan_constant.has_dyn_sized_stack, 0
	.set f64_nan_constant.has_recursion, 0
	.set f64_nan_constant.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_f64_nan_constant
	.globl	__clang_ocl_kern_imp_f64_nan_constant
	.p2align	2
	.type	__clang_ocl_kern_imp_f64_nan_constant,@function
__clang_ocl_kern_imp_f64_nan_constant:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	;;#ASMSTART
	v_cvt_f32_f64_e32 v6, 0x7ff80000
	;;#ASMEND
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v6, v0, v6
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end17:
	.size	__clang_ocl_kern_imp_f64_nan_constant, .Lfunc_end17-__clang_ocl_kern_imp_f64_nan_constant

	.set __clang_ocl_kern_imp_f64_nan_constant.num_vgpr, 32
	.set __clang_ocl_kern_imp_f64_nan_constant.num_agpr, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_f64_nan_constant.private_seg_size, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.uses_vcc, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.has_recursion, 0
	.set __clang_ocl_kern_imp_f64_nan_constant.has_indirect_call, 0
	.protected	symbolic_mask
	.globl	symbolic_mask
	.p2align	8
	.type	symbolic_mask,@function
symbolic_mask:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cmp_lt_f32_e64 s[0:1], v1, 1.0
	s_and_b64 s[0:1], s[0:1], -1
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v1, s0
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel symbolic_mask
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
.Lfunc_end18:
	.size	symbolic_mask, .Lfunc_end18-symbolic_mask

	.set symbolic_mask.num_vgpr, 2
	.set symbolic_mask.num_agpr, 0
	.set symbolic_mask.numbered_sgpr, 4
	.set symbolic_mask.private_seg_size, 0
	.set symbolic_mask.uses_vcc, 0
	.set symbolic_mask.uses_flat_scratch, 0
	.set symbolic_mask.has_dyn_sized_stack, 0
	.set symbolic_mask.has_recursion, 0
	.set symbolic_mask.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_symbolic_mask
	.globl	__clang_ocl_kern_imp_symbolic_mask
	.p2align	2
	.type	__clang_ocl_kern_imp_symbolic_mask,@function
__clang_ocl_kern_imp_symbolic_mask:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cmp_lt_f32_e64 s[0:1], v0, 1.0
	s_and_b64 s[0:1], s[0:1], -1
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	v_mov_b32_e32 v2, s0
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end19:
	.size	__clang_ocl_kern_imp_symbolic_mask, .Lfunc_end19-__clang_ocl_kern_imp_symbolic_mask

	.set __clang_ocl_kern_imp_symbolic_mask.num_vgpr, 32
	.set __clang_ocl_kern_imp_symbolic_mask.num_agpr, 0
	.set __clang_ocl_kern_imp_symbolic_mask.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_symbolic_mask.private_seg_size, 0
	.set __clang_ocl_kern_imp_symbolic_mask.uses_vcc, 0
	.set __clang_ocl_kern_imp_symbolic_mask.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_symbolic_mask.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_symbolic_mask.has_recursion, 0
	.set __clang_ocl_kern_imp_symbolic_mask.has_indirect_call, 0
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
    .name:           symbolic_select
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         symbolic_select.kd
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
    .name:           f64_half_as_word
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         f64_half_as_word.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
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
    .name:           f64_overwritten_half
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         f64_overwritten_half.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
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
    .name:           f64_from_symbolic_words
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         f64_from_symbolic_words.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
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
    .name:           f64_nan_constant
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         f64_nan_constant.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
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
    .name:           symbolic_mask
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         symbolic_mask.kd
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
