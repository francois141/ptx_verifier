	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._Z10attend_kerILi64EEv12attn_globalsIXT_EE,"axG",@progbits,_Z10attend_kerILi64EEv12attn_globalsIXT_EE,comdat
	.protected	_Z10attend_kerILi64EEv12attn_globalsIXT_EE
	.globl	_Z10attend_kerILi64EEv12attn_globalsIXT_EE
	.p2align	8
	.type	_Z10attend_kerILi64EEv12attn_globalsIXT_EE,@function
_Z10attend_kerILi64EEv12attn_globalsIXT_EE:
	s_load_dwordx8 s[8:15], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x20
	s_load_dwordx2 s[48:49], s[0:1], 0x30
	s_cmp_lg_u32 0, -1
	s_mov_b32 s5, s3
	s_cselect_b32 s3, 0, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s11, s3, -16
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s9
	s_mov_b32 s9, 0
	s_and_b32 s8, s3, 15
	s_add_i32 s11, s11, 16
	s_cmp_eq_u64 s[8:9], 0
	s_cselect_b32 s13, s3, s11
	s_add_i32 s11, s13, 0x4000
	s_load_dwordx2 s[52:53], s[0:1], 0x50
	s_load_dwordx4 s[16:19], s[0:1], 0x40
	s_load_dwordx2 s[54:55], s[0:1], 0x60
	s_load_dwordx4 s[20:23], s[0:1], 0x70
	s_load_dwordx8 s[24:31], s[0:1], 0x90
	s_load_dwordx2 s[46:47], s[0:1], 0xb0
	s_load_dwordx2 s[34:35], s[0:1], 0xc0
	s_load_dwordx2 s[44:45], s[0:1], 0xe0
	s_load_dwordx4 s[36:39], s[0:1], 0xd0
	s_and_b32 s3, s11, -16
	s_waitcnt lgkmcnt(0)
	s_add_i32 s19, s3, 16
	s_mul_hi_i32 s3, s16, s4
	s_mul_i32 s16, s16, s4
	s_bfe_i64 s[40:41], s[18:19], 0x200000
	s_mul_i32 s17, s16, s41
	s_mul_hi_u32 s21, s16, s18
	s_add_i32 s17, s21, s17
	s_mul_i32 s3, s3, s18
	s_and_b32 s8, s11, 15
	s_add_i32 s17, s17, s3
	s_mul_i32 s16, s16, s18
	s_ashr_i32 s3, s2, 31
	s_add_u32 s21, s16, s2
	s_addc_u32 s23, s17, s3
	s_mov_b32 s16, s9
	s_mov_b32 s17, s52
	s_ashr_i64 s[16:17], s[16:17], 31
	s_mul_i32 s23, s16, s23
	s_mul_hi_u32 s27, s16, s21
	s_add_i32 s23, s27, s23
	s_mul_i32 s17, s17, s21
	s_bfe_i64 s[42:43], s[52:53], 0x200000
	s_add_i32 s23, s23, s17
	s_mul_i32 s16, s16, s21
	s_add_u32 s16, s48, s16
	s_addc_u32 s17, s49, s23
	s_mul_hi_i32 s21, s20, s4
	s_mul_i32 s20, s20, s4
	s_bfe_i64 s[48:49], s[22:23], 0x200000
	s_load_dword s51, s[0:1], 0x80
	s_mul_i32 s23, s20, s49
	s_mul_hi_u32 s27, s20, s22
	s_add_i32 s23, s27, s23
	s_mul_i32 s21, s21, s22
	s_add_i32 s23, s23, s21
	s_mul_i32 s20, s20, s22
	s_add_u32 s20, s20, s2
	s_mov_b32 s50, s9
	s_addc_u32 s21, s23, s3
	s_waitcnt lgkmcnt(0)
	s_ashr_i64 s[0:1], s[50:51], 31
	s_mul_i32 s21, s0, s21
	s_mul_hi_u32 s23, s0, s20
	s_add_i32 s21, s23, s21
	s_mul_i32 s1, s1, s20
	s_add_i32 s21, s21, s1
	s_mul_i32 s0, s0, s20
	s_add_u32 s0, s54, s0
	s_addc_u32 s1, s55, s21
	v_lshrrev_b32_e32 v1, 6, v0
	s_cmp_eq_u64 s[8:9], 0
	v_lshlrev_b32_e32 v4, 10, v1
	v_add_u32_e32 v5, s13, v4
	s_cselect_b32 s41, s11, s19
	s_mul_i32 s23, s18, s52
	v_readfirstlane_b32 s37, v5
	v_add_u32_e32 v5, s41, v4
	s_add_i32 s52, s13, 0x2000
	v_readfirstlane_b32 s29, v5
	v_add_u32_e32 v5, s52, v4
	s_add_i32 s43, s41, 0x2000
	v_readfirstlane_b32 s33, v5
	v_add_u32_e32 v5, s43, v4
	v_mov_b32_e32 v84, s0
	v_readfirstlane_b32 s27, v5
	v_lshlrev_b32_e32 v5, 4, v0
	v_and_b32_e32 v6, 0x3c0, v5
	s_movk_i32 s0, 0x400
	v_lshlrev_b32_e32 v7, 4, v1
	v_and_or_b32 v4, v4, s0, v6
	v_and_b32_e32 v6, 32, v0
	v_and_b32_e32 v8, 16, v7
	v_bitop3_b32 v5, v8, v5, v6 bitop3:0x36
	v_lshrrev_b32_e32 v4, 6, v4
	v_lshrrev_b32_e32 v64, 3, v0
	v_and_or_b32 v4, v64, 32, v4
	v_lshrrev_b32_e32 v5, 1, v5
	v_and_b32_e32 v7, 32, v7
	v_and_or_b32 v5, v5, 24, v7
	v_mul_lo_u32 v4, v4, s23
	v_add_lshl_u32 v135, v5, v4, 1
	v_lshrrev_b32_e32 v65, 2, v0
	v_and_b32_e32 v5, 56, v64
	s_mul_i32 s8, s22, s51
	v_lshlrev_b32_e32 v4, 3, v0
	v_and_or_b32 v5, v65, 7, v5
	v_mov_b32_e32 v107, 0x110000
	v_and_or_b32 v4, v4, 24, v6
	v_mul_lo_u32 v5, v5, s8
	s_mov_b32 s0, s37
	s_mov_b32 s53, s9
	s_mov_b32 s54, s18
	s_mov_b32 s49, s9
	s_mov_b32 s50, s22
	v_alignbit_b32 v106, s23, 0, 22
	v_mov_b32_e32 v104, s16
	v_mov_b32_e32 v105, s17
	v_alignbit_b32 v86, s8, 0, 22
	v_mov_b32_e32 v85, s1
	v_mov_b32_e32 v87, v107
	v_add_lshl_u32 v128, v4, v5, 1
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[20:21], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_1:
	v_readfirstlane_b32 s16, v104
	v_readfirstlane_b32 s17, v105
	v_readfirstlane_b32 s18, v106
	v_readfirstlane_b32 s19, v107
	v_cmp_eq_u64_e32 vcc, s[16:17], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[18:19], v[106:107]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[16:19], s9 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[20:21]
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_lshl_b32 s0, s5, 8
	v_lshl_or_b32 v124, v1, 5, s0
	v_ashrrev_i32_e32 v125, 31, v124
	v_mov_b32_e32 v1, s4
	v_mad_i64_i32 v[4:5], s[0:1], s12, v1, v[124:125]
	s_bfe_i64 s[0:1], s[14:15], 0x200000
	v_mov_b64_e32 v[6:7], s[2:3]
	v_mul_lo_u32 v1, v4, s1
	v_mul_lo_u32 v8, v5, s14
	v_mad_u64_u32 v[4:5], s[0:1], v4, s14, v[6:7]
	s_bfe_i64 s[0:1], s[6:7], 0x200000
	v_add3_u32 v1, v8, v5, v1
	v_mul_lo_u32 v6, v4, s1
	v_mad_u64_u32 v[4:5], s[0:1], v4, s6, 0
	s_mul_i32 s0, s14, s6
	s_mul_i32 s1, s10, s12
	v_mul_lo_u32 v1, v1, s6
	v_and_b32_e32 v126, 31, v0
	s_mul_i32 s1, s0, s1
	v_add3_u32 v5, v5, v6, v1
	v_and_b32_e32 v1, 8, v65
	s_lshl_b32 s1, s1, 1
	v_mul_lo_u32 v6, v126, s0
	v_lshl_add_u64 v[2:3], v[4:5], 1, v[2:3]
	v_mov_b32_e32 v4, s1
	v_mov_b32_e32 v5, 0x20000
	v_add_lshl_u32 v1, v6, v1, 1
	s_mov_b64 s[6:7], exec
	s_barrier
.LBB0_3:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v1, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[6:7]
	s_mov_b64 s[6:7], exec
.LBB0_5:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[10:13], v1, s[8:11], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_5
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v14, 16, v6
	v_and_b32_e32 v15, 0xffff0000, v6
	v_lshlrev_b32_e32 v16, 16, v7
	v_and_b32_e32 v17, 0xffff0000, v7
	v_lshlrev_b32_e32 v18, 16, v8
	v_and_b32_e32 v19, 0xffff0000, v8
	v_lshlrev_b32_e32 v20, 16, v9
	v_and_b32_e32 v21, 0xffff0000, v9
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v22, 16, v10
	v_and_b32_e32 v10, 0xffff0000, v10
	v_lshlrev_b32_e32 v23, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v11
	v_lshlrev_b32_e32 v24, 16, v12
	v_and_b32_e32 v12, 0xffff0000, v12
	v_lshlrev_b32_e32 v25, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v13
	s_mov_b64 s[6:7], exec
.LBB0_7:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v1, s[8:11], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_7
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v26, 16, v6
	v_and_b32_e32 v27, 0xffff0000, v6
	v_lshlrev_b32_e32 v28, 16, v7
	v_and_b32_e32 v29, 0xffff0000, v7
	v_lshlrev_b32_e32 v30, 16, v8
	v_and_b32_e32 v31, 0xffff0000, v8
	v_lshlrev_b32_e32 v32, 16, v9
	v_and_b32_e32 v33, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_9:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v1, s[8:11], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_9
	s_mov_b64 exec, s[6:7]
	s_lshl_b32 s0, s23, 6
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v1, 16, v6
	v_and_b32_e32 v2, 0xffff0000, v6
	v_lshlrev_b32_e32 v3, 16, v7
	v_and_b32_e32 v4, 0xffff0000, v7
	v_lshlrev_b32_e32 v5, 16, v8
	v_and_b32_e32 v6, 0xffff0000, v8
	v_lshlrev_b32_e32 v7, 16, v9
	v_and_b32_e32 v8, 0xffff0000, v9
	s_lshl_b32 s5, s0, 1
	s_mov_b32 s0, s33
	v_mul_f32_e32 v9, 0x3e38aa3b, v14
	v_mul_f32_e32 v14, 0x3e38aa3b, v15
	v_mul_f32_e32 v15, 0x3e38aa3b, v16
	v_mul_f32_e32 v16, 0x3e38aa3b, v17
	v_mul_f32_e32 v17, 0x3e38aa3b, v18
	v_mul_f32_e32 v18, 0x3e38aa3b, v19
	v_mul_f32_e32 v19, 0x3e38aa3b, v20
	v_mul_f32_e32 v20, 0x3e38aa3b, v21
	v_mul_f32_e32 v21, 0x3e38aa3b, v22
	v_mul_f32_e32 v10, 0x3e38aa3b, v10
	v_mul_f32_e32 v22, 0x3e38aa3b, v23
	v_mul_f32_e32 v11, 0x3e38aa3b, v11
	v_mul_f32_e32 v23, 0x3e38aa3b, v24
	v_mul_f32_e32 v12, 0x3e38aa3b, v12
	v_mul_f32_e32 v24, 0x3e38aa3b, v25
	v_mul_f32_e32 v13, 0x3e38aa3b, v13
	v_mul_f32_e32 v25, 0x3e38aa3b, v26
	v_mul_f32_e32 v26, 0x3e38aa3b, v27
	v_mul_f32_e32 v27, 0x3e38aa3b, v28
	v_mul_f32_e32 v28, 0x3e38aa3b, v29
	v_mul_f32_e32 v29, 0x3e38aa3b, v30
	v_mul_f32_e32 v30, 0x3e38aa3b, v31
	v_mul_f32_e32 v31, 0x3e38aa3b, v32
	v_mul_f32_e32 v32, 0x3e38aa3b, v33
	v_mul_f32_e32 v1, 0x3e38aa3b, v1
	v_mul_f32_e32 v2, 0x3e38aa3b, v2
	v_mul_f32_e32 v3, 0x3e38aa3b, v3
	v_mul_f32_e32 v4, 0x3e38aa3b, v4
	v_mul_f32_e32 v5, 0x3e38aa3b, v5
	v_mul_f32_e32 v6, 0x3e38aa3b, v6
	v_mul_f32_e32 v7, 0x3e38aa3b, v7
	v_mul_f32_e32 v8, 0x3e38aa3b, v8
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v9, v14
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v15, v16
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v17, v18
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v19, v20
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v92, v21, v10
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v93, v22, v11
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v94, v23, v12
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v95, v24, v13
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v25, v26
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v27, v28
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v29, v30
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v31, v32
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v88, v1, v2
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v89, v3, v4
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v90, v5, v6
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v91, v7, v8
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_11:
	v_readfirstlane_b32 s8, v104
	v_readfirstlane_b32 s9, v105
	v_readfirstlane_b32 s10, v106
	v_readfirstlane_b32 s11, v107
	v_cmp_eq_u64_e32 vcc, s[8:9], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[106:107]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_11
	s_mov_b64 exec, s[6:7]
	s_mov_b32 s5, 0
	s_mov_b32 s0, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_13:
	v_readfirstlane_b32 s8, v84
	v_readfirstlane_b32 s9, v85
	v_readfirstlane_b32 s10, v86
	v_readfirstlane_b32 s11, v87
	v_cmp_eq_u64_e32 vcc, s[8:9], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[86:87]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_13
	s_mov_b64 exec, s[6:7]
	v_lshlrev_b32_e32 v1, 6, v0
	v_lshrrev_b32_e32 v2, 1, v0
	v_lshlrev_b32_e32 v66, 2, v0
	v_and_b32_e32 v67, 16, v0
	v_and_b32_e32 v1, 0x7c0, v1
	v_and_b32_e32 v2, 16, v2
	v_and_or_b32 v4, v66, 32, v67
	v_or_b32_e32 v3, v2, v1
	v_bitop3_b32 v1, v2, v4, v1 bitop3:0x36
	v_add_u32_e32 v137, s13, v1
	;;#ASMSTART
	ds_read_b128 v[36:39], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[40:43], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[44:47], v137 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[48:51], v137 offset:0x1800

	;;#ASMEND
	v_bitop3_b32 v34, v3, v4, 32 bitop3:0x36
	v_add_u32_e32 v136, s13, v34
	;;#ASMSTART
	ds_read_b128 v[52:55], v136 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[56:59], v136 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[60:63], v136 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[68:71], v136 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_mov_b32 s8, 0
	s_mov_b32 s9, s8
	s_mov_b32 s10, s8
	s_mov_b32 s11, s8
	s_mov_b32 s12, s8
	s_mov_b32 s13, s8
	s_mov_b32 s14, s8
	s_mov_b32 s15, s8
	s_mov_b32 s16, s8
	s_mov_b32 s17, s8
	s_mov_b32 s18, s8
	s_mov_b32 s19, s8
	s_mov_b32 s20, s8
	s_mov_b32 s21, s8
	s_mov_b32 s22, s8
	s_mov_b32 s23, s8
	v_mov_b64_e32 v[2:3], s[8:9]
	v_mov_b64_e32 v[4:5], s[10:11]
	v_mov_b64_e32 v[6:7], s[12:13]
	v_mov_b64_e32 v[8:9], s[14:15]
	v_mov_b64_e32 v[10:11], s[16:17]
	v_mov_b64_e32 v[12:13], s[18:19]
	v_mov_b64_e32 v[14:15], s[20:21]
	v_mov_b64_e32 v[16:17], s[22:23]
	s_barrier
	s_nop 0
	v_mfma_f32_32x32x16_bf16 v[18:33], v[36:39], v[96:99], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[44:47], v[96:99], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[52:55], v[92:95], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[60:63], v[92:95], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[40:43], v[100:103], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[48:51], v[100:103], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[56:59], v[88:91], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[68:71], v[88:91], v[2:17]
	s_nop 7
	s_nop 2
	v_max_f32_e32 v35, v19, v21
	v_max3_f32 v36, v18, v20, v22
	v_max3_f32 v35, v35, v23, v25
	v_max3_f32 v36, v36, v24, v26
	v_max3_f32 v35, v35, v27, v29
	v_max3_f32 v36, v36, v28, v30
	v_max3_f32 v35, v35, v31, v33
	v_max3_f32 v36, v36, v32, v2
	v_max3_f32 v35, v35, v3, v5
	v_max3_f32 v36, v36, v4, v6
	v_max3_f32 v35, v35, v7, v9
	v_max3_f32 v36, v36, v8, v10
	v_max3_f32 v35, v35, v11, v13
	v_max3_f32 v36, v36, v12, v14
	v_max3_f32 v35, v35, v15, v17
	v_max3_f32 v35, v36, v16, v35
	v_mov_b32_e32 v36, v35
	s_nop 1
	v_permlane32_swap_b32_e64 v35, v36 bound_ctrl:1
	s_movk_i32 s0, 0x100
	v_cmp_gt_u32_e32 vcc, s0, v0
	s_movk_i32 s0, 0xff
	v_cmp_lt_u32_e64 s[0:1], s0, v0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB0_16
	s_barrier
.LBB0_16:
	s_or_b64 exec, exec, s[6:7]
	v_max_f32_e32 v138, v35, v36
	v_sub_f32_e32 v0, v18, v138
	v_sub_f32_e32 v18, v19, v138
	v_sub_f32_e32 v19, v20, v138
	v_sub_f32_e32 v20, v21, v138
	v_sub_f32_e32 v21, v22, v138
	v_sub_f32_e32 v22, v23, v138
	v_sub_f32_e32 v23, v24, v138
	v_sub_f32_e32 v24, v25, v138
	v_sub_f32_e32 v25, v26, v138
	v_sub_f32_e32 v26, v27, v138
	v_sub_f32_e32 v27, v28, v138
	v_sub_f32_e32 v28, v29, v138
	v_sub_f32_e32 v29, v30, v138
	v_sub_f32_e32 v30, v31, v138
	v_sub_f32_e32 v31, v32, v138
	v_sub_f32_e32 v32, v33, v138
	v_exp_f32_e32 v68, v0
	v_exp_f32_e32 v69, v18
	v_exp_f32_e32 v70, v19
	v_exp_f32_e32 v71, v20
	v_exp_f32_e32 v72, v21
	v_exp_f32_e32 v73, v22
	v_exp_f32_e32 v74, v23
	v_exp_f32_e32 v75, v24
	v_exp_f32_e32 v76, v25
	v_exp_f32_e32 v77, v26
	v_exp_f32_e32 v78, v27
	v_exp_f32_e32 v79, v28
	v_exp_f32_e32 v80, v29
	v_exp_f32_e32 v81, v30
	v_exp_f32_e32 v82, v31
	v_exp_f32_e32 v83, v32
	v_sub_f32_e32 v118, v2, v138
	v_sub_f32_e32 v119, v3, v138
	v_sub_f32_e32 v120, v4, v138
	v_sub_f32_e32 v115, v5, v138
	v_sub_f32_e32 v116, v6, v138
	v_sub_f32_e32 v117, v7, v138
	v_sub_f32_e32 v112, v8, v138
	v_sub_f32_e32 v113, v9, v138
	v_sub_f32_e32 v114, v10, v138
	v_sub_f32_e32 v109, v11, v138
	v_sub_f32_e32 v110, v12, v138
	v_sub_f32_e32 v111, v13, v138
	v_sub_f32_e32 v108, v14, v138
	v_sub_f32_e32 v122, v15, v138
	v_sub_f32_e32 v123, v16, v138
	v_sub_f32_e32 v121, v17, v138
	v_add_u32_e32 v133, s52, v1
	;;#ASMSTART
	ds_read_b128 v[48:51], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[36:39], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[56:59], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[52:55], v133 offset:0x1800

	;;#ASMEND
	v_add_u32_e32 v134, s52, v34
	;;#ASMSTART
	ds_read_b128 v[44:47], v134 offset:0

	;;#ASMEND
	v_mov_b32_e32 v0, s53
	;;#ASMSTART
	ds_read_b128 v[40:43], v134 offset:0x800

	;;#ASMEND
	v_alignbit_b32 v0, s54, v0, 25
	;;#ASMSTART
	ds_read_b128 v[60:63], v134 offset:0x1000

	;;#ASMEND
	v_mul_lo_u32 v0, s42, v0
	;;#ASMSTART
	ds_read_b128 v[16:19], v134 offset:0x1800

	;;#ASMEND
	s_mov_b64 s[12:13], exec
	v_readfirstlane_b32 s0, v0
	s_lshl_b32 s5, s0, 1
	s_mov_b32 s0, s37
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_17:
	v_readfirstlane_b32 s8, v104
	v_readfirstlane_b32 s9, v105
	v_readfirstlane_b32 s10, v106
	v_readfirstlane_b32 s11, v107
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_17
	s_mov_b64 exec, s[12:13]
	v_mov_b32_e32 v0, s49
	v_alignbit_b32 v0, s50, v0, 26
	v_mul_lo_u32 v0, s51, v0
	s_mov_b64 s[12:13], exec
	v_readfirstlane_b32 s0, v0
	s_lshl_b32 s5, s0, 1
	s_mov_b32 s0, s27
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_19:
	v_readfirstlane_b32 s8, v84
	v_readfirstlane_b32 s9, v85
	v_readfirstlane_b32 s10, v86
	v_readfirstlane_b32 s11, v87
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_19
	s_mov_b64 exec, s[12:13]
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_mov_b32 s8, 0
	s_mov_b32 s9, s8
	s_mov_b32 s10, s8
	s_mov_b32 s11, s8
	s_mov_b32 s12, s8
	s_mov_b32 s13, s8
	s_mov_b32 s14, s8
	s_mov_b32 s15, s8
	s_mov_b32 s16, s8
	s_mov_b32 s17, s8
	s_mov_b32 s18, s8
	s_mov_b32 s19, s8
	s_mov_b32 s20, s8
	s_mov_b32 s21, s8
	s_mov_b32 s22, s8
	s_mov_b32 s23, s8
	v_exp_f32_e32 v139, v118
	v_exp_f32_e32 v140, v119
	v_exp_f32_e32 v141, v120
	v_exp_f32_e32 v115, v115
	v_exp_f32_e32 v142, v116
	v_exp_f32_e32 v143, v117
	v_exp_f32_e32 v144, v112
	v_exp_f32_e32 v145, v113
	v_exp_f32_e32 v146, v114
	v_exp_f32_e32 v109, v109
	v_exp_f32_e32 v110, v110
	v_exp_f32_e32 v111, v111
	v_mov_b64_e32 v[0:1], s[8:9]
	v_mov_b64_e32 v[2:3], s[10:11]
	v_mov_b64_e32 v[4:5], s[12:13]
	v_mov_b64_e32 v[6:7], s[14:15]
	v_mov_b64_e32 v[8:9], s[16:17]
	v_mov_b64_e32 v[10:11], s[18:19]
	v_mov_b64_e32 v[12:13], s[20:21]
	v_mov_b64_e32 v[14:15], s[22:23]
	s_mul_i32 s50, s42, s40
	s_mul_i32 s5, s51, s48
	v_mfma_f32_32x32x16_bf16 v[20:35], v[48:51], v[96:99], v[0:15]
	s_barrier
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v120, v68, v69
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[20:35], v[44:47], v[92:95], v[20:35]
	v_mfma_f32_32x32x16_bf16 v[20:35], v[36:39], v[100:103], v[20:35]
	v_mfma_f32_32x32x16_bf16 v[20:35], v[40:43], v[88:91], v[20:35]
	v_mfma_f32_32x32x16_bf16 v[36:51], v[56:59], v[96:99], v[0:15]
	s_nop 6
	v_exp_f32_e32 v0, v108
	v_exp_f32_e32 v1, v122
	v_exp_f32_e32 v2, v123
	v_exp_f32_e32 v3, v121
	v_and_b32_e32 v127, 4, v64
	v_and_or_b32 v5, v66, 12, v67
	v_and_or_b32 v4, v65, 3, v127
	v_lshlrev_b32_e32 v5, 1, v5
	v_lshl_or_b32 v4, v4, 6, v5
	v_add_u32_e32 v132, s41, v4
	v_add_u32_e32 v131, s43, v4
	v_add_f32_e32 v4, v69, v68
	v_add_f32_e32 v4, v4, v70
	v_add_f32_e32 v4, v4, v71
	v_add_f32_e32 v4, v4, v72
	v_add_f32_e32 v4, v4, v73
	v_add_f32_e32 v4, v4, v74
	v_add_f32_e32 v4, v4, v75
	v_add_f32_e32 v4, v4, v76
	v_add_f32_e32 v4, v4, v77
	v_add_f32_e32 v4, v4, v78
	v_add_f32_e32 v4, v4, v79
	v_add_f32_e32 v4, v4, v80
	v_add_f32_e32 v4, v4, v81
	v_add_f32_e32 v4, v4, v82
	v_add_f32_e32 v4, v4, v83
	v_add_f32_e32 v4, v4, v139
	v_add_f32_e32 v4, v4, v140
	v_add_f32_e32 v4, v4, v141
	v_add_f32_e32 v4, v4, v115
	v_add_f32_e32 v4, v4, v142
	v_add_f32_e32 v4, v4, v143
	v_add_f32_e32 v4, v4, v144
	v_add_f32_e32 v4, v4, v145
	v_add_f32_e32 v4, v4, v146
	v_add_f32_e32 v4, v4, v109
	v_add_f32_e32 v4, v4, v110
	v_add_f32_e32 v4, v4, v111
	v_add_f32_e32 v4, v4, v0
	v_add_f32_e32 v4, v4, v1
	v_add_f32_e32 v4, v4, v2
	v_add_f32_e32 v129, v4, v3
	v_mov_b32_e32 v130, v129
	s_nop 1
	v_permlane32_swap_b32_e64 v129, v130 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[36:51], v[60:63], v[92:95], v[36:51]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v121, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v122, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v123, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v116, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v117, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v118, v80, v81
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v119, v82, v83
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[36:51], v[52:55], v[100:103], v[36:51]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v112, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v113, v141, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v114, v142, v143
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v115, v144, v145
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v146, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v0, v1
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[36:51], v[16:19], v[88:91], v[36:51]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v2, v3
	;;#ASMEND
	s_barrier
	s_mul_i32 s51, s50, 0x180
	s_mov_b32 s0, s33
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_21:
	v_readfirstlane_b32 s40, v104
	v_readfirstlane_b32 s41, v105
	v_readfirstlane_b32 s42, v106
	v_readfirstlane_b32 s43, v107
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_21
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[52:53], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v132 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v132 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v132 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v132 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[54:55], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v132 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v132 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v132 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v132 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v132 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v132 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v132 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mov_b64_e32 v[82:83], s[22:23]
	v_mov_b64_e32 v[80:81], s[20:21]
	v_mov_b64_e32 v[78:79], s[18:19]
	v_mov_b64_e32 v[76:77], s[16:17]
	v_mov_b64_e32 v[74:75], s[14:15]
	v_mov_b64_e32 v[72:73], s[12:13]
	v_mov_b64_e32 v[70:71], s[10:11]
	v_mov_b64_e32 v[68:69], s[8:9]
	v_max_f32_e32 v0, v21, v23
	v_max3_f32 v1, v20, v22, v24
	v_mfma_f32_32x32x16_bf16 v[2:17], v[52:55], v[120:123], v[68:83]
	v_max3_f32 v0, v0, v25, v27
	v_max3_f32 v1, v1, v26, v28
	v_max3_f32 v0, v0, v29, v31
	v_max3_f32 v1, v1, v30, v32
	v_max3_f32 v0, v0, v33, v35
	v_mfma_f32_32x32x16_bf16 v[52:67], v[140:143], v[120:123], v[68:83]
	v_max3_f32 v1, v1, v34, v36
	v_max3_f32 v0, v0, v37, v39
	v_max3_f32 v1, v1, v38, v40
	v_max3_f32 v0, v0, v41, v43
	v_max3_f32 v1, v1, v42, v44
	v_mfma_f32_32x32x16_bf16 v[2:17], v[144:147], v[116:119], v[2:17]
	v_max3_f32 v0, v0, v45, v47
	v_max3_f32 v1, v1, v46, v48
	v_max3_f32 v0, v0, v49, v51
	v_max3_f32 v0, v1, v50, v0
	v_mov_b32_e32 v1, v0
	v_mfma_f32_32x32x16_bf16 v[52:67], v[148:151], v[116:119], v[52:67]
	s_nop 0
	v_permlane32_swap_b32_e64 v0, v1 bound_ctrl:1
	v_max3_f32 v82, v138, v0, v1
	v_sub_f32_e32 v0, v138, v82
	v_sub_f32_e32 v68, v20, v82
	v_sub_f32_e32 v69, v21, v82
	v_sub_f32_e32 v123, v36, v82
	v_mfma_f32_32x32x16_bf16 v[2:17], v[152:155], v[112:115], v[2:17]
	v_sub_f32_e32 v70, v22, v82
	v_sub_f32_e32 v71, v23, v82
	v_sub_f32_e32 v72, v24, v82
	v_sub_f32_e32 v73, v25, v82
	v_sub_f32_e32 v74, v26, v82
	v_sub_f32_e32 v138, v37, v82
	v_sub_f32_e32 v139, v38, v82
	v_mfma_f32_32x32x16_bf16 v[52:67], v[156:159], v[112:115], v[52:67]
	v_sub_f32_e32 v75, v27, v82
	v_sub_f32_e32 v76, v28, v82
	v_sub_f32_e32 v77, v29, v82
	v_sub_f32_e32 v78, v30, v82
	v_sub_f32_e32 v79, v31, v82
	v_sub_f32_e32 v38, v39, v82
	v_sub_f32_e32 v39, v40, v82
	v_mfma_f32_32x32x16_bf16 v[2:17], v[160:163], v[108:111], v[2:17]
	v_sub_f32_e32 v118, v32, v82
	v_exp_f32_e32 v80, v0
	v_sub_f32_e32 v40, v41, v82
	v_sub_f32_e32 v36, v43, v82
	v_sub_f32_e32 v37, v44, v82
	v_sub_f32_e32 v32, v45, v82
	v_sub_f32_e32 v122, v48, v82
	s_nop 4
	v_pk_mul_f32 v[22:23], v[80:81], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[80:81], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[80:81], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[80:81], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[80:81], v[2:3] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[52:67], v[164:167], v[108:111], v[52:67]
	v_pk_mul_f32 v[28:29], v[80:81], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[80:81], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[80:81], v[10:11] op_sel_hi:[0,1]
	v_sub_f32_e32 v141, v49, v82
	v_sub_f32_e32 v142, v50, v82
	v_sub_f32_e32 v140, v51, v82
	s_nop 5
	v_pk_mul_f32 v[0:1], v[80:81], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[80:81], v[54:55] op_sel_hi:[0,1]
	v_sub_f32_e32 v52, v33, v82
	v_sub_f32_e32 v53, v34, v82
	v_sub_f32_e32 v54, v35, v82
	v_pk_mul_f32 v[14:15], v[80:81], v[66:67] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[80:81], v[64:65] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[80:81], v[62:63] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[80:81], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[80:81], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[80:81], v[56:57] op_sel_hi:[0,1]
	v_exp_f32_e32 v81, v68
	v_exp_f32_e32 v83, v69
	v_exp_f32_e32 v108, v70
	v_exp_f32_e32 v109, v71
	v_exp_f32_e32 v110, v72
	v_exp_f32_e32 v111, v73
	v_exp_f32_e32 v112, v74
	v_exp_f32_e32 v113, v75
	v_exp_f32_e32 v114, v76
	v_exp_f32_e32 v115, v77
	v_exp_f32_e32 v116, v78
	v_exp_f32_e32 v117, v79
	v_exp_f32_e32 v118, v118
	v_exp_f32_e32 v119, v52
	v_exp_f32_e32 v120, v53
	v_exp_f32_e32 v121, v54
	v_sub_f32_e32 v35, v42, v82
	v_sub_f32_e32 v33, v46, v82
	v_sub_f32_e32 v34, v47, v82
	s_setprio 0
	s_barrier
	s_lshl_b32 s51, s5, 8
	s_mov_b32 s0, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_23:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_23
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[42:45], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[144:147], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[148:151], v137 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v137 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v136 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v136 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v136 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v136 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v123, v123
	v_exp_f32_e32 v138, v138
	v_exp_f32_e32 v139, v139
	v_exp_f32_e32 v143, v38
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[156:159], v[92:95], v[48:63]
	v_exp_f32_e32 v156, v39
	v_exp_f32_e32 v157, v40
	v_mfma_f32_32x32x16_bf16 v[48:63], v[144:147], v[100:103], v[48:63]
	v_exp_f32_e32 v144, v35
	v_exp_f32_e32 v145, v36
	v_exp_f32_e32 v146, v37
	v_exp_f32_e32 v147, v32
	v_exp_f32_e32 v158, v33
	v_exp_f32_e32 v159, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[148:151], v[96:99], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v81, v83
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v114, v115
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v122
	v_exp_f32_e32 v122, v141
	v_exp_f32_e32 v141, v142
	v_exp_f32_e32 v140, v140
	v_add_f32_e32 v64, v83, v81
	v_add_f32_e32 v64, v64, v108
	v_add_f32_e32 v64, v64, v109
	v_add_f32_e32 v64, v64, v110
	v_add_f32_e32 v64, v64, v111
	v_add_f32_e32 v64, v64, v112
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v114
	v_add_f32_e32 v64, v64, v115
	v_add_f32_e32 v64, v64, v116
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v120
	v_add_f32_e32 v64, v64, v121
	v_add_f32_e32 v64, v64, v123
	v_add_f32_e32 v64, v64, v138
	v_add_f32_e32 v64, v64, v139
	v_add_f32_e32 v142, v64, v143
	v_add_f32_e32 v81, v142, v156
	v_add_f32_e32 v81, v81, v157
	v_add_f32_e32 v81, v81, v144
	v_add_f32_e32 v81, v81, v145
	v_add_f32_e32 v81, v81, v146
	v_add_f32_e32 v81, v81, v147
	v_add_f32_e32 v81, v81, v158
	v_add_f32_e32 v81, v81, v159
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v116, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v118, v119
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v120, v121
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v123, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v139, v143
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v156, v157
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v144, v145
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v146, v147
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v158, v159
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v122
	;;#ASMEND
	v_add_f32_e32 v67, v81, v67
	v_add_f32_e32 v67, v67, v122
	v_add_f32_e32 v67, v67, v141
	v_add_f32_e32 v81, v67, v140
	v_mov_b32_e32 v83, v81
	s_nop 1
	v_permlane32_swap_b32_e64 v81, v83 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[160:163], v[88:91], v[48:63]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v141, v140
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[164:167], v[92:95], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[168:171], v[88:91], v[32:47]
	s_barrier
	s_lshl_b32 s51, s50, 9
	s_mov_b32 s0, s37
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_25:
	v_readfirstlane_b32 s40, v104
	v_readfirstlane_b32 s41, v105
	v_readfirstlane_b32 s42, v106
	v_readfirstlane_b32 s43, v107
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_25
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v131 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v131 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v131 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v131 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v131 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v131 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v131 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v131 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v131 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v131 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v131 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v131 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v131 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v131 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v131 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v131 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[108:111], v[76:79], v[16:31]
	v_sub_f32_e32 v60, v60, v82
	v_sub_f32_e32 v61, v61, v82
	v_sub_f32_e32 v62, v62, v82
	v_sub_f32_e32 v63, v63, v82
	v_mfma_f32_32x32x16_bf16 v[0:15], v[112:115], v[76:79], v[0:15]
	v_sub_f32_e32 v76, v52, v82
	v_sub_f32_e32 v77, v57, v82
	v_sub_f32_e32 v78, v58, v82
	v_sub_f32_e32 v79, v59, v82
	v_sub_f32_e32 v57, v32, v82
	v_mfma_f32_32x32x16_bf16 v[16:31], v[116:119], v[72:75], v[16:31]
	v_sub_f32_e32 v58, v33, v82
	v_sub_f32_e32 v59, v34, v82
	v_sub_f32_e32 v52, v39, v82
	v_mfma_f32_32x32x16_bf16 v[0:15], v[120:123], v[72:75], v[0:15]
	v_sub_f32_e32 v72, v48, v82
	v_sub_f32_e32 v73, v49, v82
	v_sub_f32_e32 v74, v50, v82
	v_sub_f32_e32 v75, v51, v82
	v_sub_f32_e32 v51, v38, v82
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[68:71], v[16:31]
	v_sub_f32_e32 v48, v41, v82
	v_sub_f32_e32 v49, v42, v82
	v_sub_f32_e32 v50, v43, v82
	v_sub_f32_e32 v138, v44, v82
	v_sub_f32_e32 v139, v45, v82
	v_mfma_f32_32x32x16_bf16 v[0:15], v[142:145], v[68:71], v[0:15]
	v_sub_f32_e32 v68, v53, v82
	v_sub_f32_e32 v69, v54, v82
	v_sub_f32_e32 v70, v55, v82
	v_sub_f32_e32 v71, v56, v82
	v_sub_f32_e32 v54, v35, v82
	v_mfma_f32_32x32x16_bf16 v[16:31], v[146:149], v[64:67], v[16:31]
	v_sub_f32_e32 v55, v36, v82
	v_sub_f32_e32 v56, v37, v82
	v_sub_f32_e32 v53, v40, v82
	v_sub_f32_e32 v141, v46, v82
	v_sub_f32_e32 v140, v47, v82
	v_mfma_f32_32x32x16_bf16 v[0:15], v[150:153], v[64:67], v[0:15]
	v_exp_f32_e32 v108, v72
	v_exp_f32_e32 v119, v73
	v_exp_f32_e32 v120, v74
	v_exp_f32_e32 v121, v75
	v_exp_f32_e32 v122, v76
	v_exp_f32_e32 v123, v68
	v_exp_f32_e32 v109, v69
	v_exp_f32_e32 v110, v70
	v_exp_f32_e32 v111, v71
	v_exp_f32_e32 v112, v77
	v_exp_f32_e32 v113, v78
	v_exp_f32_e32 v114, v79
	v_exp_f32_e32 v115, v60
	v_exp_f32_e32 v116, v61
	v_exp_f32_e32 v117, v62
	v_exp_f32_e32 v118, v63
	s_setprio 0
	s_barrier
	s_mul_i32 s51, s5, 0x180
	s_mov_b32 s0, s27
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_27:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_27
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[60:63], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v133 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v134 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v134 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v134 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v134 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v170, v57
	v_exp_f32_e32 v171, v58
	v_exp_f32_e32 v172, v59
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[60:63], v[96:99], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[92:95], v[32:47]
	v_exp_f32_e32 v154, v54
	v_exp_f32_e32 v155, v55
	v_exp_f32_e32 v156, v56
	v_mfma_f32_32x32x16_bf16 v[32:47], v[142:145], v[100:103], v[32:47]
	v_exp_f32_e32 v142, v51
	v_exp_f32_e32 v143, v52
	v_exp_f32_e32 v144, v53
	v_exp_f32_e32 v145, v48
	v_exp_f32_e32 v157, v49
	v_mfma_f32_32x32x16_bf16 v[32:47], v[158:161], v[88:91], v[32:47]
	v_exp_f32_e32 v158, v50
	v_mfma_f32_32x32x16_bf16 v[48:63], v[146:149], v[96:99], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v108, v119
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v120, v121
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v122, v123
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v109, v110
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v111, v112
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v138
	v_exp_f32_e32 v138, v139
	v_exp_f32_e32 v139, v141
	v_exp_f32_e32 v140, v140
	v_add_f32_e32 v64, v119, v108
	v_add_f32_e32 v64, v64, v120
	v_add_f32_e32 v64, v64, v121
	v_add_f32_e32 v64, v64, v122
	v_add_f32_e32 v64, v64, v123
	v_add_f32_e32 v64, v64, v109
	v_add_f32_e32 v64, v64, v110
	v_add_f32_e32 v64, v64, v111
	v_add_f32_e32 v64, v64, v112
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v114
	v_add_f32_e32 v64, v64, v115
	v_add_f32_e32 v64, v64, v116
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v170
	v_add_f32_e32 v64, v64, v171
	v_add_f32_e32 v64, v64, v172
	v_add_f32_e32 v108, v64, v154
	v_add_f32_e32 v108, v108, v155
	v_add_f32_e32 v108, v108, v156
	v_add_f32_e32 v108, v108, v142
	v_add_f32_e32 v108, v108, v143
	v_add_f32_e32 v108, v108, v144
	v_add_f32_e32 v108, v108, v145
	v_add_f32_e32 v108, v108, v157
	v_add_f32_e32 v108, v108, v158
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v113, v114
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v115, v116
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v117, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v170, v171
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v172, v154
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v155, v156
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v142, v143
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v144, v145
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v157, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v138
	;;#ASMEND
	v_add_f32_e32 v67, v108, v67
	v_add_f32_e32 v67, v67, v138
	v_add_f32_e32 v67, v67, v139
	v_add_f32_e32 v108, v67, v140
	v_mov_b32_e32 v109, v108
	s_nop 1
	v_permlane32_swap_b32_e64 v108, v109 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[162:165], v[92:95], v[48:63]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v139, v140
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[48:63], v[150:153], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[166:169], v[88:91], v[48:63]
	s_barrier
	s_mul_i32 s51, s50, 0x280
	s_mov_b32 s0, s33
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_29:
	v_readfirstlane_b32 s40, v104
	v_readfirstlane_b32 s41, v105
	v_readfirstlane_b32 s42, v106
	v_readfirstlane_b32 s43, v107
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_29
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v132 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v132 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v132 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v132 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v132 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v132 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v132 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v132 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v132 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v132 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v132 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[110:113], v[76:79], v[16:31]
	v_max_f32_e32 v110, v33, v35
	v_max3_f32 v111, v32, v34, v36
	v_max3_f32 v110, v110, v37, v39
	v_max3_f32 v111, v111, v38, v40
	v_max3_f32 v110, v110, v41, v43
	v_mfma_f32_32x32x16_bf16 v[0:15], v[114:117], v[76:79], v[0:15]
	v_max3_f32 v76, v111, v42, v44
	v_max3_f32 v77, v110, v45, v47
	v_max3_f32 v76, v76, v46, v48
	v_max3_f32 v77, v77, v49, v51
	v_max3_f32 v76, v76, v50, v52
	v_mfma_f32_32x32x16_bf16 v[16:31], v[118:121], v[72:75], v[16:31]
	v_max3_f32 v77, v77, v53, v55
	v_max3_f32 v76, v76, v54, v56
	v_max3_f32 v77, v77, v57, v59
	v_max3_f32 v76, v76, v58, v60
	v_max3_f32 v77, v77, v61, v63
	v_mfma_f32_32x32x16_bf16 v[0:15], v[138:141], v[72:75], v[0:15]
	v_max3_f32 v72, v76, v62, v77
	v_mov_b32_e32 v73, v72
	s_nop 1
	v_permlane32_swap_b32_e64 v72, v73 bound_ctrl:1
	v_max3_f32 v114, v82, v72, v73
	v_sub_f32_e32 v72, v82, v114
	v_sub_f32_e32 v46, v46, v114
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[68:71], v[16:31]
	v_sub_f32_e32 v73, v32, v114
	v_sub_f32_e32 v74, v33, v114
	v_sub_f32_e32 v75, v34, v114
	v_sub_f32_e32 v76, v35, v114
	v_sub_f32_e32 v77, v40, v114
	v_sub_f32_e32 v47, v47, v114
	v_sub_f32_e32 v40, v53, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[146:149], v[68:71], v[0:15]
	v_sub_f32_e32 v68, v36, v114
	v_sub_f32_e32 v69, v37, v114
	v_sub_f32_e32 v70, v38, v114
	v_sub_f32_e32 v71, v39, v114
	v_sub_f32_e32 v78, v41, v114
	v_sub_f32_e32 v41, v48, v114
	v_sub_f32_e32 v38, v51, v114
	v_mfma_f32_32x32x16_bf16 v[16:31], v[150:153], v[64:67], v[16:31]
	v_sub_f32_e32 v79, v42, v114
	v_sub_f32_e32 v122, v43, v114
	v_sub_f32_e32 v44, v44, v114
	v_sub_f32_e32 v45, v45, v114
	v_sub_f32_e32 v42, v49, v114
	v_sub_f32_e32 v43, v50, v114
	v_sub_f32_e32 v39, v52, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[154:157], v[64:67], v[0:15]
	v_exp_f32_e32 v82, v72
	v_sub_f32_e32 v35, v54, v114
	v_sub_f32_e32 v36, v55, v114
	v_sub_f32_e32 v37, v56, v114
	v_sub_f32_e32 v32, v57, v114
	v_sub_f32_e32 v33, v58, v114
	v_sub_f32_e32 v34, v59, v114
	s_nop 4
	v_pk_mul_f32 v[2:3], v[82:83], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[82:83], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[82:83], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[82:83], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[82:83], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[82:83], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[82:83], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[82:83], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[82:83], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[82:83], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[82:83], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[82:83], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[82:83], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[82:83], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[82:83], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[82:83], v[4:5] op_sel_hi:[0,1]
	v_exp_f32_e32 v110, v73
	v_exp_f32_e32 v111, v74
	v_exp_f32_e32 v112, v75
	v_exp_f32_e32 v113, v76
	v_exp_f32_e32 v115, v68
	v_exp_f32_e32 v116, v69
	v_exp_f32_e32 v117, v70
	v_exp_f32_e32 v118, v71
	v_exp_f32_e32 v119, v77
	v_exp_f32_e32 v120, v78
	v_exp_f32_e32 v121, v79
	v_exp_f32_e32 v122, v122
	v_exp_f32_e32 v123, v44
	v_exp_f32_e32 v138, v45
	v_exp_f32_e32 v139, v46
	v_exp_f32_e32 v140, v47
	v_sub_f32_e32 v141, v60, v114
	v_sub_f32_e32 v143, v61, v114
	v_sub_f32_e32 v144, v62, v114
	v_sub_f32_e32 v142, v63, v114
	s_setprio 0
	s_barrier
	s_lshl_b32 s51, s5, 9
	s_mov_b32 s0, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_31:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_31
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[44:47], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v137 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v137 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v136 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v136 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v136 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v136 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v145, v41
	v_exp_f32_e32 v174, v42
	v_exp_f32_e32 v175, v43
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[44:47], v[96:99], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[158:161], v[92:95], v[48:63]
	v_exp_f32_e32 v158, v38
	v_exp_f32_e32 v159, v39
	v_exp_f32_e32 v160, v40
	v_mfma_f32_32x32x16_bf16 v[48:63], v[146:149], v[100:103], v[48:63]
	v_exp_f32_e32 v146, v35
	v_exp_f32_e32 v147, v36
	v_exp_f32_e32 v148, v37
	v_exp_f32_e32 v149, v32
	v_exp_f32_e32 v161, v33
	v_mfma_f32_32x32x16_bf16 v[48:63], v[162:165], v[88:91], v[48:63]
	v_exp_f32_e32 v162, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[150:153], v[96:99], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v115, v116
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v117, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v119, v120
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v141
	v_exp_f32_e32 v141, v143
	v_exp_f32_e32 v143, v144
	v_exp_f32_e32 v142, v142
	v_add_f32_e32 v64, v111, v110
	v_add_f32_e32 v64, v64, v112
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v115
	v_add_f32_e32 v64, v64, v116
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v120
	v_add_f32_e32 v64, v64, v121
	v_add_f32_e32 v64, v64, v122
	v_add_f32_e32 v64, v64, v123
	v_add_f32_e32 v64, v64, v138
	v_add_f32_e32 v64, v64, v139
	v_add_f32_e32 v64, v64, v140
	v_add_f32_e32 v64, v64, v145
	v_add_f32_e32 v64, v64, v174
	v_add_f32_e32 v64, v64, v175
	v_add_f32_e32 v144, v64, v158
	v_add_f32_e32 v110, v144, v159
	v_add_f32_e32 v110, v110, v160
	v_add_f32_e32 v110, v110, v146
	v_add_f32_e32 v110, v110, v147
	v_add_f32_e32 v110, v110, v148
	v_add_f32_e32 v110, v110, v149
	v_add_f32_e32 v110, v110, v161
	v_add_f32_e32 v110, v110, v162
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v121, v122
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v123, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v145, v174
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v175, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v159, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v146, v147
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v148, v149
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v161, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v141
	;;#ASMEND
	v_add_f32_e32 v67, v110, v67
	v_add_f32_e32 v67, v67, v141
	v_add_f32_e32 v67, v67, v143
	v_add_f32_e32 v110, v67, v142
	v_mov_b32_e32 v111, v110
	s_nop 1
	v_permlane32_swap_b32_e64 v110, v111 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[166:169], v[92:95], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v143, v142
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[170:173], v[88:91], v[32:47]
	s_barrier
	s_mul_i32 s51, s50, 0x300
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s37
	;;#ASMEND
.LBB0_33:
	v_readfirstlane_b32 s40, v104
	v_readfirstlane_b32 s41, v105
	v_readfirstlane_b32 s42, v106
	v_readfirstlane_b32 s43, v107
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_33
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v131 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v131 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v131 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v131 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v131 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v131 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v131 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v131 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v131 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v131 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v131 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v131 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v131 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v131 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v131 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v131 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[116:119], v[76:79], v[16:31]
	v_sub_f32_e32 v48, v48, v114
	v_sub_f32_e32 v49, v49, v114
	v_sub_f32_e32 v50, v50, v114
	v_sub_f32_e32 v51, v51, v114
	v_sub_f32_e32 v52, v52, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[120:123], v[76:79], v[0:15]
	v_sub_f32_e32 v53, v53, v114
	v_sub_f32_e32 v54, v54, v114
	v_sub_f32_e32 v55, v55, v114
	v_sub_f32_e32 v56, v56, v114
	v_sub_f32_e32 v57, v57, v114
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[72:75], v[16:31]
	v_sub_f32_e32 v58, v58, v114
	v_sub_f32_e32 v59, v59, v114
	v_sub_f32_e32 v60, v60, v114
	v_sub_f32_e32 v61, v61, v114
	v_sub_f32_e32 v62, v62, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[142:145], v[72:75], v[0:15]
	v_sub_f32_e32 v63, v63, v114
	v_sub_f32_e32 v145, v35, v114
	v_sub_f32_e32 v35, v38, v114
	v_sub_f32_e32 v143, v44, v114
	v_sub_f32_e32 v144, v45, v114
	v_mfma_f32_32x32x16_bf16 v[16:31], v[146:149], v[68:71], v[16:31]
	v_sub_f32_e32 v148, v32, v114
	v_sub_f32_e32 v149, v33, v114
	v_sub_f32_e32 v146, v36, v114
	v_sub_f32_e32 v147, v37, v114
	v_sub_f32_e32 v36, v39, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[150:153], v[68:71], v[0:15]
	v_sub_f32_e32 v150, v34, v114
	v_sub_f32_e32 v37, v40, v114
	v_sub_f32_e32 v32, v41, v114
	v_sub_f32_e32 v33, v42, v114
	v_sub_f32_e32 v34, v43, v114
	v_mfma_f32_32x32x16_bf16 v[16:31], v[154:157], v[64:67], v[16:31]
	v_sub_f32_e32 v152, v46, v114
	v_sub_f32_e32 v151, v47, v114
	v_mfma_f32_32x32x16_bf16 v[0:15], v[158:161], v[64:67], v[0:15]
	v_exp_f32_e32 v112, v48
	v_exp_f32_e32 v113, v49
	v_exp_f32_e32 v115, v50
	v_exp_f32_e32 v116, v51
	v_exp_f32_e32 v117, v52
	v_exp_f32_e32 v118, v53
	v_exp_f32_e32 v119, v54
	v_exp_f32_e32 v120, v55
	v_exp_f32_e32 v121, v56
	v_exp_f32_e32 v122, v57
	v_exp_f32_e32 v123, v58
	v_exp_f32_e32 v138, v59
	v_exp_f32_e32 v139, v60
	v_exp_f32_e32 v140, v61
	v_exp_f32_e32 v141, v62
	v_exp_f32_e32 v142, v63
	s_setprio 0
	s_barrier
	s_mul_i32 s37, s5, 0x280
	s_mov_b32 s0, s27
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_35:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_35
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v133 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v134 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v134 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v134 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v134 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v148, v148
	v_exp_f32_e32 v149, v149
	v_exp_f32_e32 v150, v150
	v_exp_f32_e32 v145, v145
	v_exp_f32_e32 v146, v146
	v_exp_f32_e32 v147, v147
	v_exp_f32_e32 v153, v35
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[96:99], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[162:165], v[92:95], v[48:63]
	v_exp_f32_e32 v162, v36
	v_exp_f32_e32 v163, v37
	v_exp_f32_e32 v164, v32
	v_exp_f32_e32 v165, v33
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[166:169], v[88:91], v[48:63]
	v_exp_f32_e32 v166, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[96:99], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v115, v116
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v117, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v119, v120
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v121, v122
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v143
	v_exp_f32_e32 v143, v144
	v_exp_f32_e32 v144, v152
	v_exp_f32_e32 v151, v151
	v_add_f32_e32 v64, v113, v112
	v_add_f32_e32 v64, v64, v115
	v_add_f32_e32 v64, v64, v116
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v120
	v_add_f32_e32 v64, v64, v121
	v_add_f32_e32 v64, v64, v122
	v_add_f32_e32 v64, v64, v123
	v_add_f32_e32 v64, v64, v138
	v_add_f32_e32 v64, v64, v139
	v_add_f32_e32 v64, v64, v140
	v_add_f32_e32 v64, v64, v141
	v_add_f32_e32 v64, v64, v142
	v_add_f32_e32 v64, v64, v148
	v_add_f32_e32 v64, v64, v149
	v_add_f32_e32 v64, v64, v150
	v_add_f32_e32 v152, v64, v145
	v_add_f32_e32 v112, v152, v146
	v_add_f32_e32 v112, v112, v147
	v_add_f32_e32 v112, v112, v153
	v_add_f32_e32 v112, v112, v162
	v_add_f32_e32 v112, v112, v163
	v_add_f32_e32 v112, v112, v164
	v_add_f32_e32 v112, v112, v165
	v_add_f32_e32 v112, v112, v166
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v123, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v141, v142
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v148, v149
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v150, v145
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v146, v147
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v153, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v163, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v165, v166
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v143
	;;#ASMEND
	v_add_f32_e32 v67, v112, v67
	v_add_f32_e32 v67, v67, v143
	v_add_f32_e32 v67, v67, v144
	v_add_f32_e32 v112, v67, v151
	v_mov_b32_e32 v113, v112
	s_nop 1
	v_permlane32_swap_b32_e64 v112, v113 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[170:173], v[92:95], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v144, v151
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[158:161], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[174:177], v[88:91], v[32:47]
	s_barrier
	s_mul_i32 s37, s50, 0x380
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s33
	;;#ASMEND
.LBB0_37:
	v_readfirstlane_b32 s40, v104
	v_readfirstlane_b32 s41, v105
	v_readfirstlane_b32 s42, v106
	v_readfirstlane_b32 s43, v107
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[104:105]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[106:107]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v135, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_37
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v132 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v132 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v132 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v132 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v132 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v132 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v132 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v132 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v132 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v132 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v132 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[104:107], v[76:79], v[16:31]
	v_max_f32_e32 v104, v49, v51
	v_max3_f32 v105, v48, v50, v52
	v_max3_f32 v104, v104, v53, v55
	v_max3_f32 v105, v105, v54, v56
	v_max3_f32 v104, v104, v57, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[120:123], v[72:75], v[16:31]
	v_max3_f32 v105, v105, v58, v60
	v_max3_f32 v104, v104, v61, v63
	v_max3_f32 v105, v105, v62, v32
	v_max3_f32 v104, v104, v33, v35
	v_max3_f32 v105, v105, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[68:71], v[16:31]
	v_max3_f32 v104, v104, v37, v39
	v_max3_f32 v105, v105, v38, v40
	v_max3_f32 v104, v104, v41, v43
	v_max3_f32 v105, v105, v42, v44
	v_max3_f32 v104, v104, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[150:153], v[64:67], v[16:31]
	v_max3_f32 v104, v105, v46, v104
	v_mov_b32_e32 v105, v104
	s_nop 1
	v_permlane32_swap_b32_e64 v104, v105 bound_ctrl:1
	v_max3_f32 v105, v114, v104, v105
	v_sub_f32_e32 v104, v114, v105
	v_sub_f32_e32 v143, v46, v105
	v_mfma_f32_32x32x16_bf16 v[0:15], v[116:119], v[76:79], v[0:15]
	v_sub_f32_e32 v48, v48, v105
	v_sub_f32_e32 v49, v49, v105
	v_sub_f32_e32 v50, v50, v105
	v_sub_f32_e32 v51, v51, v105
	v_sub_f32_e32 v52, v52, v105
	v_sub_f32_e32 v150, v47, v105
	v_mfma_f32_32x32x16_bf16 v[0:15], v[138:141], v[72:75], v[0:15]
	v_sub_f32_e32 v53, v53, v105
	v_sub_f32_e32 v54, v54, v105
	v_sub_f32_e32 v55, v55, v105
	v_sub_f32_e32 v56, v56, v105
	v_sub_f32_e32 v57, v57, v105
	v_mfma_f32_32x32x16_bf16 v[0:15], v[146:149], v[68:71], v[0:15]
	v_sub_f32_e32 v58, v58, v105
	v_sub_f32_e32 v59, v59, v105
	v_sub_f32_e32 v60, v60, v105
	v_sub_f32_e32 v61, v61, v105
	v_sub_f32_e32 v62, v62, v105
	v_mfma_f32_32x32x16_bf16 v[0:15], v[154:157], v[64:67], v[0:15]
	v_sub_f32_e32 v63, v63, v105
	v_sub_f32_e32 v147, v32, v105
	v_sub_f32_e32 v148, v33, v105
	v_sub_f32_e32 v149, v34, v105
	v_sub_f32_e32 v144, v35, v105
	v_sub_f32_e32 v145, v36, v105
	v_sub_f32_e32 v146, v37, v105
	v_sub_f32_e32 v35, v38, v105
	v_sub_f32_e32 v36, v39, v105
	v_sub_f32_e32 v37, v40, v105
	v_sub_f32_e32 v32, v41, v105
	v_sub_f32_e32 v33, v42, v105
	v_sub_f32_e32 v34, v43, v105
	v_sub_f32_e32 v141, v44, v105
	v_sub_f32_e32 v142, v45, v105
	v_exp_f32_e32 v104, v104
	v_exp_f32_e32 v106, v48
	v_exp_f32_e32 v107, v49
	v_exp_f32_e32 v114, v50
	v_exp_f32_e32 v115, v51
	v_exp_f32_e32 v116, v52
	v_exp_f32_e32 v117, v53
	v_exp_f32_e32 v118, v54
	v_exp_f32_e32 v119, v55
	v_exp_f32_e32 v120, v56
	v_exp_f32_e32 v121, v57
	v_exp_f32_e32 v122, v58
	v_exp_f32_e32 v123, v59
	v_exp_f32_e32 v135, v60
	v_exp_f32_e32 v138, v61
	v_exp_f32_e32 v139, v62
	v_exp_f32_e32 v140, v63
	v_pk_mul_f32 v[30:31], v[104:105], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[104:105], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[104:105], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[104:105], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[104:105], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[104:105], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[104:105], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[104:105], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[104:105], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[104:105], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[104:105], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[104:105], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[104:105], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[104:105], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[104:105], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[104:105], v[0:1] op_sel_hi:[0,1]
	s_setprio 0
	s_barrier
	s_mul_i32 s33, s5, 0x300
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s29
	;;#ASMEND
.LBB0_39:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s33 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_39
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v137 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v137 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v137 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v137 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v136 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v136 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v136 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[172:175], v136 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v136, v147
	v_exp_f32_e32 v137, v148
	v_exp_f32_e32 v147, v149
	v_exp_f32_e32 v144, v144
	v_exp_f32_e32 v145, v145
	v_exp_f32_e32 v146, v146
	v_exp_f32_e32 v148, v35
	v_exp_f32_e32 v149, v36
	v_exp_f32_e32 v151, v37
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[96:99], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[160:163], v[92:95], v[48:63]
	v_exp_f32_e32 v160, v32
	v_exp_f32_e32 v161, v33
	v_exp_f32_e32 v162, v34
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[96:99], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v114, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v116, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v118, v119
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v120, v121
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v64, v141
	v_exp_f32_e32 v65, v142
	v_exp_f32_e32 v67, v143
	v_exp_f32_e32 v68, v150
	v_add_f32_e32 v66, v107, v106
	v_add_f32_e32 v66, v66, v114
	v_add_f32_e32 v66, v66, v115
	v_add_f32_e32 v66, v66, v116
	v_add_f32_e32 v66, v66, v117
	v_add_f32_e32 v66, v66, v118
	v_add_f32_e32 v66, v66, v119
	v_add_f32_e32 v66, v66, v120
	v_add_f32_e32 v66, v66, v121
	v_add_f32_e32 v66, v66, v122
	v_add_f32_e32 v66, v66, v123
	v_add_f32_e32 v66, v66, v135
	v_add_f32_e32 v66, v66, v138
	v_add_f32_e32 v66, v66, v139
	v_add_f32_e32 v66, v66, v140
	v_add_f32_e32 v66, v66, v136
	v_add_f32_e32 v66, v66, v137
	v_add_f32_e32 v66, v66, v147
	v_add_f32_e32 v66, v66, v144
	v_add_f32_e32 v66, v66, v145
	v_add_f32_e32 v66, v66, v146
	v_add_f32_e32 v66, v66, v148
	v_add_f32_e32 v66, v66, v149
	v_add_f32_e32 v66, v66, v151
	v_add_f32_e32 v66, v66, v160
	v_add_f32_e32 v66, v66, v161
	v_add_f32_e32 v66, v66, v162
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v122, v123
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v135, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v114, v136, v137
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v115, v147, v144
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v116, v145, v146
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v117, v148, v149
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v118, v151, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v119, v161, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v120, v64, v65
	;;#ASMEND
	v_add_f32_e32 v64, v66, v64
	v_add_f32_e32 v64, v64, v65
	v_add_f32_e32 v64, v64, v67
	v_add_f32_e32 v65, v64, v68
	v_mov_b32_e32 v66, v65
	s_nop 1
	v_permlane32_swap_b32_e64 v65, v66 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[164:167], v[88:91], v[48:63]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v121, v67, v68
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[168:171], v[92:95], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[172:175], v[88:91], v[32:47]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[68:69], v131 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v131 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v131 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v131 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v131 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v131 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v131 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v131 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[70:71], v131 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v131 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v131 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v131 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v131 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v131 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v131 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v131 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[68:71], v[72:75], v[16:31]
	s_nop 4
	v_max_f32_e32 v64, v49, v51
	v_max3_f32 v67, v48, v50, v52
	v_max3_f32 v64, v64, v53, v55
	v_max3_f32 v67, v67, v54, v56
	v_max3_f32 v64, v64, v57, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[140:143], v[76:79], v[16:31]
	v_max3_f32 v67, v67, v58, v60
	v_max3_f32 v64, v64, v61, v63
	v_max3_f32 v67, v67, v62, v32
	v_max3_f32 v64, v64, v33, v35
	v_max3_f32 v67, v67, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[148:151], v[114:117], v[16:31]
	v_max3_f32 v64, v64, v37, v39
	v_max3_f32 v67, v67, v38, v40
	v_max3_f32 v64, v64, v41, v43
	v_max3_f32 v67, v67, v42, v44
	v_max3_f32 v64, v64, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[156:159], v[118:121], v[16:31]
	v_max3_f32 v64, v67, v46, v64
	v_mov_b32_e32 v67, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v67 bound_ctrl:1
	v_max3_f32 v70, v105, v64, v67
	v_sub_f32_e32 v64, v105, v70
	v_sub_f32_e32 v141, v47, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[136:139], v[72:75], v[0:15]
	v_sub_f32_e32 v48, v48, v70
	v_sub_f32_e32 v49, v49, v70
	v_sub_f32_e32 v50, v50, v70
	v_sub_f32_e32 v51, v51, v70
	v_sub_f32_e32 v52, v52, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[144:147], v[76:79], v[0:15]
	v_sub_f32_e32 v53, v53, v70
	v_sub_f32_e32 v54, v54, v70
	v_sub_f32_e32 v55, v55, v70
	v_sub_f32_e32 v56, v56, v70
	v_sub_f32_e32 v57, v57, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[152:155], v[114:117], v[0:15]
	v_sub_f32_e32 v58, v58, v70
	v_sub_f32_e32 v59, v59, v70
	v_sub_f32_e32 v60, v60, v70
	v_sub_f32_e32 v61, v61, v70
	v_sub_f32_e32 v62, v62, v70
	v_sub_f32_e32 v117, v46, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[160:163], v[118:121], v[0:15]
	v_sub_f32_e32 v63, v63, v70
	v_sub_f32_e32 v138, v32, v70
	v_sub_f32_e32 v139, v33, v70
	v_sub_f32_e32 v140, v34, v70
	v_sub_f32_e32 v135, v35, v70
	v_sub_f32_e32 v136, v36, v70
	v_sub_f32_e32 v137, v37, v70
	v_sub_f32_e32 v121, v38, v70
	v_sub_f32_e32 v122, v39, v70
	v_sub_f32_e32 v123, v40, v70
	v_sub_f32_e32 v118, v41, v70
	v_sub_f32_e32 v119, v42, v70
	v_sub_f32_e32 v120, v43, v70
	v_sub_f32_e32 v115, v44, v70
	v_sub_f32_e32 v116, v45, v70
	v_exp_f32_e32 v64, v64
	v_exp_f32_e32 v67, v48
	v_exp_f32_e32 v68, v49
	v_exp_f32_e32 v69, v50
	v_exp_f32_e32 v71, v51
	v_exp_f32_e32 v72, v52
	v_exp_f32_e32 v73, v53
	v_exp_f32_e32 v74, v54
	v_exp_f32_e32 v75, v55
	v_exp_f32_e32 v76, v56
	v_exp_f32_e32 v77, v57
	v_exp_f32_e32 v78, v58
	v_exp_f32_e32 v79, v59
	v_exp_f32_e32 v105, v60
	v_exp_f32_e32 v106, v61
	v_exp_f32_e32 v107, v62
	v_exp_f32_e32 v114, v63
	v_pk_mul_f32 v[30:31], v[64:65], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[64:65], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[64:65], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[64:65], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[64:65], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[64:65], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[64:65], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[64:65], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[64:65], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[64:65], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[64:65], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[64:65], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[64:65], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[64:65], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[64:65], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[64:65], v[0:1] op_sel_hi:[0,1]
	s_barrier
	s_mulk_i32 s5, 0x380
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s27
	;;#ASMEND
.LBB0_41:
	v_readfirstlane_b32 s40, v84
	v_readfirstlane_b32 s41, v85
	v_readfirstlane_b32 s42, v86
	v_readfirstlane_b32 s43, v87
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[84:85]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[86:87]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v128, s[40:43], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_41
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[84:87], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v133 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v134 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v134 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v134 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v134 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v128, v138
	v_exp_f32_e32 v133, v139
	v_exp_f32_e32 v134, v140
	v_exp_f32_e32 v135, v135
	v_exp_f32_e32 v136, v136
	v_exp_f32_e32 v137, v137
	v_exp_f32_e32 v121, v121
	v_exp_f32_e32 v122, v122
	v_exp_f32_e32 v123, v123
	v_exp_f32_e32 v118, v118
	v_exp_f32_e32 v119, v119
	v_exp_f32_e32 v120, v120
	v_mov_b64_e32 v[46:47], s[22:23]
	v_mov_b64_e32 v[44:45], s[20:21]
	v_mov_b64_e32 v[42:43], s[18:19]
	v_mov_b64_e32 v[40:41], s[16:17]
	v_mov_b64_e32 v[38:39], s[14:15]
	v_mov_b64_e32 v[36:37], s[12:13]
	v_mov_b64_e32 v[34:35], s[10:11]
	v_mov_b64_e32 v[32:33], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[84:87], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[146:149], v[96:99], v[32:47]
	v_exp_f32_e32 v96, v115
	v_exp_f32_e32 v97, v116
	v_exp_f32_e32 v98, v117
	v_mfma_f32_32x32x16_bf16 v[48:63], v[154:157], v[92:95], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[162:165], v[92:95], v[32:47]
	v_exp_f32_e32 v92, v141
	v_mfma_f32_32x32x16_bf16 v[48:63], v[142:145], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[158:161], v[88:91], v[48:63]
	v_add_f32_e32 v84, v68, v67
	v_add_f32_e32 v84, v84, v69
	v_add_f32_e32 v84, v84, v71
	v_add_f32_e32 v84, v84, v72
	v_add_f32_e32 v84, v84, v73
	v_add_f32_e32 v84, v84, v74
	v_add_f32_e32 v84, v84, v75
	v_add_f32_e32 v84, v84, v76
	v_add_f32_e32 v84, v84, v77
	v_add_f32_e32 v84, v84, v78
	v_add_f32_e32 v84, v84, v79
	v_add_f32_e32 v84, v84, v105
	v_add_f32_e32 v84, v84, v106
	v_add_f32_e32 v84, v84, v107
	v_add_f32_e32 v84, v84, v114
	v_add_f32_e32 v84, v84, v128
	v_add_f32_e32 v84, v84, v133
	v_add_f32_e32 v84, v84, v134
	v_mfma_f32_32x32x16_bf16 v[32:47], v[150:153], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[166:169], v[88:91], v[32:47]
	v_add_f32_e32 v91, v84, v135
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v84, v67, v68
	;;#ASMEND
	v_add_f32_e32 v67, v91, v136
	v_add_f32_e32 v67, v67, v137
	v_add_f32_e32 v67, v67, v121
	v_add_f32_e32 v67, v67, v122
	v_add_f32_e32 v67, v67, v123
	v_add_f32_e32 v67, v67, v118
	v_add_f32_e32 v67, v67, v119
	v_add_f32_e32 v67, v67, v120
	v_add_f32_e32 v67, v67, v96
	v_add_f32_e32 v67, v67, v97
	v_add_f32_e32 v67, v67, v98
	v_add_f32_e32 v68, v67, v92
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v85, v69, v71
	;;#ASMEND
	v_mov_b32_e32 v69, v68
	s_nop 1
	v_permlane32_swap_b32_e64 v68, v69 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v86, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v87, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v105, v106
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v107, v114
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v128, v133
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v134, v135
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v136, v137
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v121, v122
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v88, v123, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v89, v119, v120
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v90, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v91, v98, v92
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[92:93], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v132 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v132 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v132 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v132 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[94:95], v132 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v132 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v132 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v132 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v132 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v132 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v132 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v132 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[16:31], v[92:95], v[84:87], v[16:31]
	v_max_f32_e32 v67, v49, v51
	v_max3_f32 v71, v48, v50, v52
	v_max3_f32 v67, v67, v53, v55
	v_max3_f32 v71, v71, v54, v56
	v_max3_f32 v67, v67, v57, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[72:75], v[16:31]
	v_max3_f32 v71, v71, v58, v60
	v_max3_f32 v67, v67, v61, v63
	v_max3_f32 v71, v71, v62, v32
	v_max3_f32 v67, v67, v33, v35
	v_max3_f32 v71, v71, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[118:121], v[76:79], v[16:31]
	v_max3_f32 v67, v67, v37, v39
	v_max3_f32 v71, v71, v38, v40
	v_max3_f32 v67, v67, v41, v43
	v_max3_f32 v71, v71, v42, v44
	v_max3_f32 v67, v67, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[88:91], v[16:31]
	v_max3_f32 v67, v71, v46, v67
	v_mov_b32_e32 v71, v67
	s_nop 1
	v_permlane32_swap_b32_e64 v67, v71 bound_ctrl:1
	v_max3_f32 v67, v70, v67, v71
	v_sub_f32_e32 v70, v70, v67
	v_sub_f32_e32 v46, v46, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[84:87], v[0:15]
	v_sub_f32_e32 v48, v48, v67
	v_sub_f32_e32 v49, v49, v67
	v_sub_f32_e32 v50, v50, v67
	v_sub_f32_e32 v51, v51, v67
	v_sub_f32_e32 v52, v52, v67
	v_sub_f32_e32 v47, v47, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[114:117], v[72:75], v[0:15]
	v_sub_f32_e32 v53, v53, v67
	v_sub_f32_e32 v54, v54, v67
	v_sub_f32_e32 v55, v55, v67
	v_sub_f32_e32 v56, v56, v67
	v_sub_f32_e32 v57, v57, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[134:137], v[76:79], v[0:15]
	v_sub_f32_e32 v58, v58, v67
	v_sub_f32_e32 v59, v59, v67
	v_sub_f32_e32 v60, v60, v67
	v_sub_f32_e32 v61, v61, v67
	v_sub_f32_e32 v62, v62, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[142:145], v[88:91], v[0:15]
	v_sub_f32_e32 v63, v63, v67
	v_sub_f32_e32 v71, v32, v67
	v_sub_f32_e32 v33, v33, v67
	v_sub_f32_e32 v34, v34, v67
	v_sub_f32_e32 v35, v35, v67
	v_sub_f32_e32 v36, v36, v67
	v_sub_f32_e32 v37, v37, v67
	v_sub_f32_e32 v38, v38, v67
	v_sub_f32_e32 v39, v39, v67
	v_sub_f32_e32 v40, v40, v67
	v_sub_f32_e32 v41, v41, v67
	v_sub_f32_e32 v42, v42, v67
	v_sub_f32_e32 v43, v43, v67
	v_sub_f32_e32 v44, v44, v67
	v_sub_f32_e32 v45, v45, v67
	v_exp_f32_e32 v32, v70
	v_exp_f32_e32 v48, v48
	v_exp_f32_e32 v49, v49
	v_exp_f32_e32 v50, v50
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v52, v52
	v_exp_f32_e32 v53, v53
	v_exp_f32_e32 v54, v54
	v_exp_f32_e32 v55, v55
	v_exp_f32_e32 v56, v56
	v_exp_f32_e32 v57, v57
	v_exp_f32_e32 v58, v58
	v_exp_f32_e32 v59, v59
	v_exp_f32_e32 v60, v60
	v_exp_f32_e32 v61, v61
	v_exp_f32_e32 v62, v62
	v_exp_f32_e32 v63, v63
	v_exp_f32_e32 v70, v71
	v_exp_f32_e32 v71, v33
	v_add_f32_e32 v33, v49, v48
	v_add_f32_e32 v33, v33, v50
	v_add_f32_e32 v33, v33, v51
	v_add_f32_e32 v33, v33, v52
	v_add_f32_e32 v33, v33, v53
	v_add_f32_e32 v33, v33, v54
	v_add_f32_e32 v33, v33, v55
	v_add_f32_e32 v33, v33, v56
	v_add_f32_e32 v33, v33, v57
	v_add_f32_e32 v33, v33, v58
	v_add_f32_e32 v33, v33, v59
	v_add_f32_e32 v33, v33, v60
	v_add_f32_e32 v33, v33, v61
	v_exp_f32_e32 v72, v34
	v_add_f32_e32 v33, v33, v62
	v_exp_f32_e32 v35, v35
	v_add_f32_e32 v33, v33, v63
	v_exp_f32_e32 v73, v36
	v_add_f32_e32 v33, v33, v70
	v_exp_f32_e32 v74, v37
	v_add_f32_e32 v33, v33, v71
	v_exp_f32_e32 v75, v38
	v_add_f32_e32 v33, v33, v72
	v_exp_f32_e32 v76, v39
	v_add_f32_e32 v33, v33, v35
	v_exp_f32_e32 v77, v40
	v_add_f32_e32 v33, v33, v73
	v_exp_f32_e32 v78, v41
	v_add_f32_e32 v33, v33, v74
	v_exp_f32_e32 v79, v42
	v_add_f32_e32 v33, v33, v75
	v_exp_f32_e32 v84, v43
	v_add_f32_e32 v33, v33, v76
	v_exp_f32_e32 v85, v44
	v_add_f32_e32 v33, v33, v77
	v_exp_f32_e32 v86, v45
	v_add_f32_e32 v33, v33, v78
	v_exp_f32_e32 v87, v46
	v_add_f32_e32 v33, v33, v79
	v_exp_f32_e32 v88, v47
	v_add_f32_e32 v33, v33, v84
	v_add_f32_e32 v33, v33, v85
	v_add_f32_e32 v33, v33, v86
	v_add_f32_e32 v33, v33, v87
	v_add_f32_e32 v33, v33, v88
	v_mov_b32_e32 v34, v33
	s_nop 1
	v_permlane32_swap_b32_e64 v33, v34 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v36, v48, v49
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v37, v50, v51
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v38, v52, v53
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v39, v54, v55
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v40, v56, v57
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v41, v58, v59
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v42, v60, v61
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v43, v62, v63
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v44, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v45, v72, v35
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v46, v73, v74
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v47, v75, v76
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v48, v77, v78
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v49, v79, v84
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v50, v85, v86
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v51, v87, v88
	;;#ASMEND
	v_pk_mul_f32 v[30:31], v[32:33], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[32:33], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[32:33], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[32:33], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[32:33], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[32:33], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[32:33], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[32:33], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[32:33], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[32:33], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[32:33], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[32:33], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[32:33], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[32:33], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[32:33], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[32:33], v[0:1] op_sel_hi:[0,1]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[52:53], v131 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[56:57], v131 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[60:61], v131 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[70:71], v131 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[74:75], v131 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[84:85], v131 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[88:89], v131 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[92:93], v131 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[54:55], v131 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[58:59], v131 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[62:63], v131 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[72:73], v131 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[76:77], v131 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[86:87], v131 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[90:91], v131 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[94:95], v131 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[16:31], v[52:55], v[36:39], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[56:59], v[36:39], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[60:63], v[40:43], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[70:73], v[40:43], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[74:77], v[44:47], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[84:87], v[44:47], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[88:91], v[48:51], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[92:95], v[48:51], v[0:15]
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_44
	s_barrier
.LBB0_44:
	s_or_b64 exec, exec, s[0:1]
	v_add_f32_e32 v35, v129, v130
	v_fmac_f32_e32 v81, v80, v35
	v_add_f32_e32 v35, v81, v83
	v_add_f32_e32 v35, v35, v108
	v_add_f32_e32 v35, v35, v109
	v_fmac_f32_e32 v110, v82, v35
	v_add_f32_e32 v35, v110, v111
	v_add_f32_e32 v35, v35, v112
	v_add_f32_e32 v35, v35, v113
	v_fmac_f32_e32 v65, v104, v35
	v_add_f32_e32 v35, v65, v66
	v_fmac_f32_e32 v68, v64, v35
	v_add_f32_e32 v35, v68, v69
	v_fmac_f32_e32 v33, v32, v35
	v_add_f32_e32 v32, v33, v34
	v_rcp_f32_e32 v44, v32
	v_mov_b32_e32 v42, s24
	v_mov_b32_e32 v43, s25
	s_mov_b64 s[6:7], exec
	v_mul_f32_e32 v38, v0, v44
	v_mov_b32_e32 v0, s4
	v_mul_f32_e32 v39, v1, v44
	v_mad_i64_i32 v[0:1], s[0:1], s28, v0, v[124:125]
	v_mul_f32_e32 v40, v2, v44
	v_mul_f32_e32 v41, v3, v44
	s_bfe_i64 s[0:1], s[30:31], 0x200000
	v_mov_b64_e32 v[2:3], s[2:3]
	v_mul_f32_e32 v33, v8, v44
	v_mul_f32_e32 v8, v18, v44
	v_mul_f32_e32 v45, v19, v44
	v_mul_f32_e32 v18, v24, v44
	v_mul_f32_e32 v19, v25, v44
	v_mul_lo_u32 v24, v1, s30
	v_mul_lo_u32 v25, v0, s1
	v_mad_u64_u32 v[0:1], s[0:1], v0, s30, v[2:3]
	v_add3_u32 v1, v24, v1, v25
	s_bfe_i64 s[0:1], s[46:47], 0x200000
	v_mul_lo_u32 v2, v1, s46
	v_mul_lo_u32 v3, v0, s1
	v_mad_u64_u32 v[0:1], s[0:1], v0, s46, 0
	s_mul_i32 s0, s30, s46
	s_mul_i32 s1, s26, s28
	v_mul_f32_e32 v34, v4, v44
	v_mul_f32_e32 v35, v5, v44
	v_mul_f32_e32 v4, v16, v44
	v_mul_f32_e32 v5, v17, v44
	s_mul_i32 s1, s0, s1
	v_add3_u32 v1, v1, v3, v2
	s_lshl_b32 s1, s1, 1
	v_mul_lo_u32 v24, v126, s0
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v4, v5
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v8, v45
	;;#ASMEND
	v_mul_f32_e32 v15, v15, v44
	v_and_b32_e32 v8, 0xffff0000, v5
	v_mul_f32_e32 v14, v14, v44
	v_mul_f32_e32 v36, v6, v44
	v_mul_f32_e32 v37, v7, v44
	v_mul_f32_e32 v9, v9, v44
	v_mul_f32_e32 v10, v10, v44
	v_mul_f32_e32 v11, v11, v44
	v_mul_f32_e32 v6, v12, v44
	v_mul_f32_e32 v7, v13, v44
	v_mul_f32_e32 v12, v31, v44
	v_mul_f32_e32 v13, v30, v44
	v_mul_f32_e32 v30, v20, v44
	v_mul_f32_e32 v31, v21, v44
	v_mul_f32_e32 v22, v22, v44
	v_mul_f32_e32 v23, v23, v44
	v_mul_f32_e32 v20, v26, v44
	v_mul_f32_e32 v21, v27, v44
	v_mul_f32_e32 v16, v28, v44
	v_mul_f32_e32 v17, v29, v44
	v_lshl_add_u64 v[0:1], v[0:1], 1, v[42:43]
	v_mov_b32_e32 v2, s1
	v_mov_b32_e32 v3, 0x20000
	v_or_b32_sdwa v5, v8, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_add_lshl_u32 v8, v24, v127, 1
.LBB0_45:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_45
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v30, v31
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v22, v23
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v22, 0xffff0000, v5
	v_or_b32_sdwa v5, v22, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_47:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:16
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_47
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v18, v19
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v20, v21
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v18, 0xffff0000, v5
	v_or_b32_sdwa v5, v18, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_49:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_49
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v16, v17
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v13, v12
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v12, 0xffff0000, v5
	v_or_b32_sdwa v5, v12, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_51:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:48
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_51
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v38, v39
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v40, v41
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v12, 0xffff0000, v5
	v_or_b32_sdwa v5, v12, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_53:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_53
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v34, v35
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v36, v37
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v12, 0xffff0000, v5
	v_or_b32_sdwa v5, v12, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_55:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:80
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_55
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v33, v9
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v10, v11
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v9, 0xffff0000, v5
	v_or_b32_sdwa v5, v9, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_57:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_57
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v6, v7
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v14, v15
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v6, 0xffff0000, v5
	v_or_b32_sdwa v5, v6, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_59:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v8, s[8:11], 0 offen offset:112
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_59
	s_mov_b64 exec, s[6:7]
	s_mov_b32 s0, 0x800000
	s_mul_i32 s1, s36, s4
	v_cmp_gt_f32_e32 vcc, s0, v32
	s_mul_hi_i32 s0, s36, s4
	s_add_u32 s2, s1, s2
	s_addc_u32 s3, s0, s3
	s_bfe_i64 s[0:1], s[38:39], 0x200000
	s_mul_i32 s0, s2, s1
	s_mul_hi_u32 s1, s2, s38
	s_add_i32 s0, s1, s0
	s_mul_i32 s3, s3, s38
	s_add_i32 s3, s0, s3
	s_mul_i32 s2, s2, s38
	s_bfe_i64 s[0:1], s[44:45], 0x200000
	v_cndmask_b32_e64 v0, 0, 32, vcc
	s_mul_i32 s0, s2, s1
	s_mul_hi_u32 s1, s2, s44
	v_ldexp_f32 v0, v32, v0
	s_add_i32 s0, s1, s0
	s_mul_i32 s3, s3, s44
	v_log_f32_e32 v0, v0
	s_add_i32 s1, s0, s3
	s_mul_i32 s0, s2, s44
	s_lshl_b64 s[0:1], s[0:1], 2
	v_mov_b32_e32 v1, 0xc1b17218
	s_add_u32 s0, s34, s0
	v_cndmask_b32_e32 v4, 0, v1, vcc
	s_addc_u32 s1, s35, s1
	v_fmac_f32_e32 v4, 0x3f317218, v0
	v_lshl_add_u64 v[0:1], v[124:125], 2, s[0:1]
	v_lshlrev_b32_e32 v2, 2, v126
	v_mov_b32_e32 v3, 0
	v_fmac_f32_e32 v4, 0x3f317218, v67
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	global_store_dword v[0:1], v4, off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z10attend_kerILi64EEv12attn_globalsIXT_EE
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 248
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
		.amdhsa_next_free_vgpr 178
		.amdhsa_next_free_sgpr 56
		.amdhsa_accum_offset 180
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
	.section	.text._Z10attend_kerILi64EEv12attn_globalsIXT_EE,"axG",@progbits,_Z10attend_kerILi64EEv12attn_globalsIXT_EE,comdat
.Lfunc_end0:
	.size	_Z10attend_kerILi64EEv12attn_globalsIXT_EE, .Lfunc_end0-_Z10attend_kerILi64EEv12attn_globalsIXT_EE

	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.num_vgpr, 178
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.num_agpr, 0
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.numbered_sgpr, 56
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.private_seg_size, 0
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.uses_vcc, 1
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.uses_flat_scratch, 0
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.has_dyn_sized_stack, 0
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.has_recursion, 0
	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_8d9b3fbc3ca616bf,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_8d9b3fbc3ca616bf
__hip_cuid_8d9b3fbc3ca616bf:
	.byte	0
	.size	__hip_cuid_8d9b3fbc3ca616bf, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_8d9b3fbc3ca616bf
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           248
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 248
    .max_flat_workgroup_size: 512
    .name:           _Z10attend_kerILi64EEv12attn_globalsIXT_EE
    .private_segment_fixed_size: 0
    .sgpr_count:     62
    .sgpr_spill_count: 0
    .symbol:         _Z10attend_kerILi64EEv12attn_globalsIXT_EE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     178
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
