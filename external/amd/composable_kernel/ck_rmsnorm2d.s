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
	.section	.text._ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_,"axG",@progbits,_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_,comdat
	.protected	_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_
	.globl	_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_
	.p2align	8
	.type	_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_,@function
_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_:
	s_load_dwordx4 s[8:11], s[0:1], 0x48
	s_load_dwordx2 s[16:17], s[0:1], 0x0
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_mbcnt_lo_u32_b32 v1, -1, 0
	v_mbcnt_hi_u32_b32 v6, -1, v1
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s10, -1
	s_ashr_i32 s4, s3, 31
	s_add_u32 s22, s3, 1
	s_addc_u32 s23, s4, 0
	s_add_i32 s9, s9, -1
	s_mul_i32 s4, s9, s11
	s_mul_hi_i32 s3, s9, s11
	s_add_u32 s4, s22, s4
	s_addc_u32 s5, s23, s3
	v_cmp_lt_i64_e32 vcc, s[4:5], v[2:3]
	s_and_b64 s[6:7], vcc, exec
	v_readfirstlane_b32 s3, v0
	v_lshrrev_b32_e32 v3, 6, v6
	s_cselect_b32 s24, s4, 0x7fffffff
	v_and_b32_e32 v1, 63, v6
	s_lshr_b32 s4, s3, 8
	s_and_b32 s3, s3, 0xc0
	v_add_u32_e32 v3, s2, v3
	v_or_b32_e32 v2, s3, v1
	v_add_u32_e32 v4, s4, v3
	v_mad_u64_u32 v[8:9], s[2:3], v4, s11, v[2:3]
	v_cmp_gt_i32_e32 vcc, s10, v2
	v_mov_b32_e32 v4, 0
	v_lshlrev_b32_e32 v9, 2, v8
	v_mov_b32_e32 v5, 0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_2
	s_lshl_b32 s18, s24, 2
	s_mov_b32 s19, 0x20000
	buffer_load_dword v5, v9, s[16:19], 0 offen
.LBB1_2:
	s_or_b64 exec, exec, s[2:3]
	v_or_b32_e32 v7, 0x100, v2
	v_cmp_gt_i32_e64 s[2:3], s10, v7
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB1_4
	s_lshl_b32 s18, s24, 2
	s_mov_b32 s19, 0x20000
	buffer_load_dword v4, v9, s[16:19], 0 offen offset:1024
.LBB1_4:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v7, 0x200, v2
	v_cmp_gt_i32_e64 s[4:5], s10, v7
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_6
	s_lshl_b32 s18, s24, 2
	s_mov_b32 s19, 0x20000
	buffer_load_dword v8, v9, s[16:19], 0 offen offset:2048
.LBB1_6:
	s_or_b64 exec, exec, s[6:7]
	s_load_dwordx4 s[12:15], s[0:1], 0x18
	v_or_b32_e32 v10, 0x300, v2
	v_cmp_gt_i32_e64 s[6:7], s10, v10
	s_and_saveexec_b64 s[20:21], s[6:7]
	s_cbranch_execz .LBB1_8
	s_lshl_b32 s18, s24, 2
	s_mov_b32 s19, 0x20000
	buffer_load_dword v7, v9, s[16:19], 0 offen offset:3072
.LBB1_8:
	s_or_b64 exec, exec, s[20:21]
	v_mov_b32_e32 v9, 0
	v_lshlrev_b32_e32 v12, 2, v2
	v_mov_b32_e32 v2, 0
	s_and_saveexec_b64 s[16:17], vcc
	s_cbranch_execz .LBB1_10
	s_lshl_b32 s26, s10, 2
	s_mov_b32 s27, 0x20000
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s24, s12
	s_mov_b32 s25, s13
	buffer_load_dword v2, v12, s[24:27], 0 offen
.LBB1_10:
	s_or_b64 exec, exec, s[16:17]
	s_and_saveexec_b64 s[16:17], s[2:3]
	s_cbranch_execz .LBB1_12
	s_lshl_b32 s26, s10, 2
	s_mov_b32 s27, 0x20000
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s24, s12
	s_mov_b32 s25, s13
	buffer_load_dword v9, v12, s[24:27], 0 offen offset:1024
.LBB1_12:
	s_or_b64 exec, exec, s[16:17]
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	s_and_saveexec_b64 s[2:3], s[4:5]
	s_cbranch_execz .LBB1_14
	s_lshl_b32 s18, s10, 2
	s_mov_b32 s19, 0x20000
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s16, s12
	s_mov_b32 s17, s13
	buffer_load_dword v11, v12, s[16:19], 0 offen offset:2048
.LBB1_14:
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[6:7]
	s_cbranch_execz .LBB1_16
	s_lshl_b32 s6, s10, 2
	s_mov_b32 s7, 0x20000
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s4, s12
	s_mov_b32 s5, s13
	buffer_load_dword v10, v12, s[4:7], 0 offen offset:3072
.LBB1_16:
	s_or_b64 exec, exec, s[2:3]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v12, v4, v4
	v_fmac_f32_e32 v12, v5, v5
	v_fmac_f32_e32 v12, v8, v8
	v_lshlrev_b32_e32 v13, 2, v6
	v_fmac_f32_e32 v12, v7, v7
	v_xor_b32_e32 v14, 4, v13
	ds_bpermute_b32 v14, v14, v12
	v_xor_b32_e32 v15, 8, v13
	s_load_dword s2, s[0:1], 0x5c
	v_readfirstlane_b32 s0, v0
	v_cmp_eq_u32_e32 vcc, 0, v6
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v12, v12, v14
	ds_bpermute_b32 v14, v15, v12
	v_xor_b32_e32 v15, 16, v13
	s_lshr_b32 s3, s0, 6
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_add_f32_e32 v12, v12, v14
	ds_bpermute_b32 v14, v15, v12
	v_xor_b32_e32 v15, 32, v13
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v12, v12, v14
	ds_bpermute_b32 v14, v15, v12
	v_xor_b32_e32 v15, 64, v13
	v_xor_b32_e32 v13, 0x80, v13
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v12, v12, v14
	ds_bpermute_b32 v14, v15, v12
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v12, v12, v14
	ds_bpermute_b32 v13, v13, v12
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_18
	s_lshl_b32 s4, s3, 2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, v12, v13
	v_mov_b32_e32 v12, s4
	ds_write_b32 v12, v6
.LBB1_18:
	s_or_b64 exec, exec, s[0:1]
	s_mul_hi_i32 s1, s9, s2
	s_mul_i32 s9, s9, s2
	s_add_u32 s0, s22, s9
	s_addc_u32 s1, s23, s1
	s_waitcnt lgkmcnt(0)
	v_mov_b64_e32 v[12:13], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[12:13]
	s_and_b64 s[4:5], vcc, exec
	v_cvt_f32_i32_e32 v16, s10
	s_cselect_b32 s0, s0, 0x7fffffff
	s_and_b32 s1, s3, 0x3fffffc
	s_lshl_b32 s1, s1, 2
	v_mov_b32_e32 v6, s1
	s_mov_b32 s1, 0x6f800000
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[12:13], v6 offset1:3
	ds_read2_b32 v[14:15], v6 offset0:1 offset1:2
	v_mov_b32_e32 v6, 0x2f800000
	v_cmp_gt_f32_e64 vcc, |v16|, s1
	v_readfirstlane_b32 s1, v0
	s_lshr_b32 s3, s1, 8
	v_cndmask_b32_e32 v6, 1.0, v6, vcc
	v_mul_f32_e32 v16, v16, v6
	v_rcp_f32_e32 v16, v16
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[12:13], v[14:15], v[12:13]
	s_and_b32 s1, s1, 0xc0
	v_add_f32_e32 v12, v12, v13
	v_mul_f32_e32 v12, v12, v16
	v_fma_f32 v6, v6, v12, s8
	v_rsq_f32_e32 v6, v6
	v_or_b32_e32 v0, s1, v1
	v_add_u32_e32 v1, s3, v3
	v_mul_lo_u32 v1, v1, s2
	v_mul_f32_e32 v5, v5, v6
	v_bfrev_b32_e32 v3, 1
	v_cmp_gt_i32_e32 vcc, s10, v0
	v_mul_f32_e32 v2, v2, v5
	v_mul_f32_e32 v4, v4, v6
	v_mul_f32_e32 v5, v8, v6
	v_mul_f32_e32 v6, v7, v6
	v_add_lshl_u32 v1, v1, v0, 2
	v_cndmask_b32_e64 v7, v3, 0, vcc
	s_lshl_b32 s2, s0, 2
	s_mov_b32 s3, 0x20000
	s_mov_b32 s0, s14
	s_mov_b32 s1, s15
	v_add_u32_e32 v7, v1, v7
	buffer_store_dword v2, v7, s[0:3], 0 offen
	v_or_b32_e32 v2, 0x100, v0
	v_cmp_gt_i32_e32 vcc, s10, v2
	v_mul_f32_e32 v4, v9, v4
	v_mul_f32_e32 v5, v11, v5
	v_cndmask_b32_e64 v2, v3, 0, vcc
	v_add_u32_e32 v2, v1, v2
	buffer_store_dword v4, v2, s[0:3], 0 offen offset:1024
	v_or_b32_e32 v2, 0x200, v0
	v_cmp_gt_i32_e32 vcc, s10, v2
	v_or_b32_e32 v0, 0x300, v0
	v_mul_f32_e32 v6, v10, v6
	v_cndmask_b32_e64 v2, v3, 0, vcc
	v_cmp_gt_i32_e32 vcc, s10, v0
	v_add_u32_e32 v2, v1, v2
	buffer_store_dword v5, v2, s[0:3], 0 offen offset:2048
	v_cndmask_b32_e64 v0, v3, 0, vcc
	v_add_u32_e32 v0, v1, v0
	buffer_store_dword v6, v0, s[0:3], 0 offen offset:3072
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 104
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
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 20
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
	.section	.text._ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_,"axG",@progbits,_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_,comdat
.Lfunc_end1:
	.size	_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_, .Lfunc_end1-_ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_

	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.num_vgpr, 17
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.num_agpr, 0
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.numbered_sgpr, 28
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.private_seg_size, 0
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.uses_vcc, 1
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.uses_flat_scratch, 0
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.has_dyn_sized_stack, 0
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.has_recursion, 0
	.set _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_1b98cb054ea62e22,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_1b98cb054ea62e22
__hip_cuid_1b98cb054ea62e22:
	.byte	0
	.size	__hip_cuid_1b98cb054ea62e22, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_1b98cb054ea62e22
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
        .size:           104
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 104
    .max_flat_workgroup_size: 256
    .name:           _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _ZN7ck_tile6kentryILi1ENS_12Rmsnorm2dFwdINS_27Rmsnorm2dFwdPipelineOnePassINS_27Rmsnorm2dFwdPipelineProblemIffffffffNS_19Generic2dBlockShapeINS_8sequenceIJLi1ELi1024EEEENS5_IJLi1ELi256EEEENS5_IJLi1ELi1EEEEEENS_18Rmsnorm2dFwdTraitsILb1ELb0ELb0ELb0ELNS_21Rmsnorm2dFusedAddEnumE0ELNS_23Rmsnorm2dFusedQuantEnumE0ELNS_22Rmsnorm2dSensitiveEnumE0EEEEENS_33Rmsnorm2dFwdPipelineDefaultPolicyEEENS_17Default2DEpilogueINS_24Default2DEpilogueProblemIffLb0ELb1ELb0EEEvEEEEJNSM_5KargsEEEEvDpT1_.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     17
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
