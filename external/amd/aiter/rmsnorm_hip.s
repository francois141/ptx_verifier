; Aiter 183a6ce66ebb csrc/kernels/rmsnorm_quant_kernels.cu:24 (add_rmsnorm_quant_kernel), dispatch :677, compiled for gfx950 by
; external/amd/aiter/build.py (case rmsnorm_hip).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
	.protected	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.globl	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.p2align	8
	.type	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,@function
_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_load_dwordx4 s[20:23], s[0:1], 0x38
	s_mov_b32 s17, 0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s6, s21, 31
	v_mov_b32_e32 v2, s21
	v_mov_b32_e32 v3, s6
	v_cmp_ge_i64_e32 vcc, s[16:17], v[2:3]
	s_cbranch_vccnz .LBB0_4
	s_mov_b64 s[4:5], s[14:15]
	s_ashr_i32 s6, s23, 31
	s_mul_hi_u32 s7, s23, s16
	s_mul_i32 s6, s6, s16
	s_add_i32 s7, s7, s6
	s_mul_i32 s6, s23, s16
	s_lshl_b64 s[6:7], s[6:7], 1
	s_add_u32 s8, s8, s6
	s_addc_u32 s6, s9, s7
	s_add_i32 s7, s22, 1
	s_lshr_b32 s9, s7, 31
	s_add_i32 s7, s7, s9
	s_lshl_b32 s7, s7, 1
	s_and_b32 s10, s7, -4
	s_and_b32 s9, s6, 0xffff
	s_mov_b32 s11, 0x20000
	v_lshlrev_b32_e32 v1, 4, v0
	buffer_load_dwordx4 v[14:17], v1, s[8:11], 0 offen sc0 nt
	s_mov_b32 s15, s11
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s10
	buffer_load_dwordx4 v[2:5], v1, s[12:15], 0 offen
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
	v_add_f32_e32 v14, v15, v14
	v_add_f32_e32 v14, v16, v14
	v_add_f32_e32 v14, v17, v14
	v_add_f32_e32 v14, v18, v14
	v_add_f32_e32 v14, v19, v14
	v_add_f32_e32 v14, v20, v14
	v_add_f32_e32 v14, v21, v14
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
	v_cmp_eq_u32_e32 vcc, 63, v22
	s_and_saveexec_b64 s[6:7], vcc
	v_lshrrev_b32_e32 v16, 4, v0
	v_and_b32_e32 v16, 60, v16
	v_add_f32_e32 v14, v14, v15
	ds_write_b32 v16, v14
	s_or_b64 exec, exec, s[6:7]
	s_load_dword s0, s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_ashr_i32 s1, s0, 31
	s_mul_hi_u32 s6, s0, s16
	s_mul_i32 s1, s1, s16
	s_add_i32 s1, s6, s1
	v_and_b32_e32 v0, 1, v0
	v_lshlrev_b32_e32 v0, 2, v0
	v_cvt_f32_i32_e32 v14, s22
	ds_read_b32 v0, v0
	s_mul_i32 s0, s0, s16
	s_lshl_b64 s[0:1], s[0:1], 1
	v_rcp_iflag_f32_e32 v14, v14
	s_add_u32 s8, s2, s0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_dpp v15, v0 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v0, v0, v15
	v_mul_f32_e32 v0, v14, v0
	v_cvt_f64_f32_e32 v[14:15], v0
	v_add_f64 v[14:15], s[4:5], v[14:15]
	v_cvt_f32_f64_e32 v0, v[14:15]
	v_rsq_f32_e32 v14, v0
	s_addc_u32 s0, s3, s1
	s_and_b32 s9, s0, 0xffff
	s_bitcmp1_b32 s20, 0
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
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v0, 0, 1.0, s[0:1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v15, 0xffff0000, v2
	v_lshlrev_b32_e32 v14, 16, v2
	v_pk_add_f32 v[14:15], v[0:1], v[14:15] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[14:15]
	;;#ASMEND
	v_and_b32_e32 v15, 0xffff0000, v3
	v_lshlrev_b32_e32 v14, 16, v3
	v_pk_add_f32 v[2:3], v[0:1], v[14:15] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v4
	v_lshlrev_b32_e32 v2, 16, v4
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[8:9], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v5
	v_lshlrev_b32_e32 v2, 16, v5
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[6:7], v[2:3]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v12, v13
	v_cvt_pk_bf16_f32 v3, v10, v11
	v_cvt_pk_bf16_f32 v4, v8, v9
	v_cvt_pk_bf16_f32 v5, v6, v7
	buffer_store_dwordx4 v[2:5], v1, s[8:11], 0 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
.LBB0_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
		.amdhsa_group_segment_fixed_size 8
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 92
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 23
		.amdhsa_next_free_sgpr 24
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
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
.Lfunc_end0:
	.size	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb, .Lfunc_end0-_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb

	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_vgpr, 23
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_agpr, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.numbered_sgpr, 24
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.private_seg_size, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_vcc, 1
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_flat_scratch, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_dyn_sized_stack, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_recursion, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_indirect_call, 0
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
	.protected	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.globl	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.p2align	8
	.type	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,@function
_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_load_dwordx4 s[20:23], s[0:1], 0x38
	s_mov_b32 s17, 0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s6, s21, 31
	v_mov_b32_e32 v2, s21
	v_mov_b32_e32 v3, s6
	v_cmp_ge_i64_e32 vcc, s[16:17], v[2:3]
	s_cbranch_vccnz .LBB1_4
	s_mov_b64 s[4:5], s[14:15]
	s_ashr_i32 s6, s23, 31
	s_mul_hi_u32 s7, s23, s16
	s_mul_i32 s6, s6, s16
	s_add_i32 s7, s7, s6
	s_mul_i32 s6, s23, s16
	s_lshl_b64 s[6:7], s[6:7], 1
	s_add_u32 s8, s8, s6
	s_addc_u32 s6, s9, s7
	s_add_i32 s7, s22, 1
	s_lshr_b32 s9, s7, 31
	s_add_i32 s7, s7, s9
	s_lshl_b32 s7, s7, 1
	s_and_b32 s10, s7, -4
	s_and_b32 s9, s6, 0xffff
	s_mov_b32 s11, 0x20000
	v_lshlrev_b32_e32 v1, 4, v0
	v_lshlrev_b32_e32 v2, 5, v0
	v_and_b32_e32 v2, 0x7800, v2
	s_movk_i32 s6, 0x3f0
	v_and_or_b32 v1, v1, s6, v2
	buffer_load_dwordx4 v[10:13], v1, s[8:11], 0 offen sc0 nt
	s_movk_i32 s17, 0x400
	buffer_load_dwordx4 v[26:29], v1, s[8:11], s17 offen sc0 nt
	s_mov_b32 s15, s11
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s10
	buffer_load_dwordx4 v[6:9], v1, s[12:15], 0 offen
	buffer_load_dwordx4 v[2:5], v1, s[12:15], s17 offen
	v_and_b32_e32 v42, 63, v0
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v25, 0xffff0000, v10
	v_lshlrev_b32_e32 v24, 16, v10
	v_and_b32_e32 v23, 0xffff0000, v11
	v_lshlrev_b32_e32 v22, 16, v11
	v_and_b32_e32 v21, 0xffff0000, v12
	v_lshlrev_b32_e32 v20, 16, v12
	v_and_b32_e32 v19, 0xffff0000, v13
	v_lshlrev_b32_e32 v18, 16, v13
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v17, 0xffff0000, v26
	v_lshlrev_b32_e32 v16, 16, v26
	v_and_b32_e32 v15, 0xffff0000, v27
	v_lshlrev_b32_e32 v14, 16, v27
	v_and_b32_e32 v13, 0xffff0000, v28
	v_lshlrev_b32_e32 v12, 16, v28
	v_and_b32_e32 v11, 0xffff0000, v29
	v_lshlrev_b32_e32 v10, 16, v29
	v_pk_mul_f32 v[26:27], v[24:25], v[24:25]
	v_pk_mul_f32 v[28:29], v[22:23], v[22:23]
	v_pk_mul_f32 v[30:31], v[20:21], v[20:21]
	v_pk_mul_f32 v[32:33], v[18:19], v[18:19]
	v_pk_mul_f32 v[34:35], v[16:17], v[16:17]
	v_pk_mul_f32 v[36:37], v[14:15], v[14:15]
	v_pk_mul_f32 v[38:39], v[12:13], v[12:13]
	v_pk_mul_f32 v[40:41], v[10:11], v[10:11]
	v_add_f32_e32 v26, v27, v26
	v_add_f32_e32 v26, v28, v26
	v_add_f32_e32 v26, v29, v26
	v_add_f32_e32 v26, v30, v26
	v_add_f32_e32 v26, v31, v26
	v_add_f32_e32 v26, v32, v26
	v_add_f32_e32 v26, v33, v26
	v_add_f32_e32 v26, v34, v26
	v_add_f32_e32 v26, v35, v26
	v_add_f32_e32 v26, v36, v26
	v_add_f32_e32 v26, v37, v26
	v_add_f32_e32 v26, v38, v26
	v_add_f32_e32 v26, v39, v26
	v_add_f32_e32 v26, v40, v26
	v_add_f32_e32 v26, v41, v26
	s_nop 1
	v_mov_b32_dpp v27, v26 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_half_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_bcast:15 row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_bcast:31 row_mask:0xf bank_mask:0xf
	v_cmp_eq_u32_e32 vcc, 63, v42
	s_and_saveexec_b64 s[6:7], vcc
	v_lshrrev_b32_e32 v28, 4, v0
	v_and_b32_e32 v28, 60, v28
	v_add_f32_e32 v26, v26, v27
	ds_write_b32 v28, v26
	s_or_b64 exec, exec, s[6:7]
	s_load_dword s0, s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_ashr_i32 s1, s0, 31
	s_mul_hi_u32 s6, s0, s16
	s_mul_i32 s1, s1, s16
	s_add_i32 s1, s6, s1
	v_and_b32_e32 v0, 3, v0
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	s_mul_i32 s0, s0, s16
	v_cvt_f32_i32_e32 v26, s22
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s8, s2, s0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_dpp v27, v0 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_rcp_iflag_f32_e32 v26, v26
	v_add_f32_e32 v0, v0, v27
	s_nop 1
	v_mov_b32_dpp v27, v0 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v0, v0, v27
	v_mul_f32_e32 v0, v26, v0
	v_cvt_f64_f32_e32 v[26:27], v0
	v_add_f64 v[26:27], s[4:5], v[26:27]
	v_cvt_f32_f64_e32 v0, v[26:27]
	v_rsq_f32_e32 v26, v0
	s_addc_u32 s0, s3, s1
	s_and_b32 s9, s0, 0xffff
	s_bitcmp1_b32 s20, 0
	v_mov_b32_e32 v27, v26
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[22:23], v[22:23], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[18:19], v[18:19], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[16:17], v[16:17], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[14:15], v[14:15], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[26:27]
	;;#ASMEND
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v0, 0, 1.0, s[0:1]
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v27, 0xffff0000, v6
	v_lshlrev_b32_e32 v26, 16, v6
	v_pk_add_f32 v[26:27], v[0:1], v[26:27] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[26:27]
	;;#ASMEND
	v_and_b32_e32 v27, 0xffff0000, v7
	v_lshlrev_b32_e32 v26, 16, v7
	v_pk_add_f32 v[6:7], v[0:1], v[26:27] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[22:23], v[6:7]
	;;#ASMEND
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_pk_add_f32 v[22:23], v[0:1], v[22:23] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[22:23]
	;;#ASMEND
	v_and_b32_e32 v23, 0xffff0000, v9
	v_lshlrev_b32_e32 v22, 16, v9
	v_pk_add_f32 v[8:9], v[0:1], v[22:23] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[18:19], v[8:9]
	;;#ASMEND
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v19, 0xffff0000, v2
	v_lshlrev_b32_e32 v18, 16, v2
	v_pk_add_f32 v[18:19], v[0:1], v[18:19] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[16:17], v[16:17], v[18:19]
	;;#ASMEND
	v_and_b32_e32 v19, 0xffff0000, v3
	v_lshlrev_b32_e32 v18, 16, v3
	v_pk_add_f32 v[2:3], v[0:1], v[18:19] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[14:15], v[14:15], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v4
	v_lshlrev_b32_e32 v2, 16, v4
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v5
	v_lshlrev_b32_e32 v2, 16, v5
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[2:3]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v24, v25
	v_cvt_pk_bf16_f32 v3, v6, v7
	v_cvt_pk_bf16_f32 v4, v20, v21
	v_cvt_pk_bf16_f32 v5, v8, v9
	buffer_store_dwordx4 v[2:5], v1, s[8:11], 0 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
	s_nop 1
	v_cvt_pk_bf16_f32 v2, v16, v17
	v_cvt_pk_bf16_f32 v3, v14, v15
	v_cvt_pk_bf16_f32 v4, v12, v13
	v_cvt_pk_bf16_f32 v5, v10, v11
	buffer_store_dwordx4 v[2:5], v1, s[8:11], s17 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
.LBB1_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 92
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 43
		.amdhsa_next_free_sgpr 24
		.amdhsa_accum_offset 44
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
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
.Lfunc_end1:
	.size	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb, .Lfunc_end1-_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb

	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_vgpr, 43
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_agpr, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.numbered_sgpr, 24
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.private_seg_size, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_vcc, 1
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_flat_scratch, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_dyn_sized_stack, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_recursion, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_indirect_call, 0
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
	.protected	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.globl	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
	.p2align	8
	.type	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,@function
_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB2_0
	.p2align	8
.LBB2_0:
	s_mov_b64 s[6:7], s[14:15]
	s_load_dwordx4 s[24:27], s[0:1], 0x38
	s_mov_b32 s17, 0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s14, s25, 31
	v_mov_b32_e32 v2, s25
	v_mov_b32_e32 v3, s14
	v_cmp_ge_i64_e32 vcc, s[16:17], v[2:3]
	s_cbranch_vccnz .LBB2_4
	s_ashr_i32 s14, s27, 31
	s_mul_hi_u32 s15, s27, s16
	s_mul_i32 s14, s14, s16
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s27, s16
	s_lshl_b64 s[14:15], s[14:15], 1
	s_add_u32 s20, s8, s14
	s_addc_u32 s8, s9, s15
	s_add_i32 s9, s26, 1
	s_lshr_b32 s14, s9, 31
	s_add_i32 s9, s9, s14
	s_lshl_b32 s9, s9, 1
	s_and_b32 s22, s9, -4
	s_and_b32 s21, s8, 0xffff
	s_mov_b32 s23, 0x20000
	v_lshlrev_b32_e32 v1, 4, v0
	v_lshlrev_b32_e32 v2, 5, v0
	v_and_b32_e32 v2, 0x7800, v2
	s_movk_i32 s8, 0x3f0
	v_and_or_b32 v1, v1, s8, v2
	s_movk_i32 s8, 0x400
	buffer_load_dwordx4 v[18:21], v1, s[20:23], s8 offen sc0 nt
	s_load_dwordx4 s[28:31], s[0:1], 0x48
	buffer_load_dwordx4 v[10:13], v1, s[20:23], 0 offen sc0 nt
	s_and_b32 s13, s13, 0xffff
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s0, s28, 31
	s_mul_hi_u32 s1, s28, s16
	s_mul_i32 s0, s0, s16
	s_add_i32 s1, s1, s0
	s_mul_i32 s0, s28, s16
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s20, s10, s0
	s_addc_u32 s0, s11, s1
	s_and_b32 s21, s0, 0xffff
	buffer_load_dwordx4 v[22:25], v1, s[20:23], s8 offen sc0 nt
	buffer_load_dwordx4 v[14:17], v1, s[20:23], 0 offen sc0 nt
	s_mov_b32 s15, s23
	s_mul_hi_u32 s1, s29, s16
	s_mul_i32 s0, s29, s16
	s_mov_b32 s14, s22
	buffer_load_dwordx4 v[6:9], v1, s[12:15], 0 offen
	buffer_load_dwordx4 v[2:5], v1, s[12:15], s8 offen
	s_ashr_i32 s9, s29, 31
	s_mul_i32 s9, s9, s16
	s_add_i32 s1, s1, s9
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s20, s4, s0
	s_addc_u32 s0, s5, s1
	s_and_b32 s21, s0, 0xffff
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v27, 0xffff0000, v18
	v_lshlrev_b32_e32 v26, 16, v18
	v_and_b32_e32 v29, 0xffff0000, v19
	v_lshlrev_b32_e32 v28, 16, v19
	v_and_b32_e32 v19, 0xffff0000, v20
	v_lshlrev_b32_e32 v18, 16, v20
	v_and_b32_e32 v31, 0xffff0000, v21
	v_lshlrev_b32_e32 v30, 16, v21
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v21, 0xffff0000, v10
	v_lshlrev_b32_e32 v20, 16, v10
	v_and_b32_e32 v33, 0xffff0000, v11
	v_lshlrev_b32_e32 v32, 16, v11
	v_and_b32_e32 v35, 0xffff0000, v12
	v_lshlrev_b32_e32 v34, 16, v12
	v_and_b32_e32 v37, 0xffff0000, v13
	v_lshlrev_b32_e32 v36, 16, v13
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v11, 0xffff0000, v22
	v_lshlrev_b32_e32 v10, 16, v22
	v_and_b32_e32 v13, 0xffff0000, v23
	v_lshlrev_b32_e32 v12, 16, v23
	v_and_b32_e32 v23, 0xffff0000, v24
	v_lshlrev_b32_e32 v22, 16, v24
	v_and_b32_e32 v39, 0xffff0000, v25
	v_lshlrev_b32_e32 v38, 16, v25
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v25, 0xffff0000, v14
	v_lshlrev_b32_e32 v24, 16, v14
	v_and_b32_e32 v41, 0xffff0000, v15
	v_lshlrev_b32_e32 v40, 16, v15
	v_and_b32_e32 v43, 0xffff0000, v16
	v_lshlrev_b32_e32 v42, 16, v16
	v_and_b32_e32 v45, 0xffff0000, v17
	v_lshlrev_b32_e32 v44, 16, v17
	v_pk_add_f32 v[16:17], v[26:27], v[10:11]
	v_pk_add_f32 v[14:15], v[28:29], v[12:13]
	v_pk_add_f32 v[12:13], v[18:19], v[22:23]
	v_pk_add_f32 v[10:11], v[30:31], v[38:39]
	v_pk_add_f32 v[24:25], v[20:21], v[24:25]
	v_pk_add_f32 v[22:23], v[32:33], v[40:41]
	v_pk_add_f32 v[20:21], v[34:35], v[42:43]
	v_pk_add_f32 v[18:19], v[36:37], v[44:45]
	v_cvt_pk_bf16_f32 v26, v24, v25
	v_cvt_pk_bf16_f32 v27, v22, v23
	v_cvt_pk_bf16_f32 v28, v20, v21
	v_cvt_pk_bf16_f32 v29, v18, v19
	v_cvt_pk_bf16_f32 v31, v10, v11
	v_cvt_pk_bf16_f32 v30, v12, v13
	buffer_store_dwordx4 v[26:29], v1, s[20:23], 0 offen sc0 nt
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
	s_nop 1
	v_cvt_pk_bf16_f32 v29, v14, v15
	v_cvt_pk_bf16_f32 v28, v16, v17
	buffer_store_dwordx4 v[28:31], v1, s[20:23], s8 offen sc0 nt
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
	v_pk_mul_f32 v[26:27], v[24:25], v[24:25]
	v_pk_mul_f32 v[28:29], v[22:23], v[22:23]
	v_pk_mul_f32 v[30:31], v[20:21], v[20:21]
	v_pk_mul_f32 v[32:33], v[18:19], v[18:19]
	v_pk_mul_f32 v[34:35], v[16:17], v[16:17]
	v_pk_mul_f32 v[36:37], v[14:15], v[14:15]
	v_pk_mul_f32 v[38:39], v[12:13], v[12:13]
	v_pk_mul_f32 v[40:41], v[10:11], v[10:11]
	v_add_f32_e32 v26, v27, v26
	v_add_f32_e32 v26, v28, v26
	v_add_f32_e32 v26, v29, v26
	v_add_f32_e32 v26, v30, v26
	v_add_f32_e32 v26, v31, v26
	v_add_f32_e32 v26, v32, v26
	v_add_f32_e32 v26, v33, v26
	v_add_f32_e32 v26, v34, v26
	v_add_f32_e32 v26, v35, v26
	v_add_f32_e32 v26, v36, v26
	v_add_f32_e32 v26, v37, v26
	v_add_f32_e32 v26, v38, v26
	v_add_f32_e32 v26, v39, v26
	v_add_f32_e32 v26, v40, v26
	v_add_f32_e32 v26, v41, v26
	v_and_b32_e32 v28, 63, v0
	s_nop 0
	v_mov_b32_dpp v27, v26 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_half_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_mirror row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_bcast:15 row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v26, v26, v27
	s_nop 1
	v_mov_b32_dpp v27, v26 row_bcast:31 row_mask:0xf bank_mask:0xf
	v_cmp_eq_u32_e32 vcc, 63, v28
	s_and_saveexec_b64 s[0:1], vcc
	v_lshrrev_b32_e32 v28, 4, v0
	v_and_b32_e32 v28, 60, v28
	v_add_f32_e32 v26, v26, v27
	ds_write_b32 v28, v26
	s_or_b64 exec, exec, s[0:1]
	s_ashr_i32 s0, s30, 31
	s_mul_hi_u32 s1, s30, s16
	s_mul_i32 s0, s0, s16
	s_add_i32 s1, s1, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_and_b32_e32 v0, 3, v0
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	s_mul_i32 s0, s30, s16
	v_cvt_f32_i32_e32 v26, s26
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s20, s2, s0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_dpp v27, v0 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_rcp_iflag_f32_e32 v26, v26
	v_add_f32_e32 v0, v0, v27
	s_nop 1
	v_mov_b32_dpp v27, v0 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	v_add_f32_e32 v0, v0, v27
	v_mul_f32_e32 v0, v26, v0
	v_cvt_f64_f32_e32 v[26:27], v0
	v_add_f64 v[26:27], s[6:7], v[26:27]
	v_cvt_f32_f64_e32 v0, v[26:27]
	v_rsq_f32_e32 v26, v0
	s_addc_u32 s0, s3, s1
	s_and_b32 s21, s0, 0xffff
	s_bitcmp1_b32 s24, 0
	v_mov_b32_e32 v27, v26
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[22:23], v[22:23], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[18:19], v[18:19], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[16:17], v[16:17], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[14:15], v[14:15], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[26:27]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[26:27]
	;;#ASMEND
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v0, 0, 1.0, s[0:1]
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v27, 0xffff0000, v6
	v_lshlrev_b32_e32 v26, 16, v6
	v_pk_add_f32 v[26:27], v[0:1], v[26:27] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[24:25], v[24:25], v[26:27]
	;;#ASMEND
	v_and_b32_e32 v27, 0xffff0000, v7
	v_lshlrev_b32_e32 v26, 16, v7
	v_pk_add_f32 v[6:7], v[0:1], v[26:27] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[22:23], v[6:7]
	;;#ASMEND
	v_and_b32_e32 v23, 0xffff0000, v8
	v_lshlrev_b32_e32 v22, 16, v8
	v_pk_add_f32 v[22:23], v[0:1], v[22:23] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[20:21], v[20:21], v[22:23]
	;;#ASMEND
	v_and_b32_e32 v23, 0xffff0000, v9
	v_lshlrev_b32_e32 v22, 16, v9
	v_pk_add_f32 v[8:9], v[0:1], v[22:23] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[18:19], v[8:9]
	;;#ASMEND
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v19, 0xffff0000, v2
	v_lshlrev_b32_e32 v18, 16, v2
	v_pk_add_f32 v[18:19], v[0:1], v[18:19] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[16:17], v[16:17], v[18:19]
	;;#ASMEND
	v_and_b32_e32 v19, 0xffff0000, v3
	v_lshlrev_b32_e32 v18, 16, v3
	v_pk_add_f32 v[2:3], v[0:1], v[18:19] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[14:15], v[14:15], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v4
	v_lshlrev_b32_e32 v2, 16, v4
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[12:13], v[12:13], v[2:3]
	;;#ASMEND
	v_and_b32_e32 v3, 0xffff0000, v5
	v_lshlrev_b32_e32 v2, 16, v5
	v_pk_add_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[10:11], v[2:3]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v24, v25
	v_cvt_pk_bf16_f32 v3, v6, v7
	v_cvt_pk_bf16_f32 v4, v20, v21
	v_cvt_pk_bf16_f32 v5, v8, v9
	buffer_store_dwordx4 v[2:5], v1, s[20:23], 0 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
	s_nop 1
	v_cvt_pk_bf16_f32 v2, v16, v17
	v_cvt_pk_bf16_f32 v3, v14, v15
	v_cvt_pk_bf16_f32 v4, v12, v13
	v_cvt_pk_bf16_f32 v5, v10, v11
	buffer_store_dwordx4 v[2:5], v1, s[20:23], s8 offen
	;;#ASMSTART
	s_nop 0
	;;#ASMEND
.LBB2_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 92
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 46
		.amdhsa_next_free_sgpr 32
		.amdhsa_accum_offset 48
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
	.section	.text._ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,"axG",@progbits,_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb,comdat
.Lfunc_end2:
	.size	_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb, .Lfunc_end2-_ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb

	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_vgpr, 46
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.num_agpr, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.numbered_sgpr, 32
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.private_seg_size, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_vcc, 1
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.uses_flat_scratch, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_dyn_sized_stack, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_recursion, 0
	.set _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_5424f205ea5ced6f,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_5424f205ea5ced6f
__hip_cuid_5424f205ea5ced6f:
	.byte	0
	.size	__hip_cuid_5424f205ea5ced6f, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_5424f205ea5ced6f
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           8
        .value_kind:     by_value
      - .offset:         56
        .size:           1
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
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           1
        .value_kind:     by_value
      - .offset:         89
        .size:           1
        .value_kind:     by_value
    .group_segment_fixed_size: 8
    .kernarg_segment_align: 8
    .kernarg_segment_size: 92
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
    .private_segment_fixed_size: 0
    .sgpr_count:     30
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi128ELi8ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.kd
    .uses_dynamic_stack: false
    .vgpr_count:     23
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           8
        .value_kind:     by_value
      - .offset:         56
        .size:           1
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
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           1
        .value_kind:     by_value
      - .offset:         89
        .size:           1
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 92
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
    .private_segment_fixed_size: 0
    .sgpr_count:     30
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb0ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.kd
    .uses_dynamic_stack: false
    .vgpr_count:     43
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           8
        .value_kind:     by_value
      - .offset:         56
        .size:           1
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
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           1
        .value_kind:     by_value
      - .offset:         89
        .size:           1
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 92
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb
    .private_segment_fixed_size: 0
    .sgpr_count:     38
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter24add_rmsnorm_quant_kernelIDF16bDF16bLi256ELi16ELb1ELb0ELb1ELi1ELb0EEEvPT0_PT_PfS4_S4_S4_dbiiiiiiibb.kd
    .uses_dynamic_stack: false
    .vgpr_count:     46
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
