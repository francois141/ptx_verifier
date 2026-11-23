; AKLR 766a200e367f aklr/ops/gemm/impls/flydsl/gemm_n2304_k8192/a5184eccfc6977a7.json, compiled for gfx950 by
; external/amd/aklr/build.py (case gemm_n2304_gemv_m8_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	gemm_n2304_k8192_gemv_0
	.p2align	8
	.type	gemm_n2304_k8192_gemv_0,@function
gemm_n2304_k8192_gemv_0:
	v_lshrrev_b32_e32 v2, 6, v0
	s_mul_i32 s16, s2, 9
	v_and_b32_e32 v1, 63, v0
	v_add_lshl_u32 v3, s16, v2, 14
	v_bitop3_b32 v4, v0, v2, 63 bitop3:0x6c
	v_lshl_or_b32 v7, v4, 4, v3
	v_bitop3_b32 v4, v2, v1, 4 bitop3:0x36
	v_lshl_or_b32 v3, v4, 4, v3
	v_subrev_co_u32_e32 v8, vcc, 64, v0
	v_add_u32_e32 v6, 0x10000, v3
	v_ashrrev_i16_e32 v3, 15, v8
	v_lshrrev_b16_e32 v3, 10, v3
	v_add_u16_e32 v9, v8, v3
	s_mul_i32 s17, s2, 3
	v_ashrrev_i16_e32 v3, 6, v9
	v_bfe_i32 v3, v3, 0, 16
	s_ashr_i32 s4, s17, 31
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x18
	v_readfirstlane_b32 s2, v2
	v_lshlrev_b32_e32 v10, 6, v3
	s_lshr_b32 s4, s4, 28
	s_lshl_b32 s21, s2, 10
	v_cmp_ne_u32_e64 s[2:3], v8, v10
	s_add_i32 s4, s17, s4
	v_or_b32_e32 v5, 0x200, v0
	s_and_b64 s[2:3], vcc, s[2:3]
	v_and_b32_e32 v9, 0xffffffc0, v9
	s_and_b32 s4, s4, 0x3ffff0
	v_lshrrev_b32_e32 v4, 6, v5
	v_subbrev_co_u32_e64 v10, s[2:3], 0, v3, s[2:3]
	v_sub_u16_e32 v8, v8, v9
	s_sub_i32 s4, s17, s4
	v_add_u32_e32 v3, s16, v4
	v_bitop3_b32 v4, v4, v0, 63 bitop3:0x78
	v_lshlrev_b32_e32 v11, 14, v10
	v_xor_b32_sdwa v8, v10, sext(v8) dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0
	s_movk_i32 s2, 0x23f
	s_lshl_b32 s6, s4, 10
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x20000
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s14, 0x2400000
	s_and_b32 s13, s13, 0xffff
	v_lshlrev_b32_e32 v4, 4, v4
	v_lshl_add_u32 v8, v8, 4, v11
	v_cmp_lt_u32_e64 s[2:3], s2, v5
	v_add_u32_e32 v5, s6, v7
	s_add_i32 s34, s21, 0x1000
	s_add_i32 s25, s21, 0x2000
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s21
	buffer_load_dwordx4 v5, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v5, s6, v6
	;;#ASMSTART
	s_mov_b32 m0, s34
	buffer_load_dwordx4 v5, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB0_2
	v_add_u32_e32 v5, s6, v8
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v5, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_2:
	s_or_saveexec_b64 s[4:5], s[4:5]
	v_lshl_or_b32 v9, v3, 14, v4
	s_xor_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_4
	v_add_u32_e32 v3, s6, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_4:
	s_or_b64 exec, exec, s[4:5]
	v_add_u32_e32 v3, 0xc0, v0
	v_lshrrev_b32_e32 v3, 6, v3
	v_lshlrev_b32_e32 v4, 14, v3
	v_xor_b32_e32 v3, v3, v1
	s_add_i32 s17, s17, 1
	v_lshl_or_b32 v11, v3, 4, v4
	v_add_u32_e32 v3, 0x1c0, v0
	s_ashr_i32 s4, s17, 31
	v_lshrrev_b32_e32 v3, 6, v3
	s_lshr_b32 s4, s4, 28
	v_lshlrev_b32_e32 v4, 14, v3
	v_xor_b32_e32 v3, v3, v1
	s_add_i32 s4, s17, s4
	v_lshl_or_b32 v3, v3, 4, v4
	v_mov_b32_e32 v4, 0x7ffffff0
	s_and_b32 s4, s4, 0x3ffff0
	v_cndmask_b32_e32 v10, v4, v3, vcc
	v_add_u32_e32 v3, s6, v11
	s_sub_i32 s4, s17, s4
	s_add_i32 s37, s21, 0x3000
	;;#ASMSTART
	s_mov_b32 m0, s37
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v10
	s_lshl_b32 s6, s4, 10
	s_add_i32 s38, s21, 0x4000
	;;#ASMSTART
	s_mov_b32 m0, s38
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	s_add_i32 s31, s21, 0x5000
	v_add_u32_e32 v3, s6, v7
	s_add_i32 s35, s21, 0x6000
	s_add_i32 s26, s21, 0x7000
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s31
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v6
	;;#ASMSTART
	s_mov_b32 m0, s35
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB0_6
	v_add_u32_e32 v3, s6, v8
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_6:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	s_cbranch_execz .LBB0_8
	v_add_u32_e32 v3, s6, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_8:
	s_or_b64 exec, exec, s[4:5]
	s_add_i32 s4, s17, 1
	s_ashr_i32 s5, s4, 31
	s_lshr_b32 s5, s5, 28
	s_add_i32 s5, s4, s5
	s_and_b32 s5, s5, 0x3ffff0
	v_add_u32_e32 v3, s6, v11
	s_sub_i32 s4, s4, s5
	s_add_i32 s33, s21, 0x8000
	;;#ASMSTART
	s_mov_b32 m0, s33
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v10
	s_lshl_b32 s6, s4, 10
	s_add_i32 s36, s21, 0x9000
	;;#ASMSTART
	s_mov_b32 m0, s36
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	s_add_i32 s27, s21, 0xa000
	v_add_u32_e32 v3, s6, v7
	s_add_i32 s29, s21, 0xb000
	s_add_i32 s19, s21, 0xc000
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s27
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v6
	;;#ASMSTART
	s_mov_b32 m0, s29
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB0_10
	v_add_u32_e32 v3, s6, v8
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_10:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	s_cbranch_execz .LBB0_12
	v_add_u32_e32 v3, s6, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_12:
	s_or_b64 exec, exec, s[4:5]
	s_add_i32 s4, s17, 2
	s_ashr_i32 s5, s4, 31
	s_lshr_b32 s5, s5, 28
	s_add_i32 s5, s4, s5
	s_and_b32 s5, s5, 0x3ffff0
	v_add_u32_e32 v3, s6, v11
	s_sub_i32 s4, s4, s5
	s_add_i32 s28, s21, 0xd000
	;;#ASMSTART
	s_mov_b32 m0, s28
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v10
	s_lshl_b32 s6, s4, 10
	s_add_i32 s30, s21, 0xe000
	;;#ASMSTART
	s_mov_b32 m0, s30
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	s_add_i32 s20, s21, 0xf000
	v_add_u32_e32 v3, s6, v7
	s_add_i32 s23, s21, 0x10000
	s_add_i32 s18, s21, 0x11000
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s20
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v3, s6, v6
	;;#ASMSTART
	s_mov_b32 m0, s23
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_xor_b64 s[4:5], exec, s[4:5]
	s_cbranch_execz .LBB0_14
	v_add_u32_e32 v3, s6, v8
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_14:
	s_andn2_saveexec_b64 s[4:5], s[4:5]
	s_cbranch_execz .LBB0_16
	v_add_u32_e32 v3, s6, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v3, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_16:
	s_or_b64 exec, exec, s[4:5]
	v_and_b32_e32 v12, 15, v0
	v_cmp_gt_u32_e64 s[4:5], 9, v12
	v_lshrrev_b32_e32 v13, 4, v1
	v_lshl_or_b32 v22, v2, 4, v13
	v_cndmask_b32_e64 v21, 8, v12, s[4:5]
	v_lshlrev_b32_e32 v23, 6, v21
	v_bitop3_b32 v2, v23, v22, v21 bitop3:0xf6
	v_min_u32_e32 v20, 7, v12
	v_lshlrev_b32_e32 v14, 4, v2
	v_mov_b32_e32 v2, 0x240
	v_lshl_add_u32 v24, v20, 6, v2
	v_bitop3_b32 v2, v24, v22, v20 bitop3:0xf6
	v_add_u32_e32 v3, s6, v11
	v_lshlrev_b32_e32 v15, 4, v2
	s_add_i32 s22, s21, 0x12000
	;;#ASMSTART
	s_mov_b32 m0, s22
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	s_add_i32 s24, s21, 0x13000
	v_add_u32_e32 v3, s6, v10
	;;#ASMSTART
	s_mov_b32 m0, s24
	buffer_load_dwordx4 v3, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[26:29], v15
	ds_read_b128 v[30:33], v14
	v_or_b32_e32 v2, 4, v22
	v_bitop3_b32 v3, v2, v23, v21 bitop3:0xde
	v_or_b32_e32 v19, 8, v22
	v_lshlrev_b32_e32 v16, 4, v3
	v_bitop3_b32 v2, v2, v24, v20 bitop3:0xde
	v_bitop3_b32 v18, v19, v24, v20 bitop3:0xde
	v_lshlrev_b32_e32 v17, 4, v2
	ds_read_b128 v[34:37], v16
	ds_read_b128 v[38:41], v17
	v_lshlrev_b32_e32 v18, 4, v18
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], 0
	ds_read_b128 v[26:29], v18
	v_or_b32_e32 v22, 12, v22
	v_bitop3_b32 v19, v19, v23, v21 bitop3:0xde
	v_bitop3_b32 v20, v22, v24, v20 bitop3:0xde
	v_lshlrev_b32_e32 v19, 4, v19
	v_lshlrev_b32_e32 v20, 4, v20
	ds_read_b128 v[30:33], v19
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[34:37], v[2:5]
	ds_read_b128 v[34:37], v20
	v_bitop3_b32 v21, v22, v23, v21 bitop3:0xde
	v_lshlrev_b32_e32 v21, 4, v21
	ds_read_b128 v[22:25], v21
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	s_add_i32 s6, s17, 3
	s_ashr_i32 s7, s6, 31
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[34:37], v[22:25], v[2:5]
	s_and_b32 s7, s7, 0x3ffff0
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	v_add_u32_e32 v22, s39, v7
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s21
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s34
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_18
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_18:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_20
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_20:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s37
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s38
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:20480
	ds_read_b128 v[26:29], v14 offset:20480
	ds_read_b128 v[30:33], v17 offset:20480
	ds_read_b128 v[34:37], v16 offset:20480
	ds_read_b128 v[38:41], v19 offset:20480
	ds_read_b128 v[42:45], v18 offset:20480
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:20480
	ds_read_b128 v[26:29], v20 offset:20480
	s_add_i32 s6, s17, 4
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s31
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s35
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_22
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_22:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_24
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_24:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s33
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s36
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:40960
	ds_read_b128 v[26:29], v14 offset:40960
	ds_read_b128 v[30:33], v17 offset:40960
	ds_read_b128 v[34:37], v16 offset:40960
	ds_read_b128 v[38:41], v19 offset:40960
	ds_read_b128 v[42:45], v18 offset:40960
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:40960
	ds_read_b128 v[26:29], v20 offset:40960
	s_add_i32 s6, s17, 5
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s27
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s29
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_26
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_26:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_28
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_28:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s28
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s30
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:61440
	ds_read_b128 v[26:29], v14 offset:61440
	ds_read_b128 v[30:33], v17 offset:61440
	ds_read_b128 v[34:37], v16 offset:61440
	ds_read_b128 v[38:41], v19 offset:61440
	ds_read_b128 v[42:45], v18 offset:61440
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:61440
	ds_read_b128 v[26:29], v20 offset:61440
	s_add_i32 s6, s17, 6
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s20
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s23
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_30
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_30:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_32
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_32:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s22
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s24
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15
	ds_read_b128 v[26:29], v14
	ds_read_b128 v[30:33], v17
	ds_read_b128 v[34:37], v16
	ds_read_b128 v[38:41], v19
	ds_read_b128 v[42:45], v18
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21
	ds_read_b128 v[26:29], v20
	s_add_i32 s6, s17, 7
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s21
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s34
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_34
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_34:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_36
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_36:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s37
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s38
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:20480
	ds_read_b128 v[26:29], v14 offset:20480
	ds_read_b128 v[30:33], v17 offset:20480
	ds_read_b128 v[34:37], v16 offset:20480
	ds_read_b128 v[38:41], v19 offset:20480
	ds_read_b128 v[42:45], v18 offset:20480
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:20480
	ds_read_b128 v[26:29], v20 offset:20480
	s_add_i32 s6, s17, 8
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s31
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s35
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_38
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_38:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_40
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_40:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s33
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s36
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:40960
	ds_read_b128 v[26:29], v14 offset:40960
	ds_read_b128 v[30:33], v17 offset:40960
	ds_read_b128 v[34:37], v16 offset:40960
	ds_read_b128 v[38:41], v19 offset:40960
	ds_read_b128 v[42:45], v18 offset:40960
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:40960
	ds_read_b128 v[26:29], v20 offset:40960
	s_add_i32 s6, s17, 9
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s27
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s29
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_42
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_42:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_44
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_44:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s28
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s30
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:61440
	ds_read_b128 v[26:29], v14 offset:61440
	ds_read_b128 v[30:33], v17 offset:61440
	ds_read_b128 v[34:37], v16 offset:61440
	ds_read_b128 v[38:41], v19 offset:61440
	ds_read_b128 v[42:45], v18 offset:61440
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:61440
	ds_read_b128 v[26:29], v20 offset:61440
	s_add_i32 s6, s17, 10
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s20
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s23
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_46
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_46:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_48
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_48:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s22
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s24
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15
	ds_read_b128 v[26:29], v14
	ds_read_b128 v[30:33], v17
	ds_read_b128 v[34:37], v16
	ds_read_b128 v[38:41], v19
	ds_read_b128 v[42:45], v18
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21
	ds_read_b128 v[26:29], v20
	s_add_i32 s6, s17, 11
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s39, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s39, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s21
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v6
	;;#ASMSTART
	s_mov_b32 m0, s34
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_50
	v_add_u32_e32 v22, s39, v8
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_50:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_52
	v_add_u32_e32 v22, s39, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s25
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_52:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s39, v11
	;;#ASMSTART
	s_mov_b32 m0, s37
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s39, v10
	;;#ASMSTART
	s_mov_b32 m0, s38
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:20480
	ds_read_b128 v[26:29], v14 offset:20480
	ds_read_b128 v[30:33], v17 offset:20480
	ds_read_b128 v[34:37], v16 offset:20480
	ds_read_b128 v[38:41], v19 offset:20480
	ds_read_b128 v[42:45], v18 offset:20480
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:20480
	ds_read_b128 v[26:29], v20 offset:20480
	s_add_i32 s6, s17, 12
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s21, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s21, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s31
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s21, v6
	;;#ASMSTART
	s_mov_b32 m0, s35
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_54
	v_add_u32_e32 v22, s21, v8
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_54:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_56
	v_add_u32_e32 v22, s21, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s26
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_56:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s21, v11
	;;#ASMSTART
	s_mov_b32 m0, s33
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s21, v10
	;;#ASMSTART
	s_mov_b32 m0, s36
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:40960
	ds_read_b128 v[26:29], v14 offset:40960
	ds_read_b128 v[30:33], v17 offset:40960
	ds_read_b128 v[34:37], v16 offset:40960
	ds_read_b128 v[38:41], v19 offset:40960
	ds_read_b128 v[42:45], v18 offset:40960
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:40960
	ds_read_b128 v[26:29], v20 offset:40960
	s_add_i32 s6, s17, 13
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s21, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v22, s21, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s27
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v22, s21, v6
	;;#ASMSTART
	s_mov_b32 m0, s29
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_xor_b64 s[6:7], exec, s[6:7]
	s_cbranch_execz .LBB0_58
	v_add_u32_e32 v22, s21, v8
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_58:
	s_andn2_saveexec_b64 s[6:7], s[6:7]
	s_cbranch_execz .LBB0_60
	v_add_u32_e32 v22, s21, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s19
	buffer_load_dwordx4 v22, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_60:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v22, s21, v11
	;;#ASMSTART
	s_mov_b32 m0, s28
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v22, s21, v10
	;;#ASMSTART
	s_mov_b32 m0, s30
	buffer_load_dwordx4 v22, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[22:25], v15 offset:61440
	ds_read_b128 v[26:29], v14 offset:61440
	ds_read_b128 v[30:33], v17 offset:61440
	ds_read_b128 v[34:37], v16 offset:61440
	ds_read_b128 v[38:41], v19 offset:61440
	ds_read_b128 v[42:45], v18 offset:61440
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[26:29], v[2:5]
	ds_read_b128 v[22:25], v21 offset:61440
	ds_read_b128 v[26:29], v20 offset:61440
	s_add_i32 s6, s17, 14
	s_ashr_i32 s7, s6, 31
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[34:37], v[2:5]
	s_lshr_b32 s7, s7, 28
	s_add_i32 s7, s6, s7
	s_and_b32 s7, s7, 0x3ffff0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[42:45], v[38:41], v[2:5]
	s_sub_i32 s6, s6, s7
	s_lshl_b32 s6, s6, 10
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[22:25], v[2:5]
	v_add_u32_e32 v7, s6, v7
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s20
	buffer_load_dwordx4 v7, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	v_add_u32_e32 v6, s6, v6
	;;#ASMSTART
	s_mov_b32 m0, s23
	buffer_load_dwordx4 v6, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
	s_and_saveexec_b64 s[20:21], s[2:3]
	s_xor_b64 s[2:3], exec, s[20:21]
	s_cbranch_execz .LBB0_62
	v_add_u32_e32 v6, s6, v8
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v6, s[8:11], 0 offen  lds
	;;#ASMEND
.LBB0_62:
	s_andn2_saveexec_b64 s[2:3], s[2:3]
	s_cbranch_execz .LBB0_64
	v_add_u32_e32 v6, s6, v9
	s_mov_b32 s15, s11
	;;#ASMSTART
	s_mov_b32 m0, s18
	buffer_load_dwordx4 v6, s[12:15], 0 offen sc0 nt lds
	;;#ASMEND
.LBB0_64:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v6, s6, v11
	;;#ASMSTART
	s_mov_b32 m0, s22
	buffer_load_dwordx4 v6, s[8:11], 0 offen  lds
	;;#ASMEND
	v_add_u32_e32 v6, s6, v10
	;;#ASMSTART
	s_mov_b32 m0, s24
	buffer_load_dwordx4 v6, s[8:11], 0 offen  lds
	;;#ASMEND
	ds_read_b128 v[6:9], v15
	ds_read_b128 v[22:25], v14
	ds_read_b128 v[26:29], v17
	ds_read_b128 v[30:33], v16
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v18
	ds_read_b128 v[22:25], v19
	v_lshlrev_b32_e32 v0, 4, v0
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v20
	ds_read_b128 v[30:33], v21
	;;#ASMSTART
	s_waitcnt vmcnt(10) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v15 offset:20480
	ds_read_b128 v[22:25], v14 offset:20480
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v17 offset:20480
	ds_read_b128 v[30:33], v16 offset:20480
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v18 offset:20480
	ds_read_b128 v[22:25], v19 offset:20480
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v20 offset:20480
	ds_read_b128 v[30:33], v21 offset:20480
	;;#ASMSTART
	s_waitcnt vmcnt(5) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v15 offset:40960
	ds_read_b128 v[22:25], v14 offset:40960
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v17 offset:40960
	ds_read_b128 v[30:33], v16 offset:40960
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v18 offset:40960
	ds_read_b128 v[22:25], v19 offset:40960
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v20 offset:40960
	ds_read_b128 v[30:33], v21 offset:40960
	;;#ASMSTART
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v15 offset:61440
	ds_read_b128 v[22:25], v14 offset:61440
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[30:33], v[2:5]
	ds_read_b128 v[26:29], v17 offset:61440
	ds_read_b128 v[14:17], v16 offset:61440
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[6:9], v18 offset:61440
	ds_read_b128 v[22:25], v19 offset:61440
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[14:17], v[2:5]
	ds_read_b128 v[14:17], v20 offset:61440
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[6:9], v[22:25], v[2:5]
	ds_read_b128 v[8:11], v21 offset:61440
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[14:17], v[8:11], v[4:7]
	s_nop 1
	v_or_b32_e32 v2, 0x14000, v0
	s_nop 4
	ds_write_b128 v2, v[4:7]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_66
	v_add_u32_e32 v6, 0x14400, v0
	ds_read_b128 v[2:5], v2
	ds_read_b128 v[6:9], v6
	v_add_u32_e32 v10, 0x14800, v0
	ds_read_b128 v[14:17], v10
	v_add_u32_e32 v0, 0x14c00, v0
	ds_read_b128 v[18:21], v0
	s_load_dwordx2 s[0:1], s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	v_pk_add_f32 v[4:5], v[4:5], v[16:17]
	v_pk_add_f32 v[2:3], v[2:3], v[14:15]
	v_pk_add_f32 v[4:5], v[4:5], v[20:21]
	v_cmp_gt_u32_e32 vcc, 32, v1
	v_cvt_pk_bf16_f32 v0, v5, s0
	v_mul_u32_u24_e32 v1, 0x2400, v13
	v_add_u32_e32 v5, s16, v12
	v_pk_add_f32 v[2:3], v[2:3], v[18:19]
	v_add_lshl_u32 v1, v5, v1, 1
	v_mov_b32_e32 v5, 0x7ffffff0
	s_and_b64 vcc, s[4:5], vcc
	s_mov_b32 s3, 0x27000
	s_mov_b32 s2, 0x9000
	s_and_b32 s1, s1, 0xffff
	v_cvt_pk_bf16_f32 v2, v2, s0
	v_cndmask_b32_e32 v6, v5, v1, vcc
	buffer_store_short v2, v6, s[0:3], 0 offen
	v_add_u32_e32 v2, 0x1200, v1
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cndmask_b32_e32 v2, v5, v2, vcc
	buffer_store_short v3, v2, s[0:3], 0 offen
	v_add_u32_e32 v2, 0x2400, v1
	v_add_u32_e32 v1, 0x3600, v1
	v_cvt_pk_bf16_f32 v4, v4, s0
	v_cndmask_b32_e32 v2, v5, v2, vcc
	v_cndmask_b32_e32 v1, v5, v1, vcc
	buffer_store_short v4, v2, s[0:3], 0 offen
	buffer_store_short v0, v1, s[0:3], 0 offen
.LBB0_66:
	s_endpgm
.Lfunc_end0:
	.size	gemm_n2304_k8192_gemv_0, .Lfunc_end0-gemm_n2304_k8192_gemv_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel gemm_n2304_k8192_gemv_0
		.amdhsa_group_segment_fixed_size 86016
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 72
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 257
		.amdhsa_next_free_sgpr 96
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

	.set .Lgemm_n2304_k8192_gemv_0.num_vgpr, 46
	.set .Lgemm_n2304_k8192_gemv_0.num_agpr, 0
	.set .Lgemm_n2304_k8192_gemv_0.numbered_sgpr, 40
	.set .Lgemm_n2304_k8192_gemv_0.num_named_barrier, 0
	.set .Lgemm_n2304_k8192_gemv_0.private_seg_size, 0
	.set .Lgemm_n2304_k8192_gemv_0.uses_vcc, 1
	.set .Lgemm_n2304_k8192_gemv_0.uses_flat_scratch, 0
	.set .Lgemm_n2304_k8192_gemv_0.has_dyn_sized_stack, 0
	.set .Lgemm_n2304_k8192_gemv_0.has_recursion, 0
	.set .Lgemm_n2304_k8192_gemv_0.has_indirect_call, 0
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
    .group_segment_fixed_size: 86016
    .kernarg_segment_align: 8
    .kernarg_segment_size: 72
    .max_flat_workgroup_size: 256
    .name:           gemm_n2304_k8192_gemv_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         gemm_n2304_k8192_gemv_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     46
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
