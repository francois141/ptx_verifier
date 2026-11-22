; FlyDSL 304d441202a3 kernels/attention/flash_attn_generic.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case flash_attn_generic_causal).
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
	s_ashr_i32 s9, s4, 31
	s_add_u32 s6, s4, 63
	s_addc_u32 s7, s9, 0
	s_lshr_b64 s[6:7], s[6:7], 6
	s_or_b64 s[10:11], s[2:3], s[6:7]
	s_cmp_lg_u32 s11, 0
	s_mov_b32 s8, s4
	s_cbranch_scc0 .LBB0_2
	v_cvt_f32_u32_e32 v1, s6
	v_cvt_f32_u32_e32 v2, s7
	s_sub_u32 s4, 0, s6
	s_subb_u32 s12, 0, s7
	s_mov_b64 s[10:11], 0
	v_fmamk_f32 v1, v2, 0x4f800000, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x5f7ffffc, v1
	v_mul_f32_e32 v2, 0x2f800000, v1
	v_trunc_f32_e32 v2, v2
	v_fmamk_f32 v1, v2, 0xcf800000, v1
	v_cvt_u32_f32_e32 v2, v2
	v_cvt_u32_f32_e32 v1, v1
	v_readfirstlane_b32 s13, v2
	v_readfirstlane_b32 s14, v1
	s_mul_i32 s15, s4, s13
	s_mul_hi_u32 s17, s4, s14
	s_mul_i32 s16, s12, s14
	s_add_i32 s15, s17, s15
	s_add_i32 s15, s15, s16
	s_mul_i32 s18, s4, s14
	s_mul_i32 s17, s14, s15
	s_mul_hi_u32 s19, s14, s18
	s_mul_hi_u32 s16, s14, s15
	s_add_u32 s17, s19, s17
	s_addc_u32 s16, 0, s16
	s_mul_hi_u32 s19, s13, s18
	s_mul_i32 s18, s13, s18
	s_add_u32 s17, s17, s18
	s_addc_u32 s16, s16, s19
	s_mul_hi_u32 s17, s13, s15
	s_addc_u32 s17, s17, 0
	s_mul_i32 s15, s13, s15
	s_add_u32 s15, s16, s15
	s_addc_u32 s16, 0, s17
	s_add_u32 s14, s14, s15
	s_addc_u32 s13, s13, s16
	s_mul_i32 s15, s4, s14
	s_mul_i32 s18, s4, s13
	s_mul_hi_u32 s4, s4, s14
	s_add_i32 s4, s4, s18
	s_mul_i32 s12, s12, s14
	s_add_i32 s4, s4, s12
	s_mul_hi_u32 s16, s13, s15
	s_mul_i32 s17, s13, s15
	s_mul_i32 s18, s14, s4
	s_mul_hi_u32 s15, s14, s15
	s_mul_hi_u32 s12, s14, s4
	s_add_u32 s15, s15, s18
	s_addc_u32 s12, 0, s12
	s_add_u32 s15, s15, s17
	s_addc_u32 s12, s12, s16
	s_mul_hi_u32 s15, s13, s4
	s_addc_u32 s15, s15, 0
	s_mul_i32 s4, s13, s4
	s_add_u32 s4, s12, s4
	s_addc_u32 s12, 0, s15
	s_add_u32 s4, s14, s4
	s_addc_u32 s12, s13, s12
	s_mul_i32 s14, s2, s12
	s_mul_hi_u32 s15, s2, s4
	s_mul_hi_u32 s13, s2, s12
	s_add_u32 s14, s15, s14
	s_addc_u32 s13, 0, s13
	s_mul_hi_u32 s15, s3, s4
	s_mul_i32 s4, s3, s4
	s_add_u32 s4, s14, s4
	s_addc_u32 s4, s13, s15
	s_mul_hi_u32 s13, s3, s12
	s_addc_u32 s13, s13, 0
	s_mul_i32 s12, s3, s12
	s_add_u32 s4, s4, s12
	s_addc_u32 s14, 0, s13
	s_mul_i32 s12, s6, s14
	s_mul_hi_u32 s13, s6, s4
	s_add_i32 s12, s13, s12
	s_mul_i32 s13, s7, s4
	s_add_i32 s15, s12, s13
	s_sub_i32 s16, s3, s15
	s_mul_i32 s12, s6, s4
	s_sub_u32 s17, s2, s12
	s_cselect_b64 s[12:13], -1, 0
	s_subb_u32 s16, s16, s7
	s_sub_u32 s18, s17, s6
	s_subb_u32 s16, s16, 0
	s_cmp_ge_u32 s16, s7
	s_cselect_b32 s19, -1, 0
	s_cmp_ge_u32 s18, s6
	s_cselect_b32 s18, -1, 0
	s_cmp_eq_u32 s16, s7
	s_cselect_b32 s16, s18, s19
	s_add_u32 s18, s4, 1
	s_addc_u32 s19, s14, 0
	s_add_u32 s20, s4, 2
	s_addc_u32 s21, s14, 0
	s_cmp_lg_u32 s16, 0
	s_cselect_b32 s16, s20, s18
	s_cselect_b32 s18, s21, s19
	s_cmp_lg_u64 s[12:13], 0
	s_subb_u32 s12, s3, s15
	s_cmp_ge_u32 s12, s7
	s_cselect_b32 s13, -1, 0
	s_cmp_ge_u32 s17, s6
	s_cselect_b32 s15, -1, 0
	s_cmp_eq_u32 s12, s7
	s_cselect_b32 s12, s15, s13
	s_cmp_lg_u32 s12, 0
	s_cselect_b32 s15, s18, s14
	s_cselect_b32 s14, s16, s4
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[10:11], -1
.LBB0_3:
	s_and_b64 s[10:11], s[10:11], exec
	s_cselect_b32 s4, 1, 0
	s_cmp_lg_u32 s4, 1
	s_cbranch_scc1 .LBB0_5
	v_cvt_f32_u32_e32 v1, s6
	s_sub_i32 s4, 0, s6
	s_mov_b32 s15, 0
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
	s_mul_i32 s11, s4, s6
	s_sub_i32 s11, s2, s11
	s_add_i32 s10, s4, 1
	s_sub_i32 s12, s11, s6
	s_cmp_ge_u32 s11, s6
	s_cselect_b32 s4, s10, s4
	s_cselect_b32 s11, s12, s11
	s_add_i32 s10, s4, 1
	s_cmp_ge_u32 s11, s6
	s_cselect_b32 s14, s10, s4
.LBB0_5:
	s_mul_i32 s4, s14, s7
	s_mul_hi_u32 s7, s14, s6
	s_add_i32 s4, s7, s4
	s_mul_i32 s7, s15, s6
	s_ashr_i32 s17, s5, 31
	s_add_i32 s4, s4, s7
	s_mul_i32 s6, s14, s6
	s_sub_u32 s2, s2, s6
	s_subb_u32 s3, s3, s4
	s_lshl_b64 s[2:3], s[2:3], 6
	s_sub_i32 s21, s5, s8
	v_lshrrev_b32_e32 v1, 1, v0
	s_lshl_b64 s[6:7], s[8:9], 7
	s_add_i32 s20, s21, s2
	s_mov_b32 s16, s5
	v_and_b32_e32 v2, 31, v0
	s_mul_i32 s4, s6, s15
	s_mul_hi_u32 s7, s6, s14
	s_lshr_b64 s[10:11], s[8:9], 25
	v_and_or_b32 v1, v1, 32, s2
	s_add_i32 s2, s20, 64
	v_bfe_u32 v84, v0, 5, 1
	s_add_i32 s18, s7, s4
	s_mul_i32 s4, s10, s14
	v_mov_b32_e32 v5, s3
	v_or_b32_e32 v4, v1, v2
	s_mov_b32 s3, 0
	s_max_i32 s2, s2, 0
	v_mov_b64_e32 v[10:11], s[16:17]
	s_add_i32 s18, s18, s4
	v_lshlrev_b32_e32 v6, 3, v84
	v_lshlrev_b64 v[82:83], 6, v[4:5]
	v_cmp_lt_u64_e32 vcc, s[2:3], v[10:11]
	v_or_b32_e32 v1, v82, v6
	v_or_b32_e32 v8, 32, v6
	s_and_b64 s[8:9], vcc, exec
	v_lshlrev_b32_e32 v93, 1, v1
	v_or_b32_e32 v1, v82, v8
	s_cselect_b32 s3, 0, s17
	s_cselect_b32 s2, s2, s5
	v_mov_b32_e32 v85, 0
	v_lshrrev_b32_e32 v80, 5, v0
	s_mul_i32 s19, s6, s14
	v_lshlrev_b32_e32 v83, 1, v1
	s_cmp_eq_u64 s[2:3], 0
	s_mov_b64 s[8:9], 0
	s_cbranch_scc1 .LBB0_10
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	v_or_b32_e32 v1, 16, v6
	v_or_b32_e32 v3, v82, v1
	v_or_b32_e32 v5, 48, v6
	s_mov_b32 s7, 0x27000
	s_waitcnt lgkmcnt(0)
	s_add_u32 s4, s4, s19
	s_addc_u32 s5, s5, s18
	s_and_b32 s5, s5, 0xffff
	v_lshlrev_b32_e32 v3, 1, v3
	v_or_b32_e32 v7, v82, v5
	buffer_load_dwordx4 v[112:115], v93, s[4:7], 0 offen
	buffer_load_dwordx4 v[116:119], v83, s[4:7], 0 offen
	v_lshlrev_b32_e32 v7, 1, v7
	buffer_load_dwordx4 v[120:123], v3, s[4:7], 0 offen
	buffer_load_dwordx4 v[124:127], v7, s[4:7], 0 offen
	v_lshlrev_b32_e32 v3, 4, v0
	v_and_b32_e32 v3, 48, v3
	v_lshlrev_b32_e32 v2, 6, v2
	v_bitop3_b32 v1, v1, v2, v3 bitop3:0xde
	v_lshlrev_b32_e32 v99, 1, v1
	v_bitop3_b32 v1, v8, v2, v3 bitop3:0xde
	v_lshrrev_b32_e32 v86, 2, v0
	s_mul_i32 s4, s16, s15
	s_mul_hi_u32 s5, s16, s14
	v_lshlrev_b32_e32 v100, 1, v1
	v_bitop3_b32 v1, v5, v2, v3 bitop3:0xde
	s_add_i32 s4, s5, s4
	s_mul_i32 s5, s17, s14
	v_lshlrev_b32_e32 v101, 1, v1
	v_mul_u32_u24_e32 v1, 0x44, v86
	v_lshlrev_b32_e32 v94, 2, v84
	s_load_dwordx2 s[10:11], s[0:1], 0x30
	s_load_dwordx2 s[12:13], s[0:1], 0x60
	s_add_i32 s5, s4, s5
	s_mul_i32 s4, s16, s14
	v_add_lshl_u32 v102, v1, v3, 1
	v_and_or_b32 v1, v86, 3, v94
	s_lshl_b64 s[14:15], s[4:5], 6
	v_and_b32_e32 v7, 16, v0
	v_xor_b32_e32 v9, v86, v0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mul_u32_u24_e32 v1, 0x44, v1
	s_add_u32 s4, s16, -1
	v_lshlrev_b32_e32 v9, 5, v9
	v_or3_b32 v6, v6, v3, v2
	v_and_or_b32 v0, v0, 12, v7
	v_or_b32_e32 v2, 0x1000, v1
	v_add_u32_e32 v1, 0x1440, v1
	s_addc_u32 s5, s17, -1
	v_and_b32_e32 v9, 0x60, v9
	v_or_b32_e32 v90, 32, v86
	v_add_u32_e32 v92, s21, v4
	v_add_lshl_u32 v103, v2, v0, 1
	v_add_lshl_u32 v104, v1, v0, 1
	v_or_b32_e32 v0, 32, v0
	v_mov_b32_e32 v87, v85
	v_or_b32_e32 v88, s14, v3
	v_mov_b32_e32 v89, s15
	v_lshl_or_b32 v96, v86, 7, v9
	v_mov_b32_e32 v91, v85
	v_lshl_or_b32 v97, v90, 7, v9
	v_lshlrev_b32_e32 v98, 1, v6
	v_add_lshl_u32 v105, v2, v0, 1
	v_add_lshl_u32 v106, v1, v0, 1
	v_mov_b32_e32 v81, v92
	v_mov_b32_e32 v95, 0
	v_mov_b32_e32 v110, 0xff800000
	v_mov_b32_e32 v107, s5
	v_mov_b32_e32 v108, s4
	s_mov_b32 s7, 0xff61b1e6
	s_mov_b32 s14, 0x3e38aa3b
	s_mov_b32 s15, 0x7060302
	v_mov_b32_e32 v109, 0xff800000
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
	s_branch .LBB0_8
	.p2align	5, , 4
.LBB0_7:
	v_lshl_add_u64 v[64:65], s[12:13], 0, v[64:65]
	global_load_dwordx4 v[76:79], v[64:65], off offset:16
	global_load_dwordx4 v[72:75], v[64:65], off
	v_lshl_add_u64 v[64:65], s[12:13], 0, v[66:67]
	global_load_dwordx4 v[68:71], v[64:65], off offset:16
	s_nop 3
	v_max_f32_e32 v111, v48, v49
	global_load_dwordx4 v[64:67], v[64:65], off
	v_max3_f32 v111, v111, v50, v51
	v_max3_f32 v111, v111, v52, v53
	v_max3_f32 v111, v111, v54, v55
	v_max3_f32 v111, v111, v56, v57
	v_max3_f32 v111, v111, v58, v59
	v_max3_f32 v111, v111, v60, v61
	v_max3_f32 v111, v111, v62, v63
	v_max3_f32 v111, v111, v32, v33
	v_max3_f32 v111, v111, v34, v35
	v_max3_f32 v111, v111, v36, v37
	v_max3_f32 v111, v111, v38, v39
	v_max3_f32 v111, v111, v40, v41
	v_max3_f32 v111, v111, v42, v43
	v_max3_f32 v111, v111, v44, v45
	v_max3_f32 v111, v111, v46, v47
	v_mov_b32_e32 v128, v111
	v_mov_b32_e32 v129, v111
	s_nop 1
	v_permlane32_swap_b32_e32 v128, v129
	v_cmp_eq_u32_e32 vcc, v128, v111
	s_waitcnt vmcnt(0)
	s_add_u32 s8, s8, 64
	v_cndmask_b32_e32 v128, v128, v129, vcc
	v_max_f32_e32 v111, v111, v128
	v_max3_f32 v111, v110, v111, s7
	v_mul_f32_e32 v128, 0xbe38aa3b, v111
	v_pk_fma_f32 v[48:49], v[48:49], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	s_addc_u32 s9, s9, 0
	v_exp_f32_e32 v129, v48
	v_exp_f32_e32 v49, v49
	v_pk_fma_f32 v[50:51], v[50:51], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_sub_f32_e32 v48, v110, v111
	v_exp_f32_e32 v130, v50
	v_exp_f32_e32 v131, v51
	v_pk_fma_f32 v[50:51], v[52:53], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_add_f32_e32 v110, v129, v49
	v_exp_f32_e32 v52, v50
	v_exp_f32_e32 v53, v51
	v_add_f32_e32 v50, v110, v130
	v_add_f32_e32 v50, v50, v131
	v_add_f32_e32 v50, v50, v52
	v_add_f32_e32 v110, v50, v53
	v_pk_fma_f32 v[50:51], v[54:55], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_fma_f32 v[32:33], v[32:33], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_exp_f32_e32 v54, v50
	v_exp_f32_e32 v55, v51
	v_pk_fma_f32 v[50:51], v[56:57], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_mul_f32_e32 v48, 0x3e38aa3b, v48
	v_exp_f32_e32 v56, v50
	v_exp_f32_e32 v57, v51
	v_add_f32_e32 v50, v110, v54
	v_add_f32_e32 v50, v50, v55
	v_add_f32_e32 v50, v50, v56
	v_add_f32_e32 v110, v50, v57
	v_pk_fma_f32 v[50:51], v[58:59], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_exp_f32_e32 v48, v48
	v_exp_f32_e32 v58, v50
	v_exp_f32_e32 v59, v51
	v_pk_fma_f32 v[50:51], v[60:61], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[14:15], v[48:49], v[14:15] op_sel_hi:[0,1]
	v_exp_f32_e32 v60, v50
	v_exp_f32_e32 v61, v51
	v_add_f32_e32 v50, v110, v58
	v_add_f32_e32 v50, v50, v59
	v_add_f32_e32 v50, v50, v60
	v_add_f32_e32 v110, v50, v61
	v_pk_fma_f32 v[50:51], v[62:63], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_exp_f32_e32 v62, v32
	v_exp_f32_e32 v50, v50
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v63, v33
	v_pk_mul_f32 v[12:13], v[48:49], v[12:13] op_sel_hi:[0,1]
	v_add_f32_e32 v32, v110, v50
	v_add_f32_e32 v32, v32, v51
	v_add_f32_e32 v32, v32, v62
	v_add_f32_e32 v110, v32, v63
	v_pk_fma_f32 v[32:33], v[34:35], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[10:11], v[48:49], v[10:11] op_sel_hi:[0,1]
	v_exp_f32_e32 v132, v32
	v_exp_f32_e32 v133, v33
	v_pk_fma_f32 v[32:33], v[36:37], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[8:9], v[48:49], v[8:9] op_sel_hi:[0,1]
	v_exp_f32_e32 v134, v32
	v_exp_f32_e32 v135, v33
	v_add_f32_e32 v32, v110, v132
	v_add_f32_e32 v32, v32, v133
	v_add_f32_e32 v32, v32, v134
	v_add_f32_e32 v110, v32, v135
	v_pk_fma_f32 v[32:33], v[38:39], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[6:7], v[48:49], v[6:7] op_sel_hi:[0,1]
	v_exp_f32_e32 v136, v32
	v_exp_f32_e32 v137, v33
	v_pk_fma_f32 v[32:33], v[40:41], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[4:5], v[48:49], v[4:5] op_sel_hi:[0,1]
	v_exp_f32_e32 v138, v32
	v_exp_f32_e32 v139, v33
	v_pk_fma_f32 v[32:33], v[42:43], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[2:3], v[48:49], v[2:3] op_sel_hi:[0,1]
	v_exp_f32_e32 v140, v32
	v_exp_f32_e32 v141, v33
	v_pk_fma_f32 v[32:33], v[44:45], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_pk_mul_f32 v[0:1], v[48:49], v[0:1] op_sel_hi:[0,1]
	v_exp_f32_e32 v142, v32
	v_exp_f32_e32 v143, v33
	v_pk_fma_f32 v[32:33], v[46:47], s[14:15], v[128:129] op_sel_hi:[1,0,0]
	v_perm_b32 v34, v53, v52, s15
	v_exp_f32_e32 v128, v32
	v_exp_f32_e32 v144, v33
	v_add_u32_e32 v32, 0x2000, v102
	v_add_u32_e32 v33, 0x2010, v102
	ds_write2_b64 v33, v[76:77], v[78:79] offset1:1
	ds_write2_b64 v32, v[72:73], v[74:75] offset1:1
	v_add_u32_e32 v32, 0x3100, v102
	v_add_u32_e32 v33, 0x3110, v102
	ds_write2_b64 v33, v[68:69], v[70:71] offset1:1
	ds_write2_b64 v32, v[64:65], v[66:67] offset1:1
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[36:37], v103
	ds_read_b64_tr_b16 v[38:39], v103 offset:1088
	v_perm_b32 v32, v49, v129, s15
	v_perm_b32 v33, v131, v130, s15
	v_perm_b32 v35, v55, v54, s15
	ds_read_b64_tr_b16 v[40:41], v103 offset:4352
	ds_read_b64_tr_b16 v[42:43], v103 offset:5440
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[36:39], v[32:35], v[0:15]
	v_perm_b32 v36, v63, v62, s15
	v_perm_b32 v37, v133, v132, s15
	v_perm_b32 v38, v135, v134, s15
	v_perm_b32 v39, v137, v136, s15
	ds_read_b64_tr_b16 v[44:45], v104
	ds_read_b64_tr_b16 v[46:47], v104 offset:1088
	ds_read_b64_tr_b16 v[52:53], v104 offset:5440
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[40:43], v[36:39], v[0:15]
	v_perm_b32 v40, v57, v56, s15
	v_perm_b32 v41, v59, v58, s15
	v_perm_b32 v42, v61, v60, s15
	v_perm_b32 v43, v51, v50, s15
	ds_read_b64_tr_b16 v[50:51], v104 offset:4352
	ds_read_b64_tr_b16 v[54:55], v105
	ds_read_b64_tr_b16 v[56:57], v105 offset:1088
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[44:47], v[40:43], v[0:15]
	v_perm_b32 v44, v139, v138, s15
	v_perm_b32 v45, v141, v140, s15
	v_perm_b32 v46, v143, v142, s15
	v_perm_b32 v47, v144, v128, s15
	v_mul_f32_e64 v30, v48, v30
	v_mul_f32_e64 v31, v48, v31
	v_pk_mul_f32 v[28:29], v[48:49], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[48:49], v[26:27] op_sel_hi:[0,1]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[50:53], v[44:47], v[0:15]
	v_mul_f32_e64 v24, v48, v24
	v_mul_f32_e64 v25, v48, v25
	v_mul_f32_e64 v22, v48, v22
	v_mul_f32_e64 v23, v48, v23
	v_mul_f32_e64 v20, v48, v20
	v_mul_f32_e64 v21, v48, v21
	v_pk_mul_f32 v[18:19], v[48:49], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[48:49], v[16:17] op_sel_hi:[0,1]
	ds_read_b64_tr_b16 v[50:51], v105 offset:4352
	ds_read_b64_tr_b16 v[52:53], v105 offset:5440
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[54:57], v[32:35], v[16:31]
	ds_read_b64_tr_b16 v[54:55], v106
	ds_read_b64_tr_b16 v[56:57], v106 offset:1088
	v_add_f32_e32 v32, v110, v136
	v_add_f32_e32 v32, v32, v137
	v_add_f32_e32 v32, v32, v138
	v_add_f32_e32 v32, v32, v139
	v_add_f32_e32 v32, v32, v140
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[50:53], v[36:39], v[16:31]
	ds_read_b64_tr_b16 v[36:37], v106 offset:4352
	ds_read_b64_tr_b16 v[38:39], v106 offset:5440
	v_add_f32_e32 v32, v32, v141
	v_add_f32_e32 v32, v32, v142
	v_add_f32_e32 v32, v32, v143
	v_add_f32_e32 v32, v32, v128
	v_add_f32_e32 v32, v32, v144
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[54:57], v[40:43], v[16:31]
	v_mov_b32_e32 v33, v32
	v_mov_b32_e32 v34, v32
	s_nop 1
	v_permlane32_swap_b32_e32 v33, v34
	v_cmp_eq_u32_e32 vcc, v33, v32
	v_fmac_f32_e32 v32, v48, v95
	v_mov_b32_e32 v110, v111
	v_cndmask_b32_e32 v33, v33, v34, vcc
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[36:39], v[44:47], v[16:31]
	v_add_f32_e32 v95, v32, v33
	v_mov_b64_e32 v[32:33], s[2:3]
	v_cmp_lt_u64_e32 vcc, s[8:9], v[32:33]
	s_cbranch_vccz .LBB0_11
.LBB0_8:
	v_lshl_add_u64 v[32:33], v[86:87], 0, s[8:9]
	v_cmp_gt_i64_e32 vcc, s[4:5], v[32:33]
	s_add_i32 s16, s8, 63
	s_cmp_le_i32 s16, s20
	v_cndmask_b32_e32 v33, v107, v33, vcc
	v_cndmask_b32_e32 v32, v108, v32, vcc
	v_lshlrev_b64 v[32:33], 6, v[32:33]
	v_lshl_add_u64 v[32:33], v[88:89], 0, v[32:33]
	v_lshlrev_b64 v[64:65], 1, v[32:33]
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[32:33], s[10:11], 0, v[64:65]
	global_load_dwordx4 v[34:37], v[32:33], off
	global_load_dwordx4 v[38:41], v[32:33], off offset:16
	v_lshl_add_u64 v[32:33], v[90:91], 0, s[8:9]
	v_cmp_gt_i64_e32 vcc, s[4:5], v[32:33]
	s_nop 1
	v_cndmask_b32_e32 v33, v107, v33, vcc
	v_cndmask_b32_e32 v32, v108, v32, vcc
	v_lshlrev_b64 v[32:33], 6, v[32:33]
	v_lshl_add_u64 v[32:33], v[88:89], 0, v[32:33]
	v_lshlrev_b64 v[66:67], 1, v[32:33]
	v_lshl_add_u64 v[32:33], s[10:11], 0, v[66:67]
	global_load_dwordx4 v[42:45], v[32:33], off offset:16
	global_load_dwordx4 v[46:49], v[32:33], off
	s_waitcnt vmcnt(2)
	ds_write_b128 v96, v[38:41] offset:16
	ds_write_b128 v96, v[34:37]
	s_waitcnt vmcnt(1)
	ds_write_b128 v97, v[42:45] offset:16
	s_waitcnt vmcnt(0)
	ds_write_b128 v97, v[46:49]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[32:35], v98
	ds_read_b128 v[68:71], v98 offset:4096
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[32:35], v[112:115], 0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[68:71], v[112:115], 0
	ds_read_b128 v[68:71], v99
	ds_read_b128 v[72:75], v99 offset:4096
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[68:71], v[120:123], v[48:63]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[72:75], v[120:123], v[32:47]
	ds_read_b128 v[68:71], v100
	ds_read_b128 v[72:75], v100 offset:4096
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[68:71], v[116:119], v[48:63]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[72:75], v[116:119], v[32:47]
	ds_read_b128 v[68:71], v101
	ds_read_b128 v[72:75], v101 offset:4096
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[48:63], v[68:71], v[124:127], v[48:63]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[32:47], v[72:75], v[124:127], v[32:47]
	s_cbranch_scc1 .LBB0_7
	v_add_u32_e32 v68, s8, v94
	v_cmp_le_i32_e32 vcc, v68, v92
	v_or_b32_e32 v70, 2, v68
	v_or_b32_e32 v69, 3, v68
	s_nop 4
	v_cndmask_b32_e32 v48, v109, v48, vcc
	v_cmp_gt_i32_e32 vcc, v92, v68
	s_nop 1
	v_cndmask_b32_e32 v49, v109, v49, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 8, v68
	s_nop 0
	v_cndmask_b32_e32 v50, v109, v50, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 9, v68
	s_nop 0
	v_cndmask_b32_e32 v51, v109, v51, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 10, v68
	s_nop 0
	v_cndmask_b32_e32 v52, v109, v52, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 11, v68
	s_nop 0
	v_cndmask_b32_e32 v53, v109, v53, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 16, v68
	s_nop 0
	v_cndmask_b32_e32 v54, v109, v54, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 17, v68
	s_nop 0
	v_cndmask_b32_e32 v55, v109, v55, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 18, v68
	s_nop 0
	v_cndmask_b32_e32 v56, v109, v56, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 19, v68
	s_nop 0
	v_cndmask_b32_e32 v57, v109, v57, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 24, v68
	s_nop 0
	v_cndmask_b32_e32 v58, v109, v58, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 25, v68
	s_nop 0
	v_cndmask_b32_e32 v59, v109, v59, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 26, v68
	s_nop 0
	v_cndmask_b32_e32 v60, v109, v60, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 27, v68
	s_nop 0
	v_cndmask_b32_e32 v61, v109, v61, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 32, v68
	s_nop 0
	v_cndmask_b32_e32 v62, v109, v62, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 33, v68
	s_nop 0
	v_cndmask_b32_e32 v63, v109, v63, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 34, v68
	s_nop 0
	v_cndmask_b32_e32 v32, v109, v32, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 35, v68
	s_nop 0
	v_cndmask_b32_e32 v33, v109, v33, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 40, v68
	s_nop 0
	v_cndmask_b32_e32 v34, v109, v34, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 41, v68
	s_nop 0
	v_cndmask_b32_e32 v35, v109, v35, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 42, v68
	s_nop 0
	v_cndmask_b32_e32 v36, v109, v36, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 43, v68
	s_nop 0
	v_cndmask_b32_e32 v37, v109, v37, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 48, v68
	s_nop 0
	v_cndmask_b32_e32 v38, v109, v38, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 49, v68
	s_nop 0
	v_cndmask_b32_e32 v39, v109, v39, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 50, v68
	s_nop 0
	v_cndmask_b32_e32 v40, v109, v40, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 51, v68
	s_nop 0
	v_cndmask_b32_e32 v41, v109, v41, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	v_or_b32_e32 v70, 56, v68
	s_nop 0
	v_cndmask_b32_e32 v42, v109, v42, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 57, v68
	s_nop 0
	v_cndmask_b32_e32 v43, v109, v43, vcc
	v_cmp_le_i32_e32 vcc, v70, v92
	s_nop 1
	v_cndmask_b32_e32 v44, v109, v44, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	v_or_b32_e32 v69, 59, v68
	v_or_b32_e32 v68, 58, v68
	v_cndmask_b32_e32 v45, v109, v45, vcc
	v_cmp_le_i32_e32 vcc, v68, v92
	s_nop 1
	v_cndmask_b32_e32 v46, v109, v46, vcc
	v_cmp_le_i32_e32 vcc, v69, v81
	s_nop 1
	v_cndmask_b32_e32 v47, v109, v47, vcc
	s_branch .LBB0_7
.LBB0_10:
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
	v_mov_b32_e32 v95, v85
.LBB0_11:
	v_rcp_f32_e32 v32, v95
	v_cmp_lt_f32_e32 vcc, 0, v95
	s_load_dwordx2 s[0:1], s[0:1], 0x90
	s_mov_b32 s7, 0x27000
	v_cndmask_b32_e32 v32, 0, v32, vcc
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
	s_waitcnt lgkmcnt(0)
	s_add_u32 s4, s0, s19
	v_pk_mul_f32 v[14:15], v[32:33], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[32:33], v[12:13] op_sel_hi:[0,1]
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
	s_addc_u32 s0, s1, s18
	s_nop 0
	v_permlane32_swap_b32_e32 v7, v32
	v_cmp_eq_u64_e32 vcc, 0, v[84:85]
	s_and_b32 s5, s0, 0xffff
	s_nop 0
	v_cndmask_b32_e32 v0, v4, v0, vcc
	v_cndmask_b32_e32 v1, v7, v1, vcc
	v_cndmask_b32_e32 v2, v2, v5, vcc
	v_cndmask_b32_e32 v3, v3, v6, vcc
	buffer_store_dwordx4 v[0:3], v93, s[4:7], 0 offen
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
	buffer_store_dwordx4 v[0:3], v5, s[4:7], 0 offen
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
	buffer_store_dwordx4 v[0:3], v83, s[4:7], 0 offen
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
	buffer_store_dwordx4 v[0:3], v4, s[4:7], 0 offen
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
		.amdhsa_next_free_vgpr 145
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

	.set .Lflash_attn_generic_kernel_0.num_vgpr, 145
	.set .Lflash_attn_generic_kernel_0.num_agpr, 0
	.set .Lflash_attn_generic_kernel_0.numbered_sgpr, 22
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
    .sgpr_count:     28
    .sgpr_spill_count: 0
    .symbol:         flash_attn_generic_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     145
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
