	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	softmax_kernel                  ; -- Begin function softmax_kernel
	.p2align	8
	.type	softmax_kernel,@function
softmax_kernel:                         ; @softmax_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.20:
	.file	1 "/work" "kernels.py"
	.loc	1 27 0 prologue_end             ; kernels.py:27:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx4 s[4:7], s[0:1], 0x8
	s_load_dwordx2 s[8:9], s[0:1], 0x18
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.21:
.LBB0_0:
.Ltmp1:
	.loc	1 32 47 is_stmt 1               ; kernels.py:32:47
	s_cmp_gt_i32 s10, 3
	s_cbranch_scc1 .LBB0_19
; %bb.1:                                ; %.lr.ph
	.loc	1 34 35                         ; kernels.py:34:35
	v_and_b32_e32 v1, 0x7f, v0
	s_movk_i32 s0, 0x64
	.loc	1 36 29                         ; kernels.py:36:29
	v_cmp_gt_u32_e64 s[0:1], s0, v1
	.loc	1 32 47                         ; kernels.py:32:47
	v_lshlrev_b32_e32 v2, 2, v1
	v_and_b32_e32 v1, 0x80, v0
	v_cmp_eq_u32_e32 vcc, 0, v1
	v_and_b32_e32 v1, 0xbf, v0
	v_cmp_eq_u32_e64 s[8:9], 0, v1
	v_lshrrev_b32_e32 v1, 4, v0
	v_mov_b32_e32 v3, 0
	v_and_b32_e32 v1, 4, v1
	v_lshl_add_u64 v[4:5], s[4:5], 0, v[2:3]
	v_add_u32_e32 v6, 0, v1
	v_cmp_gt_u32_e64 s[4:5], 2, v0
	v_lshl_add_u32 v7, v0, 2, 0
	v_cmp_eq_u32_e64 s[6:7], 0, v0
	s_and_b64 s[12:13], vcc, s[0:1]
	v_lshl_add_u64 v[0:1], s[2:3], 0, v[2:3]
	s_add_i32 s14, s10, -1
	s_mul_i32 s2, s10, 0x64
	s_mov_b32 s15, 0xc2fc0000
	v_mov_b32_e32 v2, 0x42800000
	v_not_b32_e32 v8, 63
	s_branch .LBB0_3
.LBB0_2:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 47 is_stmt 0                ; kernels.py:0:47
	s_or_b64 exec, exec, s[10:11]
	.loc	1 32 47 is_stmt 1               ; kernels.py:32:47
	s_add_i32 s14, s14, 1
	s_addk_i32 s2, 0x64
	s_cmp_lt_i32 s14, 3
	s_cbranch_scc0 .LBB0_19
.LBB0_3:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 0 47 is_stmt 0                ; kernels.py:0:47
	v_mov_b32_e32 v9, 0xff800000
	.loc	1 37 22 is_stmt 1               ; kernels.py:37:22
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_5
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 22 is_stmt 0                ; kernels.py:0:22
	s_ashr_i32 s3, s2, 31
	v_lshl_add_u64 v[10:11], s[2:3], 2, v[4:5]
	.loc	1 37 22                         ; kernels.py:37:22
	global_load_dword v9, v[10:11], off
.LBB0_5:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 22                          ; kernels.py:0:22
	s_or_b64 exec, exec, s[10:11]
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 189 40 is_stmt 1              ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_waitcnt vmcnt(0)
	v_mov_b32_dpp v10, v9 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v10, v10, v10
	v_max_f32_e32 v11, v9, v9
	v_max_f32_e32 v10, v11, v10
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_barrier
	s_nop 0
	v_mov_b32_dpp v11, v10 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_nop 1
	v_mov_b32_dpp v11, v10 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_nop 1
	v_mov_b32_dpp v11, v10 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	v_mov_b32_e32 v11, v10
	s_nop 1
	v_mov_b32_dpp v11, v11 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_nop 1
	v_mov_b32_dpp v11, v10 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 168 27                        ; standard.py:168:27 @[ kernels.py:38:37 ]
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_nop 0
	v_readlane_b32 s3, v10, 63
	s_and_saveexec_b64 s[10:11], s[8:9]
; %bb.6:                                ;   in Loop: Header=BB0_3 Depth=1
	s_nop 0
	v_mov_b32_e32 v10, s3
	ds_write_b32 v6, v10
; %bb.7:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 40 is_stmt 0                ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	v_mov_b32_e32 v10, 0
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[10:11], s[4:5]
; %bb.8:                                ;   in Loop: Header=BB0_3 Depth=1
	ds_read_b32 v10, v7
; %bb.9:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v11, v10
	s_nop 1
	v_mov_b32_dpp v11, v11 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[10:11], s[6:7]
; %bb.10:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	v_max_f32_e32 v11, v11, v11
	v_max_f32_e32 v10, v10, v10
	v_max_f32_e32 v10, v10, v11
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	ds_write_b32 v7, v10
; %bb.11:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 40                          ; standard.py:0:40
	s_or_b64 exec, exec, s[10:11]
	.loc	2 189 40                        ; standard.py:189:40 @[ kernels.py:38:37 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v10, v3
.Ltmp3:
	.loc	2 291 36 is_stmt 1              ; standard.py:291:36 @[ kernels.py:40:29 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
.Ltmp4:
	.loc	1 38 30                         ; kernels.py:38:30
	v_sub_f32_e32 v9, v9, v10
	.loc	1 39 27                         ; kernels.py:39:27
	v_mul_f32_e32 v10, 0x3fb8aa3b, v9
	v_cmp_gt_f32_e32 vcc, s15, v10
	s_nop 1
	v_cndmask_b32_e32 v10, 0, v2, vcc
	v_fmac_f32_e32 v10, 0x3fb8aa3b, v9
	v_exp_f32_e32 v9, v10
	v_cndmask_b32_e32 v10, 0, v8, vcc
	v_ldexp_f32 v9, v9, v10
.Ltmp5:
	.loc	2 261 15                        ; standard.py:261:15 @[ kernels.py:40:29 ]
	s_nop 1
	v_add_f32_dpp v10, v9, v9 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	v_mov_b32_e32 v11, v10
	s_nop 1
	v_mov_b32_dpp v11, v11 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ kernels.py:40:29 ]
	v_add_f32_e32 v10, v10, v11
	s_nop 1
	v_add_f32_dpp v10, v10, v10 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	s_nop 0
	v_readlane_b32 s3, v10, 63
	s_and_saveexec_b64 s[10:11], s[8:9]
; %bb.12:                               ;   in Loop: Header=BB0_3 Depth=1
	s_nop 0
	v_mov_b32_e32 v10, s3
	ds_write_b32 v6, v10
; %bb.13:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[10:11]
	v_mov_b32_e32 v10, 0
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[10:11], s[4:5]
; %bb.14:                               ;   in Loop: Header=BB0_3 Depth=1
	ds_read_b32 v10, v7
; %bb.15:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[10:11]
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v11, v10
	s_nop 1
	v_mov_b32_dpp v11, v11 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[10:11], s[6:7]
; %bb.16:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v10, v10, v11
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	ds_write_b32 v7, v10
; %bb.17:                               ;   in Loop: Header=BB0_3 Depth=1
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[10:11]
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
.Ltmp6:
	.loc	1 44 30 is_stmt 1               ; kernels.py:44:30
	s_and_saveexec_b64 s[10:11], s[12:13]
	s_cbranch_execz .LBB0_2
; %bb.18:                               ;   in Loop: Header=BB0_3 Depth=1
.Ltmp7:
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:40:29 ]
	ds_read_b32 v12, v3
	s_ashr_i32 s3, s2, 31
	v_lshl_add_u64 v[10:11], s[2:3], 2, v[0:1]
.Ltmp8:
	.loc	1 41 37                         ; kernels.py:41:37
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v13, s[16:17], v12, v12, v9
	v_rcp_f32_e32 v14, v13
	v_div_scale_f32 v15, vcc, v9, v12, v9
	v_fma_f32 v16, -v13, v14, 1.0
	v_fmac_f32_e32 v14, v16, v14
	v_mul_f32_e32 v16, v15, v14
	v_fma_f32 v17, -v13, v16, v15
	v_fmac_f32_e32 v16, v17, v14
	v_fma_f32 v13, -v13, v16, v15
	v_div_fmas_f32 v13, v13, v14, v16
	v_div_fixup_f32 v9, v13, v12, v9
	.loc	1 44 30                         ; kernels.py:44:30
	global_store_dword v[10:11], v9, off
	s_branch .LBB0_2
.LBB0_19:                               ; %._crit_edge
	.loc	1 32 4                          ; kernels.py:32:4
	s_endpgm
.Ltmp9:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel softmax_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 32
		.amdhsa_user_sgpr_count 10
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 8
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 18
		.amdhsa_accum_offset 20
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
.Lfunc_end0:
	.size	softmax_kernel, .Lfunc_end0-softmax_kernel
	.cfi_endproc
                                        ; -- End function
	.set softmax_kernel.num_vgpr, 18
	.set softmax_kernel.num_agpr, 0
	.set softmax_kernel.numbered_sgpr, 18
	.set softmax_kernel.private_seg_size, 0
	.set softmax_kernel.uses_vcc, 1
	.set softmax_kernel.uses_flat_scratch, 0
	.set softmax_kernel.has_dyn_sized_stack, 0
	.set softmax_kernel.has_recursion, 0
	.set softmax_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1100
; TotalNumSgprs: 24
; NumVgprs: 18
; NumAgprs: 0
; TotalNumVgprs: 18
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 24
; NumVGPRsForWavesPerEU: 18
; AccumOffset: 20
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 10
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 4
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
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
	.byte	0                               ; DW_CHILDREN_no
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
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
	.byte	11                              ; DW_FORM_data1
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
	.byte	1                               ; Abbrev [1] 0xb:0x58 DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x32 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	38                              ; DW_AT_call_line
	.byte	37                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x55:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	40                              ; DW_AT_call_line
	.byte	29                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"kernels.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work"                         ; string offset=18
.Linfo_string3:
	.asciz	"softmax_kernel"                ; string offset=24
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
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 32
    .max_flat_workgroup_size: 256
    .name:           softmax_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     24
    .sgpr_spill_count: 0
    .symbol:         softmax_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     18
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
