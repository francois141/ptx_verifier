	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	exchange
	.globl	exchange
	.p2align	8
	.type	exchange,@function
exchange:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mov_b32_e32 v3, 0x7f
	v_bitop3_b32 v0, v0, 64, v3 bitop3:0x6c
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel exchange
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
	.size	exchange, .Lfunc_end0-exchange

	.set exchange.num_vgpr, 4
	.set exchange.num_agpr, 0
	.set exchange.numbered_sgpr, 4
	.set exchange.private_seg_size, 0
	.set exchange.uses_vcc, 0
	.set exchange.uses_flat_scratch, 0
	.set exchange.has_dyn_sized_stack, 0
	.set exchange.has_recursion, 0
	.set exchange.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_exchange
	.globl	__clang_ocl_kern_imp_exchange
	.p2align	2
	.type	__clang_ocl_kern_imp_exchange,@function
__clang_ocl_kern_imp_exchange:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v6, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_exchange, .Lfunc_end1-__clang_ocl_kern_imp_exchange

	.set __clang_ocl_kern_imp_exchange.num_vgpr, 32
	.set __clang_ocl_kern_imp_exchange.num_agpr, 0
	.set __clang_ocl_kern_imp_exchange.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_exchange.private_seg_size, 0
	.set __clang_ocl_kern_imp_exchange.uses_vcc, 0
	.set __clang_ocl_kern_imp_exchange.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_exchange.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_exchange.has_recursion, 0
	.set __clang_ocl_kern_imp_exchange.has_indirect_call, 0
	.protected	two_rounds
	.globl	two_rounds
	.p2align	8
	.type	two_rounds,@function
two_rounds:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mov_b32_e32 v3, 0x7f
	v_bitop3_b32 v0, v0, 64, v3 bitop3:0x6c
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v2, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_add_f32_e32 v2, v2, v2
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel two_rounds
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
	.size	two_rounds, .Lfunc_end2-two_rounds

	.set two_rounds.num_vgpr, 4
	.set two_rounds.num_agpr, 0
	.set two_rounds.numbered_sgpr, 4
	.set two_rounds.private_seg_size, 0
	.set two_rounds.uses_vcc, 0
	.set two_rounds.uses_flat_scratch, 0
	.set two_rounds.has_dyn_sized_stack, 0
	.set two_rounds.has_recursion, 0
	.set two_rounds.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_two_rounds
	.globl	__clang_ocl_kern_imp_two_rounds
	.p2align	2
	.type	__clang_ocl_kern_imp_two_rounds,@function
__clang_ocl_kern_imp_two_rounds:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_add_f32_e32 v0, v0, v0
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v6, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end3:
	.size	__clang_ocl_kern_imp_two_rounds, .Lfunc_end3-__clang_ocl_kern_imp_two_rounds

	.set __clang_ocl_kern_imp_two_rounds.num_vgpr, 32
	.set __clang_ocl_kern_imp_two_rounds.num_agpr, 0
	.set __clang_ocl_kern_imp_two_rounds.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_two_rounds.private_seg_size, 0
	.set __clang_ocl_kern_imp_two_rounds.uses_vcc, 0
	.set __clang_ocl_kern_imp_two_rounds.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_two_rounds.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_two_rounds.has_recursion, 0
	.set __clang_ocl_kern_imp_two_rounds.has_indirect_call, 0
	.protected	no_barrier
	.globl	no_barrier
	.p2align	8
	.type	no_barrier,@function
no_barrier:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_and_b32_e32 v0, 63, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel no_barrier
		.amdhsa_group_segment_fixed_size 512
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
.Lfunc_end4:
	.size	no_barrier, .Lfunc_end4-no_barrier

	.set no_barrier.num_vgpr, 3
	.set no_barrier.num_agpr, 0
	.set no_barrier.numbered_sgpr, 4
	.set no_barrier.private_seg_size, 0
	.set no_barrier.uses_vcc, 0
	.set no_barrier.uses_flat_scratch, 0
	.set no_barrier.has_dyn_sized_stack, 0
	.set no_barrier.has_recursion, 0
	.set no_barrier.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_no_barrier
	.globl	__clang_ocl_kern_imp_no_barrier
	.p2align	2
	.type	__clang_ocl_kern_imp_no_barrier,@function
__clang_ocl_kern_imp_no_barrier:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v6, v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v6
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end5:
	.size	__clang_ocl_kern_imp_no_barrier, .Lfunc_end5-__clang_ocl_kern_imp_no_barrier

	.set __clang_ocl_kern_imp_no_barrier.num_vgpr, 32
	.set __clang_ocl_kern_imp_no_barrier.num_agpr, 0
	.set __clang_ocl_kern_imp_no_barrier.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_no_barrier.private_seg_size, 0
	.set __clang_ocl_kern_imp_no_barrier.uses_vcc, 0
	.set __clang_ocl_kern_imp_no_barrier.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_no_barrier.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_no_barrier.has_recursion, 0
	.set __clang_ocl_kern_imp_no_barrier.has_indirect_call, 0
	.protected	barrier_without_wait
	.globl	barrier_without_wait
	.p2align	8
	.type	barrier_without_wait,@function
barrier_without_wait:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mov_b32_e32 v3, 0x7f
	v_bitop3_b32 v0, v0, 64, v3 bitop3:0x6c
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	;;#ASMSTART
	s_barrier
	;;#ASMEND
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel barrier_without_wait
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
.Lfunc_end6:
	.size	barrier_without_wait, .Lfunc_end6-barrier_without_wait

	.set barrier_without_wait.num_vgpr, 4
	.set barrier_without_wait.num_agpr, 0
	.set barrier_without_wait.numbered_sgpr, 4
	.set barrier_without_wait.private_seg_size, 0
	.set barrier_without_wait.uses_vcc, 0
	.set barrier_without_wait.uses_flat_scratch, 0
	.set barrier_without_wait.has_dyn_sized_stack, 0
	.set barrier_without_wait.has_recursion, 0
	.set barrier_without_wait.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_barrier_without_wait
	.globl	__clang_ocl_kern_imp_barrier_without_wait
	.p2align	2
	.type	__clang_ocl_kern_imp_barrier_without_wait,@function
__clang_ocl_kern_imp_barrier_without_wait:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	;;#ASMSTART
	s_barrier
	;;#ASMEND
	ds_read_b32 v6, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end7:
	.size	__clang_ocl_kern_imp_barrier_without_wait, .Lfunc_end7-__clang_ocl_kern_imp_barrier_without_wait

	.set __clang_ocl_kern_imp_barrier_without_wait.num_vgpr, 32
	.set __clang_ocl_kern_imp_barrier_without_wait.num_agpr, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_barrier_without_wait.private_seg_size, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.uses_vcc, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.has_recursion, 0
	.set __clang_ocl_kern_imp_barrier_without_wait.has_indirect_call, 0
	.protected	overwrite_without_barrier
	.globl	overwrite_without_barrier
	.p2align	8
	.type	overwrite_without_barrier,@function
overwrite_without_barrier:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mov_b32_e32 v3, 0x7f
	v_bitop3_b32 v0, v0, 64, v3 bitop3:0x6c
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v2, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v2
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel overwrite_without_barrier
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
.Lfunc_end8:
	.size	overwrite_without_barrier, .Lfunc_end8-overwrite_without_barrier

	.set overwrite_without_barrier.num_vgpr, 4
	.set overwrite_without_barrier.num_agpr, 0
	.set overwrite_without_barrier.numbered_sgpr, 4
	.set overwrite_without_barrier.private_seg_size, 0
	.set overwrite_without_barrier.uses_vcc, 0
	.set overwrite_without_barrier.uses_flat_scratch, 0
	.set overwrite_without_barrier.has_dyn_sized_stack, 0
	.set overwrite_without_barrier.has_recursion, 0
	.set overwrite_without_barrier.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_overwrite_without_barrier
	.globl	__clang_ocl_kern_imp_overwrite_without_barrier
	.p2align	2
	.type	__clang_ocl_kern_imp_overwrite_without_barrier,@function
__clang_ocl_kern_imp_overwrite_without_barrier:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v0, v0
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v6, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end9:
	.size	__clang_ocl_kern_imp_overwrite_without_barrier, .Lfunc_end9-__clang_ocl_kern_imp_overwrite_without_barrier

	.set __clang_ocl_kern_imp_overwrite_without_barrier.num_vgpr, 32
	.set __clang_ocl_kern_imp_overwrite_without_barrier.num_agpr, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_overwrite_without_barrier.private_seg_size, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.uses_vcc, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.has_recursion, 0
	.set __clang_ocl_kern_imp_overwrite_without_barrier.has_indirect_call, 0
	.protected	read_pending_across_reuse_barrier
	.globl	read_pending_across_reuse_barrier
	.p2align	8
	.type	read_pending_across_reuse_barrier,@function
read_pending_across_reuse_barrier:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_xor_b32_e32 v0, 64, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v3, v0
s_barrier
ds_write_b32 v1, v2
s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dword v1, v3, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel read_pending_across_reuse_barrier
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
.Lfunc_end10:
	.size	read_pending_across_reuse_barrier, .Lfunc_end10-read_pending_across_reuse_barrier

	.set read_pending_across_reuse_barrier.num_vgpr, 4
	.set read_pending_across_reuse_barrier.num_agpr, 0
	.set read_pending_across_reuse_barrier.numbered_sgpr, 4
	.set read_pending_across_reuse_barrier.private_seg_size, 0
	.set read_pending_across_reuse_barrier.uses_vcc, 0
	.set read_pending_across_reuse_barrier.uses_flat_scratch, 0
	.set read_pending_across_reuse_barrier.has_dyn_sized_stack, 0
	.set read_pending_across_reuse_barrier.has_recursion, 0
	.set read_pending_across_reuse_barrier.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_read_pending_across_reuse_barrier
	.globl	__clang_ocl_kern_imp_read_pending_across_reuse_barrier
	.p2align	2
	.type	__clang_ocl_kern_imp_read_pending_across_reuse_barrier,@function
__clang_ocl_kern_imp_read_pending_across_reuse_barrier:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v6, v0
s_barrier
ds_write_b32 v0, v0
s_waitcnt lgkmcnt(0)
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end11:
	.size	__clang_ocl_kern_imp_read_pending_across_reuse_barrier, .Lfunc_end11-__clang_ocl_kern_imp_read_pending_across_reuse_barrier

	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.num_vgpr, 32
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.num_agpr, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.private_seg_size, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.uses_vcc, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.has_recursion, 0
	.set __clang_ocl_kern_imp_read_pending_across_reuse_barrier.has_indirect_call, 0
	.protected	read_wait_before_reuse_barrier
	.globl	read_wait_before_reuse_barrier
	.p2align	8
	.type	read_wait_before_reuse_barrier,@function
read_wait_before_reuse_barrier:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_xor_b32_e32 v0, 64, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v3, v0
s_waitcnt lgkmcnt(0)
s_barrier
ds_write_b32 v1, v2
s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dword v1, v3, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel read_wait_before_reuse_barrier
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 4
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
.Lfunc_end12:
	.size	read_wait_before_reuse_barrier, .Lfunc_end12-read_wait_before_reuse_barrier

	.set read_wait_before_reuse_barrier.num_vgpr, 4
	.set read_wait_before_reuse_barrier.num_agpr, 0
	.set read_wait_before_reuse_barrier.numbered_sgpr, 4
	.set read_wait_before_reuse_barrier.private_seg_size, 0
	.set read_wait_before_reuse_barrier.uses_vcc, 0
	.set read_wait_before_reuse_barrier.uses_flat_scratch, 0
	.set read_wait_before_reuse_barrier.has_dyn_sized_stack, 0
	.set read_wait_before_reuse_barrier.has_recursion, 0
	.set read_wait_before_reuse_barrier.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_read_wait_before_reuse_barrier
	.globl	__clang_ocl_kern_imp_read_wait_before_reuse_barrier
	.p2align	2
	.type	__clang_ocl_kern_imp_read_wait_before_reuse_barrier,@function
__clang_ocl_kern_imp_read_wait_before_reuse_barrier:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_trap 2
	s_waitcnt vmcnt(0)
	ds_write_b32 v0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v6, v0
s_waitcnt lgkmcnt(0)
s_barrier
ds_write_b32 v0, v0
s_waitcnt lgkmcnt(0)
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end13:
	.size	__clang_ocl_kern_imp_read_wait_before_reuse_barrier, .Lfunc_end13-__clang_ocl_kern_imp_read_wait_before_reuse_barrier

	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.num_vgpr, 32
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.num_agpr, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.private_seg_size, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.uses_vcc, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.has_recursion, 0
	.set __clang_ocl_kern_imp_read_wait_before_reuse_barrier.has_indirect_call, 0
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
	.addrsig_sym read_pending_across_reuse_barrier.shared
	.addrsig_sym read_wait_before_reuse_barrier.shared
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
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           exchange
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         exchange.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           two_rounds
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         two_rounds.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           no_barrier
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         no_barrier.kd
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
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           barrier_without_wait
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         barrier_without_wait.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           overwrite_without_barrier
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         overwrite_without_barrier.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           read_pending_across_reuse_barrier
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         read_pending_across_reuse_barrier.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           read_wait_before_reuse_barrier
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         read_wait_before_reuse_barrier.kd
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
