; Aiter 183a6ce66ebb csrc/kernels/fused_qk_norm.cu:26 (fused_qk_rmsnorm_kernel), dispatch :219, compiled for gfx950 by
; external/amd/aiter/build.py (case fused_qk_rmsnorm).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,"axG",@progbits,_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,comdat
	.protected	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
	.globl	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
	.p2align	8
	.type	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,@function
_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mov_b32 s18, s17
	s_load_dwordx4 s[20:23], s[0:1], 0x38
	s_mov_b32 s17, 0
	s_lshl_b64 s[24:25], s[16:17], 2
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s27, s20, 31
	s_mov_b32 s26, s20
	v_mov_b64_e32 v[2:3], s[26:27]
	v_cmp_ge_i64_e32 vcc, s[24:25], v[2:3]
	s_cbranch_vccnz .LBB0_11
	s_load_dwordx4 s[28:31], s[0:1], 0x48
	s_cmp_eq_u32 s18, 0
	v_mov_b32_e32 v1, s15
	v_mov_b32_e32 v2, s14
	s_cselect_b64 vcc, -1, 0
	v_cndmask_b32_e32 v26, v1, v2, vcc
	s_and_b64 s[0:1], vcc, exec
	s_cselect_b32 s17, s21, s22
	s_cselect_b32 s19, s7, s9
	s_cselect_b32 s18, s6, s8
	s_cselect_b32 s20, s3, s5
	s_cselect_b32 s21, s2, s4
	s_cselect_b32 s4, s10, s12
	s_cselect_b32 s5, s11, s13
	s_waitcnt lgkmcnt(0)
	s_cselect_b32 s2, s23, s28
	s_cselect_b32 s10, s29, s30
	s_ashr_i32 s3, s2, 31
	s_mul_i32 s0, s24, s3
	s_mul_hi_u32 s1, s24, s2
	s_add_i32 s0, s1, s0
	s_mul_i32 s1, s25, s2
	s_add_i32 s1, s0, s1
	s_mul_i32 s0, s24, s2
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s12, s18, s0
	s_addc_u32 s0, s19, s1
	s_add_i32 s1, s17, 1
	s_lshr_b32 s6, s1, 31
	s_add_i32 s1, s1, s6
	s_lshl_b32 s1, s1, 1
	s_and_b32 s6, s1, -4
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s7, 0x20000
	v_lshlrev_b32_e32 v27, 4, v0
	buffer_load_dwordx4 v[6:9], v27, s[4:7], 0 offen
	s_and_b32 s13, s0, 0xffff
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	buffer_load_dwordx4 v[2:5], v27, s[12:15], 0 offen sc0 nt
	v_and_b32_e32 v1, 63, v0
	v_lshrrev_b32_e32 v10, 4, v0
	v_and_b32_e32 v0, 1, v0
	s_mov_b64 s[8:9], 0
	v_cmp_eq_u32_e64 s[0:1], 63, v1
	v_and_b32_e32 v28, 60, v10
	v_lshlrev_b32_e32 v29, 2, v0
	v_cvt_f32_i32_e32 v30, s17
	s_mul_hi_u32 s5, s10, s16
	s_mul_i32 s4, s10, s16
	s_ashr_i32 s11, s10, 31
	s_mul_i32 s12, s11, s16
	s_add_i32 s5, s5, s12
	s_lshl_b64 s[4:5], s[4:5], 3
	s_add_u32 s16, s21, s4
	s_addc_u32 s17, s20, s5
	s_lshl_b64 s[10:11], s[10:11], 1
	s_add_u32 s4, s24, 1
	s_addc_u32 s5, s25, 0
	s_mul_hi_u32 s12, s4, s2
	s_mul_i32 s13, s4, s3
	s_mul_i32 s4, s4, s2
	s_add_i32 s12, s12, s13
	s_mul_i32 s5, s5, s2
	s_add_i32 s5, s12, s5
	s_lshl_b64 s[4:5], s[4:5], 1
	s_add_u32 s18, s18, s4
	s_addc_u32 s19, s19, s5
	s_lshl_b64 s[12:13], s[2:3], 1
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v1, 0xffff0000, v6
	v_lshlrev_b32_e32 v0, 16, v6
	v_and_b32_e32 v11, 0xffff0000, v7
	v_lshlrev_b32_e32 v10, 16, v7
	v_and_b32_e32 v13, 0xffff0000, v8
	v_lshlrev_b32_e32 v12, 16, v8
	v_and_b32_e32 v15, 0xffff0000, v9
	v_lshlrev_b32_e32 v14, 16, v9
	v_mov_b64_e32 v[16:17], s[26:27]
	s_branch .LBB0_3
.LBB0_2:
	s_cmp_eq_u32 s8, 3
	s_cselect_b64 s[4:5], -1, 0
	s_or_b64 s[2:3], s[2:3], s[4:5]
	s_add_u32 s8, s8, 1
	s_addc_u32 s9, s9, 0
	s_add_u32 s16, s16, s10
	s_addc_u32 s17, s17, s11
	s_add_u32 s18, s18, s12
	s_addc_u32 s19, s19, s13
	s_andn2_b64 vcc, exec, s[2:3]
	s_waitcnt vmcnt(0)
	v_mov_b64_e32 v[2:3], v[6:7]
	v_mov_b64_e32 v[4:5], v[8:9]
	s_cbranch_vccz .LBB0_11
.LBB0_3:
	s_add_u32 s4, s24, s8
	s_addc_u32 s5, s25, s9
	v_cmp_ge_i64_e64 s[2:3], s[4:5], v[16:17]
	v_cmp_lt_i64_e32 vcc, s[4:5], v[16:17]
	s_mov_b64 s[14:15], -1
	s_cbranch_vccz .LBB0_9
	s_cmp_lg_u32 s8, 3
	s_cselect_b64 s[14:15], -1, 0
	s_add_u32 s4, s4, 1
	s_addc_u32 s5, s5, 0
	v_mov_b64_e32 v[6:7], s[26:27]
	v_cmp_lt_i64_e32 vcc, s[4:5], v[6:7]
	s_and_b64 s[4:5], s[14:15], vcc
	s_andn2_b64 vcc, exec, s[4:5]
	s_waitcnt vmcnt(0)
	v_mov_b64_e32 v[8:9], v[4:5]
	v_mov_b64_e32 v[6:7], v[2:3]
	s_cbranch_vccnz .LBB0_6
	s_and_b32 s5, s19, 0xffff
	s_mov_b32 s4, s18
	buffer_load_dwordx4 v[6:9], v27, s[4:7], 0 offen sc0 nt
.LBB0_6:
	v_and_b32_e32 v19, 0xffff0000, v2
	v_lshlrev_b32_e32 v18, 16, v2
	v_and_b32_e32 v21, 0xffff0000, v3
	v_lshlrev_b32_e32 v20, 16, v3
	v_and_b32_e32 v23, 0xffff0000, v4
	v_lshlrev_b32_e32 v22, 16, v4
	v_and_b32_e32 v25, 0xffff0000, v5
	v_lshlrev_b32_e32 v24, 16, v5
	v_pk_mul_f32 v[32:33], v[18:19], v[18:19]
	v_pk_mul_f32 v[34:35], v[20:21], v[20:21]
	v_pk_mul_f32 v[36:37], v[22:23], v[22:23]
	v_pk_mul_f32 v[38:39], v[24:25], v[24:25]
	v_add_f32_e32 v31, v32, v33
	v_add_f32_e32 v31, v31, v34
	v_add_f32_e32 v31, v31, v35
	v_add_f32_e32 v31, v31, v36
	v_add_f32_e32 v31, v31, v37
	v_add_f32_e32 v31, v31, v38
	v_add_f32_e32 v31, v31, v39
	s_nop 1
	v_mov_b32_dpp v32, v31 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	s_nop 1
	v_mov_b32_dpp v32, v31 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	s_nop 1
	v_mov_b32_dpp v32, v31 row_half_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	s_nop 1
	v_mov_b32_dpp v32, v31 row_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	s_nop 1
	v_mov_b32_dpp v32, v31 row_bcast:15 row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	s_nop 1
	v_mov_b32_dpp v32, v31 row_bcast:31 row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[4:5], s[0:1]
	v_add_f32_e32 v31, v31, v32
	ds_write_b32 v28, v31
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v31, v29
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_mov_b32_dpp v32, v31 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v31, v31, v32
	v_div_scale_f32 v32, s[4:5], v30, v30, v31
	v_rcp_f32_e32 v33, v32
	v_div_scale_f32 v34, vcc, v31, v30, v31
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v35, -v32, v33, 1.0
	v_fmac_f32_e32 v33, v35, v33
	v_mul_f32_e32 v35, v34, v33
	v_fma_f32 v36, -v32, v35, v34
	v_fmac_f32_e32 v35, v36, v33
	v_fma_f32 v32, -v32, v35, v34
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v32, v32, v33, v35
	v_div_fixup_f32 v31, v32, v30, v31
	v_add_f32_e32 v31, v26, v31
	v_rsq_f32_e32 v32, v31
	s_nop 0
	v_mov_b32_e32 v33, v32
	;;#ASMSTART
	v_pk_mul_f32 v[18:19], v[18:19], v[32:33]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[32:33]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[22:23], v[22:23], v[32:33]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[32:33]
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_pk_mul_f32 v[18:19], v[18:19], v[0:1]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[10:11]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[22:23], v[22:23], v[12:13]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[14:15]
	;;#ASMEND
	s_nop 0
	v_cvt_pk_bf16_f32 v18, v18, v19
	v_cvt_pk_bf16_f32 v19, v20, v21
	v_cvt_pk_bf16_f32 v20, v22, v23
	v_cvt_pk_bf16_f32 v21, v24, v25
	s_and_b32 s5, s17, 0xffff
	s_mov_b32 s4, s16
	buffer_store_dwordx4 v[18:21], v27, s[4:7], 0 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
	s_mov_b64 s[14:15], 0
.LBB0_9:
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_2
	s_waitcnt vmcnt(0)
	v_mov_b64_e32 v[8:9], v[4:5]
	v_mov_b64_e32 v[6:7], v[2:3]
	s_branch .LBB0_2
.LBB0_11:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
		.amdhsa_group_segment_fixed_size 8
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 84
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 40
		.amdhsa_next_free_sgpr 32
		.amdhsa_accum_offset 40
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
	.section	.text._ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,"axG",@progbits,_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,comdat
.Lfunc_end0:
	.size	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii, .Lfunc_end0-_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii

	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.num_vgpr, 40
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.num_agpr, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.numbered_sgpr, 32
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.private_seg_size, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.uses_vcc, 1
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.uses_flat_scratch, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_recursion, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_indirect_call, 0
	.section	.text._ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,"axG",@progbits,_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,comdat
	.protected	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
	.globl	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
	.p2align	8
	.type	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,@function
_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_mov_b32 s18, s17
	s_load_dwordx4 s[24:27], s[0:1], 0x38
	s_mov_b32 s17, 0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s19, s24, 31
	v_mov_b32_e32 v2, s24
	v_mov_b32_e32 v3, s19
	v_cmp_ge_i64_e32 vcc, s[16:17], v[2:3]
	s_cbranch_vccnz .LBB1_4
	s_load_dwordx4 s[20:23], s[0:1], 0x48
	s_cmp_eq_u32 s18, 0
	s_cselect_b64 vcc, -1, 0
	s_and_b64 s[0:1], vcc, exec
	s_cselect_b32 s17, s25, s26
	s_cselect_b32 s7, s7, s9
	s_cselect_b32 s6, s6, s8
	s_cselect_b32 s8, s10, s12
	s_cselect_b32 s9, s11, s13
	s_waitcnt lgkmcnt(0)
	s_cselect_b32 s0, s27, s20
	s_ashr_i32 s1, s0, 31
	s_mul_i32 s1, s1, s16
	s_mul_hi_u32 s10, s0, s16
	s_add_i32 s1, s10, s1
	s_mul_i32 s0, s0, s16
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s24, s6, s0
	s_addc_u32 s0, s7, s1
	s_add_i32 s1, s17, 1
	s_lshr_b32 s6, s1, 31
	s_add_i32 s1, s1, s6
	s_lshl_b32 s1, s1, 1
	s_and_b32 s10, s1, -4
	s_mov_b32 s11, 0x20000
	v_lshlrev_b32_e32 v1, 4, v0
	s_and_b32 s25, s0, 0xffff
	s_mov_b32 s26, s10
	s_mov_b32 s27, s11
	buffer_load_dwordx4 v[14:17], v1, s[24:27], 0 offen sc0 nt
	s_and_b32 s9, s9, 0xffff
	buffer_load_dwordx4 v[2:5], v1, s[8:11], 0 offen
	v_and_b32_e32 v22, 63, v0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v13, 0xffff0000, v14
	v_lshlrev_b32_e32 v12, 16, v14
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_and_b32_e32 v9, 0xffff0000, v16
	v_lshlrev_b32_e32 v8, 16, v16
	v_and_b32_e32 v7, 0xffff0000, v17
	v_lshlrev_b32_e32 v6, 16, v17
	v_pk_mul_f32 v[14:15], v[12:13], v[12:13]
	v_pk_mul_f32 v[16:17], v[10:11], v[10:11]
	v_pk_mul_f32 v[18:19], v[8:9], v[8:9]
	v_pk_mul_f32 v[20:21], v[6:7], v[6:7]
	v_add_f32_e32 v14, v14, v15
	v_add_f32_e32 v14, v14, v16
	v_add_f32_e32 v14, v14, v17
	v_add_f32_e32 v14, v14, v18
	v_add_f32_e32 v14, v14, v19
	v_add_f32_e32 v14, v14, v20
	v_add_f32_e32 v14, v14, v21
	s_nop 1
	v_mov_b32_dpp v15, v14 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_mov_b32_dpp v15, v14 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_mov_b32_dpp v15, v14 row_half_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_mov_b32_dpp v15, v14 row_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_mov_b32_dpp v15, v14 row_bcast:15 row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v14, v14, v15
	s_nop 1
	v_mov_b32_dpp v15, v14 row_bcast:31 row_mask:0xf bank_mask:0xf
	v_cmp_eq_u32_e64 s[0:1], 63, v22
	s_and_saveexec_b64 s[6:7], s[0:1]
	v_lshrrev_b32_e32 v16, 4, v0
	v_and_b32_e32 v16, 60, v16
	v_add_f32_e32 v14, v14, v15
	ds_write_b32 v16, v14
	s_or_b64 exec, exec, s[6:7]
	s_and_b64 s[0:1], vcc, exec
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_and_b32_e32 v0, 1, v0
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	v_mov_b32_e32 v14, s15
	v_mov_b32_e32 v15, s14
	v_cndmask_b32_e32 v14, v14, v15, vcc
	v_cvt_f32_i32_e32 v15, s17
	s_waitcnt lgkmcnt(0)
	v_mov_b32_dpp v16, v0 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v0, v0, v16
	v_div_scale_f32 v16, s[0:1], v15, v15, v0
	v_rcp_f32_e32 v17, v16
	v_div_scale_f32 v18, vcc, v0, v15, v0
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v19, -v16, v17, 1.0
	v_fmac_f32_e32 v17, v19, v17
	v_mul_f32_e32 v19, v18, v17
	v_fma_f32 v20, -v16, v19, v18
	v_fmac_f32_e32 v19, v20, v17
	v_fma_f32 v16, -v16, v19, v18
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v16, v16, v17, v19
	v_div_fixup_f32 v0, v16, v15, v0
	v_add_f32_e32 v0, v14, v0
	v_rsq_f32_e32 v14, v0
	s_cselect_b32 s3, s3, s5
	s_cselect_b32 s2, s2, s4
	s_cselect_b32 s0, s21, s22
	v_mov_b32_e32 v15, v14
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[14:15]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[14:15]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[8:9], v[14:15]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[6:7], v[14:15]
	;;#ASMEND
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v15, 0xffff0000, v2
	v_lshlrev_b32_e32 v14, 16, v2
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[14:15]
	;;#ASMEND
	v_and_b32_e32 v15, 0xffff0000, v3
	v_lshlrev_b32_e32 v14, 16, v3
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[14:15]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v4
	v_lshlrev_b32_e32 v2, 16, v4
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[8:9], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v5
	v_lshlrev_b32_e32 v2, 16, v5
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[6:7], v[2:3]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v12, v13
	v_cvt_pk_bf16_f32 v3, v10, v11
	v_cvt_pk_bf16_f32 v4, v8, v9
	v_cvt_pk_bf16_f32 v5, v6, v7
	s_ashr_i32 s1, s0, 31
	s_mul_i32 s1, s1, s16
	s_mul_hi_u32 s4, s0, s16
	s_add_i32 s1, s4, s1
	s_mul_i32 s0, s0, s16
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s8, s2, s0
	s_addc_u32 s0, s3, s1
	s_and_b32 s9, s0, 0xffff
	buffer_store_dwordx4 v[2:5], v1, s[8:11], 0 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
.LBB1_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
		.amdhsa_group_segment_fixed_size 8
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 84
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 23
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 24
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
	.section	.text._ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,"axG",@progbits,_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii,comdat
.Lfunc_end1:
	.size	_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii, .Lfunc_end1-_ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii

	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.num_vgpr, 23
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.num_agpr, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.numbered_sgpr, 28
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.private_seg_size, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.uses_vcc, 1
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.uses_flat_scratch, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_dyn_sized_stack, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_recursion, 0
	.set _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_5111eca7bd90cb4b,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_5111eca7bd90cb4b
__hip_cuid_5111eca7bd90cb4b:
	.byte	0
	.size	__hip_cuid_5111eca7bd90cb4b, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_5111eca7bd90cb4b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .offset:         68
        .size:           4
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     by_value
      - .offset:         76
        .size:           4
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 8
    .kernarg_segment_align: 8
    .kernarg_segment_size: 84
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     38
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi4EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     40
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .offset:         68
        .size:           4
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     by_value
      - .offset:         76
        .size:           4
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 8
    .kernarg_segment_align: 8
    .kernarg_segment_size: 84
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter23fused_qk_rmsnorm_kernelIDF16bLi128ELi8ELb1ELi1EEEvPT_S2_PKS1_S4_S4_S4_ffiiiiiii.kd
    .uses_dynamic_stack: false
    .vgpr_count:     23
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
