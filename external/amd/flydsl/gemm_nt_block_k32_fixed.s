; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_nt_block_k32_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.p2align	8
	.type	hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0,@function
hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0:
	s_load_dwordx8 s[12:19], s[4:5], 0x7c
	v_lshrrev_b32_e32 v19, 2, v0
	v_lshrrev_b32_e32 v18, 6, v0
	v_lshlrev_b32_e32 v2, 3, v0
	v_bitop3_b32 v26, v2, 24, v0 bitop3:0x48
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
	s_mov_b32 s23, 0x27000
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mov_b32 s22, -1
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
	s_mul_i32 s11, s16, s9
	s_add_i32 s2, s11, s16
	s_min_i32 s2, s2, s14
	s_sub_i32 s6, s2, s11
	s_ashr_i32 s2, s6, 31
	s_lshr_b32 s2, s2, 27
	s_add_i32 s2, s6, s2
	s_sub_i32 s8, s8, s15
	s_ashr_i32 s14, s2, 5
	s_andn2_b32 s2, s2, 31
	s_cmp_lg_u32 s6, s2
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[24:25], s[6:7], s[2:3]
	s_lshl_b32 s7, s8, 6
	v_or_b32_e32 v1, s7, v19
	v_cmp_gt_i32_e32 vcc, s13, v1
	v_readfirstlane_b32 s8, v18
	s_lshl_b32 s9, s8, 10
	v_cndmask_b32_e32 v1, 0, v1, vcc
	v_add_u32_e32 v29, s11, v26
	v_mul_lo_u32 v27, v1, s18
	s_lshl_b32 s6, s10, 6
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s1, 0xffff
	s_and_b32 s21, s21, 0xffff
	s_add_i32 s15, s9, 0x2000
	v_add_u32_e32 v30, v27, v29
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_lshlrev_b32_e32 v1, 1, v30
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v1, s[20:23], 0 offen lds
	v_or_b32_e32 v1, s6, v19
	v_cmp_gt_i32_e32 vcc, s12, v1
	s_nop 1
	v_cndmask_b32_e32 v1, 0, v1, vcc
	v_mul_lo_u32 v28, v1, s17
	v_add_u32_e32 v31, v28, v29
	v_lshlrev_b32_e32 v1, 1, v31
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v1, s[0:3], 0 offen lds
	s_cmp_lg_u64 s[24:25], 0
	s_subb_u32 s8, s14, 0
	s_add_i32 s8, s8, -1
	v_lshlrev_b32_e32 v1, 2, v0
	s_cmp_gt_i32 s8, 0
	v_and_b32_e32 v20, 24, v1
	s_cbranch_scc1 .LBB0_2
	s_mov_b64 s[2:3], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[2:3], -1
.LBB0_3:
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, 1, 0
	v_and_b32_e32 v21, 0x200, v2
	v_and_b32_e32 v22, 0x200, v1
	s_cmp_lg_u32 s2, 1
	v_lshrrev_b32_e32 v23, 1, v0
	s_cbranch_scc1 .LBB0_8
	v_lshlrev_b32_e32 v2, 5, v0
	v_and_b32_e32 v2, 0x1e0, v2
	v_and_b32_e32 v3, 24, v23
	v_bitop3_b32 v2, v2, v20, v3 bitop3:0x36
	v_lshlrev_b32_e32 v2, 1, v2
	s_and_b32 s10, s8, 3
	v_lshl_add_u32 v24, v21, 1, v2
	s_cmp_lt_u32 s8, 4
	v_lshl_add_u32 v25, v22, 1, v2
	s_cbranch_scc1 .LBB0_9
	v_mov_b32_e32 v6, 0
	s_and_b32 s16, s8, 0x7ffffffc
	s_add_i32 s17, s9, 0x3000
	s_add_i32 s18, s9, 0x1000
	s_mov_b32 s14, 0
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	v_mov_b32_e32 v14, v6
	v_mov_b32_e32 v15, v6
	v_mov_b32_e32 v16, v6
	v_mov_b32_e32 v17, v6
	v_mov_b32_e32 v10, v6
	v_mov_b32_e32 v11, v6
	v_mov_b32_e32 v12, v6
	v_mov_b32_e32 v13, v6
	v_mov_b32_e32 v2, v6
	v_mov_b32_e32 v3, v6
	v_mov_b32_e32 v4, v6
	v_mov_b32_e32 v5, v6
.LBB0_6:
	s_lshl_b32 s19, s14, 5
	s_waitcnt vmcnt(0)
	s_barrier
	s_or_b32 s24, s19, 32
	v_add_lshl_u32 v32, v30, s24, 1
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v32, s[20:23], 0 offen lds
	v_add_lshl_u32 v32, v31, s24, 1
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v32, s[0:3], 0 offen lds
	ds_read_b128 v[32:35], v25
	ds_read_b128 v[36:39], v24 offset:8192
	ds_read_b128 v[40:43], v24 offset:10240
	ds_read_b128 v[44:47], v25 offset:2048
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[36:39], v[6:9]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[32:35], v[40:43], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[44:47], v[36:39], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[44:47], v[40:43], v[2:5]
	s_waitcnt vmcnt(0)
	s_barrier
	s_or_b32 s24, s19, 64
	v_add_lshl_u32 v32, v30, s24, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v32, s[20:23], 0 offen lds
	v_add_lshl_u32 v32, v31, s24, 1
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v32, s[0:3], 0 offen lds
	ds_read_b128 v[32:35], v25 offset:4096
	ds_read_b128 v[36:39], v24 offset:12288
	ds_read_b128 v[40:43], v24 offset:14336
	ds_read_b128 v[44:47], v25 offset:6144
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[36:39], v[6:9]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[32:35], v[40:43], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[44:47], v[36:39], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[44:47], v[40:43], v[2:5]
	s_waitcnt vmcnt(0)
	s_barrier
	s_addk_i32 s19, 0x60
	v_add_lshl_u32 v32, v30, s19, 1
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v32, s[20:23], 0 offen lds
	v_add_lshl_u32 v32, v31, s19, 1
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v32, s[0:3], 0 offen lds
	ds_read_b128 v[32:35], v25
	ds_read_b128 v[36:39], v24 offset:8192
	ds_read_b128 v[40:43], v24 offset:10240
	ds_read_b128 v[44:47], v25 offset:2048
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[36:39], v[6:9]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[32:35], v[40:43], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[44:47], v[36:39], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[44:47], v[40:43], v[2:5]
	s_add_i32 s14, s14, 4
	s_waitcnt vmcnt(0)
	s_barrier
	v_lshl_add_u32 v32, s14, 5, v29
	v_add_lshl_u32 v33, v32, v27, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v33, s[20:23], 0 offen lds
	v_add_lshl_u32 v32, v32, v28, 1
	s_mov_b32 m0, s9
	s_nop 0
	buffer_load_dwordx4 v32, s[0:3], 0 offen lds
	ds_read_b128 v[32:35], v25 offset:4096
	ds_read_b128 v[36:39], v24 offset:12288
	ds_read_b128 v[40:43], v24 offset:14336
	ds_read_b128 v[44:47], v25 offset:6144
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[36:39], v[6:9]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[32:35], v[40:43], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[44:47], v[36:39], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[44:47], v[40:43], v[2:5]
	s_cmp_lg_u32 s14, s16
	s_cbranch_scc1 .LBB0_6
	s_cmp_lg_u32 s10, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
	s_branch .LBB0_12
.LBB0_8:
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	v_mov_b32_e32 v14, v6
	v_mov_b32_e32 v15, v6
	v_mov_b32_e32 v16, v6
	v_mov_b32_e32 v17, v6
	v_mov_b32_e32 v10, v6
	v_mov_b32_e32 v11, v6
	v_mov_b32_e32 v12, v6
	v_mov_b32_e32 v13, v6
	v_mov_b32_e32 v2, v6
	v_mov_b32_e32 v3, v6
	v_mov_b32_e32 v4, v6
	v_mov_b32_e32 v5, v6
	s_branch .LBB0_12
.LBB0_9:
	v_mov_b32_e32 v2, 0
	s_mov_b32 s14, 0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v6, v2
	s_cbranch_execz .LBB0_12
.LBB0_10:
	s_lshl_b32 s2, s14, 5
	s_add_i32 s2, s2, s11
	v_add3_u32 v28, s2, v28, v26
	v_add3_u32 v26, s2, v27, v26
	s_lshl_b32 s15, s14, 11
	v_lshl_add_u32 v28, v28, 1, 64
	v_lshl_add_u32 v26, v26, 1, 64
	s_mov_b32 s2, s22
	s_mov_b32 s3, s23
	.p2align	5, , 4
.LBB0_11:
	s_and_b32 s11, s15, 0x800
	s_xor_b32 s14, s11, 0x800
	s_lshl1_add_u32 s14, s14, s9
	s_waitcnt vmcnt(0)
	s_barrier
	s_add_i32 m0, s14, 0x2000
	s_nop 0
	buffer_load_dwordx4 v26, s[20:23], 0 offen lds
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v28, s[0:3], 0 offen lds
	s_lshl_b32 s11, s11, 1
	v_or_b32_e32 v27, s11, v25
	ds_read_b128 v[30:33], v27
	v_or_b32_e32 v29, s11, v24
	ds_read_b128 v[34:37], v29 offset:8192
	ds_read_b128 v[38:41], v29 offset:10240
	ds_read_b128 v[42:45], v27 offset:2048
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[34:37], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[30:33], v[34:37], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[38:41], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_addk_i32 s15, 0x800
	s_add_i32 s10, s10, -1
	v_add_u32_e32 v28, 64, v28
	s_cmp_lg_u32 s10, 0
	v_add_u32_e32 v26, 64, v26
	s_cbranch_scc1 .LBB0_11
.LBB0_12:
	v_and_b32_e32 v24, 15, v0
	s_lshr_b32 s0, s8, 31
	v_lshlrev_b32_e32 v25, 5, v24
	v_and_b32_e32 v23, 24, v23
	s_add_i32 s0, s8, s0
	s_and_b32 s0, s0, 0xffffe
	v_bitop3_b32 v20, v23, v20, v25 bitop3:0x36
	s_sub_i32 s0, s8, s0
	v_lshlrev_b32_e32 v20, 1, v20
	v_lshl_add_u32 v20, s0, 12, v20
	v_lshl_add_u32 v22, v22, 1, v20
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[26:29], v22
	v_lshl_add_u32 v20, v21, 1, v20
	ds_read_b128 v[30:33], v20 offset:8192
	ds_read_b128 v[34:37], v20 offset:10240
	ds_read_b128 v[38:41], v22 offset:2048
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[20:23], v[26:29], v[30:33], v[6:9]
	s_barrier
	s_nop 1
	v_lshrrev_b32_e32 v6, 3, v0
	v_and_b32_e32 v6, 16, v6
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[34:37], v[2:5]
	v_and_or_b32 v7, v19, 12, v6
	v_lshlrev_b32_e32 v6, 4, v18
	v_cvt_pk_bf16_f32 v19, v20, s0
	v_mfma_f32_16x16x32_bf16 v[14:17], v[26:29], v[34:37], v[14:17]
	v_cvt_pk_bf16_f32 v18, v21, s0
	s_nop 2
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_mfma_f32_16x16x32_bf16 v[8:11], v[38:41], v[30:33], v[10:13]
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v15, v15, s0
	v_cvt_pk_bf16_f32 v14, v14, s0
	v_and_or_b32 v12, v6, 16, v24
	v_lshlrev_b32_e32 v12, 1, v12
	v_lshl_or_b32 v7, v7, 7, v12
	v_lshrrev_b32_e32 v6, 4, v0
	v_cvt_pk_bf16_f32 v0, v5, s0
	v_cvt_pk_bf16_f32 v5, v17, s0
	v_cvt_pk_bf16_f32 v13, v16, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v16, v23, s0
	v_cvt_pk_bf16_f32 v17, v22, s0
	ds_write_b16 v7, v19
	ds_write_b16 v7, v18 offset:128
	ds_write_b16 v7, v17 offset:256
	ds_write_b16 v7, v16 offset:384
	ds_write_b16 v7, v8 offset:4096
	ds_write_b16 v7, v9 offset:4224
	ds_write_b16 v7, v10 offset:4352
	ds_write_b16 v7, v11 offset:4480
	ds_write_b16 v7, v14 offset:64
	ds_write_b16 v7, v15 offset:192
	ds_write_b16 v7, v13 offset:320
	ds_write_b16 v7, v5 offset:448
	ds_write_b16 v7, v2 offset:4160
	ds_write_b16 v7, v3 offset:4288
	ds_write_b16 v7, v4 offset:4416
	ds_write_b16 v7, v0 offset:4544
	v_lshlrev_b32_e32 v3, 2, v24
	v_or_b32_e32 v2, s6, v6
	v_or_b32_e32 v0, s7, v3
	v_cmp_gt_i32_e32 vcc, s12, v2
	v_cmp_gt_i32_e64 s[0:1], s13, v0
	s_and_b64 s[4:5], s[0:1], vcc
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_14
	v_lshlrev_b32_e32 v3, 1, v3
	v_lshl_or_b32 v3, v6, 7, v3
	ds_read_b64 v[8:9], v3
	v_mad_u64_u32 v[10:11], s[4:5], v2, s13, v[0:1]
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v5, 0xffff0000, v9
	v_lshlrev_b32_e32 v4, 16, v9
	v_and_b32_e32 v3, 0xffff0000, v8
	v_lshlrev_b32_e32 v2, 16, v8
	v_lshl_add_u64 v[8:9], v[10:11], 2, s[2:3]
	global_store_dwordx4 v[8:9], v[2:5], off
.LBB0_14:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v3, 16, v6
	v_and_b32_e32 v1, 60, v1
	v_or_b32_e32 v2, s6, v3
	v_or_b32_e32 v0, s7, v1
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	v_cmp_gt_i32_e32 vcc, s13, v0
	s_and_b64 s[4:5], vcc, s[0:1]
	v_lshlrev_b32_e32 v1, 1, v1
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_16
	v_lshl_or_b32 v3, v3, 7, v1
	ds_read_b64 v[8:9], v3
	v_mad_u64_u32 v[10:11], s[4:5], v2, s13, v[0:1]
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v5, 0xffff0000, v9
	v_lshlrev_b32_e32 v4, 16, v9
	v_and_b32_e32 v3, 0xffff0000, v8
	v_lshlrev_b32_e32 v2, 16, v8
	v_lshl_add_u64 v[8:9], v[10:11], 2, s[2:3]
	global_store_dwordx4 v[8:9], v[2:5], off
.LBB0_16:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v3, 32, v6
	v_or_b32_e32 v2, s6, v3
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	s_and_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_18
	v_lshl_or_b32 v3, v3, 7, v1
	ds_read_b64 v[8:9], v3
	v_mad_u64_u32 v[10:11], s[4:5], v2, s13, v[0:1]
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v5, 0xffff0000, v9
	v_lshlrev_b32_e32 v4, 16, v9
	v_and_b32_e32 v3, 0xffff0000, v8
	v_lshlrev_b32_e32 v2, 16, v8
	v_lshl_add_u64 v[8:9], v[10:11], 2, s[2:3]
	global_store_dwordx4 v[8:9], v[2:5], off
.LBB0_18:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v3, 48, v6
	v_or_b32_e32 v2, s6, v3
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_20
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
.LBB0_20:
	s_endpgm
.Lfunc_end0:
	.size	hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0, .Lfunc_end0-hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
		.amdhsa_group_segment_fixed_size 16384
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
		.amdhsa_next_free_vgpr 48
		.amdhsa_next_free_sgpr 26
		.amdhsa_accum_offset 48
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

	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_vgpr, 48
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_agpr, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.numbered_sgpr, 26
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_named_barrier, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.private_seg_size, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_vcc, 1
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_recursion, 0
	.set .Lhgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_indirect_call, 0
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
    .group_segment_fixed_size: 16384
    .kernarg_segment_align: 8
    .kernarg_segment_size: 408
    .max_flat_workgroup_size: 256
    .name:           hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     32
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_fp32_t64x64x32x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     48
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
