; AKLR 766a200e367f aklr/ops/rms_norm/impls/triton/rms_norm_hidden_size6144/76e6a27406ca04fc.json, compiled for gfx950 by
; external/amd/aklr/build.py (case rms_norm_triton).
; dynamic LDS: 16 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rms_kernel                     ; -- Begin function _rms_kernel
	.p2align	8
	.type	_rms_kernel,@function
_rms_kernel:                            ; @_rms_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/build/rms_norm_triton" "kernel.py"
	.loc	1 8 0 prologue_end              ; kernel.py:8:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.2:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[12:13], s[2:3]
.Ltmp1:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:29:25 ]
	v_readfirstlane_b32 s2, v0
.Ltmp2:
	.loc	1 33 13                         ; kernel.py:33:13
	s_and_b32 s2, s2, 0xc0
	.loc	1 14 10                         ; kernel.py:14:10
	s_and_b32 s5, s5, 0xffff
	.loc	1 12 12                         ; kernel.py:12:12
	v_and_or_b32 v1, v0, 63, s2
	.loc	1 14 10                         ; kernel.py:14:10
	v_lshlrev_b32_e32 v1, 4, v1
	.loc	1 20 26                         ; kernel.py:20:26
	s_cmp_lt_i32 s14, s8
	.loc	1 22 14                         ; kernel.py:22:14
	s_mulk_i32 s14, 0x3000
	v_or_b32_e32 v10, s14, v1
	s_mov_b64 s[0:1], s[6:7]
	.loc	1 14 10                         ; kernel.py:14:10
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	.loc	1 22 14                         ; kernel.py:22:14
	v_bfrev_b32_e32 v11, 1
	.loc	1 20 26                         ; kernel.py:20:26
	s_cselect_b64 vcc, -1, 0
	.loc	1 24 18                         ; kernel.py:24:18
	v_add_u32_e32 v6, 0x1000, v10
	.loc	1 22 14                         ; kernel.py:22:14
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	v_cndmask_b32_e32 v44, v11, v10, vcc
	.loc	1 24 18                         ; kernel.py:24:18
	v_cndmask_b32_e32 v45, v11, v6, vcc
	.loc	1 25 18                         ; kernel.py:25:18
	v_add_u32_e32 v10, 0x2000, v10
	.loc	1 22 14                         ; kernel.py:22:14
	buffer_load_dwordx4 v[2:5], v44, s[12:15], 0 offen sc0 nt
	.loc	1 24 18                         ; kernel.py:24:18
	buffer_load_dwordx4 v[6:9], v45, s[12:15], 0 offen sc0 nt
	.loc	1 25 18                         ; kernel.py:25:18
	v_cndmask_b32_e32 v46, v11, v10, vcc
	buffer_load_dwordx4 v[10:13], v46, s[12:15], 0 offen sc0 nt
	.loc	1 14 10                         ; kernel.py:14:10
	buffer_load_dwordx4 v[14:17], v1, s[4:7], 0 offen
.Ltmp3:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:29:25 ]
	v_lshlrev_b32_e32 v0, 2, v0
	v_and_b32_e32 v0, 12, v0
	v_add_u32_e32 v47, 0, v0
.Ltmp4:
	.loc	1 16 14                         ; kernel.py:16:14
	v_or_b32_e32 v0, 0x1000, v1
	.loc	1 17 14                         ; kernel.py:17:14
	v_or_b32_e32 v1, 0x2000, v1
	.loc	1 16 14                         ; kernel.py:16:14
	buffer_load_dwordx4 v[18:21], v0, s[4:7], 0 offen
	.loc	1 17 14                         ; kernel.py:17:14
	buffer_load_dwordx4 v[22:25], v1, s[4:7], 0 offen
.Ltmp5:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:29:25 ]
	s_lshr_b32 s2, s2, 4
	v_mov_b32_e32 v48, s2
	s_mov_b32 s8, 0x45c00000
.Ltmp6:
	.loc	1 30 9                          ; kernel.py:30:9
	s_and_b32 s1, s1, 0xffff
	.loc	1 22 14                         ; kernel.py:22:14
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v1, 0xffff0000, v2
	v_lshlrev_b32_e32 v0, 16, v2
	v_and_b32_e32 v27, 0xffff0000, v3
	v_lshlrev_b32_e32 v26, 16, v3
	v_and_b32_e32 v3, 0xffff0000, v4
	v_lshlrev_b32_e32 v2, 16, v4
	v_and_b32_e32 v29, 0xffff0000, v5
	v_lshlrev_b32_e32 v28, 16, v5
	.loc	1 24 18                         ; kernel.py:24:18
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v5, 0xffff0000, v6
	v_lshlrev_b32_e32 v4, 16, v6
	.loc	1 25 18                         ; kernel.py:25:18
	s_waitcnt vmcnt(3)
	v_and_b32_e32 v31, 0xffff0000, v10
	v_lshlrev_b32_e32 v30, 16, v10
	.loc	1 24 18                         ; kernel.py:24:18
	v_and_b32_e32 v33, 0xffff0000, v7
	v_lshlrev_b32_e32 v32, 16, v7
	.loc	1 25 18                         ; kernel.py:25:18
	v_and_b32_e32 v7, 0xffff0000, v11
	v_lshlrev_b32_e32 v6, 16, v11
	.loc	1 24 18                         ; kernel.py:24:18
	v_and_b32_e32 v11, 0xffff0000, v8
	v_lshlrev_b32_e32 v10, 16, v8
	.loc	1 25 18                         ; kernel.py:25:18
	v_and_b32_e32 v35, 0xffff0000, v12
	v_lshlrev_b32_e32 v34, 16, v12
	.loc	1 24 18                         ; kernel.py:24:18
	v_and_b32_e32 v37, 0xffff0000, v9
	v_lshlrev_b32_e32 v36, 16, v9
	.loc	1 25 18                         ; kernel.py:25:18
	v_and_b32_e32 v9, 0xffff0000, v13
	v_lshlrev_b32_e32 v8, 16, v13
	.loc	1 28 29                         ; kernel.py:28:29
	v_pk_mul_f32 v[12:13], v[30:31], v[30:31]
	v_pk_mul_f32 v[38:39], v[6:7], v[6:7]
	v_pk_mul_f32 v[40:41], v[34:35], v[34:35]
	v_pk_mul_f32 v[42:43], v[8:9], v[8:9]
	.loc	1 28 19 is_stmt 0               ; kernel.py:28:19
	v_pk_fma_f32 v[12:13], v[4:5], v[4:5], v[12:13]
	v_pk_fma_f32 v[38:39], v[32:33], v[32:33], v[38:39]
	v_pk_fma_f32 v[40:41], v[10:11], v[10:11], v[40:41]
	v_pk_fma_f32 v[42:43], v[36:37], v[36:37], v[42:43]
	.loc	1 28 13                         ; kernel.py:28:13
	v_pk_fma_f32 v[12:13], v[0:1], v[0:1], v[12:13]
	v_pk_fma_f32 v[38:39], v[26:27], v[26:27], v[38:39]
	v_pk_fma_f32 v[40:41], v[2:3], v[2:3], v[40:41]
	v_pk_fma_f32 v[42:43], v[28:29], v[28:29], v[42:43]
.Ltmp7:
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:29:25 ]
	v_pk_add_f32 v[12:13], v[12:13], v[38:39]
	v_pk_add_f32 v[38:39], v[40:41], v[42:43]
	s_nop 0
	v_pk_add_f32 v[12:13], v[12:13], v[38:39]
.Ltmp8:
	.loc	1 14 10                         ; kernel.py:14:10
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v39, 0xffff0000, v15
.Ltmp9:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:29:25 ] ]
	v_add_f32_e32 v12, v12, v13
	s_nop 1
	v_add_f32_dpp v12, v12, v12 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v12, v12, v12 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v12, v12, v12 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v12, v12, v12 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp10:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:29:25 ]
	v_mov_b32_e32 v13, v12
	s_nop 1
	v_mov_b32_dpp v13, v13 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
.Ltmp11:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:29:25 ] ]
	v_add_f32_e32 v12, v13, v12
.Ltmp12:
	.loc	1 14 10                         ; kernel.py:14:10
	v_and_b32_e32 v13, 0xffff0000, v14
.Ltmp13:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:29:25 ] ]
	s_nop 0
	v_add_f32_dpp v12, v12, v12 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp14:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:29:25 ]
	s_nop 0
	v_readlane_b32 s2, v12, 63
	s_nop 1
	v_mov_b32_e32 v12, s2
	ds_write_b32 v48, v12
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v38, v47
.Ltmp15:
	.loc	1 14 10                         ; kernel.py:14:10
	v_lshlrev_b32_e32 v12, 16, v14
.Ltmp16:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:29:25 ] ]
	s_waitcnt lgkmcnt(0)
	v_add_f32_dpp v14, v38, v38 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp17:
	.loc	1 14 10                         ; kernel.py:14:10
	v_lshlrev_b32_e32 v38, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v16
.Ltmp18:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:29:25 ] ]
	v_add_f32_dpp v14, v14, v14 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp19:
	.loc	1 29 25                         ; kernel.py:29:25
	v_div_scale_f32 v40, s[2:3], s8, s8, v14
	v_rcp_f32_e32 v41, v40
	v_div_scale_f32 v42, vcc, v14, s8, v14
	.loc	1 30 9                          ; kernel.py:30:9
	s_mov_b32 s2, s6
	s_mov_b32 s3, s7
	.loc	1 29 25                         ; kernel.py:29:25
	v_fma_f32 v43, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v43, v41
	v_mul_f32_e32 v43, v42, v41
	v_fma_f32 v47, -v40, v43, v42
	v_fmac_f32_e32 v43, v47, v41
	v_fma_f32 v40, -v40, v43, v42
	v_div_fmas_f32 v40, v40, v41, v43
	v_div_fixup_f32 v14, v40, s8, v14
	v_add_f32_e32 v14, s9, v14
	.loc	1 29 16 is_stmt 0               ; kernel.py:29:16
	v_rsq_f32_e32 v40, v14
	.loc	1 14 10 is_stmt 1               ; kernel.py:14:10
	v_lshlrev_b32_e32 v14, 16, v16
	v_and_b32_e32 v43, 0xffff0000, v17
	v_lshlrev_b32_e32 v42, 16, v17
	.loc	1 30 33                         ; kernel.py:30:33
	v_pk_mul_f32 v[0:1], v[40:41], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[16:17], v[40:41], v[26:27] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[40:41], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[26:27], v[40:41], v[28:29] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[0:1], v[12:13]
	v_pk_mul_f32 v[12:13], v[16:17], v[38:39]
	v_pk_mul_f32 v[2:3], v[2:3], v[14:15]
	v_pk_mul_f32 v[14:15], v[26:27], v[42:43]
	.loc	1 30 32 is_stmt 0               ; kernel.py:30:32
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v12, v13
	v_cvt_pk_bf16_f32 v2, v2, v3
	v_cvt_pk_bf16_f32 v3, v14, v15
	.loc	1 30 9                          ; kernel.py:30:9
	buffer_store_dwordx4 v[0:3], v44, s[0:3], 0 offen sc0 sc1
	.loc	1 32 45 is_stmt 1               ; kernel.py:32:45
	v_pk_mul_f32 v[10:11], v[40:41], v[10:11] op_sel_hi:[0,1]
	v_pk_mul_f32 v[12:13], v[40:41], v[36:37] op_sel_hi:[0,1]
	.loc	1 16 14                         ; kernel.py:16:14
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v1, 0xffff0000, v18
	v_lshlrev_b32_e32 v0, 16, v18
	.loc	1 32 45                         ; kernel.py:32:45
	v_pk_mul_f32 v[2:3], v[40:41], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	.loc	1 16 14                         ; kernel.py:16:14
	v_and_b32_e32 v3, 0xffff0000, v19
	v_lshlrev_b32_e32 v2, 16, v19
	.loc	1 32 45                         ; kernel.py:32:45
	v_pk_mul_f32 v[4:5], v[40:41], v[32:33] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	.loc	1 16 14                         ; kernel.py:16:14
	v_and_b32_e32 v5, 0xffff0000, v20
	v_lshlrev_b32_e32 v4, 16, v20
	.loc	1 32 45                         ; kernel.py:32:45
	v_pk_mul_f32 v[4:5], v[10:11], v[4:5]
	.loc	1 16 14                         ; kernel.py:16:14
	v_and_b32_e32 v11, 0xffff0000, v21
	v_lshlrev_b32_e32 v10, 16, v21
	.loc	1 32 45                         ; kernel.py:32:45
	v_pk_mul_f32 v[10:11], v[12:13], v[10:11]
	.loc	1 32 44 is_stmt 0               ; kernel.py:32:44
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	v_cvt_pk_bf16_f32 v2, v4, v5
	v_cvt_pk_bf16_f32 v3, v10, v11
	.loc	1 32 13                         ; kernel.py:32:13
	buffer_store_dwordx4 v[0:3], v45, s[0:3], 0 offen sc0 sc1
	.loc	1 33 49 is_stmt 1               ; kernel.py:33:49
	v_pk_mul_f32 v[4:5], v[40:41], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[40:41], v[34:35] op_sel_hi:[0,1]
	.loc	1 17 14                         ; kernel.py:17:14
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v1, 0xffff0000, v22
	v_lshlrev_b32_e32 v0, 16, v22
	.loc	1 33 49                         ; kernel.py:33:49
	v_pk_mul_f32 v[2:3], v[40:41], v[30:31] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[2:3], v[0:1]
	.loc	1 17 14                         ; kernel.py:17:14
	v_and_b32_e32 v3, 0xffff0000, v23
	v_lshlrev_b32_e32 v2, 16, v23
	.loc	1 33 49                         ; kernel.py:33:49
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	.loc	1 17 14                         ; kernel.py:17:14
	v_and_b32_e32 v5, 0xffff0000, v24
	v_lshlrev_b32_e32 v4, 16, v24
	.loc	1 33 49                         ; kernel.py:33:49
	v_pk_mul_f32 v[4:5], v[6:7], v[4:5]
	.loc	1 17 14                         ; kernel.py:17:14
	v_and_b32_e32 v7, 0xffff0000, v25
	v_lshlrev_b32_e32 v6, 16, v25
	.loc	1 33 49                         ; kernel.py:33:49
	v_pk_mul_f32 v[8:9], v[40:41], v[8:9] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[8:9], v[6:7]
	.loc	1 33 48 is_stmt 0               ; kernel.py:33:48
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	v_cvt_pk_bf16_f32 v2, v4, v5
	v_cvt_pk_bf16_f32 v3, v6, v7
	.loc	1 33 13                         ; kernel.py:33:13
	buffer_store_dwordx4 v[0:3], v46, s[0:3], 0 offen sc0 sc1
	.loc	1 8 1 is_stmt 1                 ; kernel.py:8:1
	s_endpgm
.Ltmp20:
.Lfunc_end0:
	.size	_rms_kernel, .Lfunc_end0-_rms_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rms_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 48
		.amdhsa_user_sgpr_count 14
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 12
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 49
		.amdhsa_next_free_sgpr 16
		.amdhsa_accum_offset 52
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_xnack_mask 1
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
                                        ; -- End function
	.set .L_rms_kernel.num_vgpr, 49
	.set .L_rms_kernel.num_agpr, 0
	.set .L_rms_kernel.numbered_sgpr, 16
	.set .L_rms_kernel.num_named_barrier, 0
	.set .L_rms_kernel.private_seg_size, 0
	.set .L_rms_kernel.uses_vcc, 1
	.set .L_rms_kernel.uses_flat_scratch, 0
	.set .L_rms_kernel.has_dyn_sized_stack, 0
	.set .L_rms_kernel.has_recursion, 0
	.set .L_rms_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1464
; TotalNumSgprs: 22
; NumVgprs: 49
; NumAgprs: 0
; TotalNumVgprs: 49
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 6
; NumSGPRsForWavesPerEU: 22
; NumVGPRsForWavesPerEU: 49
; AccumOffset: 52
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 14
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 12
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	.debug_abbrev,"",@progbits
	.byte	1                               ; Abbreviation Code
	.byte	17                              ; DW_TAG_compile_unit
	.byte	1                               ; DW_CHILDREN_yes
	.byte	37                              ; DW_AT_producer
	.byte	14                              ; DW_FORM_strp
	.byte	19                              ; DW_AT_language
	.byte	5                               ; DW_FORM_data2
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	16                              ; DW_AT_stmt_list
	.byte	23                              ; DW_FORM_sec_offset
	.byte	27                              ; DW_AT_comp_dir
	.byte	14                              ; DW_FORM_strp
	.ascii	"\341\177"                      ; DW_AT_APPLE_optimized
	.byte	25                              ; DW_FORM_flag_present
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	2                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	0                               ; DW_CHILDREN_no
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	32                              ; DW_AT_inline
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	3                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	1                               ; DW_CHILDREN_yes
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	4                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	11                              ; DW_FORM_data1
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	5                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	0                               ; DW_CHILDREN_no
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x52 DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
                                        ; DW_AT_APPLE_optimized
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x2c DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	29                              ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x4d:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp1-.Lfunc_begin0
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/rms_norm_triton"   ; string offset=17 ; /work/build/rms_norm_triton
.Linfo_string3:
	.asciz	"_rms_kernel"                   ; string offset=45 ; _rms_kernel
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
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 48
    .max_flat_workgroup_size: 256
    .name:           _rms_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         _rms_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     49
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa--gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
	.section	.debug_line,"",@progbits
.Lline_table_start0:
