; MIOpen rocm-7.2.4 src/kernels/MIOpenSoftmax.cl (SoftmaxForward), src/solver/softmax/softmax.cpp:Softmax::GetSolution, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case softmax_c1000).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SoftmaxForward
	.globl	SoftmaxForward
	.p2align	8
	.type	SoftmaxForward,@function
SoftmaxForward:
	s_load_dwordx4 s[8:11], s[0:1], 0x10
	s_waitcnt lgkmcnt(0)
	s_cmp_le_i32 s9, s2
	s_cbranch_scc1 .LBB0_22
	s_load_dword s16, s[0:1], 0x50
	s_bfe_i32 s11, s8, 0x180000
	s_add_u32 s3, s0, 0x50
	s_addc_u32 s5, s1, 0
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_u32 s2, s16
	s_cselect_b32 s4, 12, 18
	s_add_u32 s4, s3, s4
	s_addc_u32 s5, s5, 0
	s_load_dword s17, s[0:1], 0x60
	global_load_ushort v4, v1, s[4:5]
	s_load_dwordx4 s[12:15], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x3c
	s_mov_b32 s3, 0
	v_lshlrev_b32_e32 v5, 2, v0
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s4, s17, 16
	v_cmp_gt_i32_e64 s[0:1], s8, v0
	s_mov_b32 s23, 0x3fb8aa3b
	s_mov_b32 s24, 0xc2ce8ed0
	s_mov_b32 s25, 0x42b17218
	v_mov_b32_e32 v7, 0x7f800000
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s5, v4
	s_lshr_b32 s20, s5, 1
	s_cmp_lg_u32 s4, 0
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lg_u64 s[4:5], 0
	s_addc_u32 s21, s16, 0
	s_abs_i32 s22, s10
	v_cvt_f32_u32_e32 v2, s22
	s_sub_i32 s16, 0, s22
	v_cmp_lt_u32_e32 vcc, 1, v4
	v_mul_lo_u32 v6, s10, v4
	v_rcp_iflag_f32_e32 v2, v2
	v_cndmask_b32_e64 v3, 0, 1, vcc
	v_cmp_ne_u32_e64 s[4:5], 1, v3
	s_ashr_i32 s26, s10, 31
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	s_nop 0
	v_readfirstlane_b32 s17, v2
	s_mul_i32 s16, s16, s17
	s_mul_hi_u32 s16, s17, s16
	s_add_i32 s27, s17, s16
	s_branch .LBB0_3
.LBB0_2:
	s_or_b64 exec, exec, s[16:17]
	s_bfe_i64 s[2:3], s[2:3], 0x200000
	s_add_u32 s2, s2, s21
	s_addc_u32 s3, s3, 0
	s_cmp_le_i32 s9, s2
	s_cbranch_scc1 .LBB0_22
.LBB0_3:
	s_ashr_i32 s16, s2, 31
	s_xor_b32 s28, s16, s26
	s_abs_i32 s16, s2
	s_mul_hi_u32 s17, s16, s27
	s_mul_i32 s18, s17, s22
	s_sub_i32 s16, s16, s18
	s_add_i32 s18, s17, 1
	s_sub_i32 s19, s16, s22
	s_cmp_ge_u32 s16, s22
	s_cselect_b32 s17, s18, s17
	s_cselect_b32 s16, s19, s16
	s_add_i32 s18, s17, 1
	s_cmp_ge_u32 s16, s22
	s_cselect_b32 s16, s18, s17
	s_xor_b32 s29, s16, s28
	s_sub_i32 s30, s29, s28
	v_mov_b32_e32 v8, 0xff7fffff
	s_and_saveexec_b64 s[16:17], s[0:1]
	s_cbranch_execz .LBB0_7
	s_bfe_i32 s18, s30, 0x180000
	s_mul_i32 s18, s18, s11
	s_add_i32 s18, s18, s28
	v_add_u32_e32 v2, s18, v0
	v_subrev_u32_e32 v2, s29, v2
	s_add_i32 s19, s6, s2
	v_mul_lo_u32 v2, s10, v2
	v_add_u32_e32 v2, s19, v2
	v_mov_b32_e32 v8, 0xff7fffff
	s_mov_b64 s[18:19], 0
	v_mov_b32_e32 v9, v0
.LBB0_5:
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[12:13]
	global_load_dword v3, v[10:11], off
	v_add_u32_e32 v9, v9, v4
	v_max_f32_e32 v8, v8, v8
	v_cmp_le_i32_e32 vcc, s8, v9
	v_add_u32_e32 v2, v2, v6
	s_or_b64 s[18:19], vcc, s[18:19]
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v3, v3, v3
	v_max_f32_e32 v8, v3, v8
	s_andn2_b64 exec, exec, s[18:19]
	s_cbranch_execnz .LBB0_5
	s_or_b64 exec, exec, s[18:19]
.LBB0_7:
	s_or_b64 exec, exec, s[16:17]
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b32 s18, s20
	ds_write_b32 v5, v8
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_vccz .LBB0_17
.LBB0_8:
	ds_read_b32 v8, v1
	v_mov_b32_e32 v9, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[16:17], s[0:1]
	s_cbranch_execz .LBB0_12
	s_bfe_i32 s18, s30, 0x180000
	s_mul_i32 s18, s18, s11
	s_add_i32 s18, s18, s28
	v_add_u32_e32 v2, s18, v0
	v_subrev_u32_e32 v2, s29, v2
	s_add_i32 s19, s6, s2
	v_mul_lo_u32 v2, s10, v2
	v_add_u32_e32 v2, s19, v2
	v_mov_b32_e32 v9, 0
	s_mov_b64 s[18:19], 0
	v_mov_b32_e32 v10, v0
.LBB0_10:
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[12:13], v[2:3], 2, s[12:13]
	global_load_dword v3, v[12:13], off
	v_add_u32_e32 v10, v10, v4
	v_cmp_le_i32_e32 vcc, s8, v10
	s_or_b64 s[18:19], vcc, s[18:19]
	v_add_u32_e32 v2, v2, v6
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v3, v3, v8
	v_mul_f32_e32 v11, 0x3fb8aa3b, v3
	v_fma_f32 v12, v3, s23, -v11
	v_rndne_f32_e32 v13, v11
	v_fmac_f32_e32 v12, 0x32a5705f, v3
	v_sub_f32_e32 v11, v11, v13
	v_add_f32_e32 v11, v11, v12
	v_cvt_i32_f32_e32 v13, v13
	v_exp_f32_e32 v11, v11
	v_cmp_ngt_f32_e32 vcc, s24, v3
	v_ldexp_f32 v11, v11, v13
	s_nop 0
	v_cndmask_b32_e32 v11, 0, v11, vcc
	v_cmp_nlt_f32_e32 vcc, s25, v3
	s_nop 1
	v_cndmask_b32_e32 v3, v7, v11, vcc
	v_add_f32_e32 v9, v9, v3
	s_andn2_b64 exec, exec, s[18:19]
	s_cbranch_execnz .LBB0_10
	s_or_b64 exec, exec, s[18:19]
.LBB0_12:
	s_or_b64 exec, exec, s[16:17]
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b32 s18, s20
	ds_write_b32 v5, v9
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_vccz .LBB0_20
.LBB0_13:
	s_and_saveexec_b64 s[16:17], s[0:1]
	s_cbranch_execz .LBB0_2
	ds_read_b32 v3, v1
	s_bfe_i32 s18, s30, 0x180000
	s_mul_i32 s18, s18, s11
	s_add_i32 s18, s18, s28
	v_add_u32_e32 v9, s18, v0
	s_waitcnt lgkmcnt(0)
	v_frexp_exp_i32_f32_e32 v2, v3
	v_frexp_mant_f32_e32 v3, v3
	v_rcp_f32_e32 v3, v3
	v_subrev_u32_e32 v9, s29, v9
	v_mul_lo_u32 v9, s10, v9
	v_add_u32_e32 v9, s2, v9
	s_mov_b64 s[18:19], 0
	v_mov_b32_e32 v10, v0
.LBB0_15:
	v_add_u32_e32 v12, s6, v9
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[12:13]
	global_load_dword v11, v[12:13], off
	v_add_u32_e32 v10, v10, v4
	v_cmp_le_i32_e32 vcc, s8, v10
	s_or_b64 s[18:19], vcc, s[18:19]
	v_add_u32_e32 v12, s7, v9
	v_ashrrev_i32_e32 v13, 31, v12
	v_add_u32_e32 v9, v9, v6
	v_lshl_add_u64 v[12:13], v[12:13], 2, s[14:15]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v11, v11, v8
	v_mul_f32_e32 v14, 0x3fb8aa3b, v11
	v_fma_f32 v15, v11, s23, -v14
	v_rndne_f32_e32 v16, v14
	v_fmac_f32_e32 v15, 0x32a5705f, v11
	v_sub_f32_e32 v14, v14, v16
	v_add_f32_e32 v14, v14, v15
	v_cvt_i32_f32_e32 v16, v16
	v_exp_f32_e32 v14, v14
	v_cmp_ngt_f32_e32 vcc, s24, v11
	v_ldexp_f32 v14, v14, v16
	s_nop 0
	v_cndmask_b32_e32 v14, 0, v14, vcc
	v_cmp_nlt_f32_e32 vcc, s25, v11
	s_nop 1
	v_cndmask_b32_e32 v11, v7, v14, vcc
	v_frexp_exp_i32_f32_e32 v14, v11
	v_frexp_mant_f32_e32 v11, v11
	v_mul_f32_e32 v11, v11, v3
	v_sub_u32_e32 v14, v14, v2
	v_ldexp_f32 v11, v11, v14
	global_store_dword v[12:13], v11, off
	s_andn2_b64 exec, exec, s[18:19]
	s_cbranch_execnz .LBB0_15
	s_branch .LBB0_2
.LBB0_16:
	s_or_b64 exec, exec, s[16:17]
	s_lshr_b32 s16, s18, 1
	s_cmp_lt_u32 s18, 2
	s_mov_b32 s18, s16
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_scc1 .LBB0_8
.LBB0_17:
	v_cmp_gt_u32_e32 vcc, s18, v0
	s_and_saveexec_b64 s[16:17], vcc
	s_cbranch_execz .LBB0_16
	v_lshl_add_u32 v2, s18, 2, v5
	ds_read_b32 v2, v2
	ds_read_b32 v3, v5
	s_waitcnt lgkmcnt(1)
	v_max_f32_e32 v2, v2, v2
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v3, v3, v3
	v_max_f32_e32 v2, v3, v2
	ds_write_b32 v5, v2
	s_branch .LBB0_16
.LBB0_19:
	s_or_b64 exec, exec, s[16:17]
	s_lshr_b32 s16, s18, 1
	s_cmp_lt_u32 s18, 2
	s_mov_b32 s18, s16
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_cbranch_scc1 .LBB0_13
.LBB0_20:
	v_cmp_gt_u32_e32 vcc, s18, v0
	s_and_saveexec_b64 s[16:17], vcc
	s_cbranch_execz .LBB0_19
	v_lshl_add_u32 v2, s18, 2, v5
	ds_read_b32 v2, v2
	ds_read_b32 v3, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	ds_write_b32 v5, v2
	s_branch .LBB0_19
.LBB0_22:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SoftmaxForward
		.amdhsa_group_segment_fixed_size 1024
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 31
		.amdhsa_accum_offset 20
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

	.set SoftmaxForward.num_vgpr, 17
	.set SoftmaxForward.num_agpr, 0
	.set SoftmaxForward.numbered_sgpr, 31
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
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 336
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SoftmaxForward
    .private_segment_fixed_size: 0
    .sgpr_count:     37
    .sgpr_spill_count: 0
    .symbol:         SoftmaxForward.kd
    .uses_dynamic_stack: false
    .vgpr_count:     17
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
