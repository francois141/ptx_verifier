; Aiter 183a6ce66ebb csrc/kernels/groupnorm.cu:208 (groupnorm_kernel_dispatch_up), :236 (_down), dispatch :281, compiled for gfx950 by
; external/amd/aiter/build.py (case groupnorm_up).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_
	.globl	_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_
	.p2align	8
	.type	_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_,@function
_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_load_dword s14, s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_bitcmp1_b32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_mov_b64 s[18:19], -1
	s_mul_i32 s5, s5, s3
	s_mul_hi_u32 s17, s4, s3
	s_add_i32 s21, s17, s5
	s_mov_b32 s20, 0
	s_cmp_lg_u64 s[20:21], 0
	s_mul_i32 s3, s4, s3
	s_cbranch_scc0 .LBB0_26
	v_cvt_f32_u32_e32 v1, s2
	v_cvt_f32_ubyte0_e32 v2, 0
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s4, 0, s2
	s_subb_u32 s5, 0, 0
	v_readfirstlane_b32 s17, v2
	v_readfirstlane_b32 s20, v1
	s_mul_i32 s22, s4, s17
	s_mul_i32 s23, s5, s20
	s_mul_hi_u32 s24, s4, s20
	s_add_i32 s22, s24, s22
	s_add_i32 s22, s22, s23
	s_mul_hi_u32 s23, s20, s22
	s_mul_i32 s24, s20, s22
	s_mul_i32 s25, s4, s20
	s_mul_hi_u32 s20, s20, s25
	s_add_u32 s20, s20, s24
	s_addc_u32 s23, 0, s23
	s_mul_hi_u32 s24, s17, s22
	s_mul_hi_u32 s26, s17, s25
	s_mul_i32 s25, s17, s25
	s_add_u32 s20, s20, s25
	s_addc_u32 s20, s23, s26
	s_addc_u32 s23, s24, 0
	s_mul_i32 s22, s17, s22
	s_add_u32 s20, s20, s22
	s_addc_u32 s22, 0, s23
	v_add_co_u32_e32 v1, vcc, s20, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s22
	s_mul_i32 s20, s4, s17
	v_readfirstlane_b32 s22, v1
	s_mul_hi_u32 s23, s4, s22
	s_add_i32 s20, s23, s20
	s_mul_i32 s5, s5, s22
	s_add_i32 s20, s20, s5
	s_mul_hi_u32 s5, s17, s20
	s_mul_i32 s4, s4, s22
	s_mul_hi_u32 s23, s17, s4
	s_mul_i32 s24, s17, s4
	s_mul_hi_u32 s25, s22, s20
	s_mul_i32 s26, s22, s20
	s_mul_hi_u32 s4, s22, s4
	s_add_u32 s4, s4, s26
	s_addc_u32 s22, 0, s25
	s_add_u32 s4, s4, s24
	s_addc_u32 s4, s22, s23
	s_addc_u32 s5, s5, 0
	s_mul_i32 s20, s17, s20
	s_add_u32 s4, s4, s20
	s_addc_u32 s5, 0, s5
	v_add_co_u32_e32 v1, vcc, s4, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s17, s17, s5
	s_ashr_i32 s4, s21, 31
	s_mov_b32 s5, s4
	s_add_u32 s20, s3, s4
	s_addc_u32 s21, s21, s4
	s_xor_b64 s[20:21], s[20:21], s[4:5]
	s_mul_hi_u32 s22, s20, s17
	s_mul_i32 s23, s20, s17
	v_readfirstlane_b32 s24, v1
	s_mul_hi_u32 s25, s20, s24
	s_add_u32 s23, s25, s23
	s_addc_u32 s22, 0, s22
	s_mul_hi_u32 s25, s21, s17
	s_mul_hi_u32 s26, s21, s24
	s_mul_i32 s24, s21, s24
	s_add_u32 s23, s23, s24
	s_addc_u32 s22, s22, s26
	s_addc_u32 s23, s25, 0
	s_mul_i32 s17, s21, s17
	s_add_u32 s17, s22, s17
	s_addc_u32 s22, 0, s23
	s_add_u32 s23, s17, 1
	s_addc_u32 s24, s22, 0
	s_add_u32 s25, s17, 2
	s_addc_u32 s26, s22, 0
	s_mul_i32 s27, s2, s22
	s_mul_hi_u32 s28, s2, s17
	s_add_i32 s28, s28, s27
	s_mul_i32 s27, s2, s17
	v_mov_b32_e32 v1, s27
	v_sub_co_u32_e32 v1, vcc, s20, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s20, s21, s28
	v_subrev_co_u32_e32 v2, vcc, s2, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s21, s20, 0
	v_readfirstlane_b32 s27, v2
	s_cmp_ge_u32 s27, s2
	s_cselect_b32 s27, -1, 0
	s_cmp_eq_u32 s21, 0
	s_cselect_b32 s21, s27, -1
	s_cmp_lg_u32 s21, 0
	s_cselect_b32 s23, s25, s23
	s_cselect_b32 s21, s26, s24
	v_readfirstlane_b32 s24, v1
	s_cmp_ge_u32 s24, s2
	s_cselect_b32 s24, -1, 0
	s_cmp_eq_u32 s20, 0
	s_cselect_b32 s20, s24, -1
	s_cmp_lg_u32 s20, 0
	s_cselect_b32 s21, s21, s22
	s_cselect_b32 s20, s23, s17
	s_xor_b64 s[20:21], s[20:21], s[4:5]
	s_sub_u32 s4, s20, s4
	s_mov_b64 vcc, exec
	s_xor_b64 s[6:7], s[6:7], -1
	s_cbranch_execnz .LBB0_3
.LBB0_2:
	v_cvt_f32_u32_e32 v1, s2
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_sub_i32 s4, 0, s2
	v_readfirstlane_b32 s5, v1
	s_mul_i32 s4, s4, s5
	s_mul_hi_u32 s4, s5, s4
	s_add_i32 s5, s5, s4
	s_mul_hi_u32 s4, s3, s5
	s_add_i32 s5, s4, 1
	s_mul_i32 s17, s4, s2
	s_sub_i32 s3, s3, s17
	s_sub_i32 s17, s3, s2
	s_cmp_ge_u32 s3, s2
	s_cselect_b32 s3, s17, s3
	s_cselect_b32 s4, s5, s4
	s_add_i32 s5, s4, 1
	s_cmp_ge_u32 s3, s2
	s_cselect_b32 s4, s5, s4
.LBB0_3:
	s_load_dword s0, s[0:1], 0x3c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s0, s0, 0xffff
	s_mul_i32 s0, s15, s0
	s_andn2_b64 vcc, exec, s[6:7]
	v_add_u32_e32 v1, s0, v0
	s_cbranch_vccnz .LBB0_9
	v_cmp_gt_u32_e32 vcc, s4, v1
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, v3
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_8
	s_mul_i32 s5, s16, s4
	s_lshl_b32 s6, s14, 10
	v_mov_b32_e32 v5, 0
	s_mov_b64 s[2:3], 0
	v_mov_b32_e32 v6, v1
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v3, v5
.LBB0_6:
	v_add_u32_e32 v4, s5, v6
	v_lshl_add_u64 v[8:9], v[4:5], 2, s[8:9]
	global_load_dword v8, v[8:9], off
	v_add_u32_e32 v6, s6, v6
	v_cmp_le_u32_e32 vcc, s4, v6
	s_or_b64 s[2:3], vcc, s[2:3]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v9, v8, v8
	v_pk_add_f32 v[2:3], v[2:3], v[8:9]
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_6
	s_or_b64 exec, exec, s[2:3]
.LBB0_8:
	s_or_b64 exec, exec, s[0:1]
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_10
	s_branch .LBB0_15
.LBB0_9:
	s_mov_b64 vcc, 0
.LBB0_10:
	v_lshlrev_b32_e32 v1, 2, v1
	v_cmp_gt_u32_e32 vcc, s4, v1
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, v3
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_14
	s_mul_i32 s5, s16, s4
	s_lshl_b32 s6, s14, 12
	v_mov_b32_e32 v5, 0
	s_mov_b64 s[2:3], 0
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v3, v5
.LBB0_12:
	v_add_u32_e32 v4, s5, v1
	v_lshl_add_u64 v[6:7], v[4:5], 2, s[8:9]
	global_load_dwordx4 v[6:9], v[6:7], off
	v_add_u32_e32 v1, s6, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_or_b64 s[2:3], vcc, s[2:3]
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v6
	v_fmac_f32_e32 v3, v6, v6
	v_pk_mov_b32 v[10:11], v[8:9], v[8:9] op_sel:[1,0]
	v_mov_b32_e32 v6, v7
	v_mov_b32_e32 v13, v9
	v_pk_mul_f32 v[14:15], v[8:9], v[8:9]
	v_add_f32_e32 v12, v2, v7
	v_mov_b32_e32 v7, v11
	v_pk_mul_f32 v[6:7], v[6:7], v[6:7]
	v_pk_add_f32 v[8:9], v[12:13], v[8:9]
	v_add_f32_e32 v2, v3, v6
	v_mov_b32_e32 v9, v15
	v_add_f32_e32 v11, v2, v7
	v_pk_add_f32 v[2:3], v[8:9], v[10:11]
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_12
	s_or_b64 exec, exec, s[2:3]
.LBB0_14:
	s_or_b64 exec, exec, s[0:1]
.LBB0_15:
	v_mbcnt_lo_u32_b32 v1, -1, 0
	v_mbcnt_hi_u32_b32 v10, -1, v1
	v_mov_b32_e32 v1, 0x80
	v_lshl_or_b32 v6, v10, 2, v1
	ds_bpermute_b32 v4, v6, v2
	ds_bpermute_b32 v5, v6, v3
	v_and_b32_e32 v11, 63, v10
	v_cmp_gt_u32_e32 vcc, 48, v11
	s_nop 1
	v_cndmask_b32_e64 v1, 0, 16, vcc
	v_add_lshl_u32 v1, v1, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v1, v2
	ds_bpermute_b32 v5, v1, v3
	v_cmp_gt_u32_e32 vcc, 56, v11
	s_nop 1
	v_cndmask_b32_e64 v7, 0, 8, vcc
	v_add_lshl_u32 v7, v7, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v7, v2
	ds_bpermute_b32 v5, v7, v3
	v_cmp_gt_u32_e32 vcc, 60, v11
	s_nop 1
	v_cndmask_b32_e64 v8, 0, 4, vcc
	v_add_lshl_u32 v8, v8, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v8, v2
	ds_bpermute_b32 v5, v8, v3
	v_cmp_gt_u32_e32 vcc, 62, v11
	s_nop 1
	v_cndmask_b32_e64 v9, 0, 2, vcc
	v_add_lshl_u32 v9, v9, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v9, v2
	ds_bpermute_b32 v5, v9, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	v_cmp_ne_u32_e32 vcc, 63, v11
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, 0, v10, vcc
	v_lshlrev_b32_e32 v10, 2, v4
	ds_bpermute_b32 v4, v10, v2
	ds_bpermute_b32 v5, v10, v3
	v_and_b32_e32 v11, 63, v0
	v_cmp_eq_u32_e32 vcc, 0, v11
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_17
	v_lshrrev_b32_e32 v12, 3, v0
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_write2_b32 v12, v2, v3 offset1:1
.LBB0_17:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_cmp_gt_u32_e32 vcc, 16, v0
	v_lshlrev_b32_e32 v4, 3, v11
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, 0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB0_24
	s_or_b64 exec, exec, s[0:1]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB0_25
.LBB0_19:
	s_or_b64 exec, exec, s[0:1]
	v_cmp_gt_u32_e32 vcc, 64, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_21
.LBB0_20:
	s_waitcnt lgkmcnt(0)
	ds_bpermute_b32 v4, v6, v2
	ds_bpermute_b32 v5, v6, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v12, v1, v2
	ds_bpermute_b32 v13, v1, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[12:13]
	ds_bpermute_b32 v6, v7, v2
	ds_bpermute_b32 v7, v7, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v8, v2
	ds_bpermute_b32 v7, v8, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v9, v2
	ds_bpermute_b32 v7, v9, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v10, v2
	ds_bpermute_b32 v7, v10, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
.LBB0_21:
	s_or_b64 exec, exec, s[0:1]
	s_mov_b32 s1, 0
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_23
	s_mul_i32 s0, s14, s16
	s_add_i32 s0, s0, s15
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s2, s10, s0
	s_addc_u32 s3, s11, s1
	v_mov_b32_e32 v0, 0
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v2, s[2:3]
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s13, s1
	global_store_dword v0, v3, s[0:1]
.LBB0_23:
	s_endpgm
.LBB0_24:
	ds_read_b32 v2, v4
	s_or_b64 exec, exec, s[0:1]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_19
.LBB0_25:
	ds_read_b32 v3, v4 offset:4
	s_or_b64 exec, exec, s[0:1]
	v_cmp_gt_u32_e32 vcc, 64, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execnz .LBB0_20
	s_branch .LBB0_21
.LBB0_26:
	s_andn2_b64 vcc, exec, s[18:19]
	s_xor_b64 s[6:7], s[6:7], -1
	s_cbranch_vccz .LBB0_2
	s_branch .LBB0_3
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_
		.amdhsa_group_segment_fixed_size 128
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
		.amdhsa_user_sgpr_count 15
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 13
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 16
		.amdhsa_next_free_sgpr 29
		.amdhsa_accum_offset 16
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
	.text
.Lfunc_end0:
	.size	_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_, .Lfunc_end0-_ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_

	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.num_vgpr, 16
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.num_agpr, 0
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.numbered_sgpr, 29
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.private_seg_size, 0
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.uses_vcc, 1
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.uses_flat_scratch, 0
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.has_dyn_sized_stack, 0
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.has_recursion, 0
	.set _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.has_indirect_call, 0
	.section	.text._ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_,"axG",@progbits,_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_,comdat
	.protected	_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_
	.globl	_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_
	.p2align	8
	.type	_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_,@function
_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	s_bitcmp1_b32 s7, 0
	s_cselect_b64 s[24:25], -1, 0
	s_mov_b64 s[20:21], -1
	s_mov_b32 s18, 0
	s_mul_i32 s7, s5, s3
	s_mul_hi_u32 s19, s4, s3
	s_add_i32 s19, s19, s7
	s_cmp_lg_u64 s[18:19], 0
	s_mul_i32 s7, s4, s3
	s_cbranch_scc0 .LBB1_52
	v_cvt_f32_u32_e32 v1, s2
	v_cvt_f32_ubyte0_e32 v2, 0
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	s_sub_u32 s18, 0, s2
	s_subb_u32 s22, 0, 0
	v_readfirstlane_b32 s23, v2
	v_readfirstlane_b32 s26, v1
	s_mul_i32 s27, s18, s23
	s_mul_i32 s28, s22, s26
	s_mul_hi_u32 s29, s18, s26
	s_add_i32 s27, s29, s27
	s_add_i32 s27, s27, s28
	s_mul_hi_u32 s28, s26, s27
	s_mul_i32 s29, s26, s27
	s_mul_i32 s30, s18, s26
	s_mul_hi_u32 s26, s26, s30
	s_add_u32 s26, s26, s29
	s_addc_u32 s28, 0, s28
	s_mul_hi_u32 s29, s23, s27
	s_mul_hi_u32 s31, s23, s30
	s_mul_i32 s30, s23, s30
	s_add_u32 s26, s26, s30
	s_addc_u32 s26, s28, s31
	s_addc_u32 s28, s29, 0
	s_mul_i32 s27, s23, s27
	s_add_u32 s26, s26, s27
	s_addc_u32 s27, 0, s28
	v_add_co_u32_e32 v1, vcc, s26, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s23, s23, s27
	s_mul_i32 s26, s18, s23
	v_readfirstlane_b32 s27, v1
	s_mul_hi_u32 s28, s18, s27
	s_add_i32 s26, s28, s26
	s_mul_i32 s22, s22, s27
	s_add_i32 s26, s26, s22
	s_mul_hi_u32 s22, s23, s26
	s_mul_i32 s18, s18, s27
	s_mul_hi_u32 s28, s23, s18
	s_mul_i32 s29, s23, s18
	s_mul_hi_u32 s30, s27, s26
	s_mul_i32 s31, s27, s26
	s_mul_hi_u32 s18, s27, s18
	s_add_u32 s18, s18, s31
	s_addc_u32 s27, 0, s30
	s_add_u32 s18, s18, s29
	s_addc_u32 s18, s27, s28
	s_addc_u32 s22, s22, 0
	s_mul_i32 s26, s23, s26
	s_add_u32 s18, s18, s26
	s_addc_u32 s22, 0, s22
	v_add_co_u32_e32 v1, vcc, s18, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s26, s23, s22
	s_ashr_i32 s22, s19, 31
	s_mov_b32 s23, s22
	s_add_u32 s18, s7, s22
	s_addc_u32 s19, s19, s22
	s_xor_b64 s[18:19], s[18:19], s[22:23]
	s_mul_hi_u32 s27, s18, s26
	s_mul_i32 s28, s18, s26
	v_readfirstlane_b32 s29, v1
	s_mul_hi_u32 s30, s18, s29
	s_add_u32 s28, s30, s28
	s_addc_u32 s27, 0, s27
	s_mul_hi_u32 s30, s19, s26
	s_mul_hi_u32 s31, s19, s29
	s_mul_i32 s29, s19, s29
	s_add_u32 s28, s28, s29
	s_addc_u32 s27, s27, s31
	s_addc_u32 s28, s30, 0
	s_mul_i32 s26, s19, s26
	s_add_u32 s26, s27, s26
	s_addc_u32 s27, 0, s28
	s_add_u32 s28, s26, 1
	s_addc_u32 s29, s27, 0
	s_add_u32 s30, s26, 2
	s_addc_u32 s31, s27, 0
	s_mul_i32 s33, s2, s27
	s_mul_hi_u32 s34, s2, s26
	s_add_i32 s34, s34, s33
	s_mul_i32 s33, s2, s26
	v_mov_b32_e32 v1, s33
	v_sub_co_u32_e32 v1, vcc, s18, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s18, s19, s34
	v_subrev_co_u32_e32 v2, vcc, s2, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s19, s18, 0
	v_readfirstlane_b32 s33, v2
	s_cmp_ge_u32 s33, s2
	s_cselect_b32 s33, -1, 0
	s_cmp_eq_u32 s19, 0
	s_cselect_b32 s19, s33, -1
	s_cmp_lg_u32 s19, 0
	s_cselect_b32 s28, s30, s28
	s_cselect_b32 s19, s31, s29
	v_readfirstlane_b32 s29, v1
	s_cmp_ge_u32 s29, s2
	s_cselect_b32 s29, -1, 0
	s_cmp_eq_u32 s18, 0
	s_cselect_b32 s18, s29, -1
	s_cmp_lg_u32 s18, 0
	s_cselect_b32 s19, s19, s27
	s_cselect_b32 s18, s28, s26
	s_xor_b64 s[18:19], s[18:19], s[22:23]
	s_sub_u32 s18, s18, s22
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB1_3
.LBB1_2:
	v_cvt_f32_u32_e32 v1, s2
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_sub_i32 s18, 0, s2
	v_readfirstlane_b32 s19, v1
	s_mul_i32 s18, s18, s19
	s_mul_hi_u32 s18, s19, s18
	s_add_i32 s19, s19, s18
	s_mul_hi_u32 s18, s7, s19
	s_add_i32 s19, s18, 1
	s_mul_i32 s20, s18, s2
	s_sub_i32 s7, s7, s20
	s_sub_i32 s20, s7, s2
	s_cmp_ge_u32 s7, s2
	s_cselect_b32 s7, s20, s7
	s_cselect_b32 s18, s19, s18
	s_add_i32 s19, s18, 1
	s_cmp_ge_u32 s7, s2
	s_cselect_b32 s18, s19, s18
.LBB1_3:
	s_load_dword s2, s[0:1], 0x48
	s_load_dwordx4 s[20:23], s[0:1], 0x38
	s_add_u32 s0, s0, 0x48
	v_mov_b32_e32 v3, 0
	s_addc_u32 s1, s1, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_u32_e32 vcc, s2, v0
	v_mov_b32_e32 v2, v3
	s_and_saveexec_b64 s[26:27], vcc
	s_cbranch_execz .LBB1_7
	s_mul_i32 s7, s2, s17
	v_mov_b32_e32 v5, 0
	s_mov_b64 s[28:29], 0
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v3, v5
.LBB1_5:
	v_add_u32_e32 v4, s7, v1
	v_lshlrev_b64 v[6:7], 2, v[4:5]
	v_lshl_add_u64 v[8:9], s[14:15], 0, v[6:7]
	v_lshl_add_u64 v[6:7], s[20:21], 0, v[6:7]
	global_load_dword v8, v[8:9], off
	global_load_dword v9, v[6:7], off
	v_add_u32_e32 v1, 0x400, v1
	v_cmp_le_u32_e32 vcc, s2, v1
	s_or_b64 s[28:29], vcc, s[28:29]
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[8:9]
	s_andn2_b64 exec, exec, s[28:29]
	s_cbranch_execnz .LBB1_5
	s_or_b64 exec, exec, s[28:29]
.LBB1_7:
	s_or_b64 exec, exec, s[26:27]
	s_xor_b64 s[14:15], s[24:25], -1
	v_mbcnt_lo_u32_b32 v1, -1, 0
	v_mbcnt_hi_u32_b32 v10, -1, v1
	v_mov_b32_e32 v1, 0x80
	v_lshl_or_b32 v6, v10, 2, v1
	ds_bpermute_b32 v4, v6, v2
	ds_bpermute_b32 v5, v6, v3
	v_and_b32_e32 v11, 63, v10
	v_cmp_gt_u32_e32 vcc, 48, v11
	s_nop 1
	v_cndmask_b32_e64 v1, 0, 16, vcc
	v_add_lshl_u32 v1, v1, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v1, v2
	ds_bpermute_b32 v5, v1, v3
	v_cmp_gt_u32_e32 vcc, 56, v11
	s_nop 1
	v_cndmask_b32_e64 v7, 0, 8, vcc
	v_add_lshl_u32 v7, v7, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v7, v2
	ds_bpermute_b32 v5, v7, v3
	v_cmp_gt_u32_e32 vcc, 60, v11
	s_nop 1
	v_cndmask_b32_e64 v8, 0, 4, vcc
	v_add_lshl_u32 v8, v8, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v8, v2
	ds_bpermute_b32 v5, v8, v3
	v_cmp_gt_u32_e32 vcc, 62, v11
	s_nop 1
	v_cndmask_b32_e64 v9, 0, 2, vcc
	v_add_lshl_u32 v9, v9, v10, 2
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v4, v9, v2
	ds_bpermute_b32 v5, v9, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	v_cmp_ne_u32_e32 vcc, 63, v11
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, 0, v10, vcc
	v_lshlrev_b32_e32 v10, 2, v4
	ds_bpermute_b32 v4, v10, v2
	ds_bpermute_b32 v5, v10, v3
	v_and_b32_e32 v11, 63, v0
	v_cmp_eq_u32_e32 vcc, 0, v11
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB1_9
	v_lshrrev_b32_e32 v12, 3, v0
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_write2_b32 v12, v2, v3 offset1:1
.LBB1_9:
	s_or_b64 exec, exec, s[20:21]
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_cmp_gt_u32_e32 vcc, 16, v0
	v_lshlrev_b32_e32 v4, 3, v11
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, 0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execnz .LBB1_31
	s_or_b64 exec, exec, s[20:21]
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execnz .LBB1_32
.LBB1_11:
	s_or_b64 exec, exec, s[20:21]
	v_cmp_gt_u32_e32 vcc, 64, v0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execnz .LBB1_33
.LBB1_12:
	s_or_b64 exec, exec, s[20:21]
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB1_14
.LBB1_13:
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	ds_write_b64 v1, v[2:3]
.LBB1_14:
	s_or_b64 exec, exec, s[20:21]
	s_load_dword s7, s[0:1], 0xc
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mov_b32_e32 v1, 0
	ds_read_b64 v[2:3], v1
	v_cvt_f32_u32_e32 v1, s18
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v4, s[0:1], v1, v1, v2
	v_rcp_f32_e32 v5, v4
	v_div_scale_f32 v6, vcc, v2, v1, v2
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v7, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v7, v5
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v4, v4, v1, v2
	v_div_scale_f32 v2, s[0:1], v1, v1, v3
	v_rcp_f32_e32 v5, v2
	v_div_scale_f32 v6, vcc, v3, v1, v3
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 3
	v_fma_f32 v7, -v2, v5, 1.0
	v_fmac_f32_e32 v5, v7, v5
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v2, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v2, -v2, v7, v6
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	v_div_fmas_f32 v2, v2, v5, v7
	v_div_fixup_f32 v1, v2, v1, v3
	v_fma_f32 v1, -v4, v4, v1
	v_add_f32_e32 v1, s6, v1
	v_cvt_f64_f32_e32 v[2:3], v1
	v_rsq_f64_e32 v[2:3], v[2:3]
	s_and_b32 s0, s7, 0xffff
	s_mul_i32 s16, s16, s0
	v_add_u32_e32 v5, s16, v0
	v_cvt_f32_f64_e32 v6, v[2:3]
	s_andn2_b64 vcc, exec, s[14:15]
	s_mov_b64 s[0:1], -1
	s_cbranch_vccnz .LBB1_35
	v_cmp_gt_u32_e32 vcc, s18, v5
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_34
	s_mul_i32 s16, s17, s18
	s_mov_b64 s[14:15], 0
	s_cmp_lg_u64 s[10:11], 0
	s_cselect_b64 s[20:21], -1, 0
	s_cmp_lg_u64 s[12:13], 0
	s_cselect_b64 s[24:25], -1, 0
	s_lshl_b32 s19, s2, 10
	v_mov_b32_e32 v1, 0
	s_mov_b32 s26, 0
	s_mov_b32 s27, s5
	s_ashr_i32 s28, s5, 31
	s_sub_i32 s33, 0, s4
	v_cvt_f32_ubyte0_e32 v7, 0
	v_mov_b32_e32 v10, v5
	s_branch .LBB1_19
.LBB1_17:
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[12:13]
	global_load_dword v3, v[8:9], off
.LBB1_18:
	v_lshlrev_b64 v[8:9], 2, v[0:1]
	v_lshl_add_u64 v[12:13], s[8:9], 0, v[8:9]
	global_load_dword v0, v[12:13], off
	v_add_u32_e32 v10, s19, v10
	v_lshl_add_u64 v[8:9], s[22:23], 0, v[8:9]
	v_cmp_le_u32_e32 vcc, s18, v10
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v0, v0, v4
	v_mul_f32_e32 v0, v0, v6
	v_fmac_f32_e32 v3, v2, v0
	s_or_b64 s[14:15], vcc, s[14:15]
	global_store_dword v[8:9], v3, off
	s_andn2_b64 exec, exec, s[14:15]
	s_cbranch_execz .LBB1_34
.LBB1_19:
	s_cmp_lg_u64 s[26:27], 0
	v_add_u32_e32 v0, s16, v10
	s_cbranch_scc0 .LBB1_30
	s_mov_b32 s29, s28
	s_add_u32 s0, s4, s28
	s_addc_u32 s1, s5, s28
	s_xor_b64 s[30:31], s[0:1], s[28:29]
	v_cvt_f32_u32_e32 v2, s30
	v_cvt_f32_u32_e32 v3, s31
	v_fmac_f32_e32 v2, 0x4f800000, v3
	v_rcp_f32_e32 v2, v2
	s_nop 0
	v_mul_f32_e32 v2, 0x5f7ffffc, v2
	v_mul_f32_e32 v3, 0x2f800000, v2
	v_trunc_f32_e32 v3, v3
	v_fmac_f32_e32 v2, 0xcf800000, v3
	v_cvt_u32_f32_e32 v11, v3
	v_cvt_u32_f32_e32 v12, v2
	s_sub_u32 s0, 0, s30
	s_subb_u32 s1, 0, s31
	v_mul_lo_u32 v2, s0, v11
	v_mul_lo_u32 v3, s1, v12
	v_mul_hi_u32 v8, s0, v12
	v_mul_lo_u32 v13, s0, v12
	v_add_u32_e32 v2, v8, v2
	v_add_u32_e32 v14, v2, v3
	v_mul_hi_u32 v3, v12, v14
	v_mul_lo_u32 v2, v12, v14
	v_mul_hi_u32 v8, v12, v13
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[2:3], v[8:9], 0, v[2:3]
	v_mul_hi_u32 v8, v11, v14
	v_mul_hi_u32 v9, v11, v13
	v_mul_lo_u32 v13, v11, v13
	v_add_co_u32_e32 v2, vcc, v2, v13
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v9, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v8, vcc
	v_mul_lo_u32 v8, v11, v14
	v_mov_b32_e32 v3, v1
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_add_co_u32_e32 v12, vcc, v12, v2
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, v11, v3, vcc
	v_mul_lo_u32 v2, s0, v11
	v_mul_hi_u32 v3, s0, v12
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s1, v12
	v_add_u32_e32 v13, v2, v3
	v_mul_hi_u32 v14, v11, v13
	v_mul_lo_u32 v8, s0, v12
	v_mul_hi_u32 v15, v11, v8
	v_mul_lo_u32 v16, v11, v8
	v_mul_hi_u32 v3, v12, v13
	v_mul_lo_u32 v2, v12, v13
	v_mul_hi_u32 v8, v12, v8
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[2:3], v[8:9], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v16
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v15, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v14, vcc
	v_mul_lo_u32 v8, v11, v13
	v_mov_b32_e32 v3, v1
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_add_co_u32_e32 v12, vcc, v12, v2
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, v11, v3, vcc
	v_mad_u64_u32 v[2:3], s[0:1], v0, v11, 0
	v_mul_hi_u32 v8, v0, v12
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[2:3], v[8:9], 0, v[2:3]
	v_mad_u64_u32 v[8:9], s[0:1], 0, v11, 0
	v_mad_u64_u32 v[12:13], s[0:1], 0, v12, 0
	v_add_co_u32_e32 v2, vcc, v2, v12
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v13, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v9, vcc
	v_mov_b32_e32 v3, v1
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_mul_lo_u32 v11, s31, v2
	v_mul_lo_u32 v12, s30, v3
	v_mad_u64_u32 v[8:9], s[0:1], s30, v2, 0
	v_add3_u32 v11, v9, v12, v11
	v_sub_u32_e32 v9, 0, v11
	v_mov_b32_e32 v12, s31
	v_sub_co_u32_e32 v14, vcc, v0, v8
	s_nop 1
	v_subb_co_u32_e64 v8, s[0:1], v9, v12, vcc
	v_subrev_co_u32_e64 v9, s[0:1], s30, v14
	s_nop 1
	v_subbrev_co_u32_e64 v8, s[0:1], 0, v8, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s31, v8
	s_nop 1
	v_cndmask_b32_e64 v12, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s30, v9
	s_nop 1
	v_cndmask_b32_e64 v9, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s31, v8
	s_nop 1
	v_cndmask_b32_e64 v15, v12, v9, s[0:1]
	v_lshl_add_u64 v[8:9], v[2:3], 0, 2
	v_lshl_add_u64 v[12:13], v[2:3], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v15
	s_nop 1
	v_cndmask_b32_e64 v9, v13, v9, s[0:1]
	v_subb_co_u32_e32 v11, vcc, 0, v11, vcc
	v_cmp_le_u32_e32 vcc, s31, v11
	s_nop 1
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s30, v14
	s_nop 1
	v_cndmask_b32_e64 v14, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s31, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v13, v14, vcc
	v_cmp_ne_u32_e32 vcc, 0, v11
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v9, vcc
	v_cndmask_b32_e64 v8, v12, v8, s[0:1]
	v_cndmask_b32_e32 v2, v2, v8, vcc
	v_xor_b32_e32 v3, s28, v3
	v_xor_b32_e32 v2, s28, v2
	v_mov_b32_e32 v8, s28
	v_subrev_co_u32_e32 v2, vcc, s28, v2
	s_nop 1
	v_subb_co_u32_e32 v3, vcc, v3, v8, vcc
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB1_22
.LBB1_21:
	v_cvt_f32_u32_e32 v2, s4
	v_rcp_iflag_f32_e32 v2, v2
	s_nop 0
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_mul_lo_u32 v3, s33, v2
	v_mul_hi_u32 v3, v2, v3
	v_add_u32_e32 v2, v2, v3
	v_mul_hi_u32 v2, v0, v2
	v_mul_lo_u32 v3, v2, s4
	v_add_u32_e32 v8, 1, v2
	v_sub_u32_e32 v3, v0, v3
	v_subrev_u32_e32 v9, s4, v3
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v9, vcc
	v_cndmask_b32_e32 v2, v2, v8, vcc
	v_add_u32_e32 v8, 1, v2
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v8, vcc
	v_mov_b32_e32 v3, v1
.LBB1_22:
	v_mov_b32_e32 v8, v1
	v_mov_b32_e32 v9, v3
	v_cmp_ne_u64_e32 vcc, 0, v[8:9]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[0:1], exec, s[0:1]
	s_cbranch_execnz .LBB1_26
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	s_cbranch_execnz .LBB1_27
.LBB1_24:
	s_or_b64 exec, exec, s[0:1]
	s_andn2_b64 vcc, exec, s[20:21]
	s_cbranch_vccnz .LBB1_28
.LBB1_25:
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[2:3], v[8:9], 2, s[10:11]
	global_load_dword v2, v[2:3], off
	s_andn2_b64 vcc, exec, s[24:25]
	s_cbranch_vccz .LBB1_17
	s_branch .LBB1_29
.LBB1_26:
	v_cvt_f32_u32_e32 v8, s3
	v_fmac_f32_e32 v8, 0x4f800000, v7
	v_rcp_f32_e32 v8, v8
	s_sub_u32 s29, 0, s3
	v_mul_f32_e32 v8, 0x5f7ffffc, v8
	v_mul_f32_e32 v9, 0x2f800000, v8
	v_trunc_f32_e32 v9, v9
	v_fmac_f32_e32 v8, 0xcf800000, v9
	v_cvt_u32_f32_e32 v11, v9
	v_cvt_u32_f32_e32 v14, v8
	v_mov_b32_e32 v9, v1
	s_subb_u32 s30, 0, 0
	v_mul_lo_u32 v8, s29, v11
	v_mul_lo_u32 v12, s30, v14
	v_mul_hi_u32 v13, s29, v14
	v_mul_lo_u32 v15, s29, v14
	v_add_u32_e32 v13, v13, v8
	v_mul_hi_u32 v8, v14, v15
	v_add_u32_e32 v16, v13, v12
	v_mul_hi_u32 v13, v14, v16
	v_mul_lo_u32 v12, v14, v16
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_mul_hi_u32 v12, v11, v16
	v_mul_hi_u32 v13, v11, v15
	v_mul_lo_u32 v15, v11, v15
	v_add_co_u32_e32 v8, vcc, v8, v15
	s_nop 1
	v_addc_co_u32_e32 v8, vcc, v9, v13, vcc
	s_nop 1
	v_addc_co_u32_e32 v13, vcc, 0, v12, vcc
	v_mul_lo_u32 v12, v11, v16
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_add_co_u32_e32 v14, vcc, v14, v8
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, v11, v9, vcc
	v_mul_lo_u32 v8, s29, v11
	v_mul_hi_u32 v9, s29, v14
	v_add_u32_e32 v8, v9, v8
	v_mul_lo_u32 v9, s30, v14
	v_add_u32_e32 v15, v8, v9
	v_mul_hi_u32 v16, v11, v15
	v_mul_lo_u32 v12, s29, v14
	v_mul_hi_u32 v17, v11, v12
	v_mul_lo_u32 v18, v11, v12
	v_mul_hi_u32 v9, v14, v15
	v_mul_lo_u32 v8, v14, v15
	v_mul_hi_u32 v12, v14, v12
	v_mov_b32_e32 v13, v1
	v_lshl_add_u64 v[8:9], v[12:13], 0, v[8:9]
	v_add_co_u32_e32 v8, vcc, v8, v18
	s_nop 1
	v_addc_co_u32_e32 v8, vcc, v9, v17, vcc
	s_nop 1
	v_addc_co_u32_e32 v13, vcc, 0, v16, vcc
	v_mul_lo_u32 v12, v11, v15
	v_mov_b32_e32 v9, v1
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_add_co_u32_e32 v14, vcc, v14, v8
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, v11, v9, vcc
	v_ashrrev_i32_e32 v8, 31, v3
	v_mov_b32_e32 v9, v8
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_xor_b32_e32 v9, v3, v8
	v_xor_b32_e32 v16, v2, v8
	v_mad_u64_u32 v[2:3], s[30:31], v16, v11, 0
	v_mul_hi_u32 v12, v16, v14
	v_mov_b32_e32 v13, v1
	v_lshl_add_u64 v[2:3], v[12:13], 0, v[2:3]
	v_mad_u64_u32 v[12:13], s[30:31], v9, v11, 0
	v_mad_u64_u32 v[14:15], s[30:31], v9, v14, 0
	v_add_co_u32_e32 v2, vcc, v2, v14
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v15, vcc
	s_nop 1
	v_addc_co_u32_e32 v13, vcc, 0, v13, vcc
	v_mov_b32_e32 v3, v1
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[12:13]
	v_mad_u64_u32 v[12:13], s[30:31], s3, v2, 0
	v_mov_b32_e32 v2, v13
	v_mad_u64_u32 v[2:3], s[30:31], s3, v3, v[2:3]
	v_sub_co_u32_e32 v3, vcc, v16, v12
	s_nop 1
	v_subb_co_u32_e32 v2, vcc, v9, v2, vcc
	v_subrev_co_u32_e32 v9, vcc, s3, v3
	s_nop 1
	v_subbrev_co_u32_e32 v11, vcc, 0, v2, vcc
	v_subrev_co_u32_e32 v12, vcc, s3, v9
	v_cmp_le_u32_e32 vcc, s3, v9
	s_nop 1
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v11
	s_nop 1
	v_cndmask_b32_e32 v11, -1, v13, vcc
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v2
	s_nop 1
	v_cndmask_b32_e32 v2, -1, v13, vcc
	v_cmp_ne_u32_e32 vcc, 0, v11
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v12, vcc
	v_cmp_ne_u32_e32 vcc, 0, v2
	s_nop 1
	v_cndmask_b32_e32 v2, v3, v9, vcc
	v_xor_b32_e32 v2, v2, v8
	v_sub_co_u32_e32 v8, vcc, v2, v8
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	s_cbranch_execz .LBB1_24
.LBB1_27:
	v_cvt_f32_u32_e32 v3, s3
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	s_sub_i32 s29, 0, s3
	v_mul_lo_u32 v8, s29, v3
	v_mul_hi_u32 v8, v3, v8
	v_add_u32_e32 v3, v3, v8
	v_mul_hi_u32 v3, v2, v3
	v_mul_lo_u32 v3, v3, s3
	v_sub_u32_e32 v2, v2, v3
	v_subrev_u32_e32 v3, s3, v2
	v_cmp_le_u32_e32 vcc, s3, v2
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v3, vcc
	v_subrev_u32_e32 v3, s3, v2
	v_cmp_le_u32_e32 vcc, s3, v2
	s_nop 1
	v_cndmask_b32_e32 v8, v2, v3, vcc
	s_or_b64 exec, exec, s[0:1]
	s_andn2_b64 vcc, exec, s[20:21]
	s_cbranch_vccz .LBB1_25
.LBB1_28:
	v_mov_b32_e32 v2, 1.0
	s_andn2_b64 vcc, exec, s[24:25]
	s_cbranch_vccz .LBB1_17
.LBB1_29:
	v_mov_b32_e32 v3, 0
	s_branch .LBB1_18
.LBB1_30:
	s_mov_b64 vcc, 0
	s_branch .LBB1_21
.LBB1_31:
	ds_read_b32 v2, v4
	s_or_b64 exec, exec, s[20:21]
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB1_11
.LBB1_32:
	ds_read_b32 v3, v4 offset:4
	s_or_b64 exec, exec, s[20:21]
	v_cmp_gt_u32_e32 vcc, 64, v0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB1_12
.LBB1_33:
	s_waitcnt lgkmcnt(0)
	ds_bpermute_b32 v4, v6, v2
	ds_bpermute_b32 v5, v6, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_bpermute_b32 v12, v1, v2
	ds_bpermute_b32 v13, v1, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[12:13]
	ds_bpermute_b32 v6, v7, v2
	ds_bpermute_b32 v7, v7, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v8, v2
	ds_bpermute_b32 v7, v8, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v9, v2
	ds_bpermute_b32 v7, v9, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	ds_bpermute_b32 v6, v10, v2
	ds_bpermute_b32 v7, v10, v3
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	s_or_b64 exec, exec, s[20:21]
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execnz .LBB1_13
	s_branch .LBB1_14
.LBB1_34:
	s_or_b64 exec, exec, s[6:7]
	s_mov_b64 s[0:1], 0
.LBB1_35:
	s_andn2_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB1_51
	v_lshlrev_b32_e32 v11, 2, v5
	v_cmp_gt_u32_e32 vcc, s18, v11
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_51
	s_mul_i32 s19, s17, s18
	s_mov_b64 s[6:7], 0
	s_cmp_lg_u64 s[10:11], 0
	s_cselect_b64 s[14:15], -1, 0
	s_cmp_lg_u64 s[12:13], 0
	s_cselect_b64 s[16:17], -1, 0
	s_lshl_b32 s2, s2, 12
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v10, 1.0
	s_mov_b32 s20, 0
	s_mov_b32 s21, s5
	s_ashr_i32 s24, s5, 31
	s_sub_i32 s28, 0, s4
	v_cvt_f32_ubyte0_e32 v13, 0
	v_mov_b32_e32 v12, v9
	s_branch .LBB1_39
.LBB1_38:
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[0:1], v[0:1], v[4:5] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[2:3], v[2:3], v[4:5] neg_lo:[0,1] neg_hi:[0,1]
	v_lshl_add_u64 v[14:15], v[8:9], 2, s[22:23]
	v_pk_mul_f32 v[0:1], v[0:1], v[6:7]
	s_nop 0
	v_pk_fma_f32 v[0:1], v[0:1], v[10:11], v[12:13] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[6:7]
	s_nop 0
	v_pk_fma_f32 v[2:3], v[2:3], v[10:11], v[12:13] op_sel_hi:[1,0,0]
	v_add_u32_e32 v11, s2, v11
	v_cmp_le_u32_e32 vcc, s18, v11
	s_or_b64 s[6:7], vcc, s[6:7]
	global_store_dwordx4 v[14:15], v[0:3], off
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execz .LBB1_51
.LBB1_39:
	s_cmp_lg_u64 s[20:21], 0
	v_add_u32_e32 v8, s19, v11
	s_cbranch_scc0 .LBB1_50
	s_mov_b32 s25, s24
	s_add_u32 s0, s4, s24
	s_addc_u32 s1, s5, s24
	s_xor_b64 s[26:27], s[0:1], s[24:25]
	v_cvt_f32_u32_e32 v0, s26
	v_cvt_f32_u32_e32 v1, s27
	v_fmac_f32_e32 v0, 0x4f800000, v1
	v_rcp_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v0, 0x5f7ffffc, v0
	v_mul_f32_e32 v1, 0x2f800000, v0
	v_trunc_f32_e32 v1, v1
	v_fmac_f32_e32 v0, 0xcf800000, v1
	v_cvt_u32_f32_e32 v14, v1
	v_cvt_u32_f32_e32 v15, v0
	s_sub_u32 s0, 0, s26
	s_subb_u32 s1, 0, s27
	v_mul_lo_u32 v0, s0, v14
	v_mul_lo_u32 v1, s1, v15
	v_mul_hi_u32 v2, s0, v15
	v_mul_lo_u32 v16, s0, v15
	v_add_u32_e32 v0, v2, v0
	v_add_u32_e32 v17, v0, v1
	v_mul_hi_u32 v1, v15, v17
	v_mul_lo_u32 v0, v15, v17
	v_mul_hi_u32 v2, v15, v16
	v_mov_b32_e32 v3, v9
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[0:1]
	v_mul_hi_u32 v2, v14, v17
	v_mul_hi_u32 v3, v14, v16
	v_mul_lo_u32 v16, v14, v16
	v_add_co_u32_e32 v0, vcc, v0, v16
	s_nop 1
	v_addc_co_u32_e32 v0, vcc, v1, v3, vcc
	s_nop 1
	v_addc_co_u32_e32 v3, vcc, 0, v2, vcc
	v_mul_lo_u32 v2, v14, v17
	v_mov_b32_e32 v1, v9
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_add_co_u32_e32 v15, vcc, v15, v0
	s_nop 1
	v_addc_co_u32_e32 v14, vcc, v14, v1, vcc
	v_mul_lo_u32 v0, s0, v14
	v_mul_hi_u32 v1, s0, v15
	v_add_u32_e32 v0, v1, v0
	v_mul_lo_u32 v1, s1, v15
	v_add_u32_e32 v16, v0, v1
	v_mul_hi_u32 v17, v14, v16
	v_mul_lo_u32 v2, s0, v15
	v_mul_hi_u32 v18, v14, v2
	v_mul_lo_u32 v19, v14, v2
	v_mul_hi_u32 v1, v15, v16
	v_mul_lo_u32 v0, v15, v16
	v_mul_hi_u32 v2, v15, v2
	v_mov_b32_e32 v3, v9
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[0:1]
	v_add_co_u32_e32 v0, vcc, v0, v19
	s_nop 1
	v_addc_co_u32_e32 v0, vcc, v1, v18, vcc
	s_nop 1
	v_addc_co_u32_e32 v3, vcc, 0, v17, vcc
	v_mul_lo_u32 v2, v14, v16
	v_mov_b32_e32 v1, v9
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_add_co_u32_e32 v15, vcc, v15, v0
	s_nop 1
	v_addc_co_u32_e32 v14, vcc, v14, v1, vcc
	v_mad_u64_u32 v[0:1], s[0:1], v8, v14, 0
	v_mul_hi_u32 v2, v8, v15
	v_mov_b32_e32 v3, v9
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[0:1]
	v_mad_u64_u32 v[2:3], s[0:1], 0, v14, 0
	v_mad_u64_u32 v[14:15], s[0:1], 0, v15, 0
	v_add_co_u32_e32 v0, vcc, v0, v14
	s_nop 1
	v_addc_co_u32_e32 v0, vcc, v1, v15, vcc
	s_nop 1
	v_addc_co_u32_e32 v3, vcc, 0, v3, vcc
	v_mov_b32_e32 v1, v9
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mul_lo_u32 v14, s27, v0
	v_mul_lo_u32 v15, s26, v1
	v_mad_u64_u32 v[2:3], s[0:1], s26, v0, 0
	v_add3_u32 v16, v3, v15, v14
	v_sub_u32_e32 v3, 0, v16
	v_mov_b32_e32 v14, s27
	v_sub_co_u32_e32 v17, vcc, v8, v2
	s_nop 1
	v_subb_co_u32_e64 v2, s[0:1], v3, v14, vcc
	v_subrev_co_u32_e64 v3, s[0:1], s26, v17
	s_nop 1
	v_subbrev_co_u32_e64 v2, s[0:1], 0, v2, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s27, v2
	s_nop 1
	v_cndmask_b32_e64 v14, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s26, v3
	s_nop 1
	v_cndmask_b32_e64 v3, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s27, v2
	s_nop 1
	v_cndmask_b32_e64 v18, v14, v3, s[0:1]
	v_lshl_add_u64 v[2:3], v[0:1], 0, 2
	v_lshl_add_u64 v[14:15], v[0:1], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v18
	s_nop 1
	v_cndmask_b32_e64 v3, v15, v3, s[0:1]
	v_subb_co_u32_e32 v15, vcc, 0, v16, vcc
	v_cmp_le_u32_e32 vcc, s27, v15
	s_nop 1
	v_cndmask_b32_e64 v16, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s26, v17
	s_nop 1
	v_cndmask_b32_e64 v17, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s27, v15
	s_nop 1
	v_cndmask_b32_e32 v15, v16, v17, vcc
	v_cmp_ne_u32_e32 vcc, 0, v15
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v3, vcc
	v_cndmask_b32_e64 v2, v14, v2, s[0:1]
	v_cndmask_b32_e32 v0, v0, v2, vcc
	v_xor_b32_e32 v1, s24, v1
	v_xor_b32_e32 v0, s24, v0
	v_mov_b32_e32 v2, s24
	v_subrev_co_u32_e32 v0, vcc, s24, v0
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v1, v2, vcc
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB1_42
.LBB1_41:
	v_cvt_f32_u32_e32 v0, s4
	v_rcp_iflag_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v0, 0x4f7ffffe, v0
	v_cvt_u32_f32_e32 v0, v0
	v_mul_lo_u32 v1, s28, v0
	v_mul_hi_u32 v1, v0, v1
	v_add_u32_e32 v0, v0, v1
	v_mul_hi_u32 v0, v8, v0
	v_mul_lo_u32 v1, v0, s4
	v_add_u32_e32 v2, 1, v0
	v_sub_u32_e32 v1, v8, v1
	v_subrev_u32_e32 v3, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v3, vcc
	v_cndmask_b32_e32 v0, v0, v2, vcc
	v_add_u32_e32 v2, 1, v0
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v2, vcc
	v_mov_b32_e32 v1, v9
.LBB1_42:
	v_mov_b32_e32 v2, v9
	v_mov_b32_e32 v3, v1
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[0:1], exec, s[0:1]
	s_cbranch_execz .LBB1_44
	v_cvt_f32_u32_e32 v2, s3
	v_fmac_f32_e32 v2, 0x4f800000, v13
	v_rcp_f32_e32 v2, v2
	s_sub_u32 s25, 0, s3
	v_mul_f32_e32 v2, 0x5f7ffffc, v2
	v_mul_f32_e32 v3, 0x2f800000, v2
	v_trunc_f32_e32 v3, v3
	v_fmac_f32_e32 v2, 0xcf800000, v3
	v_cvt_u32_f32_e32 v16, v3
	v_cvt_u32_f32_e32 v17, v2
	v_mov_b32_e32 v3, v9
	s_subb_u32 s26, 0, 0
	v_mul_lo_u32 v2, s25, v16
	v_mul_lo_u32 v14, s26, v17
	v_mul_hi_u32 v15, s25, v17
	v_mul_lo_u32 v18, s25, v17
	v_add_u32_e32 v15, v15, v2
	v_mul_hi_u32 v2, v17, v18
	v_add_u32_e32 v19, v15, v14
	v_mul_hi_u32 v15, v17, v19
	v_mul_lo_u32 v14, v17, v19
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[14:15]
	v_mul_hi_u32 v14, v16, v19
	v_mul_hi_u32 v15, v16, v18
	v_mul_lo_u32 v18, v16, v18
	v_add_co_u32_e32 v2, vcc, v2, v18
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v15, vcc
	s_nop 1
	v_addc_co_u32_e32 v15, vcc, 0, v14, vcc
	v_mul_lo_u32 v14, v16, v19
	v_mov_b32_e32 v3, v9
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[14:15]
	v_add_co_u32_e32 v17, vcc, v17, v2
	s_nop 1
	v_addc_co_u32_e32 v16, vcc, v16, v3, vcc
	v_mul_lo_u32 v2, s25, v16
	v_mul_hi_u32 v3, s25, v17
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s26, v17
	v_add_u32_e32 v18, v2, v3
	v_mul_hi_u32 v19, v16, v18
	v_mul_lo_u32 v14, s25, v17
	v_mul_hi_u32 v20, v16, v14
	v_mul_lo_u32 v21, v16, v14
	v_mul_hi_u32 v3, v17, v18
	v_mul_lo_u32 v2, v17, v18
	v_mul_hi_u32 v14, v17, v14
	v_mov_b32_e32 v15, v9
	v_lshl_add_u64 v[2:3], v[14:15], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v21
	s_nop 1
	v_addc_co_u32_e32 v2, vcc, v3, v20, vcc
	s_nop 1
	v_addc_co_u32_e32 v15, vcc, 0, v19, vcc
	v_mul_lo_u32 v14, v16, v18
	v_mov_b32_e32 v3, v9
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[14:15]
	v_add_co_u32_e32 v17, vcc, v17, v2
	s_nop 1
	v_addc_co_u32_e32 v16, vcc, v16, v3, vcc
	v_ashrrev_i32_e32 v2, 31, v1
	v_mov_b32_e32 v3, v2
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_xor_b32_e32 v3, v1, v2
	v_xor_b32_e32 v18, v0, v2
	v_mad_u64_u32 v[0:1], s[26:27], v18, v16, 0
	v_mul_hi_u32 v14, v18, v17
	v_mov_b32_e32 v15, v9
	v_lshl_add_u64 v[0:1], v[14:15], 0, v[0:1]
	v_mad_u64_u32 v[14:15], s[26:27], v3, v16, 0
	v_mad_u64_u32 v[16:17], s[26:27], v3, v17, 0
	v_add_co_u32_e32 v0, vcc, v0, v16
	s_nop 1
	v_addc_co_u32_e32 v0, vcc, v1, v17, vcc
	s_nop 1
	v_addc_co_u32_e32 v15, vcc, 0, v15, vcc
	v_mov_b32_e32 v1, v9
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[14:15]
	v_mad_u64_u32 v[14:15], s[26:27], s3, v0, 0
	v_mov_b32_e32 v0, v15
	v_mad_u64_u32 v[0:1], s[26:27], s3, v1, v[0:1]
	v_sub_co_u32_e32 v1, vcc, v18, v14
	s_nop 1
	v_subb_co_u32_e32 v0, vcc, v3, v0, vcc
	v_subrev_co_u32_e32 v3, vcc, s3, v1
	s_nop 1
	v_subbrev_co_u32_e32 v14, vcc, 0, v0, vcc
	v_subrev_co_u32_e32 v15, vcc, s3, v3
	v_cmp_le_u32_e32 vcc, s3, v3
	s_nop 1
	v_cndmask_b32_e64 v16, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v14
	s_nop 1
	v_cndmask_b32_e32 v14, -1, v16, vcc
	v_cmp_le_u32_e32 vcc, s3, v1
	s_nop 1
	v_cndmask_b32_e64 v16, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_nop 1
	v_cndmask_b32_e32 v0, -1, v16, vcc
	v_cmp_ne_u32_e32 vcc, 0, v14
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v15, vcc
	v_cmp_ne_u32_e32 vcc, 0, v0
	s_nop 1
	v_cndmask_b32_e32 v0, v1, v3, vcc
	v_xor_b32_e32 v0, v0, v2
	v_sub_co_u32_e32 v14, vcc, v0, v2
.LBB1_44:
	s_andn2_saveexec_b64 s[0:1], s[0:1]
	s_cbranch_execz .LBB1_46
	v_cvt_f32_u32_e32 v1, s3
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_sub_i32 s25, 0, s3
	v_mul_lo_u32 v2, s25, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, v0, v1
	v_mul_lo_u32 v1, v1, s3
	v_sub_u32_e32 v0, v0, v1
	v_subrev_u32_e32 v1, s3, v0
	v_cmp_le_u32_e32 vcc, s3, v0
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v1, vcc
	v_subrev_u32_e32 v1, s3, v0
	v_cmp_le_u32_e32 vcc, s3, v0
	s_nop 1
	v_cndmask_b32_e32 v14, v0, v1, vcc
.LBB1_46:
	s_or_b64 exec, exec, s[0:1]
	v_lshl_add_u64 v[0:1], v[8:9], 2, s[8:9]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB1_48
	v_mov_b32_e32 v15, v9
	v_lshl_add_u64 v[16:17], v[14:15], 2, s[10:11]
	global_load_dword v10, v[16:17], off
.LBB1_48:
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB1_38
	v_mov_b32_e32 v15, v9
	v_lshl_add_u64 v[14:15], v[14:15], 2, s[12:13]
	global_load_dword v12, v[14:15], off
	s_branch .LBB1_38
.LBB1_50:
	s_mov_b64 vcc, 0
	s_branch .LBB1_41
.LBB1_51:
	s_endpgm
.LBB1_52:
	s_andn2_b64 vcc, exec, s[20:21]
	s_cbranch_vccz .LBB1_2
	s_branch .LBB1_3
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_
		.amdhsa_group_segment_fixed_size 128
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
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
		.amdhsa_next_free_vgpr 22
		.amdhsa_next_free_sgpr 35
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
	.section	.text._ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_,"axG",@progbits,_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_,comdat
.Lfunc_end1:
	.size	_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_, .Lfunc_end1-_ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_

	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.num_vgpr, 22
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.num_agpr, 0
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.numbered_sgpr, 35
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.private_seg_size, 0
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.uses_vcc, 1
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.uses_flat_scratch, 0
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.has_dyn_sized_stack, 0
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.has_recursion, 0
	.set _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_a2a232307e39e822,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_a2a232307e39e822
__hip_cuid_a2a232307e39e822:
	.byte	0
	.size	__hip_cuid_a2a232307e39e822, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_a2a232307e39e822
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           8
        .value_kind:     by_value
      - .offset:         16
        .size:           1
        .value_kind:     by_value
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
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 128
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .max_flat_workgroup_size: 1024
    .name:           _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN2gn28groupnorm_kernel_dispatch_upIfLj1024EEEvjjxbPKT_PfS4_.kd
    .uses_dynamic_stack: false
    .vgpr_count:     16
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
      - .offset:         4
        .size:           4
        .value_kind:     by_value
      - .offset:         8
        .size:           8
        .value_kind:     by_value
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           1
        .value_kind:     by_value
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
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         76
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         84
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         86
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         88
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         90
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         92
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         94
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         136
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 128
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .max_flat_workgroup_size: 1024
    .name:           _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_
    .private_segment_fixed_size: 0
    .sgpr_count:     41
    .sgpr_spill_count: 0
    .symbol:         _ZN2gn30groupnorm_kernel_dispatch_downIfLj1024EEEvjjxfbPKT_S3_S3_PKfS5_PS1_.kd
    .uses_dynamic_stack: false
    .vgpr_count:     22
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
