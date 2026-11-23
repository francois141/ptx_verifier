	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._Z10softmax_tkILi128EEv15softmax_globalsIXT_EE,"axG",@progbits,_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE,comdat
	.protected	_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE
	.globl	_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE
	.p2align	8
	.type	_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE,@function
_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE:
	v_lshrrev_b32_e32 v1, 1, v0
	s_load_dwordx8 s[20:27], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x20
	s_load_dwordx8 s[12:19], s[0:1], 0x30
	v_and_b32_e32 v1, 0x1e0, v1
	v_lshl_add_u32 v36, s2, 7, v1
	v_ashrrev_i32_e32 v37, 31, v36
	v_mov_b32_e32 v1, s3
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v2, s20
	v_mov_b32_e32 v3, s21
	s_load_dwordx2 s[20:21], s[0:1], 0x50
	v_mad_i64_i32 v[4:5], s[0:1], s26, v1, v[36:37]
	s_bfe_i64 s[0:1], s[6:7], 0x200000
	v_mul_lo_u32 v1, v5, s6
	v_mul_lo_u32 v6, v4, s1
	v_mad_u64_u32 v[4:5], s[0:1], v4, s6, 0
	s_mul_i32 s0, s22, s24
	s_mul_i32 s0, s0, s26
	v_and_b32_e32 v39, 31, v0
	v_lshrrev_b32_e32 v0, 2, v0
	s_mul_i32 s0, s0, s6
	v_add3_u32 v5, v5, v6, v1
	v_and_b32_e32 v38, 8, v0
	s_lshl_b32 s0, s0, 1
	v_mul_lo_u32 v0, v39, s6
	s_mov_b32 s4, s3
	v_lshl_add_u64 v[32:33], v[4:5], 1, v[2:3]
	v_mov_b32_e32 v34, s0
	v_mov_b32_e32 v35, 0x20000
	v_add_lshl_u32 v44, v0, v38, 1
	s_mov_b64 s[2:3], exec
.LBB0_1:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[28:31], v44, s[8:11], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_3:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[24:27], v44, s[8:11], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	s_waitcnt vmcnt(1)
	v_perm_b32 v43, v29, v30, s0
	s_mov_b32 s0, 0xffff
	v_bfi_b32 v41, s0, v29, v29
	v_alignbit_b32 v42, v31, v30, 16
	v_bfi_b32 v40, s0, v30, v30
	s_mov_b64 s[2:3], exec
.LBB0_5:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[20:23], v44, s[8:11], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_5
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_7:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[16:19], v44, s[8:11], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_7
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_9:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[12:15], v44, s[8:11], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_9
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_11:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[8:11], v44, s[8:11], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_11
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_13:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[4:7], v44, s[8:11], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_13
	s_mov_b64 exec, s[2:3]
	s_mov_b64 s[2:3], exec
.LBB0_15:
	v_readfirstlane_b32 s8, v32
	v_readfirstlane_b32 s9, v33
	v_readfirstlane_b32 s10, v34
	v_readfirstlane_b32 s11, v35
	v_cmp_eq_u64_e32 vcc, s[8:9], v[32:33]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[10:11], v[34:35]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[0:3], v44, s[8:11], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_15
	s_mov_b64 exec, s[2:3]
	s_movk_i32 s5, 0x7f80
	v_and_b32_e32 v32, 0x7f80, v28
	v_cmp_eq_u32_e32 vcc, s5, v32
	v_and_b32_e32 v32, 0x7f, v28
	v_cmp_ne_u32_e64 s[0:1], 0, v32
	v_and_b32_e32 v32, 0x7f80, v29
	v_cmp_eq_u32_e64 s[2:3], s5, v32
	v_and_b32_e32 v32, 0x7f, v29
	v_cmp_ne_u32_e64 s[6:7], 0, v32
	v_lshlrev_b32_e32 v32, 16, v28
	v_lshlrev_b32_e32 v33, 16, v29
	v_cmp_lt_f32_e64 s[8:9], v33, v32
	v_mov_b32_e32 v33, 0x7fff
	s_and_b64 s[2:3], s[2:3], s[6:7]
	v_cndmask_b32_e64 v33, v29, v33, s[2:3]
	s_or_b64 s[2:3], s[2:3], s[8:9]
	v_cndmask_b32_e64 v34, v29, v28, s[2:3]
	s_and_b64 vcc, vcc, s[0:1]
	v_cndmask_b32_e32 v33, v34, v33, vcc
	s_movk_i32 s10, 0x7f
	v_and_b32_sdwa v34, v33, s5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_eq_u32_e32 vcc, s5, v34
	v_and_b32_sdwa v34, v33, s10 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v34
	v_and_b32_e32 v34, 0x7f80, v30
	v_and_b32_e32 v30, 0x7f, v30
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s5, v34
	v_cmp_ne_u32_e64 s[2:3], 0, v30
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v30, 16, v40
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v34, 16, v33
	v_cmp_lt_f32_e64 s[2:3], v30, v34
	s_nop 1
	v_cndmask_b32_e64 v34, v40, v33, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v34, 0x7fff
	v_cndmask_b32_e64 v34, v40, v34, s[0:1]
	v_cndmask_b32_e32 v34, v33, v34, vcc
	s_or_b64 exec, exec, s[2:3]
	v_alignbit_b32 v35, v29, v28, 16
	v_and_b32_e32 v44, 0x7f80, v35
	v_and_b32_e32 v35, 0x7f, v35
	v_cmp_ne_u32_e64 s[0:1], 0, v35
	v_and_b32_e32 v35, 0x7f80, v43
	v_cmp_eq_u32_e64 s[2:3], s5, v35
	v_and_b32_e32 v35, 0x7f, v43
	v_lshrrev_b32_e32 v33, 16, v28
	v_cmp_ne_u32_e64 s[6:7], 0, v35
	v_and_b32_e32 v35, 0xffff0000, v41
	v_and_b32_e32 v28, 0xffff0000, v28
	v_cmp_lt_f32_e64 s[8:9], v35, v28
	v_lshrrev_b32_e32 v28, 16, v29
	v_mov_b32_e32 v29, 0x7fff
	s_and_b64 s[2:3], s[2:3], s[6:7]
	v_cmp_eq_u32_e32 vcc, s5, v44
	v_cndmask_b32_e64 v29, v28, v29, s[2:3]
	s_or_b64 s[2:3], s[2:3], s[8:9]
	v_cndmask_b32_e64 v28, v28, v33, s[2:3]
	s_and_b64 vcc, vcc, s[0:1]
	v_cndmask_b32_e32 v28, v28, v29, vcc
	v_and_b32_sdwa v29, v28, s5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_eq_u32_e32 vcc, s5, v29
	v_and_b32_sdwa v29, v28, s10 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v29
	v_and_b32_e32 v29, 0x7f80, v42
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s5, v29
	v_and_b32_e32 v29, 0x7f, v42
	v_cmp_ne_u32_e64 s[2:3], 0, v29
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v29, 0xffff0000, v40
	v_lshlrev_b32_e32 v35, 16, v28
	v_cmp_lt_f32_e32 vcc, v29, v35
	s_nop 1
	v_cndmask_b32_sdwa v35, v40, v28, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v29, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v29, v40, v29, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v35, v28, v29, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v28, s0, v31, v31
	v_and_b32_sdwa v29, v34, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v29
	v_and_b32_sdwa v29, v34, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v29
	v_and_b32_e32 v29, 0x7f80, v31
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v29
	v_and_b32_e32 v29, 0x7f, v31
	v_cmp_ne_u32_e64 s[2:3], 0, v29
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v29, 16, v28
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v42, 16, v34
	v_cmp_lt_f32_e64 s[2:3], v29, v42
	s_nop 1
	v_cndmask_b32_e64 v42, v28, v34, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v42, 0x7fff
	v_cndmask_b32_e64 v42, v28, v42, s[0:1]
	v_cndmask_b32_e32 v42, v34, v42, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v34, v35, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v34
	v_and_b32_sdwa v34, v35, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v34
	v_and_b32_sdwa v34, v31, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v31, v31, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v34
	v_cmp_ne_u32_e64 s[2:3], 0, v31
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v31, 0xffff0000, v28
	v_lshlrev_b32_e32 v34, 16, v35
	v_cmp_lt_f32_e32 vcc, v31, v34
	s_nop 1
	v_cndmask_b32_sdwa v34, v28, v35, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v31, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v31, v28, v31, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v34, v35, v31, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v31, v42, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v31
	v_and_b32_sdwa v31, v42, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v31
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v31, 0x7f80, v24
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v31
	v_and_b32_e32 v31, 0x7f, v24
	v_cmp_ne_u32_e64 s[2:3], 0, v31
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v31, 16, v24
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v35, 16, v42
	v_cmp_gt_f32_e64 s[2:3], v35, v31
	s_nop 1
	v_cndmask_b32_e64 v43, v24, v42, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v35, 0x7fff
	v_cndmask_b32_e64 v35, v24, v35, s[0:1]
	v_cndmask_b32_e32 v43, v42, v35, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v42, v34, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v35, 16, v24
	v_cmp_eq_u32_e32 vcc, s2, v42
	v_and_b32_sdwa v42, v34, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v24, v25, v24, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v42
	v_and_b32_e32 v42, 0x7f80, v24
	v_and_b32_e32 v24, 0x7f, v24
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v42
	v_cmp_ne_u32_e64 s[2:3], 0, v24
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v24, 16, v35
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v42, 16, v34
	v_cmp_gt_f32_e64 s[2:3], v42, v24
	s_nop 1
	v_cndmask_b32_e64 v42, v35, v34, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v42, 0x7fff
	v_cndmask_b32_e64 v35, v35, v42, s[0:1]
	v_cndmask_b32_e32 v42, v34, v35, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v45, v25, v26, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v34, s0, v25, v25
	v_and_b32_sdwa v35, v43, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v35
	v_and_b32_sdwa v35, v43, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v35
	v_and_b32_e32 v35, 0x7f80, v25
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v35
	v_and_b32_e32 v35, 0x7f, v25
	v_cmp_ne_u32_e64 s[2:3], 0, v35
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v35, 16, v34
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v44, 16, v43
	v_cmp_lt_f32_e64 s[2:3], v35, v44
	s_nop 1
	v_cndmask_b32_e64 v44, v25, v43, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v44, 0x7fff
	v_cndmask_b32_e64 v44, v25, v44, s[0:1]
	v_cndmask_b32_e32 v44, v43, v44, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v43, v42, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v43
	v_and_b32_sdwa v43, v42, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v43
	v_and_b32_e32 v43, 0x7f80, v45
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v43
	v_and_b32_e32 v43, 0x7f, v45
	v_cmp_ne_u32_e64 s[2:3], 0, v43
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v43, 0xffff0000, v34
	v_lshlrev_b32_e32 v45, 16, v42
	v_cmp_lt_f32_e32 vcc, v43, v45
	s_nop 1
	v_cndmask_b32_sdwa v43, v25, v42, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v43, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v25, v25, v43, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v43, v42, v25, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v25, s0, v26, v26
	v_and_b32_sdwa v45, v44, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v45
	v_and_b32_sdwa v45, v44, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v42, v27, v26, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v45
	v_and_b32_e32 v45, 0x7f80, v26
	v_and_b32_e32 v26, 0x7f, v26
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v45
	v_cmp_ne_u32_e64 s[2:3], 0, v26
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v26, 16, v25
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v45, 16, v44
	v_cmp_lt_f32_e64 s[2:3], v26, v45
	s_nop 1
	v_cndmask_b32_e64 v45, v25, v44, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v45, 0x7fff
	v_cndmask_b32_e64 v45, v25, v45, s[0:1]
	v_cndmask_b32_e32 v45, v44, v45, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v44, v43, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v44
	v_and_b32_sdwa v44, v43, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v44
	v_and_b32_e32 v44, 0x7f80, v42
	v_and_b32_e32 v42, 0x7f, v42
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v44
	v_cmp_ne_u32_e64 s[2:3], 0, v42
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v42, 0xffff0000, v25
	v_lshlrev_b32_e32 v44, 16, v43
	v_cmp_lt_f32_e32 vcc, v42, v44
	s_nop 1
	v_cndmask_b32_sdwa v46, v25, v43, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v42, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v42, v25, v42, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v46, v43, v42, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v42, s0, v27, v27
	v_and_b32_sdwa v43, v45, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v43
	v_and_b32_sdwa v43, v45, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v43
	v_and_b32_e32 v43, 0x7f80, v27
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v43
	v_and_b32_e32 v43, 0x7f, v27
	v_cmp_ne_u32_e64 s[2:3], 0, v43
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v43, 16, v42
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v44, 16, v45
	v_cmp_lt_f32_e64 s[2:3], v43, v44
	s_nop 1
	v_cndmask_b32_e64 v48, v42, v45, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v44, 0x7fff
	v_cndmask_b32_e64 v44, v42, v44, s[0:1]
	v_cndmask_b32_e32 v48, v45, v44, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v44, v46, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v44
	v_and_b32_sdwa v44, v46, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v44
	v_and_b32_sdwa v44, v27, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v27, v27, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v44
	v_cmp_ne_u32_e64 s[2:3], 0, v27
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v27, 0xffff0000, v42
	v_lshlrev_b32_e32 v44, 16, v46
	v_cmp_lt_f32_e32 vcc, v27, v44
	s_nop 1
	v_cndmask_b32_sdwa v44, v42, v46, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v27, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v27, v42, v27, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v44, v46, v27, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v27, v48, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v27
	v_and_b32_sdwa v27, v48, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v27
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v27, 0x7f80, v20
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v27
	v_and_b32_e32 v27, 0x7f, v20
	v_cmp_ne_u32_e64 s[2:3], 0, v27
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v27, 16, v20
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v45, 16, v48
	v_cmp_gt_f32_e64 s[2:3], v45, v27
	s_nop 1
	v_cndmask_b32_e64 v47, v20, v48, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v45, 0x7fff
	v_cndmask_b32_e64 v45, v20, v45, s[0:1]
	v_cndmask_b32_e32 v47, v48, v45, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v46, v44, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v45, 16, v20
	v_cmp_eq_u32_e32 vcc, s2, v46
	v_and_b32_sdwa v46, v44, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v20, v21, v20, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v46
	v_and_b32_e32 v46, 0x7f80, v20
	v_and_b32_e32 v20, 0x7f, v20
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v46
	v_cmp_ne_u32_e64 s[2:3], 0, v20
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v20, 16, v45
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v46, 16, v44
	v_cmp_gt_f32_e64 s[2:3], v46, v20
	s_nop 1
	v_cndmask_b32_e64 v46, v45, v44, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v46, 0x7fff
	v_cndmask_b32_e64 v45, v45, v46, s[0:1]
	v_cndmask_b32_e32 v46, v44, v45, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v49, v21, v22, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v44, s0, v21, v21
	v_and_b32_sdwa v45, v47, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v45
	v_and_b32_sdwa v45, v47, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v45
	v_and_b32_e32 v45, 0x7f80, v21
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v45
	v_and_b32_e32 v45, 0x7f, v21
	v_cmp_ne_u32_e64 s[2:3], 0, v45
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v45, 16, v44
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v48, 16, v47
	v_cmp_lt_f32_e64 s[2:3], v45, v48
	s_nop 1
	v_cndmask_b32_e64 v48, v21, v47, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v48, 0x7fff
	v_cndmask_b32_e64 v48, v21, v48, s[0:1]
	v_cndmask_b32_e32 v48, v47, v48, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v47, v46, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v47
	v_and_b32_sdwa v47, v46, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v47
	v_and_b32_e32 v47, 0x7f80, v49
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v47
	v_and_b32_e32 v47, 0x7f, v49
	v_cmp_ne_u32_e64 s[2:3], 0, v47
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v47, 0xffff0000, v44
	v_lshlrev_b32_e32 v49, 16, v46
	v_cmp_lt_f32_e32 vcc, v47, v49
	s_nop 1
	v_cndmask_b32_sdwa v47, v21, v46, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v47, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v21, v21, v47, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v47, v46, v21, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v21, s0, v22, v22
	v_and_b32_sdwa v49, v48, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v49
	v_and_b32_sdwa v49, v48, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v46, v23, v22, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v49
	v_and_b32_e32 v49, 0x7f80, v22
	v_and_b32_e32 v22, 0x7f, v22
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v49
	v_cmp_ne_u32_e64 s[2:3], 0, v22
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v22, 16, v21
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v49, 16, v48
	v_cmp_lt_f32_e64 s[2:3], v22, v49
	s_nop 1
	v_cndmask_b32_e64 v49, v21, v48, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v49, 0x7fff
	v_cndmask_b32_e64 v49, v21, v49, s[0:1]
	v_cndmask_b32_e32 v49, v48, v49, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v48, v47, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v48
	v_and_b32_sdwa v48, v47, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v48
	v_and_b32_e32 v48, 0x7f80, v46
	v_and_b32_e32 v46, 0x7f, v46
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v48
	v_cmp_ne_u32_e64 s[2:3], 0, v46
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v46, 0xffff0000, v21
	v_lshlrev_b32_e32 v48, 16, v47
	v_cmp_lt_f32_e32 vcc, v46, v48
	s_nop 1
	v_cndmask_b32_sdwa v48, v21, v47, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v46, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v46, v21, v46, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v48, v47, v46, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v46, s0, v23, v23
	v_and_b32_sdwa v47, v49, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v47
	v_and_b32_sdwa v47, v49, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v47
	v_and_b32_e32 v47, 0x7f80, v23
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v47
	v_and_b32_e32 v47, 0x7f, v23
	v_cmp_ne_u32_e64 s[2:3], 0, v47
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v47, 16, v46
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v50, 16, v49
	v_cmp_lt_f32_e64 s[2:3], v47, v50
	s_nop 1
	v_cndmask_b32_e64 v50, v46, v49, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v50, 0x7fff
	v_cndmask_b32_e64 v50, v46, v50, s[0:1]
	v_cndmask_b32_e32 v50, v49, v50, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v49, v48, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v49
	v_and_b32_sdwa v49, v48, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v49
	v_and_b32_sdwa v49, v23, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v23, v23, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v49
	v_cmp_ne_u32_e64 s[2:3], 0, v23
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v23, 0xffff0000, v46
	v_lshlrev_b32_e32 v49, 16, v48
	v_cmp_lt_f32_e32 vcc, v23, v49
	s_nop 1
	v_cndmask_b32_sdwa v49, v46, v48, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v23, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v23, v46, v23, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v49, v48, v23, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v23, v50, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v23
	v_and_b32_sdwa v23, v50, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v23
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v23, 0x7f80, v16
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v23
	v_and_b32_e32 v23, 0x7f, v16
	v_cmp_ne_u32_e64 s[2:3], 0, v23
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v23, 16, v16
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v48, 16, v50
	v_cmp_gt_f32_e64 s[2:3], v48, v23
	s_nop 1
	v_cndmask_b32_e64 v51, v16, v50, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v48, 0x7fff
	v_cndmask_b32_e64 v48, v16, v48, s[0:1]
	v_cndmask_b32_e32 v51, v50, v48, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v50, v49, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v48, 16, v16
	v_cmp_eq_u32_e32 vcc, s2, v50
	v_and_b32_sdwa v50, v49, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v16, v17, v16, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v50
	v_and_b32_e32 v50, 0x7f80, v16
	v_and_b32_e32 v16, 0x7f, v16
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v50
	v_cmp_ne_u32_e64 s[2:3], 0, v16
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v16, 16, v48
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v50, 16, v49
	v_cmp_gt_f32_e64 s[2:3], v50, v16
	s_nop 1
	v_cndmask_b32_e64 v50, v48, v49, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v50, 0x7fff
	v_cndmask_b32_e64 v48, v48, v50, s[0:1]
	v_cndmask_b32_e32 v50, v49, v48, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v53, v17, v18, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v48, s0, v17, v17
	v_and_b32_sdwa v49, v51, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v49
	v_and_b32_sdwa v49, v51, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v49
	v_and_b32_e32 v49, 0x7f80, v17
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v49
	v_and_b32_e32 v49, 0x7f, v17
	v_cmp_ne_u32_e64 s[2:3], 0, v49
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v49, 16, v48
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v52, 16, v51
	v_cmp_lt_f32_e64 s[2:3], v49, v52
	s_nop 1
	v_cndmask_b32_e64 v52, v17, v51, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v52, 0x7fff
	v_cndmask_b32_e64 v52, v17, v52, s[0:1]
	v_cndmask_b32_e32 v52, v51, v52, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v51, v50, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v51
	v_and_b32_sdwa v51, v50, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v51
	v_and_b32_e32 v51, 0x7f80, v53
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v51
	v_and_b32_e32 v51, 0x7f, v53
	v_cmp_ne_u32_e64 s[2:3], 0, v51
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v51, 0xffff0000, v48
	v_lshlrev_b32_e32 v53, 16, v50
	v_cmp_lt_f32_e32 vcc, v51, v53
	s_nop 1
	v_cndmask_b32_sdwa v51, v17, v50, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v51, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v17, v17, v51, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v51, v50, v17, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v17, s0, v18, v18
	v_and_b32_sdwa v53, v52, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v53
	v_and_b32_sdwa v53, v52, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v50, v19, v18, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v53
	v_and_b32_e32 v53, 0x7f80, v18
	v_and_b32_e32 v18, 0x7f, v18
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v53
	v_cmp_ne_u32_e64 s[2:3], 0, v18
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v18, 16, v17
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v53, 16, v52
	v_cmp_lt_f32_e64 s[2:3], v18, v53
	s_nop 1
	v_cndmask_b32_e64 v53, v17, v52, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v53, 0x7fff
	v_cndmask_b32_e64 v53, v17, v53, s[0:1]
	v_cndmask_b32_e32 v53, v52, v53, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v52, v51, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v52
	v_and_b32_sdwa v52, v51, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v52
	v_and_b32_e32 v52, 0x7f80, v50
	v_and_b32_e32 v50, 0x7f, v50
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v52
	v_cmp_ne_u32_e64 s[2:3], 0, v50
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v50, 0xffff0000, v17
	v_lshlrev_b32_e32 v52, 16, v51
	v_cmp_lt_f32_e32 vcc, v50, v52
	s_nop 1
	v_cndmask_b32_sdwa v52, v17, v51, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v50, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v50, v17, v50, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v52, v51, v50, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v50, s0, v19, v19
	v_and_b32_sdwa v51, v53, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v51
	v_and_b32_sdwa v51, v53, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v51
	v_and_b32_e32 v51, 0x7f80, v19
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v51
	v_and_b32_e32 v51, 0x7f, v19
	v_cmp_ne_u32_e64 s[2:3], 0, v51
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v51, 16, v50
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v54, 16, v53
	v_cmp_lt_f32_e64 s[2:3], v51, v54
	s_nop 1
	v_cndmask_b32_e64 v54, v50, v53, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v54, 0x7fff
	v_cndmask_b32_e64 v54, v50, v54, s[0:1]
	v_cndmask_b32_e32 v54, v53, v54, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v53, v52, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v53
	v_and_b32_sdwa v53, v52, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v53
	v_and_b32_sdwa v53, v19, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v19, v19, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v53
	v_cmp_ne_u32_e64 s[2:3], 0, v19
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v19, 0xffff0000, v50
	v_lshlrev_b32_e32 v53, 16, v52
	v_cmp_lt_f32_e32 vcc, v19, v53
	s_nop 1
	v_cndmask_b32_sdwa v53, v50, v52, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v19, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v19, v50, v19, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v53, v52, v19, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v19, v54, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v19
	v_and_b32_sdwa v19, v54, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v19
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v19, 0x7f80, v12
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v19
	v_and_b32_e32 v19, 0x7f, v12
	v_cmp_ne_u32_e64 s[2:3], 0, v19
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v19, 16, v12
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v52, 16, v54
	v_cmp_gt_f32_e64 s[2:3], v52, v19
	s_nop 1
	v_cndmask_b32_e64 v55, v12, v54, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v52, 0x7fff
	v_cndmask_b32_e64 v52, v12, v52, s[0:1]
	v_cndmask_b32_e32 v55, v54, v52, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v54, v53, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v52, 16, v12
	v_cmp_eq_u32_e32 vcc, s2, v54
	v_and_b32_sdwa v54, v53, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v12, v13, v12, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v54
	v_and_b32_e32 v54, 0x7f80, v12
	v_and_b32_e32 v12, 0x7f, v12
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v54
	v_cmp_ne_u32_e64 s[2:3], 0, v12
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v12, 16, v52
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v54, 16, v53
	v_cmp_gt_f32_e64 s[2:3], v54, v12
	s_nop 1
	v_cndmask_b32_e64 v54, v52, v53, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v54, 0x7fff
	v_cndmask_b32_e64 v52, v52, v54, s[0:1]
	v_cndmask_b32_e32 v54, v53, v52, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v57, v13, v14, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v52, s0, v13, v13
	v_and_b32_sdwa v53, v55, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v53
	v_and_b32_sdwa v53, v55, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v53
	v_and_b32_e32 v53, 0x7f80, v13
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v53
	v_and_b32_e32 v53, 0x7f, v13
	v_cmp_ne_u32_e64 s[2:3], 0, v53
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v53, 16, v52
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v56, 16, v55
	v_cmp_lt_f32_e64 s[2:3], v53, v56
	s_nop 1
	v_cndmask_b32_e64 v56, v13, v55, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v56, 0x7fff
	v_cndmask_b32_e64 v56, v13, v56, s[0:1]
	v_cndmask_b32_e32 v56, v55, v56, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v55, v54, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v55
	v_and_b32_sdwa v55, v54, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v55
	v_and_b32_e32 v55, 0x7f80, v57
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v55
	v_and_b32_e32 v55, 0x7f, v57
	v_cmp_ne_u32_e64 s[2:3], 0, v55
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v55, 0xffff0000, v52
	v_lshlrev_b32_e32 v57, 16, v54
	v_cmp_lt_f32_e32 vcc, v55, v57
	s_nop 1
	v_cndmask_b32_sdwa v55, v13, v54, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v55, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v13, v13, v55, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v55, v54, v13, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v13, s0, v14, v14
	v_and_b32_sdwa v57, v56, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v57
	v_and_b32_sdwa v57, v56, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v54, v15, v14, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v57
	v_and_b32_e32 v57, 0x7f80, v14
	v_and_b32_e32 v14, 0x7f, v14
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v57
	v_cmp_ne_u32_e64 s[2:3], 0, v14
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v14, 16, v13
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v57, 16, v56
	v_cmp_lt_f32_e64 s[2:3], v14, v57
	s_nop 1
	v_cndmask_b32_e64 v57, v13, v56, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v57, 0x7fff
	v_cndmask_b32_e64 v57, v13, v57, s[0:1]
	v_cndmask_b32_e32 v57, v56, v57, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v56, v55, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v56
	v_and_b32_sdwa v56, v55, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v56
	v_and_b32_e32 v56, 0x7f80, v54
	v_and_b32_e32 v54, 0x7f, v54
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v56
	v_cmp_ne_u32_e64 s[2:3], 0, v54
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v54, 0xffff0000, v13
	v_lshlrev_b32_e32 v56, 16, v55
	v_cmp_lt_f32_e32 vcc, v54, v56
	s_nop 1
	v_cndmask_b32_sdwa v56, v13, v55, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v54, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v54, v13, v54, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v56, v55, v54, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v54, s0, v15, v15
	v_and_b32_sdwa v55, v57, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v55
	v_and_b32_sdwa v55, v57, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v55
	v_and_b32_e32 v55, 0x7f80, v15
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v55
	v_and_b32_e32 v55, 0x7f, v15
	v_cmp_ne_u32_e64 s[2:3], 0, v55
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v55, 16, v54
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v58, 16, v57
	v_cmp_lt_f32_e64 s[2:3], v55, v58
	s_nop 1
	v_cndmask_b32_e64 v58, v54, v57, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v58, 0x7fff
	v_cndmask_b32_e64 v58, v54, v58, s[0:1]
	v_cndmask_b32_e32 v58, v57, v58, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v57, v56, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v57
	v_and_b32_sdwa v57, v56, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v57
	v_and_b32_sdwa v57, v15, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v15, v15, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v57
	v_cmp_ne_u32_e64 s[2:3], 0, v15
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v15, 0xffff0000, v54
	v_lshlrev_b32_e32 v57, 16, v56
	v_cmp_lt_f32_e32 vcc, v15, v57
	s_nop 1
	v_cndmask_b32_sdwa v57, v54, v56, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v15, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v15, v54, v15, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v57, v56, v15, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v15, v58, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v15
	v_and_b32_sdwa v15, v58, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v15
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v15, 0x7f80, v8
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v15
	v_and_b32_e32 v15, 0x7f, v8
	v_cmp_ne_u32_e64 s[2:3], 0, v15
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v15, 16, v8
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v56, 16, v58
	v_cmp_gt_f32_e64 s[2:3], v56, v15
	s_nop 1
	v_cndmask_b32_e64 v59, v8, v58, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v56, 0x7fff
	v_cndmask_b32_e64 v56, v8, v56, s[0:1]
	v_cndmask_b32_e32 v59, v58, v56, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v58, v57, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v56, 16, v8
	v_cmp_eq_u32_e32 vcc, s2, v58
	v_and_b32_sdwa v58, v57, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v8, v9, v8, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v58
	v_and_b32_e32 v58, 0x7f80, v8
	v_and_b32_e32 v8, 0x7f, v8
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v58
	v_cmp_ne_u32_e64 s[2:3], 0, v8
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v8, 16, v56
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v58, 16, v57
	v_cmp_gt_f32_e64 s[2:3], v58, v8
	s_nop 1
	v_cndmask_b32_e64 v58, v56, v57, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v58, 0x7fff
	v_cndmask_b32_e64 v56, v56, v58, s[0:1]
	v_cndmask_b32_e32 v58, v57, v56, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v61, v9, v10, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v56, s0, v9, v9
	v_and_b32_sdwa v57, v59, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v57
	v_and_b32_sdwa v57, v59, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v57
	v_and_b32_e32 v57, 0x7f80, v9
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v57
	v_and_b32_e32 v57, 0x7f, v9
	v_cmp_ne_u32_e64 s[2:3], 0, v57
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v57, 16, v56
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v60, 16, v59
	v_cmp_lt_f32_e64 s[2:3], v57, v60
	s_nop 1
	v_cndmask_b32_e64 v60, v9, v59, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v60, 0x7fff
	v_cndmask_b32_e64 v60, v9, v60, s[0:1]
	v_cndmask_b32_e32 v60, v59, v60, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v59, v58, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v59
	v_and_b32_sdwa v59, v58, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v59
	v_and_b32_e32 v59, 0x7f80, v61
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v59
	v_and_b32_e32 v59, 0x7f, v61
	v_cmp_ne_u32_e64 s[2:3], 0, v59
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v59, 0xffff0000, v56
	v_lshlrev_b32_e32 v61, 16, v58
	v_cmp_lt_f32_e32 vcc, v59, v61
	s_nop 1
	v_cndmask_b32_sdwa v59, v9, v58, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v59, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v9, v9, v59, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v59, v58, v9, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v9, s0, v10, v10
	v_and_b32_sdwa v61, v60, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v61
	v_and_b32_sdwa v61, v60, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v58, v11, v10, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v61
	v_and_b32_e32 v61, 0x7f80, v10
	v_and_b32_e32 v10, 0x7f, v10
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v61
	v_cmp_ne_u32_e64 s[2:3], 0, v10
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v10, 16, v9
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v61, 16, v60
	v_cmp_lt_f32_e64 s[2:3], v10, v61
	s_nop 1
	v_cndmask_b32_e64 v61, v9, v60, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v61, 0x7fff
	v_cndmask_b32_e64 v61, v9, v61, s[0:1]
	v_cndmask_b32_e32 v61, v60, v61, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v60, v59, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v60
	v_and_b32_sdwa v60, v59, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v60
	v_and_b32_e32 v60, 0x7f80, v58
	v_and_b32_e32 v58, 0x7f, v58
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v60
	v_cmp_ne_u32_e64 s[2:3], 0, v58
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v58, 0xffff0000, v9
	v_lshlrev_b32_e32 v60, 16, v59
	v_cmp_lt_f32_e32 vcc, v58, v60
	s_nop 1
	v_cndmask_b32_sdwa v60, v9, v59, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v58, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v58, v9, v58, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v60, v59, v58, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v58, s0, v11, v11
	v_and_b32_sdwa v59, v61, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v59
	v_and_b32_sdwa v59, v61, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v59
	v_and_b32_e32 v59, 0x7f80, v11
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v59
	v_and_b32_e32 v59, 0x7f, v11
	v_cmp_ne_u32_e64 s[2:3], 0, v59
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v59, 16, v58
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v62, 16, v61
	v_cmp_lt_f32_e64 s[2:3], v59, v62
	s_nop 1
	v_cndmask_b32_e64 v62, v58, v61, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v62, 0x7fff
	v_cndmask_b32_e64 v62, v58, v62, s[0:1]
	v_cndmask_b32_e32 v62, v61, v62, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v61, v60, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v61
	v_and_b32_sdwa v61, v60, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v61
	v_and_b32_sdwa v61, v11, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v11, v11, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v61
	v_cmp_ne_u32_e64 s[2:3], 0, v11
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v11, 0xffff0000, v58
	v_lshlrev_b32_e32 v61, 16, v60
	v_cmp_lt_f32_e32 vcc, v11, v61
	s_nop 1
	v_cndmask_b32_sdwa v61, v58, v60, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v11, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v11, v58, v11, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v61, v60, v11, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v11, v62, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v11
	v_and_b32_sdwa v11, v62, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v11
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v11, 0x7f80, v4
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v11
	v_and_b32_e32 v11, 0x7f, v4
	v_cmp_ne_u32_e64 s[2:3], 0, v11
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v11, 16, v4
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v60, 16, v62
	v_cmp_gt_f32_e64 s[2:3], v60, v11
	s_nop 1
	v_cndmask_b32_e64 v63, v4, v62, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v60, 0x7fff
	v_cndmask_b32_e64 v60, v4, v60, s[0:1]
	v_cndmask_b32_e32 v63, v62, v60, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v62, v61, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v60, 16, v4
	v_cmp_eq_u32_e32 vcc, s2, v62
	v_and_b32_sdwa v62, v61, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v4, v5, v4, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v62
	v_and_b32_e32 v62, 0x7f80, v4
	v_and_b32_e32 v4, 0x7f, v4
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v62
	v_cmp_ne_u32_e64 s[2:3], 0, v4
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v4, 16, v60
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v62, 16, v61
	v_cmp_gt_f32_e64 s[2:3], v62, v4
	s_nop 1
	v_cndmask_b32_e64 v62, v60, v61, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v62, 0x7fff
	v_cndmask_b32_e64 v60, v60, v62, s[0:1]
	v_cndmask_b32_e32 v62, v61, v60, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v65, v5, v6, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v60, s0, v5, v5
	v_and_b32_sdwa v61, v63, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v61
	v_and_b32_sdwa v61, v63, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v61
	v_and_b32_e32 v61, 0x7f80, v5
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v61
	v_and_b32_e32 v61, 0x7f, v5
	v_cmp_ne_u32_e64 s[2:3], 0, v61
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v61, 16, v60
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v64, 16, v63
	v_cmp_lt_f32_e64 s[2:3], v61, v64
	s_nop 1
	v_cndmask_b32_e64 v64, v5, v63, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v64, 0x7fff
	v_cndmask_b32_e64 v64, v5, v64, s[0:1]
	v_cndmask_b32_e32 v64, v63, v64, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v63, v62, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v63
	v_and_b32_sdwa v63, v62, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v63
	v_and_b32_e32 v63, 0x7f80, v65
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v63
	v_and_b32_e32 v63, 0x7f, v65
	v_cmp_ne_u32_e64 s[2:3], 0, v63
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v63, 0xffff0000, v60
	v_lshlrev_b32_e32 v65, 16, v62
	v_cmp_lt_f32_e32 vcc, v63, v65
	s_nop 1
	v_cndmask_b32_sdwa v63, v5, v62, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v63, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v5, v5, v63, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v63, v62, v5, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v5, s0, v6, v6
	v_and_b32_sdwa v65, v64, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v65
	v_and_b32_sdwa v65, v64, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v62, v7, v6, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v65
	v_and_b32_e32 v65, 0x7f80, v6
	v_and_b32_e32 v6, 0x7f, v6
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v65
	v_cmp_ne_u32_e64 s[2:3], 0, v6
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v6, 16, v5
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v65, 16, v64
	v_cmp_lt_f32_e64 s[2:3], v6, v65
	s_nop 1
	v_cndmask_b32_e64 v65, v5, v64, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v65, 0x7fff
	v_cndmask_b32_e64 v65, v5, v65, s[0:1]
	v_cndmask_b32_e32 v65, v64, v65, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v64, v63, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v64
	v_and_b32_sdwa v64, v63, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v64
	v_and_b32_e32 v64, 0x7f80, v62
	v_and_b32_e32 v62, 0x7f, v62
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v64
	v_cmp_ne_u32_e64 s[2:3], 0, v62
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v62, 0xffff0000, v5
	v_lshlrev_b32_e32 v64, 16, v63
	v_cmp_lt_f32_e32 vcc, v62, v64
	s_nop 1
	v_cndmask_b32_sdwa v66, v5, v63, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v62, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v62, v5, v62, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v66, v63, v62, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v62, s0, v7, v7
	v_and_b32_sdwa v63, v65, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v63
	v_and_b32_sdwa v63, v65, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v63
	v_and_b32_e32 v63, 0x7f80, v7
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v63
	v_and_b32_e32 v63, 0x7f, v7
	v_cmp_ne_u32_e64 s[2:3], 0, v63
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v63, 16, v62
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v64, 16, v65
	v_cmp_lt_f32_e64 s[2:3], v63, v64
	s_nop 1
	v_cndmask_b32_e64 v68, v62, v65, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v64, 0x7fff
	v_cndmask_b32_e64 v64, v62, v64, s[0:1]
	v_cndmask_b32_e32 v68, v65, v64, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v64, v66, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v64
	v_and_b32_sdwa v64, v66, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v64
	v_and_b32_sdwa v64, v7, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v7, v7, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v64
	v_cmp_ne_u32_e64 s[2:3], 0, v7
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v7, 0xffff0000, v62
	v_lshlrev_b32_e32 v64, 16, v66
	v_cmp_lt_f32_e32 vcc, v7, v64
	s_nop 1
	v_cndmask_b32_sdwa v64, v62, v66, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v7, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v7, v62, v7, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v64, v66, v7, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v7, v68, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v7
	v_and_b32_sdwa v7, v68, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v7
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v7, 0x7f80, v0
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v7
	v_and_b32_e32 v7, 0x7f, v0
	v_cmp_ne_u32_e64 s[2:3], 0, v7
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v7, 16, v0
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v65, 16, v68
	v_cmp_gt_f32_e64 s[2:3], v65, v7
	s_nop 1
	v_cndmask_b32_e64 v67, v0, v68, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v65, 0x7fff
	v_cndmask_b32_e64 v65, v0, v65, s[0:1]
	v_cndmask_b32_e32 v67, v68, v65, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v66, v64, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v65, 16, v0
	v_cmp_eq_u32_e32 vcc, s2, v66
	v_and_b32_sdwa v66, v64, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v0, v1, v0, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v66
	v_and_b32_e32 v66, 0x7f80, v0
	v_and_b32_e32 v0, 0x7f, v0
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v66
	v_cmp_ne_u32_e64 s[2:3], 0, v0
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v0, 16, v65
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v66, 16, v64
	v_cmp_gt_f32_e64 s[2:3], v66, v0
	s_nop 1
	v_cndmask_b32_e64 v66, v65, v64, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v66, 0x7fff
	v_cndmask_b32_e64 v65, v65, v66, s[0:1]
	v_cndmask_b32_e32 v66, v64, v65, vcc
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v69, v1, v2, s0
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v64, s0, v1, v1
	v_and_b32_sdwa v65, v67, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v65
	v_and_b32_sdwa v65, v67, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v65
	v_and_b32_e32 v65, 0x7f80, v1
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v65
	v_and_b32_e32 v65, 0x7f, v1
	v_cmp_ne_u32_e64 s[2:3], 0, v65
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v65, 16, v64
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v68, 16, v67
	v_cmp_lt_f32_e64 s[2:3], v65, v68
	s_nop 1
	v_cndmask_b32_e64 v68, v1, v67, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v68, 0x7fff
	v_cndmask_b32_e64 v68, v1, v68, s[0:1]
	v_cndmask_b32_e32 v68, v67, v68, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v67, v66, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_and_b32_sdwa v67, v66, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v67
	v_and_b32_e32 v67, 0x7f80, v69
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_and_b32_e32 v67, 0x7f, v69
	v_cmp_ne_u32_e64 s[2:3], 0, v67
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v67, 0xffff0000, v64
	v_lshlrev_b32_e32 v69, 16, v66
	v_cmp_lt_f32_e32 vcc, v67, v69
	s_nop 1
	v_cndmask_b32_sdwa v67, v1, v66, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v67, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v1, v1, v67, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v67, v66, v1, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v1, s0, v2, v2
	v_and_b32_sdwa v69, v68, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v69
	v_and_b32_sdwa v69, v68, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v66, v3, v2, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v69
	v_and_b32_e32 v69, 0x7f80, v2
	v_and_b32_e32 v2, 0x7f, v2
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v69
	v_cmp_ne_u32_e64 s[2:3], 0, v2
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v2, 16, v1
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v69, 16, v68
	v_cmp_lt_f32_e64 s[2:3], v2, v69
	s_nop 1
	v_cndmask_b32_e64 v69, v1, v68, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v69, 0x7fff
	v_cndmask_b32_e64 v69, v1, v69, s[0:1]
	v_cndmask_b32_e32 v69, v68, v69, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v68, v67, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v68
	v_and_b32_sdwa v68, v67, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v68
	v_and_b32_e32 v68, 0x7f80, v66
	v_and_b32_e32 v66, 0x7f, v66
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v68
	v_cmp_ne_u32_e64 s[2:3], 0, v66
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v66, 0xffff0000, v1
	v_lshlrev_b32_e32 v68, 16, v67
	v_cmp_lt_f32_e32 vcc, v66, v68
	s_nop 1
	v_cndmask_b32_sdwa v68, v1, v67, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v66, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v66, v1, v66, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v68, v67, v66, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	s_movk_i32 s2, 0x7f80
	v_bfi_b32 v79, s0, v3, v3
	v_and_b32_sdwa v66, v69, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v66
	v_and_b32_sdwa v66, v69, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v66
	v_and_b32_e32 v66, 0x7f80, v3
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v66
	v_and_b32_e32 v66, 0x7f, v3
	v_cmp_ne_u32_e64 s[2:3], 0, v66
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], s[0:1], vcc
	v_lshlrev_b32_e32 v81, 16, v79
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v66, 16, v69
	v_cmp_lt_f32_e64 s[2:3], v81, v66
	s_nop 1
	v_cndmask_b32_e64 v66, v79, v69, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v66, 0x7fff
	v_cndmask_b32_e64 v66, v79, v66, s[0:1]
	v_cndmask_b32_e32 v66, v69, v66, vcc
	s_or_b64 exec, exec, s[2:3]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v67, v68, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_and_b32_sdwa v67, v68, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v67
	v_and_b32_sdwa v67, v3, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v3, v3, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_cmp_ne_u32_e64 s[2:3], 0, v3
	s_and_b64 s[2:3], vcc, s[2:3]
	s_nor_b64 s[6:7], s[2:3], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v3, 0xffff0000, v79
	v_lshlrev_b32_e32 v67, 16, v68
	v_cmp_lt_f32_e32 vcc, v3, v67
	s_nop 1
	v_cndmask_b32_sdwa v3, v79, v68, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v3, 0x7fff
	s_mov_b64 vcc, s[2:3]
	v_cndmask_b32_sdwa v3, v79, v3, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v3, v68, v3, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_movk_i32 s2, 0x7f80
	v_and_b32_sdwa v67, v66, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s3, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_and_b32_sdwa v67, v66, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v67
	v_and_b32_sdwa v67, v3, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v67
	v_and_b32_sdwa v67, v3, s3 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[2:3], 0, v67
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], vcc, s[0:1]
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v67, 16, v3
	v_lshlrev_b32_e32 v68, 16, v66
	v_cmp_gt_f32_e64 s[2:3], v68, v67
	s_nop 1
	v_cndmask_b32_e64 v67, v3, v66, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v67, 0x7fff
	v_cndmask_b32_e64 v3, v3, v67, s[0:1]
	v_cndmask_b32_e32 v67, v66, v3, vcc
	s_or_b64 exec, exec, s[2:3]
	v_and_b32_e32 v3, 0xffff, v67
	v_mov_b32_e32 v66, v3
	s_nop 1
	v_permlane32_swap_b32_e64 v3, v66 bound_ctrl:1
	s_movk_i32 s2, 0x7f80
	v_and_b32_e32 v67, 0x7f80, v3
	v_cmp_eq_u32_e32 vcc, s2, v67
	v_and_b32_e32 v67, 0x7f, v3
	v_cmp_ne_u32_e64 s[0:1], 0, v67
	v_and_b32_e32 v67, 0x7f80, v66
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v67
	v_and_b32_e32 v67, 0x7f, v66
	v_cmp_ne_u32_e64 s[2:3], 0, v67
	s_and_b64 s[0:1], s[0:1], s[2:3]
	s_nor_b64 s[2:3], vcc, s[0:1]
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v67, 16, v66
	v_lshlrev_b32_e32 v68, 16, v3
	v_cmp_gt_f32_e64 s[2:3], v68, v67
	s_nop 1
	v_cndmask_b32_e64 v67, v66, v3, s[2:3]
	s_andn2_saveexec_b64 s[2:3], s[6:7]
	v_mov_b32_e32 v67, 0x7fff
	v_cndmask_b32_e64 v66, v66, v67, s[0:1]
	v_cndmask_b32_e32 v67, v3, v66, vcc
	s_or_b64 exec, exec, s[2:3]
	v_lshlrev_b32_e32 v86, 16, v67
	v_sub_f32_e32 v87, v32, v86
	v_and_b32_e32 v32, 0xffff0000, v41
	v_and_b32_e32 v28, 0xffff0000, v28
	v_sub_f32_e32 v94, v31, v86
	v_sub_f32_e32 v31, v43, v86
	v_sub_f32_e32 v43, v45, v86
	v_sub_f32_e32 v45, v8, v86
	v_and_b32_e32 v8, 0xffff0000, v56
	v_sub_f32_e32 v88, v32, v86
	v_lshlrev_b32_e32 v32, 16, v41
	v_sub_f32_e32 v92, v28, v86
	v_and_b32_e32 v28, 0xffff0000, v34
	v_sub_f32_e32 v41, v8, v86
	v_and_b32_e32 v8, 0xffff0000, v9
	v_sub_f32_e32 v95, v28, v86
	v_sub_f32_e32 v34, v8, v86
	v_and_b32_e32 v8, 0xffff0000, v58
	v_sub_f32_e32 v28, v11, v86
	v_sub_f32_e32 v11, v0, v86
	v_and_b32_e32 v0, 0xffff0000, v64
	v_sub_f32_e32 v91, v30, v86
	v_sub_f32_e32 v30, v8, v86
	v_sub_f32_e32 v8, v0, v86
	v_and_b32_e32 v0, 0xffff0000, v1
	v_cvt_pk_bf16_f32 v1, v87, s0
	v_sub_f32_e32 v97, v26, v86
	v_sub_f32_e32 v26, v4, v86
	v_and_b32_e32 v4, 0xffff0000, v60
	v_lshlrev_b32_e32 v1, 16, v1
	s_mov_b32 s0, 0xc2aeac50
	v_sub_f32_e32 v84, v22, v86
	v_sub_f32_e32 v22, v4, v86
	v_and_b32_e32 v4, 0xffff0000, v5
	v_add_f32_e32 v5, 0x42800000, v1
	v_cmp_gt_f32_e32 vcc, s0, v1
	v_lshlrev_b32_e32 v3, 16, v33
	v_sub_f32_e32 v3, v3, v86
	v_cndmask_b32_e32 v1, v1, v5, vcc
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_lshlrev_b32_e32 v3, 16, v3
	v_sub_f32_e32 v89, v32, v86
	v_mul_f32_e32 v5, 0x114b4ea4, v1
	v_cndmask_b32_e32 v1, v1, v5, vcc
	v_add_f32_e32 v5, 0x42800000, v3
	v_cmp_gt_f32_e32 vcc, s0, v3
	v_sub_f32_e32 v66, v14, v86
	v_sub_f32_e32 v14, v7, v86
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_sub_f32_e32 v69, v12, v86
	v_and_b32_e32 v12, 0xffff0000, v52
	v_sub_f32_e32 v67, v12, v86
	v_mul_f32_e32 v5, 0x114b4ea4, v3
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_cvt_pk_bf16_f32 v5, v89, s0
	v_lshlrev_b32_e32 v5, 16, v5
	v_add_f32_e32 v7, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s0, v5
	v_and_b32_e32 v12, 0xffff0000, v13
	v_sub_f32_e32 v68, v53, v86
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	v_sub_f32_e32 v53, v12, v86
	v_and_b32_e32 v12, 0xffff0000, v54
	v_sub_f32_e32 v76, v49, v86
	v_mul_f32_e32 v7, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v7, vcc
	v_cvt_pk_bf16_f32 v7, v88, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v9, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s0, v7
	v_sub_f32_e32 v49, v12, v86
	v_and_b32_e32 v32, 0xffff0000, v40
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	v_sub_f32_e32 v90, v32, v86
	v_sub_f32_e32 v93, v29, v86
	v_sub_f32_e32 v77, v16, v86
	v_mul_f32_e32 v9, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_cvt_pk_bf16_f32 v9, v91, s0
	v_lshlrev_b32_e32 v9, 16, v9
	v_add_f32_e32 v12, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s0, v9
	v_and_b32_e32 v16, 0xffff0000, v48
	v_sub_f32_e32 v75, v16, v86
	v_cndmask_b32_e32 v9, v9, v12, vcc
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	v_and_b32_e32 v16, 0xffff0000, v17
	v_sub_f32_e32 v73, v16, v86
	v_and_b32_e32 v16, 0xffff0000, v50
	v_mul_f32_e32 v12, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v12, vcc
	v_cvt_pk_bf16_f32 v12, v90, s0
	v_lshlrev_b32_e32 v12, 16, v12
	v_add_f32_e32 v13, 0x42800000, v12
	v_cmp_gt_f32_e32 vcc, s0, v12
	v_sub_f32_e32 v71, v16, v86
	v_sub_f32_e32 v74, v18, v86
	v_cndmask_b32_e32 v12, v12, v13, vcc
	v_mul_f32_e32 v12, 0x3fb8aa3b, v12
	v_exp_f32_e32 v12, v12
	v_and_b32_e32 v25, 0xffff0000, v25
	v_sub_f32_e32 v29, v25, v86
	v_and_b32_e32 v25, 0xffff0000, v42
	v_mul_f32_e32 v13, 0x114b4ea4, v12
	v_cndmask_b32_e32 v12, v12, v13, vcc
	v_cvt_pk_bf16_f32 v13, v93, s0
	v_lshlrev_b32_e32 v13, 16, v13
	v_add_f32_e32 v16, 0x42800000, v13
	v_cmp_gt_f32_e32 vcc, s0, v13
	v_sub_f32_e32 v42, v20, v86
	v_and_b32_e32 v20, 0xffff0000, v44
	v_cndmask_b32_e32 v13, v13, v16, vcc
	v_mul_f32_e32 v13, 0x3fb8aa3b, v13
	v_exp_f32_e32 v13, v13
	v_sub_f32_e32 v85, v20, v86
	v_and_b32_e32 v20, 0xffff0000, v21
	v_sub_f32_e32 v83, v20, v86
	v_mul_f32_e32 v16, 0x114b4ea4, v13
	v_cndmask_b32_e32 v13, v13, v16, vcc
	v_cvt_pk_bf16_f32 v16, v92, s0
	v_lshlrev_b32_e32 v16, 16, v16
	v_add_f32_e32 v18, 0x42800000, v16
	v_cmp_gt_f32_e32 vcc, s0, v16
	v_and_b32_e32 v20, 0xffff0000, v46
	v_sub_f32_e32 v80, v20, v86
	v_cndmask_b32_e32 v16, v16, v18, vcc
	v_mul_f32_e32 v16, 0x3fb8aa3b, v16
	v_exp_f32_e32 v16, v16
	v_sub_f32_e32 v24, v24, v86
	v_sub_f32_e32 v78, v23, v86
	v_sub_f32_e32 v96, v35, v86
	v_mul_f32_e32 v18, 0x114b4ea4, v16
	v_cndmask_b32_e32 v16, v16, v18, vcc
	v_cvt_pk_bf16_f32 v18, v94, s0
	v_lshlrev_b32_e32 v18, 16, v18
	v_add_f32_e32 v20, 0x42800000, v18
	v_cmp_gt_f32_e32 vcc, s0, v18
	v_sub_f32_e32 v35, v27, v86
	v_cvt_pk_bf16_f32 v29, v29, s0
	v_cndmask_b32_e32 v18, v18, v20, vcc
	v_mul_f32_e32 v18, 0x3fb8aa3b, v18
	v_exp_f32_e32 v18, v18
	v_lshlrev_b32_e32 v29, 16, v29
	v_cvt_pk_bf16_f32 v31, v31, s0
	v_lshlrev_b32_e32 v31, 16, v31
	v_mul_f32_e32 v20, 0x114b4ea4, v18
	v_cndmask_b32_e32 v18, v18, v20, vcc
	v_cvt_pk_bf16_f32 v20, v24, s0
	v_lshlrev_b32_e32 v20, 16, v20
	v_add_f32_e32 v23, 0x42800000, v20
	v_cmp_gt_f32_e32 vcc, s0, v20
	v_sub_f32_e32 v33, v25, v86
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_cndmask_b32_e32 v20, v20, v23, vcc
	v_mul_f32_e32 v20, 0x3fb8aa3b, v20
	v_exp_f32_e32 v20, v20
	v_lshlrev_b32_e32 v33, 16, v33
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_lshlrev_b32_e32 v35, 16, v35
	v_mul_f32_e32 v23, 0x114b4ea4, v20
	v_cndmask_b32_e32 v20, v20, v23, vcc
	v_cvt_pk_bf16_f32 v23, v96, s0
	v_lshlrev_b32_e32 v23, 16, v23
	v_add_f32_e32 v24, 0x42800000, v23
	v_cmp_gt_f32_e32 vcc, s0, v23
	v_cvt_pk_bf16_f32 v42, v42, s0
	v_lshlrev_b32_e32 v42, 16, v42
	v_cndmask_b32_e32 v23, v23, v24, vcc
	v_mul_f32_e32 v23, 0x3fb8aa3b, v23
	v_exp_f32_e32 v23, v23
	v_cvt_pk_bf16_f32 v43, v43, s0
	v_lshlrev_b32_e32 v43, 16, v43
	v_sub_f32_e32 v82, v47, v86
	v_mul_f32_e32 v24, 0x114b4ea4, v23
	v_cndmask_b32_e32 v23, v23, v24, vcc
	v_cvt_pk_bf16_f32 v24, v95, s0
	v_lshlrev_b32_e32 v24, 16, v24
	v_add_f32_e32 v27, 0x42800000, v24
	v_cmp_gt_f32_e32 vcc, s0, v24
	v_sub_f32_e32 v72, v51, v86
	v_sub_f32_e32 v51, v55, v86
	v_cndmask_b32_e32 v24, v24, v27, vcc
	v_mul_f32_e32 v24, 0x3fb8aa3b, v24
	v_exp_f32_e32 v24, v24
	v_sub_f32_e32 v44, v57, v86
	v_sub_f32_e32 v32, v59, v86
	v_sub_f32_e32 v25, v61, v86
	v_mul_f32_e32 v27, 0x114b4ea4, v24
	v_cndmask_b32_e32 v24, v24, v27, vcc
	v_cvt_pk_bf16_f32 v27, v97, s0
	v_lshlrev_b32_e32 v27, 16, v27
	v_add_f32_e32 v46, 0x42800000, v27
	v_cmp_gt_f32_e32 vcc, s0, v27
	v_sub_f32_e32 v70, v19, v86
	v_sub_f32_e32 v19, v4, v86
	v_cndmask_b32_e32 v27, v27, v46, vcc
	v_mul_f32_e32 v27, 0x3fb8aa3b, v27
	v_exp_f32_e32 v27, v27
	v_and_b32_e32 v4, 0xffff0000, v62
	v_sub_f32_e32 v17, v63, v86
	v_sub_f32_e32 v40, v10, v86
	v_mul_f32_e32 v46, 0x114b4ea4, v27
	v_cndmask_b32_e32 v27, v27, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v29
	v_cmp_gt_f32_e32 vcc, s0, v29
	v_sub_f32_e32 v10, v65, v86
	v_cvt_pk_bf16_f32 v67, v67, s0
	v_cndmask_b32_e32 v29, v29, v46, vcc
	v_mul_f32_e32 v29, 0x3fb8aa3b, v29
	v_exp_f32_e32 v29, v29
	v_lshlrev_b32_e32 v67, 16, v67
	v_cvt_pk_bf16_f32 v66, v66, s0
	v_lshlrev_b32_e32 v66, 16, v66
	v_mul_f32_e32 v46, 0x114b4ea4, v29
	v_cndmask_b32_e32 v29, v29, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v31
	v_cmp_gt_f32_e32 vcc, s0, v31
	v_cvt_pk_bf16_f32 v53, v53, s0
	v_lshlrev_b32_e32 v53, 16, v53
	v_cndmask_b32_e32 v31, v31, v46, vcc
	v_mul_f32_e32 v31, 0x3fb8aa3b, v31
	v_exp_f32_e32 v31, v31
	v_cvt_pk_bf16_f32 v51, v51, s0
	v_lshlrev_b32_e32 v51, 16, v51
	v_cvt_pk_bf16_f32 v49, v49, s0
	v_mul_f32_e32 v46, 0x114b4ea4, v31
	v_cndmask_b32_e32 v31, v31, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v33
	v_cmp_gt_f32_e32 vcc, s0, v33
	v_lshlrev_b32_e32 v49, 16, v49
	v_sub_f32_e32 v47, v15, v86
	v_cndmask_b32_e32 v33, v33, v46, vcc
	v_mul_f32_e32 v33, 0x3fb8aa3b, v33
	v_exp_f32_e32 v33, v33
	v_cvt_pk_bf16_f32 v47, v47, s0
	v_lshlrev_b32_e32 v47, 16, v47
	v_cvt_pk_bf16_f32 v45, v45, s0
	v_mul_f32_e32 v46, 0x114b4ea4, v33
	v_cndmask_b32_e32 v33, v33, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v35
	v_cmp_gt_f32_e32 vcc, s0, v35
	v_lshlrev_b32_e32 v45, 16, v45
	v_cvt_pk_bf16_f32 v44, v44, s0
	v_cndmask_b32_e32 v35, v35, v46, vcc
	v_mul_f32_e32 v35, 0x3fb8aa3b, v35
	v_exp_f32_e32 v35, v35
	v_lshlrev_b32_e32 v44, 16, v44
	v_cvt_pk_bf16_f32 v41, v41, s0
	v_lshlrev_b32_e32 v41, 16, v41
	v_mul_f32_e32 v46, 0x114b4ea4, v35
	v_cndmask_b32_e32 v35, v35, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v42
	v_cmp_gt_f32_e32 vcc, s0, v42
	v_cvt_pk_bf16_f32 v40, v40, s0
	v_lshlrev_b32_e32 v40, 16, v40
	v_cndmask_b32_e32 v42, v42, v46, vcc
	v_mul_f32_e32 v42, 0x3fb8aa3b, v42
	v_exp_f32_e32 v42, v42
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_lshlrev_b32_e32 v34, 16, v34
	v_cvt_pk_bf16_f32 v32, v32, s0
	v_mul_f32_e32 v46, 0x114b4ea4, v42
	v_cndmask_b32_e32 v42, v42, v46, vcc
	v_add_f32_e32 v46, 0x42800000, v43
	v_cmp_gt_f32_e32 vcc, s0, v43
	v_lshlrev_b32_e32 v32, 16, v32
	v_cvt_pk_bf16_f32 v30, v30, s0
	v_cndmask_b32_e32 v43, v43, v46, vcc
	v_mul_f32_e32 v43, 0x3fb8aa3b, v43
	v_exp_f32_e32 v43, v43
	v_lshlrev_b32_e32 v30, 16, v30
	v_cvt_pk_bf16_f32 v28, v28, s0
	v_lshlrev_b32_e32 v28, 16, v28
	v_mul_f32_e32 v46, 0x114b4ea4, v43
	v_cndmask_b32_e32 v43, v43, v46, vcc
	v_cvt_pk_bf16_f32 v46, v85, s0
	v_lshlrev_b32_e32 v46, 16, v46
	v_add_f32_e32 v48, 0x42800000, v46
	v_cmp_gt_f32_e32 vcc, s0, v46
	v_cvt_pk_bf16_f32 v26, v26, s0
	v_lshlrev_b32_e32 v26, 16, v26
	v_cndmask_b32_e32 v46, v46, v48, vcc
	v_mul_f32_e32 v46, 0x3fb8aa3b, v46
	v_exp_f32_e32 v46, v46
	v_cvt_pk_bf16_f32 v25, v25, s0
	v_lshlrev_b32_e32 v25, 16, v25
	v_cvt_pk_bf16_f32 v22, v22, s0
	v_mul_f32_e32 v48, 0x114b4ea4, v46
	v_cndmask_b32_e32 v46, v46, v48, vcc
	v_cvt_pk_bf16_f32 v48, v84, s0
	v_lshlrev_b32_e32 v48, 16, v48
	v_add_f32_e32 v50, 0x42800000, v48
	v_cmp_gt_f32_e32 vcc, s0, v48
	v_lshlrev_b32_e32 v22, 16, v22
	v_sub_f32_e32 v21, v6, v86
	v_cndmask_b32_e32 v48, v48, v50, vcc
	v_mul_f32_e32 v48, 0x3fb8aa3b, v48
	v_exp_f32_e32 v48, v48
	v_cvt_pk_bf16_f32 v21, v21, s0
	v_lshlrev_b32_e32 v21, 16, v21
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_mul_f32_e32 v50, 0x114b4ea4, v48
	v_cndmask_b32_e32 v48, v48, v50, vcc
	v_cvt_pk_bf16_f32 v50, v83, s0
	v_lshlrev_b32_e32 v50, 16, v50
	v_add_f32_e32 v52, 0x42800000, v50
	v_cmp_gt_f32_e32 vcc, s0, v50
	v_lshlrev_b32_e32 v19, 16, v19
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_cndmask_b32_e32 v50, v50, v52, vcc
	v_mul_f32_e32 v50, 0x3fb8aa3b, v50
	v_exp_f32_e32 v50, v50
	v_lshlrev_b32_e32 v17, 16, v17
	v_sub_f32_e32 v15, v4, v86
	v_cvt_pk_bf16_f32 v15, v15, s0
	v_mul_f32_e32 v52, 0x114b4ea4, v50
	v_cndmask_b32_e32 v50, v50, v52, vcc
	v_cvt_pk_bf16_f32 v52, v82, s0
	v_lshlrev_b32_e32 v52, 16, v52
	v_add_f32_e32 v54, 0x42800000, v52
	v_cmp_gt_f32_e32 vcc, s0, v52
	v_lshlrev_b32_e32 v15, 16, v15
	v_cvt_pk_bf16_f32 v14, v14, s0
	v_cndmask_b32_e32 v52, v52, v54, vcc
	v_mul_f32_e32 v52, 0x3fb8aa3b, v52
	v_exp_f32_e32 v52, v52
	v_lshlrev_b32_e32 v14, 16, v14
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_lshlrev_b32_e32 v11, 16, v11
	v_mul_f32_e32 v54, 0x114b4ea4, v52
	v_cndmask_b32_e32 v52, v52, v54, vcc
	v_cvt_pk_bf16_f32 v54, v80, s0
	v_lshlrev_b32_e32 v54, 16, v54
	v_add_f32_e32 v55, 0x42800000, v54
	v_cmp_gt_f32_e32 vcc, s0, v54
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_lshlrev_b32_e32 v10, 16, v10
	v_cndmask_b32_e32 v54, v54, v55, vcc
	v_mul_f32_e32 v54, 0x3fb8aa3b, v54
	v_exp_f32_e32 v54, v54
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_lshlrev_b32_e32 v8, 16, v8
	v_sub_f32_e32 v6, v2, v86
	v_mul_f32_e32 v55, 0x114b4ea4, v54
	v_cndmask_b32_e32 v54, v54, v55, vcc
	v_cvt_pk_bf16_f32 v55, v78, s0
	v_lshlrev_b32_e32 v55, 16, v55
	v_add_f32_e32 v56, 0x42800000, v55
	v_cmp_gt_f32_e32 vcc, s0, v55
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_lshlrev_b32_e32 v6, 16, v6
	v_cndmask_b32_e32 v55, v55, v56, vcc
	v_mul_f32_e32 v55, 0x3fb8aa3b, v55
	v_exp_f32_e32 v55, v55
	v_sub_f32_e32 v4, v0, v86
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_lshlrev_b32_e32 v4, 16, v4
	v_mul_f32_e32 v56, 0x114b4ea4, v55
	v_cndmask_b32_e32 v55, v55, v56, vcc
	v_cvt_pk_bf16_f32 v56, v77, s0
	v_lshlrev_b32_e32 v56, 16, v56
	v_add_f32_e32 v57, 0x42800000, v56
	v_cmp_gt_f32_e32 vcc, s0, v56
	v_sub_f32_e32 v2, v81, v86
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cndmask_b32_e32 v56, v56, v57, vcc
	v_mul_f32_e32 v56, 0x3fb8aa3b, v56
	v_exp_f32_e32 v56, v56
	v_lshlrev_b32_e32 v2, 16, v2
	v_and_b32_e32 v0, 0xffff0000, v79
	v_sub_f32_e32 v0, v0, v86
	v_mul_f32_e32 v57, 0x114b4ea4, v56
	v_cndmask_b32_e32 v56, v56, v57, vcc
	v_cvt_pk_bf16_f32 v57, v76, s0
	v_lshlrev_b32_e32 v57, 16, v57
	v_add_f32_e32 v58, 0x42800000, v57
	v_cmp_gt_f32_e32 vcc, s0, v57
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_lshlrev_b32_e32 v0, 16, v0
	v_cndmask_b32_e32 v57, v57, v58, vcc
	v_mul_f32_e32 v57, 0x3fb8aa3b, v57
	v_exp_f32_e32 v57, v57
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_mul_f32_e32 v58, 0x114b4ea4, v57
	v_cndmask_b32_e32 v57, v57, v58, vcc
	v_cvt_pk_bf16_f32 v58, v75, s0
	v_lshlrev_b32_e32 v58, 16, v58
	v_add_f32_e32 v59, 0x42800000, v58
	v_cmp_gt_f32_e32 vcc, s0, v58
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v1, 16, v1
	v_cndmask_b32_e32 v58, v58, v59, vcc
	v_mul_f32_e32 v58, 0x3fb8aa3b, v58
	v_exp_f32_e32 v58, v58
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_mul_f32_e32 v59, 0x114b4ea4, v58
	v_cndmask_b32_e32 v58, v58, v59, vcc
	v_cvt_pk_bf16_f32 v59, v74, s0
	v_lshlrev_b32_e32 v59, 16, v59
	v_add_f32_e32 v60, 0x42800000, v59
	v_cmp_gt_f32_e32 vcc, s0, v59
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cndmask_b32_e32 v59, v59, v60, vcc
	v_mul_f32_e32 v59, 0x3fb8aa3b, v59
	v_exp_f32_e32 v59, v59
	v_lshlrev_b32_e32 v80, 16, v16
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v23, v23, s0
	v_mul_f32_e32 v60, 0x114b4ea4, v59
	v_cndmask_b32_e32 v59, v59, v60, vcc
	v_cvt_pk_bf16_f32 v60, v73, s0
	v_lshlrev_b32_e32 v60, 16, v60
	v_add_f32_e32 v61, 0x42800000, v60
	v_cmp_gt_f32_e32 vcc, s0, v60
	v_cvt_pk_bf16_f32 v24, v24, s0
	v_cvt_pk_bf16_f32 v27, v27, s0
	v_cndmask_b32_e32 v60, v60, v61, vcc
	v_mul_f32_e32 v60, 0x3fb8aa3b, v60
	v_exp_f32_e32 v60, v60
	v_lshlrev_b32_e32 v27, 16, v27
	v_cvt_pk_bf16_f32 v29, v29, s0
	v_cvt_pk_bf16_f32 v31, v31, s0
	v_mul_f32_e32 v61, 0x114b4ea4, v60
	v_cndmask_b32_e32 v60, v60, v61, vcc
	v_cvt_pk_bf16_f32 v61, v72, s0
	v_lshlrev_b32_e32 v61, 16, v61
	v_add_f32_e32 v62, 0x42800000, v61
	v_cmp_gt_f32_e32 vcc, s0, v61
	v_lshlrev_b32_e32 v31, 16, v31
	v_cvt_pk_bf16_f32 v33, v33, s0
	v_cndmask_b32_e32 v61, v61, v62, vcc
	v_mul_f32_e32 v61, 0x3fb8aa3b, v61
	v_exp_f32_e32 v61, v61
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_lshlrev_b32_e32 v81, 16, v33
	v_cvt_pk_bf16_f32 v42, v42, s0
	v_mul_f32_e32 v62, 0x114b4ea4, v61
	v_cndmask_b32_e32 v61, v61, v62, vcc
	v_cvt_pk_bf16_f32 v62, v71, s0
	v_lshlrev_b32_e32 v62, 16, v62
	v_add_f32_e32 v63, 0x42800000, v62
	v_cmp_gt_f32_e32 vcc, s0, v62
	v_cvt_pk_bf16_f32 v43, v43, s0
	v_cvt_pk_bf16_f32 v46, v46, s0
	v_cndmask_b32_e32 v62, v62, v63, vcc
	v_mul_f32_e32 v62, 0x3fb8aa3b, v62
	v_exp_f32_e32 v62, v62
	v_cvt_pk_bf16_f32 v48, v48, s0
	v_cvt_pk_bf16_f32 v50, v50, s0
	v_cvt_pk_bf16_f32 v52, v52, s0
	v_mul_f32_e32 v63, 0x114b4ea4, v62
	v_cndmask_b32_e32 v62, v62, v63, vcc
	v_cvt_pk_bf16_f32 v63, v70, s0
	v_lshlrev_b32_e32 v63, 16, v63
	v_add_f32_e32 v64, 0x42800000, v63
	v_cmp_gt_f32_e32 vcc, s0, v63
	v_cvt_pk_bf16_f32 v54, v54, s0
	v_cvt_pk_bf16_f32 v55, v55, s0
	v_cndmask_b32_e32 v63, v63, v64, vcc
	v_mul_f32_e32 v63, 0x3fb8aa3b, v63
	v_exp_f32_e32 v63, v63
	v_cvt_pk_bf16_f32 v56, v56, s0
	v_cvt_pk_bf16_f32 v57, v57, s0
	v_cvt_pk_bf16_f32 v58, v58, s0
	v_mul_f32_e32 v64, 0x114b4ea4, v63
	v_cndmask_b32_e32 v63, v63, v64, vcc
	v_cvt_pk_bf16_f32 v64, v69, s0
	v_lshlrev_b32_e32 v64, 16, v64
	v_add_f32_e32 v65, 0x42800000, v64
	v_cmp_gt_f32_e32 vcc, s0, v64
	v_cvt_pk_bf16_f32 v59, v59, s0
	v_cvt_pk_bf16_f32 v60, v60, s0
	v_cndmask_b32_e32 v64, v64, v65, vcc
	v_mul_f32_e32 v64, 0x3fb8aa3b, v64
	v_exp_f32_e32 v64, v64
	v_cvt_pk_bf16_f32 v61, v61, s0
	v_cvt_pk_bf16_f32 v62, v62, s0
	v_cvt_pk_bf16_f32 v63, v63, s0
	v_mul_f32_e32 v65, 0x114b4ea4, v64
	v_cndmask_b32_e32 v64, v64, v65, vcc
	v_cvt_pk_bf16_f32 v65, v68, s0
	v_lshlrev_b32_e32 v65, 16, v65
	v_add_f32_e32 v68, 0x42800000, v65
	v_cmp_gt_f32_e32 vcc, s0, v65
	v_cvt_pk_bf16_f32 v64, v64, s0
	s_mov_b64 s[2:3], exec
	v_cndmask_b32_e32 v65, v65, v68, vcc
	v_mul_f32_e32 v65, 0x3fb8aa3b, v65
	v_exp_f32_e32 v65, v65
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v65
	v_cndmask_b32_e32 v65, v65, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v67
	v_cmp_gt_f32_e32 vcc, s0, v67
	v_cvt_pk_bf16_f32 v65, v65, s0
	s_nop 0
	v_cndmask_b32_e32 v67, v67, v68, vcc
	v_mul_f32_e32 v67, 0x3fb8aa3b, v67
	v_exp_f32_e32 v67, v67
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v67
	v_cndmask_b32_e32 v67, v67, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v66
	v_cmp_gt_f32_e32 vcc, s0, v66
	v_cvt_pk_bf16_f32 v67, v67, s0
	s_nop 0
	v_cndmask_b32_e32 v66, v66, v68, vcc
	v_mul_f32_e32 v66, 0x3fb8aa3b, v66
	v_exp_f32_e32 v66, v66
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v66
	v_cndmask_b32_e32 v66, v66, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v53
	v_cmp_gt_f32_e32 vcc, s0, v53
	v_cvt_pk_bf16_f32 v66, v66, s0
	s_nop 0
	v_cndmask_b32_e32 v53, v53, v68, vcc
	v_mul_f32_e32 v53, 0x3fb8aa3b, v53
	v_exp_f32_e32 v53, v53
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v53
	v_cndmask_b32_e32 v53, v53, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v51
	v_cmp_gt_f32_e32 vcc, s0, v51
	v_cvt_pk_bf16_f32 v53, v53, s0
	v_lshlrev_b32_e32 v53, 16, v53
	v_cndmask_b32_e32 v51, v51, v68, vcc
	v_mul_f32_e32 v51, 0x3fb8aa3b, v51
	v_exp_f32_e32 v51, v51
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v51
	v_cndmask_b32_e32 v51, v51, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v49
	v_cmp_gt_f32_e32 vcc, s0, v49
	v_cvt_pk_bf16_f32 v51, v51, s0
	v_lshlrev_b32_e32 v51, 16, v51
	v_cndmask_b32_e32 v49, v49, v68, vcc
	v_mul_f32_e32 v49, 0x3fb8aa3b, v49
	v_exp_f32_e32 v49, v49
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v49
	v_cndmask_b32_e32 v49, v49, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v47
	v_cmp_gt_f32_e32 vcc, s0, v47
	v_cvt_pk_bf16_f32 v49, v49, s0
	v_lshlrev_b32_e32 v49, 16, v49
	v_cndmask_b32_e32 v47, v47, v68, vcc
	v_mul_f32_e32 v47, 0x3fb8aa3b, v47
	v_exp_f32_e32 v47, v47
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v47
	v_cndmask_b32_e32 v47, v47, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v45
	v_cmp_gt_f32_e32 vcc, s0, v45
	v_cvt_pk_bf16_f32 v47, v47, s0
	s_nop 0
	v_cndmask_b32_e32 v45, v45, v68, vcc
	v_mul_f32_e32 v45, 0x3fb8aa3b, v45
	v_exp_f32_e32 v45, v45
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v45
	v_cndmask_b32_e32 v45, v45, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v44
	v_cmp_gt_f32_e32 vcc, s0, v44
	v_cvt_pk_bf16_f32 v45, v45, s0
	s_nop 0
	v_cndmask_b32_e32 v44, v44, v68, vcc
	v_mul_f32_e32 v44, 0x3fb8aa3b, v44
	v_exp_f32_e32 v44, v44
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v44
	v_cndmask_b32_e32 v44, v44, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v41
	v_cmp_gt_f32_e32 vcc, s0, v41
	v_cvt_pk_bf16_f32 v44, v44, s0
	v_lshlrev_b32_e32 v44, 16, v44
	v_cndmask_b32_e32 v41, v41, v68, vcc
	v_mul_f32_e32 v41, 0x3fb8aa3b, v41
	v_exp_f32_e32 v41, v41
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v41
	v_cndmask_b32_e32 v41, v41, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v40
	v_cmp_gt_f32_e32 vcc, s0, v40
	v_cvt_pk_bf16_f32 v41, v41, s0
	v_lshlrev_b32_e32 v41, 16, v41
	v_cndmask_b32_e32 v40, v40, v68, vcc
	v_mul_f32_e32 v40, 0x3fb8aa3b, v40
	v_exp_f32_e32 v40, v40
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v40
	v_cndmask_b32_e32 v40, v40, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v34
	v_cmp_gt_f32_e32 vcc, s0, v34
	s_nop 1
	v_cndmask_b32_e32 v34, v34, v68, vcc
	v_mul_f32_e32 v34, 0x3fb8aa3b, v34
	v_exp_f32_e32 v34, v34
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v34
	v_cndmask_b32_e32 v34, v34, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v32
	v_cmp_gt_f32_e32 vcc, s0, v32
	v_cvt_pk_bf16_f32 v34, v34, s0
	s_nop 0
	v_cndmask_b32_e32 v32, v32, v68, vcc
	v_mul_f32_e32 v32, 0x3fb8aa3b, v32
	v_exp_f32_e32 v32, v32
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v32
	v_cndmask_b32_e32 v32, v32, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v30
	v_cmp_gt_f32_e32 vcc, s0, v30
	v_cvt_pk_bf16_f32 v69, v32, s0
	s_nop 0
	v_cndmask_b32_e32 v30, v30, v68, vcc
	v_mul_f32_e32 v30, 0x3fb8aa3b, v30
	v_exp_f32_e32 v30, v30
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v30
	v_cndmask_b32_e32 v30, v30, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v28
	v_cmp_gt_f32_e32 vcc, s0, v28
	v_cvt_pk_bf16_f32 v30, v30, s0
	s_nop 0
	v_cndmask_b32_e32 v28, v28, v68, vcc
	v_mul_f32_e32 v28, 0x3fb8aa3b, v28
	v_exp_f32_e32 v28, v28
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v28
	v_cndmask_b32_e32 v28, v28, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v26
	v_cmp_gt_f32_e32 vcc, s0, v26
	v_cvt_pk_bf16_f32 v70, v28, s0
	s_nop 0
	v_cndmask_b32_e32 v26, v26, v68, vcc
	v_mul_f32_e32 v26, 0x3fb8aa3b, v26
	v_exp_f32_e32 v26, v26
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v26
	v_cndmask_b32_e32 v26, v26, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v25
	v_cmp_gt_f32_e32 vcc, s0, v25
	v_cvt_pk_bf16_f32 v26, v26, s0
	s_nop 0
	v_cndmask_b32_e32 v25, v25, v68, vcc
	v_mul_f32_e32 v25, 0x3fb8aa3b, v25
	v_exp_f32_e32 v25, v25
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v25
	v_cndmask_b32_e32 v25, v25, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v22
	v_cmp_gt_f32_e32 vcc, s0, v22
	v_cvt_pk_bf16_f32 v71, v25, s0
	s_nop 0
	v_cndmask_b32_e32 v22, v22, v68, vcc
	v_mul_f32_e32 v22, 0x3fb8aa3b, v22
	v_exp_f32_e32 v22, v22
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v22
	v_cndmask_b32_e32 v22, v22, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v21
	v_cmp_gt_f32_e32 vcc, s0, v21
	v_cvt_pk_bf16_f32 v72, v22, s0
	s_nop 0
	v_cndmask_b32_e32 v21, v21, v68, vcc
	v_mul_f32_e32 v21, 0x3fb8aa3b, v21
	v_exp_f32_e32 v21, v21
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v21
	v_cndmask_b32_e32 v21, v21, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v19
	v_cmp_gt_f32_e32 vcc, s0, v19
	v_cvt_pk_bf16_f32 v73, v21, s0
	s_nop 0
	v_cndmask_b32_e32 v19, v19, v68, vcc
	v_mul_f32_e32 v19, 0x3fb8aa3b, v19
	v_exp_f32_e32 v19, v19
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v19
	v_cndmask_b32_e32 v19, v19, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v17
	v_cmp_gt_f32_e32 vcc, s0, v17
	v_cvt_pk_bf16_f32 v19, v19, s0
	s_nop 0
	v_cndmask_b32_e32 v17, v17, v68, vcc
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_exp_f32_e32 v17, v17
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v17
	v_cndmask_b32_e32 v17, v17, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v15
	v_cmp_gt_f32_e32 vcc, s0, v15
	v_cvt_pk_bf16_f32 v74, v17, s0
	s_nop 0
	v_cndmask_b32_e32 v15, v15, v68, vcc
	v_mul_f32_e32 v15, 0x3fb8aa3b, v15
	v_exp_f32_e32 v15, v15
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v15
	v_cndmask_b32_e32 v15, v15, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v14
	v_cmp_gt_f32_e32 vcc, s0, v14
	v_cvt_pk_bf16_f32 v15, v15, s0
	s_nop 0
	v_cndmask_b32_e32 v14, v14, v68, vcc
	v_mul_f32_e32 v14, 0x3fb8aa3b, v14
	v_exp_f32_e32 v14, v14
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v14
	v_cndmask_b32_e32 v14, v14, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s0, v11
	v_cvt_pk_bf16_f32 v14, v14, s0
	s_nop 0
	v_cndmask_b32_e32 v11, v11, v68, vcc
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v10
	v_cmp_gt_f32_e32 vcc, s0, v10
	v_cvt_pk_bf16_f32 v11, v11, s0
	s_nop 0
	v_cndmask_b32_e32 v10, v10, v68, vcc
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v10
	v_cndmask_b32_e32 v10, v10, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v8
	v_cmp_gt_f32_e32 vcc, s0, v8
	v_cvt_pk_bf16_f32 v10, v10, s0
	s_nop 0
	v_cndmask_b32_e32 v8, v8, v68, vcc
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v8
	v_cndmask_b32_e32 v8, v8, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v6
	v_cmp_gt_f32_e32 vcc, s0, v6
	v_cvt_pk_bf16_f32 v75, v8, s0
	s_nop 0
	v_cndmask_b32_e32 v6, v6, v68, vcc
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v4
	v_cmp_gt_f32_e32 vcc, s0, v4
	v_cvt_pk_bf16_f32 v76, v6, s0
	s_nop 0
	v_cndmask_b32_e32 v4, v4, v68, vcc
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v4
	v_cndmask_b32_e32 v4, v4, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v2
	v_cmp_gt_f32_e32 vcc, s0, v2
	v_cvt_pk_bf16_f32 v77, v4, s0
	v_lshlrev_b32_e32 v4, 16, v3
	v_cndmask_b32_e32 v2, v2, v68, vcc
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_exp_f32_e32 v2, v2
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v2
	v_cndmask_b32_e32 v2, v2, v68, vcc
	v_add_f32_e32 v68, 0x42800000, v0
	v_cmp_gt_f32_e32 vcc, s0, v0
	v_cvt_pk_bf16_f32 v78, v2, s0
	s_nop 0
	v_cndmask_b32_e32 v0, v0, v68, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v68, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v68, vcc
	v_cvt_pk_bf16_f32 v79, v0, s0
	v_lshlrev_b32_e32 v0, 16, v5
	v_add_f32_e32 v2, v0, v1
	v_lshlrev_b32_e32 v5, 16, v7
	v_cvt_pk_bf16_f32 v6, v2, s0
	v_add_f32_e32 v2, v5, v4
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_lshlrev_b32_e32 v3, 16, v2
	v_lshlrev_b32_e32 v2, 16, v12
	v_add_f32_e32 v3, v3, v2
	v_cvt_pk_bf16_f32 v7, v3, s0
	v_lshlrev_b32_e32 v6, 16, v6
	v_lshlrev_b32_e32 v3, 16, v9
	v_add_f32_e32 v6, v6, v3
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_lshlrev_b32_e32 v8, 16, v6
	v_lshlrev_b32_e32 v6, 16, v13
	v_add_f32_e32 v8, v8, v6
	v_cvt_pk_bf16_f32 v9, v8, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v7, v7, v80
	v_lshlrev_b32_e32 v12, 16, v9
	v_lshlrev_b32_e32 v9, 16, v18
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v12, v12, v9
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v8, 16, v20
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_add_f32_e32 v7, v7, v8
	v_lshlrev_b32_e32 v13, 16, v12
	v_lshlrev_b32_e32 v12, 16, v23
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v13, v13, v12
	v_cvt_pk_bf16_f32 v16, v13, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v13, 16, v24
	v_add_f32_e32 v7, v7, v13
	v_lshlrev_b32_e32 v16, 16, v16
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v16, v16, v27
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v18, 16, v29
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_add_f32_e32 v7, v7, v18
	v_lshlrev_b32_e32 v16, 16, v16
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v16, v16, v31
	v_cvt_pk_bf16_f32 v17, v16, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v7, v7, v81
	v_lshlrev_b32_e32 v20, 16, v17
	v_lshlrev_b32_e32 v17, 16, v35
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v20, v20, v17
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v16, 16, v42
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_add_f32_e32 v7, v7, v16
	v_lshlrev_b32_e32 v21, 16, v20
	v_lshlrev_b32_e32 v20, 16, v43
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v21, v21, v20
	v_cvt_pk_bf16_f32 v22, v21, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v21, 16, v46
	v_add_f32_e32 v7, v7, v21
	v_lshlrev_b32_e32 v22, 16, v22
	v_lshlrev_b32_e32 v43, 16, v48
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v22, v22, v43
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v42, 16, v50
	v_cvt_pk_bf16_f32 v22, v22, s0
	v_add_f32_e32 v7, v7, v42
	v_lshlrev_b32_e32 v22, 16, v22
	v_lshlrev_b32_e32 v46, 16, v52
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v22, v22, v46
	v_cvt_pk_bf16_f32 v23, v22, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v48, 16, v54
	v_add_f32_e32 v7, v7, v48
	v_lshlrev_b32_e32 v24, 16, v23
	v_lshlrev_b32_e32 v23, 16, v55
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v24, v24, v23
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v22, 16, v56
	v_cvt_pk_bf16_f32 v24, v24, s0
	v_add_f32_e32 v7, v7, v22
	v_lshlrev_b32_e32 v25, 16, v24
	v_lshlrev_b32_e32 v24, 16, v57
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v25, v25, v24
	v_cvt_pk_bf16_f32 v28, v25, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v25, 16, v58
	v_add_f32_e32 v7, v7, v25
	v_lshlrev_b32_e32 v28, 16, v28
	v_lshlrev_b32_e32 v52, 16, v59
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v28, v28, v52
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v50, 16, v60
	v_cvt_pk_bf16_f32 v28, v28, s0
	v_add_f32_e32 v7, v7, v50
	v_lshlrev_b32_e32 v28, 16, v28
	v_lshlrev_b32_e32 v54, 16, v61
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v28, v28, v54
	v_cvt_pk_bf16_f32 v29, v28, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v55, 16, v62
	v_add_f32_e32 v7, v7, v55
	v_lshlrev_b32_e32 v32, 16, v29
	v_lshlrev_b32_e32 v29, 16, v63
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v32, v32, v29
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v28, 16, v64
	v_cvt_pk_bf16_f32 v32, v32, s0
	v_add_f32_e32 v7, v7, v28
	v_lshlrev_b32_e32 v33, 16, v32
	v_lshlrev_b32_e32 v32, 16, v65
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_add_f32_e32 v33, v33, v32
	v_cvt_pk_bf16_f32 v35, v33, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v33, 16, v67
	v_add_f32_e32 v7, v7, v33
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v35, 16, v35
	v_lshlrev_b32_e32 v56, 16, v66
	v_add_f32_e32 v7, v7, v53
	v_add_f32_e32 v35, v35, v56
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_lshlrev_b32_e32 v35, 16, v35
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v35, v35, v51
	v_add_f32_e32 v7, v7, v49
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v68, v40, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v40, 16, v45
	v_lshlrev_b32_e32 v35, 16, v35
	v_lshlrev_b32_e32 v45, 16, v47
	v_add_f32_e32 v7, v7, v40
	v_add_f32_e32 v35, v35, v45
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_lshlrev_b32_e32 v35, 16, v35
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v35, v35, v44
	v_add_f32_e32 v7, v7, v41
	v_cvt_pk_bf16_f32 v35, v35, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v47, 16, v34
	v_lshlrev_b32_e32 v34, 16, v35
	v_lshlrev_b32_e32 v57, 16, v68
	v_add_f32_e32 v7, v7, v47
	v_add_f32_e32 v34, v34, v57
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_lshlrev_b32_e32 v34, 16, v34
	v_lshlrev_b32_e32 v58, 16, v69
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v59, 16, v30
	v_add_f32_e32 v34, v34, v58
	v_add_f32_e32 v7, v7, v59
	v_cvt_pk_bf16_f32 v34, v34, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v60, 16, v26
	v_lshlrev_b32_e32 v26, 16, v34
	v_lshlrev_b32_e32 v61, 16, v70
	v_add_f32_e32 v7, v7, v60
	v_add_f32_e32 v26, v26, v61
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v26, v26, s0
	v_lshlrev_b32_e32 v26, 16, v26
	v_lshlrev_b32_e32 v62, 16, v71
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v63, 16, v72
	v_add_f32_e32 v26, v26, v62
	v_add_f32_e32 v7, v7, v63
	v_cvt_pk_bf16_f32 v26, v26, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v64, 16, v19
	v_lshlrev_b32_e32 v19, 16, v26
	v_lshlrev_b32_e32 v65, 16, v73
	v_add_f32_e32 v7, v7, v64
	v_add_f32_e32 v19, v19, v65
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_lshlrev_b32_e32 v19, 16, v19
	v_lshlrev_b32_e32 v66, 16, v74
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v67, 16, v15
	v_add_f32_e32 v19, v19, v66
	v_add_f32_e32 v7, v7, v67
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v68, 16, v11
	v_lshlrev_b32_e32 v11, 16, v19
	v_lshlrev_b32_e32 v69, 16, v14
	v_add_f32_e32 v7, v7, v68
	v_add_f32_e32 v11, v11, v69
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_lshlrev_b32_e32 v11, 16, v11
	v_lshlrev_b32_e32 v70, 16, v10
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v71, 16, v75
	v_add_f32_e32 v10, v11, v70
	v_add_f32_e32 v7, v7, v71
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v72, 16, v77
	v_lshlrev_b32_e32 v10, 16, v10
	v_lshlrev_b32_e32 v73, 16, v76
	v_add_f32_e32 v7, v7, v72
	v_add_f32_e32 v10, v10, v73
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_lshlrev_b32_e32 v10, 16, v10
	v_lshlrev_b32_e32 v74, 16, v78
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v75, 16, v79
	v_add_f32_e32 v10, v10, v74
	v_add_f32_e32 v7, v7, v75
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v10, 16, v10
	v_add_f32_e32 v7, v10, v7
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_and_b32_e32 v7, 0xffff, v7
	v_mov_b32_e32 v10, v7
	s_nop 1
	v_permlane32_swap_b32_e64 v7, v10 bound_ctrl:1
	v_lshlrev_b32_e32 v7, 16, v7
	v_lshlrev_b32_e32 v10, 16, v10
	v_add_f32_e32 v7, v10, v7
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v7, 16, v7
	v_rcp_f32_e32 v7, v7
	s_nop 0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_lshlrev_b32_e32 v76, 16, v7
	v_mul_f32_e32 v2, v2, v76
	v_mul_f32_e32 v3, v3, v76
	v_mul_f32_e32 v7, v80, v76
	v_mul_f32_e32 v6, v6, v76
	v_cvt_pk_bf16_f32 v34, v3, v2
	v_cvt_pk_bf16_f32 v35, v6, v7
	v_mul_f32_e32 v2, v18, v76
	v_mul_f32_e32 v3, v27, v76
	v_mul_f32_e32 v6, v81, v76
	v_mul_f32_e32 v7, v31, v76
	v_cvt_pk_bf16_f32 v30, v3, v2
	v_cvt_pk_bf16_f32 v31, v7, v6
	v_mul_f32_e32 v2, v42, v76
	v_mul_f32_e32 v3, v43, v76
	v_mul_f32_e32 v6, v48, v76
	v_mul_f32_e32 v7, v46, v76
	v_cvt_pk_bf16_f32 v26, v3, v2
	v_cvt_pk_bf16_f32 v27, v7, v6
	v_mul_f32_e32 v2, v50, v76
	v_mul_f32_e32 v3, v52, v76
	v_mul_f32_e32 v6, v55, v76
	v_mul_f32_e32 v7, v54, v76
	v_cvt_pk_bf16_f32 v18, v3, v2
	v_cvt_pk_bf16_f32 v19, v7, v6
	v_mul_f32_e32 v2, v53, v76
	v_mul_f32_e32 v3, v56, v76
	v_mul_f32_e32 v6, v49, v76
	v_mul_f32_e32 v7, v51, v76
	v_cvt_pk_bf16_f32 v14, v3, v2
	v_cvt_pk_bf16_f32 v15, v7, v6
	v_mul_f32_e32 v2, v47, v76
	v_mul_f32_e32 v3, v57, v76
	v_mul_f32_e32 v6, v59, v76
	v_mul_f32_e32 v7, v58, v76
	v_cvt_pk_bf16_f32 v10, v3, v2
	v_cvt_pk_bf16_f32 v11, v7, v6
	v_mul_f32_e32 v2, v64, v76
	v_mul_f32_e32 v3, v65, v76
	v_mul_f32_e32 v7, v67, v76
	v_mul_f32_e32 v42, v66, v76
	v_cvt_pk_bf16_f32 v6, v3, v2
	v_cvt_pk_bf16_f32 v7, v42, v7
	v_mul_f32_e32 v2, v72, v76
	v_mul_f32_e32 v3, v73, v76
	v_mul_f32_e32 v42, v75, v76
	v_mul_f32_e32 v43, v74, v76
	v_cvt_pk_bf16_f32 v2, v3, v2
	v_cvt_pk_bf16_f32 v3, v43, v42
	v_mov_b32_e32 v42, s4
	v_mad_i64_i32 v[36:37], s[0:1], s18, v42, v[36:37]
	s_waitcnt lgkmcnt(0)
	s_bfe_i64 s[0:1], s[20:21], 0x200000
	v_mul_lo_u32 v42, v36, s1
	v_mad_u64_u32 v[54:55], s[0:1], v36, s20, 0
	v_mul_f32_e32 v5, v5, v76
	v_mul_f32_e32 v0, v0, v76
	v_mul_lo_u32 v37, v37, s20
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_add3_u32 v55, v55, v42, v37
	v_mul_f32_e32 v1, v1, v76
	v_mul_f32_e32 v4, v4, v76
	v_mul_f32_e32 v9, v9, v76
	v_mul_f32_e32 v8, v8, v76
	v_mul_f32_e32 v13, v13, v76
	v_mul_f32_e32 v12, v12, v76
	v_mul_f32_e32 v17, v17, v76
	v_mul_f32_e32 v16, v16, v76
	v_mul_f32_e32 v36, v21, v76
	v_mul_f32_e32 v37, v20, v76
	v_mul_f32_e32 v23, v23, v76
	v_mul_f32_e32 v22, v22, v76
	v_mul_f32_e32 v42, v25, v76
	v_mul_f32_e32 v43, v24, v76
	v_mul_f32_e32 v46, v29, v76
	v_mul_f32_e32 v53, v28, v76
	v_mul_f32_e32 v56, v33, v76
	v_mul_f32_e32 v32, v32, v76
	v_mul_f32_e32 v57, v45, v76
	v_mul_f32_e32 v40, v40, v76
	v_mul_f32_e32 v41, v41, v76
	v_mul_f32_e32 v44, v44, v76
	v_mul_f32_e32 v58, v61, v76
	v_mul_f32_e32 v59, v60, v76
	v_mul_f32_e32 v60, v63, v76
	v_mul_f32_e32 v61, v62, v76
	v_mul_f32_e32 v62, v69, v76
	v_mul_f32_e32 v63, v68, v76
	v_mul_f32_e32 v64, v71, v76
	v_mul_f32_e32 v65, v70, v76
	v_and_b32_e32 v0, 0xffff, v0
	v_lshlrev_b32_e32 v5, 16, v5
	v_or3_b32 v33, 0, v0, v5
	v_cvt_pk_bf16_f32 v66, v1, s0
	v_cvt_pk_bf16_f32 v67, v4, s0
	v_cvt_pk_bf16_f32 v28, v9, s0
	v_cvt_pk_bf16_f32 v29, v8, s0
	v_cvt_pk_bf16_f32 v51, v13, s0
	v_cvt_pk_bf16_f32 v52, v12, s0
	v_cvt_pk_bf16_f32 v24, v17, s0
	v_cvt_pk_bf16_f32 v25, v16, s0
	v_cvt_pk_bf16_f32 v49, v36, s0
	v_cvt_pk_bf16_f32 v50, v37, s0
	v_cvt_pk_bf16_f32 v16, v23, s0
	v_cvt_pk_bf16_f32 v17, v22, s0
	v_cvt_pk_bf16_f32 v47, v42, s0
	v_cvt_pk_bf16_f32 v48, v43, s0
	v_cvt_pk_bf16_f32 v12, v46, s0
	v_cvt_pk_bf16_f32 v13, v53, s0
	v_cvt_pk_bf16_f32 v45, v56, s0
	v_cvt_pk_bf16_f32 v46, v32, s0
	v_cvt_pk_bf16_f32 v8, v57, s0
	v_cvt_pk_bf16_f32 v9, v40, s0
	v_cvt_pk_bf16_f32 v43, v41, s0
	v_cvt_pk_bf16_f32 v44, v44, s0
	v_cvt_pk_bf16_f32 v4, v58, s0
	v_cvt_pk_bf16_f32 v5, v59, s0
	v_cvt_pk_bf16_f32 v41, v60, s0
	v_cvt_pk_bf16_f32 v42, v61, s0
	v_cvt_pk_bf16_f32 v0, v62, s0
	v_cvt_pk_bf16_f32 v1, v63, s0
	v_cvt_pk_bf16_f32 v37, v64, s0
	v_cvt_pk_bf16_f32 v40, v65, s0
	s_mul_i32 s0, s14, s16
	s_mul_i32 s0, s0, s18
	s_mul_i32 s0, s0, s20
	v_mul_lo_u32 v36, v39, s20
	v_lshlrev_b32_e32 v32, 16, v67
	v_and_b32_e32 v39, 0xffff, v66
	v_mov_b32_e32 v20, s12
	v_mov_b32_e32 v21, s13
	s_lshl_b32 s0, s0, 1
	v_or_b32_e32 v32, v32, v39
	v_lshl_add_u64 v[20:21], v[54:55], 1, v[20:21]
	v_mov_b32_e32 v22, s0
	v_mov_b32_e32 v23, 0x20000
	v_or3_b32 v32, v32, 0, 0
	v_add_lshl_u32 v36, v36, v38, 1
.LBB0_265:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[32:35], v36, s[4:7], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_265
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v29, 16, v29
	v_and_b32_e32 v28, 0xffff, v28
	v_and_b32_e32 v32, 0xffff, v52
	v_lshlrev_b32_e32 v33, 16, v51
	v_or_b32_e32 v28, v29, v28
	v_or3_b32 v29, 0, v32, v33
	v_or3_b32 v28, v28, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_267:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[28:31], v36, s[4:7], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_267
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v25, 16, v25
	v_and_b32_e32 v24, 0xffff, v24
	v_and_b32_e32 v28, 0xffff, v50
	v_lshlrev_b32_e32 v29, 16, v49
	v_or_b32_e32 v24, v25, v24
	v_or3_b32 v25, 0, v28, v29
	v_or3_b32 v24, v24, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_269:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[24:27], v36, s[4:7], 0 offen offset:64
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_269
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v17, 16, v17
	v_and_b32_e32 v16, 0xffff, v16
	v_and_b32_e32 v24, 0xffff, v48
	v_lshlrev_b32_e32 v25, 16, v47
	v_or_b32_e32 v16, v17, v16
	v_or3_b32 v17, 0, v24, v25
	v_or3_b32 v16, v16, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_271:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[16:19], v36, s[4:7], 0 offen offset:96
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_271
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v13, 16, v13
	v_and_b32_e32 v12, 0xffff, v12
	v_and_b32_e32 v16, 0xffff, v46
	v_lshlrev_b32_e32 v17, 16, v45
	v_or_b32_e32 v12, v13, v12
	v_or3_b32 v13, 0, v16, v17
	v_or3_b32 v12, v12, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_273:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[12:15], v36, s[4:7], 0 offen offset:128
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_273
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v9, 16, v9
	v_and_b32_e32 v8, 0xffff, v8
	v_and_b32_e32 v12, 0xffff, v44
	v_lshlrev_b32_e32 v13, 16, v43
	v_or_b32_e32 v8, v9, v8
	v_or3_b32 v9, 0, v12, v13
	v_or3_b32 v8, v8, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_275:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[8:11], v36, s[4:7], 0 offen offset:160
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_275
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v5, 16, v5
	v_and_b32_e32 v4, 0xffff, v4
	v_and_b32_e32 v8, 0xffff, v42
	v_lshlrev_b32_e32 v9, 16, v41
	v_or_b32_e32 v4, v5, v4
	v_or3_b32 v5, 0, v8, v9
	v_or3_b32 v4, v4, 0, 0
	s_mov_b64 s[2:3], exec
.LBB0_277:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[4:7], v36, s[4:7], 0 offen offset:192
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_277
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v1, 16, v1
	v_and_b32_e32 v0, 0xffff, v0
	v_and_b32_e32 v4, 0xffff, v40
	v_lshlrev_b32_e32 v5, 16, v37
	v_or_b32_e32 v0, v1, v0
	v_or3_b32 v1, 0, v4, v5
	v_or3_b32 v0, v0, 0, 0
	s_mov_b64 s[0:1], exec
.LBB0_279:
	v_readfirstlane_b32 s4, v20
	v_readfirstlane_b32 s5, v21
	v_readfirstlane_b32 s6, v22
	v_readfirstlane_b32 s7, v23
	v_cmp_eq_u64_e32 vcc, s[4:5], v[20:21]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[22:23]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[0:3], v36, s[4:7], 0 offen offset:224
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_279
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 96
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
		.amdhsa_next_free_vgpr 98
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 100
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
	.section	.text._Z10softmax_tkILi128EEv15softmax_globalsIXT_EE,"axG",@progbits,_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE,comdat
.Lfunc_end0:
	.size	_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE, .Lfunc_end0-_Z10softmax_tkILi128EEv15softmax_globalsIXT_EE

	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.num_vgpr, 98
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.num_agpr, 0
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.numbered_sgpr, 28
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.private_seg_size, 0
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.uses_vcc, 1
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.uses_flat_scratch, 0
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.has_dyn_sized_stack, 0
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.has_recursion, 0
	.set _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_404136fc13ab8ed6,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_404136fc13ab8ed6
__hip_cuid_404136fc13ab8ed6:
	.byte	0
	.size	__hip_cuid_404136fc13ab8ed6, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_404136fc13ab8ed6
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           96
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 96
    .max_flat_workgroup_size: 1024
    .name:           _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _Z10softmax_tkILi128EEv15softmax_globalsIXT_EE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     98
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
