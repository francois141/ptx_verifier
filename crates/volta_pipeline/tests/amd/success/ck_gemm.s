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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
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
	v_and_b32_e32 v94, 12, v2
	v_bitop3_b32 v95, v2, v1, 12 bitop3:0x6c
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
	v_lshlrev_b32_e32 v2, 4, v95
	v_lshl_or_b32 v3, v70, 8, v2
	v_lshl_or_b32 v6, v1, 8, v2
	v_bitop3_b32 v2, v94, v1, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v95
	v_lshlrev_b32_e32 v2, 4, v2
	v_or_b32_e32 v7, 0x4000, v6
	v_add_u32_e32 v4, v3, v2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[22:25], v3
	ds_read_b128 v[26:29], v3 offset:8192
	ds_read_b128 v[30:33], v6 offset:16384
	ds_read_b128 v[34:37], v6 offset:20480
	ds_read_b128 v[38:41], v6 offset:24576
	ds_read_b128 v[42:45], v6 offset:28672
	ds_read_b128 v[46:49], v4
	ds_read_b128 v[50:53], v4 offset:8192
	v_add_u32_e32 v4, v2, v6
	v_add_u32_e32 v2, v7, v2
	ds_read_b128 v[54:57], v4 offset:16384
	ds_read_b128 v[58:61], v2 offset:4096
	ds_read_b128 v[62:65], v2 offset:8192
	ds_read_b128 v[66:69], v2 offset:12288
	v_bitop3_b32 v2, v94, v1, 2 bitop3:0x36
	v_sub_u32_e32 v2, v2, v95
	v_lshlrev_b32_e32 v2, 4, v2
	v_add_u32_e32 v4, v3, v2
	ds_read_b128 v[70:73], v4
	ds_read_b128 v[74:77], v4 offset:8192
	v_add_u32_e32 v4, v2, v6
	v_add_u32_e32 v2, v7, v2
	ds_read_b128 v[78:81], v4 offset:16384
	ds_read_b128 v[82:85], v2 offset:4096
	ds_read_b128 v[86:89], v2 offset:8192
	ds_read_b128 v[90:93], v2 offset:12288
	v_bitop3_b32 v2, v94, v1, 3 bitop3:0x36
	v_sub_u32_e32 v2, v2, v95
	v_lshlrev_b32_e32 v8, 4, v2
	v_add_u32_e32 v2, v3, v8
	v_add_u32_e32 v6, v8, v6
	v_add_u32_e32 v14, v7, v8
	ds_read_b128 v[94:97], v2
	ds_read_b128 v[2:5], v2 offset:8192
	ds_read_b128 v[10:13], v6 offset:16384
	ds_read_b128 v[6:9], v14 offset:4096
	ds_read_b128 v[18:21], v14 offset:8192
	ds_read_b128 v[14:17], v14 offset:12288
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[0:3], v22, v30, 0
	v_lshlrev_b32_e32 v1, 2, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_mov_b32 s39, s43
	s_lshl_b32 s16, s29, 5
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v34, 0
	v_mfma_f32_16x16x4_f32 a[0:3], v23, v31, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v35, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v24, v32, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v24, v36, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v22, v38, 0
	v_mfma_f32_16x16x4_f32 a[12:15], v22, v42, 0
	v_lshrrev_b32_e32 v22, 7, v0
	v_mfma_f32_16x16x4_f32 a[0:3], v25, v33, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v25, v37, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v23, v39, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v23, v43, a[12:15]
	v_bfe_u32 v23, v0, 2, 5
	v_mfma_f32_16x16x4_f32 a[0:3], v46, v54, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v46, v58, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v26, v30, 0
	v_mfma_f32_16x16x4_f32 a[8:11], v24, v40, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v24, v44, a[12:15]
	v_lshlrev_b32_e32 v24, 3, v0
	v_and_b32_e32 v24, 24, v24
	v_or_b32_e32 v30, s30, v24
	v_lshlrev_b32_e32 v0, 5, v0
	v_cmp_gt_i32_e32 vcc, s25, v30
	v_mfma_f32_16x16x4_f32 a[24:27], v26, v38, 0
	v_mfma_f32_16x16x4_f32 a[0:3], v47, v55, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v47, v59, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v27, v31, a[16:19]
	v_mfma_f32_16x16x4_f32 a[8:11], v25, v41, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v25, v45, a[12:15]
	v_add_u32_e32 v25, s31, v22
	v_lshl_or_b32 v31, v25, 6, v23
	v_lshlrev_b32_e32 v22, 12, v22
	v_cmp_gt_i32_e64 s[6:7], s24, v31
	v_mfma_f32_16x16x4_f32 a[24:27], v27, v39, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v48, v56, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v48, v60, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v28, v32, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v28, v40, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v46, v62, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v46, v66, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v49, v57, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v49, v61, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v29, v33, a[16:19]
	v_mad_u64_u32 v[32:33], s[0:1], v31, s29, v[30:31]
	s_movk_i32 s0, 0xe00
	s_nop 0
	v_and_or_b32 v0, v0, s0, v1
	v_lshlrev_b32_e32 v1, 7, v23
	v_lshlrev_b32_e32 v23, 2, v24
	v_or3_b32 v33, v1, v22, v23
	v_mfma_f32_16x16x4_f32 a[24:27], v29, v41, a[24:27]
	s_add_i32 s0, s25, s26
	s_lshl_b32 s38, s0, 2
	s_and_b64 s[0:1], s[6:7], vcc
	v_lshlrev_b32_e32 v1, 2, v32
	v_mfma_f32_16x16x4_f32 a[28:31], v26, v42, 0
	v_mfma_f32_16x16x4_f32 a[8:11], v47, v63, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v47, v67, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v70, v78, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v70, v82, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v50, v54, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v27, v43, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v48, v64, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v48, v68, a[12:15]
	v_mfma_f32_16x16x4_f32 a[24:27], v50, v62, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v71, v79, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v71, v83, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v51, v55, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v28, v44, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v49, v65, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v49, v69, a[12:15]
	v_mfma_f32_16x16x4_f32 a[24:27], v51, v63, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v72, v80, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v72, v84, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v52, v56, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v29, v45, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v52, v64, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v86, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v70, v90, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v73, v81, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v73, v85, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v26, v34, 0
	v_bfrev_b32_e32 v34, 1
	v_mfma_f32_16x16x4_f32 a[16:19], v53, v57, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v53, v65, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v50, v66, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v71, v87, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v71, v91, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v94, v10, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v94, v6, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v27, v35, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v74, v78, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v51, v67, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v72, v88, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v72, v92, a[12:15]
	v_mfma_f32_16x16x4_f32 a[24:27], v74, v86, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v95, v11, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v95, v7, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v28, v36, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v75, v79, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v52, v68, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v73, v89, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v73, v93, a[12:15]
	v_mfma_f32_16x16x4_f32 a[24:27], v75, v87, a[24:27]
	v_mfma_f32_16x16x4_f32 a[0:3], v96, v12, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v96, v8, a[4:7]
	v_mfma_f32_16x16x4_f32 a[20:23], v29, v37, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v76, v80, a[16:19]
	v_mfma_f32_16x16x4_f32 a[28:31], v53, v69, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v76, v88, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v94, v18, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v94, v14, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v97, v13, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v97, v9, a[4:7]
	s_nop 7
	s_nop 0
	ds_write_b32 v0, a0
	ds_write_b32 v0, a1 offset:128
	ds_write_b32 v0, a2 offset:256
	ds_write_b32 v0, a3 offset:384
	ds_write_b32 v0, a7 offset:448
	ds_write_b32 v0, a6 offset:320
	ds_write_b32 v0, a5 offset:192
	ds_write_b32 v0, a4 offset:64
	v_mfma_f32_16x16x4_f32 a[20:23], v50, v58, a[20:23]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[22:25], v33 offset1:1
	ds_read2_b64 v[26:29], v33 offset0:2 offset1:3
	v_mfma_f32_16x16x4_f32 a[16:19], v77, v81, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v77, v89, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v74, v90, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v95, v19, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v95, v15, a[12:15]
	v_mfma_f32_16x16x4_f32 a[20:23], v51, v59, a[20:23]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v10, a[16:19]
	v_cndmask_b32_e64 v10, v34, 0, s[0:1]
	v_add_u32_e32 v10, v10, v1
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[22:23], v10, s[36:39], 0 offen
	v_or_b32_e32 v10, 2, v30
	v_cmp_gt_i32_e64 s[0:1], s25, v10
	s_and_b64 s[2:3], s[6:7], s[0:1]
	v_cndmask_b32_e64 v10, v34, 0, s[2:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v75, v91, a[28:31]
	v_add_u32_e32 v10, v1, v10
	buffer_store_dwordx2 v[24:25], v10, s[36:39], 0 offen offset:8
	v_or_b32_e32 v10, 4, v30
	v_cmp_gt_i32_e64 s[2:3], s25, v10
	s_and_b64 s[4:5], s[6:7], s[2:3]
	v_cndmask_b32_e64 v10, v34, 0, s[4:5]
	v_add_u32_e32 v10, v1, v10
	v_mfma_f32_16x16x4_f32 a[8:11], v96, v20, a[8:11]
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[26:27], v10, s[36:39], 0 offen offset:16
	v_or_b32_e32 v10, 6, v30
	v_cmp_gt_i32_e64 s[4:5], s25, v10
	s_and_b64 s[8:9], s[6:7], s[4:5]
	v_cndmask_b32_e64 v10, v34, 0, s[8:9]
	v_add_u32_e32 v10, v1, v10
	buffer_store_dwordx2 v[28:29], v10, s[36:39], 0 offen offset:24
	v_mfma_f32_16x16x4_f32 a[0:3], v96, v16, a[12:15]
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_or_b32_e32 v10, 32, v30
	v_cmp_gt_i32_e64 s[8:9], s25, v10
	s_and_b64 s[10:11], s[6:7], s[8:9]
	v_add_u32_e32 v26, 32, v32
	v_cndmask_b32_e64 v10, v34, 0, s[10:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v18, a[24:27]
	v_lshl_add_u32 v10, v26, 2, v10
	v_mfma_f32_16x16x4_f32 a[20:23], v52, v60, a[20:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v76, v92, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v97, v21, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v19, a[12:15]
	v_mfma_f32_16x16x4_f32 a[0:3], v97, v17, a[0:3]
	s_nop 7
	ds_write_b32 v0, a8
	ds_write_b32 v0, a9 offset:128
	ds_write_b32 v0, a10 offset:256
	ds_write_b32 v0, a11 offset:384
	ds_write_b32 v0, a3 offset:448
	ds_write_b32 v0, a2 offset:320
	ds_write_b32 v0, a1 offset:192
	ds_write_b32 v0, a0 offset:64
	v_mfma_f32_16x16x4_f32 a[20:23], v53, v61, a[20:23]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[22:25], v33 offset1:1
	v_mfma_f32_16x16x4_f32 a[28:31], v77, v93, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v20, a[12:15]
	v_mfma_f32_16x16x4_f32 a[20:23], v74, v82, a[20:23]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v21, a[8:11]
	ds_read2_b64 v[18:21], v33 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[22:23], v10, s[36:39], 0 offen
	v_or_b32_e32 v10, 34, v30
	v_cmp_gt_i32_e64 s[10:11], s25, v10
	s_and_b64 s[12:13], s[6:7], s[10:11]
	v_cndmask_b32_e64 v10, v34, 0, s[12:13]
	v_add_u32_e32 v10, v1, v10
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v14, a[28:31]
	buffer_store_dwordx2 v[24:25], v10, s[36:39], 0 offen offset:136
	v_or_b32_e32 v10, 36, v30
	v_cmp_gt_i32_e64 s[12:13], s25, v10
	s_and_b64 s[14:15], s[6:7], s[12:13]
	v_cndmask_b32_e64 v10, v34, 0, s[14:15]
	v_add_u32_e32 v10, v1, v10
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[18:19], v10, s[36:39], 0 offen offset:144
	v_mfma_f32_16x16x4_f32 a[20:23], v75, v83, a[20:23]
	v_or_b32_e32 v10, 38, v30
	v_cmp_gt_i32_e64 s[14:15], s25, v10
	s_and_b64 s[6:7], s[6:7], s[14:15]
	v_cndmask_b32_e64 v10, v34, 0, s[6:7]
	v_add_u32_e32 v1, v1, v10
	buffer_store_dwordx2 v[20:21], v1, s[36:39], 0 offen offset:152
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v15, a[8:11]
	s_barrier
	ds_write_b32 v0, a0
	ds_write_b32 v0, a1 offset:128
	ds_write_b32 v0, a2 offset:256
	v_or_b32_e32 v1, 32, v31
	v_cmp_gt_i32_e64 s[6:7], s24, v1
	s_and_b64 s[8:9], s[6:7], s[8:9]
	v_add_lshl_u32 v1, v26, s16, 2
	v_cndmask_b32_e64 v14, v34, 0, s[8:9]
	v_mfma_f32_16x16x4_f32 a[20:23], v76, v84, a[20:23]
	s_and_b64 s[8:9], s[6:7], s[10:11]
	v_add_u32_e32 v18, v1, v14
	s_and_b64 s[0:1], s[6:7], s[0:1]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v11, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v16, a[8:11]
	v_mfma_f32_16x16x4_f32 a[20:23], v77, v85, a[20:23]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v12, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v17, a[8:11]
	ds_write_b32 v0, a3 offset:384
	s_nop 7
	s_nop 0
	ds_write_b32 v0, a11 offset:448
	ds_write_b32 v0, a10 offset:320
	ds_write_b32 v0, a9 offset:192
	ds_write_b32 v0, a8 offset:64
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v13, a[4:7]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[10:13], v33 offset1:1
	ds_read2_b64 v[14:17], v33 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[10:11], v18, s[36:39], 0 offen
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v6, a[20:23]
	v_mov_b32_e32 v2, 0x80000008
	v_cndmask_b32_e64 v2, v2, 8, s[8:9]
	v_add_u32_e32 v2, v1, v2
	buffer_store_dwordx2 v[12:13], v2, s[36:39], 0 offen
	v_mov_b32_e32 v2, 0x80000010
	s_and_b64 s[8:9], s[6:7], s[12:13]
	v_cndmask_b32_e64 v2, v2, 16, s[8:9]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v7, a[4:7]
	v_add_u32_e32 v2, v1, v2
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[14:15], v2, s[36:39], 0 offen
	v_mov_b32_e32 v2, 0x80000018
	s_and_b64 s[8:9], s[6:7], s[14:15]
	v_cndmask_b32_e64 v2, v2, 24, s[8:9]
	v_add_u32_e32 v1, v1, v2
	buffer_store_dwordx2 v[16:17], v1, s[36:39], 0 offen
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v8, a[4:7]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v0, a0
	ds_write_b32 v0, a1 offset:128
	ds_write_b32 v0, a2 offset:256
	ds_write_b32 v0, a3 offset:384
	s_and_b64 s[8:9], vcc, s[6:7]
	v_add_lshl_u32 v8, v32, s16, 2
	v_cndmask_b32_e64 v4, v34, 0, s[8:9]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v9, a[4:7]
	s_nop 7
	s_nop 1
	ds_write_b32 v0, a3 offset:448
	ds_write_b32 v0, a2 offset:320
	ds_write_b32 v0, a1 offset:192
	ds_write_b32 v0, a0 offset:64
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[0:3], v33 offset1:1
	v_add_u32_e32 v9, v4, v8
	ds_read2_b64 v[4:7], v33 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[0:1], v9, s[36:39], 0 offen
	v_cndmask_b32_e64 v0, v34, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	s_and_b64 s[0:1], s[6:7], s[2:3]
	buffer_store_dwordx2 v[2:3], v0, s[36:39], 0 offen offset:8
	v_cndmask_b32_e64 v0, v34, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	s_and_b64 s[0:1], s[6:7], s[4:5]
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[4:5], v0, s[36:39], 0 offen offset:16
	v_cndmask_b32_e64 v0, v34, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	buffer_store_dwordx2 v[6:7], v0, s[36:39], 0 offen offset:24
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
		.amdhsa_next_free_vgpr 132
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 100
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 98
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 32
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 48
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
	s_load_dwordx8 s[36:43], s[0:1], 0x10
	s_load_dwordx2 s[26:27], s[0:1], 0x60
	s_load_dword s9, s[0:1], 0x68
	s_load_dword s8, s[0:1], 0x3c
	s_load_dwordx4 s[4:7], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_cmp_gt_i32 s42, 1
	s_cselect_b64 s[10:11], -1, 0
	s_bitcmp1_b32 s9, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[10:11], s[10:11], s[12:13]
	s_andn2_b64 vcc, exec, s[10:11]
	s_mov_b64 s[34:35], 0
	s_cbranch_vccnz .LBB2_2
	s_mul_i32 s9, s36, s3
	s_mul_i32 s34, s9, s37
	s_ashr_i32 s35, s34, 31
.LBB2_2:
	s_load_dword s9, s[0:1], 0x34
	s_add_i32 s33, s36, -1
	s_cmp_lt_u32 s33, 64
	s_mov_b32 s43, 0
	s_cbranch_scc1 .LBB2_10
	s_add_i32 s0, s37, -1
	s_cmp_lt_u32 s0, 64
	s_mov_b32 s0, 0
	s_cbranch_scc1 .LBB2_9
	s_add_i32 s0, s36, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s11, s0, 6
	s_add_i32 s0, s37, 63
	s_ashr_i32 s1, s0, 31
	s_lshr_b32 s1, s1, 26
	s_add_i32 s0, s0, s1
	s_ashr_i32 s10, s0, 6
	s_mul_i32 s0, s10, s11
	s_add_i32 s1, s0, 7
	s_ashr_i32 s12, s1, 31
	s_lshr_b32 s12, s12, 29
	s_add_i32 s1, s1, s12
	s_ashr_i32 s12, s1, 3
	s_and_b32 s1, s1, -8
	s_sub_i32 s13, s0, s1
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 29
	s_add_i32 s15, s2, s0
	s_and_b32 s0, s15, -8
	s_add_i32 s13, s13, 8
	s_sub_i32 s14, s2, s0
	s_cmp_gt_i32 s14, s13
	s_cbranch_scc1 .LBB2_6
	s_mul_i32 s2, s12, s14
	s_ashr_i32 s0, s15, 3
	s_cbranch_execz .LBB2_7
	s_branch .LBB2_8
.LBB2_6:
	s_ashr_i32 s0, s15, 3
.LBB2_7:
	s_add_i32 s1, s12, -1
	s_mul_i32 s1, s1, s14
	s_add_i32 s2, s13, s1
.LBB2_8:
	s_abs_i32 s1, s10
	v_cvt_f32_u32_e32 v1, s1
	s_sub_i32 s13, 0, s1
	s_add_i32 s0, s2, s0
	s_abs_i32 s12, s0
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s2, s0, s10
	s_ashr_i32 s2, s2, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s14, v1
	s_mul_i32 s13, s13, s14
	s_mul_hi_u32 s13, s14, s13
	s_add_i32 s14, s14, s13
	s_mul_hi_u32 s13, s12, s14
	s_mul_i32 s14, s13, s1
	s_sub_i32 s12, s12, s14
	s_add_i32 s15, s13, 1
	s_sub_i32 s14, s12, s1
	s_cmp_ge_u32 s12, s1
	s_cselect_b32 s13, s15, s13
	s_cselect_b32 s12, s14, s12
	s_add_i32 s14, s13, 1
	s_cmp_ge_u32 s12, s1
	s_cselect_b32 s1, s14, s13
	s_xor_b32 s1, s1, s2
	s_lshr_b32 s12, s11, 30
	s_sub_i32 s1, s1, s2
	s_add_i32 s12, s11, s12
	s_mul_i32 s2, s1, s10
	s_sub_i32 s0, s0, s2
	s_and_b32 s2, s12, -4
	s_sub_i32 s11, s11, s2
	s_cmp_ge_i32 s1, s2
	s_cselect_b32 s2, s11, 4
	s_abs_i32 s12, s2
	v_cvt_f32_u32_e32 v1, s12
	s_ashr_i32 s11, s1, 31
	s_lshr_b32 s11, s11, 30
	s_add_i32 s11, s1, s11
	v_rcp_iflag_f32_e32 v1, v1
	s_and_b32 s11, s11, -4
	s_sub_i32 s11, s1, s11
	s_sub_i32 s14, 0, s12
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s10, s11, s10
	s_add_i32 s10, s10, s0
	s_abs_i32 s13, s10
	v_readfirstlane_b32 s15, v1
	s_mul_i32 s14, s14, s15
	s_mul_hi_u32 s14, s15, s14
	s_add_i32 s15, s15, s14
	s_mul_hi_u32 s14, s13, s15
	s_mul_i32 s15, s14, s12
	s_xor_b32 s0, s10, s2
	s_sub_i32 s13, s13, s15
	s_ashr_i32 s0, s0, 31
	s_add_i32 s15, s14, 1
	s_sub_i32 s16, s13, s12
	s_cmp_ge_u32 s13, s12
	s_cselect_b32 s14, s15, s14
	s_cselect_b32 s13, s16, s13
	s_add_i32 s15, s14, 1
	s_cmp_ge_u32 s13, s12
	s_cselect_b32 s12, s15, s14
	s_xor_b32 s12, s12, s0
	s_sub_i32 s0, s12, s0
	s_mul_i32 s2, s0, s2
	s_sub_i32 s2, s10, s2
	s_add_i32 s2, s2, s1
	s_sub_i32 s2, s2, s11
.LBB2_9:
	s_mov_b32 s43, s2
	s_mov_b32 s2, s0
.LBB2_10:
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s9, s3
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s28, s4, s0
	s_addc_u32 s29, s5, s1
	s_add_u32 s44, s6, s0
	s_addc_u32 s45, s7, s1
	s_add_i32 s1, s37, 0x3fffffff
	s_mul_i32 s4, s1, s40
	s_add_i32 s1, s42, -1
	s_mul_i32 s5, s1, s9
	s_sub_i32 s5, s38, s5
	s_cmp_lt_u32 s3, s1
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshrrev_b32_e32 v164, 1, v0
	s_cselect_b32 s42, s9, s5
	s_lshl_b32 s38, s2, 6
	v_and_b32_e32 v179, 12, v1
	v_and_b32_e32 v165, 0x7e, v164
	v_lshl_add_u32 v2, s43, 6, v165
	v_bitop3_b32 v180, v164, v179, 14 bitop3:0x6c
	v_lshlrev_b32_e32 v1, 6, v165
	v_add_u32_e32 v3, s38, v165
	s_ashr_i32 s1, s8, 31
	v_lshlrev_b32_e32 v163, 2, v179
	v_mul_lo_u32 v162, v2, s39
	v_lshl_or_b32 v75, v180, 2, v1
	v_mul_lo_u32 v166, v3, s40
	v_and_b32_e32 v1, 15, v0
	v_lshrrev_b32_e32 v178, 2, v0
	s_lshr_b32 s1, s1, 28
	s_mul_i32 s0, s33, s39
	v_add_u32_e32 v65, v162, v163
	v_and_b32_e32 v74, 14, v164
	v_add_u32_e32 v61, v166, v163
	v_and_or_b32 v64, v178, 48, v1
	v_and_b32_e32 v62, 12, v178
	v_bitop3_b32 v63, v178, v1, 12 bitop3:0x6c
	s_add_i32 s8, s8, s1
	s_ashr_i32 s24, s8, 4
	s_add_i32 s0, s42, s0
	s_lshl_b32 s30, s0, 2
	s_mov_b32 s31, 0x20000
	v_lshlrev_b32_e32 v60, 2, v65
	buffer_load_dwordx4 v[66:69], v60, s[28:31], 0 offen
	v_add_u32_e32 v4, 12, v65
	v_add_lshl_u32 v5, v4, s39, 2
	buffer_load_dwordx4 v[16:19], v60, s[28:31], 0 offen offset:16
	v_add_u32_e32 v6, -16, v5
	buffer_load_dwordx2 v[6:7], v6, s[28:31], 0 offen
	v_subrev_u32_e32 v8, 32, v5
	buffer_load_dwordx2 v[70:71], v8, s[28:31], 0 offen
	v_subrev_u32_e32 v8, 24, v5
	buffer_load_dwordx2 v[72:73], v8, s[28:31], 0 offen
	v_subrev_u32_e32 v8, 40, v5
	buffer_load_dwordx2 v[44:45], v8, s[28:31], 0 offen
	v_add_lshl_u32 v8, v65, s39, 2
	buffer_load_dwordx2 v[46:47], v8, s[28:31], 0 offen
	buffer_load_dwordx4 v[20:23], v60, s[28:31], 0 offen offset:32
	v_add_u32_e32 v8, -8, v5
	buffer_load_dwordx2 v[38:39], v8, s[28:31], 0 offen
	buffer_load_dwordx2 v[40:41], v60, s[28:31], 0 offen offset:56
	v_lshlrev_b32_e32 v4, 2, v4
	buffer_load_dwordx2 v[42:43], v4, s[28:31], 0 offen
	buffer_load_dwordx4 v[24:27], v5, s[28:31], 0 offen
	v_add_u32_e32 v4, 12, v61
	v_cmp_gt_i32_e32 vcc, s36, v2
	v_or_b32_e32 v2, 1, v2
	s_add_i32 s4, s42, s4
	v_add_lshl_u32 v32, v4, s40, 2
	v_or_b32_e32 v8, 2, v163
	v_or_b32_e32 v9, 6, v163
	v_or_b32_e32 v10, 4, v163
	v_or_b32_e32 v11, 8, v163
	v_or_b32_e32 v12, 10, v163
	v_or_b32_e32 v13, 14, v163
	v_or_b32_e32 v14, 12, v163
	v_cmp_gt_i32_e64 s[0:1], s37, v3
	v_lshlrev_b32_e32 v76, 2, v61
	v_or_b32_e32 v3, 1, v3
	v_add_lshl_u32 v34, v61, s40, 2
	v_cmp_gt_i32_e64 s[2:3], s36, v2
	s_lshl_b32 s46, s4, 2
	s_mov_b32 s47, s31
	v_lshlrev_b32_e32 v2, 2, v4
	v_add_u32_e32 v33, -8, v32
	v_add_u32_e32 v35, -16, v32
	v_subrev_u32_e32 v36, 32, v32
	v_subrev_u32_e32 v37, 24, v32
	v_cmp_gt_i32_e64 s[18:19], s42, v8
	v_cmp_gt_i32_e64 s[16:17], s42, v9
	v_cmp_gt_i32_e64 s[20:21], s42, v10
	v_cmp_gt_i32_e64 s[14:15], s42, v11
	v_cmp_gt_i32_e64 s[12:13], s42, v12
	v_cmp_gt_i32_e64 s[8:9], s42, v13
	v_cmp_gt_i32_e64 s[10:11], s42, v14
	v_cmp_gt_i32_e64 s[4:5], s37, v3
	buffer_load_dwordx4 v[28:31], v76, s[44:47], 0 offen
	buffer_load_dwordx4 v[12:15], v76, s[44:47], 0 offen offset:16
	buffer_load_dwordx4 v[8:11], v76, s[44:47], 0 offen offset:32
	buffer_load_dwordx2 v[54:55], v76, s[44:47], 0 offen offset:56
	buffer_load_dwordx2 v[56:57], v2, s[44:47], 0 offen
	buffer_load_dwordx4 v[2:5], v32, s[44:47], 0 offen
	v_subrev_u32_e32 v58, 40, v32
	buffer_load_dwordx2 v[32:33], v33, s[44:47], 0 offen
	buffer_load_dwordx2 v[52:53], v35, s[44:47], 0 offen
	buffer_load_dwordx2 v[50:51], v36, s[44:47], 0 offen
	buffer_load_dwordx2 v[48:49], v37, s[44:47], 0 offen
	buffer_load_dwordx2 v[36:37], v58, s[44:47], 0 offen
	buffer_load_dwordx2 v[34:35], v34, s[44:47], 0 offen
	v_cmp_gt_i32_e64 s[6:7], s42, v163
	s_and_b64 s[22:23], s[6:7], vcc
	v_bitop3_b32 v77, v74, v179, 1 bitop3:0x36
	v_sub_u32_e32 v78, v77, v180
	v_lshlrev_b32_e32 v102, 2, v75
	v_lshlrev_b32_e32 v103, 4, v78
	v_add_u32_e32 v79, v102, v103
	v_or_b32_e32 v183, 3, v179
	v_bitop3_b32 v168, v179, v74, 3 bitop3:0x36
	v_add_u32_e32 v65, 0x4c, v65
	v_or_b32_e32 v181, 1, v179
	v_or_b32_e32 v182, 2, v179
	s_movk_i32 s48, 0x4000
	s_waitcnt vmcnt(23)
	v_cndmask_b32_e64 v67, 0, v67, s[22:23]
	v_cndmask_b32_e64 v66, 0, v66, s[22:23]
	s_and_b64 s[22:23], s[18:19], vcc
	v_cndmask_b32_e64 v69, 0, v69, s[22:23]
	v_cndmask_b32_e64 v68, 0, v68, s[22:23]
	s_and_b64 s[22:23], s[20:21], vcc
	s_waitcnt vmcnt(22)
	v_cndmask_b32_e64 v59, 0, v17, s[22:23]
	v_cndmask_b32_e64 v58, 0, v16, s[22:23]
	s_and_b64 s[22:23], s[14:15], s[2:3]
	s_waitcnt vmcnt(21)
	v_cndmask_b32_e64 v17, 0, v7, s[22:23]
	v_cndmask_b32_e64 v16, 0, v6, s[22:23]
	s_and_b64 s[22:23], s[20:21], s[2:3]
	s_waitcnt vmcnt(20)
	v_cndmask_b32_e64 v71, 0, v71, s[22:23]
	v_cndmask_b32_e64 v70, 0, v70, s[22:23]
	s_and_b64 s[22:23], s[16:17], s[2:3]
	s_waitcnt vmcnt(19)
	v_cndmask_b32_e64 v73, 0, v73, s[22:23]
	v_cndmask_b32_e64 v72, 0, v72, s[22:23]
	s_and_b64 s[22:23], s[18:19], s[2:3]
	s_waitcnt vmcnt(18)
	v_cndmask_b32_e64 v45, 0, v45, s[22:23]
	v_cndmask_b32_e64 v44, 0, v44, s[22:23]
	s_and_b64 s[22:23], s[6:7], s[2:3]
	s_waitcnt vmcnt(17)
	v_cndmask_b32_e64 v47, 0, v47, s[22:23]
	v_cndmask_b32_e64 v46, 0, v46, s[22:23]
	ds_write2_b64 v102, v[66:67], v[68:69] offset1:1
	ds_write2_b64 v79, v[46:47], v[44:45] offset0:32 offset1:33
	v_bitop3_b32 v44, v74, v179, 1 bitop3:0x14
	v_sub_u32_e32 v45, v44, v77
	v_bitop3_b32 v47, v179, v74, 1 bitop3:0x36
	v_lshlrev_b32_e32 v104, 4, v45
	v_sub_u32_e32 v44, v47, v44
	s_and_b64 s[22:23], s[16:17], vcc
	v_lshl_add_u32 v67, v78, 2, v75
	v_add_u32_e32 v46, v79, v104
	v_lshlrev_b32_e32 v105, 4, v44
	v_cndmask_b32_e64 v19, 0, v19, s[22:23]
	v_cndmask_b32_e64 v18, 0, v18, s[22:23]
	v_lshl_add_u32 v45, v45, 2, v67
	v_add_u32_e32 v67, v46, v105
	s_and_b64 s[22:23], s[14:15], vcc
	ds_write2_b64 v46, v[70:71], v[72:73] offset0:32 offset1:33
	ds_write2_b64 v67, v[58:59], v[18:19] offset1:1
	v_bitop3_b32 v18, v179, v74, 2 bitop3:0x36
	s_waitcnt vmcnt(16)
	v_cndmask_b32_e64 v21, 0, v21, s[22:23]
	v_cndmask_b32_e64 v20, 0, v20, s[22:23]
	s_and_b64 s[22:23], s[12:13], vcc
	v_or_b32_e32 v66, 1, v74
	v_lshl_add_u32 v44, v44, 2, v45
	v_sub_u32_e32 v19, v18, v47
	v_cndmask_b32_e64 v23, 0, v23, s[22:23]
	v_cndmask_b32_e64 v22, 0, v22, s[22:23]
	s_and_b64 s[22:23], s[12:13], s[2:3]
	v_lshlrev_b32_e32 v106, 4, v19
	v_lshl_add_u32 v19, v19, 2, v44
	v_bitop3_b32 v44, v179, v66, 2 bitop3:0x36
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v39, 0, v39, s[22:23]
	v_cndmask_b32_e64 v38, 0, v38, s[22:23]
	s_and_b64 s[22:23], s[10:11], vcc
	v_add_u32_e32 v45, v67, v106
	v_sub_u32_e32 v18, v44, v18
	s_waitcnt vmcnt(13)
	v_cndmask_b32_e64 v43, 0, v43, s[22:23]
	v_cndmask_b32_e64 v42, 0, v42, s[22:23]
	s_and_b64 s[22:23], s[8:9], vcc
	v_lshlrev_b32_e32 v107, 4, v18
	ds_write2_b64 v45, v[20:21], v[22:23] offset1:1
	v_bitop3_b32 v20, v74, v183, 1 bitop3:0x36
	v_cndmask_b32_e64 v41, 0, v41, s[22:23]
	v_cndmask_b32_e64 v40, 0, v40, s[22:23]
	s_and_b64 s[22:23], s[10:11], s[2:3]
	v_add_u32_e32 v46, v45, v107
	v_sub_u32_e32 v21, v20, v44
	s_waitcnt vmcnt(12)
	v_cndmask_b32_e64 v25, 0, v25, s[22:23]
	v_cndmask_b32_e64 v24, 0, v24, s[22:23]
	s_and_b64 s[22:23], s[8:9], s[2:3]
	v_lshlrev_b32_e32 v18, 2, v18
	v_lshlrev_b32_e32 v22, 2, v21
	v_lshlrev_b32_e32 v108, 4, v21
	ds_write2_b64 v46, v[16:17], v[38:39] offset0:32 offset1:33
	v_sub_u32_e32 v16, v168, v20
	v_cndmask_b32_e64 v27, 0, v27, s[22:23]
	v_cndmask_b32_e64 v26, 0, v26, s[22:23]
	v_add3_u32 v167, v18, v19, v22
	v_add_u32_e32 v18, v46, v108
	v_lshlrev_b32_e32 v109, 4, v16
	s_and_b64 s[22:23], s[6:7], s[0:1]
	s_and_b64 s[6:7], s[6:7], s[4:5]
	v_add_u32_e32 v17, v18, v109
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e64 v97, 0, v35, s[6:7]
	v_cndmask_b32_e64 v96, 0, v34, s[6:7]
	s_and_b64 s[6:7], s[16:17], s[0:1]
	ds_write2_b64 v18, v[24:25], v[26:27] offset0:32 offset1:33
	v_lshlrev_b32_e32 v169, 2, v16
	ds_write2_b64 v17, v[42:43], v[40:41] offset1:1
	v_cndmask_b32_e64 v17, 0, v29, s[22:23]
	v_cndmask_b32_e64 v16, 0, v28, s[22:23]
	s_and_b64 s[22:23], s[18:19], s[0:1]
	v_cndmask_b32_e64 v15, 0, v15, s[6:7]
	v_cndmask_b32_e64 v14, 0, v14, s[6:7]
	s_and_b64 s[6:7], s[14:15], s[0:1]
	v_cndmask_b32_e64 v19, 0, v31, s[22:23]
	v_cndmask_b32_e64 v18, 0, v30, s[22:23]
	s_and_b64 s[22:23], s[20:21], s[0:1]
	s_and_b64 s[20:21], s[20:21], s[4:5]
	v_add_u32_e32 v74, 0x4c, v61
	v_cndmask_b32_e64 v99, 0, v9, s[6:7]
	v_cndmask_b32_e64 v98, 0, v8, s[6:7]
	s_and_b64 s[6:7], s[12:13], s[0:1]
	v_add_lshl_u32 v24, v65, s39, 2
	v_lshlrev_b32_e32 v6, 2, v65
	v_cndmask_b32_e64 v91, 0, v51, s[20:21]
	v_cndmask_b32_e64 v90, 0, v50, s[20:21]
	s_and_b64 s[20:21], s[16:17], s[4:5]
	v_lshlrev_b32_e32 v22, 2, v74
	s_and_b64 s[18:19], s[18:19], s[4:5]
	v_cndmask_b32_e64 v11, 0, v11, s[6:7]
	v_cndmask_b32_e64 v10, 0, v10, s[6:7]
	s_and_b64 s[6:7], s[12:13], s[4:5]
	v_add_u32_e32 v25, -8, v24
	v_add_lshl_u32 v65, v74, s40, 2
	buffer_load_dwordx2 v[6:7], v6, s[28:31], 0 offen
	v_cndmask_b32_e64 v13, 0, v13, s[22:23]
	v_cndmask_b32_e64 v12, 0, v12, s[22:23]
	s_and_b64 s[22:23], s[14:15], s[4:5]
	v_cndmask_b32_e64 v92, 0, v48, s[20:21]
	buffer_load_dwordx2 v[22:23], v22, s[44:47], 0 offen
	v_cndmask_b32_e64 v95, 0, v37, s[18:19]
	v_cndmask_b32_e64 v94, 0, v36, s[18:19]
	v_cndmask_b32_e64 v101, 0, v33, s[6:7]
	v_cndmask_b32_e64 v100, 0, v32, s[6:7]
	buffer_load_dwordx4 v[26:29], v60, s[28:31], 0 offen offset:256
	buffer_load_dwordx4 v[30:33], v60, s[28:31], 0 offen offset:272
	buffer_load_dwordx4 v[34:37], v60, s[28:31], 0 offen offset:288
	buffer_load_dwordx2 v[8:9], v60, s[28:31], 0 offen offset:312
	buffer_load_dwordx4 v[38:41], v24, s[28:31], 0 offen
	buffer_load_dwordx2 v[44:45], v25, s[28:31], 0 offen
	v_add_u32_e32 v25, -16, v24
	v_subrev_u32_e32 v46, 32, v24
	v_subrev_u32_e32 v48, 24, v24
	v_subrev_u32_e32 v50, 40, v24
	v_subrev_u32_e32 v24, 48, v24
	v_add_u32_e32 v78, -8, v65
	v_cndmask_b32_e64 v21, 0, v53, s[22:23]
	v_cndmask_b32_e64 v20, 0, v52, s[22:23]
	v_cndmask_b32_e64 v93, 0, v49, s[20:21]
	buffer_load_dwordx2 v[42:43], v25, s[28:31], 0 offen
	buffer_load_dwordx2 v[46:47], v46, s[28:31], 0 offen
	buffer_load_dwordx2 v[48:49], v48, s[28:31], 0 offen
	buffer_load_dwordx2 v[52:53], v50, s[28:31], 0 offen
	buffer_load_dwordx2 v[50:51], v24, s[28:31], 0 offen
	buffer_load_dwordx4 v[58:61], v76, s[44:47], 0 offen offset:256
	buffer_load_dwordx4 v[66:69], v76, s[44:47], 0 offen offset:272
	buffer_load_dwordx4 v[70:73], v76, s[44:47], 0 offen offset:288
	buffer_load_dwordx2 v[24:25], v76, s[44:47], 0 offen offset:312
	buffer_load_dwordx4 v[74:77], v65, s[44:47], 0 offen
	buffer_load_dwordx2 v[80:81], v78, s[44:47], 0 offen
	v_add_u32_e32 v78, -16, v65
	v_subrev_u32_e32 v82, 32, v65
	v_subrev_u32_e32 v84, 24, v65
	v_subrev_u32_e32 v86, 40, v65
	buffer_load_dwordx2 v[78:79], v78, s[44:47], 0 offen
	buffer_load_dwordx2 v[82:83], v82, s[44:47], 0 offen
	buffer_load_dwordx2 v[84:85], v84, s[44:47], 0 offen
	buffer_load_dwordx2 v[88:89], v86, s[44:47], 0 offen
	v_subrev_u32_e32 v65, 48, v65
	buffer_load_dwordx2 v[86:87], v65, s[44:47], 0 offen
	v_add_u32_e32 v65, 0x4000, v102
	v_add_u32_e32 v102, v65, v103
	s_and_b64 s[6:7], s[10:11], s[0:1]
	ds_write2_b64 v65, v[16:17], v[18:19] offset1:1
	ds_write2_b64 v102, v[96:97], v[94:95] offset0:32 offset1:33
	v_add_u32_e32 v16, v102, v104
	v_cndmask_b32_e64 v57, 0, v57, s[6:7]
	v_cndmask_b32_e64 v56, 0, v56, s[6:7]
	s_and_b64 s[6:7], s[8:9], s[0:1]
	v_add_u32_e32 v17, v16, v105
	v_cndmask_b32_e64 v55, 0, v55, s[6:7]
	v_cndmask_b32_e64 v54, 0, v54, s[6:7]
	s_and_b64 s[6:7], s[10:11], s[4:5]
	ds_write2_b64 v16, v[90:91], v[92:93] offset0:32 offset1:33
	ds_write2_b64 v17, v[12:13], v[14:15] offset1:1
	v_add_u32_e32 v12, v17, v106
	v_cndmask_b32_e64 v3, 0, v3, s[6:7]
	v_cndmask_b32_e64 v2, 0, v2, s[6:7]
	s_and_b64 s[6:7], s[8:9], s[4:5]
	v_add_u32_e32 v13, v12, v107
	v_cndmask_b32_e64 v5, 0, v5, s[6:7]
	v_cndmask_b32_e64 v4, 0, v4, s[6:7]
	ds_write2_b64 v12, v[98:99], v[10:11] offset1:1
	v_add_u32_e32 v10, v13, v108
	ds_write2_b64 v13, v[20:21], v[100:101] offset0:32 offset1:33
	v_add_u32_e32 v11, v10, v109
	ds_write2_b64 v10, v[2:3], v[4:5] offset0:32 offset1:33
	ds_write2_b64 v11, v[56:57], v[54:55] offset1:1
	v_lshlrev_b32_e32 v2, 4, v63
	v_lshl_or_b32 v184, v64, 8, v2
	v_lshl_or_b32 v10, v1, 8, v2
	v_bitop3_b32 v2, v62, v1, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v63
	v_or_b32_e32 v185, 0x4000, v10
	v_lshlrev_b32_e32 v2, 4, v2
	v_add_u32_e32 v186, v184, v2
	v_add_u32_e32 v187, v2, v10
	v_add_u32_e32 v188, v185, v2
	v_bitop3_b32 v2, v62, v1, 2 bitop3:0x36
	v_sub_u32_e32 v2, v2, v63
	v_lshlrev_b32_e32 v2, 4, v2
	v_add_u32_e32 v189, v184, v2
	v_add_u32_e32 v190, v2, v10
	v_add_u32_e32 v191, v185, v2
	v_bitop3_b32 v2, v62, v1, 3 bitop3:0x36
	v_sub_u32_e32 v2, v2, v63
	v_lshlrev_b32_e32 v11, 4, v2
	v_add_u32_e32 v192, v184, v11
	v_add_u32_e32 v193, v11, v10
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[154:157], v184
	ds_read_b128 v[114:117], v184 offset:8192
	ds_read_b128 v[158:161], v10 offset:16384
	ds_read_b128 v[150:153], v10 offset:20480
	ds_read_b128 v[146:149], v10 offset:24576
	ds_read_b128 v[142:145], v10 offset:28672
	ds_read_b128 v[110:113], v186
	ds_read_b128 v[98:101], v186 offset:8192
	ds_read_b128 v[126:129], v187 offset:16384
	ds_read_b128 v[122:125], v188 offset:4096
	ds_read_b128 v[130:133], v188 offset:8192
	ds_read_b128 v[134:137], v188 offset:12288
	ds_read_b128 v[106:109], v189
	ds_read_b128 v[90:93], v189 offset:8192
	ds_read_b128 v[138:141], v190 offset:16384
	ds_read_b128 v[118:121], v191 offset:4096
	ds_read_b128 v[102:105], v191 offset:8192
	ds_read_b128 v[94:97], v191 offset:12288
	ds_read_b128 v[62:65], v192
	ds_read_b128 v[2:5], v192 offset:8192
	v_add_u32_e32 v194, v185, v11
	ds_read_b128 v[14:17], v193 offset:16384
	ds_read_b128 v[10:13], v194 offset:4096
	ds_read_b128 v[54:57], v194 offset:8192
	ds_read_b128 v[18:21], v194 offset:12288
	v_sub_u32_e32 v168, v180, v168
	v_lshlrev_b32_e32 v168, 2, v168
	v_add3_u32 v207, v167, v169, v168
	v_or_b32_e32 v195, 1, v164
	s_max_i32 s6, s24, 2
	v_sub_u32_e32 v164, v195, v165
	v_or_b32_e32 v198, 64, v163
	v_and_b32_e32 v163, 3, v0
	v_lshlrev_b32_e32 v196, 6, v164
	v_add_u32_e32 v197, -1, v164
	v_lshlrev_b32_e32 v199, 6, v163
	v_add_lshl_u32 v200, v166, s40, 2
	v_lshlrev_b32_e32 v201, 2, v166
	v_add_lshl_u32 v202, v162, s39, 2
	v_lshlrev_b32_e32 v203, 2, v162
	s_add_i32 s39, s6, -1
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	v_accvgpr_write_b32 a19, 0
	v_accvgpr_write_b32 a18, 0
	v_accvgpr_write_b32 a17, 0
	v_accvgpr_write_b32 a16, 0
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
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
	v_not_b32_e32 v204, 63
	v_mov_b32_e32 v205, 0x4000
	v_mov_b32_e32 v206, v207
.LBB2_11:
	v_add_u32_e32 v162, 2, v198
	v_cmp_gt_i32_e64 s[6:7], s42, v198
	v_cmp_gt_i32_e64 s[8:9], s42, v162
	v_add_u32_e32 v208, v199, v203
	s_and_b64 s[10:11], vcc, s[6:7]
	s_and_b64 s[12:13], vcc, s[8:9]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v175, 0, v27, s[10:11]
	v_cndmask_b32_e64 v174, 0, v26, s[10:11]
	v_cndmask_b32_e64 v177, 0, v29, s[12:13]
	v_cndmask_b32_e64 v176, 0, v28, s[12:13]
	buffer_load_dwordx4 v[26:29], v208, s[28:31], 0 offen offset:512
	v_mfma_f32_16x16x4_f32 a[28:31], v154, v158, a[28:31]
	v_add_u32_e32 v162, 6, v198
	v_add_u32_e32 v163, 4, v198
	v_cmp_gt_i32_e64 s[10:11], s42, v163
	v_cmp_gt_i32_e64 s[12:13], s42, v162
	s_and_b64 s[14:15], vcc, s[10:11]
	s_and_b64 s[16:17], vcc, s[12:13]
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v165, 0, v31, s[14:15]
	v_mfma_f32_16x16x4_f32 a[28:31], v155, v159, a[28:31]
	v_cndmask_b32_e64 v164, 0, v30, s[14:15]
	v_cndmask_b32_e64 v169, 0, v33, s[16:17]
	v_cndmask_b32_e64 v168, 0, v32, s[16:17]
	v_add_u32_e32 v162, 8, v198
	v_add_u32_e32 v163, 10, v198
	v_cmp_gt_i32_e64 s[14:15], s42, v162
	v_cmp_gt_i32_e64 s[16:17], s42, v163
	v_mfma_f32_16x16x4_f32 a[28:31], v156, v160, a[28:31]
	buffer_load_dwordx4 v[30:33], v208, s[28:31], 0 offen offset:528
	s_and_b64 s[18:19], vcc, s[14:15]
	s_and_b64 s[20:21], vcc, s[16:17]
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v171, 0, v35, s[18:19]
	v_cndmask_b32_e64 v170, 0, v34, s[18:19]
	v_cndmask_b32_e64 v173, 0, v37, s[20:21]
	v_cndmask_b32_e64 v172, 0, v36, s[20:21]
	v_mfma_f32_16x16x4_f32 a[24:27], v154, v150, a[24:27]
	v_add_u32_e32 v162, 14, v198
	v_add_u32_e32 v163, 12, v198
	v_cmp_gt_i32_e64 s[18:19], s42, v163
	v_cmp_gt_i32_e64 s[20:21], s42, v162
	s_and_b64 s[22:23], vcc, s[18:19]
	s_and_b64 s[24:25], vcc, s[20:21]
	s_waitcnt vmcnt(14)
	v_cndmask_b32_e64 v163, 0, v7, s[22:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v155, v151, a[24:27]
	v_cndmask_b32_e64 v162, 0, v6, s[22:23]
	s_waitcnt vmcnt(20)
	v_cndmask_b32_e64 v167, 0, v9, s[24:25]
	v_cndmask_b32_e64 v166, 0, v8, s[24:25]
	v_add_u32_e32 v216, v199, v202
	s_and_b64 s[22:23], s[2:3], s[6:7]
	s_and_b64 s[24:25], s[2:3], s[8:9]
	s_waitcnt vmcnt(13)
	v_cndmask_b32_e64 v209, 0, v51, s[22:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v157, v161, a[28:31]
	buffer_load_dwordx4 v[34:37], v208, s[28:31], 0 offen offset:544
	v_cndmask_b32_e64 v211, 0, v53, s[24:25]
	v_cndmask_b32_e64 v210, 0, v52, s[24:25]
	s_and_b64 s[24:25], s[2:3], s[12:13]
	s_waitcnt vmcnt(13)
	v_cndmask_b32_e64 v213, 0, v49, s[24:25]
	v_cndmask_b32_e64 v212, 0, v48, s[24:25]
	s_and_b64 s[24:25], s[2:3], s[16:17]
	v_mfma_f32_16x16x4_f32 a[20:23], v154, v146, a[20:23]
	v_add_u32_e32 v218, v199, v201
	v_add_u32_e32 v232, v199, v200
	v_mfma_f32_16x16x4_f32 a[24:27], v156, v152, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v157, v153, a[24:27]
	buffer_load_dwordx4 v[6:9], v208, s[28:31], 0 offen offset:560
	v_cndmask_b32_e64 v208, 0, v50, s[22:23]
	s_and_b64 s[22:23], s[2:3], s[10:11]
	v_mfma_f32_16x16x4_f32 a[20:23], v155, v147, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v156, v148, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v157, v149, a[20:23]
	buffer_load_dwordx4 v[50:53], v216, s[28:31], 0 offen offset:512
	v_mfma_f32_16x16x4_f32 a[8:11], v154, v142, a[8:11]
	v_cndmask_b32_e64 v154, 0, v46, s[22:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v155, v143, a[8:11]
	v_cndmask_b32_e64 v155, 0, v47, s[22:23]
	s_and_b64 s[22:23], s[2:3], s[14:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v156, v144, a[8:11]
	buffer_load_dwordx4 v[46:49], v216, s[28:31], 0 offen offset:528
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v156, 0, v44, s[24:25]
	v_mfma_f32_16x16x4_f32 a[16:19], v114, v158, a[16:19]
	v_cndmask_b32_e64 v158, 0, v42, s[22:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v115, v159, a[16:19]
	v_cndmask_b32_e64 v159, 0, v43, s[22:23]
	s_and_b64 s[22:23], s[2:3], s[18:19]
	v_mfma_f32_16x16x4_f32 a[8:11], v157, v145, a[8:11]
	v_cndmask_b32_e64 v157, 0, v45, s[24:25]
	buffer_load_dwordx4 v[42:45], v216, s[28:31], 0 offen offset:544
	s_and_b64 s[24:25], s[2:3], s[20:21]
	s_waitcnt vmcnt(15)
	v_cndmask_b32_e64 v215, 0, v41, s[24:25]
	v_cndmask_b32_e64 v214, 0, v40, s[24:25]
	s_and_b64 s[24:25], s[0:1], s[8:9]
	s_and_b64 s[8:9], s[4:5], s[8:9]
	v_mfma_f32_16x16x4_f32 a[12:15], v114, v150, a[12:15]
	s_waitcnt vmcnt(8)
	v_cndmask_b32_e64 v219, 0, v89, s[8:9]
	v_mfma_f32_16x16x4_f32 a[16:19], v116, v160, a[16:19]
	v_cndmask_b32_e64 v160, 0, v38, s[22:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v117, v161, a[16:19]
	v_cndmask_b32_e64 v161, 0, v39, s[22:23]
	buffer_load_dwordx4 v[38:41], v216, s[28:31], 0 offen offset:560
	s_and_b64 s[22:23], s[0:1], s[6:7]
	v_cndmask_b32_e64 v150, 0, v58, s[22:23]
	s_and_b64 s[6:7], s[4:5], s[6:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v115, v151, a[12:15]
	v_cndmask_b32_e64 v151, 0, v59, s[22:23]
	s_and_b64 s[22:23], s[0:1], s[10:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v116, v152, a[12:15]
	v_cndmask_b32_e64 v152, 0, v60, s[24:25]
	v_mfma_f32_16x16x4_f32 a[12:15], v117, v153, a[12:15]
	v_cndmask_b32_e64 v153, 0, v61, s[24:25]
	buffer_load_dwordx4 v[58:61], v218, s[44:47], 0 offen offset:512
	s_and_b64 s[24:25], s[0:1], s[12:13]
	v_cndmask_b32_e64 v217, 0, v69, s[24:25]
	v_cndmask_b32_e64 v216, 0, v68, s[24:25]
	s_and_b64 s[24:25], s[0:1], s[16:17]
	v_mfma_f32_16x16x4_f32 a[4:7], v114, v146, a[4:7]
	v_cndmask_b32_e64 v146, 0, v66, s[22:23]
	v_mfma_f32_16x16x4_f32 a[4:7], v115, v147, a[4:7]
	v_cndmask_b32_e64 v147, 0, v67, s[22:23]
	s_and_b64 s[22:23], s[0:1], s[14:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v116, v148, a[4:7]
	buffer_load_dwordx4 v[66:69], v218, s[44:47], 0 offen offset:528
	s_waitcnt vmcnt(10)
	v_cndmask_b32_e64 v148, 0, v86, s[6:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v114, v142, a[0:3]
	v_cndmask_b32_e64 v114, 0, v70, s[22:23]
	v_cndmask_b32_e64 v142, 0, v72, s[24:25]
	v_mfma_f32_16x16x4_f32 a[0:3], v115, v143, a[0:3]
	v_cndmask_b32_e64 v115, 0, v71, s[22:23]
	v_cndmask_b32_e64 v143, 0, v73, s[24:25]
	s_and_b64 s[22:23], s[0:1], s[18:19]
	s_and_b64 s[24:25], s[0:1], s[20:21]
	v_mfma_f32_16x16x4_f32 a[4:7], v117, v149, a[4:7]
	buffer_load_dwordx4 v[70:73], v218, s[44:47], 0 offen offset:544
	v_cndmask_b32_e64 v149, 0, v87, s[6:7]
	s_and_b64 s[6:7], s[4:5], s[10:11]
	v_cndmask_b32_e64 v221, 0, v83, s[6:7]
	v_cndmask_b32_e64 v220, 0, v82, s[6:7]
	s_and_b64 s[6:7], s[4:5], s[14:15]
	v_cndmask_b32_e64 v227, 0, v79, s[6:7]
	v_mfma_f32_16x16x4_f32 a[28:31], v110, v126, a[28:31]
	v_cndmask_b32_e64 v226, 0, v78, s[6:7]
	s_and_b64 s[6:7], s[4:5], s[18:19]
	v_cndmask_b32_e64 v229, 0, v75, s[6:7]
	v_cndmask_b32_e64 v228, 0, v74, s[6:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v116, v144, a[0:3]
	v_cndmask_b32_e64 v116, 0, v22, s[22:23]
	v_cndmask_b32_e64 v144, 0, v24, s[24:25]
	v_mfma_f32_16x16x4_f32 a[0:3], v117, v145, a[0:3]
	v_cndmask_b32_e64 v117, 0, v23, s[22:23]
	v_cndmask_b32_e64 v145, 0, v25, s[24:25]
	buffer_load_dwordx4 v[22:25], v218, s[44:47], 0 offen offset:560
	v_cndmask_b32_e64 v218, 0, v88, s[8:9]
	s_and_b64 s[8:9], s[4:5], s[12:13]
	v_cndmask_b32_e64 v223, 0, v85, s[8:9]
	v_cndmask_b32_e64 v222, 0, v84, s[8:9]
	v_mfma_f32_16x16x4_f32 a[28:31], v111, v127, a[28:31]
	s_and_b64 s[8:9], s[4:5], s[16:17]
	v_cndmask_b32_e64 v225, 0, v81, s[8:9]
	v_cndmask_b32_e64 v224, 0, v80, s[8:9]
	s_and_b64 s[8:9], s[4:5], s[20:21]
	v_cndmask_b32_e64 v231, 0, v77, s[8:9]
	v_cndmask_b32_e64 v230, 0, v76, s[8:9]
	v_mfma_f32_16x16x4_f32 a[28:31], v112, v128, a[28:31]
	v_mfma_f32_16x16x4_f32 a[28:31], v113, v129, a[28:31]
	buffer_load_dwordx4 v[86:89], v232, s[44:47], 0 offen offset:512
	v_mfma_f32_16x16x4_f32 a[24:27], v110, v122, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v111, v123, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v112, v124, a[24:27]
	buffer_load_dwordx4 v[82:85], v232, s[44:47], 0 offen offset:528
	v_mfma_f32_16x16x4_f32 a[20:23], v110, v130, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v111, v131, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v113, v125, a[24:27]
	buffer_load_dwordx4 v[78:81], v232, s[44:47], 0 offen offset:544
	v_mfma_f32_16x16x4_f32 a[8:11], v110, v134, a[8:11]
	v_mfma_f32_16x16x4_f32 a[20:23], v112, v132, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v113, v133, a[20:23]
	buffer_load_dwordx4 v[74:77], v232, s[44:47], 0 offen offset:560
	v_mfma_f32_16x16x4_f32 a[8:11], v111, v135, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v112, v136, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v113, v137, a[8:11]
	v_mfma_f32_16x16x4_f32 a[16:19], v98, v126, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v99, v127, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v100, v128, a[16:19]
	v_mfma_f32_16x16x4_f32 a[12:15], v98, v122, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v99, v123, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v101, v129, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v98, v130, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v100, v124, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v101, v125, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v99, v131, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v100, v132, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v101, v133, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v98, v134, a[0:3]
	v_lshlrev_b32_e32 v98, 2, v206
	ds_write2_b64 v98, v[174:175], v[176:177] offset1:1
	v_mfma_f32_16x16x4_f32 a[0:3], v99, v135, a[0:3]
	v_ashrrev_i32_e32 v99, 31, v195
	v_lshrrev_b32_e32 v99, 28, v99
	v_add_u32_e32 v99, v195, v99
	v_and_b32_e32 v99, -16, v99
	v_sub_u32_e32 v99, v195, v99
	v_mfma_f32_16x16x4_f32 a[0:3], v100, v136, a[0:3]
	v_add_u32_e32 v100, -1, v195
	v_mfma_f32_16x16x4_f32 a[28:31], v106, v138, a[28:31]
	v_mfma_f32_16x16x4_f32 a[28:31], v107, v139, a[28:31]
	v_mfma_f32_16x16x4_f32 a[0:3], v101, v137, a[0:3]
	v_lshlrev_b32_e32 v101, 2, v207
	v_mfma_f32_16x16x4_f32 a[24:27], v106, v118, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v108, v140, a[28:31]
	v_mfma_f32_16x16x4_f32 a[28:31], v109, v141, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v107, v119, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v108, v120, a[24:27]
	v_mfma_f32_16x16x4_f32 a[24:27], v109, v121, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v106, v102, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v107, v103, a[20:23]
	v_mfma_f32_16x16x4_f32 a[20:23], v108, v104, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v106, v94, a[8:11]
	v_add_u32_e32 v106, 0x4000, v101
	v_mfma_f32_16x16x4_f32 a[8:11], v107, v95, a[8:11]
	v_xor_b32_e32 v107, v99, v179
	v_mfma_f32_16x16x4_f32 a[20:23], v109, v105, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v90, v138, a[16:19]
	v_mfma_f32_16x16x4_f32 a[8:11], v108, v96, a[8:11]
	v_xor_b32_e32 v108, v99, v181
	v_mfma_f32_16x16x4_f32 a[8:11], v109, v97, a[8:11]
	v_mfma_f32_16x16x4_f32 a[16:19], v91, v139, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v92, v140, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v93, v141, a[16:19]
	v_mfma_f32_16x16x4_f32 a[12:15], v90, v118, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v91, v119, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v92, v120, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v90, v102, a[4:7]
	v_ashrrev_i32_e32 v102, 31, v100
	v_lshrrev_b32_e32 v102, 28, v102
	v_add_u32_e32 v102, v100, v102
	v_and_b32_e32 v102, -16, v102
	v_sub_u32_e32 v174, v100, v102
	v_sub_u32_e32 v102, v107, v180
	v_xor_b32_e32 v100, v99, v182
	v_mfma_f32_16x16x4_f32 a[4:7], v91, v103, a[4:7]
	v_xor_b32_e32 v99, v99, v183
	v_sub_u32_e32 v103, v108, v107
	v_xor_b32_e32 v107, v174, v181
	v_xor_b32_e32 v176, v174, v183
	v_lshl_add_u32 v177, v102, 2, v196
	v_sub_u32_e32 v175, v99, v100
	v_lshlrev_b32_e32 v232, 2, v103
	v_mfma_f32_16x16x4_f32 a[12:15], v93, v121, a[12:15]
	v_sub_u32_e32 v99, v176, v99
	v_xor_b32_e32 v109, v174, v182
	v_lshl_add_u32 v236, v99, 2, v204
	v_add_u32_e32 v99, v177, v207
	v_sub_u32_e32 v233, v109, v107
	v_sub_u32_e32 v100, v100, v109
	v_lshl_add_u32 v235, v100, 2, 64
	v_mfma_f32_16x16x4_f32 a[0:3], v90, v94, a[0:3]
	v_lshlrev_b32_e32 v90, 4, v103
	v_sub_u32_e32 v94, v107, v108
	v_lshlrev_b32_e32 v103, 2, v177
	v_lshl_add_u32 v234, v94, 2, v204
	v_add_u32_e32 v98, v98, v103
	v_add3_u32 v207, v99, v232, v234
	ds_write2_b64 v98, v[208:209], v[210:211] offset1:1
	v_mfma_f32_16x16x4_f32 a[4:7], v92, v104, a[4:7]
	v_add_u32_e32 v98, v98, v90
	v_lshlrev_b32_e32 v94, 4, v233
	v_lshlrev_b32_e32 v100, 2, v235
	ds_write2_b64 v98, v[154:155], v[212:213] offset1:1
	v_lshlrev_b32_e32 v102, 4, v175
	v_lshlrev_b32_e32 v104, 2, v236
	v_add_u32_e32 v101, v103, v101
	v_mfma_f32_16x16x4_f32 a[4:7], v93, v105, a[4:7]
	v_add_u32_e32 v99, 0x4000, v101
	v_add3_u32 v90, v101, v90, s48
	v_xor_b32_e32 v180, v174, v179
	v_mfma_f32_16x16x4_f32 a[0:3], v91, v95, a[0:3]
	v_lshl_add_u32 v91, v207, 2, v205
	v_lshl_add_u32 v95, v234, 2, v98
	v_add_u32_e32 v98, v91, v94
	v_add_u32_e32 v94, v95, v94
	ds_write2_b64 v94, v[170:171], v[172:173] offset1:1
	v_add_u32_e32 v94, v94, v100
	ds_write2_b64 v95, v[164:165], v[168:169] offset1:1
	v_mfma_f32_16x16x4_f32 a[0:3], v92, v96, a[0:3]
	v_add_u32_e32 v92, v98, v100
	v_add_u32_e32 v95, v92, v102
	ds_write2_b64 v94, v[158:159], v[156:157] offset1:1
	v_add_u32_e32 v94, v94, v102
	v_add_u32_e32 v96, v95, v104
	ds_write2_b64 v94, v[160:161], v[214:215] offset1:1
	v_add_u32_e32 v94, v94, v104
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v54, a[4:7]
	ds_write2_b64 v94, v[162:163], v[166:167] offset1:1
	ds_write2_b64 v106, v[150:151], v[152:153] offset1:1
	ds_write2_b64 v99, v[148:149], v[218:219] offset1:1
	ds_write2_b64 v90, v[220:221], v[222:223] offset1:1
	ds_write2_b64 v91, v[146:147], v[216:217] offset1:1
	ds_write2_b64 v98, v[114:115], v[142:143] offset1:1
	ds_write2_b64 v92, v[226:227], v[224:225] offset1:1
	ds_write2_b64 v95, v[228:229], v[230:231] offset1:1
	ds_write2_b64 v96, v[116:117], v[144:145] offset1:1
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[154:157], v184
	v_mfma_f32_16x16x4_f32 a[0:3], v93, v97, a[0:3]
	ds_read_b128 v[114:117], v184 offset:8192
	v_lshlrev_b32_e32 v163, 2, v233
	v_lshlrev_b32_e32 v162, 2, v175
	v_mfma_f32_16x16x4_f32 a[28:31], v62, v14, a[28:31]
	ds_read_b128 v[158:161], v185
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v55, a[4:7]
	ds_read_b128 v[150:153], v185 offset:4096
	v_mfma_f32_16x16x4_f32 a[28:31], v63, v15, a[28:31]
	ds_read_b128 v[146:149], v185 offset:8192
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v56, a[4:7]
	ds_read_b128 v[142:145], v185 offset:12288
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v18, a[0:3]
	ds_read_b128 v[110:113], v186
	v_mfma_f32_16x16x4_f32 a[28:31], v64, v16, a[28:31]
	ds_read_b128 v[98:101], v186 offset:8192
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v57, a[4:7]
	ds_read_b128 v[126:129], v187 offset:16384
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v19, a[0:3]
	ds_read_b128 v[122:125], v188 offset:4096
	v_mfma_f32_16x16x4_f32 a[28:31], v65, v17, a[28:31]
	ds_read_b128 v[130:133], v188 offset:8192
	v_mfma_f32_16x16x4_f32 a[24:27], v62, v10, a[24:27]
	ds_read_b128 v[134:137], v188 offset:12288
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v20, a[0:3]
	ds_read_b128 v[106:109], v189
	v_mfma_f32_16x16x4_f32 a[24:27], v63, v11, a[24:27]
	ds_read_b128 v[90:93], v189 offset:8192
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v21, a[0:3]
	ds_read_b128 v[138:141], v190 offset:16384
	v_mfma_f32_16x16x4_f32 a[24:27], v64, v12, a[24:27]
	ds_read_b128 v[118:121], v191 offset:4096
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v14, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v65, v13, a[24:27]
	ds_read_b128 v[102:105], v191 offset:8192
	v_mfma_f32_16x16x4_f32 a[20:23], v62, v54, a[20:23]
	ds_read_b128 v[94:97], v191 offset:12288
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v15, a[16:19]
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v10, a[12:15]
	v_sub_u32_e32 v2, v180, v176
	v_lshlrev_b32_e32 v164, 2, v2
	v_mfma_f32_16x16x4_f32 a[20:23], v63, v55, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v16, a[16:19]
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v11, a[12:15]
	v_add3_u32 v3, v206, v177, v232
	v_add3_u32 v2, v3, v234, v163
	v_add3_u32 v165, v2, v235, v162
	v_add_u32_e32 v163, v207, v163
	v_add3_u32 v162, v163, v235, v162
	v_add3_u32 v206, v165, v236, v164
	v_add3_u32 v207, v162, v236, v164
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v17, a[16:19]
	ds_read_b128 v[14:17], v193 offset:16384
	v_mfma_f32_16x16x4_f32 a[20:23], v64, v56, a[20:23]
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v12, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v13, a[12:15]
	ds_read_b128 v[10:13], v194 offset:4096
	v_mfma_f32_16x16x4_f32 a[20:23], v65, v57, a[20:23]
	ds_read_b128 v[54:57], v194 offset:8192
	v_mfma_f32_16x16x4_f32 a[8:11], v62, v18, a[8:11]
	ds_read_b128 v[2:5], v192 offset:8192
	v_mfma_f32_16x16x4_f32 a[8:11], v63, v19, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v64, v20, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v65, v21, a[8:11]
	ds_read_b128 v[18:21], v194 offset:12288
	ds_read_b128 v[62:65], v192
	s_add_i32 s39, s39, -1
	v_add_u32_e32 v195, v195, v197
	v_add_u32_e32 v198, 64, v198
	v_add_u32_e32 v200, 0x100, v200
	v_add_u32_e32 v201, 0x100, v201
	v_add_u32_e32 v202, 0x100, v202
	s_cmp_lg_u32 s39, 0
	v_add_u32_e32 v203, 0x100, v203
	s_cbranch_scc1 .LBB2_11
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[28:31], v154, v158, a[28:31]
	s_lshl_b64 s[0:1], s[34:35], 2
	s_waitcnt vmcnt(12)
	v_lshrrev_b32_e32 v6, 7, v0
	v_bfe_u32 v7, v0, 2, 5
	v_lshlrev_b32_e32 v0, 3, v0
	s_add_u32 s16, s26, s0
	v_and_b32_e32 v8, 24, v0
	v_add_u32_e32 v9, s43, v6
	v_mfma_f32_16x16x4_f32 a[24:27], v154, v150, a[24:27]
	s_addc_u32 s17, s27, s1
	s_mul_i32 s0, s33, s41
	s_mul_hi_u32 s1, 0, s41
	v_or_b32_e32 v0, s38, v8
	v_lshl_or_b32 v28, v9, 6, v7
	s_add_i32 s2, s1, s0
	v_mad_u64_u32 v[26:27], s[0:1], v28, s41, v[0:1]
	v_mfma_f32_16x16x4_f32 a[28:31], v155, v159, a[28:31]
	v_lshlrev_b32_e32 v9, 7, v178
	v_lshlrev_b32_e32 v1, 2, v1
	s_movk_i32 s0, 0xe00
	v_lshlrev_b32_e32 v7, 7, v7
	v_lshlrev_b32_e32 v6, 12, v6
	v_lshlrev_b32_e32 v8, 2, v8
	v_and_or_b32 v1, v9, s0, v1
	v_mfma_f32_16x16x4_f32 a[24:27], v155, v151, a[24:27]
	v_or3_b32 v27, v7, v6, v8
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_cmp_gt_i32_e32 vcc, s37, v0
	v_cmp_gt_i32_e64 s[6:7], s36, v28
	s_add_i32 s0, s37, s2
	s_lshl_b32 s18, s0, 2
	v_mfma_f32_16x16x4_f32 a[28:31], v156, v160, a[28:31]
	v_bfrev_b32_e32 v29, 1
	s_and_b64 s[0:1], s[6:7], vcc
	s_waitcnt vmcnt(4)
	v_cndmask_b32_e64 v22, v29, 0, s[0:1]
	s_mov_b32 s19, 0x20000
	s_lshl_b32 s20, s41, 5
	v_mfma_f32_16x16x4_f32 a[24:27], v156, v152, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v154, v146, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v154, v142, a[8:11]
	v_mfma_f32_16x16x4_f32 a[28:31], v157, v161, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v157, v153, a[24:27]
	v_mfma_f32_16x16x4_f32 a[20:23], v155, v147, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v155, v143, a[8:11]
	v_mfma_f32_16x16x4_f32 a[28:31], v110, v126, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v110, v122, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v114, v158, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v156, v148, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v156, v144, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v114, v146, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v114, v142, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v111, v127, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v111, v123, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v115, v159, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v157, v149, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v157, v145, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v115, v147, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v115, v143, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v112, v128, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v112, v124, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v116, v160, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v110, v130, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v110, v134, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v116, v148, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v116, v144, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v113, v129, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v113, v125, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v117, v161, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v111, v131, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v111, v135, a[8:11]
	v_mfma_f32_16x16x4_f32 a[4:7], v117, v149, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v117, v145, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v106, v138, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v106, v118, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v98, v126, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v112, v132, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v112, v136, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v114, v150, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v98, v130, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v98, v134, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v107, v139, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v107, v119, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v99, v127, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v113, v133, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v113, v137, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v115, v151, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v99, v131, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v99, v135, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v108, v140, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v108, v120, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v100, v128, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v106, v102, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v106, v94, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v116, v152, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v100, v132, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v100, v136, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v109, v141, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v109, v121, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v101, v129, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v107, v103, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v107, v95, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v117, v153, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v101, v133, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v101, v137, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v62, v14, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v62, v10, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v90, v138, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v108, v104, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v108, v96, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v98, v122, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v90, v102, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v90, v94, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v63, v15, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v63, v11, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v91, v139, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v109, v105, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v109, v97, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v99, v123, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v91, v103, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v91, v95, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v64, v16, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v64, v12, a[24:27]
	v_mfma_f32_16x16x4_f32 a[16:19], v92, v140, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v62, v54, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v62, v18, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v100, v124, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v92, v104, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v92, v96, a[0:3]
	v_mfma_f32_16x16x4_f32 a[28:31], v65, v17, a[28:31]
	v_mfma_f32_16x16x4_f32 a[24:27], v65, v13, a[24:27]
	s_nop 7
	s_nop 0
	ds_write_b32 v1, a28
	ds_write_b32 v1, a29 offset:128
	ds_write_b32 v1, a30 offset:256
	ds_write_b32 v1, a31 offset:384
	ds_write_b32 v1, a27 offset:448
	ds_write_b32 v1, a26 offset:320
	ds_write_b32 v1, a25 offset:192
	ds_write_b32 v1, a24 offset:64
	v_mfma_f32_16x16x4_f32 a[16:19], v93, v141, a[16:19]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[6:9], v27 offset1:1
	v_mfma_f32_16x16x4_f32 a[20:23], v63, v55, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v63, v19, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v101, v125, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v93, v105, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v93, v97, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v14, a[16:19]
	v_lshlrev_b32_e32 v14, 2, v26
	v_add_u32_e32 v30, v22, v14
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[6:7], v30, s[16:19], 0 offen
	v_or_b32_e32 v6, 2, v0
	v_cmp_gt_i32_e64 s[0:1], s37, v6
	s_and_b64 s[2:3], s[6:7], s[0:1]
	v_cndmask_b32_e64 v6, v29, 0, s[2:3]
	v_mfma_f32_16x16x4_f32 a[20:23], v64, v56, a[20:23]
	v_add_u32_e32 v6, v14, v6
	ds_read2_b64 v[22:25], v27 offset0:2 offset1:3
	buffer_store_dwordx2 v[8:9], v6, s[16:19], 0 offen offset:8
	v_or_b32_e32 v6, 4, v0
	v_cmp_gt_i32_e64 s[2:3], s37, v6
	s_and_b64 s[4:5], s[6:7], s[2:3]
	v_cndmask_b32_e64 v6, v29, 0, s[4:5]
	v_mfma_f32_16x16x4_f32 a[8:11], v64, v20, a[8:11]
	v_add_u32_e32 v6, v14, v6
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[22:23], v6, s[16:19], 0 offen offset:16
	v_or_b32_e32 v6, 6, v0
	v_cmp_gt_i32_e64 s[4:5], s37, v6
	s_and_b64 s[8:9], s[6:7], s[4:5]
	v_cndmask_b32_e64 v6, v29, 0, s[8:9]
	v_add_u32_e32 v6, v14, v6
	v_mfma_f32_16x16x4_f32 a[12:15], v90, v118, a[12:15]
	buffer_store_dwordx2 v[24:25], v6, s[16:19], 0 offen offset:24
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v54, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v18, a[0:3]
	v_mfma_f32_16x16x4_f32 a[20:23], v65, v57, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v65, v21, a[8:11]
	s_nop 7
	s_nop 0
	ds_write_b32 v1, a20
	ds_write_b32 v1, a21 offset:128
	ds_write_b32 v1, a22 offset:256
	ds_write_b32 v1, a23 offset:384
	ds_write_b32 v1, a11 offset:448
	ds_write_b32 v1, a10 offset:320
	ds_write_b32 v1, a9 offset:192
	ds_write_b32 v1, a8 offset:64
	v_mfma_f32_16x16x4_f32 a[12:15], v91, v119, a[12:15]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[6:9], v27 offset1:1
	ds_read2_b64 v[22:25], v27 offset0:2 offset1:3
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v55, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v19, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v15, a[16:19]
	v_or_b32_e32 v15, 32, v0
	v_cmp_gt_i32_e64 s[8:9], s37, v15
	s_and_b64 s[10:11], s[6:7], s[8:9]
	v_cndmask_b32_e64 v15, v29, 0, s[10:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v92, v120, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v56, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v20, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v16, a[16:19]
	v_add_u32_e32 v16, 32, v26
	v_lshl_add_u32 v15, v16, 2, v15
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[6:7], v15, s[16:19], 0 offen
	v_or_b32_e32 v6, 34, v0
	v_cmp_gt_i32_e64 s[10:11], s37, v6
	s_and_b64 s[12:13], s[6:7], s[10:11]
	v_cndmask_b32_e64 v6, v29, 0, s[12:13]
	v_mfma_f32_16x16x4_f32 a[12:15], v93, v121, a[12:15]
	v_add_u32_e32 v6, v14, v6
	buffer_store_dwordx2 v[8:9], v6, s[16:19], 0 offen offset:136
	v_or_b32_e32 v6, 36, v0
	v_cmp_gt_i32_e64 s[12:13], s37, v6
	s_and_b64 s[14:15], s[6:7], s[12:13]
	v_or_b32_e32 v0, 38, v0
	v_cndmask_b32_e64 v6, v29, 0, s[14:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v57, a[4:7]
	v_cmp_gt_i32_e64 s[14:15], s37, v0
	s_and_b64 s[6:7], s[6:7], s[14:15]
	v_cndmask_b32_e64 v0, v29, 0, s[6:7]
	v_add_u32_e32 v6, v14, v6
	v_add_u32_e32 v0, v14, v0
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[22:23], v6, s[16:19], 0 offen offset:144
	buffer_store_dwordx2 v[24:25], v0, s[16:19], 0 offen offset:152
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v21, a[0:3]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v1, a4
	ds_write_b32 v1, a5 offset:128
	ds_write_b32 v1, a6 offset:256
	ds_write_b32 v1, a7 offset:384
	s_nop 3
	ds_write_b32 v1, a3 offset:448
	ds_write_b32 v1, a2 offset:320
	ds_write_b32 v1, a1 offset:192
	ds_write_b32 v1, a0 offset:64
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v10, a[12:15]
	v_or_b32_e32 v0, 32, v28
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[6:9], v27 offset1:1
	v_cmp_gt_i32_e64 s[6:7], s36, v0
	s_and_b64 s[8:9], s[6:7], s[8:9]
	v_add_lshl_u32 v0, v16, s20, 2
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v11, a[4:7]
	v_cndmask_b32_e64 v14, v29, 0, s[8:9]
	v_mov_b32_e32 v2, 0x80000008
	s_and_b64 s[8:9], s[6:7], s[10:11]
	v_add_u32_e32 v18, v0, v14
	v_cndmask_b32_e64 v2, v2, 8, s[8:9]
	v_add_u32_e32 v2, v0, v2
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[6:7], v18, s[16:19], 0 offen
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v17, a[16:19]
	ds_read2_b64 v[14:17], v27 offset0:2 offset1:3
	buffer_store_dwordx2 v[8:9], v2, s[16:19], 0 offen
	v_mov_b32_e32 v2, 0x80000010
	s_and_b64 s[8:9], s[6:7], s[12:13]
	v_cndmask_b32_e64 v2, v2, 16, s[8:9]
	v_add_u32_e32 v2, v0, v2
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[14:15], v2, s[16:19], 0 offen
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v12, a[4:7]
	v_mov_b32_e32 v2, 0x80000018
	s_and_b64 s[8:9], s[6:7], s[14:15]
	v_cndmask_b32_e64 v2, v2, 24, s[8:9]
	v_add_u32_e32 v0, v0, v2
	buffer_store_dwordx2 v[16:17], v0, s[16:19], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v1, a0
	ds_write_b32 v1, a1 offset:128
	ds_write_b32 v1, a2 offset:256
	ds_write_b32 v1, a3 offset:384
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v13, a[4:7]
	s_nop 7
	s_nop 1
	ds_write_b32 v1, a3 offset:448
	ds_write_b32 v1, a2 offset:320
	ds_write_b32 v1, a1 offset:192
	ds_write_b32 v1, a0 offset:64
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[0:3], v27 offset1:1
	s_and_b64 s[8:9], vcc, s[6:7]
	v_add_lshl_u32 v8, v26, s20, 2
	v_cndmask_b32_e64 v4, v29, 0, s[8:9]
	v_add_u32_e32 v9, v4, v8
	ds_read2_b64 v[4:7], v27 offset0:2 offset1:3
	s_and_b64 s[0:1], s[6:7], s[0:1]
	s_waitcnt lgkmcnt(1)
	buffer_store_dwordx2 v[0:1], v9, s[16:19], 0 offen
	v_cndmask_b32_e64 v0, v29, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	s_and_b64 s[0:1], s[6:7], s[2:3]
	buffer_store_dwordx2 v[2:3], v0, s[16:19], 0 offen offset:8
	v_cndmask_b32_e64 v0, v29, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	s_and_b64 s[0:1], s[6:7], s[4:5]
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx2 v[4:5], v0, s[16:19], 0 offen offset:16
	v_cndmask_b32_e64 v0, v29, 0, s[0:1]
	v_add_u32_e32 v0, v8, v0
	buffer_store_dwordx2 v[6:7], v0, s[16:19], 0 offen offset:24
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
		.amdhsa_next_free_vgpr 272
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 240
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end2:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end2-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 237
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 32
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 49
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_699d6262548d1ca6,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_699d6262548d1ca6
__hip_cuid_699d6262548d1ca6:
	.byte	0
	.size	__hip_cuid_699d6262548d1ca6, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_699d6262548d1ca6
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
  - .agpr_count:     32
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb0ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     132
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     32
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     55
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_S8_LNS6_6device18GemmSpecializationE7ELi128ELi64ELi64ELi64ELi4ELi4ELi16ELi16ELi2ELi4ENS_8SequenceIJLi4ELi32ELi1EEEENSB_IJLi1ELi0ELi2EEEESD_Li2ELi2ELi2ELb0ELi0ESC_SD_SD_Li2ELi2ELi2ELb0ELi0ELi1ELi2ENSB_IJLi1ELi32ELi1ELi4EEEELi2ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     272
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
