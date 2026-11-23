	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64 ; -- Begin function _silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
	.p2align	8
	.type	_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64,@function
_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64: ; @_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/fusions" "activation.py"
	.loc	1 63 0 prologue_end             ; activation.py:63:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.2:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b32 s0, s17
.Ltmp1:
	.loc	1 80 54 is_stmt 1               ; activation.py:80:54
	v_readfirstlane_b32 s1, v0
	.loc	1 79 12                         ; activation.py:79:12
	s_ashr_i32 s17, s16, 31
	s_mov_b32 s14, s9
	s_mov_b64 s[24:25], s[2:3]
	s_lshl_b64 s[2:3], s[16:17], 2
	.loc	1 79 54 is_stmt 0               ; activation.py:79:54
	s_lshr_b32 s9, s1, 6
	.loc	1 80 12 is_stmt 1               ; activation.py:80:12
	s_ashr_i32 s1, s0, 31
	.loc	1 79 12                         ; activation.py:79:12
	s_mov_b32 s17, s3
	.loc	1 80 12                         ; activation.py:80:12
	s_lshl_b64 s[18:19], s[0:1], 6
	.loc	1 99 20                         ; activation.py:99:20
	s_mul_i32 s3, s2, s11
	s_mov_b64 s[20:21], s[6:7]
	.loc	1 79 54                         ; activation.py:79:54
	v_and_b32_e32 v4, 63, v0
	.loc	1 81 13                         ; activation.py:81:13
	s_ashr_i32 s0, s8, 31
	.loc	1 99 20                         ; activation.py:99:20
	s_mul_i32 s6, s9, s11
	s_add_i32 s3, s3, s18
	.loc	1 79 12                         ; activation.py:79:12
	s_or_b32 s16, s2, s9
	.loc	1 80 12                         ; activation.py:80:12
	v_or_b32_e32 v0, s18, v4
	v_mov_b32_e32 v1, s19
	.loc	1 81 13                         ; activation.py:81:13
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s0
	.loc	1 81 40 is_stmt 0               ; activation.py:81:40
	s_ashr_i32 s15, s14, 31
	.loc	1 99 20 is_stmt 1               ; activation.py:99:20
	s_add_i32 s3, s3, s6
	.loc	1 81 13                         ; activation.py:81:13
	v_cmp_lt_i64_e32 vcc, s[16:17], v[2:3]
	.loc	1 81 40 is_stmt 0               ; activation.py:81:40
	v_cmp_gt_i64_e64 s[0:1], s[14:15], v[0:1]
	.loc	1 99 20 is_stmt 1               ; activation.py:99:20
	v_add_u32_e32 v1, s3, v4
	.loc	1 99 12 is_stmt 0               ; activation.py:99:12
	v_lshlrev_b32_e32 v2, 2, v1
	v_bfrev_b32_e32 v3, 1
	.loc	1 81 12 is_stmt 1               ; activation.py:81:12
	s_and_b64 vcc, s[0:1], vcc
	.loc	1 99 12                         ; activation.py:99:12
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	v_cndmask_b32_e32 v2, v3, v2, vcc
	buffer_load_dword v2, v2, s[4:7], 0 offen
	.loc	1 106 9                         ; activation.py:106:9
	s_mul_i32 s0, s16, s10
	.loc	1 100 10                        ; activation.py:100:10
	v_add_lshl_u32 v1, s14, v1, 2
	.loc	1 105 19                        ; activation.py:105:19
	v_add_lshl_u32 v0, v0, s0, 2
	.loc	1 100 10                        ; activation.py:100:10
	v_cndmask_b32_e32 v1, v3, v1, vcc
	.loc	1 105 19                        ; activation.py:105:19
	s_and_b32 s25, s25, 0xffff
	s_mov_b32 s26, s6
	s_mov_b32 s27, s7
	v_cndmask_b32_e32 v0, v3, v0, vcc
	.loc	1 100 10                        ; activation.py:100:10
	buffer_load_dword v1, v1, s[4:7], 0 offen
	.loc	1 115 9                         ; activation.py:115:9
	s_mul_i32 s0, s2, s12
	.loc	1 105 19                        ; activation.py:105:19
	buffer_load_dword v0, v0, s[24:27], 0 offen
	.loc	1 115 9                         ; activation.py:115:9
	s_mul_i32 s9, s9, s12
	s_add_i32 s0, s0, s18
	s_add_i32 s0, s0, s9
	v_add_u32_e32 v4, s0, v4
	.loc	1 114 5                         ; activation.py:114:5
	v_lshlrev_b32_e32 v6, 2, v4
	.loc	1 119 5                         ; activation.py:119:5
	v_add_lshl_u32 v4, s14, v4, 2
	.loc	1 114 5                         ; activation.py:114:5
	v_cndmask_b32_e32 v6, v3, v6, vcc
	.loc	1 119 5                         ; activation.py:119:5
	v_cndmask_b32_e32 v3, v3, v4, vcc
	.loc	1 114 5                         ; activation.py:114:5
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s6
	s_mov_b32 s23, s7
.Ltmp2:
	.file	2 "/work/aiter/aiter/ops/triton/_triton_kernels/common" "activation.py"
	.loc	2 17 33                         ; activation.py:17:33 @[ activation.py:109:20 ]
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v5, 0xbfb8aa3b, v2
	.loc	2 17 25 is_stmt 0               ; activation.py:17:25 @[ activation.py:109:20 ]
	v_exp_f32_e32 v5, v5
.Ltmp3:
	.loc	1 111 17 is_stmt 1              ; activation.py:111:17
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, v1, v0
.Ltmp4:
	.loc	2 17 19                         ; activation.py:17:19 @[ activation.py:109:20 ]
	v_add_f32_e32 v5, 1.0, v5
	.loc	2 17 12 is_stmt 0               ; activation.py:17:12 @[ activation.py:109:20 ]
	v_div_scale_f32 v7, s[0:1], v5, v5, 1.0
	v_rcp_f32_e32 v8, v7
	v_div_scale_f32 v4, vcc, 1.0, v5, 1.0
	v_fma_f32 v9, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v9, v8
	v_mul_f32_e32 v9, v4, v8
	v_fma_f32 v10, -v7, v9, v4
	v_fmac_f32_e32 v9, v10, v8
	v_fma_f32 v4, -v7, v9, v4
	v_div_fmas_f32 v4, v4, v8, v9
	v_div_fixup_f32 v4, v4, v5, 1.0
.Ltmp5:
	.loc	1 110 17 is_stmt 1              ; activation.py:110:17
	v_mul_f32_e32 v5, v2, v4
	.loc	1 111 17                        ; activation.py:111:17
	v_mul_f32_e32 v1, v1, v4
	.loc	1 111 66 is_stmt 0              ; activation.py:111:66
	v_sub_f32_e32 v4, 1.0, v4
	.loc	1 111 52                        ; activation.py:111:52
	v_fma_f32 v2, v2, v4, 1.0
	.loc	1 111 17                        ; activation.py:111:17
	v_mul_f32_e32 v1, v1, v2
	.loc	1 112 15 is_stmt 1              ; activation.py:112:15
	v_mul_f32_e32 v0, v0, v5
	.loc	1 114 5                         ; activation.py:114:5
	buffer_store_dword v1, v6, s[20:23], 0 offen
	.loc	1 119 5                         ; activation.py:119:5
	buffer_store_dword v0, v3, s[20:23], 0 offen
	.loc	1 63 1                          ; activation.py:63:1
	s_endpgm
.Ltmp6:
.Lfunc_end0:
	.size	_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64, .Lfunc_end0-_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 64
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 11
		.amdhsa_next_free_sgpr 28
		.amdhsa_accum_offset 12
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
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.num_vgpr, 11
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.num_agpr, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.numbered_sgpr, 28
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.num_named_barrier, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.private_seg_size, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.uses_vcc, 1
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.uses_flat_scratch, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.has_dyn_sized_stack, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.has_recursion, 0
	.set .L_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 676
; TotalNumSgprs: 34
; NumVgprs: 11
; NumAgprs: 0
; TotalNumVgprs: 11
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 34
; NumVGPRsForWavesPerEU: 11
; AccumOffset: 12
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 2
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
	.byte	1                               ; Abbrev [1] 0xb:0x44 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x1e DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	109                             ; DW_AT_call_line
	.byte	20                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"activation.py"                 ; string offset=7 ; activation.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/fusions" ; string offset=21 ; /work/aiter/aiter/ops/triton/_triton_kernels/fusions
.Linfo_string3:
	.asciz	"_silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64" ; string offset=74 ; _silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
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
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 64
    .max_flat_workgroup_size: 256
    .name:           _silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _silu_and_mul_backward_kernel_BLOCK_M_4_BLOCK_N_64.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     11
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
