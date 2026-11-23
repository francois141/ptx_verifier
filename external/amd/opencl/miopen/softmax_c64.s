; MIOpen rocm-7.2.4 src/kernels/MIOpenSoftmax.cl (SoftmaxForward), src/solver/softmax/softmax.cpp:Softmax::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case softmax_c64).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SoftmaxForward
	.globl	SoftmaxForward
	.p2align	8
	.type	SoftmaxForward,@function
SoftmaxForward:
	s_load_dwordx8 s[12:19], s[0:1], 0x0
	s_load_dwordx2 s[20:21], s[0:1], 0x3c
	v_lshrrev_b32_e32 v2, 6, v0
	s_waitcnt lgkmcnt(0)
	s_lshl_b32 s19, s2, 2
	v_or_b32_e32 v4, s19, v2
	s_abs_i32 s0, s18
	v_cvt_f32_u32_e32 v3, s0
	v_sub_u32_e32 v5, 0, v4
	s_sub_i32 s2, 0, s0
	v_max_i32_e32 v4, v4, v5
	v_rcp_iflag_f32_e32 v3, v3
	s_xor_b32 s1, s19, s18
	s_ashr_i32 s1, s1, 31
	v_and_b32_e32 v1, 63, v0
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mov_b32_e32 v7, 0xff7fffff
	s_mul_i32 s17, s17, s16
	v_mul_lo_u32 v5, s2, v3
	v_mul_hi_u32 v5, v3, v5
	v_add_u32_e32 v3, v3, v5
	v_mul_hi_u32 v3, v4, v3
	v_mul_lo_u32 v5, v3, s0
	v_sub_u32_e32 v4, v4, v5
	v_add_u32_e32 v6, 1, v3
	v_cmp_le_u32_e32 vcc, s0, v4
	v_subrev_u32_e32 v5, s0, v4
	s_nop 0
	v_cndmask_b32_e32 v3, v3, v6, vcc
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_add_u32_e32 v5, 1, v3
	v_cmp_le_u32_e32 vcc, s0, v4
	s_nop 1
	v_cndmask_b32_e32 v3, v3, v5, vcc
	v_xor_b32_e32 v4, s1, v3
	v_subrev_u32_e32 v3, s1, v4
	v_mul_i32_i24_e32 v3, s16, v3
	v_cmp_gt_i32_e32 vcc, s16, v1
	v_add3_u32 v5, v3, s1, v1
	v_mov_b32_e32 v3, 0xff7fffff
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_6
	v_sub_u32_e32 v3, v5, v4
	v_mul_lo_u32 v3, s18, v3
	v_add3_u32 v6, v2, v3, s19
	s_lshl_b32 s8, s18, 6
	v_mov_b32_e32 v7, 0xff7fffff
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v8, v1
	v_mov_b32_e32 v3, 0xff7fffff
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v8, 64, v8
	v_cmp_le_i32_e64 s[0:1], s16, v8
	s_or_b64 s[4:5], s[0:1], s[4:5]
	v_add_u32_e32 v6, s8, v6
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_5
.LBB0_3:
	v_cmp_gt_i32_e64 s[0:1], s17, v6
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB0_2
	v_add_u32_e32 v10, s20, v6
	v_ashrrev_i32_e32 v11, 31, v10
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[12:13]
	global_load_dword v3, v[10:11], off
	v_max_f32_e32 v7, v7, v7
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v9, v3, v3
	v_max_f32_e32 v7, v9, v7
	s_branch .LBB0_2
.LBB0_5:
	s_or_b64 exec, exec, s[4:5]
.LBB0_6:
	s_or_b64 exec, exec, s[2:3]
	v_lshlrev_b32_e32 v6, 2, v0
	v_cmp_gt_u32_e64 s[0:1], 32, v1
	ds_write_b32 v6, v7
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_8
	ds_read2_b32 v[8:9], v6 offset1:32
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_8:
	s_or_b64 exec, exec, s[2:3]
	v_cmp_gt_u32_e64 s[2:3], 16, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB0_10
	ds_read2_b32 v[8:9], v6 offset1:16
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_10:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e64 s[4:5], 8, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_12
	ds_read2_b32 v[8:9], v6 offset1:8
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_12:
	s_or_b64 exec, exec, s[6:7]
	v_cmp_gt_u32_e64 s[6:7], 4, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[8:9], s[6:7]
	s_cbranch_execz .LBB0_14
	ds_read2_b32 v[8:9], v6 offset1:4
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_14:
	s_or_b64 exec, exec, s[8:9]
	v_cmp_gt_u32_e64 s[8:9], 2, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[10:11], s[8:9]
	s_cbranch_execz .LBB0_16
	ds_read2_b32 v[8:9], v6 offset1:2
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_16:
	s_or_b64 exec, exec, s[10:11]
	v_cmp_eq_u32_e64 s[10:11], 0, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[12:13], s[10:11]
	s_cbranch_execz .LBB0_18
	ds_read2_b32 v[8:9], v6 offset1:1
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v9, v9
	v_max_f32_e32 v8, v8, v8
	v_max_f32_e32 v7, v8, v7
	ds_write_b32 v6, v7
.LBB0_18:
	s_or_b64 exec, exec, s[12:13]
	v_and_b32_e32 v0, 0xc0, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v8, v0
	v_mov_b32_e32 v7, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_barrier
	s_and_saveexec_b64 s[22:23], vcc
	s_cbranch_execz .LBB0_22
	v_mov_b32_e32 v7, 0
	s_mov_b64 s[24:25], 0
	s_mov_b32 s20, 0x3fb8aa3b
	s_mov_b32 s26, 0xc2ce8ed0
	s_mov_b32 s27, 0x42b17218
	v_mov_b32_e32 v9, 0x7f800000
	v_mov_b32_e32 v10, v1
.LBB0_20:
	v_sub_f32_e32 v3, v3, v8
	v_mul_f32_e32 v11, 0x3fb8aa3b, v3
	v_fma_f32 v12, v3, s20, -v11
	v_rndne_f32_e32 v13, v11
	v_fmac_f32_e32 v12, 0x32a5705f, v3
	v_sub_f32_e32 v11, v11, v13
	v_add_f32_e32 v11, v11, v12
	v_cvt_i32_f32_e32 v12, v13
	v_exp_f32_e32 v11, v11
	v_cmp_ngt_f32_e64 s[12:13], s26, v3
	v_add_u32_e32 v10, 64, v10
	v_ldexp_f32 v11, v11, v12
	v_cndmask_b32_e64 v11, 0, v11, s[12:13]
	v_cmp_nlt_f32_e64 s[12:13], s27, v3
	s_nop 1
	v_cndmask_b32_e64 v3, v9, v11, s[12:13]
	v_cmp_le_i32_e64 s[12:13], s16, v10
	s_or_b64 s[24:25], s[12:13], s[24:25]
	v_add_f32_e32 v7, v7, v3
	s_andn2_b64 exec, exec, s[24:25]
	s_cbranch_execnz .LBB0_20
	s_or_b64 exec, exec, s[24:25]
.LBB0_22:
	s_or_b64 exec, exec, s[22:23]
	ds_write_b32 v6, v7
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[12:13], s[0:1]
	s_cbranch_execz .LBB0_24
	ds_read2_b32 v[8:9], v6 offset1:32
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_24:
	s_or_b64 exec, exec, s[12:13]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_26
	ds_read2_b32 v[8:9], v6 offset1:16
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_26:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_28
	ds_read2_b32 v[8:9], v6 offset1:8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_28:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[6:7]
	s_cbranch_execz .LBB0_30
	ds_read2_b32 v[8:9], v6 offset1:4
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_30:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_32
	ds_read2_b32 v[8:9], v6 offset1:2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_32:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], s[10:11]
	s_cbranch_execz .LBB0_34
	ds_read2_b32 v[8:9], v6 offset1:1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v7, v9, v8
	ds_write_b32 v6, v7
.LBB0_34:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_39
	ds_read_b32 v6, v0
	v_sub_u32_e32 v5, v5, v4
	v_mul_lo_u32 v5, s18, v5
	v_add3_u32 v2, v2, v5, s19
	s_lshl_b32 s4, s18, 6
	s_waitcnt lgkmcnt(0)
	v_frexp_mant_f32_e32 v4, v6
	v_rcp_f32_e32 v4, v4
	v_frexp_exp_i32_f32_e32 v0, v6
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_37
.LBB0_36:
	s_or_b64 exec, exec, s[2:3]
	v_add_u32_e32 v1, 64, v1
	v_cmp_le_i32_e32 vcc, s16, v1
	s_or_b64 s[0:1], vcc, s[0:1]
	v_add_u32_e32 v2, s4, v2
	s_andn2_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB0_39
.LBB0_37:
	v_cmp_gt_i32_e32 vcc, s17, v2
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_36
	v_add_u32_e32 v6, s21, v2
	v_frexp_exp_i32_f32_e32 v5, v3
	v_frexp_mant_f32_e32 v3, v3
	v_mul_f32_e32 v3, v3, v4
	v_sub_u32_e32 v5, v5, v0
	v_ashrrev_i32_e32 v7, 31, v6
	v_ldexp_f32 v3, v3, v5
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[14:15]
	global_store_dword v[6:7], v3, off
	s_branch .LBB0_36
.LBB0_39:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SoftmaxForward
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 76
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
		.amdhsa_next_free_sgpr 28
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
	.size	SoftmaxForward, .Lfunc_end0-SoftmaxForward

	.set SoftmaxForward.num_vgpr, 14
	.set SoftmaxForward.num_agpr, 0
	.set SoftmaxForward.numbered_sgpr, 28
	.set SoftmaxForward.private_seg_size, 0
	.set SoftmaxForward.uses_vcc, 1
	.set SoftmaxForward.uses_flat_scratch, 0
	.set SoftmaxForward.has_dyn_sized_stack, 0
	.set SoftmaxForward.has_recursion, 0
	.set SoftmaxForward.has_indirect_call, 0
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
        .name:           x
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           !str y
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           vector_size
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           grid_size
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           spatial_dim
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           input_h
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           input_w
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           in_nstr
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           in_cstr
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           in_hstr
        .offset:         44
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_nstr
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_cstr
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           out_hstr
        .offset:         56
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           x_offset
        .offset:         60
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           y_offset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           alpha
        .offset:         68
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           beta
        .offset:         72
        .size:           4
        .type_name:      float
        .value_kind:     by_value
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 76
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SoftmaxForward
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         SoftmaxForward.kd
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
