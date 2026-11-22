; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_hti_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0
	.p2align	8
	.type	hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0,@function
hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0:
	s_load_dwordx4 s[12:15], s[0:1], 0x7c
	s_load_dwordx2 s[16:17], s[0:1], 0x8c
	v_lshlrev_b32_e32 v166, 3, v0
	v_lshrrev_b32_e32 v8, 3, v0
	s_movk_i32 s30, 0xff
	s_waitcnt lgkmcnt(0)
	s_add_i32 s6, s13, 0xff
	s_ashr_i32 s4, s6, 31
	s_lshr_b32 s4, s4, 24
	s_add_i32 s4, s6, s4
	s_ashr_i32 s8, s4, 8
	s_and_b32 s4, s4, 0xffffff00
	s_cmp_lg_u32 s6, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	s_subb_u32 s6, s8, 0
	s_abs_i32 s7, s6
	v_cvt_f32_u32_e32 v1, s7
	s_sub_i32 s19, 0, s7
	s_abs_i32 s11, s2
	s_xor_b32 s10, s6, s2
	v_rcp_f32_e32 v2, v1
	s_ashr_i32 s15, s10, 31
	s_load_dwordx2 s[4:5], s[0:1], 0x18
	s_load_dwordx2 s[8:9], s[0:1], 0x30
	s_load_dword s18, s[0:1], 0x94
	s_mul_i32 s29, s16, s3
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_lshrrev_b32_e32 v1, 6, v0
	v_readfirstlane_b32 s20, v2
	s_mul_i32 s19, s19, s20
	s_mul_hi_u32 s19, s20, s19
	s_add_i32 s20, s20, s19
	s_mul_hi_u32 s19, s11, s20
	s_mul_i32 s20, s19, s7
	s_sub_i32 s11, s11, s20
	s_add_i32 s20, s19, 1
	s_sub_i32 s21, s11, s7
	s_cmp_ge_u32 s11, s7
	s_cselect_b32 s19, s20, s19
	s_cselect_b32 s11, s21, s11
	s_add_i32 s20, s19, 1
	s_cmp_ge_u32 s11, s7
	s_cselect_b32 s7, s20, s19
	s_xor_b32 s19, s7, s15
	s_sub_i32 s7, s19, s15
	s_mul_i32 s20, s7, s6
	s_cmp_lg_u32 s2, s20
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s10, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s6, s19, s15
	s_sub_i32 s2, s2, s20
	s_lshl_b32 s21, s2, 8
	v_bitop3_b32 v2, v166, 56, v0 bitop3:0x48
	v_add_u32_e32 v130, s29, v2
	v_or_b32_e32 v2, s21, v8
	v_cmp_gt_i32_e32 vcc, s13, v2
	v_readfirstlane_b32 s2, v1
	s_lshl_b32 s19, s6, 8
	v_cndmask_b32_e32 v2, 0, v2, vcc
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	s_lshl_b32 s15, s2, 10
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v137, v2, s18
	s_and_b32 s5, s5, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_add_i32 s22, s15, 0x10000
	v_add_u32_e32 v2, v137, v130
	v_lshlrev_b32_e32 v3, 1, v2
	s_mov_b32 m0, s22
	s_nop 0
	buffer_load_dwordx4 v3, s[8:11], 0 offen lds
	v_or_b32_e32 v167, 0x200, v0
	v_lshrrev_b32_e32 v9, 3, v167
	v_or_b32_e32 v3, s21, v9
	v_cmp_gt_i32_e32 vcc, s13, v3
	s_add_i32 s23, s15, 0x12000
	s_nop 0
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_mul_lo_u32 v138, v3, s18
	v_add_u32_e32 v3, v138, v130
	v_lshlrev_b32_e32 v4, 1, v3
	s_mov_b32 m0, s23
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], 0 offen lds
	v_or_b32_e32 v4, s19, v8
	v_cmp_gt_i32_e32 vcc, s12, v4
	s_nop 1
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v139, v4, s17
	v_add_u32_e32 v4, v139, v130
	v_lshlrev_b32_e32 v5, 1, v4
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v5, s[4:7], 0 offen lds
	v_or_b32_e32 v5, s19, v9
	v_cmp_gt_i32_e32 vcc, s12, v5
	s_add_i32 s24, s15, 0x2000
	s_nop 0
	v_cndmask_b32_e32 v5, 0, v5, vcc
	v_mul_lo_u32 v140, v5, s17
	v_add_u32_e32 v5, v140, v130
	v_lshlrev_b32_e32 v6, 1, v5
	s_mov_b32 m0, s24
	s_nop 0
	buffer_load_dwordx4 v6, s[4:7], 0 offen lds
	s_or_b32 s20, s21, 0x80
	v_or_b32_e32 v6, s20, v8
	v_cmp_gt_i32_e32 vcc, s13, v6
	s_add_i32 s25, s15, 0x14000
	s_nop 0
	v_cndmask_b32_e32 v6, 0, v6, vcc
	v_mul_lo_u32 v141, v6, s18
	v_add_u32_e32 v6, v141, v130
	v_lshlrev_b32_e32 v7, 1, v6
	s_mov_b32 m0, s25
	s_nop 0
	buffer_load_dwordx4 v7, s[8:11], 0 offen lds
	v_or_b32_e32 v7, s20, v9
	v_cmp_gt_i32_e32 vcc, s13, v7
	s_add_i32 s26, s15, 0x16000
	s_nop 0
	v_cndmask_b32_e32 v7, 0, v7, vcc
	v_mul_lo_u32 v142, v7, s18
	v_add_u32_e32 v7, v142, v130
	v_lshlrev_b32_e32 v10, 1, v7
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v10, s[8:11], 0 offen lds
	s_or_b32 s18, s19, 0x80
	v_or_b32_e32 v8, s18, v8
	v_cmp_gt_i32_e32 vcc, s12, v8
	s_add_i32 s27, s15, 0x4000
	s_nop 0
	v_cndmask_b32_e32 v8, 0, v8, vcc
	v_mul_lo_u32 v131, v8, s17
	v_add_lshl_u32 v8, v131, v130, 1
	s_mov_b32 m0, s27
	s_nop 0
	buffer_load_dwordx4 v8, s[4:7], 0 offen lds
	v_or_b32_e32 v8, s18, v9
	v_cmp_gt_i32_e32 vcc, s12, v8
	s_add_i32 s28, s15, 0x6000
	s_nop 0
	v_cndmask_b32_e32 v8, 0, v8, vcc
	v_mul_lo_u32 v132, v8, s17
	v_add_lshl_u32 v8, v132, v130, 1
	s_mov_b32 m0, s28
	s_nop 0
	buffer_load_dwordx4 v8, s[4:7], 0 offen lds
	s_movk_i32 s2, 0x100
	v_cmp_gt_u32_e32 vcc, s2, v0
	v_cmp_lt_u32_e64 s[2:3], s30, v0
	s_and_saveexec_b64 s[10:11], s[2:3]
	s_cbranch_execz .LBB0_2
	s_barrier
	s_waitcnt vmcnt(0)
.LBB0_2:
	s_or_b64 exec, exec, s[10:11]
	s_add_i32 s10, s29, s16
	s_min_i32 s10, s10, s14
	s_sub_i32 s14, s10, s29
	s_ashr_i32 s10, s14, 31
	s_lshr_b32 s10, s10, 26
	s_add_i32 s10, s14, s10
	s_ashr_i32 s29, s10, 6
	s_andn2_b32 s10, s10, 63
	s_cmp_lg_u32 s14, s10
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lt_i32 s14, 0
	s_cselect_b64 s[16:17], -1, 0
	s_and_b64 s[10:11], s[16:17], s[10:11]
	s_subb_u32 s14, s29, 0
	s_barrier
	s_add_i32 s16, s22, 0x8000
	v_mov_b32_e32 v8, 0x80
	v_lshl_add_u32 v2, v2, 1, v8
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v2, s[8:11], 0 offen lds
	s_add_i32 s17, s22, 0xa000
	v_lshl_add_u32 v2, v3, 1, v8
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v2, s[8:11], 0 offen lds
	s_add_i32 s29, s15, 0x8000
	v_lshl_add_u32 v2, v4, 1, v8
	s_mov_b32 m0, s29
	s_nop 0
	buffer_load_dwordx4 v2, s[4:7], 0 offen lds
	s_add_i32 s30, s15, 0xa000
	v_lshl_add_u32 v2, v5, 1, v8
	s_mov_b32 m0, s30
	s_nop 0
	buffer_load_dwordx4 v2, s[4:7], 0 offen lds
	s_add_i32 s31, s22, 0xc000
	v_lshl_add_u32 v2, v6, 1, v8
	s_mov_b32 m0, s31
	s_nop 0
	buffer_load_dwordx4 v2, s[8:11], 0 offen lds
	s_add_i32 s33, s22, 0xe000
	v_lshl_add_u32 v2, v7, 1, v8
	s_mov_b32 m0, s33
	s_nop 0
	buffer_load_dwordx4 v2, s[8:11], 0 offen lds
	s_cmp_gt_i32 s14, 2
	v_lshlrev_b32_e32 v3, 4, v0
	v_and_b32_e32 v133, 56, v166
	v_lshlrev_b32_e32 v2, 2, v0
	s_waitcnt vmcnt(4)
	s_barrier
	s_cbranch_scc1 .LBB0_4
	v_and_b32_e32 v134, 0xc00, v3
	v_and_b32_e32 v135, 0x400, v2
	s_mov_b64 s[10:11], 0
	s_branch .LBB0_5
.LBB0_4:
	s_mov_b64 s[10:11], -1
.LBB0_5:
	s_and_b64 s[10:11], s[10:11], exec
	s_cselect_b32 s10, 1, 0
	s_cmp_lg_u32 s10, 1
	v_lshrrev_b32_e32 v136, 1, v0
	s_cbranch_scc1 .LBB0_8
	v_lshlrev_b32_e32 v4, 6, v0
	v_and_b32_e32 v4, 0x3c0, v4
	v_and_b32_e32 v5, 24, v136
	v_and_b32_e32 v134, 0xc00, v3
	v_bitop3_b32 v3, v4, v133, v5 bitop3:0x36
	v_and_b32_e32 v135, 0x400, v2
	v_or_b32_e32 v6, v4, v5
	v_or_b32_e32 v2, v3, v135
	v_or_b32_e32 v4, v3, v134
	v_or_b32_e32 v5, v6, v134
	v_lshlrev_b32_e32 v145, 1, v2
	v_or_b32_e32 v2, v6, v135
	v_lshlrev_b32_e32 v4, 1, v4
	v_bitop3_b32 v5, v5, v133, 32 bitop3:0x36
	v_mov_b32_e32 v7, 0x10000
	v_bitop3_b32 v2, v2, v133, 32 bitop3:0x36
	v_mov_b32_e32 v122, 0
	s_add_i32 s34, s14, -2
	v_or_b32_e32 v143, 0x10000, v4
	v_lshl_or_b32 v144, v5, 1, v7
	v_lshlrev_b32_e32 v146, 1, v2
	s_add_i32 s35, s15, 0xc000
	v_add_u32_e32 v147, 64, v130
	s_add_i32 s36, s15, 0xe000
	v_or_b32_e32 v148, 0x14000, v4
	v_or_b32_e32 v149, 0x18000, v4
	v_or_b32_e32 v150, 0x1c000, v4
	s_mov_b32 s38, 0
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	v_mov_b32_e32 v123, v122
	v_mov_b32_e32 v124, v122
	v_mov_b32_e32 v125, v122
	v_mov_b32_e32 v126, v122
	v_mov_b32_e32 v127, v122
	v_mov_b32_e32 v128, v122
	v_mov_b32_e32 v129, v122
	v_mov_b32_e32 v114, v122
	v_mov_b32_e32 v115, v122
	v_mov_b32_e32 v116, v122
	v_mov_b32_e32 v117, v122
	v_mov_b32_e32 v106, v122
	v_mov_b32_e32 v107, v122
	v_mov_b32_e32 v108, v122
	v_mov_b32_e32 v109, v122
	v_mov_b32_e32 v94, v122
	v_mov_b32_e32 v95, v122
	v_mov_b32_e32 v96, v122
	v_mov_b32_e32 v97, v122
	v_mov_b32_e32 v82, v122
	v_mov_b32_e32 v83, v122
	v_mov_b32_e32 v84, v122
	v_mov_b32_e32 v85, v122
	v_mov_b32_e32 v70, v122
	v_mov_b32_e32 v71, v122
	v_mov_b32_e32 v72, v122
	v_mov_b32_e32 v73, v122
	v_mov_b32_e32 v66, v122
	v_mov_b32_e32 v67, v122
	v_mov_b32_e32 v68, v122
	v_mov_b32_e32 v69, v122
	v_mov_b32_e32 v118, v122
	v_mov_b32_e32 v119, v122
	v_mov_b32_e32 v120, v122
	v_mov_b32_e32 v121, v122
	v_mov_b32_e32 v110, v122
	v_mov_b32_e32 v111, v122
	v_mov_b32_e32 v112, v122
	v_mov_b32_e32 v113, v122
	v_mov_b32_e32 v102, v122
	v_mov_b32_e32 v103, v122
	v_mov_b32_e32 v104, v122
	v_mov_b32_e32 v105, v122
	v_mov_b32_e32 v90, v122
	v_mov_b32_e32 v91, v122
	v_mov_b32_e32 v92, v122
	v_mov_b32_e32 v93, v122
	v_mov_b32_e32 v78, v122
	v_mov_b32_e32 v79, v122
	v_mov_b32_e32 v80, v122
	v_mov_b32_e32 v81, v122
	v_mov_b32_e32 v62, v122
	v_mov_b32_e32 v63, v122
	v_mov_b32_e32 v64, v122
	v_mov_b32_e32 v65, v122
	v_mov_b32_e32 v54, v122
	v_mov_b32_e32 v55, v122
	v_mov_b32_e32 v56, v122
	v_mov_b32_e32 v57, v122
	v_mov_b32_e32 v50, v122
	v_mov_b32_e32 v51, v122
	v_mov_b32_e32 v52, v122
	v_mov_b32_e32 v53, v122
	v_mov_b32_e32 v98, v122
	v_mov_b32_e32 v99, v122
	v_mov_b32_e32 v100, v122
	v_mov_b32_e32 v101, v122
	v_mov_b32_e32 v86, v122
	v_mov_b32_e32 v87, v122
	v_mov_b32_e32 v88, v122
	v_mov_b32_e32 v89, v122
	v_mov_b32_e32 v74, v122
	v_mov_b32_e32 v75, v122
	v_mov_b32_e32 v76, v122
	v_mov_b32_e32 v77, v122
	v_mov_b32_e32 v58, v122
	v_mov_b32_e32 v59, v122
	v_mov_b32_e32 v60, v122
	v_mov_b32_e32 v61, v122
	v_mov_b32_e32 v46, v122
	v_mov_b32_e32 v47, v122
	v_mov_b32_e32 v48, v122
	v_mov_b32_e32 v49, v122
	v_mov_b32_e32 v38, v122
	v_mov_b32_e32 v39, v122
	v_mov_b32_e32 v40, v122
	v_mov_b32_e32 v41, v122
	v_mov_b32_e32 v30, v122
	v_mov_b32_e32 v31, v122
	v_mov_b32_e32 v32, v122
	v_mov_b32_e32 v33, v122
	v_mov_b32_e32 v26, v122
	v_mov_b32_e32 v27, v122
	v_mov_b32_e32 v28, v122
	v_mov_b32_e32 v29, v122
	v_mov_b32_e32 v42, v122
	v_mov_b32_e32 v43, v122
	v_mov_b32_e32 v44, v122
	v_mov_b32_e32 v45, v122
	v_mov_b32_e32 v34, v122
	v_mov_b32_e32 v35, v122
	v_mov_b32_e32 v36, v122
	v_mov_b32_e32 v37, v122
	v_mov_b32_e32 v22, v122
	v_mov_b32_e32 v23, v122
	v_mov_b32_e32 v24, v122
	v_mov_b32_e32 v25, v122
	v_mov_b32_e32 v18, v122
	v_mov_b32_e32 v19, v122
	v_mov_b32_e32 v20, v122
	v_mov_b32_e32 v21, v122
	v_mov_b32_e32 v14, v122
	v_mov_b32_e32 v15, v122
	v_mov_b32_e32 v16, v122
	v_mov_b32_e32 v17, v122
	v_mov_b32_e32 v10, v122
	v_mov_b32_e32 v11, v122
	v_mov_b32_e32 v12, v122
	v_mov_b32_e32 v13, v122
	v_mov_b32_e32 v6, v122
	v_mov_b32_e32 v7, v122
	v_mov_b32_e32 v8, v122
	v_mov_b32_e32 v9, v122
	v_mov_b32_e32 v2, v122
	v_mov_b32_e32 v3, v122
	v_mov_b32_e32 v4, v122
	v_mov_b32_e32 v5, v122
	.p2align	5, , 4
.LBB0_7:
	ds_read_b128 v[154:157], v143
	ds_read_b128 v[158:161], v143 offset:8192
	ds_read_b128 v[162:165], v144
	ds_read_b128 v[168:171], v144 offset:8192
	ds_read_b128 v[172:175], v145
	ds_read_b128 v[176:179], v145 offset:4096
	ds_read_b128 v[180:183], v145 offset:8192
	ds_read_b128 v[184:187], v145 offset:12288
	ds_read_b128 v[188:191], v146
	ds_read_b128 v[192:195], v146 offset:4096
	ds_read_b128 v[196:199], v146 offset:8192
	ds_read_b128 v[200:203], v146 offset:12288
	s_add_i32 s37, s38, 2
	v_lshl_add_u32 v151, s38, 6, v147
	v_add_lshl_u32 v152, v151, v131, 1
	s_mov_b32 m0, s35
	s_nop 0
	buffer_load_dwordx4 v152, s[4:7], 0 offen lds
	v_add_lshl_u32 v152, v151, v132, 1
	s_mov_b32 m0, s36
	s_nop 0
	buffer_load_dwordx4 v152, s[4:7], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[122:125], v[172:175], v[154:157], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[172:175], v[158:161], v[126:129]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[114:117], v[176:179], v[154:157], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[176:179], v[158:161], v[106:109]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[94:97], v[180:183], v[154:157], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[180:183], v[158:161], v[82:85]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[184:187], v[154:157], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[184:187], v[158:161], v[66:69]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[122:125], v[188:191], v[162:165], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[188:191], v[168:171], v[126:129]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[114:117], v[192:195], v[162:165], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[192:195], v[168:171], v[106:109]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[94:97], v[196:199], v[162:165], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[196:199], v[168:171], v[82:85]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[200:203], v[162:165], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[200:203], v[168:171], v[66:69]
	s_barrier
	ds_read_b128 v[204:207], v148
	ds_read_b128 v[208:211], v148 offset:8192
	ds_read_b128 v[212:215], v144 offset:16384
	ds_read_b128 v[216:219], v144 offset:24576
	v_lshl_add_u32 v152, s37, 6, v130
	v_add_lshl_u32 v153, v152, v137, 1
	s_mov_b32 m0, s22
	s_nop 0
	buffer_load_dwordx4 v153, s[8:11], 0 offen lds
	v_add_lshl_u32 v153, v152, v138, 1
	s_mov_b32 m0, s23
	s_nop 0
	buffer_load_dwordx4 v153, s[8:11], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[118:121], v[172:175], v[204:207], v[118:121]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[172:175], v[208:211], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[176:179], v[204:207], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[176:179], v[208:211], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[180:183], v[204:207], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[180:183], v[208:211], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[184:187], v[204:207], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[184:187], v[208:211], v[50:53]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[118:121], v[188:191], v[212:215], v[118:121]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[188:191], v[216:219], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[192:195], v[212:215], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[192:195], v[216:219], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[196:199], v[212:215], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[196:199], v[216:219], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[200:203], v[212:215], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[200:203], v[216:219], v[50:53]
	s_barrier
	ds_read_b128 v[172:175], v145 offset:16384
	ds_read_b128 v[176:179], v145 offset:20480
	ds_read_b128 v[180:183], v145 offset:24576
	ds_read_b128 v[184:187], v145 offset:28672
	ds_read_b128 v[188:191], v146 offset:16384
	ds_read_b128 v[192:195], v146 offset:20480
	ds_read_b128 v[196:199], v146 offset:24576
	ds_read_b128 v[200:203], v146 offset:28672
	v_add_lshl_u32 v153, v152, v139, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v153, s[4:7], 0 offen lds
	v_add_lshl_u32 v153, v152, v140, 1
	s_mov_b32 m0, s24
	s_nop 0
	buffer_load_dwordx4 v153, s[4:7], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[98:101], v[172:175], v[154:157], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[172:175], v[158:161], v[86:89]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[74:77], v[176:179], v[154:157], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[176:179], v[158:161], v[58:61]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[46:49], v[180:183], v[154:157], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[180:183], v[158:161], v[38:41]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[184:187], v[154:157], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[184:187], v[158:161], v[26:29]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[98:101], v[188:191], v[162:165], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[188:191], v[168:171], v[86:89]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[74:77], v[192:195], v[162:165], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[192:195], v[168:171], v[58:61]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[46:49], v[196:199], v[162:165], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[196:199], v[168:171], v[38:41]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[200:203], v[162:165], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[200:203], v[168:171], v[26:29]
	s_barrier
	ds_read_b128 v[154:157], v149
	ds_read_b128 v[158:161], v149 offset:8192
	ds_read_b128 v[162:165], v144 offset:32768
	ds_read_b128 v[168:171], v144 offset:40960
	v_add_lshl_u32 v153, v152, v141, 1
	s_mov_b32 m0, s25
	s_nop 0
	buffer_load_dwordx4 v153, s[8:11], 0 offen lds
	v_add_lshl_u32 v153, v152, v142, 1
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v153, s[8:11], 0 offen lds
	s_waitcnt vmcnt(6)
	s_barrier
	v_mfma_f32_16x16x32_bf16 v[42:45], v[172:175], v[204:207], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[172:175], v[208:211], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[176:179], v[204:207], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[176:179], v[208:211], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[180:183], v[204:207], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[180:183], v[208:211], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[184:187], v[204:207], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[184:187], v[208:211], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[188:191], v[212:215], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[188:191], v[216:219], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[192:195], v[212:215], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[192:195], v[216:219], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[196:199], v[212:215], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[196:199], v[216:219], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[200:203], v[212:215], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[200:203], v[216:219], v[2:5]
	s_barrier
	ds_read_b128 v[172:175], v145 offset:32768
	ds_read_b128 v[176:179], v145 offset:36864
	ds_read_b128 v[180:183], v145 offset:40960
	ds_read_b128 v[184:187], v145 offset:45056
	ds_read_b128 v[188:191], v146 offset:32768
	ds_read_b128 v[192:195], v146 offset:36864
	ds_read_b128 v[196:199], v146 offset:40960
	ds_read_b128 v[200:203], v146 offset:45056
	v_add_lshl_u32 v153, v152, v131, 1
	s_mov_b32 m0, s27
	s_nop 0
	buffer_load_dwordx4 v153, s[4:7], 0 offen lds
	v_add_lshl_u32 v152, v152, v132, 1
	s_mov_b32 m0, s28
	s_nop 0
	buffer_load_dwordx4 v152, s[4:7], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[122:125], v[172:175], v[154:157], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[172:175], v[158:161], v[126:129]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[114:117], v[176:179], v[154:157], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[176:179], v[158:161], v[106:109]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[94:97], v[180:183], v[154:157], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[180:183], v[158:161], v[82:85]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[184:187], v[154:157], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[184:187], v[158:161], v[66:69]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[122:125], v[188:191], v[162:165], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[188:191], v[168:171], v[126:129]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[114:117], v[192:195], v[162:165], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[192:195], v[168:171], v[106:109]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[94:97], v[196:199], v[162:165], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[196:199], v[168:171], v[82:85]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[200:203], v[162:165], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[200:203], v[168:171], v[66:69]
	s_barrier
	ds_read_b128 v[204:207], v150
	ds_read_b128 v[208:211], v150 offset:8192
	ds_read_b128 v[212:215], v144 offset:49152
	ds_read_b128 v[216:219], v144 offset:57344
	v_add_u32_e32 v151, 0x80, v151
	v_add_lshl_u32 v152, v151, v137, 1
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v152, s[8:11], 0 offen lds
	v_add_lshl_u32 v152, v151, v138, 1
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v152, s[8:11], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[118:121], v[172:175], v[204:207], v[118:121]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[172:175], v[208:211], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[176:179], v[204:207], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[176:179], v[208:211], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[180:183], v[204:207], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[180:183], v[208:211], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[184:187], v[204:207], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[184:187], v[208:211], v[50:53]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[118:121], v[188:191], v[212:215], v[118:121]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[188:191], v[216:219], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[192:195], v[212:215], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[192:195], v[216:219], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[196:199], v[212:215], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[196:199], v[216:219], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[200:203], v[212:215], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[200:203], v[216:219], v[50:53]
	s_barrier
	ds_read_b128 v[172:175], v145 offset:49152
	ds_read_b128 v[176:179], v145 offset:53248
	ds_read_b128 v[180:183], v145 offset:57344
	ds_read_b128 v[184:187], v145 offset:61440
	ds_read_b128 v[188:191], v146 offset:49152
	ds_read_b128 v[192:195], v146 offset:53248
	ds_read_b128 v[196:199], v146 offset:57344
	ds_read_b128 v[200:203], v146 offset:61440
	v_add_lshl_u32 v152, v151, v139, 1
	s_mov_b32 m0, s29
	s_nop 0
	buffer_load_dwordx4 v152, s[4:7], 0 offen lds
	v_add_lshl_u32 v152, v151, v140, 1
	s_mov_b32 m0, s30
	s_nop 0
	buffer_load_dwordx4 v152, s[4:7], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[98:101], v[172:175], v[154:157], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[172:175], v[158:161], v[86:89]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[74:77], v[176:179], v[154:157], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[176:179], v[158:161], v[58:61]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[46:49], v[180:183], v[154:157], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[180:183], v[158:161], v[38:41]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[184:187], v[154:157], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[184:187], v[158:161], v[26:29]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[98:101], v[188:191], v[162:165], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[188:191], v[168:171], v[86:89]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[74:77], v[192:195], v[162:165], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[192:195], v[168:171], v[58:61]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[46:49], v[196:199], v[162:165], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[196:199], v[168:171], v[38:41]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[200:203], v[162:165], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[200:203], v[168:171], v[26:29]
	s_barrier
	v_add_lshl_u32 v152, v151, v141, 1
	s_mov_b32 m0, s31
	s_nop 0
	buffer_load_dwordx4 v152, s[8:11], 0 offen lds
	v_add_lshl_u32 v151, v151, v142, 1
	s_mov_b32 m0, s33
	s_nop 0
	buffer_load_dwordx4 v151, s[8:11], 0 offen lds
	s_waitcnt vmcnt(4)
	s_barrier
	v_mfma_f32_16x16x32_bf16 v[42:45], v[172:175], v[204:207], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[172:175], v[208:211], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[176:179], v[204:207], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[176:179], v[208:211], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[180:183], v[204:207], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[180:183], v[208:211], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[184:187], v[204:207], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[184:187], v[208:211], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[188:191], v[212:215], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[188:191], v[216:219], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[192:195], v[212:215], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[192:195], v[216:219], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[196:199], v[212:215], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[196:199], v[216:219], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[200:203], v[212:215], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[200:203], v[216:219], v[2:5]
	s_cmp_lt_i32 s37, s34
	s_mov_b32 s38, s37
	s_barrier
	s_cbranch_scc1 .LBB0_7
	s_branch .LBB0_9
.LBB0_8:
	v_mov_b32_e32 v69, 0
	v_mov_b32_e32 v68, v69
	v_mov_b32_e32 v67, v69
	v_mov_b32_e32 v66, v69
	v_mov_b32_e32 v73, v69
	v_mov_b32_e32 v72, v69
	v_mov_b32_e32 v71, v69
	v_mov_b32_e32 v70, v69
	v_mov_b32_e32 v85, v69
	v_mov_b32_e32 v84, v69
	v_mov_b32_e32 v83, v69
	v_mov_b32_e32 v82, v69
	v_mov_b32_e32 v97, v69
	v_mov_b32_e32 v96, v69
	v_mov_b32_e32 v95, v69
	v_mov_b32_e32 v94, v69
	v_mov_b32_e32 v109, v69
	v_mov_b32_e32 v108, v69
	v_mov_b32_e32 v107, v69
	v_mov_b32_e32 v106, v69
	v_mov_b32_e32 v117, v69
	v_mov_b32_e32 v116, v69
	v_mov_b32_e32 v115, v69
	v_mov_b32_e32 v114, v69
	v_mov_b32_e32 v129, v69
	v_mov_b32_e32 v128, v69
	v_mov_b32_e32 v127, v69
	v_mov_b32_e32 v126, v69
	v_mov_b32_e32 v125, v69
	v_mov_b32_e32 v124, v69
	v_mov_b32_e32 v123, v69
	v_mov_b32_e32 v122, v69
	v_mov_b32_e32 v53, v69
	v_mov_b32_e32 v52, v69
	v_mov_b32_e32 v51, v69
	v_mov_b32_e32 v50, v69
	v_mov_b32_e32 v57, v69
	v_mov_b32_e32 v56, v69
	v_mov_b32_e32 v55, v69
	v_mov_b32_e32 v54, v69
	v_mov_b32_e32 v65, v69
	v_mov_b32_e32 v64, v69
	v_mov_b32_e32 v63, v69
	v_mov_b32_e32 v62, v69
	v_mov_b32_e32 v81, v69
	v_mov_b32_e32 v80, v69
	v_mov_b32_e32 v79, v69
	v_mov_b32_e32 v78, v69
	v_mov_b32_e32 v93, v69
	v_mov_b32_e32 v92, v69
	v_mov_b32_e32 v91, v69
	v_mov_b32_e32 v90, v69
	v_mov_b32_e32 v105, v69
	v_mov_b32_e32 v104, v69
	v_mov_b32_e32 v103, v69
	v_mov_b32_e32 v102, v69
	v_mov_b32_e32 v113, v69
	v_mov_b32_e32 v112, v69
	v_mov_b32_e32 v111, v69
	v_mov_b32_e32 v110, v69
	v_mov_b32_e32 v121, v69
	v_mov_b32_e32 v120, v69
	v_mov_b32_e32 v119, v69
	v_mov_b32_e32 v118, v69
	v_mov_b32_e32 v29, v69
	v_mov_b32_e32 v28, v69
	v_mov_b32_e32 v27, v69
	v_mov_b32_e32 v26, v69
	v_mov_b32_e32 v33, v69
	v_mov_b32_e32 v32, v69
	v_mov_b32_e32 v31, v69
	v_mov_b32_e32 v30, v69
	v_mov_b32_e32 v41, v69
	v_mov_b32_e32 v40, v69
	v_mov_b32_e32 v39, v69
	v_mov_b32_e32 v38, v69
	v_mov_b32_e32 v49, v69
	v_mov_b32_e32 v48, v69
	v_mov_b32_e32 v47, v69
	v_mov_b32_e32 v46, v69
	v_mov_b32_e32 v61, v69
	v_mov_b32_e32 v60, v69
	v_mov_b32_e32 v59, v69
	v_mov_b32_e32 v58, v69
	v_mov_b32_e32 v77, v69
	v_mov_b32_e32 v76, v69
	v_mov_b32_e32 v75, v69
	v_mov_b32_e32 v74, v69
	v_mov_b32_e32 v89, v69
	v_mov_b32_e32 v88, v69
	v_mov_b32_e32 v87, v69
	v_mov_b32_e32 v86, v69
	v_mov_b32_e32 v101, v69
	v_mov_b32_e32 v100, v69
	v_mov_b32_e32 v99, v69
	v_mov_b32_e32 v98, v69
	v_mov_b32_e32 v5, v69
	v_mov_b32_e32 v4, v69
	v_mov_b32_e32 v3, v69
	v_mov_b32_e32 v2, v69
	v_mov_b32_e32 v9, v69
	v_mov_b32_e32 v8, v69
	v_mov_b32_e32 v7, v69
	v_mov_b32_e32 v6, v69
	v_mov_b32_e32 v13, v69
	v_mov_b32_e32 v12, v69
	v_mov_b32_e32 v11, v69
	v_mov_b32_e32 v10, v69
	v_mov_b32_e32 v17, v69
	v_mov_b32_e32 v16, v69
	v_mov_b32_e32 v15, v69
	v_mov_b32_e32 v14, v69
	v_mov_b32_e32 v21, v69
	v_mov_b32_e32 v20, v69
	v_mov_b32_e32 v19, v69
	v_mov_b32_e32 v18, v69
	v_mov_b32_e32 v25, v69
	v_mov_b32_e32 v24, v69
	v_mov_b32_e32 v23, v69
	v_mov_b32_e32 v22, v69
	v_mov_b32_e32 v37, v69
	v_mov_b32_e32 v36, v69
	v_mov_b32_e32 v35, v69
	v_mov_b32_e32 v34, v69
	v_mov_b32_e32 v45, v69
	v_mov_b32_e32 v44, v69
	v_mov_b32_e32 v43, v69
	v_mov_b32_e32 v42, v69
.LBB0_9:
	v_and_b32_e32 v169, 15, v0
	v_lshlrev_b32_e32 v137, 6, v169
	v_and_or_b32 v136, v136, 24, v137
	v_bitop3_b32 v137, v136, v134, v133 bitop3:0xde
	v_or_b32_e32 v134, v134, v136
	v_mov_b32_e32 v138, 0x10000
	v_bitop3_b32 v134, v134, v133, 32 bitop3:0x36
	v_lshl_add_u32 v173, v134, 1, v138
	v_bitop3_b32 v134, v136, v135, v133 bitop3:0xde
	v_lshlrev_b32_e32 v170, 1, v134
	v_or_b32_e32 v134, v135, v136
	v_bitop3_b32 v133, v134, v133, 32 bitop3:0x36
	v_lshlrev_b32_e32 v171, 1, v133
	ds_read_b128 v[146:149], v170
	ds_read_b128 v[150:153], v170 offset:4096
	ds_read_b128 v[154:157], v170 offset:8192
	ds_read_b128 v[158:161], v170 offset:12288
	ds_read_b128 v[162:165], v171
	ds_read_b128 v[206:209], v171 offset:4096
	ds_read_b128 v[210:213], v171 offset:8192
	ds_read_b128 v[214:217], v171 offset:12288
	v_lshl_add_u32 v172, v137, 1, v138
	ds_read_b128 v[174:177], v172
	ds_read_b128 v[178:181], v172 offset:8192
	ds_read_b128 v[182:185], v173
	ds_read_b128 v[186:189], v173 offset:8192
	v_lshl_add_u32 v130, s14, 6, v130
	v_lshrrev_b32_e32 v168, 4, v0
	v_subrev_u32_e32 v130, 64, v130
	s_add_i32 m0, s15, 0xc000
	v_add_lshl_u32 v131, v131, v130, 1
	buffer_load_dwordx4 v131, s[4:7], 0 offen lds
	s_add_i32 m0, s15, 0xe000
	v_add_lshl_u32 v130, v132, v130, 1
	buffer_load_dwordx4 v130, s[4:7], 0 offen lds
	s_barrier
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[122:125], v[146:149], v[174:177], v[122:125]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[126:129], v[146:149], v[178:181], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[130:133], v[150:153], v[174:177], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[134:137], v[150:153], v[178:181], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[154:157], v[174:177], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[154:157], v[178:181], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[158:161], v[174:177], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[158:161], v[178:181], v[66:69]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[106:109], v[162:165], v[182:185], v[122:125]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[114:117], v[162:165], v[186:189], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[206:209], v[182:185], v[130:133]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[206:209], v[186:189], v[134:137]
	v_mfma_f32_16x16x32_bf16 v[130:133], v[210:213], v[182:185], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[134:137], v[210:213], v[186:189], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[138:141], v[214:217], v[182:185], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[142:145], v[214:217], v[186:189], v[66:69]
	s_barrier
	ds_read_b128 v[198:201], v172 offset:16384
	ds_read_b128 v[202:205], v172 offset:24576
	ds_read_b128 v[190:193], v173 offset:16384
	ds_read_b128 v[194:197], v173 offset:24576
	s_barrier
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[66:69], v[146:149], v[198:201], v[118:121]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[146:149], v[202:205], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[150:153], v[198:201], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[150:153], v[202:205], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[154:157], v[198:201], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[154:157], v[202:205], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[158:161], v[198:201], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[158:161], v[202:205], v[50:53]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[102:105], v[162:165], v[190:193], v[66:69]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[162:165], v[194:197], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[206:209], v[190:193], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[146:149], v[206:209], v[194:197], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[150:153], v[210:213], v[190:193], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[154:157], v[210:213], v[194:197], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[158:161], v[214:217], v[190:193], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[162:165], v[214:217], v[194:197], v[50:53]
	s_barrier
	ds_read_b128 v[226:229], v170 offset:16384
	ds_read_b128 v[222:225], v170 offset:20480
	ds_read_b128 v[218:221], v170 offset:24576
	ds_read_b128 v[54:57], v170 offset:28672
	ds_read_b128 v[50:53], v171 offset:16384
	ds_read_b128 v[214:217], v171 offset:20480
	ds_read_b128 v[210:213], v171 offset:24576
	ds_read_b128 v[206:209], v171 offset:28672
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[62:65], v[226:229], v[174:177], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[226:229], v[178:181], v[86:89]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[70:73], v[222:225], v[174:177], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[222:225], v[178:181], v[58:61]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[46:49], v[218:221], v[174:177], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[218:221], v[178:181], v[38:41]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[54:57], v[174:177], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[54:57], v[178:181], v[26:29]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[92:95], v[50:53], v[182:185], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[88:91], v[50:53], v[186:189], v[66:69]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[84:87], v[214:217], v[182:185], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[80:83], v[214:217], v[186:189], v[58:61]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[76:79], v[210:213], v[182:185], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[72:75], v[210:213], v[186:189], v[38:41]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[68:71], v[206:209], v[182:185], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[64:67], v[206:209], v[186:189], v[26:29]
	s_barrier
	ds_read_b128 v[186:189], v172 offset:32768
	ds_read_b128 v[182:185], v172 offset:40960
	ds_read_b128 v[178:181], v173 offset:32768
	ds_read_b128 v[174:177], v173 offset:40960
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB0_11
	s_waitcnt vmcnt(4)
.LBB0_11:
	s_or_b64 exec, exec, s[4:5]
	v_lshrrev_b32_e32 v0, 2, v0
	v_and_b32_e32 v26, 16, v168
	v_and_or_b32 v230, v0, 12, v26
	v_lshlrev_b32_e32 v0, 4, v1
	v_and_or_b32 v231, v0, 48, v169
	s_barrier
	v_mfma_f32_16x16x32_bf16 v[26:29], v[226:229], v[198:201], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[226:229], v[202:205], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[222:225], v[198:201], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[222:225], v[202:205], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[218:221], v[198:201], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[218:221], v[202:205], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[198:201], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[0:3], v[54:57], v[202:205], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[60:63], v[50:53], v[190:193], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[56:59], v[50:53], v[194:197], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[52:55], v[214:217], v[190:193], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[48:51], v[214:217], v[194:197], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[40:43], v[210:213], v[190:193], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[36:39], v[210:213], v[194:197], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[28:31], v[206:209], v[190:193], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[16:19], v[206:209], v[194:197], v[0:3]
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[190:193], v170 offset:32768
	ds_read_b128 v[194:197], v170 offset:36864
	ds_read_b128 v[198:201], v170 offset:40960
	ds_read_b128 v[202:205], v170 offset:45056
	ds_read_b128 v[206:209], v171 offset:32768
	ds_read_b128 v[210:213], v171 offset:36864
	ds_read_b128 v[214:217], v171 offset:40960
	ds_read_b128 v[218:221], v171 offset:45056
	s_barrier
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[190:193], v[186:189], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[4:7], v[190:193], v[182:185], v[114:117]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[8:11], v[194:197], v[186:189], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[12:15], v[194:197], v[182:185], v[126:129]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x32_bf16 v[20:23], v[198:201], v[186:189], v[130:133]
	v_mfma_f32_16x16x32_bf16 v[24:27], v[198:201], v[182:185], v[134:137]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[32:35], v[202:205], v[186:189], v[138:141]
	v_mfma_f32_16x16x32_bf16 v[44:47], v[202:205], v[182:185], v[142:145]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[206:209], v[178:181], v[0:3]
	v_mfma_f32_16x16x32_bf16 v[4:7], v[206:209], v[174:177], v[4:7]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[8:11], v[210:213], v[178:181], v[8:11]
	v_mfma_f32_16x16x32_bf16 v[12:15], v[210:213], v[174:177], v[12:15]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[20:23], v[214:217], v[178:181], v[20:23]
	v_mfma_f32_16x16x32_bf16 v[24:27], v[214:217], v[174:177], v[24:27]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[32:35], v[218:221], v[178:181], v[32:35]
	v_mfma_f32_16x16x32_bf16 v[44:47], v[218:221], v[174:177], v[44:47]
	s_barrier
	ds_read_b128 v[222:225], v172 offset:49152
	ds_read_b128 v[114:117], v172 offset:57344
	ds_read_b128 v[106:109], v173 offset:49152
	ds_read_b128 v[96:99], v173 offset:57344
	s_barrier
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[100:103], v[190:193], v[222:225], v[102:105]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[190:193], v[114:117], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[194:197], v[222:225], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[194:197], v[114:117], v[146:149]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[198:201], v[222:225], v[150:153]
	v_mfma_f32_16x16x32_bf16 v[130:133], v[198:201], v[114:117], v[154:157]
	v_mfma_f32_16x16x32_bf16 v[134:137], v[202:205], v[222:225], v[158:161]
	v_mfma_f32_16x16x32_bf16 v[138:141], v[202:205], v[114:117], v[162:165]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[142:145], v[206:209], v[106:109], v[100:103]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[110:113], v[206:209], v[96:99], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[210:213], v[106:109], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[210:213], v[96:99], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[214:217], v[106:109], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[130:133], v[214:217], v[96:99], v[130:133]
	v_mfma_f32_16x16x32_bf16 v[134:137], v[218:221], v[106:109], v[134:137]
	v_mfma_f32_16x16x32_bf16 v[138:141], v[218:221], v[96:99], v[138:141]
	s_barrier
	ds_read_b128 v[190:193], v170 offset:49152
	ds_read_b128 v[194:197], v170 offset:53248
	ds_read_b128 v[198:201], v170 offset:57344
	ds_read_b128 v[202:205], v170 offset:61440
	ds_read_b128 v[206:209], v171 offset:49152
	ds_read_b128 v[210:213], v171 offset:53248
	ds_read_b128 v[214:217], v171 offset:57344
	ds_read_b128 v[100:103], v171 offset:61440
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_cvt_pk_bf16_f32 v147, v44, s0
	v_lshlrev_b32_e32 v44, 1, v231
	v_cvt_pk_bf16_f32 v104, v47, s0
	v_cvt_pk_bf16_f32 v105, v46, s0
	v_cvt_pk_bf16_f32 v146, v45, s0
	v_cvt_pk_bf16_f32 v148, v27, s0
	v_cvt_pk_bf16_f32 v149, v26, s0
	v_cvt_pk_bf16_f32 v150, v25, s0
	v_cvt_pk_bf16_f32 v151, v24, s0
	v_cvt_pk_bf16_f32 v152, v15, s0
	v_cvt_pk_bf16_f32 v153, v14, s0
	v_cvt_pk_bf16_f32 v154, v13, s0
	v_cvt_pk_bf16_f32 v155, v12, s0
	v_cvt_pk_bf16_f32 v156, v7, s0
	v_cvt_pk_bf16_f32 v157, v6, s0
	v_cvt_pk_bf16_f32 v158, v5, s0
	v_cvt_pk_bf16_f32 v159, v4, s0
	v_cvt_pk_bf16_f32 v160, v35, s0
	v_cvt_pk_bf16_f32 v161, v34, s0
	v_cvt_pk_bf16_f32 v162, v33, s0
	v_cvt_pk_bf16_f32 v163, v32, s0
	v_cvt_pk_bf16_f32 v164, v23, s0
	v_mfma_f32_16x16x32_bf16 v[4:7], v[190:193], v[186:189], v[92:95]
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v92, v22, s0
	v_cvt_pk_bf16_f32 v93, v21, s0
	v_cvt_pk_bf16_f32 v94, v20, s0
	v_mfma_f32_16x16x32_bf16 v[12:15], v[190:193], v[182:185], v[88:91]
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_mfma_f32_16x16x32_bf16 v[20:23], v[194:197], v[186:189], v[84:87]
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_mfma_f32_16x16x32_bf16 v[24:27], v[194:197], v[182:185], v[80:83]
	v_mfma_f32_16x16x32_bf16 v[32:35], v[198:201], v[186:189], v[76:79]
	s_nop 2
	v_lshl_or_b32 v76, v230, 8, v44
	v_mfma_f32_16x16x32_bf16 v[44:47], v[198:201], v[182:185], v[72:75]
	ds_write_b16 v76, v0
	ds_write_b16 v76, v1 offset:256
	ds_write_b16 v76, v2 offset:512
	ds_write_b16 v76, v3 offset:768
	ds_write_b16 v76, v8 offset:8192
	ds_write_b16 v76, v9 offset:8448
	ds_write_b16 v76, v10 offset:8704
	ds_write_b16 v76, v11 offset:8960
	v_mfma_f32_16x16x32_bf16 v[68:71], v[202:205], v[186:189], v[68:71]
	ds_write_b16 v76, v94 offset:16384
	ds_write_b16 v76, v93 offset:16640
	ds_write_b16 v76, v92 offset:16896
	ds_write_b16 v76, v164 offset:17152
	ds_write_b16 v76, v163 offset:24576
	ds_write_b16 v76, v162 offset:24832
	ds_write_b16 v76, v161 offset:25088
	ds_write_b16 v76, v160 offset:25344
	ds_write_b16 v76, v159 offset:128
	v_mfma_f32_16x16x32_bf16 v[64:67], v[202:205], v[182:185], v[64:67]
	ds_write_b16 v76, v158 offset:384
	ds_write_b16 v76, v157 offset:640
	ds_write_b16 v76, v156 offset:896
	ds_write_b16 v76, v155 offset:8320
	ds_write_b16 v76, v154 offset:8576
	ds_write_b16 v76, v153 offset:8832
	ds_write_b16 v76, v152 offset:9088
	ds_write_b16 v76, v151 offset:16512
	ds_write_b16 v76, v150 offset:16768
	v_mfma_f32_16x16x32_bf16 v[0:3], v[206:209], v[178:181], v[4:7]
	ds_write_b16 v76, v149 offset:17024
	ds_write_b16 v76, v148 offset:17280
	ds_write_b16 v76, v147 offset:24704
	ds_write_b16 v76, v146 offset:24960
	ds_write_b16 v76, v105 offset:25216
	ds_write_b16 v76, v104 offset:25472
	v_mfma_f32_16x16x32_bf16 v[8:11], v[206:209], v[174:177], v[12:15]
	v_mfma_f32_16x16x32_bf16 v[4:7], v[210:213], v[178:181], v[20:23]
	v_mfma_f32_16x16x32_bf16 v[20:23], v[210:213], v[174:177], v[24:27]
	v_mfma_f32_16x16x32_bf16 v[12:15], v[214:217], v[178:181], v[32:35]
	v_mfma_f32_16x16x32_bf16 v[32:35], v[214:217], v[174:177], v[44:47]
	v_mfma_f32_16x16x32_bf16 v[24:27], v[100:103], v[178:181], v[68:71]
	v_mfma_f32_16x16x32_bf16 v[44:47], v[100:103], v[174:177], v[64:67]
	s_barrier
	v_cvt_pk_bf16_f32 v72, v121, s0
	v_cvt_pk_bf16_f32 v73, v120, s0
	v_cvt_pk_bf16_f32 v74, v119, s0
	v_cvt_pk_bf16_f32 v68, v118, s0
	v_cvt_pk_bf16_f32 v69, v145, s0
	v_cvt_pk_bf16_f32 v70, v144, s0
	v_cvt_pk_bf16_f32 v64, v143, s0
	v_cvt_pk_bf16_f32 v65, v142, s0
	v_mfma_f32_16x16x32_bf16 v[60:63], v[190:193], v[222:225], v[60:63]
	ds_write_b16 v76, v65 offset:32768
	ds_write_b16 v76, v64 offset:33024
	ds_write_b16 v76, v70 offset:33280
	ds_write_b16 v76, v69 offset:33536
	ds_write_b16 v76, v68 offset:40960
	ds_write_b16 v76, v74 offset:41216
	ds_write_b16 v76, v73 offset:41472
	ds_write_b16 v76, v72 offset:41728
	v_mfma_f32_16x16x32_bf16 v[56:59], v[190:193], v[114:117], v[56:59]
	v_cvt_pk_bf16_f32 v79, v139, s0
	v_cvt_pk_bf16_f32 v82, v132, s0
	v_cvt_pk_bf16_f32 v85, v125, s0
	v_mfma_f32_16x16x32_bf16 v[52:55], v[194:197], v[222:225], v[52:55]
	v_cvt_pk_bf16_f32 v88, v122, s0
	v_cvt_pk_bf16_f32 v90, v112, s0
	v_cvt_pk_bf16_f32 v91, v111, s0
	v_mfma_f32_16x16x32_bf16 v[48:51], v[194:197], v[114:117], v[48:51]
	v_cvt_pk_bf16_f32 v94, v136, s0
	v_cvt_pk_bf16_f32 v105, v129, s0
	v_cvt_pk_bf16_f32 v112, v126, s0
	v_mfma_f32_16x16x32_bf16 v[40:43], v[198:201], v[222:225], v[40:43]
	v_cvt_pk_bf16_f32 v77, v141, s0
	v_cvt_pk_bf16_f32 v78, v140, s0
	v_cvt_pk_bf16_f32 v80, v138, s0
	v_mfma_f32_16x16x32_bf16 v[64:67], v[198:201], v[114:117], v[36:39]
	v_cvt_pk_bf16_f32 v81, v133, s0
	v_cvt_pk_bf16_f32 v83, v131, s0
	v_cvt_pk_bf16_f32 v84, v130, s0
	v_mfma_f32_16x16x32_bf16 v[68:71], v[202:205], v[222:225], v[28:31]
	v_cvt_pk_bf16_f32 v86, v124, s0
	v_cvt_pk_bf16_f32 v87, v123, s0
	v_cvt_pk_bf16_f32 v89, v113, s0
	v_mfma_f32_16x16x32_bf16 v[72:75], v[202:205], v[114:117], v[16:19]
	v_cvt_pk_bf16_f32 v92, v110, s0
	v_cvt_pk_bf16_f32 v93, v137, s0
	v_cvt_pk_bf16_f32 v95, v135, s0
	v_mfma_f32_16x16x32_bf16 v[16:19], v[206:209], v[106:109], v[60:63]
	v_cvt_pk_bf16_f32 v104, v134, s0
	v_cvt_pk_bf16_f32 v110, v128, s0
	v_cvt_pk_bf16_f32 v111, v127, s0
	v_mfma_f32_16x16x32_bf16 v[36:39], v[206:209], v[96:99], v[56:59]
	ds_write_b16 v76, v112 offset:49152
	ds_write_b16 v76, v111 offset:49408
	ds_write_b16 v76, v110 offset:49664
	ds_write_b16 v76, v105 offset:49920
	ds_write_b16 v76, v104 offset:57344
	ds_write_b16 v76, v95 offset:57600
	ds_write_b16 v76, v94 offset:57856
	ds_write_b16 v76, v93 offset:58112
	ds_write_b16 v76, v92 offset:32896
	v_mfma_f32_16x16x32_bf16 v[28:31], v[210:213], v[106:109], v[52:55]
	ds_write_b16 v76, v91 offset:33152
	ds_write_b16 v76, v90 offset:33408
	ds_write_b16 v76, v89 offset:33664
	ds_write_b16 v76, v88 offset:41088
	ds_write_b16 v76, v87 offset:41344
	ds_write_b16 v76, v86 offset:41600
	ds_write_b16 v76, v85 offset:41856
	ds_write_b16 v76, v84 offset:49280
	ds_write_b16 v76, v83 offset:49536
	v_mfma_f32_16x16x32_bf16 v[48:51], v[210:213], v[96:99], v[48:51]
	ds_write_b16 v76, v82 offset:49792
	ds_write_b16 v76, v81 offset:50048
	ds_write_b16 v76, v80 offset:57472
	ds_write_b16 v76, v79 offset:57728
	ds_write_b16 v76, v78 offset:57984
	ds_write_b16 v76, v77 offset:58240
	v_mfma_f32_16x16x32_bf16 v[40:43], v[214:217], v[106:109], v[40:43]
	v_mfma_f32_16x16x32_bf16 v[56:59], v[214:217], v[96:99], v[64:67]
	v_mfma_f32_16x16x32_bf16 v[52:55], v[100:103], v[106:109], v[68:71]
	v_mfma_f32_16x16x32_bf16 v[60:63], v[100:103], v[96:99], v[72:75]
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_13
	s_barrier
.LBB0_13:
	s_or_b64 exec, exec, s[2:3]
	s_load_dwordx2 s[14:15], s[0:1], 0x0
	v_lshlrev_b32_e32 v70, 3, v169
	v_or_b32_e32 v66, s19, v168
	v_or_b32_e32 v68, s21, v70
	v_cmp_gt_i32_e64 s[0:1], s12, v66
	v_cmp_gt_i32_e64 s[2:3], s13, v68
	s_and_b64 s[6:7], s[2:3], s[0:1]
	v_lshlrev_b32_e32 v67, 1, v70
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], s[6:7]
	s_cbranch_execz .LBB0_15
	v_lshl_or_b32 v64, v168, 8, v67
	ds_read_b128 v[72:75], v64
	v_mad_u64_u32 v[64:65], s[6:7], v66, s13, v[68:69]
	v_ashrrev_i32_e32 v65, 31, v64
	v_lshl_add_u64 v[64:65], v[64:65], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[64:65], v[72:75], off
.LBB0_15:
	s_or_b64 exec, exec, s[4:5]
	v_lshrrev_b32_e32 v69, 4, v167
	v_and_b32_e32 v77, 0x78, v166
	v_or_b32_e32 v73, s19, v69
	v_or_b32_e32 v64, s21, v77
	v_cmp_gt_i32_e64 s[6:7], s12, v73
	v_cmp_gt_i32_e32 vcc, s13, v64
	s_and_b64 s[8:9], vcc, s[6:7]
	v_lshlrev_b32_e32 v65, 1, v77
	s_and_saveexec_b64 s[4:5], s[8:9]
	s_cbranch_execz .LBB0_17
	v_lshl_or_b32 v71, v69, 8, v65
	ds_read_b128 v[78:81], v71
	v_mad_u64_u32 v[74:75], s[8:9], v73, s13, v[64:65]
	v_ashrrev_i32_e32 v75, 31, v74
	v_lshl_add_u64 v[74:75], v[74:75], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[74:75], v[78:81], off
.LBB0_17:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v72, 64, v168
	v_or_b32_e32 v74, s19, v72
	v_cmp_gt_i32_e64 s[8:9], s12, v74
	s_and_b64 s[10:11], vcc, s[8:9]
	s_and_saveexec_b64 s[4:5], s[10:11]
	s_cbranch_execz .LBB0_19
	v_lshl_or_b32 v71, v72, 8, v65
	ds_read_b128 v[80:83], v71
	v_mad_u64_u32 v[78:79], s[10:11], v74, s13, v[64:65]
	v_ashrrev_i32_e32 v79, 31, v78
	v_lshl_add_u64 v[78:79], v[78:79], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[78:79], v[80:83], off
.LBB0_19:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v71, 0x60, v168
	v_or_b32_e32 v75, s19, v71
	v_cmp_gt_i32_e64 s[10:11], s12, v75
	s_and_b64 s[16:17], vcc, s[10:11]
	s_and_saveexec_b64 s[4:5], s[16:17]
	s_cbranch_execz .LBB0_21
	v_lshl_or_b32 v78, v71, 8, v65
	ds_read_b128 v[80:83], v78
	v_mad_u64_u32 v[78:79], s[16:17], v75, s13, v[64:65]
	v_ashrrev_i32_e32 v79, 31, v78
	v_lshl_add_u64 v[78:79], v[78:79], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[78:79], v[80:83], off
.LBB0_21:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v70, s20, v70
	v_cmp_gt_i32_e64 s[4:5], s13, v70
	s_and_b64 s[16:17], s[4:5], s[0:1]
	s_and_saveexec_b64 s[0:1], s[16:17]
	s_cbranch_execz .LBB0_23
	v_lshl_or_b32 v78, v168, 8, v67
	ds_read_b128 v[80:83], v78 offset:32768
	v_mad_u64_u32 v[78:79], s[16:17], v66, s13, v[70:71]
	v_ashrrev_i32_e32 v79, 31, v78
	v_lshl_add_u64 v[78:79], v[78:79], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[78:79], v[80:83], off
.LBB0_23:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v66, s20, v77
	v_cmp_gt_i32_e64 s[0:1], s13, v66
	s_and_b64 s[16:17], s[0:1], s[6:7]
	s_and_saveexec_b64 s[6:7], s[16:17]
	s_cbranch_execz .LBB0_25
	v_lshl_or_b32 v77, v69, 8, v65
	ds_read_b128 v[80:83], v77 offset:32768
	v_mad_u64_u32 v[78:79], s[16:17], v73, s13, v[66:67]
	v_ashrrev_i32_e32 v79, 31, v78
	v_lshl_add_u64 v[78:79], v[78:79], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[78:79], v[80:83], off
.LBB0_25:
	s_or_b64 exec, exec, s[6:7]
	s_and_b64 s[8:9], s[0:1], s[8:9]
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB0_27
	v_lshl_or_b32 v73, v72, 8, v65
	ds_read_b128 v[80:83], v73 offset:32768
	v_mad_u64_u32 v[78:79], s[8:9], v74, s13, v[66:67]
	v_ashrrev_i32_e32 v79, 31, v78
	v_lshl_add_u64 v[78:79], v[78:79], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[78:79], v[80:83], off
.LBB0_27:
	s_or_b64 exec, exec, s[6:7]
	v_or_b32_e32 v73, 0x80, v76
	s_and_b64 s[8:9], s[0:1], s[10:11]
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB0_29
	v_lshl_or_b32 v74, v71, 8, v65
	ds_read_b128 v[78:81], v74 offset:32768
	v_mad_u64_u32 v[74:75], s[8:9], v75, s13, v[66:67]
	v_ashrrev_i32_e32 v75, 31, v74
	v_lshl_add_u64 v[74:75], v[74:75], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[74:75], v[78:81], off
.LBB0_29:
	s_or_b64 exec, exec, s[6:7]
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_or_b32_e32 v74, 0x10000, v76
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	v_cvt_pk_bf16_f32 v1, v1, s0
	ds_write_b16 v74, v0
	v_add_u32_e32 v0, 0x10100, v76
	v_cvt_pk_bf16_f32 v2, v2, s0
	ds_write_b16 v0, v1
	v_add_u32_e32 v0, 0x10200, v76
	v_cvt_pk_bf16_f32 v3, v3, s0
	ds_write_b16 v0, v2
	v_add_u32_e32 v0, 0x10300, v76
	v_cvt_pk_bf16_f32 v4, v4, s0
	ds_write_b16 v0, v3
	v_or_b32_e32 v0, 0x12000, v76
	v_cvt_pk_bf16_f32 v5, v5, s0
	ds_write_b16 v0, v4
	v_add_u32_e32 v0, 0x12100, v76
	v_cvt_pk_bf16_f32 v6, v6, s0
	ds_write_b16 v0, v5
	v_add_u32_e32 v0, 0x12200, v76
	v_cvt_pk_bf16_f32 v7, v7, s0
	ds_write_b16 v0, v6
	v_add_u32_e32 v0, 0x12300, v76
	v_cvt_pk_bf16_f32 v12, v12, s0
	ds_write_b16 v0, v7
	v_or_b32_e32 v0, 0x14000, v76
	v_cvt_pk_bf16_f32 v13, v13, s0
	ds_write_b16 v0, v12
	v_add_u32_e32 v0, 0x14100, v76
	v_cvt_pk_bf16_f32 v14, v14, s0
	ds_write_b16 v0, v13
	v_add_u32_e32 v0, 0x14200, v76
	v_cvt_pk_bf16_f32 v15, v15, s0
	ds_write_b16 v0, v14
	v_add_u32_e32 v0, 0x14300, v76
	v_cvt_pk_bf16_f32 v24, v24, s0
	ds_write_b16 v0, v15
	v_or_b32_e32 v0, 0x16000, v76
	v_cvt_pk_bf16_f32 v25, v25, s0
	ds_write_b16 v0, v24
	v_add_u32_e32 v0, 0x16100, v76
	v_cvt_pk_bf16_f32 v26, v26, s0
	ds_write_b16 v0, v25
	v_add_u32_e32 v0, 0x16200, v76
	v_cvt_pk_bf16_f32 v27, v27, s0
	ds_write_b16 v0, v26
	v_add_u32_e32 v0, 0x16300, v76
	v_cvt_pk_bf16_f32 v8, v8, s0
	ds_write_b16 v0, v27
	v_add_u32_e32 v0, 0x10080, v76
	v_cvt_pk_bf16_f32 v9, v9, s0
	ds_write_b16 v0, v8
	v_add_u32_e32 v0, 0x10100, v73
	v_cvt_pk_bf16_f32 v10, v10, s0
	ds_write_b16 v0, v9
	v_add_u32_e32 v0, 0x10200, v73
	v_cvt_pk_bf16_f32 v11, v11, s0
	ds_write_b16 v0, v10
	v_add_u32_e32 v0, 0x10300, v73
	v_cvt_pk_bf16_f32 v20, v20, s0
	ds_write_b16 v0, v11
	v_or_b32_e32 v0, 0x12000, v73
	v_cvt_pk_bf16_f32 v21, v21, s0
	ds_write_b16 v0, v20
	v_add_u32_e32 v0, 0x12100, v73
	v_cvt_pk_bf16_f32 v22, v22, s0
	ds_write_b16 v0, v21
	v_add_u32_e32 v0, 0x12200, v73
	v_cvt_pk_bf16_f32 v23, v23, s0
	ds_write_b16 v0, v22
	v_add_u32_e32 v0, 0x12300, v73
	v_cvt_pk_bf16_f32 v32, v32, s0
	ds_write_b16 v0, v23
	v_or_b32_e32 v0, 0x14000, v73
	ds_write_b16 v0, v32
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_or_b32_e32 v32, 0x18000, v76
	v_cvt_pk_bf16_f32 v17, v17, s0
	ds_write_b16 v32, v16
	v_add_u32_e32 v16, 0x18100, v76
	v_cvt_pk_bf16_f32 v18, v18, s0
	ds_write_b16 v16, v17
	v_add_u32_e32 v16, 0x18200, v76
	v_cvt_pk_bf16_f32 v19, v19, s0
	ds_write_b16 v16, v18
	v_add_u32_e32 v16, 0x18300, v76
	v_cvt_pk_bf16_f32 v28, v28, s0
	ds_write_b16 v16, v19
	v_or_b32_e32 v16, 0x1a000, v76
	v_cvt_pk_bf16_f32 v29, v29, s0
	ds_write_b16 v16, v28
	v_add_u32_e32 v16, 0x1a100, v76
	v_cvt_pk_bf16_f32 v30, v30, s0
	ds_write_b16 v16, v29
	v_add_u32_e32 v16, 0x1a200, v76
	v_cvt_pk_bf16_f32 v31, v31, s0
	ds_write_b16 v16, v30
	v_add_u32_e32 v16, 0x1a300, v76
	v_cvt_pk_bf16_f32 v27, v40, s0
	ds_write_b16 v16, v31
	v_or_b32_e32 v16, 0x1c000, v76
	v_cvt_pk_bf16_f32 v26, v41, s0
	ds_write_b16 v16, v27
	v_add_u32_e32 v16, 0x1c100, v76
	v_cvt_pk_bf16_f32 v25, v42, s0
	ds_write_b16 v16, v26
	v_add_u32_e32 v16, 0x1c200, v76
	v_cvt_pk_bf16_f32 v24, v43, s0
	ds_write_b16 v16, v25
	v_add_u32_e32 v16, 0x1c300, v76
	v_cvt_pk_bf16_f32 v23, v52, s0
	ds_write_b16 v16, v24
	v_or_b32_e32 v16, 0x1e000, v76
	v_cvt_pk_bf16_f32 v22, v53, s0
	ds_write_b16 v16, v23
	v_add_u32_e32 v16, 0x1e100, v76
	v_cvt_pk_bf16_f32 v21, v54, s0
	ds_write_b16 v16, v22
	v_add_u32_e32 v16, 0x1e200, v76
	v_cvt_pk_bf16_f32 v20, v55, s0
	ds_write_b16 v16, v21
	v_add_u32_e32 v16, 0x1e300, v76
	v_cvt_pk_bf16_f32 v15, v36, s0
	ds_write_b16 v16, v20
	v_add_u32_e32 v16, 0x18080, v76
	v_cvt_pk_bf16_f32 v14, v37, s0
	ds_write_b16 v16, v15
	v_add_u32_e32 v15, 0x18100, v73
	v_cvt_pk_bf16_f32 v13, v38, s0
	ds_write_b16 v15, v14
	v_add_u32_e32 v14, 0x18200, v73
	v_cvt_pk_bf16_f32 v12, v39, s0
	ds_write_b16 v14, v13
	v_add_u32_e32 v13, 0x18300, v73
	v_cvt_pk_bf16_f32 v11, v48, s0
	ds_write_b16 v13, v12
	v_or_b32_e32 v12, 0x1a000, v73
	v_cvt_pk_bf16_f32 v10, v49, s0
	ds_write_b16 v12, v11
	v_add_u32_e32 v11, 0x1a100, v73
	v_cvt_pk_bf16_f32 v9, v50, s0
	ds_write_b16 v11, v10
	v_add_u32_e32 v10, 0x1a200, v73
	v_cvt_pk_bf16_f32 v8, v51, s0
	ds_write_b16 v10, v9
	v_add_u32_e32 v9, 0x1a300, v73
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_add_u32_e32 v0, 0x14100, v73
	v_cvt_pk_bf16_f32 v7, v56, s0
	ds_write_b16 v9, v8
	v_or_b32_e32 v8, 0x1c000, v73
	v_cvt_pk_bf16_f32 v34, v34, s0
	ds_write_b16 v0, v33
	v_add_u32_e32 v0, 0x14200, v73
	v_cvt_pk_bf16_f32 v6, v57, s0
	ds_write_b16 v8, v7
	v_add_u32_e32 v7, 0x1c100, v73
	v_cvt_pk_bf16_f32 v35, v35, s0
	ds_write_b16 v0, v34
	v_add_u32_e32 v0, 0x14300, v73
	v_cvt_pk_bf16_f32 v5, v58, s0
	ds_write_b16 v7, v6
	v_add_u32_e32 v6, 0x1c200, v73
	v_cvt_pk_bf16_f32 v44, v44, s0
	ds_write_b16 v0, v35
	v_or_b32_e32 v0, 0x16000, v73
	v_cvt_pk_bf16_f32 v4, v59, s0
	ds_write_b16 v6, v5
	v_add_u32_e32 v5, 0x1c300, v73
	v_cvt_pk_bf16_f32 v45, v45, s0
	ds_write_b16 v0, v44
	v_add_u32_e32 v0, 0x16100, v73
	v_cvt_pk_bf16_f32 v3, v60, s0
	ds_write_b16 v5, v4
	v_or_b32_e32 v4, 0x1e000, v73
	v_cvt_pk_bf16_f32 v46, v46, s0
	ds_write_b16 v0, v45
	v_add_u32_e32 v0, 0x16200, v73
	v_cvt_pk_bf16_f32 v2, v61, s0
	ds_write_b16 v4, v3
	v_add_u32_e32 v3, 0x1e100, v73
	v_cvt_pk_bf16_f32 v47, v47, s0
	ds_write_b16 v0, v46
	v_add_u32_e32 v0, 0x16300, v73
	v_cvt_pk_bf16_f32 v1, v62, s0
	ds_write_b16 v3, v2
	v_add_u32_e32 v2, 0x1e200, v73
	ds_write_b16 v0, v47
	v_cvt_pk_bf16_f32 v0, v63, s0
	ds_write_b16 v2, v1
	v_add_u32_e32 v1, 0x1e300, v73
	ds_write_b16 v1, v0
	v_or_b32_e32 v0, s18, v168
	v_cmp_gt_i32_e64 s[6:7], s12, v0
	s_mov_b32 s8, 0x10000
	s_and_b64 s[10:11], s[2:3], s[6:7]
	v_lshlrev_b32_e32 v3, 8, v168
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[10:11]
	s_cbranch_execz .LBB0_31
	v_or3_b32 v1, v3, v67, s8
	ds_read_b128 v[6:9], v1
	v_mad_u64_u32 v[4:5], s[8:9], v0, s13, v[68:69]
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[4:5], v[4:5], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[4:5], v[6:9], off
.LBB0_31:
	s_or_b64 exec, exec, s[2:3]
	v_or_b32_e32 v1, s18, v69
	v_cmp_gt_i32_e64 s[2:3], s12, v1
	s_and_b64 s[10:11], vcc, s[2:3]
	v_lshlrev_b32_e32 v5, 8, v69
	s_and_saveexec_b64 s[8:9], s[10:11]
	s_cbranch_execz .LBB0_33
	s_mov_b32 s10, 0x10000
	v_or3_b32 v2, v5, v65, s10
	ds_read_b128 v[8:11], v2
	v_mad_u64_u32 v[6:7], s[10:11], v1, s13, v[64:65]
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshl_add_u64 v[6:7], v[6:7], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[6:7], v[8:11], off
.LBB0_33:
	s_or_b64 exec, exec, s[8:9]
	v_or_b32_e32 v2, s18, v72
	v_cmp_gt_i32_e64 s[8:9], s12, v2
	s_and_b64 s[16:17], vcc, s[8:9]
	v_lshlrev_b32_e32 v6, 8, v72
	s_and_saveexec_b64 s[10:11], s[16:17]
	s_cbranch_execz .LBB0_35
	s_mov_b32 s16, 0x10000
	v_or3_b32 v4, v6, v65, s16
	ds_read_b128 v[10:13], v4
	v_mad_u64_u32 v[8:9], s[16:17], v2, s13, v[64:65]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[8:9], v[10:13], off
.LBB0_35:
	s_or_b64 exec, exec, s[10:11]
	v_or_b32_e32 v4, s18, v71
	v_cmp_gt_i32_e64 s[10:11], s12, v4
	s_and_b64 s[18:19], vcc, s[10:11]
	v_lshlrev_b32_e32 v7, 8, v71
	s_and_saveexec_b64 s[16:17], s[18:19]
	s_cbranch_execz .LBB0_37
	s_mov_b32 s12, 0x10000
	v_or3_b32 v8, v7, v65, s12
	ds_read_b128 v[10:13], v8
	v_mad_u64_u32 v[8:9], s[18:19], v4, s13, v[64:65]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[8:9], v[10:13], off
.LBB0_37:
	s_or_b64 exec, exec, s[16:17]
	s_and_b64 s[6:7], s[4:5], s[6:7]
	s_and_saveexec_b64 s[4:5], s[6:7]
	s_cbranch_execz .LBB0_39
	s_mov_b32 s6, 0x18000
	v_or3_b32 v3, v3, v67, s6
	ds_read_b128 v[10:13], v3
	v_mad_u64_u32 v[8:9], s[6:7], v0, s13, v[70:71]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[8:9], v[10:13], off
.LBB0_39:
	s_or_b64 exec, exec, s[4:5]
	s_and_b64 s[4:5], s[0:1], s[2:3]
	s_and_saveexec_b64 s[2:3], s[4:5]
	s_cbranch_execz .LBB0_41
	s_mov_b32 s4, 0x18000
	v_or3_b32 v0, v5, v65, s4
	ds_read_b128 v[8:11], v0
	v_mad_u64_u32 v[0:1], s[4:5], v1, s13, v[66:67]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[0:1], v[8:11], off
.LBB0_41:
	s_or_b64 exec, exec, s[2:3]
	s_and_b64 s[4:5], s[0:1], s[8:9]
	s_and_saveexec_b64 s[2:3], s[4:5]
	s_cbranch_execz .LBB0_43
	s_mov_b32 s4, 0x18000
	v_or3_b32 v0, v6, v65, s4
	ds_read_b128 v[8:11], v0
	v_mad_u64_u32 v[0:1], s[4:5], v2, s13, v[66:67]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[0:1], v[8:11], off
.LBB0_43:
	s_or_b64 exec, exec, s[2:3]
	s_and_b64 s[0:1], s[0:1], s[10:11]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_45
	s_mov_b32 s0, 0x18000
	v_or3_b32 v0, v7, v65, s0
	ds_read_b128 v[6:9], v0
	v_mad_u64_u32 v[0:1], s[0:1], v4, s13, v[66:67]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 1, s[14:15]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[0:1], v[6:9], off
.LBB0_45:
	s_endpgm
.Lfunc_end0:
	.size	hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0, .Lfunc_end0-hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0
		.amdhsa_group_segment_fixed_size 131072
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 152
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
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 232
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 232
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

	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.num_vgpr, 232
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.num_agpr, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.numbered_sgpr, 39
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.num_named_barrier, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.private_seg_size, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.uses_vcc, 1
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.has_recursion, 0
	.set .Lhgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.has_indirect_call, 0
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
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .offset:         80
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
      - .offset:         104
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         112
        .size:           8
        .value_kind:     global_buffer
      - .offset:         120
        .size:           4
        .value_kind:     by_value
      - .offset:         124
        .size:           4
        .value_kind:     by_value
      - .offset:         128
        .size:           4
        .value_kind:     by_value
      - .offset:         132
        .size:           4
        .value_kind:     by_value
      - .offset:         136
        .size:           4
        .value_kind:     by_value
      - .offset:         140
        .size:           4
        .value_kind:     by_value
      - .offset:         144
        .size:           4
        .value_kind:     by_value
      - .offset:         148
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 131072
    .kernarg_segment_align: 8
    .kernarg_segment_size: 152
    .max_flat_workgroup_size: 512
    .name:           hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 512
      - 1
      - 1
    .sgpr_count:     45
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_t256x256x64x2_ks1_w2x4x1_gm0_bias0_lnt_phti_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     232
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
