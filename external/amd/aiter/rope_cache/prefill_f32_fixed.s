	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb,"axG",@progbits,_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb,comdat
	.protected	_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb
	.globl	_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb
	.p2align	8
	.type	_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb,@function
_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mov_b32 s17, 0
	s_lshl_b64 s[48:49], s[16:17], 3
	s_add_u32 s14, s14, s48
	s_addc_u32 s15, s15, s49
	s_load_dwordx2 s[34:35], s[14:15], 0x0
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_i64_e64 s[14:15], s[34:35], 0
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_26
	s_load_dwordx2 s[18:19], s[0:1], 0x90
	s_load_dwordx2 s[50:51], s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s53, s19, 31
	s_mov_b32 s52, s19
	s_or_b64 s[14:15], s[34:35], s[52:53]
	s_mov_b32 s14, s17
	s_cmp_lg_u64 s[14:15], 0
	s_cbranch_scc0 .LBB0_27
	s_ashr_i32 s20, s53, 31
	s_mov_b32 s21, s20
	s_add_u32 s14, s52, s20
	s_addc_u32 s15, s53, s20
	s_xor_b64 s[24:25], s[14:15], s[20:21]
	v_cvt_f32_u32_e32 v1, s24
	v_cvt_f32_u32_e32 v2, s25
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s14, 0, s24
	s_subb_u32 s15, 0, s25
	v_readfirstlane_b32 s17, v2
	v_readfirstlane_b32 s19, v1
	s_mul_i32 s26, s14, s17
	s_mul_i32 s27, s15, s19
	s_mul_hi_u32 s28, s14, s19
	s_add_i32 s26, s28, s26
	s_add_i32 s26, s26, s27
	s_mul_hi_u32 s27, s19, s26
	s_mul_i32 s28, s19, s26
	s_mul_i32 s29, s14, s19
	s_mul_hi_u32 s19, s19, s29
	s_add_u32 s19, s19, s28
	s_addc_u32 s27, 0, s27
	s_mul_hi_u32 s28, s17, s26
	s_mul_hi_u32 s30, s17, s29
	s_mul_i32 s29, s17, s29
	s_add_u32 s19, s19, s29
	s_addc_u32 s19, s27, s30
	s_addc_u32 s27, s28, 0
	s_mul_i32 s26, s17, s26
	s_add_u32 s19, s19, s26
	s_addc_u32 s26, 0, s27
	v_add_co_u32_e32 v1, vcc, s19, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s26
	s_mul_i32 s19, s14, s17
	v_readfirstlane_b32 s26, v1
	s_mul_hi_u32 s27, s14, s26
	s_add_i32 s19, s27, s19
	s_mul_i32 s15, s15, s26
	s_add_i32 s19, s19, s15
	s_mul_hi_u32 s15, s17, s19
	s_mul_i32 s14, s14, s26
	s_mul_hi_u32 s27, s17, s14
	s_mul_i32 s28, s17, s14
	s_mul_hi_u32 s29, s26, s19
	s_mul_i32 s30, s26, s19
	s_mul_hi_u32 s14, s26, s14
	s_add_u32 s14, s14, s30
	s_addc_u32 s26, 0, s29
	s_add_u32 s14, s14, s28
	s_addc_u32 s14, s26, s27
	s_addc_u32 s15, s15, 0
	s_mul_i32 s19, s17, s19
	s_add_u32 s14, s14, s19
	s_addc_u32 s15, 0, s15
	v_add_co_u32_e32 v1, vcc, s14, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s15
	s_ashr_i32 s26, s35, 31
	s_mov_b32 s27, s26
	s_add_u32 s14, s34, s26
	s_addc_u32 s15, s35, s26
	s_xor_b64 s[28:29], s[14:15], s[26:27]
	s_mul_hi_u32 s14, s28, s17
	s_mul_i32 s15, s28, s17
	v_readfirstlane_b32 s19, v1
	s_mul_hi_u32 s30, s28, s19
	s_add_u32 s15, s30, s15
	s_addc_u32 s14, 0, s14
	s_mul_hi_u32 s30, s29, s17
	s_mul_hi_u32 s31, s29, s19
	s_mul_i32 s19, s29, s19
	s_add_u32 s15, s15, s19
	s_addc_u32 s14, s14, s31
	s_addc_u32 s15, s30, 0
	s_mul_i32 s17, s29, s17
	s_add_u32 s17, s14, s17
	s_addc_u32 s19, 0, s15
	s_mul_i32 s14, s24, s19
	s_mul_hi_u32 s15, s24, s17
	s_add_i32 s14, s15, s14
	s_mul_i32 s15, s25, s17
	s_add_i32 s30, s14, s15
	s_sub_i32 s14, s29, s30
	s_mul_i32 s15, s24, s17
	v_mov_b32_e32 v1, s15
	v_sub_co_u32_e32 v1, vcc, s28, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s28, s14, s25
	v_subrev_co_u32_e64 v2, s[14:15], s24, v1
	s_cmp_lg_u64 s[14:15], 0
	s_subb_u32 s14, s28, 0
	s_cmp_ge_u32 s14, s25
	s_cselect_b32 s15, -1, 0
	v_readfirstlane_b32 s28, v2
	s_cmp_ge_u32 s28, s24
	s_cselect_b32 s28, -1, 0
	s_cmp_eq_u32 s14, s25
	s_cselect_b32 s14, s28, s15
	s_add_u32 s15, s17, 1
	s_addc_u32 s28, s19, 0
	s_add_u32 s31, s17, 2
	s_addc_u32 s33, s19, 0
	s_cmp_lg_u32 s14, 0
	s_cselect_b32 s14, s31, s15
	s_cselect_b32 s15, s33, s28
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s28, s29, s30
	s_cmp_ge_u32 s28, s25
	s_cselect_b32 s29, -1, 0
	v_readfirstlane_b32 s30, v1
	s_cmp_ge_u32 s30, s24
	s_cselect_b32 s24, -1, 0
	s_cmp_eq_u32 s28, s25
	s_cselect_b32 s24, s24, s29
	s_cmp_lg_u32 s24, 0
	s_cselect_b32 s15, s15, s19
	s_cselect_b32 s14, s14, s17
	s_xor_b64 s[20:21], s[26:27], s[20:21]
	s_xor_b64 s[14:15], s[14:15], s[20:21]
	s_sub_u32 s54, s14, s20
	s_subb_u32 s55, s15, s21
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB0_4
.LBB0_3:
	v_cvt_f32_u32_e32 v1, s52
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mov_b32 s55, 0
	s_sub_i32 s14, 0, s52
	v_readfirstlane_b32 s15, v1
	s_mul_i32 s14, s14, s15
	s_mul_hi_u32 s14, s15, s14
	s_add_i32 s15, s15, s14
	s_mul_hi_u32 s14, s34, s15
	s_add_i32 s15, s14, 1
	s_mul_i32 s17, s14, s52
	s_sub_i32 s17, s34, s17
	s_sub_i32 s19, s17, s52
	s_cmp_ge_u32 s17, s52
	s_cselect_b32 s17, s19, s17
	s_cselect_b32 s14, s15, s14
	s_add_i32 s15, s14, 1
	s_cmp_ge_u32 s17, s52
	s_cselect_b32 s54, s15, s14
.LBB0_4:
	s_load_dwordx8 s[20:27], s[0:1], 0x70
	s_load_dwordx8 s[36:43], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s15, s22, 31
	s_mov_b32 s14, s22
	s_ashr_i32 s17, s23, 31
	s_mul_hi_u32 s19, s23, s16
	s_lshl_b64 s[56:57], s[14:15], 9
	s_mul_i32 s17, s17, s16
	s_add_i32 s29, s19, s17
	s_mul_i32 s28, s23, s16
	s_lshl_b64 s[28:29], s[28:29], 2
	s_add_u32 s28, s6, s28
	s_addc_u32 s6, s7, s29
	s_lshl_b32 s30, s22, 11
	s_and_b32 s29, s6, 0xffff
	s_mov_b32 s31, 0x20000
	s_add_i32 s14, s21, 0x3fffffff
	s_ashr_i32 s6, s39, 31
	s_mul_hi_u32 s7, s39, s16
	s_mul_i32 s6, s6, s16
	s_add_i32 s7, s7, s6
	s_mul_i32 s6, s39, s16
	s_lshl_b64 s[6:7], s[6:7], 2
	s_add_u32 s44, s2, s6
	s_addc_u32 s2, s3, s7
	s_lshl_b32 s17, s40, 2
	s_mul_i32 s3, s17, s14
	s_add_i32 s46, s3, 0x800
	s_and_b32 s45, s2, 0xffff
	s_lshr_b32 s2, s15, 30
	s_mov_b32 s3, 0
	s_or_b64 s[2:3], s[2:3], s[56:57]
	s_add_u32 s2, s2, 3
	s_addc_u32 s3, s3, 0
	v_mov_b32_e32 v1, s2
	v_alignbit_b32 v1, s3, v1, 2
	s_add_u32 s2, s50, s48
	s_addc_u32 s3, s51, s49
	v_lshrrev_b32_e32 v14, 7, v0
	v_and_b32_e32 v2, 0x7f, v0
	v_cmp_lt_u32_e32 vcc, v0, v1
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	v_lshlrev_b32_e32 v15, 2, v2
	v_mov_b64_e32 v[2:3], v[6:7]
	v_mov_b64_e32 v[4:5], v[8:9]
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_6
	v_mul_lo_u32 v2, s24, v14
	v_mul_lo_u32 v6, s40, v14
	v_add_lshl_u32 v2, v2, v15, 2
	buffer_load_dwordx4 v[2:5], v2, s[28:31], 0 offen
	v_add_lshl_u32 v6, v6, v15, 2
	s_mov_b32 s47, s31
	buffer_load_dwordx4 v[6:9], v6, s[44:47], 0 offen
.LBB0_6:
	s_or_b64 exec, exec, s[6:7]
	s_load_dwordx4 s[48:51], s[0:1], 0x40
	s_load_dwordx2 s[14:15], s[2:3], 0x0
	s_mul_i32 s0, s54, s53
	s_mul_hi_u32 s1, s54, s52
	s_add_i32 s0, s1, s0
	s_mul_i32 s1, s55, s52
	s_add_i32 s0, s0, s1
	s_mul_i32 s1, s54, s52
	s_sub_u32 s1, s34, s1
	s_subb_u32 s0, s35, s0
	s_ashr_i32 s2, s36, 31
	s_mul_hi_u32 s3, s54, s36
	s_mul_i32 s2, s54, s2
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s55, s36
	s_add_i32 s2, s2, s3
	s_mul_i32 s3, s54, s36
	s_ashr_i32 s6, s37, 31
	s_mul_i32 s6, s1, s6
	s_mul_hi_u32 s7, s1, s37
	s_add_i32 s6, s7, s6
	s_mul_i32 s0, s0, s37
	s_add_i32 s6, s6, s0
	s_mul_i32 s1, s1, s37
	s_add_u32 s0, s1, s3
	s_addc_u32 s1, s6, s2
	s_waitcnt lgkmcnt(0)
	s_add_i32 s15, s18, 0x200
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s6, s10, s0
	s_addc_u32 s7, s11, s1
	s_mul_i32 s0, s22, s15
	s_lshl_b32 s58, s0, 2
	s_and_b32 s57, s7, 0xffff
	s_ashr_i32 s0, s43, 31
	s_mul_hi_u32 s1, s43, s16
	s_mul_i32 s0, s0, s16
	s_add_i32 s3, s1, s0
	s_mul_i32 s2, s43, s16
	s_lshl_b64 s[0:1], s[2:3], 2
	s_add_u32 s52, s12, s0
	s_addc_u32 s0, s13, s1
	s_mul_i32 s1, s21, s15
	s_lshl_b32 s54, s1, 2
	s_and_b32 s53, s0, 0xffff
	v_add_u32_e32 v16, 0x100, v0
	v_cmp_lt_u32_e64 s[0:1], v16, v1
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_10
	s_mov_b64 s[34:35], 0
	s_mov_b32 s47, s31
	s_mov_b32 s56, s6
	s_mov_b32 s59, s31
	s_mov_b32 s55, s31
.LBB0_8:
	s_waitcnt vmcnt(1)
	v_mov_b64_e32 v[20:21], v[4:5]
	v_mov_b64_e32 v[18:19], v[2:3]
	v_mul_lo_u32 v17, v14, s38
	v_mul_lo_u32 v22, v14, s20
	v_lshrrev_b32_e32 v14, 7, v16
	v_mul_lo_u32 v2, v14, s24
	v_mul_lo_u32 v3, v14, s40
	v_add_lshl_u32 v2, v2, v15, 2
	v_add_lshl_u32 v3, v3, v15, 2
	buffer_load_dwordx4 v[10:13], v3, s[44:47], 0 offen
	buffer_load_dwordx4 v[2:5], v2, s[28:31], 0 offen
	v_add_u32_e32 v16, 0x100, v16
	v_add_lshl_u32 v17, v17, v15, 2
	v_add_lshl_u32 v22, v22, v15, 2
	v_cmp_ge_u32_e64 s[0:1], v16, v1
	buffer_store_dwordx4 v[18:21], v17, s[56:59], 0 offen
	s_waitcnt vmcnt(3)
	buffer_store_dwordx4 v[6:9], v22, s[52:55], 0 offen
	s_or_b64 s[34:35], s[0:1], s[34:35]
	s_waitcnt vmcnt(3)
	v_mov_b64_e32 v[6:7], v[10:11]
	v_mov_b64_e32 v[8:9], v[12:13]
	s_andn2_b64 exec, exec, s[34:35]
	s_cbranch_execnz .LBB0_8
	s_or_b64 exec, exec, s[34:35]
	v_mov_b64_e32 v[6:7], v[10:11]
	v_mov_b64_e32 v[8:9], v[12:13]
.LBB0_10:
	s_or_b64 exec, exec, s[10:11]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_12
	v_mul_lo_u32 v10, v14, s38
	v_add_lshl_u32 v10, v10, v15, 2
	s_mov_b32 s56, s6
	s_mov_b32 s59, s31
	s_waitcnt vmcnt(1)
	buffer_store_dwordx4 v[2:5], v10, s[56:59], 0 offen
	v_mul_lo_u32 v10, v14, s20
	v_add_lshl_u32 v10, v10, v15, 2
	s_mov_b32 s55, s31
	s_waitcnt vmcnt(1)
	buffer_store_dwordx4 v[6:9], v10, s[52:55], 0 offen
.LBB0_12:
	s_or_b64 exec, exec, s[0:1]
	s_lshl_b32 s0, s21, 9
	s_bfe_i32 s1, s21, 0x10016
	s_lshr_b32 s1, s1, 30
	s_or_b32 s0, s1, s0
	s_add_i32 s0, s0, 3
	s_ashr_i32 s3, s0, 2
	v_add_u32_e32 v11, v0, v1
	v_lshrrev_b32_e32 v1, 7, v11
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v6, 0x7f, v11
	v_cmp_gt_u32_e32 vcc, s3, v11
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_14
	v_mul_lo_u32 v2, s17, v1
	v_lshl_add_u32 v2, v6, 4, v2
	s_mov_b32 s47, s31
	buffer_load_dwordx4 v[2:5], v2, s[44:47], 0 offen
.LBB0_14:
	s_or_b64 exec, exec, s[0:1]
	v_add_u32_e32 v7, 0x100, v11
	v_cmp_gt_u32_e32 vcc, s3, v7
	v_lshlrev_b32_e32 v10, 4, v6
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_18
	s_lshl_b32 s15, s20, 2
	s_mov_b64 s[10:11], 0
	s_mov_b32 s47, s31
	s_mov_b32 s55, s31
.LBB0_16:
	v_mov_b32_e32 v12, v1
	v_mov_b32_e32 v14, v11
	v_add_u32_e32 v11, 0x100, v14
	v_lshrrev_b32_e32 v1, 7, v11
	v_mad_u64_u32 v[6:7], s[28:29], s17, v1, v[10:11]
	buffer_load_dwordx4 v[6:9], v6, s[44:47], 0 offen
	v_mad_u64_u32 v[12:13], s[28:29], s15, v12, v[10:11]
	v_add_u32_e32 v13, 0x200, v14
	s_waitcnt vmcnt(1)
	buffer_store_dwordx4 v[2:5], v12, s[52:55], 0 offen
	v_cmp_le_u32_e32 vcc, s3, v13
	s_or_b64 s[10:11], vcc, s[10:11]
	s_waitcnt vmcnt(1)
	v_mov_b64_e32 v[2:3], v[6:7]
	v_mov_b64_e32 v[4:5], v[8:9]
	s_andn2_b64 exec, exec, s[10:11]
	s_cbranch_execnz .LBB0_16
	s_or_b64 exec, exec, s[10:11]
	v_mov_b64_e32 v[2:3], v[6:7]
	v_mov_b64_e32 v[4:5], v[8:9]
.LBB0_18:
	s_or_b64 exec, exec, s[0:1]
	v_cmp_gt_u32_e32 vcc, s3, v11
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_20
	v_mul_lo_u32 v1, s20, v1
	v_lshl_add_u32 v1, v1, 2, v10
	s_mov_b32 s55, s31
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[2:5], v1, s[52:55], 0 offen
.LBB0_20:
	s_or_b64 exec, exec, s[0:1]
	s_ashr_i32 s0, s18, 1
	s_mul_i32 s0, s0, s14
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[10:11], s[0:1], 2
	s_add_u32 s0, s48, s10
	s_addc_u32 s1, s49, s11
	s_add_u32 s10, s50, s10
	s_addc_u32 s11, s51, s11
	s_lshl_b32 s3, s22, 5
	s_mul_i32 s14, s41, s16
	v_cmp_gt_u32_e32 vcc, s3, v0
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v2, 31, v0
	s_and_saveexec_b64 s[18:19], vcc
	s_cbranch_execz .LBB0_23
	v_lshlrev_b32_e32 v4, 2, v2
	global_load_dword v1, v4, s[0:1]
	global_load_dword v3, v4, s[10:11]
	s_mul_i32 s16, s25, s16
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[16:17], s[16:17], 2
	s_add_u32 s16, s8, s16
	s_addc_u32 s17, s9, s17
	s_ashr_i32 s15, s14, 31
	s_lshl_b64 s[8:9], s[14:15], 2
	s_add_u32 s22, s4, s8
	s_addc_u32 s23, s5, s9
	s_mov_b32 s8, 0
	s_mov_b32 s9, s2
	s_ashr_i64 s[8:9], s[8:9], 30
	s_add_u32 s8, s12, s8
	s_addc_u32 s9, s13, s9
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[6:7], s[16:17], 0, v[4:5]
	v_lshl_add_u64 v[8:9], s[22:23], 0, v[4:5]
	v_lshrrev_b32_e32 v4, 5, v0
	v_mul_lo_u32 v10, s20, v4
	s_lshl_b32 s15, s20, 3
	v_mul_lo_u32 v12, s42, v4
	s_lshl_b32 s22, s42, 3
	v_mul_lo_u32 v14, s38, v4
	s_lshl_b32 s23, s38, 3
	v_mul_lo_u32 v4, s26, v4
	s_lshl_b32 s24, s26, 3
	s_mov_b64 s[16:17], 0
	v_lshlrev_b32_e32 v16, 2, v2
	v_mov_b32_e32 v17, v5
	v_mov_b32_e32 v18, v0
.LBB0_22:
	v_lshl_add_u64 v[20:21], v[4:5], 2, v[6:7]
	v_mov_b32_e32 v13, v5
	global_load_dword v19, v[20:21], off offset:128
	global_load_dword v24, v[20:21], off
	v_lshl_add_u64 v[20:21], v[12:13], 2, v[8:9]
	global_load_dword v13, v[20:21], off offset:128
	global_load_dword v25, v[20:21], off
	v_mov_b32_e32 v15, v5
	v_mov_b32_e32 v11, v5
	v_add_u32_e32 v18, 0x100, v18
	v_add_u32_e32 v4, s24, v4
	v_lshl_add_u64 v[20:21], v[14:15], 2, s[6:7]
	v_lshl_add_u64 v[22:23], v[10:11], 2, s[8:9]
	v_add_u32_e32 v10, s15, v10
	v_add_u32_e32 v12, s22, v12
	v_add_u32_e32 v14, s23, v14
	v_cmp_le_u32_e32 vcc, s3, v18
	v_lshl_add_u64 v[20:21], v[20:21], 0, v[16:17]
	v_lshl_add_u64 v[22:23], v[22:23], 0, v[16:17]
	s_or_b64 s[16:17], vcc, s[16:17]
	s_waitcnt vmcnt(3)
	v_mul_f32_e32 v11, v3, v19
	v_mul_f32_e32 v15, v1, v19
	s_waitcnt vmcnt(2)
	v_fma_f32 v11, v1, v24, -v11
	v_fmac_f32_e32 v15, v3, v24
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v19, v3, v13
	v_mul_f32_e32 v13, v1, v13
	global_store_dword v[20:21], v11, off offset:2048
	global_store_dword v[20:21], v15, off offset:2176
	s_waitcnt vmcnt(2)
	v_fma_f32 v11, v1, v25, -v19
	v_fmac_f32_e32 v13, v3, v25
	global_store_dword v[22:23], v11, off offset:2048
	global_store_dword v[22:23], v13, off offset:2176
	s_andn2_b64 exec, exec, s[16:17]
	s_cbranch_execnz .LBB0_22
.LBB0_23:
	s_or_b64 exec, exec, s[18:19]
	s_lshl_b32 s6, s21, 5
	v_add_u32_e32 v6, s3, v0
	v_cmp_gt_u32_e32 vcc, s6, v6
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_26
	v_lshlrev_b32_e32 v0, 2, v2
	global_load_dword v7, v0, s[0:1]
	global_load_dword v8, v0, s[10:11]
	s_ashr_i32 s15, s14, 31
	s_lshl_b64 s[0:1], s[14:15], 2
	s_add_u32 s4, s4, s0
	s_addc_u32 s5, s5, s1
	s_mov_b32 s0, 0
	s_mov_b32 s1, s2
	s_ashr_i64 s[0:1], s[0:1], 30
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s13, s1
	v_mov_b32_e32 v1, 0
	v_lshl_add_u64 v[4:5], s[4:5], 0, v[0:1]
	s_mov_b64 s[2:3], 0
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, v1
.LBB0_25:
	v_lshrrev_b32_e32 v9, 5, v6
	v_mul_lo_u32 v0, v9, s42
	v_lshl_add_u64 v[10:11], v[0:1], 2, v[4:5]
	global_load_dword v0, v[10:11], off offset:128
	global_load_dword v12, v[10:11], off
	v_mov_b32_e32 v11, v1
	v_add_u32_e32 v6, 0x100, v6
	v_mul_lo_u32 v10, v9, s20
	v_cmp_le_u32_e32 vcc, s6, v6
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[0:1]
	s_or_b64 s[2:3], vcc, s[2:3]
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[2:3]
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v9, v8, v0
	v_mul_f32_e32 v0, v7, v0
	s_waitcnt vmcnt(0)
	v_fma_f32 v9, v7, v12, -v9
	v_fmac_f32_e32 v0, v8, v12
	global_store_dword v[10:11], v9, off offset:2048
	global_store_dword v[10:11], v0, off offset:2176
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_25
.LBB0_26:
	s_endpgm
.LBB0_27:
	s_mov_b64 vcc, 0
	s_branch .LBB0_3
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 172
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
		.amdhsa_next_free_sgpr 60
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
	.section	.text._ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb,"axG",@progbits,_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb,comdat
.Lfunc_end0:
	.size	_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb, .Lfunc_end0-_ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb

	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.num_vgpr, 26
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.num_agpr, 0
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.numbered_sgpr, 60
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.private_seg_size, 0
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.uses_vcc, 1
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.uses_flat_scratch, 0
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.has_dyn_sized_stack, 0
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.has_recursion, 0
	.set _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_aaba1a8be097d6e6,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_aaba1a8be097d6e6
__hip_cuid_aaba1a8be097d6e6:
	.byte	0
	.size	__hip_cuid_aaba1a8be097d6e6, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_aaba1a8be097d6e6
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
      - .actual_access:  write_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
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
      - .address_space:  global
        .offset:         152
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         160
        .size:           8
        .value_kind:     global_buffer
      - .offset:         168
        .size:           1
        .value_kind:     by_value
      - .offset:         169
        .size:           1
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 172
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb
    .private_segment_fixed_size: 0
    .sgpr_count:     66
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter48fuse_qk_rope_concat_and_cache_mla_kernel_prefillIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiiiiiPKfSD_bb.kd
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
