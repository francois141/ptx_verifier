; MIOpen rocm-7.2.4 src/kernels/MIOpenBatchNormFwdTrainSpatial.cl (MIOpenBatchNormFwdTrainSpatial), src/solver/batchnorm/forward_spatial.cpp:BnFwdTrainingSpatial::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case bn_train_spatial).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenBatchNormFwdTrainSpatial
	.globl	MIOpenBatchNormFwdTrainSpatial
	.p2align	8
	.type	MIOpenBatchNormFwdTrainSpatial,@function
MIOpenBatchNormFwdTrainSpatial:
	s_mov_b32 s3, 0
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_2
	s_load_dwordx4 s[8:11], s[0:1], 0x10
	s_lshl_b64 s[6:7], s[2:3], 2
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_add_u32 s10, s10, s6
	s_addc_u32 s11, s11, s7
	s_add_u32 s6, s8, s6
	s_addc_u32 s7, s9, s7
	s_load_dword s8, s[10:11], 0x0
	s_load_dword s6, s[6:7], 0x0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v2, s8
	v_mov_b32_e32 v3, s6
	ds_write_b64 v1, v[2:3] offset:32
.LBB0_2:
	s_or_b64 exec, exec, s[4:5]
	s_load_dwordx2 s[12:13], s[0:1], 0x8
	s_load_dwordx4 s[8:11], s[0:1], 0x30
	v_and_b32_e32 v1, 63, v0
	s_movk_i32 s4, 0x100
	v_lshl_or_b32 v6, s2, 6, v1
	v_cmp_gt_u32_e64 s[4:5], s4, v0
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v2, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[14:15], s[4:5]
	s_cbranch_execz .LBB0_6
	s_load_dwordx2 s[16:17], s[0:1], 0x0
	v_and_b32_e32 v2, 0xc0, v0
	v_mov_b32_e32 v3, 0
	v_add_u32_e32 v2, v6, v2
	s_movk_i32 s6, 0x200
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[16:17]
	global_load_dword v7, v[4:5], off
	v_add_u32_e32 v2, 0x100, v2
	v_cmp_gt_u32_e64 s[6:7], s6, v2
	s_waitcnt vmcnt(0)
	v_fma_f32 v4, v7, v7, 0
	s_and_saveexec_b64 s[18:19], s[6:7]
	s_cbranch_execz .LBB0_5
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[16:17]
	global_load_dword v3, v[2:3], off
.LBB0_5:
	s_or_b64 exec, exec, s[18:19]
	v_add_f32_e32 v2, 0, v7
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, v2, v3
	v_fmac_f32_e32 v4, v3, v3
.LBB0_6:
	s_or_b64 exec, exec, s[14:15]
	v_cmp_eq_u32_e64 s[6:7], 63, v1
	s_barrier
	;;#ASMSTART
	s_nop 4
	v_add_f32_dpp v2, v2, v2 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_add_f32_dpp v4, v4, v4 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 0
	v_add_f32_dpp v2, v2, v2 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_add_f32_dpp v4, v4, v4 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 0
	v_add_f32_dpp v2, v2, v2 row_shr:4 row_mask:0xf bank_mask:0xe
	v_add_f32_dpp v4, v4, v4 row_shr:4 row_mask:0xf bank_mask:0xe
	s_nop 0
	v_add_f32_dpp v2, v2, v2 row_shr:8 row_mask:0xf bank_mask:0xc
	v_add_f32_dpp v4, v4, v4 row_shr:8 row_mask:0xf bank_mask:0xc
	s_nop 0
	v_add_f32_dpp v2, v2, v2 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_add_f32_dpp v4, v4, v4 row_bcast:15 row_mask:0xa bank_mask:0xf
	s_nop 0
	v_add_f32_dpp v2, v2, v2 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_add_f32_dpp v4, v4, v4 row_bcast:31 row_mask:0xc bank_mask:0xf
	s_nop 0
	;;#ASMEND
	s_and_saveexec_b64 s[14:15], s[6:7]
	v_lshrrev_b32_e32 v1, 4, v0
	v_and_b32_e32 v1, 12, v1
	ds_write2_b32 v1, v2, v4 offset1:4
	s_or_b64 exec, exec, s[14:15]
	v_mov_b32_e32 v4, 0
	s_mov_b32 s6, 0
	v_mov_b32_e32 v5, v4
	s_waitcnt lgkmcnt(0)
	s_barrier
.LBB0_9:
	v_mov_b32_e32 v1, s6
	ds_read2_b32 v[8:9], v1 offset1:1
	ds_read2_b32 v[10:11], v1 offset0:4 offset1:5
	s_add_i32 s6, s6, 8
	s_cmp_lg_u32 s6, 16
	s_waitcnt lgkmcnt(1)
	v_mov_b32_e32 v12, v8
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v13, v10
	v_mov_b32_e32 v10, v9
	v_pk_add_f32 v[4:5], v[4:5], v[12:13]
	s_nop 0
	v_pk_add_f32 v[4:5], v[4:5], v[10:11]
	s_cbranch_scc1 .LBB0_9
	s_load_dword s6, s[0:1], 0x20
	s_load_dwordx2 s[0:1], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	v_mul_f32_e32 v2, s6, v4
	v_mul_f32_e32 v1, s6, v5
	v_fma_f32 v1, -v2, v2, v1
	v_cvt_f32_f64_e32 v4, s[0:1]
	v_cmp_ngt_f32_e64 s[0:1], 0, v1
	s_nop 1
	v_cndmask_b32_e64 v1, 0, v1, s[0:1]
	v_add_f32_e32 v1, v1, v4
	s_mov_b32 s0, 0x800000
	v_mul_f32_e32 v4, 0x4b800000, v1
	v_cmp_gt_f32_e64 s[0:1], s0, v1
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v4, s[0:1]
	v_rsq_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v4, 0x45800000, v1
	v_cndmask_b32_e64 v8, v1, v4, s[0:1]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_13
	v_mov_b32_e32 v1, 0
	ds_read_b64 v[4:5], v1 offset:32
	v_sub_f32_e32 v7, v7, v2
	v_and_b32_e32 v0, 0xc0, v0
	v_mul_f32_e32 v7, v7, v8
	v_add_u32_e32 v0, v6, v0
	s_waitcnt lgkmcnt(0)
	v_fma_f32 v9, v5, v7, v4
	v_lshl_add_u64 v[6:7], v[0:1], 2, s[12:13]
	v_add_u32_e32 v0, 0x100, v0
	s_movk_i32 s0, 0x200
	v_cmp_gt_u32_e64 s[0:1], s0, v0
	global_store_dword v[6:7], v9, off
	s_and_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB0_13
	v_sub_f32_e32 v3, v3, v2
	v_mul_f32_e32 v3, v3, v8
	v_fmac_f32_e32 v4, v5, v3
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[12:13]
	global_store_dword v[0:1], v4, off
.LBB0_13:
	s_or_b64 exec, exec, s[6:7]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_15
	s_lshl_b64 s[0:1], s[2:3], 2
	s_add_u32 s2, s10, s0
	s_addc_u32 s3, s11, s1
	s_add_u32 s0, s8, s0
	v_mov_b32_e32 v0, 0
	s_addc_u32 s1, s9, s1
	global_store_dword v0, v2, s[0:1]
	global_store_dword v0, v8, s[2:3]
.LBB0_15:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenBatchNormFwdTrainSpatial
		.amdhsa_group_segment_fixed_size 40
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 72
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
		.amdhsa_next_free_sgpr 20
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
	.size	MIOpenBatchNormFwdTrainSpatial, .Lfunc_end0-MIOpenBatchNormFwdTrainSpatial

	.set MIOpenBatchNormFwdTrainSpatial.num_vgpr, 14
	.set MIOpenBatchNormFwdTrainSpatial.num_agpr, 0
	.set MIOpenBatchNormFwdTrainSpatial.numbered_sgpr, 20
	.set MIOpenBatchNormFwdTrainSpatial.private_seg_size, 0
	.set MIOpenBatchNormFwdTrainSpatial.uses_vcc, 1
	.set MIOpenBatchNormFwdTrainSpatial.uses_flat_scratch, 0
	.set MIOpenBatchNormFwdTrainSpatial.has_dyn_sized_stack, 0
	.set MIOpenBatchNormFwdTrainSpatial.has_recursion, 0
	.set MIOpenBatchNormFwdTrainSpatial.has_indirect_call, 0
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
        .address_space:  constant
        .is_const:       true
        .is_restrict:    true
        .name:           scale
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  constant
        .is_const:       true
        .is_restrict:    true
        .name:           bias
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           INHW
        .offset:         32
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           epsilon
        .offset:         40
        .size:           8
        .type_name:      double
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           resultSaveMean
        .offset:         48
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           resultSaveInvVariance
        .offset:         56
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           _alpha
        .offset:         64
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           _beta
        .offset:         68
        .size:           4
        .type_name:      float
        .value_kind:     by_value
    .group_segment_fixed_size: 40
    .kernarg_segment_align: 8
    .kernarg_segment_size: 72
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenBatchNormFwdTrainSpatial
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         MIOpenBatchNormFwdTrainSpatial.kd
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
