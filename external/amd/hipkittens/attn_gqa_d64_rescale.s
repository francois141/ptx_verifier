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
	v_mov_b32_e32 v80, s0
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
	v_add_lshl_u32 v131, v5, v4, 1
	v_lshrrev_b32_e32 v65, 2, v0
	v_and_b32_e32 v5, 56, v64
	s_mul_i32 s8, s22, s51
	v_lshlrev_b32_e32 v4, 3, v0
	v_and_or_b32 v5, v65, 7, v5
	v_mov_b32_e32 v103, 0x110000
	v_and_or_b32 v4, v4, 24, v6
	v_mul_lo_u32 v5, v5, s8
	s_mov_b32 s0, s37
	s_mov_b32 s53, s9
	s_mov_b32 s54, s18
	s_mov_b32 s49, s9
	s_mov_b32 s50, s22
	v_alignbit_b32 v102, s23, 0, 22
	v_mov_b32_e32 v100, s16
	v_mov_b32_e32 v101, s17
	v_alignbit_b32 v82, s8, 0, 22
	v_mov_b32_e32 v81, s1
	v_mov_b32_e32 v83, v103
	v_add_lshl_u32 v124, v4, v5, 1
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
	v_readfirstlane_b32 s16, v100
	v_readfirstlane_b32 s17, v101
	v_readfirstlane_b32 s18, v102
	v_readfirstlane_b32 s19, v103
	v_cmp_eq_u64_e32 vcc, s[16:17], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[18:19], v[102:103]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[16:19], s9 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[20:21]
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_lshl_b32 s0, s5, 8
	v_lshl_or_b32 v120, v1, 5, s0
	v_ashrrev_i32_e32 v121, 31, v120
	v_mov_b32_e32 v1, s4
	v_mad_i64_i32 v[4:5], s[0:1], s12, v1, v[120:121]
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
	v_and_b32_e32 v122, 31, v0
	s_mul_i32 s1, s0, s1
	v_add3_u32 v5, v5, v6, v1
	v_and_b32_e32 v1, 8, v65
	s_lshl_b32 s1, s1, 1
	v_mul_lo_u32 v6, v122, s0
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
	v_cvt_pk_bf16_f32 v92, v9, v14
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v93, v15, v16
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v94, v17, v18
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v95, v19, v20
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v88, v21, v10
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v89, v22, v11
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v90, v23, v12
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v91, v24, v13
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v25, v26
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v27, v28
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v29, v30
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v31, v32
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v84, v1, v2
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v85, v3, v4
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v86, v5, v6
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v87, v7, v8
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
	v_readfirstlane_b32 s8, v100
	v_readfirstlane_b32 s9, v101
	v_readfirstlane_b32 s10, v102
	v_readfirstlane_b32 s11, v103
	v_cmp_eq_u64_e32 vcc, s[8:9], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[102:103]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[8:11], s5 offen lds
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
	v_readfirstlane_b32 s8, v80
	v_readfirstlane_b32 s9, v81
	v_readfirstlane_b32 s10, v82
	v_readfirstlane_b32 s11, v83
	v_cmp_eq_u64_e32 vcc, s[8:9], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[82:83]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[8:11], s5 offen lds
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
	v_add_u32_e32 v133, s13, v1
	;;#ASMSTART
	ds_read_b128 v[38:41], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[46:49], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[50:53], v133 offset:0x1800

	;;#ASMEND
	v_bitop3_b32 v36, v3, v4, 32 bitop3:0x36
	v_add_u32_e32 v132, s13, v36
	;;#ASMSTART
	ds_read_b128 v[54:57], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[58:61], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[68:71], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[72:75], v132 offset:0x1800

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
	v_mfma_f32_32x32x16_bf16 v[18:33], v[38:41], v[92:95], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[46:49], v[92:95], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[54:57], v[88:91], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[68:71], v[88:91], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[42:45], v[96:99], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[50:53], v[96:99], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[58:61], v[84:87], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[72:75], v[84:87], v[2:17]
	s_nop 7
	s_nop 2
	v_max_f32_e32 v34, v19, v21
	v_max3_f32 v35, v18, v20, v22
	v_max3_f32 v34, v34, v23, v25
	v_max3_f32 v35, v35, v24, v26
	v_max3_f32 v34, v34, v27, v29
	v_max3_f32 v35, v35, v28, v30
	v_max3_f32 v34, v34, v31, v33
	v_max3_f32 v35, v35, v32, v2
	v_max3_f32 v34, v34, v3, v5
	v_max3_f32 v35, v35, v4, v6
	v_max3_f32 v34, v34, v7, v9
	v_max3_f32 v35, v35, v8, v10
	v_max3_f32 v34, v34, v11, v13
	v_max3_f32 v35, v35, v12, v14
	v_max3_f32 v34, v34, v15, v17
	v_max3_f32 v34, v35, v16, v34
	v_mov_b32_e32 v35, v34
	s_nop 1
	v_permlane32_swap_b32_e64 v34, v35 bound_ctrl:1
	s_movk_i32 s0, 0x100
	v_cmp_gt_u32_e32 vcc, s0, v0
	s_movk_i32 s0, 0xff
	v_cmp_lt_u32_e64 s[0:1], s0, v0
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB0_16
	s_barrier
.LBB0_16:
	s_or_b64 exec, exec, s[6:7]
	v_max_f32_e32 v134, v34, v35
	v_sub_f32_e32 v0, v18, v134
	v_sub_f32_e32 v18, v19, v134
	v_sub_f32_e32 v19, v20, v134
	v_sub_f32_e32 v20, v21, v134
	v_sub_f32_e32 v21, v22, v134
	v_sub_f32_e32 v22, v23, v134
	v_sub_f32_e32 v23, v24, v134
	v_sub_f32_e32 v24, v25, v134
	v_sub_f32_e32 v25, v26, v134
	v_sub_f32_e32 v26, v27, v134
	v_sub_f32_e32 v27, v28, v134
	v_sub_f32_e32 v28, v29, v134
	v_sub_f32_e32 v29, v30, v134
	v_sub_f32_e32 v30, v31, v134
	v_sub_f32_e32 v31, v32, v134
	v_sub_f32_e32 v32, v33, v134
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
	v_exp_f32_e32 v108, v29
	v_exp_f32_e32 v109, v30
	v_exp_f32_e32 v110, v31
	v_exp_f32_e32 v111, v32
	v_sub_f32_e32 v118, v2, v134
	v_sub_f32_e32 v119, v3, v134
	v_sub_f32_e32 v123, v4, v134
	v_sub_f32_e32 v115, v5, v134
	v_sub_f32_e32 v116, v6, v134
	v_sub_f32_e32 v117, v7, v134
	v_sub_f32_e32 v112, v8, v134
	v_sub_f32_e32 v113, v9, v134
	v_sub_f32_e32 v114, v10, v134
	v_sub_f32_e32 v105, v11, v134
	v_sub_f32_e32 v106, v12, v134
	v_sub_f32_e32 v107, v13, v134
	v_sub_f32_e32 v104, v14, v134
	v_sub_f32_e32 v126, v15, v134
	v_sub_f32_e32 v127, v16, v134
	v_sub_f32_e32 v125, v17, v134
	v_add_u32_e32 v129, s52, v1
	;;#ASMSTART
	ds_read_b128 v[44:47], v129 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[32:35], v129 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[24:27], v129 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[20:23], v129 offset:0x1800

	;;#ASMEND
	v_add_u32_e32 v130, s52, v36
	;;#ASMSTART
	ds_read_b128 v[40:43], v130 offset:0

	;;#ASMEND
	v_mov_b32_e32 v0, s53
	;;#ASMSTART
	ds_read_b128 v[36:39], v130 offset:0x800

	;;#ASMEND
	v_alignbit_b32 v0, s54, v0, 25
	;;#ASMSTART
	ds_read_b128 v[28:31], v130 offset:0x1000

	;;#ASMEND
	v_mul_lo_u32 v0, s42, v0
	;;#ASMSTART
	ds_read_b128 v[16:19], v130 offset:0x1800

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
	v_readfirstlane_b32 s8, v100
	v_readfirstlane_b32 s9, v101
	v_readfirstlane_b32 s10, v102
	v_readfirstlane_b32 s11, v103
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[8:11], s5 offen lds
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
	v_readfirstlane_b32 s8, v80
	v_readfirstlane_b32 s9, v81
	v_readfirstlane_b32 s10, v82
	v_readfirstlane_b32 s11, v83
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[8:11], s5 offen lds
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
	v_exp_f32_e32 v135, v118
	v_exp_f32_e32 v136, v119
	v_exp_f32_e32 v137, v123
	v_exp_f32_e32 v115, v115
	v_exp_f32_e32 v138, v116
	v_exp_f32_e32 v139, v117
	v_exp_f32_e32 v140, v112
	v_exp_f32_e32 v141, v113
	v_exp_f32_e32 v142, v114
	v_exp_f32_e32 v143, v105
	v_exp_f32_e32 v144, v106
	v_exp_f32_e32 v145, v107
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
	v_mfma_f32_32x32x16_bf16 v[48:63], v[44:47], v[92:95], v[0:15]
	s_barrier
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v116, v68, v69
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v117, v70, v71
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v118, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v119, v74, v75
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[48:63], v[40:43], v[88:91], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[32:35], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[36:39], v[84:87], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[24:27], v[92:95], v[0:15]
	s_nop 6
	v_exp_f32_e32 v0, v104
	v_exp_f32_e32 v1, v126
	v_exp_f32_e32 v2, v127
	v_exp_f32_e32 v3, v125
	v_and_b32_e32 v123, 4, v64
	v_and_or_b32 v5, v66, 12, v67
	v_and_or_b32 v4, v65, 3, v123
	v_lshlrev_b32_e32 v5, 1, v5
	v_lshl_or_b32 v4, v4, 6, v5
	v_add_u32_e32 v128, s41, v4
	v_add_u32_e32 v127, s43, v4
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
	v_add_f32_e32 v4, v4, v108
	v_add_f32_e32 v4, v4, v109
	v_add_f32_e32 v4, v4, v110
	v_add_f32_e32 v4, v4, v111
	v_add_f32_e32 v4, v4, v135
	v_add_f32_e32 v4, v4, v136
	v_add_f32_e32 v4, v4, v137
	v_add_f32_e32 v4, v4, v115
	v_add_f32_e32 v4, v4, v138
	v_add_f32_e32 v4, v4, v139
	v_add_f32_e32 v4, v4, v140
	v_add_f32_e32 v4, v4, v141
	v_add_f32_e32 v4, v4, v142
	v_add_f32_e32 v4, v4, v143
	v_add_f32_e32 v4, v4, v144
	v_add_f32_e32 v4, v4, v145
	v_add_f32_e32 v4, v4, v0
	v_add_f32_e32 v4, v4, v1
	v_add_f32_e32 v4, v4, v2
	v_add_f32_e32 v125, v4, v3
	v_mov_b32_e32 v126, v125
	s_nop 1
	v_permlane32_swap_b32_e64 v125, v126 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[28:31], v[88:91], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v112, v135, v136
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v113, v137, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v114, v138, v139
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[20:23], v[96:99], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v115, v140, v141
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v142, v143
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v144, v145
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v0, v1
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v2, v3
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[16:19], v[84:87], v[32:47]
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
	v_readfirstlane_b32 s40, v100
	v_readfirstlane_b32 s41, v101
	v_readfirstlane_b32 s42, v102
	v_readfirstlane_b32 s43, v103
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_21
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[0:1], v128 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v128 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v128 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v128 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v128 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v128 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v128 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v128 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[2:3], v128 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v128 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v128 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v128 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v128 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v128 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v128 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v128 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[0:3], v[116:119], v[64:79]
	v_max_f32_e32 v0, v49, v51
	v_max3_f32 v1, v48, v50, v52
	v_max3_f32 v0, v0, v53, v55
	v_max3_f32 v135, v1, v54, v56
	v_max3_f32 v164, v0, v57, v59
	v_mfma_f32_32x32x16_bf16 v[0:15], v[136:139], v[116:119], v[64:79]
	s_nop 6
	v_max3_f32 v64, v135, v58, v60
	v_max3_f32 v65, v164, v61, v63
	v_max3_f32 v64, v64, v62, v32
	v_max3_f32 v65, v65, v33, v35
	v_max3_f32 v64, v64, v34, v36
	v_max3_f32 v65, v65, v37, v39
	v_max3_f32 v64, v64, v38, v40
	v_max3_f32 v65, v65, v41, v43
	v_max3_f32 v64, v64, v42, v44
	v_max3_f32 v65, v65, v45, v47
	v_max3_f32 v64, v64, v46, v65
	v_mov_b32_e32 v65, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v65 bound_ctrl:1
	v_max3_f32 v117, v134, v64, v65
	v_sub_f32_e32 v52, v52, v117
	v_sub_f32_e32 v53, v53, v117
	v_sub_f32_e32 v64, v134, v117
	v_exp_f32_e32 v116, v64
	v_sub_f32_e32 v58, v58, v117
	v_sub_f32_e32 v63, v63, v117
	v_sub_f32_e32 v59, v59, v117
	v_pk_mul_f32 v[30:31], v[116:117], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[116:117], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[116:117], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[116:117], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[116:117], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[116:117], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[116:117], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[116:117], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[116:117], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[116:117], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[116:117], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[116:117], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[116:117], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[116:117], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[116:117], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[116:117], v[0:1] op_sel_hi:[0,1]
	v_sub_f32_e32 v48, v48, v117
	v_sub_f32_e32 v49, v49, v117
	v_sub_f32_e32 v50, v50, v117
	v_sub_f32_e32 v51, v51, v117
	v_mfma_f32_32x32x16_bf16 v[16:31], v[140:143], v[104:107], v[16:31]
	v_sub_f32_e32 v54, v54, v117
	v_sub_f32_e32 v55, v55, v117
	v_sub_f32_e32 v56, v56, v117
	v_sub_f32_e32 v57, v57, v117
	v_sub_f32_e32 v60, v60, v117
	v_sub_f32_e32 v61, v61, v117
	v_sub_f32_e32 v62, v62, v117
	v_mfma_f32_32x32x16_bf16 v[16:31], v[148:151], v[112:115], v[16:31]
	v_sub_f32_e32 v143, v32, v117
	v_sub_f32_e32 v138, v35, v117
	v_sub_f32_e32 v139, v36, v117
	v_sub_f32_e32 v140, v37, v117
	v_sub_f32_e32 v35, v38, v117
	v_sub_f32_e32 v36, v39, v117
	v_sub_f32_e32 v37, v40, v117
	v_mfma_f32_32x32x16_bf16 v[16:31], v[156:159], v[108:111], v[16:31]
	v_exp_f32_e32 v118, v63
	v_exp_f32_e32 v119, v58
	v_sub_f32_e32 v32, v41, v117
	v_sub_f32_e32 v141, v45, v117
	v_sub_f32_e32 v142, v46, v117
	v_sub_f32_e32 v137, v47, v117
	v_mfma_f32_32x32x16_bf16 v[0:15], v[144:147], v[104:107], v[0:15]
	v_exp_f32_e32 v134, v59
	v_exp_f32_e32 v135, v49
	v_exp_f32_e32 v136, v50
	v_sub_f32_e32 v144, v33, v117
	v_sub_f32_e32 v145, v34, v117
	v_sub_f32_e32 v33, v42, v117
	v_sub_f32_e32 v34, v43, v117
	v_mfma_f32_32x32x16_bf16 v[0:15], v[152:155], v[112:115], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[160:163], v[108:111], v[0:15]
	v_exp_f32_e32 v109, v52
	v_exp_f32_e32 v110, v53
	v_exp_f32_e32 v114, v56
	v_exp_f32_e32 v115, v48
	v_exp_f32_e32 v108, v51
	v_exp_f32_e32 v104, v60
	v_exp_f32_e32 v105, v61
	v_exp_f32_e32 v106, v62
	v_exp_f32_e32 v107, v57
	v_exp_f32_e32 v112, v54
	v_exp_f32_e32 v113, v55
	v_sub_f32_e32 v111, v44, v117
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_23
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v133 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v143, v143
	v_exp_f32_e32 v144, v144
	v_exp_f32_e32 v145, v145
	v_exp_f32_e32 v138, v138
	v_exp_f32_e32 v139, v139
	v_exp_f32_e32 v140, v140
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[92:95], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[154:157], v[88:91], v[48:63]
	v_exp_f32_e32 v154, v35
	v_exp_f32_e32 v155, v36
	v_exp_f32_e32 v156, v37
	v_exp_f32_e32 v157, v32
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[158:161], v[84:87], v[48:63]
	v_exp_f32_e32 v158, v33
	v_exp_f32_e32 v159, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[146:149], v[92:95], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v115, v135
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v136, v108
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v109, v110
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v114, v107
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v111
	v_exp_f32_e32 v111, v141
	v_exp_f32_e32 v141, v142
	v_exp_f32_e32 v137, v137
	v_add_f32_e32 v64, v135, v115
	v_add_f32_e32 v64, v64, v136
	v_add_f32_e32 v64, v64, v108
	v_add_f32_e32 v64, v64, v109
	v_add_f32_e32 v64, v64, v110
	v_add_f32_e32 v64, v64, v112
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v114
	v_add_f32_e32 v64, v64, v107
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v134
	v_add_f32_e32 v64, v64, v104
	v_add_f32_e32 v64, v64, v105
	v_add_f32_e32 v64, v64, v106
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v143
	v_add_f32_e32 v64, v64, v144
	v_add_f32_e32 v64, v64, v145
	v_add_f32_e32 v142, v64, v138
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v119, v134
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v104, v105
	;;#ASMEND
	v_add_f32_e32 v104, v142, v139
	v_add_f32_e32 v104, v104, v140
	v_add_f32_e32 v104, v104, v154
	v_add_f32_e32 v104, v104, v155
	v_add_f32_e32 v104, v104, v156
	v_add_f32_e32 v104, v104, v157
	v_add_f32_e32 v104, v104, v158
	v_add_f32_e32 v104, v104, v159
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v106, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v143, v144
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v145, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v154, v155
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v156, v157
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v158, v159
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v111
	;;#ASMEND
	v_add_f32_e32 v67, v104, v67
	v_add_f32_e32 v67, v67, v111
	v_add_f32_e32 v67, v67, v141
	v_add_f32_e32 v105, v67, v137
	v_mov_b32_e32 v107, v105
	s_nop 1
	v_permlane32_swap_b32_e64 v105, v107 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[162:165], v[88:91], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v141, v137
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[150:153], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[166:169], v[84:87], v[32:47]
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
	v_readfirstlane_b32 s40, v100
	v_readfirstlane_b32 s41, v101
	v_readfirstlane_b32 s42, v102
	v_readfirstlane_b32 s43, v103
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_25
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v127 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v127 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v127 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v127 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v127 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v127 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v127 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v127 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v127 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v127 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v127 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v127 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v127 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v127 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v127 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v127 offset:0x1e00

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
	v_max_f32_e32 v104, v49, v51
	v_max3_f32 v106, v48, v50, v52
	v_max3_f32 v104, v104, v53, v55
	v_max3_f32 v106, v106, v54, v56
	v_max3_f32 v104, v104, v57, v59
	v_mfma_f32_32x32x16_bf16 v[0:15], v[112:115], v[76:79], v[0:15]
	v_max3_f32 v76, v106, v58, v60
	v_max3_f32 v77, v104, v61, v63
	v_max3_f32 v76, v76, v62, v32
	v_max3_f32 v77, v77, v33, v35
	v_max3_f32 v76, v76, v34, v36
	v_max3_f32 v77, v77, v37, v39
	v_max3_f32 v76, v76, v38, v40
	v_max3_f32 v77, v77, v41, v43
	v_max3_f32 v76, v76, v42, v44
	v_max3_f32 v77, v77, v45, v47
	v_max3_f32 v76, v76, v46, v77
	v_mov_b32_e32 v77, v76
	s_nop 1
	v_permlane32_swap_b32_e64 v76, v77 bound_ctrl:1
	v_max3_f32 v106, v117, v76, v77
	v_sub_f32_e32 v76, v117, v106
	v_exp_f32_e32 v104, v76
	v_sub_f32_e32 v61, v61, v106
	v_sub_f32_e32 v62, v62, v106
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
	v_sub_f32_e32 v48, v48, v106
	v_sub_f32_e32 v49, v49, v106
	v_sub_f32_e32 v50, v50, v106
	v_sub_f32_e32 v51, v51, v106
	v_sub_f32_e32 v52, v52, v106
	v_sub_f32_e32 v53, v53, v106
	v_sub_f32_e32 v54, v54, v106
	v_sub_f32_e32 v55, v55, v106
	v_sub_f32_e32 v56, v56, v106
	v_sub_f32_e32 v57, v57, v106
	v_sub_f32_e32 v58, v58, v106
	v_sub_f32_e32 v59, v59, v106
	v_sub_f32_e32 v60, v60, v106
	v_sub_f32_e32 v63, v63, v106
	v_mfma_f32_32x32x16_bf16 v[16:31], v[134:137], v[72:75], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[68:71], v[16:31]
	v_sub_f32_e32 v142, v36, v106
	v_sub_f32_e32 v143, v37, v106
	v_sub_f32_e32 v36, v39, v106
	v_sub_f32_e32 v37, v40, v106
	v_sub_f32_e32 v144, v45, v106
	v_sub_f32_e32 v145, v46, v106
	v_mfma_f32_32x32x16_bf16 v[16:31], v[150:153], v[64:67], v[16:31]
	v_exp_f32_e32 v108, v63
	v_exp_f32_e32 v109, v60
	v_mfma_f32_32x32x16_bf16 v[0:15], v[138:141], v[72:75], v[0:15]
	v_exp_f32_e32 v110, v61
	v_exp_f32_e32 v111, v62
	v_exp_f32_e32 v112, v57
	v_sub_f32_e32 v141, v35, v106
	v_sub_f32_e32 v35, v38, v106
	v_sub_f32_e32 v140, v44, v106
	v_sub_f32_e32 v139, v47, v106
	v_mfma_f32_32x32x16_bf16 v[0:15], v[146:149], v[68:71], v[0:15]
	v_exp_f32_e32 v113, v58
	v_exp_f32_e32 v114, v59
	v_exp_f32_e32 v115, v54
	v_sub_f32_e32 v146, v32, v106
	v_sub_f32_e32 v147, v33, v106
	v_sub_f32_e32 v148, v34, v106
	v_sub_f32_e32 v32, v41, v106
	v_mfma_f32_32x32x16_bf16 v[0:15], v[154:157], v[64:67], v[0:15]
	v_exp_f32_e32 v117, v55
	v_exp_f32_e32 v118, v56
	v_exp_f32_e32 v119, v48
	v_exp_f32_e32 v134, v49
	v_exp_f32_e32 v135, v50
	v_exp_f32_e32 v136, v51
	v_exp_f32_e32 v137, v52
	v_exp_f32_e32 v138, v53
	v_sub_f32_e32 v33, v42, v106
	v_sub_f32_e32 v34, v43, v106
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_27
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v129 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v129 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v129 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v129 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v130 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v130 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v130 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v130 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v146, v146
	v_exp_f32_e32 v147, v147
	v_exp_f32_e32 v148, v148
	v_exp_f32_e32 v141, v141
	v_exp_f32_e32 v142, v142
	v_exp_f32_e32 v143, v143
	v_exp_f32_e32 v149, v35
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[92:95], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[158:161], v[88:91], v[48:63]
	v_exp_f32_e32 v158, v36
	v_exp_f32_e32 v159, v37
	v_exp_f32_e32 v160, v32
	v_exp_f32_e32 v161, v33
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[162:165], v[84:87], v[48:63]
	v_exp_f32_e32 v162, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[150:153], v[92:95], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v119, v134
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v135, v136
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v137, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v115, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v118, v112
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v71, v140
	v_exp_f32_e32 v140, v144
	v_exp_f32_e32 v144, v145
	v_exp_f32_e32 v139, v139
	v_add_f32_e32 v68, v134, v119
	v_add_f32_e32 v68, v68, v135
	v_add_f32_e32 v68, v68, v136
	v_add_f32_e32 v68, v68, v137
	v_add_f32_e32 v68, v68, v138
	v_add_f32_e32 v68, v68, v115
	v_add_f32_e32 v68, v68, v117
	v_add_f32_e32 v68, v68, v118
	v_add_f32_e32 v68, v68, v112
	v_add_f32_e32 v68, v68, v113
	v_add_f32_e32 v68, v68, v114
	v_add_f32_e32 v68, v68, v109
	v_add_f32_e32 v68, v68, v110
	v_add_f32_e32 v68, v68, v111
	v_add_f32_e32 v68, v68, v108
	v_add_f32_e32 v68, v68, v146
	v_add_f32_e32 v68, v68, v147
	v_add_f32_e32 v68, v68, v148
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v113, v114
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v109, v110
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v111, v108
	;;#ASMEND
	v_add_f32_e32 v108, v68, v141
	v_add_f32_e32 v108, v108, v142
	v_add_f32_e32 v108, v108, v143
	v_add_f32_e32 v108, v108, v149
	v_add_f32_e32 v108, v108, v158
	v_add_f32_e32 v108, v108, v159
	v_add_f32_e32 v108, v108, v160
	v_add_f32_e32 v108, v108, v161
	v_add_f32_e32 v108, v108, v162
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v146, v147
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v148, v141
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v142, v143
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v149, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v159, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v161, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v71, v140
	;;#ASMEND
	v_add_f32_e32 v71, v108, v71
	v_add_f32_e32 v71, v71, v140
	v_add_f32_e32 v71, v71, v144
	v_add_f32_e32 v109, v71, v139
	v_mov_b32_e32 v110, v109
	s_nop 1
	v_permlane32_swap_b32_e64 v109, v110 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[166:169], v[88:91], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v144, v139
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[170:173], v[84:87], v[32:47]
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
	v_readfirstlane_b32 s40, v100
	v_readfirstlane_b32 s41, v101
	v_readfirstlane_b32 s42, v102
	v_readfirstlane_b32 s43, v103
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_29
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[112:113], v128 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v128 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v128 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v128 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v128 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v128 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v128 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v128 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[114:115], v128 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v128 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v128 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v128 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v128 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v128 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v128 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v128 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[112:115], v[76:79], v[16:31]
	v_max_f32_e32 v108, v49, v51
	v_max3_f32 v111, v48, v50, v52
	v_max3_f32 v108, v108, v53, v55
	v_max3_f32 v111, v111, v54, v56
	v_max3_f32 v108, v108, v57, v59
	v_mfma_f32_32x32x16_bf16 v[0:15], v[134:137], v[76:79], v[0:15]
	v_max3_f32 v76, v111, v58, v60
	v_max3_f32 v77, v108, v61, v63
	v_max3_f32 v76, v76, v62, v32
	v_max3_f32 v77, v77, v33, v35
	v_max3_f32 v76, v76, v34, v36
	v_max3_f32 v77, v77, v37, v39
	v_max3_f32 v76, v76, v38, v40
	v_max3_f32 v77, v77, v41, v43
	v_max3_f32 v76, v76, v42, v44
	v_max3_f32 v77, v77, v45, v47
	v_max3_f32 v76, v76, v46, v77
	v_mov_b32_e32 v77, v76
	s_nop 1
	v_permlane32_swap_b32_e64 v76, v77 bound_ctrl:1
	v_max3_f32 v108, v106, v76, v77
	v_sub_f32_e32 v76, v106, v108
	v_exp_f32_e32 v106, v76
	v_sub_f32_e32 v61, v61, v108
	v_sub_f32_e32 v62, v62, v108
	v_pk_mul_f32 v[30:31], v[106:107], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[106:107], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[106:107], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[106:107], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[106:107], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[106:107], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[106:107], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[106:107], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[106:107], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[106:107], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[106:107], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[106:107], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[106:107], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[106:107], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[106:107], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[106:107], v[0:1] op_sel_hi:[0,1]
	v_sub_f32_e32 v48, v48, v108
	v_sub_f32_e32 v49, v49, v108
	v_sub_f32_e32 v50, v50, v108
	v_sub_f32_e32 v51, v51, v108
	v_sub_f32_e32 v52, v52, v108
	v_sub_f32_e32 v53, v53, v108
	v_sub_f32_e32 v54, v54, v108
	v_sub_f32_e32 v55, v55, v108
	v_sub_f32_e32 v56, v56, v108
	v_sub_f32_e32 v57, v57, v108
	v_sub_f32_e32 v58, v58, v108
	v_sub_f32_e32 v59, v59, v108
	v_sub_f32_e32 v60, v60, v108
	v_sub_f32_e32 v63, v63, v108
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[64:67], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[146:149], v[72:75], v[16:31]
	v_sub_f32_e32 v149, v32, v108
	v_sub_f32_e32 v146, v37, v108
	v_sub_f32_e32 v37, v40, v108
	v_sub_f32_e32 v32, v41, v108
	v_sub_f32_e32 v147, v45, v108
	v_sub_f32_e32 v148, v46, v108
	v_mfma_f32_32x32x16_bf16 v[16:31], v[154:157], v[68:71], v[16:31]
	v_exp_f32_e32 v111, v63
	v_exp_f32_e32 v112, v60
	v_mfma_f32_32x32x16_bf16 v[0:15], v[142:145], v[64:67], v[0:15]
	v_exp_f32_e32 v113, v61
	v_exp_f32_e32 v114, v62
	v_exp_f32_e32 v115, v57
	v_sub_f32_e32 v144, v35, v108
	v_sub_f32_e32 v145, v36, v108
	v_sub_f32_e32 v35, v38, v108
	v_sub_f32_e32 v36, v39, v108
	v_mfma_f32_32x32x16_bf16 v[0:15], v[150:153], v[72:75], v[0:15]
	v_exp_f32_e32 v117, v58
	v_exp_f32_e32 v118, v59
	v_exp_f32_e32 v119, v54
	v_sub_f32_e32 v150, v33, v108
	v_sub_f32_e32 v151, v34, v108
	v_sub_f32_e32 v33, v42, v108
	v_sub_f32_e32 v34, v43, v108
	v_mfma_f32_32x32x16_bf16 v[0:15], v[158:161], v[68:71], v[0:15]
	v_exp_f32_e32 v134, v55
	v_exp_f32_e32 v135, v56
	v_exp_f32_e32 v136, v48
	v_exp_f32_e32 v137, v49
	v_exp_f32_e32 v138, v50
	v_exp_f32_e32 v139, v51
	v_exp_f32_e32 v140, v52
	v_exp_f32_e32 v141, v53
	v_sub_f32_e32 v142, v44, v108
	v_sub_f32_e32 v143, v47, v108
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_31
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v133 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v133 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v133 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v133 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[172:175], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v149, v149
	v_exp_f32_e32 v150, v150
	v_exp_f32_e32 v151, v151
	v_exp_f32_e32 v144, v144
	v_exp_f32_e32 v145, v145
	v_exp_f32_e32 v146, v146
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[92:95], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[160:163], v[88:91], v[48:63]
	v_exp_f32_e32 v160, v35
	v_exp_f32_e32 v161, v36
	v_exp_f32_e32 v162, v37
	v_exp_f32_e32 v163, v32
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[164:167], v[84:87], v[48:63]
	v_exp_f32_e32 v164, v33
	v_exp_f32_e32 v165, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[92:95], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v136, v137
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v138, v139
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v140, v141
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v119, v134
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v135, v115
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v142
	v_exp_f32_e32 v142, v147
	v_exp_f32_e32 v147, v148
	v_exp_f32_e32 v143, v143
	v_add_f32_e32 v64, v137, v136
	v_add_f32_e32 v64, v64, v138
	v_add_f32_e32 v64, v64, v139
	v_add_f32_e32 v64, v64, v140
	v_add_f32_e32 v64, v64, v141
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v134
	v_add_f32_e32 v64, v64, v135
	v_add_f32_e32 v64, v64, v115
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v112
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v114
	v_add_f32_e32 v64, v64, v111
	v_add_f32_e32 v64, v64, v149
	v_add_f32_e32 v64, v64, v150
	v_add_f32_e32 v64, v64, v151
	v_add_f32_e32 v148, v64, v144
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v117, v118
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v112, v113
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v114, v111
	;;#ASMEND
	v_add_f32_e32 v111, v148, v145
	v_add_f32_e32 v111, v111, v146
	v_add_f32_e32 v111, v111, v160
	v_add_f32_e32 v111, v111, v161
	v_add_f32_e32 v111, v111, v162
	v_add_f32_e32 v111, v111, v163
	v_add_f32_e32 v111, v111, v164
	v_add_f32_e32 v111, v111, v165
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v149, v150
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v151, v144
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v145, v146
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v160, v161
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v162, v163
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v164, v165
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v142
	;;#ASMEND
	v_add_f32_e32 v67, v111, v67
	v_add_f32_e32 v67, v67, v142
	v_add_f32_e32 v67, v67, v147
	v_add_f32_e32 v111, v67, v143
	v_mov_b32_e32 v112, v111
	s_nop 1
	v_permlane32_swap_b32_e64 v111, v112 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[168:171], v[88:91], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v147, v143
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[172:175], v[84:87], v[32:47]
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
	v_readfirstlane_b32 s40, v100
	v_readfirstlane_b32 s41, v101
	v_readfirstlane_b32 s42, v102
	v_readfirstlane_b32 s43, v103
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_33
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v127 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v127 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v127 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v127 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v127 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v127 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v127 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v127 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v127 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v127 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v127 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v127 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v127 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v127 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v127 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v127 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[134:137], v[76:79], v[16:31]
	v_max_f32_e32 v113, v49, v51
	v_max3_f32 v114, v48, v50, v52
	v_max3_f32 v113, v113, v53, v55
	v_max3_f32 v114, v114, v54, v56
	v_max3_f32 v113, v113, v57, v59
	v_mfma_f32_32x32x16_bf16 v[0:15], v[138:141], v[76:79], v[0:15]
	v_max3_f32 v76, v114, v58, v60
	v_max3_f32 v77, v113, v61, v63
	v_max3_f32 v76, v76, v62, v32
	v_max3_f32 v77, v77, v33, v35
	v_max3_f32 v76, v76, v34, v36
	v_max3_f32 v77, v77, v37, v39
	v_max3_f32 v76, v76, v38, v40
	v_max3_f32 v77, v77, v41, v43
	v_max3_f32 v76, v76, v42, v44
	v_max3_f32 v77, v77, v45, v47
	v_max3_f32 v76, v76, v46, v77
	v_mov_b32_e32 v77, v76
	s_nop 1
	v_permlane32_swap_b32_e64 v76, v77 bound_ctrl:1
	v_max3_f32 v115, v108, v76, v77
	v_sub_f32_e32 v76, v108, v115
	v_exp_f32_e32 v108, v76
	v_sub_f32_e32 v61, v61, v115
	v_sub_f32_e32 v62, v62, v115
	v_pk_mul_f32 v[30:31], v[108:109], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[108:109], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[108:109], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[108:109], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[108:109], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[108:109], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[108:109], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[108:109], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[108:109], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[108:109], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[108:109], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[108:109], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[108:109], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[108:109], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[108:109], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[108:109], v[0:1] op_sel_hi:[0,1]
	v_sub_f32_e32 v48, v48, v115
	v_sub_f32_e32 v49, v49, v115
	v_sub_f32_e32 v50, v50, v115
	v_sub_f32_e32 v51, v51, v115
	v_sub_f32_e32 v52, v52, v115
	v_sub_f32_e32 v53, v53, v115
	v_sub_f32_e32 v54, v54, v115
	v_sub_f32_e32 v55, v55, v115
	v_sub_f32_e32 v56, v56, v115
	v_sub_f32_e32 v57, v57, v115
	v_sub_f32_e32 v58, v58, v115
	v_sub_f32_e32 v59, v59, v115
	v_sub_f32_e32 v60, v60, v115
	v_sub_f32_e32 v63, v63, v115
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[72:75], v[16:31]
	v_sub_f32_e32 v145, v44, v115
	v_mfma_f32_32x32x16_bf16 v[16:31], v[150:153], v[68:71], v[16:31]
	v_sub_f32_e32 v152, v32, v115
	v_sub_f32_e32 v153, v33, v115
	v_sub_f32_e32 v32, v41, v115
	v_sub_f32_e32 v33, v42, v115
	v_sub_f32_e32 v150, v45, v115
	v_sub_f32_e32 v151, v46, v115
	v_mfma_f32_32x32x16_bf16 v[16:31], v[158:161], v[64:67], v[16:31]
	v_exp_f32_e32 v113, v63
	v_exp_f32_e32 v114, v60
	v_mfma_f32_32x32x16_bf16 v[0:15], v[146:149], v[72:75], v[0:15]
	v_exp_f32_e32 v117, v61
	v_exp_f32_e32 v118, v62
	v_exp_f32_e32 v119, v57
	v_sub_f32_e32 v147, v35, v115
	v_sub_f32_e32 v148, v36, v115
	v_sub_f32_e32 v149, v37, v115
	v_sub_f32_e32 v35, v38, v115
	v_mfma_f32_32x32x16_bf16 v[0:15], v[154:157], v[68:71], v[0:15]
	v_exp_f32_e32 v134, v58
	v_exp_f32_e32 v135, v59
	v_exp_f32_e32 v136, v54
	v_sub_f32_e32 v154, v34, v115
	v_sub_f32_e32 v36, v39, v115
	v_sub_f32_e32 v37, v40, v115
	v_sub_f32_e32 v34, v43, v115
	v_mfma_f32_32x32x16_bf16 v[0:15], v[162:165], v[64:67], v[0:15]
	v_exp_f32_e32 v137, v55
	v_exp_f32_e32 v138, v56
	v_exp_f32_e32 v139, v48
	v_exp_f32_e32 v140, v49
	v_exp_f32_e32 v141, v50
	v_exp_f32_e32 v142, v51
	v_exp_f32_e32 v143, v52
	v_exp_f32_e32 v144, v53
	v_sub_f32_e32 v146, v47, v115
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_35
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[38:41], v129 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v129 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v129 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v129 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v130 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v130 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[172:175], v130 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[176:179], v130 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v152, v152
	v_exp_f32_e32 v153, v153
	v_exp_f32_e32 v154, v154
	v_exp_f32_e32 v147, v147
	v_exp_f32_e32 v148, v148
	v_exp_f32_e32 v149, v149
	v_exp_f32_e32 v155, v35
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[92:95], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[164:167], v[88:91], v[48:63]
	v_exp_f32_e32 v164, v36
	v_exp_f32_e32 v165, v37
	v_exp_f32_e32 v166, v32
	v_exp_f32_e32 v167, v33
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[168:171], v[84:87], v[48:63]
	v_exp_f32_e32 v168, v34
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[92:95], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v141, v142
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v143, v144
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v136, v137
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v138, v119
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v67, v145
	v_exp_f32_e32 v145, v150
	v_exp_f32_e32 v150, v151
	v_exp_f32_e32 v146, v146
	v_add_f32_e32 v64, v140, v139
	v_add_f32_e32 v64, v64, v141
	v_add_f32_e32 v64, v64, v142
	v_add_f32_e32 v64, v64, v143
	v_add_f32_e32 v64, v64, v144
	v_add_f32_e32 v64, v64, v136
	v_add_f32_e32 v64, v64, v137
	v_add_f32_e32 v64, v64, v138
	v_add_f32_e32 v64, v64, v119
	v_add_f32_e32 v64, v64, v134
	v_add_f32_e32 v64, v64, v135
	v_add_f32_e32 v64, v64, v114
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v118
	v_add_f32_e32 v64, v64, v113
	v_add_f32_e32 v64, v64, v152
	v_add_f32_e32 v64, v64, v153
	v_add_f32_e32 v64, v64, v154
	v_add_f32_e32 v151, v64, v147
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v134, v135
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v114, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v118, v113
	;;#ASMEND
	v_add_f32_e32 v113, v151, v148
	v_add_f32_e32 v113, v113, v149
	v_add_f32_e32 v113, v113, v155
	v_add_f32_e32 v113, v113, v164
	v_add_f32_e32 v113, v113, v165
	v_add_f32_e32 v113, v113, v166
	v_add_f32_e32 v113, v113, v167
	v_add_f32_e32 v113, v113, v168
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v152, v153
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v154, v147
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v148, v149
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v155, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v165, v166
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v167, v168
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v67, v145
	;;#ASMEND
	v_add_f32_e32 v67, v113, v67
	v_add_f32_e32 v67, v67, v145
	v_add_f32_e32 v67, v67, v150
	v_add_f32_e32 v113, v67, v146
	v_mov_b32_e32 v114, v113
	s_nop 1
	v_permlane32_swap_b32_e64 v113, v114 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[32:47], v[172:175], v[88:91], v[32:47]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v150, v146
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[160:163], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[176:179], v[84:87], v[32:47]
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
	v_readfirstlane_b32 s40, v100
	v_readfirstlane_b32 s41, v101
	v_readfirstlane_b32 s42, v102
	v_readfirstlane_b32 s43, v103
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[100:101]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[102:103]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v131, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_37
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v128 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v128 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v128 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v128 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v128 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v128 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v128 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v128 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v128 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v128 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v128 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v128 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v128 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v128 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v128 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v128 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[76:79], v[16:31]
	v_max_f32_e32 v100, v49, v51
	v_max3_f32 v101, v48, v50, v52
	v_max3_f32 v100, v100, v53, v55
	v_max3_f32 v101, v101, v54, v56
	v_max3_f32 v100, v100, v57, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[138:141], v[72:75], v[16:31]
	v_max3_f32 v101, v101, v58, v60
	v_max3_f32 v100, v100, v61, v63
	v_max3_f32 v101, v101, v62, v32
	v_max3_f32 v100, v100, v33, v35
	v_max3_f32 v101, v101, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[146:149], v[68:71], v[16:31]
	v_max3_f32 v100, v100, v37, v39
	v_max3_f32 v101, v101, v38, v40
	v_max3_f32 v100, v100, v41, v43
	v_max3_f32 v101, v101, v42, v44
	v_max3_f32 v100, v100, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[154:157], v[64:67], v[16:31]
	v_max3_f32 v100, v101, v46, v100
	v_mov_b32_e32 v101, v100
	s_nop 1
	v_permlane32_swap_b32_e64 v100, v101 bound_ctrl:1
	v_max3_f32 v101, v115, v100, v101
	v_sub_f32_e32 v100, v115, v101
	v_mfma_f32_32x32x16_bf16 v[0:15], v[134:137], v[76:79], v[0:15]
	v_sub_f32_e32 v48, v48, v101
	v_sub_f32_e32 v49, v49, v101
	v_sub_f32_e32 v50, v50, v101
	v_sub_f32_e32 v51, v51, v101
	v_sub_f32_e32 v52, v52, v101
	v_mfma_f32_32x32x16_bf16 v[0:15], v[142:145], v[72:75], v[0:15]
	v_sub_f32_e32 v53, v53, v101
	v_sub_f32_e32 v54, v54, v101
	v_sub_f32_e32 v55, v55, v101
	v_sub_f32_e32 v56, v56, v101
	v_sub_f32_e32 v57, v57, v101
	v_sub_f32_e32 v145, v46, v101
	v_mfma_f32_32x32x16_bf16 v[0:15], v[150:153], v[68:71], v[0:15]
	v_sub_f32_e32 v58, v58, v101
	v_sub_f32_e32 v59, v59, v101
	v_sub_f32_e32 v60, v60, v101
	v_sub_f32_e32 v61, v61, v101
	v_sub_f32_e32 v62, v62, v101
	v_sub_f32_e32 v152, v47, v101
	v_mfma_f32_32x32x16_bf16 v[0:15], v[158:161], v[64:67], v[0:15]
	v_sub_f32_e32 v63, v63, v101
	v_sub_f32_e32 v149, v32, v101
	v_sub_f32_e32 v150, v33, v101
	v_sub_f32_e32 v151, v34, v101
	v_sub_f32_e32 v146, v35, v101
	v_sub_f32_e32 v147, v36, v101
	v_sub_f32_e32 v148, v37, v101
	v_sub_f32_e32 v35, v38, v101
	v_sub_f32_e32 v36, v39, v101
	v_sub_f32_e32 v37, v40, v101
	v_sub_f32_e32 v32, v41, v101
	v_sub_f32_e32 v33, v42, v101
	v_sub_f32_e32 v34, v43, v101
	v_sub_f32_e32 v143, v44, v101
	v_sub_f32_e32 v144, v45, v101
	v_exp_f32_e32 v100, v100
	v_exp_f32_e32 v102, v48
	v_exp_f32_e32 v103, v49
	v_exp_f32_e32 v115, v50
	v_exp_f32_e32 v117, v51
	v_exp_f32_e32 v118, v52
	v_exp_f32_e32 v119, v53
	v_exp_f32_e32 v131, v54
	v_exp_f32_e32 v134, v55
	v_exp_f32_e32 v135, v56
	v_exp_f32_e32 v136, v57
	v_exp_f32_e32 v137, v58
	v_exp_f32_e32 v138, v59
	v_exp_f32_e32 v139, v60
	v_exp_f32_e32 v140, v61
	v_exp_f32_e32 v141, v62
	v_exp_f32_e32 v142, v63
	v_pk_mul_f32 v[30:31], v[100:101], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[100:101], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[100:101], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[100:101], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[100:101], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[100:101], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[100:101], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[100:101], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[100:101], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[100:101], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[100:101], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[100:101], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[100:101], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[100:101], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[100:101], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[100:101], v[0:1] op_sel_hi:[0,1]
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s33 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_39
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
	ds_read_b128 v[162:165], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v132 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v132 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v132, v149
	v_exp_f32_e32 v133, v150
	v_exp_f32_e32 v149, v151
	v_exp_f32_e32 v146, v146
	v_exp_f32_e32 v147, v147
	v_exp_f32_e32 v148, v148
	v_exp_f32_e32 v150, v35
	v_exp_f32_e32 v151, v36
	v_exp_f32_e32 v153, v37
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[38:41], v[92:95], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[162:165], v[88:91], v[48:63]
	v_exp_f32_e32 v162, v32
	v_exp_f32_e32 v163, v33
	v_exp_f32_e32 v164, v34
	v_mfma_f32_32x32x16_bf16 v[48:63], v[42:45], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[154:157], v[92:95], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v115, v117
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v118, v119
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v131, v134
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v135, v136
	;;#ASMEND
	s_nop 6
	v_exp_f32_e32 v64, v143
	v_exp_f32_e32 v65, v144
	v_exp_f32_e32 v67, v145
	v_exp_f32_e32 v68, v152
	v_add_f32_e32 v66, v103, v102
	v_add_f32_e32 v66, v66, v115
	v_add_f32_e32 v66, v66, v117
	v_add_f32_e32 v66, v66, v118
	v_add_f32_e32 v66, v66, v119
	v_add_f32_e32 v66, v66, v131
	v_add_f32_e32 v66, v66, v134
	v_add_f32_e32 v66, v66, v135
	v_add_f32_e32 v66, v66, v136
	v_add_f32_e32 v66, v66, v137
	v_add_f32_e32 v66, v66, v138
	v_add_f32_e32 v66, v66, v139
	v_add_f32_e32 v66, v66, v140
	v_add_f32_e32 v66, v66, v141
	v_add_f32_e32 v66, v66, v142
	v_add_f32_e32 v66, v66, v132
	v_add_f32_e32 v66, v66, v133
	v_add_f32_e32 v66, v66, v149
	v_add_f32_e32 v66, v66, v146
	v_add_f32_e32 v66, v66, v147
	v_add_f32_e32 v66, v66, v148
	v_add_f32_e32 v66, v66, v150
	v_add_f32_e32 v66, v66, v151
	v_add_f32_e32 v66, v66, v153
	v_add_f32_e32 v66, v66, v162
	v_add_f32_e32 v66, v66, v163
	v_add_f32_e32 v66, v66, v164
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v137, v138
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v139, v140
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v141, v142
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v132, v132, v133
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v133, v149, v146
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v134, v147, v148
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v135, v150, v151
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v136, v153, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v137, v163, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v138, v64, v65
	;;#ASMEND
	v_add_f32_e32 v64, v66, v64
	v_add_f32_e32 v64, v64, v65
	v_add_f32_e32 v64, v64, v67
	v_add_f32_e32 v65, v64, v68
	v_mov_b32_e32 v66, v65
	s_nop 1
	v_permlane32_swap_b32_e64 v65, v66 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[166:169], v[84:87], v[48:63]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v139, v67, v68
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[32:47], v[170:173], v[88:91], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[158:161], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[174:177], v[84:87], v[32:47]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[68:69], v127 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v127 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v127 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v127 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v127 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v127 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v127 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v127 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[70:71], v127 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v127 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v127 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v127 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v127 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v127 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v127 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v127 offset:0x1e00

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
	v_mfma_f32_32x32x16_bf16 v[16:31], v[144:147], v[76:79], v[16:31]
	v_max3_f32 v67, v67, v58, v60
	v_max3_f32 v64, v64, v61, v63
	v_max3_f32 v67, v67, v62, v32
	v_max3_f32 v64, v64, v33, v35
	v_max3_f32 v67, v67, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[152:155], v[132:135], v[16:31]
	v_max3_f32 v64, v64, v37, v39
	v_max3_f32 v67, v67, v38, v40
	v_max3_f32 v64, v64, v41, v43
	v_max3_f32 v67, v67, v42, v44
	v_max3_f32 v64, v64, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[160:163], v[136:139], v[16:31]
	v_max3_f32 v64, v67, v46, v64
	v_mov_b32_e32 v67, v64
	s_nop 1
	v_permlane32_swap_b32_e64 v64, v67 bound_ctrl:1
	v_max3_f32 v70, v101, v64, v67
	v_sub_f32_e32 v64, v101, v70
	v_sub_f32_e32 v119, v46, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[140:143], v[72:75], v[0:15]
	v_sub_f32_e32 v48, v48, v70
	v_sub_f32_e32 v49, v49, v70
	v_sub_f32_e32 v50, v50, v70
	v_sub_f32_e32 v51, v51, v70
	v_sub_f32_e32 v52, v52, v70
	v_sub_f32_e32 v143, v47, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[148:151], v[76:79], v[0:15]
	v_sub_f32_e32 v53, v53, v70
	v_sub_f32_e32 v54, v54, v70
	v_sub_f32_e32 v55, v55, v70
	v_sub_f32_e32 v56, v56, v70
	v_sub_f32_e32 v57, v57, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[156:159], v[132:135], v[0:15]
	v_sub_f32_e32 v58, v58, v70
	v_sub_f32_e32 v59, v59, v70
	v_sub_f32_e32 v60, v60, v70
	v_sub_f32_e32 v61, v61, v70
	v_sub_f32_e32 v62, v62, v70
	v_mfma_f32_32x32x16_bf16 v[0:15], v[164:167], v[136:139], v[0:15]
	v_sub_f32_e32 v63, v63, v70
	v_sub_f32_e32 v140, v32, v70
	v_sub_f32_e32 v141, v33, v70
	v_sub_f32_e32 v142, v34, v70
	v_sub_f32_e32 v137, v35, v70
	v_sub_f32_e32 v138, v36, v70
	v_sub_f32_e32 v139, v37, v70
	v_sub_f32_e32 v134, v38, v70
	v_sub_f32_e32 v135, v39, v70
	v_sub_f32_e32 v136, v40, v70
	v_sub_f32_e32 v131, v41, v70
	v_sub_f32_e32 v132, v42, v70
	v_sub_f32_e32 v133, v43, v70
	v_sub_f32_e32 v117, v44, v70
	v_sub_f32_e32 v118, v45, v70
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
	v_exp_f32_e32 v101, v60
	v_exp_f32_e32 v102, v61
	v_exp_f32_e32 v103, v62
	v_exp_f32_e32 v115, v63
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
	v_readfirstlane_b32 s40, v80
	v_readfirstlane_b32 s41, v81
	v_readfirstlane_b32 s42, v82
	v_readfirstlane_b32 s43, v83
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[80:81]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[82:83]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v124, s[40:43], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_41
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[80:83], v129 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[144:147], v129 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[148:151], v129 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v129 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v130 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v130 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v130 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v130 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v124, v140
	v_exp_f32_e32 v129, v141
	v_exp_f32_e32 v130, v142
	v_exp_f32_e32 v137, v137
	v_exp_f32_e32 v138, v138
	v_exp_f32_e32 v139, v139
	v_exp_f32_e32 v134, v134
	v_exp_f32_e32 v135, v135
	v_exp_f32_e32 v136, v136
	v_exp_f32_e32 v131, v131
	v_exp_f32_e32 v132, v132
	v_exp_f32_e32 v133, v133
	v_mov_b64_e32 v[46:47], s[22:23]
	v_mov_b64_e32 v[44:45], s[20:21]
	v_mov_b64_e32 v[42:43], s[18:19]
	v_mov_b64_e32 v[40:41], s[16:17]
	v_mov_b64_e32 v[38:39], s[14:15]
	v_mov_b64_e32 v[36:37], s[12:13]
	v_mov_b64_e32 v[34:35], s[10:11]
	v_mov_b64_e32 v[32:33], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[80:83], v[92:95], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[148:151], v[92:95], v[32:47]
	v_exp_f32_e32 v92, v117
	v_exp_f32_e32 v93, v118
	v_exp_f32_e32 v94, v119
	v_mfma_f32_32x32x16_bf16 v[48:63], v[156:159], v[88:91], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[164:167], v[88:91], v[32:47]
	v_exp_f32_e32 v88, v143
	v_mfma_f32_32x32x16_bf16 v[48:63], v[144:147], v[96:99], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[160:163], v[84:87], v[48:63]
	v_add_f32_e32 v80, v68, v67
	v_add_f32_e32 v80, v80, v69
	v_add_f32_e32 v80, v80, v71
	v_add_f32_e32 v80, v80, v72
	v_add_f32_e32 v80, v80, v73
	v_add_f32_e32 v80, v80, v74
	v_add_f32_e32 v80, v80, v75
	v_add_f32_e32 v80, v80, v76
	v_add_f32_e32 v80, v80, v77
	v_add_f32_e32 v80, v80, v78
	v_add_f32_e32 v80, v80, v79
	v_add_f32_e32 v80, v80, v101
	v_add_f32_e32 v80, v80, v102
	v_add_f32_e32 v80, v80, v103
	v_add_f32_e32 v80, v80, v115
	v_add_f32_e32 v80, v80, v124
	v_add_f32_e32 v80, v80, v129
	v_add_f32_e32 v80, v80, v130
	v_mfma_f32_32x32x16_bf16 v[32:47], v[152:155], v[96:99], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[168:171], v[84:87], v[32:47]
	v_add_f32_e32 v87, v80, v137
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v80, v67, v68
	;;#ASMEND
	v_add_f32_e32 v67, v87, v138
	v_add_f32_e32 v67, v67, v139
	v_add_f32_e32 v67, v67, v134
	v_add_f32_e32 v67, v67, v135
	v_add_f32_e32 v67, v67, v136
	v_add_f32_e32 v67, v67, v131
	v_add_f32_e32 v67, v67, v132
	v_add_f32_e32 v67, v67, v133
	v_add_f32_e32 v67, v67, v92
	v_add_f32_e32 v67, v67, v93
	v_add_f32_e32 v67, v67, v94
	v_add_f32_e32 v68, v67, v88
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v81, v69, v71
	;;#ASMEND
	v_mov_b32_e32 v69, v68
	s_nop 1
	v_permlane32_swap_b32_e64 v68, v69 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v82, v72, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v83, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v76, v77
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v78, v79
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v101, v102
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v103, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v124, v129
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v130, v137
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v138, v139
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v134, v135
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v84, v136, v131
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v85, v132, v133
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v86, v92, v93
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v87, v94, v88
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[88:89], v128 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[92:93], v128 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v128 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[130:131], v128 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v128 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v128 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v128 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v128 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[90:91], v128 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[94:95], v128 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v128 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[132:133], v128 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v128 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v128 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v128 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v128 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[16:31], v[88:91], v[80:83], v[16:31]
	v_max_f32_e32 v67, v49, v51
	v_max3_f32 v71, v48, v50, v52
	v_max3_f32 v67, v67, v53, v55
	v_max3_f32 v71, v71, v54, v56
	v_max3_f32 v67, v67, v57, v59
	v_mfma_f32_32x32x16_bf16 v[16:31], v[96:99], v[72:75], v[16:31]
	v_max3_f32 v71, v71, v58, v60
	v_max3_f32 v67, v67, v61, v63
	v_max3_f32 v71, v71, v62, v32
	v_max3_f32 v67, v67, v33, v35
	v_max3_f32 v71, v71, v34, v36
	v_mfma_f32_32x32x16_bf16 v[16:31], v[134:137], v[76:79], v[16:31]
	v_max3_f32 v67, v67, v37, v39
	v_max3_f32 v71, v71, v38, v40
	v_max3_f32 v67, v67, v41, v43
	v_max3_f32 v71, v71, v42, v44
	v_max3_f32 v67, v67, v45, v47
	v_mfma_f32_32x32x16_bf16 v[16:31], v[142:145], v[84:87], v[16:31]
	v_max3_f32 v67, v71, v46, v67
	v_mov_b32_e32 v71, v67
	s_nop 1
	v_permlane32_swap_b32_e64 v67, v71 bound_ctrl:1
	v_max3_f32 v67, v70, v67, v71
	v_sub_f32_e32 v70, v70, v67
	v_sub_f32_e32 v46, v46, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[92:95], v[80:83], v[0:15]
	v_sub_f32_e32 v48, v48, v67
	v_sub_f32_e32 v49, v49, v67
	v_sub_f32_e32 v50, v50, v67
	v_sub_f32_e32 v51, v51, v67
	v_sub_f32_e32 v52, v52, v67
	v_sub_f32_e32 v47, v47, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[130:133], v[72:75], v[0:15]
	v_sub_f32_e32 v53, v53, v67
	v_sub_f32_e32 v54, v54, v67
	v_sub_f32_e32 v55, v55, v67
	v_sub_f32_e32 v56, v56, v67
	v_sub_f32_e32 v57, v57, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[138:141], v[76:79], v[0:15]
	v_sub_f32_e32 v58, v58, v67
	v_sub_f32_e32 v59, v59, v67
	v_sub_f32_e32 v60, v60, v67
	v_sub_f32_e32 v61, v61, v67
	v_sub_f32_e32 v62, v62, v67
	v_mfma_f32_32x32x16_bf16 v[0:15], v[146:149], v[84:87], v[0:15]
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
	v_exp_f32_e32 v80, v43
	v_add_f32_e32 v33, v33, v76
	v_exp_f32_e32 v81, v44
	v_add_f32_e32 v33, v33, v77
	v_exp_f32_e32 v82, v45
	v_add_f32_e32 v33, v33, v78
	v_exp_f32_e32 v83, v46
	v_add_f32_e32 v33, v33, v79
	v_exp_f32_e32 v84, v47
	v_add_f32_e32 v33, v33, v80
	v_add_f32_e32 v33, v33, v81
	v_add_f32_e32 v33, v33, v82
	v_add_f32_e32 v33, v33, v83
	v_add_f32_e32 v33, v33, v84
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
	v_cvt_pk_bf16_f32 v49, v79, v80
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v50, v81, v82
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v51, v83, v84
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
	ds_read_b64_tr_b16 v[52:53], v127 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[56:57], v127 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[60:61], v127 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[70:71], v127 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[74:75], v127 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[78:79], v127 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[82:83], v127 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[86:87], v127 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[54:55], v127 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[58:59], v127 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[62:63], v127 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[72:73], v127 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[76:77], v127 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[80:81], v127 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[84:85], v127 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[88:89], v127 offset:0x1e00

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
	v_mfma_f32_32x32x16_bf16 v[0:15], v[78:81], v[44:47], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[82:85], v[48:51], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[86:89], v[48:51], v[0:15]
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_44
	s_barrier
.LBB0_44:
	s_or_b64 exec, exec, s[0:1]
	v_add_f32_e32 v35, v125, v126
	v_fmac_f32_e32 v105, v116, v35
	v_add_f32_e32 v35, v105, v107
	v_fmac_f32_e32 v109, v104, v35
	v_add_f32_e32 v35, v109, v110
	v_fmac_f32_e32 v111, v106, v35
	v_add_f32_e32 v35, v111, v112
	v_fmac_f32_e32 v113, v35, v108
	v_add_f32_e32 v35, v113, v114
	v_fmac_f32_e32 v65, v100, v35
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
	v_mad_i64_i32 v[0:1], s[0:1], s28, v0, v[120:121]
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
	v_mul_lo_u32 v24, v122, s0
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
	v_add_lshl_u32 v8, v24, v123, 1
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
	v_lshl_add_u64 v[0:1], v[120:121], 2, s[0:1]
	v_lshlrev_b32_e32 v2, 2, v122
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
		.amdhsa_next_free_vgpr 180
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

	.set _Z10attend_kerILi64EEv12attn_globalsIXT_EE.num_vgpr, 180
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
	.type	__hip_cuid_8089dc7c370cb2d6,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_8089dc7c370cb2d6
__hip_cuid_8089dc7c370cb2d6:
	.byte	0
	.size	__hip_cuid_8089dc7c370cb2d6, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_8089dc7c370cb2d6
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
    .vgpr_count:     180
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
