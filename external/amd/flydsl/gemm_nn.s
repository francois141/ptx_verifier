; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_nn).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0
	.p2align	8
	.type	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0,@function
hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0:
	s_load_dwordx8 s[12:19], s[4:5], 0x7c
	v_lshrrev_b32_e32 v21, 3, v0
	v_lshlrev_b32_e32 v2, 3, v0
	v_lshrrev_b32_e32 v19, 6, v0
	s_mov_b32 s23, 0x27000
	s_waitcnt lgkmcnt(0)
	s_add_i32 s2, s13, 63
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 26
	s_add_i32 s0, s2, s0
	s_ashr_i32 s6, s0, 6
	s_andn2_b32 s0, s0, 63
	s_cmp_lg_u32 s2, s0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lt_i32 s2, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 s[0:1], s[2:3], s[0:1]
	s_subb_u32 s2, s6, 0
	s_abs_i32 s3, s2
	v_cvt_f32_u32_e32 v1, s3
	s_sub_i32 s11, 0, s3
	s_abs_i32 s6, s8
	s_xor_b32 s7, s2, s8
	v_rcp_f32_e32 v1, v1
	s_ashr_i32 s10, s7, 31
	s_mul_i32 s9, s16, s9
	s_load_dwordx2 s[0:1], s[4:5], 0x18
	s_load_dwordx2 s[20:21], s[4:5], 0x30
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_add_u32_e32 v28, s9, v21
	s_mov_b32 s22, -1
	v_lshrrev_b32_e32 v20, 2, v0
	v_readfirstlane_b32 s15, v1
	s_mul_i32 s11, s11, s15
	s_mul_hi_u32 s11, s15, s11
	s_add_i32 s15, s15, s11
	s_mul_hi_u32 s11, s6, s15
	s_mul_i32 s15, s11, s3
	s_sub_i32 s6, s6, s15
	s_add_i32 s19, s11, 1
	s_sub_i32 s15, s6, s3
	s_cmp_ge_u32 s6, s3
	s_cselect_b32 s11, s19, s11
	s_cselect_b32 s6, s15, s6
	s_add_i32 s15, s11, 1
	s_cmp_ge_u32 s6, s3
	s_cselect_b32 s3, s15, s11
	s_xor_b32 s11, s3, s10
	s_sub_i32 s3, s11, s10
	s_mul_i32 s15, s3, s2
	s_cmp_lg_u32 s8, s15
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lt_i32 s7, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[2:3], s[6:7], s[2:3]
	s_subb_u32 s10, s11, s10
	s_add_i32 s2, s9, s16
	s_min_i32 s2, s2, s14
	s_sub_i32 s6, s2, s9
	s_ashr_i32 s2, s6, 31
	s_lshr_b32 s2, s2, 26
	s_add_i32 s2, s6, s2
	s_sub_i32 s8, s8, s15
	s_ashr_i32 s14, s2, 6
	s_andn2_b32 s2, s2, 63
	s_cmp_lg_u32 s6, s2
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	v_lshlrev_b32_e32 v1, 4, v21
	s_and_b64 s[24:25], s[6:7], s[2:3]
	s_lshl_b32 s7, s8, 6
	v_xor_b32_e32 v1, v1, v2
	v_readfirstlane_b32 s8, v19
	v_and_or_b32 v1, v1, 56, s7
	s_lshl_b32 s6, s10, 6
	s_lshl_b32 s10, s8, 10
	v_cmp_gt_i32_e32 vcc, s13, v1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s1, 0xffff
	s_and_b32 s21, s21, 0xffff
	s_add_i32 s11, s10, 0x4000
	v_cndmask_b32_e32 v29, 0, v1, vcc
	v_mul_lo_u32 v1, v28, s18
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_add_lshl_u32 v1, v29, v1, 1
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v1, s[20:23], 0 offen lds
	v_or_b32_e32 v1, 0x100, v0
	v_lshrrev_b32_e32 v30, 3, v1
	v_lshlrev_b32_e32 v3, 4, v30
	v_xor_b32_e32 v3, v3, v2
	v_and_or_b32 v3, v3, 56, s7
	v_add_u32_e32 v36, s9, v30
	v_cmp_gt_i32_e32 vcc, s13, v3
	s_add_i32 s15, s10, 0x5000
	s_nop 0
	v_cndmask_b32_e32 v31, 0, v3, vcc
	v_mul_lo_u32 v3, v36, s18
	v_add_lshl_u32 v3, v31, v3, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v3, s[20:23], 0 offen lds
	v_or_b32_e32 v4, s6, v21
	v_cmp_gt_i32_e32 vcc, s12, v4
	v_bitop3_b32 v37, v2, 56, v0 bitop3:0x48
	v_add_u32_e32 v3, s9, v37
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v38, v4, s17
	v_add_u32_e32 v32, v38, v3
	v_lshlrev_b32_e32 v4, 1, v32
	s_mov_b32 m0, s10
	s_nop 0
	buffer_load_dwordx4 v4, s[0:3], 0 offen lds
	v_or_b32_e32 v4, s6, v30
	v_cmp_gt_i32_e32 vcc, s12, v4
	s_add_i32 s16, s10, 0x1000
	s_nop 0
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v39, v4, s17
	v_add_u32_e32 v33, v39, v3
	v_lshlrev_b32_e32 v3, 1, v33
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v3, s[0:3], 0 offen lds
	v_lshlrev_b32_e32 v3, 4, v0
	s_cmp_lg_u64 s[24:25], 0
	v_and_b32_e32 v4, 0xc0, v3
	v_lshlrev_b32_e32 v3, 5, v0
	s_subb_u32 s8, s14, 0
	v_lshlrev_b32_e32 v18, 2, v0
	v_and_b32_e32 v3, 0x600, v3
	s_add_i32 s8, s8, -1
	v_and_or_b32 v3, v18, 12, v3
	v_and_b32_e32 v5, 16, v20
	s_cmp_gt_i32 s8, 0
	v_or3_b32 v3, v3, v5, v4
	v_lshrrev_b32_e32 v4, 2, v4
	v_and_b32_e32 v22, 56, v2
	s_cbranch_scc1 .LBB0_2
	s_movk_i32 s2, 0x820
	v_and_b32_e32 v23, 0x400, v2
	v_xor_b32_e32 v25, v3, v4
	v_bitop3_b32 v26, v3, v4, 32 bitop3:0x36
	v_bitop3_b32 v24, v3, v4, s2 bitop3:0x36
	s_mov_b64 s[2:3], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[2:3], -1
.LBB0_3:
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s2, 1
	v_lshrrev_b32_e32 v27, 1, v0
	s_cbranch_scc1 .LBB0_8
	v_lshlrev_b32_e32 v5, 6, v0
	v_and_b32_e32 v5, 0x3c0, v5
	v_and_b32_e32 v6, 24, v27
	v_and_b32_e32 v23, 0x400, v2
	s_movk_i32 s2, 0x820
	v_or3_b32 v2, v5, v6, v23
	v_xor_b32_e32 v25, v3, v4
	v_bitop3_b32 v26, v3, v4, 32 bitop3:0x36
	v_bitop3_b32 v35, v5, v22, v6 bitop3:0x36
	v_bitop3_b32 v24, v3, v4, s2 bitop3:0x36
	s_cmp_eq_u32 s8, 1
	v_bitop3_b32 v34, v2, v22, 32 bitop3:0x36
	s_cbranch_scc1 .LBB0_9
	v_lshlrev_b32_e32 v2, 1, v23
	v_lshl_add_u32 v42, v35, 1, v2
	v_mov_b32_e32 v2, 0
	s_and_b32 s17, s8, 0x7ffffffe
	s_add_i32 s19, s10, 0x6000
	s_add_i32 s24, s10, 0x7000
	s_add_i32 s25, s10, 0x2000
	s_add_i32 s26, s10, 0x3000
	v_lshlrev_b32_e32 v40, 1, v25
	v_lshlrev_b32_e32 v41, 1, v26
	v_lshlrev_b32_e32 v43, 1, v24
	v_lshlrev_b32_e32 v44, 1, v34
	s_mov_b32 s14, 0
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
.LBB0_6:
	s_lshl_b32 s27, s14, 6
	s_or_b32 s27, s27, 64
	v_add_u32_e32 v45, s27, v28
	s_waitcnt vmcnt(0)
	s_barrier
	v_mul_lo_u32 v45, v45, s18
	v_add_lshl_u32 v45, v45, v29, 1
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v45, s[20:23], 0 offen lds
	v_add_u32_e32 v45, s27, v36
	v_mul_lo_u32 v45, v45, s18
	v_add_lshl_u32 v45, v45, v31, 1
	s_mov_b32 m0, s24
	s_nop 0
	buffer_load_dwordx4 v45, s[20:23], 0 offen lds
	v_add_lshl_u32 v45, v32, s27, 1
	s_mov_b32 m0, s25
	s_nop 0
	buffer_load_dwordx4 v45, s[0:3], 0 offen lds
	v_add_lshl_u32 v45, v33, s27, 1
	s_mov_b32 m0, s26
	s_nop 0
	buffer_load_dwordx4 v45, s[0:3], 0 offen lds
	ds_read_b64_tr_b16 v[62:63], v41 offset:16384
	ds_read_b64_tr_b16 v[64:65], v41 offset:16896
	ds_read_b128 v[46:49], v42
	ds_read_b64_tr_b16 v[50:51], v40 offset:16384
	ds_read_b64_tr_b16 v[52:53], v40 offset:16896
	ds_read_b128 v[54:57], v42 offset:4096
	ds_read_b64_tr_b16 v[58:59], v40 offset:20480
	ds_read_b64_tr_b16 v[60:61], v40 offset:20992
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[50:53], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[46:49], v[62:65], v[10:13]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[54:57], v[50:53], v[14:17]
	ds_read_b128 v[46:49], v44
	ds_read_b128 v[50:53], v44 offset:4096
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[62:65], v[6:9]
	ds_read_b64_tr_b16 v[54:55], v43 offset:16384
	ds_read_b64_tr_b16 v[56:57], v43 offset:16896
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[58:61], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[46:49], v[54:57], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[50:53], v[58:61], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[50:53], v[54:57], v[6:9]
	s_add_i32 s14, s14, 2
	s_lshl_b32 s27, s14, 6
	s_add_i32 s27, s27, s9
	v_add_u32_e32 v45, s27, v21
	s_waitcnt vmcnt(0)
	s_barrier
	v_mul_lo_u32 v45, v45, s18
	v_add_lshl_u32 v45, v45, v29, 1
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v45, s[20:23], 0 offen lds
	v_add_u32_e32 v45, s27, v30
	v_mul_lo_u32 v45, v45, s18
	v_add_lshl_u32 v45, v45, v31, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v45, s[20:23], 0 offen lds
	v_add_u32_e32 v45, s27, v37
	v_add_lshl_u32 v46, v45, v38, 1
	s_mov_b32 m0, s10
	s_nop 0
	buffer_load_dwordx4 v46, s[0:3], 0 offen lds
	v_add_lshl_u32 v45, v45, v39, 1
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v45, s[0:3], 0 offen lds
	ds_read_b64_tr_b16 v[62:63], v41 offset:24576
	ds_read_b64_tr_b16 v[64:65], v41 offset:25088
	ds_read_b128 v[46:49], v42 offset:8192
	ds_read_b64_tr_b16 v[50:51], v40 offset:24576
	ds_read_b64_tr_b16 v[52:53], v40 offset:25088
	ds_read_b128 v[54:57], v42 offset:12288
	ds_read_b64_tr_b16 v[58:59], v40 offset:28672
	ds_read_b64_tr_b16 v[60:61], v40 offset:29184
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[50:53], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[46:49], v[62:65], v[10:13]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[54:57], v[50:53], v[14:17]
	ds_read_b128 v[46:49], v44 offset:8192
	ds_read_b128 v[50:53], v44 offset:12288
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[62:65], v[6:9]
	ds_read_b64_tr_b16 v[54:55], v43 offset:24576
	ds_read_b64_tr_b16 v[56:57], v43 offset:25088
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[58:61], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[46:49], v[54:57], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[50:53], v[58:61], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[50:53], v[54:57], v[6:9]
	s_cmp_lg_u32 s14, s17
	s_cbranch_scc1 .LBB0_6
	s_bitcmp1_b32 s8, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
	s_branch .LBB0_11
.LBB0_8:
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	s_branch .LBB0_11
.LBB0_9:
	v_mov_b32_e32 v9, 0
	s_mov_b32 s14, 0
	v_mov_b32_e32 v8, v9
	v_mov_b32_e32 v7, v9
	v_mov_b32_e32 v6, v9
	v_mov_b32_e32 v17, v9
	v_mov_b32_e32 v16, v9
	v_mov_b32_e32 v15, v9
	v_mov_b32_e32 v14, v9
	v_mov_b32_e32 v13, v9
	v_mov_b32_e32 v12, v9
	v_mov_b32_e32 v11, v9
	v_mov_b32_e32 v10, v9
	v_mov_b32_e32 v5, v9
	v_mov_b32_e32 v4, v9
	v_mov_b32_e32 v3, v9
	v_mov_b32_e32 v2, v9
	s_cbranch_execz .LBB0_11
.LBB0_10:
	s_lshl_b32 s2, s14, 12
	s_and_b32 s11, s2, 0x1000
	s_xor_b32 s2, s11, 0x1000
	s_lshl1_add_u32 s10, s2, s10
	s_lshl_b32 s2, s14, 6
	s_add_i32 s14, s2, 64
	v_add_u32_e32 v28, s14, v28
	s_waitcnt vmcnt(0)
	s_barrier
	s_add_i32 m0, s10, 0x4000
	s_add_i32 s2, s14, s9
	v_mul_lo_u32 v28, v28, s18
	v_add_lshl_u32 v28, v28, v29, 1
	buffer_load_dwordx4 v28, s[20:23], 0 offen lds
	v_add_u32_e32 v28, s2, v30
	s_add_i32 m0, s10, 0x5000
	v_mul_lo_u32 v28, v28, s18
	v_add_lshl_u32 v28, v28, v31, 1
	buffer_load_dwordx4 v28, s[20:23], 0 offen lds
	v_add_lshl_u32 v28, v32, s14, 1
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	s_mov_b32 m0, s10
	s_nop 0
	buffer_load_dwordx4 v28, s[0:3], 0 offen lds
	s_add_i32 m0, s10, 0x1000
	v_add_lshl_u32 v28, v33, s14, 1
	buffer_load_dwordx4 v28, s[0:3], 0 offen lds
	s_lshl_b32 s0, s11, 1
	v_lshl_or_b32 v28, v35, 1, s0
	v_lshl_add_u32 v28, v23, 1, v28
	ds_read_b128 v[36:39], v28
	v_lshl_or_b32 v29, v25, 1, s0
	v_lshl_or_b32 v30, v26, 1, s0
	ds_read_b64_tr_b16 v[40:41], v29 offset:16384
	ds_read_b64_tr_b16 v[42:43], v29 offset:16896
	ds_read_b64_tr_b16 v[44:45], v29 offset:20480
	ds_read_b64_tr_b16 v[46:47], v29 offset:20992
	ds_read_b128 v[48:51], v28 offset:4096
	ds_read_b64_tr_b16 v[28:29], v30 offset:16384
	ds_read_b64_tr_b16 v[30:31], v30 offset:16896
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[48:51], v[28:31], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[36:39], v[28:31], v[10:13]
	v_lshl_or_b32 v28, v34, 1, s0
	ds_read_b128 v[30:33], v28
	v_lshl_or_b32 v29, v24, 1, s0
	v_mfma_f32_16x16x32_bf16 v[2:5], v[36:39], v[40:43], v[2:5]
	ds_read_b128 v[34:37], v28 offset:4096
	v_mfma_f32_16x16x32_bf16 v[14:17], v[48:51], v[40:43], v[14:17]
	ds_read_b64_tr_b16 v[38:39], v29 offset:16384
	ds_read_b64_tr_b16 v[40:41], v29 offset:16896
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[44:47], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[38:41], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[34:37], v[44:47], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[34:37], v[38:41], v[6:9]
.LBB0_11:
	s_lshr_b32 s0, s8, 31
	v_and_b32_e32 v28, 15, v0
	s_add_i32 s0, s8, s0
	v_lshlrev_b32_e32 v29, 6, v28
	v_and_b32_e32 v27, 24, v27
	s_and_b32 s0, s0, 0x7fffe
	s_sub_i32 s0, s8, s0
	v_bitop3_b32 v30, v27, v22, v29 bitop3:0x36
	s_lshl_b32 s0, s0, 13
	v_lshlrev_b32_e32 v30, 1, v30
	v_lshlrev_b32_e32 v31, 1, v23
	v_add3_u32 v30, s0, v30, v31
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[32:35], v30
	v_lshl_add_u32 v25, v25, 1, s0
	v_lshl_add_u32 v26, v26, 1, s0
	ds_read_b64_tr_b16 v[36:37], v25 offset:16384
	ds_read_b64_tr_b16 v[38:39], v25 offset:16896
	ds_read_b64_tr_b16 v[48:49], v26 offset:16384
	ds_read_b64_tr_b16 v[50:51], v26 offset:16896
	ds_read_b128 v[40:43], v30 offset:4096
	ds_read_b64_tr_b16 v[44:45], v25 offset:20480
	ds_read_b64_tr_b16 v[46:47], v25 offset:20992
	v_or3_b32 v23, v27, v29, v23
	v_bitop3_b32 v22, v23, v22, 32 bitop3:0x36
	v_lshl_add_u32 v22, v22, 1, s0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[32:35], v[36:39], v[2:5]
	v_lshl_add_u32 v26, v24, 1, s0
	v_mfma_f32_16x16x32_bf16 v[10:13], v[32:35], v[48:51], v[10:13]
	ds_read_b128 v[30:33], v22
	v_mfma_f32_16x16x32_bf16 v[14:17], v[40:43], v[36:39], v[14:17]
	ds_read_b128 v[34:37], v22 offset:4096
	v_mfma_f32_16x16x32_bf16 v[6:9], v[40:43], v[48:51], v[6:9]
	ds_read_b64_tr_b16 v[38:39], v26 offset:16384
	ds_read_b64_tr_b16 v[40:41], v26 offset:16896
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_mfma_f32_16x16x32_bf16 v[22:25], v[30:33], v[44:47], v[2:5]
	s_nop 2
	v_and_b32_e32 v2, 16, v21
	v_mfma_f32_16x16x32_bf16 v[4:7], v[34:37], v[38:41], v[6:9]
	v_and_or_b32 v3, v20, 12, v2
	v_lshlrev_b32_e32 v2, 4, v19
	v_and_or_b32 v19, v2, 16, v28
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[38:41], v[10:13]
	v_lshlrev_b32_e32 v19, 1, v19
	s_nop 2
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v20, v22, s0
	v_mfma_f32_16x16x32_bf16 v[14:17], v[34:37], v[44:47], v[14:17]
	v_lshl_or_b32 v3, v3, 7, v19
	v_lshrrev_b32_e32 v2, 4, v0
	v_cvt_pk_bf16_f32 v0, v7, s0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v7, v13, s0
	v_cvt_pk_bf16_f32 v8, v12, s0
	v_cvt_pk_bf16_f32 v9, v11, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v11, v17, s0
	v_cvt_pk_bf16_f32 v12, v16, s0
	v_cvt_pk_bf16_f32 v13, v15, s0
	v_cvt_pk_bf16_f32 v14, v14, s0
	v_cvt_pk_bf16_f32 v15, v25, s0
	v_cvt_pk_bf16_f32 v16, v24, s0
	v_cvt_pk_bf16_f32 v17, v23, s0
	ds_write_b16 v3, v20
	ds_write_b16 v3, v17 offset:128
	ds_write_b16 v3, v16 offset:256
	ds_write_b16 v3, v15 offset:384
	ds_write_b16 v3, v14 offset:4096
	ds_write_b16 v3, v13 offset:4224
	ds_write_b16 v3, v12 offset:4352
	ds_write_b16 v3, v11 offset:4480
	ds_write_b16 v3, v10 offset:64
	ds_write_b16 v3, v9 offset:192
	ds_write_b16 v3, v8 offset:320
	ds_write_b16 v3, v7 offset:448
	ds_write_b16 v3, v4 offset:4160
	ds_write_b16 v3, v5 offset:4288
	ds_write_b16 v3, v6 offset:4416
	ds_write_b16 v3, v0 offset:4544
	v_lshlrev_b32_e32 v4, 2, v28
	v_or_b32_e32 v3, s6, v2
	v_or_b32_e32 v0, s7, v4
	v_cmp_gt_i32_e32 vcc, s12, v3
	v_cmp_gt_i32_e64 s[0:1], s13, v0
	s_and_b64 s[4:5], s[0:1], vcc
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_13
	v_lshlrev_b32_e32 v4, 1, v4
	v_lshl_or_b32 v4, v2, 7, v4
	ds_read_b64 v[4:5], v4
	v_mad_u64_u32 v[8:9], s[4:5], v3, s13, v[0:1]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[2:3]
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_13:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_lshrrev_b32_e32 v4, 4, v1
	v_and_b32_e32 v1, 60, v18
	v_or_b32_e32 v3, s6, v4
	v_or_b32_e32 v0, s7, v1
	v_cmp_gt_i32_e64 s[0:1], s12, v3
	v_cmp_gt_i32_e32 vcc, s13, v0
	s_and_b64 s[4:5], vcc, s[0:1]
	v_lshlrev_b32_e32 v1, 1, v1
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_15
	v_lshl_or_b32 v4, v4, 7, v1
	ds_read_b64 v[4:5], v4
	v_mad_u64_u32 v[8:9], s[4:5], v3, s13, v[0:1]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[2:3]
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_15:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v4, 32, v2
	v_or_b32_e32 v3, s6, v4
	v_cmp_gt_i32_e64 s[0:1], s12, v3
	s_and_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_17
	v_lshl_or_b32 v4, v4, 7, v1
	ds_read_b64 v[4:5], v4
	v_mad_u64_u32 v[8:9], s[4:5], v3, s13, v[0:1]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[2:3]
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_17:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, 48, v2
	v_or_b32_e32 v2, s6, v3
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_19
	v_lshl_or_b32 v1, v3, 7, v1
	ds_read_b64 v[4:5], v1
	v_mad_u64_u32 v[6:7], s[0:1], v2, s13, v[0:1]
	v_ashrrev_i32_e32 v7, 31, v6
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v3, 0xffff0000, v5
	v_lshlrev_b32_e32 v2, 16, v5
	v_and_b32_e32 v1, 0xffff0000, v4
	v_lshlrev_b32_e32 v0, 16, v4
	v_lshl_add_u64 v[4:5], v[6:7], 2, s[2:3]
	global_store_dwordx4 v[4:5], v[0:3], off
.LBB0_19:
	s_endpgm
.Lfunc_end0:
	.size	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0, .Lfunc_end0-hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0
		.amdhsa_group_segment_fixed_size 32768
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 408
		.amdhsa_user_sgpr_count 8
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 1
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 1
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
		.amdhsa_next_free_vgpr 97
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 68
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

	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.num_vgpr, 66
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.num_agpr, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.numbered_sgpr, 28
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.num_named_barrier, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.private_seg_size, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.uses_vcc, 1
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.has_recursion, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.has_indirect_call, 0
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
      - .offset:         152
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         156
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         160
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         164
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         166
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         168
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         170
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         172
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         174
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         192
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         200
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         208
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         216
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         232
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .offset:         240
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
      - .offset:         248
        .size:           8
        .value_kind:     hidden_heap_v1
      - .offset:         256
        .size:           8
        .value_kind:     hidden_default_queue
      - .offset:         264
        .size:           8
        .value_kind:     hidden_completion_action
      - .offset:         352
        .size:           8
        .value_kind:     hidden_queue_ptr
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 408
    .max_flat_workgroup_size: 256
    .name:           hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnn_pft_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     66
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
