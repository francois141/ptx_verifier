	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	saveexec_ops
	.globl	saveexec_ops
	.p2align	8
	.type	saveexec_ops,@function
saveexec_ops:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_mul_u32_u24_e32 v1, 0x50, v0
	v_lshlrev_b32_e32 v1, 2, v1
	v_and_b32_e32 v6, 1, v0
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[4:5], 0, v6
	;;#ASMEND
	;;#ASMSTART
	v_cmp_gt_u32_e64 s[2:3], 48, v0
	;;#ASMEND
	v_cmp_eq_u32_e32 vcc, 1, v6
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v1, v[2:5], s[0:1]
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:16
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_or_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:20
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:36
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_xor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:40
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:56
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn2_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:60
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:76
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_orn2_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:80
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:96
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_nand_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:100
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:116
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_nor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:120
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:136
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_xnor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:140
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:156
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn1_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:160
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:176
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_orn1_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:180
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:196
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn1_wrexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:200
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:216
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn2_wrexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:220
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:236
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s6
	v_mov_b32_e32 v3, s7
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s9
	global_store_dwordx4 v1, v[2:5], s[0:1] offset:240
	s_nop 1
	v_mov_b32_e32 v2, s12
	global_store_dword v1, v2, s[0:1] offset:256
	v_mul_u32_u24_e32 v1, 0x140, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_2
	;;#ASMSTART
	global_store_dword v1, v0, s[0:1] offset:280
	;;#ASMEND
.LBB0_2:
	s_or_b64 exec, exec, s[2:3]
	;;#ASMSTART
	global_store_dword v1, v0, s[0:1] offset:284
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel saveexec_ops
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
		.amdhsa_next_free_sgpr 13
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
	.size	saveexec_ops, .Lfunc_end0-saveexec_ops

	.set saveexec_ops.num_vgpr, 7
	.set saveexec_ops.num_agpr, 0
	.set saveexec_ops.numbered_sgpr, 13
	.set saveexec_ops.private_seg_size, 0
	.set saveexec_ops.uses_vcc, 1
	.set saveexec_ops.uses_flat_scratch, 0
	.set saveexec_ops.has_dyn_sized_stack, 0
	.set saveexec_ops.has_recursion, 0
	.set saveexec_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_saveexec_ops
	.globl	__clang_ocl_kern_imp_saveexec_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_saveexec_ops,@function
__clang_ocl_kern_imp_saveexec_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_mul_u32_u24_e32 v3, 0x50, v2
	v_lshlrev_b32_e32 v4, 2, v3
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[8:9], v[0:1], 0, v[4:5]
	v_readfirstlane_b32 s1, v1
	v_readfirstlane_b32 s0, v0
	v_and_b32_e32 v0, 1, v2
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[4:5], 0, v0
	;;#ASMEND
	;;#ASMSTART
	v_cmp_gt_u32_e64 s[2:3], 48, v2
	;;#ASMEND
	v_cmp_eq_u32_e32 vcc, 1, v0
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	v_mul_u32_u24_e32 v0, 0x140, v2
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off
	global_store_dword v[8:9], v1, off offset:16
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_or_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:20
	global_store_dword v[8:9], v1, off offset:36
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_xor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:40
	global_store_dword v[8:9], v1, off offset:56
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn2_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:60
	global_store_dword v[8:9], v1, off offset:76
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_orn2_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:80
	global_store_dword v[8:9], v1, off offset:96
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_nand_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:100
	global_store_dword v[8:9], v1, off offset:116
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_nor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:120
	global_store_dword v[8:9], v1, off offset:136
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_xnor_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:140
	global_store_dword v[8:9], v1, off offset:156
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn1_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:160
	global_store_dword v[8:9], v1, off offset:176
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_orn1_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:180
	global_store_dword v[8:9], v1, off offset:196
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn1_wrexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:200
	global_store_dword v[8:9], v1, off offset:216
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_andn2_wrexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:220
	global_store_dword v[8:9], v1, off offset:236
	;;#ASMSTART
	s_mov_b64 s[10:11], exec
	s_mov_b64 exec, s[2:3]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cselect_b32 s12, 1, 0
	s_mov_b64 s[8:9], exec
	s_mov_b64 exec, s[10:11]
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v4, s6
	v_mov_b32_e32 v5, s7
	v_mov_b32_e32 v6, s8
	v_mov_b32_e32 v7, s9
	v_mov_b32_e32 v1, s12
	global_store_dwordx4 v[8:9], v[4:7], off offset:240
	global_store_dword v[8:9], v1, off offset:256
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_2
	;;#ASMSTART
	global_store_dword v0, v2, s[0:1] offset:280
	;;#ASMEND
.LBB1_2:
	s_or_b64 exec, exec, s[2:3]
	;;#ASMSTART
	global_store_dword v0, v2, s[0:1] offset:284
	;;#ASMEND
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_saveexec_ops, .Lfunc_end1-__clang_ocl_kern_imp_saveexec_ops

	.set __clang_ocl_kern_imp_saveexec_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_saveexec_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_saveexec_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_saveexec_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_saveexec_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_saveexec_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_saveexec_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_saveexec_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_saveexec_ops.has_indirect_call, 0
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
    .name:           saveexec_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     19
    .sgpr_spill_count: 0
    .symbol:         saveexec_ops.kd
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
