; FlyDSL 304d441202a3 kernels/moe/moe_sorting_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case moe_sorting_p23).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	p23_kernel_0
	.p2align	8
	.type	p23_kernel_0,@function
p23_kernel_0:
	s_load_dwordx4 s[24:27], s[0:1], 0x84
	s_cmp_lt_i32 s2, 8
	s_cbranch_scc1 .LBB0_9
	s_load_dword s19, s[0:1], 0x98
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s18, s27, 2
	s_mov_b32 s22, -1
	s_mov_b32 s28, 0
	s_lshl_b32 s3, s19, 8
	s_addk_i32 s3, 0xf800
	s_abs_i32 s4, s3
	v_cvt_f32_u32_e32 v1, s4
	s_sub_i32 s6, 0, s4
	s_add_i32 s5, s18, s3
	s_add_i32 s5, s5, -1
	v_rcp_f32_e32 v1, v1
	s_abs_i32 s8, s5
	s_xor_b32 s7, s5, s3
	s_ashr_i32 s9, s7, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_nop 0
	v_readfirstlane_b32 s10, v1
	s_mul_i32 s6, s6, s10
	s_mul_hi_u32 s6, s10, s6
	s_add_i32 s10, s10, s6
	s_mul_hi_u32 s6, s8, s10
	s_mul_i32 s10, s6, s4
	s_sub_i32 s8, s8, s10
	s_add_i32 s11, s6, 1
	s_sub_i32 s10, s8, s4
	s_cmp_ge_u32 s8, s4
	s_cselect_b32 s6, s11, s6
	s_cselect_b32 s8, s10, s8
	s_add_i32 s10, s6, 1
	s_cmp_ge_u32 s8, s4
	s_cselect_b32 s4, s10, s6
	s_xor_b32 s8, s4, s9
	s_sub_i32 s4, s8, s9
	s_mul_i32 s4, s3, s4
	s_cmp_lg_u32 s5, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s7, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[4:5], s[6:7]
	s_subb_u32 s6, s8, s9
	s_cmp_lt_i32 s6, 1
	s_cbranch_scc1 .LBB0_9
	s_load_dwordx2 s[20:21], s[0:1], 0x68
	s_lshl_b32 s33, s2, 8
	s_add_i32 s4, s6, -1
	s_and_b32 s27, s6, 7
	s_mov_b32 s23, 0x27000
	s_waitcnt lgkmcnt(0)
	s_and_b32 s21, s21, 0xffff
	s_cmp_lt_u32 s4, 7
	s_mov_b64 s[4:5], -1
	s_cbranch_scc1 .LBB0_6
	v_add_u32_e32 v1, s33, v0
	v_add_u32_e32 v2, 0xfffff800, v1
	v_lshl_add_u32 v3, s3, 1, v2
	v_mad_u64_u32 v[4:5], s[4:5], s3, 3, v[2:3]
	s_mov_b32 s29, s28
	s_mov_b32 s30, s28
	s_mov_b32 s31, s28
	s_and_b32 s34, s6, 0x7ffffff8
	v_add_u32_e32 v1, s3, v2
	v_lshl_add_u32 v5, s3, 2, v2
	v_mad_u64_u32 v[6:7], s[4:5], s3, 5, v[2:3]
	v_mad_u64_u32 v[8:9], s[4:5], s3, 6, v[2:3]
	v_mad_u64_u32 v[10:11], s[4:5], s3, 7, v[2:3]
	v_mov_b64_e32 v[12:13], s[28:29]
	v_mov_b64_e32 v[14:15], s[30:31]
.LBB0_4:
	s_mul_i32 s4, s28, s3
	v_add_u32_e32 v7, s4, v2
	s_add_i32 s28, s28, 8
	v_add_u32_e32 v9, s4, v1
	v_add_u32_e32 v11, s4, v3
	v_add_u32_e32 v16, s4, v4
	v_add_u32_e32 v17, s4, v5
	v_add_u32_e32 v18, s4, v6
	v_add_u32_e32 v19, s4, v8
	v_add_u32_e32 v20, s4, v10
	v_lshlrev_b32_e32 v21, 4, v7
	v_cmp_gt_i32_e64 s[16:17], s18, v7
	s_cmp_lg_u32 s28, s34
	v_lshlrev_b32_e32 v22, 4, v9
	v_cmp_gt_i32_e32 vcc, s18, v9
	v_lshlrev_b32_e32 v9, 4, v11
	v_cmp_gt_i32_e64 s[4:5], s18, v11
	v_lshlrev_b32_e32 v11, 4, v16
	v_cmp_gt_i32_e64 s[6:7], s18, v16
	v_lshlrev_b32_e32 v16, 4, v17
	v_cmp_gt_i32_e64 s[8:9], s18, v17
	v_lshlrev_b32_e32 v17, 4, v18
	v_cmp_gt_i32_e64 s[10:11], s18, v18
	v_lshlrev_b32_e32 v18, 4, v19
	v_cmp_gt_i32_e64 s[12:13], s18, v19
	v_lshlrev_b32_e32 v19, 4, v20
	v_cmp_gt_i32_e64 s[14:15], s18, v20
	v_cndmask_b32_e64 v7, -4, v21, s[16:17]
	v_cndmask_b32_e32 v20, -4, v22, vcc
	v_cndmask_b32_e64 v9, -4, v9, s[4:5]
	v_cndmask_b32_e64 v11, -4, v11, s[6:7]
	v_cndmask_b32_e64 v16, -4, v16, s[8:9]
	v_cndmask_b32_e64 v17, -4, v17, s[10:11]
	v_cndmask_b32_e64 v18, -4, v18, s[12:13]
	v_cndmask_b32_e64 v19, -4, v19, s[14:15]
	buffer_store_dwordx4 v[12:15], v7, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v20, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v9, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v11, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v16, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v17, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v18, s[20:23], 0 offen
	buffer_store_dwordx4 v[12:15], v19, s[20:23], 0 offen
	s_cbranch_scc1 .LBB0_4
	s_cmp_lg_u32 s27, 0
	s_cselect_b64 s[4:5], -1, 0
.LBB0_6:
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccz .LBB0_9
	s_mul_i32 s4, s28, s3
	s_add_i32 s33, s33, s4
	v_add_u32_e32 v1, s33, v0
	v_add_u32_e32 v1, 0xfffff800, v1
	s_lshl_b32 s4, s19, 12
	v_mov_b32_e32 v4, 0
	v_lshlrev_b32_e32 v2, 4, v1
	s_addk_i32 s4, 0x8000
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v6, v4
	v_mov_b32_e32 v7, v4
.LBB0_8:
	v_cmp_gt_i32_e32 vcc, s18, v1
	s_add_i32 s27, s27, -1
	v_add_u32_e32 v1, s3, v1
	v_cndmask_b32_e32 v3, -4, v2, vcc
	v_add_u32_e32 v2, s4, v2
	s_cmp_lg_u32 s27, 0
	buffer_store_dwordx4 v[4:7], v3, s[20:23], 0 offen
	s_cbranch_scc1 .LBB0_8
.LBB0_9:
	s_cmp_gt_i32 s2, 7
	s_cbranch_scc1 .LBB0_37
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[4:5], vcc
	v_mov_b32_e32 v1, 0
	ds_write_b32 v1, v1
	s_or_b64 exec, exec, s[4:5]
	s_load_dwordx2 s[28:29], s[0:1], 0x0
	v_cmp_gt_u32_e32 vcc, 8, v0
	s_mov_b32 s31, 0x27000
	s_mov_b32 s30, -1
	v_cndmask_b32_e32 v1, 0, v0, vcc
	s_waitcnt lgkmcnt(0)
	s_and_b32 s29, s29, 0xffff
	v_add_lshl_u32 v1, s26, v1, 2
	buffer_load_dword v2, v1, s[28:31], 0 offen
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshrrev_b32_e32 v6, 6, v0
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e32 v2, 0, v2, vcc
	v_add_u32_e32 v3, 31, v2
	v_ashrrev_i32_e32 v4, 31, v3
	v_lshrrev_b32_e32 v4, 27, v4
	v_add_u32_e32 v4, v3, v4
	v_ashrrev_i32_e32 v5, 5, v4
	v_and_b32_e32 v4, 0xffffffe0, v4
	v_cmp_gt_i32_e32 vcc, 0, v3
	v_cmp_ne_u32_e64 s[4:5], v3, v4
	s_and_b64 vcc, vcc, s[4:5]
	v_subbrev_co_u32_e32 v3, vcc, 0, v5, vcc
	v_lshlrev_b32_e32 v3, 5, v3
	v_cmp_ne_u32_e32 vcc, 0, v2
	v_and_b32_e32 v4, 63, v0
	v_cmp_eq_u32_e64 s[16:17], 63, v4
	v_cndmask_b32_e32 v2, 0, v3, vcc
	ds_write_b32 v1, v2 offset:4
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v7, v1 offset:4
	s_waitcnt lgkmcnt(0)
	s_nop 0
	v_add_u32_dpp v2, v7, v7 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v2, v2, v2 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v2, v2, v2 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v2, v2, v2 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v2, v2, v2 row_bcast:15 row_mask:0xa bank_mask:0xf
	s_nop 1
	v_add_u32_dpp v2, v2, v2 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_mov_b32_e32 v5, v2
	s_nop 1
	v_mov_b32_dpp v5, v5 wave_shr:1 row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[4:5], s[16:17]
	v_lshlrev_b32_e32 v3, 2, v6
	ds_write_b32 v3, v2 offset:1028
	s_or_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v2, 0x40c
	v_cmp_eq_u32_e64 s[4:5], 0, v4
	v_mov_b32_e32 v4, 0x404
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[2:3], v2 offset1:1
	v_cndmask_b32_e64 v8, v5, 0, s[4:5]
	ds_read2_b32 v[4:5], v4 offset1:1
	v_cmp_eq_u32_e64 s[6:7], 3, v6
	v_cmp_eq_u32_e64 s[10:11], 0, v6
	s_movk_i32 s3, 0x7f
	s_waitcnt lgkmcnt(1)
	v_cndmask_b32_e64 v9, 0, v2, s[6:7]
	s_waitcnt lgkmcnt(0)
	v_cndmask_b32_e64 v11, v4, 0, s[10:11]
	v_cmp_lt_u32_e64 s[8:9], s3, v0
	v_add_u32_e32 v9, v11, v9
	v_add_u32_e32 v7, v9, v7
	v_cndmask_b32_e64 v10, 0, v5, s[8:9]
	v_add3_u32 v7, v7, v8, v10
	s_lshl_b32 s3, s2, 2
	ds_write_b32 v1, v7 offset:4
	v_mov_b32_e32 v7, s3
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[8:9], v7 offset1:1
	v_or_b32_e32 v7, s2, v0
	v_cmp_eq_u32_e32 vcc, 0, v7
	s_waitcnt lgkmcnt(0)
	v_readfirstlane_b32 s27, v8
	v_readfirstlane_b32 s26, v9
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB0_16
	s_load_dwordx2 s[20:21], s[0:1], 0x58
	v_add_u32_e32 v2, v5, v2
	v_add_u32_e32 v2, v2, v4
	s_mov_b32 s23, 0x27000
	s_mov_b32 s22, -1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s21, s21, 0xffff
	v_add_u32_e32 v2, v2, v3
	v_mov_b32_e32 v3, s24
	buffer_store_dwordx2 v[2:3], off, s[20:23], 0
.LBB0_16:
	s_or_b64 exec, exec, s[12:13]
	s_ashr_i32 s12, s27, 31
	s_lshr_b32 s12, s12, 27
	s_add_i32 s18, s27, s12
	s_ashr_i32 s12, s26, 31
	s_lshr_b32 s12, s12, 27
	s_add_i32 s19, s26, s12
	s_ashr_i32 s22, s18, 5
	s_ashr_i32 s23, s19, 5
	s_cmp_lt_i32 s26, 0
	s_cselect_b64 s[12:13], -1, 0
	s_cmp_lt_i32 s27, 0
	s_cselect_b64 s[14:15], -1, 0
	s_and_b32 s20, s18, 0xffffffe0
	s_andn2_b32 s19, s19, 31
	s_cmp_lg_u32 s26, s19
	s_cselect_b64 s[18:19], -1, 0
	s_cmp_lg_u32 s27, s20
	s_cselect_b64 s[20:21], -1, 0
	s_and_b64 s[20:21], s[14:15], s[20:21]
	s_and_b64 s[12:13], s[12:13], s[18:19]
	s_subb_u32 s14, s23, 0
	s_cmp_lg_u64 s[20:21], 0
	s_subb_u32 s20, s22, 0
	s_cmp_lg_u64 s[12:13], 0
	s_subb_u32 s18, s23, s20
	s_cmp_lt_i32 s18, 1
	ds_write_b32 v1, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_scc1 .LBB0_24
	s_load_dwordx2 s[12:13], s[0:1], 0x48
	v_mov_b32_e32 v2, s3
	ds_read_b32 v11, v2
	s_and_b32 s3, s18, 7
	s_sub_i32 s14, s20, s14
	s_waitcnt lgkmcnt(0)
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s15, 0x27000
	s_cmp_gt_u32 s14, -8
	s_mov_b32 s14, -1
	s_cbranch_scc1 .LBB0_21
	v_mov_b32_e32 v10, v11
	v_mov_b32_e32 v12, v11
	s_and_b32 s18, s18, 0x7ffffff8
	s_lshl2_add_u32 s19, s20, 16
	s_mov_b32 s21, 0
	v_mov_b32_e32 v8, v10
	v_mov_b32_e32 v9, v11
	v_mov_b32_e32 v10, v12
.LBB0_19:
	s_add_i32 s22, s19, -16
	s_add_i32 s23, s19, -12
	s_add_i32 s33, s19, -8
	s_add_i32 s34, s19, -4
	v_mov_b32_e32 v2, s19
	s_add_i32 s21, s21, 8
	s_add_i32 s19, s19, 32
	v_mov_b32_e32 v3, s22
	s_cmp_lg_u32 s18, s21
	v_mov_b32_e32 v4, s23
	v_mov_b32_e32 v5, s33
	v_mov_b32_e32 v7, s34
	buffer_store_dword v11, v3, s[12:15], 0 offen
	buffer_store_dword v11, v4, s[12:15], 0 offen
	buffer_store_dword v11, v5, s[12:15], 0 offen
	buffer_store_dword v11, v7, s[12:15], 0 offen
	buffer_store_dwordx4 v[8:11], v2, s[12:15], 0 offen
	s_cbranch_scc1 .LBB0_19
	s_cmp_lg_u32 s3, 0
	s_cselect_b64 s[18:19], -1, 0
	s_and_b64 vcc, exec, s[18:19]
	s_cbranch_vccnz .LBB0_22
	s_branch .LBB0_24
.LBB0_21:
	s_mov_b32 s21, 0
	s_cbranch_execz .LBB0_24
.LBB0_22:
	s_add_i32 s20, s20, s21
	s_lshl_b32 s18, s20, 2
.LBB0_23:
	v_mov_b32_e32 v2, s18
	s_add_i32 s18, s18, 4
	s_add_i32 s3, s3, -1
	s_cmp_lg_u32 s3, 0
	buffer_store_dword v11, v2, s[12:15], 0 offen
	s_cbranch_scc1 .LBB0_23
.LBB0_24:
	s_load_dwordx2 s[36:37], s[0:1], 0x28
	s_load_dwordx2 s[40:41], s[0:1], 0x38
	s_ashr_i32 s33, s25, 2
	s_add_i32 s3, s33, 0xff
	s_ashr_i32 s12, s3, 31
	s_lshr_b32 s12, s12, 24
	s_add_i32 s12, s3, s12
	s_waitcnt lgkmcnt(0)
	s_and_b32 s37, s37, 0xffff
	s_and_b32 s41, s41, 0xffff
	s_ashr_i32 s18, s12, 8
	s_and_b32 s12, s12, 0xffffff00
	s_cmp_lg_u32 s3, s12
	s_cselect_b64 s[12:13], -1, 0
	s_cmpk_lt_i32 s33, 0xff01
	s_cselect_b64 s[14:15], -1, 0
	s_and_b64 s[12:13], s[14:15], s[12:13]
	s_subb_u32 s3, s18, 0
	s_cmp_lg_u32 s27, s26
	s_cselect_b32 s22, s3, 0
	s_mov_b32 s47, 0x27000
	s_cmp_lt_i32 s22, 1
	s_mov_b32 s46, -1
	s_cbranch_scc1 .LBB0_29
	s_load_dwordx2 s[44:45], s[0:1], 0x10
	s_movk_i32 s0, 0x404
	s_mul_i32 s25, s25, s2
	s_ashr_i32 s23, s22, 31
	v_lshl_add_u32 v2, v6, 2, s0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s45, s45, 0xffff
	v_lshl_add_u32 v3, v0, 5, -4
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, 0xff000000
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v1
	s_branch .LBB0_27
	.p2align	5
.LBB0_26:
	s_or_b64 exec, exec, s[2:3]
	v_lshl_add_u32 v20, v13, 2, v3
	v_lshlrev_b32_e32 v21, 2, v14
	v_lshlrev_b32_e32 v22, 2, v12
	v_lshlrev_b32_e32 v23, 2, v11
	v_cndmask_b32_e64 v20, 0, v20, s[14:15]
	v_add3_u32 v21, v3, v21, 8
	v_add3_u32 v22, v3, v22, 16
	v_add3_u32 v23, v3, v23, 24
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v18, v4 offset:1028
	ds_read_b64 v[16:17], v4 offset:1032
	ds_read_b32 v19, v4 offset:1040
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_cndmask_b32_e64 v21, 0, v21, s[12:13]
	v_cndmask_b32_e32 v22, 0, v22, vcc
	v_cndmask_b32_e64 v23, 0, v23, s[0:1]
	buffer_load_dword v24, v20, s[44:47], 0 offen
	buffer_load_dword v25, v21, s[44:47], 0 offen
	buffer_load_dword v26, v22, s[44:47], 0 offen
	buffer_load_dword v27, v23, s[44:47], 0 offen
	v_readfirstlane_b32 s3, v17
	v_readfirstlane_b32 s2, v16
	v_cndmask_b32_e64 v16, v18, 0, s[10:11]
	v_readfirstlane_b32 s18, v18
	v_mov_b32_e32 v18, s3
	v_mov_b32_e32 v17, s2
	v_add_u32_e32 v16, s27, v16
	s_add_i32 s3, s3, s27
	v_cndmask_b32_e64 v18, 0, v18, s[6:7]
	v_cndmask_b32_e64 v15, v15, 0, s[4:5]
	v_cndmask_b32_e64 v17, 0, v17, s[8:9]
	s_add_i32 s2, s3, s2
	v_add_u32_e32 v16, v16, v18
	v_lshl_add_u32 v13, v13, 24, v5
	v_readfirstlane_b32 s19, v19
	s_add_i32 s2, s2, s18
	v_add3_u32 v15, v16, v15, v17
	v_cndmask_b32_e64 v13, 0, v13, s[14:15]
	s_add_i32 s27, s2, s19
	v_add_u32_e32 v10, v15, v10
	v_lshlrev_b32_e32 v15, 2, v15
	v_lshl_add_u32 v14, v14, 24, v5
	v_lshl_add_u32 v12, v12, 24, v5
	s_mov_b32 s38, s46
	s_mov_b32 s39, s47
	v_or_b32_e32 v13, v13, v7
	s_add_u32 s22, s22, -1
	v_add_u32_e32 v9, v10, v9
	v_cndmask_b32_e64 v15, -4, v15, s[14:15]
	v_add_u32_e32 v20, 1, v7
	v_add_u32_e32 v21, 2, v7
	v_lshl_add_u32 v11, v11, 24, v5
	v_cndmask_b32_e64 v14, 0, v14, s[12:13]
	v_cndmask_b32_e32 v12, 0, v12, vcc
	v_lshlrev_b32_e32 v10, 2, v10
	s_addc_u32 s23, s23, -1
	buffer_store_dword v13, v15, s[36:39], 0 offen
	v_lshlrev_b32_e32 v13, 2, v9
	v_add_u32_e32 v22, 3, v7
	v_cndmask_b32_e64 v11, 0, v11, s[0:1]
	v_add_u32_e32 v3, 0x2000, v3
	v_or_b32_e32 v14, v14, v20
	v_or_b32_e32 v12, v12, v21
	v_add_u32_e32 v7, 0x400, v7
	v_cndmask_b32_e64 v10, -4, v10, s[12:13]
	v_add_lshl_u32 v8, v9, v8, 2
	s_cmp_lg_u64 s[22:23], 0
	v_cndmask_b32_e32 v9, -4, v13, vcc
	v_add_u32_e32 v6, 0x100, v6
	s_mov_b32 s42, s46
	s_mov_b32 s43, s47
	v_or_b32_e32 v11, v11, v22
	buffer_store_dword v14, v10, s[36:39], 0 offen
	v_cndmask_b32_e64 v8, -4, v8, s[0:1]
	buffer_store_dword v12, v9, s[36:39], 0 offen
	buffer_store_dword v11, v8, s[36:39], 0 offen
	s_waitcnt vmcnt(7)
	buffer_store_dword v24, v15, s[40:43], 0 offen
	s_waitcnt vmcnt(7)
	buffer_store_dword v25, v10, s[40:43], 0 offen
	s_waitcnt vmcnt(7)
	buffer_store_dword v26, v9, s[40:43], 0 offen
	s_waitcnt vmcnt(7)
	buffer_store_dword v27, v8, s[40:43], 0 offen
	s_cbranch_scc0 .LBB0_29
.LBB0_27:
	v_cmp_gt_i32_e64 s[0:1], s33, v6
	s_nop 1
	v_cndmask_b32_e64 v8, 0, v7, s[0:1]
	v_add_u32_e32 v8, s25, v8
	v_and_b32_e32 v8, -4, v8
	buffer_load_dword v8, v8, s[28:31], 0 offen
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v13, 0xff, v8
	v_bfe_u32 v14, v8, 8, 8
	v_bfe_u32 v12, v8, 16, 8
	v_lshrrev_b32_e32 v11, 24, v8
	v_cmp_ne_u32_e32 vcc, 0, v13
	v_cmp_ne_u32_e64 s[2:3], 0, v14
	v_cmp_ne_u32_e64 s[18:19], 0, v12
	v_cmp_ne_u32_e64 s[20:21], 0, v11
	s_and_b64 s[14:15], s[0:1], vcc
	v_cndmask_b32_e64 v10, 0, 1, s[14:15]
	s_and_b64 s[12:13], s[0:1], s[2:3]
	s_and_b64 vcc, s[0:1], s[18:19]
	s_and_b64 s[0:1], s[0:1], s[20:21]
	v_cndmask_b32_e64 v9, 0, 1, s[12:13]
	v_addc_co_u32_e64 v15, s[2:3], 0, v10, s[0:1]
	v_addc_co_u32_e64 v15, s[2:3], v15, v9, vcc
	v_cndmask_b32_e64 v8, 0, 1, vcc
	s_nop 0
	v_add_u32_dpp v15, v15, v15 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v15, v15, v15 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v15, v15, v15 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v16, v15, v15 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_u32_dpp v16, v16, v16 row_bcast:15 row_mask:0xa bank_mask:0xf
	s_nop 1
	v_add_u32_dpp v16, v16, v16 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_mov_b32_e32 v15, v16
	s_nop 1
	v_mov_b32_dpp v15, v15 wave_shr:1 row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[2:3], s[16:17]
	s_cbranch_execz .LBB0_26
	ds_write_b32 v2, v16
	s_branch .LBB0_26
.LBB0_29:
	s_sub_i32 s0, s26, s27
	s_add_i32 s2, s0, 0xff
	s_ashr_i32 s0, s2, 31
	s_lshr_b32 s0, s0, 24
	s_add_i32 s0, s2, s0
	s_ashr_i32 s4, s0, 8
	s_and_b32 s0, s0, 0xffffff00
	s_cmp_lg_u32 s2, s0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lt_i32 s2, 0
	s_cselect_b64 s[2:3], -1, 0
	s_and_b64 s[0:1], s[2:3], s[0:1]
	s_subb_u32 s2, s4, 0
	s_cmp_lt_i32 s2, 1
	s_mov_b32 s14, 0
	s_cbranch_scc1 .LBB0_37
	s_or_b32 s13, s24, 0x2000000
	s_add_i32 s0, s2, -1
	s_and_b32 s12, s2, 7
	s_cmp_lt_u32 s0, 7
	s_mov_b64 s[0:1], -1
	s_cbranch_scc1 .LBB0_34
	v_add_u32_e32 v2, s27, v0
	s_and_b32 s15, s2, 0x7ffffff8
	v_add_u32_e32 v2, 0x400, v2
	s_lshl_b32 s16, s27, 2
	s_mov_b32 s38, s46
	s_mov_b32 s39, s47
	v_mov_b32_e32 v4, s13
	s_mov_b32 s42, s46
	s_mov_b32 s43, s47
	v_mov_b32_e32 v3, 0
	.p2align	5, , 4
.LBB0_32:
	v_add_u32_e32 v5, 0xfffffc00, v2
	v_add_u32_e32 v6, s16, v1
	v_add_u32_e32 v7, 0xfffffd00, v2
	v_cmp_gt_i32_e32 vcc, s26, v5
	v_add_u32_e32 v8, 0xfffffe00, v2
	v_add_u32_e32 v9, 0xffffff00, v2
	v_add_u32_e32 v10, 0x100, v2
	v_add_u32_e32 v11, 0x200, v2
	v_add_u32_e32 v12, 0x300, v2
	s_add_i32 s14, s14, 8
	v_cndmask_b32_e32 v5, -4, v6, vcc
	v_add_u32_e32 v13, 0x400, v6
	v_cmp_gt_i32_e32 vcc, s26, v7
	v_add_u32_e32 v1, 0x2000, v1
	v_add_u32_e32 v7, 0x800, v6
	v_cmp_gt_i32_e64 s[0:1], s26, v8
	v_add_u32_e32 v8, 0xc00, v6
	v_cmp_gt_i32_e64 s[2:3], s26, v9
	v_add_u32_e32 v9, 0x1000, v6
	v_cmp_gt_i32_e64 s[4:5], s26, v2
	v_add_u32_e32 v14, 0x1400, v6
	v_cmp_gt_i32_e64 s[6:7], s26, v10
	v_add_u32_e32 v10, 0x1800, v6
	v_cmp_gt_i32_e64 s[8:9], s26, v11
	v_add_u32_e32 v6, 0x1c00, v6
	v_cmp_gt_i32_e64 s[10:11], s26, v12
	v_add_u32_e32 v2, 0x800, v2
	s_cmp_lg_u32 s15, s14
	buffer_store_dword v4, v5, s[36:39], 0 offen
	buffer_store_dword v3, v5, s[40:43], 0 offen
	v_cndmask_b32_e32 v5, -4, v13, vcc
	v_cndmask_b32_e64 v7, -4, v7, s[0:1]
	v_cndmask_b32_e64 v8, -4, v8, s[2:3]
	v_cndmask_b32_e64 v9, -4, v9, s[4:5]
	v_cndmask_b32_e64 v11, -4, v14, s[6:7]
	v_cndmask_b32_e64 v10, -4, v10, s[8:9]
	v_cndmask_b32_e64 v6, -4, v6, s[10:11]
	buffer_store_dword v4, v5, s[36:39], 0 offen
	buffer_store_dword v3, v5, s[40:43], 0 offen
	buffer_store_dword v4, v7, s[36:39], 0 offen
	buffer_store_dword v3, v7, s[40:43], 0 offen
	buffer_store_dword v4, v8, s[36:39], 0 offen
	buffer_store_dword v3, v8, s[40:43], 0 offen
	buffer_store_dword v4, v9, s[36:39], 0 offen
	buffer_store_dword v3, v9, s[40:43], 0 offen
	buffer_store_dword v4, v11, s[36:39], 0 offen
	buffer_store_dword v3, v11, s[40:43], 0 offen
	buffer_store_dword v4, v10, s[36:39], 0 offen
	buffer_store_dword v3, v10, s[40:43], 0 offen
	buffer_store_dword v4, v6, s[36:39], 0 offen
	buffer_store_dword v3, v6, s[40:43], 0 offen
	s_cbranch_scc1 .LBB0_32
	s_cmp_lg_u32 s12, 0
	s_cselect_b64 s[0:1], -1, 0
.LBB0_34:
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccz .LBB0_37
	s_lshl_b32 s0, s14, 8
	s_add_i32 s0, s0, s27
	v_add_u32_e32 v0, s0, v0
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s38, s46
	s_mov_b32 s39, s47
	v_mov_b32_e32 v3, s13
	s_mov_b32 s42, s46
	s_mov_b32 s43, s47
	v_mov_b32_e32 v2, 0
.LBB0_36:
	v_cmp_gt_i32_e32 vcc, s26, v0
	s_add_i32 s12, s12, -1
	v_add_u32_e32 v0, 0x100, v0
	v_cndmask_b32_e32 v4, -4, v1, vcc
	v_add_u32_e32 v1, 0x400, v1
	s_cmp_lg_u32 s12, 0
	buffer_store_dword v3, v4, s[36:39], 0 offen
	buffer_store_dword v2, v4, s[40:43], 0 offen
	s_cbranch_scc1 .LBB0_36
.LBB0_37:
	s_endpgm
.Lfunc_end0:
	.size	p23_kernel_0, .Lfunc_end0-p23_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel p23_kernel_0
		.amdhsa_group_segment_fixed_size 1044
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 408
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
		.amdhsa_next_free_vgpr 28
		.amdhsa_next_free_sgpr 48
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
	.text

	.set .Lp23_kernel_0.num_vgpr, 28
	.set .Lp23_kernel_0.num_agpr, 0
	.set .Lp23_kernel_0.numbered_sgpr, 48
	.set .Lp23_kernel_0.num_named_barrier, 0
	.set .Lp23_kernel_0.private_seg_size, 0
	.set .Lp23_kernel_0.uses_vcc, 1
	.set .Lp23_kernel_0.uses_flat_scratch, 0
	.set .Lp23_kernel_0.has_dyn_sized_stack, 0
	.set .Lp23_kernel_0.has_recursion, 0
	.set .Lp23_kernel_0.has_indirect_call, 0
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
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           4
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
      - .address_space:  global
        .offset:         120
        .size:           8
        .value_kind:     global_buffer
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
    .group_segment_fixed_size: 1044
    .kernarg_segment_align: 8
    .kernarg_segment_size: 408
    .max_flat_workgroup_size: 256
    .name:           p23_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         p23_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     28
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
