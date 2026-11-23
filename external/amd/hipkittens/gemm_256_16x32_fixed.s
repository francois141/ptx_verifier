	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_Z8micro_tk13micro_globalsiii
	.globl	_Z8micro_tk13micro_globalsiii
	.p2align	8
	.type	_Z8micro_tk13micro_globalsiii,@function
_Z8micro_tk13micro_globalsiii:
	s_load_dwordx2 s[6:7], s[0:1], 0xb8
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x20
	s_load_dwordx2 s[8:9], s[0:1], 0x30
	s_load_dwordx2 s[18:19], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s6, s3
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s7, s6
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 23
	s_add_i32 s3, s3, s6
	s_and_b32 s3, s3, 0xfffffe00
	s_cmp_gt_i32 s2, s3
	s_cbranch_scc1 .LBB0_2
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s6, s3, 29
	s_add_i32 s6, s2, s6
	s_and_b32 s10, s6, 0x3fffff8
	s_lshr_b32 s3, s3, 23
	s_sub_i32 s10, s2, s10
	s_add_i32 s2, s2, s3
	s_ashr_i32 s3, s6, 31
	s_ashr_i32 s7, s6, 3
	s_lshr_b32 s3, s3, 26
	s_add_i32 s3, s7, s3
	s_andn2_b32 s3, s3, 63
	s_and_b32 s2, s2, 0xfffffe00
	s_lshl_b32 s6, s10, 6
	s_sub_i32 s3, s7, s3
	s_add_i32 s2, s2, s6
	s_add_i32 s2, s2, s3
.LBB0_2:
	s_mov_b64 s[6:7], src_shared_base
	s_cmp_lg_u32 0, -1
	s_cselect_b32 s6, 0, 0
	s_cselect_b32 s3, s7, 0
	s_and_b32 s10, s6, 15
	s_and_b32 s7, s6, -16
	s_load_dwordx4 s[12:15], s[0:1], 0xa8
	s_add_u32 s7, s7, 16
	s_mov_b32 s11, 0
	s_waitcnt lgkmcnt(0)
	s_addc_u32 s15, s3, 0
	s_cmp_eq_u64 s[10:11], 0
	s_cselect_b32 s3, s3, s15
	s_cselect_b32 s21, s6, s7
	s_add_u32 s3, s21, 0x10000
	s_and_b32 s6, s3, -16
	s_and_b32 s10, s3, 15
	s_add_u32 s6, s6, 16
	s_cmp_eq_u64 s[10:11], 0
	s_cselect_b32 s22, s3, s6
	s_add_i32 s3, s13, 0xff
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 24
	s_add_i32 s3, s3, s6
	s_ashr_i32 s3, s3, 8
	s_lshl_b32 s6, s3, 3
	s_abs_i32 s7, s6
	v_cvt_f32_u32_e32 v1, s7
	s_add_i32 s10, s12, 0xff
	s_sub_i32 s15, 0, s7
	s_ashr_i32 s11, s10, 31
	v_rcp_iflag_f32_e32 v1, v1
	s_lshr_b32 s11, s11, 24
	s_add_i32 s10, s10, s11
	s_abs_i32 s11, s2
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_xor_b32 s3, s2, s3
	s_ashr_i32 s10, s10, 8
	s_ashr_i32 s3, s3, 31
	v_readfirstlane_b32 s20, v1
	s_mul_i32 s15, s15, s20
	s_mul_hi_u32 s15, s20, s15
	s_add_i32 s20, s20, s15
	s_mul_hi_u32 s15, s11, s20
	s_mul_i32 s20, s15, s7
	s_sub_i32 s11, s11, s20
	s_add_i32 s20, s15, 1
	s_sub_i32 s23, s11, s7
	s_cmp_ge_u32 s11, s7
	s_cselect_b32 s15, s20, s15
	s_cselect_b32 s11, s23, s11
	s_add_i32 s20, s15, 1
	s_cmp_ge_u32 s11, s7
	s_cselect_b32 s7, s20, s15
	s_xor_b32 s7, s7, s3
	s_sub_i32 s3, s7, s3
	s_lshl_b32 s7, s3, 3
	s_sub_i32 s10, s10, s7
	s_min_i32 s10, s10, 8
	s_abs_i32 s11, s10
	v_cvt_f32_u32_e32 v1, s11
	s_sub_i32 s15, 0, s11
	s_mul_i32 s3, s3, s6
	s_sub_i32 s2, s2, s3
	v_rcp_iflag_f32_e32 v1, v1
	s_abs_i32 s6, s2
	s_xor_b32 s3, s2, s10
	s_ashr_i32 s3, s3, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_lshrrev_b32_e32 v2, 6, v0
	v_lshlrev_b32_e32 v3, 10, v2
	v_lshlrev_b32_e32 v4, 4, v0
	v_readfirstlane_b32 s20, v1
	s_mul_i32 s15, s15, s20
	s_mul_hi_u32 s15, s20, s15
	s_add_i32 s20, s20, s15
	s_mul_hi_u32 s15, s6, s20
	s_mul_i32 s20, s15, s11
	s_sub_i32 s6, s6, s20
	s_add_i32 s20, s15, 1
	s_sub_i32 s23, s6, s11
	s_cmp_ge_u32 s6, s11
	s_cselect_b32 s15, s20, s15
	s_cselect_b32 s6, s23, s6
	s_add_i32 s20, s15, 1
	s_cmp_ge_u32 s6, s11
	s_cselect_b32 s6, s20, s15
	v_add_u32_e32 v1, s21, v3
	s_add_u32 s23, s21, 0x4000
	v_readfirstlane_b32 s35, v1
	v_add_u32_e32 v1, s23, v3
	s_add_u32 s26, s22, 0x4000
	v_readfirstlane_b32 s34, v1
	v_add_u32_e32 v1, s22, v3
	s_xor_b32 s6, s6, s3
	v_readfirstlane_b32 s36, v1
	v_add_u32_e32 v1, s26, v3
	s_sub_i32 s20, s6, s3
	v_readfirstlane_b32 s37, v1
	v_lshrrev_b32_e32 v1, 3, v0
	v_bfe_u32 v5, v0, 2, 4
	s_mul_i32 s3, s20, s10
	v_bitop3_b32 v4, v4, v0, 32 bitop3:0x78
	v_and_or_b32 v1, v1, 48, v5
	v_lshrrev_b32_e32 v5, 1, v0
	s_sub_i32 s15, s2, s3
	s_mul_i32 s2, s12, s16
	v_lshrrev_b32_e32 v4, 1, v4
	v_and_b32_e32 v5, 32, v5
	s_lshl_b32 s6, s2, 1
	s_mul_i32 s2, s13, s18
	v_and_or_b32 v4, v4, 24, v5
	s_lshl_b32 s10, s2, 1
	v_mad_u64_u32 v[6:7], s[2:3], v1, s16, v[4:5]
	s_lshl_b32 s2, s16, 6
	s_lshl_b32 s20, s20, 8
	v_add_lshl_u32 v132, v6, s2, 1
	v_mad_u64_u32 v[4:5], s[2:3], v1, s18, v[4:5]
	s_mul_i32 s31, s18, s20
	s_lshl_b32 s2, s18, 6
	s_lshl_b32 s12, s31, 1
	s_add_i32 s15, s15, s7
	v_add_lshl_u32 v137, v4, s2, 1
	s_mov_b32 s2, s12
	s_mov_b32 s3, s36
	s_mov_b32 s7, 0x110000
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s13, s3
	s_lshl_b32 s38, s15, 8
	s_mov_b32 s11, s7
	v_lshlrev_b32_e32 v136, 1, v4
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	s_addk_i32 s3, 0x2000
	s_mul_i32 s33, s16, s38
	;;#ASMSTART
	s_mov_b32 m0, s13
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_lshl_b32 s13, s33, 1
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s2 offen lds
	s_mov_b32 s2, s13
	s_mov_b32 s3, s35
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	v_lshlrev_b32_e32 v133, 1, v6
	s_mov_b32 s24, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_add_u32 s27, s21, 0x8000
	;;#ASMSTART
	s_mov_b32 m0, s24
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	v_add_u32_e32 v4, s27, v3
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s2 offen lds
	s_or_b32 s2, s20, 0x80
	s_mul_i32 s2, s18, s2
	s_lshl_b32 s42, s2, 1
	s_mov_b32 s2, s42
	s_mov_b32 s3, s37
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s24, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	v_readfirstlane_b32 s39, v4
	;;#ASMSTART
	s_mov_b32 m0, s24
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_add_u32 s28, s22, 0x8000
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s2 offen lds
	s_or_b32 s2, s38, 0x80
	s_mul_i32 s29, s16, s2
	s_lshl_b32 s2, s29, 1
	s_mov_b32 s3, s34
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s24, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_add_u32 s25, s22, 0xc000
	;;#ASMSTART
	s_mov_b32 m0, s24
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_add_u32 s24, s21, 0xc000
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s2 offen lds
	v_add_u32_e32 v4, s24, v3
	v_lshrrev_b32_e32 v1, 8, v0
	v_readfirstlane_b32 s30, v4
	v_add_u32_e32 v4, s28, v3
	v_add_u32_e32 v3, s25, v3
	v_readfirstlane_b32 s40, v4
	v_readfirstlane_b32 s41, v3
	v_cmp_eq_u32_e32 vcc, 1, v1
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_4
	s_barrier
.LBB0_4:
	s_or_b64 exec, exec, s[2:3]
	s_or_b32 s2, s12, 0x80
	s_mov_b32 s3, s40
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s12, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	v_and_b32_e32 v131, 3, v2
	;;#ASMSTART
	s_mov_b32 m0, s12
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	v_lshlrev_b32_e32 v2, 11, v131
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s2 offen lds
	s_or_b32 s2, s13, 0x80
	s_mov_b32 s3, s39
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s12, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	v_mov_b32_e32 v5, 0
	;;#ASMSTART
	s_mov_b32 m0, s12
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	v_and_b32_e32 v138, 48, v0
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s2 offen lds
	s_or_b32 s2, s42, 0x80
	s_mov_b32 s3, s41
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s12, s3
	s_addk_i32 s3, 0x2000
	;;#ASMSTART
	;;#ASMEND
	v_lshlrev_b32_e32 v139, 6, v0
	;;#ASMSTART
	s_mov_b32 m0, s12
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s2 offen lds
	;;#ASMSTART
	;;#ASMEND
	v_lshlrev_b32_e32 v140, 2, v0
	;;#ASMSTART
	s_mov_b32 m0, s3
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s2 offen lds
	s_ashr_i32 s2, s14, 31
	s_lshr_b32 s2, s2, 26
	s_add_i32 s42, s14, s2
	s_cmpk_gt_i32 s14, 0xbf
	v_lshlrev_b32_e32 v130, 12, v1
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	s_cbranch_scc1 .LBB0_6
	v_and_b32_e32 v3, 0x3c0, v139
	v_and_b32_e32 v4, 32, v140
	v_bitop3_b32 v134, v3, v4, v138 bitop3:0x36
	s_mov_b64 s[12:13], 0
	s_branch .LBB0_7
.LBB0_6:
	s_mov_b64 s[12:13], -1
.LBB0_7:
	s_load_dwordx2 s[2:3], s[0:1], 0x60
	s_load_dwordx2 s[0:1], s[0:1], 0x80
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s1, s42, 6
	s_andn2_b64 vcc, exec, s[12:13]
	v_lshlrev_b32_e32 v135, 1, v2
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v21, 0
	v_mov_b32_e32 v20, 0
	v_mov_b32_e32 v19, 0
	v_mov_b32_e32 v18, 0
	v_mov_b32_e32 v25, 0
	v_mov_b32_e32 v24, 0
	v_mov_b32_e32 v23, 0
	v_mov_b32_e32 v22, 0
	v_mov_b32_e32 v29, 0
	v_mov_b32_e32 v28, 0
	v_mov_b32_e32 v27, 0
	v_mov_b32_e32 v26, 0
	v_mov_b32_e32 v33, 0
	v_mov_b32_e32 v32, 0
	v_mov_b32_e32 v31, 0
	v_mov_b32_e32 v30, 0
	v_mov_b32_e32 v37, 0
	v_mov_b32_e32 v36, 0
	v_mov_b32_e32 v35, 0
	v_mov_b32_e32 v34, 0
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v39, 0
	v_mov_b32_e32 v38, 0
	v_mov_b32_e32 v45, 0
	v_mov_b32_e32 v44, 0
	v_mov_b32_e32 v43, 0
	v_mov_b32_e32 v42, 0
	v_mov_b32_e32 v49, 0
	v_mov_b32_e32 v48, 0
	v_mov_b32_e32 v47, 0
	v_mov_b32_e32 v46, 0
	v_mov_b32_e32 v53, 0
	v_mov_b32_e32 v52, 0
	v_mov_b32_e32 v51, 0
	v_mov_b32_e32 v50, 0
	v_mov_b32_e32 v57, 0
	v_mov_b32_e32 v56, 0
	v_mov_b32_e32 v55, 0
	v_mov_b32_e32 v54, 0
	v_mov_b32_e32 v61, 0
	v_mov_b32_e32 v60, 0
	v_mov_b32_e32 v59, 0
	v_mov_b32_e32 v58, 0
	v_mov_b32_e32 v65, 0
	v_mov_b32_e32 v64, 0
	v_mov_b32_e32 v63, 0
	v_mov_b32_e32 v62, 0
	v_mov_b32_e32 v69, 0
	v_mov_b32_e32 v68, 0
	v_mov_b32_e32 v67, 0
	v_mov_b32_e32 v66, 0
	v_mov_b32_e32 v73, 0
	v_mov_b32_e32 v72, 0
	v_mov_b32_e32 v71, 0
	v_mov_b32_e32 v70, 0
	v_mov_b32_e32 v77, 0
	v_mov_b32_e32 v76, 0
	v_mov_b32_e32 v75, 0
	v_mov_b32_e32 v74, 0
	v_mov_b32_e32 v81, 0
	v_mov_b32_e32 v80, 0
	v_mov_b32_e32 v79, 0
	v_mov_b32_e32 v78, 0
	v_mov_b32_e32 v85, 0
	v_mov_b32_e32 v84, 0
	v_mov_b32_e32 v83, 0
	v_mov_b32_e32 v82, 0
	v_mov_b32_e32 v89, 0
	v_mov_b32_e32 v88, 0
	v_mov_b32_e32 v87, 0
	v_mov_b32_e32 v86, 0
	v_mov_b32_e32 v93, 0
	v_mov_b32_e32 v92, 0
	v_mov_b32_e32 v91, 0
	v_mov_b32_e32 v90, 0
	v_mov_b32_e32 v97, 0
	v_mov_b32_e32 v96, 0
	v_mov_b32_e32 v95, 0
	v_mov_b32_e32 v94, 0
	v_mov_b32_e32 v101, 0
	v_mov_b32_e32 v100, 0
	v_mov_b32_e32 v99, 0
	v_mov_b32_e32 v98, 0
	v_mov_b32_e32 v105, 0
	v_mov_b32_e32 v104, 0
	v_mov_b32_e32 v103, 0
	v_mov_b32_e32 v102, 0
	v_mov_b32_e32 v109, 0
	v_mov_b32_e32 v108, 0
	v_mov_b32_e32 v107, 0
	v_mov_b32_e32 v106, 0
	v_mov_b32_e32 v113, 0
	v_mov_b32_e32 v112, 0
	v_mov_b32_e32 v111, 0
	v_mov_b32_e32 v110, 0
	v_mov_b32_e32 v117, 0
	v_mov_b32_e32 v116, 0
	v_mov_b32_e32 v115, 0
	v_mov_b32_e32 v114, 0
	v_mov_b32_e32 v121, 0
	v_mov_b32_e32 v120, 0
	v_mov_b32_e32 v119, 0
	v_mov_b32_e32 v118, 0
	v_mov_b32_e32 v125, 0
	v_mov_b32_e32 v124, 0
	v_mov_b32_e32 v123, 0
	v_mov_b32_e32 v122, 0
	v_mov_b32_e32 v129, 0
	v_mov_b32_e32 v128, 0
	v_mov_b32_e32 v127, 0
	v_mov_b32_e32 v126, 0
	s_cbranch_vccnz .LBB0_10
	s_bfe_i64 s[12:13], s[16:17], 0x200000
	v_and_b32_e32 v2, 0x3c0, v139
	v_and_b32_e32 v3, 32, v140
	s_add_u32 s13, s38, 0x80
	s_bfe_i64 s[18:19], s[18:19], 0x200000
	v_bitop3_b32 v134, v2, v3, v138 bitop3:0x36
	v_mov_b32_e32 v2, 0
	v_lshlrev_b32_e32 v3, 13, v1
	s_mul_i32 s16, s13, s12
	s_add_u32 s12, s20, 0x80
	s_add_i32 s14, s1, -2
	v_add3_u32 v138, s22, v135, v134
	v_add3_u32 v139, s21, v3, v134
	v_add3_u32 v140, s26, v135, v134
	v_add3_u32 v141, s23, v3, v134
	v_add3_u32 v142, s28, v135, v134
	v_add3_u32 v143, s27, v3, v134
	v_add3_u32 v144, s25, v135, v134
	v_add3_u32 v145, s24, v3, v134
	s_mul_i32 s17, s12, s18
	s_mov_b32 s18, 0
	s_mov_b64 s[12:13], 0
	v_mov_b32_e32 v146, s30
	v_mov_b32_e32 v147, s36
	v_mov_b32_e32 v148, s35
	v_mov_b32_e32 v149, s37
	v_mov_b32_e32 v150, s34
	v_mov_b32_e32 v151, s40
	v_mov_b32_e32 v152, s39
	v_mov_b32_e32 v153, s41
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v18, v2
	v_mov_b32_e32 v19, v2
	v_mov_b32_e32 v20, v2
	v_mov_b32_e32 v21, v2
	v_mov_b32_e32 v22, v2
	v_mov_b32_e32 v23, v2
	v_mov_b32_e32 v24, v2
	v_mov_b32_e32 v25, v2
	v_mov_b32_e32 v26, v2
	v_mov_b32_e32 v27, v2
	v_mov_b32_e32 v28, v2
	v_mov_b32_e32 v29, v2
	v_mov_b32_e32 v30, v2
	v_mov_b32_e32 v31, v2
	v_mov_b32_e32 v32, v2
	v_mov_b32_e32 v33, v2
	v_mov_b32_e32 v34, v2
	v_mov_b32_e32 v35, v2
	v_mov_b32_e32 v36, v2
	v_mov_b32_e32 v37, v2
	v_mov_b32_e32 v38, v2
	v_mov_b32_e32 v39, v2
	v_mov_b32_e32 v40, v2
	v_mov_b32_e32 v41, v2
	v_mov_b32_e32 v42, v2
	v_mov_b32_e32 v43, v2
	v_mov_b32_e32 v44, v2
	v_mov_b32_e32 v45, v2
	v_mov_b32_e32 v46, v2
	v_mov_b32_e32 v47, v2
	v_mov_b32_e32 v48, v2
	v_mov_b32_e32 v49, v2
	v_mov_b32_e32 v50, v2
	v_mov_b32_e32 v51, v2
	v_mov_b32_e32 v52, v2
	v_mov_b32_e32 v53, v2
	v_mov_b32_e32 v54, v2
	v_mov_b32_e32 v55, v2
	v_mov_b32_e32 v56, v2
	v_mov_b32_e32 v57, v2
	v_mov_b32_e32 v58, v2
	v_mov_b32_e32 v59, v2
	v_mov_b32_e32 v60, v2
	v_mov_b32_e32 v61, v2
	v_mov_b32_e32 v62, v2
	v_mov_b32_e32 v63, v2
	v_mov_b32_e32 v64, v2
	v_mov_b32_e32 v65, v2
	v_mov_b32_e32 v66, v2
	v_mov_b32_e32 v67, v2
	v_mov_b32_e32 v68, v2
	v_mov_b32_e32 v69, v2
	v_mov_b32_e32 v70, v2
	v_mov_b32_e32 v71, v2
	v_mov_b32_e32 v72, v2
	v_mov_b32_e32 v73, v2
	v_mov_b32_e32 v74, v2
	v_mov_b32_e32 v75, v2
	v_mov_b32_e32 v76, v2
	v_mov_b32_e32 v77, v2
	v_mov_b32_e32 v78, v2
	v_mov_b32_e32 v79, v2
	v_mov_b32_e32 v80, v2
	v_mov_b32_e32 v81, v2
	v_mov_b32_e32 v82, v2
	v_mov_b32_e32 v83, v2
	v_mov_b32_e32 v84, v2
	v_mov_b32_e32 v85, v2
	v_mov_b32_e32 v86, v2
	v_mov_b32_e32 v87, v2
	v_mov_b32_e32 v88, v2
	v_mov_b32_e32 v89, v2
	v_mov_b32_e32 v90, v2
	v_mov_b32_e32 v91, v2
	v_mov_b32_e32 v92, v2
	v_mov_b32_e32 v93, v2
	v_mov_b32_e32 v94, v2
	v_mov_b32_e32 v95, v2
	v_mov_b32_e32 v96, v2
	v_mov_b32_e32 v97, v2
	v_mov_b32_e32 v98, v2
	v_mov_b32_e32 v99, v2
	v_mov_b32_e32 v100, v2
	v_mov_b32_e32 v101, v2
	v_mov_b32_e32 v102, v2
	v_mov_b32_e32 v103, v2
	v_mov_b32_e32 v104, v2
	v_mov_b32_e32 v105, v2
	v_mov_b32_e32 v106, v2
	v_mov_b32_e32 v107, v2
	v_mov_b32_e32 v108, v2
	v_mov_b32_e32 v109, v2
	v_mov_b32_e32 v110, v2
	v_mov_b32_e32 v111, v2
	v_mov_b32_e32 v112, v2
	v_mov_b32_e32 v113, v2
	v_mov_b32_e32 v114, v2
	v_mov_b32_e32 v115, v2
	v_mov_b32_e32 v116, v2
	v_mov_b32_e32 v117, v2
	v_mov_b32_e32 v118, v2
	v_mov_b32_e32 v119, v2
	v_mov_b32_e32 v120, v2
	v_mov_b32_e32 v121, v2
	v_mov_b32_e32 v122, v2
	v_mov_b32_e32 v123, v2
	v_mov_b32_e32 v124, v2
	v_mov_b32_e32 v125, v2
	v_mov_b32_e32 v126, v2
	v_mov_b32_e32 v127, v2
	v_mov_b32_e32 v128, v2
	v_mov_b32_e32 v129, v2
.LBB0_9:
	;;#ASMSTART
	ds_read_b128 v[154:157], v138 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v138 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v138 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v138 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v139 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v139 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v139 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v139 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v139 offset:0x1000

	;;#ASMEND
	s_add_u32 s19, s16, s12
	;;#ASMSTART
	ds_read_b128 v[190:193], v139 offset:0x1400

	;;#ASMEND
	s_lshl_b32 s34, s19, 1
	;;#ASMSTART
	ds_read_b128 v[194:197], v139 offset:0x1800

	;;#ASMEND
	s_bitset1_b32 s34, 7
	v_readfirstlane_b32 s35, v146
	;;#ASMSTART
	ds_read_b128 v[198:201], v139 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s36, s35
	s_addk_i32 s35, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s36
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s34 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s35
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s34 offen lds
	;;#ASMSTART
	s_waitcnt lgkmcnt(8)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[126:129], v[170:173], v[154:157], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[170:173], v[162:165], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[178:181], v[154:157], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[178:181], v[162:165], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[186:189], v[154:157], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[186:189], v[162:165], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[194:197], v[154:157], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[194:197], v[162:165], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[174:177], v[158:161], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[174:177], v[166:169], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[182:185], v[158:161], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[182:185], v[166:169], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[190:193], v[158:161], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[190:193], v[166:169], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[198:201], v[158:161], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[198:201], v[166:169], v[98:101]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[202:205], v140 offset:0

	;;#ASMEND
	s_add_u32 s34, s31, s12
	;;#ASMSTART
	ds_read_b128 v[206:209], v140 offset:0x400

	;;#ASMEND
	s_add_u32 s35, s34, 0x80
	;;#ASMSTART
	ds_read_b128 v[210:213], v140 offset:0x800

	;;#ASMEND
	s_lshl_b32 s35, s35, 1
	v_readfirstlane_b32 s36, v147
	;;#ASMSTART
	ds_read_b128 v[214:217], v140 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s37, s36
	s_addk_i32 s36, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_add_i32 s18, s18, 2
	;;#ASMSTART
	s_mov_b32 m0, s37
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s35 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s36
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s35 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[94:97], v[170:173], v[202:205], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[170:173], v[210:213], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[178:181], v[202:205], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[178:181], v[210:213], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[186:189], v[202:205], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[186:189], v[210:213], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[194:197], v[202:205], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[194:197], v[210:213], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[174:177], v[206:209], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[174:177], v[214:217], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[182:185], v[206:209], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[182:185], v[214:217], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[190:193], v[206:209], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[190:193], v[214:217], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[198:201], v[206:209], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[198:201], v[214:217], v[66:69]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[170:173], v141 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v141 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v141 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v141 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v141 offset:0x1000

	;;#ASMEND
	s_add_u32 s35, s33, s12
	;;#ASMSTART
	ds_read_b128 v[190:193], v141 offset:0x1400

	;;#ASMEND
	s_add_u32 s36, s35, 0x80
	;;#ASMSTART
	ds_read_b128 v[194:197], v141 offset:0x1800

	;;#ASMEND
	s_lshl_b32 s36, s36, 1
	v_readfirstlane_b32 s37, v148
	;;#ASMSTART
	ds_read_b128 v[198:201], v141 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s38, s37
	s_addk_i32 s37, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s38
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s36 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s37
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s36 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[62:65], v[170:173], v[154:157], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[170:173], v[162:165], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[178:181], v[154:157], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[178:181], v[162:165], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[186:189], v[154:157], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[186:189], v[162:165], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[194:197], v[154:157], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[194:197], v[162:165], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[174:177], v[158:161], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[174:177], v[166:169], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[182:185], v[158:161], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[182:185], v[166:169], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[190:193], v[158:161], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[190:193], v[166:169], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[198:201], v[158:161], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[198:201], v[166:169], v[34:37]
	s_setprio 0
	s_barrier
	s_add_u32 s36, s17, s12
	s_add_u32 s37, s36, 0x80
	s_lshl_b32 s37, s37, 1
	v_readfirstlane_b32 s38, v149
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s39, s38
	s_addk_i32 s38, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s39
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s37 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s38
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s37 offen lds
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[30:33], v[170:173], v[202:205], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[170:173], v[210:213], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[178:181], v[202:205], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[178:181], v[210:213], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[186:189], v[202:205], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[186:189], v[210:213], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[194:197], v[202:205], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[194:197], v[210:213], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[174:177], v[206:209], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[174:177], v[214:217], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[182:185], v[206:209], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[182:185], v[214:217], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[190:193], v[206:209], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[190:193], v[214:217], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[198:201], v[206:209], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[198:201], v[214:217], v[2:5]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[154:157], v142 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v142 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v142 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v142 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v143 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v143 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v143 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v143 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v143 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[190:193], v143 offset:0x1400

	;;#ASMEND
	s_add_u32 s19, s19, 0x80
	;;#ASMSTART
	ds_read_b128 v[194:197], v143 offset:0x1800

	;;#ASMEND
	s_lshl_b32 s19, s19, 1
	v_readfirstlane_b32 s37, v150
	;;#ASMSTART
	ds_read_b128 v[198:201], v143 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s38, s37
	s_addk_i32 s37, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s38
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s19 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s37
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s19 offen lds
	;;#ASMSTART
	s_waitcnt lgkmcnt(8)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[126:129], v[170:173], v[154:157], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[170:173], v[162:165], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[178:181], v[154:157], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[178:181], v[162:165], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[186:189], v[154:157], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[186:189], v[162:165], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[194:197], v[154:157], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[194:197], v[162:165], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[174:177], v[158:161], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[174:177], v[166:169], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[182:185], v[158:161], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[182:185], v[166:169], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[190:193], v[158:161], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[190:193], v[166:169], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[198:201], v[158:161], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[198:201], v[166:169], v[98:101]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[202:205], v144 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[206:209], v144 offset:0x400

	;;#ASMEND
	s_add_u32 s19, s34, 0xc0
	;;#ASMSTART
	ds_read_b128 v[210:213], v144 offset:0x800

	;;#ASMEND
	s_lshl_b32 s19, s19, 1
	v_readfirstlane_b32 s34, v151
	;;#ASMSTART
	ds_read_b128 v[214:217], v144 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s37, s34
	s_addk_i32 s34, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s37
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s19 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s34
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s19 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[94:97], v[170:173], v[202:205], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[170:173], v[210:213], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[178:181], v[202:205], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[178:181], v[210:213], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[186:189], v[202:205], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[186:189], v[210:213], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[194:197], v[202:205], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[194:197], v[210:213], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[174:177], v[206:209], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[174:177], v[214:217], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[182:185], v[206:209], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[182:185], v[214:217], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[190:193], v[206:209], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[190:193], v[214:217], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[198:201], v[206:209], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[198:201], v[214:217], v[66:69]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[170:173], v145 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v145 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v145 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v145 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v145 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[190:193], v145 offset:0x1400

	;;#ASMEND
	s_add_u32 s19, s35, 0xc0
	;;#ASMSTART
	ds_read_b128 v[194:197], v145 offset:0x1800

	;;#ASMEND
	s_lshl_b32 s19, s19, 1
	v_readfirstlane_b32 s34, v152
	;;#ASMSTART
	ds_read_b128 v[198:201], v145 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s35, s34
	s_addk_i32 s34, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s35
	;;#ASMEND
	buffer_load_dwordx4 v133, s[4:7], s19 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s34
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s19 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[62:65], v[170:173], v[154:157], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[170:173], v[162:165], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[178:181], v[154:157], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[178:181], v[162:165], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[186:189], v[154:157], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[186:189], v[162:165], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[194:197], v[154:157], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[194:197], v[162:165], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[174:177], v[158:161], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[174:177], v[166:169], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[182:185], v[158:161], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[182:185], v[166:169], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[190:193], v[158:161], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[190:193], v[166:169], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[198:201], v[158:161], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[198:201], v[166:169], v[34:37]
	s_setprio 0
	s_barrier
	s_add_u32 s19, s36, 0xc0
	s_lshl_b32 s19, s19, 1
	v_readfirstlane_b32 s34, v153
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s35, s34
	s_addk_i32 s34, 0x2000
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s35
	;;#ASMEND
	buffer_load_dwordx4 v136, s[8:11], s19 offen lds
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s34
	;;#ASMEND
	buffer_load_dwordx4 v137, s[8:11], s19 offen lds
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[30:33], v[170:173], v[202:205], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[170:173], v[210:213], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[178:181], v[202:205], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[178:181], v[210:213], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[186:189], v[202:205], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[186:189], v[210:213], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[194:197], v[202:205], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[194:197], v[210:213], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[174:177], v[206:209], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[174:177], v[214:217], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[182:185], v[206:209], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[182:185], v[214:217], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[190:193], v[206:209], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[190:193], v[214:217], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[198:201], v[206:209], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[198:201], v[214:217], v[2:5]
	s_setprio 0
	s_add_u32 s12, s12, 0x80
	s_addc_u32 s13, s13, 0
	s_cmp_ge_i32 s18, s14
	s_barrier
	s_cbranch_scc0 .LBB0_9
.LBB0_10:
	v_add3_u32 v137, s22, v135, v134
	;;#ASMSTART
	ds_read_b128 v[138:141], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v137 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v137 offset:0xc00

	;;#ASMEND
	v_lshlrev_b32_e32 v130, 1, v130
	v_add3_u32 v137, s21, v130, v134
	;;#ASMSTART
	ds_read_b128 v[154:157], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v137 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v137 offset:0xc00

	;;#ASMEND
	s_lshl_b32 s1, s1, 6
	;;#ASMSTART
	ds_read_b128 v[170:173], v137 offset:0x1000

	;;#ASMEND
	s_sub_i32 s1, s1, 64
	;;#ASMSTART
	ds_read_b128 v[174:177], v137 offset:0x1400

	;;#ASMEND
	s_add_u32 s1, s29, s1
	;;#ASMSTART
	ds_read_b128 v[178:181], v137 offset:0x1800

	;;#ASMEND
	s_lshl_b32 s1, s1, 1
	;;#ASMSTART
	ds_read_b128 v[182:185], v137 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s8, s30
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s8
	;;#ASMEND
	s_add_i32 s8, s30, 0x2000
	buffer_load_dwordx4 v133, s[4:7], s1 offen lds
	;;#ASMSTART
	;;#ASMEND
	v_lshrrev_b32_e32 v136, 2, v0
	;;#ASMSTART
	s_mov_b32 m0, s8
	;;#ASMEND
	buffer_load_dwordx4 v132, s[4:7], s1 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[126:129], v[154:157], v[138:141], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[154:157], v[146:149], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[162:165], v[138:141], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[162:165], v[146:149], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[170:173], v[138:141], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[170:173], v[146:149], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[178:181], v[138:141], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[178:181], v[146:149], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[158:161], v[142:145], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[158:161], v[150:153], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[166:169], v[142:145], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[166:169], v[150:153], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[174:177], v[142:145], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[174:177], v[150:153], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[182:185], v[142:145], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[182:185], v[150:153], v[98:101]
	s_setprio 0
	s_barrier
	v_add3_u32 v132, s26, v135, v134
	;;#ASMSTART
	ds_read_b128 v[186:189], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[190:193], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[194:197], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[198:201], v132 offset:0xc00

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[90:93], v[154:157], v[194:197], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[162:165], v[194:197], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[170:173], v[186:189], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[170:173], v[194:197], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[178:181], v[186:189], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[178:181], v[194:197], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[154:157], v[186:189], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[158:161], v[198:201], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[162:165], v[186:189], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[166:169], v[198:201], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[174:177], v[190:193], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[174:177], v[198:201], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[182:185], v[190:193], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[182:185], v[198:201], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[202:205], v[158:161], v[190:193], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[154:157], v[166:169], v[190:193], v[86:89]
	s_setprio 0
	s_barrier
	v_add3_u32 v132, s23, v130, v134
	;;#ASMSTART
	ds_read_b128 v[86:89], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[94:97], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v132 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v132 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v132 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[62:65], v[86:89], v[138:141], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[158:161], v[138:141], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[158:161], v[146:149], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[166:169], v[138:141], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[166:169], v[146:149], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[174:177], v[138:141], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[174:177], v[146:149], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[86:89], v[186:189], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[86:89], v[194:197], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[158:161], v[186:189], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[158:161], v[194:197], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[166:169], v[186:189], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[166:169], v[194:197], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[174:177], v[186:189], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[174:177], v[194:197], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[94:97], v[142:145], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[86:89], v[146:149], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[162:165], v[142:145], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[162:165], v[150:153], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[170:173], v[142:145], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[170:173], v[150:153], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[178:181], v[142:145], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[178:181], v[150:153], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[94:97], v[190:193], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[94:97], v[198:201], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[162:165], v[190:193], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[162:165], v[198:201], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[170:173], v[190:193], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[170:173], v[198:201], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[178:181], v[190:193], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[178:181], v[198:201], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[182:185], v[94:97], v[150:153], v[58:61]
	s_setprio 0
	s_barrier
	s_nop 0
	v_add3_u32 v58, s28, v135, v134
	;;#ASMSTART
	ds_read_b128 v[138:141], v58 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v58 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v58 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v58 offset:0xc00

	;;#ASMEND
	v_add3_u32 v86, s27, v130, v134
	;;#ASMSTART
	ds_read_b128 v[58:61], v86 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v86 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v86 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v86 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v86 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v86 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v86 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v86 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[86:89], v[58:61], v[138:141], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[158:161], v[142:145], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[58:61], v[146:149], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[158:161], v[150:153], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[162:165], v[138:141], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[166:169], v[142:145], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[162:165], v[146:149], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[166:169], v[150:153], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[170:173], v[138:141], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[174:177], v[142:145], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[170:173], v[146:149], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[174:177], v[150:153], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[178:181], v[138:141], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[186:189], v[142:145], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[178:181], v[146:149], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[186:189], v[150:153], v[86:89]
	s_setprio 0
	s_barrier
	v_add3_u32 v98, s25, v135, v134
	;;#ASMSTART
	ds_read_b128 v[190:193], v98 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[194:197], v98 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[198:201], v98 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[206:209], v98 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[98:101], v[58:61], v[190:193], v[202:205]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[58:61], v[198:201], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[158:161], v[194:197], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[158:161], v[206:209], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[162:165], v[190:193], v[154:157]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[166:169], v[194:197], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[162:165], v[198:201], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[166:169], v[206:209], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[170:173], v[190:193], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[174:177], v[194:197], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[170:173], v[198:201], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[174:177], v[206:209], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[178:181], v[190:193], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[186:189], v[194:197], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[178:181], v[198:201], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[186:189], v[206:209], v[58:61]
	s_setprio 0
	s_barrier
	v_add3_u32 v66, s24, v130, v134
	;;#ASMSTART
	ds_read_b128 v[132:135], v66 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v66 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v66 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v66 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v66 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v66 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v66 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v66 offset:0x1c00

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[62:65], v[132:135], v[138:141], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[154:157], v[142:145], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[132:135], v[146:149], v[182:185]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[158:161], v[138:141], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[158:161], v[146:149], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[166:169], v[138:141], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[166:169], v[146:149], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[174:177], v[138:141], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[174:177], v[146:149], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[132:135], v[190:193], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[132:135], v[198:201], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[158:161], v[190:193], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[158:161], v[198:201], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[166:169], v[190:193], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[166:169], v[198:201], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[174:177], v[190:193], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[174:177], v[198:201], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[154:157], v[150:153], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[162:165], v[142:145], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[162:165], v[150:153], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[170:173], v[142:145], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[170:173], v[150:153], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[178:181], v[142:145], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[178:181], v[150:153], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[154:157], v[194:197], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[154:157], v[206:209], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[162:165], v[194:197], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[162:165], v[206:209], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[170:173], v[194:197], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[170:173], v[206:209], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[178:181], v[194:197], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[178:181], v[206:209], v[2:5]
	s_setprio 0
	s_movk_i32 s1, 0x100
	v_cmp_gt_u32_e32 vcc, s1, v0
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	s_barrier
.LBB0_12:
	s_or_b64 exec, exec, s[4:5]
	v_lshlrev_b32_e32 v1, 6, v1
	v_lshl_or_b32 v170, s15, 8, v1
	v_and_b32_e32 v1, 12, v136
	v_and_b32_e32 v0, 15, v0
	v_mad_u64_u32 v[0:1], s[4:5], v1, s0, v[0:1]
	v_lshl_or_b32 v130, v131, 5, s20
	v_ashrrev_i32_e32 v1, 31, v0
	v_mad_i64_i32 v[132:133], s[4:5], s0, v170, 0
	v_ashrrev_i32_e32 v131, 31, v130
	v_lshlrev_b64 v[134:135], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[132:133], v[132:133], 1, s[2:3]
	v_lshlrev_b64 v[130:131], 1, v[130:131]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[132:133], v[132:133], 0, v[130:131]
	v_lshlrev_b64 v[138:139], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[136:137], v[132:133], 0, v[134:135]
	v_lshl_add_u64 v[140:141], v[132:133], 0, v[138:139]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[136:137], v126, off
	global_store_short_d16_hi v[140:141], v127, off
	v_lshlrev_b64 v[126:127], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	s_mul_i32 s1, s0, 13
	v_lshlrev_b64 v[144:145], 1, v[0:1]
	v_add_u32_e32 v0, s1, v0
	v_lshl_add_u64 v[142:143], v[132:133], 0, v[126:127]
	v_lshl_add_u64 v[146:147], v[132:133], 0, v[144:145]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[142:143], v128, off
	global_store_short_d16_hi v[146:147], v129, off
	global_store_short_d16_hi v[136:137], v122, off offset:32
	global_store_short_d16_hi v[140:141], v123, off offset:32
	global_store_short_d16_hi v[142:143], v124, off offset:32
	global_store_short_d16_hi v[146:147], v125, off offset:32
	v_lshlrev_b64 v[122:123], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[128:129], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[124:125], v[132:133], 0, v[122:123]
	v_lshl_add_u64 v[148:149], v[132:133], 0, v[128:129]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[124:125], v118, off
	global_store_short_d16_hi v[148:149], v119, off
	v_lshlrev_b64 v[118:119], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[152:153], 1, v[0:1]
	v_add_u32_e32 v0, s1, v0
	v_lshl_add_u64 v[150:151], v[132:133], 0, v[118:119]
	v_lshl_add_u64 v[154:155], v[132:133], 0, v[152:153]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[150:151], v120, off
	global_store_short_d16_hi v[154:155], v121, off
	global_store_short_d16_hi v[124:125], v114, off offset:32
	global_store_short_d16_hi v[148:149], v115, off offset:32
	global_store_short_d16_hi v[150:151], v116, off offset:32
	global_store_short_d16_hi v[154:155], v117, off offset:32
	v_lshlrev_b64 v[114:115], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[120:121], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[116:117], v[132:133], 0, v[114:115]
	v_lshl_add_u64 v[156:157], v[132:133], 0, v[120:121]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[116:117], v110, off
	global_store_short_d16_hi v[156:157], v111, off
	v_lshlrev_b64 v[110:111], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[160:161], 1, v[0:1]
	v_add_u32_e32 v0, s1, v0
	v_lshl_add_u64 v[158:159], v[132:133], 0, v[110:111]
	v_lshl_add_u64 v[162:163], v[132:133], 0, v[160:161]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[158:159], v112, off
	global_store_short_d16_hi v[162:163], v113, off
	global_store_short_d16_hi v[116:117], v106, off offset:32
	global_store_short_d16_hi v[156:157], v107, off offset:32
	global_store_short_d16_hi v[158:159], v108, off offset:32
	global_store_short_d16_hi v[162:163], v109, off offset:32
	v_lshlrev_b64 v[106:107], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[112:113], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[108:109], v[132:133], 0, v[106:107]
	v_lshl_add_u64 v[164:165], v[132:133], 0, v[112:113]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[108:109], v94, off
	global_store_short_d16_hi v[164:165], v95, off
	v_lshlrev_b64 v[94:95], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 1, v[0:1]
	v_lshl_add_u64 v[166:167], v[132:133], 0, v[94:95]
	v_lshl_add_u64 v[168:169], v[132:133], 0, v[0:1]
	s_mov_b64 s[4:5], 0x100
	global_store_short_d16_hi v[166:167], v96, off
	global_store_short_d16_hi v[168:169], v97, off
	global_store_short_d16_hi v[108:109], v86, off offset:32
	global_store_short_d16_hi v[164:165], v87, off offset:32
	global_store_short_d16_hi v[166:167], v88, off offset:32
	global_store_short_d16_hi v[168:169], v89, off offset:32
	v_lshl_add_u64 v[86:87], v[132:133], 0, s[4:5]
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[134:135]
	global_store_short_d16_hi v[136:137], v102, off offset:256
	global_store_short_d16_hi v[140:141], v103, off offset:256
	global_store_short_d16_hi v[142:143], v104, off offset:256
	global_store_short_d16_hi v[146:147], v105, off offset:256
	global_store_short_d16_hi v[88:89], v98, off offset:32
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[138:139]
	global_store_short_d16_hi v[88:89], v99, off offset:32
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[126:127]
	global_store_short_d16_hi v[88:89], v100, off offset:32
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[144:145]
	global_store_short_d16_hi v[88:89], v101, off offset:32
	global_store_short_d16_hi v[124:125], v90, off offset:256
	global_store_short_d16_hi v[148:149], v91, off offset:256
	global_store_short_d16_hi v[150:151], v92, off offset:256
	global_store_short_d16_hi v[154:155], v93, off offset:256
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[122:123]
	global_store_short_d16_hi v[88:89], v82, off offset:32
	v_lshl_add_u64 v[88:89], v[86:87], 0, v[128:129]
	global_store_short_d16_hi v[88:89], v83, off offset:32
	v_lshl_add_u64 v[82:83], v[86:87], 0, v[118:119]
	global_store_short_d16_hi v[82:83], v84, off offset:32
	v_lshl_add_u64 v[82:83], v[86:87], 0, v[152:153]
	global_store_short_d16_hi v[82:83], v85, off offset:32
	global_store_short_d16_hi v[116:117], v78, off offset:256
	global_store_short_d16_hi v[156:157], v79, off offset:256
	global_store_short_d16_hi v[158:159], v80, off offset:256
	global_store_short_d16_hi v[162:163], v81, off offset:256
	v_lshl_add_u64 v[78:79], v[86:87], 0, v[114:115]
	global_store_short_d16_hi v[78:79], v74, off offset:32
	v_lshl_add_u64 v[78:79], v[86:87], 0, v[120:121]
	global_store_short_d16_hi v[78:79], v75, off offset:32
	v_lshl_add_u64 v[74:75], v[86:87], 0, v[110:111]
	global_store_short_d16_hi v[74:75], v76, off offset:32
	v_lshl_add_u64 v[74:75], v[86:87], 0, v[160:161]
	global_store_short_d16_hi v[74:75], v77, off offset:32
	global_store_short_d16_hi v[108:109], v70, off offset:256
	global_store_short_d16_hi v[164:165], v71, off offset:256
	global_store_short_d16_hi v[166:167], v72, off offset:256
	global_store_short_d16_hi v[168:169], v73, off offset:256
	v_lshl_add_u64 v[70:71], v[86:87], 0, v[106:107]
	global_store_short_d16_hi v[70:71], v58, off offset:32
	v_lshl_add_u64 v[70:71], v[86:87], 0, v[112:113]
	global_store_short_d16_hi v[70:71], v59, off offset:32
	v_lshl_add_u64 v[58:59], v[86:87], 0, v[94:95]
	global_store_short_d16_hi v[58:59], v60, off offset:32
	v_lshl_add_u64 v[58:59], v[86:87], 0, v[0:1]
	global_store_short_d16_hi v[58:59], v61, off offset:32
	v_or_b32_e32 v58, 0x80, v170
	v_mad_i64_i32 v[58:59], s[0:1], s0, v58, 0
	v_lshl_add_u64 v[58:59], v[58:59], 1, s[2:3]
	v_lshl_add_u64 v[58:59], v[58:59], 0, v[130:131]
	v_lshl_add_u64 v[60:61], v[58:59], 0, v[134:135]
	v_lshl_add_u64 v[70:71], v[58:59], 0, v[138:139]
	global_store_short_d16_hi v[60:61], v66, off
	global_store_short_d16_hi v[70:71], v67, off
	v_lshl_add_u64 v[66:67], v[58:59], 0, v[126:127]
	v_lshl_add_u64 v[72:73], v[58:59], 0, v[144:145]
	global_store_short_d16_hi v[66:67], v68, off
	global_store_short_d16_hi v[72:73], v69, off
	global_store_short_d16_hi v[60:61], v62, off offset:32
	global_store_short_d16_hi v[70:71], v63, off offset:32
	global_store_short_d16_hi v[66:67], v64, off offset:32
	global_store_short_d16_hi v[72:73], v65, off offset:32
	v_lshl_add_u64 v[62:63], v[58:59], 0, v[122:123]
	v_lshl_add_u64 v[64:65], v[58:59], 0, v[128:129]
	global_store_short_d16_hi v[62:63], v54, off
	global_store_short_d16_hi v[64:65], v55, off
	v_lshl_add_u64 v[54:55], v[58:59], 0, v[118:119]
	v_lshl_add_u64 v[68:69], v[58:59], 0, v[152:153]
	global_store_short_d16_hi v[54:55], v56, off
	global_store_short_d16_hi v[68:69], v57, off
	global_store_short_d16_hi v[62:63], v50, off offset:32
	global_store_short_d16_hi v[64:65], v51, off offset:32
	global_store_short_d16_hi v[54:55], v52, off offset:32
	global_store_short_d16_hi v[68:69], v53, off offset:32
	v_lshl_add_u64 v[50:51], v[58:59], 0, v[114:115]
	v_lshl_add_u64 v[52:53], v[58:59], 0, v[120:121]
	global_store_short_d16_hi v[50:51], v46, off
	global_store_short_d16_hi v[52:53], v47, off
	v_lshl_add_u64 v[46:47], v[58:59], 0, v[110:111]
	v_lshl_add_u64 v[56:57], v[58:59], 0, v[160:161]
	global_store_short_d16_hi v[46:47], v48, off
	global_store_short_d16_hi v[56:57], v49, off
	global_store_short_d16_hi v[50:51], v42, off offset:32
	global_store_short_d16_hi v[52:53], v43, off offset:32
	global_store_short_d16_hi v[46:47], v44, off offset:32
	global_store_short_d16_hi v[56:57], v45, off offset:32
	v_lshl_add_u64 v[42:43], v[58:59], 0, v[106:107]
	v_lshl_add_u64 v[44:45], v[58:59], 0, v[112:113]
	global_store_short_d16_hi v[42:43], v38, off
	global_store_short_d16_hi v[44:45], v39, off
	v_lshl_add_u64 v[38:39], v[58:59], 0, v[94:95]
	v_lshl_add_u64 v[48:49], v[58:59], 0, v[0:1]
	global_store_short_d16_hi v[38:39], v40, off
	global_store_short_d16_hi v[48:49], v41, off
	global_store_short_d16_hi v[42:43], v34, off offset:32
	global_store_short_d16_hi v[44:45], v35, off offset:32
	global_store_short_d16_hi v[38:39], v36, off offset:32
	global_store_short_d16_hi v[48:49], v37, off offset:32
	v_lshl_add_u64 v[34:35], v[58:59], 0, s[4:5]
	global_store_short_d16_hi v[60:61], v30, off offset:256
	global_store_short_d16_hi v[70:71], v31, off offset:256
	global_store_short_d16_hi v[66:67], v32, off offset:256
	global_store_short_d16_hi v[72:73], v33, off offset:256
	v_lshl_add_u64 v[30:31], v[34:35], 0, v[134:135]
	global_store_short_d16_hi v[30:31], v26, off offset:32
	v_lshl_add_u64 v[30:31], v[34:35], 0, v[138:139]
	global_store_short_d16_hi v[30:31], v27, off offset:32
	v_lshl_add_u64 v[26:27], v[34:35], 0, v[126:127]
	global_store_short_d16_hi v[26:27], v28, off offset:32
	v_lshl_add_u64 v[26:27], v[34:35], 0, v[144:145]
	global_store_short_d16_hi v[26:27], v29, off offset:32
	global_store_short_d16_hi v[62:63], v22, off offset:256
	global_store_short_d16_hi v[64:65], v23, off offset:256
	global_store_short_d16_hi v[54:55], v24, off offset:256
	global_store_short_d16_hi v[68:69], v25, off offset:256
	v_lshl_add_u64 v[22:23], v[34:35], 0, v[122:123]
	global_store_short_d16_hi v[22:23], v18, off offset:32
	v_lshl_add_u64 v[22:23], v[34:35], 0, v[128:129]
	global_store_short_d16_hi v[22:23], v19, off offset:32
	v_lshl_add_u64 v[18:19], v[34:35], 0, v[118:119]
	global_store_short_d16_hi v[18:19], v20, off offset:32
	v_lshl_add_u64 v[18:19], v[34:35], 0, v[152:153]
	global_store_short_d16_hi v[18:19], v21, off offset:32
	global_store_short_d16_hi v[50:51], v14, off offset:256
	global_store_short_d16_hi v[52:53], v15, off offset:256
	global_store_short_d16_hi v[46:47], v16, off offset:256
	global_store_short_d16_hi v[56:57], v17, off offset:256
	v_lshl_add_u64 v[14:15], v[34:35], 0, v[114:115]
	global_store_short_d16_hi v[14:15], v10, off offset:32
	v_lshl_add_u64 v[14:15], v[34:35], 0, v[120:121]
	global_store_short_d16_hi v[14:15], v11, off offset:32
	v_lshl_add_u64 v[10:11], v[34:35], 0, v[110:111]
	global_store_short_d16_hi v[10:11], v12, off offset:32
	v_lshl_add_u64 v[10:11], v[34:35], 0, v[160:161]
	global_store_short_d16_hi v[10:11], v13, off offset:32
	global_store_short_d16_hi v[42:43], v6, off offset:256
	global_store_short_d16_hi v[44:45], v7, off offset:256
	global_store_short_d16_hi v[38:39], v8, off offset:256
	global_store_short_d16_hi v[48:49], v9, off offset:256
	v_lshl_add_u64 v[6:7], v[34:35], 0, v[106:107]
	global_store_short_d16_hi v[6:7], v2, off offset:32
	v_lshl_add_u64 v[6:7], v[34:35], 0, v[112:113]
	global_store_short_d16_hi v[6:7], v3, off offset:32
	v_lshl_add_u64 v[2:3], v[34:35], 0, v[94:95]
	v_lshl_add_u64 v[0:1], v[34:35], 0, v[0:1]
	global_store_short_d16_hi v[2:3], v4, off offset:32
	global_store_short_d16_hi v[0:1], v5, off offset:32
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z8micro_tk13micro_globalsiii
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 440
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
		.amdhsa_next_free_vgpr 218
		.amdhsa_next_free_sgpr 43
		.amdhsa_accum_offset 220
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
	.size	_Z8micro_tk13micro_globalsiii, .Lfunc_end0-_Z8micro_tk13micro_globalsiii

	.set _Z8micro_tk13micro_globalsiii.num_vgpr, 218
	.set _Z8micro_tk13micro_globalsiii.num_agpr, 0
	.set _Z8micro_tk13micro_globalsiii.numbered_sgpr, 43
	.set _Z8micro_tk13micro_globalsiii.private_seg_size, 0
	.set _Z8micro_tk13micro_globalsiii.uses_vcc, 1
	.set _Z8micro_tk13micro_globalsiii.uses_flat_scratch, 0
	.set _Z8micro_tk13micro_globalsiii.has_dyn_sized_stack, 0
	.set _Z8micro_tk13micro_globalsiii.has_recursion, 0
	.set _Z8micro_tk13micro_globalsiii.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_8d1dee7552304a64,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_8d1dee7552304a64
__hip_cuid_8d1dee7552304a64:
	.byte	0
	.size	__hip_cuid_8d1dee7552304a64, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_8d1dee7552304a64
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           168
        .value_kind:     by_value
      - .offset:         168
        .size:           4
        .value_kind:     by_value
      - .offset:         172
        .size:           4
        .value_kind:     by_value
      - .offset:         176
        .size:           4
        .value_kind:     by_value
      - .offset:         184
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         188
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         192
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         196
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         198
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         200
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         202
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         204
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         206
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         224
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         232
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         240
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         248
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         304
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 440
    .max_flat_workgroup_size: 512
    .name:           _Z8micro_tk13micro_globalsiii
    .private_segment_fixed_size: 0
    .sgpr_count:     49
    .sgpr_spill_count: 0
    .symbol:         _Z8micro_tk13micro_globalsiii.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     218
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
