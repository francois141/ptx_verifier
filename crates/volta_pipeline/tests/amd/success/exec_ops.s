	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	exec_ops
	.globl	exec_ops
	.p2align	8
	.type	exec_ops,@function
exec_ops:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_and_b32_e32 v1, 1, v0
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[2:3], 0, v1
	;;#ASMEND
	v_lshlrev_b32_e32 v6, 7, v0
	v_mov_b64_e32 v[2:3], s[2:3]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx2 v6, v[2:3], s[6:7]
	;;#ASMSTART
	v_cmp_ne_u32_e32 vcc, 0, v1
	v_mov_b32_e32 v2, 7
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, vcc
	v_mov_b32_e32 v2, 9
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	v_add_u32_e32 v5, 0x64, v0
	v_mov_b32_e32 v3, s8
	v_mov_b32_e32 v4, s9
	global_store_dwordx3 v6, v[2:4], s[6:7] offset:8
	;;#ASMSTART
	v_cmp_gt_u32_e32 vcc, 16, v0
	s_mov_b64 s[8:9], exec
	s_and_b64 exec, s[8:9], vcc
	v_mov_b32_e32 v1, 1
	s_andn2_b64 exec, s[8:9], exec
	v_mov_b32_e32 v1, 2
	s_or_b64 exec, exec, s[8:9]
	;;#ASMEND
	global_store_dword v6, v1, s[6:7] offset:20
	v_add_u32_e32 v7, 0xc8, v0
	;;#ASMSTART
	s_mov_b64 vcc, -1
	s_mov_b64 s[8:9], -1
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	v_cmp_eq_u32_e32 vcc, v0, v0
	v_cmp_eq_u32_e64 s[8:9], v0, v0
	s_mov_b64 exec, s[10:11]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	v_cndmask_b32_e64 v3, 0, 1, s[8:9]
	;;#ASMEND
	global_store_dwordx2 v6, v[2:3], s[6:7] offset:24
	;;#ASMSTART
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[2:3]
	global_store_dword v6, v0, s[6:7] offset:32
	s_mov_b64 exec, s[8:9]
	;;#ASMEND
	v_lshlrev_b32_e32 v4, 2, v0
	;;#ASMSTART
	v_mov_b32_e32 v2, 0.5
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[2:3]
	global_load_dword v2, v4, s[4:5]
	s_mov_b64 exec, s[8:9]
	s_waitcnt vmcnt(0)
	;;#ASMEND
	global_store_dword v4, v2, s[0:1]
	v_mov_b32_e32 v8, 0x100
	;;#ASMSTART
	ds_write_b32 v4, v5
	s_waitcnt lgkmcnt(0)
	v_cmp_eq_u32_e32 vcc, 5, v0
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[2:3]
	ds_write_b32 v4, v7
	s_waitcnt lgkmcnt(0)
	s_mov_b64 exec, vcc
	ds_write_b32 v8, v7
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	ds_read_b32 v2, v4
	ds_read_b32 v3, v8
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dwordx2 v6, v[2:3], s[6:7] offset:36
	v_xor_b32_e32 v2, 1, v0
	v_lshlrev_b32_e32 v5, 2, v2
	;;#ASMSTART
	v_mov_b32_e32 v2, 7
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[2:3]
	ds_read_b32 v2, v5
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dword v6, v2, s[6:7] offset:44
	v_xor_b32_e32 v4, 8, v4
	v_add_u32_e32 v7, 0x190, v0
	;;#ASMSTART
	v_mov_b32_e32 v2, 7
	v_mov_b32_e32 v3, 7
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[2:3]
	ds_bpermute_b32 v2, v5, v7
	ds_bpermute_b32 v3, v4, v7
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dwordx2 v6, v[2:3], s[6:7] offset:48
	v_add_u32_e32 v2, 0x1f4, v0
	;;#ASMSTART
	v_cmp_le_u32_e32 vcc, 5, v0
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, vcc
	v_readfirstlane_b32 s4, v2
	s_mov_b64 exec, 0
	v_readfirstlane_b32 s5, v2
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	s_mov_b64 s[0:1], 0
	v_mov_b32_e32 v2, s4
	v_mov_b32_e32 v3, s5
	global_store_dwordx2 v6, v[2:3], s[6:7] offset:56
	;;#ASMSTART
	s_mov_b32 s8, 1
	s_mov_b64 s[4:5], exec
	s_mov_b64 exec, s[0:1]
	s_cbranch_execz .Lbranch_taken_0
	s_mov_b32 s8, 0
.Lbranch_taken_0:
	s_mov_b64 exec, s[4:5]
	;;#ASMEND
	v_mov_b64_e32 v[4:5], -1
	v_mov_b32_e32 v2, s8
	global_store_dword v6, v2, s[6:7] offset:64
	;;#ASMSTART
	s_mov_b32 s8, 1
	s_mov_b64 s[4:5], exec
	s_mov_b64 exec, s[0:1]
	s_cbranch_execnz .Lbranch_taken_1
	s_mov_b32 s8, 0
.Lbranch_taken_1:
	s_mov_b64 exec, s[4:5]
	;;#ASMEND
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v2, s8
	global_store_dword v6, v2, s[6:7] offset:68
	;;#ASMSTART
	s_mov_b32 s4, 1
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[2:3]
	s_cbranch_execz .Lbranch_taken_2
	s_mov_b32 s4, 0
.Lbranch_taken_2:
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	v_mov_b32_e32 v7, -1
	v_mov_b32_e32 v2, s4
	global_store_dword v6, v2, s[6:7] offset:72
	;;#ASMSTART
	s_mov_b32 s4, 1
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[2:3]
	s_cbranch_execnz .Lbranch_taken_3
	s_mov_b32 s4, 0
.Lbranch_taken_3:
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s4
	global_store_dword v6, v2, s[6:7] offset:76
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], v[0:1]
	s_mov_b64 s[0:1], -1
	s_mov_b64 s[4:5], exec
	s_mov_b64 exec, s[2:3]
	v_mad_u64_u32 v[2:3], s[0:1], v7, v7, v[4:5]
	s_mov_b64 exec, s[4:5]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s0
	v_mov_b32_e32 v5, s1
	global_store_dwordx4 v6, v[2:5], s[6:7] offset:80
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel exec_ops
		.amdhsa_group_segment_fixed_size 260
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
		.amdhsa_next_free_vgpr 9
		.amdhsa_next_free_sgpr 12
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
.Lfunc_end0:
	.size	exec_ops, .Lfunc_end0-exec_ops

	.set exec_ops.num_vgpr, 9
	.set exec_ops.num_agpr, 0
	.set exec_ops.numbered_sgpr, 12
	.set exec_ops.private_seg_size, 0
	.set exec_ops.uses_vcc, 1
	.set exec_ops.uses_flat_scratch, 0
	.set exec_ops.has_dyn_sized_stack, 0
	.set exec_ops.has_recursion, 0
	.set exec_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_exec_ops
	.globl	__clang_ocl_kern_imp_exec_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_exec_ops,@function
__clang_ocl_kern_imp_exec_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_lshlrev_b32_e32 v8, 7, v6
	v_mov_b32_e32 v9, 0
	v_lshl_add_u64 v[10:11], v[2:3], 0, v[8:9]
	v_readfirstlane_b32 s0, v2
	v_readfirstlane_b32 s3, v1
	v_readfirstlane_b32 s2, v0
	v_and_b32_e32 v2, 1, v6
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[4:5], 0, v2
	;;#ASMEND
	v_readfirstlane_b32 s1, v3
	v_mov_b64_e32 v[0:1], s[4:5]
	global_store_dwordx2 v[10:11], v[0:1], off
	;;#ASMSTART
	v_cmp_ne_u32_e32 vcc, 0, v2
	v_mov_b32_e32 v0, 7
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, vcc
	v_mov_b32_e32 v0, 9
	s_mov_b64 s[6:7], exec
	s_mov_b64 exec, s[8:9]
	;;#ASMEND
	v_add_u32_e32 v3, 0xc8, v6
	v_mov_b32_e32 v1, s6
	v_mov_b32_e32 v2, s7
	global_store_dwordx3 v[10:11], v[0:2], off offset:8
	v_mov_b32_e32 v7, v9
	s_nop 0
	;;#ASMSTART
	v_cmp_gt_u32_e32 vcc, 16, v6
	s_mov_b64 s[6:7], exec
	s_and_b64 exec, s[6:7], vcc
	v_mov_b32_e32 v0, 1
	s_andn2_b64 exec, s[6:7], exec
	v_mov_b32_e32 v0, 2
	s_or_b64 exec, exec, s[6:7]
	;;#ASMEND
	global_store_dword v[10:11], v0, off offset:20
	;;#ASMSTART
	s_mov_b64 vcc, -1
	s_mov_b64 s[6:7], -1
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[4:5]
	v_cmp_eq_u32_e32 vcc, v6, v6
	v_cmp_eq_u32_e64 s[6:7], v6, v6
	s_mov_b64 exec, s[8:9]
	v_cndmask_b32_e64 v0, 0, 1, vcc
	v_cndmask_b32_e64 v1, 0, 1, s[6:7]
	;;#ASMEND
	global_store_dwordx2 v[10:11], v[0:1], off offset:24
	;;#ASMSTART
	s_mov_b64 s[6:7], exec
	s_mov_b64 exec, s[4:5]
	global_store_dword v8, v6, s[0:1] offset:32
	s_mov_b64 exec, s[6:7]
	;;#ASMEND
	v_lshlrev_b32_e32 v8, 2, v6
	;;#ASMSTART
	v_mov_b32_e32 v2, 0.5
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	global_load_dword v2, v8, s[2:3]
	s_mov_b64 exec, s[0:1]
	s_waitcnt vmcnt(0)
	;;#ASMEND
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[8:9]
	global_store_dword v[0:1], v2, off
	s_trap 2
	v_add_u32_e32 v2, 0x64, v6
	;;#ASMSTART
	ds_write_b32 v0, v2
	s_waitcnt lgkmcnt(0)
	v_cmp_eq_u32_e32 vcc, 5, v6
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	ds_write_b32 v0, v3
	s_waitcnt lgkmcnt(0)
	s_mov_b64 exec, vcc
	ds_write_b32 v0, v3
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	ds_read_b32 v0, v0
	ds_read_b32 v1, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dwordx2 v[10:11], v[0:1], off offset:36
	v_xor_b32_e32 v0, 1, v6
	v_lshlrev_b32_e32 v2, 2, v0
	;;#ASMSTART
	v_mov_b32_e32 v0, 7
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	ds_read_b32 v0, v0
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dword v[10:11], v0, off offset:44
	v_xor_b32_e32 v3, 8, v8
	v_add_u32_e32 v4, 0x190, v6
	;;#ASMSTART
	v_mov_b32_e32 v0, 7
	v_mov_b32_e32 v1, 7
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	ds_bpermute_b32 v0, v2, v4
	ds_bpermute_b32 v1, v3, v4
	s_mov_b64 exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	global_store_dwordx2 v[10:11], v[0:1], off offset:48
	v_add_u32_e32 v0, 0x1f4, v6
	;;#ASMSTART
	v_cmp_le_u32_e32 vcc, 5, v6
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, vcc
	v_readfirstlane_b32 s2, v0
	s_mov_b64 exec, 0
	v_readfirstlane_b32 s3, v0
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	s_mov_b64 s[0:1], 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v[10:11], v[0:1], off offset:56
	;;#ASMSTART
	s_mov_b32 s6, 1
	s_mov_b64 s[2:3], exec
	s_mov_b64 exec, s[0:1]
	s_cbranch_execz .Lbranch_taken_4
	s_mov_b32 s6, 0
.Lbranch_taken_4:
	s_mov_b64 exec, s[2:3]
	;;#ASMEND
	v_mov_b64_e32 v[2:3], -1
	v_mov_b32_e32 v0, s6
	global_store_dword v[10:11], v0, off offset:64
	;;#ASMSTART
	s_mov_b32 s6, 1
	s_mov_b64 s[2:3], exec
	s_mov_b64 exec, s[0:1]
	s_cbranch_execnz .Lbranch_taken_5
	s_mov_b32 s6, 0
.Lbranch_taken_5:
	s_mov_b64 exec, s[2:3]
	;;#ASMEND
	v_mov_b32_e32 v4, -1
	v_mov_b32_e32 v0, s6
	global_store_dword v[10:11], v0, off offset:68
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	s_cbranch_execz .Lbranch_taken_6
	s_mov_b32 s2, 0
.Lbranch_taken_6:
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v[10:11], v0, off offset:72
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 s[0:1], exec
	s_mov_b64 exec, s[4:5]
	s_cbranch_execnz .Lbranch_taken_7
	s_mov_b32 s2, 0
.Lbranch_taken_7:
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v[10:11], v0, off offset:76
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], v[6:7]
	s_mov_b64 s[0:1], -1
	s_mov_b64 s[2:3], exec
	s_mov_b64 exec, s[4:5]
	v_mad_u64_u32 v[0:1], s[0:1], v4, v4, v[2:3]
	s_mov_b64 exec, s[2:3]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s0
	v_mov_b32_e32 v3, s1
	global_store_dwordx4 v[10:11], v[0:3], off offset:80
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_exec_ops, .Lfunc_end1-__clang_ocl_kern_imp_exec_ops

	.set __clang_ocl_kern_imp_exec_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_exec_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_exec_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_exec_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_exec_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_exec_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_exec_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_exec_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_exec_ops.has_indirect_call, 0
	.protected	pending_in_other_lanes
	.globl	pending_in_other_lanes
	.p2align	8
	.type	pending_in_other_lanes,@function
pending_in_other_lanes:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_and_b32_e32 v1, 1, v0
	v_lshlrev_b32_e32 v0, 2, v0
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[4:5], 0, v1
	;;#ASMEND
	v_mov_b32_e32 v1, 0.5
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	ds_write_b32 v0, v1
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[6:7], exec
	s_mov_b64 exec, s[4:5]
	global_load_dword v2, v0, s[0:1]
	s_andn2_b64 exec, s[6:7], exec
	ds_read_b32 v2, v0
	s_mov_b64 exec, s[6:7]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v3, v2
	s_waitcnt vmcnt(0)
	;;#ASMEND
	global_store_dword v0, v3, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel pending_in_other_lanes
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 8
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
	.size	pending_in_other_lanes, .Lfunc_end2-pending_in_other_lanes

	.set pending_in_other_lanes.num_vgpr, 4
	.set pending_in_other_lanes.num_agpr, 0
	.set pending_in_other_lanes.numbered_sgpr, 8
	.set pending_in_other_lanes.private_seg_size, 0
	.set pending_in_other_lanes.uses_vcc, 0
	.set pending_in_other_lanes.uses_flat_scratch, 0
	.set pending_in_other_lanes.has_dyn_sized_stack, 0
	.set pending_in_other_lanes.has_recursion, 0
	.set pending_in_other_lanes.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_pending_in_other_lanes
	.globl	__clang_ocl_kern_imp_pending_in_other_lanes
	.p2align	2
	.type	__clang_ocl_kern_imp_pending_in_other_lanes,@function
__clang_ocl_kern_imp_pending_in_other_lanes:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_readfirstlane_b32 s0, v0
	v_and_b32_e32 v0, 0x3ff, v31
	v_readfirstlane_b32 s1, v1
	v_and_b32_e32 v1, 1, v0
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[2:3], 0, v1
	;;#ASMEND
	v_mov_b32_e32 v1, 0.5
	v_lshlrev_b32_e32 v0, 2, v0
	s_trap 2
	;;#ASMSTART
	ds_write_b32 v0, v1
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[4:5], exec
	s_mov_b64 exec, s[2:3]
	global_load_dword v4, v0, s[0:1]
	s_andn2_b64 exec, s[4:5], exec
	ds_read_b32 v4, v0
	s_mov_b64 exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v5, v4
	s_waitcnt vmcnt(0)
	;;#ASMEND
	v_mov_b32_e32 v1, 0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[0:1]
	global_store_dword v[0:1], v5, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end3:
	.size	__clang_ocl_kern_imp_pending_in_other_lanes, .Lfunc_end3-__clang_ocl_kern_imp_pending_in_other_lanes

	.set __clang_ocl_kern_imp_pending_in_other_lanes.num_vgpr, 32
	.set __clang_ocl_kern_imp_pending_in_other_lanes.num_agpr, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_pending_in_other_lanes.private_seg_size, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.uses_vcc, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.has_recursion, 0
	.set __clang_ocl_kern_imp_pending_in_other_lanes.has_indirect_call, 0
	.protected	workgroup_exec
	.globl	workgroup_exec
	.p2align	8
	.type	workgroup_exec,@function
workgroup_exec:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	;;#ASMSTART
	v_mov_b32_e32 v1, 7
	s_cmp_eq_u32 s2, 0
	s_cselect_b64 s[6:7], -1, 0
	s_mov_b64 s[4:5], exec
	s_xor_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v1, 9
	s_mov_b64 exec, s[4:5]
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_exec
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
		.amdhsa_next_free_sgpr 8
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
	.size	workgroup_exec, .Lfunc_end4-workgroup_exec

	.set workgroup_exec.num_vgpr, 2
	.set workgroup_exec.num_agpr, 0
	.set workgroup_exec.numbered_sgpr, 8
	.set workgroup_exec.private_seg_size, 0
	.set workgroup_exec.uses_vcc, 0
	.set workgroup_exec.uses_flat_scratch, 0
	.set workgroup_exec.has_dyn_sized_stack, 0
	.set workgroup_exec.has_recursion, 0
	.set workgroup_exec.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_exec
	.globl	__clang_ocl_kern_imp_workgroup_exec
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_exec,@function
__clang_ocl_kern_imp_workgroup_exec:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	;;#ASMSTART
	v_mov_b32_e32 v4, 7
	s_cmp_eq_u32 s12, 0
	s_cselect_b64 s[2:3], -1, 0
	s_mov_b64 s[0:1], exec
	s_xor_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v4, 9
	s_mov_b64 exec, s[0:1]
	;;#ASMEND
	global_store_dword v[0:1], v4, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end5:
	.size	__clang_ocl_kern_imp_workgroup_exec, .Lfunc_end5-__clang_ocl_kern_imp_workgroup_exec

	.set __clang_ocl_kern_imp_workgroup_exec.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_exec.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_exec.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_exec.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_exec.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_exec.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_exec.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_exec.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_exec.has_indirect_call, 0
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
	.addrsig_sym exec_ops.shared
	.addrsig_sym pending_in_other_lanes.shared
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
      - .address_space:  global
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 260
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           exec_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         exec_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     9
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
    .group_segment_fixed_size: 256
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           pending_in_other_lanes
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         pending_in_other_lanes.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
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
    .name:           workgroup_exec
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         workgroup_exec.kd
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
