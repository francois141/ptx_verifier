	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_,"axG",@progbits,_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_,comdat
	.protected	_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_
	.globl	_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_
	.p2align	8
	.type	_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_,@function
_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_load_dwordx4 s[48:51], s[0:1], 0x60
	s_load_dwordx4 s[28:31], s[0:1], 0xb8
	s_load_dword s19, s[0:1], 0xe4
	s_waitcnt lgkmcnt(0)
	s_add_i32 s18, s49, s48
	s_add_i32 s17, s18, s50
	s_abs_i32 s20, s17
	v_cvt_f32_u32_e32 v1, s20
	s_bfe_u32 s19, s19, 0xb0005
	v_lshrrev_b32_e32 v2, 5, v0
	s_mul_i32 s16, s16, s19
	v_rcp_iflag_f32_e32 v3, v1
	v_add_u32_e32 v1, s16, v2
	v_xor_b32_e32 v2, s17, v1
	v_ashrrev_i32_e32 v2, 31, v2
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_sub_u32_e32 v4, 0, v1
	v_max_i32_e32 v4, v1, v4
	s_sub_i32 s16, 0, s20
	v_mul_lo_u32 v5, s16, v3
	v_mul_hi_u32 v5, v3, v5
	v_add_u32_e32 v3, v3, v5
	v_mul_hi_u32 v3, v4, v3
	v_mul_lo_u32 v5, v3, s20
	v_sub_u32_e32 v4, v4, v5
	v_add_u32_e32 v5, 1, v3
	v_cmp_le_u32_e32 vcc, s20, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_subrev_u32_e32 v5, s20, v4
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_add_u32_e32 v5, 1, v3
	v_cmp_le_u32_e32 vcc, s20, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_xor_b32_e32 v3, v3, v2
	v_sub_u32_e32 v12, v3, v2
	v_cmp_gt_i32_e32 vcc, s28, v12
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB0_29
	s_load_dwordx8 s[36:43], s[0:1], 0x38
	s_load_dwordx2 s[22:23], s[0:1], 0x58
	v_and_b32_e32 v6, 31, v0
	v_mul_lo_u32 v0, v12, s17
	v_sub_u32_e32 v0, v1, v0
	v_mov_b32_e32 v1, s48
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v2, s41
	v_mov_b32_e32 v3, s15
	v_cmp_gt_i32_e64 s[20:21], s18, v0
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[20:21]
	v_mov_b32_e32 v3, s40
	v_mov_b32_e32 v4, s14
	v_cndmask_b32_e64 v3, v3, v4, s[20:21]
	v_mov_b32_e32 v4, s8
	v_cmp_le_i32_e32 vcc, s48, v0
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v3, vcc
	s_and_b64 s[16:17], s[20:21], vcc
	v_cndmask_b32_e64 v1, 0, v1, s[16:17]
	v_mov_b32_e32 v3, s18
	s_xor_b64 s[18:19], vcc, s[16:17]
	v_cndmask_b32_e64 v1, v1, v3, s[18:19]
	v_sub_u32_e32 v10, v0, v1
	v_mov_b32_e32 v0, s9
	v_cndmask_b32_e32 v5, v0, v2, vcc
	v_mov_b32_e32 v0, s42
	v_mov_b32_e32 v1, s36
	v_cndmask_b32_e64 v0, v0, v1, s[20:21]
	v_mov_b32_e32 v1, s43
	v_mov_b32_e32 v2, s37
	v_cndmask_b32_e64 v1, v1, v2, s[20:21]
	v_mov_b32_e32 v2, s11
	v_cndmask_b32_e32 v7, v2, v1, vcc
	v_mov_b32_e32 v1, s10
	v_cndmask_b32_e32 v8, v1, v0, vcc
	v_mov_b32_e32 v0, s22
	v_mov_b32_e32 v1, s38
	v_cndmask_b32_e64 v0, v0, v1, s[20:21]
	v_mov_b32_e32 v1, s23
	v_mov_b32_e32 v2, s39
	v_cndmask_b32_e64 v1, v1, v2, s[20:21]
	v_mov_b32_e32 v2, s13
	v_cndmask_b32_e32 v3, v2, v1, vcc
	v_mov_b32_e32 v1, s12
	v_cndmask_b32_e32 v2, v1, v0, vcc
	v_mov_b32_e32 v0, s6
	v_mov_b32_e32 v1, s4
	v_cndmask_b32_e64 v0, v0, v1, s[20:21]
	v_mov_b32_e32 v1, s7
	v_mov_b32_e32 v9, s5
	v_cndmask_b32_e64 v1, v1, v9, s[20:21]
	v_mov_b32_e32 v9, s3
	v_cndmask_b32_e32 v1, v9, v1, vcc
	v_mov_b32_e32 v9, s2
	v_cndmask_b32_e32 v0, v9, v0, vcc
	v_cmp_ne_u64_e64 s[2:3], 1, v[2:3]
	v_ashrrev_i32_e32 v13, 31, v12
	v_mul_lo_u32 v9, v5, v12
	v_mul_lo_u32 v11, v4, v13
	v_mad_u64_u32 v[4:5], s[4:5], v4, v12, 0
	v_add3_u32 v5, v5, v11, v9
	v_ashrrev_i32_e32 v11, 31, v10
	v_mul_lo_u32 v14, v8, v11
	v_mul_lo_u32 v7, v7, v10
	v_mad_u64_u32 v[8:9], s[4:5], v8, v10, 0
	v_add3_u32 v9, v9, v14, v7
	v_lshlrev_b32_e32 v20, 2, v6
	v_lshl_add_u64 v[18:19], v[4:5], 2, v[0:1]
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[2:3], exec, s[4:5]
	s_cbranch_execz .LBB0_3
	v_lshl_add_u64 v[8:9], v[8:9], 2, v[18:19]
	v_mad_u64_u32 v[0:1], s[4:5], v2, v20, 0
	v_mov_b32_e32 v4, v1
	v_mad_u64_u32 v[4:5], s[4:5], v3, v20, v[4:5]
	v_mov_b32_e32 v1, v4
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[8:9]
	v_or_b32_e32 v7, 1, v20
	v_mad_u64_u32 v[4:5], s[4:5], v2, v7, 0
	v_mov_b32_e32 v6, v5
	v_mad_u64_u32 v[6:7], s[4:5], v3, v7, v[6:7]
	v_mov_b32_e32 v5, v6
	v_lshl_add_u64 v[4:5], v[4:5], 2, v[8:9]
	v_or_b32_e32 v15, 2, v20
	v_mad_u64_u32 v[6:7], s[4:5], v2, v15, 0
	v_mov_b32_e32 v14, v7
	v_mad_u64_u32 v[14:15], s[4:5], v3, v15, v[14:15]
	v_mov_b32_e32 v7, v14
	v_lshl_add_u64 v[6:7], v[6:7], 2, v[8:9]
	v_or_b32_e32 v16, 3, v20
	v_mad_u64_u32 v[14:15], s[4:5], v2, v16, 0
	v_mov_b32_e32 v2, v15
	v_mad_u64_u32 v[2:3], s[4:5], v3, v16, v[2:3]
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[16:17], v[14:15], 2, v[8:9]
.LBB0_3:
	s_or_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[2:3], s[18:19], -1
	v_lshlrev_b32_e32 v14, 2, v20
	s_xor_b64 exec, exec, s[4:5]
	v_lshl_add_u64 v[0:1], v[8:9], 2, v[18:19]
	v_mov_b32_e32 v15, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[14:15]
	v_lshl_add_u64 v[4:5], v[0:1], 0, 4
	v_lshl_add_u64 v[6:7], v[0:1], 0, 8
	v_lshl_add_u64 v[16:17], v[0:1], 0, 12
	s_or_b64 exec, exec, s[4:5]
	global_load_dword v0, v[0:1], off
	global_load_dword v8, v[4:5], off
	global_load_dword v2, v[6:7], off
	global_load_dword v3, v[16:17], off
	s_load_dwordx8 s[40:47], s[0:1], 0x70
	s_load_dwordx8 s[20:27], s[0:1], 0x90
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_19
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v4, s46
	v_mov_b32_e32 v5, s47
	v_mov_b32_e32 v1, s41
	v_mov_b32_e32 v6, s43
	v_cndmask_b32_e32 v7, v1, v6, vcc
	v_mov_b32_e32 v1, s40
	v_mov_b32_e32 v6, s42
	v_lshl_add_u64 v[4:5], v[12:13], 3, v[4:5]
	global_load_dwordx2 v[16:17], v[4:5], off
	v_cndmask_b32_e32 v6, v1, v6, vcc
	v_mov_b32_e32 v15, 0
	v_lshl_add_u64 v[4:5], v[6:7], 0, v[14:15]
	global_load_dwordx4 v[4:7], v[4:5], off
	v_mov_b32_e32 v18, s44
	v_mov_b32_e32 v19, s45
	s_waitcnt vmcnt(4)
	v_mul_f32_e32 v1, v8, v8
	s_waitcnt vmcnt(2)
	v_pk_mul_f32 v[22:23], v[2:3], v[2:3]
	v_mbcnt_lo_u32_b32 v9, -1, 0
	v_mov_b32_e32 v24, s51
	s_lshr_b32 s4, s31, 31
	s_ashr_i32 s18, s31, 31
	v_cmp_gt_i32_e64 s[2:3], s31, v20
	v_fmac_f32_e32 v1, v0, v0
	v_mbcnt_hi_u32_b32 v21, -1, v9
	s_add_i32 s19, s31, s4
	v_add_f32_e32 v1, v1, v22
	v_and_b32_e32 v9, 0x60, v21
	v_xor_b32_e32 v25, 16, v21
	v_add_f32_e32 v1, v1, v23
	v_add_u32_e32 v22, 32, v9
	v_cmp_lt_i32_e64 s[4:5], v25, v22
	s_nop 1
	v_cndmask_b32_e64 v9, v21, v25, s[4:5]
	v_lshlrev_b32_e32 v9, 2, v9
	ds_bpermute_b32 v9, v9, v1
	v_xor_b32_e32 v23, 8, v21
	v_cmp_lt_i32_e64 s[4:5], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v23, v21, v23, s[4:5]
	v_lshlrev_b32_e32 v23, 2, v23
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v9
	ds_bpermute_b32 v9, v23, v1
	v_xor_b32_e32 v23, 4, v21
	v_cmp_lt_i32_e64 s[4:5], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v23, v21, v23, s[4:5]
	v_lshlrev_b32_e32 v23, 2, v23
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v9
	ds_bpermute_b32 v9, v23, v1
	v_xor_b32_e32 v23, 2, v21
	v_cmp_lt_i32_e64 s[4:5], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v23, v21, v23, s[4:5]
	v_lshlrev_b32_e32 v23, 2, v23
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v9
	ds_bpermute_b32 v9, v23, v1
	v_xor_b32_e32 v23, 1, v21
	v_cmp_lt_i32_e64 s[4:5], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v23, v21, v23, s[4:5]
	v_lshlrev_b32_e32 v23, 2, v23
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v9
	ds_bpermute_b32 v9, v23, v1
	s_lshr_b32 s5, s18, 29
	s_ashr_i32 s4, s19, 1
	s_add_i32 s19, s31, s5
	s_ashr_i32 s5, s4, 31
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v9
	v_fmamk_f32 v1, v1, 0x3c000000, v24
	v_rsq_f32_e32 v24, v1
	s_ashr_i32 s26, s19, 3
	v_mul_f32_e32 v0, v24, v0
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v1, v16, s18
	v_mul_lo_u32 v9, v17, s31
	v_mad_u64_u32 v[16:17], s[18:19], v16, s31, 0
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v0, v4, v0
	v_add3_u32 v17, v17, v1, v9
	v_lshl_add_u64 v[18:19], v[16:17], 2, v[18:19]
	v_lshl_add_u64 v[16:17], s[4:5], 2, v[18:19]
	v_xor_b32_e32 v23, s26, v21
	s_and_saveexec_b64 s[18:19], s[2:3]
	s_cbranch_execz .LBB0_8
	s_abs_i32 s5, s4
	v_cvt_f32_u32_e32 v1, s5
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mov_b32_e32 v27, v15
	s_sub_i32 s2, 0, s5
	v_mul_lo_u32 v4, s2, v1
	v_mul_hi_u32 v4, v1, v4
	v_add_u32_e32 v1, v1, v4
	v_mul_hi_u32 v1, v20, v1
	v_mul_lo_u32 v1, v1, s5
	v_sub_u32_e32 v1, v20, v1
	v_subrev_u32_e32 v4, s5, v1
	v_cmp_le_u32_e64 s[2:3], s5, v1
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v4, s[2:3]
	v_subrev_u32_e32 v4, s5, v1
	v_cmp_le_u32_e64 s[2:3], s5, v1
	s_nop 1
	v_cndmask_b32_e64 v26, v1, v4, s[2:3]
	v_lshlrev_b64 v[26:27], 2, v[26:27]
	v_lshl_add_u64 v[28:29], v[18:19], 0, v[26:27]
	v_lshl_add_u64 v[26:27], v[16:17], 0, v[26:27]
	global_load_dword v28, v[28:29], off
	global_load_dword v29, v[26:27], off
	v_cmp_lt_i32_e64 s[2:3], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v1, v21, v23, s[2:3]
	v_lshlrev_b32_e32 v1, 2, v1
	ds_bpermute_b32 v1, v1, v0
	v_cmp_gt_i32_e64 s[2:3], s4, v20
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_cndmask_b32_e64 v1, v1, -v1, s[2:3]
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[0:1], v[0:1], v[28:29]
	s_nop 0
	v_add_f32_e32 v0, v0, v1
.LBB0_8:
	s_or_b64 exec, exec, s[18:19]
	v_or_b32_e32 v1, 1, v20
	v_mul_f32_e32 v4, v24, v8
	v_mul_f32_e32 v8, v5, v4
	v_cmp_gt_i32_e64 s[2:3], s31, v1
	s_and_saveexec_b64 s[18:19], s[2:3]
	s_cbranch_execz .LBB0_10
	s_abs_i32 s5, s4
	v_cvt_f32_u32_e32 v4, s5
	v_rcp_iflag_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	v_mov_b32_e32 v5, v15
	s_sub_i32 s2, 0, s5
	v_mul_lo_u32 v9, s2, v4
	v_mul_hi_u32 v9, v4, v9
	v_add_u32_e32 v4, v4, v9
	v_mul_hi_u32 v4, v1, v4
	v_mul_lo_u32 v4, v4, s5
	v_sub_u32_e32 v4, v1, v4
	v_subrev_u32_e32 v9, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v9, s[2:3]
	v_subrev_u32_e32 v9, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v9, s[2:3]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshl_add_u64 v[26:27], v[18:19], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[16:17], 0, v[4:5]
	global_load_dword v26, v[26:27], off
	global_load_dword v27, v[4:5], off
	v_cmp_lt_i32_e64 s[2:3], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v4, v21, v23, s[2:3]
	v_lshlrev_b32_e32 v4, 2, v4
	ds_bpermute_b32 v4, v4, v8
	v_cmp_gt_i32_e64 s[2:3], s4, v1
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_cndmask_b32_e64 v9, v4, -v4, s[2:3]
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[4:5], v[8:9], v[26:27]
	s_nop 0
	v_add_f32_e32 v8, v4, v5
.LBB0_10:
	s_or_b64 exec, exec, s[18:19]
	v_or_b32_e32 v9, 2, v20
	v_mul_f32_e32 v2, v24, v2
	v_mul_f32_e32 v2, v6, v2
	v_cmp_gt_i32_e64 s[2:3], s31, v9
	s_and_saveexec_b64 s[18:19], s[2:3]
	s_cbranch_execz .LBB0_12
	s_abs_i32 s5, s4
	v_cvt_f32_u32_e32 v4, s5
	v_rcp_iflag_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	v_mov_b32_e32 v5, 0
	s_sub_i32 s2, 0, s5
	v_mul_lo_u32 v6, s2, v4
	v_mul_hi_u32 v6, v4, v6
	v_add_u32_e32 v4, v4, v6
	v_mul_hi_u32 v4, v9, v4
	v_mul_lo_u32 v4, v4, s5
	v_sub_u32_e32 v4, v9, v4
	v_subrev_u32_e32 v6, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v6, s[2:3]
	v_subrev_u32_e32 v6, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v6, s[2:3]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshl_add_u64 v[26:27], v[18:19], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[16:17], 0, v[4:5]
	global_load_dword v26, v[26:27], off
	global_load_dword v27, v[4:5], off
	v_cmp_lt_i32_e64 s[2:3], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v4, v21, v23, s[2:3]
	v_lshlrev_b32_e32 v4, 2, v4
	ds_bpermute_b32 v4, v4, v2
	v_cmp_gt_i32_e64 s[2:3], s4, v9
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_cndmask_b32_e64 v5, v4, -v4, s[2:3]
	v_mov_b32_e32 v4, v2
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[4:5], v[4:5], v[26:27]
	s_nop 0
	v_add_f32_e32 v2, v4, v5
.LBB0_12:
	s_or_b64 exec, exec, s[18:19]
	v_or_b32_e32 v15, 3, v20
	v_mov_b32_e32 v5, 0
	v_mul_f32_e32 v3, v24, v3
	v_mul_f32_e32 v3, v7, v3
	v_cmp_gt_i32_e64 s[2:3], s31, v15
	s_and_saveexec_b64 s[18:19], s[2:3]
	s_cbranch_execz .LBB0_14
	s_abs_i32 s5, s4
	v_cvt_f32_u32_e32 v4, s5
	v_rcp_iflag_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	s_sub_i32 s2, 0, s5
	v_mul_lo_u32 v6, s2, v4
	v_mul_hi_u32 v6, v4, v6
	v_add_u32_e32 v4, v4, v6
	v_mul_hi_u32 v4, v15, v4
	v_mul_lo_u32 v4, v4, s5
	v_sub_u32_e32 v4, v15, v4
	v_subrev_u32_e32 v6, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v6, s[2:3]
	v_subrev_u32_e32 v6, s5, v4
	v_cmp_le_u32_e64 s[2:3], s5, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v6, s[2:3]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshl_add_u64 v[6:7], v[18:19], 0, v[4:5]
	v_lshl_add_u64 v[4:5], v[16:17], 0, v[4:5]
	global_load_dword v6, v[6:7], off
	global_load_dword v7, v[4:5], off
	v_cmp_lt_i32_e64 s[2:3], v23, v22
	s_nop 1
	v_cndmask_b32_e64 v4, v21, v23, s[2:3]
	v_lshlrev_b32_e32 v4, 2, v4
	ds_bpermute_b32 v4, v4, v3
	v_cmp_gt_i32_e64 s[2:3], s4, v15
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_cndmask_b32_e64 v5, v4, -v4, s[2:3]
	v_mov_b32_e32 v4, v3
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[4:5], v[4:5], v[6:7]
	s_nop 0
	v_add_f32_e32 v3, v4, v5
.LBB0_14:
	s_or_b64 exec, exec, s[18:19]
	s_load_dwordx4 s[0:3], s[0:1], 0xc8
	v_mov_b32_e32 v4, s8
	v_mov_b32_e32 v5, s14
	v_cndmask_b32_e32 v16, v4, v5, vcc
	v_mov_b32_e32 v4, s9
	v_mov_b32_e32 v5, s15
	v_cndmask_b32_e32 v17, v4, v5, vcc
	v_mov_b32_e32 v4, s10
	v_mov_b32_e32 v5, s36
	v_cndmask_b32_e32 v18, v4, v5, vcc
	v_mov_b32_e32 v4, s11
	v_mov_b32_e32 v5, s37
	v_cndmask_b32_e32 v19, v4, v5, vcc
	v_mov_b32_e32 v4, s13
	v_mov_b32_e32 v5, s39
	v_cndmask_b32_e32 v5, v4, v5, vcc
	v_mov_b32_e32 v4, s12
	v_mov_b32_e32 v6, s38
	v_cndmask_b32_e32 v4, v4, v6, vcc
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v6, s1
	v_mov_b32_e32 v7, s3
	v_cndmask_b32_e32 v7, v6, v7, vcc
	v_mov_b32_e32 v6, s0
	v_mov_b32_e32 v21, s2
	v_cndmask_b32_e32 v6, v6, v21, vcc
	v_cmp_ne_u64_e64 s[0:1], 1, v[4:5]
	v_mul_lo_u32 v21, v17, v12
	v_mul_lo_u32 v22, v16, v13
	v_mad_u64_u32 v[16:17], s[2:3], v16, v12, 0
	v_add3_u32 v17, v17, v22, v21
	v_mul_lo_u32 v21, v19, v10
	v_mul_lo_u32 v11, v18, v11
	v_mad_u64_u32 v[18:19], s[2:3], v18, v10, 0
	v_add3_u32 v19, v19, v11, v21
	v_lshl_add_u64 v[6:7], v[16:17], 2, v[6:7]
	v_lshl_add_u64 v[6:7], v[18:19], 2, v[6:7]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_xor_b64 s[0:1], exec, s[2:3]
	s_cbranch_execz .LBB0_16
	v_mad_u64_u32 v[16:17], s[2:3], v4, v20, 0
	v_mov_b32_e32 v14, v17
	v_mad_u64_u32 v[18:19], s[2:3], v5, v20, v[14:15]
	v_mov_b32_e32 v17, v18
	v_lshl_add_u64 v[16:17], v[16:17], 2, v[6:7]
	global_store_dword v[16:17], v0, off
	v_mad_u64_u32 v[16:17], s[2:3], v4, v1, 0
	v_mov_b32_e32 v14, v17
	v_mad_u64_u32 v[18:19], s[2:3], v5, v1, v[14:15]
	v_mov_b32_e32 v17, v18
	v_lshl_add_u64 v[16:17], v[16:17], 2, v[6:7]
	global_store_dword v[16:17], v8, off
	v_mad_u64_u32 v[16:17], s[2:3], v4, v9, 0
	v_mov_b32_e32 v14, v17
	v_mad_u64_u32 v[18:19], s[2:3], v5, v9, v[14:15]
	v_mov_b32_e32 v17, v18
	v_lshl_add_u64 v[16:17], v[16:17], 2, v[6:7]
	global_store_dword v[16:17], v2, off
	v_mad_u64_u32 v[16:17], s[2:3], v4, v15, 0
	v_mov_b32_e32 v4, v17
	v_mad_u64_u32 v[4:5], s[2:3], v5, v15, v[4:5]
	v_mov_b32_e32 v17, v4
	v_lshl_add_u64 v[4:5], v[16:17], 2, v[6:7]
	global_store_dword v[4:5], v3, off
.LBB0_16:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	s_cbranch_execz .LBB0_18
	v_mov_b32_e32 v15, 0
	v_lshl_add_u64 v[4:5], v[6:7], 0, v[14:15]
	v_mov_b32_e32 v1, v8
	global_store_dwordx4 v[4:5], v[0:3], off
.LBB0_18:
	s_or_b64 exec, exec, s[0:1]
.LBB0_19:
	s_or_b64 exec, exec, s[6:7]
	s_xor_b64 s[2:3], s[16:17], -1
	s_and_b64 exec, exec, vcc
	s_cbranch_execz .LBB0_29
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v4, s24
	v_mov_b32_e32 v5, s25
	v_lshl_add_u64 v[4:5], v[12:13], 3, v[4:5]
	global_load_dwordx2 v[4:5], v[4:5], off
	s_waitcnt vmcnt(0)
	v_cmp_lt_i64_e32 vcc, -1, v[4:5]
	s_and_b64 exec, exec, vcc
	s_cbranch_execz .LBB0_29
	s_ashr_i32 s11, s29, 31
	s_mov_b32 s10, s29
	v_or_b32_e32 v7, s11, v5
	v_mov_b32_e32 v6, 0
	v_cmp_ne_u64_e32 vcc, 0, v[6:7]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[4:5], exec, s[0:1]
	s_cbranch_execz .LBB0_23
	s_ashr_i32 s6, s11, 31
	s_mov_b32 s7, s6
	s_add_u32 s0, s10, s6
	s_addc_u32 s1, s11, s6
	s_xor_b64 s[8:9], s[0:1], s[6:7]
	v_cvt_f32_u32_e32 v1, s8
	v_cvt_f32_u32_e32 v7, s9
	v_fmamk_f32 v1, v7, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v7, 0x2f800000, v1
	v_trunc_f32_e32 v7, v7
	v_fmamk_f32 v1, v7, 0xcf800000, v1
	v_cvt_u32_f32_e32 v7, v7
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s0, 0, s8
	s_subb_u32 s1, 0, s9
	v_mul_lo_u32 v9, s0, v7
	v_mul_lo_u32 v11, s1, v1
	v_mul_hi_u32 v12, s0, v1
	v_mul_lo_u32 v16, s0, v1
	v_add_u32_e32 v9, v12, v9
	v_add_u32_e32 v9, v9, v11
	v_mul_hi_u32 v13, v1, v9
	v_mul_lo_u32 v12, v1, v9
	v_mul_hi_u32 v14, v1, v16
	v_mov_b32_e32 v15, v6
	v_lshl_add_u64 v[12:13], v[14:15], 0, v[12:13]
	v_mul_hi_u32 v11, v7, v9
	v_mul_hi_u32 v14, v7, v16
	v_mul_lo_u32 v15, v7, v16
	v_add_co_u32_e32 v12, vcc, v12, v15
	s_nop 1
	v_addc_co_u32_e32 v12, vcc, v13, v14, vcc
	s_nop 1
	v_addc_co_u32_e32 v15, vcc, 0, v11, vcc
	v_mul_lo_u32 v14, v7, v9
	v_mov_b32_e32 v13, v6
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_add_co_u32_e32 v1, vcc, v1, v12
	s_nop 1
	v_addc_co_u32_e32 v7, vcc, v7, v13, vcc
	v_mul_lo_u32 v9, s0, v7
	v_mul_hi_u32 v11, s0, v1
	v_add_u32_e32 v9, v11, v9
	v_mul_lo_u32 v11, s1, v1
	v_add_u32_e32 v9, v9, v11
	v_mul_hi_u32 v11, v7, v9
	v_mul_lo_u32 v14, s0, v1
	v_mul_hi_u32 v16, v7, v14
	v_mul_lo_u32 v17, v7, v14
	v_mul_hi_u32 v13, v1, v9
	v_mul_lo_u32 v12, v1, v9
	v_mul_hi_u32 v14, v1, v14
	v_mov_b32_e32 v15, v6
	v_lshl_add_u64 v[12:13], v[14:15], 0, v[12:13]
	v_add_co_u32_e32 v12, vcc, v12, v17
	s_nop 1
	v_addc_co_u32_e32 v12, vcc, v13, v16, vcc
	s_nop 1
	v_addc_co_u32_e32 v15, vcc, 0, v11, vcc
	v_mul_lo_u32 v14, v7, v9
	v_mov_b32_e32 v13, v6
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_add_co_u32_e32 v1, vcc, v1, v12
	s_nop 1
	v_addc_co_u32_e32 v7, vcc, v7, v13, vcc
	v_ashrrev_i32_e32 v12, 31, v5
	v_mov_b32_e32 v13, v12
	v_lshl_add_u64 v[14:15], v[4:5], 0, v[12:13]
	v_xor_b32_e32 v9, v15, v12
	v_xor_b32_e32 v11, v14, v12
	v_mad_u64_u32 v[14:15], s[0:1], v11, v7, 0
	v_mul_hi_u32 v16, v11, v1
	v_mov_b32_e32 v17, v6
	v_lshl_add_u64 v[14:15], v[16:17], 0, v[14:15]
	v_mad_u64_u32 v[16:17], s[0:1], v9, v7, 0
	v_mad_u64_u32 v[18:19], s[0:1], v9, v1, 0
	v_add_co_u32_e32 v1, vcc, v14, v18
	s_nop 1
	v_addc_co_u32_e32 v14, vcc, v15, v19, vcc
	s_nop 1
	v_addc_co_u32_e32 v17, vcc, 0, v17, vcc
	v_mov_b32_e32 v15, v6
	v_lshl_add_u64 v[6:7], v[14:15], 0, v[16:17]
	v_mul_lo_u32 v1, s9, v6
	v_mul_lo_u32 v13, s8, v7
	v_mad_u64_u32 v[14:15], s[0:1], s8, v6, 0
	v_add3_u32 v1, v15, v13, v1
	v_sub_u32_e32 v13, v9, v1
	v_mov_b32_e32 v15, s9
	v_sub_co_u32_e32 v11, vcc, v11, v14
	s_nop 1
	v_subb_co_u32_e64 v13, s[0:1], v13, v15, vcc
	v_subrev_co_u32_e64 v14, s[0:1], s8, v11
	s_nop 1
	v_subbrev_co_u32_e64 v13, s[0:1], 0, v13, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s9, v13
	s_nop 1
	v_cndmask_b32_e64 v15, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s8, v14
	s_nop 1
	v_cndmask_b32_e64 v14, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s9, v13
	s_nop 1
	v_cndmask_b32_e64 v13, v15, v14, s[0:1]
	v_lshl_add_u64 v[14:15], v[6:7], 0, 2
	v_lshl_add_u64 v[16:17], v[6:7], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v13
	s_nop 1
	v_cndmask_b32_e64 v13, v17, v15, s[0:1]
	v_subb_co_u32_e32 v1, vcc, v9, v1, vcc
	v_cmp_le_u32_e32 vcc, s9, v1
	s_nop 1
	v_cndmask_b32_e64 v9, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s8, v11
	s_nop 1
	v_cndmask_b32_e64 v11, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s9, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v9, v11, vcc
	v_cmp_ne_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v7, v13, vcc
	v_cndmask_b32_e64 v7, v16, v14, s[0:1]
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_xor_b32_e32 v7, s6, v12
	v_xor_b32_e32 v1, v1, v7
	v_xor_b32_e32 v6, v6, v7
	v_sub_co_u32_e32 v12, vcc, v6, v7
	s_nop 1
	v_subb_co_u32_e32 v13, vcc, v1, v7, vcc
.LBB0_23:
	s_andn2_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_25
	v_cvt_f32_u32_e32 v1, s10
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_sub_i32 s4, 0, s10
	v_mul_lo_u32 v6, s4, v1
	v_mul_hi_u32 v6, v1, v6
	v_add_u32_e32 v1, v1, v6
	v_mul_hi_u32 v1, v4, v1
	v_mul_lo_u32 v6, v1, s10
	v_add_u32_e32 v7, 1, v1
	v_sub_u32_e32 v6, v4, v6
	v_subrev_u32_e32 v9, s10, v6
	v_cmp_le_u32_e32 vcc, s10, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v6, v9, vcc
	v_cndmask_b32_e32 v1, v1, v7, vcc
	v_add_u32_e32 v7, 1, v1
	v_cmp_le_u32_e32 vcc, s10, v6
	s_nop 1
	v_cndmask_b32_e32 v12, v1, v7, vcc
	v_mov_b32_e32 v13, 0
.LBB0_25:
	s_or_b64 exec, exec, s[0:1]
	v_mul_lo_u32 v1, v13, s10
	v_mul_lo_u32 v9, v12, s11
	v_mad_u64_u32 v[6:7], s[0:1], v12, s10, 0
	v_add3_u32 v7, v7, v9, v1
	v_sub_co_u32_e32 v1, vcc, v4, v6
	s_nop 1
	v_subb_co_u32_e32 v9, vcc, v5, v7, vcc
	v_mul_lo_u32 v4, s29, v10
	v_lshlrev_b32_e32 v4, 7, v4
	v_ashrrev_i32_e32 v5, 31, v4
	s_ashr_i32 s4, s30, 31
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_xor_b64 s[0:1], exec, s[0:1]
	s_cbranch_execz .LBB0_27
	s_abs_i32 s2, s30
	v_cvt_f32_u32_e32 v9, s2
	v_mov_b32_e32 v10, s22
	v_mov_b32_e32 v11, s23
	v_rcp_iflag_f32_e32 v9, v9
	s_ashr_i32 s5, s50, 31
	v_xor_b32_e32 v12, s30, v1
	v_sub_u32_e32 v13, 0, v1
	v_mul_f32_e32 v9, 0x4f7ffffe, v9
	v_cvt_u32_f32_e32 v9, v9
	v_ashrrev_i32_e32 v12, 31, v12
	v_max_i32_e32 v13, v1, v13
	s_sub_i32 s3, 0, s2
	v_mul_lo_u32 v14, s3, v9
	v_mul_hi_u32 v14, v9, v14
	v_add_u32_e32 v9, v9, v14
	v_mul_hi_u32 v9, v13, v9
	v_mul_lo_u32 v14, v9, s2
	v_add_u32_e32 v15, 1, v9
	v_sub_u32_e32 v13, v13, v14
	v_cmp_le_u32_e32 vcc, s2, v13
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v15, vcc
	v_subrev_u32_e32 v14, s2, v13
	v_cndmask_b32_e32 v13, v13, v14, vcc
	v_add_u32_e32 v14, 1, v9
	v_cmp_le_u32_e32 vcc, s2, v13
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v14, vcc
	v_xor_b32_e32 v9, v9, v12
	v_sub_u32_e32 v9, v9, v12
	v_mad_i64_i32 v[12:13], s[2:3], s30, v9, 0
	v_mul_lo_u32 v9, v9, s30
	v_sub_u32_e32 v14, v1, v9
	v_mov_b32_e32 v15, 0
	s_lshl_b32 s6, s50, 9
	v_mov_b32_e32 v1, s50
	v_alignbit_b32 v1, s5, v1, 23
	v_mul_lo_u32 v1, v6, v1
	v_mad_u64_u32 v[10:11], s[2:3], v6, s6, v[10:11]
	v_mul_lo_u32 v6, v7, s6
	v_add3_u32 v11, v6, v11, v1
	v_lshl_add_u64 v[4:5], v[4:5], 2, v[10:11]
	v_lshlrev_b64 v[6:7], 9, v[12:13]
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[6:7]
	v_lshl_add_u64 v[4:5], v[14:15], 2, v[4:5]
	v_mul_lo_u32 v6, v20, s30
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshl_add_u64 v[10:11], v[6:7], 2, v[4:5]
	global_store_dword v[10:11], v0, off
	v_add_u32_e32 v0, s30, v6
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[6:7], v[0:1], 2, v[4:5]
	global_store_dword v[6:7], v8, off
	v_add_u32_e32 v0, s30, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[6:7], v[0:1], 2, v[4:5]
	global_store_dword v[6:7], v2, off
	v_add_u32_e32 v0, s30, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[4:5]
	global_store_dword v[0:1], v3, off
.LBB0_27:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	s_cbranch_execz .LBB0_29
	v_mov_b32_e32 v10, s20
	v_mov_b32_e32 v11, s21
	s_ashr_i32 s2, s49, 31
	v_mul_lo_u32 v9, v9, s30
	v_mul_lo_u32 v14, v1, s4
	v_mad_u64_u32 v[12:13], s[0:1], v1, s30, 0
	v_add3_u32 v13, v13, v14, v9
	s_mul_i32 s3, s30, s29
	s_lshl_b32 s5, s49, 9
	s_abs_i32 s6, s30
	v_cvt_f32_u32_e32 v1, s6
	v_mov_b32_e32 v9, s49
	v_alignbit_b32 v9, s2, v9, 23
	v_mul_lo_u32 v9, v6, v9
	v_rcp_iflag_f32_e32 v1, v1
	v_mad_u64_u32 v[10:11], s[0:1], v6, s5, v[10:11]
	v_mul_lo_u32 v6, v7, s5
	v_add3_u32 v11, v6, v11, v9
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_lshl_add_u64 v[4:5], v[4:5], 2, v[10:11]
	v_lshl_add_u64 v[4:5], v[12:13], 2, v[4:5]
	s_sub_i32 s0, 0, s6
	v_mul_lo_u32 v6, s0, v1
	v_mul_hi_u32 v6, v1, v6
	v_add_u32_e32 v9, v1, v6
	v_mul_hi_u32 v1, v20, v9
	v_mul_lo_u32 v6, v1, s6
	v_sub_u32_e32 v6, v20, v6
	v_add_u32_e32 v7, 1, v1
	v_cmp_le_u32_e32 vcc, s6, v6
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v7, vcc
	v_subrev_u32_e32 v7, s6, v6
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_add_u32_e32 v7, 1, v1
	v_cmp_le_u32_e32 vcc, s6, v6
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v7, vcc
	v_xor_b32_e32 v1, s4, v1
	v_subrev_u32_e32 v1, s4, v1
	v_mul_lo_u32 v6, s3, v1
	v_ashrrev_i32_e32 v7, 31, v6
	v_mul_lo_u32 v1, v1, s30
	v_sub_u32_e32 v10, v20, v1
	v_mov_b32_e32 v11, 0
	v_lshl_add_u64 v[6:7], v[6:7], 2, v[4:5]
	v_lshl_add_u64 v[6:7], v[10:11], 2, v[6:7]
	global_store_dword v[6:7], v0, off
	v_or_b32_e32 v6, 1, v20
	v_mul_hi_u32 v0, v6, v9
	v_mul_lo_u32 v1, v0, s6
	v_sub_u32_e32 v1, v6, v1
	v_add_u32_e32 v7, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v7, vcc
	v_subrev_u32_e32 v7, s6, v1
	v_cndmask_b32_e32 v1, v1, v7, vcc
	v_add_u32_e32 v7, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v7, vcc
	v_xor_b32_e32 v0, s4, v0
	v_subrev_u32_e32 v7, s4, v0
	v_mul_lo_u32 v0, s3, v7
	v_ashrrev_i32_e32 v1, 31, v0
	v_mul_lo_u32 v7, v7, s30
	v_sub_u32_e32 v10, v6, v7
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[4:5]
	v_lshl_add_u64 v[0:1], v[10:11], 2, v[0:1]
	global_store_dword v[0:1], v8, off
	v_or_b32_e32 v6, 2, v20
	v_mul_hi_u32 v0, v6, v9
	v_mul_lo_u32 v1, v0, s6
	v_sub_u32_e32 v1, v6, v1
	v_add_u32_e32 v7, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v7, vcc
	v_subrev_u32_e32 v7, s6, v1
	v_cndmask_b32_e32 v1, v1, v7, vcc
	v_add_u32_e32 v7, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v7, vcc
	v_xor_b32_e32 v0, s4, v0
	v_subrev_u32_e32 v7, s4, v0
	v_mul_lo_u32 v0, s3, v7
	v_ashrrev_i32_e32 v1, 31, v0
	v_mul_lo_u32 v7, v7, s30
	v_sub_u32_e32 v10, v6, v7
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[4:5]
	v_lshl_add_u64 v[0:1], v[10:11], 2, v[0:1]
	global_store_dword v[0:1], v2, off
	v_or_b32_e32 v2, 3, v20
	v_mul_hi_u32 v0, v2, v9
	v_mul_lo_u32 v1, v0, s6
	v_sub_u32_e32 v1, v2, v1
	v_add_u32_e32 v6, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v6, vcc
	v_subrev_u32_e32 v6, s6, v1
	v_cndmask_b32_e32 v1, v1, v6, vcc
	v_add_u32_e32 v6, 1, v0
	v_cmp_le_u32_e32 vcc, s6, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v6, vcc
	v_xor_b32_e32 v0, s4, v0
	v_subrev_u32_e32 v6, s4, v0
	v_mul_lo_u32 v0, s3, v6
	v_ashrrev_i32_e32 v1, 31, v0
	v_mul_lo_u32 v6, v6, s30
	v_sub_u32_e32 v10, v2, v6
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[4:5]
	v_lshl_add_u64 v[0:1], v[10:11], 2, v[0:1]
	global_store_dword v[0:1], v3, off
.LBB0_29:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 472
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
		.amdhsa_next_free_vgpr 30
		.amdhsa_next_free_sgpr 52
		.amdhsa_accum_offset 32
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
	.section	.text._ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_,"axG",@progbits,_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_,comdat
.Lfunc_end0:
	.size	_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_, .Lfunc_end0-_ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_

	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.num_vgpr, 30
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.num_agpr, 0
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.numbered_sgpr, 52
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.private_seg_size, 0
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.uses_vcc, 1
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.uses_flat_scratch, 0
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.has_dyn_sized_stack, 0
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.has_recursion, 0
	.set _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_54c5843645a384d0,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_54c5843645a384d0
__hip_cuid_54c5843645a384d0:
	.byte	0
	.size	__hip_cuid_54c5843645a384d0, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_54c5843645a384d0
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           8
        .value_kind:     by_value
      - .offset:         32
        .size:           8
        .value_kind:     by_value
      - .offset:         40
        .size:           8
        .value_kind:     by_value
      - .offset:         48
        .size:           8
        .value_kind:     by_value
      - .offset:         56
        .size:           8
        .value_kind:     by_value
      - .offset:         64
        .size:           8
        .value_kind:     by_value
      - .offset:         72
        .size:           8
        .value_kind:     by_value
      - .offset:         80
        .size:           8
        .value_kind:     by_value
      - .offset:         88
        .size:           8
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
      - .address_space:  global
        .offset:         112
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         120
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         128
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         136
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         144
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         152
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         160
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         168
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         176
        .size:           8
        .value_kind:     global_buffer
      - .offset:         184
        .size:           4
        .value_kind:     by_value
      - .offset:         188
        .size:           4
        .value_kind:     by_value
      - .offset:         192
        .size:           4
        .value_kind:     by_value
      - .offset:         196
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         200
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         208
        .size:           8
        .value_kind:     global_buffer
      - .offset:         216
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         220
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         224
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         228
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         230
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         232
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         234
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         236
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         238
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         256
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         264
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         272
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         280
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 472
    .max_flat_workgroup_size: 1024
    .name:           _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_
    .private_segment_fixed_size: 0
    .sgpr_count:     58
    .sgpr_spill_count: 0
    .symbol:         _ZN5probe38fusedQKNormRopeQuantCacheShuffleKernelIffLi128ELb0ELi1ELN4vllm18Fp8KVCacheDataTypeE0EEEvPT_S4_S4_xxxxxxxxxiiifPKS3_S6_S6_PKxPT0_SA_PxPfSC_iiiiS4_S4_.kd
    .uses_dynamic_stack: false
    .vgpr_count:     30
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
