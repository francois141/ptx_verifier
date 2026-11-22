; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_nt_bf16).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.p2align	8
	.type	hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0,@function
hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0:
	s_load_dwordx8 s[12:19], s[4:5], 0x7c
	v_lshlrev_b32_e32 v2, 3, v0
	s_load_dwordx2 s[20:21], s[4:5], 0x18
	s_load_dwordx2 s[24:25], s[4:5], 0x30
	v_bitop3_b32 v3, v2, 56, v0 bitop3:0x48
	v_lshrrev_b32_e32 v22, 6, v0
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
	s_subb_u32 s0, s6, 0
	s_abs_i32 s1, s0
	v_cvt_f32_u32_e32 v1, s1
	s_sub_i32 s7, 0, s1
	s_abs_i32 s2, s8
	s_xor_b32 s3, s0, s8
	v_rcp_f32_e32 v1, v1
	s_ashr_i32 s6, s3, 31
	s_mul_i32 s9, s16, s9
	v_add_u32_e32 v32, s9, v3
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_mov_b32 s10, 0
	s_mov_b32 s27, 0x27000
	s_mov_b32 s26, -1
	v_readfirstlane_b32 s11, v1
	s_mul_i32 s7, s7, s11
	s_mul_hi_u32 s7, s11, s7
	s_add_i32 s11, s11, s7
	s_mul_hi_u32 s7, s2, s11
	s_mul_i32 s11, s7, s1
	s_sub_i32 s2, s2, s11
	s_add_i32 s15, s7, 1
	s_sub_i32 s11, s2, s1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s7, s15, s7
	s_cselect_b32 s2, s11, s2
	s_add_i32 s11, s7, 1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s1, s11, s7
	s_xor_b32 s7, s1, s6
	s_sub_i32 s1, s7, s6
	s_mul_i32 s11, s1, s0
	s_cmp_lg_u32 s8, s11
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 s[0:1], s[2:3], s[0:1]
	s_subb_u32 s6, s7, s6
	s_add_i32 s0, s9, s16
	s_min_i32 s0, s0, s14
	s_sub_i32 s2, s0, s9
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 26
	s_add_i32 s0, s2, s0
	s_sub_i32 s7, s8, s11
	s_ashr_i32 s15, s0, 6
	s_andn2_b32 s0, s0, 63
	s_cmp_lg_u32 s2, s0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lt_i32 s2, 0
	s_cselect_b64 s[2:3], -1, 0
	s_lshl_b32 s8, s7, 6
	v_lshrrev_b32_e32 v1, 3, v0
	v_or_b32_e32 v3, s8, v1
	v_cmp_gt_i32_e32 vcc, s13, v3
	s_and_b64 s[28:29], s[2:3], s[0:1]
	v_readfirstlane_b32 s1, v22
	v_cndmask_b32_e32 v3, 0, v3, vcc
	s_lshl_b32 s11, s1, 10
	v_mul_lo_u32 v33, v3, s18
	s_lshl_b32 s0, s6, 6
	s_and_b32 s21, s21, 0xffff
	s_and_b32 s25, s25, 0xffff
	s_add_i32 s6, s11, 0x4000
	v_and_b32_e32 v19, 56, v2
	v_add_u32_e32 v28, v33, v32
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
	v_lshlrev_b32_e32 v3, 1, v28
	s_mov_b32 m0, s6
	s_nop 0
	buffer_load_dwordx4 v3, s[24:27], 0 offen lds
	v_or_b32_e32 v18, 32, v1
	v_or_b32_e32 v3, s8, v18
	v_cmp_gt_i32_e32 vcc, s13, v3
	s_add_i32 s7, s11, 0x5000
	s_nop 0
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_mul_lo_u32 v34, v3, s18
	v_add_u32_e32 v29, v34, v32
	v_lshlrev_b32_e32 v3, 1, v29
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v3, s[24:27], 0 offen lds
	v_or_b32_e32 v21, s0, v1
	v_cmp_gt_i32_e64 s[2:3], s12, v21
	s_nop 1
	v_cndmask_b32_e64 v3, 0, v21, s[2:3]
	v_mul_lo_u32 v35, v3, s17
	v_add_u32_e32 v30, v35, v32
	v_lshlrev_b32_e32 v3, 1, v30
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v3, s[20:23], 0 offen lds
	v_or_b32_e32 v20, s0, v18
	v_cmp_gt_i32_e64 s[0:1], s12, v20
	s_add_i32 s14, s11, 0x1000
	s_nop 0
	v_cndmask_b32_e64 v3, 0, v20, s[0:1]
	v_mul_lo_u32 v36, v3, s17
	v_add_u32_e32 v31, v36, v32
	v_lshlrev_b32_e32 v3, 1, v31
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v3, s[20:23], 0 offen lds
	v_lshlrev_b32_e32 v3, 6, v0
	v_lshrrev_b32_e32 v4, 1, v0
	v_and_b32_e32 v3, 0x3c0, v3
	v_and_b32_e32 v4, 24, v4
	v_lshlrev_b32_e32 v6, 4, v0
	s_cmp_lg_u64 s[28:29], 0
	v_or_b32_e32 v5, v3, v4
	v_and_b32_e32 v25, 0x400, v6
	s_subb_u32 s9, s15, 0
	v_and_b32_e32 v26, 0x400, v2
	v_or_b32_e32 v2, v5, v25
	s_add_i32 s9, s9, -1
	v_bitop3_b32 v23, v2, v19, 32 bitop3:0x36
	v_or_b32_e32 v2, v5, v26
	s_cmp_lt_i32 s9, 1
	v_bitop3_b32 v27, v3, v19, v4 bitop3:0x36
	v_bitop3_b32 v24, v2, v19, 32 bitop3:0x36
	s_cbranch_scc1 .LBB0_5
	s_cmp_eq_u32 s9, 1
	s_cbranch_scc1 .LBB0_6
	v_lshlrev_b32_e32 v2, 1, v27
	v_mov_b32_e32 v10, 0
	s_and_b32 s12, s9, 0x7ffffffe
	s_add_i32 s15, s11, 0x6000
	s_add_i32 s16, s11, 0x7000
	s_add_i32 s17, s11, 0x2000
	s_add_i32 s18, s11, 0x3000
	v_lshl_add_u32 v37, v25, 1, v2
	v_lshl_add_u32 v38, v26, 1, v2
	v_lshlrev_b32_e32 v39, 1, v23
	v_lshlrev_b32_e32 v40, 1, v24
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
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
.LBB0_3:
	s_lshl_b32 s19, s10, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_or_b32 s19, s19, 64
	v_add_lshl_u32 v41, v28, s19, 1
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v41, s[24:27], 0 offen lds
	v_add_lshl_u32 v41, v29, s19, 1
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v41, s[24:27], 0 offen lds
	v_add_lshl_u32 v41, v30, s19, 1
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v41, s[20:23], 0 offen lds
	v_add_lshl_u32 v41, v31, s19, 1
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v41, s[20:23], 0 offen lds
	ds_read_b128 v[42:45], v38
	ds_read_b128 v[46:49], v37 offset:16384
	ds_read_b128 v[50:53], v37 offset:20480
	ds_read_b128 v[54:57], v38 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[46:49], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[50:53], v[14:17]
	ds_read_b128 v[42:45], v40
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	ds_read_b128 v[46:49], v39 offset:16384
	ds_read_b128 v[50:53], v39 offset:20480
	ds_read_b128 v[54:57], v40 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[46:49], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[50:53], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	s_add_i32 s10, s10, 2
	s_waitcnt vmcnt(0)
	s_barrier
	v_lshl_add_u32 v41, s10, 6, v32
	v_add_lshl_u32 v42, v41, v33, 1
	s_mov_b32 m0, s6
	s_nop 0
	buffer_load_dwordx4 v42, s[24:27], 0 offen lds
	v_add_lshl_u32 v42, v41, v34, 1
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v42, s[24:27], 0 offen lds
	v_add_lshl_u32 v42, v41, v35, 1
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v42, s[20:23], 0 offen lds
	v_add_lshl_u32 v41, v41, v36, 1
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v41, s[20:23], 0 offen lds
	ds_read_b128 v[42:45], v38 offset:8192
	ds_read_b128 v[46:49], v37 offset:24576
	ds_read_b128 v[50:53], v37 offset:28672
	ds_read_b128 v[54:57], v38 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[46:49], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[50:53], v[14:17]
	ds_read_b128 v[42:45], v40 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	ds_read_b128 v[46:49], v39 offset:24576
	ds_read_b128 v[50:53], v39 offset:28672
	ds_read_b128 v[54:57], v40 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[46:49], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[50:53], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	s_cmp_lg_u32 s10, s12
	s_cbranch_scc1 .LBB0_3
	s_bitcmp1_b32 s9, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB0_7
	s_branch .LBB0_8
.LBB0_5:
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
	s_branch .LBB0_8
.LBB0_6:
	v_mov_b32_e32 v5, 0
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
	s_cbranch_execz .LBB0_8
.LBB0_7:
	s_lshl_b32 s6, s10, 12
	s_and_b32 s6, s6, 0x1000
	s_xor_b32 s7, s6, 0x1000
	s_lshl1_add_u32 s7, s7, s11
	s_lshl_b32 s10, s10, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_add_i32 m0, s7, 0x4000
	s_add_i32 s10, s10, 64
	v_add_lshl_u32 v28, v28, s10, 1
	buffer_load_dwordx4 v28, s[24:27], 0 offen lds
	s_add_i32 m0, s7, 0x5000
	v_add_lshl_u32 v28, v29, s10, 1
	buffer_load_dwordx4 v28, s[24:27], 0 offen lds
	v_add_lshl_u32 v28, v30, s10, 1
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v28, s[20:23], 0 offen lds
	s_add_i32 m0, s7, 0x1000
	v_add_lshl_u32 v28, v31, s10, 1
	buffer_load_dwordx4 v28, s[20:23], 0 offen lds
	s_lshl_b32 s6, s6, 1
	v_lshl_or_b32 v28, v27, 1, s6
	v_lshl_add_u32 v29, v26, 1, v28
	ds_read_b128 v[30:33], v29
	v_lshl_add_u32 v28, v25, 1, v28
	ds_read_b128 v[34:37], v28 offset:16384
	ds_read_b128 v[38:41], v28 offset:20480
	ds_read_b128 v[42:45], v29 offset:4096
	v_lshl_or_b32 v28, v24, 1, s6
	v_lshl_or_b32 v29, v23, 1, s6
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[42:45], v[34:37], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[34:37], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[38:41], v[14:17]
	ds_read_b128 v[30:33], v28
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	ds_read_b128 v[34:37], v29 offset:16384
	ds_read_b128 v[38:41], v29 offset:20480
	ds_read_b128 v[42:45], v28 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[30:33], v[34:37], v[10:13]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[30:33], v[38:41], v[14:17]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[42:45], v[34:37], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
.LBB0_8:
	s_lshr_b32 s6, s9, 31
	s_add_i32 s6, s9, s6
	s_and_b32 s6, s6, 0x7fffe
	s_sub_i32 s6, s9, s6
	s_lshl_b32 s6, s6, 13
	v_lshl_or_b32 v27, v27, 1, s6
	v_lshl_add_u32 v26, v26, 1, v27
	s_load_dwordx2 s[4:5], s[4:5], 0x0
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[28:31], v26
	v_lshl_add_u32 v25, v25, 1, v27
	ds_read_b128 v[32:35], v25 offset:16384
	ds_read_b128 v[36:39], v25 offset:20480
	ds_read_b128 v[40:43], v26 offset:4096
	v_lshl_or_b32 v24, v24, 1, s6
	v_lshl_or_b32 v23, v23, 1, s6
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[40:43], v[32:35], v[6:9]
	v_lshlrev_b32_e32 v22, 4, v22
	v_mfma_f32_16x16x32_bf16 v[10:13], v[28:31], v[32:35], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[28:31], v[36:39], v[14:17]
	ds_read_b128 v[26:29], v24
	v_mfma_f32_16x16x32_bf16 v[2:5], v[40:43], v[36:39], v[2:5]
	ds_read_b128 v[30:33], v23 offset:16384
	ds_read_b128 v[34:37], v23 offset:20480
	ds_read_b128 v[38:41], v24 offset:4096
	v_lshrrev_b32_e32 v23, 2, v0
	v_and_b32_e32 v0, 15, v0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[26:29], v[30:33], v[10:13]
	v_and_b32_e32 v24, 16, v1
	v_and_or_b32 v0, v22, 16, v0
	v_and_or_b32 v23, v23, 12, v24
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[26:29], v[34:37], v[14:17]
	v_lshlrev_b32_e32 v0, 1, v0
	s_nop 1
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_lshl_or_b32 v0, v23, 7, v0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[38:41], v[30:33], v[6:9]
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_cvt_pk_bf16_f32 v16, v16, s0
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[34:37], v[2:5]
	v_cvt_pk_bf16_f32 v15, v15, s0
	v_cvt_pk_bf16_f32 v14, v14, s0
	s_nop 1
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	s_nop 0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	s_barrier
	ds_write_b16 v0, v10
	ds_write_b16 v0, v11 offset:128
	ds_write_b16 v0, v12 offset:256
	ds_write_b16 v0, v13 offset:384
	ds_write_b16 v0, v6 offset:4096
	ds_write_b16 v0, v7 offset:4224
	ds_write_b16 v0, v8 offset:4352
	ds_write_b16 v0, v9 offset:4480
	ds_write_b16 v0, v14 offset:64
	ds_write_b16 v0, v15 offset:192
	ds_write_b16 v0, v16 offset:320
	ds_write_b16 v0, v17 offset:448
	ds_write_b16 v0, v2 offset:4160
	ds_write_b16 v0, v3 offset:4288
	ds_write_b16 v0, v4 offset:4416
	ds_write_b16 v0, v5 offset:4544
	v_or_b32_e32 v0, s8, v19
	v_cmp_gt_i32_e32 vcc, s13, v0
	s_and_b64 s[6:7], vcc, s[2:3]
	v_lshlrev_b32_e32 v2, 1, v19
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[6:7]
	s_cbranch_execz .LBB0_10
	v_lshl_or_b32 v1, v1, 7, v2
	ds_read_b128 v[6:9], v1
	v_mad_u64_u32 v[4:5], s[6:7], v21, s13, v[0:1]
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[4:5], v[4:5], 1, s[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[4:5], v[6:9], off
.LBB0_10:
	s_or_b64 exec, exec, s[2:3]
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_12
	v_lshl_or_b32 v1, v18, 7, v2
	ds_read_b128 v[2:5], v1
	v_mad_u64_u32 v[0:1], s[0:1], v20, s13, v[0:1]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 1, s[4:5]
	s_waitcnt lgkmcnt(0)
	global_store_dwordx4 v[0:1], v[2:5], off
.LBB0_12:
	s_endpgm
.Lfunc_end0:
	.size	hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0, .Lfunc_end0-hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
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
		.amdhsa_accum_offset 60
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

	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_vgpr, 58
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_agpr, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.numbered_sgpr, 30
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.num_named_barrier, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.private_seg_size, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_vcc, 1
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_recursion, 0
	.set .Lhgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.has_indirect_call, 0
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
    .name:           hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     36
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_t64x64x64x2_ks1_w2x2x1_gm0_bias0_lnt_pft_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     58
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
