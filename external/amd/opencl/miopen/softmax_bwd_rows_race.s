; MIOpen rocm-7.2.4 src/kernels/MIOpenSoftmax.cl (SoftmaxBackward), src/solver/softmax/softmax.cpp:Softmax::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case softmax_bwd_rows_race).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SoftmaxBackward
	.globl	SoftmaxBackward
	.p2align	8
	.type	SoftmaxBackward,@function
SoftmaxBackward:
	s_load_dwordx4 s[8:11], s[0:1], 0x18
	s_waitcnt lgkmcnt(0)
	s_cmp_le_i32 s9, s2
	s_cbranch_scc1 .LBB0_14
	s_load_dword s3, s[0:1], 0x68
	s_load_dword s6, s[0:1], 0x78
	s_load_dwordx4 s[12:15], s[0:1], 0x50
	s_bfe_i32 s11, s8, 0x180000
	s_add_u32 s4, s0, 0x68
	s_addc_u32 s5, s1, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s3
	s_cselect_b32 s7, 12, 18
	s_add_u32 s4, s4, s7
	s_addc_u32 s5, s5, 0
	v_mov_b32_e32 v1, 0
	global_load_ushort v2, v1, s[4:5]
	s_lshr_b32 s4, s6, 16
	s_load_dwordx4 s[16:19], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x10
	v_cmp_gt_i32_e64 s[0:1], s8, v0
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s5, v2
	s_lshr_b32 s15, s5, 1
	s_cmp_lg_u32 s4, 0
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lg_u64 s[4:5], 0
	s_addc_u32 s24, s3, 0
	s_abs_i32 s25, s10
	v_cvt_f32_u32_e32 v3, s25
	s_sub_i32 s4, 0, s25
	v_cmp_lt_u32_e32 vcc, 1, v2
	s_mov_b32 s3, 0
	v_rcp_iflag_f32_e32 v5, v3
	v_cndmask_b32_e64 v6, 0, 1, vcc
	v_lshlrev_b32_e32 v3, 2, v0
	v_mul_lo_u32 v4, s10, v2
	v_mul_f32_e32 v5, 0x4f7ffffe, v5
	v_cvt_u32_f32_e32 v5, v5
	s_ashr_i32 s26, s10, 31
	v_readfirstlane_b32 s5, v5
	s_mul_i32 s4, s4, s5
	s_mul_hi_u32 s4, s5, s4
	s_add_i32 s27, s5, s4
	v_cmp_ne_u32_e64 s[4:5], 1, v6
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[20:21]
	s_bfe_i64 s[2:3], s[2:3], 0x200000
	s_add_u32 s2, s2, s24
	s_addc_u32 s3, s3, 0
	s_cmp_le_i32 s9, s2
	s_cbranch_scc1 .LBB0_14
.LBB0_3:
	s_ashr_i32 s20, s2, 31
	s_xor_b32 s28, s20, s26
	s_abs_i32 s20, s2
	s_mul_hi_u32 s21, s20, s27
	s_mul_i32 s22, s21, s25
	s_sub_i32 s20, s20, s22
	s_add_i32 s22, s21, 1
	s_sub_i32 s23, s20, s25
	s_cmp_ge_u32 s20, s25
	s_cselect_b32 s21, s22, s21
	s_cselect_b32 s20, s23, s20
	s_add_i32 s22, s21, 1
	s_cmp_ge_u32 s20, s25
	s_cselect_b32 s20, s22, s21
	s_xor_b32 s29, s20, s28
	s_sub_i32 s30, s29, s28
	v_mov_b32_e32 v5, 0
	s_and_saveexec_b64 s[20:21], s[0:1]
	s_cbranch_execz .LBB0_7
	s_bfe_i32 s22, s30, 0x180000
	s_mul_i32 s22, s22, s11
	s_add_i32 s22, s22, s28
	v_add_u32_e32 v5, s22, v0
	v_subrev_u32_e32 v5, s29, v5
	v_mul_lo_u32 v5, s10, v5
	v_add_u32_e32 v6, s2, v5
	v_mov_b32_e32 v5, 0
	s_mov_b64 s[22:23], 0
	v_mov_b32_e32 v7, v0
.LBB0_5:
	v_add_u32_e32 v8, s12, v6
	v_add_u32_e32 v10, s13, v6
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v11, 31, v10
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[16:17]
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[18:19]
	global_load_dword v8, v[8:9], off
	global_load_dword v9, v[10:11], off
	v_add_u32_e32 v7, v7, v2
	v_cmp_le_i32_e32 vcc, s8, v7
	v_add_u32_e32 v6, v6, v4
	s_or_b64 s[22:23], vcc, s[22:23]
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v5, v8, v9
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execnz .LBB0_5
	s_or_b64 exec, exec, s[22:23]
.LBB0_7:
	s_or_b64 exec, exec, s[20:21]
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b32 s22, s15
	ds_write_b32 v3, v5
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_vccz .LBB0_12
.LBB0_8:
	s_and_saveexec_b64 s[20:21], s[0:1]
	s_cbranch_execz .LBB0_2
	s_bfe_i32 s22, s30, 0x180000
	s_mul_i32 s22, s22, s11
	ds_read_b32 v5, v1
	s_add_i32 s22, s22, s28
	v_add_u32_e32 v6, s22, v0
	v_subrev_u32_e32 v6, s29, v6
	v_mul_lo_u32 v6, s10, v6
	v_add_u32_e32 v6, s2, v6
	s_mov_b64 s[22:23], 0
	v_mov_b32_e32 v7, v0
.LBB0_10:
	v_add_u32_e32 v8, s13, v6
	v_add_u32_e32 v10, s12, v6
	v_ashrrev_i32_e32 v9, 31, v8
	v_ashrrev_i32_e32 v11, 31, v10
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[18:19]
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[16:17]
	global_load_dword v12, v[8:9], off
	global_load_dword v10, v[10:11], off
	v_add_u32_e32 v8, s14, v6
	v_add_u32_e32 v7, v7, v2
	v_ashrrev_i32_e32 v9, 31, v8
	v_cmp_le_i32_e32 vcc, s8, v7
	v_add_u32_e32 v6, v6, v4
	v_lshl_add_u64 v[8:9], v[8:9], 2, s[6:7]
	s_or_b64 s[22:23], vcc, s[22:23]
	s_waitcnt vmcnt(1) lgkmcnt(0)
	v_sub_f32_e32 v11, v12, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v10, v11, v10
	global_store_dword v[8:9], v10, off
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execnz .LBB0_10
	s_branch .LBB0_2
.LBB0_11:
	s_or_b64 exec, exec, s[20:21]
	s_lshr_b32 s20, s22, 1
	s_cmp_lt_u32 s22, 2
	s_mov_b32 s22, s20
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_scc1 .LBB0_8
.LBB0_12:
	v_cmp_gt_u32_e32 vcc, s22, v0
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB0_11
	v_lshl_add_u32 v5, s22, 2, v3
	ds_read_b32 v5, v5
	ds_read_b32 v6, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v5, v5, v6
	ds_write_b32 v3, v5
	s_branch .LBB0_11
.LBB0_14:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SoftmaxBackward
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 360
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
		.amdhsa_next_free_vgpr 13
		.amdhsa_next_free_sgpr 31
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

	.set SoftmaxBackward.num_vgpr, 13
	.set SoftmaxBackward.num_agpr, 0
	.set SoftmaxBackward.numbered_sgpr, 31
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
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         108
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         112
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         116
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         118
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         120
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         122
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         124
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         126
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         160
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         168
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 360
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SoftmaxBackward
    .private_segment_fixed_size: 0
    .sgpr_count:     37
    .sgpr_spill_count: 0
    .symbol:         SoftmaxBackward.kd
    .uses_dynamic_stack: false
    .vgpr_count:     13
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
