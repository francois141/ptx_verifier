	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	add_kernel                      ; -- Begin function add_kernel
	.p2align	8
	.type	add_kernel,@function
add_kernel:                             ; @add_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.25:
	.file	1 "/work" "kernels.py"
	.loc	1 15 0 prologue_end             ; kernels.py:15:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.26:
.LBB0_0:
.Ltmp1:
	.loc	1 17 24 is_stmt 1               ; kernels.py:17:24
	s_lshl_b32 s0, s12, 10
	.loc	1 18 28                         ; kernels.py:18:28
	v_or_b32_e32 v0, s0, v0
	s_movk_i32 s8, 0x1000
	.loc	1 20 24                         ; kernels.py:20:24
	v_ashrrev_i32_e32 v1, 31, v0
	.loc	1 19 21                         ; kernels.py:19:21
	v_cmp_gt_i32_e32 vcc, s8, v0
	.loc	1 20 24                         ; kernels.py:20:24
	v_lshl_add_u64 v[2:3], v[0:1], 2, s[2:3]
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	.loc	1 20 16 is_stmt 0               ; kernels.py:20:16
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_2
; %bb.1:
	global_load_dword v7, v[2:3], off
.LBB0_2:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[0:1]
	.loc	1 18 28 is_stmt 1               ; kernels.py:18:28
	v_or_b32_e32 v4, 0x100, v0
	.loc	1 19 21                         ; kernels.py:19:21
	v_cmp_gt_i32_e64 s[0:1], s8, v4
	.loc	1 20 16                         ; kernels.py:20:16
	s_and_saveexec_b64 s[8:9], s[0:1]
	s_cbranch_execz .LBB0_4
; %bb.3:
	global_load_dword v6, v[2:3], off offset:1024
.LBB0_4:
	.loc	1 0 16 is_stmt 0                ; kernels.py:0:16
	s_or_b64 exec, exec, s[8:9]
	.loc	1 18 28 is_stmt 1               ; kernels.py:18:28
	v_or_b32_e32 v4, 0x200, v0
	s_movk_i32 s12, 0x1000
	.loc	1 19 21                         ; kernels.py:19:21
	v_cmp_gt_i32_e64 s[10:11], s12, v4
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	.loc	1 20 16                         ; kernels.py:20:16
	s_and_saveexec_b64 s[8:9], s[10:11]
	s_cbranch_execz .LBB0_6
; %bb.5:
	global_load_dword v9, v[2:3], off offset:2048
.LBB0_6:
	.loc	1 0 16 is_stmt 0                ; kernels.py:0:16
	s_or_b64 exec, exec, s[8:9]
	.loc	1 18 28 is_stmt 1               ; kernels.py:18:28
	v_or_b32_e32 v2, 0x300, v0
	.loc	1 19 21                         ; kernels.py:19:21
	v_cmp_gt_i32_e64 s[8:9], s12, v2
	.loc	1 20 24                         ; kernels.py:20:24
	v_ashrrev_i32_e32 v3, 31, v2
	.loc	1 20 16 is_stmt 0               ; kernels.py:20:16
	s_and_saveexec_b64 s[12:13], s[8:9]
	s_cbranch_execz .LBB0_8
; %bb.7:
	.loc	1 20 24                         ; kernels.py:20:24
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[2:3]
	.loc	1 20 16                         ; kernels.py:20:16
	global_load_dword v8, v[4:5], off
.LBB0_8:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[12:13]
	.loc	1 21 24 is_stmt 1               ; kernels.py:21:24
	v_lshl_add_u64 v[4:5], v[0:1], 2, s[4:5]
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v12, 0
	.loc	1 21 16 is_stmt 0               ; kernels.py:21:16
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_10
; %bb.9:
	global_load_dword v12, v[4:5], off
.LBB0_10:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[2:3]
	.loc	1 21 16                         ; kernels.py:21:16
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_12
; %bb.11:
	global_load_dword v10, v[4:5], off offset:1024
.LBB0_12:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v13, 0
	.loc	1 21 16                         ; kernels.py:21:16
	s_and_saveexec_b64 s[2:3], s[10:11]
	s_cbranch_execnz .LBB0_19
; %bb.13:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[2:3]
	.loc	1 21 16                         ; kernels.py:21:16
	s_and_saveexec_b64 s[2:3], s[8:9]
	s_cbranch_execnz .LBB0_20
.LBB0_14:
	.loc	1 0 16                          ; kernels.py:0:16
	s_or_b64 exec, exec, s[2:3]
	.loc	1 23 26 is_stmt 1               ; kernels.py:23:26
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[6:7]
	.loc	1 23 35 is_stmt 0               ; kernels.py:23:35
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execnz .LBB0_21
.LBB0_15:
	.loc	1 0 35                          ; kernels.py:0:35
	s_or_b64 exec, exec, s[2:3]
	.loc	1 23 35                         ; kernels.py:23:35
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_22
.LBB0_16:
	.loc	1 0 35                          ; kernels.py:0:35
	s_or_b64 exec, exec, s[2:3]
	.loc	1 23 35                         ; kernels.py:23:35
	s_and_saveexec_b64 s[0:1], s[10:11]
	s_cbranch_execnz .LBB0_23
.LBB0_17:
	.loc	1 0 35                          ; kernels.py:0:35
	s_or_b64 exec, exec, s[0:1]
	.loc	1 23 35                         ; kernels.py:23:35
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execnz .LBB0_24
.LBB0_18:
	.loc	1 23 4                          ; kernels.py:23:4
	s_endpgm
.LBB0_19:
	.loc	1 21 16 is_stmt 1               ; kernels.py:21:16
	global_load_dword v13, v[4:5], off offset:2048
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[8:9]
	s_cbranch_execz .LBB0_14
.LBB0_20:
	.loc	1 21 24 is_stmt 0               ; kernels.py:21:24
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[4:5]
	.loc	1 21 16                         ; kernels.py:21:16
	global_load_dword v11, v[4:5], off
	s_or_b64 exec, exec, s[2:3]
	.loc	1 23 26 is_stmt 1               ; kernels.py:23:26
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[6:7]
	.loc	1 23 35 is_stmt 0               ; kernels.py:23:35
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_15
.LBB0_21:
	.loc	1 0 35                          ; kernels.py:0:35
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v7, v12
	.loc	1 23 35                         ; kernels.py:23:35
	global_store_dword v[0:1], v4, off
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_16
.LBB0_22:
	.loc	1 22 17 is_stmt 1               ; kernels.py:22:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v6, v10
	.loc	1 23 35                         ; kernels.py:23:35
	global_store_dword v[0:1], v4, off offset:1024
	s_or_b64 exec, exec, s[2:3]
	s_and_saveexec_b64 s[0:1], s[10:11]
	s_cbranch_execz .LBB0_17
.LBB0_23:
	.loc	1 22 17                         ; kernels.py:22:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v9, v13
	.loc	1 23 35                         ; kernels.py:23:35
	global_store_dword v[0:1], v4, off offset:2048
	s_or_b64 exec, exec, s[0:1]
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_18
.LBB0_24:
	.loc	1 22 17                         ; kernels.py:22:17
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v8, v11
	.loc	1 23 26                         ; kernels.py:23:26
	v_lshl_add_u64 v[0:1], v[2:3], 2, s[6:7]
	.loc	1 23 35 is_stmt 0               ; kernels.py:23:35
	global_store_dword v[0:1], v4, off
	.loc	1 23 4                          ; kernels.py:23:4
	s_endpgm
.Ltmp2:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel add_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 14
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
	.size	add_kernel, .Lfunc_end0-add_kernel
	.cfi_endproc
                                        ; -- End function
	.set add_kernel.num_vgpr, 14
	.set add_kernel.num_agpr, 0
	.set add_kernel.numbered_sgpr, 14
	.set add_kernel.private_seg_size, 0
	.set add_kernel.uses_vcc, 1
	.set add_kernel.uses_flat_scratch, 0
	.set add_kernel.has_dyn_sized_stack, 0
	.set add_kernel.has_recursion, 0
	.set add_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 756
; TotalNumSgprs: 20
; NumVgprs: 14
; NumAgprs: 0
; TotalNumVgprs: 14
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 20
; NumVGPRsForWavesPerEU: 14
; AccumOffset: 16
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 12
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
	.byte	0                               ; DW_CHILDREN_no
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x1f DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"kernels.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work"                         ; string offset=18
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .max_flat_workgroup_size: 256
    .name:           add_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         add_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     14
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
