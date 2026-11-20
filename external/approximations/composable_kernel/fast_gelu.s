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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
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
	v_lshl_or_b32 v42, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v1, s22, 6, v122
	v_or_b32_e32 v150, s14, v3
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v1, s15
	v_mul_lo_u32 v152, v150, s16
	s_ashr_i32 s2, s20, 31
	v_add_u32_e32 v22, v154, v2
	v_add_u32_e32 v10, v152, v2
	v_lshl_or_b32 v43, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_lshr_b32 s2, s2, 29
	s_mul_i32 s6, s19, s15
	s_mul_i32 s7, s7, s16
	v_and_b32_e32 v26, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v50, 6, v2
	v_bitop3_b32 v51, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v44, v126, v124
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
	buffer_load_dwordx4 v[62:65], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[58:61], v58, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s16, v45
	v_lshlrev_b32_e32 v66, 2, v45
	v_add_u32_e32 v45, s16, v45
	buffer_load_dwordx4 v[74:77], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[70:73], v66, s[4:7], 0 offen
	v_lshlrev_b32_e32 v47, 2, v45
	v_add_u32_e32 v45, s16, v45
	v_lshlrev_b32_e32 v66, 2, v45
	v_add_u32_e32 v45, s16, v45
	buffer_load_dwordx4 v[78:81], v47, s[4:7], 0 offen
	buffer_load_dwordx4 v[86:89], v66, s[4:7], 0 offen
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
	ds_read_b128 v[82:85], v131 offset:8192
	ds_read_b128 v[66:69], v132 offset:4096
	ds_read_b128 v[102:105], v132 offset:8192
	ds_read_b128 v[50:53], v132 offset:12288
	ds_read_b128 v[6:9], v132 offset:16384
	ds_read_b128 v[10:13], v132 offset:20480
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
	s_movk_i32 s16, 0xffe0
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
	ds_write_b128 v136, v[62:65]
	v_add_u32_e32 v62, v144, v152
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[24:27]
	buffer_load_dwordx4 v[62:65], v62, s[4:7], 0 offen
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
	ds_write_b128 v137, v[58:61]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v32, a[16:19]
	buffer_load_dwordx4 v[58:61], v46, s[4:7], 0 offen
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
	ds_write_b128 v138, v[74:77]
	v_mfma_f32_16x16x4_f32 a[40:43], v26, v106, a[40:43]
	buffer_load_dwordx4 v[74:77], v46, s[4:7], 0 offen
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
	ds_write_b128 v139, v[70:73]
	v_mfma_f32_16x16x4_f32 a[12:15], v28, v44, a[12:15]
	buffer_load_dwordx4 v[70:73], v42, s[4:7], 0 offen
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
	ds_write_b128 v140, v[78:81]
	v_mfma_f32_16x16x4_f32 a[0:3], v26, v30, a[0:3]
	v_add_u32_e32 v26, v144, v148
	buffer_load_dwordx4 v[78:81], v26, s[4:7], 0 offen
	v_add_u32_e32 v26, v144, v147
	v_mfma_f32_16x16x4_f32 a[60:63], v18, v82, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v18, v66, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v22, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v19, v83, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v19, v67, a[56:59]
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v23, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v20, v84, a[60:63]
	s_waitcnt vmcnt(9)
	ds_write_b128 v141, v[86:89]
	v_mfma_f32_16x16x4_f32 a[0:3], v29, v33, a[0:3]
	buffer_load_dwordx4 v[86:89], v26, s[4:7], 0 offen
	v_add_u32_e32 v26, v144, v146
	v_mfma_f32_16x16x4_f32 a[56:59], v20, v68, a[56:59]
	v_mfma_f32_16x16x4_f32 a[52:55], v18, v102, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v18, v50, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v24, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v21, v85, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v21, v69, a[56:59]
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
	v_mfma_f32_16x16x4_f32 a[28:31], v18, v6, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v18, v10, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v18, v22, a[20:23]
	v_add_u32_e32 v22, v144, v145
	v_mfma_f32_16x16x4_f32 a[52:55], v21, v105, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v21, v53, a[48:51]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	s_waitcnt vmcnt(9)
	ds_write_b128 v133, v[94:97]
	v_mfma_f32_16x16x4_f32 a[28:31], v19, v7, a[28:31]
	buffer_load_dwordx4 v[94:97], v22, s[4:7], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[24:27], v19, v11, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v19, v23, a[20:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v20, v8, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v20, v12, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v21, v9, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v21, v13, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v20, v24, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v18, v14, a[16:19]
	ds_read_b128 v[46:49], v128
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v82, a[32:35]
	ds_read_b128 v[26:29], v128 offset:4096
	v_mfma_f32_16x16x4_f32 a[20:23], v21, v25, a[20:23]
	ds_read_b128 v[114:117], v129
	v_mfma_f32_16x16x4_f32 a[16:19], v19, v15, a[16:19]
	ds_read_b128 v[118:121], v129 offset:4096
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v83, a[32:35]
	ds_read_b128 v[106:109], v129 offset:8192
	v_mfma_f32_16x16x4_f32 a[16:19], v20, v16, a[16:19]
	ds_read_b128 v[110:113], v129 offset:12288
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v84, a[32:35]
	ds_read_b128 v[42:45], v129 offset:16384
	v_mfma_f32_16x16x4_f32 a[16:19], v21, v17, a[16:19]
	ds_read_b128 v[38:41], v129 offset:20480
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v85, a[32:35]
	ds_read_b128 v[34:37], v129 offset:24576
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v66, a[36:39]
	ds_read_b128 v[30:33], v129 offset:28672
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v67, a[36:39]
	ds_read_b128 v[18:21], v130
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v68, a[36:39]
	ds_read_b128 v[82:85], v131 offset:8192
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v6, a[12:15]
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v69, a[36:39]
	ds_read_b128 v[66:69], v132 offset:4096
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v102, a[40:43]
	ds_read_b128 v[22:25], v132 offset:24576
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v7, a[12:15]
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v103, a[40:43]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v8, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v10, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v9, a[12:15]
	ds_read_b128 v[6:9], v132 offset:16384
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v104, a[40:43]
	ds_read_b128 v[14:17], v132 offset:28672
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v11, a[8:11]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v105, a[40:43]
	ds_read_b128 v[102:105], v132 offset:8192
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v50, a[44:47]
	v_add_u32_e32 v2, -1, v134
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v12, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v13, a[8:11]
	ds_read_b128 v[10:13], v132 offset:20480
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
	v_add3_u32 v156, v157, v156, s16
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v53, a[44:47]
	ds_read_b128 v[2:5], v130 offset:4096
	ds_read_b128 v[50:53], v132 offset:12288
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
	s_mov_b32 s15, 0xc2aeac50
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s20, s8, s0
	s_addc_u32 s21, s9, s1
	s_mul_i32 s0, s19, s17
	s_mul_hi_u32 s1, 0, s17
	s_add_i32 s4, s1, s0
	v_mfma_f32_16x16x4_f32 a[48:51], v46, v110, a[48:51]
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
	v_mfma_f32_16x16x4_f32 a[60:63], v18, v82, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v18, v66, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v18, v50, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v2, v82, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v2, v102, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v18, v102, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v50, a[44:47]
	v_lshlrev_b32_e32 v50, 13, v125
	v_or3_b32 v50, v50, v54, v55
	v_lshl_add_u32 v54, v124, 2, v50
	v_lshlrev_b32_e32 v50, 2, v0
	v_or_b32_e32 v0, s14, v0
	v_cmp_gt_i32_e64 s[2:3], s13, v0
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v66, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v19, v83, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v19, v67, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v19, v51, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v3, v83, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v3, v103, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v19, v103, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v3, v51, a[44:47]
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v67, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v20, v84, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v20, v68, a[56:59]
	v_mfma_f32_16x16x4_f32 a[48:51], v20, v52, a[48:51]
	v_mfma_f32_16x16x4_f32 a[32:35], v4, v84, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v4, v104, a[40:43]
	v_mfma_f32_16x16x4_f32 a[52:55], v20, v104, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v4, v52, a[44:47]
	v_mov_b32_e32 v52, 0xbfcc4231
	v_mfma_f32_16x16x4_f32 a[36:39], v4, v68, a[36:39]
	v_mfma_f32_16x16x4_f32 a[60:63], v21, v85, a[60:63]
	v_mfma_f32_16x16x4_f32 a[56:59], v21, v69, a[56:59]
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
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v85, a[32:35]
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
	v_lshl_or_b32 v53, v122, 9, v50
	ds_write_b32 v54, a49 offset:896
	ds_write_b32 v54, a48 offset:384
	s_nop 6
	ds_write_b32 v54, a44 offset:16768
	ds_write_b32 v54, a45 offset:17280
	ds_write_b32 v54, a46 offset:17792
	ds_write_b32 v54, a47 offset:18304
	ds_write_b32 v54, a43 offset:18176
	v_mfma_f32_16x16x4_f32 a[36:39], v5, v69, a[36:39]
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
	s_waitcnt vmcnt(6)
	ds_read_b128 v[56:59], v53
	ds_read_b128 v[60:63], v53 offset:16
	v_mfma_f32_16x16x4_f32 a[28:31], v46, v42, a[28:31]
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v50, v56, v56
	v_fmamk_f32 v50, v50, 0xbd92220c, v52
	v_mul_f32_e32 v51, v50, v56
	v_fmaak_f32 v50, v50, v56, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v51
	v_mul_f32_e32 v65, v59, v59
	v_fmamk_f32 v65, v65, 0xbd92220c, v52
	v_cndmask_b32_e32 v50, v51, v50, vcc
	v_mul_f32_e32 v50, 0x3fb8aa3b, v50
	v_exp_f32_e32 v50, v50
	v_mul_f32_e32 v66, v65, v59
	v_fmaak_f32 v65, v65, v59, 0x42800000
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[24:27]
	v_mul_f32_e32 v51, 0x114b4ea4, v50
	v_cndmask_b32_e32 v50, v50, v51, vcc
	v_add_f32_e32 v50, 1.0, v50
	v_rcp_f32_e32 v64, v50
	v_mul_f32_e32 v50, v57, v57
	v_fmamk_f32 v50, v50, 0xbd92220c, v52
	v_mul_f32_e32 v51, v50, v57
	v_fmaak_f32 v50, v50, v57, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v51
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v34, a[20:23]
	s_nop 0
	v_cndmask_b32_e32 v50, v51, v50, vcc
	v_mul_f32_e32 v50, 0x3fb8aa3b, v50
	v_mul_f32_e32 v51, v58, v58
	v_exp_f32_e32 v50, v50
	v_fmamk_f32 v51, v51, 0xbd92220c, v52
	v_mul_f32_e32 v55, v51, v58
	v_fmaak_f32 v51, v51, v58, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v55
	v_mfma_f32_16x16x4_f32 a[16:19], v46, v30, a[16:19]
	s_nop 0
	v_cndmask_b32_e64 v51, v55, v51, s[0:1]
	v_mul_f32_e32 v51, 0x3fb8aa3b, v51
	v_mul_f32_e32 v55, 0x114b4ea4, v50
	v_exp_f32_e32 v51, v51
	v_cndmask_b32_e32 v50, v50, v55, vcc
	v_cmp_gt_f32_e32 vcc, s15, v66
	v_add_f32_e32 v50, 1.0, v50
	v_mul_f32_e32 v55, 0x114b4ea4, v51
	v_cndmask_b32_e32 v65, v66, v65, vcc
	v_mul_f32_e32 v65, 0x3fb8aa3b, v65
	v_exp_f32_e32 v65, v65
	v_cndmask_b32_e64 v51, v51, v55, s[0:1]
	v_add_f32_e32 v51, 1.0, v51
	v_rcp_f32_e32 v66, v51
	v_mul_f32_e32 v51, 0x114b4ea4, v65
	v_cndmask_b32_e32 v51, v65, v51, vcc
	v_rcp_f32_e32 v65, v50
	v_add_f32_e32 v51, 1.0, v51
	v_rcp_f32_e32 v67, v51
	v_mad_u64_u32 v[50:51], s[0:1], v1, s17, v[0:1]
	v_pk_mul_f32 v[56:57], v[64:65], v[56:57]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v65, v60, v60
	v_cmp_gt_i32_e32 vcc, s12, v1
	s_add_i32 s0, s13, s4
	v_fmamk_f32 v65, v65, 0xbd92220c, v52
	v_pk_mul_f32 v[58:59], v[66:67], v[58:59]
	s_lshl_b32 s22, s0, 2
	v_bfrev_b32_e32 v51, 1
	s_and_b64 s[0:1], vcc, s[2:3]
	v_mul_f32_e32 v66, v65, v60
	v_cndmask_b32_e64 v64, v51, 0, s[0:1]
	v_fmaak_f32 v65, v65, v60, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v66
	v_lshlrev_b32_e32 v55, 2, v50
	v_add_u32_e32 v64, v64, v55
	v_cndmask_b32_e64 v65, v66, v65, s[0:1]
	v_mul_f32_e32 v65, 0x3fb8aa3b, v65
	v_exp_f32_e32 v65, v65
	buffer_store_dwordx4 v[56:59], v64, s[20:23], 0 offen
	v_mfma_f32_16x16x4_f32 a[28:31], v47, v43, a[28:31]
	v_or_b32_e32 v66, 4, v0
	v_mul_f32_e32 v57, v61, v61
	v_fmamk_f32 v57, v57, 0xbd92220c, v52
	v_mul_f32_e32 v56, 0x114b4ea4, v65
	v_mul_f32_e32 v58, v57, v61
	v_cndmask_b32_e64 v56, v65, v56, s[0:1]
	v_fmaak_f32 v57, v57, v61, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v58
	v_mul_f32_e32 v65, v63, v63
	v_fmamk_f32 v65, v65, 0xbd92220c, v52
	v_cndmask_b32_e64 v57, v58, v57, s[0:1]
	v_mul_f32_e32 v58, v62, v62
	v_fmamk_f32 v58, v58, 0xbd92220c, v52
	v_mul_f32_e32 v59, v58, v62
	v_fmaak_f32 v58, v58, v62, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v59
	v_mul_f32_e32 v67, v65, v63
	v_fmaak_f32 v65, v65, v63, 0x42800000
	v_cndmask_b32_e64 v58, v59, v58, s[4:5]
	v_cmp_gt_f32_e64 s[6:7], s15, v67
	v_mul_f32_e32 v58, 0x3fb8aa3b, v58
	v_exp_f32_e32 v58, v58
	v_cndmask_b32_e64 v65, v67, v65, s[6:7]
	v_mul_f32_e32 v65, 0x3fb8aa3b, v65
	v_exp_f32_e32 v65, v65
	v_mul_f32_e32 v59, 0x114b4ea4, v58
	v_mul_f32_e32 v57, 0x3fb8aa3b, v57
	v_cndmask_b32_e64 v58, v58, v59, s[4:5]
	v_mul_f32_e32 v59, 0x114b4ea4, v65
	v_exp_f32_e32 v57, v57
	v_cndmask_b32_e64 v59, v65, v59, s[6:7]
	v_add_f32_e32 v58, 1.0, v58
	v_add_f32_e32 v59, 1.0, v59
	v_rcp_f32_e32 v58, v58
	v_rcp_f32_e32 v59, v59
	v_mul_f32_e32 v64, 0x114b4ea4, v57
	v_cndmask_b32_e64 v57, v57, v64, s[0:1]
	v_add_f32_e32 v56, 1.0, v56
	v_add_f32_e32 v57, 1.0, v57
	v_pk_mul_f32 v[58:59], v[58:59], v[62:63]
	ds_read_b128 v[62:65], v53 offset:32
	v_rcp_f32_e32 v56, v56
	v_rcp_f32_e32 v57, v57
	v_mfma_f32_16x16x4_f32 a[24:27], v47, v39, a[24:27]
	v_cmp_gt_i32_e64 s[4:5], s13, v66
	s_and_b64 s[6:7], vcc, s[4:5]
	v_pk_mul_f32 v[56:57], v[56:57], v[60:61]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v60, v62, v62
	v_fmamk_f32 v60, v60, 0xbd92220c, v52
	v_mul_f32_e32 v61, v60, v62
	v_fmaak_f32 v60, v60, v62, 0x42800000
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v35, a[20:23]
	v_cmp_gt_f32_e64 s[0:1], s15, v61
	ds_read_b128 v[66:69], v53 offset:48
	v_or_b32_e32 v1, 1, v1
	v_cndmask_b32_e64 v60, v61, v60, s[0:1]
	v_mul_f32_e32 v60, 0x3fb8aa3b, v60
	v_exp_f32_e32 v60, v60
	v_cndmask_b32_e64 v61, v51, 0, s[6:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v31, a[16:19]
	v_add_u32_e32 v61, v55, v61
	s_waitcnt vmcnt(5)
	v_mul_f32_e32 v70, 0x114b4ea4, v60
	v_cndmask_b32_e64 v46, v60, v70, s[0:1]
	v_mul_f32_e32 v60, v63, v63
	v_fmamk_f32 v60, v60, 0xbd92220c, v52
	v_mul_f32_e32 v70, v60, v63
	v_fmaak_f32 v60, v60, v63, 0x42800000
	v_mfma_f32_16x16x4_f32 a[28:31], v48, v44, a[28:31]
	v_cmp_gt_f32_e64 s[0:1], s15, v70
	v_add_f32_e32 v46, 1.0, v46
	v_rcp_f32_e32 v46, v46
	v_cndmask_b32_e64 v47, v70, v60, s[0:1]
	v_mul_f32_e32 v47, 0x3fb8aa3b, v47
	v_exp_f32_e32 v47, v47
	v_mul_f32_e32 v60, v64, v64
	v_mfma_f32_16x16x4_f32 a[24:27], v48, v40, a[24:27]
	v_fmamk_f32 v60, v60, 0xbd92220c, v52
	v_mul_f32_e32 v70, v60, v64
	v_fmaak_f32 v60, v60, v64, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v70
	buffer_store_dwordx4 v[56:59], v61, s[20:23], 0 offen offset:16
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v36, a[20:23]
	s_nop 0
	v_or_b32_e32 v56, 8, v0
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v32, a[16:19]
	v_cndmask_b32_e64 v48, v70, v60, s[6:7]
	v_mul_f32_e32 v60, 0x114b4ea4, v47
	v_cndmask_b32_e64 v47, v47, v60, s[0:1]
	v_mul_f32_e32 v48, 0x3fb8aa3b, v48
	v_exp_f32_e32 v48, v48
	v_add_f32_e32 v47, 1.0, v47
	v_rcp_f32_e32 v47, v47
	v_mfma_f32_16x16x4_f32 a[28:31], v49, v45, a[28:31]
	v_mul_f32_e32 v60, 0x114b4ea4, v48
	v_pk_mul_f32 v[46:47], v[46:47], v[62:63]
	v_mfma_f32_16x16x4_f32 a[24:27], v49, v41, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v49, v37, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v33, a[16:19]
	v_mul_f32_e32 v49, v65, v65
	v_fmamk_f32 v49, v49, 0xbd92220c, v52
	v_mul_f32_e32 v70, v49, v65
	v_fmaak_f32 v49, v49, v65, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v70
	s_nop 1
	v_cndmask_b32_e64 v49, v70, v49, s[0:1]
	v_mul_f32_e32 v49, 0x3fb8aa3b, v49
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v42, a[12:15]
	v_exp_f32_e32 v49, v49
	v_cndmask_b32_e64 v42, v48, v60, s[6:7]
	v_add_f32_e32 v42, 1.0, v42
	v_rcp_f32_e32 v42, v42
	v_mul_f32_e32 v48, 0x114b4ea4, v49
	v_cndmask_b32_e64 v48, v49, v48, s[0:1]
	v_add_f32_e32 v48, 1.0, v48
	v_mfma_f32_16x16x4_f32 a[12:15], v27, v43, a[12:15]
	v_rcp_f32_e32 v43, v48
	v_cmp_gt_i32_e64 s[6:7], s13, v56
	s_and_b64 s[0:1], vcc, s[6:7]
	v_add_u32_e32 v56, 12, v50
	v_pk_mul_f32 v[48:49], v[42:43], v[64:65]
	v_cndmask_b32_e64 v42, v51, 0, s[0:1]
	v_add_u32_e32 v42, v55, v42
	buffer_store_dwordx4 v[46:49], v42, s[20:23], 0 offen offset:32
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v42, v66, v66
	v_fmamk_f32 v42, v42, 0xbd92220c, v52
	v_mul_f32_e32 v43, v42, v66
	v_mfma_f32_16x16x4_f32 a[8:11], v26, v38, a[8:11]
	v_fmaak_f32 v42, v42, v66, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v43
	v_or_b32_e32 v46, 12, v0
	s_nop 0
	v_cndmask_b32_e64 v42, v43, v42, s[0:1]
	v_mul_f32_e32 v42, 0x3fb8aa3b, v42
	v_exp_f32_e32 v42, v42
	v_mfma_f32_16x16x4_f32 a[8:11], v27, v39, a[8:11]
	v_mul_f32_e32 v38, 0x114b4ea4, v42
	v_cndmask_b32_e64 v38, v42, v38, s[0:1]
	v_mul_f32_e32 v42, v67, v67
	v_fmamk_f32 v42, v42, 0xbd92220c, v52
	v_mul_f32_e32 v43, v42, v67
	v_fmaak_f32 v42, v42, v67, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v43
	v_mfma_f32_16x16x4_f32 a[8:11], v28, v40, a[8:11]
	v_add_f32_e32 v38, 1.0, v38
	v_cndmask_b32_e64 v39, v43, v42, s[0:1]
	v_mul_f32_e32 v42, v68, v68
	v_fmamk_f32 v42, v42, 0xbd92220c, v52
	v_mul_f32_e32 v43, v42, v68
	v_fmaak_f32 v40, v42, v68, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v43
	v_mfma_f32_16x16x4_f32 a[12:15], v28, v44, a[12:15]
	v_mul_f32_e32 v39, 0x3fb8aa3b, v39
	v_cndmask_b32_e64 v40, v43, v40, s[8:9]
	v_mul_f32_e32 v43, v69, v69
	v_fmamk_f32 v43, v43, 0xbd92220c, v52
	v_mul_f32_e32 v44, v43, v69
	v_fmaak_f32 v43, v43, v69, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v44
	v_mul_f32_e32 v40, 0x3fb8aa3b, v40
	v_mfma_f32_16x16x4_f32 a[4:7], v26, v34, a[4:7]
	v_cndmask_b32_e64 v43, v44, v43, s[10:11]
	v_exp_f32_e32 v40, v40
	v_mul_f32_e32 v34, 0x3fb8aa3b, v43
	v_exp_f32_e32 v43, v34
	v_exp_f32_e32 v39, v39
	v_rcp_f32_e32 v38, v38
	v_mul_f32_e32 v42, 0x114b4ea4, v39
	v_mfma_f32_16x16x4_f32 a[8:11], v29, v41, a[8:11]
	v_mul_f32_e32 v41, 0x114b4ea4, v40
	v_cndmask_b32_e64 v34, v40, v41, s[8:9]
	v_mul_f32_e32 v40, 0x114b4ea4, v43
	v_cndmask_b32_e64 v40, v43, v40, s[10:11]
	v_add_f32_e32 v34, 1.0, v34
	v_cndmask_b32_e64 v39, v39, v42, s[0:1]
	v_rcp_f32_e32 v34, v34
	v_mfma_f32_16x16x4_f32 a[0:3], v26, v30, a[0:3]
	v_cmp_gt_i32_e64 s[8:9], s13, v46
	s_and_b64 s[10:11], vcc, s[8:9]
	ds_read_b128 v[46:49], v53 offset:544
	v_add_f32_e32 v39, 1.0, v39
	v_rcp_f32_e32 v39, v39
	s_nop 0
	v_pk_mul_f32 v[38:39], v[38:39], v[66:67]
	v_mfma_f32_16x16x4_f32 a[12:15], v29, v45, a[12:15]
	ds_read_b128 v[42:45], v53 offset:560
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v30, v43, v43
	v_fmamk_f32 v30, v30, 0xbd92220c, v52
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v35, a[4:7]
	v_add_f32_e32 v35, 1.0, v40
	v_rcp_f32_e32 v35, v35
	s_nop 0
	v_pk_mul_f32 v[40:41], v[34:35], v[68:69]
	v_mul_f32_e32 v34, v42, v42
	v_fmamk_f32 v34, v34, 0xbd92220c, v52
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v31, a[0:3]
	v_mul_f32_e32 v35, v34, v42
	v_fmaak_f32 v34, v34, v42, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v35
	s_nop 1
	v_cndmask_b32_e64 v34, v35, v34, s[0:1]
	v_mul_f32_e32 v34, 0x3fb8aa3b, v34
	v_exp_f32_e32 v34, v34
	v_mfma_f32_16x16x4_f32 a[4:7], v28, v36, a[4:7]
	v_cndmask_b32_e64 v35, v51, 0, s[10:11]
	v_lshl_add_u32 v35, v56, 2, v35
	v_mul_f32_e32 v36, 0x114b4ea4, v34
	v_cndmask_b32_e64 v26, v34, v36, s[0:1]
	v_mul_f32_e32 v34, v30, v43
	v_fmaak_f32 v30, v30, v43, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v34
	v_mfma_f32_16x16x4_f32 a[0:3], v28, v32, a[0:3]
	v_mul_f32_e32 v32, v47, v47
	v_cndmask_b32_e64 v27, v34, v30, s[0:1]
	v_mul_f32_e32 v27, 0x3fb8aa3b, v27
	v_exp_f32_e32 v27, v27
	v_mul_f32_e32 v30, v44, v44
	v_fmamk_f32 v30, v30, 0xbd92220c, v52
	v_mul_f32_e32 v31, v30, v44
	v_mfma_f32_16x16x4_f32 a[4:7], v29, v37, a[4:7]
	v_fmaak_f32 v30, v30, v44, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v31
	v_fmamk_f32 v32, v32, 0xbd92220c, v52
	v_add_f32_e32 v26, 1.0, v26
	v_cndmask_b32_e64 v28, v31, v30, s[10:11]
	v_mul_f32_e32 v30, 0x114b4ea4, v27
	v_cndmask_b32_e64 v27, v27, v30, s[0:1]
	v_mfma_f32_16x16x4_f32 a[0:3], v29, v33, a[0:3]
	v_mul_f32_e32 v29, v45, v45
	v_fmamk_f32 v29, v29, 0xbd92220c, v52
	v_mul_f32_e32 v31, v29, v45
	v_fmaak_f32 v29, v29, v45, 0x42800000
	v_cmp_gt_f32_e64 s[0:1], s15, v31
	v_mul_f32_e32 v28, 0x3fb8aa3b, v28
	v_exp_f32_e32 v28, v28
	v_cndmask_b32_e64 v29, v31, v29, s[0:1]
	v_mul_f32_e32 v29, 0x3fb8aa3b, v29
	v_exp_f32_e32 v29, v29
	v_mul_f32_e32 v30, 0x114b4ea4, v28
	v_cndmask_b32_e64 v28, v28, v30, s[10:11]
	v_mul_f32_e32 v33, v32, v47
	v_mul_f32_e32 v30, 0x114b4ea4, v29
	v_cndmask_b32_e64 v29, v29, v30, s[0:1]
	v_mul_f32_e32 v30, v46, v46
	v_fmamk_f32 v30, v30, 0xbd92220c, v52
	v_mul_f32_e32 v31, v30, v46
	v_fmaak_f32 v30, v30, v46, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v31
	v_cmp_gt_i32_e64 s[0:1], s12, v1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v30, v31, v30, s[10:11]
	v_mul_f32_e32 v30, 0x3fb8aa3b, v30
	v_exp_f32_e32 v30, v30
	v_cndmask_b32_e64 v31, v51, 0, s[8:9]
	v_fmaak_f32 v32, v32, v47, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v33
	v_add_f32_e32 v27, 1.0, v27
	v_add_f32_e32 v28, 1.0, v28
	v_cndmask_b32_e64 v32, v33, v32, s[8:9]
	v_mul_f32_e32 v33, v48, v48
	v_add_f32_e32 v29, 1.0, v29
	v_add_lshl_u32 v1, v56, s17, 2
	v_mul_f32_e32 v32, 0x3fb8aa3b, v32
	v_fmamk_f32 v33, v33, 0xbd92220c, v52
	v_rcp_f32_e32 v26, v26
	v_rcp_f32_e32 v28, v28
	v_rcp_f32_e32 v29, v29
	v_rcp_f32_e32 v27, v27
	buffer_store_dwordx4 v[38:41], v35, s[20:23], 0 offen
	v_add_u32_e32 v34, v1, v31
	v_mul_f32_e32 v31, 0x114b4ea4, v30
	v_exp_f32_e32 v32, v32
	v_mul_f32_e32 v35, v33, v48
	v_cndmask_b32_e64 v30, v30, v31, s[10:11]
	v_fmaak_f32 v33, v33, v48, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v35
	v_pk_mul_f32 v[28:29], v[28:29], v[44:45]
	v_pk_mul_f32 v[26:27], v[26:27], v[42:43]
	v_cndmask_b32_e64 v33, v35, v33, s[10:11]
	v_mul_f32_e32 v35, v49, v49
	v_fmamk_f32 v35, v35, 0xbd92220c, v52
	v_mul_f32_e32 v31, 0x114b4ea4, v32
	v_mul_f32_e32 v36, v35, v49
	v_cndmask_b32_e64 v31, v32, v31, s[8:9]
	v_fmaak_f32 v35, v35, v49, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v36
	buffer_store_dwordx4 v[26:29], v34, s[20:23], 0 offen
	ds_read_b128 v[26:29], v53 offset:528
	v_mul_f32_e32 v33, 0x3fb8aa3b, v33
	v_cndmask_b32_e64 v35, v36, v35, s[8:9]
	v_mfma_f32_16x16x4_f32 a[28:31], v18, v6, a[28:31]
	v_exp_f32_e32 v33, v33
	v_mul_f32_e32 v35, 0x3fb8aa3b, v35
	v_exp_f32_e32 v35, v35
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v38, v26, v26
	v_mul_f32_e32 v32, 0x114b4ea4, v33
	v_fmamk_f32 v38, v38, 0xbd92220c, v52
	v_cndmask_b32_e64 v32, v33, v32, s[10:11]
	v_mfma_f32_16x16x4_f32 a[24:27], v18, v10, a[24:27]
	v_mul_f32_e32 v33, 0x114b4ea4, v35
	v_mul_f32_e32 v39, v38, v26
	v_cndmask_b32_e64 v33, v35, v33, s[8:9]
	v_fmaak_f32 v38, v38, v26, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v39
	v_mul_f32_e32 v41, v27, v27
	s_and_b64 s[6:7], s[0:1], s[6:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v18, v22, a[20:23]
	v_cndmask_b32_e64 v38, v39, v38, s[8:9]
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v38
	v_mov_b32_e32 v39, 0x7ffffff0
	v_cndmask_b32_e64 v39, v39, -16, s[6:7]
	v_add_f32_e32 v30, 1.0, v30
	v_mul_f32_e32 v40, 0x114b4ea4, v38
	v_mfma_f32_16x16x4_f32 a[16:19], v18, v14, a[16:19]
	v_fmamk_f32 v18, v41, 0xbd92220c, v52
	v_mul_f32_e32 v41, v18, v27
	v_fmaak_f32 v18, v18, v27, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v41
	v_add_f32_e32 v31, 1.0, v31
	v_add_f32_e32 v32, 1.0, v32
	v_cndmask_b32_e64 v18, v41, v18, s[6:7]
	v_mfma_f32_16x16x4_f32 a[28:31], v19, v7, a[28:31]
	v_mul_f32_e32 v18, 0x3fb8aa3b, v18
	v_exp_f32_e32 v41, v18
	v_cndmask_b32_e64 v18, v38, v40, s[8:9]
	v_mul_f32_e32 v38, v28, v28
	v_fmamk_f32 v38, v38, 0xbd92220c, v52
	v_mul_f32_e32 v40, v38, v28
	v_cmp_gt_f32_e64 s[8:9], s15, v40
	v_mfma_f32_16x16x4_f32 a[24:27], v19, v11, a[24:27]
	v_add_f32_e32 v33, 1.0, v33
	v_rcp_f32_e32 v30, v30
	v_rcp_f32_e32 v32, v32
	v_rcp_f32_e32 v33, v33
	v_rcp_f32_e32 v31, v31
	ds_read_b128 v[34:37], v53 offset:512
	s_and_b64 s[4:5], s[0:1], s[4:5]
	v_mfma_f32_16x16x4_f32 a[20:23], v19, v23, a[20:23]
	v_pk_mul_f32 v[32:33], v[32:33], v[48:49]
	v_pk_mul_f32 v[30:31], v[30:31], v[46:47]
	v_add_f32_e32 v18, 1.0, v18
	v_rcp_f32_e32 v18, v18
	s_and_b64 s[2:3], s[2:3], s[0:1]
	v_mfma_f32_16x16x4_f32 a[16:19], v19, v15, a[16:19]
	v_mul_f32_e32 v19, 0x114b4ea4, v41
	v_cndmask_b32_e64 v19, v41, v19, s[6:7]
	v_add_f32_e32 v19, 1.0, v19
	v_rcp_f32_e32 v19, v19
	s_nop 0
	v_pk_mul_f32 v[18:19], v[18:19], v[26:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v20, v8, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v20, v12, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v20, v24, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v20, v16, a[16:19]
	v_fmaak_f32 v20, v38, v28, 0x42800000
	v_mul_f32_e32 v38, v29, v29
	v_fmamk_f32 v38, v38, 0xbd92220c, v52
	v_cndmask_b32_e64 v20, v40, v20, s[8:9]
	v_mul_f32_e32 v40, v38, v29
	v_fmaak_f32 v38, v38, v29, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v40
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v6, a[12:15]
	v_mul_f32_e32 v20, 0x3fb8aa3b, v20
	v_cndmask_b32_e64 v38, v40, v38, s[6:7]
	v_exp_f32_e32 v20, v20
	v_mul_f32_e32 v6, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v6
	v_mfma_f32_16x16x4_f32 a[28:31], v21, v9, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v21, v13, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v21, v25, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v21, v17, a[16:19]
	v_mul_f32_e32 v21, 0x114b4ea4, v20
	v_cndmask_b32_e64 v6, v20, v21, s[8:9]
	v_mul_f32_e32 v20, 0x114b4ea4, v38
	v_cndmask_b32_e64 v20, v38, v20, s[6:7]
	v_add_f32_e32 v6, 1.0, v6
	v_rcp_f32_e32 v6, v6
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v7, a[12:15]
	v_add_f32_e32 v7, 1.0, v20
	v_rcp_f32_e32 v7, v7
	v_add_u32_e32 v20, v1, v39
	buffer_store_dwordx4 v[30:33], v20, s[20:23], 0 offen
	v_pk_mul_f32 v[20:21], v[6:7], v[28:29]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v7, v34, v34
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v10, a[8:11]
	v_fmamk_f32 v7, v7, 0xbd92220c, v52
	v_mul_f32_e32 v10, v35, v35
	v_fmamk_f32 v10, v10, 0xbd92220c, v52
	v_mov_b32_e32 v6, 0x7fffffe0
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v14, a[0:3]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v8, a[12:15]
	v_mul_f32_e32 v8, v7, v34
	v_fmaak_f32 v7, v7, v34, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v8
	s_nop 1
	v_cndmask_b32_e64 v7, v8, v7, s[6:7]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v11, a[8:11]
	v_exp_f32_e32 v7, v7
	v_not_b32_e32 v8, 31
	v_mul_f32_e32 v11, v10, v35
	v_cndmask_b32_e64 v8, v6, v8, s[4:5]
	v_fmaak_f32 v10, v10, v35, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v11
	v_mul_f32_e32 v6, 0x114b4ea4, v7
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v22, a[4:7]
	v_cndmask_b32_e64 v10, v11, v10, s[4:5]
	v_mul_f32_e32 v11, v36, v36
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_fmamk_f32 v11, v11, 0xbd92220c, v52
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v6, v7, v6, s[6:7]
	v_add_f32_e32 v6, 1.0, v6
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v15, a[0:3]
	v_mul_f32_e32 v7, 0x114b4ea4, v10
	v_cndmask_b32_e64 v7, v10, v7, s[4:5]
	v_add_f32_e32 v7, 1.0, v7
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v7
	v_add_u32_e32 v1, v1, v8
	buffer_store_dwordx4 v[18:21], v1, s[20:23], 0 offen
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v12, a[8:11]
	v_mul_f32_e32 v12, v11, v36
	v_fmaak_f32 v11, v11, v36, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v12
	v_add_lshl_u32 v1, v50, s17, 2
	v_cndmask_b32_e64 v2, v51, 0, s[2:3]
	v_cndmask_b32_e64 v11, v12, v11, s[6:7]
	v_mul_f32_e32 v12, v37, v37
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v23, a[4:7]
	v_fmamk_f32 v12, v12, 0xbd92220c, v52
	v_mul_f32_e32 v22, v12, v37
	v_fmaak_f32 v12, v12, v37, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v22
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	v_cndmask_b32_e64 v12, v22, v12, s[4:5]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v16, a[0:3]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_mul_f32_e32 v10, 0x114b4ea4, v11
	v_cndmask_b32_e64 v10, v11, v10, s[6:7]
	v_add_f32_e32 v10, 1.0, v10
	v_mul_f32_e32 v11, 0x114b4ea4, v12
	v_cndmask_b32_e64 v11, v12, v11, s[4:5]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v24, a[4:7]
	v_add_f32_e32 v11, 1.0, v11
	v_rcp_f32_e32 v10, v10
	v_rcp_f32_e32 v11, v11
	v_pk_mul_f32 v[18:19], v[6:7], v[34:35]
	v_add_u32_e32 v2, v2, v1
	v_pk_mul_f32 v[20:21], v[10:11], v[36:37]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[0:3]
	buffer_store_dwordx4 v[18:21], v2, s[20:23], 0 offen
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
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v25, a[4:7]
	ds_write_b32 v54, a17 offset:896
	ds_write_b32 v54, a16 offset:384
	ds_write_b32 v54, a0 offset:16768
	ds_write_b32 v54, a1 offset:17280
	ds_write_b32 v54, a2 offset:17792
	ds_write_b32 v54, a3 offset:18304
	s_nop 3
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
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v9, a[12:15]
	s_nop 7
	s_nop 1
	ds_write_b32 v54, a3 offset:17920
	ds_write_b32 v54, a2 offset:17408
	ds_write_b32 v54, a1 offset:16896
	ds_write_b32 v54, a0 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[4:7], v53
	ds_read_b128 v[8:11], v53 offset:16
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v2, v4, v4
	v_fmamk_f32 v2, v2, 0xbd92220c, v52
	v_mul_f32_e32 v3, v2, v4
	v_fmaak_f32 v2, v2, v4, 0x42800000
	v_cmp_gt_f32_e64 s[2:3], s15, v3
	v_mul_f32_e32 v14, v7, v7
	v_fmamk_f32 v14, v14, 0xbd92220c, v52
	v_cndmask_b32_e64 v2, v3, v2, s[2:3]
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_exp_f32_e32 v2, v2
	v_mul_f32_e32 v15, v14, v7
	v_fmaak_f32 v14, v14, v7, 0x42800000
	v_mul_f32_e32 v3, 0x114b4ea4, v2
	v_cndmask_b32_e64 v2, v2, v3, s[2:3]
	v_add_f32_e32 v2, 1.0, v2
	v_rcp_f32_e32 v12, v2
	v_mul_f32_e32 v2, v5, v5
	v_fmamk_f32 v2, v2, 0xbd92220c, v52
	v_mul_f32_e32 v3, v2, v5
	v_fmaak_f32 v2, v2, v5, 0x42800000
	v_cmp_gt_f32_e64 s[2:3], s15, v3
	s_nop 1
	v_cndmask_b32_e64 v2, v3, v2, s[2:3]
	v_mul_f32_e32 v3, v6, v6
	v_fmamk_f32 v3, v3, 0xbd92220c, v52
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_mul_f32_e32 v13, v3, v6
	v_exp_f32_e32 v2, v2
	v_fmaak_f32 v3, v3, v6, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v13
	s_nop 1
	v_cndmask_b32_e64 v3, v13, v3, s[4:5]
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_mul_f32_e32 v13, 0x114b4ea4, v2
	v_cndmask_b32_e64 v2, v2, v13, s[2:3]
	v_cmp_gt_f32_e64 s[2:3], s15, v15
	v_add_f32_e32 v2, 1.0, v2
	v_mul_f32_e32 v13, 0x114b4ea4, v3
	v_cndmask_b32_e64 v14, v15, v14, s[2:3]
	v_mul_f32_e32 v14, 0x3fb8aa3b, v14
	v_exp_f32_e32 v15, v14
	v_cndmask_b32_e64 v3, v3, v13, s[4:5]
	v_rcp_f32_e32 v13, v2
	v_add_f32_e32 v3, 1.0, v3
	v_rcp_f32_e32 v14, v3
	v_mul_f32_e32 v3, 0x114b4ea4, v15
	v_pk_mul_f32 v[4:5], v[12:13], v[4:5]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v12, v8, v8
	v_cndmask_b32_e64 v3, v15, v3, s[2:3]
	v_fmamk_f32 v12, v12, 0xbd92220c, v52
	v_add_f32_e32 v3, 1.0, v3
	v_mul_f32_e32 v13, v12, v8
	v_rcp_f32_e32 v15, v3
	v_or_b32_e32 v3, 0x80, v0
	v_fmaak_f32 v12, v12, v8, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v13
	v_cmp_gt_i32_e64 s[2:3], s13, v3
	s_and_b64 s[6:7], vcc, s[2:3]
	v_cndmask_b32_e64 v12, v13, v12, s[4:5]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_add_u32_e32 v3, 0x200, v55
	v_exp_f32_e32 v12, v12
	v_cndmask_b32_e64 v13, v51, 0, s[6:7]
	v_pk_mul_f32 v[6:7], v[14:15], v[6:7]
	v_add_u32_e32 v13, v3, v13
	buffer_store_dwordx4 v[4:7], v13, s[20:23], 0 offen
	v_or_b32_e32 v14, 0x84, v0
	v_mov_b32_e32 v2, 0x42800000
	v_mul_f32_e32 v5, v9, v9
	v_fmamk_f32 v5, v5, 0xbd92220c, v52
	v_mul_f32_e32 v4, 0x114b4ea4, v12
	v_mul_f32_e32 v6, v5, v9
	v_cndmask_b32_e64 v4, v12, v4, s[4:5]
	v_fmaak_f32 v5, v5, v9, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v6
	v_mul_f32_e32 v12, v11, v11
	v_fmamk_f32 v12, v12, 0xbd92220c, v52
	v_cndmask_b32_e64 v5, v6, v5, s[4:5]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	v_mul_f32_e32 v6, v10, v10
	v_fmamk_f32 v6, v6, 0xbd92220c, v52
	v_mul_f32_e32 v7, v6, v10
	v_fmaak_f32 v6, v6, v10, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v7
	v_mul_f32_e32 v13, v12, v11
	v_fmaak_f32 v12, v12, v11, 0x42800000
	v_cndmask_b32_e64 v6, v7, v6, s[6:7]
	v_mul_f32_e32 v7, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v7, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], s15, v13
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v12, v13, v12, s[4:5]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[6:7]
	v_add_f32_e32 v6, 1.0, v6
	v_mul_f32_e32 v7, 0x114b4ea4, v12
	v_cndmask_b32_e64 v7, v12, v7, s[4:5]
	v_add_f32_e32 v7, 1.0, v7
	v_rcp_f32_e32 v6, v6
	v_rcp_f32_e32 v7, v7
	v_add_f32_e32 v4, 1.0, v4
	v_add_f32_e32 v5, 1.0, v5
	v_rcp_f32_e32 v4, v4
	v_pk_mul_f32 v[6:7], v[6:7], v[10:11]
	ds_read_b128 v[10:13], v53 offset:32
	v_rcp_f32_e32 v5, v5
	v_cmp_gt_i32_e64 s[4:5], s13, v14
	s_and_b64 s[8:9], vcc, s[4:5]
	ds_read_b128 v[14:17], v53 offset:48
	v_pk_mul_f32 v[4:5], v[4:5], v[8:9]
	s_waitcnt lgkmcnt(1)
	v_mul_f32_e32 v9, v10, v10
	v_fmamk_f32 v9, v9, 0xbd92220c, v52
	v_mul_f32_e32 v18, v9, v10
	v_fmaak_f32 v9, v9, v10, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v18
	v_mov_b32_e32 v8, 0x80000010
	v_cndmask_b32_e64 v8, v8, 16, s[8:9]
	v_cndmask_b32_e64 v9, v18, v9, s[6:7]
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	v_add_u32_e32 v20, v3, v8
	v_mul_f32_e32 v21, v13, v13
	v_fmamk_f32 v21, v21, 0xbd92220c, v52
	v_mul_f32_e32 v8, 0x114b4ea4, v9
	v_cndmask_b32_e64 v8, v9, v8, s[6:7]
	v_mul_f32_e32 v9, v11, v11
	v_fmamk_f32 v9, v9, 0xbd92220c, v52
	v_mul_f32_e32 v18, v9, v11
	v_fmaak_f32 v9, v9, v11, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v18
	v_mul_f32_e32 v22, v21, v13
	v_add_f32_e32 v8, 1.0, v8
	v_cndmask_b32_e64 v9, v18, v9, s[6:7]
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	v_mul_f32_e32 v18, v12, v12
	v_fmamk_f32 v18, v18, 0xbd92220c, v52
	v_mul_f32_e32 v19, v18, v12
	v_fmaak_f32 v18, v18, v12, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v19
	v_fmaak_f32 v21, v21, v13, 0x42800000
	v_rcp_f32_e32 v8, v8
	v_cndmask_b32_e64 v18, v19, v18, s[8:9]
	v_mul_f32_e32 v19, 0x114b4ea4, v9
	v_cndmask_b32_e64 v9, v9, v19, s[6:7]
	v_add_f32_e32 v9, 1.0, v9
	v_cmp_gt_f32_e64 s[6:7], s15, v22
	v_mul_f32_e32 v18, 0x3fb8aa3b, v18
	v_rcp_f32_e32 v9, v9
	v_cndmask_b32_e64 v21, v22, v21, s[6:7]
	v_exp_f32_e32 v18, v18
	v_mul_f32_e32 v21, 0x3fb8aa3b, v21
	v_exp_f32_e32 v21, v21
	buffer_store_dwordx4 v[4:7], v20, s[20:23], 0 offen
	v_mul_f32_e32 v19, 0x114b4ea4, v18
	v_cndmask_b32_e64 v18, v18, v19, s[8:9]
	v_pk_mul_f32 v[4:5], v[8:9], v[10:11]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v9, v14, v14
	v_fmamk_f32 v9, v9, 0xbd92220c, v52
	v_mul_f32_e32 v19, 0x114b4ea4, v21
	v_mul_f32_e32 v10, v9, v14
	v_cndmask_b32_e64 v19, v21, v19, s[6:7]
	v_fmaak_f32 v9, v9, v14, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v10
	v_add_f32_e32 v18, 1.0, v18
	v_add_f32_e32 v19, 1.0, v19
	v_cndmask_b32_e64 v9, v10, v9, s[8:9]
	v_rcp_f32_e32 v18, v18
	v_rcp_f32_e32 v19, v19
	v_or_b32_e32 v20, 0x88, v0
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_cmp_gt_i32_e64 s[6:7], s13, v20
	v_exp_f32_e32 v9, v9
	v_mov_b32_e32 v8, 0x80000020
	s_and_b64 s[10:11], vcc, s[6:7]
	v_cndmask_b32_e64 v8, v8, 32, s[10:11]
	v_pk_mul_f32 v[6:7], v[18:19], v[12:13]
	v_add_u32_e32 v8, v3, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	v_or_b32_e32 v0, 0x8c, v0
	s_and_b64 s[6:7], s[0:1], s[6:7]
	v_mul_f32_e32 v4, 0x114b4ea4, v9
	v_cndmask_b32_e64 v4, v9, v4, s[8:9]
	v_add_f32_e32 v4, 1.0, v4
	v_rcp_f32_e32 v8, v4
	v_mul_f32_e32 v4, v15, v15
	v_fmamk_f32 v4, v4, 0xbd92220c, v52
	v_mul_f32_e32 v5, v4, v15
	v_fmaak_f32 v4, v4, v15, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v5
	v_mul_f32_e32 v7, v17, v17
	v_fmamk_f32 v7, v7, 0xbd92220c, v52
	v_cndmask_b32_e64 v4, v5, v4, s[8:9]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_mul_f32_e32 v5, v16, v16
	v_exp_f32_e32 v4, v4
	v_fmamk_f32 v5, v5, 0xbd92220c, v52
	v_mul_f32_e32 v6, v5, v16
	v_fmaak_f32 v5, v5, v16, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v6
	v_mul_f32_e32 v9, v7, v17
	v_fmaak_f32 v7, v7, v17, 0x42800000
	v_cndmask_b32_e64 v5, v6, v5, s[10:11]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_mul_f32_e32 v6, 0x114b4ea4, v4
	v_exp_f32_e32 v5, v5
	v_cndmask_b32_e64 v4, v4, v6, s[8:9]
	v_cmp_gt_f32_e64 s[8:9], s15, v9
	v_add_f32_e32 v4, 1.0, v4
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v7, v9, v7, s[8:9]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	v_cndmask_b32_e64 v5, v5, v6, s[10:11]
	v_add_f32_e32 v5, 1.0, v5
	v_rcp_f32_e32 v10, v5
	v_mul_f32_e32 v5, 0x114b4ea4, v7
	v_cndmask_b32_e64 v5, v7, v5, s[8:9]
	v_add_f32_e32 v5, 1.0, v5
	v_rcp_f32_e32 v11, v5
	v_rcp_f32_e32 v9, v4
	ds_read_b128 v[4:7], v53 offset:560
	v_cmp_gt_i32_e64 s[8:9], s13, v0
	v_pk_mul_f32 v[10:11], v[10:11], v[16:17]
	s_and_b64 s[12:13], vcc, s[8:9]
	v_pk_mul_f32 v[8:9], v[8:9], v[14:15]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, v4, v4
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v16, v0, v4
	v_fmaak_f32 v0, v0, v4, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v16
	v_mul_f32_e32 v19, v7, v7
	v_fmamk_f32 v19, v19, 0xbd92220c, v52
	v_cndmask_b32_e64 v0, v16, v0, s[10:11]
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_mov_b32_e32 v16, 0x80000030
	v_cndmask_b32_e64 v20, v16, 48, s[12:13]
	v_mul_f32_e32 v21, v19, v7
	v_mul_f32_e32 v16, 0x114b4ea4, v0
	v_cndmask_b32_e64 v0, v0, v16, s[10:11]
	v_add_f32_e32 v0, 1.0, v0
	v_rcp_f32_e32 v16, v0
	v_mul_f32_e32 v0, v5, v5
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v17, v0, v5
	v_fmaak_f32 v0, v0, v5, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v17
	v_fmaak_f32 v19, v19, v7, 0x42800000
	ds_read_b128 v[12:15], v53 offset:544
	v_cndmask_b32_e32 v0, v17, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_mul_f32_e32 v17, v6, v6
	v_exp_f32_e32 v0, v0
	v_fmamk_f32 v17, v17, 0xbd92220c, v52
	v_mul_f32_e32 v18, v17, v6
	v_fmaak_f32 v17, v17, v6, 0x42800000
	v_cmp_gt_f32_e64 s[10:11], s15, v18
	s_and_b64 s[8:9], s[0:1], s[8:9]
	s_and_b64 s[4:5], s[0:1], s[4:5]
	v_cndmask_b32_e64 v17, v18, v17, s[10:11]
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_mul_f32_e32 v18, 0x114b4ea4, v0
	v_exp_f32_e32 v17, v17
	v_cndmask_b32_e32 v0, v0, v18, vcc
	v_cmp_gt_f32_e32 vcc, s15, v21
	v_add_f32_e32 v0, 1.0, v0
	v_mul_f32_e32 v18, 0x114b4ea4, v17
	v_cndmask_b32_e32 v19, v21, v19, vcc
	v_mul_f32_e32 v19, 0x3fb8aa3b, v19
	v_exp_f32_e32 v19, v19
	v_cndmask_b32_e64 v17, v17, v18, s[10:11]
	v_add_f32_e32 v17, 1.0, v17
	v_rcp_f32_e32 v18, v17
	v_mul_f32_e32 v17, 0x114b4ea4, v19
	v_cndmask_b32_e32 v17, v19, v17, vcc
	v_add_f32_e32 v17, 1.0, v17
	v_rcp_f32_e32 v19, v17
	v_rcp_f32_e32 v17, v0
	v_add_u32_e32 v0, v3, v20
	buffer_store_dwordx4 v[8:11], v0, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, v12, v12
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v3, v0, v12
	v_fmaak_f32 v0, v0, v12, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v3
	v_pk_mul_f32 v[4:5], v[16:17], v[4:5]
	v_mul_f32_e32 v10, v15, v15
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_cndmask_b32_e64 v3, v51, 0, s[8:9]
	v_fmamk_f32 v10, v10, 0xbd92220c, v52
	v_mul_f32_e32 v11, v10, v15
	v_mul_f32_e32 v8, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v8, vcc
	v_add_f32_e32 v0, 1.0, v0
	v_rcp_f32_e32 v16, v0
	v_mul_f32_e32 v0, v13, v13
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v8, v0, v13
	v_fmaak_f32 v0, v0, v13, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v8
	v_fmaak_f32 v10, v10, v15, 0x42800000
	v_pk_mul_f32 v[6:7], v[18:19], v[6:7]
	v_cndmask_b32_e32 v0, v8, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_mul_f32_e32 v8, v14, v14
	v_exp_f32_e32 v0, v0
	v_fmamk_f32 v8, v8, 0xbd92220c, v52
	v_mul_f32_e32 v9, v8, v14
	v_fmaak_f32 v8, v8, v14, 0x42800000
	v_cmp_gt_f32_e64 s[8:9], s15, v9
	v_add_u32_e32 v3, v1, v3
	buffer_store_dwordx4 v[4:7], v3, s[20:23], 0 offen offset:560
	v_cndmask_b32_e64 v8, v9, v8, s[8:9]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_mul_f32_e32 v9, 0x114b4ea4, v0
	v_exp_f32_e32 v8, v8
	v_cndmask_b32_e32 v0, v0, v9, vcc
	v_cmp_gt_f32_e32 vcc, s15, v11
	v_add_f32_e32 v0, 1.0, v0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e32 v10, v11, v10, vcc
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v8, v8, v9, s[8:9]
	v_add_f32_e32 v8, 1.0, v8
	v_rcp_f32_e32 v18, v8
	v_mul_f32_e32 v8, 0x114b4ea4, v10
	v_cndmask_b32_e32 v8, v10, v8, vcc
	v_add_f32_e32 v8, 1.0, v8
	v_rcp_f32_e32 v19, v8
	ds_read_b128 v[8:11], v53 offset:528
	v_rcp_f32_e32 v17, v0
	s_and_b64 s[0:1], s[0:1], s[2:3]
	v_pk_mul_f32 v[6:7], v[18:19], v[14:15]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, v8, v8
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v3, v0, v8
	v_fmaak_f32 v0, v0, v8, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v3
	v_pk_mul_f32 v[4:5], v[16:17], v[12:13]
	ds_read_b128 v[12:15], v53 offset:512
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_cndmask_b32_e64 v3, v51, 0, s[6:7]
	v_add_u32_e32 v3, v1, v3
	buffer_store_dwordx4 v[4:7], v3, s[20:23], 0 offen offset:544
	v_mul_f32_e32 v3, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v3, vcc
	v_mul_f32_e32 v3, v9, v9
	v_fmamk_f32 v3, v3, 0xbd92220c, v52
	v_mul_f32_e32 v4, v3, v9
	v_fmaak_f32 v3, v3, v9, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v4
	v_mul_f32_e32 v7, v11, v11
	v_fmamk_f32 v7, v7, 0xbd92220c, v52
	v_cndmask_b32_e32 v3, v4, v3, vcc
	v_mul_f32_e32 v4, v10, v10
	v_fmamk_f32 v4, v4, 0xbd92220c, v52
	v_mul_f32_e32 v5, v4, v10
	v_fmaak_f32 v4, v4, v10, 0x42800000
	v_cmp_gt_f32_e64 s[6:7], s15, v5
	v_mul_f32_e32 v16, v7, v11
	v_fmaak_f32 v7, v7, v11, 0x42800000
	v_cndmask_b32_e64 v4, v5, v4, s[6:7]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v5, v4
	v_cmp_gt_f32_e64 s[8:9], s15, v16
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_cndmask_b32_e64 v7, v16, v7, s[8:9]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v6, s[6:7]
	v_add_f32_e32 v0, 1.0, v0
	v_add_f32_e32 v5, 1.0, v5
	v_rcp_f32_e32 v4, v0
	v_mul_f32_e32 v0, 0x114b4ea4, v3
	v_rcp_f32_e32 v6, v5
	v_mul_f32_e32 v5, 0x114b4ea4, v7
	v_cndmask_b32_e64 v5, v7, v5, s[8:9]
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_add_f32_e32 v5, 1.0, v5
	v_add_f32_e32 v0, 1.0, v0
	v_rcp_f32_e32 v7, v5
	v_rcp_f32_e32 v5, v0
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v0, v12, v12
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v3, v0, v12
	v_fmaak_f32 v0, v0, v12, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v3
	v_pk_mul_f32 v[4:5], v[4:5], v[8:9]
	v_pk_mul_f32 v[6:7], v[6:7], v[10:11]
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_mul_f32_e32 v11, v15, v15
	v_cndmask_b32_e64 v10, v51, 0, s[4:5]
	v_mul_f32_e32 v3, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v3, vcc
	v_add_f32_e32 v0, 1.0, v0
	v_rcp_f32_e32 v8, v0
	v_mul_f32_e32 v0, v13, v13
	v_fmamk_f32 v0, v0, 0xbd92220c, v52
	v_mul_f32_e32 v3, v0, v13
	v_fmaak_f32 v0, v0, v13, 0x42800000
	v_cmp_gt_f32_e32 vcc, s15, v3
	s_nop 1
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_mul_f32_e32 v3, v14, v14
	v_fmamk_f32 v3, v3, 0xbd92220c, v52
	v_mul_f32_e32 v9, v3, v14
	v_fmaak_f32 v3, v3, v14, 0x42800000
	v_cmp_gt_f32_e64 s[4:5], s15, v9
	v_fmac_f32_e32 v52, 0xbd92220c, v11
	v_mul_f32_e32 v11, v52, v15
	v_cndmask_b32_e64 v3, v9, v3, s[4:5]
	v_mul_f32_e32 v9, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v9, vcc
	v_fmac_f32_e32 v2, v52, v15
	v_cmp_gt_f32_e32 vcc, s15, v11
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_cndmask_b32_e32 v2, v11, v2, vcc
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_exp_f32_e32 v11, v2
	v_mul_f32_e32 v9, 0x114b4ea4, v3
	v_cndmask_b32_e64 v2, v3, v9, s[4:5]
	v_add_f32_e32 v0, 1.0, v0
	v_mul_f32_e32 v3, 0x114b4ea4, v11
	v_cndmask_b32_e32 v3, v11, v3, vcc
	v_add_f32_e32 v2, 1.0, v2
	v_add_f32_e32 v3, 1.0, v3
	v_rcp_f32_e32 v2, v2
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v9, v0
	v_add_u32_e32 v0, v1, v10
	buffer_store_dwordx4 v[4:7], v0, s[20:23], 0 offen offset:528
	v_cndmask_b32_e64 v0, v51, 0, s[0:1]
	v_add_u32_e32 v0, v1, v0
	v_pk_mul_f32 v[4:5], v[2:3], v[14:15]
	v_pk_mul_f32 v[2:3], v[8:9], v[12:13]
	buffer_store_dwordx4 v[2:5], v0, s[20:23], 0 offen offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 64
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 29
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
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

	.type	__hip_cuid_7b4ca646419074e6,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_7b4ca646419074e6
__hip_cuid_7b4ca646419074e6:
	.byte	0
	.size	__hip_cuid_7b4ca646419074e6, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_7b4ca646419074e6
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
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_8FastGeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
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
