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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
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
	v_and_b32_e32 v1, 62, v123
	s_cmp_lt_u32 s3, s18
	v_bitop3_b32 v155, v123, v127, 6 bitop3:0x6c
	v_lshlrev_b32_e32 v3, 5, v1
	s_cselect_b32 s21, s21, s14
	s_lshl_b32 s18, s2, 8
	v_lshl_or_b32 v42, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v122, s22, 6, v1
	v_or_b32_e32 v150, s18, v3
	s_ashr_i32 s2, s20, 31
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v122, s15
	v_mul_lo_u32 v152, v150, s16
	s_lshr_b32 s2, s2, 29
	v_add_u32_e32 v22, v154, v2
	v_add_u32_e32 v10, v152, v2
	v_lshl_or_b32 v43, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_add_i32 s20, s20, s2
	s_mul_i32 s6, s19, s15
	s_mul_i32 s7, s7, s16
	v_and_b32_e32 v26, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v50, 6, v2
	v_bitop3_b32 v51, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v44, v126, v124
	s_ashr_i32 s14, s20, 3
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
	v_add_u32_e32 v30, s16, v27
	v_add_u32_e32 v45, 32, v22
	v_lshlrev_b32_e32 v22, 2, v27
	v_bitop3_b32 v47, v26, v127, 1 bitop3:0x36
	v_lshlrev_b32_e32 v26, 2, v30
	v_add_u32_e32 v34, s16, v30
	buffer_load_dwordx4 v[22:25], v22, s[4:7], 0 offen
	buffer_load_dwordx4 v[26:29], v26, s[4:7], 0 offen
	v_lshlrev_b32_e32 v30, 2, v34
	v_add_u32_e32 v38, s16, v34
	buffer_load_dwordx4 v[30:33], v30, s[4:7], 0 offen
	v_lshlrev_b32_e32 v34, 2, v38
	buffer_load_dwordx4 v[34:37], v34, s[4:7], 0 offen
	v_add_u32_e32 v58, s16, v38
	v_lshlrev_b32_e32 v38, 2, v58
	buffer_load_dwordx4 v[38:41], v38, s[4:7], 0 offen
	v_bitop3_b32 v49, v0, 1, 7 bitop3:0x6c
	s_mul_i32 s20, s16, -7
	v_sub_u32_e32 v53, v47, v155
	v_sub_u32_e32 v47, v155, v47
	v_sub_u32_e32 v54, v49, v127
	v_lshlrev_b32_e32 v55, 2, v45
	v_add_lshl_u32 v45, v45, s15, 2
	v_lshlrev_b32_e32 v48, 2, v43
	v_lshlrev_b32_e32 v59, 2, v53
	v_lshlrev_b32_e32 v47, 2, v47
	v_lshl_add_u32 v43, v54, 2, v43
	v_lshlrev_b32_e32 v138, 4, v54
	buffer_load_dwordx4 v[98:101], v55, s[0:3], 0 offen
	buffer_load_dwordx4 v[54:57], v45, s[0:3], 0 offen
	v_add3_u32 v45, s20, 32, v58
	v_add3_u32 v156, v59, v42, v47
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s16, v45
	v_lshlrev_b32_e32 v58, 2, v45
	v_add_u32_e32 v45, s16, v45
	buffer_load_dwordx4 v[66:69], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[62:65], v58, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s16, v45
	v_lshlrev_b32_e32 v58, 2, v45
	v_add_u32_e32 v45, s16, v45
	buffer_load_dwordx4 v[78:81], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[74:77], v58, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s16, v45
	v_lshlrev_b32_e32 v58, 2, v45
	v_add_u32_e32 v45, s16, v45
	buffer_load_dwordx4 v[82:85], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[86:89], v58, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_lshl_u32 v45, v45, s16, 2
	buffer_load_dwordx4 v[90:93], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[94:97], v45, s[4:7], 0 offen
	v_lshlrev_b32_e32 v46, 2, v42
	s_movk_i32 s21, 0x2000
	v_bitop3_b32 v52, v0, 2, 7 bitop3:0x6c
	v_lshl_add_u32 v53, v53, 4, v46
	v_add3_u32 v42, v48, s21, v138
	v_sub_u32_e32 v49, v52, v49
	v_lshlrev_b32_e32 v139, 4, v49
	s_movk_i32 s20, 0x80
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
	v_add3_u32 v5, v42, s20, v139
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
	ds_write_b128 v2, v[30:33] offset:128
	v_add3_u32 v2, v2, s20, v143
	v_lshlrev_b32_e32 v3, 4, v5
	s_waitcnt vmcnt(11)
	ds_write_b128 v2, v[34:37] offset:128
	v_add3_u32 v135, v2, s20, v3
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
	ds_read_b128 v[18:21], v130
	ds_read_b128 v[2:5], v130 offset:4096
	v_add_u32_e32 v132, v129, v7
	ds_read_b128 v[70:73], v131 offset:8192
	ds_read_b128 v[58:61], v132 offset:4096
	ds_read_b128 v[102:105], v132 offset:8192
	ds_read_b128 v[50:53], v132 offset:12288
	ds_read_b128 v[10:13], v132 offset:16384
	ds_read_b128 v[6:9], v132 offset:20480
	ds_read_b128 v[22:25], v132 offset:24576
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
	s_max_i32 s14, s14, 2
	v_sub_u32_e32 v144, v134, v1
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
	v_accvgpr_write_b32 a47, 0
	v_accvgpr_write_b32 a46, 0
	v_accvgpr_write_b32 a45, 0
	v_accvgpr_write_b32 a44, 0
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
	v_accvgpr_write_b32 a31, 0
	v_accvgpr_write_b32 a30, 0
	v_accvgpr_write_b32 a29, 0
	v_accvgpr_write_b32 a28, 0
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
	ds_write_b128 v155, v[54:57]
	v_add_u32_e32 v54, v144, v153
	v_mfma_f32_16x16x4_f32 a[52:55], v48, v108, a[52:55]
	buffer_load_dwordx4 v[54:57], v54, s[0:3], 0 offen
	v_mfma_f32_16x16x4_f32 a[48:51], v46, v110, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v46, v42, a[28:31]
	v_mfma_f32_16x16x4_f32 a[48:51], v47, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v47, v43, a[28:31]
	v_mfma_f32_16x16x4_f32 a[48:51], v48, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v48, v44, a[28:31]
	v_mfma_f32_16x16x4_f32 a[52:55], v49, v109, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v49, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v49, v45, a[28:31]
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
	v_mfma_f32_16x16x4_f32 a[32:35], v26, v114, a[32:35]
	v_mfma_f32_16x16x4_f32 a[36:39], v26, v118, a[36:39]
	v_mfma_f32_16x16x4_f32 a[32:35], v27, v115, a[32:35]
	v_mfma_f32_16x16x4_f32 a[36:39], v27, v119, a[36:39]
	v_mfma_f32_16x16x4_f32 a[32:35], v28, v116, a[32:35]
	v_mfma_f32_16x16x4_f32 a[36:39], v28, v120, a[36:39]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v33, a[16:19]
	v_mfma_f32_16x16x4_f32 a[32:35], v29, v117, a[32:35]
	v_mfma_f32_16x16x4_f32 a[36:39], v29, v121, a[36:39]
	s_waitcnt vmcnt(9)
	ds_write_b128 v138, v[78:81]
	v_mfma_f32_16x16x4_f32 a[40:43], v26, v106, a[40:43]
	buffer_load_dwordx4 v[78:81], v46, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[44:47], v26, v110, a[44:47]
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v42, a[12:15]
	v_add_u32_e32 v42, v144, v149
	v_mfma_f32_16x16x4_f32 a[40:43], v27, v107, a[40:43]
	v_mfma_f32_16x16x4_f32 a[44:47], v27, v111, a[44:47]
	v_mfma_f32_16x16x4_f32 a[12:15], v27, v43, a[12:15]
	v_mfma_f32_16x16x4_f32 a[40:43], v28, v108, a[40:43]
	v_mfma_f32_16x16x4_f32 a[44:47], v28, v112, a[44:47]
	v_mfma_f32_16x16x4_f32 a[40:43], v29, v109, a[40:43]
	v_mfma_f32_16x16x4_f32 a[44:47], v29, v113, a[44:47]
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
	v_mfma_f32_16x16x4_f32 a[60:63], v18, v70, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v18, v58, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v22, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v19, v71, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v19, v59, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v23, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v20, v72, a[60:63]
	s_waitcnt vmcnt(9)
	ds_write_b128 v141, v[86:89]
	v_mfma_f32_16x16x4_f32 a[0:3], v29, v33, a[0:3]
	buffer_load_dwordx4 v[86:89], v26, s[4:7], 0 offen
	v_add_u32_e32 v26, v144, v146
	v_mfma_f32_16x16x4_f32 a[56:59], v20, v60, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v18, v102, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v18, v50, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v24, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v21, v73, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v21, v61, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v19, v103, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v19, v51, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v25, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v142, v[90:93] offset:128
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	buffer_load_dwordx4 v[90:93], v26, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[52:55], v20, v104, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v20, v52, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v18, v10, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v18, v6, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v18, v22, a[20:23]
	v_add_u32_e32 v22, v144, v145
	v_mfma_f32_16x16x4_f32 a[52:55], v21, v105, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v21, v53, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	s_waitcnt vmcnt(9)
	ds_write_b128 v133, v[94:97]
	v_mfma_f32_16x16x4_f32 a[28:31], v19, v11, a[28:31]
	buffer_load_dwordx4 v[94:97], v22, s[4:7], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[24:27], v19, v7, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v19, v23, a[20:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v20, v12, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v20, v8, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v21, v13, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v21, v9, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v20, v24, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v18, v14, a[16:19]
	ds_read_b128 v[46:49], v128
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v70, a[32:35]
	ds_read_b128 v[26:29], v128 offset:4096
	v_mfma_f32_16x16x4_f32 a[20:23], v21, v25, a[20:23]
	ds_read_b128 v[114:117], v129
	v_mfma_f32_16x16x4_f32 a[16:19], v19, v15, a[16:19]
	ds_read_b128 v[118:121], v129 offset:4096
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v71, a[32:35]
	ds_read_b128 v[106:109], v129 offset:8192
	v_mfma_f32_16x16x4_f32 a[16:19], v20, v16, a[16:19]
	ds_read_b128 v[110:113], v129 offset:12288
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v72, a[32:35]
	ds_read_b128 v[42:45], v129 offset:16384
	v_mfma_f32_16x16x4_f32 a[16:19], v21, v17, a[16:19]
	ds_read_b128 v[38:41], v129 offset:20480
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v73, a[32:35]
	ds_read_b128 v[34:37], v129 offset:24576
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v58, a[36:39]
	ds_read_b128 v[30:33], v129 offset:28672
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v59, a[36:39]
	ds_read_b128 v[18:21], v130
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v60, a[36:39]
	ds_read_b128 v[70:73], v131 offset:8192
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v10, a[12:15]
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v61, a[36:39]
	ds_read_b128 v[58:61], v132 offset:4096
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v102, a[40:43]
	ds_read_b128 v[22:25], v132 offset:24576
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v11, a[12:15]
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v103, a[40:43]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v12, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v6, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v13, a[12:15]
	ds_read_b128 v[10:13], v132 offset:16384
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v104, a[40:43]
	ds_read_b128 v[14:17], v132 offset:28672
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v7, a[8:11]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v105, a[40:43]
	ds_read_b128 v[102:105], v132 offset:8192
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v50, a[44:47]
	v_add_u32_e32 v2, -1, v134
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v8, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v9, a[8:11]
	ds_read_b128 v[6:9], v132 offset:20480
	v_mfma_f32_16x16x4_f32 a[44:47], v3, v51, a[44:47]
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	v_and_b32_e32 v3, -8, v3
	v_sub_u32_e32 v155, v2, v3
	v_xor_b32_e32 v155, v155, v127
	v_sub_u32_e32 v157, v155, v157
	v_mfma_f32_16x16x4_f32 a[44:47], v4, v52, a[44:47]
	v_lshlrev_b32_e32 v157, 2, v157
	v_add3_u32 v156, v157, v156, s15
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v53, a[44:47]
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
	s_waitcnt vmcnt(8)
	v_and_b32_e32 v54, 12, v123
	v_lshlrev_b32_e32 v0, 4, v0
	v_lshlrev_b32_e32 v54, 9, v54
	v_lshlrev_b32_e32 v55, 2, v126
	v_and_b32_e32 v0, 0x70, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[56:59], v46, v118, a[56:59]
	s_mov_b32 s14, 0xbfb8aa3b
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s20, s8, s0
	s_mul_i32 s0, s19, s17
	s_mul_hi_u32 s2, 0, s17
	s_mov_b32 s16, 0x42ce8ed0
	s_addc_u32 s21, s9, s1
	v_mfma_f32_16x16x4_f32 a[48:51], v46, v110, a[48:51]
	s_add_i32 s2, s2, s0
	s_mov_b32 s15, 0xc2b17218
	s_add_i32 s2, s13, s2
	s_lshl_b32 s22, s2, 2
	s_mov_b32 s23, 0x20000
	v_mfma_f32_16x16x4_f32 a[32:35], v26, v114, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v26, v106, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v46, v106, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v26, v110, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v26, v118, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v47, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v47, v119, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v47, v111, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v27, v115, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v27, v107, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v47, v107, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v27, v111, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v27, v119, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v48, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v48, v120, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v48, v112, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v28, v116, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v28, v108, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v48, v108, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v28, v112, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v28, v120, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v49, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v49, v121, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v49, v113, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v29, v117, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v29, v109, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v49, v109, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v29, v113, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v29, v121, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v18, v70, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v18, v58, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v18, v50, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v70, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v102, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v18, v102, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v50, a[44:47]
	v_lshlrev_b32_e32 v50, 13, v125
	v_or3_b32 v50, v50, v54, v55
	v_lshl_add_u32 v54, v124, 2, v50
	v_lshlrev_b32_e32 v50, 2, v0
	v_or_b32_e32 v0, s18, v0
	v_cmp_gt_i32_e64 s[4:5], s13, v0
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v58, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v19, v71, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v19, v59, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v19, v51, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v71, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v103, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v19, v103, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v3, v51, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v59, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v20, v72, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v20, v60, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v20, v52, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v72, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v104, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v20, v104, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v4, v52, a[44:47]
	v_lshl_or_b32 v52, v1, 9, v50
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v60, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v21, v73, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v21, v61, a[56:59]
	s_nop 7
	s_nop 0
	ds_write_b32 v54, a60
	ds_write_b32 v54, a61 offset:512
	ds_write_b32 v54, a62 offset:1024
	ds_write_b32 v54, a63 offset:1536
	ds_write_b32 v54, a59 offset:1664
	ds_write_b32 v54, a58 offset:1152
	ds_write_b32 v54, a57 offset:640
	v_mfma_f32_16x16x4_f32 a[48:51], v21, v53, a[48:51]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v105, a[40:43]
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v73, a[32:35]
	v_mfma_f32_16x16x4_f32 a[52:55], v21, v105, a[52:55]
	ds_write_b32 v54, a56 offset:128
	s_nop 7
	s_nop 0
	ds_write_b32 v54, a52 offset:256
	ds_write_b32 v54, a53 offset:768
	ds_write_b32 v54, a54 offset:1280
	ds_write_b32 v54, a55 offset:1792
	ds_write_b32 v54, a51 offset:1920
	ds_write_b32 v54, a50 offset:1408
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v53, a[44:47]
	ds_write_b32 v54, a49 offset:896
	ds_write_b32 v54, a48 offset:384
	s_nop 7
	ds_write_b32 v54, a44 offset:16768
	ds_write_b32 v54, a45 offset:17280
	ds_write_b32 v54, a46 offset:17792
	ds_write_b32 v54, a47 offset:18304
	ds_write_b32 v54, a43 offset:18176
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v61, a[36:39]
	ds_write_b32 v54, a42 offset:17664
	ds_write_b32 v54, a41 offset:17152
	ds_write_b32 v54, a40 offset:16640
	s_nop 6
	ds_write_b32 v54, a36 offset:16512
	ds_write_b32 v54, a37 offset:17024
	ds_write_b32 v54, a38 offset:17536
	ds_write_b32 v54, a39 offset:18048
	ds_write_b32 v54, a35 offset:17920
	ds_write_b32 v54, a34 offset:17408
	ds_write_b32 v54, a33 offset:16896
	ds_write_b32 v54, a32 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[56:59], v52
	s_waitcnt vmcnt(6)
	ds_read_b128 v[60:63], v52 offset:16
	v_mfma_f32_16x16x4_f32 a[28:31], v46, v42, a[28:31]
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v1, 0xbfb8aa3b, v56
	v_fma_f32 v50, v56, s14, -v1
	v_rndne_f32_e32 v51, v1
	v_fmac_f32_e32 v50, 0xb2a5705f, v56
	v_sub_f32_e32 v1, v1, v51
	v_add_f32_e32 v1, v1, v50
	v_exp_f32_e32 v1, v1
	v_cvt_i32_f32_e32 v53, v51
	v_cmp_nlt_f32_e32 vcc, s16, v56
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[24:27]
	v_mad_u64_u32 v[50:51], s[0:1], v122, s17, v[0:1]
	v_ldexp_f32 v1, v1, v53
	v_cndmask_b32_e32 v51, 0, v1, vcc
	v_mov_b32_e32 v1, 0x7f800000
	v_cmp_ngt_f32_e32 vcc, s15, v56
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v34, a[20:23]
	s_nop 0
	v_cndmask_b32_e32 v56, v1, v51, vcc
	v_mul_f32_e32 v51, 0xbfb8aa3b, v57
	v_fma_f32 v53, v57, s14, -v51
	v_rndne_f32_e32 v55, v51
	v_fmac_f32_e32 v53, 0xb2a5705f, v57
	v_sub_f32_e32 v51, v51, v55
	v_add_f32_e32 v51, v51, v53
	v_cvt_i32_f32_e32 v53, v55
	v_mul_f32_e32 v55, 0xbfb8aa3b, v58
	v_fma_f32 v64, v58, s14, -v55
	v_rndne_f32_e32 v65, v55
	v_fmac_f32_e32 v64, 0xb2a5705f, v58
	v_sub_f32_e32 v55, v55, v65
	v_add_f32_e32 v55, v55, v64
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v55, v55
	v_cvt_i32_f32_e32 v64, v65
	v_cmp_nlt_f32_e32 vcc, s16, v57
	v_ldexp_f32 v51, v51, v53
	v_mfma_f32_16x16x4_f32 a[16:19], v46, v30, a[16:19]
	v_ldexp_f32 v53, v55, v64
	v_mul_f32_e32 v55, 0xbfb8aa3b, v59
	v_fma_f32 v64, v59, s14, -v55
	v_rndne_f32_e32 v65, v55
	v_fmac_f32_e32 v64, 0xb2a5705f, v59
	v_sub_f32_e32 v55, v55, v65
	v_add_f32_e32 v55, v55, v64
	v_exp_f32_e32 v55, v55
	v_cvt_i32_f32_e32 v64, v65
	v_cndmask_b32_e32 v51, 0, v51, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v58
	v_mfma_f32_16x16x4_f32 a[28:31], v47, v43, a[28:31]
	s_nop 0
	v_cndmask_b32_e32 v53, 0, v53, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v58
	s_nop 1
	v_cndmask_b32_e32 v58, v1, v53, vcc
	v_ldexp_f32 v53, v55, v64
	v_cmp_nlt_f32_e32 vcc, s16, v59
	v_mfma_f32_16x16x4_f32 a[24:27], v47, v39, a[24:27]
	s_nop 0
	v_cndmask_b32_e32 v53, 0, v53, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v59
	s_nop 1
	v_cndmask_b32_e32 v59, v1, v53, vcc
	v_pk_add_f32 v[58:59], v[58:59], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v57
	v_div_scale_f32 v53, s[0:1], v59, v59, 1.0
	v_rcp_f32_e32 v55, v53
	v_cndmask_b32_e32 v57, v1, v51, vcc
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v35, a[20:23]
	v_fma_f32 v51, -v53, v55, 1.0
	v_fmac_f32_e32 v55, v51, v55
	v_div_scale_f32 v51, vcc, 1.0, v59, 1.0
	v_mul_f32_e32 v64, v51, v55
	v_fma_f32 v65, -v53, v64, v51
	v_fmac_f32_e32 v64, v65, v55
	v_fma_f32 v51, -v53, v64, v51
	v_div_scale_f32 v53, s[0:1], v58, v58, 1.0
	v_rcp_f32_e32 v65, v53
	v_div_fmas_f32 v51, v51, v55, v64
	v_div_fixup_f32 v59, v51, v59, 1.0
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v31, a[16:19]
	v_fma_f32 v51, -v53, v65, 1.0
	v_fmac_f32_e32 v65, v51, v65
	v_div_scale_f32 v51, vcc, 1.0, v58, 1.0
	v_mul_f32_e32 v55, v51, v65
	v_fma_f32 v64, -v53, v55, v51
	v_fmac_f32_e32 v55, v64, v65
	v_fma_f32 v51, -v53, v55, v51
	v_div_scale_f32 v53, s[0:1], v57, v57, 1.0
	v_rcp_f32_e32 v64, v53
	v_div_fmas_f32 v51, v51, v65, v55
	v_div_fixup_f32 v58, v51, v58, 1.0
	v_mfma_f32_16x16x4_f32 a[28:31], v48, v44, a[28:31]
	v_fma_f32 v51, -v53, v64, 1.0
	v_fmac_f32_e32 v64, v51, v64
	v_div_scale_f32 v51, vcc, 1.0, v57, 1.0
	v_mul_f32_e32 v55, v51, v64
	v_fma_f32 v65, -v53, v55, v51
	v_fmac_f32_e32 v55, v65, v64
	v_fma_f32 v51, -v53, v55, v51
	v_div_scale_f32 v53, s[0:1], v56, v56, 1.0
	v_rcp_f32_e32 v65, v53
	v_div_fmas_f32 v51, v51, v64, v55
	v_div_fixup_f32 v57, v51, v57, 1.0
	v_cmp_gt_i32_e64 s[0:1], s12, v122
	v_fma_f32 v51, -v53, v65, 1.0
	v_fmac_f32_e32 v65, v51, v65
	v_div_scale_f32 v51, vcc, 1.0, v56, 1.0
	v_mul_f32_e32 v55, v51, v65
	v_fma_f32 v64, -v53, v55, v51
	v_fmac_f32_e32 v55, v64, v65
	v_fma_f32 v51, -v53, v55, v51
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v64, 0xbfb8aa3b, v60
	v_div_fmas_f32 v51, v51, v65, v55
	v_fma_f32 v65, v60, s14, -v64
	v_rndne_f32_e32 v66, v64
	v_div_fixup_f32 v56, v51, v56, 1.0
	v_bfrev_b32_e32 v51, 1
	s_and_b64 s[2:3], s[0:1], s[4:5]
	v_fmac_f32_e32 v65, 0xb2a5705f, v60
	v_sub_f32_e32 v64, v64, v66
	v_lshlrev_b32_e32 v53, 2, v50
	v_cndmask_b32_e64 v55, v51, 0, s[2:3]
	v_add_f32_e32 v64, v64, v65
	v_exp_f32_e32 v64, v64
	v_cvt_i32_f32_e32 v65, v66
	v_add_u32_e32 v55, v55, v53
	buffer_store_dwordx4 v[56:59], v55, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v60
	v_or_b32_e32 v55, 4, v0
	v_mul_f32_e32 v57, 0xbfb8aa3b, v61
	v_fma_f32 v58, v61, s14, -v57
	v_rndne_f32_e32 v59, v57
	v_fmac_f32_e32 v58, 0xb2a5705f, v61
	v_sub_f32_e32 v57, v57, v59
	v_ldexp_f32 v56, v64, v65
	v_add_f32_e32 v57, v57, v58
	v_cvt_i32_f32_e32 v58, v59
	v_mul_f32_e32 v59, 0xbfb8aa3b, v62
	v_cndmask_b32_e32 v56, 0, v56, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v60
	v_fma_f32 v60, v62, s14, -v59
	v_rndne_f32_e32 v64, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v62
	v_sub_f32_e32 v59, v59, v64
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v57, v57
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v64
	v_cndmask_b32_e32 v56, v1, v56, vcc
	v_ldexp_f32 v57, v57, v58
	v_cmp_nlt_f32_e32 vcc, s16, v61
	v_ldexp_f32 v58, v59, v60
	v_mul_f32_e32 v59, 0xbfb8aa3b, v63
	v_fma_f32 v60, v63, s14, -v59
	v_rndne_f32_e32 v64, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v63
	v_sub_f32_e32 v59, v59, v64
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v64
	v_cndmask_b32_e32 v57, 0, v57, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v62
	v_cmp_gt_i32_e64 s[6:7], s13, v55
	v_ldexp_f32 v59, v59, v60
	v_cndmask_b32_e32 v58, 0, v58, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v62
	v_mfma_f32_16x16x4_f32 a[24:27], v48, v40, a[24:27]
	s_nop 0
	v_cndmask_b32_e32 v58, v1, v58, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v63
	s_nop 1
	v_cndmask_b32_e32 v59, 0, v59, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v63
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v36, a[20:23]
	s_nop 0
	v_cndmask_b32_e32 v59, v1, v59, vcc
	v_pk_add_f32 v[58:59], v[58:59], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v61
	v_div_scale_f32 v60, s[2:3], v59, v59, 1.0
	v_rcp_f32_e32 v62, v60
	v_cndmask_b32_e32 v57, v1, v57, vcc
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v32, a[16:19]
	v_fma_f32 v61, -v60, v62, 1.0
	v_fmac_f32_e32 v62, v61, v62
	v_div_scale_f32 v61, vcc, 1.0, v59, 1.0
	v_mul_f32_e32 v63, v61, v62
	v_fma_f32 v64, -v60, v63, v61
	v_fmac_f32_e32 v63, v64, v62
	v_fma_f32 v60, -v60, v63, v61
	v_div_scale_f32 v61, s[2:3], v58, v58, 1.0
	v_rcp_f32_e32 v64, v61
	v_div_fmas_f32 v60, v60, v62, v63
	v_div_fixup_f32 v59, v60, v59, 1.0
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v42, a[12:15]
	v_fma_f32 v60, -v61, v64, 1.0
	v_fmac_f32_e32 v64, v60, v64
	v_div_scale_f32 v60, vcc, 1.0, v58, 1.0
	v_mul_f32_e32 v62, v60, v64
	v_fma_f32 v63, -v61, v62, v60
	v_fmac_f32_e32 v62, v63, v64
	v_fma_f32 v60, -v61, v62, v60
	v_div_scale_f32 v61, s[2:3], v57, v57, 1.0
	v_rcp_f32_e32 v63, v61
	v_div_fmas_f32 v60, v60, v64, v62
	v_div_fixup_f32 v58, v60, v58, 1.0
	v_mfma_f32_16x16x4_f32 a[36:39], v49, v45, a[28:31]
	v_fma_f32 v60, -v61, v63, 1.0
	v_fmac_f32_e32 v63, v60, v63
	v_div_scale_f32 v60, vcc, 1.0, v57, 1.0
	v_mul_f32_e32 v62, v60, v63
	v_fma_f32 v64, -v61, v62, v60
	v_fmac_f32_e32 v62, v64, v63
	v_fma_f32 v60, -v61, v62, v60
	v_div_scale_f32 v61, s[2:3], v56, v56, 1.0
	v_rcp_f32_e32 v64, v61
	v_div_fmas_f32 v60, v60, v63, v62
	v_div_fixup_f32 v57, v60, v57, 1.0
	s_and_b64 s[2:3], s[0:1], s[6:7]
	v_fma_f32 v60, -v61, v64, 1.0
	v_fmac_f32_e32 v64, v60, v64
	v_div_scale_f32 v60, vcc, 1.0, v56, 1.0
	v_mul_f32_e32 v62, v60, v64
	v_fma_f32 v63, -v61, v62, v60
	v_fmac_f32_e32 v62, v63, v64
	v_fma_f32 v60, -v61, v62, v60
	v_div_fmas_f32 v60, v60, v64, v62
	v_div_fixup_f32 v56, v60, v56, 1.0
	ds_read_b128 v[60:63], v52 offset:32
	v_cndmask_b32_e64 v55, v51, 0, s[2:3]
	v_add_u32_e32 v55, v53, v55
	buffer_store_dwordx4 v[56:59], v55, s[20:23], 0 offen offset:16
	ds_read_b128 v[64:67], v52 offset:48
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v68, 0xbfb8aa3b, v60
	v_fma_f32 v69, v60, s14, -v68
	v_rndne_f32_e32 v70, v68
	v_fmac_f32_e32 v69, 0xb2a5705f, v60
	v_sub_f32_e32 v68, v68, v70
	v_add_f32_e32 v68, v68, v69
	v_exp_f32_e32 v68, v68
	v_cvt_i32_f32_e32 v69, v70
	v_mul_f32_e32 v57, 0xbfb8aa3b, v61
	v_fma_f32 v58, v61, s14, -v57
	v_rndne_f32_e32 v59, v57
	v_fmac_f32_e32 v58, 0xb2a5705f, v61
	v_sub_f32_e32 v57, v57, v59
	v_ldexp_f32 v56, v68, v69
	v_cmp_nlt_f32_e32 vcc, s16, v60
	v_add_f32_e32 v57, v57, v58
	v_cvt_i32_f32_e32 v58, v59
	v_mul_f32_e32 v59, 0xbfb8aa3b, v62
	v_cndmask_b32_e32 v56, 0, v56, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v60
	v_fma_f32 v60, v62, s14, -v59
	v_rndne_f32_e32 v68, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v62
	v_sub_f32_e32 v59, v59, v68
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v57, v57
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v68
	v_cndmask_b32_e32 v56, v1, v56, vcc
	v_ldexp_f32 v57, v57, v58
	v_cmp_nlt_f32_e32 vcc, s16, v61
	v_ldexp_f32 v58, v59, v60
	v_mul_f32_e32 v59, 0xbfb8aa3b, v63
	v_fma_f32 v60, v63, s14, -v59
	v_rndne_f32_e32 v68, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v63
	v_sub_f32_e32 v59, v59, v68
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v68
	v_cndmask_b32_e32 v57, 0, v57, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v62
	v_or_b32_e32 v55, 8, v0
	v_ldexp_f32 v59, v59, v60
	v_cndmask_b32_e32 v58, 0, v58, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v62
	v_cmp_gt_i32_e64 s[8:9], s13, v55
	v_mfma_f32_16x16x4_f32 a[32:35], v49, v41, a[24:27]
	v_cndmask_b32_e32 v58, v1, v58, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v63
	s_nop 1
	v_cndmask_b32_e32 v59, 0, v59, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v63
	v_mfma_f32_16x16x4_f32 a[28:31], v49, v37, a[20:23]
	s_nop 0
	v_cndmask_b32_e32 v59, v1, v59, vcc
	v_pk_add_f32 v[58:59], v[58:59], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v61
	v_div_scale_f32 v60, s[2:3], v59, v59, 1.0
	v_rcp_f32_e32 v62, v60
	v_cndmask_b32_e32 v57, v1, v57, vcc
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[40:43], v49, v33, a[16:19]
	v_fma_f32 v61, -v60, v62, 1.0
	v_fmac_f32_e32 v62, v61, v62
	v_div_scale_f32 v61, vcc, 1.0, v59, 1.0
	v_mul_f32_e32 v63, v61, v62
	v_fma_f32 v68, -v60, v63, v61
	v_fmac_f32_e32 v63, v68, v62
	v_fma_f32 v60, -v60, v63, v61
	v_div_scale_f32 v61, s[2:3], v58, v58, 1.0
	v_rcp_f32_e32 v68, v61
	v_div_fmas_f32 v60, v60, v62, v63
	v_div_fixup_f32 v59, v60, v59, 1.0
	v_mfma_f32_16x16x4_f32 a[12:15], v27, v43, a[12:15]
	v_fma_f32 v60, -v61, v68, 1.0
	v_fmac_f32_e32 v68, v60, v68
	v_div_scale_f32 v60, vcc, 1.0, v58, 1.0
	v_mul_f32_e32 v62, v60, v68
	v_fma_f32 v63, -v61, v62, v60
	v_fmac_f32_e32 v62, v63, v68
	v_fma_f32 v60, -v61, v62, v60
	v_div_scale_f32 v61, s[2:3], v57, v57, 1.0
	v_rcp_f32_e32 v63, v61
	v_div_fmas_f32 v60, v60, v68, v62
	v_div_fixup_f32 v58, v60, v58, 1.0
	v_mfma_f32_16x16x4_f32 a[12:15], v28, v44, a[12:15]
	v_fma_f32 v60, -v61, v63, 1.0
	v_fmac_f32_e32 v63, v60, v63
	v_div_scale_f32 v60, vcc, 1.0, v57, 1.0
	v_mul_f32_e32 v62, v60, v63
	v_fma_f32 v68, -v61, v62, v60
	v_fmac_f32_e32 v62, v68, v63
	v_fma_f32 v60, -v61, v62, v60
	v_div_scale_f32 v61, s[2:3], v56, v56, 1.0
	v_rcp_f32_e32 v68, v61
	v_div_fmas_f32 v60, v60, v63, v62
	v_div_fixup_f32 v57, v60, v57, 1.0
	s_and_b64 s[2:3], s[0:1], s[8:9]
	v_fma_f32 v60, -v61, v68, 1.0
	v_fmac_f32_e32 v68, v60, v68
	v_div_scale_f32 v60, vcc, 1.0, v56, 1.0
	v_mul_f32_e32 v62, v60, v68
	v_fma_f32 v63, -v61, v62, v60
	v_fmac_f32_e32 v62, v63, v68
	v_fma_f32 v60, -v61, v62, v60
	v_div_fmas_f32 v60, v60, v68, v62
	v_div_fixup_f32 v56, v60, v56, 1.0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v60, 0xbfb8aa3b, v64
	v_fma_f32 v61, v64, s14, -v60
	v_rndne_f32_e32 v62, v60
	v_cndmask_b32_e64 v55, v51, 0, s[2:3]
	v_fmac_f32_e32 v61, 0xb2a5705f, v64
	v_sub_f32_e32 v60, v60, v62
	v_add_u32_e32 v55, v53, v55
	v_add_f32_e32 v60, v60, v61
	v_exp_f32_e32 v60, v60
	v_cvt_i32_f32_e32 v61, v62
	buffer_store_dwordx4 v[56:59], v55, s[20:23], 0 offen offset:32
	v_cmp_nlt_f32_e32 vcc, s16, v64
	v_or_b32_e32 v55, 12, v0
	v_mul_f32_e32 v57, 0xbfb8aa3b, v65
	v_fma_f32 v58, v65, s14, -v57
	v_rndne_f32_e32 v59, v57
	v_fmac_f32_e32 v58, 0xb2a5705f, v65
	v_sub_f32_e32 v57, v57, v59
	v_add_f32_e32 v57, v57, v58
	v_cvt_i32_f32_e32 v58, v59
	v_mul_f32_e32 v59, 0xbfb8aa3b, v66
	v_ldexp_f32 v56, v60, v61
	v_fma_f32 v60, v66, s14, -v59
	v_rndne_f32_e32 v61, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v66
	v_sub_f32_e32 v59, v59, v61
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v57, v57
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v61
	v_cndmask_b32_e32 v56, 0, v56, vcc
	v_ldexp_f32 v57, v57, v58
	v_cmp_ngt_f32_e32 vcc, s15, v64
	v_ldexp_f32 v58, v59, v60
	v_mul_f32_e32 v59, 0xbfb8aa3b, v67
	v_fma_f32 v60, v67, s14, -v59
	v_rndne_f32_e32 v61, v59
	v_fmac_f32_e32 v60, 0xb2a5705f, v67
	v_sub_f32_e32 v59, v59, v61
	v_add_f32_e32 v59, v59, v60
	v_exp_f32_e32 v59, v59
	v_cvt_i32_f32_e32 v60, v61
	v_cndmask_b32_e32 v56, v1, v56, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v65
	v_cmp_gt_i32_e64 s[10:11], s13, v55
	v_ldexp_f32 v59, v59, v60
	v_cndmask_b32_e32 v57, 0, v57, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v66
	v_add_u32_e32 v68, 12, v50
	v_mfma_f32_16x16x4_f32 a[8:11], v26, v38, a[8:11]
	v_cndmask_b32_e32 v58, 0, v58, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v66
	s_nop 1
	v_cndmask_b32_e32 v58, v1, v58, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v67
	v_mfma_f32_16x16x4_f32 a[8:11], v27, v39, a[8:11]
	s_nop 0
	v_cndmask_b32_e32 v59, 0, v59, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v67
	s_nop 1
	v_cndmask_b32_e32 v59, v1, v59, vcc
	v_pk_add_f32 v[58:59], v[58:59], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v65
	v_div_scale_f32 v60, s[2:3], v59, v59, 1.0
	v_rcp_f32_e32 v61, v60
	v_cndmask_b32_e32 v57, v1, v57, vcc
	v_pk_add_f32 v[56:57], v[56:57], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[24:27], v29, v45, a[12:15]
	v_fma_f32 v62, -v60, v61, 1.0
	v_fmac_f32_e32 v61, v62, v61
	v_div_scale_f32 v62, vcc, 1.0, v59, 1.0
	v_mul_f32_e32 v63, v62, v61
	v_fma_f32 v64, -v60, v63, v62
	v_fmac_f32_e32 v63, v64, v61
	v_fma_f32 v60, -v60, v63, v62
	v_div_scale_f32 v62, s[2:3], v58, v58, 1.0
	v_rcp_f32_e32 v64, v62
	v_div_fmas_f32 v60, v60, v61, v63
	v_div_fixup_f32 v59, v60, v59, 1.0
	v_mfma_f32_16x16x4_f32 a[8:11], v28, v40, a[8:11]
	v_fma_f32 v60, -v62, v64, 1.0
	v_fmac_f32_e32 v64, v60, v64
	v_div_scale_f32 v60, vcc, 1.0, v58, 1.0
	v_mul_f32_e32 v61, v60, v64
	v_fma_f32 v63, -v62, v61, v60
	v_fmac_f32_e32 v61, v63, v64
	v_fma_f32 v60, -v62, v61, v60
	v_div_scale_f32 v62, s[2:3], v57, v57, 1.0
	v_rcp_f32_e32 v63, v62
	v_div_fmas_f32 v60, v60, v64, v61
	v_div_fixup_f32 v58, v60, v58, 1.0
	v_mfma_f32_16x16x4_f32 a[4:7], v26, v34, a[4:7]
	v_fma_f32 v60, -v62, v63, 1.0
	v_fmac_f32_e32 v63, v60, v63
	v_div_scale_f32 v60, vcc, 1.0, v57, 1.0
	v_mul_f32_e32 v61, v60, v63
	v_fma_f32 v64, -v62, v61, v60
	v_fmac_f32_e32 v61, v64, v63
	v_fma_f32 v60, -v62, v61, v60
	v_div_scale_f32 v62, s[2:3], v56, v56, 1.0
	v_rcp_f32_e32 v64, v62
	v_div_fmas_f32 v60, v60, v63, v61
	v_div_fixup_f32 v57, v60, v57, 1.0
	s_and_b64 s[2:3], s[0:1], s[10:11]
	v_fma_f32 v60, -v62, v64, 1.0
	v_fmac_f32_e32 v64, v60, v64
	v_div_scale_f32 v60, vcc, 1.0, v56, 1.0
	v_mul_f32_e32 v61, v60, v64
	v_fma_f32 v63, -v62, v61, v60
	v_fmac_f32_e32 v61, v63, v64
	v_fma_f32 v60, -v62, v61, v60
	v_div_fmas_f32 v60, v60, v64, v61
	v_div_fixup_f32 v56, v60, v56, 1.0
	ds_read_b128 v[60:63], v52 offset:560
	v_cndmask_b32_e64 v55, v51, 0, s[2:3]
	v_lshl_add_u32 v55, v68, 2, v55
	buffer_store_dwordx4 v[56:59], v55, s[20:23], 0 offen
	v_mfma_f32_16x16x4_f32 a[16:19], v29, v41, a[8:11]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v46, 0xbfb8aa3b, v60
	v_fma_f32 v69, v60, s14, -v46
	v_rndne_f32_e32 v70, v46
	v_fmac_f32_e32 v69, 0xb2a5705f, v60
	v_sub_f32_e32 v46, v46, v70
	v_add_f32_e32 v46, v46, v69
	v_exp_f32_e32 v46, v46
	v_cvt_i32_f32_e32 v47, v70
	v_mul_f32_e32 v43, 0xbfb8aa3b, v63
	v_cmp_nlt_f32_e32 vcc, s16, v60
	v_mfma_f32_16x16x4_f32 a[0:3], v26, v30, a[0:3]
	v_ldexp_f32 v46, v46, v47
	v_mul_f32_e32 v47, 0xbfb8aa3b, v61
	v_fma_f32 v48, v61, s14, -v47
	v_rndne_f32_e32 v56, v47
	v_fmac_f32_e32 v48, 0xb2a5705f, v61
	v_sub_f32_e32 v47, v47, v56
	v_add_f32_e32 v47, v47, v48
	v_exp_f32_e32 v47, v47
	v_cvt_i32_f32_e32 v48, v56
	v_cndmask_b32_e32 v46, 0, v46, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v60
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v35, a[4:7]
	v_ldexp_f32 v47, v47, v48
	v_mul_f32_e32 v48, 0xbfb8aa3b, v62
	v_fma_f32 v49, v62, s14, -v48
	v_rndne_f32_e32 v42, v48
	v_fmac_f32_e32 v49, 0xb2a5705f, v62
	v_sub_f32_e32 v48, v48, v42
	v_add_f32_e32 v48, v48, v49
	v_exp_f32_e32 v48, v48
	v_cvt_i32_f32_e32 v42, v42
	v_rndne_f32_e32 v49, v43
	v_cvt_i32_f32_e32 v44, v49
	v_cndmask_b32_e32 v46, v1, v46, vcc
	v_ldexp_f32 v42, v48, v42
	v_fma_f32 v48, v63, s14, -v43
	v_fmac_f32_e32 v48, 0xb2a5705f, v63
	v_sub_f32_e32 v43, v43, v49
	v_add_f32_e32 v43, v43, v48
	v_exp_f32_e32 v43, v43
	v_cmp_nlt_f32_e32 vcc, s16, v61
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	ds_read_b128 v[64:67], v52 offset:544
	v_cndmask_b32_e32 v47, 0, v47, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v62
	v_ldexp_f32 v43, v43, v44
	v_or_b32_e32 v55, 1, v122
	v_cndmask_b32_e32 v42, 0, v42, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v62
	v_mfma_f32_16x16x4_f32 a[4:7], v28, v36, a[4:7]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v30, 0xbfb8aa3b, v64
	v_cndmask_b32_e32 v42, v1, v42, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v63
	v_rndne_f32_e32 v27, v30
	s_nop 0
	v_cndmask_b32_e32 v43, 0, v43, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v63
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	s_nop 0
	v_cndmask_b32_e32 v43, v1, v43, vcc
	v_pk_add_f32 v[42:43], v[42:43], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v61
	v_div_scale_f32 v48, s[2:3], v43, v43, 1.0
	v_rcp_f32_e32 v49, v48
	v_cndmask_b32_e32 v47, v1, v47, vcc
	v_pk_add_f32 v[44:45], v[46:47], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[12:15], v29, v37, a[4:7]
	v_fma_f32 v38, -v48, v49, 1.0
	v_fmac_f32_e32 v49, v38, v49
	v_div_scale_f32 v38, vcc, 1.0, v43, 1.0
	v_mul_f32_e32 v39, v38, v49
	v_fma_f32 v46, -v48, v39, v38
	v_fmac_f32_e32 v39, v46, v49
	v_div_scale_f32 v46, s[2:3], v42, v42, 1.0
	v_rcp_f32_e32 v47, v46
	v_fma_f32 v38, -v48, v39, v38
	v_div_fmas_f32 v38, v38, v49, v39
	v_div_fixup_f32 v43, v38, v43, 1.0
	v_fma_f32 v38, -v46, v47, 1.0
	v_fmac_f32_e32 v47, v38, v47
	v_div_scale_f32 v38, vcc, 1.0, v42, 1.0
	v_mul_f32_e32 v39, v38, v47
	v_fma_f32 v40, -v46, v39, v38
	v_fmac_f32_e32 v39, v40, v47
	v_div_scale_f32 v40, s[2:3], v45, v45, 1.0
	v_rcp_f32_e32 v41, v40
	v_fma_f32 v38, -v46, v39, v38
	v_div_fmas_f32 v34, v38, v47, v39
	v_div_fixup_f32 v42, v34, v42, 1.0
	v_fma_f32 v34, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v34, v41
	v_div_scale_f32 v34, vcc, 1.0, v45, 1.0
	v_mul_f32_e32 v35, v34, v41
	v_fma_f32 v38, -v40, v35, v34
	v_fmac_f32_e32 v35, v38, v41
	v_div_scale_f32 v38, s[2:3], v44, v44, 1.0
	v_rcp_f32_e32 v39, v38
	v_fma_f32 v34, -v40, v35, v34
	v_div_fmas_f32 v34, v34, v41, v35
	v_div_fixup_f32 v41, v34, v45, 1.0
	v_fma_f32 v34, -v38, v39, 1.0
	v_fmac_f32_e32 v39, v34, v39
	v_div_scale_f32 v34, vcc, 1.0, v44, 1.0
	v_mul_f32_e32 v35, v34, v39
	v_fma_f32 v36, -v38, v35, v34
	v_fmac_f32_e32 v35, v36, v39
	v_fma_f32 v34, -v38, v35, v34
	v_div_fmas_f32 v34, v34, v39, v35
	v_div_fixup_f32 v40, v34, v44, 1.0
	v_fma_f32 v34, v64, s14, -v30
	v_fmac_f32_e32 v34, 0xb2a5705f, v64
	v_sub_f32_e32 v30, v30, v27
	v_add_f32_e32 v30, v30, v34
	v_cmp_gt_i32_e64 s[2:3], s12, v55
	v_exp_f32_e32 v30, v30
	v_cvt_i32_f32_e32 v27, v27
	s_and_b64 s[10:11], s[2:3], s[10:11]
	v_add_lshl_u32 v38, v68, s17, 2
	v_cndmask_b32_e64 v26, v51, 0, s[10:11]
	v_add_u32_e32 v26, v38, v26
	buffer_store_dwordx4 v[40:43], v26, s[20:23], 0 offen
	v_ldexp_f32 v26, v30, v27
	v_mul_f32_e32 v27, 0xbfb8aa3b, v65
	v_fma_f32 v28, v65, s14, -v27
	v_mfma_f32_16x16x4_f32 a[20:23], v29, v33, a[0:3]
	v_rndne_f32_e32 v29, v27
	v_fmac_f32_e32 v28, 0xb2a5705f, v65
	v_sub_f32_e32 v27, v27, v29
	v_add_f32_e32 v27, v27, v28
	v_cvt_i32_f32_e32 v28, v29
	v_mul_f32_e32 v29, 0xbfb8aa3b, v66
	v_fma_f32 v30, v66, s14, -v29
	v_rndne_f32_e32 v31, v29
	v_fmac_f32_e32 v30, 0xb2a5705f, v66
	v_sub_f32_e32 v29, v29, v31
	v_add_f32_e32 v29, v29, v30
	v_exp_f32_e32 v27, v27
	v_exp_f32_e32 v29, v29
	v_cvt_i32_f32_e32 v30, v31
	v_cmp_nlt_f32_e32 vcc, s16, v64
	v_ldexp_f32 v27, v27, v28
	v_mfma_f32_16x16x4_f32 a[0:3], v18, v10, a[36:39]
	v_ldexp_f32 v28, v29, v30
	v_mul_f32_e32 v29, 0xbfb8aa3b, v67
	v_fma_f32 v30, v67, s14, -v29
	v_rndne_f32_e32 v31, v29
	v_fmac_f32_e32 v30, 0xb2a5705f, v67
	v_sub_f32_e32 v29, v29, v31
	v_add_f32_e32 v29, v29, v30
	v_cndmask_b32_e32 v26, 0, v26, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v64
	v_exp_f32_e32 v29, v29
	v_cvt_i32_f32_e32 v30, v31
	v_cndmask_b32_e32 v26, v1, v26, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v65
	v_mfma_f32_16x16x4_f32 a[4:7], v18, v6, a[32:35]
	v_ldexp_f32 v29, v29, v30
	v_cndmask_b32_e32 v27, 0, v27, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v66
	s_and_b64 s[8:9], s[2:3], s[8:9]
	s_and_b64 s[4:5], s[4:5], s[2:3]
	v_cndmask_b32_e32 v28, 0, v28, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v66
	v_mfma_f32_16x16x4_f32 a[8:11], v18, v22, a[28:31]
	s_nop 0
	v_cndmask_b32_e32 v28, v1, v28, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v67
	s_nop 1
	v_cndmask_b32_e32 v29, 0, v29, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v67
	v_mfma_f32_16x16x4_f32 a[28:31], v18, v14, a[40:43]
	s_nop 0
	v_cndmask_b32_e32 v29, v1, v29, vcc
	v_pk_add_f32 v[28:29], v[28:29], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v65
	v_div_scale_f32 v30, s[10:11], v29, v29, 1.0
	v_rcp_f32_e32 v31, v30
	v_cndmask_b32_e32 v27, v1, v27, vcc
	v_pk_add_f32 v[26:27], v[26:27], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[0:3], v19, v11, a[0:3]
	v_fma_f32 v32, -v30, v31, 1.0
	v_fmac_f32_e32 v31, v32, v31
	v_div_scale_f32 v32, vcc, 1.0, v29, 1.0
	v_mul_f32_e32 v33, v32, v31
	v_fma_f32 v34, -v30, v33, v32
	v_fmac_f32_e32 v33, v34, v31
	v_fma_f32 v30, -v30, v33, v32
	v_div_scale_f32 v32, s[10:11], v28, v28, 1.0
	v_rcp_f32_e32 v34, v32
	v_div_fmas_f32 v30, v30, v31, v33
	v_div_fixup_f32 v29, v30, v29, 1.0
	v_mfma_f32_16x16x4_f32 a[4:7], v19, v7, a[4:7]
	v_fma_f32 v30, -v32, v34, 1.0
	v_fmac_f32_e32 v34, v30, v34
	v_div_scale_f32 v30, vcc, 1.0, v28, 1.0
	v_mul_f32_e32 v31, v30, v34
	v_fma_f32 v33, -v32, v31, v30
	v_fmac_f32_e32 v31, v33, v34
	v_fma_f32 v30, -v32, v31, v30
	v_div_scale_f32 v32, s[10:11], v27, v27, 1.0
	v_rcp_f32_e32 v33, v32
	v_div_fmas_f32 v30, v30, v34, v31
	v_div_fixup_f32 v28, v30, v28, 1.0
	v_mfma_f32_16x16x4_f32 a[8:11], v19, v23, a[8:11]
	v_fma_f32 v30, -v32, v33, 1.0
	v_fmac_f32_e32 v33, v30, v33
	v_div_scale_f32 v30, vcc, 1.0, v27, 1.0
	v_mul_f32_e32 v31, v30, v33
	v_fma_f32 v34, -v32, v31, v30
	v_fmac_f32_e32 v31, v34, v33
	v_fma_f32 v30, -v32, v31, v30
	v_div_scale_f32 v32, s[10:11], v26, v26, 1.0
	v_rcp_f32_e32 v34, v32
	v_div_fmas_f32 v30, v30, v33, v31
	v_div_fixup_f32 v27, v30, v27, 1.0
	v_mfma_f32_16x16x4_f32 a[28:31], v19, v15, a[28:31]
	v_fma_f32 v30, -v32, v34, 1.0
	v_fmac_f32_e32 v34, v30, v34
	v_div_scale_f32 v30, vcc, 1.0, v26, 1.0
	v_mul_f32_e32 v31, v30, v34
	v_fma_f32 v33, -v32, v31, v30
	v_fmac_f32_e32 v31, v33, v34
	v_fma_f32 v18, -v32, v31, v30
	v_div_fmas_f32 v18, v18, v34, v31
	ds_read_b128 v[30:33], v52 offset:528
	v_mfma_f32_16x16x4_f32 a[0:3], v20, v12, a[0:3]
	v_div_fixup_f32 v26, v18, v26, 1.0
	v_mov_b32_e32 v18, 0x7ffffff0
	v_cndmask_b32_e64 v18, v18, -16, s[8:9]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v19, 0xbfb8aa3b, v30
	v_fma_f32 v39, v30, s14, -v19
	v_rndne_f32_e32 v40, v19
	v_fmac_f32_e32 v39, 0xb2a5705f, v30
	v_mfma_f32_16x16x4_f32 a[4:7], v20, v8, a[4:7]
	v_sub_f32_e32 v19, v19, v40
	v_add_f32_e32 v19, v19, v39
	v_exp_f32_e32 v19, v19
	v_add_u32_e32 v18, v38, v18
	buffer_store_dwordx4 v[26:29], v18, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v30
	ds_read_b128 v[34:37], v52 offset:512
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v24, a[8:11]
	v_mfma_f32_16x16x4_f32 a[28:31], v20, v16, a[28:31]
	v_cvt_i32_f32_e32 v20, v40
	v_ldexp_f32 v18, v19, v20
	v_mul_f32_e32 v19, 0xbfb8aa3b, v31
	v_fma_f32 v20, v31, s14, -v19
	v_mfma_f32_16x16x4_f32 a[24:27], v2, v10, a[24:27]
	v_fmac_f32_e32 v20, 0xb2a5705f, v31
	v_cndmask_b32_e32 v10, 0, v18, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v30
	s_nop 1
	v_cndmask_b32_e32 v10, v1, v10, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v31
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v13, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v9, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v21, v25, a[8:11]
	v_mfma_f32_16x16x4_f32 a[28:31], v21, v17, a[28:31]
	v_rndne_f32_e32 v21, v19
	v_sub_f32_e32 v19, v19, v21
	v_add_f32_e32 v19, v19, v20
	v_exp_f32_e32 v19, v19
	v_cvt_i32_f32_e32 v20, v21
	v_ldexp_f32 v18, v19, v20
	v_mfma_f32_16x16x4_f32 a[24:27], v3, v11, a[24:27]
	v_mul_f32_e32 v19, 0xbfb8aa3b, v32
	v_fma_f32 v20, v32, s14, -v19
	v_rndne_f32_e32 v11, v19
	v_fmac_f32_e32 v20, 0xb2a5705f, v32
	v_sub_f32_e32 v19, v19, v11
	v_add_f32_e32 v19, v19, v20
	v_exp_f32_e32 v19, v19
	v_mfma_f32_16x16x4_f32 a[24:27], v4, v12, a[24:27]
	v_cvt_i32_f32_e32 v11, v11
	v_mul_f32_e32 v12, 0xbfb8aa3b, v33
	v_rndne_f32_e32 v20, v12
	v_cndmask_b32_e32 v18, 0, v18, vcc
	v_ldexp_f32 v11, v19, v11
	v_fma_f32 v19, v33, s14, -v12
	v_fmac_f32_e32 v19, 0xb2a5705f, v33
	v_sub_f32_e32 v12, v12, v20
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v6, a[16:19]
	v_add_f32_e32 v12, v12, v19
	v_cvt_i32_f32_e32 v19, v20
	v_cmp_nlt_f32_e32 vcc, s16, v32
	s_nop 1
	v_cndmask_b32_e32 v11, 0, v11, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v32
	v_mfma_f32_16x16x4_f32 a[24:27], v5, v13, a[24:27]
	v_exp_f32_e32 v13, v12
	v_cndmask_b32_e32 v12, v1, v11, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v33
	v_ldexp_f32 v11, v13, v19
	s_nop 0
	v_cndmask_b32_e32 v6, 0, v11, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v33
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v7, a[16:19]
	s_nop 0
	v_cndmask_b32_e32 v13, v1, v6, vcc
	v_pk_add_f32 v[12:13], v[12:13], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v31
	v_div_scale_f32 v19, s[8:9], v13, v13, 1.0
	v_rcp_f32_e32 v20, v19
	v_cndmask_b32_e32 v11, v1, v18, vcc
	v_pk_add_f32 v[6:7], v[10:11], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v8, a[16:19]
	v_fma_f32 v10, -v19, v20, 1.0
	v_fmac_f32_e32 v20, v10, v20
	v_div_scale_f32 v10, vcc, 1.0, v13, 1.0
	v_mul_f32_e32 v8, v10, v20
	v_fma_f32 v11, -v19, v8, v10
	v_fmac_f32_e32 v8, v11, v20
	v_div_scale_f32 v11, s[8:9], v12, v12, 1.0
	v_rcp_f32_e32 v18, v11
	v_fma_f32 v10, -v19, v8, v10
	v_div_fmas_f32 v8, v10, v20, v8
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v9, a[16:19]
	v_div_fixup_f32 v9, v8, v13, 1.0
	v_fma_f32 v8, -v11, v18, 1.0
	v_fmac_f32_e32 v18, v8, v18
	v_div_scale_f32 v8, vcc, 1.0, v12, 1.0
	v_mul_f32_e32 v10, v8, v18
	v_fma_f32 v13, -v11, v10, v8
	v_fmac_f32_e32 v10, v13, v18
	v_fma_f32 v8, -v11, v10, v8
	v_div_scale_f32 v11, s[8:9], v7, v7, 1.0
	v_rcp_f32_e32 v13, v11
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v22, a[12:15]
	v_div_fmas_f32 v8, v8, v18, v10
	v_div_fixup_f32 v8, v8, v12, 1.0
	v_fma_f32 v10, -v11, v13, 1.0
	v_fmac_f32_e32 v13, v10, v13
	v_div_scale_f32 v10, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v12, v10, v13
	v_mfma_f32_16x16x4_f32 a[20:23], v2, v14, a[20:23]
	v_fma_f32 v18, -v11, v12, v10
	v_fmac_f32_e32 v12, v18, v13
	v_fma_f32 v10, -v11, v12, v10
	v_div_scale_f32 v11, s[8:9], v6, v6, 1.0
	v_rcp_f32_e32 v18, v11
	v_div_fmas_f32 v10, v10, v13, v12
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v23, a[12:15]
	v_div_fixup_f32 v7, v10, v7, 1.0
	v_fma_f32 v10, -v11, v18, 1.0
	v_fmac_f32_e32 v18, v10, v18
	v_div_scale_f32 v10, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v12, v10, v18
	v_fma_f32 v2, -v11, v12, v10
	v_mfma_f32_16x16x4_f32 a[20:23], v3, v15, a[20:23]
	v_fmac_f32_e32 v12, v2, v18
	v_fma_f32 v2, -v11, v12, v10
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v10, 0xbfb8aa3b, v34
	v_div_fmas_f32 v2, v2, v18, v12
	v_fma_f32 v11, v34, s14, -v10
	v_rndne_f32_e32 v12, v10
	v_fmac_f32_e32 v11, 0xb2a5705f, v34
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v24, a[12:15]
	v_sub_f32_e32 v10, v10, v12
	v_add_f32_e32 v10, v10, v11
	v_div_fixup_f32 v6, v2, v6, 1.0
	v_mov_b32_e32 v2, 0x7fffffe0
	v_not_b32_e32 v3, 31
	s_and_b64 vcc, s[2:3], s[6:7]
	v_cndmask_b32_e32 v2, v2, v3, vcc
	v_mfma_f32_16x16x4_f32 a[20:23], v4, v16, a[20:23]
	v_exp_f32_e32 v4, v10
	v_cvt_i32_f32_e32 v10, v12
	v_add_u32_e32 v2, v38, v2
	v_mul_f32_e32 v3, 0xbfb8aa3b, v35
	buffer_store_dwordx4 v[6:9], v2, s[20:23], 0 offen
	v_ldexp_f32 v2, v4, v10
	v_fma_f32 v4, v35, s14, -v3
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v25, a[12:15]
	v_fmac_f32_e32 v4, 0xb2a5705f, v35
	v_cmp_nlt_f32_e32 vcc, s16, v34
	s_nop 1
	v_cndmask_b32_e32 v2, 0, v2, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v34
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v17, a[20:23]
	v_rndne_f32_e32 v5, v3
	v_sub_f32_e32 v3, v3, v5
	v_add_f32_e32 v3, v3, v4
	v_cvt_i32_f32_e32 v4, v5
	v_mul_f32_e32 v5, 0xbfb8aa3b, v36
	v_fma_f32 v6, v36, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v36
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v3, v3
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cndmask_b32_e32 v2, v1, v2, vcc
	v_ldexp_f32 v3, v3, v4
	v_cmp_nlt_f32_e32 vcc, s16, v35
	v_ldexp_f32 v4, v5, v6
	v_mul_f32_e32 v5, 0xbfb8aa3b, v37
	v_fma_f32 v6, v37, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v37
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v36
	v_ldexp_f32 v5, v5, v6
	s_nop 0
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v36
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v4, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v37
	s_nop 1
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v37
	s_nop 1
	v_cndmask_b32_e32 v5, v1, v5, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v35
	v_div_scale_f32 v6, s[6:7], v5, v5, 1.0
	v_rcp_f32_e32 v7, v6
	v_cndmask_b32_e32 v3, v1, v3, vcc
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v8, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v8, v7
	v_div_scale_f32 v8, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v10, -v6, v9, v8
	v_fmac_f32_e32 v9, v10, v7
	v_fma_f32 v6, -v6, v9, v8
	v_div_scale_f32 v8, s[6:7], v4, v4, 1.0
	v_rcp_f32_e32 v10, v8
	v_div_fmas_f32 v6, v6, v7, v9
	v_div_fixup_f32 v7, v6, v5, 1.0
	v_fma_f32 v5, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v5, v10
	v_div_scale_f32 v5, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v6, v5, v10
	v_fma_f32 v9, -v8, v6, v5
	v_fmac_f32_e32 v6, v9, v10
	v_fma_f32 v5, -v8, v6, v5
	v_div_scale_f32 v8, s[6:7], v3, v3, 1.0
	v_rcp_f32_e32 v9, v8
	v_div_fmas_f32 v5, v5, v10, v6
	v_div_fixup_f32 v6, v5, v4, 1.0
	v_fma_f32 v4, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v4, v9
	v_div_scale_f32 v4, vcc, 1.0, v3, 1.0
	v_mul_f32_e32 v5, v4, v9
	v_fma_f32 v10, -v8, v5, v4
	v_fmac_f32_e32 v5, v10, v9
	v_fma_f32 v4, -v8, v5, v4
	v_div_scale_f32 v8, s[6:7], v2, v2, 1.0
	v_rcp_f32_e32 v10, v8
	v_div_fmas_f32 v4, v4, v9, v5
	v_div_fixup_f32 v5, v4, v3, 1.0
	v_fma_f32 v3, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v3, v10
	v_div_scale_f32 v3, vcc, 1.0, v2, 1.0
	v_mul_f32_e32 v4, v3, v10
	v_fma_f32 v9, -v8, v4, v3
	v_fmac_f32_e32 v4, v9, v10
	v_fma_f32 v3, -v8, v4, v3
	v_div_fmas_f32 v3, v3, v10, v4
	v_div_fixup_f32 v4, v3, v2, 1.0
	v_add_lshl_u32 v2, v50, s17, 2
	v_cndmask_b32_e64 v3, v51, 0, s[4:5]
	v_add_u32_e32 v3, v3, v2
	buffer_store_dwordx4 v[4:7], v3, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v54, a0
	ds_write_b32 v54, a1 offset:512
	ds_write_b32 v54, a2 offset:1024
	ds_write_b32 v54, a3 offset:1536
	ds_write_b32 v54, a7 offset:1664
	ds_write_b32 v54, a6 offset:1152
	ds_write_b32 v54, a5 offset:640
	ds_write_b32 v54, a4 offset:128
	ds_write_b32 v54, a8 offset:256
	ds_write_b32 v54, a9 offset:768
	ds_write_b32 v54, a10 offset:1280
	ds_write_b32 v54, a11 offset:1792
	ds_write_b32 v54, a31 offset:1920
	ds_write_b32 v54, a30 offset:1408
	ds_write_b32 v54, a29 offset:896
	ds_write_b32 v54, a28 offset:384
	ds_write_b32 v54, a20 offset:16768
	ds_write_b32 v54, a21 offset:17280
	ds_write_b32 v54, a22 offset:17792
	ds_write_b32 v54, a23 offset:18304
	ds_write_b32 v54, a15 offset:18176
	ds_write_b32 v54, a14 offset:17664
	ds_write_b32 v54, a13 offset:17152
	ds_write_b32 v54, a12 offset:16640
	ds_write_b32 v54, a16 offset:16512
	ds_write_b32 v54, a17 offset:17024
	ds_write_b32 v54, a18 offset:17536
	ds_write_b32 v54, a19 offset:18048
	ds_write_b32 v54, a27 offset:17920
	ds_write_b32 v54, a26 offset:17408
	ds_write_b32 v54, a25 offset:16896
	ds_write_b32 v54, a24 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[4:7], v52
	ds_read_b128 v[8:11], v52 offset:16
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v3, 0xbfb8aa3b, v4
	v_fma_f32 v12, v4, s14, -v3
	v_rndne_f32_e32 v13, v3
	v_fmac_f32_e32 v12, 0xb2a5705f, v4
	v_sub_f32_e32 v3, v3, v13
	v_add_f32_e32 v3, v3, v12
	v_exp_f32_e32 v3, v3
	v_cvt_i32_f32_e32 v12, v13
	v_cmp_nlt_f32_e32 vcc, s16, v4
	v_or_b32_e32 v13, 0x80, v0
	v_ldexp_f32 v3, v3, v12
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v4
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v3, vcc
	v_mul_f32_e32 v3, 0xbfb8aa3b, v5
	v_fma_f32 v12, v5, s14, -v3
	v_rndne_f32_e32 v14, v3
	v_fmac_f32_e32 v12, 0xb2a5705f, v5
	v_sub_f32_e32 v3, v3, v14
	v_add_f32_e32 v3, v3, v12
	v_cvt_i32_f32_e32 v12, v14
	v_mul_f32_e32 v14, 0xbfb8aa3b, v6
	v_fma_f32 v15, v6, s14, -v14
	v_rndne_f32_e32 v16, v14
	v_fmac_f32_e32 v15, 0xb2a5705f, v6
	v_sub_f32_e32 v14, v14, v16
	v_add_f32_e32 v14, v14, v15
	v_exp_f32_e32 v3, v3
	v_exp_f32_e32 v14, v14
	v_cvt_i32_f32_e32 v15, v16
	v_cmp_nlt_f32_e32 vcc, s16, v5
	v_ldexp_f32 v3, v3, v12
	v_ldexp_f32 v12, v14, v15
	v_mul_f32_e32 v14, 0xbfb8aa3b, v7
	v_fma_f32 v15, v7, s14, -v14
	v_rndne_f32_e32 v16, v14
	v_fmac_f32_e32 v15, 0xb2a5705f, v7
	v_sub_f32_e32 v14, v14, v16
	v_add_f32_e32 v14, v14, v15
	v_exp_f32_e32 v14, v14
	v_cvt_i32_f32_e32 v15, v16
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v6
	s_nop 1
	v_cndmask_b32_e32 v12, 0, v12, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v12, vcc
	v_ldexp_f32 v12, v14, v15
	v_cmp_nlt_f32_e32 vcc, s16, v7
	s_nop 1
	v_cndmask_b32_e32 v12, 0, v12, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v12, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v5
	v_div_scale_f32 v12, s[4:5], v7, v7, 1.0
	v_rcp_f32_e32 v14, v12
	v_cndmask_b32_e32 v5, v1, v3, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v3, -v12, v14, 1.0
	v_fmac_f32_e32 v14, v3, v14
	v_div_scale_f32 v3, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v15, v3, v14
	v_fma_f32 v16, -v12, v15, v3
	v_fmac_f32_e32 v15, v16, v14
	v_fma_f32 v3, -v12, v15, v3
	v_div_scale_f32 v12, s[4:5], v6, v6, 1.0
	v_rcp_f32_e32 v16, v12
	v_div_fmas_f32 v3, v3, v14, v15
	v_div_fixup_f32 v7, v3, v7, 1.0
	v_fma_f32 v3, -v12, v16, 1.0
	v_fmac_f32_e32 v16, v3, v16
	v_div_scale_f32 v3, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v14, v3, v16
	v_fma_f32 v15, -v12, v14, v3
	v_fmac_f32_e32 v14, v15, v16
	v_fma_f32 v3, -v12, v14, v3
	v_div_scale_f32 v12, s[4:5], v5, v5, 1.0
	v_rcp_f32_e32 v15, v12
	v_div_fmas_f32 v3, v3, v16, v14
	v_div_fixup_f32 v6, v3, v6, 1.0
	v_fma_f32 v3, -v12, v15, 1.0
	v_fmac_f32_e32 v15, v3, v15
	v_div_scale_f32 v3, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v14, v3, v15
	v_fma_f32 v16, -v12, v14, v3
	v_fmac_f32_e32 v14, v16, v15
	v_fma_f32 v3, -v12, v14, v3
	v_div_scale_f32 v12, s[4:5], v4, v4, 1.0
	v_rcp_f32_e32 v16, v12
	v_div_fmas_f32 v3, v3, v15, v14
	v_div_fixup_f32 v5, v3, v5, 1.0
	v_cmp_gt_i32_e64 s[4:5], s13, v13
	v_fma_f32 v3, -v12, v16, 1.0
	v_fmac_f32_e32 v16, v3, v16
	v_div_scale_f32 v3, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v14, v3, v16
	v_fma_f32 v15, -v12, v14, v3
	v_fmac_f32_e32 v14, v15, v16
	v_fma_f32 v3, -v12, v14, v3
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v13, 0xbfb8aa3b, v8
	v_div_fmas_f32 v3, v3, v16, v14
	v_fma_f32 v14, v8, s14, -v13
	v_rndne_f32_e32 v15, v13
	s_and_b64 s[6:7], s[0:1], s[4:5]
	v_fmac_f32_e32 v14, 0xb2a5705f, v8
	v_sub_f32_e32 v13, v13, v15
	v_div_fixup_f32 v4, v3, v4, 1.0
	v_add_u32_e32 v3, 0x200, v53
	v_cndmask_b32_e64 v12, v51, 0, s[6:7]
	v_add_f32_e32 v13, v13, v14
	v_exp_f32_e32 v13, v13
	v_cvt_i32_f32_e32 v14, v15
	v_add_u32_e32 v12, v3, v12
	buffer_store_dwordx4 v[4:7], v12, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v8
	v_or_b32_e32 v12, 0x84, v0
	v_mul_f32_e32 v5, 0xbfb8aa3b, v9
	v_fma_f32 v6, v9, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v9
	v_sub_f32_e32 v5, v5, v7
	v_ldexp_f32 v4, v13, v14
	v_add_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v7
	v_mul_f32_e32 v7, 0xbfb8aa3b, v10
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v8
	v_fma_f32 v8, v10, s14, -v7
	v_rndne_f32_e32 v13, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v10
	v_sub_f32_e32 v7, v7, v13
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v13
	v_cndmask_b32_e32 v4, v1, v4, vcc
	v_ldexp_f32 v5, v5, v6
	v_cmp_nlt_f32_e32 vcc, s16, v9
	v_ldexp_f32 v6, v7, v8
	v_mul_f32_e32 v7, 0xbfb8aa3b, v11
	v_fma_f32 v8, v11, s14, -v7
	v_rndne_f32_e32 v13, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v11
	v_sub_f32_e32 v7, v7, v13
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v13
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v10
	v_ldexp_f32 v7, v7, v8
	s_nop 0
	v_cndmask_b32_e32 v6, 0, v6, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v10
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v6, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v11
	s_nop 1
	v_cndmask_b32_e32 v7, 0, v7, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v11
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v7, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v9
	v_div_scale_f32 v8, s[6:7], v7, v7, 1.0
	v_rcp_f32_e32 v10, v8
	v_cndmask_b32_e32 v5, v1, v5, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v9, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v9, v10
	v_div_scale_f32 v9, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v11, v9, v10
	v_fma_f32 v13, -v8, v11, v9
	v_fmac_f32_e32 v11, v13, v10
	v_fma_f32 v8, -v8, v11, v9
	v_div_scale_f32 v9, s[6:7], v6, v6, 1.0
	v_rcp_f32_e32 v13, v9
	v_div_fmas_f32 v8, v8, v10, v11
	v_div_fixup_f32 v7, v8, v7, 1.0
	v_fma_f32 v8, -v9, v13, 1.0
	v_fmac_f32_e32 v13, v8, v13
	v_div_scale_f32 v8, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v10, v8, v13
	v_fma_f32 v11, -v9, v10, v8
	v_fmac_f32_e32 v10, v11, v13
	v_fma_f32 v8, -v9, v10, v8
	v_div_scale_f32 v9, s[6:7], v5, v5, 1.0
	v_rcp_f32_e32 v11, v9
	v_div_fmas_f32 v8, v8, v13, v10
	v_div_fixup_f32 v6, v8, v6, 1.0
	v_fma_f32 v8, -v9, v11, 1.0
	v_fmac_f32_e32 v11, v8, v11
	v_div_scale_f32 v8, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v10, v8, v11
	v_fma_f32 v13, -v9, v10, v8
	v_fmac_f32_e32 v10, v13, v11
	v_fma_f32 v8, -v9, v10, v8
	v_div_scale_f32 v9, s[6:7], v4, v4, 1.0
	v_rcp_f32_e32 v13, v9
	v_div_fmas_f32 v8, v8, v11, v10
	v_div_fixup_f32 v5, v8, v5, 1.0
	v_cmp_gt_i32_e64 s[6:7], s13, v12
	v_fma_f32 v8, -v9, v13, 1.0
	v_fmac_f32_e32 v13, v8, v13
	v_div_scale_f32 v8, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v10, v8, v13
	v_fma_f32 v11, -v9, v10, v8
	v_fmac_f32_e32 v10, v11, v13
	v_fma_f32 v8, -v9, v10, v8
	v_div_fmas_f32 v8, v8, v13, v10
	v_div_fixup_f32 v4, v8, v4, 1.0
	ds_read_b128 v[8:11], v52 offset:32
	v_mov_b32_e32 v12, 0x80000010
	s_and_b64 s[8:9], s[0:1], s[6:7]
	v_cndmask_b32_e64 v16, v12, 16, s[8:9]
	v_add_u32_e32 v16, v3, v16
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v17, 0xbfb8aa3b, v8
	v_fma_f32 v18, v8, s14, -v17
	v_rndne_f32_e32 v19, v17
	v_fmac_f32_e32 v18, 0xb2a5705f, v8
	v_sub_f32_e32 v17, v17, v19
	v_add_f32_e32 v17, v17, v18
	v_exp_f32_e32 v17, v17
	v_cvt_i32_f32_e32 v18, v19
	buffer_store_dwordx4 v[4:7], v16, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v8
	ds_read_b128 v[12:15], v52 offset:48
	v_mul_f32_e32 v5, 0xbfb8aa3b, v9
	v_fma_f32 v6, v9, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v9
	v_sub_f32_e32 v5, v5, v7
	v_ldexp_f32 v4, v17, v18
	v_add_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v7
	v_mul_f32_e32 v7, 0xbfb8aa3b, v10
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v8
	v_fma_f32 v8, v10, s14, -v7
	v_rndne_f32_e32 v17, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v10
	v_sub_f32_e32 v7, v7, v17
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v17
	v_cndmask_b32_e32 v4, v1, v4, vcc
	v_ldexp_f32 v5, v5, v6
	v_cmp_nlt_f32_e32 vcc, s16, v9
	v_ldexp_f32 v6, v7, v8
	v_mul_f32_e32 v7, 0xbfb8aa3b, v11
	v_fma_f32 v8, v11, s14, -v7
	v_rndne_f32_e32 v17, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v11
	v_sub_f32_e32 v7, v7, v17
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v17
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v10
	v_or_b32_e32 v16, 0x88, v0
	v_ldexp_f32 v7, v7, v8
	v_cndmask_b32_e32 v6, 0, v6, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v10
	v_or_b32_e32 v0, 0x8c, v0
	s_nop 0
	v_cndmask_b32_e32 v6, v1, v6, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v11
	s_nop 1
	v_cndmask_b32_e32 v7, 0, v7, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v11
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v7, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v9
	v_div_scale_f32 v8, s[8:9], v7, v7, 1.0
	v_rcp_f32_e32 v10, v8
	v_cndmask_b32_e32 v5, v1, v5, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v9, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v9, v10
	v_div_scale_f32 v9, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v11, v9, v10
	v_fma_f32 v17, -v8, v11, v9
	v_fmac_f32_e32 v11, v17, v10
	v_fma_f32 v8, -v8, v11, v9
	v_div_scale_f32 v9, s[8:9], v6, v6, 1.0
	v_rcp_f32_e32 v17, v9
	v_div_fmas_f32 v8, v8, v10, v11
	v_div_fixup_f32 v7, v8, v7, 1.0
	v_fma_f32 v8, -v9, v17, 1.0
	v_fmac_f32_e32 v17, v8, v17
	v_div_scale_f32 v8, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v10, v8, v17
	v_fma_f32 v11, -v9, v10, v8
	v_fmac_f32_e32 v10, v11, v17
	v_fma_f32 v8, -v9, v10, v8
	v_div_scale_f32 v9, s[8:9], v5, v5, 1.0
	v_rcp_f32_e32 v11, v9
	v_div_fmas_f32 v8, v8, v17, v10
	v_div_fixup_f32 v6, v8, v6, 1.0
	v_fma_f32 v8, -v9, v11, 1.0
	v_fmac_f32_e32 v11, v8, v11
	v_div_scale_f32 v8, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v10, v8, v11
	v_fma_f32 v17, -v9, v10, v8
	v_fmac_f32_e32 v10, v17, v11
	v_fma_f32 v8, -v9, v10, v8
	v_div_scale_f32 v9, s[8:9], v4, v4, 1.0
	v_rcp_f32_e32 v17, v9
	v_div_fmas_f32 v8, v8, v11, v10
	v_div_fixup_f32 v5, v8, v5, 1.0
	v_cmp_gt_i32_e64 s[8:9], s13, v16
	v_fma_f32 v8, -v9, v17, 1.0
	v_fmac_f32_e32 v17, v8, v17
	v_div_scale_f32 v8, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v10, v8, v17
	v_fma_f32 v11, -v9, v10, v8
	v_fmac_f32_e32 v10, v11, v17
	v_fma_f32 v8, -v9, v10, v8
	v_div_fmas_f32 v8, v8, v17, v10
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v9, 0xbfb8aa3b, v12
	v_div_fixup_f32 v4, v8, v4, 1.0
	v_mov_b32_e32 v8, 0x80000020
	s_and_b64 s[10:11], s[0:1], s[8:9]
	v_fma_f32 v10, v12, s14, -v9
	v_rndne_f32_e32 v11, v9
	v_cndmask_b32_e64 v8, v8, 32, s[10:11]
	v_fmac_f32_e32 v10, 0xb2a5705f, v12
	v_sub_f32_e32 v9, v9, v11
	v_add_f32_e32 v9, v9, v10
	v_add_u32_e32 v8, v3, v8
	v_exp_f32_e32 v9, v9
	v_cvt_i32_f32_e32 v10, v11
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v12
	s_nop 0
	v_mul_f32_e32 v5, 0xbfb8aa3b, v13
	v_fma_f32 v6, v13, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v13
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v7
	v_mul_f32_e32 v7, 0xbfb8aa3b, v14
	v_ldexp_f32 v4, v9, v10
	v_fma_f32 v8, v14, s14, -v7
	v_rndne_f32_e32 v9, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v14
	v_sub_f32_e32 v7, v7, v9
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v9
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_ldexp_f32 v5, v5, v6
	v_cmp_ngt_f32_e32 vcc, s15, v12
	v_ldexp_f32 v6, v7, v8
	v_mul_f32_e32 v7, 0xbfb8aa3b, v15
	v_fma_f32 v8, v15, s14, -v7
	v_rndne_f32_e32 v9, v7
	v_fmac_f32_e32 v8, 0xb2a5705f, v15
	v_sub_f32_e32 v7, v7, v9
	v_add_f32_e32 v7, v7, v8
	v_exp_f32_e32 v7, v7
	v_cvt_i32_f32_e32 v8, v9
	v_cndmask_b32_e32 v4, v1, v4, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v13
	v_ldexp_f32 v7, v7, v8
	s_nop 0
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v14
	s_nop 1
	v_cndmask_b32_e32 v6, 0, v6, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v14
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v6, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v15
	s_nop 1
	v_cndmask_b32_e32 v7, 0, v7, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v15
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v7, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v13
	v_div_scale_f32 v8, s[10:11], v7, v7, 1.0
	v_rcp_f32_e32 v9, v8
	v_cndmask_b32_e32 v5, v1, v5, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v10, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v10, v9
	v_div_scale_f32 v10, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v11, v10, v9
	v_fma_f32 v12, -v8, v11, v10
	v_fmac_f32_e32 v11, v12, v9
	v_fma_f32 v8, -v8, v11, v10
	v_div_scale_f32 v10, s[10:11], v6, v6, 1.0
	v_rcp_f32_e32 v12, v10
	v_div_fmas_f32 v8, v8, v9, v11
	v_div_fixup_f32 v7, v8, v7, 1.0
	v_fma_f32 v8, -v10, v12, 1.0
	v_fmac_f32_e32 v12, v8, v12
	v_div_scale_f32 v8, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v9, v8, v12
	v_fma_f32 v11, -v10, v9, v8
	v_fmac_f32_e32 v9, v11, v12
	v_fma_f32 v8, -v10, v9, v8
	v_div_scale_f32 v10, s[10:11], v5, v5, 1.0
	v_rcp_f32_e32 v11, v10
	v_div_fmas_f32 v8, v8, v12, v9
	v_div_fixup_f32 v6, v8, v6, 1.0
	v_fma_f32 v8, -v10, v11, 1.0
	v_fmac_f32_e32 v11, v8, v11
	v_div_scale_f32 v8, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v9, v8, v11
	v_fma_f32 v12, -v10, v9, v8
	v_fmac_f32_e32 v9, v12, v11
	v_fma_f32 v8, -v10, v9, v8
	v_div_scale_f32 v10, s[10:11], v4, v4, 1.0
	v_rcp_f32_e32 v12, v10
	v_div_fmas_f32 v8, v8, v11, v9
	v_div_fixup_f32 v5, v8, v5, 1.0
	v_cmp_gt_i32_e64 s[10:11], s13, v0
	v_fma_f32 v8, -v10, v12, 1.0
	v_fmac_f32_e32 v12, v8, v12
	v_div_scale_f32 v8, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v9, v8, v12
	v_fma_f32 v11, -v10, v9, v8
	v_fmac_f32_e32 v9, v11, v12
	v_fma_f32 v8, -v10, v9, v8
	v_div_fmas_f32 v12, v8, v12, v9
	ds_read_b128 v[8:11], v52 offset:560
	v_mov_b32_e32 v0, 0x80000030
	s_and_b64 s[0:1], s[0:1], s[10:11]
	v_cndmask_b32_e64 v0, v0, 48, s[0:1]
	v_div_fixup_f32 v4, v12, v4, 1.0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v16, 0xbfb8aa3b, v8
	v_fma_f32 v17, v8, s14, -v16
	v_rndne_f32_e32 v18, v16
	v_fmac_f32_e32 v17, 0xb2a5705f, v8
	v_sub_f32_e32 v16, v16, v18
	v_add_f32_e32 v16, v16, v17
	v_exp_f32_e32 v16, v16
	v_cvt_i32_f32_e32 v17, v18
	v_add_u32_e32 v0, v3, v0
	buffer_store_dwordx4 v[4:7], v0, s[20:23], 0 offen
	v_cmp_nlt_f32_e32 vcc, s16, v8
	v_ldexp_f32 v0, v16, v17
	ds_read_b128 v[12:15], v52 offset:544
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v8
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v0, vcc
	v_mul_f32_e32 v0, 0xbfb8aa3b, v9
	v_fma_f32 v3, v9, s14, -v0
	v_rndne_f32_e32 v5, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v9
	v_sub_f32_e32 v0, v0, v5
	v_add_f32_e32 v0, v0, v3
	v_cvt_i32_f32_e32 v3, v5
	v_mul_f32_e32 v5, 0xbfb8aa3b, v10
	v_fma_f32 v6, v10, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v10
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v0, v0
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cmp_nlt_f32_e32 vcc, s16, v9
	v_ldexp_f32 v0, v0, v3
	v_ldexp_f32 v3, v5, v6
	v_mul_f32_e32 v5, 0xbfb8aa3b, v11
	v_fma_f32 v6, v11, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v11
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v7, v7
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v10
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v10
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v3, vcc
	v_ldexp_f32 v3, v5, v7
	v_cmp_nlt_f32_e32 vcc, s16, v11
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v11
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v3, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v9
	v_div_scale_f32 v3, s[0:1], v7, v7, 1.0
	v_rcp_f32_e32 v8, v3
	v_cndmask_b32_e32 v5, v1, v0, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v0, -v3, v8, 1.0
	v_fmac_f32_e32 v8, v0, v8
	v_div_scale_f32 v0, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v9, v0, v8
	v_fma_f32 v10, -v3, v9, v0
	v_fmac_f32_e32 v9, v10, v8
	v_fma_f32 v0, -v3, v9, v0
	v_div_scale_f32 v3, s[0:1], v6, v6, 1.0
	v_rcp_f32_e32 v10, v3
	v_div_fmas_f32 v0, v0, v8, v9
	v_div_fixup_f32 v7, v0, v7, 1.0
	v_fma_f32 v0, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v0, v10
	v_div_scale_f32 v0, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v8, v0, v10
	v_fma_f32 v9, -v3, v8, v0
	v_fmac_f32_e32 v8, v9, v10
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v5, v5, 1.0
	v_rcp_f32_e32 v9, v3
	v_div_fmas_f32 v0, v0, v10, v8
	v_div_fixup_f32 v6, v0, v6, 1.0
	v_fma_f32 v0, -v3, v9, 1.0
	v_fmac_f32_e32 v9, v0, v9
	v_div_scale_f32 v0, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v8, v0, v9
	v_fma_f32 v10, -v3, v8, v0
	v_fmac_f32_e32 v8, v10, v9
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v4, v4, 1.0
	v_rcp_f32_e32 v10, v3
	v_div_fmas_f32 v0, v0, v9, v8
	v_div_fixup_f32 v5, v0, v5, 1.0
	s_and_b64 s[0:1], s[2:3], s[10:11]
	v_fma_f32 v0, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v0, v10
	v_div_scale_f32 v0, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v8, v0, v10
	v_fma_f32 v9, -v3, v8, v0
	v_fmac_f32_e32 v8, v9, v10
	v_fma_f32 v0, -v3, v8, v0
	v_div_fmas_f32 v0, v0, v10, v8
	v_div_fixup_f32 v4, v0, v4, 1.0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, 0xbfb8aa3b, v12
	v_fma_f32 v3, v12, s14, -v0
	v_rndne_f32_e32 v8, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v12
	v_sub_f32_e32 v0, v0, v8
	v_add_f32_e32 v0, v0, v3
	v_exp_f32_e32 v0, v0
	v_cvt_i32_f32_e32 v3, v8
	v_cndmask_b32_e64 v8, v51, 0, s[0:1]
	v_cmp_nlt_f32_e32 vcc, s16, v12
	v_add_u32_e32 v8, v2, v8
	v_ldexp_f32 v0, v0, v3
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v12
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:560
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v0, vcc
	v_mul_f32_e32 v0, 0xbfb8aa3b, v13
	v_fma_f32 v3, v13, s14, -v0
	v_rndne_f32_e32 v5, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v13
	v_sub_f32_e32 v0, v0, v5
	v_add_f32_e32 v0, v0, v3
	v_cvt_i32_f32_e32 v3, v5
	v_mul_f32_e32 v5, 0xbfb8aa3b, v14
	v_fma_f32 v6, v14, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v14
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v0, v0
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cmp_nlt_f32_e32 vcc, s16, v13
	v_ldexp_f32 v0, v0, v3
	v_ldexp_f32 v3, v5, v6
	v_mul_f32_e32 v5, 0xbfb8aa3b, v15
	v_fma_f32 v6, v15, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v15
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v7, v7
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v14
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v14
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v3, vcc
	v_ldexp_f32 v3, v5, v7
	v_cmp_nlt_f32_e32 vcc, s16, v15
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v15
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v3, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v13
	v_div_scale_f32 v3, s[0:1], v7, v7, 1.0
	v_rcp_f32_e32 v8, v3
	v_cndmask_b32_e32 v5, v1, v0, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v0, -v3, v8, 1.0
	v_fmac_f32_e32 v8, v0, v8
	v_div_scale_f32 v0, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v9, v0, v8
	v_fma_f32 v10, -v3, v9, v0
	v_fmac_f32_e32 v9, v10, v8
	v_fma_f32 v0, -v3, v9, v0
	v_div_scale_f32 v3, s[0:1], v6, v6, 1.0
	v_rcp_f32_e32 v10, v3
	v_div_fmas_f32 v0, v0, v8, v9
	v_div_fixup_f32 v7, v0, v7, 1.0
	v_fma_f32 v0, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v0, v10
	v_div_scale_f32 v0, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v8, v0, v10
	v_fma_f32 v9, -v3, v8, v0
	v_fmac_f32_e32 v8, v9, v10
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v5, v5, 1.0
	v_rcp_f32_e32 v9, v3
	v_div_fmas_f32 v0, v0, v10, v8
	v_div_fixup_f32 v6, v0, v6, 1.0
	v_fma_f32 v0, -v3, v9, 1.0
	v_fmac_f32_e32 v9, v0, v9
	v_div_scale_f32 v0, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v8, v0, v9
	v_fma_f32 v10, -v3, v8, v0
	v_fmac_f32_e32 v8, v10, v9
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v4, v4, 1.0
	v_rcp_f32_e32 v12, v3
	v_div_fmas_f32 v0, v0, v9, v8
	v_div_fixup_f32 v5, v0, v5, 1.0
	s_and_b64 s[0:1], s[2:3], s[8:9]
	v_fma_f32 v0, -v3, v12, 1.0
	v_fmac_f32_e32 v12, v0, v12
	v_div_scale_f32 v0, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v13, v0, v12
	v_fma_f32 v8, -v3, v13, v0
	v_fmac_f32_e32 v13, v8, v12
	ds_read_b128 v[8:11], v52 offset:528
	v_fma_f32 v0, -v3, v13, v0
	v_div_fmas_f32 v0, v0, v12, v13
	v_div_fixup_f32 v4, v0, v4, 1.0
	ds_read_b128 v[12:15], v52 offset:512
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v0, 0xbfb8aa3b, v8
	v_fma_f32 v3, v8, s14, -v0
	v_rndne_f32_e32 v16, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v8
	v_sub_f32_e32 v0, v0, v16
	v_add_f32_e32 v0, v0, v3
	v_exp_f32_e32 v0, v0
	v_cvt_i32_f32_e32 v3, v16
	v_cndmask_b32_e64 v16, v51, 0, s[0:1]
	v_cmp_nlt_f32_e32 vcc, s16, v8
	v_add_u32_e32 v16, v2, v16
	v_ldexp_f32 v0, v0, v3
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v8
	buffer_store_dwordx4 v[4:7], v16, s[20:23], 0 offen offset:544
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v0, vcc
	v_mul_f32_e32 v0, 0xbfb8aa3b, v9
	v_fma_f32 v3, v9, s14, -v0
	v_rndne_f32_e32 v5, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v9
	v_sub_f32_e32 v0, v0, v5
	v_add_f32_e32 v0, v0, v3
	v_cvt_i32_f32_e32 v3, v5
	v_mul_f32_e32 v5, 0xbfb8aa3b, v10
	v_fma_f32 v6, v10, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v10
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v0, v0
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cmp_nlt_f32_e32 vcc, s16, v9
	v_ldexp_f32 v0, v0, v3
	v_ldexp_f32 v3, v5, v6
	v_mul_f32_e32 v5, 0xbfb8aa3b, v11
	v_fma_f32 v6, v11, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v11
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v7, v7
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v10
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v10
	s_nop 1
	v_cndmask_b32_e32 v6, v1, v3, vcc
	v_ldexp_f32 v3, v5, v7
	v_cmp_nlt_f32_e32 vcc, s16, v11
	s_nop 1
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v11
	s_nop 1
	v_cndmask_b32_e32 v7, v1, v3, vcc
	v_pk_add_f32 v[6:7], v[6:7], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v9
	v_div_scale_f32 v3, s[0:1], v7, v7, 1.0
	v_rcp_f32_e32 v8, v3
	v_cndmask_b32_e32 v5, v1, v0, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v0, -v3, v8, 1.0
	v_fmac_f32_e32 v8, v0, v8
	v_div_scale_f32 v0, vcc, 1.0, v7, 1.0
	v_mul_f32_e32 v9, v0, v8
	v_fma_f32 v10, -v3, v9, v0
	v_fmac_f32_e32 v9, v10, v8
	v_fma_f32 v0, -v3, v9, v0
	v_div_scale_f32 v3, s[0:1], v6, v6, 1.0
	v_rcp_f32_e32 v10, v3
	v_div_fmas_f32 v0, v0, v8, v9
	v_div_fixup_f32 v7, v0, v7, 1.0
	v_fma_f32 v0, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v0, v10
	v_div_scale_f32 v0, vcc, 1.0, v6, 1.0
	v_mul_f32_e32 v8, v0, v10
	v_fma_f32 v9, -v3, v8, v0
	v_fmac_f32_e32 v8, v9, v10
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v5, v5, 1.0
	v_rcp_f32_e32 v9, v3
	v_div_fmas_f32 v0, v0, v10, v8
	v_div_fixup_f32 v6, v0, v6, 1.0
	v_fma_f32 v0, -v3, v9, 1.0
	v_fmac_f32_e32 v9, v0, v9
	v_div_scale_f32 v0, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v8, v0, v9
	v_fma_f32 v10, -v3, v8, v0
	v_fmac_f32_e32 v8, v10, v9
	v_fma_f32 v0, -v3, v8, v0
	v_div_scale_f32 v3, s[0:1], v4, v4, 1.0
	v_rcp_f32_e32 v10, v3
	v_div_fmas_f32 v0, v0, v9, v8
	v_div_fixup_f32 v5, v0, v5, 1.0
	s_and_b64 s[0:1], s[2:3], s[6:7]
	v_fma_f32 v0, -v3, v10, 1.0
	v_fmac_f32_e32 v10, v0, v10
	v_div_scale_f32 v0, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v8, v0, v10
	v_fma_f32 v9, -v3, v8, v0
	v_fmac_f32_e32 v8, v9, v10
	v_fma_f32 v0, -v3, v8, v0
	v_div_fmas_f32 v0, v0, v10, v8
	v_div_fixup_f32 v4, v0, v4, 1.0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, 0xbfb8aa3b, v12
	v_fma_f32 v3, v12, s14, -v0
	v_rndne_f32_e32 v8, v0
	v_fmac_f32_e32 v3, 0xb2a5705f, v12
	v_sub_f32_e32 v0, v0, v8
	v_add_f32_e32 v0, v0, v3
	v_exp_f32_e32 v0, v0
	v_cvt_i32_f32_e32 v3, v8
	v_cndmask_b32_e64 v8, v51, 0, s[0:1]
	v_add_u32_e32 v8, v2, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:528
	v_ldexp_f32 v0, v0, v3
	v_mul_f32_e32 v3, 0xbfb8aa3b, v13
	v_fma_f32 v4, v13, s14, -v3
	v_rndne_f32_e32 v5, v3
	v_fmac_f32_e32 v4, 0xb2a5705f, v13
	v_sub_f32_e32 v3, v3, v5
	v_add_f32_e32 v3, v3, v4
	v_cvt_i32_f32_e32 v4, v5
	v_mul_f32_e32 v5, 0xbfb8aa3b, v14
	v_fma_f32 v6, v14, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v14
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_exp_f32_e32 v3, v3
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cmp_nlt_f32_e32 vcc, s16, v12
	v_ldexp_f32 v3, v3, v4
	v_ldexp_f32 v4, v5, v6
	v_mul_f32_e32 v5, 0xbfb8aa3b, v15
	v_fma_f32 v6, v15, s14, -v5
	v_rndne_f32_e32 v7, v5
	v_fmac_f32_e32 v6, 0xb2a5705f, v15
	v_sub_f32_e32 v5, v5, v7
	v_add_f32_e32 v5, v5, v6
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v12
	v_exp_f32_e32 v5, v5
	v_cvt_i32_f32_e32 v6, v7
	v_cndmask_b32_e32 v0, v1, v0, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v13
	v_ldexp_f32 v5, v5, v6
	s_nop 0
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v14
	s_nop 1
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v14
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v4, vcc
	v_cmp_nlt_f32_e32 vcc, s16, v15
	s_nop 1
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_cmp_ngt_f32_e32 vcc, s15, v15
	s_nop 1
	v_cndmask_b32_e32 v5, v1, v5, vcc
	v_pk_add_f32 v[4:5], v[4:5], 1.0 op_sel_hi:[1,0]
	v_cmp_ngt_f32_e32 vcc, s15, v13
	v_div_scale_f32 v6, s[0:1], v5, v5, 1.0
	v_rcp_f32_e32 v7, v6
	v_cndmask_b32_e32 v1, v1, v3, vcc
	v_pk_add_f32 v[0:1], v[0:1], 1.0 op_sel_hi:[1,0]
	v_fma_f32 v3, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v3, v7
	v_div_scale_f32 v3, vcc, 1.0, v5, 1.0
	v_mul_f32_e32 v8, v3, v7
	v_fma_f32 v9, -v6, v8, v3
	v_fmac_f32_e32 v8, v9, v7
	v_fma_f32 v3, -v6, v8, v3
	v_div_scale_f32 v6, s[0:1], v4, v4, 1.0
	v_rcp_f32_e32 v9, v6
	v_div_fmas_f32 v3, v3, v7, v8
	v_div_fixup_f32 v7, v3, v5, 1.0
	v_fma_f32 v3, -v6, v9, 1.0
	v_fmac_f32_e32 v9, v3, v9
	v_div_scale_f32 v3, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v5, v3, v9
	v_fma_f32 v8, -v6, v5, v3
	v_fmac_f32_e32 v5, v8, v9
	v_div_scale_f32 v8, s[0:1], v1, v1, 1.0
	v_rcp_f32_e32 v10, v8
	v_fma_f32 v3, -v6, v5, v3
	v_div_fmas_f32 v3, v3, v9, v5
	v_div_fixup_f32 v6, v3, v4, 1.0
	v_fma_f32 v3, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v3, v10
	v_div_scale_f32 v3, vcc, 1.0, v1, 1.0
	v_mul_f32_e32 v4, v3, v10
	v_fma_f32 v5, -v8, v4, v3
	v_fmac_f32_e32 v4, v5, v10
	v_fma_f32 v3, -v8, v4, v3
	v_div_scale_f32 v8, s[0:1], v0, v0, 1.0
	v_rcp_f32_e32 v9, v8
	v_div_fmas_f32 v3, v3, v10, v4
	v_div_fixup_f32 v5, v3, v1, 1.0
	s_and_b64 s[0:1], s[2:3], s[4:5]
	v_fma_f32 v1, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v1, v9
	v_div_scale_f32 v1, vcc, 1.0, v0, 1.0
	v_mul_f32_e32 v3, v1, v9
	v_fma_f32 v4, -v8, v3, v1
	v_fmac_f32_e32 v3, v4, v9
	v_fma_f32 v1, -v8, v3, v1
	v_div_fmas_f32 v1, v1, v9, v3
	v_div_fixup_f32 v4, v1, v0, 1.0
	v_cndmask_b32_e64 v0, v51, 0, s[0:1]
	v_add_u32_e32 v0, v2, v0
	buffer_store_dwordx4 v[4:7], v0, s[20:23], 0 offen offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 64
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 29
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
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

	.type	__hip_cuid_b85ab8e59abee7b0,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_b85ab8e59abee7b0
__hip_cuid_b85ab8e59abee7b0:
	.byte	0
	.size	__hip_cuid_b85ab8e59abee7b0, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_b85ab8e59abee7b0
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
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
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
