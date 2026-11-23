	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii,"axG",@progbits,_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii,comdat
	.protected	_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii
	.globl	_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii
	.p2align	8
	.type	_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii,@function
_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mov_b64 s[28:29], s[2:3]
	s_load_dwordx4 s[36:39], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s2, s38
	v_cvt_f32_u32_e32 v1, s2
	s_lshl_b32 s33, s16, 8
	v_rcp_iflag_f32_e32 v1, v1
	v_or_b32_e32 v3, s33, v0
	s_xor_b32 s3, s33, s38
	s_ashr_i32 s17, s3, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_sub_u32_e32 v2, 0, v3
	v_max_i32_e32 v2, v3, v2
	s_sub_i32 s3, 0, s2
	v_mul_lo_u32 v4, s3, v1
	v_mul_hi_u32 v4, v1, v4
	v_add_u32_e32 v1, v1, v4
	v_mul_hi_u32 v1, v2, v1
	v_mul_lo_u32 v4, v1, s2
	v_sub_u32_e32 v2, v2, v4
	v_add_u32_e32 v4, 1, v1
	v_cmp_le_u32_e32 vcc, s2, v2
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v4, vcc
	v_subrev_u32_e32 v4, s2, v2
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_add_u32_e32 v4, 1, v1
	v_cmp_le_u32_e32 vcc, s2, v2
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v4, vcc
	v_xor_b32_e32 v20, s17, v1
	v_subrev_u32_e32 v2, s17, v20
	v_cmp_gt_i32_e32 vcc, s39, v2
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_27
	s_mov_b64 s[18:19], s[6:7]
	s_mul_i32 s2, s37, s14
	s_abs_i32 s3, s2
	v_cvt_f32_u32_e32 v4, s3
	s_load_dwordx8 s[20:27], s[0:1], 0x38
	v_mul_lo_u32 v1, v2, s38
	v_rcp_iflag_f32_e32 v4, v4
	v_sub_u32_e32 v5, 0, v2
	v_sub_u32_e32 v11, v3, v1
	v_xor_b32_e32 v3, s2, v2
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	v_max_i32_e32 v5, v2, v5
	v_ashrrev_i32_e32 v3, 31, v3
	s_sub_i32 s0, 0, s3
	v_mul_lo_u32 v6, s0, v4
	v_mul_hi_u32 v6, v4, v6
	v_add_u32_e32 v4, v4, v6
	v_mul_hi_u32 v4, v5, v4
	v_mul_lo_u32 v6, v4, s3
	v_add_u32_e32 v7, 1, v4
	v_sub_u32_e32 v5, v5, v6
	v_cmp_le_u32_e32 vcc, s3, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v7, vcc
	v_subrev_u32_e32 v6, s3, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_add_u32_e32 v6, 1, v4
	v_cmp_le_u32_e32 vcc, s3, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v6, vcc
	s_abs_i32 s0, s14
	v_cvt_f32_u32_e32 v5, s0
	v_xor_b32_e32 v4, v4, v3
	v_sub_u32_e32 v3, v4, v3
	v_mul_lo_u32 v4, v3, s2
	v_rcp_iflag_f32_e32 v5, v5
	v_sub_u32_e32 v18, v2, v4
	v_xor_b32_e32 v2, s14, v18
	v_ashrrev_i32_e32 v2, 31, v2
	v_mul_f32_e32 v4, 0x4f7ffffe, v5
	v_cvt_u32_f32_e32 v4, v4
	v_sub_u32_e32 v5, 0, v18
	v_max_i32_e32 v5, v18, v5
	s_sub_i32 s1, 0, s0
	v_mul_lo_u32 v6, s1, v4
	v_mul_hi_u32 v6, v4, v6
	v_add_u32_e32 v4, v4, v6
	v_mul_hi_u32 v4, v5, v4
	v_mul_lo_u32 v6, v4, s0
	v_sub_u32_e32 v5, v5, v6
	v_add_u32_e32 v6, 1, v4
	v_cmp_le_u32_e32 vcc, s0, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_subrev_u32_e32 v6, s0, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_add_u32_e32 v6, 1, v4
	v_cmp_le_u32_e32 vcc, s0, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_xor_b32_e32 v4, v4, v2
	v_sub_u32_e32 v19, v4, v2
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s37, s20, 2
	v_mul_lo_u32 v16, v3, s21
	v_mul_lo_u32 v12, v18, s22
	v_mul_lo_u32 v13, v3, s25
	v_mul_lo_u32 v10, v18, s26
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s7, 0x20000
	s_mov_b32 s6, -1
	s_and_b32 s29, s29, 0xffff
	s_cmp_gt_i32 s15, 0
	s_cselect_b64 s[34:35], -1, 0
	s_cmp_lt_i32 s15, 1
	v_lshlrev_b32_e32 v17, 2, v11
	s_cbranch_scc1 .LBB0_8
	v_mul_lo_u32 v2, v19, s37
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_lshl_add_u64 v[6:7], s[18:19], 0, v[2:3]
	v_lshl_add_u64 v[2:3], s[8:9], 0, v[2:3]
	v_and_b32_e32 v7, 0xffff, v7
	v_mov_b32_e32 v8, -1
	v_mov_b32_e32 v9, 0x20000
	v_and_b32_e32 v3, 0xffff, v3
	v_mov_b32_e32 v4, v8
	v_mov_b32_e32 v5, v9
	s_mov_b64 s[2:3], exec
.LBB0_3:
	v_readfirstlane_b32 s40, v6
	v_readfirstlane_b32 s41, v7
	s_nop 1
	v_cmp_eq_u64_e32 vcc, s[40:41], v[6:7]
	v_readfirstlane_b32 s42, v8
	v_readfirstlane_b32 s43, v9
	s_nop 1
	v_cmp_eq_u64_e64 s[0:1], s[42:43], v[8:9]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dword v14, v17, s[40:43], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_5:
	v_readfirstlane_b32 s40, v2
	v_readfirstlane_b32 s41, v3
	s_nop 1
	v_cmp_eq_u64_e32 vcc, s[40:41], v[2:3]
	v_readfirstlane_b32 s42, v4
	v_readfirstlane_b32 s43, v5
	s_nop 1
	v_cmp_eq_u64_e64 s[0:1], s[42:43], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dword v15, v17, s[40:43], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_5
	s_mov_b64 exec, s[2:3]
	v_add_lshl_u32 v4, v11, s37, 2
	s_waitcnt vmcnt(0)
	v_pk_mov_b32 v[2:3], v[14:15], v[14:15] op_sel:[1,0]
	v_lshlrev_b32_e32 v5, 2, v16
	v_lshl_add_u32 v5, v12, 2, v5
	s_lshl_b32 s0, s23, 2
	v_lshlrev_b32_e32 v6, 2, v0
	v_lshl_or_b32 v6, s16, 10, v6
	v_lshlrev_b32_e32 v7, 2, v1
	v_sub_u32_e32 v6, v6, v7
	v_lshlrev_b32_e32 v7, 2, v13
	v_lshl_add_u32 v7, v10, 2, v7
	s_lshl_b32 s1, s27, 2
	s_mov_b32 s30, s6
	s_mov_b32 s31, s7
	s_mov_b32 s2, s15
.LBB0_7:
	v_add_u32_e32 v8, v6, v5
	v_add_u32_e32 v9, v4, v5
	buffer_load_dword v9, v9, s[4:7], 0 offen
	buffer_load_dword v8, v8, s[4:7], 0 offen
	v_add_u32_e32 v21, v6, v7
	v_add_u32_e32 v25, v4, v7
	v_add_u32_e32 v5, s0, v5
	v_add_u32_e32 v7, s1, v7
	s_add_i32 s2, s2, -1
	s_cmp_lg_u32 s2, 0
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v22, v15, v9
	v_mul_f32_e32 v24, v3, v9
	s_waitcnt vmcnt(0)
	v_pk_fma_f32 v[22:23], v[14:15], v[8:9], v[22:23] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[8:9], v[2:3], v[8:9], v[24:25] op_sel_hi:[1,1,0]
	buffer_store_dword v22, v21, s[28:31], 0 offen
	buffer_store_dword v8, v25, s[28:31], 0 offen
	s_cbranch_scc1 .LBB0_7
.LBB0_8:
	s_ashr_i32 s18, s20, 1
	s_lshl_b32 s20, s37, 1
	s_cmp_gt_i32 s18, s20
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[2:3], s[0:1], s[34:35]
	v_cndmask_b32_e64 v2, 0, 1, s[2:3]
	v_cmp_ne_u32_e64 s[0:1], 1, v2
	s_andn2_b64 vcc, exec, s[2:3]
	v_add_u32_e32 v21, s20, v11
	s_mul_i32 s21, s38, s24
	s_mul_i32 s19, s38, s36
	v_sub_u32_e32 v2, s17, v20
	v_cmp_gt_i32_e64 s[2:3], s18, v21
	v_mul_lo_u32 v20, s38, v2
	s_cbranch_vccnz .LBB0_14
	v_mad_u64_u32 v[2:3], s[8:9], s24, v21, v[12:13]
	v_add_lshl_u32 v2, v2, v16, 2
	s_lshl_b32 s22, s23, 2
	s_lshl_b32 s25, s21, 2
	v_mad_u64_u32 v[4:5], s[8:9], s36, v21, v[10:11]
	v_add_lshl_u32 v3, v4, v13, 2
	s_lshl_b32 s26, s27, 2
	s_lshl_b32 s39, s19, 2
	s_add_i32 s8, s20, s33
	v_add3_u32 v4, v0, v20, s8
	s_mov_b32 s40, 0
	s_branch .LBB0_11
.LBB0_10:
	s_or_b64 exec, exec, s[8:9]
	s_add_i32 s40, s40, 1
	v_add_u32_e32 v2, s22, v2
	s_cmp_eq_u32 s40, s15
	v_add_u32_e32 v3, s26, v3
	s_cbranch_scc1 .LBB0_14
.LBB0_11:
	s_and_saveexec_b64 s[8:9], s[2:3]
	s_cbranch_execz .LBB0_10
	s_mov_b64 s[16:17], 0
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v7, v2
.LBB0_13:
	buffer_load_dword v8, v7, s[4:7], 0 offen
	s_mov_b32 s30, s6
	s_mov_b32 s31, s7
	v_add_u32_e32 v7, s25, v7
	v_add_u32_e32 v5, s38, v5
	v_cmp_le_i32_e32 vcc, s18, v5
	s_or_b64 s[16:17], vcc, s[16:17]
	s_waitcnt vmcnt(0)
	buffer_store_dword v8, v6, s[28:31], 0 offen
	v_add_u32_e32 v6, s39, v6
	s_andn2_b64 exec, exec, s[16:17]
	s_cbranch_execnz .LBB0_13
	s_branch .LBB0_10
.LBB0_14:
	s_andn2_b64 vcc, exec, s[34:35]
	s_cbranch_vccnz .LBB0_21
	v_mul_lo_u32 v2, v19, s14
	v_sub_u32_e32 v2, v18, v2
	s_mul_i32 s2, s24, s18
	v_add3_u32 v18, v12, v16, s2
	s_mul_i32 s2, s36, s18
	v_add3_u32 v19, v10, v13, s2
	v_mul_lo_u32 v2, v2, s37
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_lshl_add_u64 v[6:7], s[10:11], 0, v[2:3]
	v_lshl_add_u64 v[2:3], s[12:13], 0, v[2:3]
	v_and_b32_e32 v7, 0xffff, v7
	v_mov_b32_e32 v8, -1
	v_mov_b32_e32 v9, 0x20000
	v_and_b32_e32 v3, 0xffff, v3
	v_mov_b32_e32 v4, v8
	v_mov_b32_e32 v5, v9
	s_mov_b32 s14, 0
	s_mov_b64 s[12:13], exec
.LBB0_16:
	v_readfirstlane_b32 s8, v6
	v_readfirstlane_b32 s9, v7
	s_nop 1
	v_cmp_eq_u64_e32 vcc, s[8:9], v[6:7]
	v_readfirstlane_b32 s10, v8
	v_readfirstlane_b32 s11, v9
	s_nop 1
	v_cmp_eq_u64_e64 s[2:3], s[10:11], v[8:9]
	s_and_b64 s[2:3], vcc, s[2:3]
	s_and_saveexec_b64 s[2:3], s[2:3]
	buffer_load_dword v14, v17, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_16
	s_mov_b64 exec, s[12:13]
	s_mov_b64 s[12:13], exec
.LBB0_18:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	s_nop 1
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	s_nop 1
	v_cmp_eq_u64_e64 s[2:3], s[10:11], v[4:5]
	s_and_b64 s[2:3], vcc, s[2:3]
	s_and_saveexec_b64 s[2:3], s[2:3]
	buffer_load_dword v15, v17, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_18
	s_mov_b64 exec, s[12:13]
	v_add_lshl_u32 v4, v11, s37, 2
	s_waitcnt vmcnt(0)
	v_pk_mov_b32 v[2:3], v[14:15], v[14:15] op_sel:[1,0]
	s_mov_b32 s30, s6
	s_mov_b32 s31, s7
.LBB0_20:
	s_mul_i32 s2, s14, s23
	v_add_lshl_u32 v5, s2, v18, 2
	v_add_u32_e32 v6, v5, v17
	v_add_u32_e32 v5, v5, v4
	buffer_load_dword v7, v5, s[4:7], 0 offen
	buffer_load_dword v6, v6, s[4:7], 0 offen
	s_mul_i32 s2, s14, s27
	s_add_i32 s14, s14, 1
	v_add_lshl_u32 v5, s2, v19, 2
	s_cmp_lg_u32 s14, s15
	v_add_u32_e32 v11, v5, v17
	v_add_u32_e32 v5, v5, v4
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v8, v15, v7
	v_mul_f32_e32 v22, v3, v7
	s_waitcnt vmcnt(0)
	v_pk_fma_f32 v[8:9], v[14:15], v[6:7], v[8:9] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[6:7], v[2:3], v[6:7], v[22:23] op_sel_hi:[1,1,0]
	buffer_store_dword v8, v11, s[28:31], 0 offen
	buffer_store_dword v6, v5, s[28:31], 0 offen
	s_cbranch_scc1 .LBB0_20
.LBB0_21:
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB0_27
	v_cmp_gt_i32_e32 vcc, s18, v21
	s_add_i32 s2, s20, s33
	s_add_i32 s0, s2, s18
	v_add_u32_e32 v2, s0, v0
	v_sub_u32_e32 v4, v2, v1
	v_mad_u64_u32 v[2:3], s[0:1], s24, v4, v[12:13]
	v_add_lshl_u32 v1, v2, v16, 2
	s_lshl_b32 s10, s23, 2
	s_lshl_b32 s11, s21, 2
	v_mad_u64_u32 v[2:3], s[0:1], s36, v4, v[10:11]
	v_add_lshl_u32 v2, v2, v13, 2
	s_lshl_b32 s12, s27, 2
	s_lshl_b32 s13, s19, 2
	v_add3_u32 v0, v0, v20, s2
	s_mov_b32 s14, 0
	s_branch .LBB0_24
.LBB0_23:
	s_or_b64 exec, exec, s[2:3]
	s_add_i32 s14, s14, 1
	v_add_u32_e32 v1, s10, v1
	s_cmp_eq_u32 s14, s15
	v_add_u32_e32 v2, s12, v2
	s_cbranch_scc1 .LBB0_27
.LBB0_24:
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_23
	s_mov_b64 s[8:9], 0
	v_mov_b32_e32 v3, v0
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v1
.LBB0_26:
	buffer_load_dword v6, v5, s[4:7], 0 offen
	s_mov_b32 s30, s6
	s_mov_b32 s31, s7
	v_add_u32_e32 v5, s11, v5
	v_add_u32_e32 v3, s38, v3
	v_cmp_le_i32_e64 s[0:1], s18, v3
	s_or_b64 s[8:9], s[0:1], s[8:9]
	s_waitcnt vmcnt(0)
	buffer_store_dword v6, v4, s[28:31], 0 offen
	v_add_u32_e32 v4, s13, v4
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz .LBB0_26
	s_branch .LBB0_23
.LBB0_27:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 104
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
		.amdhsa_next_free_vgpr 26
		.amdhsa_next_free_sgpr 44
		.amdhsa_accum_offset 28
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
	.section	.text._ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii,"axG",@progbits,_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii,comdat
.Lfunc_end0:
	.size	_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii, .Lfunc_end0-_ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii

	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.num_vgpr, 26
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.num_agpr, 0
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.numbered_sgpr, 44
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.private_seg_size, 0
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.uses_vcc, 1
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.uses_flat_scratch, 0
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.has_dyn_sized_stack, 0
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.has_recursion, 0
	.set _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_5424eaa7832eeb9d,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_5424eaa7832eeb9d
__hip_cuid_5424eaa7832eeb9d:
	.byte	0
	.size	__hip_cuid_5424eaa7832eeb9d, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_5424eaa7832eeb9d
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
      - .actual_access:  read_only
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
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 104
    .max_flat_workgroup_size: 256
    .name:           _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     50
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe27kn_entry_1c_2d_cached_fixedIN5aiter11OpCachedFwdELi0ELb1ELb0ELb1ELb1ELi1EffEEvPT6_PKS3_PKT7_S9_S9_S9_iiiiiiiiiiiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     26
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
