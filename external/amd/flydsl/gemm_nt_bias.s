; FlyDSL 304d441202a3 kernels/gemm/gemm_a16w16_gfx950.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case gemm_nt_bias).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0
	.p2align	8
	.type	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0,@function
hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0:
	s_load_dwordx8 s[12:19], s[4:5], 0x74
	s_load_dwordx2 s[20:21], s[4:5], 0x48
	v_lshrrev_b32_e32 v28, 2, v0
	v_lshrrev_b32_e32 v29, 3, v0
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
	s_mul_i32 s26, s16, s9
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s10, v1
	s_mul_i32 s7, s7, s10
	s_mul_hi_u32 s7, s10, s7
	s_add_i32 s10, s10, s7
	s_mul_hi_u32 s7, s2, s10
	s_mul_i32 s10, s7, s1
	s_sub_i32 s2, s2, s10
	s_add_i32 s11, s7, 1
	s_sub_i32 s10, s2, s1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s7, s11, s7
	s_cselect_b32 s2, s10, s2
	s_add_i32 s10, s7, 1
	s_cmp_ge_u32 s2, s1
	s_cselect_b32 s1, s10, s7
	s_xor_b32 s7, s1, s6
	s_sub_i32 s1, s7, s6
	s_mul_i32 s10, s1, s0
	s_cmp_lg_u32 s8, s10
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 s[0:1], s[2:3], s[0:1]
	s_subb_u32 s19, s7, s6
	s_add_i32 s1, s26, s16
	s_min_i32 s1, s1, s14
	s_sub_i32 s1, s1, s26
	s_ashr_i32 s2, s1, 31
	s_lshr_b32 s2, s2, 26
	s_add_i32 s2, s1, s2
	s_sub_i32 s0, s8, s10
	s_ashr_i32 s16, s2, 6
	s_andn2_b32 s2, s2, 63
	s_cmp_lg_u32 s1, s2
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s1, 0
	v_and_b32_e32 v1, 15, v0
	s_cselect_b64 s[24:25], -1, 0
	s_lshl_b32 s15, s0, 6
	v_and_or_b32 v27, v28, 16, v1
	v_or_b32_e32 v2, s15, v27
	s_mov_b32 s3, 0x27000
	s_mov_b32 s2, -1
	v_lshlrev_b32_e32 v3, 1, v2
	v_cmp_gt_i32_e32 vcc, s13, v2
	v_or_b32_e32 v2, 32, v2
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s2
	s_mov_b32 s23, s3
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_lshlrev_b32_e32 v4, 1, v2
	v_cmp_gt_i32_e32 vcc, s13, v2
	s_load_dwordx2 s[8:9], s[4:5], 0x18
	s_load_dwordx2 s[0:1], s[4:5], 0x30
	v_cndmask_b32_e32 v2, 0, v4, vcc
	buffer_load_ushort v4, v3, s[20:23], 0 offen
	buffer_load_ushort v5, v2, s[20:23], 0 offen
	v_lshrrev_b32_e32 v3, 6, v0
	v_lshlrev_b32_e32 v2, 3, v0
	v_readfirstlane_b32 s20, v3
	v_bitop3_b32 v3, v2, 56, v0 bitop3:0x48
	v_add_u32_e32 v25, s26, v3
	v_or_b32_e32 v3, s15, v29
	v_cmp_gt_i32_e32 vcc, s13, v3
	s_lshl_b32 s14, s19, 6
	s_lshl_b32 s19, s20, 10
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_mul_lo_u32 v34, v3, s18
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	s_and_b32 s1, s1, 0xffff
	s_add_i32 s20, s19, 0x4000
	v_add_u32_e32 v18, v34, v25
	s_mov_b32 s10, s2
	s_mov_b32 s11, s3
	s_and_b64 s[6:7], s[24:25], s[6:7]
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v9, 16, v4
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v5, 16, v5
	v_lshlrev_b32_e32 v3, 1, v18
	s_mov_b32 m0, s20
	s_nop 0
	buffer_load_dwordx4 v3, s[0:3], 0 offen lds
	v_or_b32_e32 v26, 0x100, v0
	v_lshrrev_b32_e32 v3, 3, v26
	v_or_b32_e32 v4, s15, v3
	v_cmp_gt_i32_e32 vcc, s13, v4
	s_add_i32 s21, s19, 0x5000
	s_nop 0
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v35, v4, s18
	v_add_u32_e32 v19, v35, v25
	v_lshlrev_b32_e32 v4, 1, v19
	s_mov_b32 m0, s21
	s_nop 0
	buffer_load_dwordx4 v4, s[0:3], 0 offen lds
	v_or_b32_e32 v4, s14, v29
	v_cmp_gt_i32_e32 vcc, s12, v4
	s_nop 1
	v_cndmask_b32_e32 v4, 0, v4, vcc
	v_mul_lo_u32 v36, v4, s17
	v_add_u32_e32 v20, v36, v25
	v_lshlrev_b32_e32 v4, 1, v20
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], 0 offen lds
	v_or_b32_e32 v3, s14, v3
	v_cmp_gt_i32_e32 vcc, s12, v3
	s_add_i32 s18, s19, 0x1000
	s_nop 0
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_mul_lo_u32 v37, v3, s17
	v_add_u32_e32 v21, v37, v25
	v_lshlrev_b32_e32 v3, 1, v21
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v3, s[8:11], 0 offen lds
	s_cmp_lg_u64 s[6:7], 0
	s_subb_u32 s16, s16, 0
	s_add_i32 s16, s16, -1
	s_cmp_gt_i32 s16, 0
	v_lshlrev_b32_e32 v3, 4, v0
	v_and_b32_e32 v30, 56, v2
	s_cbranch_scc1 .LBB0_2
	v_and_b32_e32 v31, 0x400, v3
	v_and_b32_e32 v32, 0x400, v2
	s_mov_b64 s[6:7], 0
	s_branch .LBB0_3
.LBB0_2:
	s_mov_b64 s[6:7], -1
.LBB0_3:
	s_and_b64 s[6:7], s[6:7], exec
	s_cselect_b32 s6, 1, 0
	s_cmp_lg_u32 s6, 1
	v_lshrrev_b32_e32 v33, 1, v0
	s_cbranch_scc1 .LBB0_8
	v_lshlrev_b32_e32 v4, 6, v0
	v_and_b32_e32 v4, 0x3c0, v4
	v_and_b32_e32 v6, 24, v33
	v_or_b32_e32 v7, v4, v6
	v_and_b32_e32 v31, 0x400, v3
	v_and_b32_e32 v32, 0x400, v2
	v_or_b32_e32 v2, v7, v31
	v_bitop3_b32 v22, v2, v30, 32 bitop3:0x36
	v_or_b32_e32 v2, v7, v32
	v_bitop3_b32 v24, v4, v30, v6 bitop3:0x36
	s_cmp_eq_u32 s16, 1
	v_bitop3_b32 v23, v2, v30, 32 bitop3:0x36
	s_cbranch_scc1 .LBB0_9
	v_lshlrev_b32_e32 v2, 1, v24
	s_and_b32 s6, s16, 0x7ffffffe
	s_add_i32 s7, s19, 0x6000
	s_add_i32 s22, s19, 0x7000
	s_add_i32 s23, s19, 0x2000
	s_add_i32 s24, s19, 0x3000
	v_lshl_add_u32 v38, v31, 1, v2
	v_lshl_add_u32 v39, v32, 1, v2
	v_lshlrev_b32_e32 v40, 1, v22
	v_lshlrev_b32_e32 v41, 1, v23
	s_mov_b32 s17, 0
	s_mov_b32 s10, s2
	s_mov_b32 s11, s3
	v_mov_b32_e32 v14, v9
	v_mov_b32_e32 v15, v9
	v_mov_b32_e32 v16, v9
	v_mov_b32_e32 v17, v9
	v_mov_b32_e32 v10, v5
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v12, v5
	v_mov_b32_e32 v13, v5
	v_mov_b32_e32 v6, v9
	v_mov_b32_e32 v7, v9
	v_mov_b32_e32 v8, v9
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v3, v5
	v_mov_b32_e32 v4, v5
.LBB0_6:
	s_lshl_b32 s25, s17, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_or_b32 s25, s25, 64
	v_add_lshl_u32 v42, v18, s25, 1
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v42, s[0:3], 0 offen lds
	v_add_lshl_u32 v42, v19, s25, 1
	s_mov_b32 m0, s22
	s_nop 0
	buffer_load_dwordx4 v42, s[0:3], 0 offen lds
	v_add_lshl_u32 v42, v20, s25, 1
	s_mov_b32 m0, s23
	s_nop 0
	buffer_load_dwordx4 v42, s[8:11], 0 offen lds
	v_add_lshl_u32 v42, v21, s25, 1
	s_mov_b32 m0, s24
	s_nop 0
	buffer_load_dwordx4 v42, s[8:11], 0 offen lds
	ds_read_b128 v[42:45], v39
	ds_read_b128 v[46:49], v38 offset:16384
	ds_read_b128 v[50:53], v38 offset:20480
	ds_read_b128 v[54:57], v39 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[46:49], v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[50:53], v[10:13]
	ds_read_b128 v[42:45], v41
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	ds_read_b128 v[46:49], v40 offset:16384
	ds_read_b128 v[50:53], v40 offset:20480
	ds_read_b128 v[54:57], v41 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[46:49], v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[50:53], v[10:13]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	s_add_i32 s17, s17, 2
	s_waitcnt vmcnt(0)
	s_barrier
	v_lshl_add_u32 v42, s17, 6, v25
	v_add_lshl_u32 v43, v42, v34, 1
	s_mov_b32 m0, s20
	s_nop 0
	buffer_load_dwordx4 v43, s[0:3], 0 offen lds
	v_add_lshl_u32 v43, v42, v35, 1
	s_mov_b32 m0, s21
	s_nop 0
	buffer_load_dwordx4 v43, s[0:3], 0 offen lds
	v_add_lshl_u32 v43, v42, v36, 1
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v43, s[8:11], 0 offen lds
	v_add_lshl_u32 v42, v42, v37, 1
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v42, s[8:11], 0 offen lds
	ds_read_b128 v[42:45], v39 offset:8192
	ds_read_b128 v[46:49], v38 offset:24576
	ds_read_b128 v[50:53], v38 offset:28672
	ds_read_b128 v[54:57], v39 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[46:49], v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[50:53], v[10:13]
	ds_read_b128 v[42:45], v41 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	ds_read_b128 v[46:49], v40 offset:24576
	ds_read_b128 v[50:53], v40 offset:28672
	ds_read_b128 v[54:57], v41 offset:12288
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[46:49], v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[50:53], v[10:13]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[50:53], v[2:5]
	s_cmp_lg_u32 s17, s6
	s_cbranch_scc1 .LBB0_6
	s_bitcmp1_b32 s16, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB0_10
	s_branch .LBB0_11
.LBB0_8:
	v_mov_b32_e32 v15, v9
	v_mov_b32_e32 v16, v9
	v_mov_b32_e32 v17, v9
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v12, v5
	v_mov_b32_e32 v13, v5
	v_mov_b32_e32 v18, v9
	v_mov_b32_e32 v19, v9
	v_mov_b32_e32 v20, v9
	v_mov_b32_e32 v21, v9
	v_mov_b32_e32 v22, v5
	v_mov_b32_e32 v23, v5
	v_mov_b32_e32 v24, v5
	v_mov_b32_e32 v25, v5
	s_branch .LBB0_12
.LBB0_9:
	s_mov_b32 s17, 0
	v_mov_b32_e32 v4, v5
	v_mov_b32_e32 v3, v5
	v_mov_b32_e32 v2, v5
	v_mov_b32_e32 v8, v9
	v_mov_b32_e32 v7, v9
	v_mov_b32_e32 v6, v9
	v_mov_b32_e32 v13, v5
	v_mov_b32_e32 v12, v5
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v10, v5
	v_mov_b32_e32 v17, v9
	v_mov_b32_e32 v16, v9
	v_mov_b32_e32 v15, v9
	v_mov_b32_e32 v14, v9
	s_cbranch_execz .LBB0_11
.LBB0_10:
	s_lshl_b32 s6, s17, 12
	s_and_b32 s6, s6, 0x1000
	s_xor_b32 s7, s6, 0x1000
	s_lshl1_add_u32 s7, s7, s19
	s_lshl_b32 s10, s17, 6
	s_waitcnt vmcnt(0)
	s_barrier
	s_add_i32 m0, s7, 0x4000
	s_add_i32 s17, s10, 64
	v_add_lshl_u32 v18, v18, s17, 1
	buffer_load_dwordx4 v18, s[0:3], 0 offen lds
	s_add_i32 m0, s7, 0x5000
	v_add_lshl_u32 v18, v19, s17, 1
	buffer_load_dwordx4 v18, s[0:3], 0 offen lds
	v_add_lshl_u32 v18, v20, s17, 1
	s_mov_b32 s10, s2
	s_mov_b32 s11, s3
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	s_add_i32 m0, s7, 0x1000
	v_add_lshl_u32 v18, v21, s17, 1
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	s_lshl_b32 s0, s6, 1
	v_lshl_or_b32 v18, v24, 1, s0
	v_lshl_add_u32 v19, v32, 1, v18
	ds_read_b128 v[34:37], v19
	v_lshl_add_u32 v18, v31, 1, v18
	ds_read_b128 v[38:41], v18 offset:16384
	ds_read_b128 v[42:45], v18 offset:20480
	ds_read_b128 v[46:49], v19 offset:4096
	v_lshl_or_b32 v18, v23, 1, s0
	v_lshl_or_b32 v19, v22, 1, s0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[46:49], v[38:41], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[34:37], v[38:41], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[34:37], v[42:45], v[10:13]
	ds_read_b128 v[34:37], v18
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[42:45], v[2:5]
	ds_read_b128 v[20:23], v19 offset:16384
	ds_read_b128 v[38:41], v19 offset:20480
	ds_read_b128 v[42:45], v18 offset:4096
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[34:37], v[20:23], v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[10:13], v[34:37], v[38:41], v[10:13]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[42:45], v[20:23], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
.LBB0_11:
	s_nop 6
	v_mov_b32_e32 v21, v9
	v_mov_b32_e32 v25, v5
	v_mov_b32_e32 v9, v14
	v_mov_b32_e32 v5, v10
	v_mov_b32_e32 v18, v6
	v_mov_b32_e32 v19, v7
	v_mov_b32_e32 v20, v8
	v_mov_b32_e32 v22, v2
	v_mov_b32_e32 v23, v3
	v_mov_b32_e32 v24, v4
.LBB0_12:
	s_lshr_b32 s0, s16, 31
	s_add_i32 s0, s16, s0
	s_and_b32 s0, s0, 0x7fffe
	v_lshlrev_b32_e32 v34, 6, v1
	v_and_b32_e32 v33, 24, v33
	s_sub_i32 s0, s16, s0
	v_bitop3_b32 v2, v33, v30, v34 bitop3:0x36
	s_lshl_b32 s0, s0, 13
	v_lshl_add_u32 v2, v2, 1, s0
	v_lshl_add_u32 v3, v32, 1, v2
	s_load_dwordx2 s[2:3], s[4:5], 0x0
	s_waitcnt vmcnt(0)
	s_barrier
	ds_read_b128 v[36:39], v3
	v_lshl_add_u32 v2, v31, 1, v2
	ds_read_b128 v[40:43], v2 offset:16384
	ds_read_b128 v[44:47], v2 offset:20480
	ds_read_b128 v[48:51], v3 offset:4096
	v_mov_b32_e32 v10, v5
	v_mov_b32_e32 v14, v9
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[36:39], v[44:47], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[48:51], v[40:43], v[18:21]
	s_nop 2
	v_or_b32_e32 v18, v33, v34
	v_or_b32_e32 v19, v32, v18
	v_bitop3_b32 v19, v19, v30, 32 bitop3:0x36
	v_lshl_add_u32 v19, v19, 1, s0
	v_mfma_f32_16x16x32_bf16 v[6:9], v[36:39], v[40:43], v[14:17]
	v_or_b32_e32 v18, v31, v18
	v_bitop3_b32 v18, v18, v30, 32 bitop3:0x36
	v_lshl_add_u32 v18, v18, 1, s0
	v_mfma_f32_16x16x32_bf16 v[14:17], v[48:51], v[44:47], v[22:25]
	ds_read_b128 v[30:33], v18 offset:16384
	ds_read_b128 v[34:37], v18 offset:20480
	ds_read_b128 v[38:41], v19 offset:4096
	ds_read_b128 v[20:23], v19
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[20:23], v[30:33], v[6:9]
	s_barrier
	v_mfma_f32_16x16x32_bf16 v[18:21], v[20:23], v[34:37], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[38:41], v[34:37], v[14:17]
	s_nop 1
	v_and_b32_e32 v2, 16, v29
	v_and_or_b32 v2, v28, 12, v2
	s_nop 0
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_mfma_f32_16x16x32_bf16 v[10:13], v[38:41], v[30:33], v[10:13]
	v_lshrrev_b32_e32 v3, 4, v0
	v_cvt_pk_bf16_f32 v4, v17, s0
	v_cvt_pk_bf16_f32 v17, v20, s0
	v_lshlrev_b32_e32 v20, 1, v27
	v_lshl_or_b32 v2, v2, 7, v20
	v_cvt_pk_bf16_f32 v5, v16, s0
	v_cvt_pk_bf16_f32 v15, v15, s0
	v_cvt_pk_bf16_f32 v14, v14, s0
	v_cvt_pk_bf16_f32 v16, v21, s0
	v_cvt_pk_bf16_f32 v19, v19, s0
	v_cvt_pk_bf16_f32 v18, v18, s0
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_cvt_pk_bf16_f32 v10, v10, s0
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v8, v8, s0
	v_cvt_pk_bf16_f32 v7, v7, s0
	ds_write_b16 v2, v6
	ds_write_b16 v2, v7 offset:128
	ds_write_b16 v2, v8 offset:256
	ds_write_b16 v2, v9 offset:384
	ds_write_b16 v2, v10 offset:4096
	ds_write_b16 v2, v11 offset:4224
	ds_write_b16 v2, v12 offset:4352
	ds_write_b16 v2, v13 offset:4480
	ds_write_b16 v2, v18 offset:64
	ds_write_b16 v2, v19 offset:192
	ds_write_b16 v2, v17 offset:320
	ds_write_b16 v2, v16 offset:448
	ds_write_b16 v2, v14 offset:4160
	ds_write_b16 v2, v15 offset:4288
	ds_write_b16 v2, v5 offset:4416
	ds_write_b16 v2, v4 offset:4544
	v_lshlrev_b32_e32 v4, 2, v1
	v_or_b32_e32 v1, s14, v3
	v_or_b32_e32 v2, s15, v4
	v_cmp_gt_i32_e32 vcc, s12, v1
	v_cmp_gt_i32_e64 s[0:1], s13, v2
	s_and_b64 s[4:5], s[0:1], vcc
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_14
	v_lshlrev_b32_e32 v4, 1, v4
	v_lshl_or_b32 v4, v3, 7, v4
	ds_read_b64 v[4:5], v4
	v_mad_u64_u32 v[8:9], s[4:5], v1, s13, v[2:3]
	v_ashrrev_i32_e32 v9, 31, v8
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[2:3]
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	global_store_dwordx4 v[8:9], v[4:7], off
.LBB0_14:
	s_or_b64 exec, exec, s[0:1]
	v_lshlrev_b32_e32 v0, 2, v0
	v_lshrrev_b32_e32 v2, 4, v26
	v_and_b32_e32 v1, 60, v0
	v_or_b32_e32 v4, s14, v2
	v_or_b32_e32 v0, s15, v1
	v_cmp_gt_i32_e64 s[0:1], s12, v4
	v_cmp_gt_i32_e32 vcc, s13, v0
	s_and_b64 s[4:5], vcc, s[0:1]
	v_lshlrev_b32_e32 v1, 1, v1
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_16
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
.LBB0_16:
	s_or_b64 exec, exec, s[0:1]
	s_nop 0
	v_or_b32_e32 v4, 32, v3
	v_or_b32_e32 v2, s14, v4
	v_cmp_gt_i32_e64 s[0:1], s12, v2
	s_and_b64 s[4:5], vcc, s[0:1]
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_18
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
.LBB0_18:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, 48, v3
	v_or_b32_e32 v2, s14, v3
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
	.size	hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0, .Lfunc_end0-hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0
		.amdhsa_group_segment_fixed_size 32768
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 400
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

	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.num_vgpr, 58
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.num_agpr, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.numbered_sgpr, 27
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.num_named_barrier, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.private_seg_size, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.uses_vcc, 1
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.uses_flat_scratch, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.has_dyn_sized_stack, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.has_recursion, 0
	.set .Lhgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.has_indirect_call, 0
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
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     global_buffer
      - .offset:         96
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         104
        .size:           8
        .value_kind:     global_buffer
      - .offset:         112
        .size:           4
        .value_kind:     by_value
      - .offset:         116
        .size:           4
        .value_kind:     by_value
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
        .value_kind:     hidden_block_count_x
      - .offset:         148
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         152
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         156
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         158
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         160
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         162
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         164
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         166
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         184
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         192
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         200
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         208
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         224
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .offset:         232
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
      - .offset:         240
        .size:           8
        .value_kind:     hidden_heap_v1
      - .offset:         248
        .size:           8
        .value_kind:     hidden_default_queue
      - .offset:         256
        .size:           8
        .value_kind:     hidden_completion_action
      - .offset:         344
        .size:           8
        .value_kind:     hidden_queue_ptr
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 400
    .max_flat_workgroup_size: 256
    .name:           hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     33
    .sgpr_spill_count: 0
    .symbol:         hgemm_bf16_fp32_t64x64x64x2_ks1_w2x2x1_gm0_bias1_lnt_pft_0.kd
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
