; MIOpen rocm-7.2.4 src/kernels/MIOpenSoftmax.cl (SoftmaxBackward), src/solver/softmax/softmax.cpp:Softmax::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case softmax_bwd_c64).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SoftmaxBackward
	.globl	SoftmaxBackward
	.p2align	8
	.type	SoftmaxBackward,@function
SoftmaxBackward:
	s_load_dwordx4 s[4:7], s[0:1], 0x18
	s_load_dwordx4 s[12:15], s[0:1], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x10
	s_load_dwordx4 s[8:11], s[0:1], 0x50
	v_lshrrev_b32_e32 v2, 6, v0
	s_waitcnt lgkmcnt(0)
	s_abs_i32 s0, s6
	v_cvt_f32_u32_e32 v3, s0
	s_lshl_b32 s7, s2, 2
	v_or_b32_e32 v4, s7, v2
	v_sub_u32_e32 v5, 0, v4
	v_rcp_iflag_f32_e32 v3, v3
	s_sub_i32 s2, 0, s0
	v_max_i32_e32 v4, v4, v5
	s_xor_b32 s1, s7, s6
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	s_ashr_i32 s1, s1, 31
	v_and_b32_e32 v1, 63, v0
	v_mov_b32_e32 v8, 0
	v_mul_lo_u32 v5, s2, v3
	v_mul_hi_u32 v5, v3, v5
	v_add_u32_e32 v3, v3, v5
	v_mul_hi_u32 v3, v4, v3
	v_mul_lo_u32 v5, v3, s0
	v_sub_u32_e32 v4, v4, v5
	v_add_u32_e32 v5, 1, v3
	v_cmp_le_u32_e32 vcc, s0, v4
	s_mul_i32 s5, s5, s4
	s_nop 0
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_subrev_u32_e32 v5, s0, v4
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_add_u32_e32 v5, 1, v3
	v_cmp_le_u32_e32 vcc, s0, v4
	v_mov_b32_e32 v4, 0
	s_nop 0
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_xor_b32_e32 v5, s1, v3
	v_subrev_u32_e32 v3, s1, v5
	v_mul_i32_i24_e32 v3, s4, v3
	v_cmp_gt_i32_e32 vcc, s4, v1
	v_add3_u32 v6, v3, s1, v1
	v_mov_b32_e32 v3, 0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_6
	v_sub_u32_e32 v3, v6, v5
	v_mul_lo_u32 v3, s6, v3
	v_add3_u32 v7, v2, v3, s7
	s_lshl_b32 s11, s6, 6
	v_mov_b32_e32 v8, 0
	s_mov_b64 s[18:19], 0
	v_mov_b32_e32 v9, v1
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v4, 0
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[20:21]
	v_add_u32_e32 v9, 64, v9
	v_cmp_le_i32_e64 s[0:1], s4, v9
	s_or_b64 s[18:19], s[0:1], s[18:19]
	v_add_u32_e32 v7, s11, v7
	s_andn2_b64 exec, exec, s[18:19]
	s_cbranch_execz .LBB0_5
.LBB0_3:
	v_cmp_gt_i32_e64 s[0:1], s5, v7
	s_and_saveexec_b64 s[20:21], s[0:1]
	s_cbranch_execz .LBB0_2
	v_add_u32_e32 v12, s8, v7
	v_add_u32_e32 v10, s9, v7
	v_ashrrev_i32_e32 v13, 31, v12
	v_ashrrev_i32_e32 v11, 31, v10
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[12:13]
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[14:15]
	global_load_dword v4, v[12:13], off
	global_load_dword v3, v[10:11], off
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v8, v4, v3
	s_branch .LBB0_2
.LBB0_5:
	s_or_b64 exec, exec, s[18:19]
.LBB0_6:
	s_or_b64 exec, exec, s[2:3]
	v_lshlrev_b32_e32 v7, 2, v0
	v_cmp_gt_u32_e64 s[0:1], 32, v1
	ds_write_b32 v7, v8
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_8
	ds_read2_b32 v[8:9], v7 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_8:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e64 s[0:1], 16, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_10
	ds_read2_b32 v[8:9], v7 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_10:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e64 s[0:1], 8, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_12
	ds_read2_b32 v[8:9], v7 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_12:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e64 s[0:1], 4, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_14
	ds_read2_b32 v[8:9], v7 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_14:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e64 s[0:1], 2, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_16
	ds_read2_b32 v[8:9], v7 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_16:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_eq_u32_e64 s[0:1], 0, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_18
	ds_read2_b32 v[8:9], v7 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v8, v9, v8
	ds_write_b32 v7, v8
.LBB0_18:
	s_or_b64 exec, exec, s[2:3]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_23
	v_and_b32_e32 v0, 0xc0, v0
	v_lshlrev_b32_e32 v0, 2, v0
	ds_read_b32 v0, v0
	v_sub_u32_e32 v5, v6, v5
	v_mul_lo_u32 v5, s6, v5
	v_add3_u32 v2, v2, v5, s7
	s_lshl_b32 s6, s6, 6
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_21
.LBB0_20:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, 64, v1
	v_cmp_le_i32_e32 vcc, s4, v1
	s_or_b64 s[0:1], vcc, s[0:1]
	v_add_u32_e32 v2, s6, v2
	s_andn2_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB0_23
.LBB0_21:
	v_cmp_gt_i32_e32 vcc, s5, v2
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_20
	v_add_u32_e32 v6, s10, v2
	v_ashrrev_i32_e32 v7, 31, v6
	s_waitcnt lgkmcnt(0)
	v_sub_f32_e32 v3, v3, v0
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[16:17]
	v_mul_f32_e32 v3, v4, v3
	global_store_dword v[6:7], v3, off
	s_branch .LBB0_20
.LBB0_23:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SoftmaxBackward
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 100
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
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 22
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
	.size	SoftmaxBackward, .Lfunc_end0-SoftmaxBackward

	.set SoftmaxBackward.num_vgpr, 14
	.set SoftmaxBackward.num_agpr, 0
	.set SoftmaxBackward.numbered_sgpr, 22
	.set SoftmaxBackward.private_seg_size, 0
	.set SoftmaxBackward.uses_vcc, 1
	.set SoftmaxBackward.uses_flat_scratch, 0
	.set SoftmaxBackward.has_dyn_sized_stack, 0
	.set SoftmaxBackward.has_recursion, 0
	.set SoftmaxBackward.has_indirect_call, 0
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
        .name:           !str y
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           dy
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           dx
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           vector_size
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           grid_size
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           spatial_dim
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           input_h
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           input_w
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_nstr
        .offset:         44
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_cstr
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_hstr
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dout_nstr
        .offset:         56
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dout_cstr
        .offset:         60
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dout_hstr
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           din_nstr
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           din_cstr
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           din_hstr
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           y_offset
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dy_offset
        .offset:         84
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dx_offset
        .offset:         88
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           alpha
        .offset:         92
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         96
        .size:           4
        .type_name:      float
        .value_kind:     by_value
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 100
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SoftmaxBackward
    .private_segment_fixed_size: 0
    .sgpr_count:     28
    .sgpr_spill_count: 0
    .symbol:         SoftmaxBackward.kd
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
