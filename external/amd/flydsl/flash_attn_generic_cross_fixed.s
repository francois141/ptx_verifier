; FlyDSL 304d441202a3 kernels/attention/flash_attn_generic.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case flash_attn_generic_cross_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	flash_attn_generic_kernel_0
	.p2align	8
	.type	flash_attn_generic_kernel_0,@function
flash_attn_generic_kernel_0:
	s_load_dwordx2 s[4:5], s[0:1], 0xf0
	s_ashr_i32 s3, s2, 31
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s7, s4, 31
	s_add_u32 s8, s4, 63
	s_addc_u32 s9, s7, 0
	s_lshr_b64 s[8:9], s[8:9], 6
	s_or_b64 s[10:11], s[2:3], s[8:9]
	s_cmp_lg_u32 s11, 0
	s_mov_b32 s6, s4
	s_cbranch_scc0 .LBB0_2
	v_cvt_f32_u32_e32 v1, s8
	v_cvt_f32_u32_e32 v2, s9
	s_sub_u32 s4, 0, s8
	s_subb_u32 s10, 0, s9
	s_mov_b64 s[12:13], 0
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s11, v2
	v_readfirstlane_b32 s14, v1
	s_mul_i32 s15, s4, s11
	s_mul_hi_u32 s17, s4, s14
	s_mul_i32 s16, s10, s14
	s_add_i32 s15, s17, s15
	s_add_i32 s15, s15, s16
	s_mul_i32 s18, s4, s14
	s_mul_i32 s17, s14, s15
	s_mul_hi_u32 s19, s14, s18
	s_mul_hi_u32 s16, s14, s15
	s_add_u32 s17, s19, s17
	s_addc_u32 s16, 0, s16
	s_mul_hi_u32 s19, s11, s18
	s_mul_i32 s18, s11, s18
	s_add_u32 s17, s17, s18
	s_addc_u32 s16, s16, s19
	s_mul_hi_u32 s17, s11, s15
	s_addc_u32 s17, s17, 0
	s_mul_i32 s15, s11, s15
	s_add_u32 s15, s16, s15
	s_addc_u32 s16, 0, s17
	s_add_u32 s14, s14, s15
	s_addc_u32 s11, s11, s16
	s_mul_i32 s15, s4, s14
	s_mul_i32 s18, s4, s11
	s_mul_hi_u32 s4, s4, s14
	s_add_i32 s4, s4, s18
	s_mul_i32 s10, s10, s14
	s_add_i32 s4, s4, s10
	s_mul_hi_u32 s16, s11, s15
	s_mul_i32 s17, s11, s15
	s_mul_i32 s18, s14, s4
	s_mul_hi_u32 s15, s14, s15
	s_mul_hi_u32 s10, s14, s4
	s_add_u32 s15, s15, s18
	s_addc_u32 s10, 0, s10
	s_add_u32 s15, s15, s17
	s_addc_u32 s10, s10, s16
	s_mul_hi_u32 s15, s11, s4
	s_addc_u32 s15, s15, 0
	s_mul_i32 s4, s11, s4
	s_add_u32 s4, s10, s4
	s_addc_u32 s10, 0, s15
	s_add_u32 s4, s14, s4
	s_addc_u32 s10, s11, s10
	s_mul_i32 s14, s2, s10
	s_mul_hi_u32 s15, s2, s4
	s_mul_hi_u32 s11, s2, s10
	s_add_u32 s14, s15, s14
	s_addc_u32 s11, 0, s11
	s_mul_hi_u32 s15, s3, s4
	s_mul_i32 s4, s3, s4
	s_add_u32 s4, s14, s4
	s_addc_u32 s4, s11, s15
	s_mul_hi_u32 s11, s3, s10
	s_addc_u32 s11, s11, 0
	s_mul_i32 s10, s3, s10
	s_add_u32 s4, s4, s10
	s_addc_u32 s14, 0, s11
	s_mul_i32 s10, s8, s14
	s_mul_hi_u32 s11, s8, s4
	s_add_i32 s10, s11, s10
	s_mul_i32 s11, s9, s4
	s_add_i32 s15, s10, s11
	s_sub_i32 s16, s3, s15
	s_mul_i32 s10, s8, s4
	s_sub_u32 s17, s2, s10
	s_cselect_b64 s[10:11], -1, 0
	s_subb_u32 s16, s16, s9
	s_sub_u32 s18, s17, s8
	s_subb_u32 s16, s16, 0
	s_cmp_ge_u32 s16, s9
	s_cselect_b32 s19, -1, 0
	s_cmp_ge_u32 s18, s8
	s_cselect_b32 s18, -1, 0
	s_cmp_eq_u32 s16, s9
	s_cselect_b32 s16, s18, s19
	s_add_u32 s18, s4, 1
	s_addc_u32 s19, s14, 0
	s_add_u32 s20, s4, 2
	s_addc_u32 s21, s14, 0
	s_cmp_lg_u32 s16, 0
	s_cselect_b32 s16, s20, s18
	s_cselect_b32 s18, s21, s19
	s_cmp_lg_u64 s[10:11], 0
	s_subb_u32 s10, s3, s15
	s_cmp_ge_u32 s10, s9
	s_cselect_b32 s11, -1, 0
	s_cmp_ge_u32 s17, s8
	s_cselect_b32 s15, -1, 0
	s_cmp_eq_u32 s10, s9
	s_cselect_b32 s10, s15, s11
	s_cmp_lg_u32 s10, 0
	s_cselect_b32 s11, s18, s14
	s_cselect_b32 s10, s16, s4
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[12:13], -1
.LBB0_3:
	s_and_b64 s[12:13], s[12:13], exec
	s_cselect_b32 s4, 1, 0
	s_cmp_lg_u32 s4, 1
	s_cbranch_scc1 .LBB0_5
	v_cvt_f32_u32_e32 v1, s8
	s_sub_i32 s4, 0, s8
	s_mov_b32 s11, 0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s10, v1
	s_mul_i32 s4, s4, s10
	s_mul_hi_u32 s4, s10, s4
	s_add_i32 s10, s10, s4
	s_mul_hi_u32 s4, s2, s10
	s_mul_i32 s12, s4, s8
	s_sub_i32 s12, s2, s12
	s_add_i32 s10, s4, 1
	s_sub_i32 s13, s12, s8
	s_cmp_ge_u32 s12, s8
	s_cselect_b32 s4, s10, s4
	s_cselect_b32 s12, s13, s12
	s_add_i32 s10, s4, 1
	s_cmp_ge_u32 s12, s8
	s_cselect_b32 s10, s10, s4
.LBB0_5:
	s_mul_i32 s4, s10, s9
	s_mul_hi_u32 s9, s10, s8
	s_add_i32 s4, s9, s4
	s_mul_i32 s9, s11, s8
	s_add_i32 s4, s4, s9
	s_mul_i32 s8, s10, s8
	s_sub_u32 s2, s2, s8
	s_subb_u32 s3, s3, s4
	v_lshrrev_b32_e32 v1, 1, v0
	s_lshl_b64 s[2:3], s[2:3], 6
	v_and_b32_e32 v2, 31, v0
	v_and_or_b32 v1, v1, 32, s2
	v_bfe_u32 v84, v0, 5, 1
	s_lshl_b64 s[70:71], s[6:7], 7
	v_mov_b32_e32 v7, s3
	v_or_b32_e32 v6, v1, v2
	s_mul_i32 s4, s70, s11
	s_mul_hi_u32 s8, s70, s10
	s_lshr_b64 s[6:7], s[6:7], 25
	v_lshlrev_b32_e32 v4, 3, v84
	v_lshlrev_b64 v[82:83], 6, v[6:7]
	s_add_i32 s33, s8, s4
	s_mul_i32 s4, s6, s10
	v_or_b32_e32 v1, v82, v4
	v_or_b32_e32 v6, 32, v4
	s_add_i32 s33, s33, s4
	v_lshlrev_b32_e32 v83, 1, v1
	v_or_b32_e32 v1, v82, v6
	v_mov_b32_e32 v85, 0
	v_lshrrev_b32_e32 v80, 5, v0
	s_mul_i32 s83, s70, s10
	s_cmp_lt_i32 s5, 1
	v_lshlrev_b32_e32 v81, 1, v1
	s_cbranch_scc1 .LBB0_8
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_ashr_i32 s73, s5, 31
	v_or_b32_e32 v1, 16, v4
	v_or_b32_e32 v3, v82, v1
	v_or_b32_e32 v5, 48, v4
	s_waitcnt lgkmcnt(0)
	s_add_u32 s68, s2, s83
	s_addc_u32 s2, s3, s33
	s_and_b32 s69, s2, 0xffff
	s_mov_b32 s71, 0x27000
	v_lshlrev_b32_e32 v3, 1, v3
	v_or_b32_e32 v7, v82, v5
	buffer_load_dwordx4 v[112:115], v83, s[68:71], 0 offen
	buffer_load_dwordx4 v[116:119], v81, s[68:71], 0 offen
	v_lshlrev_b32_e32 v7, 1, v7
	buffer_load_dwordx4 v[120:123], v3, s[68:71], 0 offen
	buffer_load_dwordx4 v[124:127], v7, s[68:71], 0 offen
	v_lshlrev_b32_e32 v3, 4, v0
	v_and_b32_e32 v3, 48, v3
	v_lshlrev_b32_e32 v2, 6, v2
	s_mul_i32 s2, s5, s11
	s_mul_hi_u32 s3, s5, s10
	v_bitop3_b32 v1, v1, v2, v3 bitop3:0xde
	v_lshrrev_b32_e32 v86, 2, v0
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s73, s10
	v_lshlrev_b32_e32 v97, 1, v1
	v_bitop3_b32 v1, v6, v2, v3 bitop3:0xde
	v_lshlrev_b32_e32 v90, 2, v84
	s_load_dwordx2 s[74:75], s[0:1], 0x30
	s_load_dwordx2 s[76:77], s[0:1], 0x60
	s_add_i32 s3, s2, s3
	s_mul_i32 s2, s5, s10
	v_xor_b32_e32 v8, v86, v0
	v_or3_b32 v4, v4, v3, v2
	v_lshlrev_b32_e32 v98, 1, v1
	v_bitop3_b32 v1, v5, v2, v3 bitop3:0xde
	v_and_or_b32 v2, v86, 3, v90
	s_lshl_b64 s[2:3], s[2:3], 6
	v_and_b32_e32 v7, 16, v0
	v_lshlrev_b32_e32 v8, 5, v8
	v_lshlrev_b32_e32 v99, 1, v1
	v_mul_u32_u24_e32 v1, 0x44, v86
	v_lshlrev_b32_e32 v0, 2, v0
	v_mul_u32_u24_e32 v2, 0x44, v2
	s_add_u32 s78, s5, -1
	v_or_b32_e32 v88, s2, v3
	v_and_b32_e32 v8, 0x60, v8
	v_add_lshl_u32 v1, v1, v3, 1
	v_and_or_b32 v0, v0, 12, v7
	v_or_b32_e32 v3, 0x1000, v2
	v_add_u32_e32 v2, 0x1440, v2
	s_mov_b32 s72, s5
	s_addc_u32 s79, s73, -1
	v_lshl_or_b32 v94, v86, 7, v8
	v_add_lshl_u32 v100, v3, v0, 1
	v_add_lshl_u32 v101, v2, v0, 1
	v_or_b32_e32 v0, 32, v0
	v_mov_b32_e32 v87, v85
	v_mov_b32_e32 v89, s3
	v_or_b32_e32 v95, 0x1000, v94
	v_lshlrev_b32_e32 v96, 1, v4
	v_add_lshl_u32 v102, v3, v0, 1
	v_add_lshl_u32 v103, v2, v0, 1
	s_mov_b64 s[80:81], 0
	v_mov_b32_e32 v91, 0
	v_mov_b32_e32 v107, 0xff800000
	v_mov_b32_e32 v104, s79
	v_mov_b32_e32 v105, s78
	v_mov_b32_e32 v106, 0xff800000
	s_mov_b32 s82, 0x3e38aa3b
	v_add_u32_e32 v108, 0x2000, v1
	v_add_u32_e32 v109, 0x2010, v1
	v_add_u32_e32 v110, 0x3100, v1
	v_add_u32_e32 v111, 0x3110, v1
	s_mov_b32 s71, 0x7060302
	v_mov_b64_e32 v[92:93], s[72:73]
	v_mov_b32_e32 v0, v85
	v_mov_b32_e32 v1, v85
	v_mov_b32_e32 v2, v85
	v_mov_b32_e32 v3, v85
	v_mov_b32_e32 v4, v85
	v_mov_b32_e32 v5, v85
	v_mov_b32_e32 v6, v85
	v_mov_b32_e32 v7, v85
	v_mov_b32_e32 v8, v85
	v_mov_b32_e32 v9, v85
	v_mov_b32_e32 v10, v85
	v_mov_b32_e32 v11, v85
	v_mov_b32_e32 v12, v85
	v_mov_b32_e32 v13, v85
	v_mov_b32_e32 v14, v85
	v_mov_b32_e32 v15, v85
	v_mov_b32_e32 v16, v85
	v_mov_b32_e32 v17, v85
	v_mov_b32_e32 v18, v85
	v_mov_b32_e32 v19, v85
	v_mov_b32_e32 v20, v85
	v_mov_b32_e32 v21, v85
	v_mov_b32_e32 v22, v85
	v_mov_b32_e32 v23, v85
	v_mov_b32_e32 v24, v85
	v_mov_b32_e32 v25, v85
	v_mov_b32_e32 v26, v85
	v_mov_b32_e32 v27, v85
	v_mov_b32_e32 v28, v85
	v_mov_b32_e32 v29, v85
	v_mov_b32_e32 v30, v85
	v_mov_b32_e32 v31, v85
.LBB0_7:
	s_mov_b64 s[2:3], s[80:81]
	v_lshl_add_u64 v[32:33], v[86:87], 0, s[2:3]
	v_cmp_gt_i64_e32 vcc, s[78:79], v[32:33]
	v_lshl_add_u64 v[34:35], v[32:33], 0, 32
	v_add_u32_e32 v36, s2, v90
	v_cndmask_b32_e32 v33, v104, v33, vcc
	v_cndmask_b32_e32 v32, v105, v32, vcc
	v_cmp_gt_i64_e32 vcc, s[78:79], v[34:35]
	v_lshlrev_b64 v[32:33], 6, v[32:33]
	v_lshl_add_u64 v[32:33], v[88:89], 0, v[32:33]
	v_cndmask_b32_e32 v35, v104, v35, vcc
	v_cndmask_b32_e32 v34, v105, v34, vcc
	v_lshlrev_b64 v[34:35], 6, v[34:35]
	s_add_u32 s80, s2, 64
	v_add_u32_e32 v37, 1, v36
	v_cmp_le_i32_e64 s[4:5], s72, v36
	v_add_u32_e32 v38, 3, v36
	v_add_u32_e32 v39, 2, v36
	v_add_u32_e32 v40, 9, v36
	v_add_u32_e32 v41, 8, v36
	v_add_u32_e32 v42, 11, v36
	v_add_u32_e32 v43, 10, v36
	v_add_u32_e32 v44, 17, v36
	v_add_u32_e32 v45, 16, v36
	v_add_u32_e32 v46, 19, v36
	v_add_u32_e32 v47, 18, v36
	v_add_u32_e32 v48, 25, v36
	v_add_u32_e32 v49, 24, v36
	v_add_u32_e32 v50, 27, v36
	v_add_u32_e32 v51, 26, v36
	v_add_u32_e32 v52, 33, v36
	v_add_u32_e32 v53, 32, v36
	v_add_u32_e32 v54, 35, v36
	v_add_u32_e32 v55, 34, v36
	v_add_u32_e32 v56, 41, v36
	v_add_u32_e32 v57, 40, v36
	v_add_u32_e32 v58, 43, v36
	v_add_u32_e32 v59, 42, v36
	v_add_u32_e32 v60, 49, v36
	v_add_u32_e32 v61, 48, v36
	v_add_u32_e32 v62, 51, v36
	v_add_u32_e32 v63, 50, v36
	v_add_u32_e32 v64, 57, v36
	v_add_u32_e32 v65, 56, v36
	v_add_u32_e32 v66, 59, v36
	v_add_u32_e32 v36, 58, v36
	v_lshlrev_b64 v[32:33], 1, v[32:33]
	v_lshl_add_u64 v[34:35], v[88:89], 0, v[34:35]
	s_addc_u32 s81, s3, 0
	v_cmp_le_i32_e64 s[2:3], s72, v37
	v_cmp_le_i32_e64 s[66:67], s72, v36
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[36:37], s[74:75], 0, v[32:33]
	v_lshlrev_b64 v[34:35], 1, v[34:35]
	v_cmp_le_i32_e64 s[10:11], s72, v40
	v_cmp_le_i32_e64 s[12:13], s72, v41
	v_cmp_le_i32_e64 s[14:15], s72, v42
	v_cmp_le_i32_e64 s[16:17], s72, v43
	v_cmp_le_i32_e64 s[18:19], s72, v44
	v_cmp_le_i32_e64 s[20:21], s72, v45
	v_cmp_le_i32_e64 s[22:23], s72, v46
	v_cmp_le_i32_e64 s[24:25], s72, v47
	global_load_dwordx4 v[40:43], v[36:37], off
	global_load_dwordx4 v[44:47], v[36:37], off offset:16
	v_lshl_add_u64 v[36:37], s[74:75], 0, v[34:35]
	v_cmp_le_i32_e64 s[6:7], s72, v38
	v_cmp_le_i32_e64 s[8:9], s72, v39
	v_lshl_add_u64 v[68:69], s[76:77], 0, v[32:33]
	v_lshl_add_u64 v[76:77], s[76:77], 0, v[34:35]
	global_load_dwordx4 v[32:35], v[36:37], off offset:16
	v_cmp_le_i32_e64 s[60:61], s72, v64
	global_load_dwordx4 v[36:39], v[36:37], off
	v_cmp_le_i32_e64 s[62:63], s72, v65
	v_cmp_le_i32_e64 s[64:65], s72, v66
	v_cmp_le_i32_e64 s[26:27], s72, v48
	v_cmp_le_i32_e64 s[28:29], s72, v49
	v_cmp_le_i32_e64 s[30:31], s72, v50
	v_cmp_le_i32_e64 s[34:35], s72, v51
	v_cmp_le_i32_e64 s[36:37], s72, v52
	v_cmp_le_i32_e64 s[38:39], s72, v53
	v_cmp_le_i32_e64 s[40:41], s72, v54
	v_cmp_le_i32_e64 s[42:43], s72, v55
	v_cmp_le_i32_e64 s[44:45], s72, v56
	v_cmp_le_i32_e64 s[46:47], s72, v57
	v_cmp_le_i32_e64 s[48:49], s72, v58
	v_cmp_le_i32_e64 s[50:51], s72, v59
	v_cmp_le_i32_e64 s[52:53], s72, v60
	v_cmp_le_i32_e64 s[54:55], s72, v61
	v_cmp_le_i32_e64 s[56:57], s72, v62
	v_cmp_le_i32_e64 s[58:59], s72, v63
	s_cmp_lt_i32 s72, s80
	s_cselect_b64 s[84:85], -1, 0
	s_and_b64 s[2:3], s[84:85], s[2:3]
	s_and_b64 s[4:5], s[84:85], s[4:5]
	s_and_b64 s[6:7], s[84:85], s[6:7]
	s_and_b64 s[8:9], s[84:85], s[8:9]
	s_and_b64 s[10:11], s[84:85], s[10:11]
	s_and_b64 s[12:13], s[84:85], s[12:13]
	s_and_b64 s[14:15], s[84:85], s[14:15]
	s_and_b64 s[16:17], s[84:85], s[16:17]
	s_and_b64 s[18:19], s[84:85], s[18:19]
	s_and_b64 s[20:21], s[84:85], s[20:21]
	s_and_b64 s[22:23], s[84:85], s[22:23]
	s_and_b64 s[24:25], s[84:85], s[24:25]
	s_and_b64 s[26:27], s[84:85], s[26:27]
	s_and_b64 s[28:29], s[84:85], s[28:29]
	s_and_b64 s[30:31], s[84:85], s[30:31]
	s_and_b64 s[34:35], s[84:85], s[34:35]
	s_and_b64 s[36:37], s[84:85], s[36:37]
	s_and_b64 s[38:39], s[84:85], s[38:39]
	s_and_b64 s[40:41], s[84:85], s[40:41]
	s_and_b64 s[42:43], s[84:85], s[42:43]
	s_and_b64 s[44:45], s[84:85], s[44:45]
	s_and_b64 s[46:47], s[84:85], s[46:47]
	s_and_b64 s[48:49], s[84:85], s[48:49]
	s_and_b64 s[50:51], s[84:85], s[50:51]
	s_and_b64 s[52:53], s[84:85], s[52:53]
	s_and_b64 s[54:55], s[84:85], s[54:55]
	s_and_b64 s[56:57], s[84:85], s[56:57]
	s_and_b64 s[58:59], s[84:85], s[58:59]
	s_and_b64 s[60:61], s[84:85], s[60:61]
	s_and_b64 s[62:63], s[84:85], s[62:63]
	s_and_b64 s[64:65], s[84:85], s[64:65]
	s_and_b64 s[66:67], s[84:85], s[66:67]
	v_cmp_lt_i64_e64 s[68:69], s[80:81], v[92:93]
	s_and_b64 vcc, exec, s[68:69]
	s_waitcnt vmcnt(3)
	ds_write_b128 v94, v[40:43]
	s_waitcnt vmcnt(2)
	ds_write_b128 v94, v[44:47] offset:16
	s_waitcnt vmcnt(1)
	ds_write_b128 v95, v[32:35] offset:16
	s_waitcnt vmcnt(0)
	ds_write_b128 v95, v[36:39]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[32:35], v96
	ds_read_b128 v[64:67], v96 offset:4096
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[32:35], v[112:115], 0
	global_load_dwordx4 v[72:75], v[76:77], off offset:16
	ds_read_b128 v[128:131], v99 offset:4096
	global_load_dwordx4 v[76:79], v[76:77], off
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[64:67], v[112:115], 0
	ds_read_b128 v[64:67], v97
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[64:67], v[120:123], v[48:63]
	ds_read_b128 v[64:67], v97 offset:4096
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[64:67], v[120:123], v[32:47]
	ds_read_b128 v[64:67], v98
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[64:67], v[116:119], v[48:63]
	ds_read_b128 v[64:67], v98 offset:4096
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[64:67], v[116:119], v[32:47]
	ds_read_b128 v[64:67], v99
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[64:67], v[124:127], v[48:63]
	global_load_dwordx4 v[64:67], v[68:69], off offset:16
	s_nop 0
	global_load_dwordx4 v[68:71], v[68:69], off
	s_waitcnt vmcnt(0)
	ds_write2_b64 v111, v[72:73], v[74:75] offset1:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[128:131], v[124:127], v[32:47]
	s_nop 5
	v_cndmask_b32_e64 v49, v49, v106, s[2:3]
	v_cndmask_b32_e64 v48, v48, v106, s[4:5]
	v_cndmask_b32_e64 v51, v51, v106, s[6:7]
	v_cndmask_b32_e64 v50, v50, v106, s[8:9]
	v_max_f32_e32 v128, v48, v49
	v_cndmask_b32_e64 v53, v53, v106, s[10:11]
	v_cndmask_b32_e64 v52, v52, v106, s[12:13]
	v_max3_f32 v128, v128, v50, v51
	v_cndmask_b32_e64 v55, v55, v106, s[14:15]
	v_cndmask_b32_e64 v54, v54, v106, s[16:17]
	v_max3_f32 v128, v128, v52, v53
	v_cndmask_b32_e64 v57, v57, v106, s[18:19]
	v_cndmask_b32_e64 v56, v56, v106, s[20:21]
	v_max3_f32 v128, v128, v54, v55
	v_cndmask_b32_e64 v59, v59, v106, s[22:23]
	v_cndmask_b32_e64 v58, v58, v106, s[24:25]
	v_max3_f32 v128, v128, v56, v57
	v_cndmask_b32_e64 v61, v61, v106, s[26:27]
	v_cndmask_b32_e64 v60, v60, v106, s[28:29]
	v_max3_f32 v128, v128, v58, v59
	v_cndmask_b32_e64 v63, v63, v106, s[30:31]
	v_cndmask_b32_e64 v62, v62, v106, s[34:35]
	v_max3_f32 v128, v128, v60, v61
	v_cndmask_b32_e64 v33, v33, v106, s[36:37]
	v_cndmask_b32_e64 v32, v32, v106, s[38:39]
	v_max3_f32 v128, v128, v62, v63
	v_cndmask_b32_e64 v35, v35, v106, s[40:41]
	v_cndmask_b32_e64 v34, v34, v106, s[42:43]
	v_max3_f32 v128, v128, v32, v33
	v_cndmask_b32_e64 v37, v37, v106, s[44:45]
	v_cndmask_b32_e64 v36, v36, v106, s[46:47]
	v_max3_f32 v128, v128, v34, v35
	v_cndmask_b32_e64 v39, v39, v106, s[48:49]
	v_cndmask_b32_e64 v38, v38, v106, s[50:51]
	v_max3_f32 v128, v128, v36, v37
	v_cndmask_b32_e64 v41, v41, v106, s[52:53]
	v_cndmask_b32_e64 v40, v40, v106, s[54:55]
	v_max3_f32 v128, v128, v38, v39
	v_cndmask_b32_e64 v43, v43, v106, s[56:57]
	v_cndmask_b32_e64 v42, v42, v106, s[58:59]
	v_max3_f32 v128, v128, v40, v41
	v_cndmask_b32_e64 v45, v45, v106, s[60:61]
	v_cndmask_b32_e64 v44, v44, v106, s[62:63]
	v_max3_f32 v128, v128, v42, v43
	v_cndmask_b32_e64 v47, v47, v106, s[64:65]
	v_cndmask_b32_e64 v46, v46, v106, s[66:67]
	v_max3_f32 v128, v128, v44, v45
	v_max3_f32 v128, v128, v46, v47
	v_mov_b32_e32 v129, v128
	v_mov_b32_e32 v130, v128
	s_nop 1
	v_permlane32_swap_b32_e32 v129, v130
	v_cmp_eq_u32_e64 s[2:3], v129, v128
	ds_write2_b64 v110, v[76:77], v[78:79] offset1:1
	ds_write2_b64 v109, v[64:65], v[66:67] offset1:1
	v_cndmask_b32_e64 v129, v129, v130, s[2:3]
	v_max3_f32 v129, v107, v128, v129
	v_mul_f32_e32 v128, 0xbe38aa3b, v129
	v_sub_f32_e32 v130, v107, v129
	v_pk_fma_f32 v[48:49], v[48:49], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_mov_b32_e32 v107, v129
	v_pk_fma_f32 v[50:51], v[50:51], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[52:53], v[52:53], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[54:55], v[54:55], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[56:57], v[56:57], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[58:59], v[58:59], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[60:61], v[60:61], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[62:63], v[62:63], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[32:33], v[32:33], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[34:35], v[34:35], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[36:37], v[36:37], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[38:39], v[38:39], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[40:41], v[40:41], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[42:43], v[42:43], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[44:45], v[44:45], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[46:47], v[46:47], s[82:83], v[128:129] op_sel_hi:[1,0,0]
	v_mul_f32_e32 v128, 0x3e38aa3b, v130
	v_exp_f32_e32 v129, v48
	v_exp_f32_e32 v49, v49
	v_exp_f32_e32 v50, v50
	v_exp_f32_e32 v48, v128
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v52, v52
	v_exp_f32_e32 v53, v53
	v_add_f32_e32 v128, v129, v49
	v_exp_f32_e32 v54, v54
	v_exp_f32_e32 v130, v32
	v_perm_b32 v32, v49, v129, s71
	v_pk_mul_f32 v[14:15], v[48:49], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[48:49], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[48:49], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[48:49], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[48:49], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[48:49], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[48:49], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[48:49], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[48:49], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[48:49], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[48:49], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[48:49], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[48:49], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[48:49], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[48:49], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[48:49], v[16:17] op_sel_hi:[0,1]
	v_add_f32_e32 v49, v128, v50
	v_exp_f32_e32 v55, v55
	v_add_f32_e32 v49, v49, v51
	v_exp_f32_e32 v56, v56
	v_add_f32_e32 v49, v49, v52
	v_exp_f32_e32 v57, v57
	v_add_f32_e32 v49, v49, v53
	v_add_f32_e32 v49, v49, v54
	v_add_f32_e32 v49, v49, v55
	v_add_f32_e32 v49, v49, v56
	v_exp_f32_e32 v131, v33
	v_exp_f32_e32 v132, v34
	v_exp_f32_e32 v133, v35
	v_exp_f32_e32 v134, v36
	v_perm_b32 v33, v51, v50, s71
	v_perm_b32 v34, v53, v52, s71
	v_perm_b32 v35, v55, v54, s71
	v_perm_b32 v36, v57, v56, s71
	v_add_f32_e32 v49, v49, v57
	ds_write2_b64 v108, v[68:69], v[70:71] offset1:1
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[50:51], v100
	ds_read_b64_tr_b16 v[52:53], v100 offset:1088
	ds_read_b64_tr_b16 v[54:55], v102
	ds_read_b64_tr_b16 v[56:57], v102 offset:1088
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[50:53], v[32:35], v[0:15]
	ds_read_b64_tr_b16 v[50:51], v100 offset:4352
	ds_read_b64_tr_b16 v[52:53], v100 offset:5440
	v_exp_f32_e32 v58, v58
	v_exp_f32_e32 v59, v59
	v_exp_f32_e32 v135, v37
	v_exp_f32_e32 v136, v38
	v_exp_f32_e32 v137, v39
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[54:57], v[32:35], v[16:31]
	ds_read_b64_tr_b16 v[32:33], v102 offset:4352
	ds_read_b64_tr_b16 v[34:35], v102 offset:5440
	v_exp_f32_e32 v60, v60
	v_exp_f32_e32 v61, v61
	v_exp_f32_e32 v62, v62
	v_add_f32_e32 v49, v49, v58
	v_exp_f32_e32 v63, v63
	v_exp_f32_e32 v138, v40
	v_exp_f32_e32 v139, v41
	v_exp_f32_e32 v140, v42
	v_exp_f32_e32 v141, v43
	v_perm_b32 v40, v131, v130, s71
	v_perm_b32 v41, v133, v132, s71
	v_perm_b32 v42, v135, v134, s71
	v_perm_b32 v43, v137, v136, s71
	v_add_f32_e32 v49, v49, v59
	ds_read_b64_tr_b16 v[54:55], v103
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[50:53], v[40:43], v[0:15]
	ds_read_b64_tr_b16 v[50:51], v101
	ds_read_b64_tr_b16 v[52:53], v101 offset:1088
	ds_read_b64_tr_b16 v[56:57], v103 offset:1088
	v_perm_b32 v37, v59, v58, s71
	v_perm_b32 v38, v61, v60, s71
	v_perm_b32 v39, v63, v62, s71
	ds_read_b64_tr_b16 v[64:65], v103 offset:4352
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[32:35], v[40:43], v[16:31]
	v_add_f32_e32 v32, v49, v60
	v_add_f32_e32 v32, v32, v61
	v_add_f32_e32 v32, v32, v62
	v_add_f32_e32 v32, v32, v63
	v_add_f32_e32 v32, v32, v130
	v_add_f32_e32 v32, v32, v131
	v_add_f32_e32 v32, v32, v132
	v_add_f32_e32 v32, v32, v133
	ds_read_b64_tr_b16 v[40:41], v101 offset:4352
	ds_read_b64_tr_b16 v[42:43], v101 offset:5440
	ds_read_b64_tr_b16 v[66:67], v103 offset:5440
	v_add_f32_e32 v32, v32, v134
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[50:53], v[36:39], v[0:15]
	v_add_f32_e32 v32, v32, v135
	v_add_f32_e32 v32, v32, v136
	v_add_f32_e32 v32, v32, v137
	v_exp_f32_e32 v142, v44
	v_exp_f32_e32 v143, v45
	v_exp_f32_e32 v144, v46
	v_exp_f32_e32 v145, v47
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[54:57], v[36:39], v[16:31]
	v_add_f32_e32 v32, v32, v138
	v_add_f32_e32 v32, v32, v139
	v_add_f32_e32 v32, v32, v140
	v_add_f32_e32 v32, v32, v141
	v_perm_b32 v44, v139, v138, s71
	v_perm_b32 v45, v141, v140, s71
	v_perm_b32 v46, v143, v142, s71
	v_perm_b32 v47, v145, v144, s71
	v_add_f32_e32 v32, v32, v142
	v_add_f32_e32 v32, v32, v143
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[40:43], v[44:47], v[0:15]
	v_add_f32_e32 v32, v32, v144
	v_add_f32_e32 v32, v32, v145
	v_mov_b32_e32 v33, v32
	v_mov_b32_e32 v34, v32
	s_nop 1
	v_permlane32_swap_b32_e32 v33, v34
	v_cmp_eq_u32_e64 s[2:3], v33, v32
	v_fmac_f32_e32 v32, v48, v91
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[64:67], v[44:47], v[16:31]
	v_cndmask_b32_e64 v33, v33, v34, s[2:3]
	v_add_f32_e32 v91, v32, v33
	s_cbranch_vccnz .LBB0_7
	s_branch .LBB0_9
.LBB0_8:
	v_mov_b32_e32 v15, 0
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
	v_mov_b32_e32 v91, v85
.LBB0_9:
	v_rcp_f32_e32 v32, v91
	s_load_dwordx2 s[0:1], s[0:1], 0x90
	v_cmp_eq_u64_e32 vcc, 0, v[84:85]
	s_mov_b32 s71, 0x27000
	v_pk_mul_f32 v[4:5], v[32:33], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[32:33], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[32:33], v[0:1] op_sel_hi:[0,1]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v0, v1
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v2, v3
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v2, v4, v5
	;;#ASMEND
	v_pk_mul_f32 v[6:7], v[32:33], v[6:7] op_sel_hi:[0,1]
	v_mov_b32_e32 v4, v0
	v_mov_b32_e32 v5, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v4, v5
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v3, v6, v7
	;;#ASMEND
	v_mov_b32_e32 v4, v1
	v_mov_b32_e32 v6, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v4, v6
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v7, v2
	s_nop 1
	v_permlane32_swap_b32_e32 v4, v7
	v_pk_mul_f32 v[14:15], v[32:33], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[32:33], v[12:13] op_sel_hi:[0,1]
	s_waitcnt lgkmcnt(0)
	s_add_u32 s68, s0, s83
	v_pk_mul_f32 v[10:11], v[32:33], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[32:33], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[32:33], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[32:33], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[32:33], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[32:33], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[32:33], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[32:33], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[32:33], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[32:33], v[16:17] op_sel_hi:[0,1]
	v_mov_b32_e32 v7, v3
	v_mov_b32_e32 v32, v3
	s_addc_u32 s0, s1, s33
	s_nop 0
	v_permlane32_swap_b32_e32 v7, v32
	s_and_b32 s69, s0, 0xffff
	v_cndmask_b32_e32 v0, v4, v0, vcc
	v_cndmask_b32_e32 v1, v7, v1, vcc
	v_cndmask_b32_e32 v2, v2, v5, vcc
	v_cndmask_b32_e32 v3, v3, v6, vcc
	buffer_store_dwordx4 v[0:3], v83, s[68:71], 0 offen
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v14, v15
	;;#ASMEND
	s_nop 1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v8, v9
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v10, v11
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v2, v12, v13
	;;#ASMEND
	v_mov_b32_e32 v8, v5
	v_mov_b32_e32 v3, v0
	v_mov_b32_e32 v4, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v4
	v_mov_b32_e32 v3, v1
	v_mov_b32_e32 v6, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v6
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v7, v2
	s_nop 1
	v_permlane32_swap_b32_e32 v3, v7
	v_mov_b32_e32 v7, v5
	v_cndmask_b32_e32 v2, v2, v4, vcc
	v_lshlrev_b32_e32 v4, 1, v82
	v_permlane32_swap_b32_e32 v7, v8
	v_lshl_or_b32 v4, v80, 4, v4
	v_cndmask_b32_e32 v0, v3, v0, vcc
	v_cndmask_b32_e32 v1, v7, v1, vcc
	v_cndmask_b32_e32 v3, v5, v6, vcc
	v_or_b32_e32 v5, 32, v4
	buffer_store_dwordx4 v[0:3], v5, s[68:71], 0 offen
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v20, v21
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v7, v22, v23
	;;#ASMEND
	v_or_b32_e32 v4, 0x60, v4
	v_mov_b32_e32 v8, v5
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v16, v17
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v1, v18, v19
	;;#ASMEND
	v_mov_b32_e32 v9, v7
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v3
	v_mov_b32_e32 v2, v1
	v_mov_b32_e32 v6, v1
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v6
	v_mov_b32_e32 v2, v5
	s_nop 1
	v_permlane32_swap_b32_e32 v2, v8
	v_mov_b32_e32 v8, v7
	s_nop 1
	v_permlane32_swap_b32_e32 v8, v9
	v_cndmask_b32_e32 v0, v2, v0, vcc
	v_cndmask_b32_e32 v1, v8, v1, vcc
	v_cndmask_b32_e32 v2, v5, v3, vcc
	v_cndmask_b32_e32 v3, v7, v6, vcc
	buffer_store_dwordx4 v[0:3], v81, s[68:71], 0 offen
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v6, v28, v29
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v8, v30, v31
	;;#ASMEND
	s_nop 0
	v_mov_b32_e32 v7, v6
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v0, v24, v25
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v3, v26, v27
	;;#ASMEND
	v_mov_b32_e32 v9, v8
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v0
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v2
	v_mov_b32_e32 v1, v3
	v_mov_b32_e32 v5, v3
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v5
	v_mov_b32_e32 v1, v6
	s_nop 1
	v_permlane32_swap_b32_e32 v1, v7
	v_mov_b32_e32 v7, v8
	s_nop 1
	v_permlane32_swap_b32_e32 v7, v9
	v_cndmask_b32_e32 v0, v1, v0, vcc
	v_cndmask_b32_e32 v1, v7, v3, vcc
	v_cndmask_b32_e32 v2, v6, v2, vcc
	v_cndmask_b32_e32 v3, v8, v5, vcc
	buffer_store_dwordx4 v[0:3], v4, s[68:71], 0 offen
	s_endpgm
.Lfunc_end0:
	.size	flash_attn_generic_kernel_0, .Lfunc_end0-flash_attn_generic_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel flash_attn_generic_kernel_0
		.amdhsa_group_segment_fixed_size 16896
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 396
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
		.amdhsa_next_free_vgpr 146
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 148
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

	.set .Lflash_attn_generic_kernel_0.num_vgpr, 146
	.set .Lflash_attn_generic_kernel_0.num_agpr, 0
	.set .Lflash_attn_generic_kernel_0.numbered_sgpr, 86
	.set .Lflash_attn_generic_kernel_0.num_named_barrier, 0
	.set .Lflash_attn_generic_kernel_0.private_seg_size, 0
	.set .Lflash_attn_generic_kernel_0.uses_vcc, 1
	.set .Lflash_attn_generic_kernel_0.uses_flat_scratch, 0
	.set .Lflash_attn_generic_kernel_0.has_dyn_sized_stack, 0
	.set .Lflash_attn_generic_kernel_0.has_recursion, 0
	.set .Lflash_attn_generic_kernel_0.has_indirect_call, 0
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
      - .offset:         240
        .size:           4
        .value_kind:     by_value
      - .offset:         244
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         248
        .size:           8
        .value_kind:     global_buffer
      - .offset:         256
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         296
        .size:           8
        .value_kind:     global_buffer
      - .offset:         304
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         344
        .size:           8
        .value_kind:     global_buffer
      - .offset:         352
        .size:           40
        .value_kind:     by_value
      - .offset:         392
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 16896
    .kernarg_segment_align: 8
    .kernarg_segment_size: 396
    .max_flat_workgroup_size: 128
    .name:           flash_attn_generic_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 128
      - 1
      - 1
    .sgpr_count:     92
    .sgpr_spill_count: 0
    .symbol:         flash_attn_generic_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     146
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
