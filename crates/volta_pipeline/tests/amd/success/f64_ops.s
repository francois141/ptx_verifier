	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	f64_ops
	.globl	f64_ops
	.p2align	8
	.type	f64_ops,@function
f64_ops:
	s_load_dwordx8 s[4:11], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshlrev_b32_e32 v9, 8, v0
	v_lshlrev_b32_e32 v10, 5, v0
	v_subrev_u32_e32 v11, 32, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v6, v1, s[8:9]
	global_load_dword v7, v1, s[6:7]
	global_load_dword v8, v1, s[4:5]
	v_add_u32_e32 v12, 7, v0
	s_load_dwordx4 s[0:3], s[0:1], 0x20
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_add_f64 v[0:1], v[0:1], v[2:3]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11]
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_mul_f64 v[0:1], v[0:1], v[2:3]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:4
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_min_f64 v[0:1], v[0:1], v[2:3]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:8
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_max_f64 v[0:1], v[0:1], v[2:3]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:12
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_fma_f64 v[0:1], v[0:1], v[2:3], v[4:5]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:16
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_rcp_f64_e32 v[0:1], v[0:1]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:20
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_sqrt_f64_e32 v[0:1], v[0:1]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:24
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_rsq_f64_e32 v[0:1], v[0:1]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:28
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_rcp_f64_e64 v[0:1], -v[0:1]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:32
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_add_f64 v[0:1], -|v[0:1]|, |v[2:3]|
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:36
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_fma_f64 v[0:1], -v[0:1], |v[2:3]|, -|v[4:5]|
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:40
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_mov_b64_e32 v[4:5], v[0:1]
	v_mov_b64_e32 v[0:1], v[4:5]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:44
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_pk_mov_b32 v[4:5], v[0:1], v[0:1] op_sel:[0,1]
	v_mov_b64_e32 v[0:1], v[4:5]
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:48
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_mul_f64 v[0:1], v[0:1], 2.0
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:52
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cvt_f64_f32_e32 v[4:5], v6
	v_add_f64 v[0:1], v[0:1], 0
	v_cvt_f32_f64_e32 v13, v[0:1]
	;;#ASMEND
	global_store_dword v9, v13, s[10:11] offset:56
	;;#ASMSTART
	v_cvt_f64_f32_e64 v[0:1], -|v8|
	v_cvt_f32_f64_e64 v2, -v[0:1]
	;;#ASMEND
	global_store_dword v9, v2, s[10:11] offset:60
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	v_mov_b32_e32 v2, v8
	v_cvt_f64_f32_e32 v[2:3], v2
	v_mul_f64 v[2:3], v[2:3], s[2:3]
	v_cvt_f32_f64_e32 v2, v[2:3]
	v_mov_b32_e32 v0, v2
	;;#ASMEND
	global_store_dword v9, v0, s[10:11] offset:64
	;;#ASMSTART
	v_mov_b32_e32 v2, 0xff800000
	v_cvt_f64_f32_e32 v[2:3], v2
	v_mul_f64 v[2:3], v[2:3], s[2:3]
	v_cvt_f32_f64_e32 v0, v[2:3]
	;;#ASMEND
	global_store_dword v9, v0, s[10:11] offset:68
	;;#ASMSTART
	v_cvt_f32_f64_e32 v0, 0x40000000
	;;#ASMEND
	global_store_dword v9, v0, s[10:11] offset:72
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], s[2:3]
	v_cvt_f32_f64_e32 v2, v[0:1]
	;;#ASMEND
	global_store_dword v9, v2, s[10:11] offset:76
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_lt_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_lt_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:80
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_eq_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_eq_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:88
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_le_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_le_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:96
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_gt_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_gt_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:104
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_lg_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_lg_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:112
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_ge_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_ge_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:120
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_nge_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_nge_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:128
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_nlg_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_nlg_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:136
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_ngt_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_ngt_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:144
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_nle_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_nle_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:152
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_neq_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_neq_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:160
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[0:1], v8
	v_cvt_f64_f32_e32 v[2:3], v7
	v_cmp_nlt_f64_e32 vcc, v[0:1], v[2:3]
	v_cndmask_b32_e64 v4, v8, v7, vcc
	v_cmp_nlt_f64_e64 s[2:3], |v[0:1]|, v[2:3]
	v_cndmask_b32_e64 v5, v8, v7, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v9, v[4:5], s[10:11] offset:168
	;;#ASMSTART
	v_cvt_f64_i32_e32 v[0:1], v11
	v_cvt_i32_f64_e32 v2, v[0:1]
	;;#ASMEND
	global_store_dword v10, v2, s[0:1]
	;;#ASMSTART
	v_cvt_f64_u32_e32 v[0:1], v12
	v_cvt_u32_f64_e32 v2, v[0:1]
	;;#ASMEND
	global_store_dword v10, v2, s[0:1] offset:4
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0x40040000
	;;#ASMEND
	global_store_dword v10, v0, s[0:1] offset:8
	;;#ASMSTART
	v_cvt_u32_f64_e32 v0, -4.0
	;;#ASMEND
	global_store_dword v10, v0, s[0:1] offset:12
	;;#ASMSTART
	v_cvt_f64_i32_e64 v[0:1], v11
	v_cvt_i32_f64_e64 v2, -v[0:1]
	;;#ASMEND
	global_store_dword v10, v2, s[0:1] offset:16
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0x41f00000
	;;#ASMEND
	global_store_dword v10, v0, s[0:1] offset:20
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0xc1f00000
	;;#ASMEND
	global_store_dword v10, v0, s[0:1] offset:24
	;;#ASMSTART
	v_cvt_u32_f64_e32 v0, 0x41f00000
	;;#ASMEND
	global_store_dword v10, v0, s[0:1] offset:28
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel f64_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 48
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
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 16
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
	.size	f64_ops, .Lfunc_end0-f64_ops

	.set f64_ops.num_vgpr, 14
	.set f64_ops.num_agpr, 0
	.set f64_ops.numbered_sgpr, 12
	.set f64_ops.private_seg_size, 0
	.set f64_ops.uses_vcc, 1
	.set f64_ops.uses_flat_scratch, 0
	.set f64_ops.has_dyn_sized_stack, 0
	.set f64_ops.has_recursion, 0
	.set f64_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_f64_ops
	.globl	__clang_ocl_kern_imp_f64_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_f64_ops,@function
__clang_ocl_kern_imp_f64_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v14, 0x3ff, v31
	v_lshlrev_b32_e32 v12, 2, v14
	v_mov_b32_e32 v13, 0
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[12:13]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[12:13]
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[12:13]
	global_load_dword v15, v[4:5], off
	global_load_dword v16, v[2:3], off
	global_load_dword v17, v[0:1], off
	v_lshlrev_b32_e32 v12, 8, v14
	v_lshl_add_u64 v[0:1], v[6:7], 0, v[12:13]
	v_lshlrev_b32_e32 v12, 5, v14
	v_lshl_add_u64 v[4:5], v[8:9], 0, v[12:13]
	v_readfirstlane_b32 s1, v11
	v_readfirstlane_b32 s0, v10
	v_subrev_u32_e32 v10, 32, v14
	v_add_u32_e32 v11, 7, v14
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_add_f64 v[2:3], v[2:3], v[6:7]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_mul_f64 v[2:3], v[2:3], v[6:7]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:4
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_min_f64 v[2:3], v[2:3], v[6:7]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:8
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_max_f64 v[2:3], v[2:3], v[6:7]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:12
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_fma_f64 v[2:3], v[2:3], v[6:7], v[8:9]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:16
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_rcp_f64_e32 v[2:3], v[2:3]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:20
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_sqrt_f64_e32 v[2:3], v[2:3]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:24
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_rsq_f64_e32 v[2:3], v[2:3]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:28
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_rcp_f64_e64 v[2:3], -v[2:3]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:32
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_add_f64 v[2:3], -|v[2:3]|, |v[6:7]|
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:36
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_fma_f64 v[2:3], -v[2:3], |v[6:7]|, -|v[8:9]|
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:40
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_mov_b64_e32 v[8:9], v[2:3]
	v_mov_b64_e32 v[2:3], v[8:9]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:44
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_pk_mov_b32 v[8:9], v[2:3], v[2:3] op_sel:[0,1]
	v_mov_b64_e32 v[2:3], v[8:9]
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:48
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_mul_f64 v[2:3], v[2:3], 2.0
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:52
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cvt_f64_f32_e32 v[8:9], v15
	v_add_f64 v[2:3], v[2:3], 0
	v_cvt_f32_f64_e32 v12, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v12, off offset:56
	;;#ASMSTART
	v_cvt_f64_f32_e64 v[2:3], -|v17|
	v_cvt_f32_f64_e64 v6, -v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v6, off offset:60
	;;#ASMSTART
	v_mov_b32_e32 v2, v17
	v_cvt_f64_f32_e32 v[2:3], v2
	v_mul_f64 v[2:3], v[2:3], s[0:1]
	v_cvt_f32_f64_e32 v2, v[2:3]
	v_mov_b32_e32 v6, v2
	;;#ASMEND
	global_store_dword v[0:1], v6, off offset:64
	;;#ASMSTART
	v_mov_b32_e32 v2, 0xff800000
	v_cvt_f64_f32_e32 v[2:3], v2
	v_mul_f64 v[2:3], v[2:3], s[0:1]
	v_cvt_f32_f64_e32 v6, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v6, off offset:68
	;;#ASMSTART
	v_cvt_f32_f64_e32 v2, 0x40000000
	;;#ASMEND
	global_store_dword v[0:1], v2, off offset:72
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], s[0:1]
	v_cvt_f32_f64_e32 v6, v[2:3]
	;;#ASMEND
	global_store_dword v[0:1], v6, off offset:76
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_lt_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_lt_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:80
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_eq_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_eq_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:88
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_le_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_le_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:96
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_gt_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_gt_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:104
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_lg_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_lg_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:112
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_ge_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_ge_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:120
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_nge_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_nge_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:128
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_nlg_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_nlg_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:136
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_ngt_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_ngt_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:144
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_nle_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_nle_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:152
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_neq_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_neq_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:160
	;;#ASMSTART
	v_cvt_f64_f32_e32 v[2:3], v17
	v_cvt_f64_f32_e32 v[6:7], v16
	v_cmp_nlt_f64_e32 vcc, v[2:3], v[6:7]
	v_cndmask_b32_e64 v8, v17, v16, vcc
	v_cmp_nlt_f64_e64 s[0:1], |v[2:3]|, v[6:7]
	v_cndmask_b32_e64 v9, v17, v16, s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[8:9], off offset:168
	;;#ASMSTART
	v_cvt_f64_i32_e32 v[0:1], v10
	v_cvt_i32_f64_e32 v2, v[0:1]
	;;#ASMEND
	global_store_dword v[4:5], v2, off
	;;#ASMSTART
	v_cvt_f64_u32_e32 v[0:1], v11
	v_cvt_u32_f64_e32 v2, v[0:1]
	;;#ASMEND
	global_store_dword v[4:5], v2, off offset:4
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0x40040000
	;;#ASMEND
	global_store_dword v[4:5], v0, off offset:8
	;;#ASMSTART
	v_cvt_u32_f64_e32 v0, -4.0
	;;#ASMEND
	global_store_dword v[4:5], v0, off offset:12
	;;#ASMSTART
	v_cvt_f64_i32_e64 v[0:1], v10
	v_cvt_i32_f64_e64 v2, -v[0:1]
	;;#ASMEND
	global_store_dword v[4:5], v2, off offset:16
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0x41f00000
	;;#ASMEND
	global_store_dword v[4:5], v0, off offset:20
	;;#ASMSTART
	v_cvt_i32_f64_e32 v0, 0xc1f00000
	;;#ASMEND
	global_store_dword v[4:5], v0, off offset:24
	;;#ASMSTART
	v_cvt_u32_f64_e32 v0, 0x41f00000
	;;#ASMEND
	global_store_dword v[4:5], v0, off offset:28
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_f64_ops, .Lfunc_end1-__clang_ocl_kern_imp_f64_ops

	.set __clang_ocl_kern_imp_f64_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_f64_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_f64_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_f64_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_f64_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_f64_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_f64_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_f64_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_f64_ops.has_indirect_call, 0
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
        .is_const:       true
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .offset:         40
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 48
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           f64_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         f64_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
