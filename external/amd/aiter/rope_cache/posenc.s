	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,comdat
	.protected	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
	.globl	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
	.p2align	8
	.type	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,@function
_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_load_dword s28, s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s29, s28, 31
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s2, s2, s18
	s_addc_u32 s3, s3, s19
	s_load_dwordx2 s[2:3], s[2:3], 0x0
	s_load_dwordx8 s[20:27], s[0:1], 0x40
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s18, s2, s29
	s_mul_hi_u32 s19, s2, s28
	s_add_i32 s18, s19, s18
	s_mul_i32 s3, s3, s28
	s_add_i32 s18, s18, s3
	s_mul_i32 s2, s2, s28
	s_lshr_b32 s3, s18, 31
	s_add_u32 s2, s2, s3
	s_addc_u32 s18, s18, 0
	s_and_b32 s19, s2, -2
	s_add_u32 s2, s12, s19
	s_addc_u32 s3, s13, s18
	s_add_u32 s12, s14, s19
	s_addc_u32 s13, s15, s18
	s_lshr_b32 s14, s28, 31
	s_add_i32 s28, s28, s14
	s_ashr_i32 s14, s28, 1
	s_mul_i32 s24, s24, s14
	v_cmp_gt_i32_e32 vcc, s24, v0
	s_and_saveexec_b64 s[18:19], vcc
	s_cbranch_execz .LBB0_27
	s_mul_i32 s15, s20, s17
	s_abs_i32 s27, s14
	v_cvt_f32_u32_e32 v1, s27
	s_mul_hi_u32 s28, s20, s16
	s_add_i32 s15, s28, s15
	s_mul_i32 s21, s21, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s28, s[0:1], 0x6c
	s_add_i32 s21, s15, s21
	s_mul_i32 s20, s20, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s33, s28, 0xffff
	s_ashr_i32 s15, s14, 31
	s_sub_i32 s28, 0, s27
	v_mul_lo_u32 v2, s28, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	s_sub_i32 s34, 0, s14
	s_mov_b64 s[28:29], 0
	s_mov_b32 s35, 0x7f800000
	s_movk_i32 s36, 0x7fff
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, v0
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[30:31]
	v_lshl_add_u64 v[6:7], s[14:15], 1, v[6:7]
	v_add_u32_e32 v2, s33, v2
	v_cmp_le_i32_e32 vcc, s24, v2
	s_or_b64 s[28:29], vcc, s[28:29]
	global_store_short_d16_hi v[6:7], v4, off
	s_andn2_b64 exec, exec, s[28:29]
	s_cbranch_execz .LBB0_27
.LBB0_3:
	v_ashrrev_i32_e32 v4, 31, v2
	v_xor_b32_e32 v4, s15, v4
	v_sub_u32_e32 v5, 0, v2
	v_max_i32_e32 v5, v2, v5
	v_mul_hi_u32 v6, v5, v1
	v_mul_lo_u32 v7, v6, s27
	v_sub_u32_e32 v5, v5, v7
	v_add_u32_e32 v7, 1, v6
	v_cmp_le_u32_e32 vcc, s27, v5
	s_nop 1
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_subrev_u32_e32 v7, s27, v5
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_add_u32_e32 v7, 1, v6
	v_cmp_le_u32_e32 vcc, s27, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v6, v7, vcc
	v_xor_b32_e32 v5, v5, v4
	v_sub_u32_e32 v8, v5, v4
	v_mul_lo_u32 v4, v8, s26
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[6:7], s[20:21], 0, v[4:5]
	v_mad_u64_u32 v[8:9], s[30:31], s34, v8, v[2:3]
	v_lshl_add_u64 v[4:5], v[6:7], 1, s[4:5]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshlrev_b64 v[10:11], 1, v[8:9]
	v_lshl_add_u64 v[12:13], s[2:3], 0, v[10:11]
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[10:11]
	global_load_ushort v16, v[4:5], off
	global_load_ushort v12, v[12:13], off
	v_lshl_add_u64 v[4:5], s[14:15], 1, v[4:5]
	global_load_ushort v14, v[4:5], off
	v_lshl_add_u64 v[4:5], s[12:13], 0, v[10:11]
	global_load_ushort v15, v[4:5], off
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v11, 16, v16
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v10, 16, v12
	v_mov_b32_e32 v4, v11
	v_pk_mul_f32 v[12:13], v[4:5], v[10:11]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v12
	v_cmp_ne_u32_e32 vcc, s35, v5
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v5, v12, 16, 1
	v_add3_u32 v5, v12, v5, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	v_or_b32_e32 v5, 0x10000, v12
	v_cmp_eq_u32_sdwa vcc, v12, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v12, vcc
	s_or_b64 exec, exec, s[30:31]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v13, 16, v14
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v12, 16, v15
	v_mov_b32_e32 v14, v13
	v_pk_mul_f32 v[16:17], v[14:15], v[12:13]
	s_nop 0
	v_and_b32_e32 v15, 0x7f800000, v16
	v_cmp_ne_u32_e32 vcc, s35, v15
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v15, v16, 16, 1
	v_add3_u32 v15, v16, v15, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	v_or_b32_e32 v15, 0x10000, v16
	v_cmp_eq_u32_sdwa vcc, v16, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v15, v15, v16, vcc
	s_or_b64 exec, exec, s[30:31]
	v_and_b32_e32 v5, 0xffff0000, v5
	v_and_b32_e32 v15, 0xffff0000, v15
	v_sub_f32_e32 v5, v5, v15
	v_and_b32_e32 v15, 0x7f800000, v5
	v_cmp_ne_u32_e32 vcc, s35, v15
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v15, v5, 16, 1
	v_add3_u32 v15, v5, v15, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	v_or_b32_e32 v15, 0x10000, v5
	v_cmp_eq_u32_sdwa vcc, v5, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v15, v15, v5, vcc
	s_or_b64 exec, exec, s[30:31]
	v_lshl_add_u64 v[6:7], v[6:7], 1, s[6:7]
	v_lshl_add_u64 v[6:7], v[8:9], 1, v[6:7]
	global_store_short_d16_hi v[6:7], v15, off
	v_pk_mul_f32 v[8:9], v[14:15], v[10:11]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v8
	v_cmp_ne_u32_e32 vcc, s35, v5
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v5, v8, 16, 1
	v_add3_u32 v10, v8, v5, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	v_or_b32_e32 v5, 0x10000, v8
	v_cmp_eq_u32_sdwa vcc, v8, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v10, v5, v8, vcc
	s_or_b64 exec, exec, s[30:31]
	v_pk_mul_f32 v[4:5], v[4:5], v[12:13]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v4
	v_cmp_ne_u32_e32 vcc, s35, v5
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v5, v4, 16, 1
	v_add3_u32 v8, v4, v5, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	v_or_b32_e32 v5, 0x10000, v4
	v_cmp_eq_u32_sdwa vcc, v4, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v8, v5, v4, vcc
	s_or_b64 exec, exec, s[30:31]
	v_and_b32_e32 v4, 0xffff0000, v10
	v_and_b32_e32 v5, 0xffff0000, v8
	v_add_f32_e32 v5, v4, v5
	v_and_b32_e32 v4, 0x7f800000, v5
	v_cmp_ne_u32_e32 vcc, s35, v4
	s_and_saveexec_b64 s[30:31], vcc
	s_xor_b64 s[30:31], exec, s[30:31]
	v_bfe_u32 v4, v5, 16, 1
	v_add3_u32 v4, v5, v4, s36
	s_andn2_saveexec_b64 s[30:31], s[30:31]
	s_cbranch_execz .LBB0_2
	v_or_b32_e32 v4, 0x10000, v5
	v_cmp_eq_u32_sdwa vcc, v5, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v5, vcc
	s_branch .LBB0_2
.LBB0_27:
	s_or_b64 exec, exec, s[18:19]
	s_mul_i32 s18, s25, s14
	v_cmp_gt_i32_e32 vcc, s18, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_54
	s_mul_i32 s4, s22, s17
	s_abs_i32 s17, s14
	v_cvt_f32_u32_e32 v1, s17
	s_mul_hi_u32 s5, s22, s16
	s_add_i32 s4, s5, s4
	s_mul_i32 s5, s23, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s6, s[0:1], 0x6c
	s_add_i32 s1, s4, s5
	s_mul_i32 s0, s22, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s16, s6, 0xffff
	s_ashr_i32 s15, s14, 31
	s_sub_i32 s4, 0, s17
	v_mul_lo_u32 v2, s4, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	s_sub_i32 s19, 0, s14
	s_mov_b64 s[4:5], 0
	s_mov_b32 s20, 0x7f800000
	s_movk_i32 s21, 0x7fff
	v_mov_b32_e32 v13, 0
	s_branch .LBB0_30
.LBB0_29:
	s_or_b64 exec, exec, s[6:7]
	v_lshl_add_u64 v[4:5], s[14:15], 1, v[4:5]
	v_add_u32_e32 v0, s16, v0
	v_cmp_le_i32_e32 vcc, s18, v0
	s_or_b64 s[4:5], vcc, s[4:5]
	global_store_short_d16_hi v[4:5], v2, off
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_54
.LBB0_30:
	v_ashrrev_i32_e32 v2, 31, v0
	v_xor_b32_e32 v2, s15, v2
	v_sub_u32_e32 v3, 0, v0
	v_max_i32_e32 v3, v0, v3
	v_mul_hi_u32 v4, v3, v1
	v_mul_lo_u32 v5, v4, s17
	v_sub_u32_e32 v3, v3, v5
	v_add_u32_e32 v5, 1, v4
	v_cmp_le_u32_e32 vcc, s17, v3
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_subrev_u32_e32 v5, s17, v3
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_add_u32_e32 v5, 1, v4
	v_cmp_le_u32_e32 vcc, s17, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v4, v5, vcc
	v_xor_b32_e32 v3, v3, v2
	v_sub_u32_e32 v6, v3, v2
	v_mul_lo_u32 v2, v6, s26
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[2:3]
	v_mad_u64_u32 v[6:7], s[6:7], s19, v6, v[0:1]
	v_lshl_add_u64 v[2:3], v[4:5], 1, s[8:9]
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshlrev_b64 v[8:9], 1, v[6:7]
	v_lshl_add_u64 v[10:11], s[2:3], 0, v[8:9]
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	global_load_ushort v15, v[2:3], off
	global_load_ushort v10, v[10:11], off
	v_lshl_add_u64 v[2:3], s[14:15], 1, v[2:3]
	global_load_ushort v12, v[2:3], off
	v_lshl_add_u64 v[2:3], s[12:13], 0, v[8:9]
	global_load_ushort v14, v[2:3], off
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v9, 16, v15
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v8, 16, v10
	v_mov_b32_e32 v2, v9
	v_pk_mul_f32 v[10:11], v[2:3], v[8:9]
	s_nop 0
	v_and_b32_e32 v3, 0x7f800000, v10
	v_cmp_ne_u32_e32 vcc, s20, v3
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v3, v10, 16, 1
	v_add3_u32 v3, v10, v3, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v3, 0x10000, v10
	v_cmp_eq_u32_sdwa vcc, v10, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v10, vcc
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v11, 16, v12
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v10, 16, v14
	v_mov_b32_e32 v12, v11
	v_pk_mul_f32 v[14:15], v[12:13], v[10:11]
	s_nop 0
	v_and_b32_e32 v15, 0x7f800000, v14
	v_cmp_ne_u32_e32 vcc, s20, v15
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v15, v14, 16, 1
	v_add3_u32 v16, v14, v15, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v15, 0x10000, v14
	v_cmp_eq_u32_sdwa vcc, v14, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v16, v15, v14, vcc
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_e32 v3, 0xffff0000, v3
	v_and_b32_e32 v14, 0xffff0000, v16
	v_sub_f32_e32 v3, v3, v14
	v_and_b32_e32 v14, 0x7f800000, v3
	v_cmp_ne_u32_e32 vcc, s20, v14
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v14, v3, 16, 1
	v_add3_u32 v14, v3, v14, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v14, 0x10000, v3
	v_cmp_eq_u32_sdwa vcc, v3, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v14, v14, v3, vcc
	s_or_b64 exec, exec, s[6:7]
	v_lshl_add_u64 v[4:5], v[4:5], 1, s[10:11]
	v_lshl_add_u64 v[4:5], v[6:7], 1, v[4:5]
	global_store_short_d16_hi v[4:5], v14, off
	v_pk_mul_f32 v[6:7], v[12:13], v[8:9]
	s_nop 0
	v_and_b32_e32 v3, 0x7f800000, v6
	v_cmp_ne_u32_e32 vcc, s20, v3
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v3, v6, 16, 1
	v_add3_u32 v8, v6, v3, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v3, 0x10000, v6
	v_cmp_eq_u32_sdwa vcc, v6, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v8, v3, v6, vcc
	s_or_b64 exec, exec, s[6:7]
	v_pk_mul_f32 v[2:3], v[2:3], v[10:11]
	s_nop 0
	v_and_b32_e32 v3, 0x7f800000, v2
	v_cmp_ne_u32_e32 vcc, s20, v3
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v3, v2, 16, 1
	v_add3_u32 v6, v2, v3, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v3, 0x10000, v2
	v_cmp_eq_u32_sdwa vcc, v2, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v6, v3, v2, vcc
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_e32 v2, 0xffff0000, v8
	v_and_b32_e32 v3, 0xffff0000, v6
	v_add_f32_e32 v3, v2, v3
	v_and_b32_e32 v2, 0x7f800000, v3
	v_cmp_ne_u32_e32 vcc, s20, v2
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v2, v3, 16, 1
	v_add3_u32 v2, v3, v2, s21
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_29
	v_or_b32_e32 v2, 0x10000, v3
	v_cmp_eq_u32_sdwa vcc, v3, v13 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v3, vcc
	s_branch .LBB0_29
.LBB0_54:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 37
		.amdhsa_accum_offset 20
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
	.section	.text._ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,comdat
.Lfunc_end0:
	.size	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii, .Lfunc_end0-_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii

	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.num_vgpr, 18
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.num_agpr, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.numbered_sgpr, 37
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.private_seg_size, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.uses_vcc, 1
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.uses_flat_scratch, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_dyn_sized_stack, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_recursion, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_indirect_call, 0
	.section	.text._ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,comdat
	.protected	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
	.globl	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
	.p2align	8
	.type	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,@function
_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_load_dword s28, s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s29, s28, 31
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s2, s2, s18
	s_addc_u32 s3, s3, s19
	s_load_dwordx2 s[2:3], s[2:3], 0x0
	s_load_dwordx8 s[20:27], s[0:1], 0x40
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s18, s2, s29
	s_mul_hi_u32 s19, s2, s28
	s_add_i32 s18, s19, s18
	s_mul_i32 s3, s3, s28
	s_add_i32 s18, s18, s3
	s_mul_i32 s2, s2, s28
	s_lshr_b32 s3, s18, 31
	s_add_u32 s2, s2, s3
	s_addc_u32 s18, s18, 0
	s_and_b32 s19, s2, -2
	s_add_u32 s2, s12, s19
	s_addc_u32 s3, s13, s18
	s_add_u32 s12, s14, s19
	s_addc_u32 s13, s15, s18
	s_lshr_b32 s14, s28, 31
	s_add_i32 s28, s28, s14
	s_ashr_i32 s27, s28, 1
	s_mul_i32 s24, s24, s27
	v_cmp_gt_i32_e32 vcc, s24, v0
	v_lshlrev_b32_e32 v2, 1, v0
	s_and_saveexec_b64 s[14:15], vcc
	s_cbranch_execz .LBB1_27
	s_mul_i32 s18, s20, s17
	s_abs_i32 s30, s27
	v_cvt_f32_u32_e32 v1, s30
	s_mul_hi_u32 s19, s20, s16
	s_add_i32 s18, s19, s18
	s_mul_i32 s19, s21, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s21, s[0:1], 0x6c
	s_add_i32 s19, s18, s19
	s_mul_i32 s18, s20, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s31, s21, 0xffff
	s_ashr_i32 s33, s27, 31
	s_sub_i32 s20, 0, s30
	v_mul_lo_u32 v3, s20, v1
	v_mul_hi_u32 v3, v1, v3
	v_add_u32_e32 v1, v1, v3
	s_lshl_b32 s20, s27, 1
	s_sub_i32 s34, 0, s20
	v_lshlrev_b32_e32 v4, 1, v0
	s_lshl_b32 s35, s31, 1
	s_sub_i32 s36, 0, s27
	s_mov_b64 s[20:21], 0
	s_mov_b32 s37, 0x7f800000
	s_movk_i32 s38, 0x7fff
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v6, v0
	s_branch .LBB1_3
.LBB1_2:
	s_or_b64 exec, exec, s[28:29]
	global_store_short_d16_hi v[10:11], v7, off offset:2
	v_add_u32_e32 v6, s31, v6
	v_cmp_le_i32_e32 vcc, s24, v6
	s_or_b64 s[20:21], vcc, s[20:21]
	v_add_u32_e32 v4, s35, v4
	s_andn2_b64 exec, exec, s[20:21]
	s_cbranch_execz .LBB1_27
.LBB1_3:
	v_ashrrev_i32_e32 v5, 31, v6
	v_xor_b32_e32 v5, s33, v5
	v_sub_u32_e32 v7, 0, v6
	v_max_i32_e32 v7, v6, v7
	v_mul_hi_u32 v8, v7, v1
	v_mul_lo_u32 v9, v8, s30
	v_sub_u32_e32 v7, v7, v9
	v_add_u32_e32 v9, 1, v8
	v_cmp_le_u32_e32 vcc, s30, v7
	s_nop 1
	v_cndmask_b32_e32 v8, v8, v9, vcc
	v_subrev_u32_e32 v9, s30, v7
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_add_u32_e32 v9, 1, v8
	v_cmp_le_u32_e32 vcc, s30, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v8, v9, vcc
	v_xor_b32_e32 v7, v7, v5
	v_sub_u32_e32 v5, v7, v5
	v_mul_lo_u32 v8, v5, s26
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[10:11], s[18:19], 0, v[8:9]
	v_mad_u64_u32 v[8:9], s[28:29], s36, v5, v[6:7]
	v_lshl_add_u64 v[14:15], v[10:11], 1, s[4:5]
	v_mad_u64_u32 v[12:13], s[28:29], s34, v5, v[4:5]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshlrev_b64 v[8:9], 1, v[8:9]
	v_lshl_add_u64 v[16:17], s[2:3], 0, v[8:9]
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshl_add_u64 v[14:15], v[12:13], 1, v[14:15]
	global_load_dword v7, v[14:15], off
	global_load_ushort v5, v[16:17], off
	v_lshl_add_u64 v[8:9], s[12:13], 0, v[8:9]
	global_load_ushort v9, v[8:9], off
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v15, 16, v7
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v14, 16, v5
	v_mov_b32_e32 v8, v15
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[16:17], v[8:9], v[14:15]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v16
	v_cmp_ne_u32_e32 vcc, s37, v5
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v5, v16, 16, 1
	v_add3_u32 v5, v16, v5, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	v_or_b32_e32 v5, 0x10000, v16
	v_cmp_eq_u32_sdwa vcc, v16, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v16, vcc
	s_or_b64 exec, exec, s[28:29]
	v_and_b32_e32 v17, 0xffff0000, v7
	v_lshlrev_b32_e32 v16, 16, v9
	v_mov_b32_e32 v18, v17
	v_pk_mul_f32 v[20:21], v[18:19], v[16:17]
	s_nop 0
	v_and_b32_e32 v7, 0x7f800000, v20
	v_cmp_ne_u32_e32 vcc, s37, v7
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v7, v20, 16, 1
	v_add3_u32 v7, v20, v7, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	v_or_b32_e32 v7, 0x10000, v20
	v_cmp_eq_u32_sdwa vcc, v20, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v20, vcc
	s_or_b64 exec, exec, s[28:29]
	v_and_b32_e32 v5, 0xffff0000, v5
	v_and_b32_e32 v7, 0xffff0000, v7
	v_sub_f32_e32 v5, v5, v7
	v_and_b32_e32 v7, 0x7f800000, v5
	v_cmp_ne_u32_e32 vcc, s37, v7
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v7, v5, 16, 1
	v_add3_u32 v7, v5, v7, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	v_or_b32_e32 v7, 0x10000, v5
	v_cmp_eq_u32_sdwa vcc, v5, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v5, vcc
	s_or_b64 exec, exec, s[28:29]
	v_lshl_add_u64 v[10:11], v[10:11], 1, s[6:7]
	v_lshl_add_u64 v[10:11], v[12:13], 1, v[10:11]
	global_store_short_d16_hi v[10:11], v7, off
	v_pk_mul_f32 v[12:13], v[18:19], v[14:15]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v12
	v_cmp_ne_u32_e32 vcc, s37, v5
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v5, v12, 16, 1
	v_add3_u32 v5, v12, v5, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	v_or_b32_e32 v5, 0x10000, v12
	v_cmp_eq_u32_sdwa vcc, v12, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v12, vcc
	s_or_b64 exec, exec, s[28:29]
	v_pk_mul_f32 v[8:9], v[8:9], v[16:17]
	s_nop 0
	v_and_b32_e32 v7, 0x7f800000, v8
	v_cmp_ne_u32_e32 vcc, s37, v7
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v7, v8, 16, 1
	v_add3_u32 v7, v8, v7, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	v_or_b32_e32 v7, 0x10000, v8
	v_cmp_eq_u32_sdwa vcc, v8, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v8, vcc
	s_or_b64 exec, exec, s[28:29]
	v_and_b32_e32 v5, 0xffff0000, v5
	v_and_b32_e32 v7, 0xffff0000, v7
	v_add_f32_e32 v5, v5, v7
	v_and_b32_e32 v7, 0x7f800000, v5
	v_cmp_ne_u32_e32 vcc, s37, v7
	s_and_saveexec_b64 s[28:29], vcc
	s_xor_b64 s[28:29], exec, s[28:29]
	v_bfe_u32 v7, v5, 16, 1
	v_add3_u32 v7, v5, v7, s38
	s_andn2_saveexec_b64 s[28:29], s[28:29]
	s_cbranch_execz .LBB1_2
	v_or_b32_e32 v7, 0x10000, v5
	v_cmp_eq_u32_sdwa vcc, v5, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v5, vcc
	s_branch .LBB1_2
.LBB1_27:
	s_or_b64 exec, exec, s[14:15]
	s_mul_i32 s14, s25, s27
	v_cmp_gt_i32_e32 vcc, s14, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_54
	s_mul_i32 s4, s22, s17
	s_abs_i32 s15, s27
	v_cvt_f32_u32_e32 v1, s15
	s_mul_hi_u32 s5, s22, s16
	s_add_i32 s4, s5, s4
	s_mul_i32 s5, s23, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s6, s[0:1], 0x6c
	s_add_i32 s1, s4, s5
	s_mul_i32 s0, s22, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s16, s6, 0xffff
	s_ashr_i32 s17, s27, 31
	s_sub_i32 s4, 0, s15
	v_mul_lo_u32 v3, s4, v1
	v_mul_hi_u32 v3, v1, v3
	v_add_u32_e32 v1, v1, v3
	s_lshl_b32 s4, s27, 1
	s_sub_i32 s18, 0, s4
	s_lshl_b32 s19, s16, 1
	s_sub_i32 s20, 0, s27
	s_mov_b64 s[4:5], 0
	s_mov_b32 s21, 0x7f800000
	s_movk_i32 s22, 0x7fff
	v_mov_b32_e32 v3, 0
	s_branch .LBB1_30
.LBB1_29:
	s_or_b64 exec, exec, s[6:7]
	global_store_short_d16_hi v[6:7], v5, off offset:2
	v_add_u32_e32 v0, s16, v0
	v_cmp_le_i32_e32 vcc, s14, v0
	s_or_b64 s[4:5], vcc, s[4:5]
	v_add_u32_e32 v2, s19, v2
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB1_54
.LBB1_30:
	v_ashrrev_i32_e32 v4, 31, v0
	v_xor_b32_e32 v4, s17, v4
	v_sub_u32_e32 v5, 0, v0
	v_max_i32_e32 v5, v0, v5
	v_mul_hi_u32 v6, v5, v1
	v_mul_lo_u32 v7, v6, s15
	v_sub_u32_e32 v5, v5, v7
	v_add_u32_e32 v7, 1, v6
	v_cmp_le_u32_e32 vcc, s15, v5
	s_nop 1
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_subrev_u32_e32 v7, s15, v5
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_add_u32_e32 v7, 1, v6
	v_cmp_le_u32_e32 vcc, s15, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v6, v7, vcc
	v_xor_b32_e32 v5, v5, v4
	v_sub_u32_e32 v8, v5, v4
	v_mul_lo_u32 v4, v8, s26
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[6:7], s[0:1], 0, v[4:5]
	v_mad_u64_u32 v[4:5], s[6:7], s20, v8, v[0:1]
	v_lshl_add_u64 v[10:11], v[6:7], 1, s[8:9]
	v_mad_u64_u32 v[8:9], s[6:7], s18, v8, v[2:3]
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshlrev_b64 v[4:5], 1, v[4:5]
	v_lshl_add_u64 v[12:13], s[2:3], 0, v[4:5]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[10:11], v[8:9], 1, v[10:11]
	global_load_dword v14, v[10:11], off
	global_load_ushort v10, v[12:13], off
	v_lshl_add_u64 v[4:5], s[12:13], 0, v[4:5]
	global_load_ushort v15, v[4:5], off
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v11, 16, v14
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v10, 16, v10
	v_mov_b32_e32 v4, v11
	v_pk_mul_f32 v[12:13], v[4:5], v[10:11]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v12
	v_cmp_ne_u32_e32 vcc, s21, v5
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v5, v12, 16, 1
	v_add3_u32 v5, v12, v5, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v5, 0x10000, v12
	v_cmp_eq_u32_sdwa vcc, v12, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v12, vcc
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_e32 v13, 0xffff0000, v14
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v12, 16, v15
	v_mov_b32_e32 v14, v13
	v_pk_mul_f32 v[16:17], v[14:15], v[12:13]
	s_nop 0
	v_and_b32_e32 v15, 0x7f800000, v16
	v_cmp_ne_u32_e32 vcc, s21, v15
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v15, v16, 16, 1
	v_add3_u32 v15, v16, v15, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v15, 0x10000, v16
	v_cmp_eq_u32_sdwa vcc, v16, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v15, v15, v16, vcc
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_e32 v5, 0xffff0000, v5
	v_and_b32_e32 v15, 0xffff0000, v15
	v_sub_f32_e32 v5, v5, v15
	v_and_b32_e32 v15, 0x7f800000, v5
	v_cmp_ne_u32_e32 vcc, s21, v15
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v15, v5, 16, 1
	v_add3_u32 v15, v5, v15, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v15, 0x10000, v5
	v_cmp_eq_u32_sdwa vcc, v5, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v15, v15, v5, vcc
	s_or_b64 exec, exec, s[6:7]
	v_lshl_add_u64 v[6:7], v[6:7], 1, s[10:11]
	v_lshl_add_u64 v[6:7], v[8:9], 1, v[6:7]
	global_store_short_d16_hi v[6:7], v15, off
	v_pk_mul_f32 v[8:9], v[14:15], v[10:11]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v8
	v_cmp_ne_u32_e32 vcc, s21, v5
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v5, v8, 16, 1
	v_add3_u32 v10, v8, v5, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v5, 0x10000, v8
	v_cmp_eq_u32_sdwa vcc, v8, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v10, v5, v8, vcc
	s_or_b64 exec, exec, s[6:7]
	v_pk_mul_f32 v[4:5], v[4:5], v[12:13]
	s_nop 0
	v_and_b32_e32 v5, 0x7f800000, v4
	v_cmp_ne_u32_e32 vcc, s21, v5
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v5, v4, 16, 1
	v_add3_u32 v8, v4, v5, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_or_b32_e32 v5, 0x10000, v4
	v_cmp_eq_u32_sdwa vcc, v4, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v8, v5, v4, vcc
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_e32 v4, 0xffff0000, v10
	v_and_b32_e32 v5, 0xffff0000, v8
	v_add_f32_e32 v4, v4, v5
	v_and_b32_e32 v5, 0x7f800000, v4
	v_cmp_ne_u32_e32 vcc, s21, v5
	s_and_saveexec_b64 s[6:7], vcc
	s_xor_b64 s[6:7], exec, s[6:7]
	v_bfe_u32 v5, v4, 16, 1
	v_add3_u32 v5, v4, v5, s22
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB1_29
	v_or_b32_e32 v5, 0x10000, v4
	v_cmp_eq_u32_sdwa vcc, v4, v3 src0_sel:WORD_0 src1_sel:DWORD
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v4, vcc
	s_branch .LBB1_29
.LBB1_54:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 22
		.amdhsa_next_free_sgpr 39
		.amdhsa_accum_offset 24
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
	.section	.text._ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii,comdat
.Lfunc_end1:
	.size	_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii, .Lfunc_end1-_ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii

	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.num_vgpr, 22
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.num_agpr, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.numbered_sgpr, 39
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.private_seg_size, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.uses_vcc, 1
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.uses_flat_scratch, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_dyn_sized_stack, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_recursion, 0
	.set _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.has_indirect_call, 0
	.section	.text._ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,comdat
	.protected	_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
	.globl	_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
	.p2align	8
	.type	_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,@function
_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB2_0
	.p2align	8
.LBB2_0:
	s_load_dword s28, s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s29, s28, 31
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s2, s2, s18
	s_addc_u32 s3, s3, s19
	s_load_dwordx2 s[2:3], s[2:3], 0x0
	s_load_dwordx8 s[20:27], s[0:1], 0x40
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s18, s2, s29
	s_mul_hi_u32 s19, s2, s28
	s_add_i32 s18, s19, s18
	s_mul_i32 s3, s3, s28
	s_add_i32 s18, s18, s3
	s_mul_i32 s2, s2, s28
	s_lshr_b32 s3, s18, 31
	s_add_u32 s2, s2, s3
	s_addc_u32 s3, s18, 0
	s_lshl_b64 s[18:19], s[2:3], 1
	s_and_b32 s18, s18, -4
	s_add_u32 s2, s12, s18
	s_addc_u32 s3, s13, s19
	s_add_u32 s12, s14, s18
	s_addc_u32 s13, s15, s19
	s_lshr_b32 s14, s28, 31
	s_add_i32 s28, s28, s14
	s_ashr_i32 s14, s28, 1
	s_mul_i32 s24, s24, s14
	v_cmp_gt_i32_e32 vcc, s24, v0
	s_and_saveexec_b64 s[18:19], vcc
	s_cbranch_execz .LBB2_3
	s_mul_i32 s15, s20, s17
	s_abs_i32 s27, s14
	v_cvt_f32_u32_e32 v1, s27
	s_mul_hi_u32 s28, s20, s16
	s_add_i32 s15, s28, s15
	s_mul_i32 s21, s21, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s28, s[0:1], 0x6c
	s_add_i32 s21, s15, s21
	s_mul_i32 s20, s20, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s33, s28, 0xffff
	s_ashr_i32 s15, s14, 31
	s_sub_i32 s28, 0, s27
	v_mul_lo_u32 v2, s28, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	s_sub_i32 s34, 0, s14
	s_mov_b64 s[28:29], 0
	s_lshl_b64 s[30:31], s[14:15], 2
	v_mov_b32_e32 v2, v0
.LBB2_2:
	v_ashrrev_i32_e32 v3, 31, v2
	v_sub_u32_e32 v4, 0, v2
	v_xor_b32_e32 v3, s15, v3
	v_max_i32_e32 v4, v2, v4
	v_mul_hi_u32 v5, v4, v1
	v_mul_lo_u32 v6, v5, s27
	v_add_u32_e32 v7, 1, v5
	v_sub_u32_e32 v4, v4, v6
	v_cmp_le_u32_e32 vcc, s27, v4
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_subrev_u32_e32 v6, s27, v4
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_add_u32_e32 v6, 1, v5
	v_cmp_le_u32_e32 vcc, s27, v4
	s_nop 1
	v_cndmask_b32_e32 v4, v5, v6, vcc
	v_xor_b32_e32 v4, v4, v3
	v_sub_u32_e32 v3, v4, v3
	v_mul_lo_u32 v4, v3, s26
	v_mad_u64_u32 v[6:7], s[36:37], s34, v3, v[2:3]
	v_ashrrev_i32_e32 v5, 31, v4
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshl_add_u64 v[4:5], s[20:21], 0, v[4:5]
	v_lshlrev_b64 v[6:7], 2, v[6:7]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshl_add_u64 v[8:9], s[2:3], 0, v[6:7]
	v_lshl_add_u64 v[10:11], s[12:13], 0, v[6:7]
	v_lshl_add_u64 v[12:13], s[4:5], 0, v[4:5]
	global_load_dword v3, v[8:9], off
	global_load_dword v14, v[10:11], off
	v_lshl_add_u64 v[8:9], v[12:13], 0, v[6:7]
	v_lshl_add_u64 v[10:11], v[8:9], 0, s[30:31]
	global_load_dword v8, v[8:9], off
	global_load_dword v9, v[10:11], off
	v_add_u32_e32 v2, s33, v2
	v_cmp_le_i32_e32 vcc, s24, v2
	s_or_b64 s[28:29], vcc, s[28:29]
	v_lshl_add_u64 v[4:5], s[6:7], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[6:7]
	v_lshl_add_u64 v[6:7], v[4:5], 0, s[30:31]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v10, v14, v9
	v_mul_f32_e32 v9, v3, v9
	v_fma_f32 v3, v3, v8, -v10
	v_fmac_f32_e32 v9, v14, v8
	global_store_dword v[4:5], v3, off
	global_store_dword v[6:7], v9, off
	s_andn2_b64 exec, exec, s[28:29]
	s_cbranch_execnz .LBB2_2
.LBB2_3:
	s_or_b64 exec, exec, s[18:19]
	s_mul_i32 s18, s25, s14
	v_cmp_gt_i32_e32 vcc, s18, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB2_6
	s_mul_i32 s4, s22, s17
	s_abs_i32 s17, s14
	v_cvt_f32_u32_e32 v1, s17
	s_mul_hi_u32 s5, s22, s16
	s_add_i32 s4, s5, s4
	s_mul_i32 s5, s23, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s6, s[0:1], 0x6c
	s_add_i32 s1, s4, s5
	s_mul_i32 s0, s22, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s16, s6, 0xffff
	s_ashr_i32 s15, s14, 31
	s_sub_i32 s4, 0, s17
	v_mul_lo_u32 v2, s4, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	s_sub_i32 s19, 0, s14
	s_mov_b64 s[4:5], 0
	s_lshl_b64 s[6:7], s[14:15], 2
.LBB2_5:
	v_ashrrev_i32_e32 v2, 31, v0
	v_sub_u32_e32 v3, 0, v0
	v_xor_b32_e32 v2, s15, v2
	v_max_i32_e32 v3, v0, v3
	v_mul_hi_u32 v4, v3, v1
	v_mul_lo_u32 v5, v4, s17
	v_add_u32_e32 v6, 1, v4
	v_sub_u32_e32 v3, v3, v5
	v_cmp_le_u32_e32 vcc, s17, v3
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_subrev_u32_e32 v5, s17, v3
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_add_u32_e32 v5, 1, v4
	v_cmp_le_u32_e32 vcc, s17, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v4, v5, vcc
	v_xor_b32_e32 v3, v3, v2
	v_sub_u32_e32 v3, v3, v2
	v_mul_lo_u32 v2, v3, s26
	v_mad_u64_u32 v[4:5], s[20:21], s19, v3, v[0:1]
	v_ashrrev_i32_e32 v3, 31, v2
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[2:3], s[0:1], 0, v[2:3]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_lshl_add_u64 v[6:7], s[2:3], 0, v[4:5]
	v_lshl_add_u64 v[8:9], s[12:13], 0, v[4:5]
	v_lshl_add_u64 v[10:11], s[8:9], 0, v[2:3]
	global_load_dword v12, v[6:7], off
	global_load_dword v13, v[8:9], off
	v_lshl_add_u64 v[6:7], v[10:11], 0, v[4:5]
	v_lshl_add_u64 v[8:9], v[6:7], 0, s[6:7]
	global_load_dword v6, v[6:7], off
	global_load_dword v7, v[8:9], off
	v_add_u32_e32 v0, s16, v0
	v_cmp_le_i32_e32 vcc, s18, v0
	s_or_b64 s[4:5], vcc, s[4:5]
	v_lshl_add_u64 v[2:3], s[10:11], 0, v[2:3]
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[2:3], 0, s[6:7]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, v13, v7
	v_mul_f32_e32 v7, v12, v7
	v_fma_f32 v8, v12, v6, -v8
	v_fmac_f32_e32 v7, v13, v6
	global_store_dword v[2:3], v8, off
	global_store_dword v[4:5], v7, off
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB2_5
.LBB2_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 15
		.amdhsa_next_free_sgpr 38
		.amdhsa_accum_offset 16
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
	.section	.text._ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,comdat
.Lfunc_end2:
	.size	_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii, .Lfunc_end2-_ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii

	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.num_vgpr, 15
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.num_agpr, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.numbered_sgpr, 38
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.private_seg_size, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.uses_vcc, 1
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.uses_flat_scratch, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_dyn_sized_stack, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_recursion, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_indirect_call, 0
	.section	.text._ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,comdat
	.protected	_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
	.globl	_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
	.p2align	8
	.type	_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,@function
_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB3_0
	.p2align	8
.LBB3_0:
	s_load_dword s28, s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s29, s28, 31
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s2, s2, s18
	s_addc_u32 s3, s3, s19
	s_load_dwordx2 s[2:3], s[2:3], 0x0
	s_load_dwordx8 s[20:27], s[0:1], 0x40
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s18, s2, s29
	s_mul_hi_u32 s19, s2, s28
	s_add_i32 s18, s19, s18
	s_mul_i32 s3, s3, s28
	s_add_i32 s18, s18, s3
	s_mul_i32 s2, s2, s28
	s_lshr_b32 s3, s18, 31
	s_add_u32 s2, s2, s3
	s_addc_u32 s3, s18, 0
	s_lshl_b64 s[18:19], s[2:3], 1
	s_and_b32 s18, s18, -4
	s_add_u32 s2, s12, s18
	s_addc_u32 s3, s13, s19
	s_add_u32 s12, s14, s18
	s_addc_u32 s13, s15, s19
	s_lshr_b32 s14, s28, 31
	s_add_i32 s14, s28, s14
	s_ashr_i32 s27, s14, 1
	s_mul_i32 s24, s24, s27
	s_sub_i32 s14, s26, s28
	s_ashr_i32 s15, s14, 31
	v_cmp_gt_i32_e32 vcc, s24, v0
	v_lshlrev_b32_e32 v2, 1, v0
	s_and_saveexec_b64 s[18:19], vcc
	s_cbranch_execz .LBB3_3
	s_lshl_b64 s[28:29], s[14:15], 2
	s_add_u32 s4, s4, s28
	s_addc_u32 s5, s5, s29
	s_add_u32 s6, s6, s28
	s_addc_u32 s7, s7, s29
	s_mul_i32 s28, s20, s17
	s_abs_i32 s30, s27
	v_cvt_f32_u32_e32 v1, s30
	s_mul_hi_u32 s29, s20, s16
	s_add_i32 s28, s29, s28
	s_mul_i32 s21, s21, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s29, s[0:1], 0x6c
	s_add_i32 s21, s28, s21
	s_mul_i32 s20, s20, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s31, s29, 0xffff
	s_ashr_i32 s33, s27, 31
	s_sub_i32 s28, 0, s30
	v_mul_lo_u32 v3, s28, v1
	v_mul_hi_u32 v3, v1, v3
	v_add_u32_e32 v1, v1, v3
	s_lshl_b32 s28, s27, 1
	s_sub_i32 s34, 0, s28
	v_lshlrev_b32_e32 v4, 1, v0
	s_lshl_b32 s35, s31, 1
	s_sub_i32 s36, 0, s27
	s_mov_b64 s[28:29], 0
	v_mov_b32_e32 v6, v0
.LBB3_2:
	v_ashrrev_i32_e32 v3, 31, v6
	v_sub_u32_e32 v5, 0, v6
	v_xor_b32_e32 v3, s33, v3
	v_max_i32_e32 v5, v6, v5
	v_mul_hi_u32 v7, v5, v1
	v_mul_lo_u32 v8, v7, s30
	v_add_u32_e32 v9, 1, v7
	v_sub_u32_e32 v5, v5, v8
	v_cmp_le_u32_e32 vcc, s30, v5
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_subrev_u32_e32 v8, s30, v5
	v_cndmask_b32_e32 v5, v5, v8, vcc
	v_add_u32_e32 v8, 1, v7
	v_cmp_le_u32_e32 vcc, s30, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v7, v8, vcc
	v_xor_b32_e32 v5, v5, v3
	v_sub_u32_e32 v3, v5, v3
	v_mul_lo_u32 v8, v3, s26
	v_mad_u64_u32 v[10:11], s[38:39], s36, v3, v[6:7]
	v_mad_u64_u32 v[12:13], s[38:39], s34, v3, v[4:5]
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v11, 31, v10
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshl_add_u64 v[8:9], s[20:21], 0, v[8:9]
	v_lshlrev_b64 v[10:11], 2, v[10:11]
	v_lshlrev_b64 v[12:13], 2, v[12:13]
	v_lshlrev_b64 v[8:9], 2, v[8:9]
	v_lshl_add_u64 v[14:15], s[2:3], 0, v[10:11]
	v_lshl_add_u64 v[10:11], s[12:13], 0, v[10:11]
	v_lshl_add_u64 v[16:17], s[4:5], 0, v[8:9]
	global_load_dword v10, v[10:11], off
	v_lshl_add_u64 v[16:17], v[16:17], 0, v[12:13]
	global_load_dwordx2 v[16:17], v[16:17], off
	global_load_dword v14, v[14:15], off
	v_add_u32_e32 v6, s31, v6
	v_add_u32_e32 v4, s35, v4
	v_cmp_le_i32_e32 vcc, s24, v6
	s_or_b64 s[28:29], vcc, s[28:29]
	v_lshl_add_u64 v[8:9], s[6:7], 0, v[8:9]
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	s_waitcnt vmcnt(1)
	v_pk_mul_f32 v[10:11], v[10:11], v[16:17] op_sel:[0,1] op_sel_hi:[0,0]
	s_waitcnt vmcnt(0)
	v_pk_fma_f32 v[12:13], v[14:15], v[16:17], v[10:11] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[10:11], v[14:15], v[16:17], v[10:11] op_sel_hi:[0,1,1]
	v_mov_b32_e32 v13, v11
	global_store_dwordx2 v[8:9], v[12:13], off
	s_andn2_b64 exec, exec, s[28:29]
	s_cbranch_execnz .LBB3_2
.LBB3_3:
	s_or_b64 exec, exec, s[18:19]
	s_mul_i32 s18, s25, s27
	v_cmp_gt_i32_e32 vcc, s18, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB3_6
	s_lshl_b64 s[6:7], s[14:15], 2
	s_add_u32 s4, s8, s6
	s_addc_u32 s5, s9, s7
	s_add_u32 s6, s10, s6
	s_addc_u32 s7, s11, s7
	s_mul_i32 s8, s22, s17
	s_abs_i32 s10, s27
	v_cvt_f32_u32_e32 v1, s10
	s_mul_hi_u32 s9, s22, s16
	s_add_i32 s8, s9, s8
	s_mul_i32 s9, s23, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dword s11, s[0:1], 0x6c
	s_add_i32 s1, s8, s9
	s_mul_i32 s0, s22, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s11, s11, 0xffff
	s_ashr_i32 s14, s27, 31
	s_sub_i32 s8, 0, s10
	v_mul_lo_u32 v3, s8, v1
	v_mul_hi_u32 v3, v1, v3
	v_add_u32_e32 v1, v1, v3
	s_lshl_b32 s8, s27, 1
	s_sub_i32 s15, 0, s8
	s_lshl_b32 s16, s11, 1
	s_sub_i32 s17, 0, s27
	s_mov_b64 s[8:9], 0
.LBB3_5:
	v_ashrrev_i32_e32 v3, 31, v0
	v_sub_u32_e32 v4, 0, v0
	v_xor_b32_e32 v3, s14, v3
	v_max_i32_e32 v4, v0, v4
	v_mul_hi_u32 v5, v4, v1
	v_mul_lo_u32 v6, v5, s10
	v_add_u32_e32 v7, 1, v5
	v_sub_u32_e32 v4, v4, v6
	v_cmp_le_u32_e32 vcc, s10, v4
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_subrev_u32_e32 v6, s10, v4
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_add_u32_e32 v6, 1, v5
	v_cmp_le_u32_e32 vcc, s10, v4
	s_nop 1
	v_cndmask_b32_e32 v4, v5, v6, vcc
	v_xor_b32_e32 v4, v4, v3
	v_sub_u32_e32 v3, v4, v3
	v_mul_lo_u32 v4, v3, s26
	v_mad_u64_u32 v[6:7], s[20:21], s17, v3, v[0:1]
	v_mad_u64_u32 v[8:9], s[20:21], s15, v3, v[2:3]
	v_ashrrev_i32_e32 v5, 31, v4
	v_ashrrev_i32_e32 v7, 31, v6
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[4:5]
	v_lshlrev_b64 v[6:7], 2, v[6:7]
	v_lshlrev_b64 v[8:9], 2, v[8:9]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshl_add_u64 v[10:11], s[2:3], 0, v[6:7]
	v_lshl_add_u64 v[6:7], s[12:13], 0, v[6:7]
	v_lshl_add_u64 v[12:13], s[4:5], 0, v[4:5]
	global_load_dword v6, v[6:7], off
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[8:9]
	global_load_dwordx2 v[12:13], v[12:13], off
	global_load_dword v10, v[10:11], off
	v_add_u32_e32 v0, s11, v0
	v_add_u32_e32 v2, s16, v2
	v_cmp_le_i32_e32 vcc, s18, v0
	s_or_b64 s[8:9], vcc, s[8:9]
	v_lshl_add_u64 v[4:5], s[6:7], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[8:9]
	s_waitcnt vmcnt(1)
	v_pk_mul_f32 v[6:7], v[6:7], v[12:13] op_sel:[0,1] op_sel_hi:[0,0]
	s_waitcnt vmcnt(0)
	v_pk_fma_f32 v[8:9], v[10:11], v[12:13], v[6:7] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[6:7], v[10:11], v[12:13], v[6:7] op_sel_hi:[0,1,1]
	v_mov_b32_e32 v9, v7
	global_store_dwordx2 v[4:5], v[8:9], off
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz .LBB3_5
.LBB3_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 20
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
	.section	.text._ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,"axG",@progbits,_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii,comdat
.Lfunc_end3:
	.size	_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii, .Lfunc_end3-_ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii

	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.num_vgpr, 18
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.num_agpr, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.numbered_sgpr, 40
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.private_seg_size, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.uses_vcc, 1
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.uses_flat_scratch, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_dyn_sized_stack, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_recursion, 0
	.set _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_ae18e642629b043b,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_ae18e642629b043b
__hip_cuid_ae18e642629b043b:
	.byte	0
	.size	__hip_cuid_ae18e642629b043b, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_ae18e642629b043b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
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
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
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
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .max_flat_workgroup_size: 1024
    .name:           _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
    .private_segment_fixed_size: 0
    .sgpr_count:     43
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb1ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     18
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
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
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
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
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .max_flat_workgroup_size: 1024
    .name:           _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii
    .private_segment_fixed_size: 0
    .sgpr_count:     45
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe23rotary_embedding_kernelI12hip_bfloat16Lb0ELb0EEEvPKxPKT_PS4_S6_S7_S6_S6_ixxiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     22
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
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
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
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
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .max_flat_workgroup_size: 1024
    .name:           _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
    .private_segment_fixed_size: 0
    .sgpr_count:     44
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe23rotary_embedding_kernelIfLb1ELb0EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     15
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
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
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
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
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .max_flat_workgroup_size: 1024
    .name:           _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii
    .private_segment_fixed_size: 0
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe23rotary_embedding_kernelIfLb0ELb1EEEvPKxPKT_PS3_S5_S6_S5_S5_ixxiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     18
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
