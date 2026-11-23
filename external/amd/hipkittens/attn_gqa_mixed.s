	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._Z10attend_kerILi128EEv12attn_globalsIXT_EE,"axG",@progbits,_Z10attend_kerILi128EEv12attn_globalsIXT_EE,comdat
	.protected	_Z10attend_kerILi128EEv12attn_globalsIXT_EE
	.globl	_Z10attend_kerILi128EEv12attn_globalsIXT_EE
	.p2align	8
	.type	_Z10attend_kerILi128EEv12attn_globalsIXT_EE,@function
_Z10attend_kerILi128EEv12attn_globalsIXT_EE:
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
	s_add_i32 s11, s13, 0x8000
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
	v_lshrrev_b32_e32 v4, 6, v0
	s_cmp_eq_u64 s[8:9], 0
	v_lshlrev_b32_e32 v1, 10, v4
	v_add_u32_e32 v5, s13, v1
	s_cselect_b32 s41, s11, s19
	s_mul_i32 s23, s18, s52
	v_readfirstlane_b32 s37, v5
	v_add_u32_e32 v5, s41, v1
	s_add_i32 s52, s13, 0x4000
	v_readfirstlane_b32 s29, v5
	v_add_u32_e32 v5, s52, v1
	s_add_i32 s43, s41, 0x4000
	v_readfirstlane_b32 s33, v5
	v_add_u32_e32 v5, s43, v1
	v_mov_b32_e32 v112, s0
	v_readfirstlane_b32 s27, v5
	v_lshlrev_b32_e32 v5, 4, v0
	v_and_b32_e32 v6, 0x3c0, v5
	s_movk_i32 s0, 0x400
	v_lshlrev_b32_e32 v7, 4, v4
	v_and_or_b32 v1, v1, s0, v6
	v_and_b32_e32 v6, 32, v0
	v_and_b32_e32 v8, 16, v7
	v_bitop3_b32 v5, v8, v5, v6 bitop3:0x36
	v_lshrrev_b32_e32 v5, 1, v5
	v_and_b32_e32 v6, 0x60, v7
	v_lshrrev_b32_e32 v1, 6, v1
	v_and_or_b32 v6, v5, 24, v6
	v_mov_b32_e32 v113, s1
	v_mad_u64_u32 v[6:7], s[0:1], v1, s23, v[6:7]
	s_lshl_b32 s0, s23, 5
	v_lshrrev_b32_e32 v5, 4, v0
	v_bfe_u32 v7, v0, 2, 3
	v_lshlrev_b32_e32 v214, 1, v6
	v_add_lshl_u32 v213, v6, s0, 1
	v_lshlrev_b32_e32 v6, 3, v0
	v_and_or_b32 v5, v5, 24, v7
	v_and_b32_e32 v7, 0x60, v0
	s_mul_i32 s8, s22, s51
	v_and_or_b32 v6, v6, 24, v7
	v_mad_u64_u32 v[6:7], s[0:1], v5, s8, v[6:7]
	v_mov_b32_e32 v151, 0x110000
	v_alignbit_b32 v114, s8, 0, 22
	v_lshlrev_b32_e32 v5, 1, v6
	s_lshl_b32 s0, s8, 5
	s_mov_b32 s8, s37
	s_mov_b32 s53, s9
	s_mov_b32 s54, s18
	s_mov_b32 s49, s9
	s_mov_b32 s50, s22
	v_alignbit_b32 v150, s23, 0, 22
	v_mov_b32_e32 v148, s16
	v_mov_b32_e32 v149, s17
	v_mov_b32_e32 v115, v151
	v_lshrrev_b32_e32 v1, 2, v0
	scratch_store_dword off, v5, off
	v_add_lshl_u32 v203, v6, s0, 1
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s8
	s_mov_b64 s[20:21], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_1:
	v_readfirstlane_b32 s16, v148
	v_readfirstlane_b32 s17, v149
	v_readfirstlane_b32 s18, v150
	v_readfirstlane_b32 s19, v151
	v_cmp_eq_u64_e32 vcc, s[16:17], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[18:19], v[150:151]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[16:19], s9 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[20:21]
	s_add_i32 s0, s8, 0x2000
	s_mov_b64 s[20:21], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_3:
	v_readfirstlane_b32 s16, v148
	v_readfirstlane_b32 s17, v149
	v_readfirstlane_b32 s18, v150
	v_readfirstlane_b32 s19, v151
	v_cmp_eq_u64_e32 vcc, s[16:17], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[18:19], v[150:151]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[16:19], s9 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[20:21]
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_lshl_b32 s0, s5, 8
	v_lshl_or_b32 v6, v4, 5, s0
	v_ashrrev_i32_e32 v7, 31, v6
	v_mov_b32_e32 v4, s4
	v_mad_i64_i32 v[4:5], s[0:1], s12, v4, v[6:7]
	s_barrier
	scratch_store_dwordx2 off, v[6:7], off offset:4
	s_bfe_i64 s[0:1], s[14:15], 0x200000
	v_mov_b64_e32 v[6:7], s[2:3]
	v_mul_lo_u32 v8, v4, s1
	v_mul_lo_u32 v9, v5, s14
	v_mad_u64_u32 v[4:5], s[0:1], v4, s14, v[6:7]
	v_add3_u32 v5, v9, v5, v8
	s_bfe_i64 s[0:1], s[6:7], 0x200000
	v_mul_lo_u32 v6, v5, s6
	v_mul_lo_u32 v7, v4, s1
	v_mad_u64_u32 v[4:5], s[0:1], v4, s6, 0
	s_mul_i32 s0, s14, s6
	s_mul_i32 s1, s10, s12
	v_add3_u32 v5, v5, v7, v6
	v_and_b32_e32 v7, 31, v0
	s_mul_i32 s1, s0, s1
	v_and_b32_e32 v6, 8, v1
	s_lshl_b32 s1, s1, 1
	scratch_store_dword off, v7, off offset:12
	v_mul_lo_u32 v7, v7, s0
	v_lshl_add_u64 v[2:3], v[4:5], 1, v[2:3]
	v_mov_b32_e32 v4, s1
	v_mov_b32_e32 v5, 0x20000
	v_add_lshl_u32 v14, v7, v6, 1
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
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_5
	s_mov_b64 exec, s[6:7]
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
	buffer_load_dwordx4 v[10:13], v14, s[8:11], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_7
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v15, 16, v6
	v_and_b32_e32 v16, 0xffff0000, v6
	v_lshlrev_b32_e32 v17, 16, v7
	v_and_b32_e32 v18, 0xffff0000, v7
	v_lshlrev_b32_e32 v19, 16, v8
	v_and_b32_e32 v20, 0xffff0000, v8
	v_lshlrev_b32_e32 v21, 16, v9
	v_and_b32_e32 v22, 0xffff0000, v9
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v23, 16, v10
	v_and_b32_e32 v10, 0xffff0000, v10
	v_lshlrev_b32_e32 v24, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v11
	v_lshlrev_b32_e32 v25, 16, v12
	v_and_b32_e32 v12, 0xffff0000, v12
	v_lshlrev_b32_e32 v26, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v13
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
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_9
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v27, 16, v6
	v_and_b32_e32 v28, 0xffff0000, v6
	v_lshlrev_b32_e32 v29, 16, v7
	v_and_b32_e32 v30, 0xffff0000, v7
	v_lshlrev_b32_e32 v31, 16, v8
	v_and_b32_e32 v32, 0xffff0000, v8
	v_lshlrev_b32_e32 v33, 16, v9
	v_and_b32_e32 v34, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_11:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_11
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v35, 16, v6
	v_and_b32_e32 v36, 0xffff0000, v6
	v_lshlrev_b32_e32 v37, 16, v7
	v_and_b32_e32 v38, 0xffff0000, v7
	v_lshlrev_b32_e32 v39, 16, v8
	v_and_b32_e32 v40, 0xffff0000, v8
	v_lshlrev_b32_e32 v41, 16, v9
	v_and_b32_e32 v42, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_13:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_13
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v43, 16, v6
	v_and_b32_e32 v44, 0xffff0000, v6
	v_lshlrev_b32_e32 v45, 16, v7
	v_and_b32_e32 v46, 0xffff0000, v7
	v_lshlrev_b32_e32 v47, 16, v8
	v_and_b32_e32 v48, 0xffff0000, v8
	v_lshlrev_b32_e32 v49, 16, v9
	v_and_b32_e32 v50, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_15:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_15
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v51, 16, v6
	v_and_b32_e32 v52, 0xffff0000, v6
	v_lshlrev_b32_e32 v53, 16, v7
	v_and_b32_e32 v54, 0xffff0000, v7
	v_lshlrev_b32_e32 v55, 16, v8
	v_and_b32_e32 v56, 0xffff0000, v8
	v_lshlrev_b32_e32 v57, 16, v9
	v_and_b32_e32 v58, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_17:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_17
	s_mov_b64 exec, s[6:7]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v59, 16, v6
	v_and_b32_e32 v60, 0xffff0000, v6
	v_lshlrev_b32_e32 v61, 16, v7
	v_and_b32_e32 v62, 0xffff0000, v7
	v_lshlrev_b32_e32 v63, 16, v8
	v_and_b32_e32 v64, 0xffff0000, v8
	v_lshlrev_b32_e32 v65, 16, v9
	v_and_b32_e32 v66, 0xffff0000, v9
	s_mov_b64 s[6:7], exec
.LBB0_19:
	v_readfirstlane_b32 s8, v2
	v_readfirstlane_b32 s9, v3
	v_readfirstlane_b32 s10, v4
	v_readfirstlane_b32 s11, v5
	v_cmp_eq_u64_e32 vcc, s[8:9], v[2:3]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[4:5]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[6:9], v14, s[8:11], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_19
	s_mov_b64 exec, s[6:7]
	s_lshl_b32 s0, s23, 6
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v2, 16, v6
	v_and_b32_e32 v3, 0xffff0000, v6
	v_lshlrev_b32_e32 v4, 16, v7
	v_and_b32_e32 v5, 0xffff0000, v7
	v_lshlrev_b32_e32 v6, 16, v8
	v_and_b32_e32 v7, 0xffff0000, v8
	v_lshlrev_b32_e32 v8, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v9
	s_lshl_b32 s5, s0, 1
	s_mov_b32 s12, s33
	v_mul_f32_e32 v14, 0x3e0293ee, v15
	v_mul_f32_e32 v15, 0x3e0293ee, v16
	v_mul_f32_e32 v16, 0x3e0293ee, v17
	v_mul_f32_e32 v17, 0x3e0293ee, v18
	v_mul_f32_e32 v18, 0x3e0293ee, v19
	v_mul_f32_e32 v19, 0x3e0293ee, v20
	v_mul_f32_e32 v20, 0x3e0293ee, v21
	v_mul_f32_e32 v21, 0x3e0293ee, v22
	v_mul_f32_e32 v22, 0x3e0293ee, v23
	v_mul_f32_e32 v10, 0x3e0293ee, v10
	v_mul_f32_e32 v23, 0x3e0293ee, v24
	v_mul_f32_e32 v11, 0x3e0293ee, v11
	v_mul_f32_e32 v24, 0x3e0293ee, v25
	v_mul_f32_e32 v12, 0x3e0293ee, v12
	v_mul_f32_e32 v25, 0x3e0293ee, v26
	v_mul_f32_e32 v13, 0x3e0293ee, v13
	v_mul_f32_e32 v26, 0x3e0293ee, v27
	v_mul_f32_e32 v27, 0x3e0293ee, v28
	v_mul_f32_e32 v28, 0x3e0293ee, v29
	v_mul_f32_e32 v29, 0x3e0293ee, v30
	v_mul_f32_e32 v30, 0x3e0293ee, v31
	v_mul_f32_e32 v31, 0x3e0293ee, v32
	v_mul_f32_e32 v32, 0x3e0293ee, v33
	v_mul_f32_e32 v33, 0x3e0293ee, v34
	v_mul_f32_e32 v34, 0x3e0293ee, v35
	v_mul_f32_e32 v35, 0x3e0293ee, v36
	v_mul_f32_e32 v36, 0x3e0293ee, v37
	v_mul_f32_e32 v37, 0x3e0293ee, v38
	v_mul_f32_e32 v38, 0x3e0293ee, v39
	v_mul_f32_e32 v39, 0x3e0293ee, v40
	v_mul_f32_e32 v40, 0x3e0293ee, v41
	v_mul_f32_e32 v41, 0x3e0293ee, v42
	v_mul_f32_e32 v42, 0x3e0293ee, v43
	v_mul_f32_e32 v43, 0x3e0293ee, v44
	v_mul_f32_e32 v44, 0x3e0293ee, v45
	v_mul_f32_e32 v45, 0x3e0293ee, v46
	v_mul_f32_e32 v46, 0x3e0293ee, v47
	v_mul_f32_e32 v47, 0x3e0293ee, v48
	v_mul_f32_e32 v48, 0x3e0293ee, v49
	v_mul_f32_e32 v49, 0x3e0293ee, v50
	v_mul_f32_e32 v50, 0x3e0293ee, v51
	v_mul_f32_e32 v51, 0x3e0293ee, v52
	v_mul_f32_e32 v52, 0x3e0293ee, v53
	v_mul_f32_e32 v53, 0x3e0293ee, v54
	v_mul_f32_e32 v54, 0x3e0293ee, v55
	v_mul_f32_e32 v55, 0x3e0293ee, v56
	v_mul_f32_e32 v56, 0x3e0293ee, v57
	v_mul_f32_e32 v57, 0x3e0293ee, v58
	v_mul_f32_e32 v58, 0x3e0293ee, v59
	v_mul_f32_e32 v59, 0x3e0293ee, v60
	v_mul_f32_e32 v60, 0x3e0293ee, v61
	v_mul_f32_e32 v61, 0x3e0293ee, v62
	v_mul_f32_e32 v62, 0x3e0293ee, v63
	v_mul_f32_e32 v63, 0x3e0293ee, v64
	v_mul_f32_e32 v64, 0x3e0293ee, v65
	v_mul_f32_e32 v65, 0x3e0293ee, v66
	v_mul_f32_e32 v2, 0x3e0293ee, v2
	v_mul_f32_e32 v3, 0x3e0293ee, v3
	v_mul_f32_e32 v4, 0x3e0293ee, v4
	v_mul_f32_e32 v5, 0x3e0293ee, v5
	v_mul_f32_e32 v6, 0x3e0293ee, v6
	v_mul_f32_e32 v7, 0x3e0293ee, v7
	v_mul_f32_e32 v8, 0x3e0293ee, v8
	v_mul_f32_e32 v9, 0x3e0293ee, v9
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v144, v14, v15
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v145, v16, v17
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v146, v18, v19
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v147, v20, v21
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v140, v22, v10
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v141, v23, v11
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v142, v24, v12
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v143, v25, v13
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v136, v26, v27
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v137, v28, v29
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v138, v30, v31
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v139, v32, v33
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v132, v34, v35
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v133, v36, v37
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v134, v38, v39
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v135, v40, v41
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v128, v42, v43
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v129, v44, v45
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v130, v46, v47
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v131, v48, v49
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v124, v50, v51
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v125, v52, v53
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v126, v54, v55
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v127, v56, v57
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v120, v58, v59
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v121, v60, v61
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v122, v62, v63
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v123, v64, v65
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v116, v2, v3
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v117, v4, v5
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v118, v6, v7
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v119, v8, v9
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s12
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_21:
	v_readfirstlane_b32 s8, v148
	v_readfirstlane_b32 s9, v149
	v_readfirstlane_b32 s10, v150
	v_readfirstlane_b32 s11, v151
	v_cmp_eq_u64_e32 vcc, s[8:9], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[150:151]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_21
	s_mov_b64 exec, s[6:7]
	s_add_i32 s0, s12, 0x2000
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_23:
	v_readfirstlane_b32 s8, v148
	v_readfirstlane_b32 s9, v149
	v_readfirstlane_b32 s10, v150
	v_readfirstlane_b32 s11, v151
	v_cmp_eq_u64_e32 vcc, s[8:9], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[150:151]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_23
	s_mov_b64 exec, s[6:7]
	s_mov_b32 s5, 0
	s_mov_b32 s12, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s12
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_25:
	v_readfirstlane_b32 s8, v112
	v_readfirstlane_b32 s9, v113
	v_readfirstlane_b32 s10, v114
	v_readfirstlane_b32 s11, v115
	v_cmp_eq_u64_e32 vcc, s[8:9], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[114:115]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v2, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v2, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_25
	s_mov_b64 exec, s[6:7]
	s_add_i32 s0, s12, 0x2000
	s_mov_b64 s[6:7], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_27:
	v_readfirstlane_b32 s8, v112
	v_readfirstlane_b32 s9, v113
	v_readfirstlane_b32 s10, v114
	v_readfirstlane_b32 s11, v115
	v_cmp_eq_u64_e32 vcc, s[8:9], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[114:115]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_27
	s_mov_b64 exec, s[6:7]
	v_lshlrev_b32_e32 v2, 6, v0
	v_lshrrev_b32_e32 v3, 1, v0
	v_lshlrev_b32_e32 v62, 2, v0
	v_and_b32_e32 v63, 16, v0
	v_and_b32_e32 v2, 0x7c0, v2
	v_and_b32_e32 v3, 16, v3
	v_and_or_b32 v5, v62, 32, v63
	v_bitop3_b32 v34, v3, v5, v2 bitop3:0x36
	v_add_u32_e32 v216, s13, v34
	;;#ASMSTART
	ds_read_b128 v[40:43], v216 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[44:47], v216 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[48:51], v216 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[52:55], v216 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[56:59], v216 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[64:67], v216 offset:0x2800

	;;#ASMEND
	v_or_b32_e32 v4, v3, v2
	;;#ASMSTART
	ds_read_b128 v[68:71], v216 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[72:75], v216 offset:0x3800

	;;#ASMEND
	v_bitop3_b32 v38, v4, v5, 32 bitop3:0x36
	v_add_u32_e32 v215, s13, v38
	;;#ASMSTART
	ds_read_b128 v[76:79], v215 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[80:83], v215 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[84:87], v215 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[88:91], v215 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[92:95], v215 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[96:99], v215 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[100:103], v215 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[104:107], v215 offset:0x3800

	;;#ASMEND
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
	v_mfma_f32_32x32x16_bf16 v[18:33], v[40:43], v[144:147], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[56:59], v[144:147], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[76:79], v[140:143], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[92:95], v[140:143], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[44:47], v[136:139], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[64:67], v[136:139], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[80:83], v[132:135], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[96:99], v[132:135], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[48:51], v[128:131], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[68:71], v[128:131], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[84:87], v[124:127], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[100:103], v[124:127], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[52:55], v[120:123], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[72:75], v[120:123], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[88:91], v[116:119], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[104:107], v[116:119], v[2:17]
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
	s_cbranch_execz .LBB0_30
	s_barrier
.LBB0_30:
	s_or_b64 exec, exec, s[6:7]
	v_max_f32_e32 v202, v35, v36
	v_sub_f32_e32 v18, v18, v202
	v_sub_f32_e32 v19, v19, v202
	v_sub_f32_e32 v20, v20, v202
	v_sub_f32_e32 v21, v21, v202
	v_sub_f32_e32 v22, v22, v202
	v_sub_f32_e32 v23, v23, v202
	v_sub_f32_e32 v24, v24, v202
	v_sub_f32_e32 v25, v25, v202
	v_sub_f32_e32 v26, v26, v202
	v_sub_f32_e32 v27, v27, v202
	v_sub_f32_e32 v28, v28, v202
	v_sub_f32_e32 v29, v29, v202
	v_sub_f32_e32 v30, v30, v202
	v_sub_f32_e32 v31, v31, v202
	v_sub_f32_e32 v32, v32, v202
	v_sub_f32_e32 v33, v33, v202
	v_exp_f32_e32 v152, v18
	v_exp_f32_e32 v153, v19
	v_exp_f32_e32 v154, v20
	v_exp_f32_e32 v155, v21
	v_exp_f32_e32 v108, v22
	v_exp_f32_e32 v109, v23
	v_exp_f32_e32 v110, v24
	v_exp_f32_e32 v111, v25
	v_exp_f32_e32 v104, v26
	v_exp_f32_e32 v105, v27
	v_exp_f32_e32 v106, v28
	v_exp_f32_e32 v107, v29
	v_exp_f32_e32 v100, v30
	v_exp_f32_e32 v101, v31
	v_exp_f32_e32 v102, v32
	v_exp_f32_e32 v103, v33
	v_sub_f32_e32 v166, v2, v202
	v_sub_f32_e32 v167, v3, v202
	v_sub_f32_e32 v168, v4, v202
	v_sub_f32_e32 v163, v5, v202
	v_sub_f32_e32 v164, v6, v202
	v_sub_f32_e32 v165, v7, v202
	v_sub_f32_e32 v160, v8, v202
	v_sub_f32_e32 v161, v9, v202
	v_sub_f32_e32 v162, v10, v202
	v_sub_f32_e32 v157, v11, v202
	v_sub_f32_e32 v158, v12, v202
	v_sub_f32_e32 v159, v13, v202
	v_sub_f32_e32 v156, v14, v202
	v_sub_f32_e32 v170, v15, v202
	v_sub_f32_e32 v171, v16, v202
	v_sub_f32_e32 v169, v17, v202
	v_add_u32_e32 v211, s52, v34
	;;#ASMSTART
	ds_read_b128 v[96:99], v211 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[84:87], v211 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[58:61], v211 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[50:53], v211 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v211 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[34:37], v211 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[26:29], v211 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[22:25], v211 offset:0x3800

	;;#ASMEND
	v_add_u32_e32 v212, s52, v38
	;;#ASMSTART
	ds_read_b128 v[92:95], v212 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[88:91], v212 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[80:83], v212 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[54:57], v212 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[46:49], v212 offset:0x2000

	;;#ASMEND
	v_mov_b32_e32 v2, s53
	;;#ASMSTART
	ds_read_b128 v[38:41], v212 offset:0x2800

	;;#ASMEND
	v_alignbit_b32 v2, s54, v2, 25
	;;#ASMSTART
	ds_read_b128 v[30:33], v212 offset:0x3000

	;;#ASMEND
	v_mul_lo_u32 v2, s42, v2
	;;#ASMSTART
	ds_read_b128 v[18:21], v212 offset:0x3800

	;;#ASMEND
	s_mov_b32 s14, s37
	v_readfirstlane_b32 s0, v2
	s_lshl_b32 s5, s0, 1
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s14
	s_mov_b64 s[12:13], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_31:
	v_readfirstlane_b32 s8, v148
	v_readfirstlane_b32 s9, v149
	v_readfirstlane_b32 s10, v150
	v_readfirstlane_b32 s11, v151
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_31
	s_mov_b64 exec, s[12:13]
	s_add_i32 s0, s14, 0x2000
	s_mov_b64 s[12:13], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_33:
	v_readfirstlane_b32 s8, v148
	v_readfirstlane_b32 s9, v149
	v_readfirstlane_b32 s10, v150
	v_readfirstlane_b32 s11, v151
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_33
	s_mov_b64 exec, s[12:13]
	v_mov_b32_e32 v2, s49
	v_alignbit_b32 v2, s50, v2, 26
	v_mul_lo_u32 v2, s51, v2
	s_mov_b32 s14, s27
	v_readfirstlane_b32 s0, v2
	s_lshl_b32 s5, s0, 1
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s14
	s_mov_b64 s[12:13], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_35:
	v_readfirstlane_b32 s8, v112
	v_readfirstlane_b32 s9, v113
	v_readfirstlane_b32 s10, v114
	v_readfirstlane_b32 s11, v115
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v2, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v2, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_35
	s_mov_b64 exec, s[12:13]
	s_add_i32 s0, s14, 0x2000
	s_mov_b64 s[12:13], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_37:
	v_readfirstlane_b32 s8, v112
	v_readfirstlane_b32 s9, v113
	v_readfirstlane_b32 s10, v114
	v_readfirstlane_b32 s11, v115
	v_cmp_eq_u64_e64 s[0:1], s[8:9], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[10:11], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[8:11], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_37
	s_mov_b64 exec, s[12:13]
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
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
	s_mul_i32 s50, s42, s40
	s_mul_i32 s5, s51, s48
	v_mfma_f32_32x32x16_bf16 v[64:79], v[96:99], v[144:147], v[2:17]
	v_exp_f32_e32 v96, v166
	v_exp_f32_e32 v97, v167
	v_exp_f32_e32 v98, v168
	v_mfma_f32_32x32x16_bf16 v[64:79], v[92:95], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[84:87], v[136:139], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[88:91], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[58:61], v[128:131], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[80:83], v[124:127], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[42:45], v[144:147], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[46:49], v[140:143], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[34:37], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[38:41], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[26:29], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[30:33], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[22:25], v[120:123], v[80:95]
	v_exp_f32_e32 v99, v163
	v_exp_f32_e32 v163, v164
	v_exp_f32_e32 v164, v165
	v_exp_f32_e32 v165, v160
	v_exp_f32_e32 v166, v161
	v_exp_f32_e32 v167, v162
	v_exp_f32_e32 v172, v157
	v_exp_f32_e32 v173, v158
	v_exp_f32_e32 v174, v159
	v_exp_f32_e32 v58, v156
	v_exp_f32_e32 v59, v170
	v_exp_f32_e32 v60, v171
	v_exp_f32_e32 v61, v169
	v_lshrrev_b32_e32 v0, 3, v0
	v_mfma_f32_32x32x16_bf16 v[64:79], v[50:53], v[120:123], v[64:79]
	v_and_or_b32 v50, v62, 12, v63
	v_and_b32_e32 v51, 4, v0
	v_lshlrev_b32_e32 v0, 1, v50
	v_and_or_b32 v1, v1, 3, v51
	v_lshl_or_b32 v0, v1, 6, v0
	v_add_u32_e32 v210, s41, v0
	v_add_u32_e32 v209, s43, v0
	v_add_f32_e32 v0, v153, v152
	v_add_f32_e32 v0, v0, v154
	v_add_f32_e32 v0, v0, v155
	v_add_f32_e32 v0, v0, v108
	v_add_f32_e32 v0, v0, v109
	v_add_f32_e32 v0, v0, v110
	v_add_f32_e32 v0, v0, v111
	v_add_f32_e32 v0, v0, v104
	v_add_f32_e32 v0, v0, v105
	v_add_f32_e32 v0, v0, v106
	v_add_f32_e32 v0, v0, v107
	v_add_f32_e32 v0, v0, v100
	v_add_f32_e32 v0, v0, v101
	v_add_f32_e32 v0, v0, v102
	v_add_f32_e32 v0, v0, v103
	v_add_f32_e32 v0, v0, v96
	v_add_f32_e32 v0, v0, v97
	v_add_f32_e32 v0, v0, v98
	v_add_f32_e32 v0, v0, v99
	v_add_f32_e32 v0, v0, v163
	v_add_f32_e32 v0, v0, v164
	v_add_f32_e32 v0, v0, v165
	v_add_f32_e32 v0, v0, v166
	v_add_f32_e32 v0, v0, v167
	v_add_f32_e32 v0, v0, v172
	v_add_f32_e32 v0, v0, v173
	v_add_f32_e32 v0, v0, v174
	v_add_f32_e32 v0, v0, v58
	v_add_f32_e32 v0, v0, v59
	v_add_f32_e32 v0, v0, v60
	v_add_f32_e32 v208, v0, v61
	v_mov_b32_e32 v254, v208
	s_nop 1
	v_permlane32_swap_b32_e64 v208, v254 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[54:57], v[116:119], v[64:79]
	scratch_store_dword off, v51, off offset:16
	s_barrier
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v168, v152, v153
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v169, v154, v155
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v170, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v171, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v156, v104, v105
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[18:21], v[116:119], v[80:95]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v157, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v158, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v159, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v160, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v161, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v162, v163, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v163, v165, v166
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v152, v167, v172
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v153, v173, v174
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v154, v58, v59
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v155, v60, v61
	;;#ASMEND
	s_barrier
	s_mul_i32 s51, s50, 0x180
	s_mov_b32 s52, s33
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_39:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_39
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_41:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_41
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[0:1], v210 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[4:5], v210 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[8:9], v210 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v210 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v210 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v210 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[184:185], v210 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v210 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v210 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[176:177], v210 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v210 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v210 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v210 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v210 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v210 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[234:235], v210 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[2:3], v210 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[6:7], v210 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[10:11], v210 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v210 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v210 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v210 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[186:187], v210 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v210 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[174:175], v210 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[178:179], v210 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v210 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v210 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v210 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v210 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[198:199], v210 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[236:237], v210 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[0:3], v[168:171], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[222:225], v[156:159], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[172:175], v[160:163], v[48:63]
	v_max_f32_e32 v0, v65, v67
	v_max3_f32 v1, v64, v66, v68
	v_max3_f32 v0, v0, v69, v71
	v_max3_f32 v1, v1, v70, v72
	v_max3_f32 v0, v0, v73, v75
	v_mfma_f32_32x32x16_bf16 v[32:47], v[4:7], v[168:171], v[96:111]
	v_max3_f32 v1, v1, v74, v76
	v_max3_f32 v0, v0, v77, v79
	v_max3_f32 v1, v1, v78, v80
	v_max3_f32 v0, v0, v81, v83
	v_max3_f32 v1, v1, v82, v84
	v_mfma_f32_32x32x16_bf16 v[16:31], v[8:11], v[168:171], v[96:111]
	v_max3_f32 v0, v0, v85, v87
	v_max3_f32 v1, v1, v86, v88
	v_max3_f32 v0, v0, v89, v91
	v_max3_f32 v200, v1, v90, v92
	v_max3_f32 v201, v0, v93, v95
	v_mfma_f32_32x32x16_bf16 v[0:15], v[218:221], v[168:171], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[164:167], v[152:155], v[48:63]
	s_nop 5
	v_max3_f32 v96, v200, v94, v201
	v_mov_b32_e32 v97, v96
	s_nop 1
	v_permlane32_swap_b32_e64 v96, v97 bound_ctrl:1
	v_max3_f32 v217, v202, v96, v97
	v_sub_f32_e32 v96, v202, v217
	v_sub_f32_e32 v64, v64, v217
	v_mfma_f32_32x32x16_bf16 v[32:47], v[188:191], v[156:159], v[32:47]
	v_sub_f32_e32 v65, v65, v217
	v_sub_f32_e32 v66, v66, v217
	v_sub_f32_e32 v67, v67, v217
	v_sub_f32_e32 v68, v68, v217
	v_sub_f32_e32 v69, v69, v217
	v_sub_f32_e32 v70, v70, v217
	v_sub_f32_e32 v71, v71, v217
	v_mfma_f32_32x32x16_bf16 v[32:47], v[176:179], v[160:163], v[32:47]
	v_sub_f32_e32 v72, v72, v217
	v_sub_f32_e32 v73, v73, v217
	v_sub_f32_e32 v74, v74, v217
	v_sub_f32_e32 v75, v75, v217
	v_sub_f32_e32 v76, v76, v217
	v_sub_f32_e32 v77, v77, v217
	v_sub_f32_e32 v78, v78, v217
	v_mfma_f32_32x32x16_bf16 v[32:47], v[180:183], v[152:155], v[32:47]
	v_exp_f32_e32 v202, v96
	v_sub_f32_e32 v79, v79, v217
	v_sub_f32_e32 v171, v80, v217
	v_sub_f32_e32 v172, v81, v217
	v_pk_mul_f32 v[52:53], v[202:203], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[202:203], v[50:51] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[202:203], v[48:49] op_sel_hi:[0,1]
	s_nop 4
	v_pk_mul_f32 v[40:41], v[202:203], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[202:203], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[202:203], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[34:35], v[202:203], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[202:203], v[46:47] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[226:229], v[156:159], v[0:15]
	v_pk_mul_f32 v[32:33], v[202:203], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[202:203], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[44:45], v[202:203], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[62:63], v[202:203], v[62:63] op_sel_hi:[0,1]
	v_pk_mul_f32 v[60:61], v[202:203], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[202:203], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[202:203], v[56:57] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[184:187], v[156:159], v[16:31]
	v_pk_mul_f32 v[54:55], v[202:203], v[54:55] op_sel_hi:[0,1]
	v_sub_f32_e32 v173, v82, v217
	v_sub_f32_e32 v168, v83, v217
	v_sub_f32_e32 v169, v84, v217
	v_sub_f32_e32 v170, v85, v217
	v_sub_f32_e32 v84, v86, v217
	v_sub_f32_e32 v85, v87, v217
	v_mfma_f32_32x32x16_bf16 v[16:31], v[192:195], v[160:163], v[16:31]
	v_sub_f32_e32 v86, v88, v217
	v_sub_f32_e32 v81, v89, v217
	v_sub_f32_e32 v82, v90, v217
	v_sub_f32_e32 v83, v91, v217
	v_sub_f32_e32 v80, v92, v217
	v_sub_f32_e32 v88, v93, v217
	v_sub_f32_e32 v89, v94, v217
	v_mfma_f32_32x32x16_bf16 v[16:31], v[196:199], v[152:155], v[16:31]
	v_sub_f32_e32 v87, v95, v217
	s_nop 7
	s_nop 2
	v_pk_mul_f32 v[28:29], v[202:203], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[202:203], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[202:203], v[24:25] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[230:233], v[160:163], v[0:15]
	v_pk_mul_f32 v[22:23], v[202:203], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[202:203], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[202:203], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[202:203], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[202:203], v[30:31] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[234:237], v[152:155], v[0:15]
	s_nop 7
	s_nop 3
	v_pk_mul_f32 v[12:13], v[202:203], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[202:203], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[202:203], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[202:203], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[202:203], v[14:15] op_sel_hi:[0,1]
	v_exp_f32_e32 v166, v66
	v_exp_f32_e32 v164, v69
	v_exp_f32_e32 v165, v64
	v_exp_f32_e32 v167, v65
	v_exp_f32_e32 v161, v72
	v_exp_f32_e32 v162, v67
	v_exp_f32_e32 v163, v68
	v_exp_f32_e32 v158, v75
	v_exp_f32_e32 v159, v70
	v_exp_f32_e32 v160, v71
	v_exp_f32_e32 v155, v78
	v_exp_f32_e32 v156, v73
	v_exp_f32_e32 v157, v74
	v_exp_f32_e32 v152, v79
	v_exp_f32_e32 v153, v76
	v_exp_f32_e32 v154, v77
	v_pk_mul_f32 v[4:5], v[202:203], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[202:203], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[202:203], v[0:1] op_sel_hi:[0,1]
	s_setprio 0
	s_barrier
	s_lshl_b32 s51, s5, 8
	s_mov_b32 s52, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_43:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_43
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_45:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_45
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[90:93], v216 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v216 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v216 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v216 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v216 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[190:193], v216 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[194:197], v216 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[218:221], v216 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[222:225], v215 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[226:229], v215 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[230:233], v215 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[234:237], v215 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[238:241], v215 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[242:245], v215 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[246:249], v215 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[250:253], v215 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v171, v171
	v_exp_f32_e32 v172, v172
	v_exp_f32_e32 v173, v173
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[90:93], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[222:225], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[174:177], v[136:139], v[64:79]
	v_exp_f32_e32 v174, v84
	v_exp_f32_e32 v175, v85
	v_exp_f32_e32 v176, v86
	v_exp_f32_e32 v177, v81
	v_exp_f32_e32 v198, v82
	v_exp_f32_e32 v199, v83
	v_mfma_f32_32x32x16_bf16 v[64:79], v[226:229], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[178:181], v[128:131], v[64:79]
	v_exp_f32_e32 v178, v80
	v_exp_f32_e32 v179, v88
	v_exp_f32_e32 v180, v89
	v_exp_f32_e32 v181, v87
	v_add_f32_e32 v80, v167, v165
	v_add_f32_e32 v80, v80, v166
	v_add_f32_e32 v80, v80, v162
	v_add_f32_e32 v80, v80, v163
	v_add_f32_e32 v80, v80, v164
	v_mfma_f32_32x32x16_bf16 v[64:79], v[230:233], v[124:127], v[64:79]
	v_add_f32_e32 v80, v80, v159
	v_add_f32_e32 v80, v80, v160
	v_add_f32_e32 v80, v80, v161
	v_add_f32_e32 v80, v80, v156
	v_mfma_f32_32x32x16_bf16 v[64:79], v[182:185], v[120:123], v[64:79]
	v_add_f32_e32 v182, v80, v157
	v_mfma_f32_32x32x16_bf16 v[80:95], v[186:189], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[238:241], v[140:143], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[190:193], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[242:245], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[194:197], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[246:249], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[218:221], v[120:123], v[80:95]
	v_exp_f32_e32 v168, v168
	v_exp_f32_e32 v169, v169
	v_exp_f32_e32 v170, v170
	v_add_f32_e32 v96, v182, v158
	v_add_f32_e32 v96, v96, v153
	v_add_f32_e32 v96, v96, v154
	v_add_f32_e32 v96, v96, v155
	v_add_f32_e32 v96, v96, v152
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v172
	v_add_f32_e32 v96, v96, v173
	v_add_f32_e32 v96, v96, v168
	v_add_f32_e32 v96, v96, v169
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v174
	v_add_f32_e32 v96, v96, v175
	v_add_f32_e32 v96, v96, v176
	v_add_f32_e32 v96, v96, v177
	v_add_f32_e32 v96, v96, v198
	v_add_f32_e32 v96, v96, v199
	v_add_f32_e32 v96, v96, v178
	v_add_f32_e32 v96, v96, v179
	v_add_f32_e32 v96, v96, v180
	v_add_f32_e32 v255, v96, v181
	v_mov_b32_e32 v96, v255
	s_nop 1
	v_permlane32_swap_b32_e64 v255, v96 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[234:237], v[116:119], v[64:79]
	scratch_store_dword off, v96, off offset:20
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v165, v167
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v166, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v163, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v159, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v161, v156
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v157, v158
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[250:253], v[116:119], v[80:95]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v153, v154
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v155, v152
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v171, v172
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v173, v168
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v169, v170
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v174, v175
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v176, v177
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v198, v199
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v178, v179
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v180, v181
	;;#ASMEND
	s_barrier
	s_lshl_b32 s51, s50, 9
	s_mov_b32 s52, s37
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_47:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_47
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_49:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_49
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v209 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v209 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v209 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[168:169], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v209 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[176:177], v209 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v209 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[186:187], v209 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v209 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v209 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v209 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v209 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v209 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v209 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[234:235], v209 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v209 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v209 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v209 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v209 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v209 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[174:175], v209 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[178:179], v209 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v209 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v209 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v209 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v209 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v209 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v209 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v209 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v209 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[236:237], v209 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[152:155], v[108:111], v[48:63]
	v_sub_f32_e32 v64, v64, v217
	v_sub_f32_e32 v65, v65, v217
	v_sub_f32_e32 v66, v66, v217
	v_sub_f32_e32 v67, v67, v217
	v_sub_f32_e32 v68, v68, v217
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[108:111], v[32:47]
	v_sub_f32_e32 v69, v69, v217
	v_sub_f32_e32 v70, v70, v217
	v_sub_f32_e32 v71, v71, v217
	v_sub_f32_e32 v72, v72, v217
	v_sub_f32_e32 v73, v73, v217
	v_mfma_f32_32x32x16_bf16 v[16:31], v[160:163], v[108:111], v[16:31]
	v_sub_f32_e32 v74, v74, v217
	v_sub_f32_e32 v75, v75, v217
	v_sub_f32_e32 v76, v76, v217
	v_sub_f32_e32 v77, v77, v217
	v_sub_f32_e32 v78, v78, v217
	v_mfma_f32_32x32x16_bf16 v[0:15], v[164:167], v[108:111], v[0:15]
	v_sub_f32_e32 v79, v79, v217
	v_mfma_f32_32x32x16_bf16 v[48:63], v[168:171], v[104:107], v[48:63]
	v_sub_f32_e32 v168, v80, v217
	v_sub_f32_e32 v169, v81, v217
	v_sub_f32_e32 v170, v82, v217
	v_sub_f32_e32 v82, v83, v217
	v_sub_f32_e32 v171, v84, v217
	v_mfma_f32_32x32x16_bf16 v[32:47], v[172:175], v[104:107], v[32:47]
	v_sub_f32_e32 v172, v85, v217
	v_sub_f32_e32 v83, v86, v217
	v_sub_f32_e32 v84, v87, v217
	v_sub_f32_e32 v85, v88, v217
	v_sub_f32_e32 v86, v89, v217
	v_mfma_f32_32x32x16_bf16 v[16:31], v[176:179], v[104:107], v[16:31]
	v_sub_f32_e32 v87, v90, v217
	v_sub_f32_e32 v88, v91, v217
	v_sub_f32_e32 v80, v92, v217
	v_sub_f32_e32 v81, v93, v217
	v_sub_f32_e32 v90, v94, v217
	v_mfma_f32_32x32x16_bf16 v[0:15], v[180:183], v[104:107], v[0:15]
	v_sub_f32_e32 v89, v95, v217
	v_mfma_f32_32x32x16_bf16 v[48:63], v[186:189], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[190:193], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[194:197], v[100:103], v[16:31]
	v_exp_f32_e32 v156, v64
	v_exp_f32_e32 v158, v65
	v_exp_f32_e32 v152, v66
	v_mfma_f32_32x32x16_bf16 v[0:15], v[218:221], v[100:103], v[0:15]
	v_exp_f32_e32 v153, v67
	v_exp_f32_e32 v154, v68
	v_exp_f32_e32 v155, v69
	v_mfma_f32_32x32x16_bf16 v[48:63], v[222:225], v[96:99], v[48:63]
	v_exp_f32_e32 v157, v70
	v_exp_f32_e32 v159, v71
	v_exp_f32_e32 v160, v72
	v_mfma_f32_32x32x16_bf16 v[32:47], v[226:229], v[96:99], v[32:47]
	v_exp_f32_e32 v161, v73
	v_exp_f32_e32 v162, v74
	v_exp_f32_e32 v163, v75
	v_mfma_f32_32x32x16_bf16 v[16:31], v[230:233], v[96:99], v[16:31]
	v_exp_f32_e32 v164, v76
	v_exp_f32_e32 v165, v77
	v_exp_f32_e32 v166, v78
	v_mfma_f32_32x32x16_bf16 v[0:15], v[234:237], v[96:99], v[0:15]
	v_exp_f32_e32 v167, v79
	s_setprio 0
	s_barrier
	s_mul_i32 s51, s5, 0x180
	s_mov_b32 s52, s27
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_51:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_51
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_53:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_53
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[92:95], v211 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v211 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v211 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v211 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[190:193], v211 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[194:197], v211 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[218:221], v211 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[222:225], v211 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[226:229], v212 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[230:233], v212 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[234:237], v212 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[238:241], v212 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[242:245], v212 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[246:249], v212 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[250:253], v212 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[198:201], v212 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v168, v168
	v_exp_f32_e32 v169, v169
	v_exp_f32_e32 v170, v170
	v_exp_f32_e32 v173, v82
	v_exp_f32_e32 v182, v85
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[92:95], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[226:229], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[174:177], v[136:139], v[64:79]
	v_exp_f32_e32 v174, v83
	v_exp_f32_e32 v175, v84
	v_exp_f32_e32 v183, v86
	v_exp_f32_e32 v184, v87
	v_exp_f32_e32 v185, v88
	v_exp_f32_e32 v204, v90
	v_mfma_f32_32x32x16_bf16 v[64:79], v[230:233], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[178:181], v[128:131], v[64:79]
	v_exp_f32_e32 v180, v80
	v_exp_f32_e32 v181, v81
	v_exp_f32_e32 v205, v89
	v_add_f32_e32 v80, v158, v156
	v_add_f32_e32 v80, v80, v152
	v_add_f32_e32 v80, v80, v153
	v_add_f32_e32 v80, v80, v154
	v_add_f32_e32 v80, v80, v155
	v_add_f32_e32 v80, v80, v157
	v_add_f32_e32 v80, v80, v159
	v_add_f32_e32 v80, v80, v160
	v_add_f32_e32 v80, v80, v161
	v_add_f32_e32 v176, v80, v162
	v_mfma_f32_32x32x16_bf16 v[80:95], v[190:193], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[242:245], v[140:143], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[194:197], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[246:249], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[218:221], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[250:253], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[222:225], v[120:123], v[80:95]
	v_exp_f32_e32 v171, v171
	v_exp_f32_e32 v172, v172
	v_add_f32_e32 v96, v176, v163
	v_add_f32_e32 v96, v96, v164
	v_add_f32_e32 v96, v96, v165
	v_add_f32_e32 v96, v96, v166
	v_add_f32_e32 v96, v96, v167
	v_add_f32_e32 v96, v96, v168
	v_add_f32_e32 v96, v96, v169
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v173
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v172
	v_add_f32_e32 v96, v96, v174
	v_add_f32_e32 v96, v96, v175
	v_add_f32_e32 v96, v96, v182
	v_add_f32_e32 v96, v96, v183
	v_add_f32_e32 v96, v96, v184
	v_add_f32_e32 v96, v96, v185
	v_add_f32_e32 v96, v96, v180
	v_add_f32_e32 v96, v96, v181
	v_add_f32_e32 v96, v96, v204
	v_mfma_f32_32x32x16_bf16 v[64:79], v[234:237], v[124:127], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v176, v156, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v177, v152, v153
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v178, v154, v155
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v179, v157, v159
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v160, v161
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v162, v163
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v164, v165
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[186:189], v[120:123], v[64:79]
	v_add_f32_e32 v186, v96, v205
	v_mov_b32_e32 v187, v186
	s_nop 1
	v_permlane32_swap_b32_e64 v186, v187 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v166, v167
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v168, v169
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v170, v173
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[238:241], v[116:119], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v171, v172
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v174, v175
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v182, v183
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v184, v185
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v180, v181
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v204, v205
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[198:201], v[116:119], v[80:95]
	s_barrier
	s_mul_i32 s51, s50, 0x280
	s_mov_b32 s52, s33
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_55:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_55
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_57:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_57
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v210 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v210 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v210 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v210 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v210 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[168:169], v210 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v210 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v210 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[152:153], v210 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v210 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v210 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v210 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v210 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v210 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v210 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[234:235], v210 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v210 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v210 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[198:199], v210 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v210 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v210 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v210 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v210 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v210 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v210 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v210 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[174:175], v210 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v210 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v210 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v210 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v210 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[236:237], v210 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[188:191], v[176:179], v[48:63]
	v_max_f32_e32 v184, v65, v67
	v_max3_f32 v185, v64, v66, v68
	v_max3_f32 v184, v184, v69, v71
	v_max3_f32 v185, v185, v70, v72
	v_max3_f32 v184, v184, v73, v75
	v_mfma_f32_32x32x16_bf16 v[32:47], v[192:195], v[176:179], v[32:47]
	v_max3_f32 v185, v185, v74, v76
	v_max3_f32 v184, v184, v77, v79
	v_max3_f32 v185, v185, v78, v80
	v_max3_f32 v184, v184, v81, v83
	v_max3_f32 v185, v185, v82, v84
	v_mfma_f32_32x32x16_bf16 v[16:31], v[196:199], v[176:179], v[16:31]
	v_max3_f32 v184, v184, v85, v87
	v_max3_f32 v185, v185, v86, v88
	v_max3_f32 v184, v184, v89, v91
	v_max3_f32 v185, v185, v90, v92
	v_max3_f32 v184, v184, v93, v95
	v_mfma_f32_32x32x16_bf16 v[0:15], v[218:221], v[176:179], v[0:15]
	v_max3_f32 v176, v185, v94, v184
	v_mov_b32_e32 v177, v176
	s_nop 1
	v_permlane32_swap_b32_e64 v176, v177 bound_ctrl:1
	v_max3_f32 v177, v217, v176, v177
	v_sub_f32_e32 v176, v217, v177
	v_sub_f32_e32 v64, v64, v177
	v_mfma_f32_32x32x16_bf16 v[48:63], v[222:225], v[104:107], v[48:63]
	v_sub_f32_e32 v65, v65, v177
	v_sub_f32_e32 v66, v66, v177
	v_sub_f32_e32 v67, v67, v177
	v_sub_f32_e32 v68, v68, v177
	v_sub_f32_e32 v69, v69, v177
	v_sub_f32_e32 v70, v70, v177
	v_sub_f32_e32 v71, v71, v177
	v_mfma_f32_32x32x16_bf16 v[48:63], v[152:155], v[100:103], v[48:63]
	v_sub_f32_e32 v72, v72, v177
	v_sub_f32_e32 v73, v73, v177
	v_sub_f32_e32 v74, v74, v177
	v_sub_f32_e32 v75, v75, v177
	v_sub_f32_e32 v76, v76, v177
	v_sub_f32_e32 v77, v77, v177
	v_sub_f32_e32 v78, v78, v177
	v_mfma_f32_32x32x16_bf16 v[48:63], v[108:111], v[96:99], v[48:63]
	v_exp_f32_e32 v176, v176
	v_sub_f32_e32 v79, v79, v177
	v_sub_f32_e32 v152, v83, v177
	v_sub_f32_e32 v153, v84, v177
	v_sub_f32_e32 v84, v86, v177
	v_sub_f32_e32 v86, v88, v177
	v_sub_f32_e32 v83, v91, v177
	s_nop 4
	v_pk_mul_f32 v[60:61], v[176:177], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[176:177], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[176:177], v[56:57] op_sel_hi:[0,1]
	v_pk_mul_f32 v[54:55], v[176:177], v[54:55] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[226:229], v[104:107], v[0:15]
	v_sub_f32_e32 v88, v93, v177
	v_mfma_f32_32x32x16_bf16 v[0:15], v[230:233], v[100:103], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[234:237], v[96:99], v[0:15]
	s_nop 7
	s_nop 3
	v_pk_mul_f32 v[4:5], v[176:177], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[176:177], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[176:177], v[50:51] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[176:177], v[48:49] op_sel_hi:[0,1]
	v_pk_mul_f32 v[62:63], v[176:177], v[62:63] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[168:171], v[104:107], v[32:47]
	v_pk_mul_f32 v[2:3], v[176:177], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[176:177], v[0:1] op_sel_hi:[0,1]
	v_sub_f32_e32 v171, v80, v177
	v_sub_f32_e32 v170, v85, v177
	v_sub_f32_e32 v85, v87, v177
	v_sub_f32_e32 v80, v92, v177
	v_sub_f32_e32 v87, v95, v177
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[160:163], v[96:99], v[32:47]
	s_nop 7
	s_nop 3
	v_pk_mul_f32 v[44:45], v[176:177], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[40:41], v[176:177], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[176:177], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[176:177], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[34:35], v[176:177], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[176:177], v[46:47] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[176:177], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[176:177], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[176:177], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[176:177], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[176:177], v[14:15] op_sel_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[164:167], v[104:107], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[172:175], v[100:103], v[16:31]
	v_sub_f32_e32 v172, v81, v177
	v_sub_f32_e32 v173, v82, v177
	v_sub_f32_e32 v81, v89, v177
	v_sub_f32_e32 v82, v90, v177
	v_sub_f32_e32 v89, v94, v177
	v_mfma_f32_32x32x16_bf16 v[16:31], v[180:183], v[96:99], v[16:31]
	s_nop 7
	s_nop 3
	v_pk_mul_f32 v[22:23], v[176:177], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[176:177], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[176:177], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[176:177], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[176:177], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[176:177], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[176:177], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[176:177], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[176:177], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[176:177], v[42:43] op_sel_hi:[0,1]
	v_exp_f32_e32 v168, v66
	v_exp_f32_e32 v166, v69
	v_exp_f32_e32 v167, v64
	v_exp_f32_e32 v169, v65
	v_exp_f32_e32 v163, v72
	v_exp_f32_e32 v164, v67
	v_exp_f32_e32 v165, v68
	v_exp_f32_e32 v160, v75
	v_exp_f32_e32 v161, v70
	v_exp_f32_e32 v162, v71
	v_exp_f32_e32 v157, v78
	v_exp_f32_e32 v158, v73
	v_exp_f32_e32 v159, v74
	v_exp_f32_e32 v154, v79
	v_exp_f32_e32 v155, v76
	v_exp_f32_e32 v156, v77
	s_setprio 0
	s_barrier
	s_lshl_b32 s51, s5, 9
	s_mov_b32 s52, s29
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s52
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_59:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_59
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s52, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_61:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_61
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[90:93], v216 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v216 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[188:191], v216 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[192:195], v216 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[196:199], v216 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[218:221], v216 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[222:225], v216 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[226:229], v216 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[230:233], v215 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[234:237], v215 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[238:241], v215 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[242:245], v215 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[246:249], v215 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[250:253], v215 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v215 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[204:207], v215 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v171, v171
	v_exp_f32_e32 v172, v172
	v_exp_f32_e32 v173, v173
	v_exp_f32_e32 v174, v152
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[90:93], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[230:233], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[178:181], v[136:139], v[64:79]
	v_exp_f32_e32 v178, v84
	v_exp_f32_e32 v179, v85
	v_exp_f32_e32 v180, v86
	v_exp_f32_e32 v181, v81
	v_exp_f32_e32 v200, v82
	v_exp_f32_e32 v201, v83
	v_mfma_f32_32x32x16_bf16 v[64:79], v[234:237], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[188:191], v[128:131], v[64:79]
	v_exp_f32_e32 v188, v80
	v_exp_f32_e32 v189, v88
	v_exp_f32_e32 v190, v89
	v_exp_f32_e32 v191, v87
	v_add_f32_e32 v80, v169, v167
	v_add_f32_e32 v80, v80, v168
	v_add_f32_e32 v80, v80, v164
	v_add_f32_e32 v80, v80, v165
	v_add_f32_e32 v80, v80, v166
	v_add_f32_e32 v80, v80, v161
	v_add_f32_e32 v80, v80, v162
	v_add_f32_e32 v80, v80, v163
	v_add_f32_e32 v80, v80, v158
	v_add_f32_e32 v152, v80, v159
	v_mfma_f32_32x32x16_bf16 v[80:95], v[196:199], v[144:147], v[96:111]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v167, v169
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v168, v164
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v165, v166
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v161, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v163, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v159, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v155, v156
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[246:249], v[140:143], v[80:95]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v157, v154
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v171, v172
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v173, v174
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[218:221], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[250:253], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[222:225], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[182:185], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[226:229], v[120:123], v[80:95]
	v_exp_f32_e32 v175, v153
	v_exp_f32_e32 v170, v170
	v_add_f32_e32 v96, v152, v160
	v_add_f32_e32 v96, v96, v155
	v_add_f32_e32 v96, v96, v156
	v_add_f32_e32 v96, v96, v157
	v_add_f32_e32 v96, v96, v154
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v172
	v_add_f32_e32 v96, v96, v173
	v_add_f32_e32 v96, v96, v174
	v_add_f32_e32 v96, v96, v175
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v178
	v_add_f32_e32 v96, v96, v179
	v_add_f32_e32 v96, v96, v180
	v_add_f32_e32 v96, v96, v181
	v_add_f32_e32 v96, v96, v200
	v_add_f32_e32 v96, v96, v201
	v_add_f32_e32 v96, v96, v188
	v_add_f32_e32 v96, v96, v189
	v_add_f32_e32 v96, v96, v190
	v_add_f32_e32 v152, v96, v191
	v_mov_b32_e32 v153, v152
	s_nop 1
	v_permlane32_swap_b32_e64 v152, v153 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[238:241], v[124:127], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v175, v170
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v178, v179
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v180, v181
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v200, v201
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v188, v189
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v190, v191
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[192:195], v[120:123], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[242:245], v[116:119], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[204:207], v[116:119], v[80:95]
	s_barrier
	s_mul_i32 s51, s50, 0x300
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s37
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_63:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_63
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s37, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_65:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[40:43], s51 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_65
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[154:155], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v209 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v209 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v209 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[178:179], v209 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v209 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v209 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v209 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v209 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[204:205], v209 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v209 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v209 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v209 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v209 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[234:235], v209 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v209 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v209 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v209 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[168:169], v209 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v209 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v209 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[184:185], v209 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v209 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v209 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[198:199], v209 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[206:207], v209 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v209 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v209 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v209 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v209 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[236:237], v209 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[154:157], v[108:111], v[48:63]
	v_sub_f32_e32 v64, v64, v177
	v_sub_f32_e32 v65, v65, v177
	v_sub_f32_e32 v66, v66, v177
	v_sub_f32_e32 v67, v67, v177
	v_sub_f32_e32 v68, v68, v177
	v_mfma_f32_32x32x16_bf16 v[32:47], v[158:161], v[108:111], v[32:47]
	v_sub_f32_e32 v69, v69, v177
	v_sub_f32_e32 v70, v70, v177
	v_sub_f32_e32 v71, v71, v177
	v_sub_f32_e32 v72, v72, v177
	v_sub_f32_e32 v73, v73, v177
	v_mfma_f32_32x32x16_bf16 v[16:31], v[162:165], v[108:111], v[16:31]
	v_sub_f32_e32 v74, v74, v177
	v_sub_f32_e32 v75, v75, v177
	v_sub_f32_e32 v76, v76, v177
	v_sub_f32_e32 v77, v77, v177
	v_sub_f32_e32 v78, v78, v177
	v_mfma_f32_32x32x16_bf16 v[0:15], v[166:169], v[108:111], v[0:15]
	v_sub_f32_e32 v79, v79, v177
	v_sub_f32_e32 v154, v80, v177
	v_sub_f32_e32 v155, v81, v177
	v_sub_f32_e32 v174, v85, v177
	v_sub_f32_e32 v85, v88, v177
	v_mfma_f32_32x32x16_bf16 v[48:63], v[170:173], v[104:107], v[48:63]
	v_sub_f32_e32 v172, v82, v177
	v_sub_f32_e32 v82, v83, v177
	v_sub_f32_e32 v173, v84, v177
	v_sub_f32_e32 v83, v86, v177
	v_sub_f32_e32 v84, v87, v177
	v_mfma_f32_32x32x16_bf16 v[32:47], v[178:181], v[104:107], v[32:47]
	v_sub_f32_e32 v86, v89, v177
	v_sub_f32_e32 v87, v90, v177
	v_sub_f32_e32 v88, v91, v177
	v_sub_f32_e32 v80, v92, v177
	v_sub_f32_e32 v81, v93, v177
	v_mfma_f32_32x32x16_bf16 v[16:31], v[182:185], v[104:107], v[16:31]
	v_sub_f32_e32 v90, v94, v177
	v_sub_f32_e32 v89, v95, v177
	v_mfma_f32_32x32x16_bf16 v[0:15], v[188:191], v[104:107], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[192:195], v[100:103], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[196:199], v[100:103], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[204:207], v[100:103], v[16:31]
	v_exp_f32_e32 v156, v64
	v_exp_f32_e32 v158, v65
	v_exp_f32_e32 v157, v66
	v_mfma_f32_32x32x16_bf16 v[0:15], v[218:221], v[100:103], v[0:15]
	v_exp_f32_e32 v159, v67
	v_exp_f32_e32 v160, v68
	v_exp_f32_e32 v161, v69
	v_mfma_f32_32x32x16_bf16 v[48:63], v[222:225], v[96:99], v[48:63]
	v_exp_f32_e32 v162, v70
	v_exp_f32_e32 v163, v71
	v_exp_f32_e32 v164, v72
	v_mfma_f32_32x32x16_bf16 v[32:47], v[226:229], v[96:99], v[32:47]
	v_exp_f32_e32 v165, v73
	v_exp_f32_e32 v166, v74
	v_exp_f32_e32 v167, v75
	v_mfma_f32_32x32x16_bf16 v[16:31], v[230:233], v[96:99], v[16:31]
	v_exp_f32_e32 v168, v76
	v_exp_f32_e32 v169, v77
	v_exp_f32_e32 v170, v78
	v_mfma_f32_32x32x16_bf16 v[0:15], v[234:237], v[96:99], v[0:15]
	v_exp_f32_e32 v171, v79
	s_setprio 0
	s_barrier
	s_mul_i32 s37, s5, 0x280
	s_mov_b32 s51, s27
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s51
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_67:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_67
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s51, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_69:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_69
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[92:95], v211 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v211 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v211 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[188:191], v211 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[192:195], v211 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[196:199], v211 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[204:207], v211 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[218:221], v211 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[222:225], v212 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[226:229], v212 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[230:233], v212 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[234:237], v212 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[238:241], v212 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[242:245], v212 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[246:249], v212 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[250:253], v212 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v175, v154
	v_exp_f32_e32 v200, v155
	v_exp_f32_e32 v172, v172
	v_exp_f32_e32 v201, v82
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[92:95], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[222:225], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[178:181], v[136:139], v[64:79]
	v_exp_f32_e32 v178, v83
	v_exp_f32_e32 v179, v84
	v_exp_f32_e32 v180, v85
	v_exp_f32_e32 v181, v86
	v_exp_f32_e32 v217, v87
	v_exp_f32_e32 v222, v88
	v_mfma_f32_32x32x16_bf16 v[64:79], v[226:229], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[182:185], v[128:131], v[64:79]
	v_exp_f32_e32 v182, v80
	v_exp_f32_e32 v183, v81
	v_exp_f32_e32 v184, v90
	v_exp_f32_e32 v185, v89
	v_add_f32_e32 v80, v158, v156
	v_add_f32_e32 v80, v80, v157
	v_add_f32_e32 v80, v80, v159
	v_add_f32_e32 v80, v80, v160
	v_add_f32_e32 v80, v80, v161
	v_add_f32_e32 v80, v80, v162
	v_add_f32_e32 v80, v80, v163
	v_add_f32_e32 v80, v80, v164
	v_add_f32_e32 v80, v80, v165
	v_add_f32_e32 v154, v80, v166
	v_mfma_f32_32x32x16_bf16 v[80:95], v[192:195], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[238:241], v[140:143], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[196:199], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[242:245], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[204:207], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[246:249], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[218:221], v[120:123], v[80:95]
	v_exp_f32_e32 v173, v173
	v_exp_f32_e32 v174, v174
	v_add_f32_e32 v96, v154, v167
	v_add_f32_e32 v96, v96, v168
	v_add_f32_e32 v96, v96, v169
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v175
	v_add_f32_e32 v96, v96, v200
	v_add_f32_e32 v96, v96, v172
	v_add_f32_e32 v96, v96, v201
	v_add_f32_e32 v96, v96, v173
	v_add_f32_e32 v96, v96, v174
	v_add_f32_e32 v96, v96, v178
	v_add_f32_e32 v96, v96, v179
	v_add_f32_e32 v96, v96, v180
	v_add_f32_e32 v96, v96, v181
	v_add_f32_e32 v96, v96, v217
	v_add_f32_e32 v96, v96, v222
	v_add_f32_e32 v96, v96, v182
	v_add_f32_e32 v96, v96, v183
	v_add_f32_e32 v96, v96, v184
	v_add_f32_e32 v154, v96, v185
	v_mov_b32_e32 v155, v154
	s_nop 1
	v_permlane32_swap_b32_e64 v154, v155 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[230:233], v[124:127], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v156, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v157, v159
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v160, v161
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v162, v163
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v164, v165
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v166, v167
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v168, v169
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[188:191], v[120:123], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v170, v171
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v175, v200
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v172, v201
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v173, v174
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v178, v179
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v180, v181
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v217, v222
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[234:237], v[116:119], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v182, v183
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v184, v185
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[250:253], v[116:119], v[80:95]
	s_barrier
	s_mul_i32 s37, s50, 0x380
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s33
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_71:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v214, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_71
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s33, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_73:
	v_readfirstlane_b32 s40, v148
	v_readfirstlane_b32 s41, v149
	v_readfirstlane_b32 s42, v150
	v_readfirstlane_b32 s43, v151
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[148:149]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[150:151]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v213, s[40:43], s37 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_73
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b64_tr_b16 v[148:149], v210 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v210 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v210 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v210 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[168:169], v210 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v210 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[178:179], v210 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v210 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v210 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v210 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v210 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[204:205], v210 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v210 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v210 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v210 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v210 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[150:151], v210 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v210 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v210 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v210 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v210 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[174:175], v210 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v210 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[184:185], v210 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v210 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v210 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[198:199], v210 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[206:207], v210 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v210 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v210 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v210 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v210 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[148:151], v[96:99], v[48:63]
	v_max_f32_e32 v148, v65, v67
	v_max3_f32 v149, v64, v66, v68
	v_max3_f32 v148, v148, v69, v71
	v_max3_f32 v149, v149, v70, v72
	v_max3_f32 v148, v148, v73, v75
	v_mfma_f32_32x32x16_bf16 v[48:63], v[168:171], v[100:103], v[48:63]
	v_max3_f32 v149, v149, v74, v76
	v_max3_f32 v148, v148, v77, v79
	v_max3_f32 v149, v149, v78, v80
	v_max3_f32 v148, v148, v81, v83
	v_max3_f32 v149, v149, v82, v84
	v_mfma_f32_32x32x16_bf16 v[48:63], v[188:191], v[108:111], v[48:63]
	v_max3_f32 v148, v148, v85, v87
	v_max3_f32 v149, v149, v86, v88
	v_max3_f32 v148, v148, v89, v91
	v_max3_f32 v149, v149, v90, v92
	v_max3_f32 v148, v148, v93, v95
	v_mfma_f32_32x32x16_bf16 v[48:63], v[218:221], v[104:107], v[48:63]
	v_max3_f32 v148, v149, v94, v148
	v_mov_b32_e32 v149, v148
	s_nop 1
	v_permlane32_swap_b32_e64 v148, v149 bound_ctrl:1
	v_max3_f32 v150, v177, v148, v149
	v_sub_f32_e32 v148, v177, v150
	v_mfma_f32_32x32x16_bf16 v[32:47], v[156:159], v[96:99], v[32:47]
	v_sub_f32_e32 v64, v64, v150
	v_sub_f32_e32 v65, v65, v150
	v_sub_f32_e32 v66, v66, v150
	v_sub_f32_e32 v67, v67, v150
	v_sub_f32_e32 v68, v68, v150
	v_mfma_f32_32x32x16_bf16 v[32:47], v[172:175], v[100:103], v[32:47]
	v_sub_f32_e32 v69, v69, v150
	v_sub_f32_e32 v70, v70, v150
	v_sub_f32_e32 v71, v71, v150
	v_sub_f32_e32 v72, v72, v150
	v_sub_f32_e32 v73, v73, v150
	v_mfma_f32_32x32x16_bf16 v[32:47], v[192:195], v[108:111], v[32:47]
	v_sub_f32_e32 v74, v74, v150
	v_sub_f32_e32 v75, v75, v150
	v_sub_f32_e32 v76, v76, v150
	v_sub_f32_e32 v77, v77, v150
	v_sub_f32_e32 v78, v78, v150
	v_mfma_f32_32x32x16_bf16 v[32:47], v[222:225], v[104:107], v[32:47]
	v_sub_f32_e32 v79, v79, v150
	v_sub_f32_e32 v151, v80, v150
	v_sub_f32_e32 v172, v81, v150
	v_sub_f32_e32 v173, v82, v150
	v_sub_f32_e32 v149, v83, v150
	v_sub_f32_e32 v83, v94, v150
	v_mfma_f32_32x32x16_bf16 v[16:31], v[160:163], v[96:99], v[16:31]
	v_sub_f32_e32 v84, v84, v150
	v_sub_f32_e32 v174, v85, v150
	v_sub_f32_e32 v85, v86, v150
	v_sub_f32_e32 v86, v87, v150
	v_sub_f32_e32 v87, v88, v150
	v_mfma_f32_32x32x16_bf16 v[16:31], v[178:181], v[100:103], v[16:31]
	v_sub_f32_e32 v80, v89, v150
	v_sub_f32_e32 v88, v90, v150
	v_sub_f32_e32 v89, v91, v150
	v_sub_f32_e32 v81, v92, v150
	v_sub_f32_e32 v82, v93, v150
	v_sub_f32_e32 v90, v95, v150
	v_mfma_f32_32x32x16_bf16 v[16:31], v[196:199], v[108:111], v[16:31]
	v_exp_f32_e32 v148, v148
	v_exp_f32_e32 v156, v64
	v_exp_f32_e32 v157, v65
	v_mfma_f32_32x32x16_bf16 v[16:31], v[226:229], v[104:107], v[16:31]
	v_exp_f32_e32 v158, v66
	v_exp_f32_e32 v159, v67
	v_exp_f32_e32 v160, v68
	v_mfma_f32_32x32x16_bf16 v[0:15], v[164:167], v[96:99], v[0:15]
	v_exp_f32_e32 v161, v69
	v_exp_f32_e32 v162, v70
	v_exp_f32_e32 v163, v71
	v_mfma_f32_32x32x16_bf16 v[0:15], v[182:185], v[100:103], v[0:15]
	v_exp_f32_e32 v164, v72
	v_exp_f32_e32 v165, v73
	v_exp_f32_e32 v166, v74
	v_mfma_f32_32x32x16_bf16 v[0:15], v[204:207], v[108:111], v[0:15]
	v_exp_f32_e32 v167, v75
	v_exp_f32_e32 v168, v76
	v_exp_f32_e32 v169, v77
	v_mfma_f32_32x32x16_bf16 v[0:15], v[230:233], v[104:107], v[0:15]
	v_exp_f32_e32 v170, v78
	v_exp_f32_e32 v171, v79
	v_pk_mul_f32 v[62:63], v[148:149], v[62:63] op_sel_hi:[0,1]
	v_pk_mul_f32 v[60:61], v[148:149], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[148:149], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[148:149], v[56:57] op_sel_hi:[0,1]
	v_pk_mul_f32 v[54:55], v[148:149], v[54:55] op_sel_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[148:149], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[148:149], v[50:51] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[148:149], v[48:49] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[148:149], v[46:47] op_sel_hi:[0,1]
	v_pk_mul_f32 v[44:45], v[148:149], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[148:149], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[40:41], v[148:149], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[148:149], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[148:149], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[34:35], v[148:149], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[148:149], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[148:149], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[148:149], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[148:149], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[148:149], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[148:149], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[148:149], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[148:149], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[148:149], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[148:149], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[148:149], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[148:149], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[148:149], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[148:149], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[148:149], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[148:149], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[148:149], v[0:1] op_sel_hi:[0,1]
	s_setprio 0
	s_barrier
	s_mul_i32 s33, s5, 0x300
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s29
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_75:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s33 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_75
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s29, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_77:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s33 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_77
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[92:95], v216 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v216 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v216 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[188:191], v216 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[192:195], v216 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[196:199], v216 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[204:207], v216 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[216:219], v216 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[220:223], v215 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[224:227], v215 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[228:231], v215 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[232:235], v215 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[236:239], v215 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[240:243], v215 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[244:247], v215 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[248:251], v215 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v175, v151
	v_exp_f32_e32 v172, v172
	v_exp_f32_e32 v173, v173
	v_exp_f32_e32 v177, v149
	v_exp_f32_e32 v200, v84
	v_mov_b64_e32 v[110:111], s[22:23]
	v_mov_b64_e32 v[108:109], s[20:21]
	v_mov_b64_e32 v[106:107], s[18:19]
	v_mov_b64_e32 v[104:105], s[16:17]
	v_mov_b64_e32 v[102:103], s[14:15]
	v_mov_b64_e32 v[100:101], s[12:13]
	v_mov_b64_e32 v[98:99], s[10:11]
	v_mov_b64_e32 v[96:97], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[92:95], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[220:223], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[178:181], v[136:139], v[64:79]
	v_exp_f32_e32 v178, v85
	v_exp_f32_e32 v179, v86
	v_exp_f32_e32 v180, v87
	v_exp_f32_e32 v181, v80
	v_exp_f32_e32 v201, v88
	v_exp_f32_e32 v213, v89
	v_mfma_f32_32x32x16_bf16 v[64:79], v[224:227], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[182:185], v[128:131], v[64:79]
	v_exp_f32_e32 v182, v81
	v_exp_f32_e32 v183, v82
	v_exp_f32_e32 v184, v83
	v_exp_f32_e32 v185, v90
	v_add_f32_e32 v80, v157, v156
	v_add_f32_e32 v80, v80, v158
	v_add_f32_e32 v80, v80, v159
	v_add_f32_e32 v80, v80, v160
	v_add_f32_e32 v80, v80, v161
	v_add_f32_e32 v80, v80, v162
	v_add_f32_e32 v80, v80, v163
	v_add_f32_e32 v80, v80, v164
	v_add_f32_e32 v80, v80, v165
	v_add_f32_e32 v149, v80, v166
	v_mfma_f32_32x32x16_bf16 v[80:95], v[192:195], v[144:147], v[96:111]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[236:239], v[140:143], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[196:199], v[136:139], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[240:243], v[132:135], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[204:207], v[128:131], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[244:247], v[124:127], v[80:95]
	v_mfma_f32_32x32x16_bf16 v[80:95], v[216:219], v[120:123], v[80:95]
	v_exp_f32_e32 v174, v174
	v_add_f32_e32 v96, v149, v167
	v_add_f32_e32 v96, v96, v168
	v_add_f32_e32 v96, v96, v169
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v175
	v_add_f32_e32 v96, v96, v172
	v_add_f32_e32 v96, v96, v173
	v_add_f32_e32 v96, v96, v177
	v_add_f32_e32 v96, v96, v200
	v_add_f32_e32 v96, v96, v174
	v_add_f32_e32 v96, v96, v178
	v_add_f32_e32 v96, v96, v179
	v_add_f32_e32 v96, v96, v180
	v_add_f32_e32 v96, v96, v181
	v_add_f32_e32 v96, v96, v201
	v_add_f32_e32 v96, v96, v213
	v_add_f32_e32 v96, v96, v182
	v_add_f32_e32 v96, v96, v183
	v_add_f32_e32 v96, v96, v184
	v_add_f32_e32 v149, v96, v185
	v_mov_b32_e32 v151, v149
	s_nop 1
	v_permlane32_swap_b32_e64 v149, v151 bound_ctrl:1
	v_mfma_f32_32x32x16_bf16 v[64:79], v[228:231], v[124:127], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v156, v157
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v158, v159
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v160, v161
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v162, v163
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v164, v165
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v166, v167
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v168, v169
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[188:191], v[120:123], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v170, v171
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v175, v172
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v173, v177
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v200, v174
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v178, v179
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v180, v181
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v201, v213
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[232:235], v[116:119], v[64:79]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v182, v183
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v184, v185
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[248:251], v[116:119], v[80:95]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v209 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v209 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v209 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v209 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v209 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[196:197], v209 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[204:205], v209 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[214:215], v209 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[218:219], v209 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[222:223], v209 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[226:227], v209 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[230:231], v209 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[234:235], v209 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[238:239], v209 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v209 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v209 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v209 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v209 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v209 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v209 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v209 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[198:199], v209 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[206:207], v209 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[216:217], v209 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[220:221], v209 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[224:225], v209 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[228:229], v209 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[232:233], v209 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[236:237], v209 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[240:241], v209 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[48:63], v[156:159], v[96:99], v[48:63]
	s_nop 6
	v_max_f32_e32 v156, v65, v67
	v_max3_f32 v157, v64, v66, v68
	v_max3_f32 v156, v156, v69, v71
	v_max3_f32 v157, v157, v70, v72
	v_max3_f32 v156, v156, v73, v75
	v_mfma_f32_32x32x16_bf16 v[48:63], v[164:167], v[100:103], v[48:63]
	v_max3_f32 v157, v157, v74, v76
	v_max3_f32 v156, v156, v77, v79
	v_max3_f32 v157, v157, v78, v80
	v_max3_f32 v156, v156, v81, v83
	v_max3_f32 v157, v157, v82, v84
	v_mfma_f32_32x32x16_bf16 v[48:63], v[204:207], v[108:111], v[48:63]
	v_max3_f32 v156, v156, v85, v87
	v_max3_f32 v157, v157, v86, v88
	v_max3_f32 v156, v156, v89, v91
	v_max3_f32 v157, v157, v90, v92
	v_max3_f32 v156, v156, v93, v95
	v_mfma_f32_32x32x16_bf16 v[48:63], v[226:229], v[104:107], v[48:63]
	v_max3_f32 v156, v157, v94, v156
	v_mov_b32_e32 v157, v156
	s_nop 1
	v_permlane32_swap_b32_e64 v156, v157 bound_ctrl:1
	v_max3_f32 v156, v150, v156, v157
	v_sub_f32_e32 v150, v150, v156
	v_sub_f32_e32 v166, v94, v156
	v_mfma_f32_32x32x16_bf16 v[32:47], v[160:163], v[96:99], v[32:47]
	v_sub_f32_e32 v64, v64, v156
	v_sub_f32_e32 v65, v65, v156
	v_sub_f32_e32 v66, v66, v156
	v_sub_f32_e32 v67, v67, v156
	v_sub_f32_e32 v68, v68, v156
	v_mfma_f32_32x32x16_bf16 v[32:47], v[188:191], v[100:103], v[32:47]
	v_sub_f32_e32 v69, v69, v156
	v_sub_f32_e32 v70, v70, v156
	v_sub_f32_e32 v71, v71, v156
	v_sub_f32_e32 v72, v72, v156
	v_sub_f32_e32 v73, v73, v156
	v_mfma_f32_32x32x16_bf16 v[32:47], v[214:217], v[108:111], v[32:47]
	v_sub_f32_e32 v74, v74, v156
	v_sub_f32_e32 v75, v75, v156
	v_sub_f32_e32 v76, v76, v156
	v_sub_f32_e32 v77, v77, v156
	v_sub_f32_e32 v78, v78, v156
	v_mfma_f32_32x32x16_bf16 v[32:47], v[230:233], v[104:107], v[32:47]
	v_sub_f32_e32 v79, v79, v156
	v_sub_f32_e32 v174, v80, v156
	v_sub_f32_e32 v175, v81, v156
	v_sub_f32_e32 v177, v82, v156
	v_sub_f32_e32 v167, v83, v156
	v_mfma_f32_32x32x16_bf16 v[16:31], v[170:173], v[96:99], v[16:31]
	v_sub_f32_e32 v168, v84, v156
	v_sub_f32_e32 v178, v85, v156
	v_sub_f32_e32 v169, v86, v156
	v_sub_f32_e32 v170, v87, v156
	v_sub_f32_e32 v171, v88, v156
	v_mfma_f32_32x32x16_bf16 v[16:31], v[192:195], v[100:103], v[16:31]
	v_sub_f32_e32 v163, v89, v156
	v_sub_f32_e32 v172, v90, v156
	v_sub_f32_e32 v173, v91, v156
	v_sub_f32_e32 v164, v92, v156
	v_sub_f32_e32 v165, v93, v156
	v_mfma_f32_32x32x16_bf16 v[16:31], v[218:221], v[108:111], v[16:31]
	v_exp_f32_e32 v150, v150
	v_exp_f32_e32 v157, v64
	v_exp_f32_e32 v158, v65
	v_mfma_f32_32x32x16_bf16 v[16:31], v[234:237], v[104:107], v[16:31]
	v_exp_f32_e32 v159, v66
	v_exp_f32_e32 v160, v67
	v_exp_f32_e32 v161, v68
	v_mfma_f32_32x32x16_bf16 v[0:15], v[180:183], v[96:99], v[0:15]
	v_exp_f32_e32 v98, v69
	v_exp_f32_e32 v99, v70
	v_exp_f32_e32 v162, v71
	v_sub_f32_e32 v96, v95, v156
	v_mfma_f32_32x32x16_bf16 v[0:15], v[196:199], v[100:103], v[0:15]
	v_exp_f32_e32 v100, v72
	v_exp_f32_e32 v101, v73
	v_exp_f32_e32 v102, v74
	v_mfma_f32_32x32x16_bf16 v[0:15], v[222:225], v[108:111], v[0:15]
	v_exp_f32_e32 v103, v75
	v_exp_f32_e32 v108, v76
	v_exp_f32_e32 v109, v77
	v_mfma_f32_32x32x16_bf16 v[0:15], v[238:241], v[104:107], v[0:15]
	v_exp_f32_e32 v104, v78
	v_exp_f32_e32 v105, v79
	v_pk_mul_f32 v[62:63], v[150:151], v[62:63] op_sel_hi:[0,1]
	v_pk_mul_f32 v[60:61], v[150:151], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[150:151], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[150:151], v[56:57] op_sel_hi:[0,1]
	v_pk_mul_f32 v[54:55], v[150:151], v[54:55] op_sel_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[150:151], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[150:151], v[50:51] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[150:151], v[48:49] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[150:151], v[46:47] op_sel_hi:[0,1]
	v_pk_mul_f32 v[44:45], v[150:151], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[150:151], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[40:41], v[150:151], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[150:151], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[150:151], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[34:35], v[150:151], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[150:151], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[150:151], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[150:151], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[150:151], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[150:151], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[150:151], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[150:151], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[150:151], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[150:151], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[150:151], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[150:151], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[150:151], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[150:151], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[150:151], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[150:151], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[150:151], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[150:151], v[0:1] op_sel_hi:[0,1]
	s_barrier
	s_mulk_i32 s5, 0x380
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 s0, s27
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_79:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	scratch_load_dword v64, off, off
	s_waitcnt vmcnt(0)
	buffer_load_dwordx4 v64, s[40:43], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_79
	s_mov_b64 exec, s[48:49]
	s_add_i32 s0, s27, 0x2000
	s_mov_b64 s[48:49], exec
	;;#ASMSTART
	;;#ASMEND
	s_mov_b32 m0, 0
	;;#ASMSTART
	s_mov_b32 m0, s0
	;;#ASMEND
.LBB0_81:
	v_readfirstlane_b32 s40, v112
	v_readfirstlane_b32 s41, v113
	v_readfirstlane_b32 s42, v114
	v_readfirstlane_b32 s43, v115
	v_cmp_eq_u64_e64 s[0:1], s[40:41], v[112:113]
	s_nop 0
	v_cmp_eq_u64_e64 s[6:7], s[42:43], v[114:115]
	s_and_b64 s[0:1], s[0:1], s[6:7]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v203, s[40:43], s5 offen lds
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_81
	s_mov_b64 exec, s[48:49]
	;;#ASMSTART
	ds_read_b128 v[110:113], v211 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[180:183], v211 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[188:191], v211 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[192:195], v211 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[196:199], v211 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[204:207], v211 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[214:217], v211 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[218:221], v211 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[222:225], v212 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[226:229], v212 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[230:233], v212 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[234:237], v212 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[238:241], v212 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[242:245], v212 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[246:249], v212 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[250:253], v212 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	v_exp_f32_e32 v106, v174
	v_exp_f32_e32 v107, v175
	v_mov_b64_e32 v[78:79], s[22:23]
	v_mov_b64_e32 v[76:77], s[20:21]
	v_mov_b64_e32 v[74:75], s[18:19]
	v_mov_b64_e32 v[72:73], s[16:17]
	v_mov_b64_e32 v[70:71], s[14:15]
	v_mov_b64_e32 v[68:69], s[12:13]
	v_mov_b64_e32 v[66:67], s[10:11]
	v_mov_b64_e32 v[64:65], s[8:9]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[80:95], v[110:113], v[144:147], v[64:79]
	v_exp_f32_e32 v110, v177
	v_mfma_f32_32x32x16_bf16 v[64:79], v[196:199], v[144:147], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[238:241], v[140:143], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[204:207], v[136:139], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[242:245], v[132:135], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[214:217], v[128:131], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[246:249], v[124:127], v[64:79]
	v_mfma_f32_32x32x16_bf16 v[64:79], v[218:221], v[120:123], v[64:79]
	v_exp_f32_e32 v111, v167
	v_exp_f32_e32 v112, v168
	v_exp_f32_e32 v115, v178
	v_exp_f32_e32 v167, v169
	v_exp_f32_e32 v168, v170
	v_exp_f32_e32 v169, v171
	v_exp_f32_e32 v163, v163
	v_exp_f32_e32 v170, v172
	v_exp_f32_e32 v171, v173
	v_exp_f32_e32 v164, v164
	v_exp_f32_e32 v165, v165
	v_exp_f32_e32 v166, v166
	v_exp_f32_e32 v172, v96
	v_add_f32_e32 v96, v158, v157
	v_add_f32_e32 v96, v96, v159
	v_add_f32_e32 v96, v96, v160
	v_add_f32_e32 v96, v96, v161
	v_add_f32_e32 v96, v96, v98
	v_mfma_f32_32x32x16_bf16 v[80:95], v[222:225], v[140:143], v[80:95]
	v_add_f32_e32 v96, v96, v99
	v_add_f32_e32 v96, v96, v162
	v_add_f32_e32 v96, v96, v100
	v_add_f32_e32 v96, v96, v101
	v_add_f32_e32 v96, v96, v102
	v_mfma_f32_32x32x16_bf16 v[80:95], v[180:183], v[136:139], v[80:95]
	v_add_f32_e32 v96, v96, v103
	v_add_f32_e32 v96, v96, v108
	v_add_f32_e32 v96, v96, v109
	v_add_f32_e32 v96, v96, v104
	v_add_f32_e32 v96, v96, v105
	v_mfma_f32_32x32x16_bf16 v[80:95], v[226:229], v[132:135], v[80:95]
	v_add_f32_e32 v96, v96, v106
	v_add_f32_e32 v96, v96, v107
	v_add_f32_e32 v96, v96, v110
	v_add_f32_e32 v96, v96, v111
	v_add_f32_e32 v96, v96, v112
	v_mfma_f32_32x32x16_bf16 v[80:95], v[188:191], v[128:131], v[80:95]
	v_add_f32_e32 v96, v96, v115
	v_add_f32_e32 v96, v96, v167
	v_add_f32_e32 v96, v96, v168
	v_add_f32_e32 v96, v96, v169
	v_add_f32_e32 v96, v96, v163
	v_mfma_f32_32x32x16_bf16 v[80:95], v[230:233], v[124:127], v[80:95]
	v_add_f32_e32 v96, v96, v170
	v_add_f32_e32 v96, v96, v171
	v_add_f32_e32 v96, v96, v164
	v_add_f32_e32 v96, v96, v165
	v_add_f32_e32 v96, v96, v166
	v_mfma_f32_32x32x16_bf16 v[80:95], v[192:195], v[120:123], v[80:95]
	v_add_f32_e32 v113, v96, v172
	v_mov_b32_e32 v114, v113
	s_nop 1
	v_permlane32_swap_b32_e64 v113, v114 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v96, v157, v158
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v97, v159, v160
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v98, v161, v98
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[80:95], v[234:237], v[116:119], v[80:95]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v99, v99, v162
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v100, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v101, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v102, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v103, v104, v105
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v108, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v109, v110, v111
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v110, v112, v115
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v111, v167, v168
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v104, v169, v163
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v105, v170, v171
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v106, v164, v165
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v107, v166, v172
	;;#ASMEND
	v_mfma_f32_32x32x16_bf16 v[64:79], v[250:253], v[116:119], v[64:79]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v210 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v210 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v210 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[128:129], v210 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[132:133], v210 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v210 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v210 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v210 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v210 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[162:163], v210 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[166:167], v210 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[170:171], v210 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[178:179], v210 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[182:183], v210 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[188:189], v210 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[192:193], v210 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v210 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v210 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v210 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[130:131], v210 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v210 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v210 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v210 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v210 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[160:161], v210 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[164:165], v210 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[168:169], v210 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[172:173], v210 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[180:181], v210 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[184:185], v210 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[190:191], v210 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[194:195], v210 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[116:119], v[96:99], v[48:63]
	s_nop 7
	v_max_f32_e32 v112, v81, v83
	v_max3_f32 v115, v80, v82, v84
	v_max3_f32 v112, v112, v85, v87
	v_max3_f32 v115, v115, v86, v88
	v_max3_f32 v112, v112, v89, v91
	v_mfma_f32_32x32x16_bf16 v[48:63], v[132:135], v[100:103], v[48:63]
	v_max3_f32 v115, v115, v90, v92
	v_max3_f32 v112, v112, v93, v95
	v_max3_f32 v115, v115, v94, v64
	v_max3_f32 v112, v112, v65, v67
	v_max3_f32 v115, v115, v66, v68
	v_mfma_f32_32x32x16_bf16 v[48:63], v[158:161], v[108:111], v[48:63]
	v_max3_f32 v112, v112, v69, v71
	v_max3_f32 v115, v115, v70, v72
	v_max3_f32 v112, v112, v73, v75
	v_max3_f32 v115, v115, v74, v76
	v_max3_f32 v112, v112, v77, v79
	v_mfma_f32_32x32x16_bf16 v[48:63], v[178:181], v[104:107], v[48:63]
	v_max3_f32 v112, v115, v78, v112
	v_mov_b32_e32 v115, v112
	s_nop 1
	v_permlane32_swap_b32_e64 v112, v115 bound_ctrl:1
	v_max3_f32 v112, v156, v112, v115
	v_sub_f32_e32 v115, v156, v112
	v_sub_f32_e32 v78, v78, v112
	v_mfma_f32_32x32x16_bf16 v[32:47], v[120:123], v[96:99], v[32:47]
	v_sub_f32_e32 v116, v80, v112
	v_sub_f32_e32 v81, v81, v112
	v_sub_f32_e32 v82, v82, v112
	v_sub_f32_e32 v83, v83, v112
	v_sub_f32_e32 v84, v84, v112
	v_sub_f32_e32 v79, v79, v112
	v_mfma_f32_32x32x16_bf16 v[32:47], v[136:139], v[100:103], v[32:47]
	v_sub_f32_e32 v85, v85, v112
	v_sub_f32_e32 v86, v86, v112
	v_sub_f32_e32 v87, v87, v112
	v_sub_f32_e32 v88, v88, v112
	v_sub_f32_e32 v89, v89, v112
	v_mfma_f32_32x32x16_bf16 v[32:47], v[162:165], v[108:111], v[32:47]
	v_sub_f32_e32 v90, v90, v112
	v_sub_f32_e32 v91, v91, v112
	v_sub_f32_e32 v92, v92, v112
	v_sub_f32_e32 v93, v93, v112
	v_sub_f32_e32 v94, v94, v112
	v_mfma_f32_32x32x16_bf16 v[32:47], v[182:185], v[104:107], v[32:47]
	v_sub_f32_e32 v95, v95, v112
	v_sub_f32_e32 v64, v64, v112
	v_sub_f32_e32 v65, v65, v112
	v_sub_f32_e32 v66, v66, v112
	v_sub_f32_e32 v67, v67, v112
	v_mfma_f32_32x32x16_bf16 v[16:31], v[124:127], v[96:99], v[16:31]
	v_sub_f32_e32 v68, v68, v112
	v_sub_f32_e32 v69, v69, v112
	v_sub_f32_e32 v70, v70, v112
	v_sub_f32_e32 v71, v71, v112
	v_sub_f32_e32 v72, v72, v112
	v_mfma_f32_32x32x16_bf16 v[16:31], v[140:143], v[100:103], v[16:31]
	v_sub_f32_e32 v73, v73, v112
	v_sub_f32_e32 v74, v74, v112
	v_sub_f32_e32 v75, v75, v112
	v_sub_f32_e32 v76, v76, v112
	v_sub_f32_e32 v77, v77, v112
	v_mfma_f32_32x32x16_bf16 v[16:31], v[166:169], v[108:111], v[16:31]
	v_exp_f32_e32 v80, v115
	v_exp_f32_e32 v115, v116
	v_exp_f32_e32 v116, v81
	v_mfma_f32_32x32x16_bf16 v[16:31], v[188:191], v[104:107], v[16:31]
	v_exp_f32_e32 v117, v82
	v_exp_f32_e32 v83, v83
	v_exp_f32_e32 v84, v84
	v_mfma_f32_32x32x16_bf16 v[0:15], v[128:131], v[96:99], v[0:15]
	v_exp_f32_e32 v85, v85
	v_exp_f32_e32 v86, v86
	v_exp_f32_e32 v87, v87
	v_mfma_f32_32x32x16_bf16 v[0:15], v[144:147], v[100:103], v[0:15]
	v_exp_f32_e32 v88, v88
	v_exp_f32_e32 v89, v89
	v_exp_f32_e32 v90, v90
	v_mfma_f32_32x32x16_bf16 v[0:15], v[170:173], v[108:111], v[0:15]
	v_exp_f32_e32 v91, v91
	v_exp_f32_e32 v92, v92
	v_exp_f32_e32 v93, v93
	v_mfma_f32_32x32x16_bf16 v[0:15], v[192:195], v[104:107], v[0:15]
	v_exp_f32_e32 v94, v94
	v_exp_f32_e32 v95, v95
	v_exp_f32_e32 v96, v64
	v_add_f32_e32 v64, v116, v115
	v_add_f32_e32 v64, v64, v117
	v_add_f32_e32 v64, v64, v83
	v_add_f32_e32 v64, v64, v84
	v_add_f32_e32 v64, v64, v85
	v_add_f32_e32 v64, v64, v86
	v_add_f32_e32 v64, v64, v87
	v_add_f32_e32 v64, v64, v88
	v_add_f32_e32 v64, v64, v89
	v_add_f32_e32 v64, v64, v90
	v_add_f32_e32 v64, v64, v91
	v_add_f32_e32 v64, v64, v92
	v_exp_f32_e32 v97, v65
	v_add_f32_e32 v64, v64, v93
	v_exp_f32_e32 v98, v66
	v_add_f32_e32 v64, v64, v94
	v_exp_f32_e32 v99, v67
	v_add_f32_e32 v64, v64, v95
	v_exp_f32_e32 v100, v68
	v_add_f32_e32 v64, v64, v96
	v_exp_f32_e32 v101, v69
	v_add_f32_e32 v64, v64, v97
	v_exp_f32_e32 v102, v70
	v_add_f32_e32 v64, v64, v98
	v_exp_f32_e32 v103, v71
	v_add_f32_e32 v64, v64, v99
	v_exp_f32_e32 v104, v72
	v_add_f32_e32 v64, v64, v100
	v_exp_f32_e32 v105, v73
	v_add_f32_e32 v64, v64, v101
	v_exp_f32_e32 v106, v74
	v_add_f32_e32 v64, v64, v102
	v_exp_f32_e32 v107, v75
	v_add_f32_e32 v64, v64, v103
	v_exp_f32_e32 v108, v76
	v_add_f32_e32 v64, v64, v104
	v_exp_f32_e32 v109, v77
	v_add_f32_e32 v64, v64, v105
	v_exp_f32_e32 v110, v78
	v_add_f32_e32 v64, v64, v106
	v_exp_f32_e32 v79, v79
	v_add_f32_e32 v64, v64, v107
	v_add_f32_e32 v64, v64, v108
	v_add_f32_e32 v64, v64, v109
	v_add_f32_e32 v64, v64, v110
	v_add_f32_e32 v81, v64, v79
	v_mov_b32_e32 v82, v81
	s_nop 1
	v_permlane32_swap_b32_e64 v81, v82 bound_ctrl:1
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v64, v115, v116
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v65, v117, v83
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v66, v84, v85
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v67, v86, v87
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v68, v88, v89
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v69, v90, v91
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v70, v92, v93
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v71, v94, v95
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v72, v96, v97
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v73, v98, v99
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v74, v100, v101
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v75, v102, v103
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v76, v104, v105
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v77, v106, v107
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v78, v108, v109
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v79, v110, v79
	;;#ASMEND
	v_pk_mul_f32 v[62:63], v[80:81], v[62:63] op_sel_hi:[0,1]
	v_pk_mul_f32 v[60:61], v[80:81], v[60:61] op_sel_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[80:81], v[58:59] op_sel_hi:[0,1]
	v_pk_mul_f32 v[56:57], v[80:81], v[56:57] op_sel_hi:[0,1]
	v_pk_mul_f32 v[54:55], v[80:81], v[54:55] op_sel_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[80:81], v[52:53] op_sel_hi:[0,1]
	v_pk_mul_f32 v[50:51], v[80:81], v[50:51] op_sel_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[80:81], v[48:49] op_sel_hi:[0,1]
	v_pk_mul_f32 v[46:47], v[80:81], v[46:47] op_sel_hi:[0,1]
	v_pk_mul_f32 v[44:45], v[80:81], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[80:81], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[40:41], v[80:81], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[80:81], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[80:81], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[34:35], v[80:81], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[80:81], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[30:31], v[80:81], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[80:81], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[80:81], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[24:25], v[80:81], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[80:81], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[20:21], v[80:81], v[20:21] op_sel_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[80:81], v[18:19] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[80:81], v[16:17] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[80:81], v[14:15] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[80:81], v[12:13] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[80:81], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[80:81], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[80:81], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[80:81], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[80:81], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[80:81], v[0:1] op_sel_hi:[0,1]
	s_barrier
	;;#ASMSTART
	ds_read_b64_tr_b16 v[84:85], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[88:89], v209 offset:0x200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[92:93], v209 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[96:97], v209 offset:0x600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[100:101], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[104:105], v209 offset:0x1200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[108:109], v209 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[116:117], v209 offset:0x1600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[120:121], v209 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[124:125], v209 offset:0x2200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[128:129], v209 offset:0x2400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[132:133], v209 offset:0x2600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[136:137], v209 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[140:141], v209 offset:0x3200

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[144:145], v209 offset:0x3400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[156:157], v209 offset:0x3600

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[86:87], v209 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[90:91], v209 offset:0xa00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[94:95], v209 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[98:99], v209 offset:0xe00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[102:103], v209 offset:0x1800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[106:107], v209 offset:0x1a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[110:111], v209 offset:0x1c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[118:119], v209 offset:0x1e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[122:123], v209 offset:0x2800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[126:127], v209 offset:0x2a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[130:131], v209 offset:0x2c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[134:135], v209 offset:0x2e00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[138:139], v209 offset:0x3800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[142:143], v209 offset:0x3a00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[146:147], v209 offset:0x3c00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b64_tr_b16 v[158:159], v209 offset:0x3e00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_barrier
	v_mfma_f32_32x32x16_bf16 v[48:63], v[84:87], v[64:67], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[88:91], v[64:67], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[92:95], v[64:67], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[64:67], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[100:103], v[68:71], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[104:107], v[68:71], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[108:111], v[68:71], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[116:119], v[68:71], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[120:123], v[72:75], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[124:127], v[72:75], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[128:131], v[72:75], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[132:135], v[72:75], v[0:15]
	v_mfma_f32_32x32x16_bf16 v[48:63], v[136:139], v[76:79], v[48:63]
	v_mfma_f32_32x32x16_bf16 v[32:47], v[140:143], v[76:79], v[32:47]
	v_mfma_f32_32x32x16_bf16 v[16:31], v[144:147], v[76:79], v[16:31]
	v_mfma_f32_32x32x16_bf16 v[0:15], v[156:159], v[76:79], v[0:15]
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_84
	s_barrier
.LBB0_84:
	s_or_b64 exec, exec, s[0:1]
	v_add_f32_e32 v64, v208, v254
	v_fmac_f32_e32 v255, v202, v64
	scratch_load_dword v64, off, off offset:20
	s_mov_b64 s[6:7], exec
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v64, v255, v64
	v_add_f32_e32 v64, v64, v186
	v_add_f32_e32 v64, v64, v187
	v_fmac_f32_e32 v152, v176, v64
	v_add_f32_e32 v64, v152, v153
	v_fmac_f32_e32 v154, v64, v176
	v_add_f32_e32 v64, v154, v155
	v_fmac_f32_e32 v149, v148, v64
	v_add_f32_e32 v64, v149, v151
	v_fmac_f32_e32 v113, v150, v64
	v_add_f32_e32 v64, v113, v114
	v_fmac_f32_e32 v81, v80, v64
	v_add_f32_e32 v64, v81, v82
	v_rcp_f32_e32 v82, v64
	v_mov_b32_e32 v80, s24
	v_mov_b32_e32 v81, s25
	v_mul_f32_e32 v67, v6, v82
	v_mul_f32_e32 v6, v12, v82
	v_mul_f32_e32 v79, v35, v82
	v_mul_f32_e32 v35, v37, v82
	v_mul_f32_e32 v37, v39, v82
	v_mul_f32_e32 v39, v62, v82
	v_mul_f32_e32 v12, v50, v82
	v_mul_f32_e32 v62, v51, v82
	v_mul_f32_e32 v50, v54, v82
	v_mul_f32_e32 v51, v55, v82
	scratch_load_dwordx2 v[54:55], off, off offset:4
	v_mul_f32_e32 v69, v0, v82
	v_mov_b32_e32 v0, s4
	v_mul_f32_e32 v70, v1, v82
	v_mul_f32_e32 v71, v2, v82
	v_mul_f32_e32 v72, v3, v82
	v_mov_b64_e32 v[2:3], s[2:3]
	v_mul_f32_e32 v65, v4, v82
	v_mul_f32_e32 v66, v5, v82
	v_mul_f32_e32 v4, v48, v82
	v_mul_f32_e32 v5, v49, v82
	v_mul_f32_e32 v48, v52, v82
	v_mul_f32_e32 v49, v53, v82
	v_mul_f32_e32 v15, v15, v82
	v_mul_f32_e32 v14, v14, v82
	v_mul_f32_e32 v68, v7, v82
	v_mul_f32_e32 v8, v8, v82
	v_mul_f32_e32 v9, v9, v82
	v_mul_f32_e32 v10, v10, v82
	v_mul_f32_e32 v11, v11, v82
	v_mul_f32_e32 v7, v13, v82
	v_mul_f32_e32 v13, v31, v82
	v_mul_f32_e32 v30, v30, v82
	v_mul_f32_e32 v74, v16, v82
	v_mul_f32_e32 v75, v17, v82
	v_mul_f32_e32 v76, v18, v82
	v_mul_f32_e32 v77, v19, v82
	v_mul_f32_e32 v31, v20, v82
	v_mul_f32_e32 v73, v21, v82
	v_mul_f32_e32 v22, v22, v82
	v_mul_f32_e32 v23, v23, v82
	v_mul_f32_e32 v18, v24, v82
	v_mul_f32_e32 v19, v25, v82
	v_mul_f32_e32 v20, v26, v82
	v_mul_f32_e32 v21, v27, v82
	v_mul_f32_e32 v16, v28, v82
	v_mul_f32_e32 v17, v29, v82
	v_mul_f32_e32 v24, v47, v82
	v_mul_f32_e32 v25, v46, v82
	v_mul_f32_e32 v46, v32, v82
	v_mul_f32_e32 v47, v33, v82
	v_mul_f32_e32 v78, v34, v82
	v_mul_f32_e32 v34, v36, v82
	v_mul_f32_e32 v36, v38, v82
	v_mul_f32_e32 v28, v40, v82
	v_mul_f32_e32 v29, v41, v82
	v_mul_f32_e32 v32, v42, v82
	v_mul_f32_e32 v33, v43, v82
	v_mul_f32_e32 v26, v44, v82
	v_mul_f32_e32 v27, v45, v82
	v_mul_f32_e32 v38, v63, v82
	v_mul_f32_e32 v42, v56, v82
	v_mul_f32_e32 v43, v57, v82
	v_mul_f32_e32 v44, v58, v82
	v_mul_f32_e32 v45, v59, v82
	v_mul_f32_e32 v40, v60, v82
	v_mul_f32_e32 v41, v61, v82
	s_waitcnt vmcnt(0)
	v_mad_i64_i32 v[0:1], s[0:1], s28, v0, v[54:55]
	s_bfe_i64 s[0:1], s[30:31], 0x200000
	v_mul_lo_u32 v52, v1, s30
	v_mul_lo_u32 v53, v0, s1
	v_mad_u64_u32 v[0:1], s[0:1], v0, s30, v[2:3]
	v_add3_u32 v1, v52, v1, v53
	scratch_load_dword v53, off, off offset:12
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v4, v5
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v12, v62
	;;#ASMEND
	s_bfe_i64 s[0:1], s[46:47], 0x200000
	v_and_b32_e32 v12, 0xffff0000, v5
	v_or_b32_sdwa v5, v12, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	scratch_load_dword v12, off, off offset:16
	v_mul_lo_u32 v2, v1, s46
	v_mul_lo_u32 v3, v0, s1
	v_mad_u64_u32 v[0:1], s[0:1], v0, s46, 0
	s_mul_i32 s0, s30, s46
	s_mul_i32 s1, s26, s28
	s_mul_i32 s1, s0, s1
	v_add3_u32 v1, v1, v3, v2
	s_lshl_b32 s1, s1, 1
	v_lshl_add_u64 v[0:1], v[0:1], 1, v[80:81]
	v_mov_b32_e32 v2, s1
	v_mov_b32_e32 v3, 0x20000
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v52, v53, s0
	s_waitcnt vmcnt(0)
	v_add_lshl_u32 v12, v52, v12, 1
.LBB0_85:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_85
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v48, v49
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v50, v51
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v48, 0xffff0000, v5
	v_or_b32_sdwa v5, v48, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_87:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:16
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_87
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v42, v43
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v44, v45
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v42, 0xffff0000, v5
	v_or_b32_sdwa v5, v42, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_89:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_89
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v40, v41
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v39, v38
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v38, 0xffff0000, v5
	v_or_b32_sdwa v5, v38, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_91:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:48
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_91
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v46, v47
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v78, v79
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v38, 0xffff0000, v5
	v_or_b32_sdwa v5, v38, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_93:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_93
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v34, v35
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v36, v37
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v34, 0xffff0000, v5
	v_or_b32_sdwa v5, v34, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_95:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:80
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_95
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v28, v29
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v32, v33
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v28, 0xffff0000, v5
	v_or_b32_sdwa v5, v28, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_97:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_97
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v26, v27
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v25, v24
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v24, 0xffff0000, v5
	v_or_b32_sdwa v5, v24, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_99:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:112
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_99
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v74, v75
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v76, v77
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v24, 0xffff0000, v5
	v_or_b32_sdwa v5, v24, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_101:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_101
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v31, v73
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v22, v23
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v22, 0xffff0000, v5
	v_or_b32_sdwa v5, v22, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_103:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:144
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_103
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
.LBB0_105:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_105
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v16, v17
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v30, v13
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v13, 0xffff0000, v5
	v_or_b32_sdwa v5, v13, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_107:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:176
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_107
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v69, v70
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v71, v72
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v13, 0xffff0000, v5
	v_or_b32_sdwa v5, v13, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_109:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_109
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v65, v66
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v67, v68
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v13, 0xffff0000, v5
	v_or_b32_sdwa v5, v13, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_111:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:208
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_111
	s_mov_b64 exec, s[6:7]
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v8, v9
	;;#ASMEND
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v10, v11
	;;#ASMEND
	s_mov_b64 s[6:7], exec
	v_and_b32_e32 v8, 0xffff0000, v5
	v_or_b32_sdwa v5, v8, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
.LBB0_113:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_113
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
.LBB0_115:
	v_readfirstlane_b32 s8, v0
	v_readfirstlane_b32 s9, v1
	v_readfirstlane_b32 s10, v2
	v_readfirstlane_b32 s11, v3
	v_cmp_eq_u64_e32 vcc, s[8:9], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx2 v[4:5], v12, s[8:11], 0 offen offset:240
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_115
	s_mov_b64 exec, s[6:7]
	s_mov_b32 s0, 0x800000
	s_mul_i32 s1, s36, s4
	v_cmp_gt_f32_e32 vcc, s0, v64
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
	v_ldexp_f32 v0, v64, v0
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
	v_lshl_add_u64 v[0:1], v[54:55], 2, s[0:1]
	v_lshlrev_b32_e32 v2, 2, v53
	v_mov_b32_e32 v3, 0
	v_fmac_f32_e32 v4, 0x3f317218, v112
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	global_store_dword v[0:1], v4, off
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z10attend_kerILi128EEv12attn_globalsIXT_EE
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 28
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
		.amdhsa_enable_private_segment 1
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 256
		.amdhsa_next_free_sgpr 56
		.amdhsa_accum_offset 256
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
	.section	.text._Z10attend_kerILi128EEv12attn_globalsIXT_EE,"axG",@progbits,_Z10attend_kerILi128EEv12attn_globalsIXT_EE,comdat
.Lfunc_end0:
	.size	_Z10attend_kerILi128EEv12attn_globalsIXT_EE, .Lfunc_end0-_Z10attend_kerILi128EEv12attn_globalsIXT_EE

	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.num_vgpr, 256
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.num_agpr, 0
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.numbered_sgpr, 56
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.private_seg_size, 28
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.uses_vcc, 1
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.uses_flat_scratch, 0
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.has_dyn_sized_stack, 0
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.has_recursion, 0
	.set _Z10attend_kerILi128EEv12attn_globalsIXT_EE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_298c59d329cbe01a,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_298c59d329cbe01a
__hip_cuid_298c59d329cbe01a:
	.byte	0
	.size	__hip_cuid_298c59d329cbe01a, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_298c59d329cbe01a
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
    .name:           _Z10attend_kerILi128EEv12attn_globalsIXT_EE
    .private_segment_fixed_size: 28
    .sgpr_count:     62
    .sgpr_spill_count: 0
    .symbol:         _Z10attend_kerILi128EEv12attn_globalsIXT_EE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     256
    .vgpr_spill_count: 6
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
