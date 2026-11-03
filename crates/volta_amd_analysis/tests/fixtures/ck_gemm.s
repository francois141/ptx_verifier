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
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_d04cc9e31697e651,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_d04cc9e31697e651
__hip_cuid_d04cc9e31697e651:
	.byte	0
	.size	__hip_cuid_d04cc9e31697e651, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_d04cc9e31697e651
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
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
