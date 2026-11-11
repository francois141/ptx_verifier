	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN7ck_tileL11flush_cacheEv,"axG",@progbits,_ZN7ck_tileL11flush_cacheEv,comdat
	.globl	_ZN7ck_tileL11flush_cacheEv
	.p2align	8
	.type	_ZN7ck_tileL11flush_cacheEv,@function
_ZN7ck_tileL11flush_cacheEv:
	;;#ASMSTART
	s_icache_inv 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	s_nop 0 
	
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN7ck_tileL11flush_cacheEv
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 0
		.amdhsa_user_sgpr_count 0
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 0
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
		.amdhsa_next_free_vgpr 1
		.amdhsa_next_free_sgpr 0
		.amdhsa_accum_offset 4
		.amdhsa_reserve_vcc 0
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
	.section	.text._ZN7ck_tileL11flush_cacheEv,"axG",@progbits,_ZN7ck_tileL11flush_cacheEv,comdat
.Lfunc_end0:
	.size	_ZN7ck_tileL11flush_cacheEv, .Lfunc_end0-_ZN7ck_tileL11flush_cacheEv

	.set _ZN7ck_tileL11flush_cacheEv.num_vgpr, 0
	.set _ZN7ck_tileL11flush_cacheEv.num_agpr, 0
	.set _ZN7ck_tileL11flush_cacheEv.numbered_sgpr, 0
	.set _ZN7ck_tileL11flush_cacheEv.private_seg_size, 0
	.set _ZN7ck_tileL11flush_cacheEv.uses_vcc, 0
	.set _ZN7ck_tileL11flush_cacheEv.uses_flat_scratch, 0
	.set _ZN7ck_tileL11flush_cacheEv.has_dyn_sized_stack, 0
	.set _ZN7ck_tileL11flush_cacheEv.has_recursion, 0
	.set _ZN7ck_tileL11flush_cacheEv.has_indirect_call, 0
	.section	.text._ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_,"axG",@progbits,_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_,comdat
	.protected	_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_
	.globl	_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_
	.p2align	8
	.type	_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_,@function
_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_:
	s_load_dwordx4 s[40:43], s[0:1], 0x28
	s_load_dwordx8 s[8:15], s[0:1], 0x3c
	s_mov_b32 s6, s3
	s_abs_i32 s26, s6
	s_load_dwordx2 s[24:25], s[0:1], 0x20
	s_load_dwordx8 s[16:23], s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s43, 63
	s_ashr_i32 s5, s3, 31
	s_lshr_b32 s5, s5, 26
	s_add_i32 s3, s3, s5
	s_ashr_i32 s3, s3, 6
	s_abs_i32 s5, s3
	v_cvt_f32_u32_e32 v1, s5
	s_sub_i32 s27, 0, s5
	s_xor_b32 s7, s6, s3
	s_ashr_i32 s7, s7, 31
	v_rcp_iflag_f32_e32 v1, v1
	s_load_dwordx2 s[34:35], s[0:1], 0x5c
	s_load_dwordx4 s[28:31], s[0:1], 0x80
	s_mov_b32 s44, s9
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s33, v1
	s_mul_i32 s27, s27, s33
	s_mul_hi_u32 s27, s33, s27
	s_add_i32 s33, s33, s27
	s_mul_hi_u32 s27, s26, s33
	s_mul_i32 s33, s27, s5
	s_sub_i32 s26, s26, s33
	s_add_i32 s33, s27, 1
	s_sub_i32 s36, s26, s5
	s_cmp_ge_u32 s26, s5
	s_cselect_b32 s27, s33, s27
	s_cselect_b32 s26, s36, s26
	s_add_i32 s33, s27, 1
	s_cmp_ge_u32 s26, s5
	s_cselect_b32 s5, s33, s27
	s_xor_b32 s5, s5, s7
	s_sub_i32 s33, s5, s7
	s_cmp_eq_u64 s[24:25], 0
	s_mul_i32 s7, s33, s3
	s_cbranch_scc1 .LBB1_8
	s_ashr_i32 s3, s2, 31
	s_lshl_b64 s[26:27], s[2:3], 2
	v_mov_b32_e32 v1, 0x6f800000
	s_add_u32 s24, s24, s26
	v_mov_b32_e32 v2, 0x2f800000
	v_cmp_gt_f32_e64 vcc, |s9|, v1
	s_addc_u32 s25, s25, s27
	s_load_dword s3, s[24:25], 0x0
	v_cndmask_b32_e32 v1, 1.0, v2, vcc
	v_mul_f32_e32 v2, s9, v1
	v_rcp_f32_e32 v2, v2
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v2, s3, v2
	v_mul_f32_e32 v18, v1, v2
	s_ashr_i32 s5, s4, 31
	s_cmp_eq_u64 s[28:29], 0
	s_cbranch_scc1 .LBB1_3
.LBB1_2:
	s_lshl_b64 s[24:25], s[4:5], 2
	s_add_u32 s24, s28, s24
	s_addc_u32 s25, s29, s25
	s_load_dwordx2 s[24:25], s[24:25], 0x0
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s40, s25, s24
.LBB1_3:
	s_load_dwordx4 s[24:27], s[0:1], 0x6c
	s_cmp_eq_u64 s[30:31], 0
	s_cbranch_scc1 .LBB1_5
	s_lshl_b64 s[0:1], s[4:5], 2
	s_add_u32 s0, s30, s0
	s_addc_u32 s1, s31, s1
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s41, s1, s0
.LBB1_5:
	s_add_i32 s1, s43, -1
	s_lshl_b32 s3, s33, 6
	s_add_i32 s0, s40, -1
	s_ashr_i32 s5, s1, 31
	s_add_u32 s1, s1, 1
	s_addc_u32 s5, s5, 0
	s_add_i32 s33, s41, -1
	s_mul_i32 s28, s33, s12
	s_mul_hi_i32 s29, s33, s12
	s_add_u32 s28, s28, s1
	s_addc_u32 s29, s29, s5
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[28:29], v[2:3]
	s_and_b64 s[30:31], vcc, exec
	s_cselect_b32 s43, s28, 0x7fffffff
	s_add_i32 s28, s42, -1
	s_ashr_i32 s30, s28, 31
	s_add_u32 s36, s28, 1
	s_mul_hi_i32 s29, s33, s11
	s_mul_i32 s33, s33, s11
	s_addc_u32 s37, s30, 0
	s_add_u32 s28, s33, s36
	s_addc_u32 s29, s29, s37
	v_cmp_lt_i64_e32 vcc, s[28:29], v[2:3]
	s_and_b64 s[30:31], vcc, exec
	s_cselect_b32 s33, s28, 0x7fffffff
	s_mul_i32 s28, s0, s10
	s_mul_hi_i32 s29, s0, s10
	s_add_u32 s28, s28, s36
	s_addc_u32 s29, s29, s37
	v_cmp_lt_i64_e32 vcc, s[28:29], v[2:3]
	s_and_b64 s[30:31], vcc, exec
	s_cselect_b32 s30, s28, 0x7fffffff
	s_abs_i32 s28, s8
	v_cvt_f32_u32_e32 v1, s28
	s_sub_i32 s31, 0, s28
	s_abs_i32 s29, s2
	s_xor_b32 s8, s2, s8
	v_rcp_iflag_f32_e32 v1, v1
	s_ashr_i32 s8, s8, 31
	v_cmp_lt_i32_e32 vcc, -1, v18
	s_mov_b32 s40, 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mov_b32_e32 v22, 0
	s_mov_b32 s42, s40
	s_mov_b32 s45, s9
	v_readfirstlane_b32 s36, v1
	s_mul_i32 s31, s31, s36
	s_mul_hi_u32 s31, s36, s31
	s_add_i32 s36, s36, s31
	s_mul_hi_u32 s31, s29, s36
	s_mul_i32 s36, s31, s28
	s_sub_i32 s29, s29, s36
	s_add_i32 s36, s31, 1
	s_sub_i32 s37, s29, s28
	s_cmp_ge_u32 s29, s28
	s_cselect_b32 s31, s36, s31
	s_cselect_b32 s29, s37, s29
	s_add_i32 s36, s31, 1
	s_cmp_ge_u32 s29, s28
	s_cselect_b32 s28, s36, s31
	s_xor_b32 s28, s28, s8
	s_sub_i32 s8, s28, s8
	s_mul_hi_i32 s29, s8, s34
	s_mul_i32 s28, s8, s34
	s_lshl_b64 s[28:29], s[28:29], 2
	s_add_u32 s28, s20, s28
	s_addc_u32 s29, s21, s29
	s_waitcnt lgkmcnt(0)
	s_mul_hi_i32 s21, s26, s4
	s_mul_i32 s20, s26, s4
	s_lshl_b64 s[20:21], s[20:21], 2
	s_add_u32 s28, s28, s20
	s_addc_u32 s29, s29, s21
	s_mul_hi_i32 s21, s8, s15
	s_mul_i32 s20, s8, s15
	s_lshl_b64 s[20:21], s[20:21], 2
	s_add_u32 s8, s18, s20
	s_addc_u32 s15, s19, s21
	s_mul_hi_i32 s19, s25, s4
	s_mul_i32 s18, s25, s4
	s_lshl_b64 s[18:19], s[18:19], 2
	s_add_u32 s36, s8, s18
	s_addc_u32 s37, s15, s19
	s_mul_hi_i32 s15, s14, s2
	s_mul_i32 s14, s14, s2
	s_lshl_b64 s[14:15], s[14:15], 2
	s_add_u32 s8, s16, s14
	s_addc_u32 s17, s17, s15
	s_mul_hi_i32 s15, s24, s4
	s_mul_i32 s14, s24, s4
	s_lshl_b64 s[14:15], s[14:15], 2
	s_add_u32 s16, s8, s14
	v_readfirstlane_b32 s20, v0
	s_addc_u32 s17, s17, s15
	v_mbcnt_lo_u32_b32 v1, -1, 0
	s_lshr_b32 s8, s20, 2
	v_mbcnt_hi_u32_b32 v20, -1, v1
	s_and_b32 s8, s8, 0x3ffffff0
	v_and_b32_e32 v1, 15, v20
	s_add_i32 s8, s8, s3
	v_lshrrev_b32_e32 v21, 2, v20
	v_or_b32_e32 v2, s8, v1
	v_and_b32_e32 v67, 28, v21
	v_mul_lo_u32 v2, v2, s10
	v_add_lshl_u32 v14, v2, v67, 2
	s_lshl_b32 s18, s30, 2
	s_mov_b32 s19, 0x20000
	buffer_load_dwordx4 v[2:5], v14, s[16:19], 0 offen
	buffer_load_dwordx4 v[6:9], v14, s[16:19], 0 offen offset:64
	buffer_load_dwordx4 v[10:13], v14, s[16:19], 0 offen offset:128
	buffer_load_dwordx4 v[14:17], v14, s[16:19], 0 offen offset:192
	s_mov_b32 s8, 0x7f800000
	v_cmp_neq_f32_e64 s[14:15], |v18|, s8
	s_mov_b32 s16, 0x652b82fe
	s_add_i32 s10, s41, 63
	v_cvt_f64_f32_e32 v[18:19], v18
	s_mov_b32 s17, 0x3ff71547
	s_or_b64 vcc, s[14:15], vcc
	s_ashr_i32 s14, s10, 31
	v_mul_f64 v[18:19], v[18:19], s[16:17]
	s_lshr_b32 s14, s14, 26
	v_cvt_f32_f64_e32 v18, v[18:19]
	v_mov_b32_e32 v19, 0xff800000
	s_add_i32 s10, s10, s14
	v_lshrrev_b32_e32 v25, 4, v20
	v_cndmask_b32_e32 v85, v19, v18, vcc
	s_ashr_i32 s15, s10, 6
	s_lshr_b32 s10, s20, 3
	v_lshrrev_b32_e32 v69, 3, v20
	v_lshlrev_b32_e32 v19, 1, v20
	v_lshlrev_b32_e32 v23, 2, v20
	v_mul_u32_u24_e32 v26, 0x104, v25
	v_lshlrev_b32_e32 v27, 2, v1
	s_and_b32 s17, s10, 0x1ffffff8
	v_and_b32_e32 v18, 12, v69
	v_and_b32_e32 v19, 2, v19
	v_and_b32_e32 v71, 28, v23
	v_and_b32_e32 v24, 7, v20
	v_add_lshl_u32 v72, v26, v27, 2
	v_add_u32_e32 v74, 0x80, v23
	v_add_u32_e32 v75, 64, v23
	v_bfe_u32 v23, v20, 3, 2
	v_lshlrev_b32_e32 v26, 3, v20
	v_lshlrev_b32_e32 v20, 5, v20
	v_or_b32_e32 v70, v19, v18
	v_and_b32_e32 v20, 0xc0, v20
	s_movk_i32 s16, 0x110
	v_add_u32_e32 v18, s17, v18
	v_mad_u32_u24 v20, v23, s16, v20
	v_or_b32_e32 v18, v18, v19
	v_add_u32_e32 v21, 16, v21
	v_lshl_or_b32 v66, v19, 2, v20
	v_add_u32_e32 v19, 33, v18
	v_lshrrev_b32_e32 v21, 2, v21
	v_mul_lo_u32 v19, s12, v19
	v_mov_b32_e32 v20, 0x80
	v_sub_u32_e32 v21, v21, v25
	s_movk_i32 s14, 0x410
	v_mul_u32_u24_e32 v25, 0x440, v25
	v_lshlrev_b32_e32 v78, 2, v19
	v_mul_lo_u32 v19, s12, v18
	v_lshl_add_u32 v18, v18, 2, v20
	s_mov_b32 s41, s40
	s_lshl_b32 s10, s11, 7
	s_lshl_b32 s30, s43, 2
	v_mad_i32_i24 v73, v21, s14, v72
	v_lshl_add_u32 v76, v1, 4, v25
	v_mul_i32_i24_e32 v25, 0x440, v21
	v_add_lshl_u32 v80, v19, s12, 2
	v_mul_lo_u32 v81, s12, v18
	v_lshlrev_b32_e32 v82, 2, v19
	s_mov_b32 s43, s40
	v_mov_b64_e32 v[18:19], s[40:41]
	s_mov_b32 s8, 0xff800000
	v_cndmask_b32_e64 v68, 0, 1.0, vcc
	s_lshl_b32 s38, s33, 2
	s_mov_b32 s39, s19
	s_mov_b32 s31, s19
	s_movk_i32 s14, 0x440
	s_max_i32 s15, s15, 1
	v_mul_u32_u24_e32 v77, 0x410, v24
	s_add_i32 s16, s10, 0x80
	v_and_b32_e32 v79, 0xf0, v26
	s_lshl_b32 s17, s12, 8
	v_mov_b64_e32 v[20:21], s[42:43]
	v_add_u32_e32 v83, v76, v25
	v_mov_b32_e32 v84, v69
	v_mov_b32_e32 v23, v22
	v_mov_b32_e32 v24, v22
	v_mov_b32_e32 v25, v22
	v_mov_b32_e32 v26, v22
	v_mov_b32_e32 v27, v22
	v_mov_b32_e32 v28, v22
	v_mov_b32_e32 v29, v22
	v_mov_b32_e32 v30, v22
	v_mov_b32_e32 v31, v22
	v_mov_b32_e32 v32, v22
	v_mov_b32_e32 v33, v22
	v_mov_b32_e32 v34, v22
	v_mov_b32_e32 v35, v22
	v_mov_b32_e32 v36, v22
	v_mov_b32_e32 v37, v22
.LBB1_6:
	v_readfirstlane_b32 s12, v0
	s_lshr_b32 s18, s12, 3
	s_and_b32 s12, s18, 0x1ffffff8
	v_add_u32_e32 v46, s12, v84
	v_mul_lo_u32 v46, v46, s11
	s_and_b32 s18, s18, 0xffffff8
	v_add_lshl_u32 v54, v46, v71, 2
	v_add_u32_e32 v38, v82, v79
	v_add_u32_e32 v39, v80, v79
	v_add_u32_e32 v47, s18, v69
	v_add_u32_e32 v55, s10, v54
	v_add_u32_e32 v58, s16, v54
	buffer_load_dwordx4 v[42:45], v38, s[28:31], 0 offen
	buffer_load_dwordx4 v[38:41], v39, s[28:31], 0 offen
	v_lshl_add_u32 v106, v47, 4, v77
	buffer_load_dwordx4 v[46:49], v54, s[36:39], 0 offen
	buffer_load_dwordx4 v[50:53], v54, s[36:39], 0 offen offset:128
	buffer_load_dwordx4 v[54:57], v55, s[36:39], 0 offen
	buffer_load_dwordx4 v[58:61], v58, s[36:39], 0 offen
	s_add_i32 s15, s15, -1
	v_add_u32_e32 v84, 64, v84
	s_cmp_lg_u32 s15, 0
	s_waitcnt vmcnt(3)
	ds_write_b128 v106, v[46:49]
	s_waitcnt vmcnt(1)
	ds_write_b128 v106, v[54:57] offset:512
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[46:49], v72
	ds_read_b128 v[54:57], v72 offset:256
	ds_read_b128 v[90:93], v72 offset:512
	ds_read_b128 v[94:97], v72 offset:768
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 v[62:65], v46, v2, v[18:21]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 v[86:89], v54, v2, v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[98:101], v90, v2, v[18:21]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[102:105], v94, v2, v[18:21]
	v_mfma_f32_16x16x4_f32 v[62:65], v47, v3, v[62:65]
	v_mfma_f32_16x16x4_f32 v[86:89], v55, v3, v[86:89]
	v_mfma_f32_16x16x4_f32 v[98:101], v91, v3, v[98:101]
	v_mfma_f32_16x16x4_f32 v[102:105], v95, v3, v[102:105]
	v_mfma_f32_16x16x4_f32 v[62:65], v48, v4, v[62:65]
	v_mfma_f32_16x16x4_f32 v[86:89], v56, v4, v[86:89]
	v_mfma_f32_16x16x4_f32 v[98:101], v92, v4, v[98:101]
	v_mfma_f32_16x16x4_f32 v[102:105], v96, v4, v[102:105]
	v_mfma_f32_16x16x4_f32 v[46:49], v49, v5, v[62:65]
	v_mfma_f32_16x16x4_f32 v[54:57], v57, v5, v[86:89]
	v_mfma_f32_16x16x4_f32 v[62:65], v93, v5, v[98:101]
	v_mfma_f32_16x16x4_f32 v[86:89], v97, v5, v[102:105]
	ds_read_b128 v[90:93], v73
	ds_read_b128 v[94:97], v73 offset:256
	s_nop 2
	ds_read_b128 v[98:101], v73 offset:512
	ds_read_b128 v[102:105], v73 offset:768
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b128 v106, v[50:53]
	s_waitcnt vmcnt(0)
	ds_write_b128 v106, v[58:61] offset:512
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 v[46:49], v90, v6, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v94, v6, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v98, v6, v[62:65]
	v_mfma_f32_16x16x4_f32 v[86:89], v102, v6, v[86:89]
	v_mfma_f32_16x16x4_f32 v[46:49], v91, v7, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v95, v7, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v99, v7, v[62:65]
	v_mfma_f32_16x16x4_f32 v[86:89], v103, v7, v[86:89]
	v_mfma_f32_16x16x4_f32 v[46:49], v92, v8, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v96, v8, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v100, v8, v[62:65]
	v_mfma_f32_16x16x4_f32 v[86:89], v104, v8, v[86:89]
	v_mfma_f32_16x16x4_f32 v[46:49], v93, v9, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v97, v9, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v101, v9, v[62:65]
	v_mfma_f32_16x16x4_f32 v[50:53], v105, v9, v[86:89]
	ds_read_b128 v[58:61], v72
	s_nop 4
	ds_read_b128 v[86:89], v72 offset:256
	ds_read_b128 v[90:93], v72 offset:512
	ds_read_b128 v[94:97], v72 offset:768
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 v[46:49], v58, v10, v[46:49]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 v[54:57], v86, v10, v[54:57]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[62:65], v90, v10, v[62:65]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[50:53], v94, v10, v[50:53]
	v_mfma_f32_16x16x4_f32 v[46:49], v59, v11, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v87, v11, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v91, v11, v[62:65]
	v_mfma_f32_16x16x4_f32 v[50:53], v95, v11, v[50:53]
	v_mfma_f32_16x16x4_f32 v[46:49], v60, v12, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v88, v12, v[54:57]
	v_mfma_f32_16x16x4_f32 v[62:65], v92, v12, v[62:65]
	v_mfma_f32_16x16x4_f32 v[50:53], v96, v12, v[50:53]
	v_mfma_f32_16x16x4_f32 v[46:49], v61, v13, v[46:49]
	v_mfma_f32_16x16x4_f32 v[54:57], v89, v13, v[54:57]
	v_mfma_f32_16x16x4_f32 v[58:61], v93, v13, v[62:65]
	s_nop 5
	ds_read_b128 v[62:65], v73
	ds_read_b128 v[86:89], v73 offset:256
	v_mfma_f32_16x16x4_f32 v[50:53], v97, v13, v[50:53]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[90:93], v62, v14, v[46:49]
	ds_read_b128 v[94:97], v73 offset:512
	ds_read_b128 v[46:49], v73 offset:768
	v_mov_b32_e32 v62, v42
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 v[54:57], v86, v14, v[54:57]
	v_add_u32_e32 v86, v78, v79
	v_mfma_f32_16x16x4_f32 v[58:61], v94, v14, v[58:61]
	v_mfma_f32_16x16x4_f32 v[50:53], v46, v14, v[50:53]
	v_add_u32_e32 v46, s12, v69
	v_lshrrev_b32_e32 v46, 2, v46
	v_mfma_f32_16x16x4_f32 v[90:93], v63, v15, v[90:93]
	v_mov_b32_e32 v63, v38
	v_mov_b32_e32 v38, v43
	v_mfma_f32_16x16x4_f32 v[54:57], v87, v15, v[54:57]
	v_mfma_f32_16x16x4_f32 v[58:61], v95, v15, v[58:61]
	v_mfma_f32_16x16x4_f32 v[50:53], v47, v15, v[50:53]
	v_mad_u64_u32 v[46:47], s[18:19], v46, s14, v[66:67]
	ds_write2_b64 v46, v[62:63], v[38:39] offset1:2
	v_mfma_f32_16x16x4_f32 v[90:93], v64, v16, v[90:93]
	v_mov_b32_e32 v64, v44
	v_mfma_f32_16x16x4_f32 v[54:57], v88, v16, v[54:57]
	v_mfma_f32_16x16x4_f32 v[58:61], v96, v16, v[58:61]
	v_mfma_f32_16x16x4_f32 v[50:53], v48, v16, v[50:53]
	v_add_u32_e32 v48, v81, v79
	v_add_u32_e32 v79, s17, v79
	v_mfma_f32_16x16x4_f32 v[90:93], v65, v17, v[90:93]
	v_mov_b32_e32 v65, v40
	v_mov_b32_e32 v40, v45
	ds_write2_b64 v46, v[64:65], v[40:41] offset0:4 offset1:6
	v_mfma_f32_16x16x4_f32 v[54:57], v89, v17, v[54:57]
	s_nop 5
	v_max3_f32 v47, v90, s8, v91
	v_max3_f32 v47, v47, v92, v93
	v_mfma_f32_16x16x4_f32 v[42:45], v97, v17, v[58:61]
	s_nop 0
	v_max3_f32 v47, v47, v54, v55
	v_max3_f32 v47, v47, v56, v57
	buffer_load_dwordx4 v[62:65], v48, s[28:31], 0 offen
	buffer_load_dwordx4 v[58:61], v86, s[28:31], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[86:89], v76
	ds_read_b128 v[94:97], v76 offset:272
	s_nop 0
	v_max3_f32 v47, v47, v42, v43
	v_mfma_f32_16x16x4_f32 v[38:41], v49, v17, v[50:53]
	v_max3_f32 v47, v47, v44, v45
	s_nop 7
	s_nop 0
	v_max3_f32 v47, v47, v38, v39
	v_mov_b32_e32 v46, v41
	v_max3_f32 v41, v47, v40, v41
	ds_bpermute_b32 v47, v74, v41
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v47, v47, v47
	v_max_f32_e32 v41, v41, v47
	ds_bpermute_b32 v47, v75, v41
	s_waitcnt lgkmcnt(0)
	v_max3_f32 v47, v85, v41, v47
	v_pk_mul_f32 v[48:49], s[44:45], v[46:47]
	s_nop 0
	v_fma_f32 v41, s9, v85, -v49
	v_fma_f32 v50, s9, v90, -v49
	v_exp_f32_e32 v46, v41
	v_exp_f32_e32 v41, v50
	ds_read_b128 v[50:53], v76 offset:544
	ds_read_b128 v[98:101], v76 offset:816
	v_fma_f32 v54, s9, v54, -v49
	v_pk_mul_f32 v[24:25], v[24:25], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[46:47] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 v[22:25], v86, v41, v[22:25]
	v_fma_f32 v42, s9, v42, -v49
	v_fma_f32 v38, s9, v38, -v49
	v_exp_f32_e32 v38, v38
	v_fma_f32 v39, s9, v39, -v49
	v_exp_f32_e32 v39, v39
	v_fma_f32 v40, s9, v40, -v49
	v_exp_f32_e32 v40, v40
	v_mfma_f32_16x16x4_f32 v[26:29], v94, v41, v[26:29]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[30:33], v50, v41, v[30:33]
	v_fma_f32 v50, s9, v91, -v49
	v_exp_f32_e32 v85, v50
	v_fma_f32 v50, s9, v92, -v49
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[34:37], v98, v41, v[34:37]
	v_exp_f32_e32 v98, v50
	v_fma_f32 v50, s9, v93, -v49
	v_add_f32_e32 v41, v41, v85
	v_add_f32_e32 v41, v98, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v87, v85, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v95, v85, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v51, v85, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v99, v85, v[34:37]
	v_exp_f32_e32 v99, v50
	v_mov_b32_e32 v85, v47
	v_add_f32_e32 v41, v99, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v88, v98, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v96, v98, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v52, v98, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v100, v98, v[34:37]
	v_exp_f32_e32 v100, v54
	s_waitcnt vmcnt(1)
	v_mov_b32_e32 v54, v64
	v_add_f32_e32 v41, v100, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v89, v99, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v97, v99, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v53, v99, v[30:33]
	ds_read_b128 v[50:53], v83
	ds_read_b128 v[86:89], v83 offset:272
	ds_read_b128 v[90:93], v83 offset:544
	ds_read_b128 v[94:97], v83 offset:816
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 v[34:37], v101, v99, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v50, v100, v[22:25]
	v_fma_f32 v50, s9, v55, -v49
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v55, v60
	v_mov_b32_e32 v60, v65
	v_mfma_f32_16x16x4_f32 v[26:29], v86, v100, v[26:29]
	v_exp_f32_e32 v86, v50
	v_fma_f32 v50, s9, v56, -v49
	v_add_f32_e32 v41, v86, v41
	v_mfma_f32_16x16x4_f32 v[30:33], v90, v100, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v94, v100, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v51, v86, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v87, v86, v[26:29]
	v_exp_f32_e32 v87, v50
	v_fma_f32 v50, s9, v57, -v49
	v_add_f32_e32 v41, v87, v41
	v_mfma_f32_16x16x4_f32 v[30:33], v91, v86, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v95, v86, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v52, v87, v[22:25]
	v_mov_b32_e32 v52, v62
	v_mfma_f32_16x16x4_f32 v[26:29], v88, v87, v[26:29]
	v_exp_f32_e32 v88, v50
	v_add_u32_e32 v50, s12, v70
	v_lshrrev_b32_e32 v50, 2, v50
	v_mad_u64_u32 v[50:51], s[18:19], v50, s14, v[66:67]
	v_add_f32_e32 v41, v88, v41
	v_mfma_f32_16x16x4_f32 v[30:33], v92, v87, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v96, v87, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v53, v88, v[22:25]
	v_mov_b32_e32 v53, v58
	v_mov_b32_e32 v58, v63
	ds_write2_b64 v50, v[52:53], v[58:59] offset1:2
	ds_write2_b64 v50, v[54:55], v[60:61] offset0:4 offset1:6
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[50:53], v76
	ds_read_b128 v[54:57], v76 offset:272
	ds_read_b128 v[58:61], v76 offset:544
	ds_read_b128 v[62:65], v76 offset:816
	v_mfma_f32_16x16x4_f32 v[26:29], v89, v88, v[26:29]
	v_exp_f32_e32 v89, v42
	v_fma_f32 v42, s9, v43, -v49
	v_add_f32_e32 v41, v89, v41
	v_mfma_f32_16x16x4_f32 v[30:33], v93, v88, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v97, v88, v[34:37]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 v[22:25], v50, v89, v[22:25]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 v[26:29], v54, v89, v[26:29]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[30:33], v58, v89, v[30:33]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[34:37], v62, v89, v[34:37]
	v_exp_f32_e32 v62, v42
	v_fma_f32 v42, s9, v44, -v49
	v_add_f32_e32 v41, v62, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v51, v62, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v55, v62, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v59, v62, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v63, v62, v[34:37]
	v_exp_f32_e32 v63, v42
	v_fma_f32 v42, s9, v45, -v49
	v_add_f32_e32 v41, v63, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v52, v63, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v56, v63, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v60, v63, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v64, v63, v[34:37]
	v_exp_f32_e32 v64, v42
	s_nop 0
	v_add_f32_e32 v41, v64, v41
	v_mfma_f32_16x16x4_f32 v[22:25], v53, v64, v[22:25]
	ds_read_b128 v[42:45], v83
	ds_read_b128 v[50:53], v83 offset:272
	v_mfma_f32_16x16x4_f32 v[26:29], v57, v64, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v61, v64, v[30:33]
	ds_read_b128 v[54:57], v83 offset:544
	ds_read_b128 v[58:61], v83 offset:816
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 v[34:37], v65, v64, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v42, v38, v[22:25]
	v_mov_b32_e32 v42, v68
	v_mfma_f32_16x16x4_f32 v[26:29], v50, v38, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v54, v38, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v58, v38, v[34:37]
	v_add_f32_e32 v38, v38, v41
	v_add_f32_e32 v38, v39, v38
	v_add_f32_e32 v38, v40, v38
	v_mfma_f32_16x16x4_f32 v[22:25], v43, v39, v[22:25]
	v_sub_f32_e32 v43, v48, v49
	v_exp_f32_e32 v43, v43
	s_nop 0
	v_add_f32_e32 v38, v43, v38
	v_mfma_f32_16x16x4_f32 v[26:29], v51, v39, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v55, v39, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v59, v39, v[34:37]
	ds_bpermute_b32 v39, v74, v38
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v38, v38, v39
	ds_bpermute_b32 v39, v75, v38
	v_mfma_f32_16x16x4_f32 v[22:25], v44, v40, v[22:25]
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v68, v38, v39
	v_fmac_f32_e32 v68, v42, v46
	v_mfma_f32_16x16x4_f32 v[26:29], v52, v40, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v56, v40, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v60, v40, v[34:37]
	v_mfma_f32_16x16x4_f32 v[22:25], v45, v43, v[22:25]
	v_mfma_f32_16x16x4_f32 v[26:29], v53, v43, v[26:29]
	v_mfma_f32_16x16x4_f32 v[30:33], v57, v43, v[30:33]
	v_mfma_f32_16x16x4_f32 v[34:37], v61, v43, v[34:37]
	s_cbranch_scc1 .LBB1_6
	s_sub_i32 s8, s6, s7
	s_mul_hi_i32 s6, s0, s13
	s_mul_i32 s0, s0, s13
	s_add_u32 s0, s0, s1
	s_addc_u32 s1, s6, s5
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	s_and_b64 s[6:7], vcc, exec
	s_cselect_b32 s5, s0, 0x7fffffff
	s_mul_hi_i32 s1, s35, s2
	s_mul_i32 s0, s35, s2
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s2, s22, s0
	s_addc_u32 s6, s23, s1
	s_mul_hi_i32 s1, s27, s4
	s_mul_i32 s0, s27, s4
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s2, s0
	v_readfirstlane_b32 s2, v0
	v_rcp_f32_e32 v14, v68
	s_addc_u32 s1, s6, s1
	s_lshr_b32 s2, s2, 2
	s_and_b32 s2, s2, 0x3ffffff0
	v_or_b32_e32 v0, s3, v1
	v_add_u32_e32 v0, s2, v0
	v_lshl_or_b32 v1, s8, 6, v67
	v_mul_lo_u32 v0, v0, s13
	v_pk_mul_f32 v[4:5], v[14:15], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[14:15], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[14:15], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[14:15], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[14:15], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[14:15], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[14:15], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[14:15], v[22:23] op_sel_hi:[0,1]
	s_lshl_b32 s2, s5, 2
	s_mov_b32 s3, 0x20000
	v_add_lshl_u32 v0, v1, v0, 2
	buffer_store_dwordx4 v[14:17], v0, s[0:3], 0 offen
	buffer_store_dwordx4 v[10:13], v0, s[0:3], 0 offen offset:64
	buffer_store_dwordx4 v[6:9], v0, s[0:3], 0 offen offset:128
	buffer_store_dwordx4 v[2:5], v0, s[0:3], 0 offen offset:192
	s_endpgm
.LBB1_8:
	v_mov_b32_e32 v18, 0xff800000
	s_ashr_i32 s5, s4, 31
	s_waitcnt lgkmcnt(0)
	s_cmp_eq_u64 s[28:29], 0
	s_cbranch_scc0 .LBB1_2
	s_branch .LBB1_3
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_
		.amdhsa_group_segment_fixed_size 8704
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 144
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 107
		.amdhsa_next_free_sgpr 46
		.amdhsa_accum_offset 108
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
	.section	.text._ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_,"axG",@progbits,_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_,comdat
.Lfunc_end1:
	.size	_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_, .Lfunc_end1-_ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_

	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.num_vgpr, 107
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.num_agpr, 0
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.numbered_sgpr, 46
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.private_seg_size, 0
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.uses_vcc, 1
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.uses_flat_scratch, 0
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.has_dyn_sized_stack, 0
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.has_recursion, 0
	.set _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_5301935b862ab04e,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_5301935b862ab04e
__hip_cuid_5301935b862ab04e:
	.byte	0
	.size	__hip_cuid_5301935b862ab04e, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_5301935b862ab04e
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:           []
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 4
    .kernarg_segment_size: 0
    .max_flat_workgroup_size: 1024
    .name:           _ZN7ck_tileL11flush_cacheEv
    .private_segment_fixed_size: 0
    .sgpr_count:     6
    .sgpr_spill_count: 0
    .symbol:         _ZN7ck_tileL11flush_cacheEv.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     0
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           144
        .value_kind:     by_value
    .group_segment_fixed_size: 8704
    .kernarg_segment_align: 8
    .kernarg_segment_size: 144
    .max_flat_workgroup_size: 256
    .name:           _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_
    .private_segment_fixed_size: 0
    .sgpr_count:     52
    .sgpr_spill_count: 0
    .symbol:         _ZN7ck_tile6kentryINS_8gfx950_tELi3ENS_13FmhaFwdKernelINS_23BlockFmhaPipelineQRKSVSINS_24BlockFmhaPipelineProblemIffffffhffffNS_13TileFmhaShapeINS_8sequenceIJLi64ELi64ELi32ELi64ELi32ELi64EEEENS6_IJLi4ELi1ELi1EEEENS6_IJLi16ELi16ELi16EEEES8_S9_Lb1EEELb0ENS_17ComposedAttentionILj0ELb1EEENS_30SimplifiedGenericAttentionMaskILb0EEELb0ENS_14TileFmhaTraitsILb0ELb0ELb0ELb0ELb0ELNS_22BlockAttentionBiasEnumE0ELb0ELb0ELb0ELNS_28BlockAttentionQuantScaleEnumE0ELin1ELb0ELb0EEEEENS_35BlockFmhaPipelineQXKSVSCustomPolicyILb1ELb0ELi1ELi1EEELb0EEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb0ELb1EEEvEEEEJNSR_21FmhaFwdBatchModeKargsEEEENSt3__19enable_ifIXnt26kattr_no_packed_fp32_ops_vIT_EEvE4typeEDpT2_.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     107
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
