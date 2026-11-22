; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_nt).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.p2align	8
	.type	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0,@function
hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0:
	s_load_dwordx8 s[12:19], s[4:5], 0x7c
	v_lshlrev_b32_e32 v2, 3, v0
	v_lshrrev_b32_e32 v19, 3, v0
	v_lshrrev_b32_e32 v18, 6, v0
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
	s_load_dwordx2 s[0:1], s[4:5], 0x18
	s_load_dwordx2 s[20:21], s[4:5], 0x30
	s_mov_b32 s22, -1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
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
	s_sub_i32 s8, s8, s15
	s_mul_i32 s15, s16, s9
	s_add_i32 s2, s15, s16
	s_min_i32 s2, s2, s14
	s_sub_i32 s6, s2, s15
	s_ashr_i32 s2, s6, 31
	s_lshr_b32 s2, s2, 26
	s_add_i32 s2, s6, s2
	s_ashr_i32 s16, s2, 6
	s_andn2_b32 s2, s2, 63
	s_cmp_lg_u32 s6, s2
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[24:25], s[6:7], s[2:3]
	s_lshl_b32 s7, s8, 6
	v_bitop3_b32 v1, v2, 56, v0 bitop3:0x48
	v_add_u32_e32 v31, s15, v1
	v_or_b32_e32 v1, s7, v19
	v_cmp_gt_i32_e32 vcc, s13, v1
	v_readfirstlane_b32 s8, v18
	s_lshl_b32 s9, s8, 10
	v_cndmask_b32_e32 v1, 0, v1, vcc
	v_mul_lo_u32 v32, v1, s18
	s_lshl_b32 s6, s10, 6
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s1, 0xffff
	s_and_b32 s21, s21, 0xffff
	s_add_i32 s11, s9, 0x4000
	v_add_u32_e32 v24, v32, v31
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_lshlrev_b32_e32 v1, 1, v24
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v1, s[20:23], 0 offen lds
	v_or_b32_e32 v1, 0x100, v0
	v_lshrrev_b32_e32 v3, 3, v1
	v_or_b32_e32 v4, s7, v3
	v_cmp_gt_i32_e32 vcc, s13, v4
	s_add_i32 s14, s9, 0x5000
	s_nop 0
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v33, v4, s18
	v_add_u32_e32 v25, v33, v31
	v_lshlrev_b32_e32 v4, 1, v25
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v4, s[20:23], 0 offen lds
	v_or_b32_e32 v4, s6, v19
	v_cmp_gt_i32_e32 vcc, s12, v4
	s_nop 1
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v34, v4, s17
	v_add_u32_e32 v26, v34, v31
	v_lshlrev_b32_e32 v4, 1, v26
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v4, s[0:3], 0 offen lds
	v_or_b32_e32 v3, s6, v3
	v_cmp_gt_i32_e32 vcc, s12, v3
	s_add_i32 s15, s9, 0x1000
	s_nop 0
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_mul_lo_u32 v35, v3, s17
	v_add_u32_e32 v27, v35, v31
	v_lshlrev_b32_e32 v3, 1, v27
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v3, s[0:3], 0 offen lds
	s_cmp_lg_u64 s[24:25], 0
	s_subb_u32 s8, s16, 0
	s_add_i32 s8, s8, -1
	s_cmp_gt_i32 s8, 0
	v_lshlrev_b32_e32 v3, 4, v0
	v_and_b32_e32 v20, 56, v2
	s_cbranch_scc1 .LBB0_2
	v_and_b32_e32 v21, 0x400, v3
	v_and_b32_e32 v22, 0x400, v2
	s_mov_b64 s[2:3], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[2:3], -1
.LBB0_3:
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	s_cmp_lg_u32 s2, 1
	v_lshrrev_b32_e32 v23, 1, v0
	s_cbranch_scc1 .LBB0_8
	v_lshlrev_b32_e32 v4, 6, v0
	v_and_b32_e32 v4, 0x3c0, v4
	v_and_b32_e32 v5, 24, v23
	v_or_b32_e32 v6, v4, v5
	v_and_b32_e32 v21, 0x400, v3
	v_and_b32_e32 v22, 0x400, v2
	v_or_b32_e32 v2, v6, v21
	v_bitop3_b32 v28, v2, v20, 32 bitop3:0x36
	v_or_b32_e32 v2, v6, v22
	v_bitop3_b32 v30, v4, v20, v5 bitop3:0x36
	s_cmp_eq_u32 s8, 1
	v_bitop3_b32 v29, v2, v20, 32 bitop3:0x36
	s_cbranch_scc1 .LBB0_9
	v_lshlrev_b32_e32 v2, 1, v30
	v_mov_b32_e32 v10, 0
	s_and_b32 s16, s8, 0x7ffffffe
	s_add_i32 s17, s9, 0x6000
	s_add_i32 s18, s9, 0x7000
	s_add_i32 s19, s9, 0x2000
	s_add_i32 s24, s9, 0x3000
	v_lshl_add_u32 v36, v21, 1, v2
	v_lshl_add_u32 v37, v22, 1, v2
	v_lshlrev_b32_e32 v38, 1, v28
	v_lshlrev_b32_e32 v39, 1, v29
	s_mov_b32 s10, 0
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_mov_b32_e32 v11, v10
	v_mov_b32_e32 v12, v10
	v_mov_b32_e32 v13, v10
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v10
	v_mov_b32_e32 v16, v10
	v_mov_b32_e32 v17, v10
	v_mov_b32_e32 v6, v10
	v_mov_b32_e32 v7, v10
	v_mov_b32_e32 v8, v10
	v_mov_b32_e32 v9, v10
	v_mov_b32_e32 v2, v10
	v_mov_b32_e32 v3, v10
	v_mov_b32_e32 v4, v10
	v_mov_b32_e32 v5, v10
.LBB0_6:
	s_lshl_b32 s25, s10, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_or_b32 s25, s25, 64
	v_add_lshl_u32 v40, v24, s25, 1
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v40, s[20:23], 0 offen lds
	v_add_lshl_u32 v40, v25, s25, 1
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v40, s[20:23], 0 offen lds
	v_add_lshl_u32 v40, v26, s25, 1
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v40, s[0:3], 0 offen lds
	v_add_lshl_u32 v40, v27, s25, 1
	s_mov_b32 m0, s24
	s_nop 0
	buffer_load_dwordx4 v40, s[0:3], 0 offen lds
	ds_read_b128 v[40:43], v37
	ds_read_b128 v[44:47], v36 offset:16384
	ds_read_b128 v[48:51], v36 offset:20480
	ds_read_b128 v[52:55], v37 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[40:43], v[44:47], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[40:43], v[48:51], v[14:17]
	ds_read_b128 v[40:43], v39
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[52:55], v[44:47], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[52:55], v[48:51], v[2:5]
	ds_read_b128 v[44:47], v38 offset:16384
	ds_read_b128 v[48:51], v38 offset:20480
	ds_read_b128 v[52:55], v39 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[40:43], v[44:47], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[40:43], v[48:51], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[52:55], v[44:47], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[52:55], v[48:51], v[2:5]
	s_add_i32 s10, s10, 2
	s_waitcnt vmcnt(0)
	s_barrier
	v_lshl_add_u32 v40, s10, 6, v31
	v_add_lshl_u32 v41, v40, v32, 1
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v41, s[20:23], 0 offen lds
	v_add_lshl_u32 v41, v40, v33, 1
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v41, s[20:23], 0 offen lds
	v_add_lshl_u32 v41, v40, v34, 1
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v41, s[0:3], 0 offen lds
	v_add_lshl_u32 v40, v40, v35, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v40, s[0:3], 0 offen lds
	ds_read_b128 v[40:43], v37 offset:8192
	ds_read_b128 v[44:47], v36 offset:24576
	ds_read_b128 v[48:51], v36 offset:28672
	ds_read_b128 v[52:55], v37 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[40:43], v[44:47], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[40:43], v[48:51], v[14:17]
	ds_read_b128 v[40:43], v39 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[52:55], v[44:47], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[52:55], v[48:51], v[2:5]
	ds_read_b128 v[44:47], v38 offset:24576
	ds_read_b128 v[48:51], v38 offset:28672
	ds_read_b128 v[52:55], v39 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[40:43], v[44:47], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[40:43], v[48:51], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[52:55], v[44:47], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[52:55], v[48:51], v[2:5]
	s_cmp_lg_u32 s10, s16
	s_cbranch_scc1 .LBB0_6
	s_bitcmp1_b32 s8, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
	s_branch .LBB0_11
.LBB0_8:
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, v10
	v_mov_b32_e32 v12, v10
	v_mov_b32_e32 v13, v10
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v10
	v_mov_b32_e32 v16, v10
	v_mov_b32_e32 v17, v10
	v_mov_b32_e32 v6, v10
	v_mov_b32_e32 v7, v10
	v_mov_b32_e32 v8, v10
	v_mov_b32_e32 v9, v10
	v_mov_b32_e32 v2, v10
	v_mov_b32_e32 v3, v10
	v_mov_b32_e32 v4, v10
	v_mov_b32_e32 v5, v10
	s_branch .LBB0_11
.LBB0_9:
	v_mov_b32_e32 v5, 0
	s_mov_b32 s10, 0
	v_mov_b32_e32 v4, v5
	v_mov_b32_e32 v3, v5
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v9, v5
	v_mov_b32_e32 v8, v5
	v_mov_b32_e32 v7, v5
	v_mov_b32_e32 v6, v5
	v_mov_b32_e32 v17, v5
	v_mov_b32_e32 v16, v5
	v_mov_b32_e32 v15, v5
	v_mov_b32_e32 v14, v5
	v_mov_b32_e32 v13, v5
	v_mov_b32_e32 v12, v5
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v10, v5
	s_cbranch_execz .LBB0_11
.LBB0_10:
	s_lshl_b32 s2, s10, 12
	s_and_b32 s11, s2, 0x1000
	s_xor_b32 s2, s11, 0x1000
	s_lshl1_add_u32 s9, s2, s9
	s_lshl_b32 s2, s10, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_add_i32 m0, s9, 0x4000
	s_add_i32 s10, s2, 64
	v_add_lshl_u32 v24, v24, s10, 1
	buffer_load_dwordx4 v24, s[20:23], 0 offen lds
	s_add_i32 m0, s9, 0x5000
	v_add_lshl_u32 v24, v25, s10, 1
	buffer_load_dwordx4 v24, s[20:23], 0 offen lds
	v_add_lshl_u32 v24, v26, s10, 1
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v24, s[0:3], 0 offen lds
	s_add_i32 m0, s9, 0x1000
	v_add_lshl_u32 v24, v27, s10, 1
	buffer_load_dwordx4 v24, s[0:3], 0 offen lds
	s_lshl_b32 s0, s11, 1
	v_lshl_or_b32 v24, v30, 1, s0
	v_lshl_add_u32 v25, v22, 1, v24
	ds_read_b128 v[30:33], v25
	v_lshl_add_u32 v24, v21, 1, v24
	ds_read_b128 v[34:37], v24 offset:16384
	ds_read_b128 v[38:41], v24 offset:20480
	ds_read_b128 v[42:45], v25 offset:4096
	v_lshl_or_b32 v24, v29, 1, s0
	v_lshl_or_b32 v25, v28, 1, s0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[42:45], v[34:37], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[34:37], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[38:41], v[14:17]
	ds_read_b128 v[30:33], v24
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	ds_read_b128 v[26:29], v25 offset:16384
	ds_read_b128 v[34:37], v25 offset:20480
	ds_read_b128 v[38:41], v24 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[26:29], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[34:37], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[38:41], v[26:29], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[34:37], v[2:5]
.LBB0_11:
	s_lshr_b32 s0, s8, 31
	s_add_i32 s0, s8, s0
	v_and_b32_e32 v28, 15, v0
	s_and_b32 s0, s0, 0x7fffe
	v_lshlrev_b32_e32 v24, 6, v28
	v_and_b32_e32 v23, 24, v23
	s_sub_i32 s0, s8, s0
	v_bitop3_b32 v25, v23, v20, v24 bitop3:0x36
	s_lshl_b32 s0, s0, 13
	v_lshl_add_u32 v25, v25, 1, s0
	v_lshl_add_u32 v26, v22, 1, v25
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[30:33], v26
	v_lshl_add_u32 v25, v21, 1, v25
	ds_read_b128 v[34:37], v25 offset:16384
	ds_read_b128 v[38:41], v25 offset:20480
	ds_read_b128 v[42:45], v26 offset:4096
	v_or_b32_e32 v23, v23, v24
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[24:27], v[42:45], v[38:41], v[2:5]
	s_nop 2
	v_or_b32_e32 v2, v22, v23
	v_bitop3_b32 v2, v2, v20, 32 bitop3:0x36
	v_lshl_add_u32 v2, v2, 1, s0
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[34:37], v[10:13]
	v_or_b32_e32 v3, v21, v23
	v_bitop3_b32 v3, v3, v20, 32 bitop3:0x36
	v_lshl_add_u32 v3, v3, 1, s0
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[38:41], v[14:17]
	ds_read_b128 v[30:33], v2
	v_mfma_f32_16x16x32_bf16 v[6:9], v[42:45], v[34:37], v[6:9]
	ds_read_b128 v[20:23], v3 offset:16384
	ds_read_b128 v[34:37], v3 offset:20480
	ds_read_b128 v[38:41], v2 offset:4096
	v_lshrrev_b32_e32 v2, 2, v0
	v_and_b32_e32 v3, 16, v19
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[20:23], v[10:13]
	v_and_or_b32 v2, v2, 12, v3
	v_lshlrev_b32_e32 v3, 4, v18
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[38:41], v[20:23], v[6:9]
	s_barrier
	s_nop 2
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[34:37], v[14:17]
	v_and_or_b32 v8, v3, 16, v28
	v_lshlrev_b32_e32 v8, 1, v8
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_mfma_f32_16x16x32_bf16 v[18:21], v[38:41], v[34:37], v[24:27]
	v_lshl_or_b32 v2, v2, 7, v8
	v_lshrrev_b32_e32 v3, 4, v0
	s_nop 1
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_cvt_pk_bf16_f32 v15, v15, s0
	s_nop 0
	v_cvt_pk_bf16_f32 v9, v21, s0
	v_cvt_pk_bf16_f32 v20, v20, s0
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v14, v14, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	ds_write_b16 v2, v10
	ds_write_b16 v2, v11 offset:128
	ds_write_b16 v2, v12 offset:256
	ds_write_b16 v2, v13 offset:384
	ds_write_b16 v2, v4 offset:4096
	ds_write_b16 v2, v5 offset:4224
	ds_write_b16 v2, v6 offset:4352
	ds_write_b16 v2, v7 offset:4480
	ds_write_b16 v2, v14 offset:64
	ds_write_b16 v2, v15 offset:192
	ds_write_b16 v2, v16 offset:320
	ds_write_b16 v2, v17 offset:448
	ds_write_b16 v2, v18 offset:4160
	ds_write_b16 v2, v19 offset:4288
	ds_write_b16 v2, v20 offset:4416
	ds_write_b16 v2, v9 offset:4544
	v_lshlrev_b32_e32 v5, 2, v28
	v_or_b32_e32 v4, s6, v3
	v_or_b32_e32 v2, s7, v5
	v_cmp_gt_i32_e32 vcc, s12, v4
	v_cmp_gt_i32_e64 s[0:1], s13, v2
	s_and_b64 s[4:5], s[0:1], vcc
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_13
	v_lshlrev_b32_e32 v5, 1, v5
	v_lshl_or_b32 v5, v3, 7, v5
	ds_read_b64 v[8:9], v5
	v_mad_u64_u32 v[10:11], s[4:5], v4, s13, v[2:3]
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v9
	v_lshlrev_b32_e32 v6, 16, v9
	v_and_b32_e32 v5, 0xffff0000, v8
	v_lshlrev_b32_e32 v4, 16, v8
	v_lshl_add_u64 v[8:9], v[10:11], 2, s[2:3]
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_13:
	s_or_b64 exec, exec, s[0:1]
	v_lshlrev_b32_e32 v0, 2, v0
	v_lshrrev_b32_e32 v2, 4, v1
	v_and_b32_e32 v1, 60, v0
	v_or_b32_e32 v4, s6, v2
	v_or_b32_e32 v0, s7, v1
	v_cmp_gt_i32_e64 s[0:1], s12, v4
	v_cmp_gt_i32_e32 vcc, s13, v0
	s_and_b64 s[4:5], vcc, s[0:1]
	v_lshlrev_b32_e32 v1, 1, v1
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_15
	v_lshl_or_b32 v2, v2, 7, v1
	ds_read_b64 v[8:9], v2
	v_mad_u64_u32 v[10:11], s[4:5], v4, s13, v[0:1]
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v9
	v_lshlrev_b32_e32 v6, 16, v9
	v_and_b32_e32 v5, 0xffff0000, v8
	v_lshlrev_b32_e32 v4, 16, v8
	v_lshl_add_u64 v[8:9], v[10:11], 2, s[2:3]
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_15:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v4, 32, v3
	v_or_b32_e32 v2, s6, v4
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	s_and_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_17
	v_lshl_or_b32 v4, v4, 7, v1
	ds_read_b64 v[4:5], v4
	v_mad_u64_u32 v[8:9], s[4:5], v2, s13, v[0:1]
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
	v_or_b32_e32 v3, 48, v3
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
	.size	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0, .Lfunc_end0-hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
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
		.amdhsa_accum_offset 56
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

	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_vgpr, 56
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_agpr, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.numbered_sgpr, 26
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_named_barrier, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.private_seg_size, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_vcc, 1
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_recursion, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_indirect_call, 0
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
    .name:           hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     32
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     56
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
