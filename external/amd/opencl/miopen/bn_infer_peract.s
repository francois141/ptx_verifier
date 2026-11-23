; MIOpen rocm-7.2.4 src/kernels/MIOpenBatchNormFwdInferPerAct.cl (MIOpenBatchNormFwdInferPerActivationEst), src/solver/batchnorm/forward_inference.cpp:BnFwdInference::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case bn_infer_peract).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenBatchNormFwdInferPerActivationEst
	.globl	MIOpenBatchNormFwdInferPerActivationEst
	.p2align	8
	.type	MIOpenBatchNormFwdInferPerActivationEst,@function
MIOpenBatchNormFwdInferPerActivationEst:
	s_load_dwordx4 s[8:11], s[0:1], 0x78
	s_load_dwordx4 s[4:7], s[0:1], 0x38
	s_lshl_b32 s3, s3, 8
	v_bfe_u32 v0, v0, 10, 10
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s10, s3
	s_add_i32 s2, s2, s8
	v_add_u32_e32 v0, s3, v0
	s_cmp_gt_u32 s4, s2
	v_lshlrev_b32_e32 v2, 2, v0
	v_mov_b32_e32 v1, s2
	s_cselect_b64 s[2:3], -1, 0
	v_cmp_gt_u32_e32 vcc, s5, v2
	s_and_b64 s[2:3], s[2:3], vcc
	s_and_saveexec_b64 s[4:5], s[2:3]
	s_cbranch_execz .LBB0_4
	s_load_dwordx2 s[4:5], s[0:1], 0x48
	s_load_dwordx2 s[2:3], s[0:1], 0x18
	v_mul_lo_u32 v1, s7, v1
	v_mov_b32_e32 v17, 0
	s_cmp_eq_u32 s6, 0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v0, s4, v0
	v_lshl_add_u32 v16, v0, 2, v1
	v_lshl_add_u64 v[0:1], v[16:17], 2, s[2:3]
	global_load_dwordx4 v[12:15], v[0:1], off
	s_cbranch_scc1 .LBB0_4
	s_load_dwordx2 s[2:3], s[0:1], 0x10
	s_load_dwordx4 s[8:11], s[0:1], 0x20
	s_load_dwordx2 s[12:13], s[0:1], 0x30
	v_lshlrev_b64 v[8:9], 2, v[16:17]
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[0:1], s[2:3], 0, v[8:9]
	v_lshl_add_u64 v[4:5], s[8:9], 0, v[8:9]
	v_lshl_add_u64 v[8:9], s[10:11], 0, v[8:9]
	global_load_dwordx4 v[0:3], v[0:1], off
	global_load_dwordx4 v[4:7], v[4:5], off
	global_load_dwordx4 v[8:11], v[8:9], off
	v_cvt_f32_f64_e32 v18, s[12:13]
	s_waitcnt vmcnt(3)
	v_pk_add_f32 v[12:13], v[18:19], v[12:13] op_sel_hi:[0,1]
	v_and_b32_e32 v12, 0x7fffffff, v12
	s_mov_b32 s2, 0x800000
	v_pk_add_f32 v[14:15], v[18:19], v[14:15] op_sel_hi:[0,1]
	v_mul_f32_e32 v18, 0x4b800000, v12
	v_cmp_gt_f32_e32 vcc, s2, v12
	v_and_b32_e32 v13, 0x7fffffff, v13
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	v_cndmask_b32_e32 v12, v12, v18, vcc
	v_rsq_f32_e32 v12, v12
	v_mul_f32_e32 v18, 0x4b800000, v13
	v_cmp_gt_f32_e64 s[0:1], s2, v13
	v_and_b32_e32 v14, 0x7fffffff, v14
	v_and_b32_e32 v15, 0x7fffffff, v15
	v_cndmask_b32_e64 v13, v13, v18, s[0:1]
	v_mul_f32_e32 v18, 0x45800000, v12
	v_cndmask_b32_e32 v12, v12, v18, vcc
	v_mul_f32_e32 v19, 0x4b800000, v14
	v_cmp_gt_f32_e32 vcc, s2, v14
	v_rsq_f32_e32 v13, v13
	v_cmp_gt_f32_e64 s[2:3], s2, v15
	v_cndmask_b32_e32 v14, v14, v19, vcc
	v_mul_f32_e32 v19, 0x4b800000, v15
	v_rsq_f32_e32 v14, v14
	v_cndmask_b32_e64 v15, v15, v19, s[2:3]
	v_rsq_f32_e32 v15, v15
	v_mul_f32_e32 v18, 0x45800000, v13
	v_cndmask_b32_e64 v13, v13, v18, s[0:1]
	v_mul_f32_e32 v18, 0x45800000, v14
	v_cndmask_b32_e32 v14, v14, v18, vcc
	v_mul_f32_e32 v18, 0x45800000, v15
	v_cndmask_b32_e64 v15, v15, v18, s[2:3]
.LBB0_3:
	v_lshlrev_b64 v[22:23], 2, v[16:17]
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[18:19], s[8:9], 0, v[22:23]
	global_load_dwordx4 v[18:21], v[18:19], off
	s_add_i32 s6, s6, -1
	v_add_u32_e32 v16, s5, v16
	v_lshl_add_u64 v[22:23], s[10:11], 0, v[22:23]
	s_cmp_lg_u32 s6, 0
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v21, v21, v3
	v_sub_f32_e32 v20, v20, v2
	v_sub_f32_e32 v19, v19, v1
	v_sub_f32_e32 v18, v18, v0
	v_pk_mul_f32 v[18:19], v[12:13], v[18:19]
	v_pk_mul_f32 v[20:21], v[14:15], v[20:21]
	v_pk_fma_f32 v[18:19], v[4:5], v[18:19], v[8:9]
	v_pk_fma_f32 v[20:21], v[6:7], v[20:21], v[10:11]
	global_store_dwordx4 v[22:23], v[18:21], off
	s_cbranch_scc1 .LBB0_3
.LBB0_4:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenBatchNormFwdInferPerActivationEst
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 336
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 24
		.amdhsa_next_free_sgpr 14
		.amdhsa_accum_offset 24
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
	.size	MIOpenBatchNormFwdInferPerActivationEst, .Lfunc_end0-MIOpenBatchNormFwdInferPerActivationEst

	.set MIOpenBatchNormFwdInferPerActivationEst.num_vgpr, 24
	.set MIOpenBatchNormFwdInferPerActivationEst.num_agpr, 0
	.set MIOpenBatchNormFwdInferPerActivationEst.numbered_sgpr, 14
	.set MIOpenBatchNormFwdInferPerActivationEst.private_seg_size, 0
	.set MIOpenBatchNormFwdInferPerActivationEst.uses_vcc, 1
	.set MIOpenBatchNormFwdInferPerActivationEst.uses_flat_scratch, 0
	.set MIOpenBatchNormFwdInferPerActivationEst.has_dyn_sized_stack, 0
	.set MIOpenBatchNormFwdInferPerActivationEst.has_recursion, 0
	.set MIOpenBatchNormFwdInferPerActivationEst.has_indirect_call, 0
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
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           in
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           out
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           estimatedMean
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           estimatedVariance
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           scale
        .offset:         32
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           bias
        .offset:         40
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           epsilon
        .offset:         48
        .size:           8
        .type_name:      double
        .value_kind:     by_value
      - .name:           c
        .offset:         56
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           hw
        .offset:         60
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           batchSize
        .offset:         64
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           cStride
        .offset:         68
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           hwStride
        .offset:         72
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           batchStride
        .offset:         76
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         84
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         92
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         94
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         96
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         98
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         100
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         102
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         144
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 336
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenBatchNormFwdInferPerActivationEst
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 1
      - 256
      - 1
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         MIOpenBatchNormFwdInferPerActivationEst.kd
    .uses_dynamic_stack: false
    .vgpr_count:     24
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
