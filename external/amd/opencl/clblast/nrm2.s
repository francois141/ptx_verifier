; CLBlast 1.6.3 src/kernels/level1/xnrm2.opencl (Xnrm2), Xnrm2, compiled for gfx950
; by external/amd/opencl/clblast/extract.py (case nrm2).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	Xnrm2
	.globl	Xnrm2
	.p2align	8
	.type	Xnrm2,@function
Xnrm2:
	s_mov_b32 s3, s2
	s_load_dword s2, s[0:1], 0x0
	v_lshl_or_b32 v1, s3, 8, v0
	v_mov_b32_e32 v4, 0
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e32 vcc, s2, v1
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_4
	s_load_dword s11, s[0:1], 0x20
	s_load_dwordx4 s[4:7], s[0:1], 0x8
	v_mov_b32_e32 v4, 0
	s_waitcnt lgkmcnt(0)
	s_lshl_b32 s10, s11, 8
	v_mul_lo_u32 v2, s7, v1
	s_mul_i32 s11, s11, s7
	v_add_u32_e32 v2, s6, v2
	s_lshl_b32 s11, s11, 8
	s_mov_b64 s[6:7], 0
.LBB0_2:
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[6:7], v[2:3], 2, s[4:5]
	global_load_dword v3, v[6:7], off
	v_add_u32_e32 v1, s10, v1
	v_cmp_le_i32_e32 vcc, s2, v1
	s_or_b64 s[6:7], vcc, s[6:7]
	v_add_u32_e32 v2, s11, v2
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v4, v3, v3
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execnz .LBB0_2
	s_or_b64 exec, exec, s[6:7]
.LBB0_4:
	s_or_b64 exec, exec, s[8:9]
	s_movk_i32 s2, 0x80
	v_lshlrev_b32_e32 v1, 2, v0
	v_cmp_gt_u32_e32 vcc, s2, v0
	ds_write_b32 v1, v4
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_6
	ds_read2st64_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_6:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 64, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_8
	ds_read2st64_b32 v[2:3], v1 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_8:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 32, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_10
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_10:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 16, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_12:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 8, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_14
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_14:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 4, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_16
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_16:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 2, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_18
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB0_18:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_20
	v_mov_b32_e32 v0, 0
	ds_read_b32 v2, v1
	ds_read_b32 v0, v0 offset:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v2, v0
	ds_write_b32 v1, v0
.LBB0_20:
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_22
	s_load_dwordx2 s[0:1], s[0:1], 0x18
	v_mov_b32_e32 v0, 0
	ds_read_b32 v1, v0
	s_mov_b32 s2, 0
	s_ashr_i64 s[2:3], s[2:3], 30
	s_waitcnt lgkmcnt(0)
	s_add_u32 s0, s0, s2
	s_addc_u32 s1, s1, s3
	global_store_dword v0, v1, s[0:1]
.LBB0_22:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel Xnrm2
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
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
		.amdhsa_next_free_vgpr 8
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 8
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
	.size	Xnrm2, .Lfunc_end0-Xnrm2

	.set Xnrm2.num_vgpr, 8
	.set Xnrm2.num_agpr, 0
	.set Xnrm2.numbered_sgpr, 12
	.set Xnrm2.private_seg_size, 0
	.set Xnrm2.uses_vcc, 1
	.set Xnrm2.uses_flat_scratch, 0
	.set Xnrm2.has_dyn_sized_stack, 0
	.set Xnrm2.has_recursion, 0
	.set Xnrm2.has_indirect_call, 0
	.protected	Xnrm2Epilogue
	.globl	Xnrm2Epilogue
	.p2align	8
	.type	Xnrm2Epilogue,@function
Xnrm2Epilogue:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_cmp_gt_u32_e32 vcc, 32, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[2:3]
	global_load_dword v3, v1, s[2:3] offset:256
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_2
	ds_read2_b32 v[2:3], v1 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB1_2:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e32 vcc, 16, v0
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_4
	ds_read2_b32 v[2:3], v1 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB1_4:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e32 vcc, 8, v0
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_6
	ds_read2_b32 v[2:3], v1 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB1_6:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e32 vcc, 4, v0
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_8
	ds_read2_b32 v[2:3], v1 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB1_8:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e32 vcc, 2, v0
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_10
	ds_read2_b32 v[2:3], v1 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v1, v2
.LBB1_10:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_12
	v_mov_b32_e32 v0, 0
	ds_read_b32 v2, v1
	ds_read_b32 v0, v0 offset:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v2, v0
	ds_write_b32 v1, v0
.LBB1_12:
	s_or_b64 exec, exec, s[2:3]
	s_waitcnt lgkmcnt(0)
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_14
	s_load_dword s2, s[0:1], 0x10
	s_load_dwordx2 s[0:1], s[0:1], 0x8
	v_mov_b32_e32 v0, 0
	ds_read_b32 v1, v0
	s_mov_b32 s4, 0x800000
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s3, s2, 31
	s_lshl_b64 s[2:3], s[2:3], 2
	s_add_u32 s0, s0, s2
	s_addc_u32 s1, s1, s3
	v_cmp_gt_f32_e32 vcc, s4, v1
	s_and_b64 s[2:3], vcc, exec
	s_cselect_b32 s2, 32, 0
	v_ldexp_f32 v1, v1, s2
	v_sqrt_f32_e32 v1, v1
	s_cselect_b32 s2, -16, 0
	v_ldexp_f32 v1, v1, s2
	global_store_dword v0, v1, s[0:1]
.LBB1_14:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel Xnrm2Epilogue
		.amdhsa_group_segment_fixed_size 256
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 20
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 5
		.amdhsa_accum_offset 4
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
.Lfunc_end1:
	.size	Xnrm2Epilogue, .Lfunc_end1-Xnrm2Epilogue

	.set Xnrm2Epilogue.num_vgpr, 4
	.set Xnrm2Epilogue.num_agpr, 0
	.set Xnrm2Epilogue.numbered_sgpr, 5
	.set Xnrm2Epilogue.private_seg_size, 0
	.set Xnrm2Epilogue.uses_vcc, 1
	.set Xnrm2Epilogue.uses_flat_scratch, 0
	.set Xnrm2Epilogue.has_dyn_sized_stack, 0
	.set Xnrm2Epilogue.has_recursion, 0
	.set Xnrm2Epilogue.has_indirect_call, 0
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
      - .name:           !str n
        .offset:         0
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           xgm
        .offset:         8
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           x_offset
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           x_inc
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .address_space:  global
        .name:           output
        .offset:         24
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           Xnrm2
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         Xnrm2.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           input
        .offset:         0
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           nrm2
        .offset:         8
        .size:           8
        .type_name:      'real*'
        .value_kind:     global_buffer
      - .name:           nrm2_offset
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
    .group_segment_fixed_size: 256
    .kernarg_segment_align: 8
    .kernarg_segment_size: 20
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           Xnrm2Epilogue
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 64
      - 1
      - 1
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         Xnrm2Epilogue.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
