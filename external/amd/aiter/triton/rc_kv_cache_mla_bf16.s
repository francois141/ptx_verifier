	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_cat_and_cache_mla_kernel       ; -- Begin function _cat_and_cache_mla_kernel
	.p2align	8
	.type	_cat_and_cache_mla_kernel,@function
_cat_and_cache_mla_kernel:              ; @_cat_and_cache_mla_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.3:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels" "kv_cache.py"
	.loc	1 148 0 prologue_end            ; kv_cache.py:148:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.4:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
.Ltmp1:
	.loc	1 179 16 is_stmt 1              ; kv_cache.py:179:16
	s_ashr_i32 s17, s16, 31
	s_mov_b64 s[24:25], s[2:3]
	s_lshl_b64 s[2:3], s[16:17], 3
	s_add_u32 s2, s8, s2
	s_addc_u32 s3, s9, s3
	s_load_dwordx2 s[2:3], s[2:3], 0x0
	.loc	1 180 8                         ; kv_cache.py:180:8
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s3, 0
	.loc	1 180 5 is_stmt 0               ; kv_cache.py:180:5
	s_cbranch_scc1 .LBB0_2
; %bb.1:
	.loc	1 174 19 is_stmt 1              ; kv_cache.py:174:19
	v_and_b32_e32 v2, 31, v0
	.loc	1 194 15                        ; kv_cache.py:194:15
	s_mul_i32 s10, s10, s16
	.loc	1 175 17                        ; kv_cache.py:175:17
	v_and_b32_e32 v1, 15, v0
	.loc	1 200 15                        ; kv_cache.py:200:15
	s_mul_i32 s12, s12, s16
	.loc	1 204 18                        ; kv_cache.py:204:18
	s_and_b32 s25, s25, 0xffff
	s_mov_b32 s27, 0x27000
	s_mov_b32 s26, 0x7ffffffe
	v_add_lshl_u32 v3, s10, v2, 1
	s_mov_b64 s[20:21], s[6:7]
	buffer_load_ushort v3, v3, s[24:27], 0 offen
	.loc	1 205 16                        ; kv_cache.py:205:16
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s26
	s_mov_b32 s7, s27
	v_add_lshl_u32 v4, s12, v1, 1
	buffer_load_ushort v4, v4, s[4:7], 0 offen
	s_load_dwordx2 s[0:1], s[0:1], 0x38
.Ltmp2:
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	v_and_b32_e32 v5, 32, v0
	v_cmp_eq_u32_e32 vcc, 0, v5
	.loc	1 135 13                        ; kv_cache.py:135:13 @[ kv_cache.py:210:9 ]
	s_mul_i32 s2, s14, s2
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	v_bfrev_b32_e32 v6, 1
.Ltmp3:
	.loc	1 188 23                        ; kv_cache.py:188:23
	s_waitcnt lgkmcnt(0)
	s_load_dword s3, s[0:1], 0x0
.Ltmp4:
	.loc	1 142 9                         ; kv_cache.py:142:9 @[ kv_cache.py:210:9 ]
	v_and_b32_e32 v0, 48, v0
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	v_add_lshl_u32 v2, s2, v2, 1
	.loc	1 143 13                        ; kv_cache.py:143:13 @[ kv_cache.py:210:9 ]
	s_add_i32 s2, s2, 32
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	v_cndmask_b32_e32 v2, v6, v2, vcc
.Ltmp5:
	.loc	1 206 26                        ; kv_cache.py:206:26
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v5, s[0:1], s3, s3, 1.0
	v_rcp_f32_e32 v7, v5
.Ltmp6:
	.loc	1 142 9                         ; kv_cache.py:142:9 @[ kv_cache.py:210:9 ]
	v_add_lshl_u32 v1, s2, v1, 1
	v_cmp_eq_u32_e32 vcc, 0, v0
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s26
	.loc	1 142 9                         ; kv_cache.py:142:9 @[ kv_cache.py:210:9 ]
	v_cndmask_b32_e32 v0, v6, v1, vcc
.Ltmp7:
	.loc	1 206 26                        ; kv_cache.py:206:26
	v_fma_f32 v6, -v5, v7, 1.0
	v_div_scale_f32 v1, vcc, 1.0, s3, 1.0
	v_fmac_f32_e32 v7, v6, v7
	v_mul_f32_e32 v6, v1, v7
	v_fma_f32 v8, -v5, v6, v1
	v_fmac_f32_e32 v6, v8, v7
	v_fma_f32 v1, -v5, v6, v1
	v_div_fmas_f32 v1, v1, v7, v6
	v_div_fixup_f32 v1, v1, s3, 1.0
.Ltmp8:
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	s_mov_b32 s23, s27
.Ltmp9:
	.loc	1 207 18                        ; kv_cache.py:207:18
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v3, 16, v3
	v_mul_f32_e32 v3, v1, v3
.Ltmp10:
	.loc	1 140 49                        ; kv_cache.py:140:49 @[ kv_cache.py:210:9 ]
	v_cvt_pk_bf16_f32 v3, v3, s0
.Ltmp11:
	.loc	1 208 16                        ; kv_cache.py:208:16
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v4, 16, v4
	v_mul_f32_e32 v1, v1, v4
.Ltmp12:
	.loc	1 143 47                        ; kv_cache.py:143:47 @[ kv_cache.py:210:9 ]
	v_cvt_pk_bf16_f32 v1, v1, s0
	.loc	1 139 9                         ; kv_cache.py:139:9 @[ kv_cache.py:210:9 ]
	buffer_store_short v3, v2, s[20:23], 0 offen
	.loc	1 142 9                         ; kv_cache.py:142:9 @[ kv_cache.py:210:9 ]
	buffer_store_short v1, v0, s[20:23], 0 offen
.Ltmp13:
.LBB0_2:
	.loc	1 148 1                         ; kv_cache.py:148:1
	s_endpgm
.Ltmp14:
.Lfunc_end0:
	.size	_cat_and_cache_mla_kernel, .Lfunc_end0-_cat_and_cache_mla_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _cat_and_cache_mla_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 80
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 9
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
	.set .L_cat_and_cache_mla_kernel.num_vgpr, 9
	.set .L_cat_and_cache_mla_kernel.num_agpr, 0
	.set .L_cat_and_cache_mla_kernel.numbered_sgpr, 28
	.set .L_cat_and_cache_mla_kernel.num_named_barrier, 0
	.set .L_cat_and_cache_mla_kernel.private_seg_size, 0
	.set .L_cat_and_cache_mla_kernel.uses_vcc, 1
	.set .L_cat_and_cache_mla_kernel.uses_flat_scratch, 0
	.set .L_cat_and_cache_mla_kernel.has_dyn_sized_stack, 0
	.set .L_cat_and_cache_mla_kernel.has_recursion, 0
	.set .L_cat_and_cache_mla_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 612
; TotalNumSgprs: 34
; NumVgprs: 9
; NumAgprs: 0
; TotalNumVgprs: 9
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 34
; NumVGPRsForWavesPerEU: 9
; AccumOffset: 12
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
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
	.byte	210                             ; DW_AT_call_line
	.byte	9                               ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kv_cache.py"                   ; string offset=7 ; kv_cache.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels" ; string offset=19 ; /work/aiter/aiter/ops/triton/_triton_kernels
.Linfo_string3:
	.asciz	"_cat_and_cache_mla_kernel"     ; string offset=64 ; _cat_and_cache_mla_kernel
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
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
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
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 80
    .max_flat_workgroup_size: 64
    .name:           _cat_and_cache_mla_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _cat_and_cache_mla_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     9
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
