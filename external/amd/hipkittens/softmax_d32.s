	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._Z10softmax_tkILi32EEv15softmax_globalsIXT_EE,"axG",@progbits,_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE,comdat
	.protected	_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE
	.globl	_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE
	.p2align	8
	.type	_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE,@function
_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE:
	v_lshrrev_b32_e32 v1, 1, v0
	s_load_dwordx8 s[20:27], s[0:1], 0x0
	s_load_dwordx2 s[4:5], s[0:1], 0x20
	s_load_dwordx8 s[12:19], s[0:1], 0x30
	v_and_b32_e32 v1, 0x1e0, v1
	v_lshl_add_u32 v12, s2, 7, v1
	v_ashrrev_i32_e32 v13, 31, v12
	v_mov_b32_e32 v1, s3
	s_load_dwordx2 s[10:11], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	v_mad_i64_i32 v[4:5], s[0:1], s26, v1, v[12:13]
	s_bfe_i64 s[0:1], s[4:5], 0x200000
	v_mul_lo_u32 v1, v5, s4
	v_mul_lo_u32 v6, v4, s1
	v_mad_u64_u32 v[4:5], s[0:1], v4, s4, 0
	s_mul_i32 s0, s22, s24
	s_mul_i32 s0, s0, s26
	v_and_b32_e32 v15, 31, v0
	v_lshrrev_b32_e32 v0, 2, v0
	s_mul_i32 s0, s0, s4
	v_mov_b32_e32 v2, s20
	v_mov_b32_e32 v3, s21
	v_add3_u32 v5, v5, v6, v1
	v_and_b32_e32 v14, 8, v0
	s_lshl_b32 s0, s0, 1
	v_mul_lo_u32 v0, v15, s4
	v_lshl_add_u64 v[8:9], v[4:5], 1, v[2:3]
	v_mov_b32_e32 v10, s0
	v_mov_b32_e32 v11, 0x20000
	v_add_lshl_u32 v16, v0, v14, 1
	s_mov_b64 s[8:9], exec
.LBB0_1:
	v_readfirstlane_b32 s4, v8
	v_readfirstlane_b32 s5, v9
	v_readfirstlane_b32 s6, v10
	v_readfirstlane_b32 s7, v11
	v_cmp_eq_u64_e32 vcc, s[4:5], v[8:9]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[10:11]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[4:7], v16, s[4:7], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_1
	s_mov_b64 exec, s[8:9]
	s_mov_b64 s[8:9], exec
.LBB0_3:
	v_readfirstlane_b32 s4, v8
	v_readfirstlane_b32 s5, v9
	v_readfirstlane_b32 s6, v10
	v_readfirstlane_b32 s7, v11
	v_cmp_eq_u64_e32 vcc, s[4:5], v[8:9]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[10:11]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_load_dwordx4 v[0:3], v16, s[4:7], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_3
	s_mov_b64 exec, s[8:9]
	s_movk_i32 s15, 0x7f80
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v9, 0x7f80, v4
	s_mov_b32 s0, 0x1000706
	v_cmp_eq_u32_e32 vcc, s15, v9
	v_and_b32_e32 v9, 0x7f, v4
	v_perm_b32 v18, v5, v6, s0
	v_cmp_ne_u32_e64 s[0:1], 0, v9
	v_and_b32_e32 v9, 0x7f80, v5
	v_cmp_eq_u32_e64 s[4:5], s15, v9
	v_and_b32_e32 v9, 0x7f, v5
	v_cmp_ne_u32_e64 s[6:7], 0, v9
	v_lshlrev_b32_e32 v9, 16, v4
	v_lshlrev_b32_e32 v10, 16, v5
	v_cmp_lt_f32_e64 s[8:9], v10, v9
	v_mov_b32_e32 v10, 0x7fff
	s_and_b64 s[4:5], s[4:5], s[6:7]
	v_cndmask_b32_e64 v10, v5, v10, s[4:5]
	s_or_b64 s[4:5], s[4:5], s[8:9]
	v_cndmask_b32_e64 v11, v5, v4, s[4:5]
	s_and_b64 vcc, vcc, s[0:1]
	v_cndmask_b32_e32 v11, v11, v10, vcc
	s_movk_i32 s17, 0x7f
	v_and_b32_sdwa v10, v11, s15 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_mov_b32 s2, 0xffff
	v_cmp_eq_u32_e32 vcc, s15, v10
	v_and_b32_sdwa v10, v11, s17 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v17, v7, v6, 16
	v_bfi_b32 v8, s2, v6, v6
	v_cmp_ne_u32_e64 s[0:1], 0, v10
	v_and_b32_e32 v10, 0x7f80, v6
	v_and_b32_e32 v6, 0x7f, v6
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s15, v10
	v_cmp_ne_u32_e64 s[4:5], 0, v6
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v6, 16, v8
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v10, 16, v11
	v_cmp_lt_f32_e64 s[4:5], v6, v10
	s_nop 1
	v_cndmask_b32_e64 v16, v8, v11, s[4:5]
	s_or_saveexec_b64 s[4:5], s[6:7]
	v_bfi_b32 v10, s2, v5, v5
	s_xor_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v16, 0x7fff
	v_cndmask_b32_e64 v16, v8, v16, s[0:1]
	v_cndmask_b32_e32 v16, v11, v16, vcc
	s_or_b64 exec, exec, s[4:5]
	v_alignbit_b32 v19, v5, v4, 16
	v_and_b32_e32 v20, 0x7f80, v19
	v_and_b32_e32 v19, 0x7f, v19
	s_movk_i32 s2, 0x7f80
	v_cmp_ne_u32_e64 s[0:1], 0, v19
	v_and_b32_e32 v19, 0x7f80, v18
	v_and_b32_e32 v18, 0x7f, v18
	v_lshrrev_b32_e32 v11, 16, v4
	v_cmp_eq_u32_e64 s[4:5], s2, v19
	v_cmp_ne_u32_e64 s[6:7], 0, v18
	v_and_b32_e32 v18, 0xffff0000, v10
	v_and_b32_e32 v4, 0xffff0000, v4
	v_cmp_lt_f32_e64 s[8:9], v18, v4
	v_lshrrev_b32_e32 v4, 16, v5
	v_mov_b32_e32 v5, 0x7fff
	s_and_b64 s[4:5], s[4:5], s[6:7]
	v_cmp_eq_u32_e32 vcc, s2, v20
	v_cndmask_b32_e64 v5, v4, v5, s[4:5]
	s_or_b64 s[4:5], s[4:5], s[8:9]
	v_cndmask_b32_e64 v4, v4, v11, s[4:5]
	s_and_b64 vcc, vcc, s[0:1]
	v_cndmask_b32_e32 v4, v4, v5, vcc
	s_movk_i32 s15, 0x7f
	v_and_b32_sdwa v5, v4, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_eq_u32_e32 vcc, s2, v5
	v_and_b32_sdwa v5, v4, s15 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v5
	v_and_b32_e32 v5, 0x7f80, v17
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v5
	v_and_b32_e32 v5, 0x7f, v17
	v_cmp_ne_u32_e64 s[4:5], 0, v5
	s_and_b64 s[4:5], vcc, s[4:5]
	s_nor_b64 s[6:7], s[4:5], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v5, 0xffff0000, v8
	v_lshlrev_b32_e32 v17, 16, v4
	v_cmp_lt_f32_e32 vcc, v5, v17
	s_nop 1
	v_cndmask_b32_sdwa v17, v8, v4, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v5, 0x7fff
	s_mov_b64 vcc, s[4:5]
	v_cndmask_b32_sdwa v5, v8, v5, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v17, v4, v5, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	v_bfi_b32 v4, s0, v7, v7
	v_and_b32_sdwa v5, v16, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v5
	v_and_b32_sdwa v5, v16, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v5
	v_and_b32_e32 v5, 0x7f80, v7
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v5
	v_and_b32_e32 v5, 0x7f, v7
	v_cmp_ne_u32_e64 s[4:5], 0, v5
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v5, 16, v4
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v18, 16, v16
	v_cmp_lt_f32_e64 s[4:5], v5, v18
	s_nop 1
	v_cndmask_b32_e64 v18, v4, v16, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v18, 0x7fff
	v_cndmask_b32_e64 v18, v4, v18, s[0:1]
	v_cndmask_b32_e32 v18, v16, v18, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_sdwa v16, v17, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s4, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v16
	v_and_b32_sdwa v16, v17, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v16
	v_and_b32_sdwa v16, v7, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v7, v7, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v16
	v_cmp_ne_u32_e64 s[4:5], 0, v7
	s_and_b64 s[4:5], vcc, s[4:5]
	s_nor_b64 s[6:7], s[4:5], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v7, 0xffff0000, v4
	v_lshlrev_b32_e32 v16, 16, v17
	v_cmp_lt_f32_e32 vcc, v7, v16
	s_nop 1
	v_cndmask_b32_sdwa v16, v4, v17, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v7, 0x7fff
	s_mov_b64 vcc, s[4:5]
	v_cndmask_b32_sdwa v7, v4, v7, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v16, v17, v7, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_sdwa v7, v18, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v7
	v_and_b32_sdwa v7, v18, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v7
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v7, 0x7f80, v0
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v7
	v_and_b32_e32 v7, 0x7f, v0
	v_cmp_ne_u32_e64 s[4:5], 0, v7
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v7, 16, v0
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v17, 16, v18
	v_cmp_gt_f32_e64 s[4:5], v17, v7
	s_nop 1
	v_cndmask_b32_e64 v19, v0, v18, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v17, 0x7fff
	v_cndmask_b32_e64 v17, v0, v17, s[0:1]
	v_cndmask_b32_e32 v19, v18, v17, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_sdwa v18, v16, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_lshrrev_b32_e32 v17, 16, v0
	v_cmp_eq_u32_e32 vcc, s2, v18
	v_and_b32_sdwa v18, v16, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v0, v1, v0, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v18
	v_and_b32_e32 v18, 0x7f80, v0
	v_and_b32_e32 v0, 0x7f, v0
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v18
	v_cmp_ne_u32_e64 s[4:5], 0, v0
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v0, 16, v17
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v18, 16, v16
	v_cmp_gt_f32_e64 s[4:5], v18, v0
	s_nop 1
	v_cndmask_b32_e64 v18, v17, v16, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v18, 0x7fff
	v_cndmask_b32_e64 v17, v17, v18, s[0:1]
	v_cndmask_b32_e32 v18, v16, v17, vcc
	s_or_b64 exec, exec, s[4:5]
	s_mov_b32 s0, 0x1000706
	v_perm_b32 v21, v1, v2, s0
	s_mov_b32 s0, 0xffff
	v_bfi_b32 v16, s0, v1, v1
	v_and_b32_sdwa v17, v19, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v17
	v_and_b32_sdwa v17, v19, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v17
	v_and_b32_e32 v17, 0x7f80, v1
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v17
	v_and_b32_e32 v17, 0x7f, v1
	v_cmp_ne_u32_e64 s[4:5], 0, v17
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v17, 16, v16
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v20, 16, v19
	v_cmp_lt_f32_e64 s[4:5], v17, v20
	s_nop 1
	v_cndmask_b32_e64 v20, v1, v19, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v20, 0x7fff
	v_cndmask_b32_e64 v20, v1, v20, s[0:1]
	v_cndmask_b32_e32 v20, v19, v20, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_sdwa v19, v18, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v19
	v_and_b32_sdwa v19, v18, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v19
	v_and_b32_e32 v19, 0x7f80, v21
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v19
	v_and_b32_e32 v19, 0x7f, v21
	v_cmp_ne_u32_e64 s[4:5], 0, v19
	s_and_b64 s[4:5], vcc, s[4:5]
	s_nor_b64 s[6:7], s[4:5], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v19, 0xffff0000, v16
	v_lshlrev_b32_e32 v21, 16, v18
	v_cmp_lt_f32_e32 vcc, v19, v21
	s_nop 1
	v_cndmask_b32_sdwa v19, v1, v18, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v19, 0x7fff
	s_mov_b64 vcc, s[4:5]
	v_cndmask_b32_sdwa v1, v1, v19, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v19, v18, v1, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	v_bfi_b32 v1, s0, v2, v2
	v_and_b32_sdwa v21, v20, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v21
	v_and_b32_sdwa v21, v20, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_alignbit_b32 v18, v3, v2, 16
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	v_and_b32_e32 v21, 0x7f80, v2
	v_and_b32_e32 v2, 0x7f, v2
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v21
	v_cmp_ne_u32_e64 s[4:5], 0, v2
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v2, 16, v1
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v21, 16, v20
	v_cmp_lt_f32_e64 s[4:5], v2, v21
	s_nop 1
	v_cndmask_b32_e64 v21, v1, v20, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v21, 0x7fff
	v_cndmask_b32_e64 v21, v1, v21, s[0:1]
	v_cndmask_b32_e32 v21, v20, v21, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_sdwa v20, v19, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v20
	v_and_b32_sdwa v20, v19, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v20
	v_and_b32_e32 v20, 0x7f80, v18
	v_and_b32_e32 v18, 0x7f, v18
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v20
	v_cmp_ne_u32_e64 s[4:5], 0, v18
	s_and_b64 s[4:5], vcc, s[4:5]
	s_nor_b64 s[6:7], s[4:5], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v18, 0xffff0000, v1
	v_lshlrev_b32_e32 v20, 16, v19
	v_cmp_lt_f32_e32 vcc, v18, v20
	s_nop 1
	v_cndmask_b32_sdwa v22, v1, v19, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v18, 0x7fff
	s_mov_b64 vcc, s[4:5]
	v_cndmask_b32_sdwa v18, v1, v18, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v22, v19, v18, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	s_mov_b32 s0, 0xffff
	v_bfi_b32 v18, s0, v3, v3
	v_and_b32_sdwa v19, v21, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s0, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v19
	v_and_b32_sdwa v19, v21, s0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v19
	v_and_b32_e32 v19, 0x7f80, v3
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v19
	v_and_b32_e32 v19, 0x7f, v3
	v_cmp_ne_u32_e64 s[4:5], 0, v19
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], s[0:1], vcc
	v_lshlrev_b32_e32 v19, 16, v18
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v20, 16, v21
	v_cmp_lt_f32_e64 s[4:5], v19, v20
	s_nop 1
	v_cndmask_b32_e64 v20, v18, v21, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v20, 0x7fff
	v_cndmask_b32_e64 v20, v18, v20, s[0:1]
	v_cndmask_b32_e32 v20, v21, v20, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_sdwa v21, v22, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s4, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v21
	v_and_b32_sdwa v21, v22, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	v_and_b32_sdwa v21, v3, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v3, v3, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_and_b64 s[0:1], vcc, s[0:1]
	v_cmp_eq_u32_e32 vcc, s2, v21
	v_cmp_ne_u32_e64 s[4:5], 0, v3
	s_and_b64 s[4:5], vcc, s[4:5]
	s_nor_b64 s[6:7], s[4:5], s[0:1]
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_xor_b64 s[6:7], exec, s[8:9]
	v_and_b32_e32 v3, 0xffff0000, v18
	v_lshlrev_b32_e32 v21, 16, v22
	v_cmp_lt_f32_e32 vcc, v3, v21
	s_nop 1
	v_cndmask_b32_sdwa v3, v18, v22, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	v_mov_b32_e32 v3, 0x7fff
	s_mov_b64 vcc, s[4:5]
	v_cndmask_b32_sdwa v3, v18, v3, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_cndmask_b32_e64 v3, v22, v3, s[0:1]
	s_or_b64 exec, exec, s[6:7]
	v_and_b32_sdwa v21, v20, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_movk_i32 s4, 0x7f
	v_cmp_eq_u32_e32 vcc, s2, v21
	v_and_b32_sdwa v21, v20, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	v_and_b32_sdwa v21, v3, s2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v21
	v_and_b32_sdwa v21, v3, s4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	v_cmp_ne_u32_e64 s[4:5], 0, v21
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v21, 16, v3
	v_lshlrev_b32_e32 v22, 16, v20
	v_cmp_gt_f32_e64 s[4:5], v22, v21
	s_nop 1
	v_cndmask_b32_e64 v21, v3, v20, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v21, 0x7fff
	v_cndmask_b32_e64 v3, v3, v21, s[0:1]
	v_cndmask_b32_e32 v21, v20, v3, vcc
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_e32 v3, 0xffff, v21
	v_mov_b32_e32 v20, v3
	s_nop 1
	v_permlane32_swap_b32_e64 v3, v20 bound_ctrl:1
	v_and_b32_e32 v21, 0x7f80, v3
	v_cmp_eq_u32_e32 vcc, s2, v21
	v_and_b32_e32 v21, 0x7f, v3
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	v_and_b32_e32 v21, 0x7f80, v20
	s_and_b64 vcc, vcc, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s2, v21
	v_and_b32_e32 v21, 0x7f, v20
	v_cmp_ne_u32_e64 s[4:5], 0, v21
	s_and_b64 s[0:1], s[0:1], s[4:5]
	s_nor_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_xor_b64 s[6:7], exec, s[6:7]
	v_lshlrev_b32_e32 v21, 16, v20
	v_lshlrev_b32_e32 v22, 16, v3
	v_cmp_gt_f32_e64 s[4:5], v22, v21
	s_nop 1
	v_cndmask_b32_e64 v21, v20, v3, s[4:5]
	s_andn2_saveexec_b64 s[4:5], s[6:7]
	v_mov_b32_e32 v21, 0x7fff
	v_cndmask_b32_e64 v20, v20, v21, s[0:1]
	v_cndmask_b32_e32 v21, v3, v20, vcc
	s_or_b64 exec, exec, s[4:5]
	v_lshlrev_b32_e32 v3, 16, v11
	v_lshlrev_b32_e32 v11, 16, v21
	v_sub_f32_e32 v9, v9, v11
	v_sub_f32_e32 v3, v3, v11
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_and_b32_e32 v20, 0xffff0000, v10
	v_lshlrev_b32_e32 v10, 16, v10
	v_and_b32_e32 v8, 0xffff0000, v8
	v_and_b32_e32 v4, 0xffff0000, v4
	v_and_b32_e32 v16, 0xffff0000, v16
	v_and_b32_e32 v1, 0xffff0000, v1
	v_and_b32_e32 v18, 0xffff0000, v18
	v_lshlrev_b32_e32 v9, 16, v9
	s_mov_b32 s2, 0xc2aeac50
	v_sub_f32_e32 v20, v20, v11
	v_sub_f32_e32 v10, v10, v11
	v_sub_f32_e32 v8, v8, v11
	v_sub_f32_e32 v6, v6, v11
	v_sub_f32_e32 v4, v4, v11
	v_sub_f32_e32 v5, v5, v11
	v_sub_f32_e32 v0, v0, v11
	v_sub_f32_e32 v7, v7, v11
	v_sub_f32_e32 v16, v16, v11
	v_sub_f32_e32 v17, v17, v11
	v_sub_f32_e32 v1, v1, v11
	v_sub_f32_e32 v2, v2, v11
	v_sub_f32_e32 v18, v18, v11
	v_sub_f32_e32 v11, v19, v11
	v_add_f32_e32 v19, 0x42800000, v9
	v_cmp_gt_f32_e32 vcc, s2, v9
	v_lshlrev_b32_e32 v3, 16, v3
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_cndmask_b32_e32 v9, v9, v19, vcc
	v_add_f32_e32 v19, 0x42800000, v3
	v_cmp_gt_f32_e64 s[0:1], s2, v3
	v_mul_f32_e32 v9, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v9
	v_cndmask_b32_e64 v3, v3, v19, s[0:1]
	v_mul_f32_e32 v3, 0x3fb8aa3b, v3
	v_exp_f32_e32 v3, v3
	v_mul_f32_e32 v19, 0x114b4ea4, v9
	v_cndmask_b32_e32 v9, v9, v19, vcc
	v_lshlrev_b32_e32 v10, 16, v10
	v_mul_f32_e32 v19, 0x114b4ea4, v3
	v_cndmask_b32_e64 v3, v3, v19, s[0:1]
	v_add_f32_e32 v19, 0x42800000, v10
	v_cmp_gt_f32_e32 vcc, s2, v10
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cndmask_b32_e32 v10, v10, v19, vcc
	v_lshlrev_b32_e32 v19, 16, v20
	v_add_f32_e32 v20, 0x42800000, v19
	v_cmp_gt_f32_e64 s[0:1], s2, v19
	v_mul_f32_e32 v10, 0x3fb8aa3b, v10
	v_exp_f32_e32 v10, v10
	v_cndmask_b32_e64 v19, v19, v20, s[0:1]
	v_mul_f32_e32 v19, 0x3fb8aa3b, v19
	v_exp_f32_e32 v19, v19
	v_mul_f32_e32 v20, 0x114b4ea4, v10
	v_cndmask_b32_e32 v10, v10, v20, vcc
	v_lshlrev_b32_e32 v6, 16, v6
	v_mul_f32_e32 v20, 0x114b4ea4, v19
	v_cndmask_b32_e64 v19, v19, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v6
	v_cmp_gt_f32_e32 vcc, s2, v6
	v_lshlrev_b32_e32 v8, 16, v8
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cndmask_b32_e32 v6, v6, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v8
	v_cmp_gt_f32_e64 s[0:1], s2, v8
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	v_cndmask_b32_e64 v8, v8, v20, s[0:1]
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	v_mul_f32_e32 v20, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v20, vcc
	v_lshlrev_b32_e32 v5, 16, v5
	v_mul_f32_e32 v20, 0x114b4ea4, v8
	v_cndmask_b32_e64 v8, v8, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v5
	v_cmp_gt_f32_e32 vcc, s2, v5
	v_lshlrev_b32_e32 v4, 16, v4
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cndmask_b32_e32 v5, v5, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v4
	v_cmp_gt_f32_e64 s[0:1], s2, v4
	v_mul_f32_e32 v5, 0x3fb8aa3b, v5
	v_exp_f32_e32 v5, v5
	v_cndmask_b32_e64 v4, v4, v20, s[0:1]
	v_mul_f32_e32 v4, 0x3fb8aa3b, v4
	v_exp_f32_e32 v4, v4
	v_mul_f32_e32 v20, 0x114b4ea4, v5
	v_cndmask_b32_e32 v5, v5, v20, vcc
	v_lshlrev_b32_e32 v7, 16, v7
	v_mul_f32_e32 v20, 0x114b4ea4, v4
	v_cndmask_b32_e64 v4, v4, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v7
	v_cmp_gt_f32_e32 vcc, s2, v7
	v_lshlrev_b32_e32 v0, 16, v0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cndmask_b32_e32 v7, v7, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v0
	v_cmp_gt_f32_e64 s[0:1], s2, v0
	v_mul_f32_e32 v7, 0x3fb8aa3b, v7
	v_exp_f32_e32 v7, v7
	v_cndmask_b32_e64 v0, v0, v20, s[0:1]
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	v_mul_f32_e32 v20, 0x114b4ea4, v7
	v_cndmask_b32_e32 v7, v7, v20, vcc
	v_lshlrev_b32_e32 v17, 16, v17
	v_mul_f32_e32 v20, 0x114b4ea4, v0
	v_cndmask_b32_e64 v0, v0, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v17
	v_cmp_gt_f32_e32 vcc, s2, v17
	v_lshlrev_b32_e32 v16, 16, v16
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_cndmask_b32_e32 v17, v17, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v16
	v_cmp_gt_f32_e64 s[0:1], s2, v16
	v_mul_f32_e32 v17, 0x3fb8aa3b, v17
	v_exp_f32_e32 v17, v17
	v_cndmask_b32_e64 v16, v16, v20, s[0:1]
	v_mul_f32_e32 v16, 0x3fb8aa3b, v16
	v_exp_f32_e32 v16, v16
	v_mul_f32_e32 v20, 0x114b4ea4, v17
	v_cndmask_b32_e32 v17, v17, v20, vcc
	v_lshlrev_b32_e32 v2, 16, v2
	v_mul_f32_e32 v20, 0x114b4ea4, v16
	v_cndmask_b32_e64 v16, v16, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v2
	v_cmp_gt_f32_e32 vcc, s2, v2
	v_lshlrev_b32_e32 v1, 16, v1
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_cndmask_b32_e32 v2, v2, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v1
	v_cmp_gt_f32_e64 s[0:1], s2, v1
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_exp_f32_e32 v2, v2
	v_cndmask_b32_e64 v1, v1, v20, s[0:1]
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	v_mul_f32_e32 v20, 0x114b4ea4, v2
	v_cndmask_b32_e32 v2, v2, v20, vcc
	v_lshlrev_b32_e32 v11, 16, v11
	v_mul_f32_e32 v20, 0x114b4ea4, v1
	v_cndmask_b32_e64 v1, v1, v20, s[0:1]
	v_add_f32_e32 v20, 0x42800000, v11
	v_cmp_gt_f32_e32 vcc, s2, v11
	v_lshlrev_b32_e32 v18, 16, v18
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cndmask_b32_e32 v11, v11, v20, vcc
	v_add_f32_e32 v20, 0x42800000, v18
	v_cmp_gt_f32_e64 s[0:1], s2, v18
	v_mul_f32_e32 v11, 0x3fb8aa3b, v11
	v_exp_f32_e32 v11, v11
	v_cndmask_b32_e64 v18, v18, v20, s[0:1]
	v_mul_f32_e32 v18, 0x3fb8aa3b, v18
	v_exp_f32_e32 v18, v18
	v_mul_f32_e32 v20, 0x114b4ea4, v11
	v_cndmask_b32_e32 v11, v11, v20, vcc
	v_lshlrev_b32_e32 v9, 16, v9
	v_mul_f32_e32 v20, 0x114b4ea4, v18
	v_lshlrev_b32_e32 v10, 16, v10
	v_cndmask_b32_e64 v18, v18, v20, s[0:1]
	v_add_f32_e32 v20, v10, v9
	v_lshlrev_b32_e32 v3, 16, v3
	v_lshlrev_b32_e32 v19, 16, v19
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_add_f32_e32 v21, v19, v3
	v_cvt_pk_bf16_f32 v21, v21, s0
	v_lshlrev_b32_e32 v20, 16, v20
	v_lshlrev_b32_e32 v6, 16, v6
	v_lshlrev_b32_e32 v21, 16, v21
	v_lshlrev_b32_e32 v8, 16, v8
	v_add_f32_e32 v20, v20, v6
	v_add_f32_e32 v21, v21, v8
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v21, v21, s0
	v_lshlrev_b32_e32 v20, 16, v20
	v_lshlrev_b32_e32 v22, 16, v5
	v_add_f32_e32 v5, v20, v22
	v_lshlrev_b32_e32 v20, 16, v21
	v_lshlrev_b32_e32 v21, 16, v4
	v_add_f32_e32 v4, v20, v21
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_lshlrev_b32_e32 v4, 16, v4
	v_lshlrev_b32_e32 v20, 16, v0
	v_add_f32_e32 v0, v4, v20
	v_lshlrev_b32_e32 v4, 16, v5
	v_lshlrev_b32_e32 v7, 16, v7
	v_add_f32_e32 v4, v4, v7
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_lshlrev_b32_e32 v4, 16, v4
	v_lshlrev_b32_e32 v17, 16, v17
	v_lshlrev_b32_e32 v0, 16, v0
	v_lshlrev_b32_e32 v16, 16, v16
	v_add_f32_e32 v4, v4, v17
	v_add_f32_e32 v0, v0, v16
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_lshlrev_b32_e32 v0, 16, v0
	v_lshlrev_b32_e32 v23, 16, v1
	v_lshlrev_b32_e32 v1, 16, v4
	v_lshlrev_b32_e32 v2, 16, v2
	v_add_f32_e32 v0, v0, v23
	v_add_f32_e32 v1, v1, v2
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_lshlrev_b32_e32 v1, 16, v1
	v_lshlrev_b32_e32 v24, 16, v11
	v_lshlrev_b32_e32 v0, 16, v0
	v_lshlrev_b32_e32 v18, 16, v18
	v_add_f32_e32 v1, v1, v24
	v_add_f32_e32 v0, v0, v18
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_lshlrev_b32_e32 v0, 16, v0
	v_lshlrev_b32_e32 v1, 16, v1
	v_add_f32_e32 v0, v1, v0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_and_b32_e32 v0, 0xffff, v0
	v_mov_b32_e32 v1, v0
	s_nop 1
	v_permlane32_swap_b32_e64 v0, v1 bound_ctrl:1
	v_lshlrev_b32_e32 v0, 16, v0
	v_lshlrev_b32_e32 v1, 16, v1
	v_add_f32_e32 v0, v1, v0
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_lshlrev_b32_e32 v0, 16, v0
	v_rcp_f32_e32 v0, v0
	v_mov_b32_e32 v4, s12
	v_mov_b32_e32 v5, s13
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_lshlrev_b32_e32 v25, 16, v0
	v_mul_f32_e32 v0, v9, v25
	v_cvt_pk_bf16_f32 v9, v0, s0
	v_mul_f32_e32 v0, v3, v25
	v_cvt_pk_bf16_f32 v26, v0, s0
	v_mul_f32_e32 v0, v19, v25
	v_mul_f32_e32 v3, v16, v25
	v_cvt_pk_bf16_f32 v19, v0, s0
	v_mul_f32_e32 v0, v10, v25
	v_cvt_pk_bf16_f32 v16, v3, s0
	v_mul_f32_e32 v3, v17, v25
	v_cvt_pk_bf16_f32 v27, v0, s0
	v_mul_f32_e32 v0, v8, v25
	v_mul_f32_e32 v1, v6, v25
	v_cvt_pk_bf16_f32 v17, v3, s0
	v_mul_f32_e32 v3, v23, v25
	v_mul_f32_e32 v2, v2, v25
	v_cvt_pk_bf16_f32 v10, v1, v0
	v_mul_f32_e32 v0, v21, v25
	v_mul_f32_e32 v1, v22, v25
	v_cvt_pk_bf16_f32 v2, v2, v3
	v_mul_f32_e32 v3, v18, v25
	v_mul_f32_e32 v6, v24, v25
	v_cvt_pk_bf16_f32 v11, v1, v0
	v_mul_f32_e32 v0, v7, v25
	v_mul_f32_e32 v1, v20, v25
	v_cvt_pk_bf16_f32 v3, v6, v3
	v_mov_b32_e32 v6, s3
	v_cvt_pk_bf16_f32 v0, v0, s0
	v_cvt_pk_bf16_f32 v1, v1, s0
	v_mad_i64_i32 v[6:7], s[0:1], s18, v6, v[12:13]
	s_bfe_i64 s[0:1], s[10:11], 0x200000
	v_mul_lo_u32 v8, v7, s10
	v_mul_lo_u32 v12, v6, s1
	v_mad_u64_u32 v[6:7], s[0:1], v6, s10, 0
	s_mul_i32 s0, s14, s16
	s_mul_i32 s0, s0, s18
	v_add3_u32 v7, v7, v12, v8
	s_mul_i32 s0, s0, s10
	v_mul_lo_u32 v12, v15, s10
	v_lshlrev_b32_e32 v15, 16, v26
	v_and_b32_e32 v9, 0xffff, v9
	s_lshl_b32 s0, s0, 1
	v_and_b32_e32 v8, 0xffff, v27
	v_lshlrev_b32_e32 v13, 16, v19
	v_or_b32_e32 v15, v15, v9
	v_lshl_add_u64 v[4:5], v[6:7], 1, v[4:5]
	v_mov_b32_e32 v6, s0
	v_mov_b32_e32 v7, 0x20000
	v_or3_b32 v9, 0, v8, v13
	v_or3_b32 v8, v15, 0, 0
	v_add_lshl_u32 v12, v12, v14, 1
	s_mov_b64 s[2:3], exec
.LBB0_61:
	v_readfirstlane_b32 s4, v4
	v_readfirstlane_b32 s5, v5
	v_readfirstlane_b32 s6, v6
	v_readfirstlane_b32 s7, v7
	v_cmp_eq_u64_e32 vcc, s[4:5], v[4:5]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[6:7]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[8:11], v12, s[4:7], 0 offen
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_61
	s_mov_b64 exec, s[2:3]
	v_lshlrev_b32_e32 v1, 16, v1
	v_and_b32_e32 v0, 0xffff, v0
	v_and_b32_e32 v8, 0xffff, v17
	v_lshlrev_b32_e32 v9, 16, v16
	v_or_b32_e32 v0, v1, v0
	v_or3_b32 v1, 0, v8, v9
	v_or3_b32 v0, v0, 0, 0
	s_mov_b64 s[0:1], exec
.LBB0_63:
	v_readfirstlane_b32 s4, v4
	v_readfirstlane_b32 s5, v5
	v_readfirstlane_b32 s6, v6
	v_readfirstlane_b32 s7, v7
	v_cmp_eq_u64_e32 vcc, s[4:5], v[4:5]
	s_nop 0
	v_cmp_eq_u64_e64 s[0:1], s[6:7], v[6:7]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[0:1]
	buffer_store_dwordx4 v[0:3], v12, s[4:7], 0 offen offset:32
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_63
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE
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
		.amdhsa_next_free_vgpr 28
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 28
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
	.section	.text._Z10softmax_tkILi32EEv15softmax_globalsIXT_EE,"axG",@progbits,_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE,comdat
.Lfunc_end0:
	.size	_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE, .Lfunc_end0-_Z10softmax_tkILi32EEv15softmax_globalsIXT_EE

	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.num_vgpr, 28
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.num_agpr, 0
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.numbered_sgpr, 28
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.private_seg_size, 0
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.uses_vcc, 1
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.uses_flat_scratch, 0
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.has_dyn_sized_stack, 0
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.has_recursion, 0
	.set _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_e7c52a3785c72c32,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_e7c52a3785c72c32
__hip_cuid_e7c52a3785c72c32:
	.byte	0
	.size	__hip_cuid_e7c52a3785c72c32, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_e7c52a3785c72c32
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
    .name:           _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _Z10softmax_tkILi32EEv15softmax_globalsIXT_EE.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     28
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
