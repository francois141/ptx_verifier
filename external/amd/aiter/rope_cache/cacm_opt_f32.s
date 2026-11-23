	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf,"axG",@progbits,_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf,comdat
	.protected	_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf
	.globl	_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf
	.p2align	8
	.type	_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf,@function
_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mov_b32 s17, 0
	s_lshl_b64 s[18:19], s[16:17], 3
	s_add_u32 s8, s8, s18
	s_addc_u32 s9, s9, s19
	s_load_dwordx2 s[24:25], s[8:9], 0x0
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_i64_e64 s[8:9], s[24:25], 0
	s_and_b64 vcc, exec, s[8:9]
	s_cbranch_vccnz .LBB0_14
	s_load_dword s26, s[0:1], 0x38
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s27, s26, 31
	s_or_b64 s[8:9], s[24:25], s[26:27]
	s_mov_b32 s8, s17
	s_cmp_lg_u64 s[8:9], 0
	s_cbranch_scc0 .LBB0_15
	s_ashr_i32 s18, s27, 31
	s_mov_b32 s19, s18
	s_add_u32 s8, s26, s18
	s_addc_u32 s9, s27, s18
	s_xor_b64 s[22:23], s[8:9], s[18:19]
	v_cvt_f32_u32_e32 v1, s22
	v_cvt_f32_u32_e32 v2, s23
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s8, 0, s22
	s_subb_u32 s9, 0, s23
	v_readfirstlane_b32 s17, v2
	v_readfirstlane_b32 s28, v1
	s_mul_i32 s29, s8, s17
	s_mul_i32 s30, s9, s28
	s_mul_hi_u32 s31, s8, s28
	s_add_i32 s29, s31, s29
	s_add_i32 s29, s29, s30
	s_mul_hi_u32 s30, s28, s29
	s_mul_i32 s31, s28, s29
	s_mul_i32 s33, s8, s28
	s_mul_hi_u32 s28, s28, s33
	s_add_u32 s28, s28, s31
	s_addc_u32 s30, 0, s30
	s_mul_hi_u32 s31, s17, s29
	s_mul_hi_u32 s34, s17, s33
	s_mul_i32 s33, s17, s33
	s_add_u32 s28, s28, s33
	s_addc_u32 s28, s30, s34
	s_addc_u32 s30, s31, 0
	s_mul_i32 s29, s17, s29
	s_add_u32 s28, s28, s29
	s_addc_u32 s29, 0, s30
	v_add_co_u32_e32 v1, vcc, s28, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s29
	s_mul_i32 s28, s8, s17
	v_readfirstlane_b32 s29, v1
	s_mul_hi_u32 s30, s8, s29
	s_add_i32 s28, s30, s28
	s_mul_i32 s9, s9, s29
	s_add_i32 s28, s28, s9
	s_mul_hi_u32 s9, s17, s28
	s_mul_i32 s8, s8, s29
	s_mul_hi_u32 s30, s17, s8
	s_mul_i32 s31, s17, s8
	s_mul_hi_u32 s33, s29, s28
	s_mul_i32 s34, s29, s28
	s_mul_hi_u32 s8, s29, s8
	s_add_u32 s8, s8, s34
	s_addc_u32 s29, 0, s33
	s_add_u32 s8, s8, s31
	s_addc_u32 s8, s29, s30
	s_addc_u32 s9, s9, 0
	s_mul_i32 s28, s17, s28
	s_add_u32 s8, s8, s28
	s_addc_u32 s9, 0, s9
	v_add_co_u32_e32 v1, vcc, s8, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s9
	s_ashr_i32 s28, s25, 31
	s_mov_b32 s29, s28
	s_add_u32 s8, s24, s28
	s_addc_u32 s9, s25, s28
	s_xor_b64 s[30:31], s[8:9], s[28:29]
	s_mul_hi_u32 s8, s30, s17
	s_mul_i32 s9, s30, s17
	v_readfirstlane_b32 s33, v1
	s_mul_hi_u32 s34, s30, s33
	s_add_u32 s9, s34, s9
	s_addc_u32 s8, 0, s8
	s_mul_hi_u32 s34, s31, s17
	s_mul_hi_u32 s35, s31, s33
	s_mul_i32 s33, s31, s33
	s_add_u32 s9, s9, s33
	s_addc_u32 s8, s8, s35
	s_addc_u32 s9, s34, 0
	s_mul_i32 s17, s31, s17
	s_add_u32 s17, s8, s17
	s_addc_u32 s33, 0, s9
	s_mul_i32 s8, s22, s33
	s_mul_hi_u32 s9, s22, s17
	s_add_i32 s8, s9, s8
	s_mul_i32 s9, s23, s17
	s_add_i32 s34, s8, s9
	s_sub_i32 s8, s31, s34
	s_mul_i32 s9, s22, s17
	v_mov_b32_e32 v1, s9
	v_sub_co_u32_e32 v1, vcc, s30, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s30, s8, s23
	v_subrev_co_u32_e64 v2, s[8:9], s22, v1
	s_cmp_lg_u64 s[8:9], 0
	s_subb_u32 s8, s30, 0
	s_cmp_ge_u32 s8, s23
	s_cselect_b32 s9, -1, 0
	v_readfirstlane_b32 s30, v2
	s_cmp_ge_u32 s30, s22
	s_cselect_b32 s30, -1, 0
	s_cmp_eq_u32 s8, s23
	s_cselect_b32 s8, s30, s9
	s_add_u32 s9, s17, 1
	s_addc_u32 s30, s33, 0
	s_add_u32 s35, s17, 2
	s_addc_u32 s36, s33, 0
	s_cmp_lg_u32 s8, 0
	s_cselect_b32 s8, s35, s9
	s_cselect_b32 s9, s36, s30
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s30, s31, s34
	s_cmp_ge_u32 s30, s23
	s_cselect_b32 s31, -1, 0
	v_readfirstlane_b32 s34, v1
	s_cmp_ge_u32 s34, s22
	s_cselect_b32 s22, -1, 0
	s_cmp_eq_u32 s30, s23
	s_cselect_b32 s22, s22, s31
	s_cmp_lg_u32 s22, 0
	s_cselect_b32 s9, s9, s33
	s_cselect_b32 s8, s8, s17
	s_xor_b64 s[18:19], s[28:29], s[18:19]
	s_xor_b64 s[8:9], s[8:9], s[18:19]
	s_sub_u32 s8, s8, s18
	s_subb_u32 s9, s9, s19
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB0_4
.LBB0_3:
	v_cvt_f32_u32_e32 v1, s26
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mov_b32 s9, 0
	s_sub_i32 s8, 0, s26
	v_readfirstlane_b32 s17, v1
	s_mul_i32 s8, s8, s17
	s_mul_hi_u32 s8, s17, s8
	s_add_i32 s17, s17, s8
	s_mul_hi_u32 s8, s24, s17
	s_add_i32 s17, s8, 1
	s_mul_i32 s18, s8, s26
	s_sub_i32 s18, s24, s18
	s_sub_i32 s19, s18, s26
	s_cmp_ge_u32 s18, s26
	s_cselect_b32 s18, s19, s18
	s_cselect_b32 s8, s17, s8
	s_add_i32 s17, s8, 1
	s_cmp_ge_u32 s18, s26
	s_cselect_b32 s8, s17, s8
.LBB0_4:
	s_ashr_i32 s17, s12, 31
	s_mul_hi_u32 s18, s12, s16
	s_mul_i32 s17, s17, s16
	s_add_i32 s19, s18, s17
	s_mul_i32 s18, s12, s16
	s_lshl_b64 s[18:19], s[18:19], 2
	s_add_u32 s20, s2, s18
	s_addc_u32 s2, s3, s19
	s_lshl_b32 s22, s14, 2
	s_and_b32 s21, s2, 0xffff
	s_mov_b32 s23, 0x20000
	v_lshlrev_b32_e32 v14, 4, v0
	buffer_load_dwordx4 v[2:5], v14, s[20:23], 0 offen
	s_lshl_b32 s18, s15, 2
	s_add_i32 s2, s15, 3
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 30
	s_add_i32 s2, s2, s3
	s_ashr_i32 s2, s2, 2
	s_mov_b32 s3, 0
	v_cmp_gt_u32_e32 vcc, s2, v0
	s_and_saveexec_b64 s[28:29], vcc
	s_cbranch_execz .LBB0_6
	s_ashr_i32 s2, s13, 31
	s_mul_hi_u32 s12, s13, s16
	s_mul_i32 s2, s2, s16
	s_add_i32 s17, s12, s2
	s_mul_i32 s16, s13, s16
	s_lshl_b64 s[12:13], s[16:17], 2
	s_add_u32 s16, s4, s12
	s_addc_u32 s2, s5, s13
	s_and_b32 s17, s2, 0xffff
	s_mov_b32 s19, s23
	buffer_load_dwordx4 v[6:9], v14, s[16:19], 0 offen
.LBB0_6:
	s_or_b64 exec, exec, s[28:29]
	s_mul_i32 s2, s8, s27
	s_mul_hi_u32 s4, s8, s26
	s_add_i32 s2, s4, s2
	s_mul_i32 s4, s9, s26
	s_add_i32 s2, s2, s4
	s_mul_i32 s4, s8, s26
	s_sub_u32 s12, s24, s4
	s_subb_u32 s2, s25, s2
	s_ashr_i32 s4, s10, 31
	s_mul_hi_u32 s5, s8, s10
	s_mul_i32 s4, s8, s4
	s_add_i32 s4, s5, s4
	s_mul_i32 s5, s9, s10
	s_add_i32 s5, s4, s5
	s_mul_i32 s4, s8, s10
	s_ashr_i32 s8, s11, 31
	s_mul_i32 s8, s12, s8
	s_mul_hi_u32 s9, s12, s11
	s_load_dword s10, s[0:1], 0x54
	s_add_i32 s0, s9, s8
	s_mul_i32 s2, s2, s11
	s_add_i32 s1, s0, s2
	s_mul_i32 s0, s12, s11
	s_waitcnt lgkmcnt(0)
	s_and_b32 s2, s10, 0xffff
	s_add_i32 s8, s14, 3
	s_ashr_i32 s9, s8, 31
	s_lshr_b32 s9, s9, 30
	s_add_i32 s8, s8, s9
	s_ashr_i32 s8, s8, 2
	s_lshl_b64 s[4:5], s[4:5], 2
	s_add_u32 s4, s6, s4
	s_addc_u32 s5, s7, s5
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s4, s4, s0
	s_addc_u32 s17, s5, s1
	s_and_b32 s5, s17, 0xffff
	v_add_u32_e32 v0, s2, v0
	v_mov_b32_e32 v1, 0
	s_ashr_i32 s9, s8, 31
	v_cmp_gt_u32_e64 s[0:1], s8, v0
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_10
	s_lshl_b32 s15, s2, 4
	s_mov_b64 s[12:13], 0
	s_mov_b32 s6, s22
	s_mov_b32 s7, s23
	v_mov_b32_e32 v15, v14
.LBB0_8:
	v_add_u32_e32 v16, s15, v15
	buffer_load_dwordx4 v[10:13], v16, s[20:23], 0 offen
	s_waitcnt vmcnt(1)
	buffer_store_dwordx4 v[2:5], v15, s[4:7], 0 offen
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[2:3]
	v_cmp_le_u64_e64 s[0:1], s[8:9], v[0:1]
	v_mov_b32_e32 v15, v16
	s_or_b64 s[12:13], s[0:1], s[12:13]
	s_waitcnt vmcnt(1)
	v_mov_b64_e32 v[2:3], v[10:11]
	v_mov_b64_e32 v[4:5], v[12:13]
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB0_8
	s_or_b64 exec, exec, s[12:13]
	v_mov_b64_e32 v[2:3], v[10:11]
	v_mov_b64_e32 v[4:5], v[12:13]
.LBB0_10:
	s_or_b64 exec, exec, s[10:11]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_12
	s_ashr_i32 s15, s14, 31
	s_lshl_b64 s[6:7], s[14:15], 2
	s_add_u32 s16, s4, s6
	s_addc_u32 s6, s17, s7
	s_and_b32 s17, s6, 0xffff
	s_mov_b32 s19, 0x20000
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[6:9], v14, s[16:19], 0 offen
.LBB0_12:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v6, s3
	v_subrev_co_u32_e32 v0, vcc, s2, v0
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v1, v6, vcc
	v_cmp_gt_u64_e32 vcc, s[8:9], v[0:1]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_14
	v_lshlrev_b32_e32 v0, 4, v0
	s_mov_b32 s6, s22
	s_mov_b32 s7, s23
	buffer_store_dwordx4 v[2:5], v0, s[4:7], 0 offen
.LBB0_14:
	s_endpgm
.LBB0_15:
	s_mov_b64 vcc, 0
	s_branch .LBB0_3
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
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
		.amdhsa_next_free_vgpr 17
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
	.section	.text._ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf,"axG",@progbits,_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf,comdat
.Lfunc_end0:
	.size	_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf, .Lfunc_end0-_ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf

	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.num_vgpr, 17
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.num_agpr, 0
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.numbered_sgpr, 37
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.private_seg_size, 0
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.uses_vcc, 1
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.uses_flat_scratch, 0
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.has_dyn_sized_stack, 0
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.has_recursion, 0
	.set _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_d195582ab2073f72,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_d195582ab2073f72
__hip_cuid_d195582ab2073f72:
	.byte	0
	.size	__hip_cuid_d195582ab2073f72, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_d195582ab2073f72
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
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
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
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         76
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         84
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         86
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         88
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         90
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         92
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         94
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         136
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf
    .private_segment_fixed_size: 0
    .sgpr_count:     43
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter31concat_and_cache_mla_opt_kernelIffLN4vllm18Fp8KVCacheDataTypeE0EEEvPKT_S5_PT0_PKxiiiiiiiPKf.kd
    .uses_dynamic_stack: false
    .vgpr_count:     17
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
