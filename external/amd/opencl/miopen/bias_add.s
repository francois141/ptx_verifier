; MIOpen rocm-7.2.4 src/kernels/MIOpenTensorKernels.cl (OpTensorFwdBias), src/solver/tensorOp/OpTensorFwdBias.cpp:OpTensorFwdBias::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case bias_add).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	OpTensorFwdBias
	.globl	OpTensorFwdBias
	.p2align	8
	.type	OpTensorFwdBias,@function
OpTensorFwdBias:
	s_load_dwordx8 s[8:15], s[0:1], 0x40
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dword s34, s[0:1], 0x10
	s_load_dwordx2 s[26:27], s[0:1], 0x18
	s_load_dwordx8 s[16:23], s[0:1], 0x20
	s_waitcnt lgkmcnt(0)
	s_lshl_b64 s[8:9], s[8:9], 2
	s_add_u32 s24, s4, s8
	s_addc_u32 s25, s5, s9
	s_lshl_b64 s[4:5], s[10:11], 2
	s_add_u32 s3, s6, s4
	s_addc_u32 s33, s7, s5
	s_lshl_b64 s[4:5], s[12:13], 2
	s_add_u32 s12, s26, s4
	s_addc_u32 s13, s27, s5
	s_cmp_lt_i32 s2, s14
	s_cselect_b64 s[6:7], -1, 0
	v_cmp_eq_f32_e64 s[4:5], s22, 0
	v_cndmask_b32_e64 v1, 0, 1, s[6:7]
	s_and_b64 vcc, exec, s[4:5]
	v_cmp_ne_u32_e64 s[10:11], 1, v1
	s_cbranch_vccnz .LBB0_14
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_13
	s_cmp_eq_u32 s15, 1
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b64 s[8:9], -1, 0
	s_add_u32 s26, s0, 0x60
	s_addc_u32 s27, s1, 0
	s_abs_i32 s23, s34
	v_cvt_f32_u32_e32 v1, s23
	s_abs_i32 s4, s16
	v_cvt_f32_u32_e32 v2, s4
	s_sub_i32 s28, 0, s23
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s5, s19, s16
	v_rcp_iflag_f32_e32 v2, v2
	s_ashr_i32 s35, s34, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_ashr_i32 s5, s5, 31
	v_mov_b32_e32 v3, 0
	s_mov_b32 s39, s2
	v_readfirstlane_b32 s29, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s28, s28, s29
	s_mul_hi_u32 s28, s29, s28
	s_add_i32 s36, s29, s28
	s_sub_i32 s29, 0, s4
	v_readfirstlane_b32 s30, v1
	s_mul_i32 s29, s29, s30
	s_mul_hi_u32 s29, s30, s29
	s_abs_i32 s28, s19
	s_add_i32 s30, s30, s29
	s_mul_hi_u32 s29, s28, s30
	s_mul_i32 s30, s29, s4
	s_sub_i32 s28, s28, s30
	s_add_i32 s30, s29, 1
	s_sub_i32 s31, s28, s4
	s_cmp_ge_u32 s28, s4
	s_cselect_b32 s29, s30, s29
	s_cselect_b32 s28, s31, s28
	s_add_i32 s30, s29, 1
	s_cmp_ge_u32 s28, s4
	s_cselect_b32 s4, s30, s29
	s_xor_b32 s4, s4, s5
	s_sub_i32 s28, s4, s5
	s_abs_i32 s37, s28
	v_cvt_f32_u32_e32 v1, s37
	s_ashr_i32 s38, s28, 31
	s_sub_i32 s28, 0, s37
	v_cmp_gt_i32_e64 s[4:5], s19, v0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s28, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[6:7]
	v_cmp_ne_u32_e64 s[6:7], 1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[8:9]
	v_cmp_ne_u32_e64 s[8:9], 1, v2
	s_branch .LBB0_4
.LBB0_3:
	s_or_b64 exec, exec, s[28:29]
	s_addk_i32 s39, 0x1000
	s_cmp_lt_i32 s39, s14
	s_cbranch_scc0 .LBB0_13
.LBB0_4:
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b32 s30, s39
	s_cbranch_vccnz .LBB0_6
	s_abs_i32 s29, s39
	s_mul_hi_u32 s30, s29, s36
	s_mul_i32 s30, s30, s23
	s_sub_i32 s29, s29, s30
	s_ashr_i32 s28, s39, 31
	s_sub_i32 s30, s29, s23
	s_cmp_ge_u32 s29, s23
	s_cselect_b32 s29, s30, s29
	s_sub_i32 s30, s29, s23
	s_cmp_ge_u32 s29, s23
	s_cselect_b32 s29, s30, s29
	s_xor_b32 s29, s29, s28
	s_sub_i32 s30, s29, s28
.LBB0_6:
	s_and_saveexec_b64 s[28:29], s[4:5]
	s_cbranch_execz .LBB0_3
	s_load_dword s42, s[26:27], 0x0
	s_ashr_i32 s31, s30, 31
	s_lshl_b64 s[40:41], s[30:31], 2
	s_add_u32 s40, s3, s40
	s_addc_u32 s41, s33, s41
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s42
	s_cselect_b32 s31, 12, 18
	s_add_u32 s42, s26, s31
	s_addc_u32 s43, s27, 0
	global_load_dword v2, v3, s[40:41]
	global_load_ushort v4, v3, s[42:43]
	s_abs_i32 s42, s39
	s_mul_hi_u32 s43, s42, s36
	s_mul_i32 s44, s43, s23
	s_ashr_i32 s41, s39, 31
	s_sub_i32 s42, s42, s44
	s_xor_b32 s41, s41, s35
	s_add_i32 s45, s43, 1
	s_sub_i32 s44, s42, s23
	s_cmp_ge_u32 s42, s23
	s_cselect_b32 s43, s45, s43
	s_cselect_b32 s42, s44, s42
	s_add_i32 s44, s43, 1
	s_cmp_ge_u32 s42, s23
	s_cselect_b32 s42, s44, s43
	s_xor_b32 s42, s42, s41
	s_mul_i32 s40, s30, s18
	s_mov_b64 s[30:31], 0
	v_mov_b32_e32 v6, v0
	s_sub_i32 s41, s42, s41
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v8, s21, v2
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v2, 0xffff, v4
	v_mov_b64_e32 v[4:5], v[0:1]
	s_branch .LBB0_9
.LBB0_8:
	v_mul_lo_u32 v6, v7, s17
	v_add3_u32 v6, v5, s40, v6
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshlrev_b64 v[6:7], 2, v[6:7]
	v_lshl_add_u64 v[10:11], s[24:25], 0, v[6:7]
	global_load_dword v9, v[10:11], off
	v_lshl_add_u64 v[10:11], s[12:13], 0, v[6:7]
	global_load_dword v12, v[10:11], off
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[6:7], v[4:5], 0, v[2:3]
	v_cmp_le_i32_e32 vcc, s19, v6
	s_or_b64 s[30:31], vcc, s[30:31]
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v4, s20, v9
	v_add_f32_e32 v4, v8, v4
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v4, s22, v12
	global_store_dword v[10:11], v4, off
	v_mov_b64_e32 v[4:5], v[6:7]
	s_andn2_b64 exec, exec, s[30:31]
	s_cbranch_execz .LBB0_3
.LBB0_9:
	s_and_b64 vcc, exec, s[8:9]
	v_mov_b32_e32 v5, v6
	s_cbranch_vccz .LBB0_11
	s_and_b64 vcc, exec, s[8:9]
	v_mov_b32_e32 v7, s41
	s_cbranch_vccnz .LBB0_8
	s_branch .LBB0_12
.LBB0_11:
	v_sub_u32_e32 v7, 0, v6
	v_max_i32_e32 v7, v6, v7
	v_mul_hi_u32 v9, v7, v1
	v_mul_lo_u32 v9, v9, s37
	v_sub_u32_e32 v7, v7, v9
	v_subrev_u32_e32 v9, s37, v7
	v_cmp_le_u32_e32 vcc, s37, v7
	v_ashrrev_i32_e32 v5, 31, v6
	s_nop 0
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_subrev_u32_e32 v9, s37, v7
	v_cmp_le_u32_e32 vcc, s37, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_xor_b32_e32 v7, v7, v5
	v_sub_u32_e32 v5, v7, v5
	s_and_b64 vcc, exec, s[8:9]
	v_mov_b32_e32 v7, s41
	s_cbranch_vccnz .LBB0_8
.LBB0_12:
	v_sub_u32_e32 v9, 0, v6
	v_ashrrev_i32_e32 v7, 31, v6
	v_max_i32_e32 v6, v6, v9
	v_mul_hi_u32 v9, v6, v1
	v_mul_lo_u32 v10, v9, s37
	v_sub_u32_e32 v6, v6, v10
	v_add_u32_e32 v10, 1, v9
	v_cmp_le_u32_e32 vcc, s37, v6
	v_xor_b32_e32 v7, s38, v7
	s_nop 0
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_subrev_u32_e32 v10, s37, v6
	v_cndmask_b32_e32 v6, v6, v10, vcc
	v_add_u32_e32 v10, 1, v9
	v_cmp_le_u32_e32 vcc, s37, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v9, v10, vcc
	v_xor_b32_e32 v6, v6, v7
	v_sub_u32_e32 v7, v6, v7
	s_branch .LBB0_8
.LBB0_13:
	s_cbranch_execz .LBB0_15
	s_branch .LBB0_27
.LBB0_14:
.LBB0_15:
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_27
	s_cmp_eq_u32 s15, 1
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_eq_u32 s15, 0
	s_cselect_b64 s[10:11], -1, 0
	s_add_u32 s8, s0, 0x60
	s_addc_u32 s9, s1, 0
	s_abs_i32 s15, s34
	v_cvt_f32_u32_e32 v1, s15
	s_abs_i32 s0, s16
	v_cvt_f32_u32_e32 v2, s0
	s_sub_i32 s6, 0, s15
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s1, s19, s16
	v_rcp_iflag_f32_e32 v2, v2
	s_ashr_i32 s26, s34, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_ashr_i32 s1, s1, 31
	v_mov_b32_e32 v3, 0
	s_mov_b32 s29, s2
	v_readfirstlane_b32 s7, v1
	v_mul_f32_e32 v1, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v1, v1
	s_mul_i32 s6, s6, s7
	s_mul_hi_u32 s6, s7, s6
	s_add_i32 s16, s7, s6
	s_sub_i32 s7, 0, s0
	v_readfirstlane_b32 s22, v1
	s_mul_i32 s7, s7, s22
	s_mul_hi_u32 s7, s22, s7
	s_abs_i32 s6, s19
	s_add_i32 s22, s22, s7
	s_mul_hi_u32 s7, s6, s22
	s_mul_i32 s22, s7, s0
	s_sub_i32 s6, s6, s22
	s_add_i32 s22, s7, 1
	s_sub_i32 s23, s6, s0
	s_cmp_ge_u32 s6, s0
	s_cselect_b32 s7, s22, s7
	s_cselect_b32 s6, s23, s6
	s_add_i32 s22, s7, 1
	s_cmp_ge_u32 s6, s0
	s_cselect_b32 s0, s22, s7
	s_xor_b32 s0, s0, s1
	s_sub_i32 s6, s0, s1
	s_abs_i32 s27, s6
	v_cvt_f32_u32_e32 v1, s27
	s_ashr_i32 s28, s6, 31
	s_sub_i32 s6, 0, s27
	v_cmp_gt_i32_e64 s[0:1], s19, v0
	v_rcp_iflag_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mul_lo_u32 v2, s6, v1
	v_mul_hi_u32 v2, v1, v2
	v_add_u32_e32 v1, v1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[4:5]
	v_cmp_ne_u32_e64 s[6:7], 1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[10:11]
	v_cmp_ne_u32_e64 s[4:5], 1, v2
	s_branch .LBB0_18
.LBB0_17:
	s_or_b64 exec, exec, s[10:11]
	s_addk_i32 s29, 0x1000
	s_cmp_ge_i32 s29, s14
	s_cbranch_scc1 .LBB0_27
.LBB0_18:
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b32 s22, s29
	s_cbranch_vccnz .LBB0_20
	s_abs_i32 s11, s29
	s_mul_hi_u32 s22, s11, s16
	s_mul_i32 s22, s22, s15
	s_sub_i32 s11, s11, s22
	s_ashr_i32 s10, s29, 31
	s_sub_i32 s22, s11, s15
	s_cmp_ge_u32 s11, s15
	s_cselect_b32 s11, s22, s11
	s_sub_i32 s22, s11, s15
	s_cmp_ge_u32 s11, s15
	s_cselect_b32 s11, s22, s11
	s_xor_b32 s11, s11, s10
	s_sub_i32 s22, s11, s10
.LBB0_20:
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_17
	s_load_dword s34, s[8:9], 0x0
	s_ashr_i32 s23, s22, 31
	s_lshl_b64 s[30:31], s[22:23], 2
	s_add_u32 s30, s3, s30
	s_addc_u32 s31, s33, s31
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s34
	s_cselect_b32 s23, 12, 18
	s_add_u32 s34, s8, s23
	s_addc_u32 s35, s9, 0
	global_load_dword v2, v3, s[30:31]
	global_load_ushort v4, v3, s[34:35]
	s_abs_i32 s34, s29
	s_mul_hi_u32 s35, s34, s16
	s_mul_i32 s36, s35, s15
	s_ashr_i32 s31, s29, 31
	s_sub_i32 s34, s34, s36
	s_xor_b32 s31, s31, s26
	s_add_i32 s37, s35, 1
	s_sub_i32 s36, s34, s15
	s_cmp_ge_u32 s34, s15
	s_cselect_b32 s35, s37, s35
	s_cselect_b32 s34, s36, s34
	s_add_i32 s36, s35, 1
	s_cmp_ge_u32 s34, s15
	s_cselect_b32 s34, s36, s35
	s_xor_b32 s34, s34, s31
	s_mul_i32 s30, s22, s18
	s_mov_b64 s[22:23], 0
	v_mov_b32_e32 v6, v0
	s_sub_i32 s31, s34, s31
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v8, s21, v2
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v2, 0xffff, v4
	v_mov_b64_e32 v[4:5], v[0:1]
	s_branch .LBB0_23
.LBB0_22:
	v_mul_lo_u32 v6, v7, s17
	v_add3_u32 v6, v5, s30, v6
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshlrev_b64 v[10:11], 2, v[6:7]
	v_lshl_add_u64 v[6:7], s[24:25], 0, v[10:11]
	global_load_dword v9, v[6:7], off
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[6:7], v[4:5], 0, v[2:3]
	v_cmp_le_i32_e32 vcc, s19, v6
	v_lshl_add_u64 v[4:5], s[12:13], 0, v[10:11]
	s_or_b64 s[22:23], vcc, s[22:23]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v9, s20, v9
	v_add_f32_e32 v9, v8, v9
	global_store_dword v[4:5], v9, off
	v_mov_b64_e32 v[4:5], v[6:7]
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execz .LBB0_17
.LBB0_23:
	s_and_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v5, v6
	s_cbranch_vccz .LBB0_25
	s_and_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v7, s31
	s_cbranch_vccnz .LBB0_22
	s_branch .LBB0_26
.LBB0_25:
	v_sub_u32_e32 v7, 0, v6
	v_max_i32_e32 v7, v6, v7
	v_mul_hi_u32 v9, v7, v1
	v_mul_lo_u32 v9, v9, s27
	v_sub_u32_e32 v7, v7, v9
	v_subrev_u32_e32 v9, s27, v7
	v_cmp_le_u32_e32 vcc, s27, v7
	v_ashrrev_i32_e32 v5, 31, v6
	s_nop 0
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_subrev_u32_e32 v9, s27, v7
	v_cmp_le_u32_e32 vcc, s27, v7
	s_nop 1
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_xor_b32_e32 v7, v7, v5
	v_sub_u32_e32 v5, v7, v5
	s_and_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v7, s31
	s_cbranch_vccnz .LBB0_22
.LBB0_26:
	v_sub_u32_e32 v9, 0, v6
	v_ashrrev_i32_e32 v7, 31, v6
	v_max_i32_e32 v6, v6, v9
	v_mul_hi_u32 v9, v6, v1
	v_mul_lo_u32 v10, v9, s27
	v_sub_u32_e32 v6, v6, v10
	v_add_u32_e32 v10, 1, v9
	v_cmp_le_u32_e32 vcc, s27, v6
	v_xor_b32_e32 v7, s28, v7
	s_nop 0
	v_cndmask_b32_e32 v9, v9, v10, vcc
	v_subrev_u32_e32 v10, s27, v6
	v_cndmask_b32_e32 v6, v6, v10, vcc
	v_add_u32_e32 v10, 1, v9
	v_cmp_le_u32_e32 vcc, s27, v6
	s_nop 1
	v_cndmask_b32_e32 v6, v9, v10, vcc
	v_xor_b32_e32 v6, v6, v7
	v_sub_u32_e32 v7, v6, v7
	s_branch .LBB0_22
.LBB0_27:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel OpTensorFwdBias
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
		.amdhsa_next_free_vgpr 13
		.amdhsa_next_free_sgpr 46
		.amdhsa_accum_offset 16
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
	.size	OpTensorFwdBias, .Lfunc_end0-OpTensorFwdBias

	.set OpTensorFwdBias.num_vgpr, 13
	.set OpTensorFwdBias.num_agpr, 0
	.set OpTensorFwdBias.numbered_sgpr, 46
	.set OpTensorFwdBias.private_seg_size, 0
	.set OpTensorFwdBias.uses_vcc, 1
	.set OpTensorFwdBias.uses_flat_scratch, 0
	.set OpTensorFwdBias.has_dyn_sized_stack, 0
	.set OpTensorFwdBias.has_recursion, 0
	.set OpTensorFwdBias.has_indirect_call, 0
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
      - .name:           b_c
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           c
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           c_n
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
      - .name:           incr_wg
        .offset:         92
        .size:           4
        .type_name:      int
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
    .name:           OpTensorFwdBias
    .private_segment_fixed_size: 0
    .sgpr_count:     52
    .sgpr_spill_count: 0
    .symbol:         OpTensorFwdBias.kd
    .uses_dynamic_stack: false
    .vgpr_count:     13
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
