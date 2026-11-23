; CLBlast 1.6.3 src/kernels/level3/xgemm_direct_part3.opencl (XgemmDirectNT), Xgemm, compiled for gfx950
; by external/amd/opencl/clblast/extract.py (case gemm_direct_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	XgemmDirectNN
	.globl	XgemmDirectNN
	.p2align	8
	.type	XgemmDirectNN,@function
XgemmDirectNN:
	s_load_dwordx2 s[4:5], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s4, s3
	s_add_i32 s8, s3, s2
	s_ashr_i32 s9, s8, 31
	s_mov_b32 s2, 0
	s_mov_b32 s3, s9
	s_cmp_lg_u64 s[2:3], 0
	s_cbranch_scc0 .LBB0_40
	v_cvt_f32_u32_e32 v1, s5
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s5
	s_subb_u32 s7, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s12, s6, s10
	s_mul_hi_u32 s14, s6, s11
	s_mul_i32 s13, s7, s11
	s_add_i32 s12, s14, s12
	s_add_i32 s12, s12, s13
	s_mul_i32 s15, s6, s11
	s_mul_hi_u32 s13, s11, s12
	s_mul_i32 s14, s11, s12
	s_mul_hi_u32 s11, s11, s15
	s_add_u32 s11, s11, s14
	s_addc_u32 s13, 0, s13
	s_mul_hi_u32 s16, s10, s15
	s_mul_i32 s15, s10, s15
	s_add_u32 s11, s11, s15
	s_mul_hi_u32 s14, s10, s12
	s_addc_u32 s11, s13, s16
	s_addc_u32 s13, s14, 0
	s_mul_i32 s12, s10, s12
	s_add_u32 s11, s11, s12
	s_addc_u32 s12, 0, s13
	v_add_co_u32_e32 v1, vcc, s11, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s10, s10, s12
	v_readfirstlane_b32 s12, v1
	s_mul_i32 s11, s6, s10
	s_mul_hi_u32 s13, s6, s12
	s_add_i32 s11, s13, s11
	s_mul_i32 s7, s7, s12
	s_add_i32 s11, s11, s7
	s_mul_i32 s6, s6, s12
	s_mul_hi_u32 s13, s10, s6
	s_mul_i32 s14, s10, s6
	s_mul_i32 s16, s12, s11
	s_mul_hi_u32 s6, s12, s6
	s_mul_hi_u32 s15, s12, s11
	s_add_u32 s6, s6, s16
	s_addc_u32 s12, 0, s15
	s_add_u32 s6, s6, s14
	s_mul_hi_u32 s7, s10, s11
	s_addc_u32 s6, s12, s13
	s_addc_u32 s7, s7, 0
	s_mul_i32 s11, s10, s11
	s_add_u32 s6, s6, s11
	s_addc_u32 s7, 0, s7
	v_add_co_u32_e32 v1, vcc, s6, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s6, s10, s7
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s10, s8, s6
	s_mul_hi_u32 s12, s8, s11
	s_mul_hi_u32 s7, s8, s6
	s_add_u32 s10, s12, s10
	s_addc_u32 s7, 0, s7
	s_mul_hi_u32 s13, s9, s11
	s_mul_i32 s11, s9, s11
	s_add_u32 s10, s10, s11
	s_mul_hi_u32 s12, s9, s6
	s_addc_u32 s7, s7, s13
	s_addc_u32 s10, s12, 0
	s_mul_i32 s6, s9, s6
	s_add_u32 s6, s7, s6
	s_addc_u32 s7, 0, s10
	s_add_u32 s10, s6, 1
	s_addc_u32 s11, s7, 0
	s_add_u32 s12, s6, 2
	s_mul_i32 s14, s5, s7
	s_mul_hi_u32 s15, s5, s6
	s_addc_u32 s13, s7, 0
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s5, s6
	v_mov_b32_e32 v1, s14
	v_sub_co_u32_e32 v1, vcc, s8, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s14, s9, s15
	v_subrev_co_u32_e32 v2, vcc, s5, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s15, s14, 0
	v_readfirstlane_b32 s16, v2
	s_cmp_ge_u32 s16, s5
	s_cselect_b32 s16, -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b32 s15, s16, -1
	s_cmp_lg_u32 s15, 0
	s_cselect_b32 s10, s12, s10
	v_readfirstlane_b32 s12, v1
	s_cselect_b32 s11, s13, s11
	s_cmp_ge_u32 s12, s5
	s_cselect_b32 s12, -1, 0
	s_cmp_eq_u32 s14, 0
	s_cselect_b32 s12, s12, -1
	s_cmp_lg_u32 s12, 0
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s6, s10, s6
	s_cbranch_execnz .LBB0_3
.LBB0_2:
	v_cvt_f32_u32_e32 v1, s5
	s_sub_i32 s2, 0, s5
	s_mov_b32 s7, 0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s3, v1
	s_mul_i32 s2, s2, s3
	s_mul_hi_u32 s2, s3, s2
	s_add_i32 s3, s3, s2
	s_mul_hi_u32 s2, s8, s3
	s_mul_i32 s6, s2, s5
	s_sub_i32 s6, s8, s6
	s_add_i32 s3, s2, 1
	s_sub_i32 s10, s6, s5
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s2, s3, s2
	s_cselect_b32 s6, s10, s6
	s_add_i32 s3, s2, 1
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s6, s3, s2
.LBB0_3:
	s_mul_i32 s2, s7, s5
	s_mul_hi_u32 s3, s6, s5
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s6, s5
	s_sub_u32 s28, s8, s2
	s_subb_u32 s29, s9, s3
	s_bfe_i64 s[2:3], s[28:29], 0x200000
	s_add_u32 s5, s2, s6
	s_addc_u32 s7, s3, s7
	s_mov_b32 s6, 0
	s_cmp_lg_u64 s[6:7], 0
	s_cbranch_scc0 .LBB0_41
	v_cvt_f32_u32_e32 v1, s4
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s4
	s_subb_u32 s8, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	v_mov_b32_e32 v5, 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v6, v2
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s6, v6
	v_mul_hi_u32 v4, s6, v1
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v2, v4, v2
	v_mul_lo_u32 v7, s6, v1
	v_add_u32_e32 v8, v2, v3
	v_mul_hi_u32 v3, v1, v8
	v_mul_lo_u32 v2, v1, v8
	v_mul_hi_u32 v4, v1, v7
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, v6, v7
	v_mul_lo_u32 v7, v6, v7
	v_add_co_u32_e32 v2, vcc, v2, v7
	v_mul_hi_u32 v9, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v9, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_lo_u32 v4, s6, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_lo_u32 v2, s6, v6
	v_mul_hi_u32 v3, s6, v1
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v7, v2, v3
	v_mul_hi_u32 v9, v6, v4
	v_mul_lo_u32 v10, v6, v4
	v_mul_hi_u32 v3, v1, v7
	v_mul_lo_u32 v2, v1, v7
	v_mul_hi_u32 v4, v1, v4
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v10
	v_mul_hi_u32 v8, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v9, vcc
	v_mul_lo_u32 v2, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v8, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_hi_u32 v4, s5, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_hi_u32 v3, s5, v6
	v_mul_lo_u32 v2, s5, v6
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, s7, v1
	v_mul_lo_u32 v1, s7, v1
	v_add_co_u32_e32 v1, vcc, v2, v1
	v_mul_hi_u32 v7, s7, v6
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, s7, v6
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v7, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_lo_u32 v1, s4, v3
	v_mul_hi_u32 v3, s4, v2
	v_mul_lo_u32 v2, s4, v2
	v_add_u32_e32 v1, v3, v1
	v_mov_b32_e32 v3, s7
	v_sub_co_u32_e32 v2, vcc, s5, v2
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v3, v1, vcc
	v_subrev_co_u32_e32 v3, vcc, s4, v2
	s_nop 1
	v_subbrev_co_u32_e32 v4, vcc, 0, v1, vcc
	v_subrev_co_u32_e32 v5, vcc, s4, v3
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v4, -1, v6, vcc
	v_cmp_ne_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_cmp_le_u32_e32 vcc, s4, v2
	s_nop 1
	v_cndmask_b32_e64 v4, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1, v4, vcc
	v_cmp_ne_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v4, v2, v3, vcc
	s_cbranch_execnz .LBB0_6
.LBB0_5:
	v_cvt_f32_u32_e32 v1, s4
	s_sub_i32 s2, 0, s4
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s2, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, s5, v1
	v_mul_lo_u32 v1, v1, s4
	v_sub_u32_e32 v1, s5, v1
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v2, vcc
.LBB0_6:
	s_load_dwordx8 s[12:19], s[0:1], 0x18
	s_load_dwordx4 s[20:23], s[0:1], 0x0
	s_load_dwordx2 s[10:11], s[0:1], 0x38
	s_load_dwordx4 s[24:27], s[0:1], 0x40
	v_and_b32_e32 v7, 0x3ff, v0
	v_lshlrev_b32_e32 v12, 4, v4
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s2, s20, 31
	s_lshr_b32 s2, s2, 28
	v_lshlrev_b32_e32 v9, 1, v7
	v_bfe_u32 v11, v0, 10, 10
	s_add_i32 s2, s20, s2
	v_or_b32_e32 v2, v12, v9
	s_lshl_b32 s29, s28, 4
	v_lshlrev_b32_e32 v3, 1, v11
	s_and_b32 s4, s2, -16
	v_or_b32_e32 v5, s29, v3
	v_cmp_le_i32_e64 s[2:3], s4, v2
	v_cmp_gt_i32_e32 vcc, s4, v2
	s_mov_b64 s[6:7], 0
	s_mov_b64 s[30:31], 0
	s_and_saveexec_b64 s[4:5], vcc
	s_ashr_i32 s8, s21, 31
	s_lshr_b32 s8, s8, 28
	s_add_i32 s8, s21, s8
	s_and_b32 s8, s8, -16
	v_cmp_le_i32_e32 vcc, s8, v5
	s_andn2_b64 s[2:3], s[2:3], exec
	s_and_b64 s[8:9], vcc, exec
	s_mov_b64 s[30:31], exec
	s_or_b64 s[2:3], s[2:3], s[8:9]
	s_or_b64 exec, exec, s[4:5]
	s_load_dword s27, s[0:1], 0x10
	s_and_saveexec_b64 s[34:35], s[2:3]
	s_cbranch_execz .LBB0_28
	s_cmp_lt_i32 s22, 16
	v_cmp_gt_i32_e32 vcc, s20, v2
	s_cbranch_scc1 .LBB0_42
	s_ashr_i32 s0, s22, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s22, s0
	s_and_b32 s38, s0, -16
	s_movk_i32 s0, 0x88
	v_mov_b32_e32 v0, 0x440
	v_mad_u32_u24 v15, v11, s0, v0
	v_lshlrev_b32_e32 v0, 7, v11
	v_or_b32_e32 v17, 1, v3
	v_or_b32_e32 v10, 1, v9
	v_sub_u32_e32 v37, 0, v0
	v_lshlrev_b32_e32 v0, 2, v3
	v_lshlrev_b32_e32 v1, 2, v9
	v_mul_u32_u24_e32 v14, 0x44, v17
	s_movk_i32 s1, 0x440
	v_add_u32_e32 v20, 0x484, v0
	v_add_u32_e32 v21, 0x4c8, v0
	v_add_u32_e32 v22, 0x50c, v0
	v_add_u32_e32 v23, 0x550, v0
	v_add_u32_e32 v24, 0x594, v0
	v_add_u32_e32 v25, 0x5d8, v0
	v_add_u32_e32 v26, 0x61c, v0
	v_add_u32_e32 v27, 0x660, v0
	v_add_u32_e32 v28, 0x6a4, v0
	v_add_u32_e32 v29, 0x6e8, v0
	v_add_u32_e32 v30, 0x72c, v0
	v_add_u32_e32 v31, 0x770, v0
	v_add_u32_e32 v32, 0x7b4, v0
	v_add_u32_e32 v33, 0x7f8, v0
	v_add_u32_e32 v34, 0x83c, v0
	v_add_u32_e32 v0, v12, v10
	v_mul_u32_u24_e32 v13, 0x88, v11
	v_add3_u32 v19, v14, v1, s1
	v_cmp_gt_i32_e64 s[0:1], s20, v0
	v_add_u32_e32 v8, s29, v9
	v_add_u32_e32 v0, s29, v10
	v_add_u32_e32 v6, s14, v12
	s_add_i32 s6, s29, s18
	v_add_u32_e32 v18, v15, v1
	s_mov_b32 s33, 0
	v_cmp_gt_i32_e64 s[2:3], s21, v8
	v_cmp_gt_i32_e64 s[4:5], s21, v0
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v6, v6, v10
	v_add_u32_e32 v8, s18, v8
	v_add_u32_e32 v10, s6, v10
	v_mov_b32_e32 v16, 0
	v_add_u32_e32 v35, v1, v13
	v_add_u32_e32 v36, v1, v14
	v_add_u32_e32 v37, v15, v37
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v13, 0
	s_branch .LBB0_12
.LBB0_11:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v19, v39 offset:4
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[38:39], v1 offset1:1
	ds_read2_b32 v[40:41], v37 offset1:1
	s_add_i32 s33, s33, 16
	s_cmp_ge_i32 s33, s38
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	v_fmac_f32_e32 v14, v38, v41
	v_fmac_f32_e32 v13, v39, v41
	ds_read2_b32 v[38:39], v1 offset0:17 offset1:18
	ds_read2_b32 v[40:41], v37 offset0:17 offset1:34
	ds_read_b32 v42, v20 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:34 offset1:35
	ds_read_b32 v40, v21 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:51 offset1:52
	ds_read2_b32 v[40:41], v37 offset0:51 offset1:68
	ds_read_b32 v42, v22 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:68 offset1:69
	ds_read_b32 v40, v23 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:85 offset1:86
	ds_read2_b32 v[40:41], v37 offset0:85 offset1:102
	ds_read_b32 v42, v24 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:102 offset1:103
	ds_read_b32 v40, v25 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:119 offset1:120
	ds_read2_b32 v[40:41], v37 offset0:119 offset1:136
	ds_read_b32 v42, v26 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:136 offset1:137
	ds_read_b32 v40, v27 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:153 offset1:154
	ds_read2_b32 v[40:41], v37 offset0:153 offset1:170
	ds_read_b32 v42, v28 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:170 offset1:171
	ds_read_b32 v40, v29 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:187 offset1:188
	ds_read2_b32 v[40:41], v37 offset0:187 offset1:204
	ds_read_b32 v42, v30 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:204 offset1:205
	ds_read_b32 v40, v31 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	v_fmac_f32_e32 v15, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:221 offset1:222
	ds_read2_b32 v[40:41], v37 offset0:221 offset1:238
	ds_read_b32 v42, v32 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v42
	v_fmac_f32_e32 v13, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:238 offset1:239
	ds_read_b32 v40, v33 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v16, v38, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v38, v40
	v_add_u32_e32 v38, 0x3fc, v1
	v_fmac_f32_e32 v15, v39, v41
	v_fmac_f32_e32 v13, v39, v40
	ds_read2_b32 v[38:39], v38 offset1:1
	ds_read_b32 v40, v37 offset:1020
	ds_read_b32 v41, v34 offset:4
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v16, v38, v40
	v_fmac_f32_e32 v15, v39, v40
	v_fmac_f32_e32 v14, v38, v41
	v_fmac_f32_e32 v13, v39, v41
	s_cbranch_scc1 .LBB0_43
.LBB0_12:
	v_add_u32_e32 v39, s33, v3
	v_cmp_gt_i32_e64 s[8:9], s22, v39
	s_and_b64 s[36:37], vcc, s[8:9]
	v_mov_b32_e32 v38, 0
	s_and_saveexec_b64 s[6:7], s[36:37]
	s_cbranch_execz .LBB0_14
	v_mad_u64_u32 v[40:41], s[36:37], v39, s15, v[0:1]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[12:13]
	global_load_dword v38, v[40:41], off
.LBB0_14:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v40, 1, v39
	v_cmp_gt_i32_e64 s[6:7], s22, v40
	s_waitcnt vmcnt(0)
	ds_write_b32 v35, v38
	v_add_u32_e32 v38, s33, v17
	s_and_b64 s[40:41], vcc, s[6:7]
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	s_and_saveexec_b64 s[36:37], s[40:41]
	s_cbranch_execz .LBB0_16
	v_mad_u64_u32 v[42:43], s[40:41], v38, s15, v[0:1]
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	global_load_dword v41, v[42:43], off
.LBB0_16:
	s_or_b64 exec, exec, s[36:37]
	s_and_b64 s[40:41], s[0:1], s[8:9]
	s_waitcnt vmcnt(0)
	ds_write_b32 v36, v41
	s_and_saveexec_b64 s[36:37], s[40:41]
	s_cbranch_execz .LBB0_18
	v_mad_u64_u32 v[40:41], s[40:41], v39, s15, v[6:7]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[12:13]
	global_load_dword v40, v[40:41], off
.LBB0_18:
	s_or_b64 exec, exec, s[36:37]
	s_waitcnt vmcnt(0)
	ds_write_b32 v35, v40 offset:4
	s_and_b64 s[40:41], s[0:1], s[6:7]
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	s_and_saveexec_b64 s[36:37], s[40:41]
	s_cbranch_execz .LBB0_20
	v_mad_u64_u32 v[42:43], s[40:41], v38, s15, v[6:7]
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	global_load_dword v41, v[42:43], off
.LBB0_20:
	s_or_b64 exec, exec, s[36:37]
	s_and_b64 s[40:41], s[2:3], s[8:9]
	s_waitcnt vmcnt(0)
	ds_write_b32 v36, v41 offset:4
	s_and_saveexec_b64 s[36:37], s[40:41]
	s_cbranch_execz .LBB0_22
	v_mad_u64_u32 v[40:41], s[40:41], v39, s19, v[8:9]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[16:17]
	global_load_dword v40, v[40:41], off
.LBB0_22:
	s_or_b64 exec, exec, s[36:37]
	s_waitcnt vmcnt(0)
	ds_write_b32 v18, v40
	s_and_b64 s[36:37], s[4:5], s[8:9]
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	s_and_saveexec_b64 s[8:9], s[36:37]
	s_cbranch_execz .LBB0_24
	v_mad_u64_u32 v[42:43], s[36:37], v39, s19, v[10:11]
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[16:17]
	global_load_dword v41, v[42:43], off
.LBB0_24:
	s_or_b64 exec, exec, s[8:9]
	s_and_b64 s[36:37], s[2:3], s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v18, v41 offset:4
	s_and_saveexec_b64 s[8:9], s[36:37]
	s_cbranch_execz .LBB0_26
	v_mad_u64_u32 v[40:41], s[36:37], v38, s19, v[8:9]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[16:17]
	global_load_dword v40, v[40:41], off
.LBB0_26:
	s_or_b64 exec, exec, s[8:9]
	s_and_b64 s[8:9], s[4:5], s[6:7]
	v_mov_b32_e32 v39, 0
	s_waitcnt vmcnt(0)
	ds_write_b32 v19, v40
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB0_11
	v_mad_u64_u32 v[38:39], s[8:9], v38, s19, v[10:11]
	v_ashrrev_i32_e32 v39, 31, v38
	v_lshl_add_u64 v[38:39], v[38:39], 2, s[16:17]
	global_load_dword v39, v[38:39], off
	s_branch .LBB0_11
.LBB0_28:
	s_or_b64 exec, exec, s[34:35]
	s_and_saveexec_b64 s[0:1], s[30:31]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execz .LBB0_75
.LBB0_29:
	s_cmp_lt_i32 s22, 16
	s_cbranch_scc1 .LBB0_77
	s_ashr_i32 s0, s22, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s22, s0
	s_and_b32 s21, s0, -16
	s_or_b32 s0, s15, s14
	s_bitcmp1_b32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_lshr_b32 s2, s15, 31
	s_add_i32 s2, s15, s2
	s_ashr_i32 s30, s2, 1
	s_lshr_b32 s2, s14, 31
	s_add_i32 s2, s14, s2
	s_ashr_i32 s5, s2, 1
	s_or_b32 s2, s19, s18
	s_movk_i32 s4, 0x88
	v_lshlrev_b32_e32 v0, 3, v4
	s_bitcmp1_b32 s2, 0
	v_mov_b32_e32 v4, 0x440
	s_cselect_b64 s[2:3], -1, 0
	v_mad_u32_u24 v6, v11, s4, v4
	s_lshr_b32 s4, s19, 31
	s_add_i32 s4, s19, s4
	s_ashr_i32 s31, s4, 1
	s_lshr_b32 s4, s18, 31
	s_add_i32 s4, s18, s4
	v_lshl_add_u32 v17, v7, 3, v4
	v_add_u32_e32 v4, s14, v12
	v_or_b32_e32 v13, 1, v3
	s_ashr_i32 s4, s4, 1
	s_lshl_b32 s28, s28, 3
	v_add_u32_e32 v12, v4, v9
	s_add_i32 s29, s29, s18
	v_lshlrev_b32_e32 v4, 7, v11
	v_lshlrev_b32_e32 v1, 2, v9
	v_mul_u32_u24_e32 v10, 0x88, v11
	v_mul_u32_u24_e32 v14, 0x44, v13
	s_movk_i32 s20, 0x440
	v_add_u32_e32 v19, s29, v9
	v_sub_u32_e32 v8, 0, v4
	v_lshlrev_b32_e32 v4, 2, v3
	v_add_u32_e32 v0, s5, v0
	s_add_i32 s28, s28, s4
	v_add_u32_e32 v15, v6, v1
	v_add3_u32 v16, v14, v1, s20
	v_add_u32_e32 v18, 1, v12
	s_mov_b32 s20, 0
	v_add_u32_e32 v11, 0x484, v4
	v_add_u32_e32 v20, 0x4c8, v4
	v_add_u32_e32 v21, 0x50c, v4
	v_add_u32_e32 v22, 0x550, v4
	v_add_u32_e32 v23, 0x594, v4
	v_add_u32_e32 v24, 0x5d8, v4
	v_add_u32_e32 v25, 0x61c, v4
	v_add_u32_e32 v26, 0x660, v4
	v_add_u32_e32 v27, 0x6a4, v4
	v_add_u32_e32 v28, 0x6e8, v4
	v_add_u32_e32 v29, 0x72c, v4
	v_add_u32_e32 v30, 0x770, v4
	v_add_u32_e32 v31, 0x7b4, v4
	v_add_u32_e32 v32, 0x7f8, v4
	v_add_u32_e32 v33, 0x83c, v4
	v_add_u32_e32 v0, v0, v7
	v_add_u32_e32 v34, 1, v19
	v_add_u32_e32 v4, s28, v7
	v_mov_b32_e32 v9, 0
	v_add_u32_e32 v35, v1, v10
	v_add_u32_e32 v36, v1, v14
	v_add_u32_e32 v37, v6, v8
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v6, 0
	s_branch .LBB0_32
.LBB0_31:
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[38:39], v1 offset1:1
	ds_read2_b32 v[40:41], v37 offset1:1
	s_add_i32 s20, s20, 16
	s_cmp_ge_i32 s20, s21
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	v_fmac_f32_e32 v7, v38, v41
	v_fmac_f32_e32 v6, v39, v41
	ds_read2_b32 v[38:39], v1 offset0:17 offset1:18
	ds_read2_b32 v[40:41], v37 offset0:17 offset1:34
	ds_read_b32 v42, v11 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:34 offset1:35
	ds_read_b32 v40, v20 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:51 offset1:52
	ds_read2_b32 v[40:41], v37 offset0:51 offset1:68
	ds_read_b32 v42, v21 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:68 offset1:69
	ds_read_b32 v40, v22 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:85 offset1:86
	ds_read2_b32 v[40:41], v37 offset0:85 offset1:102
	ds_read_b32 v42, v23 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:102 offset1:103
	ds_read_b32 v40, v24 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:119 offset1:120
	ds_read2_b32 v[40:41], v37 offset0:119 offset1:136
	ds_read_b32 v42, v25 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:136 offset1:137
	ds_read_b32 v40, v26 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:153 offset1:154
	ds_read2_b32 v[40:41], v37 offset0:153 offset1:170
	ds_read_b32 v42, v27 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:170 offset1:171
	ds_read_b32 v40, v28 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:187 offset1:188
	ds_read2_b32 v[40:41], v37 offset0:187 offset1:204
	ds_read_b32 v42, v29 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:204 offset1:205
	ds_read_b32 v40, v30 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	v_fmac_f32_e32 v8, v39, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v1 offset0:221 offset1:222
	ds_read2_b32 v[40:41], v37 offset0:221 offset1:238
	ds_read_b32 v42, v31 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v42
	v_fmac_f32_e32 v6, v39, v42
	ds_read2_b32 v[38:39], v1 offset0:238 offset1:239
	ds_read_b32 v40, v32 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v41
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v38, v40
	v_add_u32_e32 v38, 0x3fc, v1
	v_fmac_f32_e32 v8, v39, v41
	v_fmac_f32_e32 v6, v39, v40
	ds_read2_b32 v[38:39], v38 offset1:1
	ds_read_b32 v40, v37 offset:1020
	ds_read_b32 v41, v33 offset:4
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v9, v38, v40
	v_fmac_f32_e32 v8, v39, v40
	v_fmac_f32_e32 v7, v38, v41
	v_fmac_f32_e32 v6, v39, v41
	s_cbranch_scc1 .LBB0_78
.LBB0_32:
	v_add_u32_e32 v39, s20, v3
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[0:1]
	v_add_u32_e32 v38, s20, v13
	s_cbranch_vccz .LBB0_36
	v_mul_lo_u32 v44, v39, s15
	v_mul_lo_u32 v46, v38, s15
	v_add_u32_e32 v40, v44, v12
	v_add_u32_e32 v42, v46, v12
	v_ashrrev_i32_e32 v41, 31, v40
	v_ashrrev_i32_e32 v43, 31, v42
	v_add_u32_e32 v44, v44, v18
	v_add_u32_e32 v46, v46, v18
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[12:13]
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	v_ashrrev_i32_e32 v45, 31, v44
	v_ashrrev_i32_e32 v47, 31, v46
	v_lshl_add_u64 v[44:45], v[44:45], 2, s[12:13]
	v_lshl_add_u64 v[46:47], v[46:47], 2, s[12:13]
	global_load_dword v40, v[40:41], off
	global_load_dword v41, v[42:43], off
	global_load_dword v42, v[44:45], off
	global_load_dword v43, v[46:47], off
	s_waitcnt vmcnt(3)
	ds_write_b32 v35, v40
	s_waitcnt vmcnt(2)
	ds_write_b32 v36, v41
	s_waitcnt vmcnt(1)
	ds_write_b32 v35, v42 offset:4
	s_waitcnt vmcnt(0)
	ds_write_b32 v36, v43 offset:4
	s_cbranch_execz .LBB0_37
.LBB0_34:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_38
.LBB0_35:
	v_mul_lo_u32 v42, v39, s19
	v_add_u32_e32 v40, v19, v42
	v_add_u32_e32 v42, v42, v34
	v_mul_lo_u32 v46, v38, s19
	v_ashrrev_i32_e32 v41, 31, v40
	v_ashrrev_i32_e32 v43, 31, v42
	v_add_u32_e32 v44, v19, v46
	v_add_u32_e32 v46, v46, v34
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[16:17]
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[16:17]
	v_ashrrev_i32_e32 v45, 31, v44
	v_ashrrev_i32_e32 v47, 31, v46
	v_lshl_add_u64 v[44:45], v[44:45], 2, s[16:17]
	v_lshl_add_u64 v[46:47], v[46:47], 2, s[16:17]
	global_load_dword v40, v[40:41], off
	global_load_dword v41, v[42:43], off
	global_load_dword v42, v[44:45], off
	global_load_dword v43, v[46:47], off
	s_waitcnt vmcnt(2)
	ds_write2_b32 v15, v40, v41 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v16, v42, v43 offset1:1
	s_cbranch_execnz .LBB0_31
	s_branch .LBB0_39
.LBB0_36:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB0_34
.LBB0_37:
	v_mad_u64_u32 v[40:41], s[4:5], v39, s30, v[0:1]
	v_mad_u64_u32 v[42:43], s[4:5], v38, s30, v[0:1]
	v_ashrrev_i32_e32 v41, 31, v40
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[40:41], v[40:41], 3, s[12:13]
	v_lshl_add_u64 v[42:43], v[42:43], 3, s[12:13]
	global_load_dwordx2 v[40:41], v[40:41], off
	global_load_dwordx2 v[42:43], v[42:43], off
	s_waitcnt vmcnt(1)
	ds_write2_b32 v35, v40, v41 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v36, v42, v43 offset1:1
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_35
.LBB0_38:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB0_31
.LBB0_39:
	v_mad_u64_u32 v[40:41], s[4:5], v39, s31, v[4:5]
	v_mad_u64_u32 v[38:39], s[4:5], v38, s31, v[4:5]
	v_ashrrev_i32_e32 v41, 31, v40
	v_ashrrev_i32_e32 v39, 31, v38
	v_lshl_add_u64 v[40:41], v[40:41], 3, s[16:17]
	v_lshl_add_u64 v[38:39], v[38:39], 3, s[16:17]
	global_load_dwordx2 v[40:41], v[40:41], off
	global_load_dwordx2 v[38:39], v[38:39], off
	v_add_u32_e32 v42, v17, v10
	v_add_u32_e32 v43, v17, v14
	s_waitcnt vmcnt(1)
	ds_write2_b32 v42, v40, v41 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v43, v38, v39 offset1:1
	s_branch .LBB0_31
.LBB0_40:
	s_branch .LBB0_2
.LBB0_41:
	s_branch .LBB0_5
.LBB0_42:
	s_mov_b32 s33, 0
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v16, 0
.LBB0_43:
	s_cmp_ge_i32 s33, s22
	v_or_b32_e32 v6, 1, v2
	s_cbranch_scc1 .LBB0_54
	v_or_b32_e32 v10, 1, v5
	v_cmp_gt_i32_e32 vcc, s20, v2
	v_cmp_gt_i32_e64 s[0:1], s20, v6
	v_cmp_gt_i32_e64 s[2:3], s21, v5
	v_cmp_gt_i32_e64 s[4:5], s21, v10
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v1, s14, v6
	v_add_u32_e32 v8, s18, v5
	v_add_u32_e32 v10, s18, v10
	s_branch .LBB0_46
.LBB0_45:
	s_or_b64 exec, exec, s[6:7]
	s_add_i32 s33, s33, 1
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v16, v18, v20
	v_fmac_f32_e32 v15, v17, v20
	v_fmac_f32_e32 v14, v18, v19
	s_cmp_ge_i32 s33, s22
	v_fmac_f32_e32 v13, v17, v19
	s_cbranch_scc1 .LBB0_54
.LBB0_46:
	v_mov_b32_e32 v17, 0
	s_mul_i32 s8, s33, s15
	v_mov_b32_e32 v18, 0
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_48
	v_add_u32_e32 v18, s8, v0
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v18, v[18:19], off
.LBB0_48:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB0_50
	v_add_u32_e32 v20, s8, v1
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[12:13]
	global_load_dword v17, v[20:21], off
.LBB0_50:
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v19, 0
	s_mul_i32 s8, s33, s19
	v_mov_b32_e32 v20, 0
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_52
	v_add_u32_e32 v20, s8, v8
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v20, v[20:21], off
.LBB0_52:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_45
	v_add_u32_e32 v22, s8, v10
	v_ashrrev_i32_e32 v23, 31, v22
	v_lshl_add_u64 v[22:23], v[22:23], 2, s[16:17]
	global_load_dword v19, v[22:23], off
	s_branch .LBB0_45
.LBB0_54:
	s_cmp_eq_u32 s26, 0
	v_cmp_le_i32_e64 s[2:3], s21, v5
	v_cmp_le_i32_e64 s[4:5], s20, v2
	s_cselect_b64 s[0:1], -1, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[8:9], s27, 0
	s_nor_b64 s[36:37], s[4:5], s[2:3]
	s_and_saveexec_b64 s[6:7], s[36:37]
	s_cbranch_execz .LBB0_59
	v_cndmask_b32_e64 v1, v2, v5, s[0:1]
	v_cndmask_b32_e64 v0, v5, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[36:37], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[8:9]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccz .LBB0_107
	v_lshl_add_u64 v[18:19], v[0:1], 2, s[10:11]
	global_load_dword v8, v[18:19], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, s27, v8
	v_fmac_f32_e32 v8, s23, v16
	s_cbranch_execnz .LBB0_58
.LBB0_57:
	v_mul_f32_e32 v8, s23, v16
.LBB0_58:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v8, off
.LBB0_59:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_le_i32_e64 s[6:7], s20, v6
	v_cndmask_b32_e64 v0, 0, 1, s[8:9]
	s_nor_b64 s[36:37], s[6:7], s[2:3]
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	s_and_saveexec_b64 s[8:9], s[36:37]
	s_cbranch_execz .LBB0_64
	v_cndmask_b32_e64 v1, v6, v5, s[0:1]
	v_cndmask_b32_e64 v0, v5, v6, s[0:1]
	v_mad_u64_u32 v[0:1], s[36:37], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB0_108
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[10:11]
	global_load_dword v8, v[16:17], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, s27, v8
	v_fmac_f32_e32 v8, s23, v15
	s_cbranch_execnz .LBB0_63
.LBB0_62:
	v_mul_f32_e32 v8, s23, v15
.LBB0_63:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v8, off
.LBB0_64:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v10, 1, v5
	v_cmp_le_i32_e64 s[8:9], s21, v10
	s_nor_b64 s[20:21], s[4:5], s[8:9]
	s_and_saveexec_b64 s[4:5], s[20:21]
	s_cbranch_execz .LBB0_69
	v_cndmask_b32_e64 v1, v2, v10, s[0:1]
	v_cndmask_b32_e64 v0, v10, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[20:21], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB0_109
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[10:11]
	global_load_dword v8, v[16:17], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, s27, v8
	v_fmac_f32_e32 v8, s23, v14
	s_cbranch_execnz .LBB0_68
.LBB0_67:
	v_mul_f32_e32 v8, s23, v14
.LBB0_68:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v8, off
.LBB0_69:
	s_or_b64 exec, exec, s[4:5]
	s_nor_b64 s[4:5], s[6:7], s[8:9]
	s_mov_b64 s[6:7], 0
	s_and_saveexec_b64 s[8:9], s[4:5]
	s_xor_b64 s[4:5], exec, s[8:9]
	s_cbranch_execz .LBB0_74
	v_cndmask_b32_e64 v1, v6, v10, s[0:1]
	v_cndmask_b32_e64 v0, v10, v6, s[0:1]
	v_mad_u64_u32 v[0:1], s[0:1], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB0_110
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v6, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, s27, v6
	v_fmac_f32_e32 v8, s23, v13
	s_cbranch_execnz .LBB0_73
.LBB0_72:
	v_mul_f32_e32 v8, s23, v13
.LBB0_73:
	s_mov_b64 s[6:7], exec
.LBB0_74:
	s_or_b64 exec, exec, s[4:5]
	s_and_b64 s[6:7], s[6:7], exec
	s_andn2_b64 s[30:31], s[30:31], exec
	s_or_b64 exec, exec, s[34:35]
	s_and_saveexec_b64 s[0:1], s[30:31]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execnz .LBB0_29
.LBB0_75:
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB0_102
.LBB0_76:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v8, off
	s_endpgm
.LBB0_77:
	s_mov_b32 s20, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
.LBB0_78:
	s_cmp_ge_i32 s20, s22
	s_cbranch_scc1 .LBB0_81
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v1, s18, v5
	v_add_u32_e32 v3, 1, v0
	v_add_u32_e32 v4, 1, v1
.LBB0_80:
	s_mul_i32 s0, s20, s15
	s_mul_i32 s1, s20, s19
	v_add_u32_e32 v10, s0, v0
	v_add_u32_e32 v12, s0, v3
	v_add_u32_e32 v14, s1, v1
	v_add_u32_e32 v16, s1, v4
	v_ashrrev_i32_e32 v11, 31, v10
	v_ashrrev_i32_e32 v13, 31, v12
	v_ashrrev_i32_e32 v15, 31, v14
	v_ashrrev_i32_e32 v17, 31, v16
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[12:13]
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[12:13]
	v_lshl_add_u64 v[14:15], v[14:15], 2, s[16:17]
	v_lshl_add_u64 v[16:17], v[16:17], 2, s[16:17]
	global_load_dword v14, v[14:15], off
	global_load_dword v10, v[10:11], off
	global_load_dword v11, v[12:13], off
	global_load_dword v12, v[16:17], off
	s_add_i32 s20, s20, 1
	s_cmp_lt_i32 s20, s22
	s_waitcnt vmcnt(2)
	v_fmac_f32_e32 v9, v10, v14
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v8, v11, v14
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v7, v10, v12
	v_fmac_f32_e32 v6, v11, v12
	s_cbranch_scc1 .LBB0_80
.LBB0_81:
	s_cmp_eq_u32 s26, 0
	v_mad_u64_u32 v[0:1], s[0:1], v5, s25, v[2:3]
	v_mul_lo_u32 v4, v2, s25
	v_add_u32_e32 v1, v4, v5
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v2, v1, v0, s[0:1]
	s_cmp_lg_u32 s26, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[12:13], s27, 0
	v_add_u32_e32 v2, s24, v2
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccz .LBB0_103
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[10:11]
	global_load_dword v10, v[10:11], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v10, s27, v10
	v_fmac_f32_e32 v10, s23, v9
	s_cbranch_execnz .LBB0_84
.LBB0_83:
	v_mul_f32_e32 v10, s23, v9
.LBB0_84:
	v_cndmask_b32_e64 v9, 0, 1, s[4:5]
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	v_cmp_ne_u32_e64 s[2:3], 1, v9
	s_andn2_b64 vcc, exec, s[4:5]
	global_store_dword v[2:3], v10, off
	s_cbranch_vccnz .LBB0_86
	v_add_u32_e32 v1, s25, v1
	s_cbranch_execz .LBB0_87
	s_branch .LBB0_88
.LBB0_86:
.LBB0_87:
	v_or_b32_e32 v1, 1, v0
.LBB0_88:
	v_cndmask_b32_e64 v2, 0, 1, s[12:13]
	v_cmp_ne_u32_e64 s[4:5], 1, v2
	v_add_u32_e32 v2, s24, v1
	s_andn2_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccnz .LBB0_104
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[10:11]
	global_load_dword v1, v[10:11], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, s27, v1
	v_fmac_f32_e32 v1, s23, v8
	s_cbranch_execnz .LBB0_91
.LBB0_90:
	v_mul_f32_e32 v1, s23, v8
.LBB0_91:
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	global_store_dword v[2:3], v1, off
	v_or_b32_e32 v3, 1, v5
	v_add_u32_e32 v2, s25, v0
	v_add_u32_e32 v0, v4, v3
	v_cndmask_b32_e64 v0, v0, v2, s[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB0_105
	v_lshl_add_u64 v[8:9], v[0:1], 2, s[10:11]
	global_load_dword v5, v[8:9], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, s27, v5
	v_fmac_f32_e32 v5, s23, v7
	s_cbranch_execnz .LBB0_94
.LBB0_93:
	v_mul_f32_e32 v5, s23, v7
.LBB0_94:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	s_and_b64 vcc, exec, s[2:3]
	global_store_dword v[0:1], v5, off
	s_cbranch_vccnz .LBB0_96
	v_add3_u32 v0, v4, s25, v3
	s_cbranch_execz .LBB0_97
	s_branch .LBB0_98
.LBB0_96:
.LBB0_97:
	v_add_u32_e32 v0, 1, v2
.LBB0_98:
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB0_106
	v_lshl_add_u64 v[2:3], v[0:1], 2, s[10:11]
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v8, s27, v2
	v_fmac_f32_e32 v8, s23, v6
	s_cbranch_execnz .LBB0_101
.LBB0_100:
	v_mul_f32_e32 v8, s23, v6
.LBB0_101:
	s_or_b64 s[6:7], s[6:7], exec
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execnz .LBB0_76
.LBB0_102:
	s_endpgm
.LBB0_103:
	s_branch .LBB0_83
.LBB0_104:
	s_branch .LBB0_90
.LBB0_105:
	s_branch .LBB0_93
.LBB0_106:
	s_branch .LBB0_100
.LBB0_107:
	s_branch .LBB0_57
.LBB0_108:
	s_branch .LBB0_62
.LBB0_109:
	s_branch .LBB0_67
.LBB0_110:
	s_branch .LBB0_72
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel XgemmDirectNN
		.amdhsa_group_segment_fixed_size 2176
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 48
		.amdhsa_next_free_sgpr 42
		.amdhsa_accum_offset 48
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
	.text
.Lfunc_end0:
	.size	XgemmDirectNN, .Lfunc_end0-XgemmDirectNN

	.set XgemmDirectNN.num_vgpr, 48
	.set XgemmDirectNN.num_agpr, 0
	.set XgemmDirectNN.numbered_sgpr, 42
	.set XgemmDirectNN.private_seg_size, 0
	.set XgemmDirectNN.uses_vcc, 1
	.set XgemmDirectNN.uses_flat_scratch, 0
	.set XgemmDirectNN.has_dyn_sized_stack, 0
	.set XgemmDirectNN.has_recursion, 0
	.set XgemmDirectNN.has_indirect_call, 0
	.protected	XgemmDirectNT
	.globl	XgemmDirectNT
	.p2align	8
	.type	XgemmDirectNT,@function
XgemmDirectNT:
	s_load_dwordx2 s[4:5], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s4, s3
	s_add_i32 s8, s3, s2
	s_ashr_i32 s9, s8, 31
	s_mov_b32 s2, 0
	s_mov_b32 s3, s9
	s_cmp_lg_u64 s[2:3], 0
	s_cbranch_scc0 .LBB1_40
	v_cvt_f32_u32_e32 v1, s5
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s5
	s_subb_u32 s7, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s12, s6, s10
	s_mul_hi_u32 s14, s6, s11
	s_mul_i32 s13, s7, s11
	s_add_i32 s12, s14, s12
	s_add_i32 s12, s12, s13
	s_mul_i32 s15, s6, s11
	s_mul_hi_u32 s13, s11, s12
	s_mul_i32 s14, s11, s12
	s_mul_hi_u32 s11, s11, s15
	s_add_u32 s11, s11, s14
	s_addc_u32 s13, 0, s13
	s_mul_hi_u32 s16, s10, s15
	s_mul_i32 s15, s10, s15
	s_add_u32 s11, s11, s15
	s_mul_hi_u32 s14, s10, s12
	s_addc_u32 s11, s13, s16
	s_addc_u32 s13, s14, 0
	s_mul_i32 s12, s10, s12
	s_add_u32 s11, s11, s12
	s_addc_u32 s12, 0, s13
	v_add_co_u32_e32 v1, vcc, s11, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s10, s10, s12
	v_readfirstlane_b32 s12, v1
	s_mul_i32 s11, s6, s10
	s_mul_hi_u32 s13, s6, s12
	s_add_i32 s11, s13, s11
	s_mul_i32 s7, s7, s12
	s_add_i32 s11, s11, s7
	s_mul_i32 s6, s6, s12
	s_mul_hi_u32 s13, s10, s6
	s_mul_i32 s14, s10, s6
	s_mul_i32 s16, s12, s11
	s_mul_hi_u32 s6, s12, s6
	s_mul_hi_u32 s15, s12, s11
	s_add_u32 s6, s6, s16
	s_addc_u32 s12, 0, s15
	s_add_u32 s6, s6, s14
	s_mul_hi_u32 s7, s10, s11
	s_addc_u32 s6, s12, s13
	s_addc_u32 s7, s7, 0
	s_mul_i32 s11, s10, s11
	s_add_u32 s6, s6, s11
	s_addc_u32 s7, 0, s7
	v_add_co_u32_e32 v1, vcc, s6, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s6, s10, s7
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s10, s8, s6
	s_mul_hi_u32 s12, s8, s11
	s_mul_hi_u32 s7, s8, s6
	s_add_u32 s10, s12, s10
	s_addc_u32 s7, 0, s7
	s_mul_hi_u32 s13, s9, s11
	s_mul_i32 s11, s9, s11
	s_add_u32 s10, s10, s11
	s_mul_hi_u32 s12, s9, s6
	s_addc_u32 s7, s7, s13
	s_addc_u32 s10, s12, 0
	s_mul_i32 s6, s9, s6
	s_add_u32 s6, s7, s6
	s_addc_u32 s7, 0, s10
	s_add_u32 s10, s6, 1
	s_addc_u32 s11, s7, 0
	s_add_u32 s12, s6, 2
	s_mul_i32 s14, s5, s7
	s_mul_hi_u32 s15, s5, s6
	s_addc_u32 s13, s7, 0
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s5, s6
	v_mov_b32_e32 v1, s14
	v_sub_co_u32_e32 v1, vcc, s8, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s14, s9, s15
	v_subrev_co_u32_e32 v2, vcc, s5, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s15, s14, 0
	v_readfirstlane_b32 s16, v2
	s_cmp_ge_u32 s16, s5
	s_cselect_b32 s16, -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b32 s15, s16, -1
	s_cmp_lg_u32 s15, 0
	s_cselect_b32 s10, s12, s10
	v_readfirstlane_b32 s12, v1
	s_cselect_b32 s11, s13, s11
	s_cmp_ge_u32 s12, s5
	s_cselect_b32 s12, -1, 0
	s_cmp_eq_u32 s14, 0
	s_cselect_b32 s12, s12, -1
	s_cmp_lg_u32 s12, 0
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s6, s10, s6
	s_cbranch_execnz .LBB1_3
.LBB1_2:
	v_cvt_f32_u32_e32 v1, s5
	s_sub_i32 s2, 0, s5
	s_mov_b32 s7, 0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s3, v1
	s_mul_i32 s2, s2, s3
	s_mul_hi_u32 s2, s3, s2
	s_add_i32 s3, s3, s2
	s_mul_hi_u32 s2, s8, s3
	s_mul_i32 s6, s2, s5
	s_sub_i32 s6, s8, s6
	s_add_i32 s3, s2, 1
	s_sub_i32 s10, s6, s5
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s2, s3, s2
	s_cselect_b32 s6, s10, s6
	s_add_i32 s3, s2, 1
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s6, s3, s2
.LBB1_3:
	s_mul_i32 s2, s7, s5
	s_mul_hi_u32 s3, s6, s5
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s6, s5
	s_sub_u32 s2, s8, s2
	s_subb_u32 s3, s9, s3
	s_bfe_i64 s[8:9], s[2:3], 0x200000
	s_add_u32 s3, s8, s6
	s_addc_u32 s9, s9, s7
	s_mov_b32 s8, 0
	s_cmp_lg_u64 s[8:9], 0
	s_cbranch_scc0 .LBB1_41
	v_cvt_f32_u32_e32 v1, s4
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s5, 0, s4
	s_subb_u32 s8, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	v_mov_b32_e32 v5, 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v6, v2
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s5, v6
	v_mul_hi_u32 v4, s5, v1
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v2, v4, v2
	v_mul_lo_u32 v7, s5, v1
	v_add_u32_e32 v8, v2, v3
	v_mul_hi_u32 v3, v1, v8
	v_mul_lo_u32 v2, v1, v8
	v_mul_hi_u32 v4, v1, v7
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, v6, v7
	v_mul_lo_u32 v7, v6, v7
	v_add_co_u32_e32 v2, vcc, v2, v7
	v_mul_hi_u32 v9, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v9, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_lo_u32 v4, s5, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_lo_u32 v2, s5, v6
	v_mul_hi_u32 v3, s5, v1
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v7, v2, v3
	v_mul_hi_u32 v9, v6, v4
	v_mul_lo_u32 v10, v6, v4
	v_mul_hi_u32 v3, v1, v7
	v_mul_lo_u32 v2, v1, v7
	v_mul_hi_u32 v4, v1, v4
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v10
	v_mul_hi_u32 v8, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v9, vcc
	v_mul_lo_u32 v2, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v8, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_hi_u32 v4, s3, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_hi_u32 v3, s3, v6
	v_mul_lo_u32 v2, s3, v6
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, s9, v1
	v_mul_lo_u32 v1, s9, v1
	v_add_co_u32_e32 v1, vcc, v2, v1
	v_mul_hi_u32 v7, s9, v6
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, s9, v6
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v7, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_lo_u32 v1, s4, v3
	v_mul_hi_u32 v3, s4, v2
	v_mul_lo_u32 v2, s4, v2
	v_add_u32_e32 v1, v3, v1
	v_mov_b32_e32 v3, s9
	v_sub_co_u32_e32 v2, vcc, s3, v2
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v3, v1, vcc
	v_subrev_co_u32_e32 v3, vcc, s4, v2
	s_nop 1
	v_subbrev_co_u32_e32 v4, vcc, 0, v1, vcc
	v_subrev_co_u32_e32 v5, vcc, s4, v3
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v4, -1, v6, vcc
	v_cmp_ne_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_cmp_le_u32_e32 vcc, s4, v2
	s_nop 1
	v_cndmask_b32_e64 v4, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1, v4, vcc
	v_cmp_ne_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v4, v2, v3, vcc
	s_cbranch_execnz .LBB1_6
.LBB1_5:
	v_cvt_f32_u32_e32 v1, s4
	s_sub_i32 s5, 0, s4
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s5, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, s3, v1
	v_mul_lo_u32 v1, v1, s4
	v_sub_u32_e32 v1, s3, v1
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v4, v1, v2, vcc
.LBB1_6:
	s_load_dwordx8 s[12:19], s[0:1], 0x18
	s_load_dwordx4 s[20:23], s[0:1], 0x0
	s_load_dwordx2 s[10:11], s[0:1], 0x38
	s_load_dwordx4 s[24:27], s[0:1], 0x40
	s_lshl_b32 s33, s2, 4
	v_and_b32_e32 v5, 0x3ff, v0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s2, s20, 31
	s_lshr_b32 s2, s2, 28
	v_lshlrev_b32_e32 v9, 4, v4
	v_lshlrev_b32_e32 v7, 1, v5
	v_bfe_u32 v10, v0, 10, 10
	s_add_i32 s2, s20, s2
	v_or_b32_e32 v2, v9, v7
	v_lshlrev_b32_e32 v3, 1, v10
	s_and_b32 s4, s2, -16
	v_or_b32_e32 v8, s33, v3
	v_cmp_le_i32_e64 s[2:3], s4, v2
	v_cmp_gt_i32_e32 vcc, s4, v2
	s_mov_b64 s[6:7], 0
	s_mov_b64 s[28:29], 0
	s_and_saveexec_b64 s[4:5], vcc
	s_ashr_i32 s8, s21, 31
	s_lshr_b32 s8, s8, 28
	s_add_i32 s8, s21, s8
	s_and_b32 s8, s8, -16
	v_cmp_le_i32_e32 vcc, s8, v8
	s_andn2_b64 s[2:3], s[2:3], exec
	s_and_b64 s[8:9], vcc, exec
	s_mov_b64 s[28:29], exec
	s_or_b64 s[2:3], s[2:3], s[8:9]
	s_or_b64 exec, exec, s[4:5]
	s_load_dword s27, s[0:1], 0x10
	s_and_saveexec_b64 s[30:31], s[2:3]
	s_cbranch_execz .LBB1_28
	s_cmp_lt_i32 s22, 16
	v_cmp_gt_i32_e32 vcc, s20, v2
	v_cmp_gt_i32_e64 s[0:1], s21, v8
	s_cbranch_scc1 .LBB1_42
	s_ashr_i32 s2, s22, 31
	s_lshr_b32 s2, s2, 28
	s_add_i32 s2, s22, s2
	v_or_b32_e32 v15, 1, v3
	s_and_b32 s37, s2, -16
	s_movk_i32 s2, 0x88
	s_movk_i32 s3, 0x44
	v_or_b32_e32 v6, 1, v7
	v_mov_b32_e32 v0, 0x440
	v_add_u32_e32 v22, s33, v15
	v_add_u32_e32 v11, s18, v7
	v_lshlrev_b32_e32 v1, 2, v7
	v_mul_u32_u24_e32 v12, 0x88, v10
	v_mul_u32_u24_e32 v13, 0x44, v15
	v_mad_u32_u24 v16, v10, s2, v0
	v_add_u32_e32 v14, s18, v6
	v_mad_u32_u24 v18, v15, s3, v0
	v_add_u32_e32 v0, v9, v6
	v_add_u32_e32 v20, s14, v9
	v_mul_lo_u32 v21, v8, s19
	v_mul_lo_u32 v23, v22, s19
	v_add_u32_e32 v17, v16, v1
	v_add_u32_e32 v19, v18, v1
	v_cmp_gt_i32_e64 s[2:3], s20, v0
	v_cmp_gt_i32_e64 s[4:5], s21, v22
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v6, v20, v6
	v_add_u32_e32 v20, v21, v11
	v_add_u32_e32 v21, v21, v14
	v_add_u32_e32 v22, v23, v11
	v_add_u32_e32 v23, v23, v14
	v_mov_b32_e32 v14, 0
	s_mov_b32 s36, 0
	v_add_u32_e32 v24, v1, v12
	v_add_u32_e32 v25, v1, v13
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v11, 0
	s_branch .LBB1_12
.LBB1_11:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v19, v26 offset:4
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[26:27], v16 offset1:1
	ds_read2_b32 v[28:29], v18 offset1:1
	ds_read2_b32 v[30:31], v1 offset1:1
	ds_read2_b32 v[32:33], v1 offset0:17 offset1:18
	ds_read2_b32 v[34:35], v1 offset0:34 offset1:35
	ds_read2_b32 v[36:37], v1 offset0:51 offset1:52
	ds_read2_b32 v[38:39], v1 offset0:204 offset1:205
	ds_read2_b32 v[40:41], v1 offset0:221 offset1:222
	ds_read2_b32 v[42:43], v1 offset0:238 offset1:239
	s_waitcnt lgkmcnt(6)
	v_fmac_f32_e32 v14, v30, v26
	v_fmac_f32_e32 v13, v31, v26
	v_fmac_f32_e32 v12, v30, v28
	v_fmac_f32_e32 v11, v31, v28
	ds_read2_b32 v[44:45], v16 offset0:10 offset1:11
	ds_read2_b32 v[46:47], v16 offset0:12 offset1:13
	ds_read2_b32 v[48:49], v16 offset0:14 offset1:15
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v14, v32, v27
	v_fmac_f32_e32 v13, v33, v27
	v_fmac_f32_e32 v12, v32, v29
	v_fmac_f32_e32 v11, v33, v29
	ds_read2_b32 v[26:27], v16 offset0:2 offset1:3
	ds_read2_b32 v[28:29], v18 offset0:2 offset1:3
	ds_read2_b32 v[30:31], v16 offset0:4 offset1:5
	ds_read2_b32 v[32:33], v16 offset0:6 offset1:7
	ds_read2_b32 v[50:51], v16 offset0:8 offset1:9
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v14, v34, v26
	v_fmac_f32_e32 v13, v35, v26
	ds_read2_b32 v[52:53], v18 offset0:4 offset1:5
	ds_read2_b32 v[54:55], v18 offset0:6 offset1:7
	ds_read2_b32 v[56:57], v18 offset0:8 offset1:9
	v_fmac_f32_e32 v14, v36, v27
	v_fmac_f32_e32 v13, v37, v27
	ds_read2_b32 v[26:27], v1 offset0:68 offset1:69
	s_waitcnt lgkmcnt(7)
	v_fmac_f32_e32 v12, v34, v28
	v_fmac_f32_e32 v11, v35, v28
	v_fmac_f32_e32 v12, v36, v29
	v_fmac_f32_e32 v11, v37, v29
	ds_read2_b32 v[28:29], v1 offset0:85 offset1:86
	ds_read2_b32 v[34:35], v1 offset0:102 offset1:103
	ds_read2_b32 v[36:37], v1 offset0:119 offset1:120
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v14, v26, v30
	v_fmac_f32_e32 v13, v27, v30
	v_fmac_f32_e32 v12, v26, v52
	v_fmac_f32_e32 v11, v27, v52
	ds_read2_b32 v[26:27], v1 offset0:136 offset1:137
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v14, v28, v31
	v_fmac_f32_e32 v13, v29, v31
	v_fmac_f32_e32 v12, v28, v53
	v_fmac_f32_e32 v11, v29, v53
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v14, v34, v32
	v_fmac_f32_e32 v13, v35, v32
	v_fmac_f32_e32 v12, v34, v54
	v_fmac_f32_e32 v11, v35, v54
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v14, v36, v33
	v_fmac_f32_e32 v13, v37, v33
	v_fmac_f32_e32 v12, v36, v55
	v_fmac_f32_e32 v11, v37, v55
	ds_read2_b32 v[28:29], v1 offset0:153 offset1:154
	ds_read2_b32 v[30:31], v1 offset0:170 offset1:171
	ds_read2_b32 v[32:33], v1 offset0:187 offset1:188
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v14, v26, v50
	v_fmac_f32_e32 v13, v27, v50
	v_fmac_f32_e32 v12, v26, v56
	v_fmac_f32_e32 v11, v27, v56
	ds_read2_b32 v[26:27], v18 offset0:10 offset1:11
	v_add_u32_e32 v36, 0x3fc, v1
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v14, v28, v51
	v_fmac_f32_e32 v13, v29, v51
	v_fmac_f32_e32 v12, v28, v57
	v_fmac_f32_e32 v11, v29, v57
	ds_read2_b32 v[28:29], v18 offset0:12 offset1:13
	ds_read2_b32 v[34:35], v18 offset0:14 offset1:15
	ds_read2_b32 v[36:37], v36 offset1:1
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v14, v30, v44
	v_fmac_f32_e32 v13, v31, v44
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v12, v30, v26
	v_fmac_f32_e32 v11, v31, v26
	v_fmac_f32_e32 v14, v32, v45
	v_fmac_f32_e32 v13, v33, v45
	v_fmac_f32_e32 v12, v32, v27
	v_fmac_f32_e32 v11, v33, v27
	v_fmac_f32_e32 v14, v38, v46
	v_fmac_f32_e32 v13, v39, v46
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v38, v28
	v_fmac_f32_e32 v11, v39, v28
	v_fmac_f32_e32 v14, v40, v47
	v_fmac_f32_e32 v13, v41, v47
	v_fmac_f32_e32 v12, v40, v29
	v_fmac_f32_e32 v11, v41, v29
	v_fmac_f32_e32 v14, v42, v48
	v_fmac_f32_e32 v13, v43, v48
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v34
	v_fmac_f32_e32 v11, v43, v34
	s_add_i32 s36, s36, 16
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v14, v36, v49
	v_fmac_f32_e32 v13, v37, v49
	v_fmac_f32_e32 v12, v36, v35
	v_fmac_f32_e32 v11, v37, v35
	s_cmp_ge_i32 s36, s37
	s_cbranch_scc1 .LBB1_43
.LBB1_12:
	v_add_u32_e32 v26, s36, v3
	v_cmp_gt_i32_e64 s[6:7], s22, v26
	s_and_b64 s[34:35], vcc, s[6:7]
	v_mov_b32_e32 v27, 0
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB1_14
	v_mad_u64_u32 v[28:29], s[34:35], v26, s15, v[0:1]
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v27, v[28:29], off
.LBB1_14:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v28, 1, v26
	v_cmp_gt_i32_e64 s[8:9], s22, v28
	s_waitcnt vmcnt(0)
	ds_write_b32 v24, v27
	v_add_u32_e32 v27, s36, v15
	s_and_b64 s[38:39], vcc, s[8:9]
	v_mov_b32_e32 v28, 0
	v_mov_b32_e32 v29, 0
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB1_16
	v_mad_u64_u32 v[30:31], s[38:39], v27, s15, v[0:1]
	v_ashrrev_i32_e32 v31, 31, v30
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[12:13]
	global_load_dword v29, v[30:31], off
.LBB1_16:
	s_or_b64 exec, exec, s[34:35]
	s_and_b64 s[34:35], s[2:3], s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v25, v29
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB1_18
	v_mad_u64_u32 v[28:29], s[34:35], v26, s15, v[6:7]
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v28, v[28:29], off
.LBB1_18:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v24, v28 offset:4
	s_and_b64 s[8:9], s[2:3], s[8:9]
	v_mov_b32_e32 v26, 0
	v_mov_b32_e32 v28, 0
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB1_20
	v_mad_u64_u32 v[28:29], s[8:9], v27, s15, v[6:7]
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v28, v[28:29], off
.LBB1_20:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v27, s36, v7
	v_cmp_gt_i32_e64 s[6:7], s22, v27
	s_and_b64 s[34:35], s[6:7], s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v25, v28 offset:4
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB1_22
	v_add_u32_e32 v28, s36, v20
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v26, v[28:29], off
.LBB1_22:
	s_or_b64 exec, exec, s[8:9]
	s_waitcnt vmcnt(0)
	ds_write_b32 v17, v26
	v_add_u32_e32 v26, 1, v27
	v_cmp_gt_i32_e64 s[8:9], s22, v26
	s_and_b64 s[38:39], s[8:9], s[0:1]
	v_mov_b32_e32 v26, 0
	v_mov_b32_e32 v27, 0
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB1_24
	v_add_u32_e32 v28, s36, v21
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v27, v[28:29], off
.LBB1_24:
	s_or_b64 exec, exec, s[34:35]
	s_and_b64 s[34:35], s[6:7], s[4:5]
	s_waitcnt vmcnt(0)
	ds_write_b32 v17, v27 offset:4
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB1_26
	v_add_u32_e32 v26, s36, v22
	v_ashrrev_i32_e32 v27, 31, v26
	v_lshl_add_u64 v[26:27], v[26:27], 2, s[16:17]
	global_load_dword v26, v[26:27], off
.LBB1_26:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v19, v26
	s_and_b64 s[8:9], s[8:9], s[4:5]
	v_mov_b32_e32 v26, 0
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB1_11
	v_add_u32_e32 v26, s36, v23
	v_ashrrev_i32_e32 v27, 31, v26
	v_lshl_add_u64 v[26:27], v[26:27], 2, s[16:17]
	global_load_dword v26, v[26:27], off
	s_branch .LBB1_11
.LBB1_28:
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execz .LBB1_75
.LBB1_29:
	s_cmp_lt_i32 s22, 16
	v_mul_lo_u32 v1, v8, s19
	s_cbranch_scc1 .LBB1_77
	s_ashr_i32 s0, s22, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s22, s0
	s_and_b32 s21, s0, -16
	s_or_b32 s0, s15, s14
	s_bitcmp1_b32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_lshr_b32 s2, s15, 31
	s_add_i32 s2, s15, s2
	s_ashr_i32 s28, s2, 1
	s_lshr_b32 s2, s14, 31
	s_add_i32 s2, s14, s2
	s_ashr_i32 s20, s2, 1
	s_or_b32 s2, s19, s18
	s_movk_i32 s4, 0x88
	s_bitcmp1_b32 s2, 0
	v_mov_b32_e32 v20, 0x440
	s_cselect_b64 s[2:3], -1, 0
	v_mad_u32_u24 v15, v10, s4, v20
	s_lshr_b32 s4, s19, 31
	s_add_i32 s4, s19, s4
	s_ashr_i32 s29, s4, 1
	s_lshr_b32 s4, s18, 31
	v_or_b32_e32 v13, 1, v3
	v_lshlrev_b32_e32 v0, 3, v4
	s_add_i32 s4, s18, s4
	v_add_u32_e32 v9, s14, v9
	v_lshlrev_b32_e32 v11, 2, v7
	s_movk_i32 s5, 0x44
	v_add_u32_e32 v4, s18, v7
	s_ashr_i32 s4, s4, 1
	v_add_u32_e32 v21, v9, v7
	v_add_u32_e32 v0, s20, v0
	v_add_u32_e32 v7, s33, v13
	v_mul_u32_u24_e32 v12, 0x88, v10
	v_add_u32_e32 v10, 1, v4
	v_mad_u32_u24 v18, v13, s5, v20
	v_add_u32_e32 v6, s4, v5
	v_lshl_add_u32 v20, v5, 3, v20
	v_add_u32_e32 v0, v0, v5
	v_mul_lo_u32 v5, v7, s19
	v_mul_u32_u24_e32 v14, 0x44, v13
	v_add_u32_e32 v16, v1, v4
	v_add_u32_e32 v24, v5, v4
	v_add_u32_e32 v25, v10, v5
	v_mad_u64_u32 v[4:5], s[4:5], v8, s29, v[6:7]
	v_mad_u64_u32 v[6:7], s[4:5], v7, s29, v[6:7]
	v_add_u32_e32 v17, v15, v11
	v_add_u32_e32 v19, v18, v11
	v_add_u32_e32 v22, 1, v21
	v_add_u32_e32 v23, v10, v1
	v_mov_b32_e32 v10, 0
	s_mov_b32 s20, 0
	v_add_u32_e32 v26, v11, v12
	v_add_u32_e32 v27, v11, v14
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v5, 0
	s_branch .LBB1_32
.LBB1_31:
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[28:29], v15 offset1:1
	ds_read2_b32 v[30:31], v18 offset1:1
	ds_read2_b32 v[32:33], v11 offset1:1
	ds_read2_b32 v[34:35], v11 offset0:17 offset1:18
	ds_read2_b32 v[36:37], v11 offset0:34 offset1:35
	ds_read2_b32 v[38:39], v11 offset0:51 offset1:52
	ds_read2_b32 v[40:41], v11 offset0:204 offset1:205
	ds_read2_b32 v[42:43], v11 offset0:221 offset1:222
	ds_read2_b32 v[44:45], v11 offset0:238 offset1:239
	s_waitcnt lgkmcnt(6)
	v_fmac_f32_e32 v10, v32, v28
	v_fmac_f32_e32 v9, v33, v28
	v_fmac_f32_e32 v7, v32, v30
	v_fmac_f32_e32 v5, v33, v30
	ds_read2_b32 v[46:47], v15 offset0:10 offset1:11
	ds_read2_b32 v[48:49], v15 offset0:12 offset1:13
	ds_read2_b32 v[50:51], v15 offset0:14 offset1:15
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v10, v34, v29
	v_fmac_f32_e32 v9, v35, v29
	v_fmac_f32_e32 v7, v34, v31
	v_fmac_f32_e32 v5, v35, v31
	ds_read2_b32 v[28:29], v15 offset0:2 offset1:3
	ds_read2_b32 v[30:31], v18 offset0:2 offset1:3
	ds_read2_b32 v[32:33], v15 offset0:4 offset1:5
	ds_read2_b32 v[34:35], v15 offset0:6 offset1:7
	ds_read2_b32 v[52:53], v15 offset0:8 offset1:9
	s_waitcnt lgkmcnt(4)
	v_fmac_f32_e32 v10, v36, v28
	v_fmac_f32_e32 v9, v37, v28
	ds_read2_b32 v[54:55], v18 offset0:4 offset1:5
	ds_read2_b32 v[56:57], v18 offset0:6 offset1:7
	ds_read2_b32 v[58:59], v18 offset0:8 offset1:9
	v_fmac_f32_e32 v10, v38, v29
	v_fmac_f32_e32 v9, v39, v29
	ds_read2_b32 v[28:29], v11 offset0:68 offset1:69
	s_waitcnt lgkmcnt(7)
	v_fmac_f32_e32 v7, v36, v30
	v_fmac_f32_e32 v5, v37, v30
	v_fmac_f32_e32 v7, v38, v31
	v_fmac_f32_e32 v5, v39, v31
	ds_read2_b32 v[30:31], v11 offset0:85 offset1:86
	ds_read2_b32 v[36:37], v11 offset0:102 offset1:103
	ds_read2_b32 v[38:39], v11 offset0:119 offset1:120
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v10, v28, v32
	v_fmac_f32_e32 v9, v29, v32
	v_fmac_f32_e32 v7, v28, v54
	v_fmac_f32_e32 v5, v29, v54
	ds_read2_b32 v[28:29], v11 offset0:136 offset1:137
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v10, v30, v33
	v_fmac_f32_e32 v9, v31, v33
	v_fmac_f32_e32 v7, v30, v55
	v_fmac_f32_e32 v5, v31, v55
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v10, v36, v34
	v_fmac_f32_e32 v9, v37, v34
	v_fmac_f32_e32 v7, v36, v56
	v_fmac_f32_e32 v5, v37, v56
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v10, v38, v35
	v_fmac_f32_e32 v9, v39, v35
	v_fmac_f32_e32 v7, v38, v57
	v_fmac_f32_e32 v5, v39, v57
	ds_read2_b32 v[30:31], v11 offset0:153 offset1:154
	ds_read2_b32 v[32:33], v11 offset0:170 offset1:171
	ds_read2_b32 v[34:35], v11 offset0:187 offset1:188
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v10, v28, v52
	v_fmac_f32_e32 v9, v29, v52
	v_fmac_f32_e32 v7, v28, v58
	v_fmac_f32_e32 v5, v29, v58
	ds_read2_b32 v[28:29], v18 offset0:10 offset1:11
	v_add_u32_e32 v38, 0x3fc, v11
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v10, v30, v53
	v_fmac_f32_e32 v9, v31, v53
	v_fmac_f32_e32 v7, v30, v59
	v_fmac_f32_e32 v5, v31, v59
	ds_read2_b32 v[30:31], v18 offset0:12 offset1:13
	ds_read2_b32 v[36:37], v18 offset0:14 offset1:15
	ds_read2_b32 v[38:39], v38 offset1:1
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v10, v32, v46
	v_fmac_f32_e32 v9, v33, v46
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v7, v32, v28
	v_fmac_f32_e32 v5, v33, v28
	v_fmac_f32_e32 v10, v34, v47
	v_fmac_f32_e32 v9, v35, v47
	v_fmac_f32_e32 v7, v34, v29
	v_fmac_f32_e32 v5, v35, v29
	v_fmac_f32_e32 v10, v40, v48
	v_fmac_f32_e32 v9, v41, v48
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v7, v40, v30
	v_fmac_f32_e32 v5, v41, v30
	v_fmac_f32_e32 v10, v42, v49
	v_fmac_f32_e32 v9, v43, v49
	v_fmac_f32_e32 v7, v42, v31
	v_fmac_f32_e32 v5, v43, v31
	v_fmac_f32_e32 v10, v44, v50
	v_fmac_f32_e32 v9, v45, v50
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v7, v44, v36
	v_fmac_f32_e32 v5, v45, v36
	s_add_i32 s20, s20, 16
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v38, v51
	v_fmac_f32_e32 v9, v39, v51
	v_fmac_f32_e32 v7, v38, v37
	v_fmac_f32_e32 v5, v39, v37
	s_cmp_ge_i32 s20, s21
	s_cbranch_scc1 .LBB1_78
.LBB1_32:
	v_add_u32_e32 v29, s20, v3
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[0:1]
	v_add_u32_e32 v28, s20, v13
	s_cbranch_vccz .LBB1_36
	v_mul_lo_u32 v34, v29, s15
	v_mul_lo_u32 v36, v28, s15
	v_add_u32_e32 v30, v34, v21
	v_add_u32_e32 v32, v36, v21
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v33, 31, v32
	v_add_u32_e32 v34, v34, v22
	v_add_u32_e32 v36, v36, v22
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[12:13]
	v_lshl_add_u64 v[32:33], v[32:33], 2, s[12:13]
	v_ashrrev_i32_e32 v35, 31, v34
	v_ashrrev_i32_e32 v37, 31, v36
	v_lshl_add_u64 v[34:35], v[34:35], 2, s[12:13]
	v_lshl_add_u64 v[36:37], v[36:37], 2, s[12:13]
	global_load_dword v30, v[30:31], off
	global_load_dword v31, v[32:33], off
	global_load_dword v32, v[34:35], off
	global_load_dword v33, v[36:37], off
	s_waitcnt vmcnt(3)
	ds_write_b32 v26, v30
	s_waitcnt vmcnt(2)
	ds_write_b32 v27, v31
	s_waitcnt vmcnt(1)
	ds_write_b32 v26, v32 offset:4
	s_waitcnt vmcnt(0)
	ds_write_b32 v27, v33 offset:4
	s_cbranch_execz .LBB1_37
.LBB1_34:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB1_38
.LBB1_35:
	v_add_u32_e32 v28, s20, v16
	v_add_u32_e32 v30, s20, v23
	v_ashrrev_i32_e32 v29, 31, v28
	v_ashrrev_i32_e32 v31, 31, v30
	v_add_u32_e32 v32, s20, v24
	v_add_u32_e32 v34, s20, v25
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[16:17]
	v_ashrrev_i32_e32 v33, 31, v32
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[32:33], v[32:33], 2, s[16:17]
	v_lshl_add_u64 v[34:35], v[34:35], 2, s[16:17]
	global_load_dword v28, v[28:29], off
	global_load_dword v29, v[30:31], off
	global_load_dword v30, v[32:33], off
	global_load_dword v31, v[34:35], off
	s_waitcnt vmcnt(2)
	ds_write2_b32 v17, v28, v29 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v19, v30, v31 offset1:1
	s_cbranch_execnz .LBB1_31
	s_branch .LBB1_39
.LBB1_36:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB1_34
.LBB1_37:
	v_mad_u64_u32 v[30:31], s[4:5], v29, s28, v[0:1]
	v_mad_u64_u32 v[28:29], s[4:5], v28, s28, v[0:1]
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[30:31], v[30:31], 3, s[12:13]
	v_lshl_add_u64 v[28:29], v[28:29], 3, s[12:13]
	global_load_dwordx2 v[30:31], v[30:31], off
	global_load_dwordx2 v[28:29], v[28:29], off
	s_waitcnt vmcnt(1)
	ds_write2_b32 v26, v30, v31 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v27, v28, v29 offset1:1
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB1_35
.LBB1_38:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB1_31
.LBB1_39:
	s_lshr_b32 s4, s20, 1
	v_add_u32_e32 v28, s4, v4
	v_add_u32_e32 v30, s4, v6
	v_ashrrev_i32_e32 v29, 31, v28
	v_ashrrev_i32_e32 v31, 31, v30
	v_lshl_add_u64 v[28:29], v[28:29], 3, s[16:17]
	v_lshl_add_u64 v[30:31], v[30:31], 3, s[16:17]
	global_load_dwordx2 v[28:29], v[28:29], off
	global_load_dwordx2 v[30:31], v[30:31], off
	v_add_u32_e32 v32, v20, v12
	v_add_u32_e32 v33, v20, v14
	s_waitcnt vmcnt(1)
	ds_write2_b32 v32, v28, v29 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v33, v30, v31 offset1:1
	s_branch .LBB1_31
.LBB1_40:
	s_branch .LBB1_2
.LBB1_41:
	s_branch .LBB1_5
.LBB1_42:
	s_mov_b32 s36, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v14, 0
.LBB1_43:
	s_cmp_ge_i32 s36, s22
	v_or_b32_e32 v6, 1, v2
	s_cbranch_scc1 .LBB1_54
	v_mul_lo_u32 v15, v8, s19
	v_or_b32_e32 v0, 1, v8
	v_add_u32_e32 v15, s18, v15
	v_cmp_gt_i32_e32 vcc, s20, v2
	v_cmp_gt_i32_e64 s[0:1], s20, v6
	v_cmp_gt_i32_e64 s[2:3], s21, v8
	v_cmp_gt_i32_e64 s[4:5], s21, v0
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v1, s14, v6
	v_add_u32_e32 v16, s19, v15
	s_branch .LBB1_46
.LBB1_45:
	s_or_b64 exec, exec, s[6:7]
	s_add_i32 s36, s36, 1
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v14, v18, v20
	v_fmac_f32_e32 v13, v17, v20
	v_fmac_f32_e32 v12, v18, v19
	s_cmp_ge_i32 s36, s22
	v_fmac_f32_e32 v11, v17, v19
	s_cbranch_scc1 .LBB1_54
.LBB1_46:
	v_mov_b32_e32 v17, 0
	s_mul_i32 s8, s36, s15
	v_mov_b32_e32 v18, 0
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_48
	v_add_u32_e32 v18, s8, v0
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v18, v[18:19], off
.LBB1_48:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB1_50
	v_add_u32_e32 v20, s8, v1
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[12:13]
	global_load_dword v17, v[20:21], off
.LBB1_50:
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v19, 0
	v_mov_b32_e32 v20, 0
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB1_52
	v_add_u32_e32 v20, s36, v15
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v20, v[20:21], off
.LBB1_52:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB1_45
	v_add_u32_e32 v22, s36, v16
	v_ashrrev_i32_e32 v23, 31, v22
	v_lshl_add_u64 v[22:23], v[22:23], 2, s[16:17]
	global_load_dword v19, v[22:23], off
	s_branch .LBB1_45
.LBB1_54:
	s_cmp_eq_u32 s26, 0
	v_cmp_le_i32_e64 s[2:3], s21, v8
	v_cmp_le_i32_e64 s[4:5], s20, v2
	s_cselect_b64 s[0:1], -1, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[8:9], s27, 0
	s_nor_b64 s[34:35], s[4:5], s[2:3]
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB1_59
	v_cndmask_b32_e64 v1, v2, v8, s[0:1]
	v_cndmask_b32_e64 v0, v8, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[34:35], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[8:9]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccz .LBB1_107
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[10:11]
	global_load_dword v15, v[16:17], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v15, s27, v15
	v_fmac_f32_e32 v15, s23, v14
	s_cbranch_execnz .LBB1_58
.LBB1_57:
	v_mul_f32_e32 v15, s23, v14
.LBB1_58:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v15, off
.LBB1_59:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_le_i32_e64 s[6:7], s20, v6
	v_cndmask_b32_e64 v0, 0, 1, s[8:9]
	s_nor_b64 s[34:35], s[6:7], s[2:3]
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB1_64
	v_cndmask_b32_e64 v1, v6, v8, s[0:1]
	v_cndmask_b32_e64 v0, v8, v6, s[0:1]
	v_mad_u64_u32 v[0:1], s[34:35], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB1_108
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v14, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v14, s27, v14
	v_fmac_f32_e32 v14, s23, v13
	s_cbranch_execnz .LBB1_63
.LBB1_62:
	v_mul_f32_e32 v14, s23, v13
.LBB1_63:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v14, off
.LBB1_64:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v13, 1, v8
	v_cmp_le_i32_e64 s[8:9], s21, v13
	s_nor_b64 s[20:21], s[4:5], s[8:9]
	s_and_saveexec_b64 s[4:5], s[20:21]
	s_cbranch_execz .LBB1_69
	v_cndmask_b32_e64 v1, v2, v13, s[0:1]
	v_cndmask_b32_e64 v0, v13, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[20:21], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB1_109
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v14, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v14, s27, v14
	v_fmac_f32_e32 v14, s23, v12
	s_cbranch_execnz .LBB1_68
.LBB1_67:
	v_mul_f32_e32 v14, s23, v12
.LBB1_68:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v14, off
.LBB1_69:
	s_or_b64 exec, exec, s[4:5]
	s_nor_b64 s[4:5], s[6:7], s[8:9]
	s_mov_b64 s[6:7], 0
	s_and_saveexec_b64 s[8:9], s[4:5]
	s_xor_b64 s[4:5], exec, s[8:9]
	s_cbranch_execz .LBB1_74
	v_cndmask_b32_e64 v1, v6, v13, s[0:1]
	v_cndmask_b32_e64 v0, v13, v6, s[0:1]
	v_mad_u64_u32 v[0:1], s[0:1], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB1_110
	v_lshl_add_u64 v[12:13], v[0:1], 2, s[10:11]
	global_load_dword v6, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v12, s27, v6
	v_fmac_f32_e32 v12, s23, v11
	s_cbranch_execnz .LBB1_73
.LBB1_72:
	v_mul_f32_e32 v12, s23, v11
.LBB1_73:
	s_mov_b64 s[6:7], exec
.LBB1_74:
	s_or_b64 exec, exec, s[4:5]
	s_and_b64 s[6:7], s[6:7], exec
	s_andn2_b64 s[28:29], s[28:29], exec
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execnz .LBB1_29
.LBB1_75:
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB1_102
.LBB1_76:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v12, off
	s_endpgm
.LBB1_77:
	s_mov_b32 s20, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v10, 0
.LBB1_78:
	s_cmp_ge_i32 s20, s22
	s_cbranch_scc1 .LBB1_81
	v_add_u32_e32 v0, s14, v2
	v_add_u32_e32 v1, s18, v1
	v_add_u32_e32 v3, 1, v0
	v_add_u32_e32 v4, s19, v1
.LBB1_80:
	s_mul_i32 s0, s20, s15
	v_add_u32_e32 v12, s20, v1
	v_add_u32_e32 v14, s20, v4
	v_add_u32_e32 v16, s0, v0
	v_add_u32_e32 v18, s0, v3
	v_ashrrev_i32_e32 v13, 31, v12
	v_ashrrev_i32_e32 v15, 31, v14
	v_ashrrev_i32_e32 v17, 31, v16
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[16:17]
	v_lshl_add_u64 v[14:15], v[14:15], 2, s[16:17]
	v_lshl_add_u64 v[16:17], v[16:17], 2, s[12:13]
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v6, v[12:13], off
	global_load_dword v11, v[14:15], off
	global_load_dword v12, v[16:17], off
	global_load_dword v13, v[18:19], off
	s_add_i32 s20, s20, 1
	s_cmp_lt_i32 s20, s22
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v10, v12, v6
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v9, v13, v6
	v_fmac_f32_e32 v7, v12, v11
	v_fmac_f32_e32 v5, v13, v11
	s_cbranch_scc1 .LBB1_80
.LBB1_81:
	s_cmp_eq_u32 s26, 0
	v_mad_u64_u32 v[0:1], s[0:1], v8, s25, v[2:3]
	v_mul_lo_u32 v4, v2, s25
	v_add_u32_e32 v1, v4, v8
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v2, v1, v0, s[0:1]
	s_cmp_lg_u32 s26, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[12:13], s27, 0
	v_add_u32_e32 v2, s24, v2
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccz .LBB1_103
	v_lshl_add_u64 v[12:13], v[2:3], 2, s[10:11]
	global_load_dword v6, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s27, v6
	v_fmac_f32_e32 v6, s23, v10
	s_cbranch_execnz .LBB1_84
.LBB1_83:
	v_mul_f32_e32 v6, s23, v10
.LBB1_84:
	v_cndmask_b32_e64 v10, 0, 1, s[4:5]
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	v_cmp_ne_u32_e64 s[2:3], 1, v10
	s_andn2_b64 vcc, exec, s[4:5]
	global_store_dword v[2:3], v6, off
	s_cbranch_vccnz .LBB1_86
	v_add_u32_e32 v1, s25, v1
	s_cbranch_execz .LBB1_87
	s_branch .LBB1_88
.LBB1_86:
.LBB1_87:
	v_or_b32_e32 v1, 1, v0
.LBB1_88:
	v_cndmask_b32_e64 v2, 0, 1, s[12:13]
	v_cmp_ne_u32_e64 s[4:5], 1, v2
	v_add_u32_e32 v2, s24, v1
	s_andn2_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccnz .LBB1_104
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[10:11]
	global_load_dword v1, v[10:11], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, s27, v1
	v_fmac_f32_e32 v1, s23, v9
	s_cbranch_execnz .LBB1_91
.LBB1_90:
	v_mul_f32_e32 v1, s23, v9
.LBB1_91:
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	global_store_dword v[2:3], v1, off
	v_or_b32_e32 v3, 1, v8
	v_add_u32_e32 v2, s25, v0
	v_add_u32_e32 v0, v4, v3
	v_cndmask_b32_e64 v0, v0, v2, s[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB1_105
	v_lshl_add_u64 v[8:9], v[0:1], 2, s[10:11]
	global_load_dword v6, v[8:9], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s27, v6
	v_fmac_f32_e32 v6, s23, v7
	s_cbranch_execnz .LBB1_94
.LBB1_93:
	v_mul_f32_e32 v6, s23, v7
.LBB1_94:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	s_and_b64 vcc, exec, s[2:3]
	global_store_dword v[0:1], v6, off
	s_cbranch_vccnz .LBB1_96
	v_add3_u32 v0, v4, s25, v3
	s_cbranch_execz .LBB1_97
	s_branch .LBB1_98
.LBB1_96:
.LBB1_97:
	v_add_u32_e32 v0, 1, v2
.LBB1_98:
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB1_106
	v_lshl_add_u64 v[2:3], v[0:1], 2, s[10:11]
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v12, s27, v2
	v_fmac_f32_e32 v12, s23, v5
	s_cbranch_execnz .LBB1_101
.LBB1_100:
	v_mul_f32_e32 v12, s23, v5
.LBB1_101:
	s_or_b64 s[6:7], s[6:7], exec
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execnz .LBB1_76
.LBB1_102:
	s_endpgm
.LBB1_103:
	s_branch .LBB1_83
.LBB1_104:
	s_branch .LBB1_90
.LBB1_105:
	s_branch .LBB1_93
.LBB1_106:
	s_branch .LBB1_100
.LBB1_107:
	s_branch .LBB1_57
.LBB1_108:
	s_branch .LBB1_62
.LBB1_109:
	s_branch .LBB1_67
.LBB1_110:
	s_branch .LBB1_72
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel XgemmDirectNT
		.amdhsa_group_segment_fixed_size 2176
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 60
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 60
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
	.text
.Lfunc_end1:
	.size	XgemmDirectNT, .Lfunc_end1-XgemmDirectNT

	.set XgemmDirectNT.num_vgpr, 60
	.set XgemmDirectNT.num_agpr, 0
	.set XgemmDirectNT.numbered_sgpr, 40
	.set XgemmDirectNT.private_seg_size, 0
	.set XgemmDirectNT.uses_vcc, 1
	.set XgemmDirectNT.uses_flat_scratch, 0
	.set XgemmDirectNT.has_dyn_sized_stack, 0
	.set XgemmDirectNT.has_recursion, 0
	.set XgemmDirectNT.has_indirect_call, 0
	.protected	XgemmDirectTN
	.globl	XgemmDirectTN
	.p2align	8
	.type	XgemmDirectTN,@function
XgemmDirectTN:
	s_load_dwordx2 s[4:5], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s4, s3
	s_add_i32 s8, s3, s2
	s_ashr_i32 s9, s8, 31
	s_mov_b32 s2, 0
	s_mov_b32 s3, s9
	s_cmp_lg_u64 s[2:3], 0
	s_cbranch_scc0 .LBB2_40
	v_cvt_f32_u32_e32 v1, s5
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s5
	s_subb_u32 s7, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s12, s6, s10
	s_mul_hi_u32 s14, s6, s11
	s_mul_i32 s13, s7, s11
	s_add_i32 s12, s14, s12
	s_add_i32 s12, s12, s13
	s_mul_i32 s15, s6, s11
	s_mul_hi_u32 s13, s11, s12
	s_mul_i32 s14, s11, s12
	s_mul_hi_u32 s11, s11, s15
	s_add_u32 s11, s11, s14
	s_addc_u32 s13, 0, s13
	s_mul_hi_u32 s16, s10, s15
	s_mul_i32 s15, s10, s15
	s_add_u32 s11, s11, s15
	s_mul_hi_u32 s14, s10, s12
	s_addc_u32 s11, s13, s16
	s_addc_u32 s13, s14, 0
	s_mul_i32 s12, s10, s12
	s_add_u32 s11, s11, s12
	s_addc_u32 s12, 0, s13
	v_add_co_u32_e32 v1, vcc, s11, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s10, s10, s12
	v_readfirstlane_b32 s12, v1
	s_mul_i32 s11, s6, s10
	s_mul_hi_u32 s13, s6, s12
	s_add_i32 s11, s13, s11
	s_mul_i32 s7, s7, s12
	s_add_i32 s11, s11, s7
	s_mul_i32 s6, s6, s12
	s_mul_hi_u32 s13, s10, s6
	s_mul_i32 s14, s10, s6
	s_mul_i32 s16, s12, s11
	s_mul_hi_u32 s6, s12, s6
	s_mul_hi_u32 s15, s12, s11
	s_add_u32 s6, s6, s16
	s_addc_u32 s12, 0, s15
	s_add_u32 s6, s6, s14
	s_mul_hi_u32 s7, s10, s11
	s_addc_u32 s6, s12, s13
	s_addc_u32 s7, s7, 0
	s_mul_i32 s11, s10, s11
	s_add_u32 s6, s6, s11
	s_addc_u32 s7, 0, s7
	v_add_co_u32_e32 v1, vcc, s6, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s6, s10, s7
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s10, s8, s6
	s_mul_hi_u32 s12, s8, s11
	s_mul_hi_u32 s7, s8, s6
	s_add_u32 s10, s12, s10
	s_addc_u32 s7, 0, s7
	s_mul_hi_u32 s13, s9, s11
	s_mul_i32 s11, s9, s11
	s_add_u32 s10, s10, s11
	s_mul_hi_u32 s12, s9, s6
	s_addc_u32 s7, s7, s13
	s_addc_u32 s10, s12, 0
	s_mul_i32 s6, s9, s6
	s_add_u32 s6, s7, s6
	s_addc_u32 s7, 0, s10
	s_add_u32 s10, s6, 1
	s_addc_u32 s11, s7, 0
	s_add_u32 s12, s6, 2
	s_mul_i32 s14, s5, s7
	s_mul_hi_u32 s15, s5, s6
	s_addc_u32 s13, s7, 0
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s5, s6
	v_mov_b32_e32 v1, s14
	v_sub_co_u32_e32 v1, vcc, s8, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s14, s9, s15
	v_subrev_co_u32_e32 v2, vcc, s5, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s15, s14, 0
	v_readfirstlane_b32 s16, v2
	s_cmp_ge_u32 s16, s5
	s_cselect_b32 s16, -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b32 s15, s16, -1
	s_cmp_lg_u32 s15, 0
	s_cselect_b32 s10, s12, s10
	v_readfirstlane_b32 s12, v1
	s_cselect_b32 s11, s13, s11
	s_cmp_ge_u32 s12, s5
	s_cselect_b32 s12, -1, 0
	s_cmp_eq_u32 s14, 0
	s_cselect_b32 s12, s12, -1
	s_cmp_lg_u32 s12, 0
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s6, s10, s6
	s_cbranch_execnz .LBB2_3
.LBB2_2:
	v_cvt_f32_u32_e32 v1, s5
	s_sub_i32 s2, 0, s5
	s_mov_b32 s7, 0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s3, v1
	s_mul_i32 s2, s2, s3
	s_mul_hi_u32 s2, s3, s2
	s_add_i32 s3, s3, s2
	s_mul_hi_u32 s2, s8, s3
	s_mul_i32 s6, s2, s5
	s_sub_i32 s6, s8, s6
	s_add_i32 s3, s2, 1
	s_sub_i32 s10, s6, s5
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s2, s3, s2
	s_cselect_b32 s6, s10, s6
	s_add_i32 s3, s2, 1
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s6, s3, s2
.LBB2_3:
	s_mul_i32 s2, s7, s5
	s_mul_hi_u32 s3, s6, s5
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s6, s5
	s_sub_u32 s26, s8, s2
	s_subb_u32 s27, s9, s3
	s_bfe_i64 s[2:3], s[26:27], 0x200000
	s_add_u32 s5, s2, s6
	s_addc_u32 s7, s3, s7
	s_mov_b32 s6, 0
	s_cmp_lg_u64 s[6:7], 0
	s_cbranch_scc0 .LBB2_41
	v_cvt_f32_u32_e32 v1, s4
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s4
	s_subb_u32 s8, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	v_mov_b32_e32 v5, 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v6, v2
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s6, v6
	v_mul_hi_u32 v4, s6, v1
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v2, v4, v2
	v_mul_lo_u32 v7, s6, v1
	v_add_u32_e32 v8, v2, v3
	v_mul_hi_u32 v3, v1, v8
	v_mul_lo_u32 v2, v1, v8
	v_mul_hi_u32 v4, v1, v7
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, v6, v7
	v_mul_lo_u32 v7, v6, v7
	v_add_co_u32_e32 v2, vcc, v2, v7
	v_mul_hi_u32 v9, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v9, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_lo_u32 v4, s6, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_lo_u32 v2, s6, v6
	v_mul_hi_u32 v3, s6, v1
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v7, v2, v3
	v_mul_hi_u32 v9, v6, v4
	v_mul_lo_u32 v10, v6, v4
	v_mul_hi_u32 v3, v1, v7
	v_mul_lo_u32 v2, v1, v7
	v_mul_hi_u32 v4, v1, v4
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v10
	v_mul_hi_u32 v8, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v9, vcc
	v_mul_lo_u32 v2, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v8, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_hi_u32 v4, s5, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_hi_u32 v3, s5, v6
	v_mul_lo_u32 v2, s5, v6
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, s7, v1
	v_mul_lo_u32 v1, s7, v1
	v_add_co_u32_e32 v1, vcc, v2, v1
	v_mul_hi_u32 v7, s7, v6
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, s7, v6
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v7, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_lo_u32 v1, s4, v3
	v_mul_hi_u32 v3, s4, v2
	v_mul_lo_u32 v2, s4, v2
	v_add_u32_e32 v1, v3, v1
	v_mov_b32_e32 v3, s7
	v_sub_co_u32_e32 v2, vcc, s5, v2
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v3, v1, vcc
	v_subrev_co_u32_e32 v3, vcc, s4, v2
	s_nop 1
	v_subbrev_co_u32_e32 v4, vcc, 0, v1, vcc
	v_subrev_co_u32_e32 v5, vcc, s4, v3
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v4, -1, v6, vcc
	v_cmp_ne_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_cmp_le_u32_e32 vcc, s4, v2
	s_nop 1
	v_cndmask_b32_e64 v4, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1, v4, vcc
	v_cmp_ne_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v3, vcc
	s_cbranch_execnz .LBB2_6
.LBB2_5:
	v_cvt_f32_u32_e32 v1, s4
	s_sub_i32 s2, 0, s4
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s2, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, s5, v1
	v_mul_lo_u32 v1, v1, s4
	v_sub_u32_e32 v1, s5, v1
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v2, v1, v2, vcc
.LBB2_6:
	s_load_dwordx8 s[12:19], s[0:1], 0x18
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[24:25], s[0:1], 0x38
	s_load_dwordx4 s[20:23], s[0:1], 0x40
	v_and_b32_e32 v6, 0x3ff, v0
	v_lshlrev_b32_e32 v5, 4, v2
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s2, s8, 31
	s_lshr_b32 s2, s2, 28
	v_lshlrev_b32_e32 v8, 1, v6
	v_bfe_u32 v9, v0, 10, 10
	s_add_i32 s2, s8, s2
	v_or_b32_e32 v2, v5, v8
	s_lshl_b32 s27, s26, 4
	v_lshlrev_b32_e32 v3, 1, v9
	s_and_b32 s4, s2, -16
	v_or_b32_e32 v7, s27, v3
	v_cmp_le_i32_e64 s[2:3], s4, v2
	v_cmp_gt_i32_e32 vcc, s4, v2
	s_mov_b64 s[6:7], 0
	s_mov_b64 s[28:29], 0
	s_and_saveexec_b64 s[4:5], vcc
	s_ashr_i32 s23, s9, 31
	s_lshr_b32 s23, s23, 28
	s_add_i32 s23, s9, s23
	s_and_b32 s23, s23, -16
	v_cmp_le_i32_e32 vcc, s23, v7
	s_andn2_b64 s[2:3], s[2:3], exec
	s_and_b64 s[30:31], vcc, exec
	s_mov_b64 s[28:29], exec
	s_or_b64 s[2:3], s[2:3], s[30:31]
	s_or_b64 exec, exec, s[4:5]
	s_load_dword s23, s[0:1], 0x10
	s_and_saveexec_b64 s[30:31], s[2:3]
	s_cbranch_execz .LBB2_28
	s_cmp_lt_i32 s10, 16
	s_cbranch_scc1 .LBB2_42
	s_ashr_i32 s0, s10, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s10, s0
	v_or_b32_e32 v1, 1, v3
	v_or_b32_e32 v4, 1, v8
	s_and_b32 s36, s0, -16
	s_movk_i32 s0, 0x88
	v_mov_b32_e32 v14, 0x440
	v_lshlrev_b32_e32 v17, 7, v9
	v_add_u32_e32 v32, v5, v3
	v_add_u32_e32 v33, v5, v1
	v_add_u32_e32 v34, s27, v4
	v_add_u32_e32 v0, s14, v8
	v_lshlrev_b32_e32 v10, 2, v8
	v_mul_u32_u24_e32 v11, 0x88, v9
	v_mul_u32_u24_e32 v12, 0x44, v1
	v_add_u32_e32 v13, s14, v4
	s_movk_i32 s1, 0x440
	v_mad_u32_u24 v39, v9, s0, v14
	v_lshlrev_b32_e32 v38, 7, v6
	v_sub_u32_e32 v40, 0, v17
	v_lshlrev_b32_e32 v31, 2, v3
	v_add_u32_e32 v36, s27, v8
	v_cmp_gt_i32_e64 s[4:5], s9, v34
	v_mul_lo_u32 v34, v32, s15
	v_mul_lo_u32 v35, v33, s15
	s_add_i32 s6, s27, s18
	v_add_u32_e32 v14, v39, v10
	v_add3_u32 v15, v12, v10, s1
	v_mul_u32_u24_e32 v16, 0x44, v4
	s_mov_b32 s33, 0
	v_add_u32_e32 v17, 0x484, v31
	v_add_u32_e32 v18, 0x4c8, v31
	v_add_u32_e32 v19, 0x50c, v31
	v_add_u32_e32 v20, 0x550, v31
	v_add_u32_e32 v21, 0x594, v31
	v_add_u32_e32 v22, 0x5d8, v31
	v_add_u32_e32 v23, 0x61c, v31
	v_add_u32_e32 v24, 0x660, v31
	v_add_u32_e32 v25, 0x6a4, v31
	v_add_u32_e32 v26, 0x6e8, v31
	v_add_u32_e32 v27, 0x72c, v31
	v_add_u32_e32 v28, 0x770, v31
	v_add_u32_e32 v29, 0x7b4, v31
	v_add_u32_e32 v30, 0x7f8, v31
	v_add_u32_e32 v31, 0x83c, v31
	v_cmp_gt_i32_e32 vcc, s8, v32
	v_cmp_gt_i32_e64 s[0:1], s8, v33
	v_cmp_gt_i32_e64 s[2:3], s9, v36
	v_add_u32_e32 v32, v34, v0
	v_add_u32_e32 v33, v35, v0
	v_add_u32_e32 v34, v34, v13
	v_add_u32_e32 v35, v35, v13
	v_add_u32_e32 v0, s18, v36
	v_add_u32_e32 v4, s6, v4
	v_mov_b32_e32 v13, 0
	v_add_u32_e32 v36, v10, v11
	v_add_u32_e32 v37, v10, v12
	v_add_u32_e32 v38, v10, v38
	v_add_u32_e32 v39, v39, v40
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v10, 0
	s_branch .LBB2_12
.LBB2_11:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v15, v40 offset:4
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[40:41], v38 offset1:1
	ds_read2_b32 v[42:43], v16 offset1:1
	ds_read2_b32 v[44:45], v39 offset1:1
	s_add_i32 s33, s33, 16
	s_cmp_ge_i32 s33, s36
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v13, v40, v44
	v_fmac_f32_e32 v12, v42, v44
	v_fmac_f32_e32 v11, v40, v45
	v_fmac_f32_e32 v10, v42, v45
	ds_read2_b32 v[44:45], v39 offset0:17 offset1:34
	ds_read_b32 v40, v17 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:2 offset1:3
	ds_read2_b32 v[42:43], v16 offset0:2 offset1:3
	ds_read_b32 v44, v18 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:51 offset1:68
	ds_read_b32 v40, v19 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:4 offset1:5
	ds_read2_b32 v[42:43], v16 offset0:4 offset1:5
	ds_read_b32 v44, v20 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:85 offset1:102
	ds_read_b32 v40, v21 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:6 offset1:7
	ds_read2_b32 v[42:43], v16 offset0:6 offset1:7
	ds_read_b32 v44, v22 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:119 offset1:136
	ds_read_b32 v40, v23 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:8 offset1:9
	ds_read2_b32 v[42:43], v16 offset0:8 offset1:9
	ds_read_b32 v44, v24 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:153 offset1:170
	ds_read_b32 v40, v25 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:10 offset1:11
	ds_read2_b32 v[42:43], v16 offset0:10 offset1:11
	ds_read_b32 v44, v26 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:187 offset1:204
	ds_read_b32 v40, v27 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:12 offset1:13
	ds_read2_b32 v[42:43], v16 offset0:12 offset1:13
	ds_read_b32 v44, v28 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read2_b32 v[44:45], v39 offset0:221 offset1:238
	ds_read_b32 v40, v29 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v13, v41, v44
	v_fmac_f32_e32 v12, v43, v44
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v41, v40
	v_fmac_f32_e32 v10, v43, v40
	ds_read2_b32 v[40:41], v38 offset0:14 offset1:15
	ds_read2_b32 v[42:43], v16 offset0:14 offset1:15
	ds_read_b32 v44, v30 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v13, v40, v45
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v42, v45
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v11, v40, v44
	v_fmac_f32_e32 v10, v42, v44
	ds_read_b32 v40, v39 offset:1020
	ds_read_b32 v42, v31 offset:4
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v13, v41, v40
	v_fmac_f32_e32 v12, v43, v40
	v_fmac_f32_e32 v11, v41, v42
	v_fmac_f32_e32 v10, v43, v42
	s_cbranch_scc1 .LBB2_43
.LBB2_12:
	v_add_u32_e32 v40, s33, v8
	v_cmp_gt_i32_e64 s[6:7], s10, v40
	s_and_b64 s[38:39], s[6:7], vcc
	v_mov_b32_e32 v41, 0
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB2_14
	v_add_u32_e32 v42, s33, v32
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	global_load_dword v41, v[42:43], off
.LBB2_14:
	s_or_b64 exec, exec, s[34:35]
	s_waitcnt vmcnt(0)
	ds_write_b32 v36, v41
	s_and_b64 s[34:35], s[6:7], s[0:1]
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v42, 0
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB2_16
	v_add_u32_e32 v42, s33, v33
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	global_load_dword v42, v[42:43], off
.LBB2_16:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v40, 1, v40
	v_cmp_gt_i32_e64 s[6:7], s10, v40
	s_and_b64 s[38:39], s[6:7], vcc
	s_waitcnt vmcnt(0)
	ds_write_b32 v37, v42
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB2_18
	v_add_u32_e32 v40, s33, v34
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[12:13]
	global_load_dword v41, v[40:41], off
.LBB2_18:
	s_or_b64 exec, exec, s[34:35]
	s_waitcnt vmcnt(0)
	ds_write_b32 v36, v41 offset:4
	s_and_b64 s[34:35], s[6:7], s[0:1]
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v40, 0
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB2_20
	v_add_u32_e32 v42, s33, v35
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[12:13]
	global_load_dword v40, v[42:43], off
.LBB2_20:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v37, v40 offset:4
	v_add_u32_e32 v40, s33, v3
	v_cmp_gt_i32_e64 s[6:7], s10, v40
	s_and_b64 s[38:39], s[2:3], s[6:7]
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB2_22
	v_mad_u64_u32 v[42:43], s[38:39], v40, s19, v[0:1]
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[16:17]
	global_load_dword v41, v[42:43], off
.LBB2_22:
	s_or_b64 exec, exec, s[34:35]
	s_waitcnt vmcnt(0)
	ds_write_b32 v14, v41
	s_and_b64 s[34:35], s[4:5], s[6:7]
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v42, 0
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB2_24
	v_mad_u64_u32 v[42:43], s[34:35], v40, s19, v[4:5]
	v_ashrrev_i32_e32 v43, 31, v42
	v_lshl_add_u64 v[42:43], v[42:43], 2, s[16:17]
	global_load_dword v42, v[42:43], off
.LBB2_24:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v40, 1, v40
	v_cmp_gt_i32_e64 s[6:7], s10, v40
	s_waitcnt vmcnt(0)
	ds_write_b32 v14, v42 offset:4
	v_add_u32_e32 v42, s33, v1
	s_and_b64 s[38:39], s[2:3], s[6:7]
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB2_26
	v_mad_u64_u32 v[40:41], s[38:39], v42, s19, v[0:1]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[16:17]
	global_load_dword v41, v[40:41], off
.LBB2_26:
	s_or_b64 exec, exec, s[34:35]
	s_and_b64 s[34:35], s[4:5], s[6:7]
	v_mov_b32_e32 v40, 0
	s_waitcnt vmcnt(0)
	ds_write_b32 v15, v41
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB2_11
	v_mad_u64_u32 v[40:41], s[34:35], v42, s19, v[4:5]
	v_ashrrev_i32_e32 v41, 31, v40
	v_lshl_add_u64 v[40:41], v[40:41], 2, s[16:17]
	global_load_dword v40, v[40:41], off
	s_branch .LBB2_11
.LBB2_28:
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execz .LBB2_75
.LBB2_29:
	s_cmp_lt_i32 s10, 16
	s_cbranch_scc1 .LBB2_77
	s_ashr_i32 s0, s10, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s10, s0
	s_and_b32 s28, s0, -16
	s_or_b32 s0, s15, s14
	s_bitcmp1_b32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_lshr_b32 s2, s15, 31
	s_add_i32 s2, s15, s2
	s_ashr_i32 s30, s2, 1
	s_lshr_b32 s2, s14, 31
	s_add_i32 s2, s14, s2
	s_ashr_i32 s2, s2, 1
	v_add_u32_e32 v4, s2, v6
	s_or_b32 s2, s19, s18
	s_movk_i32 s4, 0x88
	s_bitcmp1_b32 s2, 0
	v_mov_b32_e32 v19, 0x440
	s_cselect_b64 s[2:3], -1, 0
	v_mad_u32_u24 v42, v9, s4, v19
	s_lshr_b32 s4, s19, 31
	s_add_i32 s4, s19, s4
	v_add_u32_e32 v0, s14, v8
	v_or_b32_e32 v14, 1, v3
	v_add_u32_e32 v11, v5, v3
	s_ashr_i32 s29, s4, 1
	s_lshr_b32 s4, s18, 31
	v_add_u32_e32 v1, 1, v0
	v_mul_lo_u32 v12, v11, s15
	s_add_i32 s4, s18, s4
	v_add_u32_e32 v5, v5, v14
	v_lshlrev_b32_e32 v10, 2, v8
	v_mul_u32_u24_e32 v13, 0x88, v9
	v_mul_u32_u24_e32 v15, 0x44, v14
	v_add_u32_e32 v16, v12, v1
	s_movk_i32 s5, 0x440
	s_ashr_i32 s31, s4, 1
	s_lshl_b32 s33, s26, 3
	s_add_i32 s27, s27, s18
	v_lshlrev_b32_e32 v9, 7, v9
	v_add_u32_e32 v36, v0, v12
	v_mul_lo_u32 v12, v5, s15
	v_add3_u32 v18, v15, v10, s5
	v_add_u32_e32 v20, s27, v8
	v_lshlrev_b32_e32 v8, 7, v6
	v_sub_u32_e32 v9, 0, v9
	v_lshlrev_b32_e32 v35, 2, v3
	v_add_u32_e32 v37, v0, v12
	v_add_u32_e32 v38, v12, v1
	v_mad_u64_u32 v[0:1], s[4:5], v11, s30, v[4:5]
	v_mad_u64_u32 v[4:5], s[4:5], v5, s30, v[4:5]
	s_add_i32 s33, s33, s31
	v_add_u32_e32 v17, v42, v10
	v_lshl_add_u32 v19, v6, 3, v19
	s_mov_b32 s26, 0
	v_add_u32_e32 v21, 0x484, v35
	v_add_u32_e32 v22, 0x4c8, v35
	v_add_u32_e32 v23, 0x50c, v35
	v_add_u32_e32 v24, 0x550, v35
	v_add_u32_e32 v25, 0x594, v35
	v_add_u32_e32 v26, 0x5d8, v35
	v_add_u32_e32 v27, 0x61c, v35
	v_add_u32_e32 v28, 0x660, v35
	v_add_u32_e32 v29, 0x6a4, v35
	v_add_u32_e32 v30, 0x6e8, v35
	v_add_u32_e32 v31, 0x72c, v35
	v_add_u32_e32 v32, 0x770, v35
	v_add_u32_e32 v33, 0x7b4, v35
	v_add_u32_e32 v34, 0x7f8, v35
	v_add_u32_e32 v35, 0x83c, v35
	v_add_u32_e32 v1, 1, v20
	v_add_u32_e32 v6, s33, v6
	v_mov_b32_e32 v12, 0
	v_add_u32_e32 v39, v10, v13
	v_add_u32_e32 v40, v10, v15
	v_add_u32_e32 v41, v10, v8
	v_add_u32_e32 v42, v42, v9
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v5, 0
	s_branch .LBB2_32
.LBB2_31:
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[8:9], v41 offset1:1
	ds_read2_b32 v[44:45], v41 offset0:17 offset1:18
	ds_read2_b32 v[46:47], v42 offset1:1
	s_add_i32 s26, s26, 16
	s_cmp_ge_i32 s26, s28
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v12, v8, v46
	v_fmac_f32_e32 v11, v44, v46
	v_fmac_f32_e32 v10, v8, v47
	v_fmac_f32_e32 v5, v44, v47
	ds_read2_b32 v[46:47], v42 offset0:17 offset1:34
	ds_read_b32 v8, v21 offset:4
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:2 offset1:3
	ds_read2_b32 v[44:45], v41 offset0:19 offset1:20
	ds_read_b32 v43, v22 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:51 offset1:68
	ds_read_b32 v8, v23 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:4 offset1:5
	ds_read2_b32 v[44:45], v41 offset0:21 offset1:22
	ds_read_b32 v43, v24 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:85 offset1:102
	ds_read_b32 v8, v25 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:6 offset1:7
	ds_read2_b32 v[44:45], v41 offset0:23 offset1:24
	ds_read_b32 v43, v26 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:119 offset1:136
	ds_read_b32 v8, v27 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:8 offset1:9
	ds_read2_b32 v[44:45], v41 offset0:25 offset1:26
	ds_read_b32 v43, v28 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:153 offset1:170
	ds_read_b32 v8, v29 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:10 offset1:11
	ds_read2_b32 v[44:45], v41 offset0:27 offset1:28
	ds_read_b32 v43, v30 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:187 offset1:204
	ds_read_b32 v8, v31 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:12 offset1:13
	ds_read2_b32 v[44:45], v41 offset0:29 offset1:30
	ds_read_b32 v43, v32 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	ds_read2_b32 v[46:47], v42 offset0:221 offset1:238
	ds_read_b32 v8, v33 offset:4
	v_fmac_f32_e32 v5, v44, v43
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v12, v9, v46
	v_fmac_f32_e32 v11, v45, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v9, v8
	v_fmac_f32_e32 v5, v45, v8
	ds_read2_b32 v[8:9], v41 offset0:14 offset1:15
	ds_read2_b32 v[44:45], v41 offset0:31 offset1:32
	ds_read_b32 v43, v34 offset:4
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v12, v8, v47
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v11, v44, v47
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v10, v8, v43
	v_fmac_f32_e32 v5, v44, v43
	ds_read_b32 v8, v42 offset:1020
	ds_read_b32 v43, v35 offset:4
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v12, v9, v8
	v_fmac_f32_e32 v11, v45, v8
	v_fmac_f32_e32 v10, v9, v43
	v_fmac_f32_e32 v5, v45, v43
	s_cbranch_scc1 .LBB2_78
.LBB2_32:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccz .LBB2_34
	v_add_u32_e32 v8, s26, v36
	v_add_u32_e32 v44, s26, v37
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v45, 31, v44
	v_add_u32_e32 v46, s26, v16
	v_add_u32_e32 v48, s26, v38
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[12:13]
	v_lshl_add_u64 v[44:45], v[44:45], 2, s[12:13]
	v_ashrrev_i32_e32 v47, 31, v46
	v_ashrrev_i32_e32 v49, 31, v48
	v_lshl_add_u64 v[46:47], v[46:47], 2, s[12:13]
	v_lshl_add_u64 v[48:49], v[48:49], 2, s[12:13]
	global_load_dword v8, v[8:9], off
	global_load_dword v9, v[44:45], off
	global_load_dword v43, v[46:47], off
	global_load_dword v44, v[48:49], off
	s_mov_b64 s[4:5], 0
	s_waitcnt vmcnt(3)
	ds_write_b32 v39, v8
	s_waitcnt vmcnt(2)
	ds_write_b32 v40, v9
	s_waitcnt vmcnt(1)
	ds_write_b32 v39, v43 offset:4
	s_waitcnt vmcnt(0)
	ds_write_b32 v40, v44 offset:4
.LBB2_34:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB2_36
	s_lshr_b32 s4, s26, 1
	v_add_u32_e32 v8, s4, v0
	v_add_u32_e32 v44, s4, v4
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v45, 31, v44
	v_lshl_add_u64 v[8:9], v[8:9], 3, s[12:13]
	v_lshl_add_u64 v[44:45], v[44:45], 3, s[12:13]
	global_load_dwordx2 v[8:9], v[8:9], off
	global_load_dwordx2 v[44:45], v[44:45], off
	s_waitcnt vmcnt(1)
	ds_write2_b32 v39, v8, v9 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v40, v44, v45 offset1:1
.LBB2_36:
	v_add_u32_e32 v9, s26, v3
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	v_add_u32_e32 v8, s26, v14
	s_cbranch_vccz .LBB2_38
	v_mul_lo_u32 v43, v9, s19
	v_add_u32_e32 v44, v20, v43
	v_add_u32_e32 v46, v43, v1
	v_mul_lo_u32 v43, v8, s19
	v_ashrrev_i32_e32 v45, 31, v44
	v_ashrrev_i32_e32 v47, 31, v46
	v_add_u32_e32 v48, v20, v43
	v_add_u32_e32 v50, v43, v1
	v_lshl_add_u64 v[44:45], v[44:45], 2, s[16:17]
	v_lshl_add_u64 v[46:47], v[46:47], 2, s[16:17]
	v_ashrrev_i32_e32 v49, 31, v48
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[48:49], v[48:49], 2, s[16:17]
	v_lshl_add_u64 v[50:51], v[50:51], 2, s[16:17]
	global_load_dword v43, v[44:45], off
	global_load_dword v44, v[46:47], off
	global_load_dword v45, v[48:49], off
	global_load_dword v46, v[50:51], off
	s_mov_b64 s[4:5], 0
	s_waitcnt vmcnt(2)
	ds_write2_b32 v17, v43, v44 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v18, v45, v46 offset1:1
.LBB2_38:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB2_31
	v_mad_u64_u32 v[44:45], s[4:5], v9, s29, v[6:7]
	v_mad_u64_u32 v[8:9], s[4:5], v8, s29, v[6:7]
	v_ashrrev_i32_e32 v45, 31, v44
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[44:45], v[44:45], 3, s[16:17]
	v_lshl_add_u64 v[8:9], v[8:9], 3, s[16:17]
	global_load_dwordx2 v[44:45], v[44:45], off
	global_load_dwordx2 v[8:9], v[8:9], off
	v_add_u32_e32 v43, v19, v13
	v_add_u32_e32 v46, v19, v15
	s_waitcnt vmcnt(1)
	ds_write2_b32 v43, v44, v45 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v46, v8, v9 offset1:1
	s_branch .LBB2_31
.LBB2_40:
	s_branch .LBB2_2
.LBB2_41:
	s_branch .LBB2_5
.LBB2_42:
	s_mov_b32 s33, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v13, 0
.LBB2_43:
	s_cmp_ge_i32 s33, s10
	v_or_b32_e32 v4, 1, v2
	s_cbranch_scc1 .LBB2_54
	v_mul_lo_u32 v0, v2, s15
	v_or_b32_e32 v15, 1, v7
	v_add_u32_e32 v0, s14, v0
	v_cmp_gt_i32_e32 vcc, s8, v2
	v_cmp_gt_i32_e64 s[0:1], s8, v4
	v_cmp_gt_i32_e64 s[2:3], s9, v7
	v_cmp_gt_i32_e64 s[4:5], s9, v15
	v_add_u32_e32 v1, s15, v0
	v_add_u32_e32 v14, s18, v7
	v_add_u32_e32 v15, s18, v15
	s_branch .LBB2_46
.LBB2_45:
	s_or_b64 exec, exec, s[6:7]
	s_add_i32 s33, s33, 1
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v13, v17, v19
	v_fmac_f32_e32 v12, v16, v19
	v_fmac_f32_e32 v11, v17, v18
	s_cmp_ge_i32 s33, s10
	v_fmac_f32_e32 v10, v16, v18
	s_cbranch_scc1 .LBB2_54
.LBB2_46:
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB2_48
	v_add_u32_e32 v18, s33, v0
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v17, v[18:19], off
.LBB2_48:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB2_50
	v_add_u32_e32 v18, s33, v1
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v16, v[18:19], off
.LBB2_50:
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v18, 0
	s_mul_i32 s34, s33, s19
	v_mov_b32_e32 v19, 0
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB2_52
	v_add_u32_e32 v20, s34, v14
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v19, v[20:21], off
.LBB2_52:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB2_45
	v_add_u32_e32 v20, s34, v15
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v18, v[20:21], off
	s_branch .LBB2_45
.LBB2_54:
	s_cmp_eq_u32 s22, 0
	v_cmp_le_i32_e64 s[2:3], s9, v7
	v_cmp_le_i32_e64 s[4:5], s8, v2
	s_cselect_b64 s[0:1], -1, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[34:35], s23, 0
	s_nor_b64 s[36:37], s[4:5], s[2:3]
	s_and_saveexec_b64 s[6:7], s[36:37]
	s_cbranch_execz .LBB2_59
	v_cndmask_b32_e64 v1, v2, v7, s[0:1]
	v_cndmask_b32_e64 v0, v7, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[36:37], v1, s21, v[0:1]
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[34:35]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccz .LBB2_107
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[24:25]
	global_load_dword v14, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v14, s23, v14
	v_fmac_f32_e32 v14, s11, v13
	s_cbranch_execnz .LBB2_58
.LBB2_57:
	v_mul_f32_e32 v14, s11, v13
.LBB2_58:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[24:25]
	global_store_dword v[0:1], v14, off
.LBB2_59:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_le_i32_e64 s[6:7], s8, v4
	v_cndmask_b32_e64 v0, 0, 1, s[34:35]
	s_nor_b64 s[36:37], s[6:7], s[2:3]
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	s_and_saveexec_b64 s[34:35], s[36:37]
	s_cbranch_execz .LBB2_64
	v_cndmask_b32_e64 v1, v4, v7, s[0:1]
	v_cndmask_b32_e64 v0, v7, v4, s[0:1]
	v_mad_u64_u32 v[0:1], s[36:37], v1, s21, v[0:1]
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB2_108
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[24:25]
	global_load_dword v13, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v13, s23, v13
	v_fmac_f32_e32 v13, s11, v12
	s_cbranch_execnz .LBB2_63
.LBB2_62:
	v_mul_f32_e32 v13, s11, v12
.LBB2_63:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[24:25]
	global_store_dword v[0:1], v13, off
.LBB2_64:
	s_or_b64 exec, exec, s[34:35]
	v_or_b32_e32 v12, 1, v7
	v_cmp_le_i32_e64 s[8:9], s9, v12
	s_nor_b64 s[34:35], s[4:5], s[8:9]
	s_and_saveexec_b64 s[4:5], s[34:35]
	s_cbranch_execz .LBB2_69
	v_cndmask_b32_e64 v1, v2, v12, s[0:1]
	v_cndmask_b32_e64 v0, v12, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[34:35], v1, s21, v[0:1]
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB2_109
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[24:25]
	global_load_dword v13, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v13, s23, v13
	v_fmac_f32_e32 v13, s11, v11
	s_cbranch_execnz .LBB2_68
.LBB2_67:
	v_mul_f32_e32 v13, s11, v11
.LBB2_68:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[24:25]
	global_store_dword v[0:1], v13, off
.LBB2_69:
	s_or_b64 exec, exec, s[4:5]
	s_nor_b64 s[4:5], s[6:7], s[8:9]
	s_mov_b64 s[6:7], 0
	s_and_saveexec_b64 s[8:9], s[4:5]
	s_xor_b64 s[4:5], exec, s[8:9]
	s_cbranch_execz .LBB2_74
	v_cndmask_b32_e64 v1, v4, v12, s[0:1]
	v_cndmask_b32_e64 v0, v12, v4, s[0:1]
	v_mad_u64_u32 v[0:1], s[0:1], v1, s21, v[0:1]
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB2_110
	v_lshl_add_u64 v[12:13], v[0:1], 2, s[24:25]
	global_load_dword v4, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v11, s23, v4
	v_fmac_f32_e32 v11, s11, v10
	s_cbranch_execnz .LBB2_73
.LBB2_72:
	v_mul_f32_e32 v11, s11, v10
.LBB2_73:
	s_mov_b64 s[6:7], exec
.LBB2_74:
	s_or_b64 exec, exec, s[4:5]
	s_and_b64 s[6:7], s[6:7], exec
	s_andn2_b64 s[28:29], s[28:29], exec
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execnz .LBB2_29
.LBB2_75:
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB2_102
.LBB2_76:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[24:25]
	global_store_dword v[0:1], v11, off
	s_endpgm
.LBB2_77:
	s_mov_b32 s26, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
.LBB2_78:
	s_cmp_ge_i32 s26, s10
	s_cbranch_scc1 .LBB2_81
	v_mul_lo_u32 v0, v2, s15
	v_add_u32_e32 v0, s14, v0
	v_add_u32_e32 v1, s18, v7
	v_add_u32_e32 v3, s15, v0
	v_add_u32_e32 v4, 1, v1
.LBB2_80:
	v_add_u32_e32 v8, s26, v0
	s_mul_i32 s0, s26, s19
	v_add_u32_e32 v14, s26, v3
	v_ashrrev_i32_e32 v9, 31, v8
	v_add_u32_e32 v16, s0, v1
	v_ashrrev_i32_e32 v15, 31, v14
	v_add_u32_e32 v18, s0, v4
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[12:13]
	v_ashrrev_i32_e32 v17, 31, v16
	v_lshl_add_u64 v[14:15], v[14:15], 2, s[12:13]
	v_ashrrev_i32_e32 v19, 31, v18
	global_load_dword v6, v[8:9], off
	global_load_dword v13, v[14:15], off
	v_lshl_add_u64 v[8:9], v[16:17], 2, s[16:17]
	v_lshl_add_u64 v[14:15], v[18:19], 2, s[16:17]
	global_load_dword v8, v[8:9], off
	global_load_dword v9, v[14:15], off
	s_add_i32 s26, s26, 1
	s_cmp_lt_i32 s26, s10
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v12, v6, v8
	v_fmac_f32_e32 v11, v13, v8
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v10, v6, v9
	v_fmac_f32_e32 v5, v13, v9
	s_cbranch_scc1 .LBB2_80
.LBB2_81:
	s_cmp_eq_u32 s22, 0
	v_mad_u64_u32 v[0:1], s[0:1], v7, s21, v[2:3]
	v_mul_lo_u32 v4, v2, s21
	v_add_u32_e32 v1, v4, v7
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v2, v1, v0, s[0:1]
	s_cmp_lg_u32 s22, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[12:13], s23, 0
	v_add_u32_e32 v2, s20, v2
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccz .LBB2_103
	v_lshl_add_u64 v[8:9], v[2:3], 2, s[24:25]
	global_load_dword v6, v[8:9], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s23, v6
	v_fmac_f32_e32 v6, s11, v12
	s_cbranch_execnz .LBB2_84
.LBB2_83:
	v_mul_f32_e32 v6, s11, v12
.LBB2_84:
	v_cndmask_b32_e64 v8, 0, 1, s[4:5]
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[24:25]
	v_cmp_ne_u32_e64 s[2:3], 1, v8
	s_andn2_b64 vcc, exec, s[4:5]
	global_store_dword v[2:3], v6, off
	s_cbranch_vccnz .LBB2_86
	v_add_u32_e32 v1, s21, v1
	s_cbranch_execz .LBB2_87
	s_branch .LBB2_88
.LBB2_86:
.LBB2_87:
	v_or_b32_e32 v1, 1, v0
.LBB2_88:
	v_cndmask_b32_e64 v2, 0, 1, s[12:13]
	v_cmp_ne_u32_e64 s[4:5], 1, v2
	v_add_u32_e32 v2, s20, v1
	s_andn2_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccnz .LBB2_104
	v_lshl_add_u64 v[8:9], v[2:3], 2, s[24:25]
	global_load_dword v1, v[8:9], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, s23, v1
	v_fmac_f32_e32 v1, s11, v11
	s_cbranch_execnz .LBB2_91
.LBB2_90:
	v_mul_f32_e32 v1, s11, v11
.LBB2_91:
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[24:25]
	global_store_dword v[2:3], v1, off
	v_or_b32_e32 v3, 1, v7
	v_add_u32_e32 v2, s21, v0
	v_add_u32_e32 v0, v4, v3
	v_cndmask_b32_e64 v0, v0, v2, s[0:1]
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB2_105
	v_lshl_add_u64 v[6:7], v[0:1], 2, s[24:25]
	global_load_dword v6, v[6:7], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s23, v6
	v_fmac_f32_e32 v6, s11, v10
	s_cbranch_execnz .LBB2_94
.LBB2_93:
	v_mul_f32_e32 v6, s11, v10
.LBB2_94:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[24:25]
	s_and_b64 vcc, exec, s[2:3]
	global_store_dword v[0:1], v6, off
	s_cbranch_vccnz .LBB2_96
	v_add3_u32 v0, v4, s21, v3
	s_cbranch_execz .LBB2_97
	s_branch .LBB2_98
.LBB2_96:
.LBB2_97:
	v_add_u32_e32 v0, 1, v2
.LBB2_98:
	v_add_u32_e32 v0, s20, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB2_106
	v_lshl_add_u64 v[2:3], v[0:1], 2, s[24:25]
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v11, s23, v2
	v_fmac_f32_e32 v11, s11, v5
	s_cbranch_execnz .LBB2_101
.LBB2_100:
	v_mul_f32_e32 v11, s11, v5
.LBB2_101:
	s_or_b64 s[6:7], s[6:7], exec
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execnz .LBB2_76
.LBB2_102:
	s_endpgm
.LBB2_103:
	s_branch .LBB2_83
.LBB2_104:
	s_branch .LBB2_90
.LBB2_105:
	s_branch .LBB2_93
.LBB2_106:
	s_branch .LBB2_100
.LBB2_107:
	s_branch .LBB2_57
.LBB2_108:
	s_branch .LBB2_62
.LBB2_109:
	s_branch .LBB2_67
.LBB2_110:
	s_branch .LBB2_72
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel XgemmDirectTN
		.amdhsa_group_segment_fixed_size 2176
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 52
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 52
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
	.text
.Lfunc_end2:
	.size	XgemmDirectTN, .Lfunc_end2-XgemmDirectTN

	.set XgemmDirectTN.num_vgpr, 52
	.set XgemmDirectTN.num_agpr, 0
	.set XgemmDirectTN.numbered_sgpr, 40
	.set XgemmDirectTN.private_seg_size, 0
	.set XgemmDirectTN.uses_vcc, 1
	.set XgemmDirectTN.uses_flat_scratch, 0
	.set XgemmDirectTN.has_dyn_sized_stack, 0
	.set XgemmDirectTN.has_recursion, 0
	.set XgemmDirectTN.has_indirect_call, 0
	.protected	XgemmDirectTT
	.globl	XgemmDirectTT
	.p2align	8
	.type	XgemmDirectTT,@function
XgemmDirectTT:
	s_load_dwordx2 s[4:5], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s4, s3
	s_add_i32 s8, s3, s2
	s_ashr_i32 s9, s8, 31
	s_mov_b32 s2, 0
	s_mov_b32 s3, s9
	s_cmp_lg_u64 s[2:3], 0
	s_cbranch_scc0 .LBB3_40
	v_cvt_f32_u32_e32 v1, s5
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s6, 0, s5
	s_subb_u32 s7, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s12, s6, s10
	s_mul_hi_u32 s14, s6, s11
	s_mul_i32 s13, s7, s11
	s_add_i32 s12, s14, s12
	s_add_i32 s12, s12, s13
	s_mul_i32 s15, s6, s11
	s_mul_hi_u32 s13, s11, s12
	s_mul_i32 s14, s11, s12
	s_mul_hi_u32 s11, s11, s15
	s_add_u32 s11, s11, s14
	s_addc_u32 s13, 0, s13
	s_mul_hi_u32 s16, s10, s15
	s_mul_i32 s15, s10, s15
	s_add_u32 s11, s11, s15
	s_mul_hi_u32 s14, s10, s12
	s_addc_u32 s11, s13, s16
	s_addc_u32 s13, s14, 0
	s_mul_i32 s12, s10, s12
	s_add_u32 s11, s11, s12
	s_addc_u32 s12, 0, s13
	v_add_co_u32_e32 v1, vcc, s11, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s10, s10, s12
	v_readfirstlane_b32 s12, v1
	s_mul_i32 s11, s6, s10
	s_mul_hi_u32 s13, s6, s12
	s_add_i32 s11, s13, s11
	s_mul_i32 s7, s7, s12
	s_add_i32 s11, s11, s7
	s_mul_i32 s6, s6, s12
	s_mul_hi_u32 s13, s10, s6
	s_mul_i32 s14, s10, s6
	s_mul_i32 s16, s12, s11
	s_mul_hi_u32 s6, s12, s6
	s_mul_hi_u32 s15, s12, s11
	s_add_u32 s6, s6, s16
	s_addc_u32 s12, 0, s15
	s_add_u32 s6, s6, s14
	s_mul_hi_u32 s7, s10, s11
	s_addc_u32 s6, s12, s13
	s_addc_u32 s7, s7, 0
	s_mul_i32 s11, s10, s11
	s_add_u32 s6, s6, s11
	s_addc_u32 s7, 0, s7
	v_add_co_u32_e32 v1, vcc, s6, v1
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s6, s10, s7
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s10, s8, s6
	s_mul_hi_u32 s12, s8, s11
	s_mul_hi_u32 s7, s8, s6
	s_add_u32 s10, s12, s10
	s_addc_u32 s7, 0, s7
	s_mul_hi_u32 s13, s9, s11
	s_mul_i32 s11, s9, s11
	s_add_u32 s10, s10, s11
	s_mul_hi_u32 s12, s9, s6
	s_addc_u32 s7, s7, s13
	s_addc_u32 s10, s12, 0
	s_mul_i32 s6, s9, s6
	s_add_u32 s6, s7, s6
	s_addc_u32 s7, 0, s10
	s_add_u32 s10, s6, 1
	s_addc_u32 s11, s7, 0
	s_add_u32 s12, s6, 2
	s_mul_i32 s14, s5, s7
	s_mul_hi_u32 s15, s5, s6
	s_addc_u32 s13, s7, 0
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s5, s6
	v_mov_b32_e32 v1, s14
	v_sub_co_u32_e32 v1, vcc, s8, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s14, s9, s15
	v_subrev_co_u32_e32 v2, vcc, s5, v1
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s15, s14, 0
	v_readfirstlane_b32 s16, v2
	s_cmp_ge_u32 s16, s5
	s_cselect_b32 s16, -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b32 s15, s16, -1
	s_cmp_lg_u32 s15, 0
	s_cselect_b32 s10, s12, s10
	v_readfirstlane_b32 s12, v1
	s_cselect_b32 s11, s13, s11
	s_cmp_ge_u32 s12, s5
	s_cselect_b32 s12, -1, 0
	s_cmp_eq_u32 s14, 0
	s_cselect_b32 s12, s12, -1
	s_cmp_lg_u32 s12, 0
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s6, s10, s6
	s_cbranch_execnz .LBB3_3
.LBB3_2:
	v_cvt_f32_u32_e32 v1, s5
	s_sub_i32 s2, 0, s5
	s_mov_b32 s7, 0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s3, v1
	s_mul_i32 s2, s2, s3
	s_mul_hi_u32 s2, s3, s2
	s_add_i32 s3, s3, s2
	s_mul_hi_u32 s2, s8, s3
	s_mul_i32 s6, s2, s5
	s_sub_i32 s6, s8, s6
	s_add_i32 s3, s2, 1
	s_sub_i32 s10, s6, s5
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s2, s3, s2
	s_cselect_b32 s6, s10, s6
	s_add_i32 s3, s2, 1
	s_cmp_ge_u32 s6, s5
	s_cselect_b32 s6, s3, s2
.LBB3_3:
	s_mul_i32 s2, s7, s5
	s_mul_hi_u32 s3, s6, s5
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s6, s5
	s_sub_u32 s2, s8, s2
	s_subb_u32 s3, s9, s3
	s_bfe_i64 s[8:9], s[2:3], 0x200000
	s_add_u32 s3, s8, s6
	s_addc_u32 s9, s9, s7
	s_mov_b32 s8, 0
	s_cmp_lg_u64 s[8:9], 0
	s_cbranch_scc0 .LBB3_41
	v_cvt_f32_u32_e32 v1, s4
	v_mov_b32_e32 v2, 0x4f800000
	s_sub_u32 s5, 0, s4
	s_subb_u32 s8, 0, 0
	v_fmac_f32_e32 v1, 0, v2
	v_rcp_f32_e32 v1, v1
	v_mov_b32_e32 v5, 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v6, v2
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s5, v6
	v_mul_hi_u32 v4, s5, v1
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v2, v4, v2
	v_mul_lo_u32 v7, s5, v1
	v_add_u32_e32 v8, v2, v3
	v_mul_hi_u32 v3, v1, v8
	v_mul_lo_u32 v2, v1, v8
	v_mul_hi_u32 v4, v1, v7
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, v6, v7
	v_mul_lo_u32 v7, v6, v7
	v_add_co_u32_e32 v2, vcc, v2, v7
	v_mul_hi_u32 v9, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, v6, v8
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v9, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_lo_u32 v4, s5, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_lo_u32 v2, s5, v6
	v_mul_hi_u32 v3, s5, v1
	v_add_u32_e32 v2, v3, v2
	v_mul_lo_u32 v3, s8, v1
	v_add_u32_e32 v7, v2, v3
	v_mul_hi_u32 v9, v6, v4
	v_mul_lo_u32 v10, v6, v4
	v_mul_hi_u32 v3, v1, v7
	v_mul_lo_u32 v2, v1, v7
	v_mul_hi_u32 v4, v1, v4
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v2, vcc, v2, v10
	v_mul_hi_u32 v8, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v9, vcc
	v_mul_lo_u32 v2, v6, v7
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v8, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_add_co_u32_e32 v1, vcc, v1, v2
	v_mul_hi_u32 v4, s3, v1
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v6, v3, vcc
	v_mul_hi_u32 v3, s3, v6
	v_mul_lo_u32 v2, s3, v6
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_hi_u32 v4, s9, v1
	v_mul_lo_u32 v1, s9, v1
	v_add_co_u32_e32 v1, vcc, v2, v1
	v_mul_hi_u32 v7, s9, v6
	s_nop 0
	v_addc_co_u32_e32 v4, vcc, v3, v4, vcc
	v_mul_lo_u32 v2, s9, v6
	s_nop 0
	v_addc_co_u32_e32 v3, vcc, 0, v7, vcc
	v_lshl_add_u64 v[2:3], v[4:5], 0, v[2:3]
	v_mul_lo_u32 v1, s4, v3
	v_mul_hi_u32 v3, s4, v2
	v_mul_lo_u32 v2, s4, v2
	v_add_u32_e32 v1, v3, v1
	v_mov_b32_e32 v3, s9
	v_sub_co_u32_e32 v2, vcc, s3, v2
	s_nop 1
	v_subb_co_u32_e32 v1, vcc, v3, v1, vcc
	v_subrev_co_u32_e32 v3, vcc, s4, v2
	s_nop 1
	v_subbrev_co_u32_e32 v4, vcc, 0, v1, vcc
	v_subrev_co_u32_e32 v5, vcc, s4, v3
	v_cmp_le_u32_e32 vcc, s4, v3
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v4, -1, v6, vcc
	v_cmp_ne_u32_e32 vcc, 0, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_cmp_le_u32_e32 vcc, s4, v2
	s_nop 1
	v_cndmask_b32_e64 v4, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, -1, v4, vcc
	v_cmp_ne_u32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v2, v2, v3, vcc
	s_cbranch_execnz .LBB3_6
.LBB3_5:
	v_cvt_f32_u32_e32 v1, s4
	s_sub_i32 s5, 0, s4
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s5, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_mul_hi_u32 v1, s3, v1
	v_mul_lo_u32 v1, v1, s4
	v_sub_u32_e32 v1, s3, v1
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_subrev_u32_e32 v2, s4, v1
	v_cmp_le_u32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e32 v2, v1, v2, vcc
.LBB3_6:
	s_load_dwordx8 s[12:19], s[0:1], 0x18
	s_load_dwordx4 s[20:23], s[0:1], 0x0
	s_load_dwordx2 s[10:11], s[0:1], 0x38
	s_load_dwordx4 s[24:27], s[0:1], 0x40
	s_lshl_b32 s33, s2, 4
	v_and_b32_e32 v4, 0x3ff, v0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s2, s20, 31
	s_lshr_b32 s2, s2, 28
	v_lshlrev_b32_e32 v3, 4, v2
	v_lshlrev_b32_e32 v5, 1, v4
	v_bfe_u32 v6, v0, 10, 10
	s_add_i32 s2, s20, s2
	v_or_b32_e32 v2, v3, v5
	v_lshlrev_b32_e32 v7, 1, v6
	s_and_b32 s4, s2, -16
	v_or_b32_e32 v10, s33, v7
	v_cmp_le_i32_e64 s[2:3], s4, v2
	v_cmp_gt_i32_e32 vcc, s4, v2
	s_mov_b64 s[6:7], 0
	s_mov_b64 s[28:29], 0
	s_and_saveexec_b64 s[4:5], vcc
	s_ashr_i32 s8, s21, 31
	s_lshr_b32 s8, s8, 28
	s_add_i32 s8, s21, s8
	s_and_b32 s8, s8, -16
	v_cmp_le_i32_e32 vcc, s8, v10
	s_andn2_b64 s[2:3], s[2:3], exec
	s_and_b64 s[8:9], vcc, exec
	s_mov_b64 s[28:29], exec
	s_or_b64 s[2:3], s[2:3], s[8:9]
	s_or_b64 exec, exec, s[4:5]
	s_load_dword s27, s[0:1], 0x10
	s_and_saveexec_b64 s[30:31], s[2:3]
	s_cbranch_execz .LBB3_28
	s_cmp_lt_i32 s22, 16
	v_cmp_gt_i32_e32 vcc, s21, v10
	s_cbranch_scc1 .LBB3_42
	s_ashr_i32 s0, s22, 31
	s_lshr_b32 s0, s0, 28
	v_or_b32_e32 v12, 1, v7
	s_add_i32 s0, s22, s0
	v_add_u32_e32 v16, v3, v7
	v_add_u32_e32 v17, v3, v12
	s_and_b32 s37, s0, -16
	v_add_u32_e32 v9, s14, v5
	s_movk_i32 s0, 0x88
	s_movk_i32 s1, 0x44
	v_or_b32_e32 v15, 1, v5
	v_mov_b32_e32 v13, 0x440
	v_mul_lo_u32 v18, v16, s15
	v_mul_lo_u32 v20, v17, s15
	v_add_u32_e32 v8, s18, v5
	v_mul_u32_u24_e32 v25, 0x44, v12
	v_add_u32_e32 v19, s14, v15
	v_mad_u32_u24 v0, v6, s0, v13
	v_add_u32_e32 v23, s18, v15
	v_mad_u32_u24 v13, v12, s1, v13
	v_cmp_gt_i32_e64 s[0:1], s20, v16
	v_cmp_gt_i32_e64 s[2:3], s20, v17
	v_add_u32_e32 v12, s33, v12
	v_add_u32_e32 v16, v18, v9
	v_add_u32_e32 v17, v20, v9
	v_mul_lo_u32 v9, v10, s19
	v_lshlrev_b32_e32 v11, 2, v5
	v_mul_u32_u24_e32 v24, 0x88, v6
	v_lshlrev_b32_e32 v26, 7, v4
	v_add_u32_e32 v18, v18, v19
	v_add_u32_e32 v19, v20, v19
	v_add_u32_e32 v20, v9, v8
	v_add_u32_e32 v21, v9, v23
	v_mul_lo_u32 v9, v12, s19
	v_add_u32_e32 v1, v0, v11
	v_add_u32_e32 v14, v13, v11
	v_mul_u32_u24_e32 v15, 0x44, v15
	v_cmp_gt_i32_e64 s[4:5], s21, v12
	v_add_u32_e32 v22, v9, v8
	v_add_u32_e32 v23, v9, v23
	v_mov_b32_e32 v12, 0
	s_mov_b32 s36, 0
	v_add_u32_e32 v24, v11, v24
	v_add_u32_e32 v25, v11, v25
	v_add_u32_e32 v26, v11, v26
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v8, 0
	s_branch .LBB3_12
.LBB3_11:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v14, v27 offset:4
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[28:29], v15 offset1:1
	ds_read2_b32 v[30:31], v0 offset1:1
	ds_read2_b32 v[32:33], v13 offset1:1
	ds_read2_b32 v[34:35], v26 offset1:1
	ds_read2_b32 v[36:37], v26 offset0:2 offset1:3
	ds_read2_b32 v[38:39], v26 offset0:4 offset1:5
	ds_read2_b32 v[40:41], v26 offset0:6 offset1:7
	ds_read2_b32 v[42:43], v0 offset0:2 offset1:3
	ds_read2_b32 v[44:45], v0 offset0:4 offset1:5
	ds_read2_b32 v[46:47], v0 offset0:6 offset1:7
	ds_read2_b32 v[48:49], v15 offset0:2 offset1:3
	ds_read2_b32 v[50:51], v15 offset0:4 offset1:5
	ds_read2_b32 v[52:53], v15 offset0:6 offset1:7
	ds_read2_b32 v[54:55], v13 offset0:2 offset1:3
	ds_read2_b32 v[56:57], v13 offset0:4 offset1:5
	ds_read2_b32 v[58:59], v13 offset0:6 offset1:7
	s_waitcnt lgkmcnt(12)
	v_fmac_f32_e32 v12, v34, v30
	v_fmac_f32_e32 v11, v28, v30
	v_fmac_f32_e32 v9, v34, v32
	v_fmac_f32_e32 v8, v28, v32
	v_fmac_f32_e32 v12, v35, v31
	v_fmac_f32_e32 v11, v29, v31
	v_fmac_f32_e32 v9, v35, v33
	v_fmac_f32_e32 v8, v29, v33
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v12, v36, v42
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v11, v48, v42
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v9, v36, v54
	v_fmac_f32_e32 v8, v48, v54
	v_fmac_f32_e32 v12, v37, v43
	v_fmac_f32_e32 v11, v49, v43
	v_fmac_f32_e32 v9, v37, v55
	v_fmac_f32_e32 v8, v49, v55
	v_fmac_f32_e32 v12, v38, v44
	v_fmac_f32_e32 v11, v50, v44
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v56
	v_fmac_f32_e32 v8, v50, v56
	v_fmac_f32_e32 v12, v39, v45
	v_fmac_f32_e32 v11, v51, v45
	v_fmac_f32_e32 v9, v39, v57
	v_fmac_f32_e32 v8, v51, v57
	v_fmac_f32_e32 v12, v40, v46
	v_fmac_f32_e32 v11, v52, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v9, v40, v58
	v_fmac_f32_e32 v8, v52, v58
	v_fmac_f32_e32 v12, v41, v47
	v_fmac_f32_e32 v11, v53, v47
	v_fmac_f32_e32 v9, v41, v59
	v_fmac_f32_e32 v8, v53, v59
	ds_read2_b32 v[28:29], v15 offset0:8 offset1:9
	ds_read2_b32 v[30:31], v0 offset0:8 offset1:9
	ds_read2_b32 v[32:33], v13 offset0:8 offset1:9
	ds_read2_b32 v[34:35], v26 offset0:8 offset1:9
	ds_read2_b32 v[36:37], v26 offset0:10 offset1:11
	ds_read2_b32 v[38:39], v26 offset0:12 offset1:13
	ds_read2_b32 v[40:41], v26 offset0:14 offset1:15
	ds_read2_b32 v[42:43], v0 offset0:10 offset1:11
	ds_read2_b32 v[44:45], v0 offset0:12 offset1:13
	ds_read2_b32 v[46:47], v0 offset0:14 offset1:15
	ds_read2_b32 v[48:49], v15 offset0:10 offset1:11
	ds_read2_b32 v[50:51], v15 offset0:12 offset1:13
	ds_read2_b32 v[52:53], v15 offset0:14 offset1:15
	ds_read2_b32 v[54:55], v13 offset0:10 offset1:11
	ds_read2_b32 v[56:57], v13 offset0:12 offset1:13
	ds_read2_b32 v[58:59], v13 offset0:14 offset1:15
	s_waitcnt lgkmcnt(12)
	v_fmac_f32_e32 v12, v34, v30
	v_fmac_f32_e32 v11, v28, v30
	v_fmac_f32_e32 v9, v34, v32
	v_fmac_f32_e32 v8, v28, v32
	v_fmac_f32_e32 v12, v35, v31
	v_fmac_f32_e32 v11, v29, v31
	v_fmac_f32_e32 v9, v35, v33
	v_fmac_f32_e32 v8, v29, v33
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v12, v36, v42
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v11, v48, v42
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v9, v36, v54
	v_fmac_f32_e32 v8, v48, v54
	v_fmac_f32_e32 v12, v37, v43
	v_fmac_f32_e32 v11, v49, v43
	v_fmac_f32_e32 v9, v37, v55
	v_fmac_f32_e32 v8, v49, v55
	v_fmac_f32_e32 v12, v38, v44
	v_fmac_f32_e32 v11, v50, v44
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v9, v38, v56
	v_fmac_f32_e32 v8, v50, v56
	v_fmac_f32_e32 v12, v39, v45
	v_fmac_f32_e32 v11, v51, v45
	v_fmac_f32_e32 v9, v39, v57
	v_fmac_f32_e32 v8, v51, v57
	v_fmac_f32_e32 v12, v40, v46
	v_fmac_f32_e32 v11, v52, v46
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v9, v40, v58
	v_fmac_f32_e32 v8, v52, v58
	s_add_i32 s36, s36, 16
	v_fmac_f32_e32 v12, v41, v47
	v_fmac_f32_e32 v11, v53, v47
	v_fmac_f32_e32 v9, v41, v59
	v_fmac_f32_e32 v8, v53, v59
	s_cmp_ge_i32 s36, s37
	s_cbranch_scc1 .LBB3_43
.LBB3_12:
	v_add_u32_e32 v27, s36, v5
	v_cmp_gt_i32_e64 s[6:7], s22, v27
	s_and_b64 s[34:35], s[6:7], s[0:1]
	v_mov_b32_e32 v28, 0
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB3_14
	v_add_u32_e32 v28, s36, v16
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v28, v[28:29], off
.LBB3_14:
	s_or_b64 exec, exec, s[8:9]
	s_waitcnt vmcnt(0)
	ds_write_b32 v24, v28
	s_and_b64 s[34:35], s[6:7], s[2:3]
	v_mov_b32_e32 v28, 0
	v_mov_b32_e32 v29, 0
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB3_16
	v_add_u32_e32 v30, s36, v17
	v_ashrrev_i32_e32 v31, 31, v30
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[12:13]
	global_load_dword v29, v[30:31], off
.LBB3_16:
	s_or_b64 exec, exec, s[8:9]
	v_add_u32_e32 v27, 1, v27
	v_cmp_gt_i32_e64 s[8:9], s22, v27
	s_and_b64 s[38:39], s[8:9], s[0:1]
	s_waitcnt vmcnt(0)
	ds_write_b32 v25, v29
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB3_18
	v_add_u32_e32 v28, s36, v18
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v28, v[28:29], off
.LBB3_18:
	s_or_b64 exec, exec, s[34:35]
	s_waitcnt vmcnt(0)
	ds_write_b32 v24, v28 offset:4
	s_and_b64 s[38:39], s[8:9], s[2:3]
	v_mov_b32_e32 v27, 0
	v_mov_b32_e32 v28, 0
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB3_20
	v_add_u32_e32 v28, s36, v19
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[12:13]
	global_load_dword v28, v[28:29], off
.LBB3_20:
	s_or_b64 exec, exec, s[34:35]
	s_and_b64 s[38:39], s[6:7], vcc
	s_waitcnt vmcnt(0)
	ds_write_b32 v25, v28 offset:4
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB3_22
	v_add_u32_e32 v28, s36, v20
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v27, v[28:29], off
.LBB3_22:
	s_or_b64 exec, exec, s[34:35]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v27
	s_and_b64 s[38:39], s[8:9], vcc
	v_mov_b32_e32 v27, 0
	v_mov_b32_e32 v28, 0
	s_and_saveexec_b64 s[34:35], s[38:39]
	s_cbranch_execz .LBB3_24
	v_add_u32_e32 v28, s36, v21
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v28, v[28:29], off
.LBB3_24:
	s_or_b64 exec, exec, s[34:35]
	s_and_b64 s[34:35], s[6:7], s[4:5]
	s_waitcnt vmcnt(0)
	ds_write_b32 v1, v28 offset:4
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB3_26
	v_add_u32_e32 v28, s36, v22
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v27, v[28:29], off
.LBB3_26:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt vmcnt(0)
	ds_write_b32 v14, v27
	s_and_b64 s[8:9], s[8:9], s[4:5]
	v_mov_b32_e32 v27, 0
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB3_11
	v_add_u32_e32 v28, s36, v23
	v_ashrrev_i32_e32 v29, 31, v28
	v_lshl_add_u64 v[28:29], v[28:29], 2, s[16:17]
	global_load_dword v27, v[28:29], off
	s_branch .LBB3_11
.LBB3_28:
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execz .LBB3_75
.LBB3_29:
	s_cmp_lt_i32 s22, 16
	v_mul_lo_u32 v12, v10, s19
	s_cbranch_scc1 .LBB3_77
	s_ashr_i32 s0, s22, 31
	s_lshr_b32 s0, s0, 28
	s_add_i32 s0, s22, s0
	s_and_b32 s21, s0, -16
	s_or_b32 s0, s15, s14
	s_bitcmp1_b32 s0, 0
	s_cselect_b64 s[0:1], -1, 0
	s_lshr_b32 s2, s15, 31
	s_add_i32 s2, s15, s2
	s_ashr_i32 s20, s2, 1
	s_lshr_b32 s2, s14, 31
	s_add_i32 s2, s14, s2
	s_ashr_i32 s2, s2, 1
	v_add_u32_e32 v8, s2, v4
	s_or_b32 s2, s19, s18
	v_add_u32_e32 v0, s14, v5
	v_lshlrev_b32_e32 v28, 2, v5
	s_movk_i32 s4, 0x88
	s_bitcmp1_b32 s2, 0
	v_add_u32_e32 v25, s18, v5
	v_mov_b32_e32 v5, 0x440
	s_cselect_b64 s[2:3], -1, 0
	v_mad_u32_u24 v16, v6, s4, v5
	s_lshr_b32 s4, s19, 31
	s_add_i32 s4, s19, s4
	s_ashr_i32 s28, s4, 1
	s_lshr_b32 s4, s18, 31
	s_add_i32 s4, s18, s4
	v_or_b32_e32 v9, 1, v7
	s_ashr_i32 s4, s4, 1
	s_movk_i32 s5, 0x44
	v_add_u32_e32 v26, s4, v4
	v_lshl_add_u32 v21, v4, 3, v5
	v_lshlrev_b32_e32 v29, 7, v4
	v_add_u32_e32 v4, v3, v9
	v_add_u32_e32 v1, 1, v0
	v_mad_u32_u24 v19, v9, s5, v5
	v_mul_lo_u32 v5, v4, s15
	v_add_u32_e32 v7, v3, v7
	v_add_u32_e32 v3, v0, v5
	v_add_u32_e32 v24, v5, v1
	v_mad_u64_u32 v[4:5], s[4:5], v4, s20, v[8:9]
	v_mul_lo_u32 v11, v7, s15
	v_add_u32_e32 v5, s33, v9
	v_mul_u32_u24_e32 v13, 0x88, v6
	v_add_u32_e32 v15, v11, v1
	v_add_u32_e32 v6, 1, v25
	v_add_u32_e32 v22, v0, v11
	v_mad_u64_u32 v[0:1], s[4:5], v7, s20, v[8:9]
	v_mul_lo_u32 v7, v5, s19
	v_mul_u32_u24_e32 v14, 0x44, v9
	v_add_u32_e32 v17, v12, v25
	v_add_u32_e32 v23, v6, v12
	v_add_u32_e32 v1, v7, v25
	v_add_u32_e32 v25, v6, v7
	v_mad_u64_u32 v[6:7], s[4:5], v10, s28, v[26:27]
	v_mad_u64_u32 v[8:9], s[4:5], v5, s28, v[26:27]
	v_add_u32_e32 v18, v16, v28
	v_add_u32_e32 v20, v19, v28
	v_mov_b32_e32 v11, 0
	s_mov_b32 s20, 0
	v_add_u32_e32 v26, v28, v13
	v_add_u32_e32 v27, v28, v14
	v_add_u32_e32 v28, v28, v29
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v5, 0
	s_branch .LBB3_32
.LBB3_31:
	s_waitcnt lgkmcnt(0)
	ds_read2_b32 v[30:31], v28 offset0:17 offset1:18
	ds_read2_b32 v[32:33], v16 offset1:1
	ds_read2_b32 v[34:35], v19 offset1:1
	ds_read2_b32 v[36:37], v28 offset1:1
	ds_read2_b32 v[38:39], v28 offset0:2 offset1:3
	ds_read2_b32 v[40:41], v28 offset0:4 offset1:5
	ds_read2_b32 v[42:43], v28 offset0:6 offset1:7
	ds_read2_b32 v[44:45], v16 offset0:2 offset1:3
	ds_read2_b32 v[46:47], v16 offset0:4 offset1:5
	ds_read2_b32 v[48:49], v16 offset0:6 offset1:7
	ds_read2_b32 v[50:51], v28 offset0:19 offset1:20
	ds_read2_b32 v[52:53], v28 offset0:21 offset1:22
	ds_read2_b32 v[54:55], v28 offset0:23 offset1:24
	ds_read2_b32 v[56:57], v19 offset0:2 offset1:3
	ds_read2_b32 v[58:59], v19 offset0:4 offset1:5
	ds_read2_b32 v[60:61], v19 offset0:6 offset1:7
	s_waitcnt lgkmcnt(12)
	v_fmac_f32_e32 v11, v36, v32
	v_fmac_f32_e32 v9, v30, v32
	v_fmac_f32_e32 v7, v36, v34
	v_fmac_f32_e32 v5, v30, v34
	v_fmac_f32_e32 v11, v37, v33
	v_fmac_f32_e32 v9, v31, v33
	v_fmac_f32_e32 v7, v37, v35
	v_fmac_f32_e32 v5, v31, v35
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v11, v38, v44
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v9, v50, v44
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v7, v38, v56
	v_fmac_f32_e32 v5, v50, v56
	v_fmac_f32_e32 v11, v39, v45
	v_fmac_f32_e32 v9, v51, v45
	v_fmac_f32_e32 v7, v39, v57
	v_fmac_f32_e32 v5, v51, v57
	v_fmac_f32_e32 v11, v40, v46
	v_fmac_f32_e32 v9, v52, v46
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v7, v40, v58
	v_fmac_f32_e32 v5, v52, v58
	v_fmac_f32_e32 v11, v41, v47
	v_fmac_f32_e32 v9, v53, v47
	v_fmac_f32_e32 v7, v41, v59
	v_fmac_f32_e32 v5, v53, v59
	v_fmac_f32_e32 v11, v42, v48
	v_fmac_f32_e32 v9, v54, v48
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v42, v60
	v_fmac_f32_e32 v5, v54, v60
	v_fmac_f32_e32 v11, v43, v49
	v_fmac_f32_e32 v9, v55, v49
	v_fmac_f32_e32 v7, v43, v61
	v_fmac_f32_e32 v5, v55, v61
	ds_read2_b32 v[30:31], v28 offset0:25 offset1:26
	ds_read2_b32 v[32:33], v16 offset0:8 offset1:9
	ds_read2_b32 v[34:35], v19 offset0:8 offset1:9
	ds_read2_b32 v[36:37], v28 offset0:8 offset1:9
	ds_read2_b32 v[38:39], v28 offset0:10 offset1:11
	ds_read2_b32 v[40:41], v28 offset0:12 offset1:13
	ds_read2_b32 v[42:43], v28 offset0:14 offset1:15
	ds_read2_b32 v[44:45], v16 offset0:10 offset1:11
	ds_read2_b32 v[46:47], v16 offset0:12 offset1:13
	ds_read2_b32 v[48:49], v16 offset0:14 offset1:15
	ds_read2_b32 v[50:51], v28 offset0:27 offset1:28
	ds_read2_b32 v[52:53], v28 offset0:29 offset1:30
	ds_read2_b32 v[54:55], v28 offset0:31 offset1:32
	ds_read2_b32 v[56:57], v19 offset0:10 offset1:11
	ds_read2_b32 v[58:59], v19 offset0:12 offset1:13
	ds_read2_b32 v[60:61], v19 offset0:14 offset1:15
	s_waitcnt lgkmcnt(12)
	v_fmac_f32_e32 v11, v36, v32
	v_fmac_f32_e32 v9, v30, v32
	v_fmac_f32_e32 v7, v36, v34
	v_fmac_f32_e32 v5, v30, v34
	v_fmac_f32_e32 v11, v37, v33
	v_fmac_f32_e32 v9, v31, v33
	v_fmac_f32_e32 v7, v37, v35
	v_fmac_f32_e32 v5, v31, v35
	s_waitcnt lgkmcnt(8)
	v_fmac_f32_e32 v11, v38, v44
	s_waitcnt lgkmcnt(5)
	v_fmac_f32_e32 v9, v50, v44
	s_waitcnt lgkmcnt(2)
	v_fmac_f32_e32 v7, v38, v56
	v_fmac_f32_e32 v5, v50, v56
	v_fmac_f32_e32 v11, v39, v45
	v_fmac_f32_e32 v9, v51, v45
	v_fmac_f32_e32 v7, v39, v57
	v_fmac_f32_e32 v5, v51, v57
	v_fmac_f32_e32 v11, v40, v46
	v_fmac_f32_e32 v9, v52, v46
	s_waitcnt lgkmcnt(1)
	v_fmac_f32_e32 v7, v40, v58
	v_fmac_f32_e32 v5, v52, v58
	v_fmac_f32_e32 v11, v41, v47
	v_fmac_f32_e32 v9, v53, v47
	v_fmac_f32_e32 v7, v41, v59
	v_fmac_f32_e32 v5, v53, v59
	v_fmac_f32_e32 v11, v42, v48
	v_fmac_f32_e32 v9, v54, v48
	s_waitcnt lgkmcnt(0)
	v_fmac_f32_e32 v7, v42, v60
	v_fmac_f32_e32 v5, v54, v60
	s_add_i32 s20, s20, 16
	v_fmac_f32_e32 v11, v43, v49
	v_fmac_f32_e32 v9, v55, v49
	v_fmac_f32_e32 v7, v43, v61
	v_fmac_f32_e32 v5, v55, v61
	s_cmp_ge_i32 s20, s21
	s_cbranch_scc1 .LBB3_78
.LBB3_32:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccz .LBB3_36
	v_add_u32_e32 v30, s20, v22
	v_add_u32_e32 v32, s20, v3
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v33, 31, v32
	v_add_u32_e32 v34, s20, v15
	v_add_u32_e32 v36, s20, v24
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[12:13]
	v_lshl_add_u64 v[32:33], v[32:33], 2, s[12:13]
	v_ashrrev_i32_e32 v35, 31, v34
	v_ashrrev_i32_e32 v37, 31, v36
	v_lshl_add_u64 v[34:35], v[34:35], 2, s[12:13]
	v_lshl_add_u64 v[36:37], v[36:37], 2, s[12:13]
	global_load_dword v29, v[30:31], off
	global_load_dword v30, v[32:33], off
	global_load_dword v31, v[34:35], off
	global_load_dword v32, v[36:37], off
	s_waitcnt vmcnt(3)
	ds_write_b32 v26, v29
	s_waitcnt vmcnt(2)
	ds_write_b32 v27, v30
	s_waitcnt vmcnt(1)
	ds_write_b32 v26, v31 offset:4
	s_waitcnt vmcnt(0)
	ds_write_b32 v27, v32 offset:4
	s_cbranch_execz .LBB3_37
.LBB3_34:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB3_38
.LBB3_35:
	v_add_u32_e32 v30, s20, v17
	v_add_u32_e32 v32, s20, v23
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v33, 31, v32
	v_add_u32_e32 v34, s20, v1
	v_add_u32_e32 v36, s20, v25
	v_lshl_add_u64 v[30:31], v[30:31], 2, s[16:17]
	v_lshl_add_u64 v[32:33], v[32:33], 2, s[16:17]
	v_ashrrev_i32_e32 v35, 31, v34
	v_ashrrev_i32_e32 v37, 31, v36
	v_lshl_add_u64 v[34:35], v[34:35], 2, s[16:17]
	v_lshl_add_u64 v[36:37], v[36:37], 2, s[16:17]
	global_load_dword v29, v[30:31], off
	global_load_dword v30, v[32:33], off
	global_load_dword v31, v[34:35], off
	global_load_dword v32, v[36:37], off
	s_waitcnt vmcnt(2)
	ds_write2_b32 v18, v29, v30 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v20, v31, v32 offset1:1
	s_cbranch_execnz .LBB3_31
	s_branch .LBB3_39
.LBB3_36:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB3_34
.LBB3_37:
	s_lshr_b32 s4, s20, 1
	v_add_u32_e32 v30, s4, v0
	v_add_u32_e32 v32, s4, v4
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v33, 31, v32
	v_lshl_add_u64 v[30:31], v[30:31], 3, s[12:13]
	v_lshl_add_u64 v[32:33], v[32:33], 3, s[12:13]
	global_load_dwordx2 v[30:31], v[30:31], off
	global_load_dwordx2 v[32:33], v[32:33], off
	s_waitcnt vmcnt(1)
	ds_write2_b32 v26, v30, v31 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v27, v32, v33 offset1:1
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB3_35
.LBB3_38:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB3_31
.LBB3_39:
	s_lshr_b32 s4, s20, 1
	v_add_u32_e32 v30, s4, v6
	v_add_u32_e32 v32, s4, v8
	v_ashrrev_i32_e32 v31, 31, v30
	v_ashrrev_i32_e32 v33, 31, v32
	v_lshl_add_u64 v[30:31], v[30:31], 3, s[16:17]
	v_lshl_add_u64 v[32:33], v[32:33], 3, s[16:17]
	global_load_dwordx2 v[30:31], v[30:31], off
	global_load_dwordx2 v[32:33], v[32:33], off
	v_add_u32_e32 v29, v21, v13
	v_add_u32_e32 v34, v21, v14
	s_waitcnt vmcnt(1)
	ds_write2_b32 v29, v30, v31 offset1:1
	s_waitcnt vmcnt(0)
	ds_write2_b32 v34, v32, v33 offset1:1
	s_branch .LBB3_31
.LBB3_40:
	s_branch .LBB3_2
.LBB3_41:
	s_branch .LBB3_5
.LBB3_42:
	s_mov_b32 s36, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
.LBB3_43:
	s_cmp_ge_i32 s36, s22
	v_or_b32_e32 v13, 1, v2
	s_cbranch_scc1 .LBB3_54
	v_or_b32_e32 v0, 1, v10
	v_cmp_gt_i32_e64 s[4:5], s21, v0
	v_mul_lo_u32 v0, v2, s15
	v_mul_lo_u32 v14, v10, s19
	v_add_u32_e32 v0, s14, v0
	v_add_u32_e32 v14, s18, v14
	v_cmp_gt_i32_e32 vcc, s20, v2
	v_cmp_gt_i32_e64 s[0:1], s20, v13
	v_cmp_gt_i32_e64 s[2:3], s21, v10
	v_add_u32_e32 v1, s15, v0
	v_add_u32_e32 v15, s19, v14
	s_branch .LBB3_46
.LBB3_45:
	s_or_b64 exec, exec, s[6:7]
	s_add_i32 s36, s36, 1
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v12, v17, v19
	v_fmac_f32_e32 v11, v16, v19
	v_fmac_f32_e32 v9, v17, v18
	s_cmp_ge_i32 s36, s22
	v_fmac_f32_e32 v8, v16, v18
	s_cbranch_scc1 .LBB3_54
.LBB3_46:
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB3_48
	v_add_u32_e32 v18, s36, v0
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v17, v[18:19], off
.LBB3_48:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB3_50
	v_add_u32_e32 v18, s36, v1
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[12:13]
	global_load_dword v16, v[18:19], off
.LBB3_50:
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v18, 0
	v_mov_b32_e32 v19, 0
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB3_52
	v_add_u32_e32 v20, s36, v14
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v19, v[20:21], off
.LBB3_52:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB3_45
	v_add_u32_e32 v20, s36, v15
	v_ashrrev_i32_e32 v21, 31, v20
	v_lshl_add_u64 v[20:21], v[20:21], 2, s[16:17]
	global_load_dword v18, v[20:21], off
	s_branch .LBB3_45
.LBB3_54:
	s_cmp_eq_u32 s26, 0
	v_cmp_le_i32_e64 s[2:3], s21, v10
	v_cmp_le_i32_e64 s[4:5], s20, v2
	s_cselect_b64 s[0:1], -1, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[8:9], s27, 0
	s_nor_b64 s[34:35], s[4:5], s[2:3]
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB3_59
	v_cndmask_b32_e64 v1, v2, v10, s[0:1]
	v_cndmask_b32_e64 v0, v10, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[34:35], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[8:9]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccz .LBB3_107
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v14, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v14, s27, v14
	v_fmac_f32_e32 v14, s23, v12
	s_cbranch_execnz .LBB3_58
.LBB3_57:
	v_mul_f32_e32 v14, s23, v12
.LBB3_58:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v14, off
.LBB3_59:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_le_i32_e64 s[6:7], s20, v13
	v_cndmask_b32_e64 v0, 0, 1, s[8:9]
	s_nor_b64 s[34:35], s[6:7], s[2:3]
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	s_and_saveexec_b64 s[8:9], s[34:35]
	s_cbranch_execz .LBB3_64
	v_cndmask_b32_e64 v1, v13, v10, s[0:1]
	v_cndmask_b32_e64 v0, v10, v13, s[0:1]
	v_mad_u64_u32 v[0:1], s[34:35], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB3_108
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v12, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v12, s27, v12
	v_fmac_f32_e32 v12, s23, v11
	s_cbranch_execnz .LBB3_63
.LBB3_62:
	v_mul_f32_e32 v12, s23, v11
.LBB3_63:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v12, off
.LBB3_64:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v11, 1, v10
	v_cmp_le_i32_e64 s[8:9], s21, v11
	s_nor_b64 s[20:21], s[4:5], s[8:9]
	s_and_saveexec_b64 s[4:5], s[20:21]
	s_cbranch_execz .LBB3_69
	v_cndmask_b32_e64 v1, v2, v11, s[0:1]
	v_cndmask_b32_e64 v0, v11, v2, s[0:1]
	v_mad_u64_u32 v[0:1], s[20:21], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB3_109
	v_lshl_add_u64 v[14:15], v[0:1], 2, s[10:11]
	global_load_dword v12, v[14:15], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v12, s27, v12
	v_fmac_f32_e32 v12, s23, v9
	s_cbranch_execnz .LBB3_68
.LBB3_67:
	v_mul_f32_e32 v12, s23, v9
.LBB3_68:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v12, off
.LBB3_69:
	s_or_b64 exec, exec, s[4:5]
	s_nor_b64 s[4:5], s[6:7], s[8:9]
	s_mov_b64 s[6:7], 0
	s_and_saveexec_b64 s[8:9], s[4:5]
	s_xor_b64 s[4:5], exec, s[8:9]
	s_cbranch_execz .LBB3_74
	v_cndmask_b32_e64 v1, v13, v11, s[0:1]
	v_cndmask_b32_e64 v0, v11, v13, s[0:1]
	v_mad_u64_u32 v[0:1], s[0:1], v1, s25, v[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[2:3]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB3_110
	v_lshl_add_u64 v[12:13], v[0:1], 2, s[10:11]
	global_load_dword v9, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v9, s27, v9
	v_fmac_f32_e32 v9, s23, v8
	s_cbranch_execnz .LBB3_73
.LBB3_72:
	v_mul_f32_e32 v9, s23, v8
.LBB3_73:
	s_mov_b64 s[6:7], exec
.LBB3_74:
	s_or_b64 exec, exec, s[4:5]
	s_and_b64 s[6:7], s[6:7], exec
	s_andn2_b64 s[28:29], s[28:29], exec
	s_or_b64 exec, exec, s[30:31]
	s_and_saveexec_b64 s[0:1], s[28:29]
	s_xor_b64 s[8:9], exec, s[0:1]
	s_cbranch_execnz .LBB3_29
.LBB3_75:
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB3_102
.LBB3_76:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	global_store_dword v[0:1], v9, off
	s_endpgm
.LBB3_77:
	s_mov_b32 s20, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v11, 0
.LBB3_78:
	s_cmp_ge_i32 s20, s22
	s_cbranch_scc1 .LBB3_81
	v_mul_lo_u32 v0, v2, s15
	v_add_u32_e32 v0, s14, v0
	v_add_u32_e32 v1, s18, v12
	v_add_u32_e32 v3, s15, v0
	v_add_u32_e32 v4, s19, v1
.LBB3_80:
	v_add_u32_e32 v12, s20, v0
	v_add_u32_e32 v16, s20, v1
	v_add_u32_e32 v14, s20, v3
	v_add_u32_e32 v18, s20, v4
	v_ashrrev_i32_e32 v13, 31, v12
	v_ashrrev_i32_e32 v17, 31, v16
	v_ashrrev_i32_e32 v15, 31, v14
	v_ashrrev_i32_e32 v19, 31, v18
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[12:13]
	v_lshl_add_u64 v[16:17], v[16:17], 2, s[16:17]
	v_lshl_add_u64 v[14:15], v[14:15], 2, s[12:13]
	v_lshl_add_u64 v[18:19], v[18:19], 2, s[16:17]
	global_load_dword v6, v[16:17], off
	global_load_dword v8, v[12:13], off
	global_load_dword v12, v[14:15], off
	global_load_dword v13, v[18:19], off
	s_add_i32 s20, s20, 1
	s_cmp_lt_i32 s20, s22
	s_waitcnt vmcnt(2)
	v_fmac_f32_e32 v11, v8, v6
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v9, v12, v6
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v7, v8, v13
	v_fmac_f32_e32 v5, v12, v13
	s_cbranch_scc1 .LBB3_80
.LBB3_81:
	s_cmp_eq_u32 s26, 0
	v_mad_u64_u32 v[0:1], s[0:1], v10, s25, v[2:3]
	v_mul_lo_u32 v4, v2, s25
	v_add_u32_e32 v1, v4, v10
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v2, v1, v0, s[0:1]
	s_cmp_lg_u32 s26, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_neq_f32_e64 s[12:13], s27, 0
	v_add_u32_e32 v2, s24, v2
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccz .LBB3_103
	v_lshl_add_u64 v[12:13], v[2:3], 2, s[10:11]
	global_load_dword v6, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s27, v6
	v_fmac_f32_e32 v6, s23, v11
	s_cbranch_execnz .LBB3_84
.LBB3_83:
	v_mul_f32_e32 v6, s23, v11
.LBB3_84:
	v_cndmask_b32_e64 v8, 0, 1, s[4:5]
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	v_cmp_ne_u32_e64 s[2:3], 1, v8
	s_andn2_b64 vcc, exec, s[4:5]
	global_store_dword v[2:3], v6, off
	s_cbranch_vccnz .LBB3_86
	v_add_u32_e32 v1, s25, v1
	s_cbranch_execz .LBB3_87
	s_branch .LBB3_88
.LBB3_86:
.LBB3_87:
	v_or_b32_e32 v1, 1, v0
.LBB3_88:
	v_cndmask_b32_e64 v2, 0, 1, s[12:13]
	v_cmp_ne_u32_e64 s[4:5], 1, v2
	v_add_u32_e32 v2, s24, v1
	s_andn2_b64 vcc, exec, s[12:13]
	v_ashrrev_i32_e32 v3, 31, v2
	s_cbranch_vccnz .LBB3_104
	v_lshl_add_u64 v[12:13], v[2:3], 2, s[10:11]
	global_load_dword v1, v[12:13], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, s27, v1
	v_fmac_f32_e32 v1, s23, v9
	s_cbranch_execnz .LBB3_91
.LBB3_90:
	v_mul_f32_e32 v1, s23, v9
.LBB3_91:
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[10:11]
	global_store_dword v[2:3], v1, off
	v_or_b32_e32 v3, 1, v10
	v_add_u32_e32 v2, s25, v0
	v_add_u32_e32 v0, v4, v3
	v_cndmask_b32_e64 v0, v0, v2, s[0:1]
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB3_105
	v_lshl_add_u64 v[8:9], v[0:1], 2, s[10:11]
	global_load_dword v6, v[8:9], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v6, s27, v6
	v_fmac_f32_e32 v6, s23, v7
	s_cbranch_execnz .LBB3_94
.LBB3_93:
	v_mul_f32_e32 v6, s23, v7
.LBB3_94:
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[10:11]
	s_and_b64 vcc, exec, s[2:3]
	global_store_dword v[0:1], v6, off
	s_cbranch_vccnz .LBB3_96
	v_add3_u32 v0, v4, s25, v3
	s_cbranch_execz .LBB3_97
	s_branch .LBB3_98
.LBB3_96:
.LBB3_97:
	v_add_u32_e32 v0, 1, v2
.LBB3_98:
	v_add_u32_e32 v0, s24, v0
	s_and_b64 vcc, exec, s[4:5]
	v_ashrrev_i32_e32 v1, 31, v0
	s_cbranch_vccnz .LBB3_106
	v_lshl_add_u64 v[2:3], v[0:1], 2, s[10:11]
	global_load_dword v2, v[2:3], off
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v9, s27, v2
	v_fmac_f32_e32 v9, s23, v5
	s_cbranch_execnz .LBB3_101
.LBB3_100:
	v_mul_f32_e32 v9, s23, v5
.LBB3_101:
	s_or_b64 s[6:7], s[6:7], exec
	s_or_b64 exec, exec, s[8:9]
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execnz .LBB3_76
.LBB3_102:
	s_endpgm
.LBB3_103:
	s_branch .LBB3_83
.LBB3_104:
	s_branch .LBB3_90
.LBB3_105:
	s_branch .LBB3_93
.LBB3_106:
	s_branch .LBB3_100
.LBB3_107:
	s_branch .LBB3_57
.LBB3_108:
	s_branch .LBB3_62
.LBB3_109:
	s_branch .LBB3_67
.LBB3_110:
	s_branch .LBB3_72
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel XgemmDirectTT
		.amdhsa_group_segment_fixed_size 2176
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 62
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 64
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
	.text
.Lfunc_end3:
	.size	XgemmDirectTT, .Lfunc_end3-XgemmDirectTT

	.set XgemmDirectTT.num_vgpr, 62
	.set XgemmDirectTT.num_agpr, 0
	.set XgemmDirectTT.numbered_sgpr, 40
	.set XgemmDirectTT.private_seg_size, 0
	.set XgemmDirectTT.uses_vcc, 1
	.set XgemmDirectTT.uses_flat_scratch, 0
	.set XgemmDirectTT.has_dyn_sized_stack, 0
	.set XgemmDirectTT.has_recursion, 0
	.set XgemmDirectTT.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.ident	"Homebrew clang version 21.1.8"
	.ident	"AMD clang version 22.0.0git (https://github.com/RadeonOpenCompute/llvm-project roc-7.2.1 26084 f58b06dce1f9c15707c5f808fd002e18c2accf7e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .name:           kSizeM
        .offset:         0
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeN
        .offset:         4
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeK
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           arg_alpha
        .offset:         12
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .name:           arg_beta
        .offset:         16
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           agm
        .offset:         24
        .size:           8
        .type_name:      'realMD*'
        .value_kind:     global_buffer
      - .name:           a_offset
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_ld
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           bgm
        .offset:         40
        .size:           8
        .type_name:      'realND*'
        .value_kind:     global_buffer
      - .name:           b_offset
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_ld
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           cgm
        .offset:         56
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           c_offset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_ld
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_transpose
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_conjugate
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_conjugate
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 2176
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           XgemmDirectNN
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 8
      - 8
      - 1
    .sgpr_count:     48
    .sgpr_spill_count: 0
    .symbol:         XgemmDirectNN.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     48
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .name:           kSizeM
        .offset:         0
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeN
        .offset:         4
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeK
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           arg_alpha
        .offset:         12
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .name:           arg_beta
        .offset:         16
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           agm
        .offset:         24
        .size:           8
        .type_name:      'realMD*'
        .value_kind:     global_buffer
      - .name:           a_offset
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_ld
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           bgm
        .offset:         40
        .size:           8
        .type_name:      'realND*'
        .value_kind:     global_buffer
      - .name:           b_offset
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_ld
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           cgm
        .offset:         56
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           c_offset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_ld
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_transpose
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_conjugate
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_conjugate
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 2176
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           XgemmDirectNT
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 8
      - 8
      - 1
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         XgemmDirectNT.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     60
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .name:           kSizeM
        .offset:         0
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeN
        .offset:         4
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeK
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           arg_alpha
        .offset:         12
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .name:           arg_beta
        .offset:         16
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           agm
        .offset:         24
        .size:           8
        .type_name:      'realMD*'
        .value_kind:     global_buffer
      - .name:           a_offset
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_ld
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           bgm
        .offset:         40
        .size:           8
        .type_name:      'realND*'
        .value_kind:     global_buffer
      - .name:           b_offset
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_ld
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           cgm
        .offset:         56
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           c_offset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_ld
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_transpose
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_conjugate
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_conjugate
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 2176
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           XgemmDirectTN
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 8
      - 8
      - 1
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         XgemmDirectTN.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     52
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .name:           kSizeM
        .offset:         0
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeN
        .offset:         4
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           kSizeK
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           arg_alpha
        .offset:         12
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .name:           arg_beta
        .offset:         16
        .size:           4
        .type_name:      real_arg
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           agm
        .offset:         24
        .size:           8
        .type_name:      'realMD*'
        .value_kind:     global_buffer
      - .name:           a_offset
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_ld
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           bgm
        .offset:         40
        .size:           8
        .type_name:      'realND*'
        .value_kind:     global_buffer
      - .name:           b_offset
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_ld
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           cgm
        .offset:         56
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           c_offset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_ld
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_transpose
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           a_conjugate
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           b_conjugate
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 2176
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           XgemmDirectTT
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 8
      - 8
      - 1
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         XgemmDirectTT.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     62
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
