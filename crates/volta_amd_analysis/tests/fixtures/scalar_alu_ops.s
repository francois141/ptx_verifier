	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	scalar_alu_ops
	.globl	scalar_alu_ops
	.p2align	8
	.type	scalar_alu_ops,@function
scalar_alu_ops:
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v4, 9, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	s_sub_u32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1]
	;;#ASMSTART
	s_cmp_eq_u32 s4, s4
	s_subb_u32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:8
	;;#ASMSTART
	s_min_i32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:16
	;;#ASMSTART
	s_min_u32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:24
	;;#ASMSTART
	s_max_u32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:32
	;;#ASMSTART
	s_or_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:40
	;;#ASMSTART
	s_andn2_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:48
	;;#ASMSTART
	s_orn2_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:56
	;;#ASMSTART
	s_nand_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:64
	;;#ASMSTART
	s_nor_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:72
	;;#ASMSTART
	s_xnor_b32 s2, s4, s5
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:80
	;;#ASMSTART
	s_cmp_lt_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_lt_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_lt_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:88
	;;#ASMSTART
	s_cmp_eq_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_eq_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_eq_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:100
	;;#ASMSTART
	s_cmp_le_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_le_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_le_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:112
	;;#ASMSTART
	s_cmp_gt_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_gt_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_gt_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:124
	;;#ASMSTART
	s_cmp_lg_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_lg_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:136
	;;#ASMSTART
	s_cmp_ge_i32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_ge_i32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_ge_i32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:148
	;;#ASMSTART
	s_cmp_lt_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_lt_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_lt_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:160
	;;#ASMSTART
	s_cmp_eq_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_eq_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_eq_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:172
	;;#ASMSTART
	s_cmp_le_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_le_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_le_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:184
	;;#ASMSTART
	s_cmp_gt_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_gt_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_gt_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:196
	;;#ASMSTART
	s_cmp_lg_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_lg_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:208
	;;#ASMSTART
	s_cmp_ge_u32 s4, s5
	s_cselect_b32 s2, 1, 0
	s_cmp_ge_u32 s4, s4
	s_cselect_b32 s3, 1, 0
	s_cmp_ge_u32 s5, s4
	s_cselect_b32 s12, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s12
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:220
	;;#ASMSTART
	s_bitcmp0_b32 s4, s6
	s_cselect_b32 s2, 1, 0
	s_bitcmp0_b32 s4, s7
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:232
	;;#ASMSTART
	s_bitcmp1_b32 s4, s6
	s_cselect_b32 s2, 1, 0
	s_bitcmp1_b32 s4, s7
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:240
	;;#ASMSTART
	s_xor_b64 s[2:3], s[8:9], s[10:11]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:248
	;;#ASMSTART
	s_orn2_b64 s[2:3], s[8:9], s[10:11]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:260
	;;#ASMSTART
	s_nand_b64 s[2:3], s[8:9], s[10:11]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:272
	;;#ASMSTART
	s_nor_b64 s[2:3], s[8:9], s[10:11]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:284
	;;#ASMSTART
	s_xnor_b64 s[2:3], s[8:9], s[10:11]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:296
	;;#ASMSTART
	s_lshl_b64 s[2:3], s[8:9], s6
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:308
	;;#ASMSTART
	s_lshr_b64 s[2:3], s[8:9], s6
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:320
	;;#ASMSTART
	s_ashr_i64 s[2:3], s[8:9], s6
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:332
	;;#ASMSTART
	s_cmp_eq_u64 s[8:9], s[10:11]
	s_cselect_b32 s2, 1, 0
	s_cmp_eq_u64 s[8:9], s[8:9]
	s_cselect_b32 s3, 1, 0
	s_cmp_eq_u64 s[10:11], s[8:9]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:344
	;;#ASMSTART
	s_cmp_lg_u64 s[8:9], s[10:11]
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u64 s[8:9], s[8:9]
	s_cselect_b32 s3, 1, 0
	s_cmp_lg_u64 s[10:11], s[8:9]
	s_cselect_b32 s5, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:356
	;;#ASMSTART
	s_bitcmp0_b64 s[8:9], s6
	s_cselect_b32 s2, 1, 0
	s_bitcmp0_b64 s[8:9], s7
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:368
	;;#ASMSTART
	s_bitcmp1_b64 s[8:9], s6
	s_cselect_b32 s2, 1, 0
	s_bitcmp1_b64 s[8:9], s7
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:376
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, 0
	s_cbranch_vccz .Lbranch_taken_0
	s_mov_b32 s2, 0
.Lbranch_taken_0:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:384
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, -1
	s_cbranch_vccz .Lbranch_taken_1
	s_mov_b32 s2, 0
.Lbranch_taken_1:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:388
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, 0
	s_cbranch_vccnz .Lbranch_taken_2
	s_mov_b32 s2, 0
.Lbranch_taken_2:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:392
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, -1
	s_cbranch_vccnz .Lbranch_taken_3
	s_mov_b32 s2, 0
.Lbranch_taken_3:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:396
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_nop 0
	s_cbranch_execz .Lbranch_taken_4
	s_mov_b32 s2, 0
.Lbranch_taken_4:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:400
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_nop 0
	s_cbranch_execnz .Lbranch_taken_5
	s_mov_b32 s2, 0
.Lbranch_taken_5:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	global_store_dword v4, v0, s[0:1] offset:404
	;;#ASMSTART
	s_mov_b64 s[2:3], 0x7fffffff
	;;#ASMEND
	s_nop 0
	v_mov_b64_e32 v[0:1], s[2:3]
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:408
	;;#ASMSTART
	s_and_b64 s[2:3], s[8:9], 0xffff00
	;;#ASMEND
	s_nop 0
	v_mov_b64_e32 v[0:1], s[2:3]
	global_store_dwordx2 v4, v[0:1], s[0:1] offset:416
	;;#ASMSTART
	s_not_b32 s2, s4
	s_cselect_b32 s3, 1, 0
	s_not_b32 s5, -1
	s_cselect_b32 s6, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s5
	v_mov_b32_e32 v3, s6
	global_store_dwordx4 v4, v[0:3], s[0:1] offset:424
	;;#ASMSTART
	s_not_b64 s[2:3], s[8:9]
	s_cselect_b32 s6, 1, 0
	s_not_b64 s[4:5], -1
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v0, s2
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s6
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:440
	s_nop 1
	v_mov_b32_e32 v0, s4
	v_mov_b32_e32 v1, s5
	v_mov_b32_e32 v2, s7
	global_store_dwordx3 v4, v[0:2], s[0:1] offset:452
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel scalar_alu_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
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
	.size	scalar_alu_ops, .Lfunc_end0-scalar_alu_ops

	.set scalar_alu_ops.num_vgpr, 5
	.set scalar_alu_ops.num_agpr, 0
	.set scalar_alu_ops.numbered_sgpr, 13
	.set scalar_alu_ops.private_seg_size, 0
	.set scalar_alu_ops.uses_vcc, 1
	.set scalar_alu_ops.uses_flat_scratch, 0
	.set scalar_alu_ops.has_dyn_sized_stack, 0
	.set scalar_alu_ops.has_recursion, 0
	.set scalar_alu_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_scalar_alu_ops
	.globl	__clang_ocl_kern_imp_scalar_alu_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_scalar_alu_ops,@function
__clang_ocl_kern_imp_scalar_alu_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v10, 0x3ff, v31
	v_lshlrev_b32_e32 v10, 9, v10
	v_mov_b32_e32 v11, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[10:11]
	v_readfirstlane_b32 s4, v2
	v_readfirstlane_b32 s7, v3
	;;#ASMSTART
	s_sub_u32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s5, v4
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off
	;;#ASMSTART
	s_cmp_eq_u32 s4, s4
	s_subb_u32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s6, v5
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:8
	;;#ASMSTART
	s_min_i32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s1, v7
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:16
	;;#ASMSTART
	s_min_u32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s0, v6
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:24
	;;#ASMSTART
	s_max_u32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s3, v9
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:32
	;;#ASMSTART
	s_or_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	v_readfirstlane_b32 s2, v8
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:40
	;;#ASMSTART
	s_andn2_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:48
	;;#ASMSTART
	s_orn2_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:56
	;;#ASMSTART
	s_nand_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:64
	;;#ASMSTART
	s_nor_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:72
	;;#ASMSTART
	s_xnor_b32 s8, s4, s7
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	global_store_dwordx2 v[0:1], v[2:3], off offset:80
	;;#ASMSTART
	s_cmp_lt_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_lt_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_lt_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:88
	;;#ASMSTART
	s_cmp_eq_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_eq_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_eq_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:100
	;;#ASMSTART
	s_cmp_le_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_le_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_le_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:112
	;;#ASMSTART
	s_cmp_gt_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_gt_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_gt_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:124
	;;#ASMSTART
	s_cmp_lg_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_lg_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_lg_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:136
	;;#ASMSTART
	s_cmp_ge_i32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_ge_i32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_ge_i32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:148
	;;#ASMSTART
	s_cmp_lt_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_lt_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_lt_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:160
	;;#ASMSTART
	s_cmp_eq_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_eq_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_eq_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:172
	;;#ASMSTART
	s_cmp_le_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_le_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_le_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:184
	;;#ASMSTART
	s_cmp_gt_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_gt_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_gt_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:196
	;;#ASMSTART
	s_cmp_lg_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_lg_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_lg_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:208
	;;#ASMSTART
	s_cmp_ge_u32 s4, s7
	s_cselect_b32 s8, 1, 0
	s_cmp_ge_u32 s4, s4
	s_cselect_b32 s9, 1, 0
	s_cmp_ge_u32 s7, s4
	s_cselect_b32 s10, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s10
	global_store_dwordx3 v[0:1], v[2:4], off offset:220
	;;#ASMSTART
	s_bitcmp0_b32 s4, s5
	s_cselect_b32 s7, 1, 0
	s_bitcmp0_b32 s4, s6
	s_cselect_b32 s8, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s7
	v_mov_b32_e32 v3, s8
	global_store_dwordx2 v[0:1], v[2:3], off offset:232
	;;#ASMSTART
	s_bitcmp1_b32 s4, s5
	s_cselect_b32 s7, 1, 0
	s_bitcmp1_b32 s4, s6
	s_cselect_b32 s8, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s7
	v_mov_b32_e32 v3, s8
	global_store_dwordx2 v[0:1], v[2:3], off offset:240
	;;#ASMSTART
	s_xor_b64 s[8:9], s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:248
	;;#ASMSTART
	s_orn2_b64 s[8:9], s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:260
	;;#ASMSTART
	s_nand_b64 s[8:9], s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:272
	;;#ASMSTART
	s_nor_b64 s[8:9], s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:284
	;;#ASMSTART
	s_xnor_b64 s[8:9], s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:296
	;;#ASMSTART
	s_lshl_b64 s[8:9], s[0:1], s5
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:308
	;;#ASMSTART
	s_lshr_b64 s[8:9], s[0:1], s5
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:320
	;;#ASMSTART
	s_ashr_i64 s[8:9], s[0:1], s5
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:332
	;;#ASMSTART
	s_cmp_eq_u64 s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	s_cmp_eq_u64 s[0:1], s[0:1]
	s_cselect_b32 s8, 1, 0
	s_cmp_eq_u64 s[2:3], s[0:1]
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s7
	v_mov_b32_e32 v3, s8
	v_mov_b32_e32 v4, s9
	global_store_dwordx3 v[0:1], v[2:4], off offset:344
	;;#ASMSTART
	s_cmp_lg_u64 s[0:1], s[2:3]
	s_cselect_b32 s7, 1, 0
	s_cmp_lg_u64 s[0:1], s[0:1]
	s_cselect_b32 s8, 1, 0
	s_cmp_lg_u64 s[2:3], s[0:1]
	s_cselect_b32 s9, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s7
	v_mov_b32_e32 v3, s8
	v_mov_b32_e32 v4, s9
	global_store_dwordx3 v[0:1], v[2:4], off offset:356
	;;#ASMSTART
	s_bitcmp0_b64 s[0:1], s5
	s_cselect_b32 s2, 1, 0
	s_bitcmp0_b64 s[0:1], s6
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s2
	v_mov_b32_e32 v3, s3
	global_store_dwordx2 v[0:1], v[2:3], off offset:368
	;;#ASMSTART
	s_bitcmp1_b64 s[0:1], s5
	s_cselect_b32 s2, 1, 0
	s_bitcmp1_b64 s[0:1], s6
	s_cselect_b32 s3, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	v_mov_b32_e32 v3, s3
	global_store_dwordx2 v[0:1], v[2:3], off offset:376
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, 0
	s_cbranch_vccz .Lbranch_taken_6
	s_mov_b32 s2, 0
.Lbranch_taken_6:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:384
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, -1
	s_cbranch_vccz .Lbranch_taken_7
	s_mov_b32 s2, 0
.Lbranch_taken_7:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:388
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, 0
	s_cbranch_vccnz .Lbranch_taken_8
	s_mov_b32 s2, 0
.Lbranch_taken_8:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:392
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_mov_b64 vcc, -1
	s_cbranch_vccnz .Lbranch_taken_9
	s_mov_b32 s2, 0
.Lbranch_taken_9:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:396
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_nop 0
	s_cbranch_execz .Lbranch_taken_10
	s_mov_b32 s2, 0
.Lbranch_taken_10:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:400
	;;#ASMSTART
	s_mov_b32 s2, 1
	s_nop 0
	s_cbranch_execnz .Lbranch_taken_11
	s_mov_b32 s2, 0
.Lbranch_taken_11:
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	global_store_dword v[0:1], v2, off offset:404
	;;#ASMSTART
	s_mov_b64 s[2:3], 0x7fffffff
	;;#ASMEND
	s_nop 0
	v_mov_b64_e32 v[2:3], s[2:3]
	global_store_dwordx2 v[0:1], v[2:3], off offset:408
	;;#ASMSTART
	s_and_b64 s[2:3], s[0:1], 0xffff00
	;;#ASMEND
	s_nop 0
	v_mov_b64_e32 v[2:3], s[2:3]
	global_store_dwordx2 v[0:1], v[2:3], off offset:416
	;;#ASMSTART
	s_not_b32 s2, s4
	s_cselect_b32 s3, 1, 0
	s_not_b32 s5, -1
	s_cselect_b32 s6, 1, 0
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v2, s2
	v_mov_b32_e32 v3, s3
	v_mov_b32_e32 v4, s5
	v_mov_b32_e32 v5, s6
	global_store_dwordx4 v[0:1], v[2:5], off offset:424
	;;#ASMSTART
	s_not_b64 s[2:3], s[0:1]
	s_cselect_b32 s6, 1, 0
	s_not_b64 s[4:5], -1
	s_cselect_b32 s7, 1, 0
	;;#ASMEND
	s_nop 1
	v_mov_b32_e32 v2, s2
	v_mov_b32_e32 v3, s3
	v_mov_b32_e32 v4, s6
	global_store_dwordx3 v[0:1], v[2:4], off offset:440
	s_nop 1
	v_mov_b32_e32 v2, s4
	v_mov_b32_e32 v3, s5
	v_mov_b32_e32 v4, s7
	global_store_dwordx3 v[0:1], v[2:4], off offset:452
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_scalar_alu_ops, .Lfunc_end1-__clang_ocl_kern_imp_scalar_alu_ops

	.set __clang_ocl_kern_imp_scalar_alu_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_scalar_alu_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_scalar_alu_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_scalar_alu_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_scalar_alu_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_scalar_alu_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_scalar_alu_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_scalar_alu_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_scalar_alu_ops.has_indirect_call, 0
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
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         24
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         32
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           scalar_alu_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     19
    .sgpr_spill_count: 0
    .symbol:         scalar_alu_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
