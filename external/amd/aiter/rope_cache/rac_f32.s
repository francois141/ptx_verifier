	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_,"axG",@progbits,_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_,comdat
	.protected	_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_
	.globl	_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_
	.p2align	8
	.type	_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_,@function
_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_cmp_lg_u32 s12, 1
	s_mov_b32 s17, 0
	s_cbranch_scc0 .LBB0_2
	s_lshl_b64 s[18:19], s[16:17], 2
	s_add_u32 s18, s10, s18
	s_addc_u32 s19, s11, s19
	s_load_dword s18, s[18:19], 0x0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s19, s18, 31
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_3
	s_branch .LBB0_4
.LBB0_2:
	s_mov_b64 vcc, 0
.LBB0_3:
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s10, s10, s18
	s_addc_u32 s11, s11, s19
	s_load_dwordx2 s[18:19], s[10:11], 0x0
.LBB0_4:
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_i64_e64 s[10:11], s[18:19], 0
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_11
	s_load_dwordx4 s[20:23], s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s25, s21, 31
	s_mov_b32 s24, s21
	s_or_b64 s[10:11], s[18:19], s[24:25]
	s_mov_b32 s10, 0
	s_cmp_lg_u64 s[10:11], 0
	s_cbranch_scc0 .LBB0_12
	s_ashr_i32 s26, s25, 31
	s_mov_b32 s27, s26
	s_add_u32 s10, s24, s26
	s_addc_u32 s11, s25, s26
	s_xor_b64 s[30:31], s[10:11], s[26:27]
	v_cvt_f32_u32_e32 v1, s30
	v_cvt_f32_u32_e32 v2, s31
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s10, 0, s30
	s_subb_u32 s11, 0, s31
	v_readfirstlane_b32 s12, v2
	v_readfirstlane_b32 s17, v1
	s_mul_i32 s23, s10, s12
	s_mul_i32 s33, s11, s17
	s_mul_hi_u32 s34, s10, s17
	s_add_i32 s23, s34, s23
	s_add_i32 s23, s23, s33
	s_mul_hi_u32 s33, s17, s23
	s_mul_i32 s34, s17, s23
	s_mul_i32 s35, s10, s17
	s_mul_hi_u32 s17, s17, s35
	s_add_u32 s17, s17, s34
	s_addc_u32 s33, 0, s33
	s_mul_hi_u32 s34, s12, s23
	s_mul_hi_u32 s36, s12, s35
	s_mul_i32 s35, s12, s35
	s_add_u32 s17, s17, s35
	s_addc_u32 s17, s33, s36
	s_addc_u32 s33, s34, 0
	s_mul_i32 s23, s12, s23
	s_add_u32 s17, s17, s23
	s_addc_u32 s23, 0, s33
	v_add_co_u32_e32 v1, vcc, s17, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s12, s12, s23
	s_mul_i32 s17, s10, s12
	v_readfirstlane_b32 s23, v1
	s_mul_hi_u32 s33, s10, s23
	s_add_i32 s17, s33, s17
	s_mul_i32 s11, s11, s23
	s_add_i32 s17, s17, s11
	s_mul_hi_u32 s11, s12, s17
	s_mul_i32 s10, s10, s23
	s_mul_hi_u32 s33, s12, s10
	s_mul_i32 s34, s12, s10
	s_mul_hi_u32 s35, s23, s17
	s_mul_i32 s36, s23, s17
	s_mul_hi_u32 s10, s23, s10
	s_add_u32 s10, s10, s36
	s_addc_u32 s23, 0, s35
	s_add_u32 s10, s10, s34
	s_addc_u32 s10, s23, s33
	s_addc_u32 s11, s11, 0
	s_mul_i32 s17, s12, s17
	s_add_u32 s10, s10, s17
	s_addc_u32 s11, 0, s11
	v_add_co_u32_e32 v1, vcc, s10, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s12, s12, s11
	s_ashr_i32 s34, s19, 31
	s_mov_b32 s35, s34
	s_add_u32 s10, s18, s34
	s_addc_u32 s11, s19, s34
	s_xor_b64 s[36:37], s[10:11], s[34:35]
	s_mul_hi_u32 s10, s36, s12
	s_mul_i32 s11, s36, s12
	v_readfirstlane_b32 s17, v1
	s_mul_hi_u32 s23, s36, s17
	s_add_u32 s11, s23, s11
	s_addc_u32 s10, 0, s10
	s_mul_hi_u32 s23, s37, s12
	s_mul_hi_u32 s33, s37, s17
	s_mul_i32 s17, s37, s17
	s_add_u32 s11, s11, s17
	s_addc_u32 s10, s10, s33
	s_addc_u32 s11, s23, 0
	s_mul_i32 s12, s37, s12
	s_add_u32 s12, s10, s12
	s_addc_u32 s17, 0, s11
	s_mul_i32 s10, s30, s17
	s_mul_hi_u32 s11, s30, s12
	s_add_i32 s10, s11, s10
	s_mul_i32 s11, s31, s12
	s_add_i32 s23, s10, s11
	s_sub_i32 s10, s37, s23
	s_mul_i32 s11, s30, s12
	v_mov_b32_e32 v1, s11
	v_sub_co_u32_e32 v1, vcc, s36, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s33, s10, s31
	v_subrev_co_u32_e64 v2, s[10:11], s30, v1
	s_cmp_lg_u64 s[10:11], 0
	s_subb_u32 s10, s33, 0
	s_cmp_ge_u32 s10, s31
	s_cselect_b32 s11, -1, 0
	v_readfirstlane_b32 s33, v2
	s_cmp_ge_u32 s33, s30
	s_cselect_b32 s33, -1, 0
	s_cmp_eq_u32 s10, s31
	s_cselect_b32 s10, s33, s11
	s_add_u32 s11, s12, 1
	s_addc_u32 s33, s17, 0
	s_add_u32 s36, s12, 2
	s_addc_u32 s38, s17, 0
	s_cmp_lg_u32 s10, 0
	s_cselect_b32 s10, s36, s11
	s_cselect_b32 s11, s38, s33
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s23, s37, s23
	s_cmp_ge_u32 s23, s31
	s_cselect_b32 s33, -1, 0
	v_readfirstlane_b32 s36, v1
	s_cmp_ge_u32 s36, s30
	s_cselect_b32 s30, -1, 0
	s_cmp_eq_u32 s23, s31
	s_cselect_b32 s23, s30, s33
	s_cmp_lg_u32 s23, 0
	s_cselect_b32 s11, s11, s17
	s_cselect_b32 s10, s10, s12
	s_xor_b64 s[26:27], s[34:35], s[26:27]
	s_xor_b64 s[10:11], s[10:11], s[26:27]
	s_sub_u32 s10, s10, s26
	s_subb_u32 s11, s11, s27
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB0_8
.LBB0_7:
	v_cvt_f32_u32_e32 v1, s24
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mov_b32 s11, 0
	s_sub_i32 s10, 0, s24
	v_readfirstlane_b32 s12, v1
	s_mul_i32 s10, s10, s12
	s_mul_hi_u32 s10, s12, s10
	s_add_i32 s12, s12, s10
	s_mul_hi_u32 s10, s18, s12
	s_add_i32 s12, s10, 1
	s_mul_i32 s17, s10, s24
	s_sub_i32 s17, s18, s17
	s_sub_i32 s23, s17, s24
	s_cmp_ge_u32 s17, s24
	s_cselect_b32 s17, s23, s17
	s_cselect_b32 s10, s12, s10
	s_add_i32 s12, s10, 1
	s_cmp_ge_u32 s17, s24
	s_cselect_b32 s10, s12, s10
.LBB0_8:
	s_mul_i32 s17, s20, s15
	v_cmp_gt_i32_e32 vcc, s17, v0
	s_and_saveexec_b64 s[26:27], vcc
	s_cbranch_execz .LBB0_11
	s_mul_i32 s12, s10, s25
	s_mul_hi_u32 s23, s10, s24
	s_add_i32 s12, s23, s12
	s_mul_i32 s11, s11, s24
	s_add_i32 s12, s12, s11
	s_mul_i32 s24, s10, s24
	s_sub_u32 s10, s18, s24
	s_subb_u32 s11, s19, s12
	s_ashr_i32 s18, s13, 31
	s_mul_hi_u32 s19, s13, s16
	s_mul_i32 s18, s18, s16
	s_add_i32 s27, s19, s18
	s_mul_i32 s26, s13, s16
	s_ashr_i32 s13, s14, 31
	s_mul_hi_u32 s19, s14, s16
	s_abs_i32 s18, s22
	v_cvt_f32_u32_e32 v1, s18
	s_mul_i32 s13, s13, s16
	s_add_i32 s29, s19, s13
	s_mul_i32 s28, s14, s16
	v_rcp_iflag_f32_e32 v1, v1
	s_ashr_i32 s13, s15, 31
	s_ashr_i32 s14, s20, 31
	s_ashr_i32 s16, s22, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_xor_b32 s25, s14, s16
	s_abs_i32 s19, s20
	s_sub_i32 s23, 0, s18
	v_readfirstlane_b32 s30, v1
	s_mul_i32 s23, s23, s30
	s_mul_hi_u32 s23, s30, s23
	s_add_i32 s23, s30, s23
	s_mul_hi_u32 s30, s19, s23
	s_mul_i32 s31, s30, s18
	s_sub_i32 s31, s19, s31
	s_add_i32 s33, s30, 1
	s_sub_i32 s34, s31, s18
	s_cmp_ge_u32 s31, s18
	s_cselect_b32 s30, s33, s30
	s_cselect_b32 s31, s34, s31
	s_add_i32 s33, s30, 1
	s_cmp_ge_u32 s31, s18
	s_cselect_b32 s30, s33, s30
	s_xor_b32 s30, s30, s25
	s_sub_i32 s25, s30, s25
	s_ashr_i32 s30, s25, 31
	s_mul_i32 s12, s12, s15
	s_mul_i32 s13, s24, s13
	s_mul_hi_u32 s31, s24, s15
	s_add_i32 s13, s31, s13
	s_add_i32 s33, s13, s12
	s_mul_i32 s34, s24, s15
	s_mul_i32 s12, s33, s22
	s_mul_i32 s13, s34, s16
	s_mul_hi_u32 s15, s34, s22
	s_add_i32 s13, s15, s13
	s_add_i32 s12, s13, s12
	s_mul_i32 s13, s34, s22
	s_mul_i32 s15, s13, s30
	s_mul_hi_u32 s24, s13, s25
	s_add_i32 s15, s24, s15
	s_mul_i32 s12, s12, s25
	s_add_i32 s31, s15, s12
	s_mul_i32 s30, s13, s25
	s_mul_i32 s15, s22, s21
	s_mul_i32 s24, s15, s25
	s_mul_i32 s12, s10, s16
	s_mul_hi_u32 s13, s10, s22
	s_add_i32 s12, s13, s12
	s_mul_i32 s13, s11, s22
	s_add_i32 s13, s12, s13
	s_mul_i32 s12, s10, s22
	s_mul_i32 s33, s33, s20
	s_mul_i32 s25, s34, s14
	s_mul_hi_u32 s35, s34, s20
	s_add_i32 s25, s35, s25
	s_add_i32 s35, s25, s33
	s_mul_i32 s34, s34, s20
	s_lshl_b64 s[26:27], s[26:27], 2
	s_add_u32 s2, s2, s26
	s_addc_u32 s3, s3, s27
	s_lshl_b64 s[26:27], s[28:29], 2
	s_add_u32 s4, s4, s26
	s_addc_u32 s5, s5, s27
	v_cvt_f32_u32_e32 v1, s19
	s_lshl_b64 s[26:27], s[30:31], 2
	s_add_u32 s6, s6, s26
	s_addc_u32 s7, s7, s27
	v_rcp_iflag_f32_e32 v1, v1
	s_lshl_b64 s[26:27], s[34:35], 2
	s_load_dword s25, s[0:1], 0x64
	s_add_u32 s0, s8, s26
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_addc_u32 s1, s9, s27
	s_waitcnt lgkmcnt(0)
	s_and_b32 s25, s25, 0xffff
	s_sub_i32 s8, 0, s19
	v_mul_lo_u32 v2, s8, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v2, v1, v2
	s_mul_i32 s26, s20, s21
	s_mov_b64 s[8:9], 0
.LBB0_10:
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[4:5], 2, v[0:1]
	v_lshl_add_u64 v[6:7], s[2:3], 0, v[4:5]
	global_load_dword v3, v[6:7], off
	v_lshl_add_u64 v[4:5], s[4:5], 0, v[4:5]
	global_load_dword v12, v[4:5], off
	v_sub_u32_e32 v4, 0, v0
	v_xor_b32_e32 v1, s14, v1
	v_max_i32_e32 v4, v0, v4
	v_mul_hi_u32 v5, v4, v2
	v_mul_lo_u32 v6, v5, s19
	v_add_u32_e32 v7, 1, v5
	v_sub_u32_e32 v4, v4, v6
	v_cmp_le_u32_e32 vcc, s19, v4
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_subrev_u32_e32 v6, s19, v4
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_add_u32_e32 v6, 1, v5
	v_cmp_le_u32_e32 vcc, s19, v4
	s_nop 1
	v_cndmask_b32_e32 v4, v5, v6, vcc
	v_xor_b32_e32 v4, v4, v1
	v_sub_u32_e32 v1, v4, v1
	v_mul_lo_u32 v5, v1, s20
	v_mul_lo_u32 v4, s24, v1
	v_mul_lo_u32 v6, v1, s26
	v_sub_u32_e32 v1, v0, v5
	v_ashrrev_i32_e32 v5, 31, v4
	v_ashrrev_i32_e32 v7, 31, v6
	v_add_u32_e32 v0, s25, v0
	v_ashrrev_i32_e32 v9, 31, v1
	v_sub_u32_e32 v10, 0, v1
	v_mul_lo_u32 v8, v1, s21
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[6:7]
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[0:1]
	v_cmp_le_i32_e32 vcc, s17, v0
	v_xor_b32_e32 v11, s16, v9
	v_max_i32_e32 v10, v1, v10
	v_ashrrev_i32_e32 v9, 31, v8
	s_or_b64 s[8:9], vcc, s[8:9]
	v_mul_hi_u32 v13, v10, s23
	v_lshl_add_u64 v[6:7], v[8:9], 2, v[6:7]
	v_mul_lo_u32 v8, v13, s18
	v_add_u32_e32 v9, 1, v13
	v_lshl_add_u64 v[6:7], s[10:11], 2, v[6:7]
	v_sub_u32_e32 v8, v10, v8
	v_cmp_le_u32_e32 vcc, s18, v8
	s_nop 1
	v_cndmask_b32_e32 v9, v13, v9, vcc
	v_subrev_u32_e32 v10, s18, v8
	v_cndmask_b32_e32 v8, v8, v10, vcc
	v_add_u32_e32 v10, 1, v9
	v_cmp_le_u32_e32 vcc, s18, v8
	s_nop 1
	v_cndmask_b32_e32 v8, v9, v10, vcc
	v_xor_b32_e32 v8, v8, v11
	v_sub_u32_e32 v8, v8, v11
	v_mul_lo_u32 v9, v8, s22
	v_mul_lo_u32 v8, s15, v8
	v_sub_u32_e32 v10, v1, v9
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v11, 31, v10
	v_lshl_add_u64 v[4:5], v[8:9], 2, v[4:5]
	v_lshl_add_u64 v[4:5], s[12:13], 2, v[4:5]
	v_lshl_add_u64 v[4:5], v[10:11], 2, v[4:5]
	s_waitcnt vmcnt(1)
	global_store_dword v[4:5], v3, off
	s_waitcnt vmcnt(1)
	global_store_dword v[6:7], v12, off
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz .LBB0_10
.LBB0_11:
	s_endpgm
.LBB0_12:
	s_mov_b64 vcc, 0
	s_branch .LBB0_7
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 39
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
	.section	.text._ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_,"axG",@progbits,_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_,comdat
.Lfunc_end0:
	.size	_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_, .Lfunc_end0-_ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_

	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.num_vgpr, 14
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.num_agpr, 0
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.numbered_sgpr, 39
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.private_seg_size, 0
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.uses_vcc, 1
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.uses_flat_scratch, 0
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.has_dyn_sized_stack, 0
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.has_recursion, 0
	.set _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_700785f124c8bbee,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_700785f124c8bbee
__hip_cuid_700785f124c8bbee:
	.byte	0
	.size	__hip_cuid_700785f124c8bbee, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_700785f124c8bbee
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
      - .actual_access:  write_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
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
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     global_buffer
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_
    .private_segment_fixed_size: 0
    .sgpr_count:     45
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter24reshape_and_cache_kernelIffLN4vllm18Fp8KVCacheDataTypeE0ELb0EEEvPKT_S5_PT0_S7_PKvNS_14SlotIndexWidthEiiiiiiPKfSC_.kd
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
