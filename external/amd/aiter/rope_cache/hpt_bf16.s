	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji,"axG",@progbits,_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji,comdat
	.protected	_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji
	.globl	_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji
	.p2align	8
	.type	_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji,@function
_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_mul_hi_u32 s9, s9, s16
	s_add_i32 s9, s16, s9
	s_lshr_b32 s33, s9, s10
	s_mul_i32 s8, s33, s8
	s_sub_i32 s44, s16, s8
	s_mul_i32 s8, s5, s44
	s_mul_hi_u32 s9, s4, s44
	s_add_i32 s9, s9, s8
	s_mul_i32 s8, s4, s44
	s_lshl_b64 s[8:9], s[8:9], 1
	s_add_u32 s8, s2, s8
	s_addc_u32 s9, s3, s9
	s_ashr_i32 s46, s33, 31
	s_mul_i32 s2, s6, s46
	s_mul_hi_u32 s3, s6, s33
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s7, s33
	s_add_i32 s3, s2, s3
	s_mul_i32 s2, s6, s33
	s_lshl_b64 s[2:3], s[2:3], 1
	s_add_u32 s36, s8, s2
	s_addc_u32 s2, s9, s3
	s_and_b32 s37, s2, 0xffff
	s_mov_b32 s39, 0x20000
	s_movk_i32 s38, 0x400
	v_lshlrev_b32_e32 v1, 4, v0
	buffer_load_dwordx4 v[22:25], v1, s[36:39], 0 offen
	s_load_dwordx4 s[40:43], s[0:1], 0x58
	s_load_dwordx16 s[16:31], s[0:1], 0x88
	s_mov_b32 s45, 0
	;;#ASMSTART
	;;#ASMEND
	s_lshl_b64 s[2:3], s[44:45], 3
	s_waitcnt lgkmcnt(0)
	s_add_u32 s8, s40, s2
	s_addc_u32 s9, s41, s3
	s_load_dwordx2 s[12:13], s[8:9], 0x0
	s_add_u32 s2, s42, s2
	s_addc_u32 s3, s43, s3
	s_load_dwordx2 s[8:9], s[2:3], 0x0
	s_load_dwordx4 s[40:43], s[0:1], 0x78
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	;;#ASMEND
	s_ashr_i32 s2, s11, 31
	v_mov_b32_e32 v2, s11
	v_mov_b32_e32 v3, s2
	v_cmp_lt_i64_e32 vcc, s[8:9], v[2:3]
	s_add_i32 s4, s11, -1
	s_and_b64 s[2:3], vcc, exec
	s_cselect_b32 s6, s8, s4
	s_mov_b64 s[2:3], -1
	v_cmp_gt_i64_e64 s[4:5], s[8:9], -1
	s_and_b64 s[4:5], s[4:5], exec
	s_cselect_b32 s4, s6, 0
	s_mul_i32 s31, s11, s28
	s_mul_i32 s29, s11, s30
	s_lshl_b32 s38, s31, 1
	s_and_b32 s37, s41, 0xffff
	s_lshl_b32 s10, s29, 1
	s_and_b32 s9, s43, 0xffff
	s_cmp_eq_u32 s33, 0
	s_cselect_b64 s[34:35], -1, 0
	s_and_b64 vcc, exec, s[34:35]
	v_and_b32_e32 v26, 7, v0
	s_cbranch_vccnz .LBB0_2
	v_and_b32_e32 v42, 7, v0
	s_mov_b64 s[2:3], 0
.LBB0_2:
	s_load_dwordx2 s[6:7], s[0:1], 0x50
	s_mul_i32 s41, s4, s28
	s_mul_i32 s28, s4, s30
	s_andn2_b64 vcc, exec, s[2:3]
	v_cmp_gt_u32_e64 s[2:3], 8, v0
	s_cbranch_vccnz .LBB0_4
	s_load_dwordx4 s[48:51], s[0:1], 0x38
	s_mul_i32 s4, s25, s44
	s_mul_hi_u32 s5, s24, s44
	s_add_i32 s5, s5, s4
	s_mul_i32 s4, s24, s44
	s_lshl_b64 s[4:5], s[4:5], 1
	s_waitcnt lgkmcnt(0)
	s_add_u32 s52, s48, s4
	s_addc_u32 s4, s49, s5
	s_and_b32 s53, s4, 0xffff
	s_mov_b32 s55, 0x20000
	s_movk_i32 s54, 0x400
	buffer_load_dwordx4 v[18:21], v1, s[52:55], 0 offen
	s_mul_i32 s4, s27, s44
	s_mul_hi_u32 s5, s26, s44
	s_add_i32 s5, s5, s4
	s_mul_i32 s4, s26, s44
	s_lshl_b64 s[4:5], s[4:5], 1
	s_add_u32 s52, s50, s4
	s_addc_u32 s4, s51, s5
	v_lshlrev_b32_e32 v2, 3, v26
	s_and_b32 s53, s4, 0xffff
	s_movk_i32 s54, 0x80
	v_lshlrev_b32_e32 v3, 4, v26
	v_mov_b32_e32 v4, 0x80
	v_cndmask_b32_e64 v5, v4, v3, s[2:3]
	v_subrev_u32_e32 v6, 32, v2
	v_cmp_gt_u32_e32 vcc, 4, v26
	s_nop 1
	v_cndmask_b32_e32 v14, v6, v2, vcc
	v_xor_b32_e32 v2, 64, v3
	v_cndmask_b32_e64 v6, v4, v2, s[2:3]
	buffer_load_dwordx4 v[2:5], v5, s[52:55], 0 offen
	buffer_load_dwordx4 v[6:9], v6, s[52:55], 0 offen
	v_add_u32_e32 v10, s41, v14
	v_mov_b32_e32 v11, s31
	v_cndmask_b32_e64 v10, v11, v10, s[2:3]
	v_lshlrev_b32_e32 v10, 1, v10
	s_mov_b32 s36, s40
	buffer_load_dwordx4 v[10:13], v10, s[36:39], 0 offen
	v_add_u32_e32 v14, s28, v14
	v_mov_b32_e32 v15, s29
	v_cndmask_b32_e64 v14, v15, v14, s[2:3]
	v_lshlrev_b32_e32 v14, 1, v14
	s_mov_b32 s8, s42
	s_mov_b32 s11, s39
	buffer_load_dwordx4 v[14:17], v14, s[8:11], 0 offen
	v_mov_b32_e32 v42, v26
	s_branch .LBB0_5
.LBB0_4:
	v_mov_b32_e32 v18, 0
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v19, v18
	v_mov_b32_e32 v20, v18
	v_mov_b32_e32 v21, v18
.LBB0_5:
	v_readfirstlane_b32 s4, v0
	v_mov_b32_e32 v26, 0
	s_cmp_lt_i32 s4, 8
	s_cselect_b64 s[24:25], -1, 0
	s_cmp_gt_i32 s4, 7
	v_lshlrev_b32_e32 v0, 4, v42
	v_cmp_gt_u32_e64 s[4:5], 4, v42
	v_mov_b32_e32 v27, 0
	v_mov_b32_e32 v28, 0
	v_mov_b32_e32 v29, 0
	v_mov_b32_e32 v34, 0
	v_mov_b32_e32 v35, 0
	v_mov_b32_e32 v36, 0
	v_mov_b32_e32 v37, 0
	v_mov_b32_e32 v30, 0
	v_mov_b32_e32 v31, 0
	v_mov_b32_e32 v32, 0
	v_mov_b32_e32 v33, 0
	v_mov_b32_e32 v38, 0
	v_mov_b32_e32 v39, 0
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	s_cbranch_scc1 .LBB0_7
	s_mul_i32 s8, s17, s44
	s_mul_hi_u32 s11, s16, s44
	s_add_i32 s17, s11, s8
	s_mul_i32 s16, s16, s44
	s_lshl_b64 s[16:17], s[16:17], 1
	s_add_u32 s8, s14, s16
	s_addc_u32 s11, s15, s17
	s_mul_i32 s14, s18, s46
	s_mul_hi_u32 s15, s18, s33
	s_add_i32 s14, s15, s14
	s_mul_i32 s15, s19, s33
	s_add_i32 s15, s14, s15
	s_mul_i32 s14, s18, s33
	s_lshl_b64 s[14:15], s[14:15], 1
	s_add_u32 s16, s8, s14
	s_addc_u32 s8, s11, s15
	v_lshlrev_b32_e32 v26, 3, v42
	s_and_b32 s17, s8, 0xffff
	s_mov_b32 s19, 0x20000
	s_movk_i32 s18, 0x80
	v_mov_b32_e32 v27, 0x80
	v_cndmask_b32_e64 v28, v27, v0, s[2:3]
	v_subrev_u32_e32 v29, 32, v26
	v_cndmask_b32_e64 v26, v29, v26, s[4:5]
	v_xor_b32_e32 v29, 64, v0
	v_cndmask_b32_e64 v27, v27, v29, s[2:3]
	buffer_load_dwordx4 v[38:41], v28, s[16:19], 0 offen
	buffer_load_dwordx4 v[30:33], v27, s[16:19], 0 offen
	v_add_u32_e32 v27, s41, v26
	v_mov_b32_e32 v28, s31
	v_cndmask_b32_e64 v27, v28, v27, s[2:3]
	v_lshlrev_b32_e32 v27, 1, v27
	s_mov_b32 s36, s40
	buffer_load_dwordx4 v[34:37], v27, s[36:39], 0 offen
	v_add_u32_e32 v26, s28, v26
	v_mov_b32_e32 v27, s29
	v_cndmask_b32_e64 v26, v27, v26, s[2:3]
	v_lshlrev_b32_e32 v26, 1, v26
	s_mov_b32 s8, s42
	s_mov_b32 s11, s39
	buffer_load_dwordx4 v[26:29], v26, s[8:11], 0 offen
.LBB0_7:
	s_mul_i32 s8, s21, s44
	s_mul_hi_u32 s9, s20, s44
	s_add_i32 s9, s9, s8
	s_mul_i32 s8, s20, s44
	s_lshl_b64 s[8:9], s[8:9], 1
	s_waitcnt lgkmcnt(0)
	s_add_u32 s8, s6, s8
	s_addc_u32 s9, s7, s9
	s_mul_i32 s6, s22, s46
	s_mul_hi_u32 s7, s22, s33
	s_add_i32 s6, s7, s6
	s_mul_i32 s7, s23, s33
	s_add_i32 s7, s6, s7
	s_mul_i32 s6, s22, s33
	s_lshl_b64 s[6:7], s[6:7], 1
	s_add_u32 s8, s8, s6
	s_addc_u32 s14, s9, s7
	s_and_b32 s9, s14, 0xffff
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0x400
	v_mov_b32_e32 v42, 0x400
	v_cmp_gt_i64_e64 s[6:7], s[12:13], -1
	s_nop 1
	v_cndmask_b32_e64 v42, v42, v1, s[6:7]
	s_andn2_b64 vcc, exec, s[24:25]
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[22:25], v42, s[8:11], 0 offen
	s_cbranch_vccz .LBB0_10
	s_and_b64 s[6:7], s[34:35], s[6:7]
	s_andn2_b64 vcc, exec, s[6:7]
	s_cbranch_vccz .LBB0_11
.LBB0_9:
	s_endpgm
.LBB0_10:
	s_nop 0
	v_and_b32_e32 v23, 0xffff0000, v38
	v_lshlrev_b32_e32 v22, 16, v38
	v_and_b32_e32 v25, 0xffff0000, v30
	v_lshlrev_b32_e32 v24, 16, v30
	v_and_b32_e32 v43, 0xffff0000, v34
	v_lshlrev_b32_e32 v42, 16, v34
	v_and_b32_e32 v45, 0xffff0000, v26
	v_lshlrev_b32_e32 v44, 16, v26
	v_pk_mul_f32 v[24:25], v[24:25], v[44:45]
	s_nop 0
	v_cndmask_b32_e64 v25, v25, -v25, s[4:5]
	v_cndmask_b32_e64 v24, v24, -v24, s[4:5]
	v_pk_fma_f32 v[22:23], v[22:23], v[42:43], v[24:25]
	s_nop 0
	v_cvt_pk_bf16_f32 v22, v22, v23
	v_and_b32_e32 v25, 0xffff0000, v39
	v_lshlrev_b32_e32 v24, 16, v39
	v_and_b32_e32 v39, 0xffff0000, v31
	v_lshlrev_b32_e32 v38, 16, v31
	v_and_b32_e32 v31, 0xffff0000, v35
	v_lshlrev_b32_e32 v30, 16, v35
	v_and_b32_e32 v35, 0xffff0000, v27
	v_lshlrev_b32_e32 v34, 16, v27
	v_pk_mul_f32 v[26:27], v[38:39], v[34:35]
	s_nop 0
	v_cndmask_b32_e64 v27, v27, -v27, s[4:5]
	v_cndmask_b32_e64 v26, v26, -v26, s[4:5]
	v_pk_fma_f32 v[24:25], v[24:25], v[30:31], v[26:27]
	s_nop 0
	v_cvt_pk_bf16_f32 v23, v24, v25
	v_and_b32_e32 v25, 0xffff0000, v40
	v_lshlrev_b32_e32 v24, 16, v40
	v_and_b32_e32 v27, 0xffff0000, v32
	v_lshlrev_b32_e32 v26, 16, v32
	v_and_b32_e32 v31, 0xffff0000, v36
	v_lshlrev_b32_e32 v30, 16, v36
	v_and_b32_e32 v35, 0xffff0000, v28
	v_lshlrev_b32_e32 v34, 16, v28
	v_pk_mul_f32 v[26:27], v[26:27], v[34:35]
	s_nop 0
	v_cndmask_b32_e64 v27, v27, -v27, s[4:5]
	v_cndmask_b32_e64 v26, v26, -v26, s[4:5]
	v_pk_fma_f32 v[24:25], v[24:25], v[30:31], v[26:27]
	s_nop 0
	v_cvt_pk_bf16_f32 v24, v24, v25
	v_and_b32_e32 v27, 0xffff0000, v41
	v_lshlrev_b32_e32 v26, 16, v41
	v_and_b32_e32 v31, 0xffff0000, v33
	v_lshlrev_b32_e32 v30, 16, v33
	v_and_b32_e32 v33, 0xffff0000, v37
	v_lshlrev_b32_e32 v32, 16, v37
	v_and_b32_e32 v35, 0xffff0000, v29
	v_lshlrev_b32_e32 v34, 16, v29
	v_pk_mul_f32 v[28:29], v[30:31], v[34:35]
	s_nop 0
	v_cndmask_b32_e64 v29, v29, -v29, s[4:5]
	v_cndmask_b32_e64 v28, v28, -v28, s[4:5]
	v_pk_fma_f32 v[26:27], v[26:27], v[32:33], v[28:29]
	s_nop 0
	v_cvt_pk_bf16_f32 v25, v26, v27
	s_add_u32 s8, s8, 0x400
	s_addc_u32 s9, s14, 0
	s_and_b32 s9, s9, 0xffff
	s_movk_i32 s10, 0x80
	v_mov_b32_e32 v26, 0x80
	s_and_b64 vcc, s[2:3], s[6:7]
	v_cndmask_b32_e32 v26, v26, v0, vcc
	buffer_store_dwordx4 v[22:25], v26, s[8:11], 0 offen
	s_and_b64 s[6:7], s[34:35], s[6:7]
	s_andn2_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB0_9
.LBB0_11:
	s_load_dwordx2 s[14:15], s[0:1], 0x48
	s_load_dwordx4 s[8:11], s[0:1], 0xd8
	v_mov_b64_e32 v[22:23], 0x7fffffff
	v_cmp_gt_u64_e32 vcc, s[12:13], v[22:23]
	s_cbranch_vccz .LBB0_16
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s17, s8, 31
	s_mov_b32 s16, s8
	s_or_b64 s[6:7], s[12:13], s[16:17]
	s_mov_b32 s6, 0
	s_cmp_lg_u64 s[6:7], 0
	s_cbranch_scc0 .LBB0_19
	s_ashr_i32 s18, s17, 31
	s_mov_b32 s19, s18
	s_add_u32 s6, s16, s18
	s_addc_u32 s7, s17, s18
	s_xor_b64 s[22:23], s[6:7], s[18:19]
	v_cvt_f32_u32_e32 v22, s22
	v_cvt_f32_u32_e32 v23, s23
	v_fmamk_f32 v22, v23, 0x4f800000, v22
	v_rcp_f32_e32 v22, v22
	s_nop 0
	v_mul_f32_e32 v22, 0x5f7ffffc, v22
	v_mul_f32_e32 v23, 0x2f800000, v22
	v_trunc_f32_e32 v23, v23
	v_fmamk_f32 v22, v23, 0xcf800000, v22
	v_cvt_u32_f32_e32 v23, v23
	v_cvt_u32_f32_e32 v22, v22
	s_sub_u32 s6, 0, s22
	s_subb_u32 s7, 0, s23
	v_readfirstlane_b32 s11, v23
	v_readfirstlane_b32 s24, v22
	s_mul_i32 s25, s6, s11
	s_mul_i32 s26, s7, s24
	s_mul_hi_u32 s27, s6, s24
	s_add_i32 s25, s27, s25
	s_add_i32 s25, s25, s26
	s_mul_hi_u32 s26, s24, s25
	s_mul_i32 s27, s24, s25
	s_mul_i32 s28, s6, s24
	s_mul_hi_u32 s24, s24, s28
	s_add_u32 s24, s24, s27
	s_addc_u32 s26, 0, s26
	s_mul_hi_u32 s27, s11, s25
	s_mul_hi_u32 s29, s11, s28
	s_mul_i32 s28, s11, s28
	s_add_u32 s24, s24, s28
	s_addc_u32 s24, s26, s29
	s_addc_u32 s26, s27, 0
	s_mul_i32 s25, s11, s25
	s_add_u32 s24, s24, s25
	s_addc_u32 s25, 0, s26
	v_add_co_u32_e32 v22, vcc, s24, v22
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s11, s11, s25
	s_mul_i32 s24, s6, s11
	v_readfirstlane_b32 s25, v22
	s_mul_hi_u32 s26, s6, s25
	s_add_i32 s24, s26, s24
	s_mul_i32 s7, s7, s25
	s_add_i32 s24, s24, s7
	s_mul_hi_u32 s7, s11, s24
	s_mul_i32 s6, s6, s25
	s_mul_hi_u32 s26, s11, s6
	s_mul_i32 s27, s11, s6
	s_mul_hi_u32 s28, s25, s24
	s_mul_i32 s29, s25, s24
	s_mul_hi_u32 s6, s25, s6
	s_add_u32 s6, s6, s29
	s_addc_u32 s25, 0, s28
	s_add_u32 s6, s6, s27
	s_addc_u32 s6, s25, s26
	s_addc_u32 s7, s7, 0
	s_mul_i32 s24, s11, s24
	s_add_u32 s6, s6, s24
	s_addc_u32 s7, 0, s7
	v_add_co_u32_e32 v22, vcc, s6, v22
	s_cmp_lg_u64 vcc, 0
	s_addc_u32 s11, s11, s7
	s_ashr_i32 s24, s13, 31
	s_mov_b32 s25, s24
	s_add_u32 s6, s12, s24
	s_addc_u32 s7, s13, s24
	s_xor_b64 s[26:27], s[6:7], s[24:25]
	s_mul_hi_u32 s6, s26, s11
	s_mul_i32 s7, s26, s11
	v_readfirstlane_b32 s28, v22
	s_mul_hi_u32 s29, s26, s28
	s_add_u32 s7, s29, s7
	s_addc_u32 s6, 0, s6
	s_mul_hi_u32 s29, s27, s11
	s_mul_hi_u32 s30, s27, s28
	s_mul_i32 s28, s27, s28
	s_add_u32 s7, s7, s28
	s_addc_u32 s6, s6, s30
	s_addc_u32 s7, s29, 0
	s_mul_i32 s11, s27, s11
	s_add_u32 s11, s6, s11
	s_addc_u32 s28, 0, s7
	s_mul_i32 s6, s22, s28
	s_mul_hi_u32 s7, s22, s11
	s_add_i32 s6, s7, s6
	s_mul_i32 s7, s23, s11
	s_add_i32 s29, s6, s7
	s_sub_i32 s6, s27, s29
	s_mul_i32 s7, s22, s11
	v_mov_b32_e32 v22, s7
	v_sub_co_u32_e32 v22, vcc, s26, v22
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s26, s6, s23
	v_subrev_co_u32_e64 v23, s[6:7], s22, v22
	s_cmp_lg_u64 s[6:7], 0
	s_subb_u32 s6, s26, 0
	s_cmp_ge_u32 s6, s23
	s_cselect_b32 s7, -1, 0
	v_readfirstlane_b32 s26, v23
	s_cmp_ge_u32 s26, s22
	s_cselect_b32 s26, -1, 0
	s_cmp_eq_u32 s6, s23
	s_cselect_b32 s6, s26, s7
	s_add_u32 s7, s11, 1
	s_addc_u32 s26, s28, 0
	s_add_u32 s30, s11, 2
	s_addc_u32 s31, s28, 0
	s_cmp_lg_u32 s6, 0
	s_cselect_b32 s6, s30, s7
	s_cselect_b32 s7, s31, s26
	s_cmp_lg_u64 vcc, 0
	s_subb_u32 s26, s27, s29
	s_cmp_ge_u32 s26, s23
	s_cselect_b32 s27, -1, 0
	v_readfirstlane_b32 s29, v22
	s_cmp_ge_u32 s29, s22
	s_cselect_b32 s22, -1, 0
	s_cmp_eq_u32 s26, s23
	s_cselect_b32 s22, s22, s27
	s_cmp_lg_u32 s22, 0
	s_cselect_b32 s7, s7, s28
	s_cselect_b32 s6, s6, s11
	s_xor_b64 s[18:19], s[24:25], s[18:19]
	s_xor_b64 s[6:7], s[6:7], s[18:19]
	s_sub_u32 s6, s6, s18
	s_subb_u32 s7, s7, s19
	s_mov_b64 vcc, exec
	s_cbranch_execnz .LBB0_15
.LBB0_14:
	v_cvt_f32_u32_e32 v22, s16
	v_rcp_iflag_f32_e32 v22, v22
	s_nop 0
	v_mul_f32_e32 v22, 0x4f7ffffe, v22
	v_cvt_u32_f32_e32 v22, v22
	s_mov_b32 s7, 0
	s_sub_i32 s6, 0, s16
	v_readfirstlane_b32 s11, v22
	s_mul_i32 s6, s6, s11
	s_mul_hi_u32 s6, s11, s6
	s_add_i32 s11, s11, s6
	s_mul_hi_u32 s6, s12, s11
	s_add_i32 s11, s6, 1
	s_mul_i32 s18, s6, s16
	s_sub_i32 s18, s12, s18
	s_sub_i32 s19, s18, s16
	s_cmp_ge_u32 s18, s16
	s_cselect_b32 s18, s19, s18
	s_cselect_b32 s6, s11, s6
	s_add_i32 s11, s6, 1
	s_cmp_ge_u32 s18, s16
	s_cselect_b32 s6, s11, s6
.LBB0_15:
	s_mul_i32 s11, s6, s17
	s_mul_hi_u32 s17, s6, s16
	s_add_i32 s11, s17, s11
	s_mul_i32 s17, s7, s16
	s_add_i32 s11, s11, s17
	s_mul_i32 s16, s6, s16
	s_sub_u32 s16, s12, s16
	s_subb_u32 s17, s13, s11
	s_mov_b64 vcc, 0
	s_branch .LBB0_18
.LBB0_16:
	s_mov_b64 vcc, exec
	s_cbranch_execz .LBB0_18
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s6, s13, s9
	s_mul_hi_u32 s7, s12, s9
	s_add_i32 s6, s7, s6
	s_add_i32 s6, s6, s12
	s_lshr_b32 s6, s6, s10
	s_mov_b32 s7, 0
	s_mul_i32 s8, s6, s8
	s_sub_i32 s16, s12, s8
	s_mov_b32 s17, s7
.LBB0_18:
	s_waitcnt lgkmcnt(0)
	s_load_dwordx4 s[8:11], s[0:1], 0xc8
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s1, s6, s9
	s_mul_hi_u32 s9, s6, s8
	s_mul_i32 s7, s7, s8
	s_mul_i32 s0, s6, s8
	s_mul_i32 s6, s16, s11
	s_add_i32 s1, s9, s1
	s_add_i32 s1, s1, s7
	s_mul_hi_u32 s7, s16, s10
	s_add_i32 s6, s7, s6
	s_mul_i32 s7, s17, s10
	s_add_i32 s7, s6, s7
	s_mul_i32 s6, s16, s10
	s_lshl_b64 s[0:1], s[0:1], 1
	s_add_u32 s8, s14, s0
	s_addc_u32 s9, s15, s1
	s_lshl_b64 s[0:1], s[6:7], 1
	s_add_u32 s8, s8, s0
	s_addc_u32 s0, s9, s1
	s_and_b32 s9, s0, 0xffff
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0x400
	buffer_store_dwordx4 v[18:21], v1, s[8:11], 0 offen
	s_nop 1
	v_and_b32_e32 v19, 0xffff0000, v2
	v_lshlrev_b32_e32 v18, 16, v2
	v_and_b32_e32 v21, 0xffff0000, v6
	v_lshlrev_b32_e32 v20, 16, v6
	v_and_b32_e32 v23, 0xffff0000, v10
	v_lshlrev_b32_e32 v22, 16, v10
	v_and_b32_e32 v25, 0xffff0000, v14
	v_lshlrev_b32_e32 v24, 16, v14
	v_pk_mul_f32 v[20:21], v[20:21], v[24:25]
	s_nop 0
	v_cndmask_b32_e64 v21, v21, -v21, s[4:5]
	v_cndmask_b32_e64 v20, v20, -v20, s[4:5]
	v_pk_fma_f32 v[18:19], v[18:19], v[22:23], v[20:21]
	s_nop 0
	v_cvt_pk_bf16_f32 v2, v18, v19
	v_and_b32_e32 v19, 0xffff0000, v3
	v_lshlrev_b32_e32 v18, 16, v3
	v_and_b32_e32 v21, 0xffff0000, v7
	v_lshlrev_b32_e32 v20, 16, v7
	v_and_b32_e32 v7, 0xffff0000, v11
	v_lshlrev_b32_e32 v6, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_pk_mul_f32 v[10:11], v[20:21], v[10:11]
	s_nop 0
	v_cndmask_b32_e64 v11, v11, -v11, s[4:5]
	v_cndmask_b32_e64 v10, v10, -v10, s[4:5]
	v_pk_fma_f32 v[6:7], v[18:19], v[6:7], v[10:11]
	s_nop 0
	v_cvt_pk_bf16_f32 v3, v6, v7
	v_and_b32_e32 v7, 0xffff0000, v4
	v_lshlrev_b32_e32 v6, 16, v4
	v_and_b32_e32 v11, 0xffff0000, v8
	v_lshlrev_b32_e32 v10, 16, v8
	v_and_b32_e32 v15, 0xffff0000, v12
	v_lshlrev_b32_e32 v14, 16, v12
	v_and_b32_e32 v19, 0xffff0000, v16
	v_lshlrev_b32_e32 v18, 16, v16
	v_pk_mul_f32 v[10:11], v[10:11], v[18:19]
	s_nop 0
	v_cndmask_b32_e64 v11, v11, -v11, s[4:5]
	v_cndmask_b32_e64 v10, v10, -v10, s[4:5]
	v_pk_fma_f32 v[6:7], v[6:7], v[14:15], v[10:11]
	s_nop 0
	v_cvt_pk_bf16_f32 v4, v6, v7
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v11, 0xffff0000, v9
	v_lshlrev_b32_e32 v10, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v13
	v_lshlrev_b32_e32 v8, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v17
	v_lshlrev_b32_e32 v12, 16, v17
	v_pk_mul_f32 v[10:11], v[10:11], v[12:13]
	s_nop 0
	v_cndmask_b32_e64 v11, v11, -v11, s[4:5]
	v_cndmask_b32_e64 v10, v10, -v10, s[4:5]
	v_pk_fma_f32 v[6:7], v[6:7], v[8:9], v[10:11]
	s_nop 0
	v_cvt_pk_bf16_f32 v5, v6, v7
	s_add_u32 s8, s8, 0x400
	s_addc_u32 s0, s0, 0
	s_and_b32 s9, s0, 0xffff
	s_movk_i32 s10, 0x80
	v_mov_b32_e32 v1, 0x80
	v_cndmask_b32_e64 v0, v1, v0, s[2:3]
	buffer_store_dwordx4 v[2:5], v0, s[8:11], 0 offen
	s_endpgm
.LBB0_19:
	s_mov_b64 vcc, 0
	s_branch .LBB0_14
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 228
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 46
		.amdhsa_next_free_sgpr 56
		.amdhsa_accum_offset 48
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
	.section	.text._ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji,"axG",@progbits,_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji,comdat
.Lfunc_end0:
	.size	_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji, .Lfunc_end0-_ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji

	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.num_vgpr, 46
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.num_agpr, 0
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.numbered_sgpr, 56
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.private_seg_size, 0
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.uses_vcc, 1
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.uses_flat_scratch, 0
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.has_dyn_sized_stack, 0
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.has_recursion, 0
	.set _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_e7b587bcdc117a1b,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_e7b587bcdc117a1b
__hip_cuid_e7b587bcdc117a1b:
	.byte	0
	.size	__hip_cuid_e7b587bcdc117a1b, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_e7b587bcdc117a1b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           8
        .value_kind:     by_value
      - .offset:         16
        .size:           8
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         104
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         112
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         120
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         128
        .size:           8
        .value_kind:     global_buffer
      - .offset:         136
        .size:           8
        .value_kind:     by_value
      - .offset:         144
        .size:           8
        .value_kind:     by_value
      - .offset:         152
        .size:           8
        .value_kind:     by_value
      - .offset:         160
        .size:           8
        .value_kind:     by_value
      - .offset:         168
        .size:           8
        .value_kind:     by_value
      - .offset:         176
        .size:           8
        .value_kind:     by_value
      - .offset:         184
        .size:           8
        .value_kind:     by_value
      - .offset:         192
        .size:           8
        .value_kind:     by_value
      - .offset:         200
        .size:           8
        .value_kind:     by_value
      - .offset:         208
        .size:           8
        .value_kind:     by_value
      - .offset:         216
        .size:           4
        .value_kind:     by_value
      - .offset:         220
        .size:           4
        .value_kind:     by_value
      - .offset:         224
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 228
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji
    .private_segment_fixed_size: 0
    .sgpr_count:     62
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter45fused_qk_rope_concat_and_cache_mla_seg_kernelIDF16bDF16bDF16bLi512ELi64ELi0ELb1ELb1ELi8ELi1ELb0ELb1ELb1ELb1ELb1EEEvPKT_xxijiiiS3_S3_S3_PT0_PT1_PKxS9_PKfSB_S3_S3_xxxxxxxxxxiji.kd
    .uses_dynamic_stack: false
    .vgpr_count:     46
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
