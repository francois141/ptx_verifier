	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	vector_int_ops
	.globl	vector_int_ops
	.p2align	8
	.type	vector_int_ops,@function
vector_int_ops:
	s_load_dwordx4 s[12:15], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x10
	s_load_dwordx2 s[0:1], s[0:1], 0x30
	v_lshlrev_b32_e32 v8, 8, v0
	v_or_b32_e32 v1, 0x10000, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	v_mul_lo_u32 v2, v1, s14
	;;#ASMEND
	global_store_dword v8, v2, s[12:13]
	;;#ASMSTART
	v_mul_lo_u32 v2, s14, v1
	;;#ASMEND
	global_store_dword v8, v2, s[12:13] offset:4
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v2, -1, 0
	;;#ASMEND
	v_not_b32_e32 v6, v0
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v3, -1, v2
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:8
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v2, s15, 7
	;;#ASMEND
	v_add_u32_e32 v9, -16, v0
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v3, s15, v2
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:16
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:24
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], -1
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:32
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], s[4:5]
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:40
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:48
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[6:7], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:52
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:56
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[10:11], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:60
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:64
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:68
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:72
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:76
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:80
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:84
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:88
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:92
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:96
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:100
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:104
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:108
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:112
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[8:9], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:116
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:120
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[4:5], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v8, v4, s[12:13] offset:124
	;;#ASMSTART
	v_mul_hi_u32 v2, v1, s15
	;;#ASMEND
	global_store_dword v8, v2, s[12:13] offset:128
	;;#ASMSTART
	v_mul_hi_i32 v2, v1, s15
	;;#ASMEND
	global_store_dword v8, v2, s[12:13] offset:132
	;;#ASMSTART
	v_bcnt_u32_b32 v2, v1, 7
	;;#ASMEND
	global_store_dword v8, v2, s[12:13] offset:136
	v_or_b32_e32 v2, 0x20000, v0
	v_or_b32_e32 v3, 0x30000, v0
	;;#ASMSTART
	v_pk_mov_b32 v[4:5], v[0:1], v[2:3]
	;;#ASMEND
	global_store_dwordx2 v8, v[4:5], s[12:13] offset:140
	;;#ASMSTART
	v_pk_mov_b32 v[4:5], v[0:1], v[2:3] op_sel:[0,1]
	;;#ASMEND
	global_store_dwordx2 v8, v[4:5], s[12:13] offset:148
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], v[0:1], v[2:3] op_sel:[1,1]
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:156
	v_mov_b64_e32 v[2:3], v[0:1]
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], v[2:3], v[2:3] op_sel:[1,0]
	;;#ASMEND
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:164
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], s[4:5], s[4:5] op_sel:[0,1]
	;;#ASMEND
	s_mov_b32 s0, 0x80000003
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:172
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], -2, 64
	;;#ASMEND
	v_mov_b32_e32 v1, 0
	s_mov_b32 s1, 1
	global_store_dwordx2 v8, v[2:3], s[12:13] offset:180
	v_lshl_add_u64 v[4:5], v[0:1], 0, s[0:1]
	v_mov_b32_e32 v7, v1
	v_and_b32_e32 v1, 3, v0
	v_lshrrev_b32_e32 v2, 5, v0
	v_add_u32_e32 v1, v1, v2
	v_add_u32_e32 v2, 30, v0
	;;#ASMSTART
	v_lshlrev_b64 v[2:3], v2, v[4:5]
	;;#ASMEND
	;;#ASMSTART
	v_lshl_add_u64 v[4:5], v[4:5], v1, v[6:7]
	;;#ASMEND
	global_store_dwordx4 v8, v[2:5], s[12:13] offset:188
	v_add_u32_e32 v10, -12, v0
	v_mov_b32_e32 v11, 32
	v_mov_b32_e32 v12, -8
	;;#ASMSTART
	v_add_co_u32_e32 v4, vcc, v9, v11
	v_addc_co_u32_e32 v5, vcc, v10, v12, vcc
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_sub_co_u32_e64 v7, s[0:1], v11, v9
	v_subb_co_u32_e64 v0, s[0:1], v12, v10, s[0:1]
	v_cndmask_b32_e64 v1, 0, 1, s[0:1]
	v_subrev_co_u32_e32 v2, vcc, v9, v11
	v_subbrev_co_u32_e32 v3, vcc, v10, v12, vcc
	v_cndmask_b32_e64 v13, 0, 1, vcc
	;;#ASMEND
	global_store_dwordx4 v8, v[4:7], s[12:13] offset:204
	global_store_dwordx4 v8, v[0:3], s[12:13] offset:220
	global_store_dword v8, v13, s[12:13] offset:236
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel vector_int_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 56
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
		.amdhsa_next_free_sgpr 16
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
	.size	vector_int_ops, .Lfunc_end0-vector_int_ops

	.set vector_int_ops.num_vgpr, 14
	.set vector_int_ops.num_agpr, 0
	.set vector_int_ops.numbered_sgpr, 16
	.set vector_int_ops.private_seg_size, 0
	.set vector_int_ops.uses_vcc, 1
	.set vector_int_ops.uses_flat_scratch, 0
	.set vector_int_ops.has_dyn_sized_stack, 0
	.set vector_int_ops.has_recursion, 0
	.set vector_int_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_vector_int_ops
	.globl	__clang_ocl_kern_imp_vector_int_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_vector_int_ops,@function
__clang_ocl_kern_imp_vector_int_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v14, 0x3ff, v31
	v_lshlrev_b32_e32 v16, 8, v14
	v_mov_b32_e32 v17, 0
	v_lshl_add_u64 v[18:19], v[0:1], 0, v[16:17]
	v_readfirstlane_b32 s0, v2
	v_or_b32_e32 v15, 0x10000, v14
	;;#ASMSTART
	v_mul_lo_u32 v0, v15, s0
	;;#ASMEND
	global_store_dword v[18:19], v0, off
	;;#ASMSTART
	v_mul_lo_u32 v0, s0, v15
	;;#ASMEND
	global_store_dword v[18:19], v0, off offset:4
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v0, -1, 0
	;;#ASMEND
	v_readfirstlane_b32 s6, v3
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v1, -1, v0
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:8
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v0, s6, 7
	;;#ASMEND
	v_readfirstlane_b32 s1, v5
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v1, s6, v0
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:16
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:24
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], -1
	;;#ASMEND
	v_readfirstlane_b32 s0, v4
	global_store_dwordx2 v[18:19], v[0:1], off offset:32
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:40
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:48
	v_readfirstlane_b32 s3, v7
	v_readfirstlane_b32 s2, v6
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:52
	v_readfirstlane_b32 s3, v9
	v_readfirstlane_b32 s2, v8
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:56
	v_readfirstlane_b32 s5, v11
	v_readfirstlane_b32 s4, v10
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:60
	v_readfirstlane_b32 s5, v13
	v_readfirstlane_b32 s4, v12
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:64
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:68
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:72
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_eq_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:76
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:80
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:84
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_le_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:88
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:92
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:96
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_gt_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:100
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:104
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:108
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ne_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:112
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[2:3], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:116
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:120
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_ge_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v2, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[18:19], v2, off offset:124
	;;#ASMSTART
	v_mul_hi_u32 v0, v15, s6
	;;#ASMEND
	global_store_dword v[18:19], v0, off offset:128
	;;#ASMSTART
	v_mul_hi_i32 v0, v15, s6
	;;#ASMEND
	global_store_dword v[18:19], v0, off offset:132
	;;#ASMSTART
	v_bcnt_u32_b32 v0, v15, 7
	;;#ASMEND
	global_store_dword v[18:19], v0, off offset:136
	v_or_b32_e32 v0, 0x20000, v14
	v_or_b32_e32 v1, 0x30000, v14
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], v[14:15], v[0:1]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[2:3], off offset:140
	;;#ASMSTART
	v_pk_mov_b32 v[2:3], v[14:15], v[0:1] op_sel:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[2:3], off offset:148
	;;#ASMSTART
	v_pk_mov_b32 v[0:1], v[14:15], v[0:1] op_sel:[1,1]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:156
	v_mov_b64_e32 v[0:1], v[14:15]
	;;#ASMSTART
	v_pk_mov_b32 v[0:1], v[0:1], v[0:1] op_sel:[1,0]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:164
	;;#ASMSTART
	v_pk_mov_b32 v[0:1], s[0:1], s[0:1] op_sel:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[18:19], v[0:1], off offset:172
	;;#ASMSTART
	v_pk_mov_b32 v[0:1], -2, 64
	;;#ASMEND
	s_mov_b32 s0, 0x80000003
	global_store_dwordx2 v[18:19], v[0:1], off offset:180
	v_mov_b32_e32 v15, v17
	s_mov_b32 s1, 1
	v_and_b32_e32 v0, 3, v14
	v_lshrrev_b32_e32 v1, 5, v14
	v_lshl_add_u64 v[2:3], v[14:15], 0, s[0:1]
	v_add_u32_e32 v4, v0, v1
	v_add_u32_e32 v0, 30, v14
	v_not_b32_e32 v16, v14
	;;#ASMSTART
	v_lshlrev_b64 v[0:1], v0, v[2:3]
	;;#ASMEND
	;;#ASMSTART
	v_lshl_add_u64 v[2:3], v[2:3], v4, v[16:17]
	;;#ASMEND
	global_store_dwordx4 v[18:19], v[0:3], off offset:188
	v_add_u32_e32 v8, -16, v14
	v_add_u32_e32 v9, -12, v14
	v_mov_b32_e32 v10, 32
	v_mov_b32_e32 v11, -8
	;;#ASMSTART
	v_add_co_u32_e32 v4, vcc, v8, v10
	v_addc_co_u32_e32 v5, vcc, v9, v11, vcc
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_sub_co_u32_e64 v7, s[0:1], v10, v8
	v_subb_co_u32_e64 v0, s[0:1], v11, v9, s[0:1]
	v_cndmask_b32_e64 v1, 0, 1, s[0:1]
	v_subrev_co_u32_e32 v2, vcc, v8, v10
	v_subbrev_co_u32_e32 v3, vcc, v9, v11, vcc
	v_cndmask_b32_e64 v12, 0, 1, vcc
	;;#ASMEND
	global_store_dwordx4 v[18:19], v[4:7], off offset:204
	global_store_dwordx4 v[18:19], v[0:3], off offset:220
	global_store_dword v[18:19], v12, off offset:236
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_vector_int_ops, .Lfunc_end1-__clang_ocl_kern_imp_vector_int_ops

	.set __clang_ocl_kern_imp_vector_int_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_vector_int_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_vector_int_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_vector_int_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_vector_int_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_vector_int_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_indirect_call, 0
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
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .type_name:      uint
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
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         48
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 56
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           vector_int_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         vector_int_ops.kd
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
