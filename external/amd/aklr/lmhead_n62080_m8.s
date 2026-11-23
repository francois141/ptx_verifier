; AKLR 766a200e367f aklr/ops/gemm/impls/hip/gemm_n62080_k4096/f72cfb48b99e9164.json, compiled for gfx950 by
; external/amd/aklr/build.py (case lmhead_n62080_m8).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,"axG",@progbits,_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,comdat
	.protected	_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
	.globl	_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
	.p2align	8
	.type	_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,@function
_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi:
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x10
	s_load_dword s13, s[0:1], 0x28
	v_readfirstlane_b32 s3, v0
	s_cmpk_lt_u32 s3, 0x180
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[0:1], s[0:1], exec
	s_waitcnt lgkmcnt(0)
	s_cselect_b32 s9, s11, s9
	s_cselect_b32 s8, s10, s8
	s_cselect_b32 s19, 1, 2
	s_lshl_b32 s4, s13, 13
	s_cmpk_lt_u32 s3, 0x180
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s11, 6, 2
	s_cselect_b32 s10, 0x1e500000, s4
	s_lshr_b32 s18, s3, 6
	s_add_i32 s22, s18, -6
	s_cmpk_lt_u32 s3, 0x180
	s_cselect_b64 s[4:5], -1, 0
	s_mul_i32 s14, s2, 0x1e50
	s_and_b64 s[0:1], s[4:5], exec
	s_cselect_b32 s0, s18, s22
	s_ashr_i32 s1, s14, 31
	s_lshr_b32 s1, s1, 23
	s_add_i32 s1, s14, s1
	s_addk_i32 s14, 0x1e50
	s_ashr_i32 s15, s14, 31
	s_lshr_b32 s15, s15, 23
	s_add_i32 s14, s14, s15
	s_ashr_i32 s1, s1, 9
	s_ashr_i32 s14, s14, 9
	s_lshl_b32 s12, s1, 3
	s_sub_i32 s1, s14, s1
	s_lshl_b32 s20, s1, 3
	s_cmpk_gt_u32 s3, 0x17f
	v_and_b32_e32 v1, 63, v0
	s_cselect_b64 s[14:15], -1, 0
	s_lshl_b32 s17, s0, 6
	v_or_b32_e32 v2, s17, v1
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	s_add_i32 s16, s20, -1
	v_ashrrev_i32_e32 v4, 3, v3
	v_and_b32_e32 v3, 0xffffff8, v3
	s_add_i32 s1, s13, -1
	v_sub_u32_e32 v2, v2, v3
	v_min_i32_e32 v3, s16, v4
	v_bitop3_b32 v2, v4, v2, 7 bitop3:0x6c
	v_add_u32_e32 v3, s12, v3
	v_min_i32_e32 v4, s1, v4
	v_cndmask_b32_e64 v3, v4, v3, s[4:5]
	v_lshlrev_b32_e32 v2, 4, v2
	s_add_i32 s0, s11, s0
	v_lshl_add_u32 v4, v3, 13, v2
	v_lshl_or_b32 v2, s0, 6, v1
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	v_ashrrev_i32_e32 v5, 3, v3
	v_and_b32_e32 v3, 0xffffff8, v3
	v_sub_u32_e32 v2, v2, v3
	v_min_i32_e32 v3, s16, v5
	v_bitop3_b32 v2, v5, v2, 7 bitop3:0x6c
	v_add_u32_e32 v3, s12, v3
	v_min_i32_e32 v5, s1, v5
	s_lshl_b32 s0, s11, 7
	v_cndmask_b32_e64 v3, v5, v3, s[4:5]
	v_lshlrev_b32_e32 v2, 4, v2
	s_add_i32 s0, s0, s17
	v_lshl_add_u32 v5, v3, 13, v2
	v_or_b32_e32 v2, s0, v1
	s_ashr_i32 s0, s2, 31
	v_ashrrev_i32_e32 v3, 31, v2
	s_lshr_b32 s0, s0, 26
	v_lshrrev_b32_e32 v3, 29, v3
	s_add_i32 s0, s2, s0
	v_add_u32_e32 v3, v2, v3
	s_andn2_b32 s0, s0, 63
	v_ashrrev_i32_e32 v6, 3, v3
	v_and_b32_e32 v3, 0xffffff8, v3
	s_sub_i32 s24, s2, s0
	v_sub_u32_e32 v2, v2, v3
	v_min_i32_e32 v3, s16, v6
	s_cmpk_lt_u32 s3, 0x200
	v_bitop3_b32 v2, v6, v2, 7 bitop3:0x6c
	v_add_u32_e32 v3, s12, v3
	v_min_i32_e32 v6, s1, v6
	s_cselect_b64 s[0:1], -1, 0
	s_lshl_b32 s21, s18, 10
	v_cndmask_b32_e64 v3, v6, v3, s[4:5]
	v_lshlrev_b32_e32 v2, 4, v2
	s_cmpk_lt_u32 s3, 0x100
	v_lshl_add_u32 v6, v3, 13, v2
	v_cndmask_b32_e64 v2, 0, 1, s[0:1]
	s_cselect_b64 s[2:3], -1, 0
	v_cmp_ne_u32_e64 s[0:1], 1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[2:3]
	s_mov_b32 s11, 0x20000
	s_mov_b32 s23, 0
	s_mov_b32 s25, 0
	s_movk_i32 s26, 0xe800
	v_cmp_ne_u32_e64 s[2:3], 1, v2
	s_branch .LBB0_2
.LBB0_1:
	s_add_i32 s25, s25, 1
	s_addk_i32 s26, 0x800
	s_addk_i32 s23, 0x4000
	s_cmp_eq_u32 s19, s25
	s_cbranch_scc1 .LBB0_9
.LBB0_2:
	s_add_i32 s16, s24, s25
	s_sub_i32 s17, s16, 64
	s_cmp_gt_i32 s16, 63
	s_cselect_b32 s16, s17, s16
	s_lshl_b32 s27, s16, 7
	s_mov_b64 s[16:17], -1
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_6
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB0_5
	s_add_i32 s16, s21, s26
	s_add_i32 s16, s16, 0x8000
	;;#ASMSTART
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], s27 offen lds
	;;#ASMEND
.LBB0_5:
	s_mov_b64 s[16:17], 0
.LBB0_6:
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_1
	s_add_i32 s16, s21, s23
	;;#ASMSTART
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], s27 offen nt lds
	;;#ASMEND
	s_add_i32 s17, s16, 0x1800
	;;#ASMSTART
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v5, s[8:11], s27 offen nt lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_1
	s_addk_i32 s16, 0x3000
	;;#ASMSTART
	s_mov_b32 m0, s16
	s_nop 0
	buffer_load_dwordx4 v6, s[8:11], s27 offen nt lds
	;;#ASMEND
	s_branch .LBB0_1
.LBB0_9:
	v_lshrrev_b32_e32 v8, 4, v1
	v_and_b32_e32 v7, 15, v0
	v_and_b32_e32 v1, 7, v0
	v_bitop3_b32 v0, v8, v0, 7 bitop3:0x78
	s_lshl_b32 s16, s22, 10
	s_add_i32 s17, s21, 0x1800
	s_add_i32 s22, s21, 0x3000
	v_lshlrev_b32_e32 v11, 4, v0
	v_bitop3_b32 v0, v8, v1, 4 bitop3:0x36
	v_lshlrev_b32_e32 v9, 7, v7
	s_and_b64 s[4:5], s[4:5], exec
	v_lshlrev_b32_e32 v10, 4, v0
	v_mov_b32_e32 v0, 0
	s_cselect_b32 s23, 2, 3
	s_add_i32 s24, s19, s24
	v_lshl_or_b32 v12, s18, 11, v9
	s_sub_i32 s25, 64, s19
	s_mov_b32 s26, 0
	s_mov_b32 s27, 0
	s_mov_b32 s28, 0
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	s_branch .LBB0_11
.LBB0_10:
	v_lshl_add_u32 v13, s26, 14, v12
	v_lshl_or_b32 v22, s27, 11, v9
	v_add_u32_e32 v14, v13, v11
	v_add_u32_e32 v18, v22, v11
	v_add_u32_e32 v13, v13, v10
	v_add_u32_e32 v26, v22, v10
	ds_read_b128 v[14:17], v14
	ds_read_b128 v[18:21], v18 offset:32768
	ds_read_b128 v[22:25], v13
	ds_read_b128 v[26:29], v26 offset:32768
	s_add_i32 s4, s19, 1
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[18:21], v[0:3]
	s_cmp_lg_u32 s4, s23
	s_cselect_b32 s19, s4, 0
	s_add_i32 s4, s26, 1
	s_cmp_lg_u32 s4, 2
	s_cselect_b32 s26, s4, 0
	s_add_i32 s4, s27, 1
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[26:29], v[0:3]
	s_cmp_lg_u32 s4, 3
	s_cselect_b32 s27, s4, 0
	s_add_i32 s28, s28, 1
	s_cmp_eq_u32 s28, 63
	s_cbranch_scc1 .LBB0_23
.LBB0_11:
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_13
	s_waitcnt vmcnt(1)
	s_mov_b64 s[4:5], 0
.LBB0_13:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB0_15
	s_waitcnt vmcnt(0)
.LBB0_15:
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_cmp_ge_u32 s28, s25
	s_cbranch_scc1 .LBB0_10
	s_add_i32 s4, s24, s28
	s_sub_i32 s5, s4, 64
	s_cmp_gt_i32 s4, 63
	s_cselect_b32 s4, s5, s4
	s_lshl_b32 s29, s4, 7
	s_mov_b64 s[4:5], -1
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_20
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB0_19
	s_lshl_b32 s4, s19, 11
	s_add_i32 s4, s4, s16
	s_add_i32 s4, s4, 0x8000
	;;#ASMSTART
	s_mov_b32 m0, s4
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], s29 offen lds
	;;#ASMEND
.LBB0_19:
	s_mov_b64 s[4:5], 0
.LBB0_20:
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB0_10
	s_lshl_b32 s4, s19, 14
	s_add_i32 s5, s4, s21
	;;#ASMSTART
	s_mov_b32 m0, s5
	s_nop 0
	buffer_load_dwordx4 v4, s[8:11], s29 offen nt lds
	;;#ASMEND
	s_add_i32 s5, s4, s17
	;;#ASMSTART
	s_mov_b32 m0, s5
	s_nop 0
	buffer_load_dwordx4 v5, s[8:11], s29 offen nt lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
	s_add_i32 s4, s4, s22
	;;#ASMSTART
	s_mov_b32 m0, s4
	s_nop 0
	buffer_load_dwordx4 v6, s[8:11], s29 offen nt lds
	;;#ASMEND
	s_branch .LBB0_10
.LBB0_23:
	v_lshl_add_u32 v4, s26, 14, v12
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMEND
	v_lshl_or_b32 v5, s27, 11, v9
	v_add_u32_e32 v6, v4, v11
	v_add_u32_e32 v4, v4, v10
	v_add_u32_e32 v9, v5, v11
	ds_read_b128 v[12:15], v6
	ds_read_b128 v[16:19], v9 offset:32768
	v_add_u32_e32 v5, v5, v10
	ds_read_b128 v[20:23], v4
	ds_read_b128 v[24:27], v5 offset:32768
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[12:15], v[16:19], v[0:3]
	v_lshlrev_b32_e32 v4, 2, v8
	v_lshl_or_b32 v4, s18, 4, v4
	v_cmp_gt_i32_e32 vcc, s13, v7
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[20:23], v[24:27], v[0:3]
	v_cmp_gt_i32_e64 s[0:1], s20, v4
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_25
	s_ashr_i32 s13, s12, 31
	s_lshl_b64 s[0:1], s[12:13], 1
	s_add_u32 s0, s0, s6
	s_nop 0
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	v_mul_u32_u24_e32 v2, 0x1e500, v7
	v_mov_b32_e32 v3, 0
	s_addc_u32 s1, s1, s7
	v_lshl_add_u64 v[6:7], s[0:1], 0, v[2:3]
	v_mov_b32_e32 v5, v3
	v_lshl_add_u64 v[2:3], v[4:5], 1, v[6:7]
	global_store_dwordx2 v[2:3], v[0:1], off
.LBB0_25:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
		.amdhsa_group_segment_fixed_size 38912
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 44
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
		.amdhsa_next_free_vgpr 30
		.amdhsa_next_free_sgpr 30
		.amdhsa_accum_offset 32
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
	.section	.text._ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,"axG",@progbits,_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,comdat
.Lfunc_end0:
	.size	_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi, .Lfunc_end0-_ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi

	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.num_vgpr, 30
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.num_agpr, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.numbered_sgpr, 30
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.private_seg_size, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.uses_vcc, 1
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.uses_flat_scratch, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_dyn_sized_stack, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_recursion, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_435c6fe62a1ea88b,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_435c6fe62a1ea88b
__hip_cuid_435c6fe62a1ea88b:
	.byte	0
	.size	__hip_cuid_435c6fe62a1ea88b, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_435c6fe62a1ea88b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 38912
    .kernarg_segment_align: 8
    .kernarg_segment_size: 44
    .max_flat_workgroup_size: 512
    .name:           _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
    .private_segment_fixed_size: 0
    .sgpr_count:     36
    .sgpr_spill_count: 0
    .symbol:         _ZN6lmhead11gemm_kernelINS_3CfgILi62080ELi4096ELi16ELi512ELi1ELi2ELi3ELi1ELi8ELi2ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     30
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
