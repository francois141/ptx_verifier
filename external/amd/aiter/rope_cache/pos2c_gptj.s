	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,"axG",@progbits,_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,comdat
	.protected	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
	.globl	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
	.p2align	8
	.type	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,@function
_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mov_b64 s[28:29], s[6:7]
	s_mov_b64 s[44:45], s[2:3]
	s_load_dwordx2 s[18:19], s[0:1], 0x8c
	s_load_dword s2, s[0:1], 0x94
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s3, s19
	v_cvt_f32_u32_e32 v1, s3
	s_lshl_b32 s6, s16, 8
	v_rcp_iflag_f32_e32 v2, v1
	v_or_b32_e32 v1, s6, v0
	s_xor_b32 s6, s6, s19
	s_ashr_i32 s6, s6, 31
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_sub_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	s_sub_i32 s7, 0, s3
	v_mul_lo_u32 v4, s7, v2
	v_mul_hi_u32 v4, v2, v4
	v_add_u32_e32 v2, v2, v4
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v4, v2, s3
	v_sub_u32_e32 v3, v3, v4
	v_add_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_subrev_u32_e32 v4, s3, v3
	v_cndmask_b32_e32 v3, v3, v4, vcc
	v_add_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_xor_b32_e32 v2, s6, v2
	v_subrev_u32_e32 v6, s6, v2
	v_cmp_gt_i32_e32 vcc, s2, v6
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_36
	s_mov_b64 s[48:49], s[10:11]
	s_abs_i32 s3, s18
	v_cvt_f32_u32_e32 v2, s3
	v_rcp_iflag_f32_e32 v2, v2
	v_ashrrev_i32_e32 v3, 31, v6
	s_ashr_i32 s6, s18, 31
	v_sub_u32_e32 v4, 0, v6
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_xor_b32_e32 v3, s6, v3
	v_max_i32_e32 v4, v6, v4
	s_sub_i32 s7, 0, s3
	v_readfirstlane_b32 s10, v2
	s_mul_i32 s7, s7, s10
	s_mul_hi_u32 s7, s10, s7
	s_add_i32 s10, s10, s7
	v_mul_hi_u32 v2, v4, s10
	v_mul_lo_u32 v5, v2, s3
	v_add_u32_e32 v7, 1, v2
	v_sub_u32_e32 v4, v4, v5
	v_cmp_le_u32_e32 vcc, s3, v4
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v7, vcc
	v_subrev_u32_e32 v5, s3, v4
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_add_u32_e32 v5, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v4
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v5, vcc
	v_xor_b32_e32 v2, v2, v3
	v_sub_u32_e32 v2, v2, v3
	v_mul_lo_u32 v3, v2, s18
	v_sub_u32_e32 v3, v6, v3
	s_ashr_i32 s7, s2, 31
	s_xor_b32 s6, s7, s6
	s_abs_i32 s2, s2
	s_mul_hi_u32 s7, s2, s10
	s_mul_i32 s10, s7, s3
	s_sub_i32 s2, s2, s10
	s_add_i32 s10, s7, 1
	s_sub_i32 s11, s2, s3
	s_cmp_ge_u32 s2, s3
	s_cselect_b32 s7, s10, s7
	s_cselect_b32 s2, s11, s2
	s_add_i32 s10, s7, 1
	s_cmp_ge_u32 s2, s3
	s_cselect_b32 s2, s10, s7
	s_xor_b32 s2, s2, s6
	s_sub_i32 s2, s2, s6
	v_mad_u64_u32 v[4:5], s[2:3], s2, v3, v[2:3]
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[4:5], v[4:5], 3, s[14:15]
	global_load_dwordx2 v[4:5], v[4:5], off
	s_load_dwordx8 s[20:27], s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s2, s20
	s_ashr_i32 s3, s20, 31
	s_waitcnt vmcnt(0)
	v_cmp_lt_i64_e32 vcc, -1, v[4:5]
	v_cmp_gt_i64_e64 s[2:3], s[2:3], v[4:5]
	s_and_b64 s[2:3], vcc, s[2:3]
	s_and_b64 exec, exec, s[2:3]
	s_cbranch_execz .LBB0_36
	v_mul_lo_u32 v17, v6, s19
	v_sub_u32_e32 v18, v1, v17
	s_lshl_b32 s18, s24, 1
	s_and_b32 s49, s49, 0xffff
	s_mov_b32 s51, 0x20000
	s_mov_b32 s50, -1
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s50
	s_mov_b32 s15, s51
	v_mul_lo_u32 v1, s18, v4
	v_lshl_add_u32 v1, v18, 2, v1
	buffer_load_dword v4, v1, s[48:51], 0 offen
	buffer_load_dword v1, v1, s[12:15], 0 offen
	s_load_dwordx8 s[36:43], s[0:1], 0x5c
	s_load_dwordx4 s[0:3], s[0:1], 0x7c
	v_mul_lo_u32 v19, v3, s25
	v_mul_lo_u32 v31, v2, s26
	s_min_i32 s17, s21, s22
	s_and_b32 s29, s29, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_and_b32 s45, s45, 0xffff
	s_and_b32 s5, s5, 0xffff
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s3, 0
	v_lshlrev_b32_e32 v27, 3, v0
	v_add_u32_e32 v30, v31, v19
	s_mov_b32 s30, s50
	s_mov_b32 s31, s51
	s_cmp_lt_i32 s17, 2
	v_lshlrev_b32_e32 v28, 3, v17
	v_lshlrev_b32_e32 v15, 1, v31
	v_mul_lo_u32 v20, v3, s36
	v_mul_lo_u32 v25, v2, s37
	v_mul_lo_u32 v21, v3, s40
	v_mul_lo_u32 v32, v2, s41
	v_mul_lo_u32 v22, v3, s0
	v_mul_lo_u32 v26, v2, s1
	v_add_u32_e32 v24, v25, v20
	v_add_u32_e32 v29, v32, v21
	v_add_u32_e32 v23, v26, v22
	v_lshlrev_b32_e32 v14, 1, v25
	v_lshlrev_b32_e32 v16, 1, v32
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v2, 16, v4
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v6, 16, v1
	v_and_b32_e32 v4, 0xffff0000, v4
	v_and_b32_e32 v8, 0xffff0000, v1
	v_lshlrev_b32_e32 v1, 1, v26
	s_cbranch_scc1 .LBB0_5
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v9, v8
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v7, v6
	v_lshl_or_b32 v10, s16, 11, v27
	v_sub_u32_e32 v33, v10, v28
	v_add_lshl_u32 v34, v30, s27, 1
	v_add_u32_e32 v35, 4, v34
	s_lshl_b32 s0, s27, 2
	v_lshl_add_u32 v36, v19, 1, v15
	v_add_lshl_u32 v37, v24, s38, 1
	s_lshl_b32 s1, s38, 2
	v_lshl_add_u32 v38, v20, 1, v14
	v_add_lshl_u32 v39, v29, s42, 1
	s_lshl_b32 s12, s42, 2
	v_lshl_add_u32 v40, v21, 1, v16
	v_add_lshl_u32 v41, v23, s2, 1
	s_lshl_b32 s13, s2, 2
	v_lshl_add_u32 v42, v22, 1, v1
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
.LBB0_4:
	v_add_u32_e32 v10, v33, v36
	buffer_load_dwordx2 v[44:45], v10, s[28:31], 0 offen
	v_add_u32_e32 v10, v33, v38
	buffer_load_dwordx2 v[12:13], v10, s[8:11], 0 offen
	v_add_u32_e32 v10, v33, v34
	buffer_load_dword v43, v10, s[28:31], 0 offen
	v_add_u32_e32 v10, v33, v35
	buffer_load_dword v52, v10, s[28:31], 0 offen
	v_add_u32_e32 v10, v33, v37
	buffer_load_dwordx2 v[10:11], v10, s[8:11], 0 offen
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v47, 0xffff0000, v44
	v_lshlrev_b32_e32 v46, 16, v44
	v_pk_mul_f32 v[48:49], v[6:7], v[46:47]
	s_nop 0
	v_pk_fma_f32 v[50:51], v[2:3], v[46:47], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[46:47], v[2:3], v[46:47], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v44, v50, v47
	v_and_b32_e32 v47, 0xffff0000, v45
	v_lshlrev_b32_e32 v46, 16, v45
	v_pk_mul_f32 v[48:49], v[8:9], v[46:47]
	s_nop 0
	v_pk_fma_f32 v[50:51], v[4:5], v[46:47], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[46:47], v[4:5], v[46:47], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v45, v50, v47
	v_add_u32_e32 v46, v33, v40
	buffer_store_dwordx2 v[44:45], v46, s[44:47], 0 offen
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v45, 0xffff0000, v12
	v_lshlrev_b32_e32 v44, 16, v12
	v_pk_mul_f32 v[46:47], v[6:7], v[44:45]
	s_nop 0
	v_pk_fma_f32 v[48:49], v[2:3], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[44:45], v[2:3], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v12, v48, v45
	v_and_b32_e32 v45, 0xffff0000, v13
	v_lshlrev_b32_e32 v44, 16, v13
	v_pk_mul_f32 v[46:47], v[8:9], v[44:45]
	s_nop 0
	v_pk_fma_f32 v[48:49], v[4:5], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[44:45], v[4:5], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v13, v48, v45
	v_add_u32_e32 v44, v33, v42
	buffer_store_dwordx2 v[12:13], v44, s[4:7], 0 offen
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v13, 0xffff0000, v43
	v_lshlrev_b32_e32 v12, 16, v43
	v_pk_mul_f32 v[44:45], v[6:7], v[12:13]
	s_nop 0
	v_pk_fma_f32 v[46:47], v[2:3], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[12:13], v[2:3], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v12, v46, v13
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v45, 0xffff0000, v52
	v_lshlrev_b32_e32 v44, 16, v52
	v_pk_mul_f32 v[46:47], v[8:9], v[44:45]
	s_nop 0
	v_pk_fma_f32 v[48:49], v[4:5], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[44:45], v[4:5], v[44:45], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v13, v48, v45
	v_add_u32_e32 v43, v33, v39
	buffer_store_dwordx2 v[12:13], v43, s[44:47], 0 offen
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v13, 0xffff0000, v10
	v_lshlrev_b32_e32 v12, 16, v10
	v_pk_mul_f32 v[44:45], v[6:7], v[12:13]
	s_nop 0
	v_pk_fma_f32 v[46:47], v[2:3], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[12:13], v[2:3], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v10, v46, v13
	v_and_b32_e32 v13, 0xffff0000, v11
	v_lshlrev_b32_e32 v12, 16, v11
	v_pk_mul_f32 v[44:45], v[8:9], v[12:13]
	s_nop 0
	v_pk_fma_f32 v[46:47], v[4:5], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[12:13], v[4:5], v[12:13], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	s_nop 0
	v_cvt_pk_bf16_f32 v11, v46, v13
	v_add_u32_e32 v12, v33, v41
	buffer_store_dwordx2 v[10:11], v12, s[4:7], 0 offen
	s_mov_b32 s14, s3
	s_add_i32 s3, s3, 2
	v_add_u32_e32 v35, s0, v35
	v_add_u32_e32 v34, s0, v34
	v_add_u32_e32 v36, s0, v36
	v_add_u32_e32 v37, s1, v37
	v_add_u32_e32 v38, s1, v38
	v_add_u32_e32 v39, s12, v39
	v_add_u32_e32 v40, s12, v40
	v_add_u32_e32 v41, s13, v41
	v_add_u32_e32 v42, s13, v42
	s_add_i32 s14, s14, 3
	s_cmp_lt_i32 s14, s17
	s_cbranch_scc1 .LBB0_4
.LBB0_5:
	s_cmp_ge_i32 s3, s17
	v_lshlrev_b32_e32 v10, 3, v18
	s_cbranch_scc1 .LBB0_7
	s_mul_i32 s0, s3, s27
	v_add_lshl_u32 v3, s0, v30, 1
	v_add_u32_e32 v5, v3, v10
	v_or_b32_e32 v7, 4, v10
	v_add_u32_e32 v3, v3, v7
	buffer_load_dword v5, v5, s[28:31], 0 offen
	buffer_load_dword v3, v3, s[28:31], 0 offen
	s_mul_i32 s0, s3, s38
	v_add_lshl_u32 v9, s0, v24, 1
	v_add_u32_e32 v11, v9, v10
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_dword v11, v11, s[8:11], 0 offen
	v_add_u32_e32 v9, v9, v7
	buffer_load_dword v9, v9, s[8:11], 0 offen
	s_mul_i32 s0, s3, s42
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	s_mul_i32 s1, s3, s2
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_lshl_u32 v12, s0, v29, 1
	v_add_lshl_u32 v13, s1, v23, 1
	v_add_u32_e32 v33, v12, v10
	v_add_u32_e32 v50, v12, v7
	v_add_u32_e32 v51, v13, v10
	v_add_u32_e32 v7, v13, v7
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v13, 0xffff0000, v5
	v_lshlrev_b32_e32 v12, 16, v5
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v35, 0xffff0000, v3
	v_lshlrev_b32_e32 v34, 16, v3
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v37, 0xffff0000, v11
	v_lshlrev_b32_e32 v36, 16, v11
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v39, 0xffff0000, v9
	v_lshlrev_b32_e32 v38, 16, v9
	v_pk_mul_f32 v[40:41], v[6:7], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[8:9], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[44:45], v[6:7], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[8:9], v[38:39] op_sel_hi:[0,1]
	v_pk_fma_f32 v[48:49], v[2:3], v[12:13], v[40:41] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[12:13], v[2:3], v[12:13], v[40:41] op_sel:[0,0,1] op_sel_hi:[0,1,0]
	v_pk_fma_f32 v[40:41], v[4:5], v[34:35], v[42:43] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[34:35], v[4:5], v[34:35], v[42:43] op_sel:[0,0,1] op_sel_hi:[0,1,0]
	v_pk_fma_f32 v[42:43], v[2:3], v[36:37], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[36:37], v[2:3], v[36:37], v[44:45] op_sel:[0,0,1] op_sel_hi:[0,1,0]
	v_pk_fma_f32 v[44:45], v[4:5], v[38:39], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[38:39], v[4:5], v[38:39], v[46:47] op_sel:[0,0,1] op_sel_hi:[0,1,0]
	v_cvt_pk_bf16_f32 v3, v48, v13
	v_cvt_pk_bf16_f32 v5, v40, v35
	v_cvt_pk_bf16_f32 v9, v42, v37
	v_cvt_pk_bf16_f32 v11, v44, v39
	buffer_store_dword v3, v33, s[44:47], 0 offen
	buffer_store_dword v5, v50, s[44:47], 0 offen
	buffer_store_dword v9, v51, s[4:7], 0 offen
	buffer_store_dword v11, v7, s[4:7], 0 offen
.LBB0_7:
	s_add_i32 s0, s17, 1
	s_cmp_ge_i32 s0, s21
	s_mov_b32 s6, s17
	s_cbranch_scc1 .LBB0_10
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v9, v8
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v7, v6
	v_lshl_or_b32 v11, s16, 11, v27
	v_sub_u32_e32 v11, v11, v28
	s_mul_i32 s1, s27, s0
	v_add_lshl_u32 v12, v30, s1, 1
	v_add_u32_e32 v13, 4, v12
	s_lshl_b32 s1, s27, 2
	s_mul_i32 s3, s42, s0
	v_add_lshl_u32 v33, v29, s3, 1
	s_lshl_b32 s3, s42, 2
	s_mul_i32 s6, s27, s17
	v_add_u32_e32 v34, s6, v19
	v_add_lshl_u32 v31, v34, v31, 1
	s_mul_i32 s6, s42, s17
	v_add_u32_e32 v34, s6, v21
	v_add_lshl_u32 v32, v34, v32, 1
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	s_mov_b32 s6, s17
.LBB0_9:
	v_add_u32_e32 v34, v11, v31
	v_add_u32_e32 v36, v11, v12
	v_add_u32_e32 v37, v11, v13
	buffer_load_dwordx2 v[34:35], v34, s[28:31], 0 offen
	buffer_load_dword v40, v36, s[28:31], 0 offen
	buffer_load_dword v42, v37, s[28:31], 0 offen
	v_add_u32_e32 v52, v11, v32
	v_add_u32_e32 v53, v11, v33
	s_mov_b32 s7, s6
	v_add_u32_e32 v13, s1, v13
	v_add_u32_e32 v12, s1, v12
	v_add_u32_e32 v33, s3, v33
	v_add_u32_e32 v31, s1, v31
	v_add_u32_e32 v32, s3, v32
	s_add_i32 s6, s6, 2
	s_add_i32 s7, s7, 3
	s_cmp_lt_i32 s7, s21
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v37, 0xffff0000, v34
	v_lshlrev_b32_e32 v36, 16, v34
	v_and_b32_e32 v39, 0xffff0000, v35
	v_lshlrev_b32_e32 v38, 16, v35
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v35, 0xffff0000, v40
	v_lshlrev_b32_e32 v34, 16, v40
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v41, 0xffff0000, v42
	v_lshlrev_b32_e32 v40, 16, v42
	v_pk_mul_f32 v[42:43], v[6:7], v[36:37]
	v_pk_mul_f32 v[44:45], v[8:9], v[38:39]
	v_pk_mul_f32 v[46:47], v[6:7], v[34:35]
	v_pk_mul_f32 v[48:49], v[8:9], v[40:41]
	v_pk_fma_f32 v[50:51], v[2:3], v[36:37], v[42:43] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[36:37], v[2:3], v[36:37], v[42:43] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[42:43], v[4:5], v[38:39], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[38:39], v[4:5], v[38:39], v[44:45] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[44:45], v[2:3], v[34:35], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[34:35], v[2:3], v[34:35], v[46:47] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[46:47], v[4:5], v[40:41], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[40:41], v[4:5], v[40:41], v[48:49] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_cvt_pk_bf16_f32 v36, v50, v37
	v_cvt_pk_bf16_f32 v37, v42, v39
	v_cvt_pk_bf16_f32 v34, v44, v35
	v_cvt_pk_bf16_f32 v35, v46, v41
	buffer_store_dwordx2 v[36:37], v52, s[44:47], 0 offen
	buffer_store_dwordx2 v[34:35], v53, s[44:47], 0 offen
	s_cbranch_scc1 .LBB0_9
.LBB0_10:
	s_cmp_ge_i32 s6, s21
	s_cbranch_scc1 .LBB0_12
	s_mul_i32 s1, s6, s27
	v_add_lshl_u32 v3, s1, v30, 1
	v_add_u32_e32 v5, v3, v10
	buffer_load_dword v5, v5, s[28:31], 0 offen
	v_or_b32_e32 v7, 4, v10
	v_add_u32_e32 v3, v3, v7
	buffer_load_dword v3, v3, s[28:31], 0 offen
	s_mul_i32 s1, s6, s42
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	v_add_lshl_u32 v9, s1, v29, 1
	v_add_u32_e32 v11, v9, v10
	v_add_u32_e32 v7, v9, v7
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v13, 0xffff0000, v5
	v_lshlrev_b32_e32 v12, 16, v5
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v31, 0xffff0000, v3
	v_lshlrev_b32_e32 v30, 16, v3
	v_pk_mul_f32 v[32:33], v[6:7], v[12:13] op_sel:[0,1] op_sel_hi:[0,0]
	v_pk_mul_f32 v[34:35], v[8:9], v[30:31] op_sel:[0,1] op_sel_hi:[0,0]
	v_pk_fma_f32 v[36:37], v[2:3], v[12:13], v[32:33] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[12:13], v[2:3], v[12:13], v[32:33] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[32:33], v[4:5], v[30:31], v[34:35] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[30:31], v[4:5], v[30:31], v[34:35] op_sel_hi:[0,1,1]
	v_cvt_pk_bf16_f32 v3, v36, v13
	v_cvt_pk_bf16_f32 v5, v32, v31
	buffer_store_dword v3, v11, s[44:47], 0 offen
	buffer_store_dword v5, v7, s[44:47], 0 offen
.LBB0_12:
	s_cmp_ge_i32 s0, s22
	s_mov_b32 s3, s17
	s_cbranch_scc1 .LBB0_15
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v9, v8
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v7, v6
	v_lshl_or_b32 v11, s16, 11, v27
	v_sub_u32_e32 v11, v11, v28
	s_mul_i32 s1, s38, s0
	v_add_lshl_u32 v12, v24, s1, 1
	v_add_u32_e32 v13, 4, v12
	s_lshl_b32 s1, s38, 2
	s_mul_i32 s0, s2, s0
	v_add_lshl_u32 v27, v23, s0, 1
	s_lshl_b32 s0, s2, 2
	s_mul_i32 s3, s38, s17
	v_add_u32_e32 v28, s3, v20
	v_add_lshl_u32 v25, v28, v25, 1
	s_mul_i32 s3, s2, s17
	v_add_u32_e32 v28, s3, v22
	v_add_lshl_u32 v26, v28, v26, 1
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	s_mov_b32 s3, s17
.LBB0_14:
	v_add_u32_e32 v28, v11, v25
	v_add_u32_e32 v30, v11, v12
	v_add_u32_e32 v31, v11, v13
	buffer_load_dwordx2 v[28:29], v28, s[8:11], 0 offen
	buffer_load_dword v34, v30, s[8:11], 0 offen
	buffer_load_dword v36, v31, s[8:11], 0 offen
	v_add_u32_e32 v46, v11, v26
	v_add_u32_e32 v47, v11, v27
	s_mov_b32 s12, s3
	v_add_u32_e32 v13, s1, v13
	v_add_u32_e32 v12, s1, v12
	v_add_u32_e32 v27, s0, v27
	v_add_u32_e32 v25, s1, v25
	v_add_u32_e32 v26, s0, v26
	s_add_i32 s3, s3, 2
	s_add_i32 s12, s12, 3
	s_cmp_lt_i32 s12, s22
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v31, 0xffff0000, v28
	v_lshlrev_b32_e32 v30, 16, v28
	v_and_b32_e32 v33, 0xffff0000, v29
	v_lshlrev_b32_e32 v32, 16, v29
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v29, 0xffff0000, v34
	v_lshlrev_b32_e32 v28, 16, v34
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v35, 0xffff0000, v36
	v_lshlrev_b32_e32 v34, 16, v36
	v_pk_mul_f32 v[36:37], v[6:7], v[30:31]
	v_pk_mul_f32 v[38:39], v[8:9], v[32:33]
	v_pk_mul_f32 v[40:41], v[6:7], v[28:29]
	v_pk_mul_f32 v[42:43], v[8:9], v[34:35]
	v_pk_fma_f32 v[44:45], v[2:3], v[30:31], v[36:37] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[30:31], v[2:3], v[30:31], v[36:37] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[36:37], v[4:5], v[32:33], v[38:39] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[32:33], v[4:5], v[32:33], v[38:39] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[38:39], v[2:3], v[28:29], v[40:41] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[28:29], v[2:3], v[28:29], v[40:41] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_pk_fma_f32 v[40:41], v[4:5], v[34:35], v[42:43] op_sel:[0,0,1] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[34:35], v[4:5], v[34:35], v[42:43] op_sel:[0,0,1] op_sel_hi:[1,1,0]
	v_cvt_pk_bf16_f32 v30, v44, v31
	v_cvt_pk_bf16_f32 v31, v36, v33
	v_cvt_pk_bf16_f32 v28, v38, v29
	v_cvt_pk_bf16_f32 v29, v40, v35
	buffer_store_dwordx2 v[30:31], v46, s[4:7], 0 offen
	buffer_store_dwordx2 v[28:29], v47, s[4:7], 0 offen
	s_cbranch_scc1 .LBB0_14
.LBB0_15:
	s_cmp_ge_i32 s3, s22
	s_cbranch_scc1 .LBB0_17
	s_mul_i32 s0, s3, s38
	v_add_lshl_u32 v3, s0, v24, 1
	v_add_u32_e32 v5, v3, v10
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_dword v5, v5, s[8:11], 0 offen
	v_or_b32_e32 v7, 4, v10
	v_add_u32_e32 v3, v3, v7
	buffer_load_dword v3, v3, s[8:11], 0 offen
	s_mul_i32 s0, s3, s2
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_lshl_u32 v9, s0, v23, 1
	v_add_u32_e32 v23, v9, v10
	v_add_u32_e32 v26, v9, v7
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v11, 0xffff0000, v5
	v_lshlrev_b32_e32 v10, 16, v5
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v13, 0xffff0000, v3
	v_lshlrev_b32_e32 v12, 16, v3
	v_pk_mul_f32 v[6:7], v[6:7], v[10:11] op_sel:[0,1] op_sel_hi:[0,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[12:13] op_sel:[0,1] op_sel_hi:[0,0]
	v_pk_fma_f32 v[24:25], v[2:3], v[10:11], v[6:7] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[2:3], v[2:3], v[10:11], v[6:7] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[6:7], v[4:5], v[12:13], v[8:9] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[4:5], v[4:5], v[12:13], v[8:9] op_sel_hi:[0,1,1]
	v_cvt_pk_bf16_f32 v2, v24, v3
	v_cvt_pk_bf16_f32 v3, v6, v5
	buffer_store_dword v2, v23, s[4:7], 0 offen
	buffer_store_dword v3, v26, s[4:7], 0 offen
.LBB0_17:
	s_cmp_le_i32 s23, s18
	s_cbranch_scc1 .LBB0_36
	v_lshlrev_b32_e32 v8, 1, v18
	s_cmp_lt_i32 s17, 1
	v_add_u32_e32 v2, s18, v8
	v_lshlrev_b32_e32 v7, 1, v19
	v_lshlrev_b32_e32 v0, 2, v0
	v_lshlrev_b32_e32 v3, 2, v17
	v_lshlrev_b32_e32 v5, 1, v20
	v_lshlrev_b32_e32 v6, 1, v21
	v_lshlrev_b32_e32 v4, 1, v22
	s_cbranch_scc1 .LBB0_24
	v_add_u32_e32 v9, s18, v8
	v_add_u32_e32 v10, 2, v9
	v_cmp_ge_i32_e32 vcc, s23, v10
	s_lshl_b32 s3, s19, 1
	s_add_i32 s20, s3, 2
	s_lshl_b32 s0, s16, 10
	v_add3_u32 v10, v7, v15, s0
	s_lshl_b32 s1, s24, 2
	v_add3_u32 v10, v10, v0, s1
	v_sub_u32_e32 v10, v10, v3
	s_lshl_b32 s25, s27, 1
	s_lshl_b32 s26, s19, 2
	v_add3_u32 v11, v5, v14, s0
	v_add3_u32 v11, v11, v0, s1
	v_sub_u32_e32 v11, v11, v3
	s_lshl_b32 s33, s38, 1
	v_add3_u32 v12, v6, v16, s0
	v_add3_u32 v12, v12, v0, s1
	v_sub_u32_e32 v12, v12, v3
	s_lshl_b32 s34, s42, 1
	v_add3_u32 v13, v4, v1, s0
	v_add3_u32 v13, v13, v0, s1
	v_sub_u32_e32 v13, v13, v3
	s_lshl_b32 s35, s2, 1
	s_mov_b32 s36, 0
	s_branch .LBB0_21
.LBB0_20:
	s_or_b64 exec, exec, s[12:13]
	s_add_i32 s36, s36, 1
	v_add_u32_e32 v10, s25, v10
	v_add_u32_e32 v11, s33, v11
	v_add_u32_e32 v12, s34, v12
	s_cmp_eq_u32 s36, s17
	v_add_u32_e32 v13, s35, v13
	s_cbranch_scc1 .LBB0_24
.LBB0_21:
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB0_20
	s_mov_b32 s37, 0
	s_mov_b64 s[14:15], 0
	v_mov_b32_e32 v17, v9
.LBB0_23:
	v_add_u32_e32 v18, s37, v10
	v_add_u32_e32 v19, s37, v11
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_dword v18, v18, s[28:31], 0 offen
	buffer_load_dword v19, v19, s[8:11], 0 offen
	v_add_u32_e32 v20, s37, v12
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	v_add_u32_e32 v21, s37, v13
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_u32_e32 v22, s3, v17
	v_add_u32_e32 v17, s20, v17
	s_add_i32 s37, s37, s26
	v_cmp_lt_i32_e64 s[0:1], s23, v17
	v_mov_b32_e32 v17, v22
	s_or_b64 s[14:15], s[0:1], s[14:15]
	s_waitcnt vmcnt(1)
	buffer_store_dword v18, v20, s[44:47], 0 offen
	s_waitcnt vmcnt(1)
	buffer_store_dword v19, v21, s[4:7], 0 offen
	s_andn2_b64 exec, exec, s[14:15]
	s_cbranch_execnz .LBB0_23
	s_branch .LBB0_20
.LBB0_24:
	s_cmp_ge_i32 s22, s21
	s_cbranch_scc1 .LBB0_30
	v_add_u32_e32 v8, s18, v8
	v_add_u32_e32 v9, 2, v8
	v_cmp_ge_i32_e32 vcc, s23, v9
	s_lshl_b32 s3, s19, 1
	s_add_i32 s12, s3, 2
	s_mul_i32 s0, s27, s17
	v_lshl_add_u32 v7, s0, 1, v7
	s_lshl_b32 s0, s16, 10
	v_add3_u32 v7, v7, v15, s0
	s_lshl_b32 s1, s24, 2
	v_add3_u32 v7, v7, v0, s1
	v_sub_u32_e32 v7, v7, v3
	s_lshl_b32 s13, s27, 1
	s_lshl_b32 s14, s19, 2
	s_mul_i32 s6, s42, s17
	v_lshl_add_u32 v6, s6, 1, v6
	v_add3_u32 v6, v6, v16, s0
	v_add3_u32 v6, v6, v0, s1
	v_sub_u32_e32 v6, v6, v3
	s_lshl_b32 s15, s42, 1
	s_mov_b32 s18, s17
	s_branch .LBB0_27
.LBB0_26:
	s_or_b64 exec, exec, s[6:7]
	s_add_i32 s18, s18, 1
	v_add_u32_e32 v7, s13, v7
	s_cmp_ge_i32 s18, s21
	v_add_u32_e32 v6, s15, v6
	s_cbranch_scc1 .LBB0_30
.LBB0_27:
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_26
	s_mov_b32 s20, 0
	s_mov_b64 s[10:11], 0
	v_mov_b32_e32 v9, v8
.LBB0_29:
	v_add_u32_e32 v10, s20, v7
	buffer_load_dword v10, v10, s[28:31], 0 offen
	v_add_u32_e32 v11, s20, v6
	s_mov_b32 s46, s30
	s_mov_b32 s47, s31
	v_add_u32_e32 v12, s3, v9
	v_add_u32_e32 v9, s12, v9
	s_add_i32 s20, s20, s14
	v_cmp_lt_i32_e64 s[0:1], s23, v9
	v_mov_b32_e32 v9, v12
	s_or_b64 s[10:11], s[0:1], s[10:11]
	s_waitcnt vmcnt(0)
	buffer_store_dword v10, v11, s[44:47], 0 offen
	s_andn2_b64 exec, exec, s[10:11]
	s_cbranch_execnz .LBB0_29
	s_branch .LBB0_26
.LBB0_30:
	s_cmp_ge_i32 s21, s22
	s_cbranch_scc1 .LBB0_36
	v_add_u32_e32 v6, 2, v2
	v_cmp_ge_i32_e32 vcc, s23, v6
	s_lshl_b32 s14, s19, 1
	s_add_i32 s15, s14, 2
	s_mul_i32 s0, s38, s17
	v_lshl_add_u32 v5, s0, 1, v5
	s_lshl_b32 s0, s16, 10
	v_add3_u32 v5, v5, v14, s0
	s_lshl_b32 s1, s24, 2
	v_add3_u32 v5, v5, v0, s1
	v_sub_u32_e32 v5, v5, v3
	s_lshl_b32 s16, s38, 1
	s_lshl_b32 s18, s19, 2
	s_mul_i32 s3, s2, s17
	v_lshl_add_u32 v4, s3, 1, v4
	v_add3_u32 v1, v4, v1, s0
	v_add3_u32 v0, v1, v0, s1
	v_sub_u32_e32 v0, v0, v3
	s_lshl_b32 s19, s2, 1
	s_branch .LBB0_33
.LBB0_32:
	s_or_b64 exec, exec, s[2:3]
	s_add_i32 s17, s17, 1
	v_add_u32_e32 v5, s16, v5
	s_cmp_ge_i32 s17, s22
	v_add_u32_e32 v0, s19, v0
	s_cbranch_scc1 .LBB0_36
.LBB0_33:
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_32
	s_mov_b32 s20, 0
	s_mov_b64 s[12:13], 0
	v_mov_b32_e32 v1, v2
.LBB0_35:
	v_add_u32_e32 v3, s20, v5
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_dword v3, v3, s[8:11], 0 offen
	v_add_u32_e32 v4, s20, v0
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_u32_e32 v6, s14, v1
	v_add_u32_e32 v1, s15, v1
	s_add_i32 s20, s20, s18
	v_cmp_lt_i32_e64 s[0:1], s23, v1
	v_mov_b32_e32 v1, v6
	s_or_b64 s[12:13], s[0:1], s[12:13]
	s_waitcnt vmcnt(0)
	buffer_store_dword v3, v4, s[4:7], 0 offen
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB0_35
	s_branch .LBB0_32
.LBB0_36:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 152
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 54
		.amdhsa_next_free_sgpr 52
		.amdhsa_accum_offset 56
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
	.section	.text._ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,"axG",@progbits,_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,comdat
.Lfunc_end0:
	.size	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii, .Lfunc_end0-_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii

	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.num_vgpr, 54
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.num_agpr, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.numbered_sgpr, 52
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.private_seg_size, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.uses_vcc, 1
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.uses_flat_scratch, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_recursion, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_indirect_call, 0
	.section	.text._ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,"axG",@progbits,_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,comdat
	.protected	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
	.globl	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
	.p2align	8
	.type	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,@function
_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_mov_b64 s[28:29], s[6:7]
	s_mov_b64 s[52:53], s[2:3]
	s_load_dwordx8 s[20:27], s[0:1], 0x78
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s3, s26
	v_cvt_f32_u32_e32 v1, s3
	s_lshl_b32 s17, s16, 8
	v_rcp_iflag_f32_e32 v2, v1
	v_or_b32_e32 v1, s17, v0
	s_xor_b32 s2, s17, s26
	s_ashr_i32 s2, s2, 31
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_sub_u32_e32 v3, 0, v1
	v_max_i32_e32 v3, v1, v3
	s_sub_i32 s6, 0, s3
	v_mul_lo_u32 v4, s6, v2
	v_mul_hi_u32 v4, v2, v4
	v_add_u32_e32 v2, v2, v4
	v_mul_hi_u32 v2, v3, v2
	v_mul_lo_u32 v4, v2, s3
	v_sub_u32_e32 v3, v3, v4
	v_add_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_subrev_u32_e32 v4, s3, v3
	v_cndmask_b32_e32 v3, v3, v4, vcc
	v_add_u32_e32 v4, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_xor_b32_e32 v9, s2, v2
	v_subrev_u32_e32 v4, s2, v9
	v_cmp_gt_i32_e32 vcc, s27, v4
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_36
	s_mov_b64 s[56:57], s[10:11]
	s_abs_i32 s3, s25
	v_cvt_f32_u32_e32 v2, s3
	v_rcp_iflag_f32_e32 v2, v2
	v_ashrrev_i32_e32 v3, 31, v4
	s_ashr_i32 s6, s25, 31
	v_sub_u32_e32 v5, 0, v4
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_xor_b32_e32 v3, s6, v3
	v_max_i32_e32 v5, v4, v5
	s_sub_i32 s7, 0, s3
	v_readfirstlane_b32 s10, v2
	s_mul_i32 s7, s7, s10
	s_mul_hi_u32 s7, s10, s7
	s_add_i32 s10, s10, s7
	v_mul_hi_u32 v2, v5, s10
	v_mul_lo_u32 v6, v2, s3
	v_add_u32_e32 v7, 1, v2
	v_sub_u32_e32 v5, v5, v6
	v_cmp_le_u32_e32 vcc, s3, v5
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v7, vcc
	v_subrev_u32_e32 v6, s3, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_add_u32_e32 v6, 1, v2
	v_cmp_le_u32_e32 vcc, s3, v5
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v6, vcc
	v_xor_b32_e32 v2, v2, v3
	v_sub_u32_e32 v10, v2, v3
	v_mul_lo_u32 v2, v10, s25
	v_sub_u32_e32 v11, v4, v2
	s_ashr_i32 s7, s27, 31
	s_xor_b32 s6, s7, s6
	s_abs_i32 s7, s27
	s_mul_hi_u32 s10, s7, s10
	s_mul_i32 s11, s10, s3
	s_sub_i32 s7, s7, s11
	s_add_i32 s11, s10, 1
	s_sub_i32 s18, s7, s3
	s_cmp_ge_u32 s7, s3
	s_cselect_b32 s10, s11, s10
	s_cselect_b32 s7, s18, s7
	s_add_i32 s11, s10, 1
	s_cmp_ge_u32 s7, s3
	s_cselect_b32 s3, s11, s10
	s_xor_b32 s3, s3, s6
	s_sub_i32 s3, s3, s6
	v_mad_u64_u32 v[2:3], s[6:7], s3, v11, v[10:11]
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[2:3], v[2:3], 3, s[14:15]
	global_load_dwordx2 v[2:3], v[2:3], off
	s_load_dwordx16 s[36:51], s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s0, s36
	s_ashr_i32 s1, s36, 31
	s_waitcnt vmcnt(0)
	v_cmp_lt_i64_e32 vcc, -1, v[2:3]
	v_cmp_gt_i64_e64 s[0:1], s[0:1], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB1_36
	v_mul_lo_u32 v12, v4, s26
	v_sub_u32_e32 v14, v1, v12
	v_mul_lo_u32 v1, s40, v2
	s_and_b32 s57, s57, 0xffff
	s_mov_b32 s59, 0x20000
	s_mov_b32 s58, -1
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s58
	s_mov_b32 s15, s59
	v_add_lshl_u32 v1, v1, v14, 1
	buffer_load_ushort v13, v1, s[12:15], 0 offen
	buffer_load_ushort v18, v1, s[56:59], 0 offen
	v_mul_lo_u32 v8, v11, s41
	v_mul_lo_u32 v7, v10, s42
	v_mul_lo_u32 v4, v11, s45
	v_mul_lo_u32 v3, v10, s46
	v_mul_lo_u32 v6, v11, s49
	v_mul_lo_u32 v5, v10, s50
	v_mul_lo_u32 v2, v11, s21
	v_mul_lo_u32 v1, v10, s22
	s_min_i32 s14, s37, s38
	s_and_b32 s29, s29, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_and_b32 s53, s53, 0xffff
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s0, 0
	v_lshlrev_b32_e32 v17, 2, v0
	v_add_u32_e32 v20, v7, v8
	v_add_u32_e32 v16, v3, v4
	v_add_u32_e32 v19, v5, v6
	v_add_u32_e32 v15, v1, v2
	s_mov_b32 s30, s58
	s_mov_b32 s31, s59
	s_cmp_lt_i32 s14, 2
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v11, 16, v13
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v10, 16, v18
	v_lshlrev_b32_e32 v18, 2, v12
	s_cbranch_scc1 .LBB1_5
	v_pk_mov_b32 v[12:13], v[10:11], v[10:11] op_sel:[1,0]
	v_lshl_or_b32 v21, s16, 10, v17
	v_sub_u32_e32 v21, v21, v18
	v_add_lshl_u32 v22, v20, s43, 1
	v_add_u32_e32 v23, 2, v22
	s_lshl_b32 s1, s43, 2
	v_lshlrev_b32_e32 v24, 1, v7
	v_lshl_add_u32 v24, v8, 1, v24
	v_add_lshl_u32 v25, v16, s47, 1
	s_lshl_b32 s3, s47, 2
	v_lshlrev_b32_e32 v26, 1, v3
	v_lshl_add_u32 v26, v4, 1, v26
	v_add_lshl_u32 v27, v19, s51, 1
	s_lshl_b32 s12, s51, 2
	v_lshlrev_b32_e32 v28, 1, v5
	v_lshl_add_u32 v28, v6, 1, v28
	v_add_lshl_u32 v29, v15, s23, 1
	s_lshl_b32 s13, s23, 2
	v_lshlrev_b32_e32 v30, 1, v1
	v_lshl_add_u32 v30, v2, 1, v30
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
.LBB1_4:
	v_add_u32_e32 v31, v21, v24
	v_add_u32_e32 v32, v21, v26
	v_add_u32_e32 v33, v21, v22
	v_add_u32_e32 v34, v21, v23
	v_add_u32_e32 v35, v21, v25
	buffer_load_ushort v36, v31, s[28:31], 0 offen offset:2
	buffer_load_ushort v31, v31, s[28:31], 0 offen
	buffer_load_ushort v37, v32, s[8:11], 0 offen offset:2
	buffer_load_ushort v38, v32, s[8:11], 0 offen
	buffer_load_ushort v39, v34, s[28:31], 0 offen
	buffer_load_ushort v40, v33, s[28:31], 0 offen
	buffer_load_ushort v41, v35, s[8:11], 0 offen offset:2
	buffer_load_ushort v42, v35, s[8:11], 0 offen
	v_add_u32_e32 v48, v21, v28
	v_add_u32_e32 v49, v21, v30
	v_add_u32_e32 v50, v21, v27
	v_add_u32_e32 v51, v21, v29
	s_mov_b32 s15, s0
	v_add_u32_e32 v23, s1, v23
	v_add_u32_e32 v22, s1, v22
	v_add_u32_e32 v24, s1, v24
	v_add_u32_e32 v25, s3, v25
	v_add_u32_e32 v26, s3, v26
	v_add_u32_e32 v27, s12, v27
	v_add_u32_e32 v28, s12, v28
	v_add_u32_e32 v29, s13, v29
	v_add_u32_e32 v30, s13, v30
	s_add_i32 s0, s0, 2
	s_add_i32 s15, s15, 3
	s_cmp_lt_i32 s15, s14
	s_waitcnt vmcnt(7)
	v_lshlrev_b32_e32 v33, 16, v36
	s_waitcnt vmcnt(6)
	v_lshlrev_b32_e32 v32, 16, v31
	s_waitcnt vmcnt(5)
	v_lshlrev_b32_e32 v35, 16, v37
	s_waitcnt vmcnt(4)
	v_lshlrev_b32_e32 v34, 16, v38
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v37, 16, v39
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v36, 16, v40
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v39, 16, v41
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v38, 16, v42
	v_pk_mul_f32 v[40:41], v[10:11], v[32:33]
	v_pk_mul_f32 v[32:33], v[12:13], v[32:33]
	v_pk_mul_f32 v[42:43], v[10:11], v[34:35]
	v_pk_mul_f32 v[34:35], v[12:13], v[34:35]
	v_pk_mul_f32 v[44:45], v[10:11], v[36:37]
	v_pk_mul_f32 v[36:37], v[12:13], v[36:37]
	v_pk_mul_f32 v[46:47], v[10:11], v[38:39]
	v_pk_mul_f32 v[38:39], v[12:13], v[38:39]
	v_sub_f32_e32 v31, v40, v41
	v_add_f32_e32 v32, v32, v33
	v_sub_f32_e32 v33, v42, v43
	v_add_f32_e32 v34, v34, v35
	v_sub_f32_e32 v35, v44, v45
	v_add_f32_e32 v36, v36, v37
	v_sub_f32_e32 v37, v46, v47
	v_add_f32_e32 v38, v38, v39
	v_cvt_pk_bf16_f32 v31, v31, s0
	v_cvt_pk_bf16_f32 v32, v32, s0
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_cvt_pk_bf16_f32 v36, v36, s0
	v_cvt_pk_bf16_f32 v37, v37, s0
	v_cvt_pk_bf16_f32 v38, v38, s0
	buffer_store_short v31, v48, s[52:55], 0 offen
	buffer_store_short v32, v48, s[52:55], 0 offen offset:2
	buffer_store_short v33, v49, s[4:7], 0 offen
	buffer_store_short v34, v49, s[4:7], 0 offen offset:2
	buffer_store_short v35, v50, s[52:55], 0 offen
	buffer_store_short v36, v50, s[52:55], 0 offen offset:2
	buffer_store_short v37, v51, s[4:7], 0 offen
	buffer_store_short v38, v51, s[4:7], 0 offen offset:2
	s_cbranch_scc1 .LBB1_4
.LBB1_5:
	s_cmp_ge_i32 s0, s14
	v_lshlrev_b32_e32 v21, 2, v14
	s_cbranch_scc1 .LBB1_7
	s_mul_i32 s1, s0, s43
	v_add_lshl_u32 v12, s1, v20, 1
	v_add_u32_e32 v13, v12, v21
	v_or_b32_e32 v22, 2, v21
	v_add_u32_e32 v12, v12, v22
	buffer_load_ushort v23, v13, s[28:31], 0 offen
	buffer_load_ushort v12, v12, s[28:31], 0 offen
	s_mul_i32 s1, s0, s47
	v_add_lshl_u32 v13, s1, v16, 1
	v_add_u32_e32 v24, v13, v21
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	v_add_u32_e32 v13, v13, v22
	buffer_load_ushort v25, v13, s[8:11], 0 offen
	buffer_load_ushort v24, v24, s[8:11], 0 offen
	s_mul_i32 s1, s0, s51
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	s_mul_i32 s0, s0, s23
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_lshl_u32 v13, s1, v19, 1
	v_add_lshl_u32 v26, s0, v15, 1
	v_add_u32_e32 v28, v13, v21
	v_add_u32_e32 v29, v13, v22
	v_add_u32_e32 v30, v26, v21
	v_add_u32_e32 v31, v26, v22
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v13, 16, v12
	v_lshlrev_b32_e32 v12, 16, v23
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v23, 16, v25
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v22, 16, v24
	v_pk_mul_f32 v[24:25], v[10:11], v[12:13]
	v_pk_mul_f32 v[12:13], v[10:11], v[12:13] op_sel:[1,0] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[10:11], v[22:23]
	v_pk_mul_f32 v[22:23], v[10:11], v[22:23] op_sel:[1,0] op_sel_hi:[0,1]
	v_sub_f32_e32 v24, v24, v25
	v_add_f32_e32 v12, v12, v13
	v_sub_f32_e32 v13, v26, v27
	v_add_f32_e32 v22, v22, v23
	v_cvt_pk_bf16_f32 v23, v24, s0
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_cvt_pk_bf16_f32 v22, v22, s0
	buffer_store_short v23, v28, s[52:55], 0 offen
	buffer_store_short v12, v29, s[52:55], 0 offen
	buffer_store_short v13, v30, s[4:7], 0 offen
	buffer_store_short v22, v31, s[4:7], 0 offen
.LBB1_7:
	s_add_i32 s0, s14, 1
	s_cmp_ge_i32 s0, s37
	s_mov_b32 s1, s14
	s_cbranch_scc1 .LBB1_10
	v_pk_mov_b32 v[12:13], v[10:11], v[10:11] op_sel:[1,0]
	v_lshl_or_b32 v22, s16, 10, v17
	v_sub_u32_e32 v22, v22, v18
	s_mul_i32 s1, s43, s0
	v_add_lshl_u32 v23, v20, s1, 1
	v_add_u32_e32 v24, 2, v23
	s_lshl_b32 s3, s43, 2
	s_mul_i32 s1, s51, s0
	v_add_lshl_u32 v25, v19, s1, 1
	s_lshl_b32 s6, s51, 2
	s_mul_i32 s1, s43, s14
	v_add_u32_e32 v26, s1, v8
	v_add_lshl_u32 v26, v26, v7, 1
	s_mul_i32 s1, s51, s14
	v_add_u32_e32 v27, s1, v6
	v_add_lshl_u32 v27, v27, v5, 1
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	s_mov_b32 s1, s14
.LBB1_9:
	v_add_u32_e32 v28, v22, v26
	v_add_u32_e32 v29, v22, v23
	v_add_u32_e32 v30, v22, v24
	buffer_load_ushort v31, v28, s[28:31], 0 offen offset:2
	buffer_load_ushort v28, v28, s[28:31], 0 offen
	buffer_load_ushort v30, v30, s[28:31], 0 offen
	buffer_load_ushort v32, v29, s[28:31], 0 offen
	v_add_u32_e32 v36, v22, v27
	v_add_u32_e32 v37, v22, v25
	s_mov_b32 s7, s1
	v_add_u32_e32 v24, s3, v24
	v_add_u32_e32 v23, s3, v23
	v_add_u32_e32 v25, s6, v25
	v_add_u32_e32 v26, s3, v26
	v_add_u32_e32 v27, s6, v27
	s_add_i32 s1, s1, 2
	s_add_i32 s7, s7, 3
	s_cmp_lt_i32 s7, s37
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v29, 16, v31
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v28, 16, v28
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v31, 16, v30
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v30, 16, v32
	v_pk_mul_f32 v[32:33], v[10:11], v[28:29]
	v_pk_mul_f32 v[28:29], v[12:13], v[28:29]
	v_pk_mul_f32 v[34:35], v[10:11], v[30:31]
	v_pk_mul_f32 v[30:31], v[12:13], v[30:31]
	v_sub_f32_e32 v32, v32, v33
	v_add_f32_e32 v28, v28, v29
	v_sub_f32_e32 v29, v34, v35
	v_add_f32_e32 v30, v30, v31
	v_cvt_pk_bf16_f32 v31, v32, s0
	v_cvt_pk_bf16_f32 v28, v28, s0
	v_cvt_pk_bf16_f32 v29, v29, s0
	v_cvt_pk_bf16_f32 v30, v30, s0
	buffer_store_short v31, v36, s[52:55], 0 offen
	buffer_store_short v28, v36, s[52:55], 0 offen offset:2
	buffer_store_short v29, v37, s[52:55], 0 offen
	buffer_store_short v30, v37, s[52:55], 0 offen offset:2
	s_cbranch_scc1 .LBB1_9
.LBB1_10:
	s_cmp_ge_i32 s1, s37
	s_cbranch_scc1 .LBB1_12
	s_mul_i32 s3, s1, s43
	v_add_lshl_u32 v12, s3, v20, 1
	v_add_u32_e32 v13, v12, v21
	v_or_b32_e32 v20, 2, v21
	v_add_u32_e32 v12, v12, v20
	buffer_load_ushort v12, v12, s[28:31], 0 offen
	buffer_load_ushort v22, v13, s[28:31], 0 offen
	s_mul_i32 s1, s1, s51
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	v_add_lshl_u32 v13, s1, v19, 1
	v_add_u32_e32 v19, v13, v21
	v_add_u32_e32 v20, v13, v20
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v13, 16, v12
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v12, 16, v22
	v_pk_mul_f32 v[22:23], v[10:11], v[12:13]
	v_pk_mul_f32 v[12:13], v[10:11], v[12:13] op_sel:[1,0] op_sel_hi:[0,1]
	v_sub_f32_e32 v22, v22, v23
	v_add_f32_e32 v12, v12, v13
	v_cvt_pk_bf16_f32 v13, v22, s0
	v_cvt_pk_bf16_f32 v12, v12, s0
	buffer_store_short v13, v19, s[52:55], 0 offen
	buffer_store_short v12, v20, s[52:55], 0 offen
.LBB1_12:
	s_cmp_ge_i32 s0, s38
	s_mov_b32 s1, s14
	s_cbranch_scc1 .LBB1_15
	v_pk_mov_b32 v[12:13], v[10:11], v[10:11] op_sel:[1,0]
	v_lshl_or_b32 v17, s16, 10, v17
	v_sub_u32_e32 v17, v17, v18
	s_mul_i32 s1, s47, s0
	v_add_lshl_u32 v18, v16, s1, 1
	v_add_u32_e32 v19, 2, v18
	s_lshl_b32 s3, s47, 2
	s_mul_i32 s0, s23, s0
	v_add_lshl_u32 v20, v15, s0, 1
	s_lshl_b32 s0, s23, 2
	s_mul_i32 s1, s47, s14
	v_add_u32_e32 v22, s1, v4
	v_add_lshl_u32 v22, v22, v3, 1
	s_mul_i32 s1, s23, s14
	v_add_u32_e32 v23, s1, v2
	v_add_lshl_u32 v23, v23, v1, 1
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	s_mov_b32 s1, s14
.LBB1_14:
	v_add_u32_e32 v24, v17, v22
	v_add_u32_e32 v25, v17, v18
	v_add_u32_e32 v26, v17, v19
	buffer_load_ushort v27, v24, s[8:11], 0 offen offset:2
	buffer_load_ushort v24, v24, s[8:11], 0 offen
	buffer_load_ushort v26, v26, s[8:11], 0 offen
	buffer_load_ushort v28, v25, s[8:11], 0 offen
	v_add_u32_e32 v32, v17, v23
	v_add_u32_e32 v33, v17, v20
	s_mov_b32 s12, s1
	v_add_u32_e32 v19, s3, v19
	v_add_u32_e32 v18, s3, v18
	v_add_u32_e32 v20, s0, v20
	v_add_u32_e32 v22, s3, v22
	v_add_u32_e32 v23, s0, v23
	s_add_i32 s1, s1, 2
	s_add_i32 s12, s12, 3
	s_cmp_lt_i32 s12, s38
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v25, 16, v27
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v24, 16, v24
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v27, 16, v26
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v26, 16, v28
	v_pk_mul_f32 v[28:29], v[10:11], v[24:25]
	v_pk_mul_f32 v[24:25], v[12:13], v[24:25]
	v_pk_mul_f32 v[30:31], v[10:11], v[26:27]
	v_pk_mul_f32 v[26:27], v[12:13], v[26:27]
	v_sub_f32_e32 v28, v28, v29
	v_add_f32_e32 v24, v24, v25
	v_sub_f32_e32 v25, v30, v31
	v_add_f32_e32 v26, v26, v27
	v_cvt_pk_bf16_f32 v27, v28, s0
	v_cvt_pk_bf16_f32 v24, v24, s0
	v_cvt_pk_bf16_f32 v25, v25, s0
	v_cvt_pk_bf16_f32 v26, v26, s0
	buffer_store_short v27, v32, s[4:7], 0 offen
	buffer_store_short v24, v32, s[4:7], 0 offen offset:2
	buffer_store_short v25, v33, s[4:7], 0 offen
	buffer_store_short v26, v33, s[4:7], 0 offen offset:2
	s_cbranch_scc1 .LBB1_14
.LBB1_15:
	s_cmp_ge_i32 s1, s38
	s_cbranch_scc1 .LBB1_17
	s_mul_i32 s0, s1, s47
	v_add_lshl_u32 v12, s0, v16, 1
	v_add_u32_e32 v13, v12, v21
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	v_or_b32_e32 v16, 2, v21
	v_add_u32_e32 v12, v12, v16
	buffer_load_ushort v12, v12, s[8:11], 0 offen
	buffer_load_ushort v17, v13, s[8:11], 0 offen
	s_mul_i32 s0, s1, s23
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_lshl_u32 v13, s0, v15, 1
	v_add_u32_e32 v15, v13, v21
	v_add_u32_e32 v18, v13, v16
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v13, 16, v12
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v12, 16, v17
	v_pk_mul_f32 v[16:17], v[10:11], v[12:13]
	v_pk_mul_f32 v[10:11], v[10:11], v[12:13] op_sel:[1,0] op_sel_hi:[0,1]
	v_sub_f32_e32 v12, v16, v17
	v_add_f32_e32 v10, v10, v11
	v_cvt_pk_bf16_f32 v11, v12, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	buffer_store_short v11, v15, s[4:7], 0 offen
	buffer_store_short v10, v18, s[4:7], 0 offen
.LBB1_17:
	s_lshl_b32 s15, s40, 1
	s_cmp_le_i32 s39, s15
	s_cbranch_scc1 .LBB1_36
	s_cmp_lt_i32 s14, 1
	v_add_u32_e32 v10, s15, v14
	s_mul_i32 s21, s26, s44
	s_mul_i32 s18, s26, s48
	s_mul_i32 s19, s26, s20
	s_mul_i32 s16, s26, s24
	v_sub_u32_e32 v9, s2, v9
	v_cmp_gt_i32_e32 vcc, s39, v10
	v_mul_lo_u32 v9, s26, v9
	s_cbranch_scc1 .LBB1_24
	v_mad_u64_u32 v[12:13], s[0:1], s44, v10, v[8:9]
	v_add_lshl_u32 v11, v12, v7, 1
	s_lshl_b32 s22, s43, 1
	s_lshl_b32 s25, s21, 1
	v_mad_u64_u32 v[12:13], s[0:1], s48, v10, v[4:5]
	v_add_lshl_u32 v12, v12, v3, 1
	s_lshl_b32 s27, s47, 1
	s_lshl_b32 s33, s18, 1
	v_mad_u64_u32 v[14:15], s[0:1], s20, v10, v[6:7]
	v_add_lshl_u32 v13, v14, v5, 1
	s_lshl_b32 s34, s51, 1
	s_lshl_b32 s35, s19, 1
	v_mad_u64_u32 v[14:15], s[0:1], s24, v10, v[2:3]
	v_add_lshl_u32 v14, v14, v1, 1
	s_lshl_b32 s36, s23, 1
	s_lshl_b32 s40, s16, 1
	s_add_i32 s0, s15, s17
	v_add3_u32 v15, v0, v9, s0
	s_mov_b32 s41, 0
	s_branch .LBB1_21
.LBB1_20:
	s_or_b64 exec, exec, s[2:3]
	s_add_i32 s41, s41, 1
	v_add_u32_e32 v11, s22, v11
	v_add_u32_e32 v12, s27, v12
	v_add_u32_e32 v13, s34, v13
	s_cmp_eq_u32 s41, s14
	v_add_u32_e32 v14, s36, v14
	s_cbranch_scc1 .LBB1_24
.LBB1_21:
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_20
	s_mov_b64 s[12:13], 0
	v_mov_b32_e32 v16, v15
	v_mov_b32_e32 v17, v14
	v_mov_b32_e32 v18, v13
	v_mov_b32_e32 v19, v12
	v_mov_b32_e32 v20, v11
.LBB1_23:
	buffer_load_ushort v21, v20, s[28:31], 0 offen
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_ushort v22, v19, s[8:11], 0 offen
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_u32_e32 v20, s25, v20
	v_add_u32_e32 v16, s26, v16
	v_add_u32_e32 v19, s33, v19
	v_cmp_le_i32_e64 s[0:1], s39, v16
	s_or_b64 s[12:13], s[0:1], s[12:13]
	s_waitcnt vmcnt(1)
	buffer_store_short v21, v18, s[52:55], 0 offen
	v_add_u32_e32 v18, s35, v18
	s_waitcnt vmcnt(1)
	buffer_store_short v22, v17, s[4:7], 0 offen
	v_add_u32_e32 v17, s40, v17
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB1_23
	s_branch .LBB1_20
.LBB1_24:
	s_cmp_ge_i32 s38, s37
	s_cbranch_scc1 .LBB1_30
	v_cmp_gt_i32_e32 vcc, s39, v10
	s_mul_i32 s0, s43, s14
	v_mul_lo_u32 v11, s44, v10
	v_add3_u32 v8, s0, v11, v8
	v_add_lshl_u32 v7, v8, v7, 1
	s_lshl_b32 s10, s43, 1
	s_lshl_b32 s11, s21, 1
	s_mul_i32 s0, s51, s14
	v_mul_lo_u32 v8, s20, v10
	v_add3_u32 v6, s0, v8, v6
	v_add_lshl_u32 v5, v6, v5, 1
	s_lshl_b32 s12, s51, 1
	s_lshl_b32 s13, s19, 1
	s_add_i32 s0, s15, s17
	v_add3_u32 v6, v0, v9, s0
	s_mov_b32 s19, s14
	s_branch .LBB1_27
.LBB1_26:
	s_or_b64 exec, exec, s[2:3]
	s_add_i32 s19, s19, 1
	v_add_u32_e32 v7, s10, v7
	s_cmp_ge_i32 s19, s37
	v_add_u32_e32 v5, s12, v5
	s_cbranch_scc1 .LBB1_30
.LBB1_27:
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_26
	s_mov_b64 s[6:7], 0
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v12, v7
.LBB1_29:
	buffer_load_ushort v13, v12, s[28:31], 0 offen
	s_mov_b32 s54, s30
	s_mov_b32 s55, s31
	v_add_u32_e32 v12, s11, v12
	v_add_u32_e32 v8, s26, v8
	v_cmp_le_i32_e64 s[0:1], s39, v8
	s_or_b64 s[6:7], s[0:1], s[6:7]
	s_waitcnt vmcnt(0)
	buffer_store_short v13, v11, s[52:55], 0 offen
	v_add_u32_e32 v11, s13, v11
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execnz .LBB1_29
	s_branch .LBB1_26
.LBB1_30:
	s_cmp_ge_i32 s37, s38
	s_cbranch_scc1 .LBB1_36
	v_cmp_gt_i32_e32 vcc, s39, v10
	s_mul_i32 s0, s47, s14
	v_mul_lo_u32 v5, s48, v10
	v_add3_u32 v4, s0, v5, v4
	v_add_lshl_u32 v3, v4, v3, 1
	s_lshl_b32 s19, s47, 1
	s_lshl_b32 s18, s18, 1
	s_mul_i32 s0, s23, s14
	v_mul_lo_u32 v4, s24, v10
	v_add3_u32 v2, s0, v4, v2
	v_add_lshl_u32 v1, v2, v1, 1
	s_lshl_b32 s20, s23, 1
	s_lshl_b32 s16, s16, 1
	s_add_i32 s15, s15, s17
	v_add3_u32 v0, v0, v9, s15
	s_branch .LBB1_33
.LBB1_32:
	s_or_b64 exec, exec, s[2:3]
	s_add_i32 s14, s14, 1
	v_add_u32_e32 v3, s19, v3
	s_cmp_ge_i32 s14, s38
	v_add_u32_e32 v1, s20, v1
	s_cbranch_scc1 .LBB1_36
.LBB1_33:
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_32
	s_mov_b64 s[12:13], 0
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v4, v1
	v_mov_b32_e32 v5, v3
.LBB1_35:
	s_mov_b32 s10, s30
	s_mov_b32 s11, s31
	buffer_load_ushort v6, v5, s[8:11], 0 offen
	s_mov_b32 s6, s30
	s_mov_b32 s7, s31
	v_add_u32_e32 v2, s26, v2
	v_add_u32_e32 v5, s18, v5
	v_cmp_le_i32_e64 s[0:1], s39, v2
	s_or_b64 s[12:13], s[0:1], s[12:13]
	s_waitcnt vmcnt(0)
	buffer_store_short v6, v4, s[4:7], 0 offen
	v_add_u32_e32 v4, s16, v4
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB1_35
	s_branch .LBB1_32
.LBB1_36:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 152
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 52
		.amdhsa_next_free_sgpr 60
		.amdhsa_accum_offset 52
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
	.section	.text._ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,"axG",@progbits,_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii,comdat
.Lfunc_end1:
	.size	_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii, .Lfunc_end1-_ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii

	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.num_vgpr, 52
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.num_agpr, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.numbered_sgpr, 60
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.private_seg_size, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.uses_vcc, 1
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.uses_flat_scratch, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_recursion, 0
	.set _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_3e5f88a9e7b3691c,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_3e5f88a9e7b3691c
__hip_cuid_3e5f88a9e7b3691c:
	.byte	0
	.size	__hip_cuid_3e5f88a9e7b3691c, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_3e5f88a9e7b3691c
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .offset:         68
        .size:           4
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     by_value
      - .offset:         76
        .size:           4
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     by_value
      - .offset:         92
        .size:           4
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     by_value
      - .offset:         100
        .size:           4
        .value_kind:     by_value
      - .offset:         104
        .size:           4
        .value_kind:     by_value
      - .offset:         108
        .size:           4
        .value_kind:     by_value
      - .offset:         112
        .size:           4
        .value_kind:     by_value
      - .offset:         116
        .size:           4
        .value_kind:     by_value
      - .offset:         120
        .size:           4
        .value_kind:     by_value
      - .offset:         124
        .size:           4
        .value_kind:     by_value
      - .offset:         128
        .size:           4
        .value_kind:     by_value
      - .offset:         132
        .size:           4
        .value_kind:     by_value
      - .offset:         136
        .size:           4
        .value_kind:     by_value
      - .offset:         140
        .size:           4
        .value_kind:     by_value
      - .offset:         144
        .size:           4
        .value_kind:     by_value
      - .offset:         148
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 152
    .max_flat_workgroup_size: 256
    .name:           _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     58
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi2ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     54
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .offset:         68
        .size:           4
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     by_value
      - .offset:         76
        .size:           4
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     by_value
      - .offset:         92
        .size:           4
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     by_value
      - .offset:         100
        .size:           4
        .value_kind:     by_value
      - .offset:         104
        .size:           4
        .value_kind:     by_value
      - .offset:         108
        .size:           4
        .value_kind:     by_value
      - .offset:         112
        .size:           4
        .value_kind:     by_value
      - .offset:         116
        .size:           4
        .value_kind:     by_value
      - .offset:         120
        .size:           4
        .value_kind:     by_value
      - .offset:         124
        .size:           4
        .value_kind:     by_value
      - .offset:         128
        .size:           4
        .value_kind:     by_value
      - .offset:         132
        .size:           4
        .value_kind:     by_value
      - .offset:         136
        .size:           4
        .value_kind:     by_value
      - .offset:         140
        .size:           4
        .value_kind:     by_value
      - .offset:         144
        .size:           4
        .value_kind:     by_value
      - .offset:         148
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 152
    .max_flat_workgroup_size: 256
    .name:           _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     66
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter32kn_entry_2c_sbhd_cached_indirectINS_11OpCachedFwdELi1ELb1ELb0ELb1ELb1ELb1ELb1ELi1ELb1E12hip_bfloat16S2_xEEvPT9_S4_PKS3_S6_PKT10_S9_PKT11_iiiiiiiiiiiiiiiiiiiiiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     52
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
