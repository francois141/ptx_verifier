	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE,"axG",@progbits,_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE,comdat
	.protected	_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE
	.globl	_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE
	.p2align	8
	.type	_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE,@function
_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE:
	s_load_dwordx8 s[8:15], s[0:1], 0x60
	s_waitcnt lgkmcnt(0)
	s_load_dword s11, s[0:1], 0xb0
	s_load_dword s13, s[0:1], 0x80
	s_load_dwordx8 s[20:27], s[0:1], 0x90
	s_lshl_b32 s16, s4, 5
	s_ashr_i32 s17, s16, 31
	s_waitcnt lgkmcnt(0)
	s_mul_hi_i32 s5, s11, s16
	s_mul_i32 s4, s11, s16
	s_mul_i32 s6, s22, s24
	s_lshl_b64 s[4:5], s[4:5], 1
	v_and_b32_e32 v73, 31, v0
	v_lshrrev_b32_e32 v1, 2, v0
	s_mul_i32 s6, s6, s26
	s_add_u32 s4, s20, s4
	v_and_b32_e32 v72, 8, v1
	s_mul_i32 s6, s6, s11
	v_mul_lo_u32 v1, v73, s11
	s_addc_u32 s5, s21, s5
	s_lshl_b32 s6, s6, 1
	s_mov_b32 s7, 0x20000
	v_add_lshl_u32 v1, v1, v72, 1
	buffer_load_dwordx4 v[54:57], v1, s[4:7], 0 offen
	buffer_load_dwordx4 v[38:41], v1, s[4:7], 0 offen offset:32
	buffer_load_dwordx4 v[22:25], v1, s[4:7], 0 offen offset:64
	buffer_load_dwordx4 v[6:9], v1, s[4:7], 0 offen offset:96
	s_mul_hi_i32 s5, s13, s16
	s_mul_i32 s4, s13, s16
	s_mul_i32 s6, s10, s12
	s_lshl_b64 s[4:5], s[4:5], 1
	s_mul_i32 s6, s6, s14
	s_add_u32 s4, s8, s4
	s_mul_i32 s6, s6, s13
	v_mul_lo_u32 v1, v73, s13
	s_addc_u32 s5, s9, s5
	s_lshl_b32 s6, s6, 1
	v_add_lshl_u32 v1, v1, v72, 1
	buffer_load_dwordx4 v[50:53], v1, s[4:7], 0 offen
	buffer_load_dwordx4 v[34:37], v1, s[4:7], 0 offen offset:32
	buffer_load_dwordx4 v[18:21], v1, s[4:7], 0 offen offset:64
	buffer_load_dwordx4 v[2:5], v1, s[4:7], 0 offen offset:96
	s_load_dwordx8 s[20:27], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x30
	s_load_dwordx2 s[12:13], s[0:1], 0x20
	v_lshrrev_b32_e32 v0, 6, v0
	v_add_u32_e32 v0, s3, v0
	s_ashr_i32 s3, s2, 31
	v_mov_b64_e32 v[12:13], s[2:3]
	s_load_dwordx2 s[18:19], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	v_mad_i64_i32 v[12:13], s[0:1], s24, v0, v[12:13]
	s_bfe_i64 s[0:1], s[26:27], 0x200000
	v_mov_b64_e32 v[14:15], s[16:17]
	v_mov_b32_e32 v70, s4
	v_mov_b32_e32 v71, s5
	v_mad_u64_u32 v[14:15], s[4:5], v12, s26, v[14:15]
	v_mul_lo_u32 v1, v12, s1
	v_mul_lo_u32 v12, v13, s26
	s_bfe_i64 s[0:1], s[12:13], 0x200000
	v_add3_u32 v1, v12, v15, v1
	v_mul_lo_u32 v15, v14, s1
	v_mad_u64_u32 v[12:13], s[0:1], v14, s12, 0
	s_mul_i32 s0, s22, s24
	s_mul_i32 s0, s0, s26
	v_mul_lo_u32 v1, v1, s12
	s_mul_i32 s0, s0, s12
	v_mov_b32_e32 v10, s20
	v_mov_b32_e32 v11, s21
	v_add3_u32 v13, v13, v15, v1
	s_lshl_b32 s0, s0, 1
	v_mul_lo_u32 v1, v73, s12
	v_lshl_add_u64 v[66:67], v[12:13], 1, v[10:11]
	v_mov_b32_e32 v68, s0
	v_mov_b32_e32 v69, 0x20000
	v_add_lshl_u32 v1, v1, v72, 1
	s_mov_b64 s[4:5], exec
.LBB0_1:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[58:61], v1, s[12:15], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_3:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[42:45], v1, s[12:15], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_5:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[26:29], v1, s[12:15], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_5
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_7:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[10:13], v1, s[12:15], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_7
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_9:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[62:65], v1, s[12:15], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_9
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_11:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[46:49], v1, s[12:15], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_11
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_13:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[30:33], v1, s[12:15], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_13
	s_mov_b64 exec, s[4:5]
	s_mov_b64 s[4:5], exec
.LBB0_15:
	v_readfirstlane_b32 s12, v66
	v_readfirstlane_b32 s13, v67
	v_readfirstlane_b32 s14, v68
	v_readfirstlane_b32 s15, v69
	v_cmp_eq_u64_e32 vcc, s[12:13], v[66:67]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[14:15], v[68:69]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[14:17], v1, s[12:15], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_15
	s_mov_b64 exec, s[4:5]
	s_waitcnt vmcnt(7)
	v_and_b32_e32 v1, 0xffff0000, v58
	v_and_b32_e32 v67, 0xffff0000, v54
	v_lshlrev_b32_e32 v58, 16, v58
	v_lshlrev_b32_e32 v54, 16, v54
	v_and_b32_e32 v74, 0xffff0000, v50
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v76, 16, v62
	v_lshlrev_b32_e32 v50, 16, v50
	v_mul_f32_e32 v68, v54, v58
	v_and_b32_e32 v69, 0xffff0000, v62
	v_mul_f32_e32 v62, v50, v76
	v_mul_f32_e32 v54, v54, v76
	v_mul_f32_e32 v50, v50, v58
	v_mul_f32_e32 v66, v67, v1
	v_mul_f32_e32 v67, v67, v69
	v_cvt_pk_bf16_f32 v54, v54, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v50, v50, s0
	v_cvt_pk_bf16_f32 v67, v67, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v54, 16, v54
	v_lshlrev_b32_e32 v50, 16, v50
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v62, v62, s0
	v_add_f32_e32 v50, v50, v54
	v_lshlrev_b32_e32 v54, 16, v67
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v66, v66, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v62, 16, v62
	v_lshlrev_b32_e32 v68, 16, v68
	v_add_f32_e32 v1, v1, v54
	v_sub_f32_e32 v62, v68, v62
	v_lshlrev_b32_e32 v68, 16, v75
	v_lshlrev_b32_e32 v66, 16, v66
	v_cvt_pk_bf16_f32 v54, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v59
	v_and_b32_e32 v58, 0xffff0000, v55
	v_lshlrev_b32_e32 v59, 16, v59
	v_lshlrev_b32_e32 v55, 16, v55
	v_and_b32_e32 v74, 0xffff0000, v51
	v_lshlrev_b32_e32 v76, 16, v63
	v_lshlrev_b32_e32 v51, 16, v51
	v_sub_f32_e32 v66, v66, v68
	v_mul_f32_e32 v68, v55, v59
	v_and_b32_e32 v69, 0xffff0000, v63
	v_mul_f32_e32 v63, v51, v76
	v_mul_f32_e32 v55, v55, v76
	v_mul_f32_e32 v51, v51, v59
	v_mul_f32_e32 v67, v58, v1
	v_mul_f32_e32 v58, v58, v69
	v_cvt_pk_bf16_f32 v55, v55, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v51, v51, s0
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v63, v63, s0
	v_cvt_pk_bf16_f32 v58, v58, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v55, 16, v55
	v_lshlrev_b32_e32 v51, 16, v51
	v_cvt_pk_bf16_f32 v67, v67, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v63, 16, v63
	v_lshlrev_b32_e32 v68, 16, v68
	v_add_f32_e32 v51, v51, v55
	v_lshlrev_b32_e32 v55, 16, v58
	v_lshlrev_b32_e32 v1, 16, v1
	v_sub_f32_e32 v63, v68, v63
	v_lshlrev_b32_e32 v68, 16, v75
	v_lshlrev_b32_e32 v67, 16, v67
	v_add_f32_e32 v1, v1, v55
	v_sub_f32_e32 v67, v67, v68
	v_cvt_pk_bf16_f32 v55, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v60
	v_and_b32_e32 v68, 0xffff0000, v56
	v_mul_f32_e32 v58, v68, v1
	v_lshlrev_b32_e32 v60, 16, v60
	v_lshlrev_b32_e32 v56, 16, v56
	v_and_b32_e32 v69, 0xffff0000, v64
	v_and_b32_e32 v74, 0xffff0000, v52
	v_lshlrev_b32_e32 v64, 16, v64
	v_lshlrev_b32_e32 v52, 16, v52
	v_cvt_pk_bf16_f32 v59, v58, s0
	v_mul_f32_e32 v58, v56, v60
	v_mul_f32_e32 v76, v52, v64
	v_mul_f32_e32 v56, v56, v64
	v_mul_f32_e32 v52, v52, v60
	v_mul_f32_e32 v68, v68, v69
	v_cvt_pk_bf16_f32 v56, v56, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v52, v52, s0
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v56, 16, v56
	v_lshlrev_b32_e32 v52, 16, v52
	v_mul_f32_e32 v75, v74, v69
	v_add_f32_e32 v52, v52, v56
	v_lshlrev_b32_e32 v56, 16, v68
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_add_f32_e32 v1, v1, v56
	v_cvt_pk_bf16_f32 v58, v58, s0
	v_cvt_pk_bf16_f32 v76, v76, s0
	v_lshlrev_b32_e32 v75, 16, v75
	v_lshlrev_b32_e32 v59, 16, v59
	v_cvt_pk_bf16_f32 v56, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v61
	v_and_b32_e32 v64, 0xffff0000, v57
	v_lshlrev_b32_e32 v76, 16, v76
	v_lshlrev_b32_e32 v58, 16, v58
	v_sub_f32_e32 v59, v59, v75
	v_mul_f32_e32 v60, v64, v1
	v_lshlrev_b32_e32 v69, 16, v61
	v_lshlrev_b32_e32 v57, 16, v57
	v_and_b32_e32 v74, 0xffff0000, v65
	v_and_b32_e32 v75, 0xffff0000, v53
	v_lshlrev_b32_e32 v65, 16, v65
	v_lshlrev_b32_e32 v53, 16, v53
	v_sub_f32_e32 v58, v58, v76
	v_cvt_pk_bf16_f32 v68, v60, s0
	v_mul_f32_e32 v60, v57, v69
	v_mul_f32_e32 v76, v53, v65
	v_mul_f32_e32 v57, v57, v65
	v_mul_f32_e32 v53, v53, v69
	v_mul_f32_e32 v61, v75, v74
	v_mul_f32_e32 v64, v64, v74
	v_cvt_pk_bf16_f32 v57, v57, s0
	v_mul_f32_e32 v1, v75, v1
	v_cvt_pk_bf16_f32 v53, v53, s0
	v_cvt_pk_bf16_f32 v60, v60, s0
	v_cvt_pk_bf16_f32 v61, v61, s0
	v_cvt_pk_bf16_f32 v76, v76, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v57, 16, v57
	v_lshlrev_b32_e32 v53, 16, v53
	v_lshlrev_b32_e32 v76, 16, v76
	v_lshlrev_b32_e32 v60, 16, v60
	v_lshlrev_b32_e32 v61, 16, v61
	v_lshlrev_b32_e32 v68, 16, v68
	v_add_f32_e32 v53, v53, v57
	v_lshlrev_b32_e32 v57, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_sub_f32_e32 v60, v60, v76
	v_sub_f32_e32 v61, v68, v61
	v_add_f32_e32 v1, v1, v57
	v_and_b32_e32 v64, 0xffff0000, v38
	v_lshlrev_b32_e32 v68, 16, v42
	v_lshlrev_b32_e32 v38, 16, v38
	v_and_b32_e32 v74, 0xffff0000, v34
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v76, 16, v46
	v_lshlrev_b32_e32 v34, 16, v34
	v_cvt_pk_bf16_f32 v57, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v42
	v_mul_f32_e32 v42, v38, v68
	v_and_b32_e32 v69, 0xffff0000, v46
	v_mul_f32_e32 v46, v34, v76
	v_mul_f32_e32 v38, v38, v76
	v_mul_f32_e32 v34, v34, v68
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v38, v38, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v38, 16, v38
	v_lshlrev_b32_e32 v34, 16, v34
	v_cvt_pk_bf16_f32 v42, v42, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v46, v46, s0
	v_add_f32_e32 v34, v34, v38
	v_lshlrev_b32_e32 v38, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v46, 16, v46
	v_lshlrev_b32_e32 v42, 16, v42
	v_add_f32_e32 v1, v1, v38
	v_and_b32_e32 v64, 0xffff0000, v39
	v_lshlrev_b32_e32 v68, 16, v43
	v_lshlrev_b32_e32 v39, 16, v39
	v_and_b32_e32 v74, 0xffff0000, v35
	v_lshlrev_b32_e32 v76, 16, v47
	v_lshlrev_b32_e32 v35, 16, v35
	v_sub_f32_e32 v42, v42, v46
	v_lshlrev_b32_e32 v46, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v38, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v43
	v_mul_f32_e32 v43, v39, v68
	v_and_b32_e32 v69, 0xffff0000, v47
	v_mul_f32_e32 v47, v35, v76
	v_mul_f32_e32 v39, v39, v76
	v_mul_f32_e32 v35, v35, v68
	v_sub_f32_e32 v46, v65, v46
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v39, v39, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v39, 16, v39
	v_lshlrev_b32_e32 v35, 16, v35
	v_cvt_pk_bf16_f32 v43, v43, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v47, v47, s0
	v_add_f32_e32 v35, v35, v39
	v_lshlrev_b32_e32 v39, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v47, 16, v47
	v_lshlrev_b32_e32 v43, 16, v43
	v_add_f32_e32 v1, v1, v39
	v_and_b32_e32 v64, 0xffff0000, v40
	v_lshlrev_b32_e32 v68, 16, v44
	v_lshlrev_b32_e32 v40, 16, v40
	v_and_b32_e32 v74, 0xffff0000, v36
	v_lshlrev_b32_e32 v76, 16, v48
	v_lshlrev_b32_e32 v36, 16, v36
	v_sub_f32_e32 v43, v43, v47
	v_lshlrev_b32_e32 v47, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v39, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v44
	v_mul_f32_e32 v44, v40, v68
	v_and_b32_e32 v69, 0xffff0000, v48
	v_mul_f32_e32 v48, v36, v76
	v_mul_f32_e32 v40, v40, v76
	v_mul_f32_e32 v36, v36, v68
	v_sub_f32_e32 v47, v65, v47
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v40, v40, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v36, v36, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v40, 16, v40
	v_lshlrev_b32_e32 v36, 16, v36
	v_cvt_pk_bf16_f32 v44, v44, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v48, v48, s0
	v_add_f32_e32 v36, v36, v40
	v_lshlrev_b32_e32 v40, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v48, 16, v48
	v_lshlrev_b32_e32 v44, 16, v44
	v_add_f32_e32 v1, v1, v40
	v_and_b32_e32 v64, 0xffff0000, v41
	v_lshlrev_b32_e32 v68, 16, v45
	v_lshlrev_b32_e32 v41, 16, v41
	v_and_b32_e32 v74, 0xffff0000, v37
	v_lshlrev_b32_e32 v76, 16, v49
	v_lshlrev_b32_e32 v37, 16, v37
	v_sub_f32_e32 v44, v44, v48
	v_lshlrev_b32_e32 v48, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v40, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v45
	v_mul_f32_e32 v45, v41, v68
	v_and_b32_e32 v69, 0xffff0000, v49
	v_mul_f32_e32 v49, v37, v76
	v_mul_f32_e32 v41, v41, v76
	v_mul_f32_e32 v37, v37, v68
	v_sub_f32_e32 v48, v65, v48
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v41, v41, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v37, v37, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v41, 16, v41
	v_lshlrev_b32_e32 v37, 16, v37
	v_cvt_pk_bf16_f32 v45, v45, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v49, v49, s0
	v_add_f32_e32 v37, v37, v41
	v_lshlrev_b32_e32 v41, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v49, 16, v49
	v_lshlrev_b32_e32 v45, 16, v45
	v_add_f32_e32 v1, v1, v41
	v_and_b32_e32 v64, 0xffff0000, v22
	v_lshlrev_b32_e32 v68, 16, v26
	v_lshlrev_b32_e32 v22, 16, v22
	v_and_b32_e32 v74, 0xffff0000, v18
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v76, 16, v30
	v_lshlrev_b32_e32 v18, 16, v18
	v_sub_f32_e32 v45, v45, v49
	v_lshlrev_b32_e32 v49, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v41, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v26
	v_mul_f32_e32 v26, v22, v68
	v_and_b32_e32 v69, 0xffff0000, v30
	v_mul_f32_e32 v30, v18, v76
	v_mul_f32_e32 v22, v22, v76
	v_mul_f32_e32 v18, v18, v68
	v_sub_f32_e32 v49, v65, v49
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v22, v22, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v22, 16, v22
	v_lshlrev_b32_e32 v18, 16, v18
	v_cvt_pk_bf16_f32 v26, v26, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v30, v30, s0
	v_add_f32_e32 v18, v18, v22
	v_lshlrev_b32_e32 v22, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v30, 16, v30
	v_lshlrev_b32_e32 v26, 16, v26
	v_add_f32_e32 v1, v1, v22
	v_and_b32_e32 v64, 0xffff0000, v23
	v_lshlrev_b32_e32 v68, 16, v27
	v_lshlrev_b32_e32 v23, 16, v23
	v_and_b32_e32 v74, 0xffff0000, v19
	v_lshlrev_b32_e32 v76, 16, v31
	v_lshlrev_b32_e32 v19, 16, v19
	v_sub_f32_e32 v26, v26, v30
	v_lshlrev_b32_e32 v30, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v22, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v27
	v_mul_f32_e32 v27, v23, v68
	v_and_b32_e32 v69, 0xffff0000, v31
	v_mul_f32_e32 v31, v19, v76
	v_mul_f32_e32 v23, v23, v76
	v_mul_f32_e32 v19, v19, v68
	v_sub_f32_e32 v30, v65, v30
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v23, v23, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v23, 16, v23
	v_lshlrev_b32_e32 v19, 16, v19
	v_cvt_pk_bf16_f32 v27, v27, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v31, v31, s0
	v_add_f32_e32 v19, v19, v23
	v_lshlrev_b32_e32 v23, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v31, 16, v31
	v_lshlrev_b32_e32 v27, 16, v27
	v_add_f32_e32 v1, v1, v23
	v_and_b32_e32 v64, 0xffff0000, v24
	v_lshlrev_b32_e32 v68, 16, v28
	v_lshlrev_b32_e32 v24, 16, v24
	v_and_b32_e32 v74, 0xffff0000, v20
	v_lshlrev_b32_e32 v76, 16, v32
	v_lshlrev_b32_e32 v20, 16, v20
	v_sub_f32_e32 v27, v27, v31
	v_lshlrev_b32_e32 v31, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v23, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v28
	v_mul_f32_e32 v28, v24, v68
	v_and_b32_e32 v69, 0xffff0000, v32
	v_mul_f32_e32 v32, v20, v76
	v_mul_f32_e32 v24, v24, v76
	v_mul_f32_e32 v20, v20, v68
	v_sub_f32_e32 v31, v65, v31
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v24, v24, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v24, 16, v24
	v_lshlrev_b32_e32 v20, 16, v20
	v_cvt_pk_bf16_f32 v28, v28, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v32, v32, s0
	v_add_f32_e32 v20, v20, v24
	v_lshlrev_b32_e32 v24, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v32, 16, v32
	v_lshlrev_b32_e32 v28, 16, v28
	v_add_f32_e32 v1, v1, v24
	v_and_b32_e32 v64, 0xffff0000, v25
	v_lshlrev_b32_e32 v68, 16, v29
	v_lshlrev_b32_e32 v25, 16, v25
	v_and_b32_e32 v74, 0xffff0000, v21
	v_lshlrev_b32_e32 v76, 16, v33
	v_lshlrev_b32_e32 v21, 16, v21
	v_sub_f32_e32 v28, v28, v32
	v_lshlrev_b32_e32 v32, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_cvt_pk_bf16_f32 v24, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v29
	v_mul_f32_e32 v29, v25, v68
	v_and_b32_e32 v69, 0xffff0000, v33
	v_mul_f32_e32 v33, v21, v76
	v_mul_f32_e32 v25, v25, v76
	v_mul_f32_e32 v21, v21, v68
	v_sub_f32_e32 v32, v65, v32
	v_mul_f32_e32 v65, v64, v1
	v_mul_f32_e32 v64, v64, v69
	v_cvt_pk_bf16_f32 v25, v25, s0
	v_mul_f32_e32 v1, v74, v1
	v_cvt_pk_bf16_f32 v21, v21, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v25, 16, v25
	v_lshlrev_b32_e32 v21, 16, v21
	v_add_f32_e32 v21, v21, v25
	v_lshlrev_b32_e32 v25, 16, v64
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v29, v29, s0
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_add_f32_e32 v1, v1, v25
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_lshlrev_b32_e32 v33, 16, v33
	v_lshlrev_b32_e32 v29, 16, v29
	v_cvt_pk_bf16_f32 v25, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v10
	v_and_b32_e32 v68, 0xffff0000, v6
	v_sub_f32_e32 v29, v29, v33
	v_lshlrev_b32_e32 v33, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_mul_f32_e32 v64, v68, v1
	v_lshlrev_b32_e32 v10, 16, v10
	v_lshlrev_b32_e32 v6, 16, v6
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v69, 0xffff0000, v14
	v_and_b32_e32 v74, 0xffff0000, v2
	v_lshlrev_b32_e32 v14, 16, v14
	v_lshlrev_b32_e32 v2, 16, v2
	v_sub_f32_e32 v33, v65, v33
	v_cvt_pk_bf16_f32 v65, v64, s0
	v_mul_f32_e32 v64, v6, v10
	v_mul_f32_e32 v76, v2, v14
	v_mul_f32_e32 v6, v6, v14
	v_mul_f32_e32 v2, v2, v10
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_mul_f32_e32 v68, v68, v69
	v_mul_f32_e32 v1, v74, v1
	v_lshlrev_b32_e32 v6, 16, v6
	v_lshlrev_b32_e32 v2, 16, v2
	v_mul_f32_e32 v75, v74, v69
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_add_f32_e32 v2, v2, v6
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_cvt_pk_bf16_f32 v10, v2, s0
	v_lshlrev_b32_e32 v2, 16, v68
	v_lshlrev_b32_e32 v1, 16, v1
	v_lshlrev_b32_e32 v75, 16, v75
	v_lshlrev_b32_e32 v65, 16, v65
	v_add_f32_e32 v1, v1, v2
	v_sub_f32_e32 v65, v65, v75
	v_cvt_pk_bf16_f32 v14, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v11
	v_and_b32_e32 v2, 0xffff0000, v7
	v_and_b32_e32 v74, 0xffff0000, v15
	v_and_b32_e32 v75, 0xffff0000, v3
	v_mul_f32_e32 v6, v2, v1
	v_mul_f32_e32 v69, v75, v74
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v69, v69, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v76, v76, s0
	v_lshlrev_b32_e32 v69, 16, v69
	v_lshlrev_b32_e32 v6, 16, v6
	v_lshlrev_b32_e32 v76, 16, v76
	v_lshlrev_b32_e32 v64, 16, v64
	v_lshlrev_b32_e32 v11, 16, v11
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v15, 16, v15
	v_lshlrev_b32_e32 v3, 16, v3
	v_sub_f32_e32 v6, v6, v69
	v_sub_f32_e32 v64, v64, v76
	v_mul_f32_e32 v68, v7, v11
	v_mul_f32_e32 v76, v3, v15
	v_cvt_pk_bf16_f32 v69, v6, s0
	v_mul_f32_e32 v2, v2, v74
	v_mul_f32_e32 v6, v7, v15
	v_mul_f32_e32 v1, v75, v1
	v_mul_f32_e32 v3, v3, v11
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_cvt_pk_bf16_f32 v76, v76, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_lshlrev_b32_e32 v76, 16, v76
	v_lshlrev_b32_e32 v68, 16, v68
	v_lshlrev_b32_e32 v6, 16, v6
	v_lshlrev_b32_e32 v3, 16, v3
	v_lshlrev_b32_e32 v2, 16, v2
	v_lshlrev_b32_e32 v1, 16, v1
	v_sub_f32_e32 v68, v68, v76
	v_add_f32_e32 v3, v3, v6
	v_add_f32_e32 v1, v1, v2
	v_lshlrev_b32_e32 v6, 16, v12
	v_lshlrev_b32_e32 v7, 16, v8
	v_and_b32_e32 v75, 0xffff0000, v4
	v_lshlrev_b32_e32 v76, 16, v16
	v_lshlrev_b32_e32 v4, 16, v4
	v_cvt_pk_bf16_f32 v15, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v12
	v_and_b32_e32 v2, 0xffff0000, v8
	v_mul_f32_e32 v8, v7, v6
	v_and_b32_e32 v12, 0xffff0000, v16
	v_mul_f32_e32 v16, v4, v76
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_cvt_pk_bf16_f32 v11, v3, s0
	v_mul_f32_e32 v3, v2, v1
	v_mul_f32_e32 v74, v75, v12
	v_lshlrev_b32_e32 v16, 16, v16
	v_lshlrev_b32_e32 v8, 16, v8
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v74, v74, s0
	v_sub_f32_e32 v8, v8, v16
	v_cvt_pk_bf16_f32 v16, v8, s0
	v_lshlrev_b32_e32 v8, 16, v74
	v_lshlrev_b32_e32 v3, 16, v3
	v_sub_f32_e32 v3, v3, v8
	v_mul_f32_e32 v2, v2, v12
	v_mul_f32_e32 v1, v75, v1
	v_cvt_pk_bf16_f32 v74, v3, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_mul_f32_e32 v3, v7, v76
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_mul_f32_e32 v4, v4, v6
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_lshlrev_b32_e32 v2, 16, v2
	v_lshlrev_b32_e32 v1, 16, v1
	v_lshlrev_b32_e32 v3, 16, v3
	v_lshlrev_b32_e32 v4, 16, v4
	v_add_f32_e32 v1, v1, v2
	v_add_f32_e32 v3, v4, v3
	v_cvt_pk_bf16_f32 v12, v1, s0
	v_and_b32_e32 v1, 0xffff0000, v13
	v_and_b32_e32 v2, 0xffff0000, v9
	v_lshlrev_b32_e32 v4, 16, v13
	v_lshlrev_b32_e32 v6, 16, v9
	v_and_b32_e32 v13, 0xffff0000, v17
	v_and_b32_e32 v9, 0xffff0000, v5
	v_lshlrev_b32_e32 v17, 16, v17
	v_lshlrev_b32_e32 v5, 16, v5
	v_mul_f32_e32 v7, v6, v4
	v_mul_f32_e32 v76, v5, v17
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v76, v76, s0
	v_cvt_pk_bf16_f32 v8, v3, s0
	v_mul_f32_e32 v3, v2, v1
	v_mul_f32_e32 v75, v9, v13
	v_lshlrev_b32_e32 v76, 16, v76
	v_lshlrev_b32_e32 v7, 16, v7
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v75, v75, s0
	v_sub_f32_e32 v7, v7, v76
	v_cvt_pk_bf16_f32 v76, v7, s0
	v_lshlrev_b32_e32 v7, 16, v75
	v_lshlrev_b32_e32 v3, 16, v3
	v_sub_f32_e32 v3, v3, v7
	v_cvt_pk_bf16_f32 v75, v3, s0
	v_mul_f32_e32 v3, v6, v17
	v_mul_f32_e32 v4, v5, v4
	v_mul_f32_e32 v2, v2, v13
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_mul_f32_e32 v1, v9, v1
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v3, 16, v3
	v_lshlrev_b32_e32 v4, 16, v4
	v_add_f32_e32 v3, v4, v3
	v_lshlrev_b32_e32 v2, 16, v2
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v9, v3, s0
	v_add_f32_e32 v1, v1, v2
	v_mov_b64_e32 v[2:3], s[2:3]
	v_cvt_pk_bf16_f32 v62, v62, s0
	v_cvt_pk_bf16_f32 v66, v66, s0
	v_cvt_pk_bf16_f32 v50, v50, s0
	v_cvt_pk_bf16_f32 v63, v63, s0
	v_cvt_pk_bf16_f32 v67, v67, s0
	v_cvt_pk_bf16_f32 v51, v51, s0
	v_cvt_pk_bf16_f32 v58, v58, s0
	v_cvt_pk_bf16_f32 v59, v59, s0
	v_cvt_pk_bf16_f32 v52, v52, s0
	v_cvt_pk_bf16_f32 v60, v60, s0
	v_cvt_pk_bf16_f32 v61, v61, s0
	v_cvt_pk_bf16_f32 v53, v53, s0
	v_cvt_pk_bf16_f32 v42, v42, s0
	v_cvt_pk_bf16_f32 v46, v46, s0
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_cvt_pk_bf16_f32 v43, v43, s0
	v_cvt_pk_bf16_f32 v47, v47, s0
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_cvt_pk_bf16_f32 v44, v44, s0
	v_cvt_pk_bf16_f32 v48, v48, s0
	v_cvt_pk_bf16_f32 v36, v36, s0
	v_cvt_pk_bf16_f32 v45, v45, s0
	v_cvt_pk_bf16_f32 v49, v49, s0
	v_cvt_pk_bf16_f32 v37, v37, s0
	v_cvt_pk_bf16_f32 v26, v26, s0
	v_cvt_pk_bf16_f32 v30, v30, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v27, v27, s0
	v_cvt_pk_bf16_f32 v31, v31, s0
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cvt_pk_bf16_f32 v28, v28, s0
	v_cvt_pk_bf16_f32 v32, v32, s0
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v29, v29, s0
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_cvt_pk_bf16_f32 v21, v21, s0
	v_cvt_pk_bf16_f32 v64, v64, s0
	v_cvt_pk_bf16_f32 v65, v65, s0
	v_cvt_pk_bf16_f32 v68, v68, s0
	v_cvt_pk_bf16_f32 v13, v1, s0
	v_mad_i64_i32 v[0:1], s[0:1], s8, v0, v[2:3]
	s_bfe_i64 s[0:1], s[10:11], 0x200000
	v_mov_b64_e32 v[2:3], s[16:17]
	v_mad_u64_u32 v[2:3], s[2:3], v0, s10, v[2:3]
	v_mul_lo_u32 v0, v0, s1
	v_mul_lo_u32 v1, v1, s10
	v_add3_u32 v0, v1, v3, v0
	s_bfe_i64 s[0:1], s[18:19], 0x200000
	v_mul_lo_u32 v3, v2, s1
	v_mul_lo_u32 v4, v0, s18
	v_mad_u64_u32 v[0:1], s[0:1], v2, s18, 0
	v_add3_u32 v1, v1, v3, v4
	s_mul_i32 s0, s6, s8
	v_lshlrev_b32_e32 v4, 16, v67
	s_mul_i32 s0, s0, s10
	v_or_b32_sdwa v5, v4, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v66
	v_and_b32_e32 v6, 0xffff, v62
	s_mul_i32 s0, s0, s18
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v61
	s_lshl_b32 s0, s0, 1
	v_mul_lo_u32 v17, v73, s18
	v_or_b32_sdwa v7, v6, v60 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v59
	v_and_b32_e32 v58, 0xffff, v58
	v_lshl_add_u64 v[0:1], v[0:1], 1, v[70:71]
	v_mov_b32_e32 v2, s0
	v_mov_b32_e32 v3, 0x20000
	v_or_b32_e32 v6, v6, v58
	v_add_lshl_u32 v17, v17, v72, 1
	s_mov_b64 s[2:3], exec
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
.LBB0_17:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_17
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v47
	v_or_b32_sdwa v5, v4, v43 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v46
	v_and_b32_e32 v6, 0xffff, v42
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v49
	v_or_b32_sdwa v7, v6, v45 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v48
	v_and_b32_e32 v42, 0xffff, v44
	v_or_b32_e32 v6, v6, v42
	s_mov_b64 s[2:3], exec
.LBB0_19:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_19
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v31
	v_or_b32_sdwa v5, v4, v27 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v30
	v_and_b32_e32 v6, 0xffff, v26
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v33
	v_or_b32_sdwa v7, v6, v29 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v32
	v_and_b32_e32 v26, 0xffff, v28
	v_or_b32_e32 v6, v6, v26
	s_mov_b64 s[2:3], exec
.LBB0_21:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_21
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v69
	v_or_b32_sdwa v5, v4, v68 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v65
	v_and_b32_e32 v6, 0xffff, v64
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v75
	v_or_b32_sdwa v7, v6, v76 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v74
	v_and_b32_e32 v16, 0xffff, v16
	v_or_b32_e32 v6, v6, v16
	s_mov_b64 s[2:3], exec
.LBB0_23:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_23
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v55
	v_or_b32_sdwa v5, v4, v51 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v54
	v_and_b32_e32 v6, 0xffff, v50
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v57
	v_or_b32_sdwa v7, v6, v53 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v56
	v_and_b32_e32 v16, 0xffff, v52
	v_or_b32_e32 v6, v6, v16
	s_mov_b64 s[2:3], exec
.LBB0_25:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_25
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v39
	v_or_b32_sdwa v5, v4, v35 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v38
	v_and_b32_e32 v6, 0xffff, v34
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v41
	v_or_b32_sdwa v7, v6, v37 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v40
	v_and_b32_e32 v16, 0xffff, v36
	v_or_b32_e32 v6, v6, v16
	s_mov_b64 s[2:3], exec
.LBB0_27:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_27
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v23
	v_or_b32_sdwa v5, v4, v19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v22
	v_and_b32_e32 v6, 0xffff, v18
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v25
	v_or_b32_sdwa v7, v6, v21 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v24
	v_and_b32_e32 v16, 0xffff, v20
	v_or_b32_e32 v6, v6, v16
	s_mov_b64 s[2:3], exec
.LBB0_29:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_29
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v4, 16, v15
	v_or_b32_sdwa v5, v4, v11 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v4, 16, v14
	v_and_b32_e32 v6, 0xffff, v10
	v_or_b32_e32 v4, v4, v6
	v_lshlrev_b32_e32 v6, 16, v13
	v_or_b32_sdwa v7, v6, v9 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	v_lshlrev_b32_e32 v6, 16, v12
	v_and_b32_e32 v8, 0xffff, v8
	v_or_b32_e32 v6, v6, v8
	s_mov_b64 s[0:1], exec
.LBB0_31:
	v_readfirstlane_b32 s4, v0
	v_readfirstlane_b32 s5, v1
	v_readfirstlane_b32 s6, v2
	v_readfirstlane_b32 s7, v3
	v_cmp_eq_u64_e32 vcc, s[4:5], v[0:1]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v17, s[4:7], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_31
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 200
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
		.amdhsa_next_free_vgpr 77
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 80
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
	.section	.text._Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE,"axG",@progbits,_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE,comdat
.Lfunc_end0:
	.size	_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE, .Lfunc_end0-_Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE

	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.num_vgpr, 77
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.num_agpr, 0
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.numbered_sgpr, 28
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.private_seg_size, 0
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.uses_vcc, 1
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.uses_flat_scratch, 0
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.has_dyn_sized_stack, 0
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.has_recursion, 0
	.set _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_ac4d9262df71cd7d,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_ac4d9262df71cd7d
__hip_cuid_ac4d9262df71cd7d:
	.byte	0
	.size	__hip_cuid_ac4d9262df71cd7d, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_ac4d9262df71cd7d
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           200
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 200
    .max_flat_workgroup_size: 1024
    .name:           _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _Z15tk_fused_rotaryILi128EEv14rotary_globalsIXT_EE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     77
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
