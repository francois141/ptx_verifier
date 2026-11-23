; MIOpen rocm-7.2.4 src/kernels/UniversalTranspose.cl (UniversalTranspose), include/miopen/utility/transposing_solver.hpp:UniversalTransposeSolver, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case transpose_nhwc_nchw).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	UniversalTranspose
	.globl	UniversalTranspose
	.p2align	8
	.type	UniversalTranspose,@function
UniversalTranspose:
	s_load_dwordx16 s[4:19], s[0:1], 0x0
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s16, s15
	s_mul_hi_u32 s20, s16, s14
	s_add_i32 s26, s20, s3
	s_mul_i32 s3, s17, s14
	s_mul_i32 s27, s16, s14
	s_add_i32 s26, s26, s3
	s_mul_i32 s3, s27, s13
	s_mul_hi_u32 s20, s27, s12
	s_add_i32 s28, s20, s3
	s_mul_i32 s3, s26, s12
	s_mul_i32 s29, s27, s12
	s_add_i32 s28, s28, s3
	s_mul_i32 s20, s29, s11
	s_mul_hi_u32 s21, s29, s10
	s_mul_i32 s3, s28, s10
	s_add_i32 s30, s21, s20
	s_mul_i32 s31, s29, s10
	s_add_i32 s30, s30, s3
	s_mul_i32 s9, s31, s9
	s_mul_hi_u32 s20, s31, s8
	s_mul_i32 s3, s30, s8
	s_add_i32 s9, s20, s9
	s_add_i32 s9, s9, s3
	s_mul_i32 s8, s31, s8
	v_cmp_gt_u64_e32 vcc, s[8:9], v[0:1]
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB0_31
	s_load_dword s3, s[0:1], 0x88
	s_add_u32 s20, s0, 0x88
	s_addc_u32 s21, s1, 0
	v_cvt_f32_u32_e32 v4, s31
	v_cvt_f32_u32_e32 v5, s30
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s3
	s_cselect_b32 s2, 12, 18
	s_add_u32 s2, s20, s2
	s_addc_u32 s3, s21, 0
	global_load_ushort v3, v2, s[2:3]
	v_fmac_f32_e32 v4, 0x4f800000, v5
	v_rcp_f32_e32 v4, v4
	s_load_dwordx2 s[20:21], s[0:1], 0x80
	s_load_dwordx16 s[36:51], s[0:1], 0x40
	s_mov_b64 s[22:23], 0
	v_mul_f32_e32 v4, 0x5f7ffffc, v4
	v_mul_f32_e32 v5, 0x2f800000, v4
	v_trunc_f32_e32 v5, v5
	v_fmac_f32_e32 v4, 0xcf800000, v5
	v_cvt_u32_f32_e32 v16, v5
	v_cvt_u32_f32_e32 v17, v4
	v_mov_b32_e32 v5, v2
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v4, 0xffff, v3
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[0:1]
	v_mul_lo_u32 v3, v13, s16
	v_mul_lo_u32 v18, v12, s17
	v_mad_u64_u32 v[12:13], s[0:1], v12, s16, 0
	v_add3_u32 v3, v13, v18, v3
	v_sub_co_u32_e32 v26, vcc, v0, v12
	v_mul_lo_u32 v18, v7, s18
	v_mul_lo_u32 v19, v6, s19
	v_mad_u64_u32 v[12:13], s[0:1], v6, s18, 0
	v_add3_u32 v13, v13, v19, v18
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v20, v9, s36
	v_mul_lo_u32 v21, v8, s37
	v_mad_u64_u32 v[18:19], s[0:1], v8, s36, 0
	v_add3_u32 v19, v19, v21, v20
	v_mul_lo_u32 v22, v11, s38
	v_mul_lo_u32 v23, v10, s39
	v_mad_u64_u32 v[20:21], s[0:1], v10, s38, 0
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[4:5]
	v_subb_co_u32_e32 v3, vcc, v1, v3, vcc
	v_add3_u32 v21, v21, v23, v22
	v_mul_lo_u32 v24, v15, s40
	v_mul_lo_u32 v25, v14, s41
	v_mad_u64_u32 v[22:23], s[0:1], v14, s40, 0
	v_lshl_add_u64 v[12:13], v[18:19], 2, v[12:13]
	v_add3_u32 v23, v23, v25, v24
	v_mul_lo_u32 v27, v3, s42
	v_mul_lo_u32 v28, v26, s43
	v_mad_u64_u32 v[24:25], s[0:1], v26, s42, 0
	v_lshl_add_u64 v[12:13], v[20:21], 2, v[12:13]
	v_add3_u32 v25, v25, v28, v27
	v_lshl_add_u64 v[12:13], v[22:23], 2, v[12:13]
	v_lshl_add_u64 v[12:13], v[24:25], 2, v[12:13]
	global_load_dword v18, v[12:13], off
	v_mul_lo_u32 v12, v7, s44
	v_mul_lo_u32 v13, v6, s45
	v_mad_u64_u32 v[6:7], s[0:1], v6, s44, 0
	v_add3_u32 v7, v7, v13, v12
	v_mul_lo_u32 v12, v9, s46
	v_mul_lo_u32 v13, v8, s47
	v_mad_u64_u32 v[8:9], s[0:1], v8, s46, 0
	v_add3_u32 v9, v9, v13, v12
	v_mul_lo_u32 v12, v11, s48
	v_mul_lo_u32 v13, v10, s49
	v_mad_u64_u32 v[10:11], s[0:1], v10, s48, 0
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[6:7]
	v_add3_u32 v11, v11, v13, v12
	v_mul_lo_u32 v15, v15, s50
	v_mul_lo_u32 v19, v14, s51
	v_mad_u64_u32 v[12:13], s[0:1], v14, s50, 0
	v_lshl_add_u64 v[6:7], v[8:9], 2, v[6:7]
	v_add3_u32 v13, v13, v19, v15
	v_mul_lo_u32 v3, v3, s20
	v_mul_lo_u32 v19, v26, s21
	v_mad_u64_u32 v[14:15], s[0:1], v26, s20, 0
	v_lshl_add_u64 v[6:7], v[10:11], 2, v[6:7]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	v_add3_u32 v15, v15, v19, v3
	v_lshl_add_u64 v[6:7], v[12:13], 2, v[6:7]
	v_cmp_le_u64_e32 vcc, s[8:9], v[0:1]
	v_lshl_add_u64 v[6:7], v[14:15], 2, v[6:7]
	s_or_b64 s[22:23], vcc, s[22:23]
	s_waitcnt vmcnt(0)
	global_store_dword v[6:7], v18, off
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execz .LBB0_31
.LBB0_3:
	v_or_b32_e32 v3, s30, v1
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[2:3], exec, s[0:1]
	s_cbranch_execz .LBB0_5
	s_sub_u32 s0, 0, s31
	s_subb_u32 s1, 0, s30
	v_mul_hi_u32 v6, s0, v17
	v_mul_lo_u32 v7, s0, v16
	v_mul_lo_u32 v3, s1, v17
	v_add_u32_e32 v6, v6, v7
	v_add_u32_e32 v3, v6, v3
	v_mul_lo_u32 v10, s0, v17
	v_mul_hi_u32 v7, v17, v3
	v_mul_lo_u32 v6, v17, v3
	v_mul_hi_u32 v8, v17, v10
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[6:7], v[8:9], 0, v[6:7]
	v_mul_hi_u32 v9, v16, v10
	v_mul_lo_u32 v10, v16, v10
	v_add_co_u32_e32 v6, vcc, v6, v10
	v_mul_hi_u32 v8, v16, v3
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v7, v9, vcc
	v_mov_b32_e32 v7, v2
	s_nop 0
	v_addc_co_u32_e32 v9, vcc, 0, v8, vcc
	v_mul_lo_u32 v8, v16, v3
	v_lshl_add_u64 v[6:7], v[6:7], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v17, v6
	v_mul_lo_u32 v8, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v16, v7, vcc
	v_mul_lo_u32 v6, s0, v10
	v_mul_hi_u32 v7, s0, v3
	v_add_u32_e32 v6, v7, v6
	v_mul_lo_u32 v7, s1, v3
	v_add_u32_e32 v11, v6, v7
	v_mul_hi_u32 v13, v10, v8
	v_mul_lo_u32 v14, v10, v8
	v_mul_hi_u32 v7, v3, v11
	v_mul_lo_u32 v6, v3, v11
	v_mul_hi_u32 v8, v3, v8
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[6:7], v[8:9], 0, v[6:7]
	v_add_co_u32_e32 v6, vcc, v6, v14
	v_mul_hi_u32 v12, v10, v11
	s_nop 0
	v_addc_co_u32_e32 v6, vcc, v7, v13, vcc
	v_mul_lo_u32 v8, v10, v11
	s_nop 0
	v_addc_co_u32_e32 v9, vcc, 0, v12, vcc
	v_mov_b32_e32 v7, v2
	v_lshl_add_u64 v[6:7], v[6:7], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v3, v6
	v_mul_hi_u32 v8, v0, v3
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v10, v7, vcc
	v_mad_u64_u32 v[6:7], s[0:1], v0, v10, 0
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[6:7], v[8:9], 0, v[6:7]
	v_mad_u64_u32 v[8:9], s[0:1], v1, v10, 0
	v_mad_u64_u32 v[10:11], s[0:1], v1, v3, 0
	v_add_co_u32_e32 v3, vcc, v6, v10
	s_nop 1
	v_addc_co_u32_e32 v6, vcc, v7, v11, vcc
	v_mov_b32_e32 v7, v2
	s_nop 0
	v_addc_co_u32_e32 v9, vcc, 0, v9, vcc
	v_lshl_add_u64 v[6:7], v[6:7], 0, v[8:9]
	v_mul_lo_u32 v3, s30, v6
	v_mul_lo_u32 v10, s31, v7
	v_mad_u64_u32 v[8:9], s[0:1], s31, v6, 0
	v_add3_u32 v3, v9, v10, v3
	v_sub_u32_e32 v9, v1, v3
	v_mov_b32_e32 v10, s30
	v_sub_co_u32_e32 v12, vcc, v0, v8
	s_nop 1
	v_subb_co_u32_e64 v8, s[0:1], v9, v10, vcc
	v_subrev_co_u32_e64 v9, s[0:1], s31, v12
	v_subb_co_u32_e32 v3, vcc, v1, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v8, s[0:1], 0, v8, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s30, v8
	v_cmp_le_u32_e32 vcc, s30, v3
	s_nop 0
	v_cndmask_b32_e64 v10, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s31, v9
	s_nop 1
	v_cndmask_b32_e64 v9, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s30, v8
	s_nop 1
	v_cndmask_b32_e64 v13, v10, v9, s[0:1]
	v_lshl_add_u64 v[8:9], v[6:7], 0, 2
	v_lshl_add_u64 v[10:11], v[6:7], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v13
	s_nop 1
	v_cndmask_b32_e64 v9, v11, v9, s[0:1]
	v_cndmask_b32_e64 v11, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s31, v12
	s_nop 1
	v_cndmask_b32_e64 v12, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s30, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v11, v12, vcc
	v_cmp_ne_u32_e32 vcc, 0, v3
	v_cndmask_b32_e64 v3, v10, v8, s[0:1]
	s_nop 0
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_cndmask_b32_e32 v6, v6, v3, vcc
.LBB0_5:
	s_andn2_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_7
	v_cvt_f32_u32_e32 v3, s31
	s_sub_i32 s2, 0, s31
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v6, s2, v3
	v_mul_hi_u32 v6, v3, v6
	v_add_u32_e32 v3, v3, v6
	v_mul_hi_u32 v3, v0, v3
	v_mul_lo_u32 v6, v3, s31
	v_sub_u32_e32 v6, v0, v6
	v_add_u32_e32 v7, 1, v3
	v_subrev_u32_e32 v8, s31, v6
	v_cmp_le_u32_e32 vcc, s31, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v6, v8, vcc
	v_cndmask_b32_e32 v3, v3, v7, vcc
	v_add_u32_e32 v7, 1, v3
	v_cmp_le_u32_e32 vcc, s31, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v3, v7, vcc
	v_mov_b32_e32 v7, v2
.LBB0_7:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s28, v1
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[2:3], exec, s[0:1]
	s_cbranch_execz .LBB0_9
	v_cvt_f32_u32_e32 v3, s29
	v_cvt_f32_u32_e32 v8, s28
	s_sub_u32 s0, 0, s29
	s_subb_u32 s1, 0, s28
	v_fmac_f32_e32 v3, 0x4f800000, v8
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v8, 0x2f800000, v3
	v_trunc_f32_e32 v8, v8
	v_fmac_f32_e32 v3, 0xcf800000, v8
	v_cvt_u32_f32_e32 v12, v8
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v8, s0, v12
	v_mul_hi_u32 v10, s0, v3
	v_mul_lo_u32 v9, s1, v3
	v_add_u32_e32 v10, v10, v8
	v_mul_lo_u32 v13, s0, v3
	v_add_u32_e32 v14, v10, v9
	v_mul_hi_u32 v8, v3, v13
	v_mul_hi_u32 v11, v3, v14
	v_mul_lo_u32 v10, v3, v14
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[10:11]
	v_mul_hi_u32 v11, v12, v13
	v_mul_lo_u32 v13, v12, v13
	v_add_co_u32_e32 v8, vcc, v8, v13
	v_mul_hi_u32 v10, v12, v14
	s_nop 0
	v_addc_co_u32_e32 v8, vcc, v9, v11, vcc
	v_mov_b32_e32 v9, v2
	s_nop 0
	v_addc_co_u32_e32 v11, vcc, 0, v10, vcc
	v_mul_lo_u32 v10, v12, v14
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[10:11]
	v_add_co_u32_e32 v3, vcc, v3, v8
	v_mul_lo_u32 v10, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v12, vcc, v12, v9, vcc
	v_mul_lo_u32 v8, s0, v12
	v_mul_hi_u32 v9, s0, v3
	v_add_u32_e32 v8, v9, v8
	v_mul_lo_u32 v9, s1, v3
	v_add_u32_e32 v13, v8, v9
	v_mul_hi_u32 v15, v12, v10
	v_mul_lo_u32 v18, v12, v10
	v_mul_hi_u32 v9, v3, v13
	v_mul_lo_u32 v8, v3, v13
	v_mul_hi_u32 v10, v3, v10
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[8:9], v[10:11], 0, v[8:9]
	v_add_co_u32_e32 v8, vcc, v8, v18
	v_mul_hi_u32 v14, v12, v13
	s_nop 0
	v_addc_co_u32_e32 v8, vcc, v9, v15, vcc
	v_mul_lo_u32 v10, v12, v13
	s_nop 0
	v_addc_co_u32_e32 v11, vcc, 0, v14, vcc
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[10:11]
	v_add_co_u32_e32 v3, vcc, v3, v8
	v_mul_hi_u32 v10, v0, v3
	s_nop 0
	v_addc_co_u32_e32 v12, vcc, v12, v9, vcc
	v_mad_u64_u32 v[8:9], s[0:1], v0, v12, 0
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[8:9], v[10:11], 0, v[8:9]
	v_mad_u64_u32 v[10:11], s[0:1], v1, v12, 0
	v_mad_u64_u32 v[12:13], s[0:1], v1, v3, 0
	v_add_co_u32_e32 v3, vcc, v8, v12
	s_nop 1
	v_addc_co_u32_e32 v8, vcc, v9, v13, vcc
	v_mov_b32_e32 v9, v2
	s_nop 0
	v_addc_co_u32_e32 v11, vcc, 0, v11, vcc
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[10:11]
	v_mul_lo_u32 v3, s28, v8
	v_mul_lo_u32 v12, s29, v9
	v_mad_u64_u32 v[10:11], s[0:1], s29, v8, 0
	v_add3_u32 v3, v11, v12, v3
	v_sub_u32_e32 v11, v1, v3
	v_mov_b32_e32 v12, s28
	v_sub_co_u32_e32 v14, vcc, v0, v10
	s_nop 1
	v_subb_co_u32_e64 v10, s[0:1], v11, v12, vcc
	v_subrev_co_u32_e64 v11, s[0:1], s29, v14
	v_subb_co_u32_e32 v3, vcc, v1, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v10, s[0:1], 0, v10, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s28, v10
	v_cmp_le_u32_e32 vcc, s28, v3
	s_nop 0
	v_cndmask_b32_e64 v12, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s29, v11
	s_nop 1
	v_cndmask_b32_e64 v11, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s28, v10
	s_nop 1
	v_cndmask_b32_e64 v15, v12, v11, s[0:1]
	v_lshl_add_u64 v[10:11], v[8:9], 0, 2
	v_lshl_add_u64 v[12:13], v[8:9], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v15
	s_nop 1
	v_cndmask_b32_e64 v11, v13, v11, s[0:1]
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s29, v14
	s_nop 1
	v_cndmask_b32_e64 v14, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s28, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v13, v14, vcc
	v_cmp_ne_u32_e32 vcc, 0, v3
	v_cndmask_b32_e64 v3, v12, v10, s[0:1]
	s_nop 0
	v_cndmask_b32_e32 v11, v9, v11, vcc
	v_cndmask_b32_e32 v10, v8, v3, vcc
.LBB0_9:
	s_andn2_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_11
	v_cvt_f32_u32_e32 v3, s29
	s_sub_i32 s2, 0, s29
	v_mov_b32_e32 v11, v2
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v8, s2, v3
	v_mul_hi_u32 v8, v3, v8
	v_add_u32_e32 v3, v3, v8
	v_mul_hi_u32 v3, v0, v3
	v_mul_lo_u32 v8, v3, s29
	v_sub_u32_e32 v8, v0, v8
	v_add_u32_e32 v9, 1, v3
	v_subrev_u32_e32 v10, s29, v8
	v_cmp_le_u32_e32 vcc, s29, v8
	s_nop 1
	v_cndmask_b32_e32 v8, v8, v10, vcc
	v_cndmask_b32_e32 v3, v3, v9, vcc
	v_add_u32_e32 v9, 1, v3
	v_cmp_le_u32_e32 vcc, s29, v8
	s_nop 1
	v_cndmask_b32_e32 v10, v3, v9, vcc
.LBB0_11:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s11, v11
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[24:25], exec, s[0:1]
	s_cbranch_execz .LBB0_13
	v_cvt_f32_u32_e32 v3, s10
	v_cvt_f32_u32_e32 v8, s11
	s_sub_u32 s0, 0, s10
	s_subb_u32 s1, 0, s11
	v_fmac_f32_e32 v3, 0x4f800000, v8
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v8, 0x2f800000, v3
	v_trunc_f32_e32 v8, v8
	v_fmac_f32_e32 v3, 0xcf800000, v8
	v_cvt_u32_f32_e32 v14, v8
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v8, s0, v14
	v_mul_hi_u32 v12, s0, v3
	v_mul_lo_u32 v9, s1, v3
	v_add_u32_e32 v12, v12, v8
	v_mul_lo_u32 v15, s0, v3
	v_add_u32_e32 v18, v12, v9
	v_mul_hi_u32 v8, v3, v15
	v_mul_hi_u32 v13, v3, v18
	v_mul_lo_u32 v12, v3, v18
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_mul_hi_u32 v13, v14, v15
	v_mul_lo_u32 v15, v14, v15
	v_add_co_u32_e32 v8, vcc, v8, v15
	v_mul_hi_u32 v12, v14, v18
	s_nop 0
	v_addc_co_u32_e32 v8, vcc, v9, v13, vcc
	v_mov_b32_e32 v9, v2
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v12, vcc
	v_mul_lo_u32 v12, v14, v18
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_add_co_u32_e32 v3, vcc, v3, v8
	v_mul_lo_u32 v12, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v14, v9, vcc
	v_mul_lo_u32 v8, s0, v14
	v_mul_hi_u32 v9, s0, v3
	v_add_u32_e32 v8, v9, v8
	v_mul_lo_u32 v9, s1, v3
	v_add_u32_e32 v15, v8, v9
	v_mul_hi_u32 v19, v14, v12
	v_mul_lo_u32 v20, v14, v12
	v_mul_hi_u32 v9, v3, v15
	v_mul_lo_u32 v8, v3, v15
	v_mul_hi_u32 v12, v3, v12
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[8:9], v[12:13], 0, v[8:9]
	v_add_co_u32_e32 v8, vcc, v8, v20
	v_mul_hi_u32 v18, v14, v15
	s_nop 0
	v_addc_co_u32_e32 v8, vcc, v9, v19, vcc
	v_mul_lo_u32 v12, v14, v15
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v18, vcc
	v_mov_b32_e32 v9, v2
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_add_co_u32_e32 v3, vcc, v3, v8
	v_mul_hi_u32 v12, v10, v3
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v14, v9, vcc
	v_mad_u64_u32 v[8:9], s[0:1], v10, v14, 0
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[8:9], v[12:13], 0, v[8:9]
	v_mad_u64_u32 v[12:13], s[0:1], v11, v14, 0
	v_mad_u64_u32 v[14:15], s[0:1], v11, v3, 0
	v_add_co_u32_e32 v3, vcc, v8, v14
	s_nop 1
	v_addc_co_u32_e32 v8, vcc, v9, v15, vcc
	v_mov_b32_e32 v9, v2
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v13, vcc
	v_lshl_add_u64 v[8:9], v[8:9], 0, v[12:13]
	v_mul_lo_u32 v3, s11, v8
	v_mul_lo_u32 v12, s10, v9
	v_mad_u64_u32 v[8:9], s[0:1], s10, v8, 0
	v_add3_u32 v3, v9, v12, v3
	v_sub_u32_e32 v9, v11, v3
	v_mov_b32_e32 v12, s11
	v_sub_co_u32_e32 v8, vcc, v10, v8
	s_nop 1
	v_subb_co_u32_e64 v9, s[0:1], v9, v12, vcc
	v_subrev_co_u32_e64 v10, s[0:1], s10, v8
	v_subb_co_u32_e32 v3, vcc, v11, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v13, s[2:3], 0, v9, s[0:1]
	v_cmp_le_u32_e64 s[2:3], s11, v13
	v_subb_co_u32_e64 v9, s[0:1], v9, v12, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v14, 0, -1, s[2:3]
	v_cmp_le_u32_e64 s[2:3], s10, v10
	v_subrev_co_u32_e64 v12, s[0:1], s10, v10
	s_nop 0
	v_cndmask_b32_e64 v15, 0, -1, s[2:3]
	v_cmp_eq_u32_e64 s[2:3], s11, v13
	v_subbrev_co_u32_e64 v9, s[0:1], 0, v9, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v14, v14, v15, s[2:3]
	v_cmp_le_u32_e32 vcc, s11, v3
	v_cmp_ne_u32_e64 s[0:1], 0, v14
	s_nop 0
	v_cndmask_b32_e64 v11, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s10, v8
	v_cndmask_b32_e64 v9, v13, v9, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s11, v3
	s_nop 1
	v_cndmask_b32_e32 v11, v11, v13, vcc
	v_cmp_ne_u32_e32 vcc, 0, v11
	s_nop 1
	v_cndmask_b32_e32 v9, v3, v9, vcc
	v_cndmask_b32_e64 v3, v10, v12, s[0:1]
	v_cndmask_b32_e32 v8, v8, v3, vcc
.LBB0_13:
	s_andn2_saveexec_b64 s[0:1], s[24:25]
	s_cbranch_execz .LBB0_15
	v_cvt_f32_u32_e32 v3, s10
	s_sub_i32 s2, 0, s10
	v_mov_b32_e32 v9, v2
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v8, s2, v3
	v_mul_hi_u32 v8, v3, v8
	v_add_u32_e32 v3, v3, v8
	v_mul_hi_u32 v3, v10, v3
	v_mul_lo_u32 v3, v3, s10
	v_sub_u32_e32 v3, v10, v3
	v_subrev_u32_e32 v8, s10, v3
	v_cmp_le_u32_e32 vcc, s10, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v8, vcc
	v_subrev_u32_e32 v8, s10, v3
	v_cmp_le_u32_e32 vcc, s10, v3
	s_nop 1
	v_cndmask_b32_e32 v8, v3, v8, vcc
.LBB0_15:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s26, v1
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[2:3], exec, s[0:1]
	s_cbranch_execz .LBB0_17
	v_cvt_f32_u32_e32 v3, s27
	v_cvt_f32_u32_e32 v10, s26
	s_sub_u32 s0, 0, s27
	s_subb_u32 s1, 0, s26
	v_fmac_f32_e32 v3, 0x4f800000, v10
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v10, 0x2f800000, v3
	v_trunc_f32_e32 v10, v10
	v_fmac_f32_e32 v3, 0xcf800000, v10
	v_cvt_u32_f32_e32 v14, v10
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v10, s0, v14
	v_mul_hi_u32 v12, s0, v3
	v_mul_lo_u32 v11, s1, v3
	v_add_u32_e32 v12, v12, v10
	v_mul_lo_u32 v15, s0, v3
	v_add_u32_e32 v18, v12, v11
	v_mul_hi_u32 v10, v3, v15
	v_mul_hi_u32 v13, v3, v18
	v_mul_lo_u32 v12, v3, v18
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[12:13]
	v_mul_hi_u32 v13, v14, v15
	v_mul_lo_u32 v15, v14, v15
	v_add_co_u32_e32 v10, vcc, v10, v15
	v_mul_hi_u32 v12, v14, v18
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v11, v13, vcc
	v_mov_b32_e32 v11, v2
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v12, vcc
	v_mul_lo_u32 v12, v14, v18
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[12:13]
	v_add_co_u32_e32 v3, vcc, v3, v10
	v_mul_lo_u32 v12, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v14, v11, vcc
	v_mul_lo_u32 v10, s0, v14
	v_mul_hi_u32 v11, s0, v3
	v_add_u32_e32 v10, v11, v10
	v_mul_lo_u32 v11, s1, v3
	v_add_u32_e32 v15, v10, v11
	v_mul_hi_u32 v19, v14, v12
	v_mul_lo_u32 v20, v14, v12
	v_mul_hi_u32 v11, v3, v15
	v_mul_lo_u32 v10, v3, v15
	v_mul_hi_u32 v12, v3, v12
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[10:11], v[12:13], 0, v[10:11]
	v_add_co_u32_e32 v10, vcc, v10, v20
	v_mul_hi_u32 v18, v14, v15
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v11, v19, vcc
	v_mul_lo_u32 v12, v14, v15
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v18, vcc
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[12:13]
	v_add_co_u32_e32 v3, vcc, v3, v10
	v_mul_hi_u32 v12, v0, v3
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v14, v11, vcc
	v_mad_u64_u32 v[10:11], s[0:1], v0, v14, 0
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[10:11], v[12:13], 0, v[10:11]
	v_mad_u64_u32 v[12:13], s[0:1], v1, v14, 0
	v_mad_u64_u32 v[14:15], s[0:1], v1, v3, 0
	v_add_co_u32_e32 v3, vcc, v10, v14
	s_nop 1
	v_addc_co_u32_e32 v10, vcc, v11, v15, vcc
	v_mov_b32_e32 v11, v2
	s_nop 0
	v_addc_co_u32_e32 v13, vcc, 0, v13, vcc
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[12:13]
	v_mul_lo_u32 v3, s26, v10
	v_mul_lo_u32 v14, s27, v11
	v_mad_u64_u32 v[12:13], s[0:1], s27, v10, 0
	v_add3_u32 v3, v13, v14, v3
	v_sub_u32_e32 v13, v1, v3
	v_mov_b32_e32 v14, s26
	v_sub_co_u32_e32 v18, vcc, v0, v12
	s_nop 1
	v_subb_co_u32_e64 v12, s[0:1], v13, v14, vcc
	v_subrev_co_u32_e64 v13, s[0:1], s27, v18
	v_subb_co_u32_e32 v3, vcc, v1, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v12, s[0:1], 0, v12, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s26, v12
	v_cmp_le_u32_e32 vcc, s26, v3
	s_nop 0
	v_cndmask_b32_e64 v14, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s27, v13
	s_nop 1
	v_cndmask_b32_e64 v13, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s26, v12
	s_nop 1
	v_cndmask_b32_e64 v19, v14, v13, s[0:1]
	v_lshl_add_u64 v[12:13], v[10:11], 0, 2
	v_lshl_add_u64 v[14:15], v[10:11], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v19
	s_nop 1
	v_cndmask_b32_e64 v13, v15, v13, s[0:1]
	v_cndmask_b32_e64 v15, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s27, v18
	s_nop 1
	v_cndmask_b32_e64 v18, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s26, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v15, v18, vcc
	v_cmp_ne_u32_e32 vcc, 0, v3
	v_cndmask_b32_e64 v3, v14, v12, s[0:1]
	s_nop 0
	v_cndmask_b32_e32 v13, v11, v13, vcc
	v_cndmask_b32_e32 v12, v10, v3, vcc
.LBB0_17:
	s_andn2_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_19
	v_cvt_f32_u32_e32 v3, s27
	s_sub_i32 s2, 0, s27
	v_mov_b32_e32 v13, v2
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v10, s2, v3
	v_mul_hi_u32 v10, v3, v10
	v_add_u32_e32 v3, v3, v10
	v_mul_hi_u32 v3, v0, v3
	v_mul_lo_u32 v10, v3, s27
	v_sub_u32_e32 v10, v0, v10
	v_add_u32_e32 v11, 1, v3
	v_subrev_u32_e32 v12, s27, v10
	v_cmp_le_u32_e32 vcc, s27, v10
	s_nop 1
	v_cndmask_b32_e32 v10, v10, v12, vcc
	v_cndmask_b32_e32 v3, v3, v11, vcc
	v_add_u32_e32 v11, 1, v3
	v_cmp_le_u32_e32 vcc, s27, v10
	s_nop 1
	v_cndmask_b32_e32 v12, v3, v11, vcc
.LBB0_19:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s13, v13
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[24:25], exec, s[0:1]
	s_cbranch_execz .LBB0_21
	v_cvt_f32_u32_e32 v3, s12
	v_cvt_f32_u32_e32 v10, s13
	s_sub_u32 s0, 0, s12
	s_subb_u32 s1, 0, s13
	v_fmac_f32_e32 v3, 0x4f800000, v10
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v10, 0x2f800000, v3
	v_trunc_f32_e32 v10, v10
	v_fmac_f32_e32 v3, 0xcf800000, v10
	v_cvt_u32_f32_e32 v18, v10
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v10, s0, v18
	v_mul_hi_u32 v14, s0, v3
	v_mul_lo_u32 v11, s1, v3
	v_add_u32_e32 v14, v14, v10
	v_mul_lo_u32 v19, s0, v3
	v_add_u32_e32 v20, v14, v11
	v_mul_hi_u32 v10, v3, v19
	v_mul_hi_u32 v15, v3, v20
	v_mul_lo_u32 v14, v3, v20
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[14:15]
	v_mul_hi_u32 v15, v18, v19
	v_mul_lo_u32 v19, v18, v19
	v_add_co_u32_e32 v10, vcc, v10, v19
	v_mul_hi_u32 v14, v18, v20
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v11, v15, vcc
	v_mov_b32_e32 v11, v2
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v14, vcc
	v_mul_lo_u32 v14, v18, v20
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[14:15]
	v_add_co_u32_e32 v3, vcc, v3, v10
	v_mul_lo_u32 v14, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v18, vcc, v18, v11, vcc
	v_mul_lo_u32 v10, s0, v18
	v_mul_hi_u32 v11, s0, v3
	v_add_u32_e32 v10, v11, v10
	v_mul_lo_u32 v11, s1, v3
	v_add_u32_e32 v19, v10, v11
	v_mul_hi_u32 v21, v18, v14
	v_mul_lo_u32 v22, v18, v14
	v_mul_hi_u32 v11, v3, v19
	v_mul_lo_u32 v10, v3, v19
	v_mul_hi_u32 v14, v3, v14
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[10:11], v[14:15], 0, v[10:11]
	v_add_co_u32_e32 v10, vcc, v10, v22
	v_mul_hi_u32 v20, v18, v19
	s_nop 0
	v_addc_co_u32_e32 v10, vcc, v11, v21, vcc
	v_mul_lo_u32 v14, v18, v19
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v20, vcc
	v_mov_b32_e32 v11, v2
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[14:15]
	v_add_co_u32_e32 v3, vcc, v3, v10
	v_mul_hi_u32 v14, v12, v3
	s_nop 0
	v_addc_co_u32_e32 v18, vcc, v18, v11, vcc
	v_mad_u64_u32 v[10:11], s[0:1], v12, v18, 0
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[10:11], v[14:15], 0, v[10:11]
	v_mad_u64_u32 v[14:15], s[0:1], v13, v18, 0
	v_mad_u64_u32 v[18:19], s[0:1], v13, v3, 0
	v_add_co_u32_e32 v3, vcc, v10, v18
	s_nop 1
	v_addc_co_u32_e32 v10, vcc, v11, v19, vcc
	v_mov_b32_e32 v11, v2
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v15, vcc
	v_lshl_add_u64 v[10:11], v[10:11], 0, v[14:15]
	v_mul_lo_u32 v3, s13, v10
	v_mul_lo_u32 v14, s12, v11
	v_mad_u64_u32 v[10:11], s[0:1], s12, v10, 0
	v_add3_u32 v3, v11, v14, v3
	v_sub_u32_e32 v11, v13, v3
	v_mov_b32_e32 v14, s13
	v_sub_co_u32_e32 v10, vcc, v12, v10
	s_nop 1
	v_subb_co_u32_e64 v11, s[0:1], v11, v14, vcc
	v_subrev_co_u32_e64 v12, s[0:1], s12, v10
	v_subb_co_u32_e32 v3, vcc, v13, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v15, s[2:3], 0, v11, s[0:1]
	v_cmp_le_u32_e64 s[2:3], s13, v15
	v_subb_co_u32_e64 v11, s[0:1], v11, v14, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v18, 0, -1, s[2:3]
	v_cmp_le_u32_e64 s[2:3], s12, v12
	v_subrev_co_u32_e64 v14, s[0:1], s12, v12
	s_nop 0
	v_cndmask_b32_e64 v19, 0, -1, s[2:3]
	v_cmp_eq_u32_e64 s[2:3], s13, v15
	v_subbrev_co_u32_e64 v11, s[0:1], 0, v11, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v18, v18, v19, s[2:3]
	v_cmp_le_u32_e32 vcc, s13, v3
	v_cmp_ne_u32_e64 s[0:1], 0, v18
	s_nop 0
	v_cndmask_b32_e64 v13, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s12, v10
	v_cndmask_b32_e64 v11, v15, v11, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v15, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s13, v3
	s_nop 1
	v_cndmask_b32_e32 v13, v13, v15, vcc
	v_cmp_ne_u32_e32 vcc, 0, v13
	s_nop 1
	v_cndmask_b32_e32 v11, v3, v11, vcc
	v_cndmask_b32_e64 v3, v12, v14, s[0:1]
	v_cndmask_b32_e32 v10, v10, v3, vcc
.LBB0_21:
	s_andn2_saveexec_b64 s[0:1], s[24:25]
	s_cbranch_execz .LBB0_23
	v_cvt_f32_u32_e32 v3, s12
	s_sub_i32 s2, 0, s12
	v_mov_b32_e32 v11, v2
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v10, s2, v3
	v_mul_hi_u32 v10, v3, v10
	v_add_u32_e32 v3, v3, v10
	v_mul_hi_u32 v3, v12, v3
	v_mul_lo_u32 v3, v3, s12
	v_sub_u32_e32 v3, v12, v3
	v_subrev_u32_e32 v10, s12, v3
	v_cmp_le_u32_e32 vcc, s12, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v10, vcc
	v_subrev_u32_e32 v10, s12, v3
	v_cmp_le_u32_e32 vcc, s12, v3
	s_nop 1
	v_cndmask_b32_e32 v10, v3, v10, vcc
.LBB0_23:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s17, v1
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[2:3], exec, s[0:1]
	s_cbranch_execz .LBB0_25
	v_cvt_f32_u32_e32 v3, s16
	v_cvt_f32_u32_e32 v12, s17
	s_sub_u32 s0, 0, s16
	s_subb_u32 s1, 0, s17
	v_fmac_f32_e32 v3, 0x4f800000, v12
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v12, 0x2f800000, v3
	v_trunc_f32_e32 v12, v12
	v_fmac_f32_e32 v3, 0xcf800000, v12
	v_cvt_u32_f32_e32 v18, v12
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v12, s0, v18
	v_mul_hi_u32 v14, s0, v3
	v_mul_lo_u32 v13, s1, v3
	v_add_u32_e32 v14, v14, v12
	v_mul_lo_u32 v19, s0, v3
	v_add_u32_e32 v20, v14, v13
	v_mul_hi_u32 v12, v3, v19
	v_mul_hi_u32 v15, v3, v20
	v_mul_lo_u32 v14, v3, v20
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_mul_hi_u32 v15, v18, v19
	v_mul_lo_u32 v19, v18, v19
	v_add_co_u32_e32 v12, vcc, v12, v19
	v_mul_hi_u32 v14, v18, v20
	s_nop 0
	v_addc_co_u32_e32 v12, vcc, v13, v15, vcc
	v_mov_b32_e32 v13, v2
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v14, vcc
	v_mul_lo_u32 v14, v18, v20
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_add_co_u32_e32 v3, vcc, v3, v12
	v_mul_lo_u32 v14, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v18, vcc, v18, v13, vcc
	v_mul_lo_u32 v12, s0, v18
	v_mul_hi_u32 v13, s0, v3
	v_add_u32_e32 v12, v13, v12
	v_mul_lo_u32 v13, s1, v3
	v_add_u32_e32 v19, v12, v13
	v_mul_hi_u32 v21, v18, v14
	v_mul_lo_u32 v22, v18, v14
	v_mul_hi_u32 v13, v3, v19
	v_mul_lo_u32 v12, v3, v19
	v_mul_hi_u32 v14, v3, v14
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[12:13], v[14:15], 0, v[12:13]
	v_add_co_u32_e32 v12, vcc, v12, v22
	v_mul_hi_u32 v20, v18, v19
	s_nop 0
	v_addc_co_u32_e32 v12, vcc, v13, v21, vcc
	v_mul_lo_u32 v14, v18, v19
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v20, vcc
	v_mov_b32_e32 v13, v2
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_add_co_u32_e32 v3, vcc, v3, v12
	v_mul_hi_u32 v14, v0, v3
	s_nop 0
	v_addc_co_u32_e32 v18, vcc, v18, v13, vcc
	v_mad_u64_u32 v[12:13], s[0:1], v0, v18, 0
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[12:13], v[14:15], 0, v[12:13]
	v_mad_u64_u32 v[14:15], s[0:1], v1, v18, 0
	v_mad_u64_u32 v[18:19], s[0:1], v1, v3, 0
	v_add_co_u32_e32 v3, vcc, v12, v18
	s_nop 1
	v_addc_co_u32_e32 v12, vcc, v13, v19, vcc
	v_mov_b32_e32 v13, v2
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v15, vcc
	v_lshl_add_u64 v[12:13], v[12:13], 0, v[14:15]
	v_mul_lo_u32 v3, s17, v12
	v_mul_lo_u32 v18, s16, v13
	v_mad_u64_u32 v[14:15], s[0:1], s16, v12, 0
	v_add3_u32 v3, v15, v18, v3
	v_sub_u32_e32 v15, v1, v3
	v_mov_b32_e32 v18, s17
	v_sub_co_u32_e32 v20, vcc, v0, v14
	s_nop 1
	v_subb_co_u32_e64 v14, s[0:1], v15, v18, vcc
	v_subrev_co_u32_e64 v15, s[0:1], s16, v20
	v_subb_co_u32_e32 v3, vcc, v1, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v14, s[0:1], 0, v14, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s17, v14
	v_cmp_le_u32_e32 vcc, s17, v3
	s_nop 0
	v_cndmask_b32_e64 v18, 0, -1, s[0:1]
	v_cmp_le_u32_e64 s[0:1], s16, v15
	s_nop 1
	v_cndmask_b32_e64 v15, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], s17, v14
	s_nop 1
	v_cndmask_b32_e64 v21, v18, v15, s[0:1]
	v_lshl_add_u64 v[14:15], v[12:13], 0, 2
	v_lshl_add_u64 v[18:19], v[12:13], 0, 1
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	s_nop 1
	v_cndmask_b32_e64 v15, v19, v15, s[0:1]
	v_cndmask_b32_e64 v19, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s16, v20
	s_nop 1
	v_cndmask_b32_e64 v20, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s17, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v19, v20, vcc
	v_cmp_ne_u32_e32 vcc, 0, v3
	v_cndmask_b32_e64 v3, v18, v14, s[0:1]
	s_nop 0
	v_cndmask_b32_e32 v13, v13, v15, vcc
	v_cndmask_b32_e32 v12, v12, v3, vcc
.LBB0_25:
	s_andn2_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_27
	v_cvt_f32_u32_e32 v3, s16
	s_sub_i32 s2, 0, s16
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v12, s2, v3
	v_mul_hi_u32 v12, v3, v12
	v_add_u32_e32 v3, v3, v12
	v_mul_hi_u32 v3, v0, v3
	v_mul_lo_u32 v12, v3, s16
	v_sub_u32_e32 v12, v0, v12
	v_add_u32_e32 v13, 1, v3
	v_subrev_u32_e32 v14, s16, v12
	v_cmp_le_u32_e32 vcc, s16, v12
	s_nop 1
	v_cndmask_b32_e32 v12, v12, v14, vcc
	v_cndmask_b32_e32 v3, v3, v13, vcc
	v_add_u32_e32 v13, 1, v3
	v_cmp_le_u32_e32 vcc, s16, v12
	s_nop 1
	v_cndmask_b32_e32 v12, v3, v13, vcc
	v_mov_b32_e32 v13, v2
.LBB0_27:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v3, s15, v13
	v_cmp_ne_u64_e32 vcc, 0, v[2:3]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[24:25], exec, s[0:1]
	s_cbranch_execz .LBB0_29
	v_cvt_f32_u32_e32 v3, s14
	v_cvt_f32_u32_e32 v14, s15
	s_sub_u32 s0, 0, s14
	s_subb_u32 s1, 0, s15
	v_fmac_f32_e32 v3, 0x4f800000, v14
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v14, 0x2f800000, v3
	v_trunc_f32_e32 v14, v14
	v_fmac_f32_e32 v3, 0xcf800000, v14
	v_cvt_u32_f32_e32 v20, v14
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v14, s0, v20
	v_mul_hi_u32 v18, s0, v3
	v_mul_lo_u32 v15, s1, v3
	v_add_u32_e32 v18, v18, v14
	v_mul_lo_u32 v21, s0, v3
	v_add_u32_e32 v22, v18, v15
	v_mul_hi_u32 v14, v3, v21
	v_mul_hi_u32 v19, v3, v22
	v_mul_lo_u32 v18, v3, v22
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[14:15], v[14:15], 0, v[18:19]
	v_mul_hi_u32 v19, v20, v21
	v_mul_lo_u32 v21, v20, v21
	v_add_co_u32_e32 v14, vcc, v14, v21
	v_mul_hi_u32 v18, v20, v22
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v15, v19, vcc
	v_mov_b32_e32 v15, v2
	s_nop 0
	v_addc_co_u32_e32 v19, vcc, 0, v18, vcc
	v_mul_lo_u32 v18, v20, v22
	v_lshl_add_u64 v[14:15], v[14:15], 0, v[18:19]
	v_add_co_u32_e32 v3, vcc, v3, v14
	v_mul_lo_u32 v18, s0, v3
	s_nop 0
	v_addc_co_u32_e32 v20, vcc, v20, v15, vcc
	v_mul_lo_u32 v14, s0, v20
	v_mul_hi_u32 v15, s0, v3
	v_add_u32_e32 v14, v15, v14
	v_mul_lo_u32 v15, s1, v3
	v_add_u32_e32 v21, v14, v15
	v_mul_hi_u32 v23, v20, v18
	v_mul_lo_u32 v24, v20, v18
	v_mul_hi_u32 v15, v3, v21
	v_mul_lo_u32 v14, v3, v21
	v_mul_hi_u32 v18, v3, v18
	v_mov_b32_e32 v19, v2
	v_lshl_add_u64 v[14:15], v[18:19], 0, v[14:15]
	v_add_co_u32_e32 v14, vcc, v14, v24
	v_mul_hi_u32 v22, v20, v21
	s_nop 0
	v_addc_co_u32_e32 v14, vcc, v15, v23, vcc
	v_mul_lo_u32 v18, v20, v21
	s_nop 0
	v_addc_co_u32_e32 v19, vcc, 0, v22, vcc
	v_mov_b32_e32 v15, v2
	v_lshl_add_u64 v[14:15], v[14:15], 0, v[18:19]
	v_add_co_u32_e32 v3, vcc, v3, v14
	v_mul_hi_u32 v18, v12, v3
	s_nop 0
	v_addc_co_u32_e32 v20, vcc, v20, v15, vcc
	v_mad_u64_u32 v[14:15], s[0:1], v12, v20, 0
	v_mov_b32_e32 v19, v2
	v_lshl_add_u64 v[14:15], v[18:19], 0, v[14:15]
	v_mad_u64_u32 v[18:19], s[0:1], v13, v20, 0
	v_mad_u64_u32 v[20:21], s[0:1], v13, v3, 0
	v_add_co_u32_e32 v3, vcc, v14, v20
	s_nop 1
	v_addc_co_u32_e32 v14, vcc, v15, v21, vcc
	v_mov_b32_e32 v15, v2
	s_nop 0
	v_addc_co_u32_e32 v19, vcc, 0, v19, vcc
	v_lshl_add_u64 v[14:15], v[14:15], 0, v[18:19]
	v_mul_lo_u32 v3, s15, v14
	v_mul_lo_u32 v18, s14, v15
	v_mad_u64_u32 v[14:15], s[0:1], s14, v14, 0
	v_add3_u32 v3, v15, v18, v3
	v_sub_u32_e32 v15, v13, v3
	v_mov_b32_e32 v18, s15
	v_sub_co_u32_e32 v14, vcc, v12, v14
	s_nop 1
	v_subb_co_u32_e64 v15, s[0:1], v15, v18, vcc
	v_subrev_co_u32_e64 v19, s[0:1], s14, v14
	v_subb_co_u32_e32 v3, vcc, v13, v3, vcc
	s_nop 0
	v_subbrev_co_u32_e64 v20, s[2:3], 0, v15, s[0:1]
	v_cmp_le_u32_e64 s[2:3], s15, v20
	v_subb_co_u32_e64 v15, s[0:1], v15, v18, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v21, 0, -1, s[2:3]
	v_cmp_le_u32_e64 s[2:3], s14, v19
	v_subrev_co_u32_e64 v18, s[0:1], s14, v19
	s_nop 0
	v_cndmask_b32_e64 v22, 0, -1, s[2:3]
	v_cmp_eq_u32_e64 s[2:3], s15, v20
	v_subbrev_co_u32_e64 v15, s[0:1], 0, v15, s[0:1]
	s_nop 0
	v_cndmask_b32_e64 v21, v21, v22, s[2:3]
	v_cmp_ne_u32_e64 s[0:1], 0, v21
	v_cmp_le_u32_e32 vcc, s15, v3
	s_nop 0
	v_cndmask_b32_e64 v15, v20, v15, s[0:1]
	v_cndmask_b32_e64 v20, 0, -1, vcc
	v_cmp_le_u32_e32 vcc, s14, v14
	s_nop 1
	v_cndmask_b32_e64 v21, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, s15, v3
	s_nop 1
	v_cndmask_b32_e32 v20, v20, v21, vcc
	v_cmp_ne_u32_e32 vcc, 0, v20
	s_nop 1
	v_cndmask_b32_e32 v15, v3, v15, vcc
	v_cndmask_b32_e64 v3, v19, v18, s[0:1]
	v_cndmask_b32_e32 v14, v14, v3, vcc
.LBB0_29:
	s_andn2_saveexec_b64 s[0:1], s[24:25]
	s_cbranch_execz .LBB0_2
	v_cvt_f32_u32_e32 v3, s14
	s_sub_i32 s2, 0, s14
	v_mov_b32_e32 v15, v2
	v_rcp_iflag_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v14, s2, v3
	v_mul_hi_u32 v14, v3, v14
	v_add_u32_e32 v3, v3, v14
	v_mul_hi_u32 v3, v12, v3
	v_mul_lo_u32 v3, v3, s14
	v_sub_u32_e32 v3, v12, v3
	v_subrev_u32_e32 v14, s14, v3
	v_cmp_le_u32_e32 vcc, s14, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v14, vcc
	v_subrev_u32_e32 v14, s14, v3
	v_cmp_le_u32_e32 vcc, s14, v3
	s_nop 1
	v_cndmask_b32_e32 v14, v3, v14, vcc
	s_branch .LBB0_2
.LBB0_31:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel UniversalTranspose
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 392
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
		.amdhsa_next_free_vgpr 29
		.amdhsa_next_free_sgpr 52
		.amdhsa_accum_offset 32
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
.Lfunc_end0:
	.size	UniversalTranspose, .Lfunc_end0-UniversalTranspose

	.set UniversalTranspose.num_vgpr, 29
	.set UniversalTranspose.num_agpr, 0
	.set UniversalTranspose.numbered_sgpr, 52
	.set UniversalTranspose.private_seg_size, 0
	.set UniversalTranspose.uses_vcc, 1
	.set UniversalTranspose.uses_flat_scratch, 0
	.set UniversalTranspose.has_dyn_sized_stack, 0
	.set UniversalTranspose.has_recursion, 0
	.set UniversalTranspose.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.ident	"Homebrew clang version 21.1.8"
	.ident	"AMD clang version 22.0.0git (https://github.com/RadeonOpenCompute/llvm-project roc-7.2.1 26084 f58b06dce1f9c15707c5f808fd002e18c2accf7e)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .name:           in
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           out
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           lens_n
        .offset:         16
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           lens_c
        .offset:         24
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           lens_d
        .offset:         32
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           lens_h
        .offset:         40
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           lens_w
        .offset:         48
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           in_strides_n
        .offset:         56
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           in_strides_c
        .offset:         64
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           in_strides_d
        .offset:         72
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           in_strides_h
        .offset:         80
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           in_strides_w
        .offset:         88
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           out_strides_n
        .offset:         96
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           out_strides_c
        .offset:         104
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           out_strides_d
        .offset:         112
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           out_strides_h
        .offset:         120
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .name:           out_strides_w
        .offset:         128
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         136
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         140
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         144
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         148
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         150
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         152
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         154
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         156
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         158
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         176
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         184
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         192
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         200
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 392
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           UniversalTranspose
    .private_segment_fixed_size: 0
    .sgpr_count:     58
    .sgpr_spill_count: 0
    .symbol:         UniversalTranspose.kd
    .uses_dynamic_stack: false
    .vgpr_count:     29
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
