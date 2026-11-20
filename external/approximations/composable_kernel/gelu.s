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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
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
	s_lshl_b32 s14, s2, 8
	v_lshl_or_b32 v10, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v122, s22, 6, v1
	v_or_b32_e32 v150, s14, v3
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v122, s15
	v_mul_lo_u32 v152, v150, s16
	s_ashr_i32 s2, s20, 31
	v_add_u32_e32 v6, v154, v2
	v_add_u32_e32 v8, v152, v2
	v_lshl_or_b32 v9, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_lshr_b32 s2, s2, 29
	s_mul_i32 s6, s19, s15
	s_mul_i32 s7, s7, s16
	v_and_b32_e32 v7, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v82, 6, v2
	v_bitop3_b32 v83, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v84, v126, v124
	s_add_i32 s20, s20, s2
	s_ashr_i32 s18, s20, 3
	s_add_i32 s2, s21, s6
	s_lshl_b32 s2, s2, 2
	s_mov_b32 s3, 0x20000
	v_lshlrev_b32_e32 v2, 2, v6
	v_add_lshl_u32 v11, v6, s15, 2
	s_add_i32 s21, s21, s7
	buffer_load_dwordx4 v[2:5], v2, s[0:3], 0 offen
	buffer_load_dwordx4 v[42:45], v11, s[0:3], 0 offen
	s_lshl_b32 s6, s21, 2
	s_mov_b32 s7, s3
	v_lshlrev_b32_e32 v11, 2, v8
	v_add_u32_e32 v8, s16, v8
	v_lshlrev_b32_e32 v12, 2, v8
	buffer_load_dwordx4 v[46:49], v11, s[4:7], 0 offen
	buffer_load_dwordx4 v[54:57], v12, s[4:7], 0 offen
	v_add_u32_e32 v8, s16, v8
	v_lshlrev_b32_e32 v11, 2, v8
	buffer_load_dwordx4 v[58:61], v11, s[4:7], 0 offen
	v_add_u32_e32 v8, s16, v8
	v_lshlrev_b32_e32 v11, 2, v8
	v_add_u32_e32 v8, s16, v8
	v_lshlrev_b32_e32 v12, 2, v8
	v_add_u32_e32 v8, s16, v8
	buffer_load_dwordx4 v[62:65], v11, s[4:7], 0 offen
	buffer_load_dwordx4 v[66:69], v12, s[4:7], 0 offen
	v_lshlrev_b32_e32 v13, 2, v8
	v_add_u32_e32 v8, s16, v8
	buffer_load_dwordx4 v[70:73], v13, s[4:7], 0 offen
	v_lshlrev_b32_e32 v13, 2, v8
	buffer_load_dwordx4 v[74:77], v13, s[4:7], 0 offen
	v_add_u32_e32 v13, s16, v8
	v_lshlrev_b32_e32 v8, 2, v13
	v_bitop3_b32 v7, v7, v127, 1 bitop3:0x36
	buffer_load_dwordx4 v[78:81], v8, s[4:7], 0 offen
	v_sub_u32_e32 v12, v7, v155
	v_sub_u32_e32 v7, v155, v7
	v_add_u32_e32 v6, 32, v6
	s_mul_i32 s20, s16, -7
	v_bitop3_b32 v11, v0, 1, 7 bitop3:0x6c
	v_bitop3_b32 v87, v0, 2, 7 bitop3:0x6c
	v_lshlrev_b32_e32 v14, 2, v12
	v_lshlrev_b32_e32 v15, 2, v7
	v_lshlrev_b32_e32 v85, 2, v10
	v_sub_u32_e32 v8, v11, v127
	v_sub_u32_e32 v88, v87, v11
	v_lshlrev_b32_e32 v11, 2, v6
	v_add_lshl_u32 v6, v6, s15, 2
	v_add3_u32 v156, v14, v10, v15
	v_add3_u32 v10, s20, 32, v13
	v_lshlrev_b32_e32 v86, 2, v9
	v_lshl_add_u32 v90, v8, 2, v9
	v_lshlrev_b32_e32 v138, 4, v8
	buffer_load_dwordx4 v[50:53], v11, s[0:3], 0 offen
	buffer_load_dwordx4 v[6:9], v6, s[0:3], 0 offen
	v_lshlrev_b32_e32 v11, 2, v10
	v_add_u32_e32 v10, s16, v10
	v_add_u32_e32 v18, s16, v10
	v_lshlrev_b32_e32 v19, 2, v18
	v_add_u32_e32 v18, s16, v18
	v_add_u32_e32 v26, s16, v18
	v_lshlrev_b32_e32 v27, 2, v26
	v_add_u32_e32 v26, s16, v26
	v_add_u32_e32 v34, s16, v26
	v_lshl_add_u32 v89, v12, 4, v85
	v_lshlrev_b32_e32 v12, 2, v10
	v_lshlrev_b32_e32 v20, 2, v18
	v_lshlrev_b32_e32 v30, 2, v26
	v_lshlrev_b32_e32 v35, 2, v34
	v_add_lshl_u32 v38, v34, s16, 2
	buffer_load_dwordx4 v[14:17], v11, s[4:7], 0 offen
	buffer_load_dwordx4 v[10:13], v12, s[4:7], 0 offen
	buffer_load_dwordx4 v[22:25], v19, s[4:7], 0 offen
	buffer_load_dwordx4 v[18:21], v20, s[4:7], 0 offen
	buffer_load_dwordx4 v[26:29], v27, s[4:7], 0 offen
	buffer_load_dwordx4 v[30:33], v30, s[4:7], 0 offen
	buffer_load_dwordx4 v[34:37], v35, s[4:7], 0 offen
	buffer_load_dwordx4 v[38:41], v38, s[4:7], 0 offen
	s_movk_i32 s21, 0x2000
	v_add3_u32 v91, v86, s21, v138
	v_lshlrev_b32_e32 v139, 4, v88
	s_movk_i32 s20, 0x80
	v_mov_b32_e32 v136, 0xffffff20
	s_waitcnt vmcnt(19)
	ds_write_b128 v85, v[2:5]
	s_waitcnt vmcnt(18)
	ds_write_b128 v89, v[42:45] offset:128
	s_waitcnt vmcnt(17)
	ds_write_b128 v86, v[46:49] offset:8192
	s_waitcnt vmcnt(16)
	ds_write_b128 v91, v[54:57] offset:128
	v_bitop3_b32 v3, v0, 3, 7 bitop3:0x6c
	v_sub_u32_e32 v4, v3, v87
	v_bitop3_b32 v42, v0, 4, 7 bitop3:0x6c
	v_bitop3_b32 v44, v0, 5, 7 bitop3:0x6c
	v_lshlrev_b32_e32 v2, 2, v88
	v_lshlrev_b32_e32 v5, 2, v4
	v_sub_u32_e32 v3, v42, v3
	v_sub_u32_e32 v42, v44, v42
	v_add3_u32 v2, v90, v2, v5
	v_add3_u32 v5, v91, s20, v139
	v_lshlrev_b32_e32 v43, 2, v3
	v_lshlrev_b32_e32 v45, 2, v42
	v_lshlrev_b32_e32 v140, 4, v4
	s_waitcnt vmcnt(15)
	ds_write_b128 v5, v[58:61] offset:128
	v_add3_u32 v2, v2, v43, v45
	v_add3_u32 v4, v5, s20, v140
	v_bitop3_b32 v5, v0, 6, 7 bitop3:0x6c
	v_bitop3_b32 v45, v0, 7, v0 bitop3:0xc
	v_sub_u32_e32 v43, v5, v44
	v_sub_u32_e32 v5, v45, v5
	v_lshlrev_b32_e32 v44, 2, v43
	v_lshlrev_b32_e32 v46, 2, v5
	v_lshlrev_b32_e32 v141, 4, v3
	v_add3_u32 v133, v2, v44, v46
	v_add3_u32 v2, v4, s20, v141
	v_lshlrev_b32_e32 v142, 4, v42
	s_waitcnt vmcnt(14)
	ds_write_b128 v4, v[62:65] offset:128
	s_waitcnt vmcnt(13)
	ds_write_b128 v2, v[66:69] offset:128
	v_add3_u32 v2, v2, s20, v142
	v_lshlrev_b32_e32 v143, 4, v43
	s_waitcnt vmcnt(12)
	ds_write_b128 v2, v[70:73] offset:128
	v_add3_u32 v2, v2, s20, v143
	v_lshlrev_b32_e32 v3, 4, v5
	s_waitcnt vmcnt(11)
	ds_write_b128 v2, v[74:77] offset:128
	v_add3_u32 v135, v2, s20, v3
	v_lshlrev_b32_e32 v2, 7, v124
	v_lshlrev_b32_e32 v3, 11, v125
	v_lshlrev_b32_e32 v4, 4, v83
	v_or3_b32 v128, v3, v2, v4
	v_bitop3_b32 v2, v82, v127, 1 bitop3:0x36
	v_sub_u32_e32 v2, v2, v83
	v_lshl_or_b32 v42, v84, 7, v4
	v_lshlrev_b32_e32 v43, 4, v2
	v_or_b32_e32 v129, 0x2000, v42
	v_add_u32_e32 v130, v128, v43
	v_add_u32_e32 v131, v43, v42
	v_sub_u32_e32 v134, v127, v45
	s_waitcnt vmcnt(10)
	ds_write_b128 v135, v[78:81] offset:128
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[106:109], v128
	ds_read_b128 v[58:61], v128 offset:4096
	ds_read_b128 v[114:117], v42 offset:8192
	ds_read_b128 v[118:121], v42 offset:12288
	ds_read_b128 v[98:101], v42 offset:16384
	ds_read_b128 v[110:113], v42 offset:20480
	ds_read_b128 v[90:93], v42 offset:24576
	ds_read_b128 v[94:97], v42 offset:28672
	ds_read_b128 v[102:105], v42 offset:32768
	ds_read_b128 v[86:89], v42 offset:36864
	ds_read_b128 v[66:69], v130
	ds_read_b128 v[2:5], v130 offset:4096
	v_add_u32_e32 v132, v129, v43
	ds_read_b128 v[78:81], v131 offset:8192
	ds_read_b128 v[70:73], v132 offset:4096
	ds_read_b128 v[62:65], v132 offset:8192
	ds_read_b128 v[54:57], v132 offset:12288
	ds_read_b128 v[42:45], v132 offset:16384
	ds_read_b128 v[46:49], v132 offset:20480
	ds_read_b128 v[82:85], v132 offset:24576
	ds_read_b128 v[74:77], v132 offset:28672
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
	s_add_i32 s15, s18, -1
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a19, 0
	v_accvgpr_write_b32 a18, 0
	v_accvgpr_write_b32 a17, 0
	v_accvgpr_write_b32 a16, 0
	v_accvgpr_write_b32 a63, 0
	v_accvgpr_write_b32 a62, 0
	v_accvgpr_write_b32 a61, 0
	v_accvgpr_write_b32 a60, 0
	v_accvgpr_write_b32 a55, 0
	v_accvgpr_write_b32 a54, 0
	v_accvgpr_write_b32 a53, 0
	v_accvgpr_write_b32 a52, 0
	v_accvgpr_write_b32 a51, 0
	v_accvgpr_write_b32 a50, 0
	v_accvgpr_write_b32 a49, 0
	v_accvgpr_write_b32 a48, 0
	v_accvgpr_write_b32 a39, 0
	v_accvgpr_write_b32 a38, 0
	v_accvgpr_write_b32 a37, 0
	v_accvgpr_write_b32 a36, 0
	v_accvgpr_write_b32 a43, 0
	v_accvgpr_write_b32 a42, 0
	v_accvgpr_write_b32 a41, 0
	v_accvgpr_write_b32 a40, 0
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
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	v_accvgpr_write_b32 a27, 0
	v_accvgpr_write_b32 a26, 0
	v_accvgpr_write_b32 a25, 0
	v_accvgpr_write_b32 a24, 0
	v_accvgpr_write_b32 a47, 0
	v_accvgpr_write_b32 a46, 0
	v_accvgpr_write_b32 a45, 0
	v_accvgpr_write_b32 a44, 0
	v_accvgpr_write_b32 a59, 0
	v_accvgpr_write_b32 a58, 0
	v_accvgpr_write_b32 a57, 0
	v_accvgpr_write_b32 a56, 0
	s_movk_i32 s16, 0xffe0
.LBB1_11:
	v_lshlrev_b32_e32 v157, 2, v156
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(9)
	ds_write_b128 v157, v[50:53]
	v_add_u32_e32 v50, v144, v154
	v_mfma_f32_16x16x4_f32 a[60:63], v106, v114, a[60:63]
	buffer_load_dwordx4 v[50:53], v50, s[0:3], 0 offen
	v_ashrrev_i32_e32 v157, 31, v134
	v_lshrrev_b32_e32 v157, 29, v157
	v_add_u32_e32 v157, v134, v157
	v_and_b32_e32 v157, -8, v157
	v_sub_u32_e32 v157, v134, v157
	v_xor_b32_e32 v157, v157, v127
	v_mfma_f32_16x16x4_f32 a[52:55], v106, v118, a[52:55]
	v_sub_u32_e32 v155, v157, v155
	v_lshlrev_b32_e32 v155, 2, v155
	v_add3_u32 v156, v156, v135, v155
	v_lshlrev_b32_e32 v155, 2, v156
	v_mfma_f32_16x16x4_f32 a[60:63], v107, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v107, v119, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v106, v98, a[48:51]
	v_mfma_f32_16x16x4_f32 a[60:63], v108, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v108, v120, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v107, v99, a[48:51]
	v_mfma_f32_16x16x4_f32 a[60:63], v109, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v109, v121, a[52:55]
	s_waitcnt vmcnt(9)
	ds_write_b128 v155, v[6:9]
	v_add_u32_e32 v6, v144, v153
	v_mfma_f32_16x16x4_f32 a[48:51], v108, v100, a[48:51]
	buffer_load_dwordx4 v[6:9], v6, s[0:3], 0 offen
	v_mfma_f32_16x16x4_f32 a[36:39], v106, v110, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v106, v90, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v107, v111, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v107, v91, a[40:43]
	v_mfma_f32_16x16x4_f32 a[36:39], v108, v112, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v108, v92, a[40:43]
	v_mfma_f32_16x16x4_f32 a[48:51], v109, v101, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v109, v113, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v109, v93, a[40:43]
	s_waitcnt vmcnt(9)
	ds_write_b128 v136, v[14:17]
	v_add_u32_e32 v14, v144, v152
	v_mfma_f32_16x16x4_f32 a[28:31], v106, v94, a[28:31]
	buffer_load_dwordx4 v[14:17], v14, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[32:35], v106, v102, a[32:35]
	v_mfma_f32_16x16x4_f32 a[28:31], v107, v95, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v107, v103, a[32:35]
	v_mfma_f32_16x16x4_f32 a[20:23], v106, v86, a[20:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v108, v96, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v108, v104, a[32:35]
	v_mfma_f32_16x16x4_f32 a[20:23], v107, v87, a[20:23]
	v_mfma_f32_16x16x4_f32 a[28:31], v109, v97, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v109, v105, a[32:35]
	s_waitcnt vmcnt(9)
	ds_write_b128 v137, v[10:13]
	v_add_u32_e32 v10, v144, v151
	v_mfma_f32_16x16x4_f32 a[20:23], v108, v88, a[20:23]
	buffer_load_dwordx4 v[10:13], v10, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v114, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v58, v118, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v115, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v59, v119, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v116, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v60, v120, a[12:15]
	v_mfma_f32_16x16x4_f32 a[20:23], v109, v89, a[20:23]
	v_mfma_f32_16x16x4_f32 a[8:11], v61, v117, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v61, v121, a[12:15]
	s_waitcnt vmcnt(9)
	ds_write_b128 v138, v[22:25]
	v_add_u32_e32 v22, v144, v150
	v_mfma_f32_16x16x4_f32 a[24:27], v58, v98, a[24:27]
	buffer_load_dwordx4 v[22:25], v22, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[44:47], v58, v110, a[44:47]
	v_mfma_f32_16x16x4_f32 a[24:27], v59, v99, a[24:27]
	v_mfma_f32_16x16x4_f32 a[44:47], v59, v111, a[44:47]
	v_mfma_f32_16x16x4_f32 a[56:59], v58, v90, a[56:59]
	v_mfma_f32_16x16x4_f32 a[24:27], v60, v100, a[24:27]
	v_mfma_f32_16x16x4_f32 a[44:47], v60, v112, a[44:47]
	v_mfma_f32_16x16x4_f32 a[56:59], v59, v91, a[56:59]
	v_mfma_f32_16x16x4_f32 a[24:27], v61, v101, a[24:27]
	v_mfma_f32_16x16x4_f32 a[44:47], v61, v113, a[44:47]
	s_waitcnt vmcnt(9)
	ds_write_b128 v139, v[18:21]
	v_add_u32_e32 v18, v144, v149
	v_mfma_f32_16x16x4_f32 a[56:59], v60, v92, a[56:59]
	buffer_load_dwordx4 v[18:21], v18, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[16:19], v58, v94, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v58, v102, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v59, v95, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v59, v103, a[4:7]
	v_mfma_f32_16x16x4_f32 a[16:19], v60, v96, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v60, v104, a[4:7]
	v_mfma_f32_16x16x4_f32 a[56:59], v61, v93, a[56:59]
	v_mfma_f32_16x16x4_f32 a[16:19], v61, v97, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v61, v105, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v140, v[26:29]
	v_add_u32_e32 v26, v144, v148
	v_mfma_f32_16x16x4_f32 a[0:3], v58, v86, a[0:3]
	buffer_load_dwordx4 v[26:29], v26, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[60:63], v66, v78, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v66, v70, a[52:55]
	v_mfma_f32_16x16x4_f32 a[0:3], v59, v87, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v82, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v67, v79, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v67, v71, a[52:55]
	v_mfma_f32_16x16x4_f32 a[0:3], v60, v88, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v83, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v68, v80, a[60:63]
	s_waitcnt vmcnt(9)
	ds_write_b128 v141, v[30:33]
	v_add_u32_e32 v30, v144, v147
	v_mfma_f32_16x16x4_f32 a[0:3], v61, v89, a[0:3]
	buffer_load_dwordx4 v[30:33], v30, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[52:55], v68, v72, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v66, v62, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v66, v54, a[36:39]
	v_mfma_f32_16x16x4_f32 a[4:7], v4, v84, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v69, v81, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v69, v73, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v67, v63, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v67, v55, a[36:39]
	v_mfma_f32_16x16x4_f32 a[4:7], v5, v85, a[4:7]
	s_waitcnt vmcnt(9)
	ds_write_b128 v142, v[34:37] offset:128
	v_add_u32_e32 v34, v144, v146
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v74, a[0:3]
	buffer_load_dwordx4 v[34:37], v34, s[4:7], 0 offen
	v_mfma_f32_16x16x4_f32 a[48:51], v68, v64, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v68, v56, a[36:39]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v75, a[0:3]
	v_mfma_f32_16x16x4_f32 a[40:43], v66, v42, a[40:43]
	v_mfma_f32_16x16x4_f32 a[28:31], v66, v46, a[28:31]
	v_mfma_f32_16x16x4_f32 a[48:51], v69, v65, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v69, v57, a[36:39]
	v_mfma_f32_16x16x4_f32 a[32:35], v66, v82, a[32:35]
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v76, a[0:3]
	s_waitcnt vmcnt(9)
	ds_write_b128 v133, v[38:41]
	v_add_u32_e32 v38, v144, v145
	v_mfma_f32_16x16x4_f32 a[40:43], v67, v43, a[40:43]
	buffer_load_dwordx4 v[38:41], v38, s[4:7], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[28:31], v67, v47, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v67, v83, a[32:35]
	v_mfma_f32_16x16x4_f32 a[40:43], v68, v44, a[40:43]
	v_mfma_f32_16x16x4_f32 a[28:31], v68, v48, a[28:31]
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v77, a[0:3]
	v_mfma_f32_16x16x4_f32 a[40:43], v69, v45, a[40:43]
	v_mfma_f32_16x16x4_f32 a[28:31], v69, v49, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v68, v84, a[32:35]
	v_mfma_f32_16x16x4_f32 a[20:23], v66, v74, a[20:23]
	ds_read_b128 v[106:109], v128
	v_mfma_f32_16x16x4_f32 a[8:11], v2, v78, a[8:11]
	ds_read_b128 v[58:61], v128 offset:4096
	v_mfma_f32_16x16x4_f32 a[32:35], v69, v85, a[32:35]
	ds_read_b128 v[114:117], v129
	v_mfma_f32_16x16x4_f32 a[20:23], v67, v75, a[20:23]
	ds_read_b128 v[118:121], v129 offset:4096
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v79, a[8:11]
	ds_read_b128 v[98:101], v129 offset:8192
	v_mfma_f32_16x16x4_f32 a[20:23], v68, v76, a[20:23]
	ds_read_b128 v[110:113], v129 offset:12288
	v_mfma_f32_16x16x4_f32 a[8:11], v4, v80, a[8:11]
	ds_read_b128 v[90:93], v129 offset:16384
	v_mfma_f32_16x16x4_f32 a[20:23], v69, v77, a[20:23]
	ds_read_b128 v[94:97], v129 offset:20480
	v_mfma_f32_16x16x4_f32 a[8:11], v5, v81, a[8:11]
	ds_read_b128 v[102:105], v129 offset:24576
	v_mfma_f32_16x16x4_f32 a[12:15], v2, v70, a[12:15]
	ds_read_b128 v[86:89], v129 offset:28672
	v_mfma_f32_16x16x4_f32 a[12:15], v3, v71, a[12:15]
	ds_read_b128 v[66:69], v130
	v_mfma_f32_16x16x4_f32 a[12:15], v4, v72, a[12:15]
	ds_read_b128 v[78:81], v131 offset:8192
	v_mfma_f32_16x16x4_f32 a[56:59], v2, v42, a[56:59]
	v_mfma_f32_16x16x4_f32 a[12:15], v5, v73, a[12:15]
	ds_read_b128 v[70:73], v132 offset:4096
	v_mfma_f32_16x16x4_f32 a[24:27], v2, v62, a[24:27]
	ds_read_b128 v[82:85], v132 offset:24576
	v_mfma_f32_16x16x4_f32 a[56:59], v3, v43, a[56:59]
	v_mfma_f32_16x16x4_f32 a[24:27], v3, v63, a[24:27]
	v_mfma_f32_16x16x4_f32 a[56:59], v4, v44, a[56:59]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v46, a[16:19]
	v_mfma_f32_16x16x4_f32 a[56:59], v5, v45, a[56:59]
	ds_read_b128 v[42:45], v132 offset:16384
	v_mfma_f32_16x16x4_f32 a[24:27], v4, v64, a[24:27]
	ds_read_b128 v[74:77], v132 offset:28672
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v47, a[16:19]
	v_mfma_f32_16x16x4_f32 a[24:27], v5, v65, a[24:27]
	ds_read_b128 v[62:65], v132 offset:8192
	v_mfma_f32_16x16x4_f32 a[44:47], v2, v54, a[44:47]
	v_add_u32_e32 v2, -1, v134
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v48, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v49, a[16:19]
	ds_read_b128 v[46:49], v132 offset:20480
	v_mfma_f32_16x16x4_f32 a[44:47], v3, v55, a[44:47]
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	v_and_b32_e32 v3, -8, v3
	v_sub_u32_e32 v155, v2, v3
	v_xor_b32_e32 v155, v155, v127
	v_sub_u32_e32 v157, v155, v157
	v_mfma_f32_16x16x4_f32 a[44:47], v4, v56, a[44:47]
	v_lshlrev_b32_e32 v157, 2, v157
	v_add3_u32 v156, v157, v156, s16
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v57, a[44:47]
	ds_read_b128 v[2:5], v130 offset:4096
	ds_read_b128 v[54:57], v132 offset:12288
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
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v114, a[8:11]
	s_waitcnt vmcnt(8)
	v_and_b32_e32 v7, 12, v123
	v_lshlrev_b32_e32 v0, 4, v0
	v_and_b32_e32 v6, 0x70, v0
	v_lshlrev_b32_e32 v0, 13, v125
	v_lshlrev_b32_e32 v7, 9, v7
	v_lshlrev_b32_e32 v8, 2, v126
	v_or3_b32 v0, v0, v7, v8
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v115, a[8:11]
	s_waitcnt vmcnt(0)
	v_lshl_add_u32 v40, v124, 2, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_lshlrev_b32_e32 v0, 2, v6
	v_lshl_or_b32 v37, v1, 9, v0
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v116, a[8:11]
	v_mfma_f32_16x16x4_f32 a[64:67], v61, v117, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v118, a[12:15]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v119, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v120, a[8:11]
	v_mfma_f32_16x16x4_f32 a[68:71], v61, v121, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v98, a[24:27]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v99, a[8:11]
	v_mfma_f32_16x16x4_f32 a[60:63], v106, v114, a[60:63]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v100, a[8:11]
	v_mfma_f32_16x16x4_f32 a[60:63], v107, v115, a[60:63]
	v_mfma_f32_16x16x4_f32 a[24:27], v61, v101, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v110, a[44:47]
	v_mfma_f32_16x16x4_f32 a[0:3], v58, v86, a[0:3]
	v_mfma_f32_16x16x4_f32 a[60:63], v108, v116, a[60:63]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v111, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v59, v87, a[0:3]
	v_mfma_f32_16x16x4_f32 a[60:63], v109, v117, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v106, v118, a[52:55]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v112, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v60, v88, a[0:3]
	v_mfma_f32_16x16x4_f32 a[52:55], v107, v119, a[52:55]
	v_mfma_f32_16x16x4_f32 a[44:47], v61, v113, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v90, a[56:59]
	v_mfma_f32_16x16x4_f32 a[80:83], v61, v89, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v78, a[60:63]
	v_mfma_f32_16x16x4_f32 a[52:55], v108, v120, a[52:55]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v91, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v79, a[0:3]
	v_mfma_f32_16x16x4_f32 a[52:55], v109, v121, a[52:55]
	v_mfma_f32_16x16x4_f32 a[48:51], v106, v98, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v106, v94, a[28:31]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v92, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v80, a[0:3]
	v_mfma_f32_16x16x4_f32 a[48:51], v107, v99, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v107, v95, a[28:31]
	v_mfma_f32_16x16x4_f32 a[56:59], v61, v93, a[8:11]
	v_mfma_f32_16x16x4_f32 a[8:11], v58, v94, a[16:19]
	v_mfma_f32_16x16x4_f32 a[4:7], v58, v102, a[4:7]
	v_mfma_f32_16x16x4_f32 a[60:63], v69, v81, a[0:3]
	s_nop 7
	s_nop 1
	ds_write_b32 v40, a60
	ds_write_b32 v40, a61 offset:512
	ds_write_b32 v40, a62 offset:1024
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v70, a[52:55]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v78, a[64:67]
	v_mfma_f32_16x16x4_f32 a[48:51], v108, v100, a[48:51]
	v_mfma_f32_16x16x4_f32 a[28:31], v108, v96, a[28:31]
	v_mfma_f32_16x16x4_f32 a[4:7], v59, v103, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v71, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v79, a[16:19]
	v_mfma_f32_16x16x4_f32 a[48:51], v109, v101, a[48:51]
	v_mfma_f32_16x16x4_f32 a[36:39], v106, v110, a[36:39]
	v_mfma_f32_16x16x4_f32 a[28:31], v109, v97, a[28:31]
	v_mfma_f32_16x16x4_f32 a[32:35], v106, v102, a[32:35]
	v_mfma_f32_16x16x4_f32 a[4:7], v60, v104, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v72, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v80, a[16:19]
	v_mfma_f32_16x16x4_f32 a[36:39], v107, v111, a[36:39]
	v_mfma_f32_16x16x4_f32 a[32:35], v107, v103, a[32:35]
	v_mfma_f32_16x16x4_f32 a[76:79], v61, v105, a[4:7]
	v_mfma_f32_16x16x4_f32 a[52:55], v69, v73, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v62, a[48:51]
	v_mfma_f32_16x16x4_f32 a[4:7], v66, v46, a[28:31]
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v81, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v70, a[68:71]
	v_mfma_f32_16x16x4_f32 a[36:39], v108, v112, a[36:39]
	v_mfma_f32_16x16x4_f32 a[32:35], v108, v104, a[32:35]
	v_mfma_f32_16x16x4_f32 a[8:11], v59, v95, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v63, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v71, a[16:19]
	v_mfma_f32_16x16x4_f32 a[36:39], v109, v113, a[36:39]
	v_mfma_f32_16x16x4_f32 a[40:43], v106, v90, a[40:43]
	v_mfma_f32_16x16x4_f32 a[32:35], v109, v105, a[32:35]
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v96, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v64, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v72, a[16:19]
	v_mfma_f32_16x16x4_f32 a[40:43], v107, v91, a[40:43]
	v_mfma_f32_16x16x4_f32 a[72:75], v61, v97, a[8:11]
	v_mfma_f32_16x16x4_f32 a[48:51], v69, v65, a[0:3]
	ds_write_b32 v40, a63 offset:1536
	ds_write_b32 v40, a55 offset:1664
	ds_write_b32 v40, a54 offset:1152
	ds_write_b32 v40, a53 offset:640
	ds_write_b32 v40, a52 offset:128
	s_nop 4
	ds_write_b32 v40, a48 offset:256
	ds_write_b32 v40, a49 offset:768
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v54, a[36:39]
	v_mfma_f32_16x16x4_f32 a[8:11], v66, v82, a[32:35]
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v73, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v62, a[24:27]
	v_mfma_f32_16x16x4_f32 a[40:43], v108, v92, a[40:43]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v55, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v63, a[16:19]
	v_mfma_f32_16x16x4_f32 a[40:43], v109, v93, a[40:43]
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v56, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v64, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v106, v86, a[20:23]
	v_mfma_f32_16x16x4_f32 a[36:39], v69, v57, a[0:3]
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v42, a[40:43]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v65, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v54, a[44:47]
	v_mfma_f32_16x16x4_f32 a[20:23], v107, v87, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v55, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v108, v88, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v56, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v109, v89, a[20:23]
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v57, a[16:19]
	ds_write_b32 v40, a50 offset:1280
	ds_write_b32 v40, a51 offset:1792
	ds_write_b32 v40, a39 offset:1920
	ds_write_b32 v40, a38 offset:1408
	ds_write_b32 v40, a37 offset:896
	ds_write_b32 v40, a36 offset:384
	s_nop 3
	ds_write_b32 v40, a44 offset:16768
	ds_write_b32 v40, a45 offset:17280
	ds_write_b32 v40, a46 offset:17792
	ds_write_b32 v40, a47 offset:18304
	ds_write_b32 v40, a43 offset:18176
	ds_write_b32 v40, a42 offset:17664
	ds_write_b32 v40, a41 offset:17152
	ds_write_b32 v40, a40 offset:16640
	v_mfma_f32_16x16x4_f32 a[12:15], v66, v74, a[20:23]
	ds_write_b32 v40, a32 offset:16512
	ds_write_b32 v40, a33 offset:17024
	ds_write_b32 v40, a34 offset:17536
	ds_write_b32 v40, a35 offset:18048
	ds_write_b32 v40, a31 offset:17920
	ds_write_b32 v40, a30 offset:17408
	ds_write_b32 v40, a29 offset:16896
	ds_write_b32 v40, a28 offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v42, a[56:59]
	v_mfma_f32_16x16x4_f32 a[20:23], v2, v46, a[72:75]
	v_mfma_f32_16x16x4_f32 a[24:27], v2, v82, a[76:79]
	v_mfma_f32_16x16x4_f32 a[36:39], v2, v74, a[80:83]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v43, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v67, v47, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v67, v83, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v67, v75, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v43, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v3, v47, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v3, v83, a[24:27]
	v_mfma_f32_16x16x4_f32 a[36:39], v3, v75, a[36:39]
	ds_read_b128 v[0:3], v37
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v44, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v68, v48, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v68, v84, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v68, v76, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v44, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v4, v48, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v4, v84, a[24:27]
	v_mfma_f32_16x16x4_f32 a[30:33], v4, v76, a[36:39]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[0:1], |v4|, 1.0
	v_mfma_f32_16x16x4_f32 a[0:3], v69, v45, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v69, v49, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v69, v85, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v69, v77, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v45, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v49, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v5, v85, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v77, a[30:33]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_xor_b64 s[0:1], exec, s[2:3]
	s_cbranch_execz .LBB1_14
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s2, v5
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s2
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s2, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_sub_f32_e32 v7, 1.0, v5
.LBB1_14:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v5
	v_fmaak_f32 v7, v5, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v5, v7, 0x3de703be
	v_fmaak_f32 v7, v5, v7, 0xbec09330
	v_fmaak_f32 v5, v5, v7, 0x3e0375d0
	v_fma_f32 v7, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v5, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[0:1], |v5|, 1.0
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_xor_b64 s[0:1], exec, s[2:3]
	s_cbranch_execz .LBB1_18
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v5|, s2, v8
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v8, |v5|, v8, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v8, |v5|, v8, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v8, |v5|, v8, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v8, |v5|, v8, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v8, |v5|, v8, s2
	v_fma_f32 v8, |v5|, v8, -|v5|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e32 vcc, s2, v8
	s_nop 1
	v_cndmask_b32_e32 v8, v8, v9, vcc
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e32 v8, v8, v9, vcc
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_18:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	v_mul_f32_e32 v8, v5, v5
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v5|, v8, |v5|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[0:1], |v9|, 1.0
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_xor_b64 s[0:1], exec, s[2:3]
	s_cbranch_execz .LBB1_22
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s2, v10
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s2
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e32 vcc, s2, v10
	s_nop 1
	v_cndmask_b32_e32 v10, v10, v11, vcc
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e32 v10, v10, v11, vcc
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_22:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[0:1], |v11|, 1.0
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_xor_b64 s[0:1], exec, s[2:3]
	s_cbranch_execz .LBB1_26
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s2, v12
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s2
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e32 vcc, s2, v12
	s_nop 1
	v_cndmask_b32_e32 v12, v12, v13, vcc
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e32 v12, v12, v13, vcc
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_26:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v36, s14, v6
	v_mad_u64_u32 v[38:39], s[0:1], v122, s17, v[36:37]
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s20, s8, s0
	s_addc_u32 s21, s9, s1
	s_mul_i32 s0, s19, s17
	s_mul_hi_u32 s1, 0, s17
	s_add_i32 s1, s1, s0
	s_brev_b32 s0, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s0, v12, v11
	v_bfi_b32 v10, s0, v10, v9
	v_bfi_b32 v5, s0, v8, v5
	v_bfi_b32 v4, s0, v7, v4
	v_pk_fma_f32 v[4:5], v[4:5], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:16
	v_cmp_gt_i32_e64 s[2:3], s13, v36
	v_cmp_gt_i32_e32 vcc, s12, v122
	s_add_i32 s0, s13, s1
	s_lshl_b32 s22, s0, 2
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[0:1], vcc, s[2:3]
	v_lshlrev_b32_e32 v39, 2, v38
	v_cndmask_b32_e64 v8, v8, 0, s[0:1]
	s_mov_b32 s23, 0x20000
	v_add_u32_e32 v8, v8, v39
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[0:1], |v4|, 1.0
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_30
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s0, v5
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s0
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e64 s[0:1], s0, v5
	s_nop 1
	v_cndmask_b32_e64 v5, v5, v6, s[0:1]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v6, s[0:1]
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_30:
	s_andn2_saveexec_b64 s[0:1], s[4:5]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[0:1], |v6|, 1.0
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_34
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s0, v7
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s0
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e64 s[0:1], s0, v7
	s_nop 1
	v_cndmask_b32_e64 v7, v7, v8, s[0:1]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v8, s[0:1]
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_34:
	s_andn2_saveexec_b64 s[0:1], s[4:5]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[0:1], |v8|, 1.0
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_38
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s0, v9
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s0
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e64 s[0:1], s0, v9
	s_nop 1
	v_cndmask_b32_e64 v9, v9, v10, s[0:1]
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e64 v9, v9, v10, s[0:1]
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_38:
	s_andn2_saveexec_b64 s[0:1], s[4:5]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[0:1], |v10|, 1.0
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_42
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s0, v11
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s0
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e64 s[0:1], s0, v11
	s_nop 1
	v_cndmask_b32_e64 v11, v11, v12, s[0:1]
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e64 v11, v11, v12, s[0:1]
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_42:
	s_andn2_saveexec_b64 s[0:1], s[4:5]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[0:1]
	s_brev_b32 s0, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s0, v11, v10
	v_bfi_b32 v10, s0, v9, v8
	v_bfi_b32 v7, s0, v7, v6
	v_bfi_b32 v6, s0, v5, v4
	v_or_b32_e32 v12, 4, v36
	v_pk_fma_f32 v[4:5], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:32
	v_cmp_gt_i32_e64 s[4:5], s13, v12
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[0:1], vcc, s[4:5]
	v_cndmask_b32_e64 v8, v8, 0, s[0:1]
	v_add_u32_e32 v8, v39, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:16
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[0:1], |v4|, 1.0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_46
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s0, v5
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s0
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e64 s[0:1], s0, v5
	s_nop 1
	v_cndmask_b32_e64 v5, v5, v6, s[0:1]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v6, s[0:1]
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_46:
	s_andn2_saveexec_b64 s[0:1], s[6:7]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[0:1], |v6|, 1.0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_50
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s0, v7
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s0
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e64 s[0:1], s0, v7
	s_nop 1
	v_cndmask_b32_e64 v7, v7, v8, s[0:1]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v8, s[0:1]
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_50:
	s_andn2_saveexec_b64 s[0:1], s[6:7]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[0:1], |v8|, 1.0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_54
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s0, v9
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s0
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e64 s[0:1], s0, v9
	s_nop 1
	v_cndmask_b32_e64 v9, v9, v10, s[0:1]
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e64 v9, v9, v10, s[0:1]
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_54:
	s_andn2_saveexec_b64 s[0:1], s[6:7]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[0:1], |v10|, 1.0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_58
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s0, v11
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s0
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e64 s[0:1], s0, v11
	s_nop 1
	v_cndmask_b32_e64 v11, v11, v12, s[0:1]
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e64 v11, v11, v12, s[0:1]
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_58:
	s_andn2_saveexec_b64 s[0:1], s[6:7]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[0:1]
	s_brev_b32 s0, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s0, v11, v10
	v_bfi_b32 v10, s0, v9, v8
	v_bfi_b32 v7, s0, v7, v6
	v_bfi_b32 v6, s0, v5, v4
	v_or_b32_e32 v12, 8, v36
	v_pk_fma_f32 v[4:5], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:48
	v_cmp_gt_i32_e64 s[6:7], s13, v12
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[0:1], vcc, s[6:7]
	v_cndmask_b32_e64 v8, v8, 0, s[0:1]
	v_add_u32_e32 v8, v39, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:32
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[0:1], |v5|, 1.0
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_62
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v5|, s0, v4
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v4, |v5|, v4, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v4, |v5|, v4, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v4, |v5|, v4, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v4, |v5|, v4, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v4, |v5|, v4, s0
	v_fma_f32 v4, |v5|, v4, -|v5|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v4
	v_cmp_gt_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v6, s[0:1]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v6, s[0:1]
	v_sub_f32_e32 v6, 1.0, v4
.LBB1_62:
	s_andn2_saveexec_b64 s[0:1], s[8:9]
	v_mul_f32_e32 v4, v5, v5
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v4
	v_fmaak_f32 v6, v4, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v4, v6, 0x3de703be
	v_fmaak_f32 v6, v4, v6, 0xbec09330
	v_fmaak_f32 v4, v4, v6, 0x3e0375d0
	v_fma_f32 v6, |v5|, v4, |v5|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[0:1], |v7|, 1.0
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_66
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v7|, s0, v4
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v4, |v7|, v4, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v4, |v7|, v4, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v4, |v7|, v4, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v4, |v7|, v4, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v4, |v7|, v4, s0
	v_fma_f32 v4, |v7|, v4, -|v7|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v4
	v_cmp_gt_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v8, s[0:1]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v8, s[0:1]
	v_sub_f32_e32 v8, 1.0, v4
.LBB1_66:
	s_andn2_saveexec_b64 s[0:1], s[8:9]
	v_mul_f32_e32 v4, v7, v7
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v4
	v_fmaak_f32 v8, v4, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v4, v8, 0x3de703be
	v_fmaak_f32 v8, v4, v8, 0xbec09330
	v_fmaak_f32 v4, v4, v8, 0x3e0375d0
	v_fma_f32 v8, |v7|, v4, |v7|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[0:1], |v9|, 1.0
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_70
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v9|, s0, v4
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v4, |v9|, v4, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v4, |v9|, v4, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v4, |v9|, v4, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v4, |v9|, v4, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v4, |v9|, v4, s0
	v_fma_f32 v4, |v9|, v4, -|v9|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v4
	v_cmp_gt_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v10, s[0:1]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v10, s[0:1]
	v_sub_f32_e32 v10, 1.0, v4
.LBB1_70:
	s_andn2_saveexec_b64 s[0:1], s[8:9]
	v_mul_f32_e32 v4, v9, v9
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v4
	v_fmaak_f32 v10, v4, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v4, v10, 0x3de703be
	v_fmaak_f32 v10, v4, v10, 0xbec09330
	v_fmaak_f32 v4, v4, v10, 0x3e0375d0
	v_fma_f32 v10, |v9|, v4, |v9|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[0:1], |v11|, 1.0
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_74
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v11|, s0, v4
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v4, |v11|, v4, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v4, |v11|, v4, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v4, |v11|, v4, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v4, |v11|, v4, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v4, |v11|, v4, s0
	v_fma_f32 v4, |v11|, v4, -|v11|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v4
	v_cmp_gt_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v12, s[0:1]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v12, s[0:1]
	v_sub_f32_e32 v12, 1.0, v4
.LBB1_74:
	s_andn2_saveexec_b64 s[0:1], s[8:9]
	v_mul_f32_e32 v4, v11, v11
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v4
	v_fmaak_f32 v12, v4, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v4, v12, 0x3de703be
	v_fmaak_f32 v12, v4, v12, 0xbec09330
	v_fmaak_f32 v4, v4, v12, 0x3e0375d0
	v_fma_f32 v12, |v11|, v4, |v11|
	s_or_b64 exec, exec, s[0:1]
	s_brev_b32 s0, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s0, v12, v11
	v_bfi_b32 v10, s0, v10, v9
	v_bfi_b32 v7, s0, v8, v7
	v_bfi_b32 v6, s0, v6, v5
	v_or_b32_e32 v13, 12, v36
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:560
	v_cmp_gt_i32_e64 s[8:9], s13, v13
	v_bfrev_b32_e32 v5, 1
	s_and_b64 s[0:1], vcc, s[8:9]
	v_add_u32_e32 v4, 12, v38
	v_cndmask_b32_e64 v5, v5, 0, s[0:1]
	v_lshl_add_u32 v5, v4, 2, v5
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[0:1], |v5|, 1.0
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_78
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s0, v6
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s0
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[0:1], s0, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[0:1]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[0:1]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_78:
	s_andn2_saveexec_b64 s[0:1], s[10:11]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[0:1], |v7|, 1.0
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_82
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s0, v8
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s0
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[0:1], s0, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[0:1]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[0:1]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_82:
	s_andn2_saveexec_b64 s[0:1], s[10:11]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[0:1], |v9|, 1.0
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_86
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s0, v10
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s0
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[0:1], s0, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[0:1]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[0:1]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_86:
	s_andn2_saveexec_b64 s[0:1], s[10:11]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[0:1]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[0:1], |v11|, 1.0
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_90
	s_mov_b32 s0, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s0, v12
	s_mov_b32 s0, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s0
	s_mov_b32 s0, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s0
	s_mov_b32 s0, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s0
	s_mov_b32 s0, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s0
	s_mov_b32 s0, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s0
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s0, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[0:1], s0, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[0:1]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[0:1]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_90:
	s_andn2_saveexec_b64 s[0:1], s[10:11]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[0:1]
	s_brev_b32 s0, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s0, v12, v11
	v_bfi_b32 v10, s0, v10, v9
	v_bfi_b32 v7, s0, v8, v7
	v_bfi_b32 v6, s0, v6, v5
	v_or_b32_e32 v13, 1, v122
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:544
	v_cmp_gt_i32_e64 s[0:1], s12, v13
	v_bfrev_b32_e32 v5, 1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_add_lshl_u32 v4, v4, s17, 2
	v_cndmask_b32_e64 v5, v5, 0, s[8:9]
	v_add_u32_e32 v5, v4, v5
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[8:9], |v5|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_94
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s8, v6
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s8
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[8:9], s8, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[8:9]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[8:9]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_94:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[8:9], |v7|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_98
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s8, v8
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s8
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[8:9], s8, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[8:9]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[8:9]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_98:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[8:9], |v9|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_102
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s8, v10
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s8
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[8:9], s8, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[8:9]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[8:9]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_102:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[8:9], |v11|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_106
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s8, v12
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s8
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[8:9], s8, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[8:9]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[8:9]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_106:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[8:9]
	s_brev_b32 s8, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s8, v12, v11
	v_bfi_b32 v10, s8, v10, v9
	v_bfi_b32 v7, s8, v8, v7
	v_bfi_b32 v6, s8, v6, v5
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:528
	v_mov_b32_e32 v5, 0x7ffffff0
	s_and_b64 s[6:7], s[6:7], s[0:1]
	v_cndmask_b32_e64 v5, v5, -16, s[6:7]
	v_add_u32_e32 v5, v4, v5
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[6:7], |v5|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_110
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s6, v6
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s6
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[6:7], s6, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[6:7]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[6:7]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_110:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[6:7], |v7|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_114
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s6, v8
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s6
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[6:7], s6, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[6:7]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[6:7]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_114:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[6:7], |v9|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_118
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s6, v10
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s6
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[6:7], s6, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[6:7]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[6:7]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_118:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[6:7], |v11|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_122
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s6, v12
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s6
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[6:7], s6, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[6:7]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[6:7]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_122:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[6:7]
	s_brev_b32 s6, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s6, v12, v11
	v_bfi_b32 v10, s6, v10, v9
	v_bfi_b32 v7, s6, v8, v7
	v_bfi_b32 v6, s6, v6, v5
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:512
	v_mov_b32_e32 v5, 0x7fffffe0
	v_not_b32_e32 v10, 31
	s_and_b64 s[4:5], s[4:5], s[0:1]
	v_cndmask_b32_e64 v5, v5, v10, s[4:5]
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v41, 0x3f3504f3, v0
	v_add_u32_e32 v4, v4, v5
	v_cmp_ge_f32_e64 s[4:5], |v41|, 1.0
	buffer_store_dwordx4 v[6:9], v4, s[20:23], 0 offen
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_126
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v41|, s4, v4
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v4, |v41|, v4, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v4, |v41|, v4, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v4, |v41|, v4, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v4, |v41|, v4, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v4, |v41|, v4, s4
	v_fma_f32 v4, |v41|, v4, -|v41|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v5, 0x42800000, v4
	v_cmp_gt_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v5, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_sub_f32_e32 v42, 1.0, v4
.LBB1_126:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v4, v41, v41
	v_mov_b32_e32 v5, 0x3ba10414
	v_fmac_f32_e32 v5, 0xba1345e1, v4
	v_fmaak_f32 v5, v4, v5, 0xbcdac9b8
	v_fmaak_f32 v5, v4, v5, 0x3de703be
	v_fmaak_f32 v5, v4, v5, 0xbec09330
	v_fmaak_f32 v4, v4, v5, 0x3e0375d0
	v_fma_f32 v42, |v41|, v4, |v41|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v43, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[4:5], |v43|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_130
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v43|, s4, v4
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v4, |v43|, v4, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v4, |v43|, v4, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v4, |v43|, v4, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v4, |v43|, v4, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v4, |v43|, v4, s4
	v_fma_f32 v4, |v43|, v4, -|v43|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v5, 0x42800000, v4
	v_cmp_gt_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v5, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_sub_f32_e32 v44, 1.0, v4
.LBB1_130:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v4, v43, v43
	v_mov_b32_e32 v5, 0x3ba10414
	v_fmac_f32_e32 v5, 0xba1345e1, v4
	v_fmaak_f32 v5, v4, v5, 0xbcdac9b8
	v_fmaak_f32 v5, v4, v5, 0x3de703be
	v_fmaak_f32 v5, v4, v5, 0xbec09330
	v_fmaak_f32 v4, v4, v5, 0x3e0375d0
	v_fma_f32 v44, |v43|, v4, |v43|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v45, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[4:5], |v45|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_134
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v45|, s4, v4
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v4, |v45|, v4, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v4, |v45|, v4, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v4, |v45|, v4, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v4, |v45|, v4, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v4, |v45|, v4, s4
	v_fma_f32 v4, |v45|, v4, -|v45|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v5, 0x42800000, v4
	v_cmp_gt_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v5, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_sub_f32_e32 v46, 1.0, v4
.LBB1_134:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v4, v45, v45
	v_mov_b32_e32 v5, 0x3ba10414
	v_fmac_f32_e32 v5, 0xba1345e1, v4
	v_fmaak_f32 v5, v4, v5, 0xbcdac9b8
	v_fmaak_f32 v5, v4, v5, 0x3de703be
	v_fmaak_f32 v5, v4, v5, 0xbec09330
	v_fmaak_f32 v4, v4, v5, 0x3e0375d0
	v_fma_f32 v46, |v45|, v4, |v45|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v47, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[4:5], |v47|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_138
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v4, 0x39c68948
	v_fma_f32 v4, |v47|, s4, v4
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v4, |v47|, v4, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v4, |v47|, v4, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v4, |v47|, v4, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v4, |v47|, v4, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v4, |v47|, v4, s4
	v_fma_f32 v4, |v47|, v4, -|v47|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v5, 0x42800000, v4
	v_cmp_gt_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v5, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v5, s[4:5]
	v_sub_f32_e32 v48, 1.0, v4
.LBB1_138:
	s_or_saveexec_b64 s[4:5], s[6:7]
	v_accvgpr_read_b32 v27, a3
	v_accvgpr_read_b32 v35, a7
	v_accvgpr_read_b32 v19, a11
	v_accvgpr_read_b32 v23, a15
	v_accvgpr_read_b32 v4, a16
	v_accvgpr_read_b32 v8, a20
	v_accvgpr_read_b32 v12, a24
	v_accvgpr_read_b32 v28, a28
	v_accvgpr_read_b32 v26, a2
	v_accvgpr_read_b32 v25, a1
	v_accvgpr_read_b32 v24, a0
	v_accvgpr_read_b32 v34, a6
	v_accvgpr_read_b32 v33, a5
	v_accvgpr_read_b32 v32, a4
	v_accvgpr_read_b32 v18, a10
	v_accvgpr_read_b32 v17, a9
	v_accvgpr_read_b32 v16, a8
	v_accvgpr_read_b32 v22, a14
	v_accvgpr_read_b32 v21, a13
	v_accvgpr_read_b32 v20, a12
	v_accvgpr_read_b32 v5, a17
	v_accvgpr_read_b32 v6, a18
	v_accvgpr_read_b32 v7, a19
	v_accvgpr_read_b32 v9, a21
	v_accvgpr_read_b32 v10, a22
	v_accvgpr_read_b32 v11, a23
	v_accvgpr_read_b32 v13, a25
	v_accvgpr_read_b32 v14, a26
	v_accvgpr_read_b32 v15, a27
	v_accvgpr_read_b32 v29, a29
	v_accvgpr_read_b32 v30, a30
	v_accvgpr_read_b32 v31, a31
	s_xor_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v48, v47, v47
	v_mov_b32_e32 v49, 0x3ba10414
	v_fmac_f32_e32 v49, 0xba1345e1, v48
	v_fmaak_f32 v49, v48, v49, 0xbcdac9b8
	v_fmaak_f32 v49, v48, v49, 0x3de703be
	v_fmaak_f32 v49, v48, v49, 0xbec09330
	v_fmaak_f32 v48, v48, v49, 0x3e0375d0
	v_fma_f32 v48, |v47|, v48, |v47|
	s_or_b64 exec, exec, s[4:5]
	s_brev_b32 s4, -2
	v_bfi_b32 v42, s4, v42, v41
	v_bfrev_b32_e32 v41, 1
	s_and_b64 s[2:3], s[2:3], s[0:1]
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v47, s4, v48, v47
	v_bfi_b32 v46, s4, v46, v45
	v_bfi_b32 v43, s4, v44, v43
	v_add_lshl_u32 v38, v38, s17, 2
	v_cndmask_b32_e64 v41, v41, 0, s[2:3]
	v_pk_fma_f32 v[0:1], v[42:43], v[0:1], v[0:1]
	v_pk_fma_f32 v[2:3], v[46:47], v[2:3], v[2:3]
	v_add_u32_e32 v41, v41, v38
	buffer_store_dwordx4 v[0:3], v41, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_add_u32_e32 v0, 0x400, v40
	ds_write2_b32 v0, v27, v35 offset0:128 offset1:160
	ds_write2_b32 v0, v26, v34 offset1:32
	ds_write2_b32 v40, v25, v33 offset0:128 offset1:160
	ds_write2_b32 v40, v24, v32 offset1:32
	ds_write2_b32 v0, v19, v23 offset0:192 offset1:224
	ds_write2_b32 v0, v18, v22 offset0:64 offset1:96
	ds_write2_b32 v40, v17, v21 offset0:192 offset1:224
	ds_write2_b32 v40, v16, v20 offset0:64 offset1:96
	v_add_u32_e32 v0, 0x4400, v40
	v_add_u32_e32 v1, 0x4000, v40
	ds_write2_b32 v0, v15, v31 offset0:192 offset1:224
	ds_write2_b32 v0, v14, v30 offset0:64 offset1:96
	ds_write2_b32 v1, v13, v29 offset0:192 offset1:224
	ds_write2_b32 v1, v12, v28 offset0:64 offset1:96
	ds_write2_b32 v0, v7, v11 offset0:128 offset1:160
	ds_write2_b32 v0, v6, v10 offset1:32
	ds_write2_b32 v1, v5, v9 offset0:128 offset1:160
	ds_write2_b32 v1, v4, v8 offset1:32
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[0:3], v37
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[2:3], |v4|, 1.0
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_142
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s2, v5
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s2
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e64 s[2:3], s2, v5
	s_nop 1
	v_cndmask_b32_e64 v5, v5, v6, s[2:3]
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e64 v5, v5, v6, s[2:3]
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_142:
	s_andn2_saveexec_b64 s[2:3], s[4:5]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[2:3]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[2:3], |v6|, 1.0
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_146
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s2, v7
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s2
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e64 s[2:3], s2, v7
	s_nop 1
	v_cndmask_b32_e64 v7, v7, v8, s[2:3]
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e64 v7, v7, v8, s[2:3]
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_146:
	s_andn2_saveexec_b64 s[2:3], s[4:5]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[2:3]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[2:3], |v8|, 1.0
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_150
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s2, v9
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s2
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e64 s[2:3], s2, v9
	s_nop 1
	v_cndmask_b32_e64 v9, v9, v10, s[2:3]
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e64 v9, v9, v10, s[2:3]
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_150:
	s_andn2_saveexec_b64 s[2:3], s[4:5]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[2:3]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[2:3], |v10|, 1.0
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB1_154
	s_mov_b32 s2, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s2, v11
	s_mov_b32 s2, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s2
	s_mov_b32 s2, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s2
	s_mov_b32 s2, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s2
	s_mov_b32 s2, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s2
	s_mov_b32 s2, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s2
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s2, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e64 s[2:3], s2, v11
	s_nop 1
	v_cndmask_b32_e64 v11, v11, v12, s[2:3]
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e64 v11, v11, v12, s[2:3]
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_154:
	s_andn2_saveexec_b64 s[2:3], s[4:5]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[2:3]
	s_brev_b32 s2, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s2, v11, v10
	v_bfi_b32 v10, s2, v9, v8
	v_bfi_b32 v7, s2, v7, v6
	v_bfi_b32 v6, s2, v5, v4
	v_or_b32_e32 v12, 0x80, v36
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:16
	v_cmp_gt_i32_e64 s[2:3], s13, v12
	v_bfrev_b32_e32 v5, 1
	s_and_b64 s[4:5], vcc, s[2:3]
	v_add_u32_e32 v4, 0x200, v39
	v_cndmask_b32_e64 v5, v5, 0, s[4:5]
	v_add_u32_e32 v5, v4, v5
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[4:5], |v5|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_158
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s4, v6
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s4
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[4:5], s4, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[4:5]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[4:5]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_158:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[4:5], |v7|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_162
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s4, v8
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s4
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[4:5], s4, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[4:5]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[4:5]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_162:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[4:5], |v9|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_166
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s4, v10
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s4
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[4:5], s4, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[4:5]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[4:5]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_166:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[4:5], |v11|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB1_170
	s_mov_b32 s4, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s4, v12
	s_mov_b32 s4, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s4
	s_mov_b32 s4, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s4
	s_mov_b32 s4, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s4
	s_mov_b32 s4, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s4
	s_mov_b32 s4, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s4
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s4, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[4:5], s4, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[4:5]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[4:5]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_170:
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[4:5]
	s_brev_b32 s4, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s4, v12, v11
	v_bfi_b32 v10, s4, v10, v9
	v_bfi_b32 v7, s4, v8, v7
	v_bfi_b32 v6, s4, v6, v5
	v_or_b32_e32 v13, 0x84, v36
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:32
	v_cmp_gt_i32_e64 s[4:5], s13, v13
	v_mov_b32_e32 v5, 0x80000010
	s_and_b64 s[6:7], vcc, s[4:5]
	v_cndmask_b32_e64 v5, v5, 16, s[6:7]
	v_add_u32_e32 v5, v5, v4
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[6:7], |v5|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_174
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s6, v6
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s6
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[6:7], s6, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[6:7]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[6:7]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_174:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[6:7], |v7|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_178
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s6, v8
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s6
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[6:7], s6, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[6:7]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[6:7]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_178:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[6:7], |v9|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_182
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s6, v10
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s6
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[6:7], s6, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[6:7]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[6:7]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_182:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[6:7], |v11|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB1_186
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s6, v12
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s6
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[6:7], s6, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[6:7]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[6:7]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_186:
	s_andn2_saveexec_b64 s[6:7], s[8:9]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[6:7]
	s_brev_b32 s6, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s6, v12, v11
	v_bfi_b32 v10, s6, v10, v9
	v_bfi_b32 v7, s6, v8, v7
	v_bfi_b32 v6, s6, v6, v5
	v_or_b32_e32 v13, 0x88, v36
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:48
	v_cmp_gt_i32_e64 s[6:7], s13, v13
	v_mov_b32_e32 v5, 0x80000020
	s_and_b64 s[8:9], vcc, s[6:7]
	v_cndmask_b32_e64 v5, v5, 32, s[8:9]
	v_add_u32_e32 v5, v5, v4
	buffer_store_dwordx4 v[6:9], v5, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v5, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[8:9], |v5|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_190
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v6, 0x39c68948
	v_fma_f32 v6, |v5|, s8, v6
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v6, |v5|, v6, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v6, |v5|, v6, s8
	v_fma_f32 v6, |v5|, v6, -|v5|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v7, 0x42800000, v6
	v_cmp_gt_f32_e64 s[8:9], s8, v6
	s_nop 1
	v_cndmask_b32_e64 v6, v6, v7, s[8:9]
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e64 v6, v6, v7, s[8:9]
	v_sub_f32_e32 v6, 1.0, v6
.LBB1_190:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v6, v5, v5
	v_mov_b32_e32 v7, 0x3ba10414
	v_fmac_f32_e32 v7, 0xba1345e1, v6
	v_fmaak_f32 v7, v6, v7, 0xbcdac9b8
	v_fmaak_f32 v7, v6, v7, 0x3de703be
	v_fmaak_f32 v7, v6, v7, 0xbec09330
	v_fmaak_f32 v6, v6, v7, 0x3e0375d0
	v_fma_f32 v6, |v5|, v6, |v5|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v7, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[8:9], |v7|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_194
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v8, 0x39c68948
	v_fma_f32 v8, |v7|, s8, v8
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v8, |v7|, v8, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v8, |v7|, v8, s8
	v_fma_f32 v8, |v7|, v8, -|v7|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v9, 0x42800000, v8
	v_cmp_gt_f32_e64 s[8:9], s8, v8
	s_nop 1
	v_cndmask_b32_e64 v8, v8, v9, s[8:9]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v9, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v9, s[8:9]
	v_sub_f32_e32 v8, 1.0, v8
.LBB1_194:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v8, v7, v7
	v_mov_b32_e32 v9, 0x3ba10414
	v_fmac_f32_e32 v9, 0xba1345e1, v8
	v_fmaak_f32 v9, v8, v9, 0xbcdac9b8
	v_fmaak_f32 v9, v8, v9, 0x3de703be
	v_fmaak_f32 v9, v8, v9, 0xbec09330
	v_fmaak_f32 v8, v8, v9, 0x3e0375d0
	v_fma_f32 v8, |v7|, v8, |v7|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v9, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[8:9], |v9|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_198
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v10, 0x39c68948
	v_fma_f32 v10, |v9|, s8, v10
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v10, |v9|, v10, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v10, |v9|, v10, s8
	v_fma_f32 v10, |v9|, v10, -|v9|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v11, 0x42800000, v10
	v_cmp_gt_f32_e64 s[8:9], s8, v10
	s_nop 1
	v_cndmask_b32_e64 v10, v10, v11, s[8:9]
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v11, 0x114b4ea4, v10
	v_cndmask_b32_e64 v10, v10, v11, s[8:9]
	v_sub_f32_e32 v10, 1.0, v10
.LBB1_198:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v10, v9, v9
	v_mov_b32_e32 v11, 0x3ba10414
	v_fmac_f32_e32 v11, 0xba1345e1, v10
	v_fmaak_f32 v11, v10, v11, 0xbcdac9b8
	v_fmaak_f32 v11, v10, v11, 0x3de703be
	v_fmaak_f32 v11, v10, v11, 0xbec09330
	v_fmaak_f32 v10, v10, v11, 0x3e0375d0
	v_fma_f32 v10, |v9|, v10, |v9|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v11, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[8:9], |v11|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[10:11], exec, s[10:11]
	s_cbranch_execz .LBB1_202
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v12, 0x39c68948
	v_fma_f32 v12, |v11|, s8, v12
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v12, |v11|, v12, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v12, |v11|, v12, s8
	v_fma_f32 v12, |v11|, v12, -|v11|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e64 s[8:9], s8, v12
	s_nop 1
	v_cndmask_b32_e64 v12, v12, v13, s[8:9]
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	s_nop 0
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e64 v12, v12, v13, s[8:9]
	v_sub_f32_e32 v12, 1.0, v12
.LBB1_202:
	s_andn2_saveexec_b64 s[8:9], s[10:11]
	v_mul_f32_e32 v12, v11, v11
	v_mov_b32_e32 v13, 0x3ba10414
	v_fmac_f32_e32 v13, 0xba1345e1, v12
	v_fmaak_f32 v13, v12, v13, 0xbcdac9b8
	v_fmaak_f32 v13, v12, v13, 0x3de703be
	v_fmaak_f32 v13, v12, v13, 0xbec09330
	v_fmaak_f32 v12, v12, v13, 0x3e0375d0
	v_fma_f32 v12, |v11|, v12, |v11|
	s_or_b64 exec, exec, s[8:9]
	s_brev_b32 s8, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s8, v12, v11
	v_bfi_b32 v10, s8, v10, v9
	v_bfi_b32 v7, s8, v8, v7
	v_bfi_b32 v6, s8, v6, v5
	v_or_b32_e32 v13, 0x8c, v36
	v_pk_fma_f32 v[6:7], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[8:9], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:560
	v_cmp_gt_i32_e64 s[8:9], s13, v13
	v_mov_b32_e32 v5, 0x80000030
	s_and_b64 s[10:11], vcc, s[8:9]
	v_cndmask_b32_e64 v5, v5, 48, s[10:11]
	v_add_u32_e32 v4, v5, v4
	buffer_store_dwordx4 v[6:9], v4, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[10:11], |v4|, 1.0
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_xor_b64 s[10:11], exec, s[12:13]
	s_cbranch_execz .LBB1_206
	s_mov_b32 s12, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s12, v5
	s_mov_b32 s12, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s12
	s_mov_b32 s12, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s12
	s_mov_b32 s12, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s12
	s_mov_b32 s12, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s12
	s_mov_b32 s12, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s12
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s12, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s12, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_206:
	s_andn2_saveexec_b64 s[10:11], s[10:11]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[10:11]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[10:11], |v6|, 1.0
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_xor_b64 s[10:11], exec, s[12:13]
	s_cbranch_execz .LBB1_210
	s_mov_b32 s12, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s12, v7
	s_mov_b32 s12, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s12
	s_mov_b32 s12, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s12
	s_mov_b32 s12, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s12
	s_mov_b32 s12, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s12
	s_mov_b32 s12, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s12
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s12, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s12, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_210:
	s_andn2_saveexec_b64 s[10:11], s[10:11]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[10:11]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[10:11], |v8|, 1.0
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_xor_b64 s[10:11], exec, s[12:13]
	s_cbranch_execz .LBB1_214
	s_mov_b32 s12, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s12, v9
	s_mov_b32 s12, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s12
	s_mov_b32 s12, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s12
	s_mov_b32 s12, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s12
	s_mov_b32 s12, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s12
	s_mov_b32 s12, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s12
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s12, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s12, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_214:
	s_andn2_saveexec_b64 s[10:11], s[10:11]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[10:11]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[10:11], |v10|, 1.0
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_xor_b64 s[10:11], exec, s[12:13]
	s_cbranch_execz .LBB1_218
	s_mov_b32 s12, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s12, v11
	s_mov_b32 s12, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s12
	s_mov_b32 s12, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s12
	s_mov_b32 s12, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s12
	s_mov_b32 s12, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s12
	s_mov_b32 s12, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s12
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s12, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s12, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_218:
	s_andn2_saveexec_b64 s[10:11], s[10:11]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[10:11]
	s_brev_b32 s10, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s10, v11, v10
	v_bfi_b32 v10, s10, v9, v8
	v_bfi_b32 v7, s10, v7, v6
	v_bfi_b32 v6, s10, v5, v4
	v_pk_fma_f32 v[4:5], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:544
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v8, v8, 0, s[8:9]
	v_add_u32_e32 v8, v38, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:560
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[8:9], |v4|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[8:9], exec, s[10:11]
	s_cbranch_execz .LBB1_222
	s_mov_b32 s10, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s10, v5
	s_mov_b32 s10, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s10
	s_mov_b32 s10, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s10
	s_mov_b32 s10, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s10
	s_mov_b32 s10, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s10
	s_mov_b32 s10, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s10
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s10, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s10, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_222:
	s_andn2_saveexec_b64 s[8:9], s[8:9]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[8:9], |v6|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[8:9], exec, s[10:11]
	s_cbranch_execz .LBB1_226
	s_mov_b32 s10, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s10, v7
	s_mov_b32 s10, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s10
	s_mov_b32 s10, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s10
	s_mov_b32 s10, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s10
	s_mov_b32 s10, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s10
	s_mov_b32 s10, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s10
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s10, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s10, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_226:
	s_andn2_saveexec_b64 s[8:9], s[8:9]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[8:9], |v8|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[8:9], exec, s[10:11]
	s_cbranch_execz .LBB1_230
	s_mov_b32 s10, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s10, v9
	s_mov_b32 s10, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s10
	s_mov_b32 s10, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s10
	s_mov_b32 s10, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s10
	s_mov_b32 s10, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s10
	s_mov_b32 s10, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s10
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s10, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s10, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_230:
	s_andn2_saveexec_b64 s[8:9], s[8:9]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[8:9]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[8:9], |v10|, 1.0
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_xor_b64 s[8:9], exec, s[10:11]
	s_cbranch_execz .LBB1_234
	s_mov_b32 s10, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s10, v11
	s_mov_b32 s10, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s10
	s_mov_b32 s10, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s10
	s_mov_b32 s10, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s10
	s_mov_b32 s10, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s10
	s_mov_b32 s10, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s10
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s10, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s10, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_234:
	s_andn2_saveexec_b64 s[8:9], s[8:9]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[8:9]
	s_brev_b32 s8, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s8, v11, v10
	v_bfi_b32 v10, s8, v9, v8
	v_bfi_b32 v7, s8, v7, v6
	v_bfi_b32 v6, s8, v5, v4
	v_pk_fma_f32 v[4:5], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:528
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[6:7], s[6:7], s[0:1]
	v_cndmask_b32_e64 v8, v8, 0, s[6:7]
	v_add_u32_e32 v8, v38, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:544
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[6:7], |v4|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	s_cbranch_execz .LBB1_238
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s8, v5
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s8
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s8, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_238:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[6:7], |v6|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	s_cbranch_execz .LBB1_242
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s8, v7
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s8
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s8, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_242:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[6:7], |v8|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	s_cbranch_execz .LBB1_246
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s8, v9
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s8
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s8, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_246:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[6:7]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[6:7], |v10|, 1.0
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	s_cbranch_execz .LBB1_250
	s_mov_b32 s8, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s8, v11
	s_mov_b32 s8, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s8
	s_mov_b32 s8, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s8
	s_mov_b32 s8, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s8
	s_mov_b32 s8, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s8
	s_mov_b32 s8, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s8
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s8, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s8, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_250:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[6:7]
	s_brev_b32 s6, -2
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s6, v11, v10
	v_bfi_b32 v10, s6, v9, v8
	v_bfi_b32 v7, s6, v7, v6
	v_bfi_b32 v6, s6, v5, v4
	v_pk_fma_f32 v[4:5], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[6:7], v[10:11], v[2:3], v[2:3]
	ds_read_b128 v[0:3], v37 offset:512
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[4:5], s[4:5], s[0:1]
	v_cndmask_b32_e64 v8, v8, 0, s[4:5]
	v_add_u32_e32 v8, v38, v8
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:528
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mul_f32_e32 v4, 0x3f3504f3, v0
	v_cmp_ge_f32_e64 s[4:5], |v4|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[4:5], exec, s[6:7]
	s_cbranch_execz .LBB1_254
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v5, 0x39c68948
	v_fma_f32 v5, |v4|, s6, v5
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v5, |v4|, v5, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v5, |v4|, v5, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v5, |v4|, v5, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v5, |v4|, v5, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v5, |v4|, v5, s6
	v_fma_f32 v5, |v4|, v5, -|v4|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v6, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s6, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	s_nop 0
	v_mul_f32_e32 v6, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_sub_f32_e32 v5, 1.0, v5
.LBB1_254:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	v_mul_f32_e32 v5, v4, v4
	v_mov_b32_e32 v6, 0x3ba10414
	v_fmac_f32_e32 v6, 0xba1345e1, v5
	v_fmaak_f32 v6, v5, v6, 0xbcdac9b8
	v_fmaak_f32 v6, v5, v6, 0x3de703be
	v_fmaak_f32 v6, v5, v6, 0xbec09330
	v_fmaak_f32 v5, v5, v6, 0x3e0375d0
	v_fma_f32 v5, |v4|, v5, |v4|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v6, 0x3f3504f3, v1
	v_cmp_ge_f32_e64 s[4:5], |v6|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[4:5], exec, s[6:7]
	s_cbranch_execz .LBB1_258
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v7, 0x39c68948
	v_fma_f32 v7, |v6|, s6, v7
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v7, |v6|, v7, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v7, |v6|, v7, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v7, |v6|, v7, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v7, |v6|, v7, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v7, |v6|, v7, s6
	v_fma_f32 v7, |v6|, v7, -|v6|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v8, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s6, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	s_nop 0
	v_mul_f32_e32 v8, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_sub_f32_e32 v7, 1.0, v7
.LBB1_258:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	v_mul_f32_e32 v7, v6, v6
	v_mov_b32_e32 v8, 0x3ba10414
	v_fmac_f32_e32 v8, 0xba1345e1, v7
	v_fmaak_f32 v8, v7, v8, 0xbcdac9b8
	v_fmaak_f32 v8, v7, v8, 0x3de703be
	v_fmaak_f32 v8, v7, v8, 0xbec09330
	v_fmaak_f32 v7, v7, v8, 0x3e0375d0
	v_fma_f32 v7, |v6|, v7, |v6|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v8, 0x3f3504f3, v2
	v_cmp_ge_f32_e64 s[4:5], |v8|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[4:5], exec, s[6:7]
	s_cbranch_execz .LBB1_262
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v9, 0x39c68948
	v_fma_f32 v9, |v8|, s6, v9
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v9, |v8|, v9, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v9, |v8|, v9, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v9, |v8|, v9, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v9, |v8|, v9, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v9, |v8|, v9, s6
	v_fma_f32 v9, |v8|, v9, -|v8|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v10, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s6, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	s_nop 0
	v_mul_f32_e32 v10, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_sub_f32_e32 v9, 1.0, v9
.LBB1_262:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	v_mul_f32_e32 v9, v8, v8
	v_mov_b32_e32 v10, 0x3ba10414
	v_fmac_f32_e32 v10, 0xba1345e1, v9
	v_fmaak_f32 v10, v9, v10, 0xbcdac9b8
	v_fmaak_f32 v10, v9, v10, 0x3de703be
	v_fmaak_f32 v10, v9, v10, 0xbec09330
	v_fmaak_f32 v9, v9, v10, 0x3e0375d0
	v_fma_f32 v9, |v8|, v9, |v8|
	s_or_b64 exec, exec, s[4:5]
	v_mul_f32_e32 v10, 0x3f3504f3, v3
	v_cmp_ge_f32_e64 s[4:5], |v10|, 1.0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[4:5], exec, s[6:7]
	s_cbranch_execz .LBB1_266
	s_mov_b32 s6, 0xb78e98ab
	v_mov_b32_e32 v11, 0x39c68948
	v_fma_f32 v11, |v10|, s6, v11
	s_mov_b32 s6, 0xbb7cd369
	v_fma_f32 v11, |v10|, v11, s6
	s_mov_b32 s6, 0x3cc618b2
	v_fma_f32 v11, |v10|, v11, s6
	s_mov_b32 s6, 0xbdda74e4
	v_fma_f32 v11, |v10|, v11, s6
	s_mov_b32 s6, 0xbf228afd
	v_fma_f32 v11, |v10|, v11, s6
	s_mov_b32 s6, 0xbe03c728
	v_fma_f32 v11, |v10|, v11, s6
	v_fma_f32 v11, |v10|, v11, -|v10|
	s_mov_b32 s6, 0xc2aeac50
	v_add_f32_e32 v12, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s6, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v12, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v12, vcc
	v_sub_f32_e32 v11, 1.0, v11
.LBB1_266:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	v_mul_f32_e32 v11, v10, v10
	v_mov_b32_e32 v12, 0x3ba10414
	v_fmac_f32_e32 v12, 0xba1345e1, v11
	v_fmaak_f32 v12, v11, v12, 0xbcdac9b8
	v_fmaak_f32 v12, v11, v12, 0x3de703be
	v_fmaak_f32 v12, v11, v12, 0xbec09330
	v_fmaak_f32 v11, v11, v12, 0x3e0375d0
	v_fma_f32 v11, |v10|, v11, |v10|
	s_or_b64 exec, exec, s[4:5]
	s_brev_b32 s4, -2
	v_bfi_b32 v7, s4, v7, v6
	v_bfi_b32 v6, s4, v5, v4
	v_bfrev_b32_e32 v4, 1
	s_and_b64 s[0:1], s[2:3], s[0:1]
	v_pk_mul_f32 v[2:3], v[2:3], 0.5 op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], 0.5 op_sel_hi:[1,0]
	v_bfi_b32 v11, s4, v11, v10
	v_bfi_b32 v10, s4, v9, v8
	v_cndmask_b32_e64 v4, v4, 0, s[0:1]
	v_pk_fma_f32 v[0:1], v[6:7], v[0:1], v[0:1]
	v_pk_fma_f32 v[2:3], v[10:11], v[2:3], v[2:3]
	v_add_u32_e32 v4, v38, v4
	buffer_store_dwordx4 v[0:3], v4, s[20:23], 0 offen offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
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
		.amdhsa_next_free_vgpr 244
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 84
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 29
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
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

	.type	__hip_cuid_720ee620efe0ab77,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_720ee620efe0ab77
__hip_cuid_720ee620efe0ab77:
	.byte	0
	.size	__hip_cuid_720ee620efe0ab77, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_720ee620efe0ab77
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
  - .agpr_count:     84
    .args:
      - .offset:         0
        .size:           112
        .value_kind:     by_value
    .group_segment_fixed_size: 40960
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_4GeluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     244
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
