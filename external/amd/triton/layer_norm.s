	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	layer_norm_fwd_kernel           ; -- Begin function layer_norm_fwd_kernel
	.p2align	8
	.type	layer_norm_fwd_kernel,@function
layer_norm_fwd_kernel:                  ; @layer_norm_fwd_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.17:
	.file	1 "/work" "kernels.py"
	.loc	1 95 0 prologue_end             ; kernels.py:95:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_load_dword s14, s[0:1], 0x30
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.18:
.LBB0_0:
.Ltmp1:
	.loc	1 99 15 is_stmt 1               ; kernels.py:99:15
	s_mul_i32 s0, s15, 0x64
	.loc	1 99 9 is_stmt 0                ; kernels.py:99:9
	s_ashr_i32 s1, s0, 31
	.loc	1 100 9 is_stmt 1               ; kernels.py:100:9
	s_lshl_b64 s[16:17], s[0:1], 2
	s_add_u32 s0, s2, s16
	.loc	1 104 34                        ; kernels.py:104:34
	v_and_b32_e32 v1, 63, v0
	.loc	1 100 9                         ; kernels.py:100:9
	s_addc_u32 s1, s3, s17
	v_lshlrev_b32_e32 v2, 2, v1
	.loc	1 105 20                        ; kernels.py:105:20
	global_load_dword v6, v2, s[0:1]
	s_movk_i32 s2, 0x64
	v_mov_b32_e32 v3, 0
	.loc	1 104 21                        ; kernels.py:104:21
	v_or_b32_e32 v1, 64, v1
	s_mov_b32 s18, s15
	v_lshl_add_u64 v[4:5], s[0:1], 0, v[2:3]
	.loc	1 105 42                        ; kernels.py:105:42
	v_cmp_gt_u32_e64 s[0:1], s2, v1
	v_mov_b32_e32 v1, 0
	.loc	1 105 20 is_stmt 0              ; kernels.py:105:20
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_2
; %bb.1:
	global_load_dword v1, v[4:5], off offset:256
.LBB0_2:
	.loc	1 0 20                          ; kernels.py:0:20
	s_or_b64 exec, exec, s[2:3]
	.loc	1 106 17 is_stmt 1              ; kernels.py:106:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v7, 0, v6
	v_add_f32_e32 v1, v7, v1
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 261 15                        ; standard.py:261:15 @[ kernels.py:107:18 ]
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:107:18 ]
	v_mov_b32_e32 v7, v1
	s_nop 1
	v_mov_b32_dpp v7, v7 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ kernels.py:107:18 ]
	v_add_f32_e32 v1, v1, v7
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:107:18 ]
	s_nop 0
	v_readlane_b32 s15, v1, 63
.Ltmp3:
	.loc	1 111 20                        ; kernels.py:111:20
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_4
; %bb.3:
	global_load_dword v3, v[4:5], off offset:256
.LBB0_4:
	.loc	1 0 20 is_stmt 0                ; kernels.py:0:20
	s_or_b64 exec, exec, s[2:3]
	s_mov_b32 s19, 0x42c80000
	.loc	1 107 35 is_stmt 1              ; kernels.py:107:35
	v_mov_b32_e32 v1, s15
	v_div_scale_f32 v7, s[2:3], s19, s19, v1
	v_rcp_f32_e32 v8, v7
	v_mov_b32_e32 v9, 0x42c80000
	v_fma_f32 v10, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v10, v8
	v_div_scale_f32 v10, vcc, s15, v9, s15
	v_mul_f32_e32 v11, v10, v8
	v_fma_f32 v12, -v7, v11, v10
	v_fmac_f32_e32 v11, v12, v8
	v_fma_f32 v7, -v7, v11, v10
	v_div_fmas_f32 v7, v7, v8, v11
	v_div_fixup_f32 v1, v7, s19, v1
	.loc	1 112 35                        ; kernels.py:112:35
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v3, v3, v1
	.loc	1 112 41 is_stmt 0              ; kernels.py:112:41
	v_cndmask_b32_e64 v3, 0, v3, s[0:1]
	.loc	1 112 35                        ; kernels.py:112:35
	v_sub_f32_e32 v6, v6, v1
	.loc	1 113 20 is_stmt 1              ; kernels.py:113:20
	v_mul_f32_e32 v3, v3, v3
	.loc	1 113 16 is_stmt 0              ; kernels.py:113:16
	v_fmac_f32_e32 v3, v6, v6
.Ltmp4:
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ kernels.py:114:17 ]
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:114:17 ]
	v_mov_b32_e32 v6, v3
	s_nop 1
	v_mov_b32_dpp v6, v6 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ kernels.py:114:17 ]
	v_add_f32_e32 v3, v3, v6
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ kernels.py:114:17 ]
	s_nop 0
	v_readlane_b32 s15, v3, 63
.Ltmp5:
	.loc	1 114 33                        ; kernels.py:114:33
	s_nop 1
	v_mov_b32_e32 v3, s15
	v_div_scale_f32 v6, s[2:3], s19, s19, v3
	v_rcp_f32_e32 v7, v6
	s_nop 0
	v_fma_f32 v8, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v8, v7
	v_div_scale_f32 v8, vcc, s15, v9, s15
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v10, -v6, v9, v8
	v_fmac_f32_e32 v9, v10, v7
	v_fma_f32 v6, -v6, v9, v8
	v_div_fmas_f32 v6, v6, v7, v9
	v_div_fixup_f32 v3, v6, s19, v3
	.loc	1 115 29                        ; kernels.py:115:29
	v_add_f32_e32 v3, s14, v3
	.loc	1 115 23 is_stmt 0              ; kernels.py:115:23
	v_sqrt_f32_e32 v3, v3
	.loc	1 115 15                        ; kernels.py:115:15
	s_nop 0
	v_div_scale_f32 v6, s[2:3], v3, v3, 1.0
	v_rcp_f32_e32 v7, v6
	s_nop 0
	v_fma_f32 v8, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v8, v7
	v_div_scale_f32 v8, vcc, 1.0, v3, 1.0
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v10, -v6, v9, v8
	v_fmac_f32_e32 v9, v10, v7
	v_fma_f32 v6, -v6, v9, v8
	v_div_fmas_f32 v6, v6, v7, v9
	v_div_fixup_f32 v3, v6, v3, 1.0
	.loc	1 116 25 is_stmt 1              ; kernels.py:116:25
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_6
; %bb.5:
	.loc	1 0 25 is_stmt 0                ; kernels.py:0:25
	s_ashr_i32 s19, s18, 31
	s_lshl_b64 s[14:15], s[18:19], 2
	s_add_u32 s12, s12, s14
	s_addc_u32 s13, s13, s15
	s_add_u32 s10, s10, s14
	v_mov_b32_e32 v6, 0
	s_addc_u32 s11, s11, s15
	.loc	1 116 25                        ; kernels.py:116:25
	global_store_dword v6, v1, s[10:11]
	.loc	1 117 25 is_stmt 1              ; kernels.py:117:25
	global_store_dword v6, v3, s[12:13]
.LBB0_6:                                ; %.critedge
	.loc	1 0 25 is_stmt 0                ; kernels.py:0:25
	s_or_b64 exec, exec, s[2:3]
	.loc	1 99 9 is_stmt 1                ; kernels.py:99:9
	s_add_u32 s2, s4, s16
	v_and_b32_e32 v0, 0xc0, v0
	s_addc_u32 s3, s5, s17
	v_cmp_eq_u32_e32 vcc, 0, v0
	.loc	1 126 27                        ; kernels.py:126:27
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_8
; %bb.7:
	.loc	1 123 20                        ; kernels.py:123:20
	global_load_dword v0, v[4:5], off
	.loc	1 122 20                        ; kernels.py:122:20
	global_load_dword v6, v2, s[8:9]
	.loc	1 121 20                        ; kernels.py:121:20
	global_load_dword v7, v2, s[6:7]
	s_waitcnt vmcnt(2)
	v_sub_f32_e32 v0, v0, v1
	v_mul_f32_e32 v0, v3, v0
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v6, v7, v0
	.loc	1 126 27                        ; kernels.py:126:27
	global_store_dword v2, v6, s[2:3]
.LBB0_8:
	.loc	1 0 27 is_stmt 0                ; kernels.py:0:27
	s_or_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v0, 0
	v_mov_b32_e32 v6, 0
	.loc	1 121 20 is_stmt 1              ; kernels.py:121:20
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB0_13
; %bb.9:
	.loc	1 0 20 is_stmt 0                ; kernels.py:0:20
	s_or_b64 exec, exec, s[4:5]
	.loc	1 122 20 is_stmt 1              ; kernels.py:122:20
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB0_14
.LBB0_10:
	.loc	1 0 20 is_stmt 0                ; kernels.py:0:20
	s_or_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v7, 0
	.loc	1 123 20 is_stmt 1              ; kernels.py:123:20
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB0_15
.LBB0_11:
	.loc	1 0 20 is_stmt 0                ; kernels.py:0:20
	s_or_b64 exec, exec, s[4:5]
	.loc	1 126 27 is_stmt 1              ; kernels.py:126:27
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execnz .LBB0_16
.LBB0_12:
	.loc	1 118 4                         ; kernels.py:118:4
	s_endpgm
.LBB0_13:
	.loc	1 121 20                        ; kernels.py:121:20
	global_load_dword v6, v2, s[6:7] offset:256
	s_or_b64 exec, exec, s[4:5]
	.loc	1 122 20                        ; kernels.py:122:20
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_10
.LBB0_14:
	global_load_dword v0, v2, s[8:9] offset:256
	s_or_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v7, 0
	.loc	1 123 20                        ; kernels.py:123:20
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_11
.LBB0_15:
	global_load_dword v7, v[4:5], off offset:256
	s_or_b64 exec, exec, s[4:5]
	.loc	1 126 27                        ; kernels.py:126:27
	s_and_b64 s[0:1], vcc, s[0:1]
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_12
.LBB0_16:
	.loc	1 0 27 is_stmt 0                ; kernels.py:0:27
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v1, v7, v1
	v_mul_f32_e32 v1, v3, v1
	v_fmac_f32_e32 v0, v6, v1
	.loc	1 126 27                        ; kernels.py:126:27
	global_store_dword v2, v0, s[2:3] offset:256
	.loc	1 118 4 is_stmt 1               ; kernels.py:118:4
	s_endpgm
.Ltmp6:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel layer_norm_fwd_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 72
		.amdhsa_user_sgpr_count 15
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 13
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
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 16
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
	.size	layer_norm_fwd_kernel, .Lfunc_end0-layer_norm_fwd_kernel
	.cfi_endproc
                                        ; -- End function
	.set layer_norm_fwd_kernel.num_vgpr, 13
	.set layer_norm_fwd_kernel.num_agpr, 0
	.set layer_norm_fwd_kernel.numbered_sgpr, 20
	.set layer_norm_fwd_kernel.private_seg_size, 0
	.set layer_norm_fwd_kernel.uses_vcc, 1
	.set layer_norm_fwd_kernel.uses_flat_scratch, 0
	.set layer_norm_fwd_kernel.has_dyn_sized_stack, 0
	.set layer_norm_fwd_kernel.has_recursion, 0
	.set layer_norm_fwd_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1164
; TotalNumSgprs: 26
; NumVgprs: 13
; NumAgprs: 0
; TotalNumVgprs: 13
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 3
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 26
; NumVGPRsForWavesPerEU: 13
; AccumOffset: 16
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 3
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x60 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x3a DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	107                             ; DW_AT_call_line
	.byte	18                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x55:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp4                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	114                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"kernels.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work"                         ; string offset=18
.Linfo_string3:
	.asciz	"layer_norm_fwd_kernel"         ; string offset=24
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
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
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
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 72
    .max_flat_workgroup_size: 256
    .name:           layer_norm_fwd_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         layer_norm_fwd_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     13
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
