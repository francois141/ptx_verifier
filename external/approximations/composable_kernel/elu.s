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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
	.protected	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.globl	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
	.p2align	8
	.type	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,@function
_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE:
	s_load_dwordx8 s[12:19], s[0:1], 0x10
	s_load_dwordx2 s[8:9], s[0:1], 0x68
	s_waitcnt lgkmcnt(0)
	s_load_dword s19, s[0:1], 0x70
	s_load_dword s23, s[0:1], 0x3c
	s_load_dwordx4 s[4:7], s[0:1], 0x58
	s_cmp_gt_i32 s18, 1
	s_cselect_b64 s[10:11], -1, 0
	s_waitcnt lgkmcnt(0)
	s_bitcmp1_b32 s19, 0
	s_cselect_b64 s[20:21], -1, 0
	s_and_b64 s[10:11], s[10:11], s[20:21]
	s_andn2_b64 vcc, exec, s[10:11]
	s_mov_b64 s[10:11], 0
	s_cbranch_vccnz .LBB1_2
	s_mul_i32 s10, s12, s3
	s_mul_i32 s10, s10, s13
	s_ashr_i32 s11, s10, 31
.LBB1_2:
	s_load_dword s24, s[0:1], 0x34
	s_add_i32 s22, s12, -1
	s_cmp_lt_u32 s22, 64
	s_mov_b32 s20, 0
	s_cbranch_scc1 .LBB1_10
	s_add_i32 s19, s13, -1
	s_cmpk_lt_u32 s19, 0x100
	s_mov_b32 s19, 0
	s_cbranch_scc1 .LBB1_9
	s_add_i32 s19, s12, 63
	s_ashr_i32 s20, s19, 31
	s_lshr_b32 s20, s20, 26
	s_add_i32 s19, s19, s20
	s_ashr_i32 s25, s19, 6
	s_add_i32 s19, s13, 0xff
	s_ashr_i32 s20, s19, 31
	s_lshr_b32 s20, s20, 24
	s_add_i32 s19, s19, s20
	s_ashr_i32 s19, s19, 8
	s_mul_i32 s20, s19, s25
	s_add_i32 s21, s20, 7
	s_ashr_i32 s26, s21, 31
	s_lshr_b32 s26, s26, 29
	s_add_i32 s21, s21, s26
	s_ashr_i32 s26, s21, 3
	s_and_b32 s21, s21, -8
	s_sub_i32 s27, s20, s21
	s_ashr_i32 s20, s2, 31
	s_lshr_b32 s20, s20, 29
	s_add_i32 s29, s2, s20
	s_and_b32 s20, s29, -8
	s_add_i32 s27, s27, 8
	s_sub_i32 s28, s2, s20
	s_cmp_gt_i32 s28, s27
	s_cbranch_scc1 .LBB1_6
	s_mul_i32 s2, s26, s28
	s_ashr_i32 s20, s29, 3
	s_cbranch_execz .LBB1_7
	s_branch .LBB1_8
.LBB1_6:
	s_ashr_i32 s20, s29, 3
.LBB1_7:
	s_add_i32 s2, s26, -1
	s_mul_i32 s2, s2, s28
	s_add_i32 s2, s27, s2
.LBB1_8:
	s_abs_i32 s21, s19
	v_cvt_f32_u32_e32 v1, s21
	s_sub_i32 s27, 0, s21
	s_add_i32 s2, s2, s20
	s_abs_i32 s26, s2
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s20, s2, s19
	s_ashr_i32 s20, s20, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s28, v1
	s_mul_i32 s27, s27, s28
	s_mul_hi_u32 s27, s28, s27
	s_add_i32 s28, s28, s27
	s_mul_hi_u32 s27, s26, s28
	s_mul_i32 s28, s27, s21
	s_sub_i32 s26, s26, s28
	s_add_i32 s29, s27, 1
	s_sub_i32 s28, s26, s21
	s_cmp_ge_u32 s26, s21
	s_cselect_b32 s27, s29, s27
	s_cselect_b32 s26, s28, s26
	s_add_i32 s28, s27, 1
	s_cmp_ge_u32 s26, s21
	s_cselect_b32 s21, s28, s27
	s_xor_b32 s21, s21, s20
	s_lshr_b32 s26, s25, 30
	s_sub_i32 s20, s21, s20
	s_add_i32 s26, s25, s26
	s_mul_i32 s21, s20, s19
	s_sub_i32 s2, s2, s21
	s_and_b32 s21, s26, -4
	s_sub_i32 s25, s25, s21
	s_cmp_ge_i32 s20, s21
	s_cselect_b32 s21, s25, 4
	s_abs_i32 s26, s21
	v_cvt_f32_u32_e32 v1, s26
	s_ashr_i32 s25, s20, 31
	s_lshr_b32 s25, s25, 30
	s_add_i32 s25, s20, s25
	v_rcp_iflag_f32_e32 v1, v1
	s_and_b32 s25, s25, -4
	s_sub_i32 s25, s20, s25
	s_sub_i32 s28, 0, s26
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s19, s25, s19
	s_add_i32 s2, s19, s2
	s_abs_i32 s27, s2
	v_readfirstlane_b32 s29, v1
	s_mul_i32 s28, s28, s29
	s_mul_hi_u32 s28, s29, s28
	s_add_i32 s29, s29, s28
	s_mul_hi_u32 s28, s27, s29
	s_mul_i32 s29, s28, s26
	s_xor_b32 s19, s2, s21
	s_sub_i32 s27, s27, s29
	s_ashr_i32 s19, s19, 31
	s_add_i32 s29, s28, 1
	s_sub_i32 s30, s27, s26
	s_cmp_ge_u32 s27, s26
	s_cselect_b32 s28, s29, s28
	s_cselect_b32 s27, s30, s27
	s_add_i32 s29, s28, 1
	s_cmp_ge_u32 s27, s26
	s_cselect_b32 s26, s29, s28
	s_xor_b32 s26, s26, s19
	s_sub_i32 s19, s26, s19
	s_mul_i32 s21, s19, s21
	s_sub_i32 s2, s2, s21
	s_add_i32 s2, s2, s20
	s_sub_i32 s2, s2, s25
.LBB1_9:
	s_mov_b32 s20, s2
	s_mov_b32 s2, s19
.LBB1_10:
	s_load_dword s19, s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s24, s3
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[26:27], s[0:1], 2
	s_add_u32 s0, s4, s26
	s_addc_u32 s1, s5, s27
	s_add_u32 s4, s6, s26
	s_addc_u32 s5, s7, s27
	s_add_i32 s18, s18, -1
	s_mul_i32 s21, s18, s24
	v_lshrrev_b32_e32 v123, 2, v0
	s_add_i32 s7, s13, 0x3fffffff
	s_sub_i32 s14, s14, s21
	v_and_b32_e32 v127, 7, v0
	v_and_b32_e32 v1, 62, v123
	s_cmp_lt_u32 s3, s18
	v_bitop3_b32 v155, v123, v127, 6 bitop3:0x6c
	v_lshlrev_b32_e32 v3, 5, v1
	s_cselect_b32 s21, s24, s14
	s_lshl_b32 s14, s2, 8
	v_lshl_or_b32 v10, v155, 2, v3
	v_and_b32_e32 v3, 0xf8, v0
	v_lshl_or_b32 v122, s20, 6, v1
	v_or_b32_e32 v150, s14, v3
	v_lshlrev_b32_e32 v2, 2, v127
	v_mul_lo_u32 v154, v122, s15
	v_mul_lo_u32 v152, v150, s16
	s_ashr_i32 s2, s23, 31
	v_add_u32_e32 v6, v154, v2
	v_add_u32_e32 v8, v152, v2
	v_lshl_or_b32 v9, v3, 5, v2
	v_and_b32_e32 v124, 15, v0
	v_lshrrev_b32_e32 v2, 3, v0
	v_and_b32_e32 v126, 16, v123
	s_lshr_b32 s2, s2, 29
	s_mul_i32 s6, s22, s15
	s_mul_i32 s7, s7, s16
	v_and_b32_e32 v7, 6, v123
	v_lshrrev_b32_e32 v125, 7, v0
	v_and_b32_e32 v82, 6, v2
	v_bitop3_b32 v83, v2, v127, 6 bitop3:0x6c
	v_or_b32_e32 v84, v126, v124
	s_add_i32 s23, s23, s2
	s_ashr_i32 s18, s23, 3
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
	ds_write_b32 v40, a62 offset:1024
	ds_write_b32 v40, a63 offset:1536
	ds_write_b32 v40, a55 offset:1664
	ds_write_b32 v40, a54 offset:1152
	ds_write_b32 v40, a53 offset:640
	ds_write_b32 v40, a52 offset:128
	s_nop 3
	ds_write_b32 v40, a48 offset:256
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v54, a[36:39]
	v_mfma_f32_16x16x4_f32 a[8:11], v66, v82, a[32:35]
	v_mfma_f32_16x16x4_f32 a[32:35], v5, v73, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v62, a[24:27]
	v_mfma_f32_16x16x4_f32 a[40:43], v108, v92, a[40:43]
	v_mfma_f32_16x16x4_f32 a[0:3], v67, v55, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v63, a[16:19]
	v_mfma_f32_16x16x4_f32 a[40:43], v109, v93, a[40:43]
	v_mfma_f32_16x16x4_f32 a[20:23], v106, v86, a[20:23]
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v56, a[0:3]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v64, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v107, v87, a[20:23]
	v_mfma_f32_16x16x4_f32 a[36:39], v69, v57, a[0:3]
	ds_write_b32 v40, a49 offset:768
	ds_write_b32 v40, a50 offset:1280
	ds_write_b32 v40, a51 offset:1792
	s_nop 6
	ds_write_b32 v40, a39 offset:1920
	ds_write_b32 v40, a38 offset:1408
	ds_write_b32 v40, a37 offset:896
	ds_write_b32 v40, a36 offset:384
	v_mfma_f32_16x16x4_f32 a[0:3], v66, v42, a[40:43]
	v_mfma_f32_16x16x4_f32 a[40:43], v5, v65, a[16:19]
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v54, a[44:47]
	v_mfma_f32_16x16x4_f32 a[20:23], v108, v88, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v3, v55, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v109, v89, a[20:23]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v56, a[16:19]
	v_mfma_f32_16x16x4_f32 a[12:15], v66, v74, a[20:23]
	v_mfma_f32_16x16x4_f32 a[44:47], v5, v57, a[16:19]
	s_nop 7
	s_nop 1
	ds_write_b32 v40, a44 offset:16768
	ds_write_b32 v40, a45 offset:17280
	ds_write_b32 v40, a46 offset:17792
	ds_write_b32 v40, a47 offset:18304
	ds_write_b32 v40, a43 offset:18176
	ds_write_b32 v40, a42 offset:17664
	ds_write_b32 v40, a41 offset:17152
	v_mfma_f32_16x16x4_f32 a[16:19], v2, v42, a[56:59]
	ds_write_b32 v40, a40 offset:16640
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
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e32 vcc, 0, v0
	v_mfma_f32_16x16x4_f32 a[0:3], v68, v44, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v68, v48, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v68, v84, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v68, v76, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v4, v44, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v4, v48, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v4, v84, a[24:27]
	v_mfma_f32_16x16x4_f32 a[30:33], v4, v76, a[36:39]
	v_mfma_f32_16x16x4_f32 a[0:3], v69, v45, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v69, v49, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v69, v85, a[8:11]
	v_mfma_f32_16x16x4_f32 a[12:15], v69, v77, a[12:15]
	v_mfma_f32_16x16x4_f32 a[16:19], v5, v45, a[16:19]
	v_mfma_f32_16x16x4_f32 a[20:23], v5, v49, a[20:23]
	v_mfma_f32_16x16x4_f32 a[24:27], v5, v85, a[24:27]
	v_mfma_f32_16x16x4_f32 a[28:31], v5, v77, a[30:33]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB1_94
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v1
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB1_95
.LBB1_14:
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v2
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB1_96
.LBB1_15:
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v3
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_17
.LBB1_16:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v7, 0x3ab69700
	v_fmac_f32_e32 v7, 0x395133b1, v5
	v_fmaak_f32 v7, v5, v7, 0x3c0887f9
	v_fmaak_f32 v7, v5, v7, 0x3d2aaa81
	v_fmaak_f32 v7, v5, v7, 0x3e2aaaab
	v_fma_f32 v7, v5, v7, 0.5
	v_mul_f32_e32 v7, v7, v5
	v_fmac_f32_e32 v5, v5, v7
	v_cvt_i32_f32_e32 v7, v4
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v8, 0x7f
	v_cmp_eq_f32_e32 vcc, s2, v4
	s_mov_b32 s2, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v7, v8, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v7, -1.0, v4
	v_fmac_f32_e32 v7, v4, v5
	v_add_f32_e32 v4, v7, v7
	v_cndmask_b32_e32 v4, v7, v4, vcc
	v_cmp_le_f32_e32 vcc, s2, v3
	s_nop 1
	v_cndmask_b32_e32 v3, -1.0, v4, vcc
	v_mul_f32_e32 v3, s19, v3
.LBB1_17:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v36, s14, v6
	v_mad_u64_u32 v[38:39], s[0:1], v122, s17, v[36:37]
	s_lshl_b64 s[0:1], s[10:11], 2
	s_add_u32 s20, s8, s0
	s_addc_u32 s21, s9, s1
	s_mul_i32 s0, s22, s17
	s_mul_hi_u32 s1, 0, s17
	ds_read_b128 v[4:7], v37 offset:16
	s_add_i32 s1, s1, s0
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
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[0:1], 0, v4
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB1_97
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v5
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB1_98
.LBB1_19:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v6
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB1_99
.LBB1_20:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v7
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB1_22
.LBB1_21:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v7
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v7, s19, v0
.LBB1_22:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v0, 4, v36
	v_cmp_gt_i32_e64 s[4:5], s13, v0
	ds_read_b128 v[0:3], v37 offset:32
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[0:1], vcc, s[4:5]
	v_cndmask_b32_e64 v8, v8, 0, s[0:1]
	v_add_u32_e32 v8, v39, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[0:1], 0, v0
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:16
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execnz .LBB1_100
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v1
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execnz .LBB1_101
.LBB1_24:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v2
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execnz .LBB1_102
.LBB1_25:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v3
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB1_27
.LBB1_26:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v3
	s_nop 1
	v_cndmask_b32_e64 v3, -1.0, v4, s[0:1]
	v_mul_f32_e32 v3, s19, v3
.LBB1_27:
	s_or_b64 exec, exec, s[6:7]
	v_or_b32_e32 v4, 8, v36
	v_cmp_gt_i32_e64 s[6:7], s13, v4
	ds_read_b128 v[4:7], v37 offset:48
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[0:1], vcc, s[6:7]
	v_cndmask_b32_e64 v8, v8, 0, s[0:1]
	v_add_u32_e32 v8, v39, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[0:1], 0, v4
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen offset:32
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execnz .LBB1_103
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v5
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execnz .LBB1_104
.LBB1_29:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v6
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execnz .LBB1_105
.LBB1_30:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v7
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execz .LBB1_32
.LBB1_31:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v7
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v7, s19, v0
.LBB1_32:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v0, 12, v36
	v_cmp_gt_i32_e64 s[8:9], s13, v0
	ds_read_b128 v[0:3], v37 offset:560
	v_bfrev_b32_e32 v9, 1
	s_and_b64 s[0:1], vcc, s[8:9]
	v_add_u32_e32 v8, 12, v38
	v_cndmask_b32_e64 v9, v9, 0, s[0:1]
	v_lshl_add_u32 v9, v8, 2, v9
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[0:1], 0, v0
	buffer_store_dwordx4 v[4:7], v9, s[20:23], 0 offen
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execnz .LBB1_106
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v1
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execnz .LBB1_107
.LBB1_34:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v2
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execnz .LBB1_108
.LBB1_35:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v3
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB1_37
.LBB1_36:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v3
	s_nop 1
	v_cndmask_b32_e64 v3, -1.0, v4, s[0:1]
	v_mul_f32_e32 v3, s19, v3
.LBB1_37:
	s_or_b64 exec, exec, s[10:11]
	v_add_lshl_u32 v12, v8, s17, 2
	ds_read_b128 v[8:11], v37 offset:544
	v_or_b32_e32 v4, 1, v122
	v_cmp_gt_i32_e64 s[0:1], s12, v4
	v_bfrev_b32_e32 v4, 1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v4, v4, 0, s[8:9]
	v_add_u32_e32 v4, v12, v4
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[8:9], 0, v8
	buffer_store_dwordx4 v[0:3], v4, s[20:23], 0 offen
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_109
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v9
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_110
.LBB1_39:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v10
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_111
.LBB1_40:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v11
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_42
.LBB1_41:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v11
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v11
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[8:9]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v11
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[8:9]
	v_mul_f32_e32 v11, s19, v0
.LBB1_42:
	s_or_b64 exec, exec, s[10:11]
	ds_read_b128 v[4:7], v37 offset:528
	v_mov_b32_e32 v0, 0x7ffffff0
	s_and_b64 s[6:7], s[6:7], s[0:1]
	v_cndmask_b32_e64 v0, v0, -16, s[6:7]
	v_add_u32_e32 v0, v12, v0
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[6:7], 0, v4
	buffer_store_dwordx4 v[8:11], v0, s[20:23], 0 offen
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_112
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v5
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_113
.LBB1_44:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v6
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_114
.LBB1_45:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v7
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_47
.LBB1_46:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v7
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v7, s19, v0
.LBB1_47:
	s_or_b64 exec, exec, s[8:9]
	ds_read_b128 v[0:3], v37 offset:512
	v_mov_b32_e32 v8, 0x7fffffe0
	v_not_b32_e32 v9, 31
	s_and_b64 s[4:5], s[4:5], s[0:1]
	v_cndmask_b32_e64 v8, v8, v9, s[4:5]
	v_add_u32_e32 v8, v12, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[4:5], 0, v0
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_115
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v1
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_116
.LBB1_49:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v2
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_51
.LBB1_50:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v2
	s_nop 1
	v_cndmask_b32_e64 v2, -1.0, v4, s[4:5]
	v_mul_f32_e32 v2, s19, v2
.LBB1_51:
	s_or_b64 exec, exec, s[6:7]
	v_accvgpr_read_b32 v31, a3
	v_accvgpr_read_b32 v35, a7
	v_accvgpr_read_b32 v23, a11
	v_accvgpr_read_b32 v27, a15
	v_accvgpr_read_b32 v4, a16
	v_accvgpr_read_b32 v8, a20
	v_accvgpr_read_b32 v12, a24
	v_accvgpr_read_b32 v16, a28
	v_accvgpr_read_b32 v30, a2
	v_accvgpr_read_b32 v29, a1
	v_accvgpr_read_b32 v28, a0
	v_accvgpr_read_b32 v34, a6
	v_accvgpr_read_b32 v33, a5
	v_accvgpr_read_b32 v32, a4
	v_accvgpr_read_b32 v22, a10
	v_accvgpr_read_b32 v21, a9
	v_accvgpr_read_b32 v20, a8
	v_accvgpr_read_b32 v26, a14
	v_accvgpr_read_b32 v25, a13
	v_accvgpr_read_b32 v24, a12
	v_accvgpr_read_b32 v5, a17
	v_accvgpr_read_b32 v6, a18
	v_accvgpr_read_b32 v7, a19
	v_accvgpr_read_b32 v9, a21
	v_accvgpr_read_b32 v10, a22
	v_accvgpr_read_b32 v11, a23
	v_accvgpr_read_b32 v13, a25
	v_accvgpr_read_b32 v14, a26
	v_accvgpr_read_b32 v15, a27
	v_accvgpr_read_b32 v17, a29
	v_accvgpr_read_b32 v18, a30
	v_accvgpr_read_b32 v19, a31
	v_cmp_ge_f32_e64 s[4:5], 0, v3
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_53
	v_mul_f32_e32 v41, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v41, v41
	v_fmamk_f32 v42, v41, 0xbf317218, v3
	v_fmamk_f32 v42, v41, 0x3102e308, v42
	v_mov_b32_e32 v43, 0x3ab69700
	v_fmac_f32_e32 v43, 0x395133b1, v42
	v_fmaak_f32 v43, v42, v43, 0x3c0887f9
	v_fmaak_f32 v43, v42, v43, 0x3d2aaa81
	v_fmaak_f32 v43, v42, v43, 0x3e2aaaab
	v_fma_f32 v43, v42, v43, 0.5
	v_mul_f32_e32 v43, v43, v42
	v_fmac_f32_e32 v42, v42, v43
	v_cvt_i32_f32_e32 v43, v41
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v44, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v41
	s_nop 1
	v_cndmask_b32_e64 v41, v43, v44, s[4:5]
	v_ldexp_f32 v41, 1.0, v41
	v_add_f32_e32 v43, -1.0, v41
	v_fmac_f32_e32 v43, v41, v42
	v_add_f32_e32 v41, v43, v43
	v_cndmask_b32_e64 v41, v43, v41, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v3
	s_nop 1
	v_cndmask_b32_e64 v3, -1.0, v41, s[4:5]
	v_mul_f32_e32 v3, s19, v3
.LBB1_53:
	s_or_b64 exec, exec, s[6:7]
	v_bfrev_b32_e32 v41, 1
	s_and_b64 s[2:3], s[2:3], s[0:1]
	v_add_lshl_u32 v38, v38, s17, 2
	v_cndmask_b32_e64 v41, v41, 0, s[2:3]
	v_add_u32_e32 v41, v41, v38
	buffer_store_dwordx4 v[0:3], v41, s[20:23], 0 offen
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_add_u32_e32 v0, 0x400, v40
	ds_write2_b32 v0, v31, v35 offset0:128 offset1:160
	ds_write2_b32 v0, v30, v34 offset1:32
	ds_write2_b32 v40, v29, v33 offset0:128 offset1:160
	ds_write2_b32 v40, v28, v32 offset1:32
	ds_write2_b32 v0, v23, v27 offset0:192 offset1:224
	ds_write2_b32 v0, v22, v26 offset0:64 offset1:96
	ds_write2_b32 v40, v21, v25 offset0:192 offset1:224
	ds_write2_b32 v40, v20, v24 offset0:64 offset1:96
	v_add_u32_e32 v0, 0x4400, v40
	v_add_u32_e32 v1, 0x4000, v40
	ds_write2_b32 v0, v15, v19 offset0:192 offset1:224
	ds_write2_b32 v0, v14, v18 offset0:64 offset1:96
	ds_write2_b32 v1, v13, v17 offset0:192 offset1:224
	ds_write2_b32 v1, v12, v16 offset0:64 offset1:96
	ds_write2_b32 v0, v7, v11 offset0:128 offset1:160
	ds_write2_b32 v0, v6, v10 offset1:32
	ds_write2_b32 v1, v5, v9 offset0:128 offset1:160
	ds_write2_b32 v1, v4, v8 offset1:32
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[4:7], v37
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[2:3], 0, v4
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execnz .LBB1_117
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v5
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execnz .LBB1_118
.LBB1_55:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v6
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execnz .LBB1_119
.LBB1_56:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v7
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB1_58
.LBB1_57:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[2:3], s2, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[2:3]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[2:3]
	s_mov_b32 s2, 0xc1880000
	v_cmp_le_f32_e64 s[2:3], s2, v7
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[2:3]
	v_mul_f32_e32 v7, s19, v0
.LBB1_58:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v0, 0x80, v36
	v_cmp_gt_i32_e64 s[2:3], s13, v0
	ds_read_b128 v[0:3], v37 offset:16
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[4:5], vcc, s[2:3]
	v_add_u32_e32 v12, 0x200, v39
	v_cndmask_b32_e64 v8, v8, 0, s[4:5]
	v_add_u32_e32 v8, v12, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[4:5], 0, v0
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_120
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v1
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_121
.LBB1_60:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v2
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_122
.LBB1_61:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v3
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_63
.LBB1_62:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v3
	s_nop 1
	v_cndmask_b32_e64 v3, -1.0, v4, s[4:5]
	v_mul_f32_e32 v3, s19, v3
.LBB1_63:
	s_or_b64 exec, exec, s[6:7]
	v_or_b32_e32 v4, 0x84, v36
	v_cmp_gt_i32_e64 s[4:5], s13, v4
	ds_read_b128 v[4:7], v37 offset:32
	v_mov_b32_e32 v8, 0x80000010
	s_and_b64 s[6:7], vcc, s[4:5]
	v_cndmask_b32_e64 v8, v8, 16, s[6:7]
	v_add_u32_e32 v8, v8, v12
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[6:7], 0, v4
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_123
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v5
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_124
.LBB1_65:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v6
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_125
.LBB1_66:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v7
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_68
.LBB1_67:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v7
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v7, s19, v0
.LBB1_68:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v0, 0x88, v36
	v_cmp_gt_i32_e64 s[6:7], s13, v0
	ds_read_b128 v[0:3], v37 offset:48
	v_mov_b32_e32 v8, 0x80000020
	s_and_b64 s[8:9], vcc, s[6:7]
	v_cndmask_b32_e64 v8, v8, 32, s[8:9]
	v_add_u32_e32 v8, v8, v12
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e64 s[8:9], 0, v0
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_126
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v1
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_127
.LBB1_70:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v2
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_128
.LBB1_71:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v3
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_73
.LBB1_72:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[8:9]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v3
	s_nop 1
	v_cndmask_b32_e64 v3, -1.0, v4, s[8:9]
	v_mul_f32_e32 v3, s19, v3
.LBB1_73:
	s_or_b64 exec, exec, s[10:11]
	ds_read_b128 v[8:11], v37 offset:560
	v_or_b32_e32 v4, 0x8c, v36
	v_cmp_gt_i32_e64 s[8:9], s13, v4
	v_mov_b32_e32 v4, 0x80000030
	s_and_b64 s[10:11], vcc, s[8:9]
	v_cndmask_b32_e64 v4, v4, 48, s[10:11]
	v_add_u32_e32 v4, v4, v12
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e32 vcc, 0, v8
	buffer_store_dwordx4 v[0:3], v4, s[20:23], 0 offen
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execnz .LBB1_129
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v9
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execnz .LBB1_130
.LBB1_75:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v10
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execnz .LBB1_131
.LBB1_76:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v11
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB1_78
.LBB1_77:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v11
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v11
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s12, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s12, v0
	s_mov_b32 s12, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s12, v11
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v11, s19, v0
.LBB1_78:
	s_or_b64 exec, exec, s[10:11]
	ds_read_b128 v[4:7], v37 offset:544
	v_bfrev_b32_e32 v0, 1
	s_and_b64 s[8:9], s[0:1], s[8:9]
	v_cndmask_b32_e64 v0, v0, 0, s[8:9]
	v_add_u32_e32 v0, v38, v0
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e32 vcc, 0, v4
	buffer_store_dwordx4 v[8:11], v0, s[20:23], 0 offen offset:560
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execnz .LBB1_132
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v5
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execnz .LBB1_133
.LBB1_80:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v6
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execnz .LBB1_134
.LBB1_81:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v7
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_83
.LBB1_82:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s10, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s10, v0
	s_mov_b32 s10, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s10, v7
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v7, s19, v0
.LBB1_83:
	s_or_b64 exec, exec, s[8:9]
	ds_read_b128 v[0:3], v37 offset:528
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[6:7], s[6:7], s[0:1]
	v_cndmask_b32_e64 v8, v8, 0, s[6:7]
	v_add_u32_e32 v8, v38, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e32 vcc, 0, v0
	buffer_store_dwordx4 v[4:7], v8, s[20:23], 0 offen offset:544
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execnz .LBB1_135
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v1
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execnz .LBB1_136
.LBB1_85:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v2
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execnz .LBB1_137
.LBB1_86:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v3
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_88
.LBB1_87:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v3
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v3
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e32 vcc, s8, v4
	s_mov_b32 s8, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v6, v7, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e32 v4, v6, v4, vcc
	v_cmp_le_f32_e32 vcc, s8, v3
	s_nop 1
	v_cndmask_b32_e32 v3, -1.0, v4, vcc
	v_mul_f32_e32 v3, s19, v3
.LBB1_88:
	s_or_b64 exec, exec, s[6:7]
	ds_read_b128 v[4:7], v37 offset:512
	v_bfrev_b32_e32 v8, 1
	s_and_b64 s[4:5], s[4:5], s[0:1]
	v_cndmask_b32_e64 v8, v8, 0, s[4:5]
	v_add_u32_e32 v8, v38, v8
	s_waitcnt lgkmcnt(0)
	v_cmp_ge_f32_e32 vcc, 0, v4
	buffer_store_dwordx4 v[0:3], v8, s[20:23], 0 offen offset:528
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execnz .LBB1_138
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v5
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execnz .LBB1_139
.LBB1_90:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v6
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execnz .LBB1_140
.LBB1_91:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v7
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_93
.LBB1_92:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v7
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v7
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s6, v0
	s_mov_b32 s6, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s6, v7
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v7, s19, v0
.LBB1_93:
	s_or_b64 exec, exec, s[4:5]
	v_bfrev_b32_e32 v0, 1
	s_and_b64 s[0:1], s[2:3], s[0:1]
	v_cndmask_b32_e64 v0, v0, 0, s[0:1]
	v_add_u32_e32 v0, v38, v0
	buffer_store_dwordx4 v[4:7], v0, s[20:23], 0 offen offset:512
	s_endpgm
.LBB1_94:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v7, 0x3ab69700
	v_fmac_f32_e32 v7, 0x395133b1, v5
	v_fmaak_f32 v7, v5, v7, 0x3c0887f9
	v_fmaak_f32 v7, v5, v7, 0x3d2aaa81
	v_fmaak_f32 v7, v5, v7, 0x3e2aaaab
	v_fma_f32 v7, v5, v7, 0.5
	v_mul_f32_e32 v7, v7, v5
	v_fmac_f32_e32 v5, v5, v7
	v_cvt_i32_f32_e32 v7, v4
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v8, 0x7f
	v_cmp_eq_f32_e32 vcc, s2, v4
	s_mov_b32 s2, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v7, v8, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v7, -1.0, v4
	v_fmac_f32_e32 v7, v4, v5
	v_add_f32_e32 v4, v7, v7
	v_cndmask_b32_e32 v4, v7, v4, vcc
	v_cmp_le_f32_e32 vcc, s2, v0
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v4, vcc
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v1
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_14
.LBB1_95:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v7, 0x3ab69700
	v_fmac_f32_e32 v7, 0x395133b1, v5
	v_fmaak_f32 v7, v5, v7, 0x3c0887f9
	v_fmaak_f32 v7, v5, v7, 0x3d2aaa81
	v_fmaak_f32 v7, v5, v7, 0x3e2aaaab
	v_fma_f32 v7, v5, v7, 0.5
	v_mul_f32_e32 v7, v7, v5
	v_fmac_f32_e32 v5, v5, v7
	v_cvt_i32_f32_e32 v7, v4
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v8, 0x7f
	v_cmp_eq_f32_e32 vcc, s2, v4
	s_mov_b32 s2, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v7, v8, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v7, -1.0, v4
	v_fmac_f32_e32 v7, v4, v5
	v_add_f32_e32 v4, v7, v7
	v_cndmask_b32_e32 v4, v7, v4, vcc
	v_cmp_le_f32_e32 vcc, s2, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1.0, v4, vcc
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v2
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_15
.LBB1_96:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v7, 0x3ab69700
	v_fmac_f32_e32 v7, 0x395133b1, v5
	v_fmaak_f32 v7, v5, v7, 0x3c0887f9
	v_fmaak_f32 v7, v5, v7, 0x3d2aaa81
	v_fmaak_f32 v7, v5, v7, 0x3e2aaaab
	v_fma_f32 v7, v5, v7, 0.5
	v_mul_f32_e32 v7, v7, v5
	v_fmac_f32_e32 v5, v5, v7
	v_cvt_i32_f32_e32 v7, v4
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v8, 0x7f
	v_cmp_eq_f32_e32 vcc, s2, v4
	s_mov_b32 s2, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v7, v8, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v7, -1.0, v4
	v_fmac_f32_e32 v7, v4, v5
	v_add_f32_e32 v4, v7, v7
	v_cndmask_b32_e32 v4, v7, v4, vcc
	v_cmp_le_f32_e32 vcc, s2, v2
	s_nop 1
	v_cndmask_b32_e32 v2, -1.0, v4, vcc
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[0:1]
	v_cmp_ge_f32_e32 vcc, 0, v3
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB1_16
	s_branch .LBB1_17
.LBB1_97:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v5
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB1_19
.LBB1_98:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v5
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v6
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB1_20
.LBB1_99:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v6
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[0:1], 0, v7
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB1_21
	s_branch .LBB1_22
.LBB1_100:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v4, s[0:1]
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v1
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB1_24
.LBB1_101:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -1.0, v4, s[0:1]
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v2
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB1_25
.LBB1_102:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v2
	s_nop 1
	v_cndmask_b32_e64 v2, -1.0, v4, s[0:1]
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[0:1], 0, v3
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execnz .LBB1_26
	s_branch .LBB1_27
.LBB1_103:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v5
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execz .LBB1_29
.LBB1_104:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v5
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v6
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execz .LBB1_30
.LBB1_105:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[0:1]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v6
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[0:1]
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[0:1], 0, v7
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execnz .LBB1_31
	s_branch .LBB1_32
.LBB1_106:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v4, s[0:1]
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v1
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB1_34
.LBB1_107:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -1.0, v4, s[0:1]
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v2
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB1_35
.LBB1_108:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s0, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[0:1], s0, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[0:1]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[0:1]
	s_mov_b32 s0, 0xc1880000
	v_cmp_le_f32_e64 s[0:1], s0, v2
	s_nop 1
	v_cndmask_b32_e64 v2, -1.0, v4, s[0:1]
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[0:1], 0, v3
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execnz .LBB1_36
	s_branch .LBB1_37
.LBB1_109:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v8
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v8
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[8:9]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v8
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[8:9]
	v_mul_f32_e32 v8, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v9
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_39
.LBB1_110:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v9
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v9
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[8:9]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v9
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[8:9]
	v_mul_f32_e32 v9, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v10
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_40
.LBB1_111:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v10
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v10
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[8:9]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v10
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[8:9]
	v_mul_f32_e32 v10, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v11
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_41
	s_branch .LBB1_42
.LBB1_112:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v4
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v5
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_44
.LBB1_113:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v5
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v6
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_45
.LBB1_114:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v6
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v7
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_46
	s_branch .LBB1_47
.LBB1_115:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v4, s[4:5]
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v1
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_49
.LBB1_116:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -1.0, v4, s[4:5]
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v2
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_50
	s_branch .LBB1_51
.LBB1_117:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[2:3], s2, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[2:3]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[2:3]
	s_mov_b32 s2, 0xc1880000
	v_cmp_le_f32_e64 s[2:3], s2, v4
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[2:3]
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v5
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB1_55
.LBB1_118:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[2:3], s2, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[2:3]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[2:3]
	s_mov_b32 s2, 0xc1880000
	v_cmp_le_f32_e64 s[2:3], s2, v5
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[2:3]
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v6
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB1_56
.LBB1_119:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s2, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[2:3], s2, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[2:3]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[2:3]
	s_mov_b32 s2, 0xc1880000
	v_cmp_le_f32_e64 s[2:3], s2, v6
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[2:3]
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e64 s[2:3], 0, v7
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execnz .LBB1_57
	s_branch .LBB1_58
.LBB1_120:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v4, s[4:5]
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v1
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_60
.LBB1_121:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -1.0, v4, s[4:5]
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v2
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_61
.LBB1_122:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s4, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[4:5], s4, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[4:5]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[4:5]
	s_mov_b32 s4, 0xc1880000
	v_cmp_le_f32_e64 s[4:5], s4, v2
	s_nop 1
	v_cndmask_b32_e64 v2, -1.0, v4, s[4:5]
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e64 s[4:5], 0, v3
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execnz .LBB1_62
	s_branch .LBB1_63
.LBB1_123:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v4
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v5
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_65
.LBB1_124:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v5
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v6
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB1_66
.LBB1_125:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e64 s[6:7], s6, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v2, v3, s[6:7]
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e64 v0, v2, v0, s[6:7]
	s_mov_b32 s6, 0xc1880000
	v_cmp_le_f32_e64 s[6:7], s6, v6
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v0, s[6:7]
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e64 s[6:7], 0, v7
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execnz .LBB1_67
	s_branch .LBB1_68
.LBB1_126:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[8:9]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -1.0, v4, s[8:9]
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v1
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_70
.LBB1_127:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[8:9]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -1.0, v4, s[8:9]
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v2
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB1_71
.LBB1_128:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e64 s[8:9], s8, v4
	s_nop 1
	v_cndmask_b32_e64 v4, v6, v7, s[8:9]
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e64 v4, v6, v4, s[8:9]
	s_mov_b32 s8, 0xc1880000
	v_cmp_le_f32_e64 s[8:9], s8, v2
	s_nop 1
	v_cndmask_b32_e64 v2, -1.0, v4, s[8:9]
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e64 s[8:9], 0, v3
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execnz .LBB1_72
	s_branch .LBB1_73
.LBB1_129:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v8
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v8
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s12, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s12, v0
	s_mov_b32 s12, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s12, v8
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v8, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v9
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB1_75
.LBB1_130:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v9
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v9
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s12, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s12, v0
	s_mov_b32 s12, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s12, v9
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v9, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v10
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB1_76
.LBB1_131:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v10
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v10
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s12, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s12, v0
	s_mov_b32 s12, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s12, v10
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v10, s19, v0
	s_or_b64 exec, exec, s[10:11]
	v_cmp_ge_f32_e32 vcc, 0, v11
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execnz .LBB1_77
	s_branch .LBB1_78
.LBB1_132:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s10, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s10, v0
	s_mov_b32 s10, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s10, v4
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v5
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_80
.LBB1_133:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s10, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s10, v0
	s_mov_b32 s10, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s10, v5
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v6
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_81
.LBB1_134:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s10, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s10, v0
	s_mov_b32 s10, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s10, v6
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[8:9]
	v_cmp_ge_f32_e32 vcc, 0, v7
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execnz .LBB1_82
	s_branch .LBB1_83
.LBB1_135:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v0
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v0
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e32 vcc, s8, v4
	s_mov_b32 s8, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v6, v7, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e32 v4, v6, v4, vcc
	v_cmp_le_f32_e32 vcc, s8, v0
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v4, vcc
	v_mul_f32_e32 v0, s19, v0
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v1
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_85
.LBB1_136:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v1
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v1
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e32 vcc, s8, v4
	s_mov_b32 s8, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v6, v7, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e32 v4, v6, v4, vcc
	v_cmp_le_f32_e32 vcc, s8, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1.0, v4, vcc
	v_mul_f32_e32 v1, s19, v1
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v2
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_86
.LBB1_137:
	v_mul_f32_e32 v4, 0x3fb8aa3b, v2
	v_rndne_f32_e32 v4, v4
	v_fmamk_f32 v5, v4, 0xbf317218, v2
	v_fmamk_f32 v5, v4, 0x3102e308, v5
	v_mov_b32_e32 v6, 0x3ab69700
	v_fmac_f32_e32 v6, 0x395133b1, v5
	v_fmaak_f32 v6, v5, v6, 0x3c0887f9
	v_fmaak_f32 v6, v5, v6, 0x3d2aaa81
	v_fmaak_f32 v6, v5, v6, 0x3e2aaaab
	v_fma_f32 v6, v5, v6, 0.5
	v_mul_f32_e32 v6, v6, v5
	v_fmac_f32_e32 v5, v5, v6
	v_cvt_i32_f32_e32 v6, v4
	s_mov_b32 s8, 0x43000000
	v_mov_b32_e32 v7, 0x7f
	v_cmp_eq_f32_e32 vcc, s8, v4
	s_mov_b32 s8, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v4, v6, v7, vcc
	v_ldexp_f32 v4, 1.0, v4
	v_add_f32_e32 v6, -1.0, v4
	v_fmac_f32_e32 v6, v4, v5
	v_add_f32_e32 v4, v6, v6
	v_cndmask_b32_e32 v4, v6, v4, vcc
	v_cmp_le_f32_e32 vcc, s8, v2
	s_nop 1
	v_cndmask_b32_e32 v2, -1.0, v4, vcc
	v_mul_f32_e32 v2, s19, v2
	s_or_b64 exec, exec, s[6:7]
	v_cmp_ge_f32_e32 vcc, 0, v3
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execnz .LBB1_87
	s_branch .LBB1_88
.LBB1_138:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v4
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v4
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s6, v0
	s_mov_b32 s6, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s6, v4
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v4, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v5
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_90
.LBB1_139:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v5
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v5
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s6, v0
	s_mov_b32 s6, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s6, v5
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v5, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v6
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_91
.LBB1_140:
	v_mul_f32_e32 v0, 0x3fb8aa3b, v6
	v_rndne_f32_e32 v0, v0
	v_fmamk_f32 v1, v0, 0xbf317218, v6
	v_fmamk_f32 v1, v0, 0x3102e308, v1
	v_mov_b32_e32 v2, 0x3ab69700
	v_fmac_f32_e32 v2, 0x395133b1, v1
	v_fmaak_f32 v2, v1, v2, 0x3c0887f9
	v_fmaak_f32 v2, v1, v2, 0x3d2aaa81
	v_fmaak_f32 v2, v1, v2, 0x3e2aaaab
	v_fma_f32 v2, v1, v2, 0.5
	v_mul_f32_e32 v2, v2, v1
	v_fmac_f32_e32 v1, v1, v2
	v_cvt_i32_f32_e32 v2, v0
	s_mov_b32 s6, 0x43000000
	v_mov_b32_e32 v3, 0x7f
	v_cmp_eq_f32_e32 vcc, s6, v0
	s_mov_b32 s6, 0xc1880000
	s_nop 0
	v_cndmask_b32_e32 v0, v2, v3, vcc
	v_ldexp_f32 v0, 1.0, v0
	v_add_f32_e32 v2, -1.0, v0
	v_fmac_f32_e32 v2, v0, v1
	v_add_f32_e32 v0, v2, v2
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cmp_le_f32_e32 vcc, s6, v6
	s_nop 1
	v_cndmask_b32_e32 v0, -1.0, v0, vcc
	v_mul_f32_e32 v6, s19, v0
	s_or_b64 exec, exec, s[4:5]
	v_cmp_ge_f32_e32 vcc, 0, v7
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execnz .LBB1_92
	s_branch .LBB1_93
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
		.amdhsa_group_segment_fixed_size 40960
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 120
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
	.section	.text._ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,"axG",@progbits,_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE,comdat
.Lfunc_end1:
	.size	_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE, .Lfunc_end1-_ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE

	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_vgpr, 158
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.num_agpr, 84
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.numbered_sgpr, 31
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.private_seg_size, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_vcc, 1
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.uses_flat_scratch, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_dyn_sized_stack, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_recursion, 0
	.set _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.has_indirect_call, 0
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
	.long	4
	.size	c_element_op_size, 4

	.protected	c_element_op_align
	.type	c_element_op_align,@object
	.globl	c_element_op_align
	.p2align	2, 0x0
c_element_op_align:
	.long	4
	.size	c_element_op_align, 4

	.type	__hip_cuid_ddd80aea6bb698ab,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_ddd80aea6bb698ab
__hip_cuid_ddd80aea6bb698ab:
	.byte	0
	.size	__hip_cuid_ddd80aea6bb698ab, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_ddd80aea6bb698ab
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
        .size:           120
        .value_kind:     by_value
    .group_segment_fixed_size: 40960
    .kernarg_segment_align: 8
    .kernarg_segment_size: 120
    .max_flat_workgroup_size: 256
    .name:           _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE
    .private_segment_fixed_size: 0
    .sgpr_count:     37
    .sgpr_spill_count: 0
    .symbol:         _ZN2ck27kernel_gemm_xdl_cshuffle_v3INS_28GridwiseGemm_xdl_cshuffle_v3INS_13tensor_layout4gemm8RowMajorENS3_11ColumnMajorES4_fffffNS_16tensor_operation12element_wise11PassThroughES8_NS7_3EluELNS6_6device18GemmSpecializationE0ELi256ELi64ELi256ELi32ELi4ELi4ELi16ELi16ELi2ELi8ENS_8SequenceIJLi8ELi32ELi1EEEENSC_IJLi1ELi0ELi2EEEESE_Li2ELi4ELi4ELb0ELi0ESD_SE_SE_Li2ELi4ELi4ELb0ELi0ELi2ELi4ENSC_IJLi1ELi32ELi1ELi8EEEELi4ELNS_26BlockGemmPipelineSchedulerE0ELNS_24BlockGemmPipelineVersionE2EffLb0ELb0ELb0EEELb1ELNS_25InMemoryDataOperationEnumE0ELi1ELNS_10TailNumberE10EEEvNT_8ArgumentE.kd
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
