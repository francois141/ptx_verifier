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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
	s_load_dwordx8 s[16:23], s[0:1], 0x10
	s_load_dwordx2 s[8:9], s[0:1], 0x60
	s_load_dword s12, s[0:1], 0x68
	s_load_dword s14, s[0:1], 0x3c
	s_load_dwordx4 s[4:7], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_cmp_gt_i32 s22, 1
	s_cselect_b64 s[10:11], -1, 0
	s_bitcmp1_b32 s12, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[10:11], s[10:11], s[12:13]
	s_andn2_b64 vcc, exec, s[10:11]
	s_mov_b64 s[10:11], 0
	s_cbranch_vccnz .LBB1_2
	s_mul_i32 s10, s16, s3
	s_mul_i32 s10, s10, s17
	s_ashr_i32 s11, s10, 31
.LBB1_2:
	s_load_dword s13, s[0:1], 0x34
	s_add_i32 s12, s16, -1
	s_cmp_lt_u32 s12, 64
	s_mov_b32 s15, 0
	s_cbranch_scc1 .LBB1_10
	s_add_i32 s0, s17, -1
	s_cmpk_lt_u32 s0, 0x100
	s_mov_b32 s0, 0
	s_cbranch_scc1 .LBB1_9
	s_add_i32 s0, s16, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s23, s0, 6
	s_add_i32 s0, s17, 0xff
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 24
	s_add_i32 s0, s0, s1
	s_ashr_i32 s15, s0, 8
	s_mul_i32 s0, s15, s23
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
	s_abs_i32 s1, s15
	v_cvt_f32_u32_e32 v1, s1
	s_sub_i32 s25, 0, s1
	s_add_i32 s0, s2, s0
	s_abs_i32 s24, s0
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s2, s0, s15
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
	s_mul_i32 s2, s1, s15
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
	s_mul_i32 s15, s23, s15
	s_add_i32 s15, s15, s0
	s_abs_i32 s25, s15
	v_readfirstlane_b32 s27, v1
	s_mul_i32 s26, s26, s27
	s_mul_hi_u32 s26, s27, s26
	s_add_i32 s27, s27, s26
	s_mul_hi_u32 s26, s25, s27
	s_mul_i32 s27, s26, s24
	s_xor_b32 s0, s15, s2
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
	s_sub_i32 s2, s15, s2
	s_add_i32 s2, s2, s1
	s_sub_i32 s2, s2, s23
.LBB1_9:
	s_mov_b32 s15, s2
	s_mov_b32 s2, s0
.LBB1_10:
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s13, s3
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[24:25], s[0:1], 2
	s_add_u32 s0, s4, s24
	s_addc_u32 s1, s5, s25
	s_add_u32 s4, s6, s24
	s_addc_u32 s5, s7, s25
	s_add_i32 s22, s22, -1
	s_mul_i32 s23, s22, s13
	v_lshrrev_b32_e32 v123, 2, v0
	s_add_i32 s7, s17, 0x3fffffff
	s_sub_i32 s18, s18, s23
	v_and_b32_e32 v127, 7, v0
	v_and_b32_e32 v1, 62, v123
	s_cmp_lt_u32 s3, s22
	v_bitop3_b32 v155, v123, v127, 6 bitop3:0x6c
	v_lshlrev_b32_e32 v3, 5, v1
	s_cselect_b32 s18, s13, s18
	s_lshl_b32 s13, s2, 8
	v_lshl_or_b32 v42, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v122, s15, 6, v1
	v_or_b32_e32 v150, s13, v3
	s_ashr_i32 s2, s14, 31
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v122, s19
	v_mul_lo_u32 v152, v150, s20
	s_lshr_b32 s2, s2, 29
	v_add_u32_e32 v22, v154, v2
	v_add_u32_e32 v10, v152, v2
	v_lshl_or_b32 v43, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_add_i32 s14, s14, s2
	s_mul_i32 s6, s12, s19
	s_mul_i32 s7, s7, s20
	v_and_b32_e32 v26, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v50, 6, v2
	v_bitop3_b32 v51, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v44, v126, v124
	s_ashr_i32 s14, s14, 3
	s_add_i32 s2, s18, s6
	s_mov_b32 s3, 0x20000
	s_add_i32 s18, s18, s7
	v_add_u32_e32 v18, s20, v10
	s_lshl_b32 s2, s2, 2
	v_lshlrev_b32_e32 v2, 2, v22
	v_add_lshl_u32 v6, v22, s19, 2
	s_lshl_b32 s6, s18, 2
	s_mov_b32 s7, s3
	v_lshlrev_b32_e32 v11, 2, v10
	v_lshlrev_b32_e32 v14, 2, v18
	buffer_load_dwordx4 v[2:5], v2, s[0:3], 0 offen
	buffer_load_dwordx4 v[6:9], v6, s[0:3], 0 offen
	buffer_load_dwordx4 v[10:13], v11, s[4:7], 0 offen
	buffer_load_dwordx4 v[14:17], v14, s[4:7], 0 offen
	v_add_u32_e32 v23, s20, v18
	v_lshlrev_b32_e32 v18, 2, v23
	buffer_load_dwordx4 v[18:21], v18, s[4:7], 0 offen
	v_add_u32_e32 v27, s20, v23
	v_add_u32_e32 v30, s20, v27
	v_add_u32_e32 v45, 32, v22
	v_lshlrev_b32_e32 v22, 2, v27
	v_bitop3_b32 v47, v26, v127, 1 bitop3:0x36
	v_lshlrev_b32_e32 v26, 2, v30
	v_add_u32_e32 v34, s20, v30
	buffer_load_dwordx4 v[22:25], v22, s[4:7], 0 offen
	buffer_load_dwordx4 v[26:29], v26, s[4:7], 0 offen
	v_lshlrev_b32_e32 v30, 2, v34
	v_add_u32_e32 v38, s20, v34
	buffer_load_dwordx4 v[30:33], v30, s[4:7], 0 offen
	v_lshlrev_b32_e32 v34, 2, v38
	buffer_load_dwordx4 v[34:37], v34, s[4:7], 0 offen
	v_add_u32_e32 v54, s20, v38
	v_lshlrev_b32_e32 v38, 2, v54
	buffer_load_dwordx4 v[38:41], v38, s[4:7], 0 offen
	s_mul_i32 s15, s20, -7
	v_sub_u32_e32 v53, v47, v155
	v_sub_u32_e32 v47, v155, v47
	v_lshlrev_b32_e32 v56, 2, v45
	v_add_lshl_u32 v45, v45, s19, 2
	v_lshlrev_b32_e32 v57, 2, v53
	v_lshlrev_b32_e32 v47, 2, v47
	buffer_load_dwordx4 v[98:101], v56, s[0:3], 0 offen
	buffer_load_dwordx4 v[58:61], v45, s[0:3], 0 offen
	v_add3_u32 v45, s15, 32, v54
	v_add3_u32 v156, v57, v42, v47
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s20, v45
	v_lshlrev_b32_e32 v54, 2, v45
	v_add_u32_e32 v45, s20, v45
	buffer_load_dwordx4 v[66:69], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[62:65], v54, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s20, v45
	v_lshlrev_b32_e32 v54, 2, v45
	v_add_u32_e32 v45, s20, v45
	buffer_load_dwordx4 v[78:81], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[74:77], v54, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s20, v45
	v_lshlrev_b32_e32 v54, 2, v45
	v_add_u32_e32 v45, s20, v45
	buffer_load_dwordx4 v[82:85], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[86:89], v54, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_lshl_u32 v45, v45, s20, 2
	buffer_load_dwordx4 v[90:93], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[94:97], v45, s[4:7], 0 offen
	v_bitop3_b32 v49, v0, 1, 7 bitop3:0x6c
	v_sub_u32_e32 v55, v49, v127
	v_lshlrev_b32_e32 v46, 2, v42
	v_lshlrev_b32_e32 v48, 2, v43
	s_movk_i32 s18, 0x2000
	v_lshlrev_b32_e32 v138, 4, v55
	v_bitop3_b32 v52, v0, 2, 7 bitop3:0x6c
	v_lshl_add_u32 v53, v53, 4, v46
	v_add3_u32 v42, v48, s18, v138
	v_sub_u32_e32 v49, v52, v49
	v_lshl_add_u32 v43, v55, 2, v43
	v_lshlrev_b32_e32 v139, 4, v49
	s_movk_i32 s15, 0x80
	v_mov_b32_e32 v136, 0xffffff20
	s_waitcnt vmcnt(19)
	ds_write_b128 v46, v[2:5]
	s_waitcnt vmcnt(18)
	ds_write_b128 v53, v[6:9] offset:128
	s_waitcnt vmcnt(17)
	ds_write_b128 v48, v[10:13] offset:8192
	s_waitcnt vmcnt(16)
	ds_write_b128 v42, v[14:17] offset:128
	v_bitop3_b32 v3, v0, 3, 7 bitop3:0x6c
	v_sub_u32_e32 v4, v3, v52
	v_bitop3_b32 v6, v0, 4, 7 bitop3:0x6c
	v_bitop3_b32 v8, v0, 5, 7 bitop3:0x6c
	v_lshlrev_b32_e32 v2, 2, v49
	v_lshlrev_b32_e32 v5, 2, v4
	v_sub_u32_e32 v3, v6, v3
	v_sub_u32_e32 v6, v8, v6
	v_add3_u32 v2, v43, v2, v5
	v_add3_u32 v5, v42, s15, v139
	v_lshlrev_b32_e32 v7, 2, v3
	v_lshlrev_b32_e32 v9, 2, v6
	v_lshlrev_b32_e32 v140, 4, v4
	s_waitcnt vmcnt(15)
	ds_write_b128 v5, v[18:21] offset:128
	v_add3_u32 v2, v2, v7, v9
	v_add3_u32 v4, v5, s15, v140
	v_bitop3_b32 v5, v0, 6, 7 bitop3:0x6c
	v_bitop3_b32 v9, v0, 7, v0 bitop3:0xc
	v_sub_u32_e32 v7, v5, v8
	v_sub_u32_e32 v5, v9, v5
	v_lshlrev_b32_e32 v8, 2, v7
	v_lshlrev_b32_e32 v10, 2, v5
	v_lshlrev_b32_e32 v141, 4, v3
	v_add3_u32 v133, v2, v8, v10
	v_add3_u32 v2, v4, s15, v141
	v_lshlrev_b32_e32 v142, 4, v6
	s_waitcnt vmcnt(14)
	ds_write_b128 v4, v[22:25] offset:128
	s_waitcnt vmcnt(13)
	ds_write_b128 v2, v[26:29] offset:128
	v_add3_u32 v2, v2, s15, v142
	v_lshlrev_b32_e32 v143, 4, v7
	s_waitcnt vmcnt(12)
	ds_write_b128 v2, v[30:33] offset:128
	v_add3_u32 v2, v2, s15, v143
	v_lshlrev_b32_e32 v3, 4, v5
	s_waitcnt vmcnt(11)
	ds_write_b128 v2, v[34:37] offset:128
	v_add3_u32 v135, v2, s15, v3
	v_lshlrev_b32_e32 v2, 7, v124
	v_lshlrev_b32_e32 v3, 11, v125
	v_lshlrev_b32_e32 v4, 4, v51
	v_or3_b32 v128, v3, v2, v4
	v_bitop3_b32 v2, v50, v127, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v51
	v_lshl_or_b32 v6, v44, 7, v4
	v_lshlrev_b32_e32 v7, 4, v2
	v_or_b32_e32 v129, 0x2000, v6
	v_add_u32_e32 v130, v128, v7
	v_add_u32_e32 v131, v7, v6
	v_sub_u32_e32 v134, v127, v9
	s_waitcnt vmcnt(10)
	ds_write_b128 v135, v[38:41] offset:128
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[46:49], v128
	ds_read_b128 v[26:29], v128 offset:4096
	ds_read_b128 v[114:117], v6 offset:8192
	ds_read_b128 v[118:121], v6 offset:12288
	ds_read_b128 v[106:109], v6 offset:16384
	ds_read_b128 v[110:113], v6 offset:20480
	ds_read_b128 v[42:45], v6 offset:24576
	ds_read_b128 v[38:41], v6 offset:28672
	ds_read_b128 v[34:37], v6 offset:32768
	ds_read_b128 v[30:33], v6 offset:36864
	ds_read_b128 v[22:25], v130
	ds_read_b128 v[2:5], v130 offset:4096
	v_add_u32_e32 v132, v129, v7
	ds_read_b128 v[70:73], v131 offset:8192
	ds_read_b128 v[102:105], v132 offset:4096
	ds_read_b128 v[54:57], v132 offset:8192
	ds_read_b128 v[50:53], v132 offset:12288
	ds_read_b128 v[6:9], v132 offset:16384
	ds_read_b128 v[10:13], v132 offset:20480
	ds_read_b128 v[18:21], v132 offset:24576
	ds_read_b128 v[14:17], v132 offset:28672
	v_lshl_add_u32 v136, v134, 2, v136
	v_add_lshl_u32 v137, v133, v136, 2
	v_add_u32_e32 v133, 0x80, v135
	v_lshl_add_u32 v136, v136, 2, v133
	s_movk_i32 s18, 0x2400
	v_add3_u32 v137, v138, v137, s18
	v_add_u32_e32 v138, v136, v138
	s_movk_i32 s18, 0x100
	v_add3_u32 v138, v138, v139, s18
	v_add3_u32 v139, v138, v140, s15
	v_or_b32_e32 v134, 1, v123
	v_add3_u32 v140, v139, v141, s15
	v_or_b32_e32 v145, 7, v150
	v_or_b32_e32 v146, 6, v150
	v_or_b32_e32 v147, 5, v150
	v_or_b32_e32 v148, 4, v150
	v_or_b32_e32 v149, 3, v150
	v_or_b32_e32 v150, 2, v150
	s_max_i32 s14, s14, 2
	v_sub_u32_e32 v144, v134, v1
	v_add3_u32 v141, v140, v142, s15
	v_mul_lo_u32 v145, s20, v145
	v_mov_b32_e32 v157, 0x100
	v_mul_lo_u32 v146, s20, v146
	v_mul_lo_u32 v147, s20, v147
	v_mul_lo_u32 v148, s20, v148
	v_mul_lo_u32 v149, s20, v149
	v_mul_lo_u32 v150, s20, v150
	v_add_u32_e32 v151, s20, v152
	v_add_u32_e32 v153, s19, v154
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
	s_add_i32 s14, s14, -1
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	v_accvgpr_write_b32 a43, 0
	v_accvgpr_write_b32 a42, 0
	v_accvgpr_write_b32 a41, 0
	v_accvgpr_write_b32 a40, 0
	v_accvgpr_write_b32 a39, 0
	v_accvgpr_write_b32 a38, 0
	v_accvgpr_write_b32 a37, 0
	v_accvgpr_write_b32 a36, 0
	v_accvgpr_write_b32 a35, 0
	v_accvgpr_write_b32 a34, 0
	v_accvgpr_write_b32 a33, 0
	v_accvgpr_write_b32 a32, 0
	v_accvgpr_write_b32 a31, 0
	v_accvgpr_write_b32 a30, 0
	v_accvgpr_write_b32 a29, 0
	v_accvgpr_write_b32 a28, 0
	v_accvgpr_write_b32 a19, 0
	v_accvgpr_write_b32 a18, 0
	v_accvgpr_write_b32 a17, 0
	v_accvgpr_write_b32 a16, 0
	v_accvgpr_write_b32 a23, 0
	v_accvgpr_write_b32 a22, 0
	v_accvgpr_write_b32 a21, 0
	v_accvgpr_write_b32 a20, 0
	v_accvgpr_write_b32 a27, 0
	v_accvgpr_write_b32 a26, 0
	v_accvgpr_write_b32 a25, 0
	v_accvgpr_write_b32 a24, 0
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
	s_movk_i32 s15, 0xffe0
.LBB1_11:
	v_lshlrev_b32_e32 v157, 2, v156
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(9)
	ds_write_b128 v157, v[98:101]
	v_add_u32_e32 v98, v144, v154
	v_mfma_f32_16x16x4_f32 a[60:63], v46, v114, a[60:63]
	buffer_load_dwordx4 v[98:101], v98, s[0:3], 0 offen
	v_ashrrev_i32_e32 v157, 31, v134
	v_lshrrev_b32_e32 v157, 29, v157
	v_add_u32_e32 v157, v134, v157
	v_and_b32_e32 v157, -8, v157
	v_sub_u32_e32 v157, v134, v157
	v_xor_b32_e32 v157, v157, v127
	v_mfma_f32_16x16x4_f32 a[56:59], v46, v118, a[56:59]
	v_sub_u32_e32 v155, v157, v155
	v_lshlrev_b32_e32 v155, 2, v155
	v_add3_u32 v156, v156, v135, v155
	v_lshlrev_b32_e32 v155, 2, v156
	v_mfma_f32_16x16x4_f32 a[60:63], v47, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v47, v119, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v46, v106, a[52:55]
	v_mfma_f32_16x16x4_f32 a[60:63], v48, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v48, v120, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v47, v107, a[52:55]
	v_mfma_f32_16x16x4_f32 a[60:63], v49, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v49, v121, a[56:59]
	s_waitcnt vmcnt(9)
	ds_write_b128 v155, v[58:61]
	v_add_u32_e32 v58, v144, v153
	v_mfma_f32_16x16x4_f32 a[52:55], v48, v108, a[52:55]
	buffer_load_dwordx4 v[58:61], v58, s[0:3], 0 offen
	v_mfma_f32_16x16x4_f32 a[48:51], v46, v110, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v46, v42, a[44:47]
	v_mfma_f32_16x16x4_f32 a[48:51], v47, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v47, v43, a[44:47]
	v_mfma_f32_16x16x4_f32 a[48:51], v48, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v48, v44, a[44:47]
	v_mfma_f32_16x16x4_f32 a[52:55], v49, v109, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v49, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[44:47], v49, v45, a[44:47]
	s_waitcnt vmcnt(9)
	ds_write_b128 v136, v[66:69]
	v_add_u32_e32 v66, v144, v152
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[24:27]
	buffer_load_dwordx4 v[66:69], v66, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v34, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v46, v30, a[16:19]
	v_add_u32_e32 v46, v144, v151
	v_mfma_f32_16x16x4_f32 a[24:27], v47, v39, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v35, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v31, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v48, v40, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v36, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v49, v41, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v49, v37, a[20:23]
	s_waitcnt vmcnt(9)
	ds_write_b128 v137, v[62:65]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v32, a[16:19]
	buffer_load_dwordx4 v[62:65], v46, s[4:7], 0 offen
	v_add_u32_e32 v46, v144, v150
	v_mfma_f32_16x16x4_f32 a[28:31], v26, v114, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v26, v118, a[32:35]
	v_mfma_f32_16x16x4_f32 a[28:31], v27, v115, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v27, v119, a[32:35]
	v_mfma_f32_16x16x4_f32 a[28:31], v28, v116, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v28, v120, a[32:35]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v33, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v29, v117, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v29, v121, a[32:35]
	s_waitcnt vmcnt(9)
	ds_write_b128 v138, v[78:81]
	v_mfma_f32_16x16x4_f32 a[36:39], v26, v106, a[36:39]
	buffer_load_dwordx4 v[78:81], v46, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[40:43], v26, v110, a[40:43]
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v42, a[12:15]
	v_add_u32_e32 v42, v144, v149
	v_mfma_f32_16x16x4_f32 a[36:39], v27, v107, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v27, v111, a[40:43]
	v_mfma_f32_16x16x4_f32 a[12:15], v27, v43, a[12:15]
	v_mfma_f32_16x16x4_f32 a[36:39], v28, v108, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v28, v112, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v29, v109, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v29, v113, a[40:43]
	s_waitcnt vmcnt(9)
	ds_write_b128 v139, v[74:77]
	v_mfma_f32_16x16x4_f32 a[12:15], v28, v44, a[12:15]
	buffer_load_dwordx4 v[74:77], v42, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[8:11], v26, v38, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v26, v34, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v27, v39, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v35, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v28, v40, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v28, v36, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v29, v45, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v29, v41, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v29, v37, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v140, v[82:85]
	v_mfma_f32_16x16x4_f32 a[0:3], v26, v30, a[0:3]
	v_add_u32_e32 v26, v144, v148
	buffer_load_dwordx4 v[82:85], v26, s[4:7], 0 offen
	v_add_u32_e32 v26, v144, v147
	v_mfma_f32_16x16x4_f32 a[60:63], v22, v70, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v22, v102, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v18, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v23, v71, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v23, v103, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v19, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v24, v72, a[60:63]
	s_waitcnt vmcnt(9)
	ds_write_b128 v141, v[86:89]
	v_mfma_f32_16x16x4_f32 a[0:3], v29, v33, a[0:3]
	buffer_load_dwordx4 v[86:89], v26, s[4:7], 0 offen
	v_add_u32_e32 v26, v144, v146
	v_mfma_f32_16x16x4_f32 a[56:59], v24, v104, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v22, v54, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v22, v50, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v20, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v25, v73, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v25, v105, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v23, v55, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v23, v51, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v21, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v142, v[90:93] offset:128
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	buffer_load_dwordx4 v[90:93], v26, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[52:55], v24, v56, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v24, v52, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_mfma_f32_16x16x4_f32 a[44:47], v22, v6, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v22, v10, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v22, v18, a[20:23]
	v_add_u32_e32 v18, v144, v145
	v_mfma_f32_16x16x4_f32 a[52:55], v25, v57, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v25, v53, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	s_waitcnt vmcnt(9)
	ds_write_b128 v133, v[94:97]
	v_mfma_f32_16x16x4_f32 a[44:47], v23, v7, a[44:47]
	buffer_load_dwordx4 v[94:97], v18, s[4:7], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[24:27], v23, v11, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v23, v19, a[20:23]
	v_mfma_f32_16x16x4_f32 a[44:47], v24, v8, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v24, v12, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[44:47], v25, v9, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v25, v13, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v24, v20, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v22, v14, a[16:19]
	ds_read_b128 v[46:49], v128
	v_mfma_f32_16x16x4_f32 a[28:31], v2, v70, a[28:31]
	ds_read_b128 v[26:29], v128 offset:4096
	v_mfma_f32_16x16x4_f32 a[20:23], v25, v21, a[20:23]
	ds_read_b128 v[114:117], v129
	v_mfma_f32_16x16x4_f32 a[16:19], v23, v15, a[16:19]
	ds_read_b128 v[118:121], v129 offset:4096
	v_mfma_f32_16x16x4_f32 a[28:31], v3, v71, a[28:31]
	ds_read_b128 v[106:109], v129 offset:8192
	v_mfma_f32_16x16x4_f32 a[16:19], v24, v16, a[16:19]
	ds_read_b128 v[110:113], v129 offset:12288
	v_mfma_f32_16x16x4_f32 a[28:31], v4, v72, a[28:31]
	ds_read_b128 v[42:45], v129 offset:16384
	v_mfma_f32_16x16x4_f32 a[16:19], v25, v17, a[16:19]
	ds_read_b128 v[38:41], v129 offset:20480
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v73, a[28:31]
	ds_read_b128 v[34:37], v129 offset:24576
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v102, a[32:35]
	ds_read_b128 v[30:33], v129 offset:28672
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v103, a[32:35]
	ds_read_b128 v[22:25], v130
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v104, a[32:35]
	ds_read_b128 v[70:73], v131 offset:8192
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v6, a[12:15]
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v105, a[32:35]
	ds_read_b128 v[102:105], v132 offset:4096
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v54, a[36:39]
	ds_read_b128 v[18:21], v132 offset:24576
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v7, a[12:15]
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v55, a[36:39]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v8, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v10, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v9, a[12:15]
	ds_read_b128 v[6:9], v132 offset:16384
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v56, a[36:39]
	ds_read_b128 v[14:17], v132 offset:28672
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v11, a[8:11]
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v57, a[36:39]
	ds_read_b128 v[54:57], v132 offset:8192
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v50, a[40:43]
	v_add_u32_e32 v2, -1, v134
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v12, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v13, a[8:11]
	ds_read_b128 v[10:13], v132 offset:20480
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v51, a[40:43]
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	v_and_b32_e32 v3, -8, v3
	v_sub_u32_e32 v155, v2, v3
	v_xor_b32_e32 v155, v155, v127
	v_sub_u32_e32 v157, v155, v157
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v52, a[40:43]
	v_lshlrev_b32_e32 v157, 2, v157
	v_add3_u32 v156, v157, v156, s15
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v53, a[40:43]
	ds_read_b128 v[2:5], v130 offset:4096
	ds_read_b128 v[50:53], v132 offset:12288
	s_add_i32 s14, s14, -1
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
	s_cmp_lg_u32 s14, 0
	v_add_u32_e32 v154, 0x80, v154
	s_cbranch_scc1 .LBB1_11
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[60:63], v46, v114, a[60:63]
	v_lshlrev_b32_e32 v0, 4, v0
	v_and_b32_e32 v0, 0x70, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s24, s8, s0
	s_mul_i32 s0, s12, s21
	v_mfma_f32_16x16x4_f32 a[56:59], v46, v118, a[56:59]
	s_mul_hi_u32 s4, 0, s21
	s_mov_b32 s15, 0xc2aeac50
	s_addc_u32 s25, s9, s1
	s_add_i32 s4, s4, s0
	s_mov_b32 s18, 0x3f867d5f
	s_mov_b32 s14, 0x3fe10966
	s_mov_b32 s27, 0x20000
	v_mfma_f32_16x16x4_f32 a[52:55], v46, v106, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v26, v118, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v26, v110, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v46, v110, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v26, v106, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v26, v114, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v47, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v47, v119, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v47, v107, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v27, v119, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v27, v111, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v47, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v27, v107, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v27, v115, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v48, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v48, v120, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v48, v108, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v28, v120, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v28, v112, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v48, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v28, v108, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v28, v116, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v49, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v49, v121, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v49, v109, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v29, v121, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v29, v113, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v49, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v29, v109, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v29, v117, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v22, v70, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v22, v102, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v22, v54, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v102, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v50, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v22, v50, a[48:51]
	v_or_b32_e32 v50, s13, v0
	v_lshlrev_b32_e32 v0, 2, v0
	v_cmp_gt_i32_e64 s[2:3], s17, v50
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v54, a[36:39]
	v_and_b32_e32 v54, 12, v123
	v_lshlrev_b32_e32 v54, 9, v54
	v_mfma_f32_16x16x4_f32 a[28:31], v2, v70, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v23, v71, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v23, v103, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v23, v55, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v103, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v51, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v23, v51, a[48:51]
	v_lshlrev_b32_e32 v51, 2, v126
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v55, a[36:39]
	v_lshlrev_b32_e32 v55, 13, v125
	v_or3_b32 v51, v55, v54, v51
	v_lshl_add_u32 v54, v124, 2, v51
	v_lshl_or_b32 v51, v1, 9, v0
	v_mfma_f32_16x16x4_f32 a[28:31], v3, v71, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v24, v72, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v24, v104, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v24, v56, a[52:55]
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v104, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v52, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v24, v52, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v56, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v4, v72, a[28:31]
	v_mfma_f32_16x16x4_f32 a[60:63], v25, v73, a[60:63]
	s_nop 7
	s_nop 1
	ds_write_b32 v54, a60
	ds_write_b32 v54, a61 offset:512
	ds_write_b32 v54, a62 offset:1024
	ds_write_b32 v54, a63 offset:1536
	v_mfma_f32_16x16x4_f32 a[56:59], v25, v105, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v25, v57, a[52:55]
	s_nop 7
	s_nop 0
	ds_write_b32 v54, a59 offset:1664
	ds_write_b32 v54, a58 offset:1152
	ds_write_b32 v54, a57 offset:640
	ds_write_b32 v54, a56 offset:128
	ds_write_b32 v54, a52 offset:256
	ds_write_b32 v54, a53 offset:768
	ds_write_b32 v54, a54 offset:1280
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v105, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v53, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v25, v53, a[48:51]
	ds_write_b32 v54, a55 offset:1792
	s_nop 7
	s_nop 0
	ds_write_b32 v54, a51 offset:1920
	ds_write_b32 v54, a50 offset:1408
	ds_write_b32 v54, a49 offset:896
	ds_write_b32 v54, a48 offset:384
	ds_write_b32 v54, a40 offset:16768
	ds_write_b32 v54, a41 offset:17280
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v57, a[36:39]
	ds_write_b32 v54, a42 offset:17792
	ds_write_b32 v54, a43 offset:18304
	s_nop 7
	ds_write_b32 v54, a39 offset:18176
	ds_write_b32 v54, a38 offset:17664
	ds_write_b32 v54, a37 offset:17152
	ds_write_b32 v54, a36 offset:16640
	ds_write_b32 v54, a32 offset:16512
	v_mad_u64_u32 v[52:53], s[0:1], v122, s21, v[50:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v73, a[28:31]
	ds_write_b32 v54, a33 offset:17024
	ds_write_b32 v54, a34 offset:17536
	ds_write_b32 v54, a35 offset:18048
	s_nop 6
	ds_write_b32 v54, a31 offset:17920
	ds_write_b32 v54, a30 offset:17408
	ds_write_b32 v54, a29 offset:16896
	ds_write_b32 v54, a28 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(8)
	ds_read_b128 v[56:59], v51
	v_mfma_f32_16x16x4_f32 a[44:47], v46, v42, a[44:47]
	s_waitcnt vmcnt(6)
	ds_read_b128 v[60:63], v51 offset:16
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v0, 0x42800000, v56
	v_cmp_gt_f32_e32 vcc, s15, v56
	v_add_f32_e32 v1, 0x42800000, v57
	v_cmp_gt_f32_e64 s[0:1], s15, v57
	v_cndmask_b32_e32 v0, v56, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_cndmask_b32_e64 v1, v57, v1, s[0:1]
	v_exp_f32_e32 v0, v0
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[24:27]
	v_mul_f32_e32 v53, 0x114b4ea4, v0
	v_cndmask_b32_e32 v64, v0, v53, vcc
	v_mul_f32_e32 v0, 0x114b4ea4, v1
	v_cndmask_b32_e64 v65, v1, v0, s[0:1]
	v_add_f32_e32 v0, 0x42800000, v58
	v_cmp_gt_f32_e32 vcc, s15, v58
	v_add_f32_e32 v1, 0x42800000, v59
	v_cmp_gt_f32_e64 s[0:1], s15, v59
	v_cndmask_b32_e32 v0, v58, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_cndmask_b32_e64 v1, v59, v1, s[0:1]
	v_exp_f32_e32 v0, v0
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v34, a[20:23]
	v_mul_f32_e32 v53, 0x114b4ea4, v0
	v_cndmask_b32_e32 v66, v0, v53, vcc
	v_mul_f32_e32 v0, 0x114b4ea4, v1
	v_cndmask_b32_e64 v67, v1, v0, s[0:1]
	s_mov_b32 s0, 0xbfe10966
	v_mov_b64_e32 v[0:1], s[0:1]
	v_pk_mul_f32 v[68:69], v[58:59], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[16:19], v46, v30, a[16:19]
	v_pk_fma_f32 v[66:67], v[66:67], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e32 vcc, 0, v59
	v_pk_mul_f32 v[70:71], v[56:57], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[64:65], v[64:65], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e32 v59, v67, v69, vcc
	v_cmp_lt_f32_e32 vcc, 0, v58
	s_add_i32 s0, s17, s4
	v_mfma_f32_16x16x4_f32 a[44:47], v47, v43, a[44:47]
	v_cndmask_b32_e32 v58, v66, v68, vcc
	v_cmp_lt_f32_e32 vcc, 0, v57
	s_lshl_b32 s26, s0, 2
	v_bfrev_b32_e32 v46, 1
	v_cndmask_b32_e32 v57, v65, v71, vcc
	v_cmp_lt_f32_e32 vcc, 0, v56
	v_lshlrev_b32_e32 v53, 2, v52
	v_mfma_f32_16x16x4_f32 a[24:27], v47, v39, a[24:27]
	v_cndmask_b32_e32 v56, v64, v70, vcc
	v_cmp_gt_i32_e32 vcc, s16, v122
	s_and_b64 s[0:1], vcc, s[2:3]
	v_cndmask_b32_e64 v55, v46, 0, s[0:1]
	v_add_u32_e32 v55, v55, v53
	buffer_store_dwordx4 v[56:59], v55, s[24:27], 0 offen
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v55, 0x42800000, v60
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v35, a[20:23]
	v_cmp_gt_f32_e64 s[0:1], s15, v60
	v_cmp_gt_f32_e64 s[4:5], s15, v61
	v_add_f32_e32 v57, 0x42800000, v63
	v_cndmask_b32_e64 v55, v60, v55, s[0:1]
	v_mul_f32_e32 v55, 0x3fb8aa3b, v55
	v_exp_f32_e32 v55, v55
	v_cmp_gt_f32_e64 s[6:7], s15, v63
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v31, a[16:19]
	v_or_b32_e32 v47, 4, v50
	v_pk_mul_f32 v[64:65], v[60:61], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v42, a[12:15]
	v_cndmask_b32_e64 v42, v63, v57, s[6:7]
	v_mul_f32_e32 v42, 0x3fb8aa3b, v42
	v_exp_f32_e32 v57, v42
	v_mfma_f32_16x16x4_f32 a[44:47], v48, v44, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v48, v40, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v36, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v32, a[16:19]
	v_add_f32_e32 v48, 0x42800000, v61
	v_cndmask_b32_e64 v48, v61, v48, s[4:5]
	v_mul_f32_e32 v48, 0x3fb8aa3b, v48
	v_exp_f32_e32 v56, v48
	v_mul_f32_e32 v48, 0x114b4ea4, v55
	v_cndmask_b32_e64 v48, v55, v48, s[0:1]
	v_add_f32_e32 v55, 0x42800000, v62
	v_mfma_f32_16x16x4_f32 a[12:15], v27, v43, a[12:15]
	v_cmp_gt_f32_e64 s[0:1], s15, v62
	s_nop 1
	v_cndmask_b32_e64 v55, v62, v55, s[0:1]
	v_mul_f32_e32 v55, 0x3fb8aa3b, v55
	v_exp_f32_e32 v55, v55
	v_mfma_f32_16x16x4_f32 a[12:15], v28, v44, a[12:15]
	v_mul_f32_e32 v42, 0x114b4ea4, v55
	v_cndmask_b32_e64 v42, v55, v42, s[0:1]
	v_mul_f32_e32 v55, 0x114b4ea4, v57
	v_cndmask_b32_e64 v43, v57, v55, s[6:7]
	v_pk_fma_f32 v[42:43], v[42:43], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[0:1], 0, v63
	v_mfma_f32_16x16x4_f32 a[8:11], v26, v38, a[8:11]
	v_mfma_f32_16x16x4_f32 a[44:47], v49, v45, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v49, v41, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v49, v37, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v33, a[16:19]
	v_mul_f32_e32 v49, 0x114b4ea4, v56
	v_cndmask_b32_e64 v49, v56, v49, s[4:5]
	v_pk_mul_f32 v[56:57], v[62:63], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[48:49], v[48:49], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v59, v43, v57, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v62
	v_cmp_gt_i32_e64 s[4:5], s17, v47
	v_mfma_f32_16x16x4_f32 a[12:15], v29, v45, a[12:15]
	v_cndmask_b32_e64 v58, v42, v56, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v61
	ds_read_b128 v[42:45], v51 offset:32
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[6:7], s15, v43
	v_cndmask_b32_e64 v57, v49, v65, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v60
	v_mfma_f32_16x16x4_f32 a[8:11], v27, v39, a[8:11]
	v_add_f32_e32 v49, 0x42800000, v44
	v_cndmask_b32_e64 v56, v48, v64, s[0:1]
	s_and_b64 s[0:1], vcc, s[4:5]
	v_cndmask_b32_e64 v47, v46, 0, s[0:1]
	v_add_u32_e32 v47, v53, v47
	buffer_store_dwordx4 v[56:59], v47, s[24:27], 0 offen offset:16
	v_add_f32_e32 v47, 0x42800000, v42
	v_cmp_gt_f32_e64 s[0:1], s15, v42
	v_mfma_f32_16x16x4_f32 a[8:11], v28, v40, a[8:11]
	v_cmp_gt_f32_e64 s[8:9], s15, v45
	v_cndmask_b32_e64 v38, v42, v47, s[0:1]
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v38
	v_add_f32_e32 v47, 0x42800000, v43
	v_cndmask_b32_e64 v47, v43, v47, s[6:7]
	v_mul_f32_e32 v39, 0x3fb8aa3b, v47
	v_mul_f32_e32 v48, 0x114b4ea4, v38
	v_cndmask_b32_e64 v38, v38, v48, s[0:1]
	v_cmp_gt_f32_e64 s[0:1], s15, v44
	v_exp_f32_e32 v39, v39
	v_mfma_f32_16x16x4_f32 a[8:11], v29, v41, a[8:11]
	v_cndmask_b32_e64 v40, v44, v49, s[0:1]
	v_add_f32_e32 v49, 0x42800000, v45
	v_mul_f32_e32 v40, 0x3fb8aa3b, v40
	v_cndmask_b32_e64 v49, v45, v49, s[8:9]
	v_exp_f32_e32 v40, v40
	v_mul_f32_e32 v49, 0x3fb8aa3b, v49
	v_exp_f32_e32 v41, v49
	v_mul_f32_e32 v48, 0x114b4ea4, v39
	v_cndmask_b32_e64 v39, v39, v48, s[6:7]
	v_mul_f32_e32 v48, 0x114b4ea4, v40
	v_cndmask_b32_e64 v40, v40, v48, s[0:1]
	v_mul_f32_e32 v48, 0x114b4ea4, v41
	v_cndmask_b32_e64 v41, v41, v48, s[8:9]
	v_pk_mul_f32 v[48:49], v[44:45], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[4:7], v26, v34, a[4:7]
	v_pk_fma_f32 v[40:41], v[40:41], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[0:1], 0, v45
	ds_read_b128 v[56:59], v51 offset:48
	v_or_b32_e32 v47, 8, v50
	v_cndmask_b32_e64 v41, v41, v49, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v44
	v_pk_mul_f32 v[60:61], v[42:43], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[38:39], v[38:39], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v40, v40, v48, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v43
	v_cmp_gt_i32_e64 s[6:7], s17, v47
	v_mfma_f32_16x16x4_f32 a[0:3], v26, v30, a[0:3]
	v_cndmask_b32_e64 v39, v39, v61, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v42
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[8:9], s15, v57
	v_add_u32_e32 v42, 12, v52
	v_cndmask_b32_e64 v38, v38, v60, s[0:1]
	s_and_b64 s[0:1], vcc, s[6:7]
	v_cndmask_b32_e64 v34, v46, 0, s[0:1]
	v_add_u32_e32 v34, v53, v34
	buffer_store_dwordx4 v[38:41], v34, s[24:27], 0 offen offset:32
	v_add_f32_e32 v34, 0x42800000, v56
	v_cmp_gt_f32_e64 s[0:1], s15, v56
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v35, a[4:7]
	v_add_f32_e32 v35, 0x42800000, v57
	v_cndmask_b32_e64 v34, v56, v34, s[0:1]
	v_mul_f32_e32 v34, 0x3fb8aa3b, v34
	v_cndmask_b32_e64 v35, v57, v35, s[8:9]
	v_exp_f32_e32 v34, v34
	v_mul_f32_e32 v35, 0x3fb8aa3b, v35
	v_exp_f32_e32 v35, v35
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	v_mul_f32_e32 v26, 0x114b4ea4, v34
	v_cndmask_b32_e64 v34, v34, v26, s[0:1]
	v_mul_f32_e32 v26, 0x114b4ea4, v35
	v_cndmask_b32_e64 v35, v35, v26, s[8:9]
	v_add_f32_e32 v26, 0x42800000, v58
	v_cmp_gt_f32_e64 s[0:1], s15, v58
	v_add_f32_e32 v27, 0x42800000, v59
	v_cmp_gt_f32_e64 s[8:9], s15, v59
	v_cndmask_b32_e64 v26, v58, v26, s[0:1]
	v_mul_f32_e32 v26, 0x3fb8aa3b, v26
	v_cndmask_b32_e64 v27, v59, v27, s[8:9]
	v_mfma_f32_16x16x4_f32 a[4:7], v28, v36, a[4:7]
	v_exp_f32_e32 v26, v26
	v_mul_f32_e32 v27, 0x3fb8aa3b, v27
	v_exp_f32_e32 v27, v27
	v_pk_mul_f32 v[30:31], v[58:59], s[18:19] op_sel_hi:[1,0]
	v_or_b32_e32 v38, 12, v50
	v_pk_fma_f32 v[34:35], v[34:35], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_or_b32_e32 v43, 1, v122
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	v_mul_f32_e32 v28, 0x114b4ea4, v26
	v_cndmask_b32_e64 v26, v26, v28, s[0:1]
	v_mul_f32_e32 v28, 0x114b4ea4, v27
	v_cndmask_b32_e64 v27, v27, v28, s[8:9]
	v_pk_fma_f32 v[26:27], v[26:27], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[0:1], 0, v59
	v_cmp_gt_i32_e64 s[8:9], s17, v38
	v_mfma_f32_16x16x4_f32 a[4:7], v29, v37, a[4:7]
	v_pk_mul_f32 v[36:37], v[56:57], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[0:3], v29, v33, a[0:3]
	v_cndmask_b32_e64 v29, v27, v31, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v58
	s_nop 1
	v_cndmask_b32_e64 v28, v26, v30, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v57
	v_mfma_f32_16x16x4_f32 a[28:31], v22, v6, a[44:47]
	s_nop 0
	v_cndmask_b32_e64 v27, v35, v37, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v56
	s_nop 1
	v_cndmask_b32_e64 v26, v34, v36, s[0:1]
	s_and_b64 s[0:1], vcc, s[8:9]
	v_cndmask_b32_e64 v30, v46, 0, s[0:1]
	v_lshl_add_u32 v34, v42, 2, v30
	ds_read_b128 v[30:33], v51 offset:560
	buffer_store_dwordx4 v[26:29], v34, s[24:27], 0 offen
	ds_read_b128 v[26:29], v51 offset:544
	v_mfma_f32_16x16x4_f32 a[24:27], v22, v10, a[24:27]
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v34, 0x42800000, v30
	v_cmp_gt_f32_e64 s[0:1], s15, v30
	v_add_f32_e32 v35, 0x42800000, v31
	v_cmp_gt_f32_e64 s[10:11], s15, v31
	v_cndmask_b32_e64 v34, v30, v34, s[0:1]
	v_mul_f32_e32 v34, 0x3fb8aa3b, v34
	v_exp_f32_e32 v34, v34
	v_cndmask_b32_e64 v35, v31, v35, s[10:11]
	v_add_f32_e32 v37, 0x42800000, v32
	v_mul_f32_e32 v35, 0x3fb8aa3b, v35
	v_mul_f32_e32 v36, 0x114b4ea4, v34
	v_cndmask_b32_e64 v34, v34, v36, s[0:1]
	v_cmp_gt_f32_e64 s[0:1], s15, v32
	v_add_f32_e32 v38, 0x42800000, v33
	v_cmp_gt_f32_e64 s[12:13], s15, v33
	v_cndmask_b32_e64 v37, v32, v37, s[0:1]
	v_exp_f32_e32 v35, v35
	v_mul_f32_e32 v37, 0x3fb8aa3b, v37
	v_cndmask_b32_e64 v38, v33, v38, s[12:13]
	v_exp_f32_e32 v37, v37
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v38
	v_mul_f32_e32 v36, 0x114b4ea4, v35
	v_cndmask_b32_e64 v35, v35, v36, s[10:11]
	v_mul_f32_e32 v36, 0x114b4ea4, v37
	v_cndmask_b32_e64 v36, v37, v36, s[0:1]
	v_mul_f32_e32 v37, 0x114b4ea4, v38
	v_cndmask_b32_e64 v37, v38, v37, s[12:13]
	v_pk_mul_f32 v[38:39], v[32:33], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[36:37], v[36:37], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[0:1], 0, v33
	v_pk_mul_f32 v[40:41], v[30:31], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[34:35], v[34:35], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v33, v37, v39, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v32
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[10:11], s15, v27
	v_mfma_f32_16x16x4_f32 a[20:23], v22, v18, a[20:23]
	v_cndmask_b32_e64 v32, v36, v38, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v31
	v_add_lshl_u32 v38, v42, s21, 2
	v_pk_mul_f32 v[36:37], v[26:27], s[18:19] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v31, v35, v41, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], 0, v30
	v_mfma_f32_16x16x4_f32 a[16:19], v22, v14, a[16:19]
	s_nop 0
	v_cndmask_b32_e64 v30, v34, v40, s[0:1]
	v_cmp_gt_i32_e64 s[0:1], s16, v43
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v34, v46, 0, s[8:9]
	v_add_u32_e32 v34, v38, v34
	buffer_store_dwordx4 v[30:33], v34, s[24:27], 0 offen
	v_cmp_gt_f32_e64 s[8:9], s15, v26
	v_mfma_f32_16x16x4_f32 a[28:31], v23, v7, a[28:31]
	v_add_f32_e32 v30, 0x42800000, v26
	v_cndmask_b32_e64 v30, v26, v30, s[8:9]
	v_add_f32_e32 v31, 0x42800000, v27
	v_mul_f32_e32 v30, 0x3fb8aa3b, v30
	v_cndmask_b32_e64 v31, v27, v31, s[10:11]
	v_exp_f32_e32 v30, v30
	v_mul_f32_e32 v31, 0x3fb8aa3b, v31
	v_exp_f32_e32 v31, v31
	v_add_f32_e32 v33, 0x42800000, v29
	v_mul_f32_e32 v32, 0x114b4ea4, v30
	v_cndmask_b32_e64 v30, v30, v32, s[8:9]
	v_mul_f32_e32 v32, 0x114b4ea4, v31
	v_cndmask_b32_e64 v31, v31, v32, s[10:11]
	v_add_f32_e32 v32, 0x42800000, v28
	v_cmp_gt_f32_e64 s[8:9], s15, v28
	v_cmp_gt_f32_e64 s[10:11], s15, v29
	v_mfma_f32_16x16x4_f32 a[24:27], v23, v11, a[24:27]
	v_cndmask_b32_e64 v32, v28, v32, s[8:9]
	v_mul_f32_e32 v32, 0x3fb8aa3b, v32
	v_cndmask_b32_e64 v33, v29, v33, s[10:11]
	v_exp_f32_e32 v32, v32
	v_mul_f32_e32 v33, 0x3fb8aa3b, v33
	v_exp_f32_e32 v33, v33
	v_pk_fma_f32 v[30:31], v[30:31], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_mul_f32_e32 v34, 0x114b4ea4, v32
	v_cndmask_b32_e64 v32, v32, v34, s[8:9]
	v_mul_f32_e32 v34, 0x114b4ea4, v33
	v_cndmask_b32_e64 v33, v33, v34, s[10:11]
	v_pk_mul_f32 v[34:35], v[28:29], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[32:33], v[32:33], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[8:9], 0, v29
	v_mfma_f32_16x16x4_f32 a[20:23], v23, v19, a[20:23]
	v_mov_b32_e32 v22, 0x7ffffff0
	v_cndmask_b32_e64 v29, v33, v35, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v28
	s_and_b64 s[6:7], s[0:1], s[6:7]
	v_cndmask_b32_e64 v22, v22, -16, s[6:7]
	v_cndmask_b32_e64 v28, v32, v34, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v27
	v_mfma_f32_16x16x4_f32 a[16:19], v23, v15, a[16:19]
	v_add_u32_e32 v22, v38, v22
	v_cndmask_b32_e64 v27, v31, v37, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v26
	s_and_b64 s[4:5], s[0:1], s[4:5]
	s_and_b64 s[2:3], s[2:3], s[0:1]
	v_cndmask_b32_e64 v26, v30, v36, s[8:9]
	ds_read_b128 v[30:33], v51 offset:528
	buffer_store_dwordx4 v[26:29], v22, s[24:27], 0 offen
	v_mfma_f32_16x16x4_f32 a[28:31], v24, v8, a[28:31]
	ds_read_b128 v[26:29], v51 offset:512
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v22, 0x42800000, v30
	v_cmp_gt_f32_e64 s[6:7], s15, v30
	v_add_f32_e32 v23, 0x42800000, v31
	v_cmp_gt_f32_e64 s[8:9], s15, v31
	v_cndmask_b32_e64 v22, v30, v22, s[6:7]
	v_mfma_f32_16x16x4_f32 a[24:27], v24, v12, a[24:27]
	v_mul_f32_e32 v22, 0x3fb8aa3b, v22
	v_exp_f32_e32 v22, v22
	v_cndmask_b32_e64 v23, v31, v23, s[8:9]
	v_mul_f32_e32 v23, 0x3fb8aa3b, v23
	v_cmp_gt_f32_e64 s[10:11], s15, v33
	v_exp_f32_e32 v23, v23
	v_pk_mul_f32 v[34:35], v[30:31], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[20:23], v24, v20, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v24, v16, a[16:19]
	v_mul_f32_e32 v24, 0x114b4ea4, v22
	v_cndmask_b32_e64 v22, v22, v24, s[6:7]
	v_add_f32_e32 v24, 0x42800000, v32
	v_cmp_gt_f32_e64 s[6:7], s15, v32
	s_nop 1
	v_cndmask_b32_e64 v24, v32, v24, s[6:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v6, a[12:15]
	v_mul_f32_e32 v24, 0x3fb8aa3b, v24
	v_exp_f32_e32 v24, v24
	v_mul_f32_e32 v6, 0x114b4ea4, v23
	v_cndmask_b32_e64 v23, v23, v6, s[8:9]
	v_pk_fma_f32 v[22:23], v[22:23], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_mul_f32_e32 v6, 0x114b4ea4, v24
	v_cndmask_b32_e64 v6, v24, v6, s[6:7]
	v_mfma_f32_16x16x4_f32 a[28:31], v25, v9, a[28:31]
	v_cmp_lt_f32_e64 s[6:7], 0, v33
	v_mfma_f32_16x16x4_f32 a[24:27], v25, v13, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v25, v21, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v25, v17, a[16:19]
	v_add_f32_e32 v25, 0x42800000, v33
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v7, a[12:15]
	v_cndmask_b32_e64 v7, v33, v25, s[10:11]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v24, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v24, s[10:11]
	v_pk_mul_f32 v[24:25], v[32:33], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	v_cndmask_b32_e64 v25, v7, v25, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v32
	v_not_b32_e32 v7, 31
	s_nop 0
	v_cndmask_b32_e64 v24, v6, v24, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v31
	v_mov_b32_e32 v6, 0x7fffffe0
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v18, a[4:7]
	v_cndmask_b32_e64 v23, v23, v35, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v30
	v_cndmask_b32_e64 v6, v6, v7, s[4:5]
	v_add_u32_e32 v6, v38, v6
	v_cndmask_b32_e64 v22, v22, v34, s[6:7]
	buffer_store_dwordx4 v[22:25], v6, s[24:27], 0 offen
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, 0x42800000, v26
	v_cmp_gt_f32_e64 s[4:5], s15, v26
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v10, a[8:11]
	v_add_f32_e32 v7, 0x42800000, v27
	v_cndmask_b32_e64 v6, v26, v6, s[4:5]
	v_cmp_gt_f32_e64 s[6:7], s15, v27
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v7, v27, v7, s[6:7]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v10, 0x42800000, v29
	v_pk_mul_f32 v[22:23], v[26:27], s[18:19] op_sel_hi:[1,0]
	v_add_lshl_u32 v2, v52, s21, 2
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v19, a[4:7]
	v_pk_mul_f32 v[18:19], v[28:29], s[18:19] op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v8, a[12:15]
	v_mul_f32_e32 v8, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v8, s[4:5]
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v8, s[6:7]
	v_add_f32_e32 v8, 0x42800000, v28
	v_cmp_gt_f32_e64 s[4:5], s15, v28
	v_cmp_gt_f32_e64 s[6:7], s15, v29
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v11, a[8:11]
	v_cndmask_b32_e64 v8, v28, v8, s[4:5]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_cndmask_b32_e64 v10, v29, v10, s[6:7]
	v_exp_f32_e32 v8, v8
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v11, v10
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	v_mul_f32_e32 v10, 0x114b4ea4, v8
	v_cndmask_b32_e64 v10, v8, v10, s[4:5]
	v_mul_f32_e32 v8, 0x114b4ea4, v11
	v_cndmask_b32_e64 v11, v11, v8, s[6:7]
	v_pk_fma_f32 v[10:11], v[10:11], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[4:5], 0, v29
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v20, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v12, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v21, a[4:7]
	v_cndmask_b32_e64 v21, v11, v19, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v28
	s_nop 1
	v_cndmask_b32_e64 v20, v10, v18, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v27
	s_nop 1
	v_cndmask_b32_e64 v19, v7, v23, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v26
	s_nop 1
	v_cndmask_b32_e64 v18, v6, v22, s[4:5]
	v_cndmask_b32_e64 v6, v46, 0, s[2:3]
	v_add_u32_e32 v6, v6, v2
	buffer_store_dwordx4 v[18:21], v6, s[24:27], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v54, a28
	ds_write_b32 v54, a29 offset:512
	ds_write_b32 v54, a30 offset:1024
	ds_write_b32 v54, a31 offset:1536
	ds_write_b32 v54, a27 offset:1664
	ds_write_b32 v54, a26 offset:1152
	ds_write_b32 v54, a25 offset:640
	ds_write_b32 v54, a24 offset:128
	ds_write_b32 v54, a20 offset:256
	ds_write_b32 v54, a21 offset:768
	ds_write_b32 v54, a22 offset:1280
	ds_write_b32 v54, a23 offset:1792
	ds_write_b32 v54, a19 offset:1920
	ds_write_b32 v54, a18 offset:1408
	ds_write_b32 v54, a17 offset:896
	ds_write_b32 v54, a16 offset:384
	ds_write_b32 v54, a0 offset:16768
	ds_write_b32 v54, a1 offset:17280
	ds_write_b32 v54, a2 offset:17792
	ds_write_b32 v54, a3 offset:18304
	ds_write_b32 v54, a7 offset:18176
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v13, a[8:11]
	ds_write_b32 v54, a6 offset:17664
	ds_write_b32 v54, a5 offset:17152
	ds_write_b32 v54, a4 offset:16640
	s_nop 6
	ds_write_b32 v54, a0 offset:16512
	ds_write_b32 v54, a1 offset:17024
	ds_write_b32 v54, a2 offset:17536
	ds_write_b32 v54, a3 offset:18048
	v_or_b32_e32 v20, 0x80, v50
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v9, a[12:15]
	s_nop 7
	s_nop 1
	ds_write_b32 v54, a3 offset:17920
	ds_write_b32 v54, a2 offset:17408
	ds_write_b32 v54, a1 offset:16896
	ds_write_b32 v54, a0 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[4:7], v51
	ds_read_b128 v[8:11], v51 offset:16
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v3, 0x42800000, v4
	v_cmp_gt_f32_e64 s[2:3], s15, v4
	v_add_f32_e32 v12, 0x42800000, v5
	v_cmp_gt_f32_e64 s[4:5], s15, v5
	v_cndmask_b32_e64 v3, v4, v3, s[2:3]
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_cndmask_b32_e64 v12, v5, v12, s[4:5]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v13, v12
	v_mul_f32_e32 v12, 0x114b4ea4, v3
	v_cndmask_b32_e64 v12, v3, v12, s[2:3]
	v_add_f32_e32 v14, 0x42800000, v6
	v_cmp_gt_f32_e64 s[2:3], s15, v6
	v_add_f32_e32 v15, 0x42800000, v7
	v_cmp_gt_f32_e64 s[6:7], s15, v7
	v_cndmask_b32_e64 v14, v6, v14, s[2:3]
	v_mul_f32_e32 v14, 0x3fb8aa3b, v14
	v_cndmask_b32_e64 v15, v7, v15, s[6:7]
	v_exp_f32_e32 v14, v14
	v_mul_f32_e32 v15, 0x3fb8aa3b, v15
	v_exp_f32_e32 v15, v15
	v_mul_f32_e32 v3, 0x114b4ea4, v13
	v_cndmask_b32_e64 v13, v13, v3, s[4:5]
	v_mul_f32_e32 v3, 0x114b4ea4, v14
	v_cndmask_b32_e64 v14, v14, v3, s[2:3]
	v_mul_f32_e32 v3, 0x114b4ea4, v15
	v_cndmask_b32_e64 v15, v15, v3, s[6:7]
	v_pk_mul_f32 v[16:17], v[6:7], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[14:15], v[14:15], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[2:3], 0, v7
	v_pk_mul_f32 v[18:19], v[4:5], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[12:13], v[12:13], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v7, v15, v17, s[2:3]
	v_cmp_lt_f32_e64 s[2:3], 0, v6
	v_add_u32_e32 v3, 0x200, v53
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[6:7], s15, v9
	v_cndmask_b32_e64 v6, v14, v16, s[2:3]
	v_cmp_lt_f32_e64 s[2:3], 0, v5
	v_cmp_gt_f32_e64 s[8:9], s15, v11
	v_pk_mul_f32 v[14:15], v[8:9], s[18:19] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v5, v13, v19, s[2:3]
	v_cmp_lt_f32_e64 s[2:3], 0, v4
	v_or_b32_e32 v16, 0x84, v50
	s_nop 0
	v_cndmask_b32_e64 v4, v12, v18, s[2:3]
	v_cmp_gt_i32_e64 s[2:3], s17, v20
	s_and_b64 s[4:5], vcc, s[2:3]
	v_cndmask_b32_e64 v12, v46, 0, s[4:5]
	v_add_u32_e32 v12, v3, v12
	buffer_store_dwordx4 v[4:7], v12, s[24:27], 0 offen
	v_cmp_gt_f32_e64 s[4:5], s15, v8
	v_add_f32_e32 v12, 0x42800000, v11
	v_add_f32_e32 v4, 0x42800000, v8
	v_cndmask_b32_e64 v4, v8, v4, s[4:5]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	v_add_f32_e32 v5, 0x42800000, v9
	v_cndmask_b32_e64 v5, v9, v5, s[6:7]
	v_add_f32_e32 v7, 0x42800000, v10
	v_mul_f32_e32 v6, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v6, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], s15, v10
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	v_cndmask_b32_e64 v7, v10, v7, s[4:5]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_cndmask_b32_e64 v12, v11, v12, s[8:9]
	v_exp_f32_e32 v7, v7
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v6, s[6:7]
	v_mul_f32_e32 v6, 0x114b4ea4, v7
	v_cndmask_b32_e64 v6, v7, v6, s[4:5]
	v_mul_f32_e32 v7, 0x114b4ea4, v12
	v_cndmask_b32_e64 v7, v12, v7, s[8:9]
	v_pk_mul_f32 v[12:13], v[10:11], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[4:5], 0, v11
	v_pk_fma_f32 v[4:5], v[4:5], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_or_b32_e32 v20, 0x88, v50
	v_cndmask_b32_e64 v7, v7, v13, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v10
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v12, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v9
	v_mov_b32_e32 v12, 0x80000010
	s_nop 0
	v_cndmask_b32_e64 v5, v5, v15, s[4:5]
	v_cmp_lt_f32_e64 s[4:5], 0, v8
	ds_read_b128 v[8:11], v51 offset:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v13, 0x42800000, v9
	v_cndmask_b32_e64 v4, v4, v14, s[4:5]
	v_cmp_gt_i32_e64 s[4:5], s17, v16
	s_and_b64 s[6:7], vcc, s[4:5]
	v_cndmask_b32_e64 v12, v12, 16, s[6:7]
	v_add_u32_e32 v12, v3, v12
	buffer_store_dwordx4 v[4:7], v12, s[24:27], 0 offen
	v_add_f32_e32 v12, 0x42800000, v8
	v_cmp_gt_f32_e64 s[6:7], s15, v8
	v_cmp_gt_f32_e64 s[8:9], s15, v9
	v_add_f32_e32 v15, 0x42800000, v10
	v_cndmask_b32_e64 v12, v8, v12, s[6:7]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_cndmask_b32_e64 v13, v9, v13, s[8:9]
	v_mul_f32_e32 v13, 0x3fb8aa3b, v13
	v_add_f32_e32 v16, 0x42800000, v11
	v_mul_f32_e32 v14, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v14, s[6:7]
	v_cmp_gt_f32_e64 s[6:7], s15, v10
	v_cmp_gt_f32_e64 s[10:11], s15, v11
	v_exp_f32_e32 v13, v13
	v_cndmask_b32_e64 v15, v10, v15, s[6:7]
	v_mul_f32_e32 v15, 0x3fb8aa3b, v15
	v_cndmask_b32_e64 v16, v11, v16, s[10:11]
	v_exp_f32_e32 v15, v15
	v_mul_f32_e32 v16, 0x3fb8aa3b, v16
	v_exp_f32_e32 v16, v16
	v_mul_f32_e32 v14, 0x114b4ea4, v13
	v_cndmask_b32_e64 v13, v13, v14, s[8:9]
	v_mul_f32_e32 v14, 0x114b4ea4, v15
	v_cndmask_b32_e64 v14, v15, v14, s[6:7]
	v_mul_f32_e32 v15, 0x114b4ea4, v16
	v_cndmask_b32_e64 v15, v16, v15, s[10:11]
	v_pk_mul_f32 v[16:17], v[10:11], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[14:15], v[14:15], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[6:7], 0, v11
	v_pk_mul_f32 v[18:19], v[8:9], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[12:13], v[12:13], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v11, v15, v17, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v10
	ds_read_b128 v[4:7], v51 offset:48
	s_and_b64 s[4:5], s[0:1], s[4:5]
	v_cndmask_b32_e64 v10, v14, v16, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v9
	v_or_b32_e32 v16, 0x8c, v50
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[10:11], s15, v5
	v_cndmask_b32_e64 v9, v13, v19, s[6:7]
	v_cmp_lt_f32_e64 s[6:7], 0, v8
	v_cmp_gt_f32_e64 s[12:13], s15, v7
	v_pk_mul_f32 v[14:15], v[4:5], s[18:19] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v8, v12, v18, s[6:7]
	v_cmp_gt_i32_e64 s[6:7], s17, v20
	v_mov_b32_e32 v12, 0x80000020
	s_and_b64 s[8:9], vcc, s[6:7]
	v_cndmask_b32_e64 v12, v12, 32, s[8:9]
	v_add_u32_e32 v12, v3, v12
	buffer_store_dwordx4 v[8:11], v12, s[24:27], 0 offen
	v_cmp_gt_f32_e64 s[8:9], s15, v4
	v_add_f32_e32 v12, 0x42800000, v7
	v_add_f32_e32 v8, 0x42800000, v4
	v_cndmask_b32_e64 v8, v4, v8, s[8:9]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	v_add_f32_e32 v9, 0x42800000, v5
	v_cndmask_b32_e64 v9, v5, v9, s[10:11]
	v_add_f32_e32 v11, 0x42800000, v6
	v_mul_f32_e32 v10, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v10, s[8:9]
	v_cmp_gt_f32_e64 s[8:9], s15, v6
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	v_cndmask_b32_e64 v11, v6, v11, s[8:9]
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_cndmask_b32_e64 v12, v7, v12, s[12:13]
	v_exp_f32_e32 v11, v11
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e64 v9, v9, v10, s[10:11]
	v_mul_f32_e32 v10, 0x114b4ea4, v11
	v_cndmask_b32_e64 v10, v11, v10, s[8:9]
	v_mul_f32_e32 v11, 0x114b4ea4, v12
	v_cndmask_b32_e64 v11, v12, v11, s[12:13]
	v_pk_mul_f32 v[12:13], v[6:7], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[10:11], v[10:11], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e64 s[8:9], 0, v7
	v_pk_fma_f32 v[8:9], v[8:9], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	s_and_b64 s[6:7], s[0:1], s[6:7]
	v_cndmask_b32_e64 v7, v11, v13, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v10, v12, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v5
	v_mov_b32_e32 v12, 0x80000030
	s_nop 0
	v_cndmask_b32_e64 v5, v9, v15, s[8:9]
	v_cmp_lt_f32_e64 s[8:9], 0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v8, v14, s[8:9]
	ds_read_b128 v[8:11], v51 offset:560
	v_cmp_gt_i32_e64 s[8:9], s17, v16
	s_and_b64 s[10:11], vcc, s[8:9]
	v_cndmask_b32_e64 v12, v12, 48, s[10:11]
	v_add_u32_e32 v3, v3, v12
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v16, 0x42800000, v8
	v_cmp_gt_f32_e32 vcc, s15, v8
	buffer_store_dwordx4 v[4:7], v3, s[24:27], 0 offen
	v_add_f32_e32 v17, 0x42800000, v9
	v_cndmask_b32_e32 v16, v8, v16, vcc
	v_mul_f32_e32 v16, 0x3fb8aa3b, v16
	v_exp_f32_e32 v16, v16
	v_add_f32_e32 v5, 0x42800000, v10
	v_cmp_gt_f32_e64 s[10:11], s15, v9
	v_cmp_gt_f32_e64 s[12:13], s15, v11
	v_mul_f32_e32 v3, 0x114b4ea4, v16
	v_cndmask_b32_e32 v4, v16, v3, vcc
	v_cmp_gt_f32_e32 vcc, s15, v10
	v_cndmask_b32_e64 v17, v9, v17, s[10:11]
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_cndmask_b32_e32 v5, v10, v5, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v6, v5
	v_add_f32_e32 v5, 0x42800000, v11
	v_exp_f32_e32 v17, v17
	v_cndmask_b32_e64 v5, v11, v5, s[12:13]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v7, v5
	v_mul_f32_e32 v3, 0x114b4ea4, v17
	v_cndmask_b32_e64 v5, v17, v3, s[10:11]
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v3, vcc
	v_mul_f32_e32 v3, 0x114b4ea4, v7
	ds_read_b128 v[12:15], v51 offset:544
	v_cndmask_b32_e64 v7, v7, v3, s[12:13]
	v_pk_mul_f32 v[16:17], v[10:11], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e32 vcc, 0, v11
	v_pk_mul_f32 v[18:19], v[8:9], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[4:5], v[4:5], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e32 v7, v7, v17, vcc
	v_cmp_lt_f32_e32 vcc, 0, v10
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v3, v46, 0, s[8:9]
	v_cndmask_b32_e32 v6, v6, v16, vcc
	v_cmp_lt_f32_e32 vcc, 0, v9
	v_add_u32_e32 v3, v2, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v9, 0x42800000, v13
	v_cndmask_b32_e32 v5, v5, v19, vcc
	v_cmp_lt_f32_e32 vcc, 0, v8
	v_add_f32_e32 v8, 0x42800000, v12
	v_cmp_gt_f32_e64 s[8:9], s15, v13
	v_cndmask_b32_e32 v4, v4, v18, vcc
	v_cmp_gt_f32_e32 vcc, s15, v12
	buffer_store_dwordx4 v[4:7], v3, s[24:27], 0 offen offset:560
	v_cndmask_b32_e64 v9, v13, v9, s[8:9]
	v_cndmask_b32_e32 v8, v12, v8, vcc
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	v_add_f32_e32 v5, 0x42800000, v14
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_cmp_gt_f32_e64 s[10:11], s15, v15
	v_mul_f32_e32 v3, 0x114b4ea4, v8
	v_cndmask_b32_e32 v4, v8, v3, vcc
	v_cmp_gt_f32_e32 vcc, s15, v14
	v_exp_f32_e32 v9, v9
	v_pk_mul_f32 v[10:11], v[12:13], s[18:19] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v5, v14, v5, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v6, v5
	v_add_f32_e32 v5, 0x42800000, v15
	v_cndmask_b32_e64 v5, v15, v5, s[10:11]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v7, v5
	v_mul_f32_e32 v3, 0x114b4ea4, v9
	v_cndmask_b32_e64 v5, v9, v3, s[8:9]
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v3, vcc
	v_mul_f32_e32 v3, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v3, s[10:11]
	v_pk_mul_f32 v[8:9], v[14:15], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e32 vcc, 0, v15
	v_pk_fma_f32 v[4:5], v[4:5], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v3, v46, 0, s[6:7]
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_cmp_lt_f32_e32 vcc, 0, v14
	v_add_u32_e32 v3, v2, v3
	s_and_b64 s[0:1], s[0:1], s[2:3]
	v_cndmask_b32_e32 v6, v6, v8, vcc
	v_cmp_lt_f32_e32 vcc, 0, v13
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v11, vcc
	v_cmp_lt_f32_e32 vcc, 0, v12
	ds_read_b128 v[12:15], v51 offset:512
	s_nop 0
	v_cndmask_b32_e32 v4, v4, v10, vcc
	ds_read_b128 v[8:11], v51 offset:528
	buffer_store_dwordx4 v[4:7], v3, s[24:27], 0 offen offset:544
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v16, 0x42800000, v8
	v_cmp_gt_f32_e32 vcc, s15, v8
	v_add_f32_e32 v5, 0x42800000, v10
	v_add_f32_e32 v17, 0x42800000, v9
	v_cndmask_b32_e32 v16, v8, v16, vcc
	v_mul_f32_e32 v16, 0x3fb8aa3b, v16
	v_exp_f32_e32 v16, v16
	v_cmp_gt_f32_e64 s[6:7], s15, v9
	v_cmp_gt_f32_e64 s[8:9], s15, v11
	v_pk_mul_f32 v[18:19], v[8:9], s[18:19] op_sel_hi:[1,0]
	v_mul_f32_e32 v3, 0x114b4ea4, v16
	v_cndmask_b32_e32 v4, v16, v3, vcc
	v_cmp_gt_f32_e32 vcc, s15, v10
	v_cndmask_b32_e64 v17, v9, v17, s[6:7]
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_cndmask_b32_e32 v5, v10, v5, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v6, v5
	v_add_f32_e32 v5, 0x42800000, v11
	v_exp_f32_e32 v17, v17
	v_cndmask_b32_e64 v5, v11, v5, s[8:9]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v7, v5
	v_mul_f32_e32 v3, 0x114b4ea4, v17
	v_cndmask_b32_e64 v5, v17, v3, s[6:7]
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v3, vcc
	v_mul_f32_e32 v3, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v3, s[8:9]
	v_pk_mul_f32 v[16:17], v[10:11], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[6:7], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e32 vcc, 0, v11
	v_pk_fma_f32 v[4:5], v[4:5], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cndmask_b32_e64 v3, v46, 0, s[4:5]
	v_cndmask_b32_e32 v7, v7, v17, vcc
	v_cmp_lt_f32_e32 vcc, 0, v10
	v_add_u32_e32 v3, v2, v3
	v_cmp_gt_f32_e64 s[4:5], s15, v13
	v_cndmask_b32_e32 v6, v6, v16, vcc
	v_cmp_lt_f32_e32 vcc, 0, v9
	v_add_f32_e32 v9, 0x42800000, v13
	v_cndmask_b32_e64 v9, v13, v9, s[4:5]
	v_cndmask_b32_e32 v5, v5, v19, vcc
	v_cmp_lt_f32_e32 vcc, 0, v8
	v_add_f32_e32 v8, 0x42800000, v12
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_cndmask_b32_e32 v4, v4, v18, vcc
	v_cmp_gt_f32_e32 vcc, s15, v12
	buffer_store_dwordx4 v[4:7], v3, s[24:27], 0 offen offset:528
	v_cmp_gt_f32_e64 s[6:7], s15, v15
	v_cndmask_b32_e32 v8, v12, v8, vcc
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	v_add_f32_e32 v5, 0x42800000, v14
	v_exp_f32_e32 v9, v9
	v_pk_mul_f32 v[10:11], v[12:13], s[18:19] op_sel_hi:[1,0]
	v_mul_f32_e32 v3, 0x114b4ea4, v8
	v_cndmask_b32_e32 v4, v8, v3, vcc
	v_cmp_gt_f32_e32 vcc, s15, v14
	v_mul_f32_e32 v3, 0x114b4ea4, v9
	s_nop 0
	v_cndmask_b32_e32 v5, v14, v5, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v6, v5
	v_add_f32_e32 v5, 0x42800000, v15
	v_cndmask_b32_e64 v5, v15, v5, s[6:7]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v7, v5
	v_cndmask_b32_e64 v5, v9, v3, s[4:5]
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v3, vcc
	v_mul_f32_e32 v3, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v3, s[6:7]
	v_pk_mul_f32 v[8:9], v[14:15], s[18:19] op_sel_hi:[1,0]
	v_pk_fma_f32 v[4:5], v[4:5], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[0:1], v[6:7], s[14:15], v[0:1] op_sel_hi:[1,0,0]
	v_cmp_lt_f32_e32 vcc, 0, v15
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v9, vcc
	v_cmp_lt_f32_e32 vcc, 0, v14
	s_nop 1
	v_cndmask_b32_e32 v6, v0, v8, vcc
	v_cmp_lt_f32_e32 vcc, 0, v13
	v_cndmask_b32_e64 v0, v46, 0, s[0:1]
	v_add_u32_e32 v0, v2, v0
	v_cndmask_b32_e32 v5, v5, v11, vcc
	v_cmp_lt_f32_e32 vcc, 0, v12
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v10, vcc
	buffer_store_dwordx4 v[4:7], v0, s[24:27], 0 offen offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
		.amdhsa_next_free_vgpr 224
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 64
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 29
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
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

	.type	__hip_cuid_f067675beb1804da,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_f067675beb1804da
__hip_cuid_f067675beb1804da:
	.byte	0
	.size	__hip_cuid_f067675beb1804da, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_f067675beb1804da
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
  - .agpr_count:     64
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 40960
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_N7pytorch4SeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSD_IJLi1ELi0ELi2EEEESF_Li2ELi4ELi4ELb0ELi0ESE_SF_SF_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSD_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     224
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
