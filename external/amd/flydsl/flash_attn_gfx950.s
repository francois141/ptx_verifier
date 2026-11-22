; FlyDSL 304d441202a3 kernels/attention/flash_attn_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case flash_attn_gfx950).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	flash_attn_dualwave_swp_gfx950_kernel_0
	.p2align	8
	.type	flash_attn_dualwave_swp_gfx950_kernel_0,@function
flash_attn_dualwave_swp_gfx950_kernel_0:
	s_mov_b32 s6, s3
	s_load_dwordx4 s[12:15], s[0:1], 0x240
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x30
	s_load_dwordx2 s[28:29], s[0:1], 0x60
	s_ashr_i32 s7, s6, 31
	s_ashr_i32 s3, s2, 31
	s_lshl_b64 s[20:21], s[6:7], 8
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s6, s20, s14
	s_lshl_b64 s[2:3], s[2:3], 6
	v_readfirstlane_b32 s10, v0
	s_add_i32 s30, s6, s2
	s_mul_hi_i32 s7, s14, s12
	s_mul_i32 s6, s14, s12
	s_ashr_i32 s5, s4, 31
	s_lshr_b32 s22, s10, 6
	s_lshr_b32 s24, s10, 8
	s_lshl_b64 s[10:11], s[6:7], 1
	s_mul_i32 s3, s10, s5
	s_mul_hi_u32 s11, s10, s4
	s_lshr_b64 s[6:7], s[6:7], 31
	s_add_i32 s3, s11, s3
	s_mul_i32 s6, s6, s4
	s_ashr_i32 s23, s13, 31
	s_add_i32 s3, s3, s6
	s_mul_i32 s12, s10, s4
	s_add_u32 s8, s12, s8
	s_addc_u32 s6, s3, s9
	s_and_b32 s9, s6, 0xffff
	s_mul_i32 s6, s15, s13
	s_mul_hi_i32 s7, s15, s13
	s_lshl_b32 s18, s6, 1
	s_mul_i32 s5, s18, s5
	s_mul_hi_u32 s19, s18, s4
	s_lshr_b64 s[6:7], s[6:7], 31
	s_add_i32 s5, s19, s5
	s_mul_i32 s6, s6, s4
	v_lshrrev_b32_e32 v1, 6, v0
	s_add_i32 s5, s5, s6
	s_mul_i32 s4, s18, s4
	s_add_u32 s16, s4, s16
	v_lshlrev_b32_e32 v2, 3, v0
	v_and_or_b32 v3, v0, 56, v1
	s_mov_b32 s11, 0x27000
	s_addc_u32 s6, s5, s17
	s_mul_i32 s27, s22, 0x410
	v_and_b32_e32 v4, 56, v2
	v_mul_lo_u32 v3, v3, s15
	s_and_b32 s17, s6, 0xffff
	s_mov_b32 s19, s11
	v_add_lshl_u32 v131, v3, v4, 1
	s_mov_b32 m0, s27
	s_load_dword s26, s[0:1], 0x250
	buffer_load_dwordx4 v131, s[16:19], 0 offen lds
	s_add_u32 s4, s4, s28
	v_and_b32_e32 v3, 7, v0
	v_bfe_u32 v128, v0, 5, 1
	s_addc_u32 s5, s5, s29
	v_mul_u32_u24_e32 v3, 0x208, v3
	v_and_b32_e32 v2, 0xc0, v2
	s_mulk_i32 s22, 0x440
	v_mov_b32_e32 v129, 0
	s_mov_b32 s6, s18
	s_mov_b32 s7, s11
	s_and_b32 s5, s5, 0xffff
	v_add_u32_e32 v10, v3, v2
	v_lshlrev_b32_e32 v130, 3, v128
	s_add_i32 s25, s27, 0x4280
	s_add_i32 s21, s22, 0x2080
	v_lshlrev_b32_e32 v1, 5, v1
	s_mov_b32 s36, s4
	s_mov_b32 s37, s5
	s_mov_b32 s38, s18
	s_mov_b32 s39, s11
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_or_b32 v132, v0, 31, v1
	v_mul_lo_u32 v1, v132, s14
	v_add_u32_e32 v1, s30, v1
	v_add_lshl_u32 v1, v1, v130, 1
	s_barrier
	buffer_load_dwordx4 v[6:9], v1, s[8:11], 0 offen
	buffer_load_dwordx4 v[2:5], v1, s[8:11], 0 offen offset:32
	buffer_load_dwordx4 v[38:41], v1, s[8:11], 0 offen offset:64
	buffer_load_dwordx4 v[34:37], v1, s[8:11], 0 offen offset:96
	s_mov_b32 m0, s25
	s_lshl_b32 s28, s15, 7
	buffer_load_dwordx4 v131, s[16:19], s28 offen lds
	s_mov_b32 m0, s21
	v_add_lshl_u32 v133, v10, v130, 1
	buffer_load_dwordx4 v131, s[36:39], 0 offen lds
	ds_read_b128 v[10:13], v133
	ds_read_b128 v[62:65], v133 offset:32
	ds_read_b128 v[66:69], v133 offset:512
	ds_read_b128 v[58:61], v133 offset:544
	ds_read_b128 v[54:57], v133 offset:64
	ds_read_b128 v[46:49], v133 offset:96
	ds_read_b128 v[50:53], v133 offset:576
	ds_read_b128 v[42:45], v133 offset:608
	s_cmp_eq_u32 s24, 0
	s_waitcnt vmcnt(1) lgkmcnt(0)
	s_cbranch_scc1 .LBB0_2
	s_barrier
.LBB0_2:
	v_cvt_f32_i32_e32 v1, s26
	v_and_b32_e32 v15, 0xffff0000, v9
	v_lshlrev_b32_e32 v14, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v8
	v_rsq_f32_e32 v1, v1
	v_lshlrev_b32_e32 v8, 16, v8
	v_and_b32_e32 v17, 0xffff0000, v7
	v_lshlrev_b32_e32 v16, 16, v7
	v_mul_f32_e32 v76, 0x3fb8aa3b, v1
	v_and_b32_e32 v7, 0xffff0000, v6
	v_lshlrev_b32_e32 v6, 16, v6
	v_pk_mul_f32 v[6:7], v[76:77], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[76:77], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[76:77], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[76:77], v[14:15] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v95, v14, v15
	v_cvt_pk_bf16_f32 v94, v8, v9
	v_cvt_pk_bf16_f32 v93, v16, v17
	v_cvt_pk_bf16_f32 v92, v6, v7
	v_and_b32_e32 v81, 0xffff0000, v3
	v_lshlrev_b32_e32 v80, 16, v3
	v_and_b32_e32 v3, 0xffff0000, v2
	v_lshlrev_b32_e32 v2, 16, v2
	v_and_b32_e32 v75, 0xffff0000, v5
	v_lshlrev_b32_e32 v74, 16, v5
	v_mfma_f32_32x32x16_bf16 v[18:33], v[10:13], v[92:95], 0
	v_and_b32_e32 v79, 0xffff0000, v4
	v_lshlrev_b32_e32 v78, 16, v4
	v_mul_f32_e64 v82, v76, v2
	v_mul_f32_e64 v83, v76, v3
	v_mul_f32_e64 v74, v76, v74
	v_mul_f32_e64 v75, v76, v75
	v_cvt_pk_bf16_f32 v91, v74, v75
	v_cvt_pk_bf16_f32 v88, v82, v83
	v_and_b32_e32 v73, 0xffff0000, v41
	v_mfma_f32_32x32x16_bf16 v[2:17], v[66:69], v[92:95], 0
	v_mul_f32_e64 v66, v76, v80
	v_mul_f32_e64 v67, v76, v81
	v_mul_f32_e64 v68, v76, v78
	v_mul_f32_e64 v69, v76, v79
	v_cvt_pk_bf16_f32 v90, v68, v69
	v_cvt_pk_bf16_f32 v89, v66, v67
	v_lshlrev_b32_e32 v72, 16, v41
	v_and_b32_e32 v41, 0xffff0000, v40
	v_lshlrev_b32_e32 v40, 16, v40
	v_mfma_f32_32x32x16_bf16 v[18:33], v[62:65], v[88:91], v[18:33]
	v_and_b32_e32 v63, 0xffff0000, v39
	v_lshlrev_b32_e32 v62, 16, v39
	v_and_b32_e32 v39, 0xffff0000, v38
	v_lshlrev_b32_e32 v38, 16, v38
	v_mul_f32_e64 v38, v76, v38
	v_mul_f32_e64 v39, v76, v39
	v_pk_mul_f32 v[40:41], v[76:77], v[40:41] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v82, v40, v41
	v_mfma_f32_32x32x16_bf16 v[2:17], v[58:61], v[88:91], v[2:17]
	v_mul_f32_e64 v58, v76, v62
	v_mul_f32_e64 v59, v76, v63
	v_mul_f32_e64 v60, v76, v72
	v_mul_f32_e64 v61, v76, v73
	v_cvt_pk_bf16_f32 v83, v60, v61
	v_cvt_pk_bf16_f32 v81, v58, v59
	v_cvt_pk_bf16_f32 v80, v38, v39
	v_and_b32_e32 v71, 0xffff0000, v37
	v_lshlrev_b32_e32 v70, 16, v37
	v_mfma_f32_32x32x16_bf16 v[18:33], v[54:57], v[80:83], v[18:33]
	v_and_b32_e32 v37, 0xffff0000, v36
	v_lshlrev_b32_e32 v36, 16, v36
	v_and_b32_e32 v39, 0xffff0000, v35
	v_lshlrev_b32_e32 v38, 16, v35
	v_and_b32_e32 v35, 0xffff0000, v34
	v_lshlrev_b32_e32 v34, 16, v34
	v_pk_mul_f32 v[34:35], v[76:77], v[34:35] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[50:53], v[80:83], v[2:17]
	v_mul_f32_e64 v38, v76, v38
	v_mul_f32_e64 v39, v76, v39
	v_mul_f32_e64 v36, v76, v36
	v_mul_f32_e64 v37, v76, v37
	v_mul_f32_e64 v40, v76, v70
	v_mul_f32_e64 v41, v76, v71
	v_cvt_pk_bf16_f32 v87, v40, v41
	v_cvt_pk_bf16_f32 v86, v36, v37
	v_cvt_pk_bf16_f32 v85, v38, v39
	v_cvt_pk_bf16_f32 v84, v34, v35
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[18:33], v[46:49], v[84:87], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[42:45], v[84:87], v[2:17]
	s_cmp_gt_i32 s13, 63
	s_cbranch_scc1 .LBB0_4
	v_lshlrev_b32_e32 v1, 2, v128
	v_or_b32_e32 v34, 32, v1
	v_mov_b32_e32 v35, 0xff800000
	v_cmp_gt_i32_e32 vcc, s13, v1
	v_or_b32_e32 v36, 33, v1
	s_nop 3
	v_cndmask_b32_e32 v18, v35, v18, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 1, v1
	s_nop 0
	v_cndmask_b32_e32 v2, v35, v2, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 2, v1
	s_nop 0
	v_cndmask_b32_e32 v19, v35, v19, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 34, v1
	s_nop 0
	v_cndmask_b32_e32 v3, v35, v3, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 3, v1
	s_nop 0
	v_cndmask_b32_e32 v20, v35, v20, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 35, v1
	s_nop 0
	v_cndmask_b32_e32 v4, v35, v4, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 8, v1
	s_nop 0
	v_cndmask_b32_e32 v21, v35, v21, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 40, v1
	s_nop 0
	v_cndmask_b32_e32 v5, v35, v5, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 9, v1
	s_nop 0
	v_cndmask_b32_e32 v22, v35, v22, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 41, v1
	s_nop 0
	v_cndmask_b32_e32 v6, v35, v6, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 10, v1
	s_nop 0
	v_cndmask_b32_e32 v23, v35, v23, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 42, v1
	s_nop 0
	v_cndmask_b32_e32 v7, v35, v7, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 11, v1
	s_nop 0
	v_cndmask_b32_e32 v24, v35, v24, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 43, v1
	s_nop 0
	v_cndmask_b32_e32 v8, v35, v8, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 16, v1
	s_nop 0
	v_cndmask_b32_e32 v25, v35, v25, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 48, v1
	s_nop 0
	v_cndmask_b32_e32 v9, v35, v9, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 17, v1
	s_nop 0
	v_cndmask_b32_e32 v26, v35, v26, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 49, v1
	s_nop 0
	v_cndmask_b32_e32 v10, v35, v10, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 18, v1
	s_nop 0
	v_cndmask_b32_e32 v27, v35, v27, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 50, v1
	s_nop 0
	v_cndmask_b32_e32 v11, v35, v11, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 19, v1
	s_nop 0
	v_cndmask_b32_e32 v28, v35, v28, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 51, v1
	s_nop 0
	v_cndmask_b32_e32 v12, v35, v12, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 24, v1
	s_nop 0
	v_cndmask_b32_e32 v29, v35, v29, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 56, v1
	s_nop 0
	v_cndmask_b32_e32 v13, v35, v13, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 25, v1
	s_nop 0
	v_cndmask_b32_e32 v30, v35, v30, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 57, v1
	s_nop 0
	v_cndmask_b32_e32 v14, v35, v14, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 26, v1
	s_nop 0
	v_cndmask_b32_e32 v31, v35, v31, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	v_or_b32_e32 v36, 58, v1
	s_nop 0
	v_cndmask_b32_e32 v15, v35, v15, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	v_or_b32_e32 v34, 27, v1
	v_or_b32_e32 v1, 59, v1
	v_cndmask_b32_e32 v32, v35, v32, vcc
	v_cmp_gt_i32_e32 vcc, s13, v36
	s_nop 1
	v_cndmask_b32_e32 v16, v35, v16, vcc
	v_cmp_gt_i32_e32 vcc, s13, v34
	s_nop 1
	v_cndmask_b32_e32 v33, v35, v33, vcc
	v_cmp_gt_i32_e32 vcc, s13, v1
	s_nop 1
	v_cndmask_b32_e32 v17, v35, v17, vcc
.LBB0_4:
	v_bfe_u32 v34, v0, 2, 2
	v_mul_u32_u24_e32 v1, 0x880, v128
	v_mul_u32_u24_e32 v34, 0x220, v34
	v_add_u32_e32 v1, v1, v34
	v_and_b32_e32 v34, 16, v0
	v_lshlrev_b32_e32 v0, 2, v0
	v_and_b32_e32 v0, 12, v0
	v_or3_b32 v0, v34, v1, v0
	s_nop 0
	v_max_f32_e32 v1, v18, v19
	v_max3_f32 v1, v1, v20, v21
	v_max3_f32 v1, v1, v22, v23
	v_max3_f32 v1, v1, v24, v25
	v_max3_f32 v1, v1, v26, v27
	v_max3_f32 v1, v1, v28, v29
	v_max3_f32 v1, v1, v30, v31
	v_max3_f32 v1, v1, v32, v33
	v_max3_f32 v1, v1, v2, v3
	v_max3_f32 v1, v1, v4, v5
	v_max3_f32 v1, v1, v6, v7
	v_max3_f32 v1, v1, v8, v9
	v_max3_f32 v1, v1, v10, v11
	v_max3_f32 v1, v1, v12, v13
	v_max3_f32 v1, v1, v14, v15
	v_max3_f32 v1, v1, v16, v17
	s_add_u32 s8, s13, 63
	v_mov_b32_e32 v34, v1
	s_addc_u32 s9, s23, 0
	s_nop 0
	v_permlane32_swap_b32_e64 v1, v34 bound_ctrl:1
	s_lshr_b64 s[8:9], s[8:9], 6
	v_max_f32_e32 v134, v1, v34
	s_add_u32 s8, s8, 1
	v_pk_add_f32 v[18:19], v[18:19], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[20:21], v[20:21], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[22:23], v[22:23], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[24:25], v[24:25], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[26:27], v[26:27], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[28:29], v[28:29], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[30:31], v[30:31], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[32:33], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_addc_u32 s9, s9, 0
	s_and_b32 s8, s8, -2
	v_exp_f32_e32 v64, v18
	v_exp_f32_e32 v65, v19
	v_exp_f32_e32 v70, v20
	v_exp_f32_e32 v71, v21
	v_exp_f32_e32 v66, v22
	v_exp_f32_e32 v67, v23
	v_exp_f32_e32 v68, v24
	v_exp_f32_e32 v69, v25
	v_exp_f32_e32 v96, v26
	v_exp_f32_e32 v97, v27
	v_exp_f32_e32 v76, v28
	v_exp_f32_e32 v77, v29
	v_exp_f32_e32 v98, v30
	v_exp_f32_e32 v99, v31
	v_exp_f32_e32 v78, v32
	v_exp_f32_e32 v79, v33
	v_cmp_gt_u64_e64 s[18:19], s[8:9], 4
	s_and_b64 vcc, s[18:19], exec
	s_cselect_b32 s9, s9, 0
	s_cselect_b32 s29, s8, 4
	v_pk_add_f32 v[104:105], v[16:17], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[106:107], v[14:15], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[34:35], v[12:13], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[72:73], v[10:11], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[74:75], v[8:9], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[100:101], v[6:7], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[102:103], v[4:5], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[2:3], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_barrier
	s_mov_b32 m0, s27
	s_lshl_b32 s8, s15, 8
	s_mov_b32 s18, s6
	s_mov_b32 s19, s7
	buffer_load_dwordx4 v131, s[16:19], s8 offen lds
	s_add_u32 s8, s29, -1
	s_mov_b64 s[18:19], -1
	s_addc_u32 s9, s9, -1
	v_lshlrev_b32_e32 v137, 1, v0
	s_cbranch_vccnz .LBB0_6
	v_add_u32_e32 v135, 0x2080, v137
	s_mov_b64 s[18:19], 0
	s_branch .LBB0_7
.LBB0_6:
.LBB0_7:
	s_add_i32 s11, s22, 0x6300
	s_lshl_b32 s26, s15, 1
	s_and_b64 s[18:19], s[18:19], exec
	s_cselect_b32 s18, 1, 0
	s_cmp_lg_u32 s18, 1
	s_cbranch_scc1 .LBB0_10
	v_mov_b32_e32 v0, 0
	v_add_u32_e32 v135, 0x2080, v137
	v_add_u32_e32 v119, 0x6300, v137
	s_mul_i32 s30, s26, 0x80000080
	s_lshl_b32 s31, s15, 9
	s_mulk_i32 s15, 0x180
	s_mov_b64 s[22:23], 3
	s_mov_b32 s33, 0
	v_mov_b32_e32 v138, 0
	v_mov_b64_e32 v[116:117], s[8:9]
	s_mov_b32 s18, s6
	s_mov_b32 s19, s7
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	v_mov_b32_e32 v4, v0
	v_mov_b32_e32 v5, v0
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v0
	v_mov_b32_e32 v8, v0
	v_mov_b32_e32 v9, v0
	v_mov_b32_e32 v10, v0
	v_mov_b32_e32 v11, v0
	v_mov_b32_e32 v12, v0
	v_mov_b32_e32 v13, v0
	v_mov_b32_e32 v14, v0
	v_mov_b32_e32 v15, v0
	v_mov_b32_e32 v16, v0
	v_mov_b32_e32 v17, v0
	v_mov_b32_e32 v18, v0
	v_mov_b32_e32 v19, v0
	v_mov_b32_e32 v20, v0
	v_mov_b32_e32 v21, v0
	v_mov_b32_e32 v22, v0
	v_mov_b32_e32 v23, v0
	v_mov_b32_e32 v24, v0
	v_mov_b32_e32 v25, v0
	v_mov_b32_e32 v26, v0
	v_mov_b32_e32 v27, v0
	v_mov_b32_e32 v28, v0
	v_mov_b32_e32 v29, v0
	v_mov_b32_e32 v30, v0
	v_mov_b32_e32 v31, v0
	.p2align	5, , 4
.LBB0_9:
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_add_i32 s9, s28, s33
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v131, s[4:7], s9 offen lds
	ds_read_b128 v[36:39], v133 offset:17024
	ds_read_b128 v[120:123], v133 offset:17056
	ds_read_b128 v[124:127], v133 offset:17536
	ds_read_b128 v[140:143], v133 offset:17568
	ds_read_b128 v[144:147], v133 offset:17088
	ds_read_b128 v[148:151], v133 offset:17120
	ds_read_b128 v[152:155], v133 offset:17600
	ds_read_b128 v[156:159], v133 offset:17632
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[92:95], 0
	v_exp_f32_e32 v108, v32
	v_exp_f32_e32 v109, v33
	v_exp_f32_e32 v102, v102
	v_exp_f32_e32 v114, v104
	v_exp_f32_e32 v115, v105
	v_exp_f32_e32 v110, v72
	v_exp_f32_e32 v101, v101
	v_mfma_f32_32x32x16_bf16 v[48:63], v[120:123], v[88:91], v[48:63]
	v_exp_f32_e32 v111, v73
	v_exp_f32_e32 v112, v34
	v_exp_f32_e32 v113, v35
	v_exp_f32_e32 v120, v74
	v_exp_f32_e32 v121, v75
	v_exp_f32_e32 v107, v107
	v_mfma_f32_32x32x16_bf16 v[32:47], v[124:127], v[92:95], 0
	v_exp_f32_e32 v106, v106
	v_exp_f32_e32 v103, v103
	v_exp_f32_e32 v100, v100
	v_mfma_f32_32x32x16_bf16 v[32:47], v[140:143], v[88:91], v[32:47]
	v_add_f32_e64 v72, v112, v76
	v_add_f32_e64 v73, v113, v77
	v_add_f32_e64 v74, v102, v70
	v_add_f32_e64 v75, v103, v71
	v_add_f32_e64 v104, v114, v78
	v_add_f32_e64 v105, v115, v79
	v_pk_add_f32 v[122:123], v[120:121], v[68:69]
	v_pk_add_f32 v[124:125], v[110:111], v[96:97]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[144:147], v[80:83], v[48:63]
	v_add_f32_e64 v126, v108, v64
	v_add_f32_e64 v127, v109, v65
	v_add_f32_e64 v140, v106, v98
	v_add_f32_e64 v141, v107, v99
	v_add_f32_e64 v142, v100, v66
	v_add_f32_e64 v143, v101, v67
	v_pk_add_f32 v[124:125], v[126:127], v[124:125]
	v_pk_add_f32 v[140:141], v[142:143], v[140:141]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[80:83], v[32:47]
	v_add_f32_e64 v104, v122, v104
	v_add_f32_e64 v105, v123, v105
	v_add_f32_e64 v72, v74, v72
	v_add_f32_e64 v73, v75, v73
	v_add_f32_e64 v74, v124, v140
	v_add_f32_e64 v75, v125, v141
	v_pk_add_f32 v[72:73], v[72:73], v[104:105]
	s_nop 0
	v_pk_add_f32 v[72:73], v[74:75], v[72:73]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[148:151], v[84:87], v[48:63]
	v_add_f32_e32 v72, v72, v73
	v_mov_b32_e32 v73, v72
	s_nop 1
	v_permlane32_swap_b32_e64 v72, v73 bound_ctrl:1
	v_add_f32_e32 v73, v138, v73
	v_add_f32_e32 v104, v73, v72
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v100, v101
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[84:87], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v64, v65
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v66, v67
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v120, v121
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v114, v115
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_add_i32 s9, s15, s33
	s_mov_b32 m0, s25
	s_nop 0
	buffer_load_dwordx4 v131, s[16:19], s9 offen lds
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v135 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v135 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v135 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v135 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v135 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v135 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v135 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v135 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v135 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v135 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v135 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v135 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v135 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v135 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v135 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v135 offset:960

	;;#ASMEND
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[0:15], v[106:109], v[64:67], v[0:15]
	v_max_f32_e32 v105, v48, v49
	v_max3_f32 v105, v105, v50, v51
	v_max3_f32 v105, v105, v52, v53
	v_max3_f32 v105, v105, v54, v55
	v_max3_f32 v105, v105, v56, v57
	v_max3_f32 v105, v105, v58, v59
	v_and_b32_e32 v107, 0xffff0000, v76
	v_mfma_f32_32x32x16_bf16 v[16:31], v[120:123], v[64:67], v[16:31]
	v_max3_f32 v64, v105, v60, v61
	v_max3_f32 v64, v64, v62, v63
	v_max3_f32 v64, v64, v32, v33
	v_max3_f32 v64, v64, v34, v35
	v_max3_f32 v64, v64, v36, v37
	v_max3_f32 v64, v64, v38, v39
	v_max3_f32 v64, v64, v40, v41
	v_max3_f32 v64, v64, v42, v43
	v_max3_f32 v64, v64, v44, v45
	v_max3_f32 v64, v64, v46, v47
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_max3_f32 v118, v134, v64, v65
	v_sub_f32_e32 v64, v134, v118
	v_exp_f32_e32 v64, v64
	v_lshlrev_b32_e32 v106, 16, v76
	v_and_b32_e32 v109, 0xffff0000, v77
	v_lshlrev_b32_e32 v108, 16, v77
	v_and_b32_e32 v77, 0xffff0000, v78
	v_lshlrev_b32_e32 v76, 16, v78
	v_and_b32_e32 v115, 0xffff0000, v79
	v_lshlrev_b32_e32 v114, 16, v79
	v_and_b32_e32 v67, 0xffff0000, v68
	v_lshlrev_b32_e32 v66, 16, v68
	v_and_b32_e32 v79, 0xffff0000, v69
	v_lshlrev_b32_e32 v78, 16, v69
	v_and_b32_e32 v69, 0xffff0000, v70
	v_lshlrev_b32_e32 v68, 16, v70
	v_and_b32_e32 v121, 0xffff0000, v71
	v_lshlrev_b32_e32 v120, 16, v71
	v_and_b32_e32 v71, 0xffff0000, v72
	v_lshlrev_b32_e32 v70, 16, v72
	v_and_b32_e32 v123, 0xffff0000, v73
	v_lshlrev_b32_e32 v122, 16, v73
	v_and_b32_e32 v73, 0xffff0000, v74
	v_lshlrev_b32_e32 v72, 16, v74
	v_and_b32_e32 v147, 0xffff0000, v75
	v_lshlrev_b32_e32 v146, 16, v75
	v_pk_mul_f32 v[14:15], v[64:65], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[64:65], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[64:65], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[64:65], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[64:65], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[64:65], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[64:65], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[64:65], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[64:65], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[64:65], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[64:65], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[64:65], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[64:65], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[64:65], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[64:65], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[64:65], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[74:75], v[64:65], v[146:147] op_sel_hi:[0,1]
	v_pk_mul_f32 v[146:147], v[64:65], v[72:73] op_sel_hi:[0,1]
	v_pk_mul_f32 v[72:73], v[64:65], v[120:121] op_sel_hi:[0,1]
	v_pk_mul_f32 v[120:121], v[64:65], v[68:69] op_sel_hi:[0,1]
	v_pk_mul_f32 v[78:79], v[64:65], v[78:79] op_sel_hi:[0,1]
	v_pk_mul_f32 v[148:149], v[64:65], v[66:67] op_sel_hi:[0,1]
	;;#ASMSTART
	;;#ASMEND
	v_cvt_pk_bf16_f32 v69, v72, v73
	v_cvt_pk_bf16_f32 v68, v120, v121
	v_cvt_pk_bf16_f32 v67, v78, v79
	v_cvt_pk_bf16_f32 v66, v148, v149
	v_pk_mul_f32 v[78:79], v[64:65], v[122:123] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v73, v74, v75
	v_mfma_f32_32x32x16_bf16 v[16:31], v[124:127], v[66:69], v[16:31]
	v_cvt_pk_bf16_f32 v72, v146, v147
	v_mul_f32_e64 v74, v64, v76
	v_mul_f32_e64 v75, v64, v77
	v_cvt_pk_bf16_f32 v76, v74, v75
	v_add_f32_e64 v48, v48, -v118
	v_add_f32_e64 v49, v49, -v118
	v_pk_add_f32 v[50:51], v[50:51], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[52:53], v[52:53], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[110:113], v[66:69], v[0:15]
	v_mul_f32_e64 v110, v64, v70
	v_mul_f32_e64 v111, v64, v71
	v_cvt_pk_bf16_f32 v71, v78, v79
	v_cvt_pk_bf16_f32 v70, v110, v111
	v_mul_f32_e64 v112, v64, v114
	v_mul_f32_e64 v113, v64, v115
	v_pk_mul_f32 v[78:79], v[64:65], v[108:109] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v77, v112, v113
	v_cvt_pk_bf16_f32 v75, v78, v79
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[70:73], v[16:31]
	v_add_f32_e64 v56, v56, -v118
	v_add_f32_e64 v57, v57, -v118
	v_add_f32_e64 v58, v58, -v118
	v_add_f32_e64 v59, v59, -v118
	v_add_f32_e64 v60, v60, -v118
	v_add_f32_e64 v61, v61, -v118
	v_pk_add_f32 v[62:63], v[62:63], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[32:33], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[66:67], v[34:35], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[68:69], v[36:37], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[100:103], v[70:73], v[0:15]
	v_mul_f32_e64 v100, v64, v106
	v_mul_f32_e64 v101, v64, v107
	v_cvt_pk_bf16_f32 v74, v100, v101
	v_exp_f32_e32 v100, v58
	v_exp_f32_e32 v101, v59
	v_exp_f32_e32 v102, v60
	v_exp_f32_e32 v103, v61
	v_exp_f32_e32 v106, v62
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[74:77], v[0:15]
	v_exp_f32_e32 v97, v49
	v_exp_f32_e32 v98, v56
	v_exp_f32_e32 v99, v57
	v_exp_f32_e32 v107, v63
	v_pk_add_f32 v[70:71], v[38:39], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[72:73], v[40:41], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[34:35], v[46:47], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[74:77], v[16:31]
	v_exp_f32_e32 v76, v50
	v_exp_f32_e32 v78, v52
	v_exp_f32_e32 v79, v53
	v_exp_f32_e32 v96, v48
	v_exp_f32_e32 v74, v54
	v_exp_f32_e32 v75, v55
	v_exp_f32_e32 v77, v51
	v_pk_add_f32 v[108:109], v[42:43], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[110:111], v[44:45], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_add_i32 s9, s30, s33
	s_mov_b32 m0, s21
	s_nop 0
	buffer_load_dwordx4 v131, s[4:7], s9 offen lds
	ds_read_b128 v[138:141], v133 offset:512
	ds_read_b128 v[36:39], v133
	ds_read_b128 v[124:127], v133 offset:32
	ds_read_b128 v[142:145], v133 offset:544
	ds_read_b128 v[146:149], v133 offset:64
	ds_read_b128 v[150:153], v133 offset:96
	ds_read_b128 v[154:157], v133 offset:576
	ds_read_b128 v[158:161], v133 offset:608
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[92:95], 0
	v_exp_f32_e32 v112, v32
	v_exp_f32_e32 v113, v33
	v_exp_f32_e32 v114, v66
	v_exp_f32_e32 v109, v109
	v_exp_f32_e32 v70, v70
	v_exp_f32_e32 v71, v71
	v_exp_f32_e32 v122, v72
	v_mfma_f32_32x32x16_bf16 v[48:63], v[124:127], v[88:91], v[48:63]
	v_exp_f32_e32 v69, v69
	v_exp_f32_e32 v111, v111
	v_exp_f32_e32 v120, v34
	v_exp_f32_e32 v115, v67
	v_exp_f32_e32 v110, v110
	v_exp_f32_e32 v68, v68
	v_mfma_f32_32x32x16_bf16 v[48:63], v[146:149], v[80:83], v[48:63]
	v_exp_f32_e32 v121, v35
	v_exp_f32_e32 v123, v73
	v_exp_f32_e32 v108, v108
	v_mfma_f32_32x32x16_bf16 v[32:47], v[138:141], v[92:95], 0
	v_add_f32_e64 v66, v98, v122
	v_add_f32_e64 v67, v99, v123
	v_add_f32_e64 v72, v100, v108
	v_add_f32_e64 v73, v101, v109
	v_add_f32_e64 v124, v76, v114
	v_add_f32_e64 v125, v77, v115
	v_pk_add_f32 v[126:127], v[106:107], v[120:121]
	v_pk_add_f32 v[138:139], v[74:75], v[70:71]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[142:145], v[88:91], v[32:47]
	v_add_f32_e64 v140, v102, v110
	v_add_f32_e64 v141, v103, v111
	v_add_f32_e64 v142, v78, v68
	v_add_f32_e64 v143, v79, v69
	v_add_f32_e64 v144, v96, v112
	v_add_f32_e64 v145, v97, v113
	v_pk_add_f32 v[140:141], v[142:143], v[140:141]
	v_pk_add_f32 v[126:127], v[138:139], v[126:127]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[80:83], v[32:47]
	v_add_f32_e64 v72, v124, v72
	v_add_f32_e64 v73, v125, v73
	v_add_f32_e64 v66, v144, v66
	v_add_f32_e64 v67, v145, v67
	v_add_f32_e64 v72, v72, v126
	v_add_f32_e64 v73, v73, v127
	v_pk_add_f32 v[66:67], v[66:67], v[140:141]
	s_nop 0
	v_pk_add_f32 v[66:67], v[66:67], v[72:73]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[150:153], v[84:87], v[48:63]
	v_add_f32_e32 v65, v66, v67
	v_mov_b32_e32 v66, v65
	s_nop 1
	v_permlane32_swap_b32_e64 v66, v65 bound_ctrl:1
	v_fmac_f32_e32 v65, v64, v104
	v_add_f32_e32 v136, v65, v66
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v114, v115
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[158:161], v[84:87], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v122, v123
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v120, v121
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_add_i32 s33, s31, s33
	s_mov_b32 m0, s27
	s_nop 0
	buffer_load_dwordx4 v131, s[16:19], s33 offen lds
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v119 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v119 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v119 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v119 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v119 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v119 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v119 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v119 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v119 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v119 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v119 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v119 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v119 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v119 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v119 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v119 offset:960

	;;#ASMEND
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[0:15], v[120:123], v[64:67], v[0:15]
	v_max_f32_e32 v120, v48, v49
	v_max3_f32 v120, v120, v50, v51
	v_max3_f32 v120, v120, v52, v53
	v_max3_f32 v120, v120, v54, v55
	v_max3_f32 v120, v120, v56, v57
	v_max3_f32 v120, v120, v58, v59
	v_and_b32_e32 v121, 0xffff0000, v68
	v_mfma_f32_32x32x16_bf16 v[16:31], v[124:127], v[64:67], v[16:31]
	v_max3_f32 v64, v120, v60, v61
	v_max3_f32 v64, v64, v62, v63
	v_max3_f32 v64, v64, v32, v33
	v_max3_f32 v64, v64, v34, v35
	v_max3_f32 v64, v64, v36, v37
	v_max3_f32 v64, v64, v38, v39
	v_max3_f32 v64, v64, v40, v41
	v_max3_f32 v64, v64, v42, v43
	v_max3_f32 v64, v64, v44, v45
	v_max3_f32 v64, v64, v46, v47
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_max3_f32 v134, v118, v64, v65
	v_sub_f32_e32 v64, v118, v134
	v_exp_f32_e32 v118, v64
	v_lshlrev_b32_e32 v120, 16, v68
	v_and_b32_e32 v65, 0xffff0000, v69
	v_lshlrev_b32_e32 v64, 16, v69
	v_and_b32_e32 v69, 0xffff0000, v71
	v_lshlrev_b32_e32 v68, 16, v71
	v_and_b32_e32 v67, 0xffff0000, v70
	v_lshlrev_b32_e32 v66, 16, v70
	v_pk_mul_f32 v[68:69], v[118:119], v[68:69] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[118:119], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[118:119], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[118:119], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[118:119], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[118:119], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[118:119], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[118:119], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[118:119], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[118:119], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[118:119], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[118:119], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[118:119], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[118:119], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[118:119], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[118:119], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[118:119], v[16:17] op_sel_hi:[0,1]
	v_and_b32_e32 v123, 0xffff0000, v72
	v_lshlrev_b32_e32 v122, 16, v72
	v_and_b32_e32 v125, 0xffff0000, v73
	v_lshlrev_b32_e32 v124, 16, v73
	v_and_b32_e32 v71, 0xffff0000, v74
	v_lshlrev_b32_e32 v70, 16, v74
	v_and_b32_e32 v73, 0xffff0000, v75
	v_lshlrev_b32_e32 v72, 16, v75
	v_pk_mul_f32 v[74:75], v[118:119], v[66:67] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v67, v68, v69
	v_pk_mul_f32 v[64:65], v[118:119], v[64:65] op_sel_hi:[0,1]
	v_pk_mul_f32 v[68:69], v[118:119], v[120:121] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v66, v74, v75
	v_cvt_pk_bf16_f32 v65, v64, v65
	v_cvt_pk_bf16_f32 v64, v68, v69
	;;#ASMSTART
	;;#ASMEND
	v_pk_mul_f32 v[68:69], v[118:119], v[72:73] op_sel_hi:[0,1]
	v_pk_mul_f32 v[72:73], v[118:119], v[70:71] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[104:107], v[64:67], v[0:15]
	v_cvt_pk_bf16_f32 v71, v68, v69
	v_cvt_pk_bf16_f32 v70, v72, v73
	v_mul_f32_e64 v68, v118, v124
	v_mul_f32_e64 v69, v118, v125
	v_mul_f32_e64 v72, v118, v122
	v_mul_f32_e64 v73, v118, v123
	v_cvt_pk_bf16_f32 v69, v68, v69
	v_cvt_pk_bf16_f32 v68, v72, v73
	v_and_b32_e32 v75, 0xffff0000, v79
	v_lshlrev_b32_e32 v74, 16, v79
	v_mfma_f32_32x32x16_bf16 v[0:15], v[100:103], v[68:71], v[0:15]
	v_and_b32_e32 v73, 0xffff0000, v76
	v_lshlrev_b32_e32 v72, 16, v76
	v_add_f32_e64 v48, v48, -v134
	v_add_f32_e64 v49, v49, -v134
	v_add_f32_e64 v50, v50, -v134
	v_add_f32_e64 v51, v51, -v134
	v_pk_add_f32 v[52:53], v[52:53], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[56:57], v[56:57], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[64:67], v[16:31]
	v_and_b32_e32 v65, 0xffff0000, v77
	v_lshlrev_b32_e32 v64, 16, v77
	v_and_b32_e32 v67, 0xffff0000, v78
	v_lshlrev_b32_e32 v66, 16, v78
	v_mul_f32_e64 v64, v118, v64
	v_mul_f32_e64 v65, v118, v65
	v_cvt_pk_bf16_f32 v65, v64, v65
	v_pk_add_f32 v[58:59], v[58:59], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[112:115], v[68:71], v[16:31]
	v_mul_f32_e64 v68, v118, v74
	v_mul_f32_e64 v69, v118, v75
	v_mul_f32_e64 v70, v118, v66
	v_mul_f32_e64 v71, v118, v67
	v_cvt_pk_bf16_f32 v67, v68, v69
	v_pk_mul_f32 v[68:69], v[118:119], v[72:73] op_sel_hi:[0,1]
	v_cvt_pk_bf16_f32 v66, v70, v71
	v_cvt_pk_bf16_f32 v64, v68, v69
	v_pk_add_f32 v[60:61], v[60:61], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[62:63], v[62:63], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[64:67], v[0:15]
	v_exp_f32_e32 v69, v55
	v_exp_f32_e32 v71, v51
	v_exp_f32_e32 v68, v54
	v_exp_f32_e32 v96, v56
	v_exp_f32_e32 v97, v57
	v_exp_f32_e32 v76, v58
	v_exp_f32_e32 v77, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[108:111], v[64:67], v[16:31]
	v_exp_f32_e32 v67, v53
	v_exp_f32_e32 v64, v48
	v_exp_f32_e32 v65, v49
	v_exp_f32_e32 v70, v50
	v_exp_f32_e32 v66, v52
	v_exp_f32_e32 v98, v60
	v_exp_f32_e32 v99, v61
	v_exp_f32_e32 v78, v62
	v_exp_f32_e32 v79, v63
	v_mul_f32_e32 v138, v118, v136
	v_pk_add_f32 v[32:33], v[32:33], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[102:103], v[34:35], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[100:101], v[36:37], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[74:75], v[38:39], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[72:73], v[40:41], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[34:35], v[42:43], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[106:107], v[44:45], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[104:105], v[46:47], v[134:135] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_setprio 0
	s_barrier
	s_add_u32 s22, s22, 2
	s_addc_u32 s23, s23, 0
	v_cmp_lt_u64_e32 vcc, s[22:23], v[116:117]
	s_mov_b32 s33, s9
	s_cbranch_vccnz .LBB0_9
	s_branch .LBB0_11
.LBB0_10:
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v138, 0
	v_mov_b32_e32 v14, v15
	v_mov_b32_e32 v13, v15
	v_mov_b32_e32 v12, v15
	v_mov_b32_e32 v11, v15
	v_mov_b32_e32 v10, v15
	v_mov_b32_e32 v9, v15
	v_mov_b32_e32 v8, v15
	v_mov_b32_e32 v7, v15
	v_mov_b32_e32 v6, v15
	v_mov_b32_e32 v5, v15
	v_mov_b32_e32 v4, v15
	v_mov_b32_e32 v3, v15
	v_mov_b32_e32 v2, v15
	v_mov_b32_e32 v1, v15
	v_mov_b32_e32 v0, v15
	v_mov_b32_e32 v31, v15
	v_mov_b32_e32 v30, v15
	v_mov_b32_e32 v29, v15
	v_mov_b32_e32 v28, v15
	v_mov_b32_e32 v27, v15
	v_mov_b32_e32 v26, v15
	v_mov_b32_e32 v25, v15
	v_mov_b32_e32 v24, v15
	v_mov_b32_e32 v23, v15
	v_mov_b32_e32 v22, v15
	v_mov_b32_e32 v21, v15
	v_mov_b32_e32 v20, v15
	v_mov_b32_e32 v19, v15
	v_mov_b32_e32 v18, v15
	v_mov_b32_e32 v17, v15
	v_mov_b32_e32 v16, v15
.LBB0_11:
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_lshl_b32 s9, s29, 6
	s_add_i32 s22, s9, 0xffffff40
	s_mul_i32 s15, s26, s22
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v131, s[4:7], s15 offen lds
	ds_read_b128 v[36:39], v133 offset:17024
	ds_read_b128 v[114:117], v133 offset:17056
	ds_read_b128 v[118:121], v133 offset:17536
	ds_read_b128 v[122:125], v133 offset:17568
	ds_read_b128 v[140:143], v133 offset:17088
	ds_read_b128 v[144:147], v133 offset:17120
	ds_read_b128 v[148:151], v133 offset:17600
	ds_read_b128 v[152:155], v133 offset:17632
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[92:95], 0
	v_exp_f32_e32 v108, v32
	v_exp_f32_e32 v109, v33
	v_exp_f32_e32 v102, v102
	v_exp_f32_e32 v104, v104
	v_exp_f32_e32 v105, v105
	v_exp_f32_e32 v110, v72
	v_exp_f32_e32 v101, v101
	v_mfma_f32_32x32x16_bf16 v[48:63], v[114:117], v[88:91], v[48:63]
	v_exp_f32_e32 v111, v73
	v_exp_f32_e32 v112, v34
	v_exp_f32_e32 v113, v35
	v_exp_f32_e32 v114, v74
	v_exp_f32_e32 v115, v75
	v_exp_f32_e32 v107, v107
	v_mfma_f32_32x32x16_bf16 v[32:47], v[118:121], v[92:95], 0
	v_exp_f32_e32 v106, v106
	v_exp_f32_e32 v103, v103
	v_exp_f32_e32 v100, v100
	v_mfma_f32_32x32x16_bf16 v[32:47], v[122:125], v[88:91], v[32:47]
	v_add_f32_e64 v72, v112, v76
	v_add_f32_e64 v73, v113, v77
	v_add_f32_e64 v74, v102, v70
	v_add_f32_e64 v75, v103, v71
	v_add_f32_e64 v116, v104, v78
	v_add_f32_e64 v117, v105, v79
	v_pk_add_f32 v[118:119], v[114:115], v[68:69]
	v_pk_add_f32 v[120:121], v[110:111], v[96:97]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[140:143], v[80:83], v[48:63]
	v_add_f32_e64 v122, v108, v64
	v_add_f32_e64 v123, v109, v65
	v_add_f32_e64 v124, v106, v98
	v_add_f32_e64 v125, v107, v99
	v_add_f32_e64 v126, v100, v66
	v_add_f32_e64 v127, v101, v67
	v_pk_add_f32 v[120:121], v[122:123], v[120:121]
	v_pk_add_f32 v[124:125], v[126:127], v[124:125]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[148:151], v[80:83], v[32:47]
	v_add_f32_e64 v116, v118, v116
	v_add_f32_e64 v117, v119, v117
	v_add_f32_e64 v72, v74, v72
	v_add_f32_e64 v73, v75, v73
	v_add_f32_e64 v74, v120, v124
	v_add_f32_e64 v75, v121, v125
	v_pk_add_f32 v[72:73], v[72:73], v[116:117]
	s_nop 0
	v_pk_add_f32 v[72:73], v[74:75], v[72:73]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[144:147], v[84:87], v[48:63]
	v_add_f32_e32 v139, v72, v73
	v_mov_b32_e32 v140, v139
	s_nop 1
	v_permlane32_swap_b32_e64 v139, v140 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v64, v65
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v114, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v98, v99
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[84:87], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v66, v67
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v104, v105
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_lshl_b32 s8, s8, 6
	s_mov_b32 m0, s25
	s_mul_i32 s15, s26, s8
	s_mov_b32 s18, s6
	s_mov_b32 s19, s7
	buffer_load_dwordx4 v131, s[16:19], s15 offen lds
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v135 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v135 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v135 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v135 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v135 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v135 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v135 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v135 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v135 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v135 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v135 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v135 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v135 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v135 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v135 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v135 offset:960

	;;#ASMEND
	s_add_i32 s16, s9, 0xffffff80
	s_cmp_le_i32 s16, s13
	s_cbranch_scc1 .LBB0_13
	v_lshl_or_b32 v136, v128, 2, s22
	v_or_b32_e32 v141, 32, v136
	v_mov_b32_e32 v142, 0xff800000
	v_cmp_gt_i32_e32 vcc, s13, v136
	v_or_b32_e32 v143, 33, v136
	s_nop 0
	v_cndmask_b32_e32 v48, v142, v48, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 1, v136
	s_nop 0
	v_cndmask_b32_e32 v32, v142, v32, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 2, v136
	s_nop 0
	v_cndmask_b32_e32 v49, v142, v49, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 34, v136
	s_nop 0
	v_cndmask_b32_e32 v33, v142, v33, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 3, v136
	s_nop 0
	v_cndmask_b32_e32 v50, v142, v50, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 35, v136
	s_nop 0
	v_cndmask_b32_e32 v34, v142, v34, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 8, v136
	s_nop 0
	v_cndmask_b32_e32 v51, v142, v51, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 40, v136
	s_nop 0
	v_cndmask_b32_e32 v35, v142, v35, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 9, v136
	s_nop 0
	v_cndmask_b32_e32 v52, v142, v52, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 41, v136
	s_nop 0
	v_cndmask_b32_e32 v36, v142, v36, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 10, v136
	s_nop 0
	v_cndmask_b32_e32 v53, v142, v53, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 42, v136
	s_nop 0
	v_cndmask_b32_e32 v37, v142, v37, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 11, v136
	s_nop 0
	v_cndmask_b32_e32 v54, v142, v54, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 43, v136
	s_nop 0
	v_cndmask_b32_e32 v38, v142, v38, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 16, v136
	s_nop 0
	v_cndmask_b32_e32 v55, v142, v55, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 48, v136
	s_nop 0
	v_cndmask_b32_e32 v39, v142, v39, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 17, v136
	s_nop 0
	v_cndmask_b32_e32 v56, v142, v56, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 49, v136
	s_nop 0
	v_cndmask_b32_e32 v40, v142, v40, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 18, v136
	s_nop 0
	v_cndmask_b32_e32 v57, v142, v57, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 50, v136
	s_nop 0
	v_cndmask_b32_e32 v41, v142, v41, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 19, v136
	s_nop 0
	v_cndmask_b32_e32 v58, v142, v58, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 51, v136
	s_nop 0
	v_cndmask_b32_e32 v42, v142, v42, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 24, v136
	s_nop 0
	v_cndmask_b32_e32 v59, v142, v59, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 56, v136
	s_nop 0
	v_cndmask_b32_e32 v43, v142, v43, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 25, v136
	s_nop 0
	v_cndmask_b32_e32 v60, v142, v60, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 57, v136
	s_nop 0
	v_cndmask_b32_e32 v44, v142, v44, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 26, v136
	s_nop 0
	v_cndmask_b32_e32 v61, v142, v61, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v143, 58, v136
	s_nop 0
	v_cndmask_b32_e32 v45, v142, v45, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	v_or_b32_e32 v141, 27, v136
	v_or_b32_e32 v136, 59, v136
	v_cndmask_b32_e32 v62, v142, v62, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	s_nop 1
	v_cndmask_b32_e32 v46, v142, v46, vcc
	v_cmp_gt_i32_e32 vcc, s13, v141
	s_nop 1
	v_cndmask_b32_e32 v63, v142, v63, vcc
	v_cmp_gt_i32_e32 vcc, s13, v136
	s_nop 1
	v_cndmask_b32_e32 v47, v142, v47, vcc
.LBB0_13:
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[0:15], v[120:123], v[64:67], v[0:15]
	v_max_f32_e32 v120, v48, v49
	v_max3_f32 v120, v120, v50, v51
	v_max3_f32 v120, v120, v52, v53
	v_max3_f32 v120, v120, v54, v55
	v_max3_f32 v120, v120, v56, v57
	v_mfma_f32_32x32x16_bf16 v[16:31], v[124:127], v[64:67], v[16:31]
	v_max3_f32 v64, v120, v58, v59
	v_max3_f32 v64, v64, v60, v61
	v_max3_f32 v64, v64, v62, v63
	v_max3_f32 v64, v64, v32, v33
	v_max3_f32 v64, v64, v34, v35
	v_mfma_f32_32x32x16_bf16 v[0:15], v[112:115], v[68:71], v[0:15]
	v_max3_f32 v64, v64, v36, v37
	v_max3_f32 v64, v64, v38, v39
	v_max3_f32 v64, v64, v40, v41
	v_max3_f32 v64, v64, v42, v43
	v_max3_f32 v64, v64, v44, v45
	v_mfma_f32_32x32x16_bf16 v[16:31], v[116:119], v[68:71], v[16:31]
	v_max3_f32 v64, v64, v46, v47
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_max3_f32 v136, v134, v64, v65
	v_sub_f32_e32 v64, v134, v136
	v_pk_add_f32 v[56:57], v[56:57], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[58:59], v[58:59], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[108:111], v[72:75], v[0:15]
	v_add_f32_e64 v48, v48, -v136
	v_add_f32_e64 v49, v49, -v136
	v_add_f32_e64 v60, v60, -v136
	v_add_f32_e64 v61, v61, -v136
	v_add_f32_e64 v50, v50, -v136
	v_add_f32_e64 v51, v51, -v136
	v_pk_add_f32 v[52:53], v[52:53], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[62:63], v[62:63], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[32:33], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[104:107], v[72:75], v[16:31]
	v_exp_f32_e32 v134, v64
	v_exp_f32_e32 v72, v48
	v_exp_f32_e32 v73, v49
	v_pk_add_f32 v[68:69], v[34:35], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[70:71], v[36:37], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[64:65], v[38:39], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[66:67], v[40:41], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[76:79], v[0:15]
	v_exp_f32_e32 v74, v50
	v_exp_f32_e32 v75, v51
	v_exp_f32_e32 v96, v52
	v_exp_f32_e32 v98, v58
	v_exp_f32_e32 v99, v59
	v_pk_add_f32 v[34:35], v[42:43], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[104:105], v[44:45], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[76:79], v[16:31]
	v_exp_f32_e32 v97, v53
	v_exp_f32_e32 v76, v54
	v_exp_f32_e32 v77, v55
	v_exp_f32_e32 v78, v56
	v_exp_f32_e32 v79, v57
	v_exp_f32_e32 v100, v60
	v_exp_f32_e32 v101, v61
	v_exp_f32_e32 v102, v62
	v_exp_f32_e32 v103, v63
	v_pk_add_f32 v[106:107], v[46:47], v[136:137] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[134:135], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[134:135], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[134:135], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[134:135], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[134:135], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[134:135], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[134:135], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[134:135], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[134:135], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[134:135], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[134:135], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[134:135], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[134:135], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[134:135], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[134:135], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[134:135], v[16:17] op_sel_hi:[0,1]
	;;#ASMSTART
	;;#ASMEND
	s_setprio 0
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_mul_i32 s26, s26, s16
	s_mov_b32 m0, s21
	s_nop 0
	buffer_load_dwordx4 v131, s[4:7], s26 offen lds
	ds_read_b128 v[36:39], v133
	ds_read_b128 v[114:117], v133 offset:32
	ds_read_b128 v[118:121], v133 offset:512
	ds_read_b128 v[122:125], v133 offset:544
	ds_read_b128 v[142:145], v133 offset:64
	ds_read_b128 v[146:149], v133 offset:96
	ds_read_b128 v[150:153], v133 offset:576
	ds_read_b128 v[154:157], v133 offset:608
	s_waitcnt vmcnt(2) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[92:95], 0
	v_exp_f32_e32 v108, v32
	v_exp_f32_e32 v109, v33
	v_exp_f32_e32 v68, v68
	v_exp_f32_e32 v106, v106
	v_exp_f32_e32 v107, v107
	v_exp_f32_e32 v110, v66
	v_exp_f32_e32 v71, v71
	v_mfma_f32_32x32x16_bf16 v[48:63], v[114:117], v[88:91], v[48:63]
	v_exp_f32_e32 v111, v67
	v_exp_f32_e32 v112, v34
	v_exp_f32_e32 v113, v35
	v_exp_f32_e32 v114, v64
	v_exp_f32_e32 v115, v65
	v_exp_f32_e32 v105, v105
	v_mfma_f32_32x32x16_bf16 v[32:47], v[118:121], v[92:95], 0
	v_exp_f32_e32 v104, v104
	v_exp_f32_e32 v69, v69
	v_exp_f32_e32 v70, v70
	v_mfma_f32_32x32x16_bf16 v[32:47], v[122:125], v[88:91], v[32:47]
	v_add_f32_e64 v64, v98, v112
	v_add_f32_e64 v65, v99, v113
	v_add_f32_e64 v66, v74, v68
	v_add_f32_e64 v67, v75, v69
	v_add_f32_e64 v116, v102, v106
	v_add_f32_e64 v117, v103, v107
	v_pk_add_f32 v[118:119], v[76:77], v[114:115]
	v_pk_add_f32 v[120:121], v[78:79], v[110:111]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[142:145], v[80:83], v[48:63]
	v_add_f32_e64 v122, v72, v108
	v_add_f32_e64 v123, v73, v109
	v_add_f32_e64 v124, v100, v104
	v_add_f32_e64 v125, v101, v105
	v_add_f32_e64 v126, v96, v70
	v_add_f32_e64 v127, v97, v71
	v_pk_add_f32 v[120:121], v[122:123], v[120:121]
	v_pk_add_f32 v[124:125], v[126:127], v[124:125]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[150:153], v[80:83], v[32:47]
	v_add_f32_e64 v116, v118, v116
	v_add_f32_e64 v117, v119, v117
	v_add_f32_e64 v64, v66, v64
	v_add_f32_e64 v65, v67, v65
	v_add_f32_e64 v66, v120, v124
	v_add_f32_e64 v67, v121, v125
	v_pk_add_f32 v[64:65], v[64:65], v[116:117]
	s_nop 0
	v_pk_add_f32 v[64:65], v[66:67], v[64:65]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[146:149], v[84:87], v[48:63]
	v_add_f32_e32 v141, v64, v65
	v_mov_b32_e32 v142, v141
	s_nop 1
	v_permlane32_swap_b32_e64 v142, v141 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v114, v115
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[84:87], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v104, v105
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v106, v107
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	v_add_u32_e32 v137, 0x6300, v137
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v137 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v137 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v137 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v137 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v137 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v137 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v137 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v137 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v137 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v137 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v137 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v137 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v137 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v137 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v137 offset:960

	;;#ASMEND
	s_add_i32 s17, s16, 64
	s_cmp_le_i32 s17, s13
	s_cbranch_scc1 .LBB0_15
	v_lshl_or_b32 v143, v128, 2, s16
	v_or_b32_e32 v144, 32, v143
	v_mov_b32_e32 v145, 0xff800000
	v_cmp_gt_i32_e32 vcc, s13, v143
	v_or_b32_e32 v146, 33, v143
	s_nop 0
	v_cndmask_b32_e32 v48, v145, v48, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 1, v143
	s_nop 0
	v_cndmask_b32_e32 v32, v145, v32, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 2, v143
	s_nop 0
	v_cndmask_b32_e32 v49, v145, v49, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 34, v143
	s_nop 0
	v_cndmask_b32_e32 v33, v145, v33, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 3, v143
	s_nop 0
	v_cndmask_b32_e32 v50, v145, v50, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 35, v143
	s_nop 0
	v_cndmask_b32_e32 v34, v145, v34, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 8, v143
	s_nop 0
	v_cndmask_b32_e32 v51, v145, v51, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 40, v143
	s_nop 0
	v_cndmask_b32_e32 v35, v145, v35, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 9, v143
	s_nop 0
	v_cndmask_b32_e32 v52, v145, v52, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 41, v143
	s_nop 0
	v_cndmask_b32_e32 v36, v145, v36, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 10, v143
	s_nop 0
	v_cndmask_b32_e32 v53, v145, v53, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 42, v143
	s_nop 0
	v_cndmask_b32_e32 v37, v145, v37, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 11, v143
	s_nop 0
	v_cndmask_b32_e32 v54, v145, v54, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 43, v143
	s_nop 0
	v_cndmask_b32_e32 v38, v145, v38, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 16, v143
	s_nop 0
	v_cndmask_b32_e32 v55, v145, v55, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 48, v143
	s_nop 0
	v_cndmask_b32_e32 v39, v145, v39, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 17, v143
	s_nop 0
	v_cndmask_b32_e32 v56, v145, v56, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 49, v143
	s_nop 0
	v_cndmask_b32_e32 v40, v145, v40, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 18, v143
	s_nop 0
	v_cndmask_b32_e32 v57, v145, v57, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 50, v143
	s_nop 0
	v_cndmask_b32_e32 v41, v145, v41, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 19, v143
	s_nop 0
	v_cndmask_b32_e32 v58, v145, v58, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 51, v143
	s_nop 0
	v_cndmask_b32_e32 v42, v145, v42, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 24, v143
	s_nop 0
	v_cndmask_b32_e32 v59, v145, v59, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 56, v143
	s_nop 0
	v_cndmask_b32_e32 v43, v145, v43, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 25, v143
	s_nop 0
	v_cndmask_b32_e32 v60, v145, v60, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 57, v143
	s_nop 0
	v_cndmask_b32_e32 v44, v145, v44, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 26, v143
	s_nop 0
	v_cndmask_b32_e32 v61, v145, v61, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	v_or_b32_e32 v146, 58, v143
	s_nop 0
	v_cndmask_b32_e32 v45, v145, v45, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	v_or_b32_e32 v144, 27, v143
	v_or_b32_e32 v143, 59, v143
	v_cndmask_b32_e32 v62, v145, v62, vcc
	v_cmp_gt_i32_e32 vcc, s13, v146
	s_nop 1
	v_cndmask_b32_e32 v46, v145, v46, vcc
	v_cmp_gt_i32_e32 vcc, s13, v144
	s_nop 1
	v_cndmask_b32_e32 v63, v145, v63, vcc
	v_cmp_gt_i32_e32 vcc, s13, v143
	s_nop 1
	v_cndmask_b32_e32 v47, v145, v47, vcc
.LBB0_15:
	s_waitcnt vmcnt(1) lgkmcnt(0)
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[0:15], v[120:123], v[64:67], v[0:15]
	v_max_f32_e32 v120, v48, v49
	v_max3_f32 v120, v120, v50, v51
	v_max3_f32 v120, v120, v52, v53
	v_max3_f32 v120, v120, v54, v55
	v_max3_f32 v120, v120, v56, v57
	v_mfma_f32_32x32x16_bf16 v[16:31], v[124:127], v[64:67], v[16:31]
	v_max3_f32 v64, v120, v58, v59
	v_max3_f32 v64, v64, v60, v61
	v_max3_f32 v64, v64, v62, v63
	v_max3_f32 v64, v64, v32, v33
	v_max3_f32 v64, v64, v34, v35
	v_mfma_f32_32x32x16_bf16 v[0:15], v[112:115], v[68:71], v[0:15]
	v_max3_f32 v64, v64, v36, v37
	v_max3_f32 v64, v64, v38, v39
	v_max3_f32 v64, v64, v40, v41
	v_max3_f32 v64, v64, v42, v43
	v_max3_f32 v64, v64, v44, v45
	v_mfma_f32_32x32x16_bf16 v[16:31], v[116:119], v[68:71], v[16:31]
	v_max3_f32 v64, v64, v46, v47
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_max3_f32 v112, v136, v64, v65
	v_sub_f32_e32 v64, v136, v112
	v_pk_add_f32 v[56:57], v[56:57], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[58:59], v[58:59], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[108:111], v[72:75], v[0:15]
	v_add_f32_e64 v48, v48, -v112
	v_add_f32_e64 v49, v49, -v112
	v_add_f32_e64 v60, v60, -v112
	v_add_f32_e64 v61, v61, -v112
	v_add_f32_e64 v50, v50, -v112
	v_add_f32_e64 v51, v51, -v112
	v_pk_add_f32 v[52:53], v[52:53], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[62:63], v[62:63], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v70, v56
	v_mfma_f32_32x32x16_bf16 v[16:31], v[104:107], v[72:75], v[16:31]
	v_exp_f32_e32 v114, v64
	v_exp_f32_e32 v68, v48
	v_exp_f32_e32 v69, v49
	v_exp_f32_e32 v71, v57
	v_pk_add_f32 v[32:33], v[32:33], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[104:105], v[34:35], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[106:107], v[36:37], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[76:79], v[0:15]
	v_exp_f32_e32 v72, v50
	v_exp_f32_e32 v73, v51
	v_exp_f32_e32 v74, v52
	v_exp_f32_e32 v96, v62
	v_exp_f32_e32 v97, v63
	v_pk_add_f32 v[64:65], v[38:39], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[66:67], v[40:41], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[76:79], v[16:31]
	v_exp_f32_e32 v75, v53
	v_exp_f32_e32 v98, v54
	v_exp_f32_e32 v99, v55
	v_exp_f32_e32 v76, v58
	v_exp_f32_e32 v77, v59
	v_exp_f32_e32 v78, v60
	v_exp_f32_e32 v79, v61
	v_pk_add_f32 v[34:35], v[42:43], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[100:101], v[44:45], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[102:103], v[46:47], v[112:113] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[114:115], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[114:115], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[114:115], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[114:115], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[114:115], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[114:115], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[114:115], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[114:115], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[114:115], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[114:115], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[114:115], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[114:115], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[114:115], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[114:115], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[114:115], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[114:115], v[16:17] op_sel_hi:[0,1]
	;;#ASMSTART
	;;#ASMEND
	s_setprio 0
	s_barrier
	;;#ASMSTART
	s_nop 7
	;;#ASMEND
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v131, s[4:7], s15 offen lds
	ds_read_b128 v[36:39], v133 offset:17024
	ds_read_b128 v[118:121], v133 offset:17056
	ds_read_b128 v[122:125], v133 offset:17536
	ds_read_b128 v[144:147], v133 offset:17568
	ds_read_b128 v[148:151], v133 offset:17088
	ds_read_b128 v[152:155], v133 offset:17120
	ds_read_b128 v[156:159], v133 offset:17600
	ds_read_b128 v[160:163], v133 offset:17632
	s_waitcnt vmcnt(1) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[92:95], 0
	v_exp_f32_e32 v108, v32
	v_exp_f32_e32 v109, v33
	v_exp_f32_e32 v104, v104
	v_exp_f32_e32 v110, v66
	v_exp_f32_e32 v101, v101
	v_mfma_f32_32x32x16_bf16 v[48:63], v[118:121], v[88:91], v[48:63]
	v_exp_f32_e32 v111, v67
	v_exp_f32_e32 v116, v34
	v_exp_f32_e32 v117, v35
	v_mfma_f32_32x32x16_bf16 v[32:47], v[122:125], v[92:95], 0
	v_exp_f32_e32 v100, v100
	v_exp_f32_e32 v105, v105
	v_exp_f32_e32 v92, v106
	v_exp_f32_e32 v94, v102
	v_exp_f32_e32 v95, v103
	v_exp_f32_e32 v102, v64
	v_exp_f32_e32 v103, v65
	v_mfma_f32_32x32x16_bf16 v[32:47], v[144:147], v[88:91], v[32:47]
	v_exp_f32_e32 v93, v107
	v_pk_add_f32 v[64:65], v[76:77], v[116:117]
	v_pk_add_f32 v[66:67], v[72:73], v[104:105]
	v_pk_add_f32 v[88:89], v[96:97], v[94:95]
	v_pk_add_f32 v[90:91], v[98:99], v[102:103]
	v_pk_add_f32 v[106:107], v[70:71], v[110:111]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[148:151], v[80:83], v[48:63]
	v_add_f32_e64 v118, v68, v108
	v_add_f32_e64 v119, v69, v109
	v_add_f32_e64 v120, v78, v100
	v_add_f32_e64 v121, v79, v101
	v_add_f32_e64 v122, v74, v92
	v_add_f32_e64 v123, v75, v93
	v_pk_add_f32 v[106:107], v[118:119], v[106:107]
	v_pk_add_f32 v[120:121], v[122:123], v[120:121]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[80:83], v[32:47]
	v_add_f32_e64 v80, v90, v88
	v_add_f32_e64 v81, v91, v89
	v_add_f32_e64 v64, v66, v64
	v_add_f32_e64 v65, v67, v65
	v_add_f32_e64 v66, v106, v120
	v_add_f32_e64 v67, v107, v121
	v_pk_add_f32 v[64:65], v[64:65], v[80:81]
	s_nop 0
	v_pk_add_f32 v[64:65], v[66:67], v[64:65]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[152:155], v[84:87], v[48:63]
	v_add_f32_e32 v113, v64, v65
	v_mov_b32_e32 v115, v113
	s_nop 1
	v_permlane32_swap_b32_e64 v115, v113 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v76, v77
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[160:163], v[84:87], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v104, v105
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v92, v93
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v116, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v94, v95
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v135 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v135 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v135 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v135 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[92:93], v135 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[94:95], v135 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[80:81], v135 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[82:83], v135 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v135 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v135 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v135 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v135 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[88:89], v135 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[90:91], v135 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[84:85], v135 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[86:87], v135 offset:960

	;;#ASMEND
	s_cmp_le_i32 s9, s13
	s_cbranch_scc1 .LBB0_17
	v_lshl_or_b32 v116, v128, 2, s8
	v_or_b32_e32 v117, 32, v116
	v_mov_b32_e32 v118, 0xff800000
	v_cmp_gt_i32_e32 vcc, s13, v116
	v_or_b32_e32 v119, 33, v116
	s_nop 0
	v_cndmask_b32_e32 v48, v118, v48, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 1, v116
	s_nop 0
	v_cndmask_b32_e32 v32, v118, v32, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 2, v116
	s_nop 0
	v_cndmask_b32_e32 v49, v118, v49, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 34, v116
	s_nop 0
	v_cndmask_b32_e32 v33, v118, v33, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 3, v116
	s_nop 0
	v_cndmask_b32_e32 v50, v118, v50, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 35, v116
	s_nop 0
	v_cndmask_b32_e32 v34, v118, v34, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 8, v116
	s_nop 0
	v_cndmask_b32_e32 v51, v118, v51, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 40, v116
	s_nop 0
	v_cndmask_b32_e32 v35, v118, v35, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 9, v116
	s_nop 0
	v_cndmask_b32_e32 v52, v118, v52, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 41, v116
	s_nop 0
	v_cndmask_b32_e32 v36, v118, v36, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 10, v116
	s_nop 0
	v_cndmask_b32_e32 v53, v118, v53, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 42, v116
	s_nop 0
	v_cndmask_b32_e32 v37, v118, v37, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 11, v116
	s_nop 0
	v_cndmask_b32_e32 v54, v118, v54, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 43, v116
	s_nop 0
	v_cndmask_b32_e32 v38, v118, v38, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 16, v116
	s_nop 0
	v_cndmask_b32_e32 v55, v118, v55, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 48, v116
	s_nop 0
	v_cndmask_b32_e32 v39, v118, v39, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 17, v116
	s_nop 0
	v_cndmask_b32_e32 v56, v118, v56, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 49, v116
	s_nop 0
	v_cndmask_b32_e32 v40, v118, v40, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 18, v116
	s_nop 0
	v_cndmask_b32_e32 v57, v118, v57, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 50, v116
	s_nop 0
	v_cndmask_b32_e32 v41, v118, v41, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 19, v116
	s_nop 0
	v_cndmask_b32_e32 v58, v118, v58, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 51, v116
	s_nop 0
	v_cndmask_b32_e32 v42, v118, v42, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 24, v116
	s_nop 0
	v_cndmask_b32_e32 v59, v118, v59, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 56, v116
	s_nop 0
	v_cndmask_b32_e32 v43, v118, v43, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 25, v116
	s_nop 0
	v_cndmask_b32_e32 v60, v118, v60, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 57, v116
	s_nop 0
	v_cndmask_b32_e32 v44, v118, v44, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 26, v116
	s_nop 0
	v_cndmask_b32_e32 v61, v118, v61, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	v_or_b32_e32 v119, 58, v116
	s_nop 0
	v_cndmask_b32_e32 v45, v118, v45, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	v_or_b32_e32 v117, 27, v116
	v_or_b32_e32 v116, 59, v116
	v_cndmask_b32_e32 v62, v118, v62, vcc
	v_cmp_gt_i32_e32 vcc, s13, v119
	s_nop 1
	v_cndmask_b32_e32 v46, v118, v46, vcc
	v_cmp_gt_i32_e32 vcc, s13, v117
	s_nop 1
	v_cndmask_b32_e32 v63, v118, v63, vcc
	v_cmp_gt_i32_e32 vcc, s13, v116
	s_nop 1
	v_cndmask_b32_e32 v47, v118, v47, vcc
.LBB0_17:
	s_load_dwordx2 s[0:1], s[0:1], 0x90
	v_add_f32_e32 v116, v138, v140
	v_add_f32_e32 v116, v116, v139
	v_fmac_f32_e32 v141, v134, v116
	v_add_f32_e32 v116, v141, v142
	s_waitcnt lgkmcnt(0)
	s_add_u32 s8, s12, s0
	v_fmac_f32_e32 v113, v114, v116
	s_addc_u32 s0, s3, s1
	v_add_f32_e32 v114, v113, v115
	v_or_b32_e32 v113, s20, v132
	s_and_b32 s9, s0, 0xffff
	s_mov_b32 s11, 0x27000
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[0:15], v[108:111], v[64:67], v[0:15]
	v_max_f32_e32 v108, v48, v49
	v_max3_f32 v108, v108, v50, v51
	v_max3_f32 v108, v108, v52, v53
	v_max3_f32 v108, v108, v54, v55
	v_max3_f32 v108, v108, v56, v57
	v_max3_f32 v108, v108, v58, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[104:107], v[64:67], v[16:31]
	v_max3_f32 v64, v108, v60, v61
	v_max3_f32 v64, v64, v62, v63
	v_max3_f32 v64, v64, v32, v33
	v_max3_f32 v64, v64, v34, v35
	v_max3_f32 v64, v64, v36, v37
	v_max3_f32 v64, v64, v38, v39
	v_mfma_f32_32x32x16_bf16 v[0:15], v[100:103], v[68:71], v[0:15]
	v_max3_f32 v64, v64, v40, v41
	v_max3_f32 v64, v64, v42, v43
	v_max3_f32 v64, v64, v44, v45
	v_max3_f32 v64, v64, v46, v47
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[96:99], v[68:71], v[16:31]
	v_max3_f32 v66, v112, v64, v65
	v_sub_f32_e32 v64, v112, v66
	v_add_f32_e64 v48, v48, -v66
	v_add_f32_e64 v49, v49, -v66
	v_add_f32_e64 v50, v50, -v66
	v_add_f32_e64 v51, v51, -v66
	v_pk_add_f32 v[52:53], v[52:53], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[34:35], v[34:35], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[92:95], v[72:75], v[0:15]
	v_add_f32_e64 v56, v56, -v66
	v_add_f32_e64 v57, v57, -v66
	v_add_f32_e64 v38, v38, -v66
	v_add_f32_e64 v39, v39, -v66
	v_add_f32_e64 v58, v58, -v66
	v_add_f32_e64 v59, v59, -v66
	v_pk_add_f32 v[60:61], v[60:61], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[62:63], v[62:63], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[32:33], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[36:37], v[36:37], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[88:91], v[72:75], v[16:31]
	v_add_f32_e64 v40, v40, -v66
	v_add_f32_e64 v41, v41, -v66
	v_exp_f32_e32 v64, v64
	v_exp_f32_e32 v48, v48
	v_exp_f32_e32 v49, v49
	v_exp_f32_e32 v59, v59
	v_exp_f32_e32 v60, v60
	v_exp_f32_e32 v61, v61
	v_mfma_f32_32x32x16_bf16 v[0:15], v[80:83], v[76:79], v[0:15]
	v_exp_f32_e32 v50, v50
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v52, v52
	v_exp_f32_e32 v62, v62
	v_exp_f32_e32 v63, v63
	v_pk_add_f32 v[42:43], v[42:43], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[44:45], v[44:45], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[84:87], v[76:79], v[16:31]
	v_exp_f32_e32 v53, v53
	v_exp_f32_e32 v54, v54
	v_exp_f32_e32 v55, v55
	v_exp_f32_e32 v56, v56
	v_exp_f32_e32 v57, v57
	v_exp_f32_e32 v58, v58
	v_pk_add_f32 v[46:47], v[46:47], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v66, v32
	v_exp_f32_e32 v67, v33
	v_exp_f32_e32 v68, v34
	v_exp_f32_e32 v69, v35
	v_exp_f32_e32 v36, v36
	v_exp_f32_e32 v37, v37
	v_exp_f32_e32 v38, v38
	v_exp_f32_e32 v39, v39
	v_exp_f32_e32 v70, v40
	v_exp_f32_e32 v71, v41
	v_exp_f32_e32 v72, v42
	v_exp_f32_e32 v73, v43
	v_exp_f32_e32 v74, v44
	v_exp_f32_e32 v76, v46
	v_exp_f32_e32 v77, v47
	v_exp_f32_e32 v75, v45
	v_pk_add_f32 v[32:33], v[58:59], v[72:73]
	v_pk_add_f32 v[34:35], v[50:51], v[68:69]
	v_pk_add_f32 v[40:41], v[62:63], v[76:77]
	v_pk_add_f32 v[42:43], v[54:55], v[38:39]
	v_pk_add_f32 v[44:45], v[56:57], v[70:71]
	v_pk_add_f32 v[46:47], v[48:49], v[66:67]
	v_pk_add_f32 v[78:79], v[60:61], v[74:75]
	v_pk_add_f32 v[80:81], v[52:53], v[36:37]
	v_pk_add_f32 v[44:45], v[46:47], v[44:45]
	v_pk_add_f32 v[78:79], v[80:81], v[78:79]
	v_pk_add_f32 v[40:41], v[42:43], v[40:41]
	v_pk_add_f32 v[32:33], v[34:35], v[32:33]
	v_pk_add_f32 v[34:35], v[44:45], v[78:79]
	v_pk_add_f32 v[32:33], v[32:33], v[40:41]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v40, v66, v67
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v41, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v42, v36, v37
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v43, v38, v39
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v36, v56, v57
	;;#ASMEND
	s_nop 0
	v_pk_add_f32 v[32:33], v[34:35], v[32:33]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v34, v52, v53
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v35, v54, v55
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v37, v58, v59
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v38, v60, v61
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v39, v62, v63
	;;#ASMEND
	s_nop 0
	v_add_f32_e32 v32, v32, v33
	v_mov_b32_e32 v33, v32
	s_nop 1
	v_permlane32_swap_b32_e64 v33, v32 bound_ctrl:1
	v_fmac_f32_e32 v32, v64, v114
	v_add_f32_e32 v80, v32, v33
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v32, v48, v49
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v33, v50, v51
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v44, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v45, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v46, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v47, v76, v77
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	;;#ASMEND
	v_pk_mul_f32 v[62:63], v[64:65], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[60:61], v[64:65], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[64:65], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[64:65], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[54:55], v[64:65], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[64:65], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[64:65], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[64:65], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[64:65], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[64:65], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[64:65], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[64:65], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[64:65], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[64:65], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[64:65], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[64:65], v[16:17] op_sel_hi:[0,1]
	;;#ASMSTART
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[16:17], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[18:19], v137 offset:128

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[20:21], v137 offset:256

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[22:23], v137 offset:384

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[24:25], v137 offset:512

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[26:27], v137 offset:640

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[28:29], v137 offset:768

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[30:31], v137 offset:896

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[64:65], v137 offset:64

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[66:67], v137 offset:192

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[68:69], v137 offset:320

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[70:71], v137 offset:448

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[72:73], v137 offset:576

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[74:75], v137 offset:704

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[76:77], v137 offset:832

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[78:79], v137 offset:960

	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[16:19], v[32:35], v[48:63]
	v_rcp_f32_e32 v16, v80
	v_cmp_lt_f32_e32 vcc, 0, v80
	;;#ASMSTART
	s_cmp_eq_u32 s24, 0
	s_cbranch_scc0 1f
	s_barrier
	1:
	;;#ASMEND
	s_nop 1
	v_cndmask_b32_e32 v16, 0, v16, vcc
	v_cmp_eq_u64_e32 vcc, 0, v[128:129]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[64:67], v[32:35], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[20:23], v[36:39], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[68:71], v[36:39], v[0:15]
	v_mul_lo_u32 v36, v113, s14
	v_or_b32_e32 v37, s2, v130
	v_mfma_f32_32x32x16_bf16 v[48:63], v[24:27], v[40:43], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[72:75], v[40:43], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[28:31], v[44:47], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[76:79], v[44:47], v[0:15]
	s_nop 10
	v_mul_f32_e64 v26, v54, v16
	v_mul_f32_e64 v27, v55, v16
	v_mul_f32_e64 v18, v62, v16
	v_mul_f32_e64 v19, v63, v16
	v_mul_f32_e64 v20, v60, v16
	v_mul_f32_e64 v21, v61, v16
	v_pk_mul_f32 v[22:23], v[58:59], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[56:57], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[52:53], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[50:51], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[48:49], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[2:3], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[0:1], v[16:17] op_sel_hi:[1,0]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v32, v33
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v3, v26, v27
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v30, v31
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v2, v28, v29
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v18, v18, v19
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v4, v5
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v26, v0
	v_mov_b32_e32 v27, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v26, v27
	v_mov_b32_e32 v26, v1
	v_mov_b32_e32 v28, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v26, v28
	v_mov_b32_e32 v26, v2
	v_mov_b32_e32 v29, v2
	s_nop 1
	v_permlane32_swap_b32_e32 v26, v29
	v_mov_b32_e32 v29, v3
	v_mov_b32_e32 v30, v3
	s_nop 1
	v_permlane32_swap_b32_e32 v29, v30
	v_cndmask_b32_e32 v0, v26, v0, vcc
	v_cndmask_b32_e32 v1, v29, v1, vcc
	v_cndmask_b32_e32 v2, v2, v27, vcc
	v_cndmask_b32_e32 v3, v3, v28, vcc
	v_add_lshl_u32 v26, v37, v36, 1
	buffer_store_dwordx4 v[0:3], v26, s[8:11], 0 offen
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v6, v6, v7
	;;#ASMEND
	v_mov_b32_e32 v7, v4
	s_nop 0
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v24, v25
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v2, v20, v21
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v22, v23
	;;#ASMEND
	v_mov_b32_e32 v22, v18
	v_mov_b32_e32 v3, v0
	v_mov_b32_e32 v20, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v20
	v_mov_b32_e32 v3, v1
	v_mov_b32_e32 v19, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v19
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v21, v2
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v21
	v_mov_b32_e32 v21, v18
	s_nop 1
	v_permlane32_swap_b32_e32 v21, v22
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_cndmask_b32_e32 v1, v21, v1, vcc
	v_cndmask_b32_e32 v2, v2, v20, vcc
	v_cndmask_b32_e32 v3, v18, v19, vcc
	buffer_store_dwordx4 v[0:3], v26, s[8:11], 0 offen offset:32
	s_nop 1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v16, v17
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v34, v35
	;;#ASMEND
	v_mov_b32_e32 v16, v6
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v3
	v_mov_b32_e32 v2, v1
	v_mov_b32_e32 v5, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v5
	v_mov_b32_e32 v2, v4
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v7
	v_mov_b32_e32 v7, v6
	s_nop 1
	v_permlane32_swap_b32_e32 v7, v16
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cndmask_b32_e32 v1, v7, v1, vcc
	v_cndmask_b32_e32 v2, v4, v3, vcc
	v_cndmask_b32_e32 v3, v6, v5, vcc
	buffer_store_dwordx4 v[0:3], v26, s[8:11], 0 offen offset:64
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v12, v13
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v7, v14, v15
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v6, v5
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v8, v9
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v3, v10, v11
	;;#ASMEND
	v_mov_b32_e32 v8, v7
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v2
	v_mov_b32_e32 v1, v3
	v_mov_b32_e32 v4, v3
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v4
	v_mov_b32_e32 v1, v5
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v6
	v_mov_b32_e32 v6, v7
	s_nop 1
	v_permlane32_swap_b32_e32 v6, v8
	v_cndmask_b32_e32 v0, v1, v0, vcc
	v_cndmask_b32_e32 v1, v6, v3, vcc
	v_cndmask_b32_e32 v2, v5, v2, vcc
	v_cndmask_b32_e32 v3, v7, v4, vcc
	buffer_store_dwordx4 v[0:3], v26, s[8:11], 0 offen offset:96
	s_endpgm
.Lfunc_end0:
	.size	flash_attn_dualwave_swp_gfx950_kernel_0, .Lfunc_end0-flash_attn_dualwave_swp_gfx950_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel flash_attn_dualwave_swp_gfx950_kernel_0
		.amdhsa_group_segment_fixed_size 34048
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 608
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
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 164
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 164
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

	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.num_vgpr, 164
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.num_agpr, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.numbered_sgpr, 40
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.num_named_barrier, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.private_seg_size, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.uses_vcc, 1
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.uses_flat_scratch, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.has_dyn_sized_stack, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.has_recursion, 0
	.set .Lflash_attn_dualwave_swp_gfx950_kernel_0.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
      - .offset:         104
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         144
        .size:           8
        .value_kind:     global_buffer
      - .offset:         152
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         192
        .size:           8
        .value_kind:     global_buffer
      - .offset:         200
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         240
        .size:           8
        .value_kind:     global_buffer
      - .offset:         248
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         288
        .size:           8
        .value_kind:     global_buffer
      - .offset:         296
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         336
        .size:           8
        .value_kind:     global_buffer
      - .offset:         344
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         384
        .size:           8
        .value_kind:     global_buffer
      - .offset:         392
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         432
        .size:           8
        .value_kind:     global_buffer
      - .offset:         440
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         480
        .size:           8
        .value_kind:     global_buffer
      - .offset:         488
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         528
        .size:           8
        .value_kind:     global_buffer
      - .offset:         536
        .size:           40
        .value_kind:     by_value
      - .offset:         576
        .size:           4
        .value_kind:     by_value
      - .offset:         580
        .size:           4
        .value_kind:     by_value
      - .offset:         584
        .size:           4
        .value_kind:     by_value
      - .offset:         588
        .size:           4
        .value_kind:     by_value
      - .offset:         592
        .size:           4
        .value_kind:     by_value
      - .offset:         596
        .size:           4
        .value_kind:     by_value
      - .offset:         600
        .size:           4
        .value_kind:     by_value
      - .offset:         604
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 34048
    .kernarg_segment_align: 8
    .kernarg_segment_size: 608
    .max_flat_workgroup_size: 512
    .name:           flash_attn_dualwave_swp_gfx950_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 512
      - 1
      - 1
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         flash_attn_dualwave_swp_gfx950_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     164
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
