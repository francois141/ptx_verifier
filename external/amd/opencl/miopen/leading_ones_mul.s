; MIOpen rocm-7.2.4 src/kernels/MIOpenTensorKernels.cl (OpTensorLeadingOnes), src/solver/tensorOp/OpTensorLeadingOnes.cpp:OpTensorLeadingOnes::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case leading_ones_mul).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	OpTensorLeadingOnes
	.globl	OpTensorLeadingOnes
	.p2align	8
	.type	OpTensorLeadingOnes,@function
OpTensorLeadingOnes:
	s_load_dwordx2 s[24:25], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_cmp_eq_u32 s25, 15
	s_cselect_b64 s[36:37], -1, 0
	s_cmp_lg_u32 s25, 15
	s_cselect_b64 s[34:35], -1, 0
	s_and_b64 vcc, exec, s[34:35]
	s_cbranch_vccz .LBB0_2
	v_mov_b32_e32 v2, s2
	s_cbranch_execz .LBB0_3
	s_branch .LBB0_4
.LBB0_2:
	v_mov_b32_e32 v2, s2
.LBB0_3:
	s_load_dword s3, s[0:1], 0x6c
	s_load_dword s4, s[0:1], 0x88
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s3, s2, s3
	s_add_i32 s3, s3, s4
	v_add_u32_e32 v2, s3, v0
.LBB0_4:
	s_load_dword s3, s[0:1], 0x38
	s_load_dwordx4 s[4:7], s[0:1], 0x40
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x10
	s_load_dwordx8 s[16:23], s[0:1], 0x18
	s_load_dwordx2 s[14:15], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_lshl_b64 s[4:5], s[4:5], 2
	s_add_u32 s26, s8, s4
	s_addc_u32 s27, s9, s5
	s_lshl_b64 s[4:5], s[6:7], 2
	s_add_u32 s28, s10, s4
	s_addc_u32 s29, s11, s5
	s_lshl_b64 s[4:5], s[14:15], 2
	s_add_u32 s30, s12, s4
	s_addc_u32 s31, s13, s5
	v_cmp_eq_f32_e64 s[4:5], s3, 0
	v_cmp_gt_i32_e64 s[14:15], s24, v2
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB0_20
	s_and_saveexec_b64 s[38:39], s[14:15]
	s_cbranch_execz .LBB0_19
	s_add_u32 s40, s0, 0x60
	s_addc_u32 s41, s1, 0
	s_and_b32 s4, 1, s25
	s_and_b32 s6, 2, s25
	s_cmp_eq_u32 s4, 1
	s_cselect_b64 s[4:5], -1, 0
	v_cndmask_b32_e64 v4, 0, 1, s[4:5]
	s_and_b64 s[4:5], s[4:5], exec
	s_cselect_b32 s33, s18, 1
	s_bitcmp1_b32 s25, 2
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lg_u32 s6, 0
	s_cselect_b64 s[4:5], -1, 0
	v_cndmask_b32_e64 v5, 0, 1, s[4:5]
	s_and_b64 s[4:5], s[4:5], exec
	s_cselect_b32 s4, s17, 1
	s_abs_i32 s48, s18
	v_cvt_f32_u32_e32 v1, s48
	s_abs_i32 s50, s33
	s_sub_i32 s6, 0, s48
	v_cvt_f32_u32_e32 v6, s50
	v_rcp_iflag_f32_e32 v3, v1
	s_abs_i32 s51, s17
	s_abs_i32 s53, s16
	v_rcp_iflag_f32_e32 v6, v6
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_cvt_f32_u32_e32 v9, s53
	v_mul_f32_e32 v6, 0x4f7ffffe, v6
	v_cvt_u32_f32_e32 v6, v6
	v_mul_lo_u32 v7, s6, v3
	v_mul_hi_u32 v7, v3, v7
	v_add_u32_e32 v3, v3, v7
	v_cvt_f32_u32_e32 v7, s51
	v_rcp_iflag_f32_e32 v9, v9
	s_sub_i32 s6, 0, s50
	v_mul_lo_u32 v8, s6, v6
	v_rcp_iflag_f32_e32 v7, v7
	v_mul_f32_e32 v9, 0x4f7ffffe, v9
	v_cvt_u32_f32_e32 v9, v9
	v_mul_hi_u32 v8, v6, v8
	v_mul_f32_e32 v7, 0x4f7ffffe, v7
	v_cvt_u32_f32_e32 v7, v7
	s_sub_i32 s6, 0, s51
	v_add_u32_e32 v6, v6, v8
	v_cndmask_b32_e64 v1, v0, 0, s[36:37]
	v_mul_lo_u32 v8, s6, v7
	v_mul_hi_u32 v8, v7, v8
	s_sub_i32 s6, 0, s53
	v_add_u32_e32 v7, v7, v8
	v_mul_lo_u32 v8, s6, v9
	v_mul_hi_u32 v8, v9, v8
	v_add_u32_e32 v8, v9, v8
	v_cndmask_b32_e64 v9, 0, 1, s[34:35]
	v_cmp_ne_u32_e64 s[8:9], 1, v4
	v_cndmask_b32_e64 v4, 0, 1, s[10:11]
	s_mul_i32 s49, s33, s4
	v_cmp_gt_i32_e64 s[4:5], s21, v1
	s_ashr_i32 s52, s33, 31
	s_mov_b64 s[42:43], 0
	v_cmp_ne_u32_e64 s[6:7], 1, v9
	v_mov_b32_e32 v9, 0
	v_cmp_ne_u32_e64 s[10:11], 1, v5
	v_cmp_ne_u32_e64 s[12:13], 1, v4
	v_mov_b32_e32 v4, v2
	s_branch .LBB0_8
.LBB0_7:
	s_or_b64 exec, exec, s[44:45]
	v_add_u32_e32 v4, 0x1000, v4
	v_cmp_le_i32_e32 vcc, s24, v4
	s_or_b64 s[42:43], vcc, s[42:43]
	s_andn2_b64 exec, exec, s[42:43]
	s_cbranch_execz .LBB0_19
.LBB0_8:
	s_and_b64 vcc, exec, s[6:7]
	s_waitcnt vmcnt(1)
	v_mov_b32_e32 v10, s21
	s_cbranch_vccnz .LBB0_10
	s_load_dword s44, s[40:41], 0x0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s44
	s_cselect_b32 s44, 12, 18
	s_add_u32 s44, s40, s44
	s_addc_u32 s45, s41, 0
	global_load_ushort v10, v9, s[44:45]
.LBB0_10:
	v_ashrrev_i32_e32 v5, 31, v4
	s_waitcnt vmcnt(0)
	v_lshl_add_u64 v[12:13], v[4:5], 2, s[28:29]
	global_load_dword v13, v[12:13], off
	v_sub_u32_e32 v11, 0, v4
	v_mov_b32_e32 v14, 0
	s_and_b64 vcc, exec, s[8:9]
	v_max_i32_e32 v11, v4, v11
	v_mov_b32_e32 v12, 0
	s_cbranch_vccz .LBB0_14
	s_mov_b32 s46, 1
	s_and_b64 vcc, exec, s[10:11]
	s_mov_b32 s44, 1
	s_cbranch_vccz .LBB0_15
.LBB0_12:
	s_and_b64 vcc, exec, s[12:13]
	v_mov_b32_e32 v15, 0
	s_cbranch_vccz .LBB0_16
.LBB0_13:
	s_and_saveexec_b64 s[44:45], s[4:5]
	s_cbranch_execz .LBB0_7
	s_branch .LBB0_17
.LBB0_14:
	v_mul_hi_u32 v12, v11, v3
	v_mul_lo_u32 v12, v12, s48
	v_sub_u32_e32 v12, v11, v12
	v_subrev_u32_e32 v15, s48, v12
	v_cmp_le_u32_e32 vcc, s48, v12
	s_nop 1
	v_cndmask_b32_e32 v12, v12, v15, vcc
	v_subrev_u32_e32 v15, s48, v12
	v_cmp_le_u32_e32 vcc, s48, v12
	s_nop 1
	v_cndmask_b32_e32 v12, v12, v15, vcc
	v_xor_b32_e32 v12, v12, v5
	v_sub_u32_e32 v12, v12, v5
	s_mov_b32 s46, 1
	s_and_b64 vcc, exec, s[10:11]
	s_mov_b32 s44, 1
	s_cbranch_vccnz .LBB0_12
.LBB0_15:
	v_mul_hi_u32 v14, v11, v6
	v_mul_lo_u32 v15, v14, s50
	v_sub_u32_e32 v15, v11, v15
	v_add_u32_e32 v16, 1, v14
	v_cmp_le_u32_e32 vcc, s50, v15
	v_xor_b32_e32 v5, s52, v5
	s_mov_b32 s44, s17
	v_cndmask_b32_e32 v14, v14, v16, vcc
	v_subrev_u32_e32 v16, s50, v15
	v_cndmask_b32_e32 v15, v15, v16, vcc
	v_add_u32_e32 v16, 1, v14
	v_cmp_le_u32_e32 vcc, s50, v15
	s_nop 1
	v_cndmask_b32_e32 v14, v14, v16, vcc
	v_xor_b32_e32 v14, v14, v5
	v_sub_u32_e32 v5, v14, v5
	v_sub_u32_e32 v15, 0, v5
	v_ashrrev_i32_e32 v14, 31, v5
	v_max_i32_e32 v5, v5, v15
	v_mul_hi_u32 v15, v5, v7
	v_mul_lo_u32 v15, v15, s51
	v_sub_u32_e32 v5, v5, v15
	v_subrev_u32_e32 v15, s51, v5
	v_cmp_le_u32_e32 vcc, s51, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v15, vcc
	v_subrev_u32_e32 v15, s51, v5
	v_cmp_le_u32_e32 vcc, s51, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v15, vcc
	v_xor_b32_e32 v5, v5, v14
	v_sub_u32_e32 v14, v5, v14
	s_and_b64 vcc, exec, s[12:13]
	v_mov_b32_e32 v15, 0
	s_cbranch_vccnz .LBB0_13
.LBB0_16:
	s_mul_i32 s44, s44, s33
	s_abs_i32 s45, s44
	v_cvt_f32_u32_e32 v5, s45
	v_xor_b32_e32 v15, s44, v4
	s_sub_i32 s44, 0, s45
	v_ashrrev_i32_e32 v15, 31, v15
	v_rcp_iflag_f32_e32 v5, v5
	s_mov_b32 s46, s16
	v_mul_f32_e32 v5, 0x4f7ffffe, v5
	v_cvt_u32_f32_e32 v5, v5
	v_mul_lo_u32 v16, s44, v5
	v_mul_hi_u32 v16, v5, v16
	v_add_u32_e32 v5, v5, v16
	v_mul_hi_u32 v5, v11, v5
	v_mul_lo_u32 v16, v5, s45
	v_sub_u32_e32 v16, v11, v16
	v_add_u32_e32 v17, 1, v5
	v_cmp_le_u32_e32 vcc, s45, v16
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v17, vcc
	v_subrev_u32_e32 v17, s45, v16
	v_cndmask_b32_e32 v16, v16, v17, vcc
	v_add_u32_e32 v17, 1, v5
	v_cmp_le_u32_e32 vcc, s45, v16
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v17, vcc
	v_xor_b32_e32 v5, v5, v15
	v_sub_u32_e32 v5, v5, v15
	v_sub_u32_e32 v16, 0, v5
	v_ashrrev_i32_e32 v15, 31, v5
	v_max_i32_e32 v5, v5, v16
	v_mul_hi_u32 v16, v5, v8
	v_mul_lo_u32 v16, v16, s53
	v_sub_u32_e32 v5, v5, v16
	v_subrev_u32_e32 v16, s53, v5
	v_cmp_le_u32_e32 vcc, s53, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v16, vcc
	v_subrev_u32_e32 v16, s53, v5
	v_cmp_le_u32_e32 vcc, s53, v5
	s_nop 1
	v_cndmask_b32_e32 v5, v5, v16, vcc
	v_xor_b32_e32 v5, v5, v15
	v_sub_u32_e32 v15, v5, v15
	s_and_saveexec_b64 s[44:45], s[4:5]
	s_cbranch_execz .LBB0_7
.LBB0_17:
	s_mul_i32 s46, s49, s46
	s_abs_i32 s47, s46
	v_cvt_f32_u32_e32 v5, s47
	v_mul_lo_u32 v14, v14, s18
	v_rcp_iflag_f32_e32 v16, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, s23, v13
	v_mul_f32_e32 v13, 0x4f7ffffe, v16
	v_cvt_u32_f32_e32 v13, v13
	v_xor_b32_e32 v16, s46, v4
	s_sub_i32 s46, 0, s47
	v_ashrrev_i32_e32 v16, 31, v16
	v_mul_lo_u32 v17, s46, v13
	v_mul_hi_u32 v17, v13, v17
	v_add_u32_e32 v13, v13, v17
	v_mul_hi_u32 v13, v11, v13
	v_mul_lo_u32 v17, v13, s47
	v_sub_u32_e32 v11, v11, v17
	v_add_u32_e32 v18, 1, v13
	v_cmp_le_u32_e32 vcc, s47, v11
	v_subrev_u32_e32 v17, s47, v11
	s_nop 0
	v_cndmask_b32_e32 v13, v13, v18, vcc
	v_cndmask_b32_e32 v11, v11, v17, vcc
	v_add_u32_e32 v17, 1, v13
	v_cmp_le_u32_e32 vcc, s47, v11
	s_mov_b64 s[46:47], 0
	s_nop 0
	v_cndmask_b32_e32 v11, v13, v17, vcc
	v_xor_b32_e32 v11, v11, v16
	v_sub_u32_e32 v11, v11, v16
	v_mul_lo_u32 v13, v15, s20
	v_mul_lo_u32 v11, v11, s19
	v_add3_u32 v12, v1, v12, v13
	v_add3_u32 v11, v12, v14, v11
	v_mov_b32_e32 v12, 0
.LBB0_18:
	v_add_u32_e32 v14, v11, v12
	v_ashrrev_i32_e32 v15, 31, v14
	v_lshlrev_b64 v[14:15], 2, v[14:15]
	v_lshl_add_u64 v[16:17], s[26:27], 0, v[14:15]
	global_load_dword v13, v[16:17], off
	v_lshl_add_u64 v[14:15], s[30:31], 0, v[14:15]
	global_load_dword v16, v[14:15], off
	v_add_u32_e32 v12, v12, v10
	v_add_u32_e32 v17, v1, v12
	v_cmp_le_i32_e32 vcc, s21, v17
	s_or_b64 s[46:47], vcc, s[46:47]
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v13, s22, v13
	v_mul_f32_e32 v13, v5, v13
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v13, s3, v16
	global_store_dword v[14:15], v13, off
	s_andn2_b64 exec, exec, s[46:47]
	s_cbranch_execnz .LBB0_18
	s_branch .LBB0_7
.LBB0_19:
	s_or_b64 exec, exec, s[38:39]
	s_cbranch_execz .LBB0_21
	s_branch .LBB0_35
.LBB0_20:
.LBB0_21:
	s_and_saveexec_b64 s[4:5], s[14:15]
	s_cbranch_execz .LBB0_35
	s_add_u32 s12, s0, 0x60
	s_addc_u32 s13, s1, 0
	s_and_b32 s0, 1, s25
	s_and_b32 s4, 2, s25
	s_cmp_eq_u32 s0, 1
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v3, 0, 1, s[0:1]
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s3, s18, 1
	s_bitcmp1_b32 s25, 2
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s4, 0
	s_cselect_b64 s[0:1], -1, 0
	v_cndmask_b32_e64 v8, 0, 1, s[0:1]
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s17, 1
	s_abs_i32 s25, s18
	v_cvt_f32_u32_e32 v1, s25
	s_abs_i32 s38, s3
	s_sub_i32 s4, 0, s25
	v_cvt_f32_u32_e32 v4, s38
	v_rcp_iflag_f32_e32 v1, v1
	s_abs_i32 s39, s17
	s_abs_i32 s41, s16
	v_rcp_iflag_f32_e32 v4, v4
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_cvt_f32_u32_e32 v7, s41
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	v_mul_lo_u32 v5, s4, v1
	v_mul_hi_u32 v5, v1, v5
	v_add_u32_e32 v1, v1, v5
	v_cvt_f32_u32_e32 v5, s39
	v_rcp_iflag_f32_e32 v7, v7
	s_sub_i32 s4, 0, s38
	v_mul_lo_u32 v6, s4, v4
	v_rcp_iflag_f32_e32 v5, v5
	v_mul_f32_e32 v7, 0x4f7ffffe, v7
	v_cvt_u32_f32_e32 v7, v7
	v_mul_hi_u32 v6, v4, v6
	v_mul_f32_e32 v5, 0x4f7ffffe, v5
	v_cvt_u32_f32_e32 v5, v5
	s_sub_i32 s4, 0, s39
	v_add_u32_e32 v4, v4, v6
	v_cndmask_b32_e64 v0, v0, 0, s[36:37]
	v_mul_lo_u32 v6, s4, v5
	v_mul_hi_u32 v6, v5, v6
	s_sub_i32 s4, 0, s41
	v_add_u32_e32 v5, v5, v6
	v_mul_lo_u32 v6, s4, v7
	v_mul_hi_u32 v6, v7, v6
	v_add_u32_e32 v6, v7, v6
	v_cndmask_b32_e64 v7, 0, 1, s[34:35]
	v_cmp_ne_u32_e64 s[4:5], 1, v3
	v_cndmask_b32_e64 v3, 0, 1, s[6:7]
	s_mul_i32 s33, s3, s0
	v_cmp_gt_i32_e64 s[0:1], s21, v0
	s_ashr_i32 s40, s3, 31
	s_mov_b64 s[14:15], 0
	v_cmp_ne_u32_e64 s[10:11], 1, v7
	v_mov_b32_e32 v7, 0
	v_cmp_ne_u32_e64 s[6:7], 1, v8
	v_cmp_ne_u32_e64 s[8:9], 1, v3
	s_branch .LBB0_24
.LBB0_23:
	s_or_b64 exec, exec, s[34:35]
	v_add_u32_e32 v2, 0x1000, v2
	v_cmp_le_i32_e32 vcc, s24, v2
	s_or_b64 s[14:15], vcc, s[14:15]
	s_andn2_b64 exec, exec, s[14:15]
	s_cbranch_execz .LBB0_35
.LBB0_24:
	s_and_b64 vcc, exec, s[10:11]
	s_waitcnt vmcnt(1)
	v_mov_b32_e32 v8, s21
	s_cbranch_vccnz .LBB0_26
	s_load_dword s34, s[12:13], 0x0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s34
	s_cselect_b32 s34, 12, 18
	s_add_u32 s34, s12, s34
	s_addc_u32 s35, s13, 0
	global_load_ushort v8, v7, s[34:35]
.LBB0_26:
	v_ashrrev_i32_e32 v3, 31, v2
	s_waitcnt vmcnt(0)
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[28:29]
	global_load_dword v10, v[10:11], off
	v_mov_b32_e32 v11, 0
	s_and_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v9, 0
	s_cbranch_vccz .LBB0_30
	s_mov_b32 s36, 1
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b32 s34, 1
	s_cbranch_vccz .LBB0_31
.LBB0_28:
	s_and_b64 vcc, exec, s[8:9]
	v_mov_b32_e32 v12, 0
	s_cbranch_vccz .LBB0_32
.LBB0_29:
	s_and_saveexec_b64 s[34:35], s[0:1]
	s_cbranch_execz .LBB0_23
	s_branch .LBB0_33
.LBB0_30:
	v_sub_u32_e32 v9, 0, v2
	v_max_i32_e32 v9, v2, v9
	v_mul_hi_u32 v12, v9, v1
	v_mul_lo_u32 v12, v12, s25
	v_sub_u32_e32 v9, v9, v12
	v_subrev_u32_e32 v12, s25, v9
	v_cmp_le_u32_e32 vcc, s25, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v12, vcc
	v_subrev_u32_e32 v12, s25, v9
	v_cmp_le_u32_e32 vcc, s25, v9
	s_nop 1
	v_cndmask_b32_e32 v9, v9, v12, vcc
	v_xor_b32_e32 v9, v9, v3
	v_sub_u32_e32 v9, v9, v3
	s_mov_b32 s36, 1
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b32 s34, 1
	s_cbranch_vccnz .LBB0_28
.LBB0_31:
	v_sub_u32_e32 v11, 0, v2
	v_max_i32_e32 v11, v2, v11
	v_mul_hi_u32 v12, v11, v4
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v13, v12, s38
	v_sub_u32_e32 v11, v11, v13
	v_add_u32_e32 v13, 1, v12
	v_cmp_le_u32_e32 vcc, s38, v11
	v_xor_b32_e32 v3, s40, v3
	s_mov_b32 s34, s17
	v_cndmask_b32_e32 v12, v12, v13, vcc
	v_subrev_u32_e32 v13, s38, v11
	v_cndmask_b32_e32 v11, v11, v13, vcc
	v_add_u32_e32 v13, 1, v12
	v_cmp_le_u32_e32 vcc, s38, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v12, v13, vcc
	v_xor_b32_e32 v11, v11, v3
	v_sub_u32_e32 v3, v11, v3
	v_sub_u32_e32 v12, 0, v3
	v_ashrrev_i32_e32 v11, 31, v3
	v_max_i32_e32 v3, v3, v12
	v_mul_hi_u32 v12, v3, v5
	v_mul_lo_u32 v12, v12, s39
	v_sub_u32_e32 v3, v3, v12
	v_subrev_u32_e32 v12, s39, v3
	v_cmp_le_u32_e32 vcc, s39, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v12, vcc
	v_subrev_u32_e32 v12, s39, v3
	v_cmp_le_u32_e32 vcc, s39, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v12, vcc
	v_xor_b32_e32 v3, v3, v11
	v_sub_u32_e32 v11, v3, v11
	s_and_b64 vcc, exec, s[8:9]
	v_mov_b32_e32 v12, 0
	s_cbranch_vccnz .LBB0_29
.LBB0_32:
	s_mul_i32 s34, s34, s3
	s_abs_i32 s35, s34
	v_cvt_f32_u32_e32 v3, s35
	s_waitcnt vmcnt(1)
	v_xor_b32_e32 v13, s34, v2
	s_sub_i32 s34, 0, s35
	v_sub_u32_e32 v12, 0, v2
	v_rcp_iflag_f32_e32 v3, v3
	v_max_i32_e32 v12, v2, v12
	v_ashrrev_i32_e32 v13, 31, v13
	s_mov_b32 s36, s16
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mul_lo_u32 v14, s34, v3
	v_mul_hi_u32 v14, v3, v14
	v_add_u32_e32 v3, v3, v14
	v_mul_hi_u32 v3, v12, v3
	v_mul_lo_u32 v14, v3, s35
	v_sub_u32_e32 v12, v12, v14
	v_add_u32_e32 v15, 1, v3
	v_cmp_le_u32_e32 vcc, s35, v12
	v_subrev_u32_e32 v14, s35, v12
	s_nop 0
	v_cndmask_b32_e32 v3, v3, v15, vcc
	v_cndmask_b32_e32 v12, v12, v14, vcc
	v_add_u32_e32 v14, 1, v3
	v_cmp_le_u32_e32 vcc, s35, v12
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v14, vcc
	v_xor_b32_e32 v3, v3, v13
	v_sub_u32_e32 v3, v3, v13
	v_sub_u32_e32 v13, 0, v3
	v_ashrrev_i32_e32 v12, 31, v3
	v_max_i32_e32 v3, v3, v13
	v_mul_hi_u32 v13, v3, v6
	v_mul_lo_u32 v13, v13, s41
	v_sub_u32_e32 v3, v3, v13
	v_subrev_u32_e32 v13, s41, v3
	v_cmp_le_u32_e32 vcc, s41, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v13, vcc
	v_subrev_u32_e32 v13, s41, v3
	v_cmp_le_u32_e32 vcc, s41, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v13, vcc
	v_xor_b32_e32 v3, v3, v12
	v_sub_u32_e32 v12, v3, v12
	s_and_saveexec_b64 s[34:35], s[0:1]
	s_cbranch_execz .LBB0_23
.LBB0_33:
	s_mul_i32 s36, s33, s36
	s_abs_i32 s37, s36
	v_cvt_f32_u32_e32 v3, s37
	v_xor_b32_e32 v14, s36, v2
	s_sub_i32 s36, 0, s37
	v_ashrrev_i32_e32 v14, 31, v14
	s_waitcnt vmcnt(1)
	v_rcp_iflag_f32_e32 v13, v3
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, s23, v10
	v_sub_u32_e32 v10, 0, v2
	v_max_i32_e32 v10, v2, v10
	v_mul_f32_e32 v13, 0x4f7ffffe, v13
	v_cvt_u32_f32_e32 v13, v13
	v_mul_lo_u32 v12, v12, s20
	v_mul_lo_u32 v11, v11, s18
	v_add3_u32 v9, v0, v9, v12
	v_mul_lo_u32 v15, s36, v13
	v_mul_hi_u32 v15, v13, v15
	v_add_u32_e32 v13, v13, v15
	v_mul_hi_u32 v13, v10, v13
	v_mul_lo_u32 v15, v13, s37
	v_sub_u32_e32 v10, v10, v15
	v_add_u32_e32 v16, 1, v13
	v_cmp_le_u32_e32 vcc, s37, v10
	v_subrev_u32_e32 v15, s37, v10
	s_nop 0
	v_cndmask_b32_e32 v13, v13, v16, vcc
	v_cndmask_b32_e32 v10, v10, v15, vcc
	v_add_u32_e32 v15, 1, v13
	v_cmp_le_u32_e32 vcc, s37, v10
	s_mov_b64 s[36:37], 0
	s_nop 0
	v_cndmask_b32_e32 v10, v13, v15, vcc
	v_xor_b32_e32 v10, v10, v14
	v_sub_u32_e32 v10, v10, v14
	v_mul_lo_u32 v10, v10, s19
	v_add3_u32 v9, v9, v11, v10
	v_mov_b32_e32 v10, 0
.LBB0_34:
	v_add_u32_e32 v12, v9, v10
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshlrev_b64 v[12:13], 2, v[12:13]
	v_lshl_add_u64 v[14:15], s[26:27], 0, v[12:13]
	global_load_dword v11, v[14:15], off
	v_add_u32_e32 v10, v10, v8
	v_add_u32_e32 v14, v0, v10
	v_cmp_le_i32_e32 vcc, s21, v14
	v_lshl_add_u64 v[12:13], s[30:31], 0, v[12:13]
	s_or_b64 s[36:37], vcc, s[36:37]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v11, s22, v11
	v_mul_f32_e32 v11, v3, v11
	global_store_dword v[12:13], v11, off
	s_andn2_b64 exec, exec, s[36:37]
	s_cbranch_execnz .LBB0_34
	s_branch .LBB0_23
.LBB0_35:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel OpTensorLeadingOnes
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 19
		.amdhsa_next_free_sgpr 54
		.amdhsa_accum_offset 20
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
	.size	OpTensorLeadingOnes, .Lfunc_end0-OpTensorLeadingOnes

	.set OpTensorLeadingOnes.num_vgpr, 19
	.set OpTensorLeadingOnes.num_agpr, 0
	.set OpTensorLeadingOnes.numbered_sgpr, 54
	.set OpTensorLeadingOnes.private_seg_size, 0
	.set OpTensorLeadingOnes.uses_vcc, 1
	.set OpTensorLeadingOnes.uses_flat_scratch, 0
	.set OpTensorLeadingOnes.has_dyn_sized_stack, 0
	.set OpTensorLeadingOnes.has_recursion, 0
	.set OpTensorLeadingOnes.has_indirect_call, 0
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
        .name:           a
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           b
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           c
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           c_c
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_h
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_w
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_nstride
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           c_cstride
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           work_per_wg
        .offset:         44
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           alpha0
        .offset:         48
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           alpha1
        .offset:         52
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         56
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           Aoffset
        .offset:         64
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           Boffset
        .offset:         72
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           Coffset
        .offset:         80
        .size:           8
        .type_name:      long
        .value_kind:     by_value
      - .name:           num_wg
        .offset:         88
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           bitmap
        .offset:         92
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           OpTensorLeadingOnes
    .private_segment_fixed_size: 0
    .sgpr_count:     60
    .sgpr_spill_count: 0
    .symbol:         OpTensorLeadingOnes.kd
    .uses_dynamic_stack: false
    .vgpr_count:     19
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
