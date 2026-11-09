	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	workgroup_x
	.globl	workgroup_x
	.p2align	8
	.type	workgroup_x,@function
workgroup_x:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s2
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_x
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 3
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
	.size	workgroup_x, .Lfunc_end0-workgroup_x

	.set workgroup_x.num_vgpr, 2
	.set workgroup_x.num_agpr, 0
	.set workgroup_x.numbered_sgpr, 3
	.set workgroup_x.private_seg_size, 0
	.set workgroup_x.uses_vcc, 0
	.set workgroup_x.uses_flat_scratch, 0
	.set workgroup_x.has_dyn_sized_stack, 0
	.set workgroup_x.has_recursion, 0
	.set workgroup_x.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_x
	.globl	__clang_ocl_kern_imp_workgroup_x
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_x,@function
__clang_ocl_kern_imp_workgroup_x:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s12
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_workgroup_x, .Lfunc_end1-__clang_ocl_kern_imp_workgroup_x

	.set __clang_ocl_kern_imp_workgroup_x.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_x.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_x.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_x.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_x.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_x.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_indirect_call, 0
	.protected	workgroup_y
	.globl	workgroup_y
	.p2align	8
	.type	workgroup_y,@function
workgroup_y:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s3
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_y
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
		.amdhsa_system_sgpr_workgroup_id_y 1
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
	.size	workgroup_y, .Lfunc_end2-workgroup_y

	.set workgroup_y.num_vgpr, 2
	.set workgroup_y.num_agpr, 0
	.set workgroup_y.numbered_sgpr, 4
	.set workgroup_y.private_seg_size, 0
	.set workgroup_y.uses_vcc, 0
	.set workgroup_y.uses_flat_scratch, 0
	.set workgroup_y.has_dyn_sized_stack, 0
	.set workgroup_y.has_recursion, 0
	.set workgroup_y.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_y
	.globl	__clang_ocl_kern_imp_workgroup_y
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_y,@function
__clang_ocl_kern_imp_workgroup_y:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s13
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end3:
	.size	__clang_ocl_kern_imp_workgroup_y, .Lfunc_end3-__clang_ocl_kern_imp_workgroup_y

	.set __clang_ocl_kern_imp_workgroup_y.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_y.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_y.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_y.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_y.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_y.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_indirect_call, 0
	.protected	workgroup_z
	.globl	workgroup_z
	.p2align	8
	.type	workgroup_z,@function
workgroup_z:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s3
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_z
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
		.amdhsa_system_sgpr_workgroup_id_z 1
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
	.size	workgroup_z, .Lfunc_end4-workgroup_z

	.set workgroup_z.num_vgpr, 2
	.set workgroup_z.num_agpr, 0
	.set workgroup_z.numbered_sgpr, 4
	.set workgroup_z.private_seg_size, 0
	.set workgroup_z.uses_vcc, 0
	.set workgroup_z.uses_flat_scratch, 0
	.set workgroup_z.has_dyn_sized_stack, 0
	.set workgroup_z.has_recursion, 0
	.set workgroup_z.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_z
	.globl	__clang_ocl_kern_imp_workgroup_z
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_z,@function
__clang_ocl_kern_imp_workgroup_z:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s14
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end5:
	.size	__clang_ocl_kern_imp_workgroup_z, .Lfunc_end5-__clang_ocl_kern_imp_workgroup_z

	.set __clang_ocl_kern_imp_workgroup_z.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_z.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_z.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_z.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_z.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_z.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_indirect_call, 0
	.protected	workgroup_xyz
	.globl	workgroup_xyz
	.p2align	8
	.type	workgroup_xyz,@function
workgroup_xyz:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s2
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	v_mov_b32_e32 v1, s3
	global_store_dword v0, v1, s[0:1] offset:256
	v_mov_b32_e32 v1, s4
	global_store_dword v0, v1, s[0:1] offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_xyz
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 5
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
	.size	workgroup_xyz, .Lfunc_end6-workgroup_xyz

	.set workgroup_xyz.num_vgpr, 2
	.set workgroup_xyz.num_agpr, 0
	.set workgroup_xyz.numbered_sgpr, 5
	.set workgroup_xyz.private_seg_size, 0
	.set workgroup_xyz.uses_vcc, 0
	.set workgroup_xyz.uses_flat_scratch, 0
	.set workgroup_xyz.has_dyn_sized_stack, 0
	.set workgroup_xyz.has_recursion, 0
	.set workgroup_xyz.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_xyz
	.globl	__clang_ocl_kern_imp_workgroup_xyz
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_xyz,@function
__clang_ocl_kern_imp_workgroup_xyz:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s12
	global_store_dword v[0:1], v2, off
	v_mov_b32_e32 v2, s13
	global_store_dword v[0:1], v2, off offset:256
	v_mov_b32_e32 v2, s14
	global_store_dword v[0:1], v2, off offset:512
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end7:
	.size	__clang_ocl_kern_imp_workgroup_xyz, .Lfunc_end7-__clang_ocl_kern_imp_workgroup_xyz

	.set __clang_ocl_kern_imp_workgroup_xyz.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_xyz.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_xyz.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_indirect_call, 0
	.protected	grid_lds_words
	.globl	grid_lds_words
	.p2align	8
	.type	grid_lds_words,@function
grid_lds_words:
	v_lshl_add_u32 v1, s2, 6, v0
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	;;#ASMSTART
	s_and_b32 s0, s2, 0
	;;#ASMEND
	v_add_u32_e32 v2, 1, v1
	v_add_lshl_u32 v3, s0, v0, 2
	ds_write_b32 v3, v2
	v_xor_b32_e32 v2, 1, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_lshlrev_b32_e32 v2, 2, v2
	v_xor_b32_e32 v0, 8, v0
	;;#ASMSTART
	ds_read_b32 v3, v2
	s_waitcnt lgkmcnt(0)
	v_xor_b32_e32 v4, 85, v3
	v_cvt_f32_u32_e32 v6, v3
	ds_bpermute_b32 v5, v0, v3
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_lshl_b32 s0, s2, 7
	v_add_lshl_u32 v0, v1, s0, 2
	;;#ASMSTART
	global_store_dword v0, v3, s[4:5]
	;;#ASMEND
	v_add_u32_e32 v2, 0x100, v0
	;;#ASMSTART
	global_store_dword v2, v4, s[4:5]
	;;#ASMEND
	v_add_u32_e32 v0, 0x200, v0
	;;#ASMSTART
	global_store_dword v0, v5, s[4:5]
	;;#ASMEND
	v_lshlrev_b32_e32 v0, 2, v1
	;;#ASMSTART
	global_store_dword v0, v6, s[6:7]
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel grid_lds_words
		.amdhsa_group_segment_fixed_size 256
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
		.amdhsa_next_free_vgpr 7
		.amdhsa_next_free_sgpr 8
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
.Lfunc_end8:
	.size	grid_lds_words, .Lfunc_end8-grid_lds_words

	.set grid_lds_words.num_vgpr, 7
	.set grid_lds_words.num_agpr, 0
	.set grid_lds_words.numbered_sgpr, 8
	.set grid_lds_words.private_seg_size, 0
	.set grid_lds_words.uses_vcc, 0
	.set grid_lds_words.uses_flat_scratch, 0
	.set grid_lds_words.has_dyn_sized_stack, 0
	.set grid_lds_words.has_recursion, 0
	.set grid_lds_words.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_grid_lds_words
	.globl	__clang_ocl_kern_imp_grid_lds_words
	.p2align	2
	.type	__clang_ocl_kern_imp_grid_lds_words,@function
__clang_ocl_kern_imp_grid_lds_words:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshl_add_u32 v5, s12, 6, v4
	v_add_u32_e32 v6, 1, v5
	v_lshlrev_b32_e32 v4, 2, v4
	;;#ASMSTART
	s_and_b32 s0, s12, 0
	;;#ASMEND
	s_trap 2
	ds_write_b32 v0, v6
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_xor_b32_e32 v4, 8, v4
	;;#ASMSTART
	ds_read_b32 v6, v0
	s_waitcnt lgkmcnt(0)
	v_xor_b32_e32 v7, 85, v6
	v_cvt_f32_u32_e32 v9, v6
	ds_bpermute_b32 v8, v4, v6
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_lshl_b32 s2, s12, 7
	v_readfirstlane_b32 s1, v1
	v_readfirstlane_b32 s0, v0
	v_add_lshl_u32 v0, v5, s2, 2
	;;#ASMSTART
	global_store_dword v0, v6, s[0:1]
	;;#ASMEND
	v_add_u32_e32 v1, 0x100, v0
	;;#ASMSTART
	global_store_dword v1, v7, s[0:1]
	;;#ASMEND
	v_add_u32_e32 v0, 0x200, v0
	;;#ASMSTART
	global_store_dword v0, v8, s[0:1]
	;;#ASMEND
	v_readfirstlane_b32 s1, v3
	v_readfirstlane_b32 s0, v2
	v_lshlrev_b32_e32 v0, 2, v5
	;;#ASMSTART
	global_store_dword v0, v9, s[0:1]
	;;#ASMEND
	s_setpc_b64 s[30:31]
.Lfunc_end9:
	.size	__clang_ocl_kern_imp_grid_lds_words, .Lfunc_end9-__clang_ocl_kern_imp_grid_lds_words

	.set __clang_ocl_kern_imp_grid_lds_words.num_vgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_words.num_agpr, 0
	.set __clang_ocl_kern_imp_grid_lds_words.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_words.private_seg_size, 0
	.set __clang_ocl_kern_imp_grid_lds_words.uses_vcc, 0
	.set __clang_ocl_kern_imp_grid_lds_words.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_grid_lds_words.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_grid_lds_words.has_recursion, 0
	.set __clang_ocl_kern_imp_grid_lds_words.has_indirect_call, 0
	.protected	grid_vcc_branch
	.globl	grid_vcc_branch
	.p2align	8
	.type	grid_vcc_branch,@function
grid_vcc_branch:
	v_mov_b32_e32 v1, 17
	;;#ASMSTART
	v_cmp_eq_u32_e32 vcc, s2, v0
	v_mov_b32_e32 v2, 0
	s_cbranch_vccz .Lgrid_vcc_done_0
	v_cndmask_b32_e32 v2, 0, v1, vcc
.Lgrid_vcc_done_0:
	;;#ASMEND
	v_lshlrev_b32_e32 v0, 2, v0
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshl_add_u32 v0, s2, 8, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	global_store_dword v0, v2, s[0:1]
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel grid_vcc_branch
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
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 3
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
.Lfunc_end10:
	.size	grid_vcc_branch, .Lfunc_end10-grid_vcc_branch

	.set grid_vcc_branch.num_vgpr, 3
	.set grid_vcc_branch.num_agpr, 0
	.set grid_vcc_branch.numbered_sgpr, 3
	.set grid_vcc_branch.private_seg_size, 0
	.set grid_vcc_branch.uses_vcc, 1
	.set grid_vcc_branch.uses_flat_scratch, 0
	.set grid_vcc_branch.has_dyn_sized_stack, 0
	.set grid_vcc_branch.has_recursion, 0
	.set grid_vcc_branch.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_grid_vcc_branch
	.globl	__clang_ocl_kern_imp_grid_vcc_branch
	.p2align	2
	.type	__clang_ocl_kern_imp_grid_vcc_branch,@function
__clang_ocl_kern_imp_grid_vcc_branch:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_readfirstlane_b32 s0, v0
	v_lshlrev_b32_e32 v0, 2, v2
	v_mov_b32_e32 v3, 17
	;;#ASMSTART
	v_cmp_eq_u32_e32 vcc, s12, v2
	v_mov_b32_e32 v4, 0
	s_cbranch_vccz .Lgrid_vcc_done_1
	v_cndmask_b32_e32 v4, 0, v3, vcc
.Lgrid_vcc_done_1:
	;;#ASMEND
	v_readfirstlane_b32 s1, v1
	v_lshl_add_u32 v0, s12, 8, v0
	;;#ASMSTART
	global_store_dword v0, v4, s[0:1]
	;;#ASMEND
	s_setpc_b64 s[30:31]
.Lfunc_end11:
	.size	__clang_ocl_kern_imp_grid_vcc_branch, .Lfunc_end11-__clang_ocl_kern_imp_grid_vcc_branch

	.set __clang_ocl_kern_imp_grid_vcc_branch.num_vgpr, 32
	.set __clang_ocl_kern_imp_grid_vcc_branch.num_agpr, 0
	.set __clang_ocl_kern_imp_grid_vcc_branch.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_grid_vcc_branch.private_seg_size, 0
	.set __clang_ocl_kern_imp_grid_vcc_branch.uses_vcc, 1
	.set __clang_ocl_kern_imp_grid_vcc_branch.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_grid_vcc_branch.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_grid_vcc_branch.has_recursion, 0
	.set __clang_ocl_kern_imp_grid_vcc_branch.has_indirect_call, 0
	.protected	grid_lds_addresses
	.globl	grid_lds_addresses
	.p2align	8
	.type	grid_lds_addresses,@function
grid_lds_addresses:
	s_lshl_b32 s2, s2, 6
	v_add_lshl_u32 v1, s2, v0, 2
	;;#ASMSTART
	ds_write_b32 v1, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	global_store_dword v1, v0, s[0:1]
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel grid_lds_addresses
		.amdhsa_group_segment_fixed_size 512
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 3
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
	.size	grid_lds_addresses, .Lfunc_end12-grid_lds_addresses

	.set grid_lds_addresses.num_vgpr, 2
	.set grid_lds_addresses.num_agpr, 0
	.set grid_lds_addresses.numbered_sgpr, 3
	.set grid_lds_addresses.private_seg_size, 0
	.set grid_lds_addresses.uses_vcc, 0
	.set grid_lds_addresses.uses_flat_scratch, 0
	.set grid_lds_addresses.has_dyn_sized_stack, 0
	.set grid_lds_addresses.has_recursion, 0
	.set grid_lds_addresses.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_grid_lds_addresses
	.globl	__clang_ocl_kern_imp_grid_lds_addresses
	.p2align	2
	.type	__clang_ocl_kern_imp_grid_lds_addresses,@function
__clang_ocl_kern_imp_grid_lds_addresses:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_lshl_b32 s0, s12, 6
	v_and_b32_e32 v2, 0x3ff, v31
	s_trap 2
	;;#ASMSTART
	ds_write_b32 v0, v2
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	v_add_lshl_u32 v3, s0, v2, 2
	v_readfirstlane_b32 s1, v1
	v_readfirstlane_b32 s0, v0
	;;#ASMSTART
	global_store_dword v3, v2, s[0:1]
	;;#ASMEND
	s_setpc_b64 s[30:31]
.Lfunc_end13:
	.size	__clang_ocl_kern_imp_grid_lds_addresses, .Lfunc_end13-__clang_ocl_kern_imp_grid_lds_addresses

	.set __clang_ocl_kern_imp_grid_lds_addresses.num_vgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_addresses.num_agpr, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_addresses.private_seg_size, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.uses_vcc, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.has_recursion, 0
	.set __clang_ocl_kern_imp_grid_lds_addresses.has_indirect_call, 0
	.protected	grid_lds_nan
	.globl	grid_lds_nan
	.p2align	8
	.type	grid_lds_nan,@function
grid_lds_nan:
	s_lshl_b32 s3, s2, 30
	s_or_b32 s3, s3, 0x3fc00000
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s3
	ds_write_b32 v0, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v1, v0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v1, 0, v1
	;;#ASMEND
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshl_add_u32 v0, s2, 8, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	global_store_dword v0, v1, s[0:1]
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel grid_lds_nan
		.amdhsa_group_segment_fixed_size 256
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
.Lfunc_end14:
	.size	grid_lds_nan, .Lfunc_end14-grid_lds_nan

	.set grid_lds_nan.num_vgpr, 2
	.set grid_lds_nan.num_agpr, 0
	.set grid_lds_nan.numbered_sgpr, 4
	.set grid_lds_nan.private_seg_size, 0
	.set grid_lds_nan.uses_vcc, 0
	.set grid_lds_nan.uses_flat_scratch, 0
	.set grid_lds_nan.has_dyn_sized_stack, 0
	.set grid_lds_nan.has_recursion, 0
	.set grid_lds_nan.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_grid_lds_nan
	.globl	__clang_ocl_kern_imp_grid_lds_nan
	.p2align	2
	.type	__clang_ocl_kern_imp_grid_lds_nan,@function
__clang_ocl_kern_imp_grid_lds_nan:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_lshl_b32 s0, s12, 30
	s_or_b32 s0, s0, 0x3fc00000
	v_and_b32_e32 v2, 0x3ff, v31
	v_mov_b32_e32 v3, s0
	v_lshlrev_b32_e32 v2, 2, v2
	s_trap 2
	ds_write_b32 v0, v3
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	ds_read_b32 v3, v0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v3, 0, v3
	;;#ASMEND
	v_readfirstlane_b32 s1, v1
	v_readfirstlane_b32 s0, v0
	v_lshl_add_u32 v0, s12, 8, v2
	;;#ASMSTART
	global_store_dword v0, v3, s[0:1]
	;;#ASMEND
	s_setpc_b64 s[30:31]
.Lfunc_end15:
	.size	__clang_ocl_kern_imp_grid_lds_nan, .Lfunc_end15-__clang_ocl_kern_imp_grid_lds_nan

	.set __clang_ocl_kern_imp_grid_lds_nan.num_vgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_nan.num_agpr, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_grid_lds_nan.private_seg_size, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.uses_vcc, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.has_recursion, 0
	.set __clang_ocl_kern_imp_grid_lds_nan.has_indirect_call, 0
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
	.addrsig_sym grid_lds_words.shared
	.addrsig_sym grid_lds_addresses.shared
	.addrsig_sym grid_lds_nan.shared
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
    .name:           workgroup_x
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         workgroup_x.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .name:           workgroup_y
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         workgroup_y.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .name:           workgroup_z
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         workgroup_z.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .name:           workgroup_xyz
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         workgroup_xyz.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 256
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           grid_lds_words
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         grid_lds_words.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     7
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .name:           grid_vcc_branch
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         grid_vcc_branch.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 512
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           grid_lds_addresses
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         grid_lds_addresses.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 256
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           grid_lds_nan
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         grid_lds_nan.kd
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
