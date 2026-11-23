; AKLR 766a200e367f aklr/ops/rms_norm/impls/hip/add_rms_norm_hidden_size6144/1f0b6c68db064ca4.json, compiled for gfx950 by
; external/amd/aklr/build.py (case add_rms_norm_hip).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d,"axG",@progbits,_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d,comdat
	.globl	_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d
	.p2align	8
	.type	_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d,@function
_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d:
	s_load_dwordx8 s[4:11], s[0:1], 0x0
	s_mul_i32 s17, s2, 0x3000
	s_mul_hi_u32 s16, s2, 0x3000
	v_and_b32_e32 v1, 0xc0, v0
	v_and_b32_e32 v62, 63, v0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s12, s4, s17
	s_addc_u32 s2, s5, s16
	s_and_b32 s13, s2, 0xffff
	v_mul_u32_u24_e32 v1, 48, v1
	s_add_u32 s4, s6, s17
	v_lshl_or_b32 v46, v62, 4, v1
	s_movk_i32 s14, 0x3000
	s_mov_b32 s15, 0x20000
	s_addc_u32 s2, s7, s16
	s_and_b32 s5, s2, 0xffff
	s_mov_b32 s6, s14
	s_mov_b32 s7, s15
	buffer_load_dwordx4 v[2:5], v46, s[12:15], 0 offen sc0 nt
	buffer_load_dwordx4 v[18:21], v46, s[4:7], 0 offen sc0 nt
	s_load_dwordx2 s[2:3], s[0:1], 0x20
	s_setreg_imm32_b32 hwreg(HW_REG_MODE, 4, 2), 0
	buffer_load_dwordx4 v[34:37], v46, s[12:15], 0 offen offset:1024 sc0 nt
	buffer_load_dwordx4 v[38:41], v46, s[4:7], 0 offen offset:1024 sc0 nt
	v_add_u32_e32 v47, 0x400, v46
	buffer_load_dwordx4 v[42:45], v46, s[12:15], 0 offen offset:2048 sc0 nt
	buffer_load_dwordx4 v[50:53], v46, s[4:7], 0 offen offset:2048 sc0 nt
	v_add_u32_e32 v1, 0x800, v46
	s_and_b32 s13, s9, 0xffff
	s_mov_b32 s12, s8
	buffer_load_dwordx4 v[14:17], v46, s[12:15], 0 offen
	buffer_load_dwordx4 v[10:13], v46, s[12:15], 0 offen offset:1024
	buffer_load_dwordx4 v[6:9], v46, s[12:15], 0 offen offset:2048
	v_mov_b32_e32 v22, 0x45c00000
	;;#ASMSTART
	v_rcp_iflag_f32 v48, v22
	s_nop 0
	;;#ASMEND
	s_waitcnt vmcnt(8)
	v_lshlrev_b32_e32 v22, 16, v2
	v_and_b32_e32 v23, 0xffff0000, v2
	s_waitcnt vmcnt(7)
	v_lshlrev_b32_e32 v24, 16, v18
	v_and_b32_e32 v25, 0xffff0000, v18
	v_pk_add_f32 v[22:23], v[22:23], v[24:25]
	v_lshlrev_b32_e32 v24, 16, v3
	v_and_b32_e32 v25, 0xffff0000, v3
	v_lshlrev_b32_e32 v18, 16, v19
	v_and_b32_e32 v19, 0xffff0000, v19
	v_pk_mul_f32 v[54:55], v[22:23], v[22:23]
	v_pk_add_f32 v[24:25], v[24:25], v[18:19]
	v_lshlrev_b32_e32 v18, 16, v4
	v_and_b32_e32 v19, 0xffff0000, v4
	v_lshlrev_b32_e32 v26, 16, v20
	v_and_b32_e32 v27, 0xffff0000, v20
	v_pk_mul_f32 v[56:57], v[24:25], v[24:25]
	v_pk_add_f32 v[26:27], v[18:19], v[26:27]
	v_lshlrev_b32_e32 v18, 16, v5
	v_and_b32_e32 v19, 0xffff0000, v5
	v_lshlrev_b32_e32 v20, 16, v21
	v_and_b32_e32 v21, 0xffff0000, v21
	v_add_f32_e32 v49, v55, v54
	v_pk_add_f32 v[28:29], v[18:19], v[20:21]
	s_waitcnt vmcnt(6)
	v_lshlrev_b32_e32 v18, 16, v34
	v_and_b32_e32 v19, 0xffff0000, v34
	s_waitcnt vmcnt(5)
	v_lshlrev_b32_e32 v20, 16, v38
	v_and_b32_e32 v21, 0xffff0000, v38
	v_add_f32_e32 v49, v49, v56
	v_pk_mul_f32 v[58:59], v[26:27], v[26:27]
	v_pk_add_f32 v[30:31], v[18:19], v[20:21]
	v_lshlrev_b32_e32 v18, 16, v35
	v_and_b32_e32 v19, 0xffff0000, v35
	v_lshlrev_b32_e32 v20, 16, v39
	v_and_b32_e32 v21, 0xffff0000, v39
	v_add_f32_e32 v49, v57, v49
	v_pk_add_f32 v[32:33], v[18:19], v[20:21]
	v_lshlrev_b32_e32 v18, 16, v36
	v_and_b32_e32 v19, 0xffff0000, v36
	v_lshlrev_b32_e32 v20, 16, v40
	v_and_b32_e32 v21, 0xffff0000, v40
	v_add_f32_e32 v49, v49, v58
	v_pk_mul_f32 v[60:61], v[28:29], v[28:29]
	v_pk_add_f32 v[34:35], v[18:19], v[20:21]
	v_lshlrev_b32_e32 v18, 16, v37
	v_and_b32_e32 v19, 0xffff0000, v37
	v_lshlrev_b32_e32 v20, 16, v41
	v_and_b32_e32 v21, 0xffff0000, v41
	v_add_f32_e32 v49, v59, v49
	v_pk_add_f32 v[36:37], v[18:19], v[20:21]
	s_waitcnt vmcnt(4)
	v_lshlrev_b32_e32 v18, 16, v42
	v_and_b32_e32 v19, 0xffff0000, v42
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v20, 16, v50
	v_and_b32_e32 v21, 0xffff0000, v50
	v_add_f32_e32 v49, v49, v60
	v_pk_add_f32 v[38:39], v[18:19], v[20:21]
	v_lshlrev_b32_e32 v18, 16, v43
	v_and_b32_e32 v19, 0xffff0000, v43
	v_lshlrev_b32_e32 v20, 16, v51
	v_and_b32_e32 v21, 0xffff0000, v51
	v_lshlrev_b32_e32 v42, 16, v52
	v_and_b32_e32 v43, 0xffff0000, v52
	v_lshlrev_b32_e32 v50, 16, v53
	v_and_b32_e32 v51, 0xffff0000, v53
	v_pk_mul_f32 v[52:53], v[30:31], v[30:31]
	v_add_f32_e32 v49, v61, v49
	v_pk_add_f32 v[40:41], v[18:19], v[20:21]
	v_lshlrev_b32_e32 v20, 16, v44
	v_and_b32_e32 v21, 0xffff0000, v44
	v_lshlrev_b32_e32 v44, 16, v45
	v_and_b32_e32 v45, 0xffff0000, v45
	v_add_f32_e32 v49, v49, v52
	v_pk_add_f32 v[44:45], v[44:45], v[50:51]
	v_pk_mul_f32 v[50:51], v[32:33], v[32:33]
	v_add_f32_e32 v49, v53, v49
	v_add_f32_e32 v49, v49, v50
	v_pk_mul_f32 v[54:55], v[34:35], v[34:35]
	v_add_f32_e32 v49, v51, v49
	v_add_f32_e32 v49, v49, v54
	v_pk_mul_f32 v[56:57], v[36:37], v[36:37]
	v_add_f32_e32 v49, v55, v49
	v_add_f32_e32 v49, v49, v56
	v_pk_mul_f32 v[50:51], v[38:39], v[38:39]
	v_add_f32_e32 v49, v57, v49
	v_add_f32_e32 v49, v49, v50
	v_pk_mul_f32 v[52:53], v[40:41], v[40:41]
	v_add_f32_e32 v49, v51, v49
	v_pk_add_f32 v[42:43], v[20:21], v[42:43]
	v_add_f32_e32 v49, v49, v52
	v_pk_mul_f32 v[60:61], v[42:43], v[42:43]
	v_add_f32_e32 v49, v53, v49
	v_add_f32_e32 v49, v49, v60
	v_pk_mul_f32 v[58:59], v[44:45], v[44:45]
	v_add_f32_e32 v49, v61, v49
	v_add_f32_e32 v49, v49, v58
	v_add_f32_e32 v49, v59, v49
	s_waitcnt lgkmcnt(0)
	s_add_u32 s12, s2, s17
	s_addc_u32 s2, s3, s16
	v_add_f32_dpp v49, v49, v49 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v51, 0
	s_and_b32 s13, s2, 0xffff
	v_add_f32_dpp v49, v49, v49 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cvt_pk_bf16_f32 v2, v22, v23
	v_cvt_pk_bf16_f32 v3, v24, v25
	v_add_f32_dpp v49, v49, v49 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cvt_pk_bf16_f32 v4, v26, v27
	v_cvt_pk_bf16_f32 v5, v28, v29
	v_add_f32_dpp v50, v49, v49 row_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cvt_pk_bf16_f32 v18, v30, v31
	v_cvt_pk_bf16_f32 v19, v32, v33
	v_add_f32_dpp v50, v50, v50 row_bcast:15 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_cvt_pk_bf16_f32 v20, v34, v35
	v_cvt_pk_bf16_f32 v21, v36, v37
	v_mov_b32_e32 v49, 0
	v_mov_b32_dpp v51, v50 row_bcast:31 row_mask:0xf bank_mask:0xf
	v_cmp_eq_u32_e32 vcc, 63, v62
	buffer_store_dwordx4 v[2:5], v46, s[12:15], 0 offen sc0 sc1
	buffer_store_dwordx4 v[18:21], v46, s[12:15], 0 offen offset:1024 sc0 sc1
	s_and_saveexec_b64 s[2:3], vcc
	v_lshrrev_b32_e32 v0, 4, v0
	v_and_b32_e32 v0, 12, v0
	v_add_f32_e32 v50, v50, v51
	ds_write_b32 v0, v50
	s_or_b64 exec, exec, s[2:3]
	s_load_dwordx2 s[0:1], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[50:53], v49
	v_cvt_pk_bf16_f32 v54, v38, v39
	v_cvt_pk_bf16_f32 v55, v40, v41
	v_cvt_pk_bf16_f32 v56, v42, v43
	v_cvt_pk_bf16_f32 v57, v44, v45
	s_waitcnt vmcnt(3)
	v_lshlrev_b32_e32 v62, 16, v10
	v_and_b32_e32 v63, 0xffff0000, v10
	v_lshlrev_b32_e32 v10, 16, v11
	v_and_b32_e32 v11, 0xffff0000, v11
	v_pk_add_f32 v[64:65], v[10:11], 0 op_sel_hi:[1,0]
	v_lshlrev_b32_e32 v10, 16, v12
	v_and_b32_e32 v11, 0xffff0000, v12
	v_pk_add_f32 v[66:67], v[10:11], 0 op_sel_hi:[1,0]
	v_lshlrev_b32_e32 v10, 16, v13
	v_and_b32_e32 v11, 0xffff0000, v13
	v_pk_add_f32 v[68:69], v[10:11], 0 op_sel_hi:[1,0]
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v10, 16, v6
	v_and_b32_e32 v11, 0xffff0000, v6
	v_lshlrev_b32_e32 v6, 16, v7
	v_and_b32_e32 v7, 0xffff0000, v7
	v_pk_add_f32 v[72:73], v[6:7], 0 op_sel_hi:[1,0]
	v_lshlrev_b32_e32 v6, 16, v8
	v_and_b32_e32 v7, 0xffff0000, v8
	v_lshlrev_b32_e32 v58, 16, v14
	v_and_b32_e32 v59, 0xffff0000, v14
	v_lshlrev_b32_e32 v14, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v15
	v_lshlrev_b32_e32 v60, 16, v16
	v_and_b32_e32 v61, 0xffff0000, v16
	v_lshlrev_b32_e32 v16, 16, v17
	v_and_b32_e32 v17, 0xffff0000, v17
	v_pk_add_f32 v[74:75], v[6:7], 0 op_sel_hi:[1,0]
	v_lshlrev_b32_e32 v6, 16, v9
	v_and_b32_e32 v7, 0xffff0000, v9
	v_pk_add_f32 v[58:59], v[58:59], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[14:15], v[14:15], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[60:61], v[60:61], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[16:17], v[16:17], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[62:63], v[62:63], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[70:71], v[10:11], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[76:77], v[6:7], 0 op_sel_hi:[1,0]
	buffer_store_dwordx4 v[54:57], v1, s[12:15], 0 offen sc0 sc1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v50, v51
	v_add_f32_e32 v6, v52, v53
	;;#ASMSTART
	;;#ASMEND
	s_add_u32 s12, s10, s17
	v_add_f32_e32 v0, v6, v0
	v_mul_f32_e32 v0, v48, v0
	v_cvt_f64_f32_e32 v[6:7], v0
	v_add_f64 v[6:7], s[0:1], v[6:7]
	v_cvt_f32_f64_e32 v0, v[6:7]
	v_rsq_f32_e32 v0, v0
	s_addc_u32 s0, s11, s16
	s_and_b32 s13, s0, 0xffff
	v_pk_mul_f32 v[6:7], v[0:1], v[22:23] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[0:1], v[24:25] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[6:7], v[58:59]
	v_pk_mul_f32 v[8:9], v[8:9], v[14:15]
	v_cvt_pk_bf16_f32 v6, v6, v7
	v_cvt_pk_bf16_f32 v7, v8, v9
	v_pk_mul_f32 v[8:9], v[0:1], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[0:1], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[8:9], v[60:61]
	v_pk_mul_f32 v[10:11], v[10:11], v[16:17]
	v_cvt_pk_bf16_f32 v8, v8, v9
	v_cvt_pk_bf16_f32 v9, v10, v11
	v_pk_mul_f32 v[10:11], v[0:1], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[0:1], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[10:11], v[10:11], v[62:63]
	v_pk_mul_f32 v[12:13], v[12:13], v[64:65]
	v_cvt_pk_bf16_f32 v10, v10, v11
	v_cvt_pk_bf16_f32 v11, v12, v13
	v_pk_mul_f32 v[12:13], v[0:1], v[34:35] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[0:1], v[36:37] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[12:13], v[66:67]
	v_pk_mul_f32 v[14:15], v[14:15], v[68:69]
	v_cvt_pk_bf16_f32 v12, v12, v13
	v_cvt_pk_bf16_f32 v13, v14, v15
	v_pk_mul_f32 v[14:15], v[0:1], v[38:39] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[0:1], v[40:41] op_sel_hi:[0,1]
	v_pk_mul_f32 v[14:15], v[14:15], v[70:71]
	v_pk_mul_f32 v[16:17], v[16:17], v[72:73]
	v_cvt_pk_bf16_f32 v14, v14, v15
	v_cvt_pk_bf16_f32 v15, v16, v17
	v_pk_mul_f32 v[16:17], v[0:1], v[42:43] op_sel_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[0:1], v[44:45] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[16:17], v[74:75]
	v_pk_mul_f32 v[22:23], v[22:23], v[76:77]
	v_cvt_pk_bf16_f32 v16, v16, v17
	v_cvt_pk_bf16_f32 v17, v22, v23
	buffer_store_dwordx4 v[6:9], v46, s[12:15], 0 offen sc0 sc1
	buffer_store_dwordx4 v[10:13], v47, s[12:15], 0 offen sc0 sc1
	buffer_store_dwordx4 v[14:17], v1, s[12:15], 0 offen sc0 sc1
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	;;#ASMSTART
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 48
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
		.amdhsa_next_free_vgpr 78
		.amdhsa_next_free_sgpr 18
		.amdhsa_accum_offset 80
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
	.section	.text._ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d,"axG",@progbits,_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d,comdat
.Lfunc_end0:
	.size	_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d, .Lfunc_end0-_ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d

	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.num_vgpr, 78
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.num_agpr, 0
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.numbered_sgpr, 18
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.private_seg_size, 0
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.uses_vcc, 1
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.uses_flat_scratch, 0
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.has_dyn_sized_stack, 0
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.has_recursion, 0
	.set _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_733f8bcd23b39cf,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_733f8bcd23b39cf
__hip_cuid_733f8bcd23b39cf:
	.byte	0
	.size	__hip_cuid_733f8bcd23b39cf, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_733f8bcd23b39cf
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           8
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 48
    .max_flat_workgroup_size: 256
    .name:           _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d
    .private_segment_fixed_size: 0
    .sgpr_count:     24
    .sgpr_spill_count: 0
    .symbol:         _ZN12_GLOBAL__N_123add_rmsnorm_bf16_kernelILi3EEEvPKvS2_S2_PvS3_d.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     78
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
