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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
	s_load_dwordx8 s[24:31], s[0:1], 0x10
	s_load_dword s12, s[0:1], 0x68
	s_load_dwordx2 s[8:9], s[0:1], 0x60
	s_load_dwordx4 s[4:7], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_cmp_gt_i32 s30, 1
	s_cselect_b64 s[10:11], -1, 0
	s_bitcmp1_b32 s12, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[10:11], s[10:11], s[12:13]
	s_andn2_b64 vcc, exec, s[10:11]
	s_mov_b64 s[10:11], 0
	s_cbranch_vccnz .LBB1_2
	s_mul_i32 s10, s24, s3
	s_mul_i32 s10, s10, s25
	s_ashr_i32 s11, s10, 31
.LBB1_2:
	s_load_dword s13, s[0:1], 0x34
	s_add_i32 s12, s24, -1
	s_cmp_lt_u32 s12, 64
	s_mov_b32 s31, 0
	s_cbranch_scc1 .LBB1_10
	s_add_i32 s0, s25, -1
	s_cmp_lt_u32 s0, 64
	s_mov_b32 s0, 0
	s_cbranch_scc1 .LBB1_9
	s_add_i32 s0, s24, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s15, s0, 6
	s_add_i32 s0, s25, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s14, s0, 6
	s_mul_i32 s0, s14, s15
	s_add_i32 s1, s0, 7
	s_ashr_i32 s16, s1, 31
	s_lshr_b32 s16, s16, 29
	s_add_i32 s1, s1, s16
	s_ashr_i32 s16, s1, 3
	s_and_b32 s1, s1, -8
	s_sub_i32 s17, s0, s1
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 29
	s_add_i32 s19, s2, s0
	s_and_b32 s0, s19, -8
	s_add_i32 s17, s17, 8
	s_sub_i32 s18, s2, s0
	s_cmp_gt_i32 s18, s17
	s_cbranch_scc1 .LBB1_6
	s_mul_i32 s2, s16, s18
	s_ashr_i32 s0, s19, 3
	s_cbranch_execz .LBB1_7
	s_branch .LBB1_8
.LBB1_6:
	s_ashr_i32 s0, s19, 3
.LBB1_7:
	s_add_i32 s1, s16, -1
	s_mul_i32 s1, s1, s18
	s_add_i32 s2, s17, s1
.LBB1_8:
	s_abs_i32 s1, s14
	v_cvt_f32_u32_e32 v1, s1
	s_sub_i32 s17, 0, s1
	s_add_i32 s0, s2, s0
	s_abs_i32 s16, s0
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s2, s0, s14
	s_ashr_i32 s2, s2, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s18, v1
	s_mul_i32 s17, s17, s18
	s_mul_hi_u32 s17, s18, s17
	s_add_i32 s18, s18, s17
	s_mul_hi_u32 s17, s16, s18
	s_mul_i32 s18, s17, s1
	s_sub_i32 s16, s16, s18
	s_add_i32 s19, s17, 1
	s_sub_i32 s18, s16, s1
	s_cmp_ge_u32 s16, s1
	s_cselect_b32 s17, s19, s17
	s_cselect_b32 s16, s18, s16
	s_add_i32 s18, s17, 1
	s_cmp_ge_u32 s16, s1
	s_cselect_b32 s1, s18, s17
	s_xor_b32 s1, s1, s2
	s_lshr_b32 s16, s15, 30
	s_sub_i32 s1, s1, s2
	s_add_i32 s16, s15, s16
	s_mul_i32 s2, s1, s14
	s_sub_i32 s0, s0, s2
	s_and_b32 s2, s16, -4
	s_sub_i32 s15, s15, s2
	s_cmp_ge_i32 s1, s2
	s_cselect_b32 s2, s15, 4
	s_abs_i32 s16, s2
	v_cvt_f32_u32_e32 v1, s16
	s_ashr_i32 s15, s1, 31
	s_lshr_b32 s15, s15, 30
	s_add_i32 s15, s1, s15
	v_rcp_iflag_f32_e32 v1, v1
	s_and_b32 s15, s15, -4
	s_sub_i32 s15, s1, s15
	s_sub_i32 s18, 0, s16
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s14, s15, s14
	s_add_i32 s14, s14, s0
	s_abs_i32 s17, s14
	v_readfirstlane_b32 s19, v1
	s_mul_i32 s18, s18, s19
	s_mul_hi_u32 s18, s19, s18
	s_add_i32 s19, s19, s18
	s_mul_hi_u32 s18, s17, s19
	s_mul_i32 s19, s18, s16
	s_xor_b32 s0, s14, s2
	s_sub_i32 s17, s17, s19
	s_ashr_i32 s0, s0, 31
	s_add_i32 s19, s18, 1
	s_sub_i32 s20, s17, s16
	s_cmp_ge_u32 s17, s16
	s_cselect_b32 s18, s19, s18
	s_cselect_b32 s17, s20, s17
	s_add_i32 s19, s18, 1
	s_cmp_ge_u32 s17, s16
	s_cselect_b32 s16, s19, s18
	s_xor_b32 s16, s16, s0
	s_sub_i32 s0, s16, s0
	s_mul_i32 s2, s0, s2
	s_sub_i32 s2, s14, s2
	s_add_i32 s2, s2, s1
	s_sub_i32 s2, s2, s15
.LBB1_9:
	s_mov_b32 s31, s2
	s_mov_b32 s2, s0
.LBB1_10:
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s36, s8, s0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s13, s3
	s_addc_u32 s37, s9, s1
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s44, s6, s0
	s_addc_u32 s45, s7, s1
	s_add_u32 s40, s4, s0
	s_addc_u32 s41, s5, s1
	s_add_i32 s0, s30, -1
	s_mul_i32 s1, s0, s13
	s_sub_i32 s1, s26, s1
	v_lshlrev_b32_e32 v1, 2, v0
	s_cmp_lt_u32 s3, s0
	v_and_b32_e32 v66, 12, v1
	v_lshrrev_b32_e32 v1, 1, v0
	s_cselect_b32 s4, s13, s1
	s_lshl_b32 s30, s2, 6
	v_and_b32_e32 v67, 0x7e, v1
	s_add_i32 s0, s25, 0x3fffffff
	v_lshl_add_u32 v15, s31, 6, v67
	v_lshlrev_b32_e32 v14, 2, v66
	v_and_b32_e32 v68, 14, v1
	v_bitop3_b32 v69, v1, v66, 14 bitop3:0x6c
	v_add_u32_e32 v20, s30, v67
	v_and_b32_e32 v1, 15, v0
	v_lshrrev_b32_e32 v2, 2, v0
	s_mul_i32 s26, s12, s29
	s_mul_i32 s3, s0, s28
	s_mul_i32 s12, s12, s27
	v_mad_u64_u32 v[6:7], s[0:1], v15, s27, v[14:15]
	v_mad_u64_u32 v[18:19], s[0:1], v20, s28, v[14:15]
	v_and_or_b32 v70, v2, 48, v1
	v_and_b32_e32 v98, 12, v2
	v_bitop3_b32 v99, v2, v1, 12 bitop3:0x6c
	s_add_i32 s0, s4, s12
	s_lshl_b32 s42, s0, 2
	s_mov_b32 s43, 0x20000
	v_lshlrev_b32_e32 v16, 2, v6
	buffer_load_dwordx4 v[2:5], v16, s[40:43], 0 offen
	v_add_u32_e32 v17, 12, v6
	v_add_lshl_u32 v19, v17, s27, 2
	buffer_load_dwordx4 v[6:9], v16, s[40:43], 0 offen offset:16
	v_add_u32_e32 v10, -16, v19
	buffer_load_dwordx2 v[34:35], v10, s[40:43], 0 offen
	v_subrev_u32_e32 v10, 32, v19
	buffer_load_dwordx2 v[36:37], v10, s[40:43], 0 offen
	v_subrev_u32_e32 v10, 24, v19
	buffer_load_dwordx2 v[38:39], v10, s[40:43], 0 offen
	v_subrev_u32_e32 v10, 40, v19
	buffer_load_dwordx2 v[40:41], v10, s[40:43], 0 offen
	v_subrev_u32_e32 v10, 48, v19
	buffer_load_dwordx2 v[42:43], v10, s[40:43], 0 offen
	buffer_load_dwordx4 v[10:13], v16, s[40:43], 0 offen offset:32
	v_add_u32_e32 v21, -8, v19
	buffer_load_dwordx2 v[44:45], v21, s[40:43], 0 offen
	buffer_load_dwordx2 v[48:49], v16, s[40:43], 0 offen offset:56
	v_lshlrev_b32_e32 v17, 2, v17
	buffer_load_dwordx2 v[46:47], v17, s[40:43], 0 offen
	v_lshlrev_b32_e32 v30, 2, v18
	v_add_u32_e32 v18, 12, v18
	v_cmp_gt_i32_e64 s[0:1], s4, v14
	v_cmp_gt_i32_e64 s[18:19], s24, v15
	v_or_b32_e32 v21, 2, v14
	v_or_b32_e32 v22, 6, v14
	v_or_b32_e32 v23, 4, v14
	v_or_b32_e32 v24, 8, v14
	v_or_b32_e32 v25, 10, v14
	v_or_b32_e32 v26, 14, v14
	v_or_b32_e32 v27, 12, v14
	v_or_b32_e32 v28, 1, v15
	buffer_load_dwordx4 v[14:17], v19, s[40:43], 0 offen
	s_add_i32 s6, s4, s3
	v_add_lshl_u32 v54, v18, s28, 2
	v_or_b32_e32 v19, 1, v20
	s_lshl_b32 s46, s6, 2
	s_mov_b32 s47, s43
	v_lshlrev_b32_e32 v31, 2, v18
	v_add_u32_e32 v55, -8, v54
	v_add_u32_e32 v56, -16, v54
	v_subrev_u32_e32 v58, 32, v54
	v_subrev_u32_e32 v60, 24, v54
	v_subrev_u32_e32 v62, 40, v54
	v_subrev_u32_e32 v64, 48, v54
	v_cmp_gt_i32_e32 vcc, s25, v20
	v_cmp_gt_i32_e64 s[14:15], s4, v21
	v_cmp_gt_i32_e64 s[12:13], s4, v22
	v_cmp_gt_i32_e64 s[16:17], s4, v23
	v_cmp_gt_i32_e64 s[10:11], s4, v24
	v_cmp_gt_i32_e64 s[8:9], s4, v25
	v_cmp_gt_i32_e64 s[2:3], s4, v26
	v_cmp_gt_i32_e64 s[4:5], s4, v27
	v_cmp_gt_i32_e64 s[20:21], s24, v28
	v_cmp_gt_i32_e64 s[6:7], s25, v19
	buffer_load_dwordx4 v[18:21], v30, s[44:47], 0 offen
	buffer_load_dwordx4 v[22:25], v30, s[44:47], 0 offen offset:16
	buffer_load_dwordx4 v[26:29], v30, s[44:47], 0 offen offset:32
	buffer_load_dwordx2 v[50:51], v30, s[44:47], 0 offen offset:56
	buffer_load_dwordx2 v[52:53], v31, s[44:47], 0 offen
	buffer_load_dwordx4 v[30:33], v54, s[44:47], 0 offen
	buffer_load_dwordx2 v[54:55], v55, s[44:47], 0 offen
	buffer_load_dwordx2 v[56:57], v56, s[44:47], 0 offen
	buffer_load_dwordx2 v[58:59], v58, s[44:47], 0 offen
	buffer_load_dwordx2 v[60:61], v60, s[44:47], 0 offen
	buffer_load_dwordx2 v[62:63], v62, s[44:47], 0 offen
	buffer_load_dwordx2 v[64:65], v64, s[44:47], 0 offen
	s_and_b64 s[22:23], s[0:1], s[18:19]
	v_lshlrev_b32_e32 v67, 8, v67
	v_lshl_or_b32 v67, v69, 4, v67
	s_waitcnt vmcnt(23)
	v_cndmask_b32_e64 v3, 0, v3, s[22:23]
	v_cndmask_b32_e64 v2, 0, v2, s[22:23]
	s_and_b64 s[22:23], s[14:15], s[18:19]
	v_cndmask_b32_e64 v5, 0, v5, s[22:23]
	v_cndmask_b32_e64 v4, 0, v4, s[22:23]
	s_and_b64 s[22:23], s[16:17], s[18:19]
	s_waitcnt vmcnt(22)
	v_cndmask_b32_e64 v7, 0, v7, s[22:23]
	v_cndmask_b32_e64 v6, 0, v6, s[22:23]
	s_and_b64 s[22:23], s[10:11], s[20:21]
	s_waitcnt vmcnt(21)
	v_cndmask_b32_e64 v35, 0, v35, s[22:23]
	v_cndmask_b32_e64 v34, 0, v34, s[22:23]
	s_and_b64 s[22:23], s[16:17], s[20:21]
	s_waitcnt vmcnt(20)
	v_cndmask_b32_e64 v37, 0, v37, s[22:23]
	v_cndmask_b32_e64 v36, 0, v36, s[22:23]
	s_and_b64 s[22:23], s[12:13], s[20:21]
	ds_write2_b64 v67, v[2:3], v[4:5] offset1:1
	v_bitop3_b32 v3, v68, v66, 1 bitop3:0x36
	s_waitcnt vmcnt(19)
	v_cndmask_b32_e64 v39, 0, v39, s[22:23]
	v_cndmask_b32_e64 v38, 0, v38, s[22:23]
	s_and_b64 s[22:23], s[14:15], s[20:21]
	v_sub_u32_e32 v4, v3, v69
	s_waitcnt vmcnt(18)
	v_cndmask_b32_e64 v41, 0, v41, s[22:23]
	v_cndmask_b32_e64 v40, 0, v40, s[22:23]
	s_and_b64 s[22:23], s[0:1], s[20:21]
	v_lshl_add_u32 v69, v4, 4, v67
	v_bitop3_b32 v4, v68, v66, 1 bitop3:0x14
	s_waitcnt vmcnt(17)
	v_cndmask_b32_e64 v43, 0, v43, s[22:23]
	v_cndmask_b32_e64 v42, 0, v42, s[22:23]
	v_sub_u32_e32 v3, v4, v3
	v_bitop3_b32 v5, v66, v68, 1 bitop3:0x36
	ds_write2_b64 v69, v[42:43], v[40:41] offset0:32 offset1:33
	v_lshlrev_b32_e32 v40, 4, v3
	v_sub_u32_e32 v4, v5, v4
	s_and_b64 s[22:23], s[12:13], s[18:19]
	v_add_u32_e32 v3, v69, v40
	v_lshlrev_b32_e32 v41, 4, v4
	v_cndmask_b32_e64 v9, 0, v9, s[22:23]
	v_cndmask_b32_e64 v8, 0, v8, s[22:23]
	v_or_b32_e32 v2, 1, v68
	v_add_u32_e32 v4, v3, v41
	ds_write2_b64 v3, v[36:37], v[38:39] offset0:32 offset1:33
	ds_write2_b64 v4, v[6:7], v[8:9] offset1:1
	v_bitop3_b32 v3, v66, v68, 2 bitop3:0x36
	s_and_b64 s[22:23], s[10:11], s[18:19]
	v_sub_u32_e32 v5, v3, v5
	v_bitop3_b32 v2, v66, v2, 2 bitop3:0x36
	s_waitcnt vmcnt(16)
	v_cndmask_b32_e64 v11, 0, v11, s[22:23]
	v_cndmask_b32_e64 v10, 0, v10, s[22:23]
	s_and_b64 s[22:23], s[8:9], s[18:19]
	v_lshlrev_b32_e32 v36, 4, v5
	v_sub_u32_e32 v3, v2, v3
	v_cndmask_b32_e64 v13, 0, v13, s[22:23]
	v_cndmask_b32_e64 v12, 0, v12, s[22:23]
	v_add_u32_e32 v4, v4, v36
	v_lshlrev_b32_e32 v37, 4, v3
	v_add_u32_e32 v3, v4, v37
	ds_write2_b64 v4, v[10:11], v[12:13] offset1:1
	v_or_b32_e32 v4, 3, v66
	v_bitop3_b32 v4, v68, v4, 1 bitop3:0x36
	s_and_b64 s[22:23], s[8:9], s[20:21]
	v_sub_u32_e32 v2, v4, v2
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v45, 0, v45, s[22:23]
	v_cndmask_b32_e64 v44, 0, v44, s[22:23]
	s_and_b64 s[22:23], s[4:5], s[18:19]
	s_and_b64 s[18:19], s[2:3], s[18:19]
	v_lshlrev_b32_e32 v38, 4, v2
	s_waitcnt vmcnt(14)
	v_cndmask_b32_e64 v49, 0, v49, s[18:19]
	v_cndmask_b32_e64 v48, 0, v48, s[18:19]
	s_and_b64 s[18:19], s[4:5], s[20:21]
	v_add_u32_e32 v2, v3, v38
	ds_write2_b64 v3, v[34:35], v[44:45] offset0:32 offset1:33
	v_bitop3_b32 v3, v66, v68, 3 bitop3:0x36
	s_waitcnt vmcnt(12)
	v_cndmask_b32_e64 v15, 0, v15, s[18:19]
	v_cndmask_b32_e64 v14, 0, v14, s[18:19]
	s_and_b64 s[18:19], s[2:3], s[20:21]
	v_sub_u32_e32 v3, v3, v4
	v_cndmask_b32_e64 v17, 0, v17, s[18:19]
	v_cndmask_b32_e64 v16, 0, v16, s[18:19]
	v_lshlrev_b32_e32 v34, 4, v3
	s_and_b64 s[18:19], s[0:1], vcc
	s_and_b64 s[0:1], s[0:1], s[6:7]
	v_cndmask_b32_e64 v47, 0, v47, s[22:23]
	v_cndmask_b32_e64 v46, 0, v46, s[22:23]
	v_add_u32_e32 v3, v2, v34
	ds_write2_b64 v2, v[14:15], v[16:17] offset0:32 offset1:33
	ds_write2_b64 v3, v[46:47], v[48:49] offset1:1
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e64 v17, 0, v65, s[0:1]
	v_cndmask_b32_e64 v16, 0, v64, s[0:1]
	s_and_b64 s[0:1], s[12:13], vcc
	v_cndmask_b32_e64 v3, 0, v19, s[18:19]
	v_cndmask_b32_e64 v2, 0, v18, s[18:19]
	s_and_b64 s[18:19], s[14:15], vcc
	v_cndmask_b32_e64 v19, 0, v25, s[0:1]
	v_cndmask_b32_e64 v18, 0, v24, s[0:1]
	s_and_b64 s[0:1], s[10:11], vcc
	v_cndmask_b32_e64 v5, 0, v21, s[18:19]
	v_cndmask_b32_e64 v4, 0, v20, s[18:19]
	s_and_b64 s[18:19], s[16:17], vcc
	v_cndmask_b32_e64 v21, 0, v27, s[0:1]
	v_cndmask_b32_e64 v20, 0, v26, s[0:1]
	s_and_b64 s[0:1], s[8:9], vcc
	v_cndmask_b32_e64 v7, 0, v23, s[18:19]
	v_cndmask_b32_e64 v6, 0, v22, s[18:19]
	v_cndmask_b32_e64 v23, 0, v29, s[0:1]
	v_cndmask_b32_e64 v22, 0, v28, s[0:1]
	s_and_b64 s[0:1], s[8:9], s[6:7]
	s_and_b64 s[14:15], s[14:15], s[6:7]
	v_cndmask_b32_e64 v25, 0, v55, s[0:1]
	v_cndmask_b32_e64 v24, 0, v54, s[0:1]
	s_and_b64 s[0:1], s[4:5], vcc
	v_add_u32_e32 v35, 0x4000, v67
	s_and_b64 s[16:17], s[16:17], s[6:7]
	v_cndmask_b32_e64 v15, 0, v63, s[14:15]
	v_cndmask_b32_e64 v14, 0, v62, s[14:15]
	v_cndmask_b32_e64 v27, 0, v53, s[0:1]
	v_cndmask_b32_e64 v26, 0, v52, s[0:1]
	s_movk_i32 s0, 0x4000
	ds_write2_b64 v35, v[2:3], v[4:5] offset1:1
	v_add_u32_e32 v2, 0x4100, v69
	v_cndmask_b32_e64 v11, 0, v59, s[16:17]
	v_cndmask_b32_e64 v10, 0, v58, s[16:17]
	s_and_b64 s[16:17], s[12:13], s[6:7]
	ds_write2_b64 v2, v[16:17], v[14:15] offset1:1
	v_add3_u32 v2, v69, s0, v40
	v_cndmask_b32_e64 v13, 0, v61, s[16:17]
	v_cndmask_b32_e64 v12, 0, v60, s[16:17]
	s_and_b64 vcc, s[2:3], vcc
	v_add_u32_e32 v3, v2, v41
	v_cndmask_b32_e32 v29, 0, v51, vcc
	v_cndmask_b32_e32 v28, 0, v50, vcc
	s_and_b64 vcc, s[4:5], s[6:7]
	ds_write2_b64 v2, v[10:11], v[12:13] offset0:32 offset1:33
	ds_write2_b64 v3, v[6:7], v[18:19] offset1:1
	v_add_u32_e32 v2, v3, v36
	s_and_b64 s[18:19], s[10:11], s[6:7]
	v_cndmask_b32_e32 v31, 0, v31, vcc
	v_cndmask_b32_e32 v30, 0, v30, vcc
	s_and_b64 vcc, s[2:3], s[6:7]
	v_add_u32_e32 v3, v2, v37
	v_cndmask_b32_e64 v9, 0, v57, s[18:19]
	v_cndmask_b32_e64 v8, 0, v56, s[18:19]
	v_cndmask_b32_e32 v33, 0, v33, vcc
	v_cndmask_b32_e32 v32, 0, v32, vcc
	ds_write2_b64 v2, v[20:21], v[22:23] offset1:1
	v_add_u32_e32 v2, v3, v38
	ds_write2_b64 v3, v[8:9], v[24:25] offset0:32 offset1:33
	v_add_u32_e32 v3, v2, v34
	ds_write2_b64 v2, v[30:31], v[32:33] offset0:32 offset1:33
	ds_write2_b64 v3, v[26:27], v[28:29] offset1:1
	v_lshlrev_b32_e32 v2, 4, v99
	v_lshl_or_b32 v3, v70, 8, v2
	v_lshl_or_b32 v6, v1, 8, v2
	v_bitop3_b32 v2, v98, v1, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v99
	v_lshlrev_b32_e32 v2, 4, v2
	v_or_b32_e32 v7, 0x4000, v6
	v_add_u32_e32 v4, v3, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[50:53], v3
	ds_read_b128 v[54:57], v3 offset:8192
	ds_read_b128 v[58:61], v6 offset:16384
	ds_read_b128 v[62:65], v6 offset:20480
	ds_read_b128 v[66:69], v6 offset:24576
	ds_read_b128 v[70:73], v6 offset:28672
	ds_read_b128 v[74:77], v4
	ds_read_b128 v[78:81], v4 offset:8192
	v_add_u32_e32 v4, v2, v6
	v_add_u32_e32 v2, v7, v2
	ds_read_b128 v[82:85], v4 offset:16384
	ds_read_b128 v[86:89], v2 offset:4096
	ds_read_b128 v[90:93], v2 offset:8192
	ds_read_b128 v[94:97], v2 offset:12288
	v_bitop3_b32 v2, v98, v1, 2 bitop3:0x36
	v_sub_u32_e32 v2, v2, v99
	v_lshlrev_b32_e32 v2, 4, v2
	v_add_u32_e32 v4, v3, v2
	ds_read_b128 v[46:49], v4
	ds_read_b128 v[14:17], v4 offset:8192
	v_add_u32_e32 v4, v2, v6
	v_add_u32_e32 v2, v7, v2
	ds_read_b128 v[22:25], v4 offset:16384
	ds_read_b128 v[18:21], v2 offset:4096
	ds_read_b128 v[38:41], v2 offset:8192
	ds_read_b128 v[34:37], v2 offset:12288
	v_bitop3_b32 v2, v98, v1, 3 bitop3:0x36
	v_sub_u32_e32 v2, v2, v99
	v_lshlrev_b32_e32 v8, 4, v2
	v_add_u32_e32 v2, v3, v8
	v_add_u32_e32 v6, v8, v6
	v_add_u32_e32 v26, v7, v8
	ds_read_b128 v[42:45], v2
	ds_read_b128 v[2:5], v2 offset:8192
	ds_read_b128 v[10:13], v6 offset:16384
	ds_read_b128 v[6:9], v26 offset:4096
	ds_read_b128 v[30:33], v26 offset:8192
	ds_read_b128 v[26:29], v26 offset:12288
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[0:3], v50, v58, 0
	v_lshlrev_b32_e32 v1, 2, v1
	s_movk_i32 s0, 0xe00
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_mov_b32 s18, 0x42aeac50
	s_mov_b32 s39, s43
	s_lshl_b32 s19, s29, 5
	v_mfma_f32_16x16x4_f32 a[0:3], v51, v59, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v52, v60, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v53, v61, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v50, v62, 0
	v_mfma_f32_16x16x4_f32 a[4:7], v51, v63, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v74, v82, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v52, v64, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v75, v83, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v53, v65, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v50, v66, 0
	v_mfma_f32_16x16x4_f32 a[0:3], v76, v84, a[0:3]
	v_mfma_f32_16x16x4_f32 a[8:11], v51, v67, a[8:11]
	v_mfma_f32_16x16x4_f32 a[32:35], v77, v85, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v74, v86, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v52, v68, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v75, v87, a[0:3]
	v_mfma_f32_16x16x4_f32 a[8:11], v53, v69, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v50, v70, 0
	v_lshlrev_b32_e32 v50, 3, v0
	v_mfma_f32_16x16x4_f32 a[0:3], v76, v88, a[0:3]
	v_mfma_f32_16x16x4_f32 a[12:15], v51, v71, a[12:15]
	v_lshrrev_b32_e32 v51, 7, v0
	v_mfma_f32_16x16x4_f32 a[36:39], v77, v89, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v74, v90, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v52, v72, a[12:15]
	v_add_u32_e32 v52, s31, v51
	v_mfma_f32_16x16x4_f32 a[0:3], v75, v91, a[0:3]
	v_mfma_f32_16x16x4_f32 a[12:15], v53, v73, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v54, v58, 0
	v_mfma_f32_16x16x4_f32 a[0:3], v76, v92, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v55, v59, a[16:19]
	v_mfma_f32_16x16x4_f32 a[40:43], v77, v93, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v74, v94, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v56, v60, a[16:19]
	v_mfma_f32_16x16x4_f32 a[0:3], v75, v95, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v57, v61, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v54, v62, 0
	v_mfma_f32_16x16x4_f32 a[0:3], v76, v96, a[0:3]
	v_mfma_f32_16x16x4_f32 a[20:23], v55, v63, a[20:23]
	v_mfma_f32_16x16x4_f32 a[44:47], v77, v97, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v78, v82, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v56, v64, a[20:23]
	v_mfma_f32_16x16x4_f32 a[0:3], v79, v83, a[0:3]
	v_mfma_f32_16x16x4_f32 a[20:23], v57, v65, a[20:23]
	v_mfma_f32_16x16x4_f32 a[0:3], v80, v84, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v46, v22, a[32:35]
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v85, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v78, v86, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v18, a[36:39]
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v23, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v19, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v24, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v20, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v25, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v49, v21, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v54, v66, 0
	v_mfma_f32_16x16x4_f32 a[16:19], v42, v10, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v42, v6, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v55, v67, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v54, v70, 0
	v_bfe_u32 v54, v0, 2, 5
	v_lshlrev_b32_e32 v0, 5, v0
	v_lshl_or_b32 v53, v52, 6, v54
	v_and_or_b32 v52, v0, s0, v1
	v_lshlrev_b32_e32 v0, 7, v54
	v_lshlrev_b32_e32 v1, 12, v51
	v_cmp_gt_i32_e64 s[6:7], s24, v53
	v_mfma_f32_16x16x4_f32 a[16:19], v43, v11, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v43, v7, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v56, v68, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v55, v71, a[28:31]
	v_and_b32_e32 v55, 24, v50
	v_lshlrev_b32_e32 v51, 2, v55
	v_or3_b32 v51, v0, v1, v51
	v_or_b32_e32 v50, s30, v55
	v_mad_u64_u32 v[0:1], s[0:1], v53, s29, v[50:51]
	v_lshlrev_b32_e32 v62, 2, v0
	v_mfma_f32_16x16x4_f32 a[16:19], v44, v12, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v44, v8, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v57, v69, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v56, v72, a[28:31]
	v_mfma_f32_16x16x4_f32 a[16:19], v45, v13, a[16:19]
	s_nop 7
	s_nop 1
	ds_write_b32 v52, a16
	ds_write_b32 v52, a17 offset:128
	ds_write_b32 v52, a18 offset:256
	v_mfma_f32_16x16x4_f32 a[20:23], v45, v9, a[20:23]
	ds_write_b32 v52, a19 offset:384
	s_nop 7
	s_nop 0
	ds_write_b32 v52, a23 offset:448
	ds_write_b32 v52, a22 offset:320
	ds_write_b32 v52, a21 offset:192
	ds_write_b32 v52, a20 offset:64
	v_mfma_f32_16x16x4_f32 a[8:11], v78, v90, a[24:27]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[58:61], v51 offset0:2 offset1:3
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_f32_e64 s[4:5], s18, v59
	v_mfma_f32_16x16x4_f32 a[28:31], v57, v73, a[28:31]
	ds_read2_b64 v[54:57], v51 offset1:1
	v_cmp_lt_f32_e64 s[8:9], s18, v61
	s_waitcnt lgkmcnt(0)
	v_sub_f32_e32 v1, 0x42800000, v54
	v_cmp_lt_f32_e32 vcc, s18, v54
	v_mfma_f32_16x16x4_f32 a[24:27], v46, v38, a[40:43]
	v_cmp_lt_f32_e64 s[0:1], s18, v55
	v_cndmask_b32_e64 v1, -v54, v1, vcc
	v_sub_f32_e32 v54, 0x42800000, v55
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_cndmask_b32_e64 v54, -v55, v54, s[0:1]
	v_exp_f32_e32 v1, v1
	v_mul_f32_e32 v54, 0x3fb8aa3b, v54
	v_mfma_f32_16x16x4_f32 a[20:23], v46, v34, a[44:47]
	v_exp_f32_e32 v55, v54
	v_mul_f32_e32 v54, 0x114b4ea4, v1
	v_cndmask_b32_e32 v54, v1, v54, vcc
	v_cmp_gt_i32_e32 vcc, s25, v50
	v_mul_f32_e32 v1, 0x114b4ea4, v55
	v_cndmask_b32_e64 v55, v55, v1, s[0:1]
	v_pk_add_f32 v[54:55], v[54:55], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[8:11], v79, v91, a[8:11]
	v_rcp_f32_e32 v55, v55
	v_rcp_f32_e32 v54, v54
	s_add_i32 s0, s25, s26
	s_lshl_b32 s38, s0, 2
	v_bfrev_b32_e32 v1, 1
	s_and_b64 s[0:1], s[6:7], vcc
	v_cndmask_b32_e64 v46, v1, 0, s[0:1]
	v_mfma_f32_16x16x4_f32 a[16:19], v47, v39, a[24:27]
	v_add_u32_e32 v46, v46, v62
	buffer_store_dwordx2 v[54:55], v46, s[36:39], 0 offen
	v_sub_f32_e32 v46, 0x42800000, v56
	v_cmp_lt_f32_e64 s[0:1], s18, v56
	v_cmp_lt_f32_e64 s[2:3], s18, v57
	v_add_u32_e32 v54, 32, v0
	v_cndmask_b32_e64 v46, -v56, v46, s[0:1]
	v_mfma_f32_16x16x4_f32 a[20:23], v47, v35, a[20:23]
	v_sub_f32_e32 v47, 0x42800000, v57
	v_cndmask_b32_e64 v47, -v57, v47, s[2:3]
	v_mul_f32_e32 v46, 0x3fb8aa3b, v46
	v_mul_f32_e32 v47, 0x3fb8aa3b, v47
	v_exp_f32_e32 v46, v46
	v_exp_f32_e32 v47, v47
	v_add_lshl_u32 v0, v0, s19, 2
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v92, a[8:11]
	v_mfma_f32_16x16x4_f32 a[16:19], v48, v40, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v48, v36, a[20:23]
	v_or_b32_e32 v48, 2, v50
	v_mfma_f32_16x16x4_f32 a[12:15], v81, v93, a[8:11]
	v_mfma_f32_16x16x4_f32 a[16:19], v49, v41, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v49, v37, a[20:23]
	v_mul_f32_e32 v49, 0x114b4ea4, v46
	v_cndmask_b32_e64 v46, v46, v49, s[0:1]
	v_cmp_gt_i32_e64 s[0:1], s25, v48
	v_or_b32_e32 v48, 4, v50
	v_mfma_f32_16x16x4_f32 a[12:15], v14, v38, a[12:15]
	v_mul_f32_e32 v38, 0x114b4ea4, v47
	v_cndmask_b32_e64 v47, v47, v38, s[2:3]
	v_pk_add_f32 v[46:47], v[46:47], 1.0 op_sel_hi:[1,0]
	s_and_b64 s[2:3], s[6:7], s[0:1]
	v_rcp_f32_e32 v47, v47
	v_rcp_f32_e32 v46, v46
	v_cndmask_b32_e64 v38, v1, 0, s[2:3]
	v_mfma_f32_16x16x4_f32 a[8:11], v78, v94, a[28:31]
	v_add_u32_e32 v38, v62, v38
	buffer_store_dwordx2 v[46:47], v38, s[36:39], 0 offen offset:8
	v_sub_f32_e32 v38, 0x42800000, v58
	v_cmp_lt_f32_e64 s[2:3], s18, v58
	v_sub_f32_e32 v46, 0x42800000, v59
	v_cndmask_b32_e64 v46, -v59, v46, s[4:5]
	v_cndmask_b32_e64 v38, -v58, v38, s[2:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v42, v30, a[16:19]
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v38
	v_mul_f32_e32 v46, 0x3fb8aa3b, v46
	v_exp_f32_e32 v47, v46
	v_mul_f32_e32 v46, 0x114b4ea4, v38
	v_cndmask_b32_e64 v46, v38, v46, s[2:3]
	v_mfma_f32_16x16x4_f32 a[20:23], v42, v26, a[20:23]
	v_mul_f32_e32 v38, 0x114b4ea4, v47
	v_cndmask_b32_e64 v47, v47, v38, s[4:5]
	v_pk_add_f32 v[46:47], v[46:47], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_i32_e64 s[2:3], s25, v48
	v_rcp_f32_e32 v47, v47
	v_rcp_f32_e32 v46, v46
	s_and_b64 s[4:5], s[6:7], s[2:3]
	v_mfma_f32_16x16x4_f32 a[8:11], v79, v95, a[8:11]
	v_cndmask_b32_e64 v38, v1, 0, s[4:5]
	v_add_u32_e32 v38, v62, v38
	buffer_store_dwordx2 v[46:47], v38, s[36:39], 0 offen offset:16
	v_sub_f32_e32 v38, 0x42800000, v60
	v_cmp_lt_f32_e64 s[4:5], s18, v60
	v_sub_f32_e32 v42, 0x42800000, v61
	v_cndmask_b32_e64 v42, -v61, v42, s[8:9]
	v_mfma_f32_16x16x4_f32 a[16:19], v43, v31, a[16:19]
	v_cndmask_b32_e64 v38, -v60, v38, s[4:5]
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_exp_f32_e32 v38, v38
	v_mul_f32_e32 v42, 0x3fb8aa3b, v42
	v_or_b32_e32 v46, 6, v50
	v_mfma_f32_16x16x4_f32 a[20:23], v43, v27, a[20:23]
	v_exp_f32_e32 v43, v42
	v_mul_f32_e32 v42, 0x114b4ea4, v38
	v_cndmask_b32_e64 v42, v38, v42, s[4:5]
	v_cmp_gt_i32_e64 s[4:5], s25, v46
	v_mul_f32_e32 v38, 0x114b4ea4, v43
	v_cndmask_b32_e64 v43, v43, v38, s[8:9]
	v_pk_add_f32 v[42:43], v[42:43], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v96, a[8:11]
	v_rcp_f32_e32 v43, v43
	v_rcp_f32_e32 v42, v42
	s_and_b64 s[8:9], s[6:7], s[4:5]
	v_cndmask_b32_e64 v38, v1, 0, s[8:9]
	v_add_u32_e32 v38, v62, v38
	buffer_store_dwordx2 v[42:43], v38, s[36:39], 0 offen offset:24
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[16:19], v44, v32, a[16:19]
	s_barrier
	v_mfma_f32_16x16x4_f32 a[20:23], v44, v28, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v81, v97, a[8:11]
	v_mfma_f32_16x16x4_f32 a[16:19], v45, v33, a[16:19]
	s_nop 7
	s_nop 1
	ds_write_b32 v52, a16
	ds_write_b32 v52, a17 offset:128
	ds_write_b32 v52, a18 offset:256
	ds_write_b32 v52, a19 offset:384
	v_mfma_f32_16x16x4_f32 a[20:23], v45, v29, a[20:23]
	s_nop 7
	s_nop 1
	ds_write_b32 v52, a23 offset:448
	ds_write_b32 v52, a22 offset:320
	ds_write_b32 v52, a21 offset:192
	ds_write_b32 v52, a20 offset:64
	v_mfma_f32_16x16x4_f32 a[12:15], v15, v39, a[12:15]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[42:45], v51 offset1:1
	ds_read2_b64 v[46:49], v51 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	v_sub_f32_e32 v38, 0x42800000, v42
	v_mfma_f32_16x16x4_f32 a[8:11], v14, v34, a[8:11]
	v_cmp_lt_f32_e64 s[8:9], s18, v42
	v_sub_f32_e32 v39, 0x42800000, v43
	v_cmp_lt_f32_e64 s[10:11], s18, v43
	v_cndmask_b32_e64 v38, -v42, v38, s[8:9]
	v_mul_f32_e32 v38, 0x3fb8aa3b, v38
	v_cndmask_b32_e64 v39, -v43, v39, s[10:11]
	v_mul_f32_e32 v39, 0x3fb8aa3b, v39
	v_mfma_f32_16x16x4_f32 a[12:15], v16, v40, a[12:15]
	v_exp_f32_e32 v38, v38
	v_exp_f32_e32 v39, v39
	v_or_b32_e32 v40, 32, v50
	v_cmp_lt_f32_e64 s[12:13], s18, v45
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_f32_e64 s[14:15], s18, v47
	v_mul_f32_e32 v34, 0x114b4ea4, v39
	v_cndmask_b32_e64 v39, v39, v34, s[10:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v15, v35, a[8:11]
	v_sub_f32_e32 v35, 0x42800000, v45
	v_cndmask_b32_e64 v35, -v45, v35, s[12:13]
	v_mul_f32_e32 v35, 0x3fb8aa3b, v35
	v_exp_f32_e32 v35, v35
	v_cmp_lt_f32_e64 s[16:17], s18, v49
	v_mfma_f32_16x16x4_f32 a[12:15], v17, v41, a[12:15]
	v_mul_f32_e32 v41, 0x114b4ea4, v38
	v_cndmask_b32_e64 v38, v38, v41, s[8:9]
	v_pk_add_f32 v[38:39], v[38:39], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_i32_e64 s[8:9], s25, v40
	v_rcp_f32_e32 v39, v39
	v_rcp_f32_e32 v38, v38
	s_and_b64 s[10:11], s[6:7], s[8:9]
	v_mfma_f32_16x16x4_f32 a[8:11], v16, v36, a[8:11]
	v_cndmask_b32_e64 v34, v1, 0, s[10:11]
	v_lshl_add_u32 v34, v54, 2, v34
	buffer_store_dwordx2 v[38:39], v34, s[36:39], 0 offen
	v_sub_f32_e32 v34, 0x42800000, v44
	v_cmp_lt_f32_e64 s[10:11], s18, v44
	v_or_b32_e32 v36, 34, v50
	s_nop 0
	v_cndmask_b32_e64 v34, -v44, v34, s[10:11]
	v_mul_f32_e32 v34, 0x3fb8aa3b, v34
	v_exp_f32_e32 v34, v34
	v_mfma_f32_16x16x4_f32 a[0:3], v79, v87, a[0:3]
	v_mfma_f32_16x16x4_f32 a[8:11], v17, v37, a[8:11]
	v_mul_f32_e32 v37, 0x114b4ea4, v34
	v_cndmask_b32_e64 v34, v34, v37, s[10:11]
	v_mul_f32_e32 v37, 0x114b4ea4, v35
	v_cndmask_b32_e64 v35, v35, v37, s[12:13]
	v_pk_add_f32 v[34:35], v[34:35], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_i32_e64 s[10:11], s25, v36
	v_rcp_f32_e32 v35, v35
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v30, a[12:15]
	v_rcp_f32_e32 v34, v34
	s_and_b64 s[12:13], s[6:7], s[10:11]
	v_cndmask_b32_e64 v30, v1, 0, s[12:13]
	v_add_u32_e32 v30, v62, v30
	buffer_store_dwordx2 v[34:35], v30, s[36:39], 0 offen offset:136
	v_sub_f32_e32 v30, 0x42800000, v46
	v_cmp_lt_f32_e64 s[12:13], s18, v46
	v_mfma_f32_16x16x4_f32 a[0:3], v80, v88, a[0:3]
	s_nop 0
	v_cndmask_b32_e64 v30, -v46, v30, s[12:13]
	v_mul_f32_e32 v30, 0x3fb8aa3b, v30
	v_exp_f32_e32 v30, v30
	s_nop 0
	v_mul_f32_e32 v34, 0x114b4ea4, v30
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v26, a[8:11]
	v_cndmask_b32_e64 v30, v30, v34, s[12:13]
	v_sub_f32_e32 v26, 0x42800000, v48
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v31, a[12:15]
	v_sub_f32_e32 v31, 0x42800000, v47
	v_cndmask_b32_e64 v31, -v47, v31, s[14:15]
	v_mul_f32_e32 v31, 0x3fb8aa3b, v31
	v_exp_f32_e32 v31, v31
	s_nop 0
	v_mul_f32_e32 v34, 0x114b4ea4, v31
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v89, a[0:3]
	v_cndmask_b32_e64 v31, v31, v34, s[14:15]
	v_pk_add_f32 v[30:31], v[30:31], 1.0 op_sel_hi:[1,0]
	v_or_b32_e32 v34, 32, v53
	v_rcp_f32_e32 v31, v31
	v_rcp_f32_e32 v30, v30
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v27, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v14, v22, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v32, a[12:15]
	v_or_b32_e32 v32, 36, v50
	v_cmp_gt_i32_e64 s[12:13], s25, v32
	s_and_b64 s[14:15], s[6:7], s[12:13]
	v_cndmask_b32_e64 v32, v1, 0, s[14:15]
	v_add_u32_e32 v32, v62, v32
	v_cmp_lt_f32_e64 s[14:15], s18, v48
	buffer_store_dwordx2 v[30:31], v32, s[36:39], 0 offen offset:144
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v28, a[8:11]
	v_cndmask_b32_e64 v26, -v48, v26, s[14:15]
	v_sub_f32_e32 v30, 0x42800000, v49
	v_mul_f32_e32 v26, 0x3fb8aa3b, v26
	v_cndmask_b32_e64 v27, -v49, v30, s[16:17]
	v_exp_f32_e32 v26, v26
	v_mul_f32_e32 v27, 0x3fb8aa3b, v27
	v_exp_f32_e32 v27, v27
	v_mfma_f32_16x16x4_f32 a[0:3], v14, v18, a[0:3]
	v_mul_f32_e32 v31, 0x114b4ea4, v26
	v_cndmask_b32_e64 v26, v26, v31, s[14:15]
	v_mul_f32_e32 v31, 0x114b4ea4, v27
	v_cndmask_b32_e64 v27, v27, v31, s[16:17]
	v_or_b32_e32 v30, 38, v50
	v_pk_add_f32 v[26:27], v[26:27], 1.0 op_sel_hi:[1,0]
	v_cmp_gt_i32_e64 s[14:15], s25, v30
	v_mfma_f32_16x16x4_f32 a[4:7], v15, v23, a[4:7]
	v_rcp_f32_e32 v27, v27
	v_rcp_f32_e32 v26, v26
	s_and_b64 s[6:7], s[6:7], s[14:15]
	v_cndmask_b32_e64 v28, v1, 0, s[6:7]
	v_add_u32_e32 v28, v62, v28
	buffer_store_dwordx2 v[26:27], v28, s[36:39], 0 offen offset:152
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v33, a[12:15]
	s_barrier
	s_nop 7
	s_nop 0
	ds_write_b32 v52, a12
	ds_write_b32 v52, a13 offset:128
	ds_write_b32 v52, a14 offset:256
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v29, a[8:11]
	ds_write_b32 v52, a15 offset:384
	s_nop 7
	s_nop 0
	ds_write_b32 v52, a11 offset:448
	ds_write_b32 v52, a10 offset:320
	ds_write_b32 v52, a9 offset:192
	ds_write_b32 v52, a8 offset:64
	v_mfma_f32_16x16x4_f32 a[0:3], v15, v19, a[0:3]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[26:29], v51 offset1:1
	ds_read2_b64 v[30:33], v51 offset0:2 offset1:3
	v_add_lshl_u32 v18, v54, s19, 2
	s_waitcnt lgkmcnt(1)
	v_sub_f32_e32 v22, 0x42800000, v26
	v_mfma_f32_16x16x4_f32 a[4:7], v16, v24, a[4:7]
	v_cmp_lt_f32_e64 s[6:7], s18, v26
	v_sub_f32_e32 v23, 0x42800000, v27
	v_cmp_lt_f32_e64 s[16:17], s18, v27
	v_cndmask_b32_e64 v22, -v26, v22, s[6:7]
	v_mul_f32_e32 v22, 0x3fb8aa3b, v22
	v_exp_f32_e32 v22, v22
	v_cndmask_b32_e64 v23, -v27, v23, s[16:17]
	v_mfma_f32_16x16x4_f32 a[0:3], v16, v20, a[0:3]
	v_mul_f32_e32 v23, 0x3fb8aa3b, v23
	v_exp_f32_e32 v23, v23
	v_mul_f32_e32 v24, 0x114b4ea4, v22
	v_cndmask_b32_e64 v22, v22, v24, s[6:7]
	v_cmp_gt_i32_e64 s[6:7], s24, v34
	v_mul_f32_e32 v24, 0x114b4ea4, v23
	s_and_b64 s[8:9], s[6:7], s[8:9]
	v_mfma_f32_16x16x4_f32 a[4:7], v17, v25, a[4:7]
	v_cndmask_b32_e64 v23, v23, v24, s[16:17]
	v_cndmask_b32_e64 v14, v1, 0, s[8:9]
	v_sub_f32_e32 v24, 0x42800000, v28
	v_cmp_lt_f32_e64 s[8:9], s18, v28
	v_sub_f32_e32 v19, 0x42800000, v29
	v_cmp_lt_f32_e64 s[16:17], s18, v29
	v_cndmask_b32_e64 v15, -v28, v24, s[8:9]
	v_mfma_f32_16x16x4_f32 a[0:3], v17, v21, a[0:3]
	v_pk_add_f32 v[22:23], v[22:23], 1.0 op_sel_hi:[1,0]
	v_mul_f32_e32 v15, 0x3fb8aa3b, v15
	v_cndmask_b32_e64 v19, -v29, v19, s[16:17]
	v_rcp_f32_e32 v23, v23
	v_rcp_f32_e32 v22, v22
	v_exp_f32_e32 v15, v15
	v_mul_f32_e32 v19, 0x3fb8aa3b, v19
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v10, a[4:7]
	v_exp_f32_e32 v16, v19
	v_add_u32_e32 v14, v18, v14
	buffer_store_dwordx2 v[22:23], v14, s[36:39], 0 offen
	v_mul_f32_e32 v14, 0x114b4ea4, v15
	v_cndmask_b32_e64 v14, v15, v14, s[8:9]
	v_mul_f32_e32 v15, 0x114b4ea4, v16
	v_cndmask_b32_e64 v15, v16, v15, s[16:17]
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v6, a[0:3]
	v_mov_b32_e32 v16, 0x80000008
	s_and_b64 s[8:9], s[6:7], s[10:11]
	v_cndmask_b32_e64 v16, v16, 8, s[8:9]
	s_waitcnt lgkmcnt(0)
	v_sub_f32_e32 v17, 0x42800000, v30
	v_cmp_lt_f32_e64 s[8:9], s18, v30
	v_cmp_lt_f32_e64 s[10:11], s18, v31
	v_pk_add_f32 v[14:15], v[14:15], 1.0 op_sel_hi:[1,0]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v11, a[4:7]
	v_cndmask_b32_e64 v10, -v30, v17, s[8:9]
	v_sub_f32_e32 v17, 0x42800000, v31
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_cndmask_b32_e64 v17, -v31, v17, s[10:11]
	v_rcp_f32_e32 v15, v15
	v_rcp_f32_e32 v14, v14
	v_exp_f32_e32 v10, v10
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v7, a[0:3]
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_exp_f32_e32 v11, v17
	v_add_u32_e32 v16, v18, v16
	buffer_store_dwordx2 v[14:15], v16, s[36:39], 0 offen
	v_mul_f32_e32 v14, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v14, s[8:9]
	v_mul_f32_e32 v14, 0x114b4ea4, v11
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v12, a[4:7]
	v_mov_b32_e32 v12, 0x80000010
	s_and_b64 s[8:9], s[6:7], s[12:13]
	v_cndmask_b32_e64 v11, v11, v14, s[10:11]
	v_cndmask_b32_e64 v12, v12, 16, s[8:9]
	v_sub_f32_e32 v14, 0x42800000, v32
	v_cmp_lt_f32_e64 s[8:9], s18, v32
	v_cmp_lt_f32_e64 s[10:11], s18, v33
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v8, a[0:3]
	v_pk_add_f32 v[10:11], v[10:11], 1.0 op_sel_hi:[1,0]
	v_add_u32_e32 v12, v18, v12
	v_rcp_f32_e32 v11, v11
	v_rcp_f32_e32 v10, v10
	s_and_b64 s[0:1], s[6:7], s[0:1]
	buffer_store_dwordx2 v[10:11], v12, s[36:39], 0 offen
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v13, a[4:7]
	v_cndmask_b32_e64 v13, -v32, v14, s[8:9]
	v_sub_f32_e32 v14, 0x42800000, v33
	v_mul_f32_e32 v13, 0x3fb8aa3b, v13
	v_cndmask_b32_e64 v14, -v33, v14, s[10:11]
	v_exp_f32_e32 v13, v13
	v_mul_f32_e32 v2, 0x3fb8aa3b, v14
	v_exp_f32_e32 v2, v2
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v9, a[0:3]
	v_mul_f32_e32 v6, 0x114b4ea4, v13
	v_cndmask_b32_e64 v10, v13, v6, s[8:9]
	v_mul_f32_e32 v6, 0x114b4ea4, v2
	v_cndmask_b32_e64 v11, v2, v6, s[10:11]
	v_pk_add_f32 v[2:3], v[10:11], 1.0 op_sel_hi:[1,0]
	v_mov_b32_e32 v6, 0x80000018
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v2, v2
	s_and_b64 s[8:9], s[6:7], s[14:15]
	v_cndmask_b32_e64 v6, v6, 24, s[8:9]
	v_add_u32_e32 v6, v18, v6
	buffer_store_dwordx2 v[2:3], v6, s[36:39], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v52, a4
	ds_write_b32 v52, a5 offset:128
	ds_write_b32 v52, a6 offset:256
	ds_write_b32 v52, a7 offset:384
	ds_write_b32 v52, a3 offset:448
	ds_write_b32 v52, a2 offset:320
	ds_write_b32 v52, a1 offset:192
	ds_write_b32 v52, a0 offset:64
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[2:5], v51 offset1:1
	ds_read2_b64 v[6:9], v51 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	v_sub_f32_e32 v10, 0x42800000, v2
	v_cmp_lt_f32_e64 s[8:9], s18, v2
	v_cmp_lt_f32_e64 s[10:11], s18, v3
	v_sub_f32_e32 v11, 0x42800000, v4
	v_cndmask_b32_e64 v2, -v2, v10, s[8:9]
	v_sub_f32_e32 v10, 0x42800000, v3
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_cndmask_b32_e64 v3, -v3, v10, s[10:11]
	v_exp_f32_e32 v2, v2
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_mul_f32_e32 v10, 0x114b4ea4, v2
	v_cndmask_b32_e64 v2, v2, v10, s[8:9]
	v_mul_f32_e32 v10, 0x114b4ea4, v3
	s_and_b64 s[8:9], vcc, s[6:7]
	v_cmp_lt_f32_e32 vcc, s18, v4
	v_cndmask_b32_e64 v3, v3, v10, s[10:11]
	v_cndmask_b32_e64 v10, v1, 0, s[8:9]
	v_cndmask_b32_e64 v4, -v4, v11, vcc
	v_sub_f32_e32 v11, 0x42800000, v5
	v_cmp_lt_f32_e64 s[8:9], s18, v5
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_cndmask_b32_e64 v5, -v5, v11, s[8:9]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v2, v2
	v_exp_f32_e32 v4, v4
	v_exp_f32_e32 v5, v5
	v_add_u32_e32 v10, v10, v0
	buffer_store_dwordx2 v[2:3], v10, s[36:39], 0 offen
	v_mul_f32_e32 v2, 0x114b4ea4, v4
	v_mul_f32_e32 v3, 0x114b4ea4, v5
	v_cndmask_b32_e32 v2, v4, v2, vcc
	v_cndmask_b32_e64 v3, v5, v3, s[8:9]
	s_waitcnt lgkmcnt(0)
	v_sub_f32_e32 v5, 0x42800000, v6
	v_cmp_lt_f32_e32 vcc, s18, v6
	v_cndmask_b32_e64 v4, v1, 0, s[0:1]
	v_cmp_lt_f32_e64 s[0:1], s18, v7
	v_cndmask_b32_e64 v5, -v6, v5, vcc
	v_sub_f32_e32 v6, 0x42800000, v7
	v_cndmask_b32_e64 v6, -v7, v6, s[0:1]
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v2, v2
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v6, v6
	v_exp_f32_e32 v5, v5
	v_add_u32_e32 v4, v0, v4
	buffer_store_dwordx2 v[2:3], v4, s[36:39], 0 offen offset:8
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_mul_f32_e32 v2, 0x114b4ea4, v5
	v_cndmask_b32_e64 v3, v6, v3, s[0:1]
	s_and_b64 s[0:1], s[6:7], s[2:3]
	v_cndmask_b32_e32 v2, v5, v2, vcc
	v_cndmask_b32_e64 v4, v1, 0, s[0:1]
	v_sub_f32_e32 v5, 0x42800000, v8
	v_cmp_lt_f32_e32 vcc, s18, v8
	v_sub_f32_e32 v6, 0x42800000, v9
	v_cmp_lt_f32_e64 s[0:1], s18, v9
	v_cndmask_b32_e64 v5, -v8, v5, vcc
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	v_cndmask_b32_e64 v6, -v9, v6, s[0:1]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v2, v2
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v6, v6
	v_add_u32_e32 v4, v0, v4
	buffer_store_dwordx2 v[2:3], v4, s[36:39], 0 offen offset:16
	v_mul_f32_e32 v2, 0x114b4ea4, v5
	v_mul_f32_e32 v3, 0x114b4ea4, v6
	v_cndmask_b32_e32 v2, v5, v2, vcc
	v_cndmask_b32_e64 v3, v6, v3, s[0:1]
	v_pk_add_f32 v[2:3], v[2:3], 1.0 op_sel_hi:[1,0]
	s_and_b64 s[0:1], s[6:7], s[4:5]
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v2, v2
	v_cndmask_b32_e64 v1, v1, 0, s[0:1]
	v_add_u32_e32 v0, v0, v1
	buffer_store_dwordx2 v[2:3], v0, s[36:39], 0 offen offset:24
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
		.amdhsa_group_segment_fixed_size 32768
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
		.amdhsa_next_free_vgpr 148
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 100
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 100
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 48
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 48
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_70903055bcc5c163,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_70903055bcc5c163
__hip_cuid_70903055bcc5c163:
	.byte	0
	.size	__hip_cuid_70903055bcc5c163, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_70903055bcc5c163
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:           []
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 4
    .kernarg_segment_size: 0
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
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
  - .agpr_count:     48
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_7SigmoidELNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi2ELi2ELb0ELi0ESD_SE_SE_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSC_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     148
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
