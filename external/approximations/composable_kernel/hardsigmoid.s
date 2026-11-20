	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN2ckL12flush_icacheEv,"axG",@progbits,_ZN2ckL12flush_icacheEv,comdat
	.globl	_ZN2ckL12flush_icacheEv
	.p2align	8
	.type	_ZN2ckL12flush_icacheEv,@function
_ZN2ckL12flush_icacheEv:
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
	.amdhsa_kernel _ZN2ckL12flush_icacheEv
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
	.section	.text._ZN2ckL12flush_icacheEv,"axG",@progbits,_ZN2ckL12flush_icacheEv,comdat
.Lfunc_end0:
	.size	_ZN2ckL12flush_icacheEv, .Lfunc_end0-_ZN2ckL12flush_icacheEv

	.set _ZN2ckL12flush_icacheEv.num_vgpr, 0
	.set _ZN2ckL12flush_icacheEv.num_agpr, 0
	.set _ZN2ckL12flush_icacheEv.numbered_sgpr, 0
	.set _ZN2ckL12flush_icacheEv.private_seg_size, 0
	.set _ZN2ckL12flush_icacheEv.uses_vcc, 0
	.set _ZN2ckL12flush_icacheEv.uses_flat_scratch, 0
	.set _ZN2ckL12flush_icacheEv.has_dyn_sized_stack, 0
	.set _ZN2ckL12flush_icacheEv.has_recursion, 0
	.set _ZN2ckL12flush_icacheEv.has_indirect_call, 0
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
	s_load_dwordx8 s[12:19], s[0:1], 0x10
	s_load_dwordx2 s[8:9], s[0:1], 0x60
	s_waitcnt lgkmcnt(0)
	s_load_dword s19, s[0:1], 0x68
	s_load_dword s20, s[0:1], 0x3c
	s_load_dwordx4 s[4:7], s[0:1], 0x50
	s_cmp_gt_i32 s18, 1
	s_cselect_b64 s[10:11], -1, 0
	s_waitcnt lgkmcnt(0)
	s_bitcmp1_b32 s19, 0
	s_cselect_b64 s[22:23], -1, 0
	s_and_b64 s[10:11], s[10:11], s[22:23]
	s_andn2_b64 vcc, exec, s[10:11]
	s_mov_b64 s[10:11], 0
	s_cbranch_vccnz .LBB1_2
	s_mul_i32 s10, s12, s3
	s_mul_i32 s10, s10, s13
	s_ashr_i32 s11, s10, 31
.LBB1_2:
	s_load_dword s21, s[0:1], 0x34
	s_add_i32 s19, s12, -1
	s_cmp_lt_u32 s19, 64
	s_mov_b32 s22, 0
	s_cbranch_scc1 .LBB1_10
	s_add_i32 s0, s13, -1
	s_cmpk_lt_u32 s0, 0x100
	s_mov_b32 s0, 0
	s_cbranch_scc1 .LBB1_9
	s_add_i32 s0, s12, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s23, s0, 6
	s_add_i32 s0, s13, 0xff
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 24
	s_add_i32 s0, s0, s1
	s_ashr_i32 s22, s0, 8
	s_mul_i32 s0, s22, s23
	s_add_i32 s1, s0, 7
	s_ashr_i32 s24, s1, 31
	s_lshr_b32 s24, s24, 29
	s_add_i32 s1, s1, s24
	s_ashr_i32 s24, s1, 3
	s_and_b32 s1, s1, -8
	s_sub_i32 s25, s0, s1
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 29
	s_add_i32 s27, s2, s0
	s_and_b32 s0, s27, -8
	s_add_i32 s25, s25, 8
	s_sub_i32 s26, s2, s0
	s_cmp_gt_i32 s26, s25
	s_cbranch_scc1 .LBB1_6
	s_mul_i32 s2, s24, s26
	s_ashr_i32 s0, s27, 3
	s_cbranch_execz .LBB1_7
	s_branch .LBB1_8
.LBB1_6:
	s_ashr_i32 s0, s27, 3
.LBB1_7:
	s_add_i32 s1, s24, -1
	s_mul_i32 s1, s1, s26
	s_add_i32 s2, s25, s1
.LBB1_8:
	s_abs_i32 s1, s22
	v_cvt_f32_u32_e32 v1, s1
	s_sub_i32 s25, 0, s1
	s_add_i32 s0, s2, s0
	s_abs_i32 s24, s0
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s2, s0, s22
	s_ashr_i32 s2, s2, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s26, v1
	s_mul_i32 s25, s25, s26
	s_mul_hi_u32 s25, s26, s25
	s_add_i32 s26, s26, s25
	s_mul_hi_u32 s25, s24, s26
	s_mul_i32 s26, s25, s1
	s_sub_i32 s24, s24, s26
	s_add_i32 s27, s25, 1
	s_sub_i32 s26, s24, s1
	s_cmp_ge_u32 s24, s1
	s_cselect_b32 s25, s27, s25
	s_cselect_b32 s24, s26, s24
	s_add_i32 s26, s25, 1
	s_cmp_ge_u32 s24, s1
	s_cselect_b32 s1, s26, s25
	s_xor_b32 s1, s1, s2
	s_lshr_b32 s24, s23, 30
	s_sub_i32 s1, s1, s2
	s_add_i32 s24, s23, s24
	s_mul_i32 s2, s1, s22
	s_sub_i32 s0, s0, s2
	s_and_b32 s2, s24, -4
	s_sub_i32 s23, s23, s2
	s_cmp_ge_i32 s1, s2
	s_cselect_b32 s2, s23, 4
	s_abs_i32 s24, s2
	v_cvt_f32_u32_e32 v1, s24
	s_ashr_i32 s23, s1, 31
	s_lshr_b32 s23, s23, 30
	s_add_i32 s23, s1, s23
	v_rcp_iflag_f32_e32 v1, v1
	s_and_b32 s23, s23, -4
	s_sub_i32 s23, s1, s23
	s_sub_i32 s26, 0, s24
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s22, s23, s22
	s_add_i32 s22, s22, s0
	s_abs_i32 s25, s22
	v_readfirstlane_b32 s27, v1
	s_mul_i32 s26, s26, s27
	s_mul_hi_u32 s26, s27, s26
	s_add_i32 s27, s27, s26
	s_mul_hi_u32 s26, s25, s27
	s_mul_i32 s27, s26, s24
	s_xor_b32 s0, s22, s2
	s_sub_i32 s25, s25, s27
	s_ashr_i32 s0, s0, 31
	s_add_i32 s27, s26, 1
	s_sub_i32 s28, s25, s24
	s_cmp_ge_u32 s25, s24
	s_cselect_b32 s26, s27, s26
	s_cselect_b32 s25, s28, s25
	s_add_i32 s27, s26, 1
	s_cmp_ge_u32 s25, s24
	s_cselect_b32 s24, s27, s26
	s_xor_b32 s24, s24, s0
	s_sub_i32 s0, s24, s0
	s_mul_i32 s2, s0, s2
	s_sub_i32 s2, s22, s2
	s_add_i32 s2, s2, s1
	s_sub_i32 s2, s2, s23
.LBB1_9:
	s_mov_b32 s22, s2
	s_mov_b32 s2, s0
.LBB1_10:
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s21, s3
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[24:25], s[0:1], 2
	s_add_u32 s0, s4, s24
	s_addc_u32 s1, s5, s25
	s_add_u32 s4, s6, s24
	s_addc_u32 s5, s7, s25
	s_add_i32 s18, s18, -1
	s_mul_i32 s23, s18, s21
	v_lshrrev_b32_e32 v123, 2, v0
	s_add_i32 s7, s13, 0x3fffffff
	s_sub_i32 s14, s14, s23
	v_and_b32_e32 v127, 7, v0
	v_and_b32_e32 v122, 62, v123
	s_cmp_lt_u32 s3, s18
	v_bitop3_b32 v155, v123, v127, 6 bitop3:0x6c
	v_lshlrev_b32_e32 v3, 5, v122
	s_cselect_b32 s21, s21, s14
	s_lshl_b32 s14, s2, 8
	v_lshl_or_b32 v38, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v1, s22, 6, v122
	v_or_b32_e32 v150, s14, v3
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v1, s15
	v_mul_lo_u32 v152, v150, s16
	s_ashr_i32 s2, s20, 31
	v_add_u32_e32 v22, v154, v2
	v_add_u32_e32 v10, v152, v2
	v_lshl_or_b32 v30, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_lshr_b32 s2, s2, 29
	s_mul_i32 s6, s19, s15
	s_mul_i32 s7, s7, s16
	v_and_b32_e32 v26, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v82, 6, v2
	v_bitop3_b32 v83, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v84, v126, v124
	s_add_i32 s20, s20, s2
	s_ashr_i32 s18, s20, 3
	s_add_i32 s2, s21, s6
	s_mov_b32 s3, 0x20000
	s_add_i32 s21, s21, s7
	v_add_u32_e32 v18, s16, v10
	s_lshl_b32 s2, s2, 2
	v_lshlrev_b32_e32 v2, 2, v22
	v_add_lshl_u32 v6, v22, s15, 2
	s_lshl_b32 s6, s21, 2
	s_mov_b32 s7, s3
	v_lshlrev_b32_e32 v11, 2, v10
	v_lshlrev_b32_e32 v14, 2, v18
	buffer_load_dwordx4 v[2:5], v2, s[0:3], 0 offen
	buffer_load_dwordx4 v[6:9], v6, s[0:3], 0 offen
	buffer_load_dwordx4 v[10:13], v11, s[4:7], 0 offen
	buffer_load_dwordx4 v[14:17], v14, s[4:7], 0 offen
	v_add_u32_e32 v23, s16, v18
	v_lshlrev_b32_e32 v18, 2, v23
	buffer_load_dwordx4 v[18:21], v18, s[4:7], 0 offen
	v_add_u32_e32 v27, s16, v23
	v_add_u32_e32 v34, s16, v27
	v_add_u32_e32 v31, 32, v22
	v_lshlrev_b32_e32 v22, 2, v27
	v_bitop3_b32 v32, v26, v127, 1 bitop3:0x36
	v_lshlrev_b32_e32 v26, 2, v34
	v_add_u32_e32 v40, s16, v34
	buffer_load_dwordx4 v[22:25], v22, s[4:7], 0 offen
	buffer_load_dwordx4 v[26:29], v26, s[4:7], 0 offen
	v_lshlrev_b32_e32 v34, 2, v40
	v_add_u32_e32 v40, s16, v40
	buffer_load_dwordx4 v[34:37], v34, s[4:7], 0 offen
	v_lshlrev_b32_e32 v41, 2, v40
	buffer_load_dwordx4 v[70:73], v41, s[4:7], 0 offen
	v_add_u32_e32 v40, s16, v40
	v_lshlrev_b32_e32 v41, 2, v40
	buffer_load_dwordx4 v[78:81], v41, s[4:7], 0 offen
	v_sub_u32_e32 v39, v32, v155
	v_sub_u32_e32 v32, v155, v32
	s_mul_i32 s20, s16, -7
	v_lshlrev_b32_e32 v42, 2, v39
	v_lshlrev_b32_e32 v43, 2, v32
	v_lshlrev_b32_e32 v85, 2, v38
	v_add3_u32 v156, v42, v38, v43
	v_add3_u32 v38, s20, 32, v40
	v_lshl_add_u32 v89, v39, 4, v85
	v_lshlrev_b32_e32 v39, 2, v38
	v_add_u32_e32 v38, s16, v38
	v_add_u32_e32 v46, s16, v38
	v_lshlrev_b32_e32 v47, 2, v46
	v_add_u32_e32 v46, s16, v46
	v_add_u32_e32 v54, s16, v46
	v_lshlrev_b32_e32 v55, 2, v54
	v_add_u32_e32 v54, s16, v54
	v_bitop3_b32 v33, v0, 1, 7 bitop3:0x6c
	v_bitop3_b32 v87, v0, 2, 7 bitop3:0x6c
	v_add_u32_e32 v62, s16, v54
	v_sub_u32_e32 v41, v33, v127
	v_sub_u32_e32 v88, v87, v33
	v_lshlrev_b32_e32 v33, 2, v31
	v_add_lshl_u32 v31, v31, s15, 2
	v_lshlrev_b32_e32 v40, 2, v38
	v_lshlrev_b32_e32 v48, 2, v46
	v_lshlrev_b32_e32 v58, 2, v54
	v_lshlrev_b32_e32 v63, 2, v62
	v_add_lshl_u32 v66, v62, s16, 2
	v_lshlrev_b32_e32 v86, 2, v30
	v_lshl_add_u32 v90, v41, 2, v30
	v_lshlrev_b32_e32 v138, 4, v41
	buffer_load_dwordx4 v[74:77], v33, s[0:3], 0 offen
	buffer_load_dwordx4 v[30:33], v31, s[0:3], 0 offen
	buffer_load_dwordx4 v[42:45], v39, s[4:7], 0 offen
	buffer_load_dwordx4 v[38:41], v40, s[4:7], 0 offen
	buffer_load_dwordx4 v[50:53], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[46:49], v48, s[4:7], 0 offen
	buffer_load_dwordx4 v[54:57], v55, s[4:7], 0 offen
	buffer_load_dwordx4 v[58:61], v58, s[4:7], 0 offen
	buffer_load_dwordx4 v[62:65], v63, s[4:7], 0 offen
	buffer_load_dwordx4 v[66:69], v66, s[4:7], 0 offen
	s_movk_i32 s21, 0x2000
	v_add3_u32 v91, v86, s21, v138
	v_lshlrev_b32_e32 v139, 4, v88
	s_movk_i32 s20, 0x80
	v_mov_b32_e32 v136, 0xffffff20
	s_waitcnt vmcnt(19)
	ds_write_b128 v85, v[2:5]
	s_waitcnt vmcnt(18)
	ds_write_b128 v89, v[6:9] offset:128
	s_waitcnt vmcnt(17)
	ds_write_b128 v86, v[10:13] offset:8192
	s_waitcnt vmcnt(16)
	ds_write_b128 v91, v[14:17] offset:128
	v_bitop3_b32 v3, v0, 3, 7 bitop3:0x6c
	v_sub_u32_e32 v4, v3, v87
	v_bitop3_b32 v6, v0, 4, 7 bitop3:0x6c
	v_bitop3_b32 v8, v0, 5, 7 bitop3:0x6c
	v_lshlrev_b32_e32 v2, 2, v88
	v_lshlrev_b32_e32 v5, 2, v4
	v_sub_u32_e32 v3, v6, v3
	v_sub_u32_e32 v6, v8, v6
	v_add3_u32 v2, v90, v2, v5
	v_add3_u32 v5, v91, s20, v139
	v_lshlrev_b32_e32 v7, 2, v3
	v_lshlrev_b32_e32 v9, 2, v6
	v_lshlrev_b32_e32 v140, 4, v4
	s_waitcnt vmcnt(15)
	ds_write_b128 v5, v[18:21] offset:128
	v_add3_u32 v2, v2, v7, v9
	v_add3_u32 v4, v5, s20, v140
	v_bitop3_b32 v5, v0, 6, 7 bitop3:0x6c
	v_bitop3_b32 v9, v0, 7, v0 bitop3:0xc
	v_sub_u32_e32 v7, v5, v8
	v_sub_u32_e32 v5, v9, v5
	v_lshlrev_b32_e32 v8, 2, v7
	v_lshlrev_b32_e32 v10, 2, v5
	v_lshlrev_b32_e32 v141, 4, v3
	v_add3_u32 v133, v2, v8, v10
	v_add3_u32 v2, v4, s20, v141
	v_lshlrev_b32_e32 v142, 4, v6
	s_waitcnt vmcnt(14)
	ds_write_b128 v4, v[22:25] offset:128
	s_waitcnt vmcnt(13)
	ds_write_b128 v2, v[26:29] offset:128
	v_add3_u32 v2, v2, s20, v142
	v_lshlrev_b32_e32 v143, 4, v7
	s_waitcnt vmcnt(12)
	ds_write_b128 v2, v[34:37] offset:128
	v_add3_u32 v2, v2, s20, v143
	v_lshlrev_b32_e32 v3, 4, v5
	s_waitcnt vmcnt(11)
	ds_write_b128 v2, v[70:73] offset:128
	v_add3_u32 v135, v2, s20, v3
	v_lshlrev_b32_e32 v2, 7, v124
	v_lshlrev_b32_e32 v3, 11, v125
	v_lshlrev_b32_e32 v4, 4, v83
	v_or3_b32 v128, v3, v2, v4
	v_bitop3_b32 v2, v82, v127, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v83
	v_lshl_or_b32 v6, v84, 7, v4
	v_lshlrev_b32_e32 v7, 4, v2
	v_or_b32_e32 v129, 0x2000, v6
	v_add_u32_e32 v130, v128, v7
	v_add_u32_e32 v131, v7, v6
	v_sub_u32_e32 v134, v127, v9
	s_waitcnt vmcnt(10)
	ds_write_b128 v135, v[78:81] offset:128
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[106:109], v128
	ds_read_b128 v[70:73], v128 offset:4096
	ds_read_b128 v[114:117], v6 offset:8192
	ds_read_b128 v[118:121], v6 offset:12288
	ds_read_b128 v[98:101], v6 offset:16384
	ds_read_b128 v[110:113], v6 offset:20480
	ds_read_b128 v[90:93], v6 offset:24576
	ds_read_b128 v[94:97], v6 offset:28672
	ds_read_b128 v[102:105], v6 offset:32768
	ds_read_b128 v[86:89], v6 offset:36864
	ds_read_b128 v[22:25], v130
	ds_read_b128 v[2:5], v130 offset:4096
	v_add_u32_e32 v132, v129, v7
	ds_read_b128 v[82:85], v131 offset:8192
	ds_read_b128 v[34:37], v132 offset:4096
	ds_read_b128 v[78:81], v132 offset:8192
	ds_read_b128 v[26:29], v132 offset:12288
	ds_read_b128 v[6:9], v132 offset:16384
	ds_read_b128 v[10:13], v132 offset:20480
	ds_read_b128 v[18:21], v132 offset:24576
	ds_read_b128 v[14:17], v132 offset:28672
	v_lshl_add_u32 v136, v134, 2, v136
	v_add_lshl_u32 v137, v133, v136, 2
	v_add_u32_e32 v133, 0x80, v135
	v_lshl_add_u32 v136, v136, 2, v133
	s_movk_i32 s21, 0x2400
	v_add3_u32 v137, v138, v137, s21
	v_add_u32_e32 v138, v136, v138
	s_movk_i32 s21, 0x100
	v_add3_u32 v138, v138, v139, s21
	v_add3_u32 v139, v138, v140, s20
	v_or_b32_e32 v134, 1, v123
	v_add3_u32 v140, v139, v141, s20
	v_or_b32_e32 v145, 7, v150
	v_or_b32_e32 v146, 6, v150
	v_or_b32_e32 v147, 5, v150
	v_or_b32_e32 v148, 4, v150
	v_or_b32_e32 v149, 3, v150
	v_or_b32_e32 v150, 2, v150
	s_max_i32 s18, s18, 2
	v_sub_u32_e32 v144, v134, v122
	v_add3_u32 v141, v140, v142, s20
	v_mul_lo_u32 v145, s16, v145
	v_mov_b32_e32 v157, 0x100
	v_mul_lo_u32 v146, s16, v146
	v_mul_lo_u32 v147, s16, v147
	v_mul_lo_u32 v148, s16, v148
	v_mul_lo_u32 v149, s16, v149
	v_mul_lo_u32 v150, s16, v150
	v_add_u32_e32 v151, s16, v152
	v_add_u32_e32 v153, s15, v154
	v_lshlrev_b32_e32 v135, 5, v144
	v_add_u32_e32 v142, v141, v143
	v_add_u32_e32 v143, -1, v144
	v_lshlrev_b32_e32 v144, 4, v127
	v_lshl_add_u32 v145, v145, 2, v157
	v_lshl_add_u32 v146, v146, 2, v157
	v_lshl_add_u32 v147, v147, 2, v157
	v_lshl_add_u32 v148, v148, 2, v157
	v_lshl_add_u32 v149, v149, 2, v157
	v_lshl_add_u32 v150, v150, 2, v157
	v_lshl_add_u32 v151, v151, 2, v157
	v_lshl_add_u32 v152, v152, 2, v157
	v_lshl_add_u32 v153, v153, 2, v157
	v_lshl_add_u32 v154, v154, 2, v157
	s_add_i32 s15, s18, -1
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a31, 0
	v_accvgpr_write_b32 a30, 0
	v_accvgpr_write_b32 a29, 0
	v_accvgpr_write_b32 a28, 0
	v_accvgpr_write_b32 a35, 0
	v_accvgpr_write_b32 a34, 0
	v_accvgpr_write_b32 a33, 0
	v_accvgpr_write_b32 a32, 0
	v_accvgpr_write_b32 a23, 0
	v_accvgpr_write_b32 a22, 0
	v_accvgpr_write_b32 a21, 0
	v_accvgpr_write_b32 a20, 0
	v_accvgpr_write_b32 a19, 0
	v_accvgpr_write_b32 a18, 0
	v_accvgpr_write_b32 a17, 0
	v_accvgpr_write_b32 a16, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
	v_accvgpr_write_b32 a27, 0
	v_accvgpr_write_b32 a26, 0
	v_accvgpr_write_b32 a25, 0
	v_accvgpr_write_b32 a24, 0
	v_accvgpr_write_b32 a39, 0
	v_accvgpr_write_b32 a38, 0
	v_accvgpr_write_b32 a37, 0
	v_accvgpr_write_b32 a36, 0
	v_accvgpr_write_b32 a43, 0
	v_accvgpr_write_b32 a42, 0
	v_accvgpr_write_b32 a41, 0
	v_accvgpr_write_b32 a40, 0
	v_accvgpr_write_b32 a47, 0
	v_accvgpr_write_b32 a46, 0
	v_accvgpr_write_b32 a45, 0
	v_accvgpr_write_b32 a44, 0
	v_accvgpr_write_b32 a51, 0
	v_accvgpr_write_b32 a50, 0
	v_accvgpr_write_b32 a49, 0
	v_accvgpr_write_b32 a48, 0
	v_accvgpr_write_b32 a55, 0
	v_accvgpr_write_b32 a54, 0
	v_accvgpr_write_b32 a53, 0
	v_accvgpr_write_b32 a52, 0
	v_accvgpr_write_b32 a59, 0
	v_accvgpr_write_b32 a58, 0
	v_accvgpr_write_b32 a57, 0
	v_accvgpr_write_b32 a56, 0
	v_accvgpr_write_b32 a63, 0
	v_accvgpr_write_b32 a62, 0
	v_accvgpr_write_b32 a61, 0
	v_accvgpr_write_b32 a60, 0
	s_movk_i32 s16, 0xffe0
.LBB1_11:
	v_lshlrev_b32_e32 v157, 2, v156
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(9)
	ds_write_b128 v157, v[74:77]
	v_add_u32_e32 v74, v144, v154
	v_mfma_f32_16x16x4_f32 a[60:63], v106, v114, a[60:63]
	buffer_load_dwordx4 v[74:77], v74, s[0:3], 0 offen
	v_ashrrev_i32_e32 v157, 31, v134
	v_lshrrev_b32_e32 v157, 29, v157
	v_add_u32_e32 v157, v134, v157
	v_and_b32_e32 v157, -8, v157
	v_sub_u32_e32 v157, v134, v157
	v_xor_b32_e32 v157, v157, v127
	v_mfma_f32_16x16x4_f32 a[56:59], v106, v118, a[56:59]
	v_sub_u32_e32 v155, v157, v155
	v_lshlrev_b32_e32 v155, 2, v155
	v_add3_u32 v156, v156, v135, v155
	v_lshlrev_b32_e32 v155, 2, v156
	v_mfma_f32_16x16x4_f32 a[60:63], v107, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v107, v119, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v106, v98, a[52:55]
	v_mfma_f32_16x16x4_f32 a[60:63], v108, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v108, v120, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v107, v99, a[52:55]
	v_mfma_f32_16x16x4_f32 a[60:63], v109, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v109, v121, a[56:59]
	s_waitcnt vmcnt(9)
	ds_write_b128 v155, v[30:33]
	v_add_u32_e32 v30, v144, v153
	v_mfma_f32_16x16x4_f32 a[52:55], v108, v100, a[52:55]
	buffer_load_dwordx4 v[30:33], v30, s[0:3], 0 offen
	v_mfma_f32_16x16x4_f32 a[48:51], v106, v110, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v106, v90, a[44:47]
	v_mfma_f32_16x16x4_f32 a[48:51], v107, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v107, v91, a[44:47]
	v_mfma_f32_16x16x4_f32 a[48:51], v108, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v108, v92, a[44:47]
	v_mfma_f32_16x16x4_f32 a[52:55], v109, v101, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v109, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v109, v93, a[44:47]
	s_waitcnt vmcnt(9)
	ds_write_b128 v136, v[42:45]
	v_add_u32_e32 v42, v144, v152
	v_mfma_f32_16x16x4_f32 a[40:43], v106, v94, a[40:43]
	buffer_load_dwordx4 v[42:45], v42, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[36:39], v106, v102, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v107, v95, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v107, v103, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v106, v86, a[24:27]
	v_mfma_f32_16x16x4_f32 a[40:43], v108, v96, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v108, v104, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v107, v87, a[24:27]
	v_mfma_f32_16x16x4_f32 a[40:43], v109, v97, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v109, v105, a[36:39]
	s_waitcnt vmcnt(9)
	ds_write_b128 v137, v[38:41]
	v_add_u32_e32 v38, v144, v151
	v_mfma_f32_16x16x4_f32 a[24:27], v108, v88, a[24:27]
	buffer_load_dwordx4 v[38:41], v38, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v114, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v70, v118, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v115, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v71, v119, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v116, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v72, v120, a[12:15]
	v_mfma_f32_16x16x4_f32 a[24:27], v109, v89, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v73, v117, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v73, v121, a[12:15]
	s_waitcnt vmcnt(9)
	ds_write_b128 v138, v[50:53]
	v_add_u32_e32 v50, v144, v150
	v_mfma_f32_16x16x4_f32 a[16:19], v70, v98, a[16:19]
	buffer_load_dwordx4 v[50:53], v50, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[20:23], v70, v110, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v71, v99, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v71, v111, a[20:23]
	v_mfma_f32_16x16x4_f32 a[32:35], v70, v90, a[32:35]
	v_mfma_f32_16x16x4_f32 a[16:19], v72, v100, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v72, v112, a[20:23]
	v_mfma_f32_16x16x4_f32 a[32:35], v71, v91, a[32:35]
	v_mfma_f32_16x16x4_f32 a[16:19], v73, v101, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v73, v113, a[20:23]
	s_waitcnt vmcnt(9)
	ds_write_b128 v139, v[46:49]
	v_add_u32_e32 v46, v144, v149
	v_mfma_f32_16x16x4_f32 a[32:35], v72, v92, a[32:35]
	buffer_load_dwordx4 v[46:49], v46, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[28:31], v70, v94, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v70, v102, a[4:7]
	v_mfma_f32_16x16x4_f32 a[28:31], v71, v95, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v71, v103, a[4:7]
	v_mfma_f32_16x16x4_f32 a[28:31], v72, v96, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v72, v104, a[4:7]
	v_mfma_f32_16x16x4_f32 a[32:35], v73, v93, a[32:35]
	v_mfma_f32_16x16x4_f32 a[28:31], v73, v97, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v73, v105, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v140, v[54:57]
	v_add_u32_e32 v54, v144, v148
	v_mfma_f32_16x16x4_f32 a[0:3], v70, v86, a[0:3]
	buffer_load_dwordx4 v[54:57], v54, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[60:63], v22, v82, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v22, v34, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v71, v87, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v18, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v23, v83, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v23, v35, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v72, v88, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v19, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v24, v84, a[60:63]
	s_waitcnt vmcnt(9)
	ds_write_b128 v141, v[58:61]
	v_add_u32_e32 v58, v144, v147
	v_mfma_f32_16x16x4_f32 a[0:3], v73, v89, a[0:3]
	buffer_load_dwordx4 v[58:61], v58, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[56:59], v24, v36, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v22, v78, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v22, v26, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v20, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v25, v85, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v25, v37, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v23, v79, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v23, v27, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v21, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v142, v[62:65] offset:128
	v_add_u32_e32 v62, v144, v146
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	buffer_load_dwordx4 v[62:65], v62, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[52:55], v24, v80, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v24, v28, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_mfma_f32_16x16x4_f32 a[44:47], v22, v6, a[44:47]
	v_mfma_f32_16x16x4_f32 a[40:43], v22, v10, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v22, v18, a[36:39]
	v_add_u32_e32 v18, v144, v145
	v_mfma_f32_16x16x4_f32 a[52:55], v25, v81, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v25, v29, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	s_waitcnt vmcnt(9)
	ds_write_b128 v133, v[66:69]
	v_mfma_f32_16x16x4_f32 a[44:47], v23, v7, a[44:47]
	buffer_load_dwordx4 v[66:69], v18, s[4:7], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[40:43], v23, v11, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v23, v19, a[36:39]
	v_mfma_f32_16x16x4_f32 a[44:47], v24, v8, a[44:47]
	v_mfma_f32_16x16x4_f32 a[40:43], v24, v12, a[40:43]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[44:47], v25, v9, a[44:47]
	v_mfma_f32_16x16x4_f32 a[40:43], v25, v13, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v24, v20, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v22, v14, a[24:27]
	ds_read_b128 v[106:109], v128
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v82, a[8:11]
	ds_read_b128 v[70:73], v128 offset:4096
	v_mfma_f32_16x16x4_f32 a[36:39], v25, v21, a[36:39]
	ds_read_b128 v[114:117], v129
	v_mfma_f32_16x16x4_f32 a[24:27], v23, v15, a[24:27]
	ds_read_b128 v[118:121], v129 offset:4096
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v83, a[8:11]
	ds_read_b128 v[98:101], v129 offset:8192
	v_mfma_f32_16x16x4_f32 a[24:27], v24, v16, a[24:27]
	ds_read_b128 v[110:113], v129 offset:12288
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v84, a[8:11]
	ds_read_b128 v[90:93], v129 offset:16384
	v_mfma_f32_16x16x4_f32 a[24:27], v25, v17, a[24:27]
	ds_read_b128 v[94:97], v129 offset:20480
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v85, a[8:11]
	ds_read_b128 v[102:105], v129 offset:24576
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v34, a[12:15]
	ds_read_b128 v[86:89], v129 offset:28672
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v35, a[12:15]
	ds_read_b128 v[22:25], v130
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v36, a[12:15]
	ds_read_b128 v[82:85], v131 offset:8192
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v6, a[32:35]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v37, a[12:15]
	ds_read_b128 v[34:37], v132 offset:4096
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v78, a[16:19]
	ds_read_b128 v[18:21], v132 offset:24576
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v7, a[32:35]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v79, a[16:19]
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v8, a[32:35]
	v_mfma_f32_16x16x4_f32 a[28:31], v2, v10, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v9, a[32:35]
	ds_read_b128 v[6:9], v132 offset:16384
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v80, a[16:19]
	ds_read_b128 v[14:17], v132 offset:28672
	v_mfma_f32_16x16x4_f32 a[28:31], v3, v11, a[28:31]
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v81, a[16:19]
	ds_read_b128 v[78:81], v132 offset:8192
	v_mfma_f32_16x16x4_f32 a[20:23], v2, v26, a[20:23]
	v_add_u32_e32 v2, -1, v134
	v_mfma_f32_16x16x4_f32 a[28:31], v4, v12, a[28:31]
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v13, a[28:31]
	ds_read_b128 v[10:13], v132 offset:20480
	v_mfma_f32_16x16x4_f32 a[20:23], v3, v27, a[20:23]
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	v_and_b32_e32 v3, -8, v3
	v_sub_u32_e32 v155, v2, v3
	v_xor_b32_e32 v155, v155, v127
	v_sub_u32_e32 v157, v155, v157
	v_mfma_f32_16x16x4_f32 a[20:23], v4, v28, a[20:23]
	v_lshlrev_b32_e32 v157, 2, v157
	v_add3_u32 v156, v157, v156, s16
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v29, a[20:23]
	ds_read_b128 v[2:5], v130 offset:4096
	ds_read_b128 v[26:29], v132 offset:12288
	s_add_i32 s15, s15, -1
	v_add_u32_e32 v145, 0x80, v145
	v_add_u32_e32 v146, 0x80, v146
	v_add_u32_e32 v147, 0x80, v147
	v_add_u32_e32 v148, 0x80, v148
	v_add_u32_e32 v149, 0x80, v149
	v_add_u32_e32 v150, 0x80, v150
	v_add_u32_e32 v151, 0x80, v151
	v_add_u32_e32 v152, 0x80, v152
	v_add_u32_e32 v134, v134, v143
	v_add_u32_e32 v153, 0x80, v153
	s_cmp_lg_u32 s15, 0
	v_add_u32_e32 v154, 0x80, v154
	s_cbranch_scc1 .LBB1_11
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_16x16x4_f32 a[24:27], v106, v86, a[24:27]
	s_waitcnt vmcnt(8)
	v_and_b32_e32 v30, 12, v123
	v_lshlrev_b32_e32 v30, 9, v30
	v_lshlrev_b32_e32 v31, 2, v126
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_lshlrev_b32_e32 v0, 4, v0
	v_and_b32_e32 v0, 0x70, v0
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v114, a[8:11]
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s20, s8, s0
	s_addc_u32 s21, s9, s1
	s_mul_i32 s0, s19, s17
	s_mul_hi_u32 s1, 0, s17
	s_add_i32 s4, s1, s0
	v_cmp_gt_i32_e32 vcc, s12, v1
	v_mfma_f32_16x16x4_f32 a[24:27], v107, v87, a[24:27]
	s_mov_b32 s10, 0x3e2aaaab
	s_mov_b32 s23, 0x20000
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v115, a[8:11]
	v_mfma_f32_16x16x4_f32 a[24:27], v108, v88, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v116, a[8:11]
	v_mfma_f32_16x16x4_f32 a[64:67], v109, v89, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v73, v117, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v118, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v119, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v120, a[8:11]
	v_mfma_f32_16x16x4_f32 a[68:71], v73, v121, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v98, a[16:19]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v99, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v100, a[8:11]
	v_mfma_f32_16x16x4_f32 a[72:75], v73, v101, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v110, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v111, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v112, a[8:11]
	v_mfma_f32_16x16x4_f32 a[20:23], v73, v113, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v90, a[32:35]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v91, a[8:11]
	v_mfma_f32_16x16x4_f32 a[60:63], v106, v114, a[60:63]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v92, a[8:11]
	v_mfma_f32_16x16x4_f32 a[60:63], v107, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[16:19], v73, v93, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v94, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v70, v102, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v108, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v95, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v71, v103, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v109, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v106, v118, a[56:59]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v96, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v72, v104, a[4:7]
	v_mfma_f32_16x16x4_f32 a[56:59], v107, v119, a[56:59]
	v_mfma_f32_16x16x4_f32 a[12:15], v73, v97, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v73, v105, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v82, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v108, v120, a[56:59]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v83, a[4:7]
	v_mfma_f32_16x16x4_f32 a[56:59], v109, v121, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v106, v98, a[52:55]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v84, a[4:7]
	v_mfma_f32_16x16x4_f32 a[52:55], v107, v99, a[52:55]
	v_mfma_f32_16x16x4_f32 a[28:31], v25, v85, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v34, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v108, v100, a[52:55]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v35, a[4:7]
	v_mfma_f32_16x16x4_f32 a[52:55], v109, v101, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v106, v110, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v36, a[4:7]
	v_mfma_f32_16x16x4_f32 a[48:51], v107, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v25, v37, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v78, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v108, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v79, a[4:7]
	v_mfma_f32_16x16x4_f32 a[48:51], v109, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v106, v90, a[44:47]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v80, a[4:7]
	v_mfma_f32_16x16x4_f32 a[44:47], v107, v91, a[44:47]
	v_mfma_f32_16x16x4_f32 a[52:55], v25, v81, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v26, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v108, v92, a[44:47]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v27, a[4:7]
	v_mfma_f32_16x16x4_f32 a[44:47], v109, v93, a[44:47]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v28, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v2, v26, a[20:23]
	v_lshlrev_b32_e32 v26, 13, v125
	v_or3_b32 v26, v26, v30, v31
	s_waitcnt vmcnt(6)
	v_lshl_add_u32 v38, v124, 2, v26
	ds_write_b32 v38, a28
	ds_write_b32 v38, a29 offset:512
	ds_write_b32 v38, a30 offset:1024
	ds_write_b32 v38, a31 offset:1536
	ds_write_b32 v38, a35 offset:1664
	ds_write_b32 v38, a34 offset:1152
	ds_write_b32 v38, a33 offset:640
	ds_write_b32 v38, a32 offset:128
	ds_write_b32 v38, a52 offset:256
	v_lshlrev_b32_e32 v26, 2, v0
	v_or_b32_e32 v0, s14, v0
	v_mfma_f32_16x16x4_f32 a[56:59], v2, v78, a[72:75]
	v_cmp_gt_i32_e64 s[2:3], s13, v0
	v_mfma_f32_16x16x4_f32 a[40:43], v106, v94, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v106, v102, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v2, v82, a[24:27]
	v_mfma_f32_16x16x4_f32 a[48:51], v25, v29, a[4:7]
	ds_write_b32 v38, a53 offset:768
	ds_write_b32 v38, a54 offset:1280
	ds_write_b32 v38, a55 offset:1792
	s_nop 6
	ds_write_b32 v38, a51 offset:1920
	ds_write_b32 v38, a50 offset:1408
	ds_write_b32 v38, a49 offset:896
	ds_write_b32 v38, a48 offset:384
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v6, a[44:47]
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v34, a[68:71]
	v_mfma_f32_16x16x4_f32 a[20:23], v3, v27, a[20:23]
	v_mfma_f32_16x16x4_f32 a[56:59], v3, v79, a[56:59]
	v_mfma_f32_16x16x4_f32 a[40:43], v107, v95, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v107, v103, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v3, v83, a[24:27]
	v_mfma_f32_16x16x4_f32 a[44:47], v3, v35, a[44:47]
	v_mfma_f32_16x16x4_f32 a[20:23], v4, v28, a[20:23]
	v_lshl_or_b32 v28, v122, 9, v26
	v_mad_u64_u32 v[26:27], s[0:1], v1, s17, v[0:1]
	v_mov_b32_e32 v27, 0x40c00000
	s_add_i32 s0, s13, s4
	s_lshl_b32 s22, s0, 2
	s_and_b64 s[0:1], vcc, s[2:3]
	v_mfma_f32_16x16x4_f32 a[56:59], v4, v80, a[56:59]
	v_lshlrev_b32_e32 v39, 2, v26
	v_or_b32_e32 v1, 1, v1
	v_mfma_f32_16x16x4_f32 a[40:43], v108, v96, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v108, v104, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v4, v84, a[24:27]
	v_mfma_f32_16x16x4_f32 a[44:47], v4, v36, a[44:47]
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v29, a[20:23]
	v_mfma_f32_16x16x4_f32 a[0:3], v70, v86, a[0:3]
	v_mfma_f32_16x16x4_f32 a[56:59], v5, v81, a[56:59]
	s_nop 7
	ds_write_b32 v38, a20 offset:16768
	ds_write_b32 v38, a21 offset:17280
	ds_write_b32 v38, a22 offset:17792
	ds_write_b32 v38, a23 offset:18304
	ds_write_b32 v38, a59 offset:18176
	ds_write_b32 v38, a58 offset:17664
	ds_write_b32 v38, a57 offset:17152
	v_mfma_f32_16x16x4_f32 a[40:43], v109, v97, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v109, v105, a[36:39]
	v_mfma_f32_16x16x4_f32 a[24:27], v5, v85, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v37, a[44:47]
	ds_write_b32 v38, a56 offset:16640
	s_nop 7
	s_nop 0
	ds_write_b32 v38, a20 offset:16512
	ds_write_b32 v38, a21 offset:17024
	ds_write_b32 v38, a22 offset:17536
	ds_write_b32 v38, a23 offset:18048
	ds_write_b32 v38, a27 offset:17920
	ds_write_b32 v38, a26 offset:17408
	v_mfma_f32_16x16x4_f32 a[0:3], v71, v87, a[0:3]
	ds_write_b32 v38, a25 offset:16896
	ds_write_b32 v38, a24 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[30:33], v28
	ds_read_b128 v[34:37], v28 offset:16
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v29, 0x40400000, v30
	v_mfma_f32_16x16x4_f32 a[40:43], v22, v10, a[40:43]
	v_med3_f32 v30, v29, 0, v27
	v_add_f32_e32 v29, 0x40400000, v31
	v_med3_f32 v31, v29, 0, v27
	v_add_f32_e32 v29, 0x40400000, v32
	v_med3_f32 v32, v29, 0, v27
	v_add_f32_e32 v29, 0x40400000, v33
	v_med3_f32 v33, v29, 0, v27
	v_mfma_f32_16x16x4_f32 a[24:27], v22, v18, a[36:39]
	v_bfrev_b32_e32 v29, 1
	v_cndmask_b32_e64 v40, v29, 0, s[0:1]
	v_pk_mul_f32 v[32:33], v[32:33], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v40, v40, v39
	buffer_store_dwordx4 v[30:33], v40, s[20:23], 0 offen
	v_or_b32_e32 v40, 4, v0
	v_mfma_f32_16x16x4_f32 a[28:31], v22, v14, a[64:67]
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v30, 0x40400000, v34
	v_add_f32_e32 v31, 0x40400000, v35
	v_add_f32_e32 v32, 0x40400000, v36
	v_add_f32_e32 v33, 0x40400000, v37
	ds_read_b128 v[34:37], v28 offset:32
	v_cmp_gt_i32_e64 s[4:5], s13, v40
	s_and_b64 s[0:1], vcc, s[4:5]
	v_mfma_f32_16x16x4_f32 a[0:3], v72, v88, a[0:3]
	v_med3_f32 v30, v30, 0, v27
	v_med3_f32 v31, v31, 0, v27
	v_med3_f32 v32, v32, 0, v27
	v_med3_f32 v33, v33, 0, v27
	v_cndmask_b32_e64 v40, v29, 0, s[0:1]
	v_pk_mul_f32 v[32:33], v[32:33], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], s[10:11] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v7, a[4:7]
	v_add_u32_e32 v22, v39, v40
	buffer_store_dwordx4 v[30:33], v22, s[20:23], 0 offen offset:16
	v_or_b32_e32 v40, 8, v0
	ds_read_b128 v[30:33], v28 offset:48
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v22, 0x40400000, v34
	v_add_f32_e32 v34, 0x40400000, v35
	v_add_f32_e32 v35, 0x40400000, v37
	v_mfma_f32_16x16x4_f32 a[20:23], v23, v11, a[40:43]
	v_cmp_gt_i32_e64 s[6:7], s13, v40
	v_med3_f32 v22, v22, 0, v27
	v_med3_f32 v35, v35, 0, v27
	s_and_b64 s[0:1], vcc, s[6:7]
	v_mfma_f32_16x16x4_f32 a[24:27], v23, v19, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v23, v15, a[28:31]
	v_med3_f32 v23, v34, 0, v27
	v_add_f32_e32 v34, 0x40400000, v36
	v_med3_f32 v34, v34, 0, v27
	v_pk_mul_f32 v[36:37], v[34:35], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[22:23], s[10:11] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v22, v29, 0, s[0:1]
	v_add_u32_e32 v22, v39, v22
	v_mfma_f32_16x16x4_f32 a[0:3], v73, v89, a[0:3]
	buffer_store_dwordx4 v[34:37], v22, s[20:23], 0 offen offset:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v22, 0x40400000, v30
	v_add_f32_e32 v23, 0x40400000, v31
	v_or_b32_e32 v34, 12, v0
	v_cmp_gt_i32_e64 s[8:9], s13, v34
	s_and_b64 s[0:1], vcc, s[8:9]
	v_add_u32_e32 v35, 12, v26
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v6, a[16:19]
	v_med3_f32 v22, v22, 0, v27
	v_med3_f32 v23, v23, 0, v27
	v_cndmask_b32_e64 v6, v29, 0, s[0:1]
	v_pk_mul_f32 v[22:23], v[22:23], s[10:11] op_sel_hi:[1,0]
	v_lshl_add_u32 v6, v35, 2, v6
	v_cmp_gt_i32_e64 s[0:1], s12, v1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v8, a[4:7]
	v_add_lshl_u32 v1, v35, s17, 2
	s_and_b64 s[6:7], s[0:1], s[6:7]
	s_and_b64 s[4:5], s[0:1], s[4:5]
	s_and_b64 s[2:3], s[2:3], s[0:1]
	v_mfma_f32_16x16x4_f32 a[20:23], v24, v12, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v24, v20, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v24, v16, a[28:31]
	v_add_f32_e32 v24, 0x40400000, v32
	v_med3_f32 v24, v24, 0, v27
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v7, a[16:19]
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v25, v9, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v25, v13, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v25, v21, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v25, v17, a[28:31]
	v_add_f32_e32 v25, 0x40400000, v33
	ds_read_b128 v[30:33], v28 offset:560
	v_med3_f32 v25, v25, 0, v27
	v_pk_mul_f32 v[24:25], v[24:25], s[10:11] op_sel_hi:[1,0]
	buffer_store_dwordx4 v[22:25], v6, s[20:23], 0 offen
	ds_read_b128 v[22:25], v28 offset:544
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v6, 0x40400000, v30
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v18, a[8:11]
	v_add_f32_e32 v7, 0x40400000, v31
	v_med3_f32 v6, v6, 0, v27
	v_med3_f32 v7, v7, 0, v27
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v10, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v8, a[16:19]
	v_add_f32_e32 v8, 0x40400000, v32
	v_med3_f32 v30, v8, 0, v27
	v_add_f32_e32 v8, 0x40400000, v33
	v_med3_f32 v31, v8, 0, v27
	v_pk_mul_f32 v[32:33], v[30:31], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v6, v29, 0, s[8:9]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_add_u32_e32 v6, v1, v6
	buffer_store_dwordx4 v[30:33], v6, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, 0x40400000, v22
	v_add_f32_e32 v7, 0x40400000, v23
	ds_read_b128 v[30:33], v28 offset:528
	v_med3_f32 v6, v6, 0, v27
	v_med3_f32 v7, v7, 0, v27
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v19, a[8:11]
	v_add_f32_e32 v8, 0x40400000, v24
	v_med3_f32 v10, v8, 0, v27
	v_add_f32_e32 v8, 0x40400000, v25
	v_pk_mul_f32 v[22:23], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_mov_b32_e32 v6, 0x7ffffff0
	v_cndmask_b32_e64 v6, v6, -16, s[6:7]
	v_add_u32_e32 v6, v1, v6
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v11, a[12:15]
	v_med3_f32 v11, v8, 0, v27
	v_pk_mul_f32 v[24:25], v[10:11], s[10:11] op_sel_hi:[1,0]
	buffer_store_dwordx4 v[22:25], v6, s[20:23], 0 offen
	ds_read_b128 v[22:25], v28 offset:512
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v6, 0x40400000, v30
	v_add_f32_e32 v7, 0x40400000, v31
	v_med3_f32 v6, v6, 0, v27
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	v_med3_f32 v7, v7, 0, v27
	v_add_f32_e32 v8, 0x40400000, v32
	v_med3_f32 v10, v8, 0, v27
	v_add_f32_e32 v8, 0x40400000, v33
	v_pk_mul_f32 v[30:31], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_mov_b32_e32 v6, 0x7fffffe0
	v_not_b32_e32 v7, 31
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v20, a[8:11]
	v_med3_f32 v11, v8, 0, v27
	v_cndmask_b32_e64 v6, v6, v7, s[4:5]
	v_pk_mul_f32 v[32:33], v[10:11], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v1, v1, v6
	buffer_store_dwordx4 v[30:33], v1, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, 0x40400000, v22
	v_med3_f32 v6, v1, 0, v27
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v12, a[12:15]
	v_add_f32_e32 v1, 0x40400000, v23
	v_med3_f32 v7, v1, 0, v27
	v_add_f32_e32 v1, 0x40400000, v24
	v_med3_f32 v10, v1, 0, v27
	v_add_f32_e32 v1, 0x40400000, v25
	v_med3_f32 v11, v1, 0, v27
	v_cndmask_b32_e64 v1, v29, 0, s[2:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_pk_mul_f32 v[18:19], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v21, a[8:11]
	v_pk_mul_f32 v[20:21], v[10:11], s[10:11] op_sel_hi:[1,0]
	v_add_lshl_u32 v10, v26, s17, 2
	v_add_u32_e32 v1, v1, v10
	buffer_store_dwordx4 v[18:21], v1, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v38, a4
	ds_write_b32 v38, a5 offset:512
	ds_write_b32 v38, a6 offset:1024
	ds_write_b32 v38, a7 offset:1536
	ds_write_b32 v38, a23 offset:1664
	ds_write_b32 v38, a22 offset:1152
	ds_write_b32 v38, a21 offset:640
	ds_write_b32 v38, a20 offset:128
	ds_write_b32 v38, a24 offset:256
	ds_write_b32 v38, a25 offset:768
	ds_write_b32 v38, a26 offset:1280
	ds_write_b32 v38, a27 offset:1792
	ds_write_b32 v38, a31 offset:1920
	ds_write_b32 v38, a30 offset:1408
	ds_write_b32 v38, a29 offset:896
	ds_write_b32 v38, a28 offset:384
	ds_write_b32 v38, a0 offset:16768
	ds_write_b32 v38, a1 offset:17280
	ds_write_b32 v38, a2 offset:17792
	ds_write_b32 v38, a3 offset:18304
	ds_write_b32 v38, a11 offset:18176
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v13, a[12:15]
	ds_write_b32 v38, a10 offset:17664
	ds_write_b32 v38, a9 offset:17152
	ds_write_b32 v38, a8 offset:16640
	s_nop 6
	ds_write_b32 v38, a0 offset:16512
	ds_write_b32 v38, a1 offset:17024
	ds_write_b32 v38, a2 offset:17536
	ds_write_b32 v38, a3 offset:18048
	v_or_b32_e32 v1, 0x80, v0
	v_cmp_gt_i32_e64 s[2:3], s13, v1
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v9, a[16:19]
	s_nop 7
	s_nop 1
	ds_write_b32 v38, a3 offset:17920
	ds_write_b32 v38, a2 offset:17408
	ds_write_b32 v38, a1 offset:16896
	ds_write_b32 v38, a0 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[2:5], v28
	ds_read_b128 v[6:9], v28 offset:16
	s_and_b64 s[4:5], vcc, s[2:3]
	v_add_u32_e32 v11, 0x200, v39
	v_cndmask_b32_e64 v1, v29, 0, s[4:5]
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, 0x40400000, v2
	v_add_f32_e32 v3, 0x40400000, v3
	v_add_f32_e32 v4, 0x40400000, v4
	v_add_f32_e32 v5, 0x40400000, v5
	v_med3_f32 v2, v2, 0, v27
	v_med3_f32 v3, v3, 0, v27
	v_med3_f32 v4, v4, 0, v27
	v_med3_f32 v5, v5, 0, v27
	v_pk_mul_f32 v[4:5], v[4:5], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v1, v11, v1
	buffer_store_dwordx4 v[2:5], v1, s[20:23], 0 offen
	v_or_b32_e32 v1, 0x84, v0
	v_cmp_gt_i32_e64 s[4:5], s13, v1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, 0x40400000, v6
	v_add_f32_e32 v3, 0x40400000, v7
	v_add_f32_e32 v4, 0x40400000, v8
	v_add_f32_e32 v5, 0x40400000, v9
	v_mov_b32_e32 v1, 0x80000010
	s_and_b64 s[6:7], vcc, s[4:5]
	ds_read_b128 v[6:9], v28 offset:32
	v_med3_f32 v2, v2, 0, v27
	v_med3_f32 v3, v3, 0, v27
	v_med3_f32 v4, v4, 0, v27
	v_med3_f32 v5, v5, 0, v27
	v_cndmask_b32_e64 v1, v1, 16, s[6:7]
	v_pk_mul_f32 v[4:5], v[4:5], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v1, v11, v1
	buffer_store_dwordx4 v[2:5], v1, s[20:23], 0 offen
	v_or_b32_e32 v1, 0x88, v0
	v_cmp_gt_i32_e64 s[6:7], s13, v1
	ds_read_b128 v[2:5], v28 offset:48
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v6, 0x40400000, v6
	v_add_f32_e32 v7, 0x40400000, v7
	v_add_f32_e32 v8, 0x40400000, v8
	v_add_f32_e32 v9, 0x40400000, v9
	v_mov_b32_e32 v1, 0x80000020
	s_and_b64 s[8:9], vcc, s[6:7]
	v_med3_f32 v6, v6, 0, v27
	v_med3_f32 v7, v7, 0, v27
	v_med3_f32 v8, v8, 0, v27
	v_med3_f32 v9, v9, 0, v27
	v_cndmask_b32_e64 v1, v1, 32, s[8:9]
	v_pk_mul_f32 v[8:9], v[8:9], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v1, v11, v1
	buffer_store_dwordx4 v[6:9], v1, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, 0x40400000, v3
	v_add_f32_e32 v3, 0x40400000, v5
	v_or_b32_e32 v6, 0x8c, v0
	v_cmp_gt_i32_e64 s[8:9], s13, v6
	v_add_f32_e32 v0, 0x40400000, v2
	v_add_f32_e32 v2, 0x40400000, v4
	v_mov_b32_e32 v8, 0x80000030
	s_and_b64 s[12:13], vcc, s[8:9]
	v_med3_f32 v0, v0, 0, v27
	v_med3_f32 v1, v1, 0, v27
	v_med3_f32 v2, v2, 0, v27
	v_med3_f32 v3, v3, 0, v27
	ds_read_b128 v[4:7], v28 offset:560
	v_cndmask_b32_e64 v8, v8, 48, s[12:13]
	v_pk_mul_f32 v[2:3], v[2:3], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v8, v11, v8
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen
	ds_read_b128 v[0:3], v28 offset:544
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v4, 0x40400000, v4
	v_add_f32_e32 v5, 0x40400000, v5
	v_add_f32_e32 v6, 0x40400000, v6
	v_add_f32_e32 v7, 0x40400000, v7
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_med3_f32 v4, v4, 0, v27
	v_med3_f32 v5, v5, 0, v27
	v_med3_f32 v6, v6, 0, v27
	v_med3_f32 v7, v7, 0, v27
	v_cndmask_b32_e64 v8, v29, 0, s[8:9]
	v_pk_mul_f32 v[6:7], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v8, v10, v8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, 0x40400000, v0
	v_add_f32_e32 v1, 0x40400000, v1
	v_add_f32_e32 v2, 0x40400000, v2
	v_add_f32_e32 v3, 0x40400000, v3
	s_and_b64 s[6:7], s[0:1], s[6:7]
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:560
	v_med3_f32 v0, v0, 0, v27
	v_med3_f32 v1, v1, 0, v27
	v_med3_f32 v2, v2, 0, v27
	v_med3_f32 v3, v3, 0, v27
	ds_read_b128 v[4:7], v28 offset:528
	v_cndmask_b32_e64 v8, v29, 0, s[6:7]
	v_pk_mul_f32 v[2:3], v[2:3], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v8, v10, v8
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen offset:544
	ds_read_b128 v[0:3], v28 offset:512
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v4, 0x40400000, v4
	v_add_f32_e32 v5, 0x40400000, v5
	v_add_f32_e32 v6, 0x40400000, v6
	v_add_f32_e32 v7, 0x40400000, v7
	s_and_b64 s[4:5], s[0:1], s[4:5]
	v_med3_f32 v4, v4, 0, v27
	v_med3_f32 v5, v5, 0, v27
	v_med3_f32 v6, v6, 0, v27
	v_med3_f32 v7, v7, 0, v27
	v_cndmask_b32_e64 v8, v29, 0, s[4:5]
	v_pk_mul_f32 v[6:7], v[6:7], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v8, v10, v8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, 0x40400000, v0
	v_add_f32_e32 v1, 0x40400000, v1
	v_add_f32_e32 v2, 0x40400000, v2
	v_add_f32_e32 v3, 0x40400000, v3
	s_and_b64 s[0:1], s[0:1], s[2:3]
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:528
	v_med3_f32 v0, v0, 0, v27
	v_med3_f32 v1, v1, 0, v27
	v_med3_f32 v2, v2, 0, v27
	v_med3_f32 v3, v3, 0, v27
	v_cndmask_b32_e64 v4, v29, 0, s[0:1]
	v_pk_mul_f32 v[2:3], v[2:3], s[10:11] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], s[10:11] op_sel_hi:[1,0]
	v_add_u32_e32 v4, v10, v4
	buffer_store_dwordx4 v[0:3], v4, s[20:23], 0 offen offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
		.amdhsa_group_segment_fixed_size 40960
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 112
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
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 236
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 160
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 76
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 29
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.protected	c_element_op_size
	.type	c_element_op_size,@object
	.section	.rodata,"a",@progbits
	.globl	c_element_op_size
	.p2align	2, 0x0
c_element_op_size:
	.long	1
	.size	c_element_op_size, 4

	.protected	c_element_op_align
	.type	c_element_op_align,@object
	.globl	c_element_op_align
	.p2align	2, 0x0
c_element_op_align:
	.long	1
	.size	c_element_op_align, 4

	.type	__hip_cuid_ae5f75576ef3a386,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_ae5f75576ef3a386
__hip_cuid_ae5f75576ef3a386:
	.byte	0
	.size	__hip_cuid_ae5f75576ef3a386, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_ae5f75576ef3a386
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:           []
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 4
    .kernarg_segment_size: 0
    .max_flat_workgroup_size: 1024
    .name:           _ZN2ckL12flush_icacheEv
    .private_segment_fixed_size: 0
    .sgpr_count:     6
    .sgpr_spill_count: 0
    .symbol:         _ZN2ckL12flush_icacheEv.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     0
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     76
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 40960
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch11HardsigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     236
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
