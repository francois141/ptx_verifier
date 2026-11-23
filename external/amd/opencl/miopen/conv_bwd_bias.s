; MIOpen rocm-7.2.4 src/kernels/MIOpenConvBwdBias.cl (MIOpenConvBwdB), src/ocl/convolutionocl.cpp:ConvolutionBackwardBias, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case conv_bwd_bias).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	MIOpenConvBwdB
	.globl	MIOpenConvBwdB
	.p2align	8
	.type	MIOpenConvBwdB,@function
MIOpenConvBwdB:
	s_load_dwordx8 s[8:15], s[0:1], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x20
	s_waitcnt lgkmcnt(0)
	s_cmp_le_u32 s12, s3
	v_cmp_gt_u32_e32 vcc, s17, v0
	s_cbranch_scc1 .LBB0_16
	v_mov_b32_e32 v1, 0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_9
	v_cvt_f32_u32_e32 v2, s15
	s_and_b32 s2, s15, 0xffffff
	s_mul_i32 s18, s13, s3
	s_cmp_eq_u32 s16, 0
	v_rcp_iflag_f32_e32 v3, v2
	v_lshl_add_u32 v2, v0, 2, s18
	s_cselect_b64 s[18:19], -1, 0
	s_sub_i32 s20, 0, s15
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[6:7], 0
	s_add_i32 s24, s15, -1
	v_mul_lo_u32 v4, s20, v3
	v_mul_hi_u32 v4, v3, v4
	v_add_u32_e32 v3, v3, v4
	v_mov_b32_e32 v6, s16
	v_mov_b32_e32 v7, v0
	s_branch .LBB0_4
.LBB0_3:
	s_or_b64 exec, exec, s[20:21]
	v_add_u32_e32 v7, 0x100, v7
	v_cmp_le_u32_e32 vcc, s17, v7
	s_or_b64 s[6:7], vcc, s[6:7]
	v_add_u32_e32 v2, 0x400, v2
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execz .LBB0_8
.LBB0_4:
	v_mul_hi_u32 v4, v7, v3
	v_mul_lo_u32 v5, v4, s15
	v_sub_u32_e32 v5, v7, v5
	v_add_u32_e32 v8, 1, v4
	v_cmp_le_u32_e32 vcc, s15, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v8, vcc
	v_subrev_u32_e32 v8, s15, v5
	v_cndmask_b32_e32 v5, v5, v8, vcc
	v_add_u32_e32 v8, 1, v4
	v_cmp_le_u32_e32 vcc, s15, v5
	s_nop 1
	v_cndmask_b32_e32 v4, v4, v8, vcc
	v_mul_u32_u24_e32 v5, s2, v4
	v_sub_u32_e32 v8, v7, v5
	v_cmp_eq_u32_e32 vcc, s24, v8
	s_nop 1
	v_cndmask_b32_e32 v8, 4, v6, vcc
	v_cndmask_b32_e64 v8, v8, 4, s[18:19]
	v_cmp_lt_i32_e32 vcc, 0, v8
	s_and_saveexec_b64 s[20:21], vcc
	s_cbranch_execz .LBB0_3
	v_mad_u64_u32 v[10:11], s[22:23], v4, s14, v[2:3]
	v_lshlrev_b32_e32 v4, 2, v5
	v_sub_u32_e32 v4, v10, v4
	s_mov_b64 s[22:23], 0
.LBB0_6:
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[10:11], v[4:5], 2, s[8:9]
	global_load_dword v5, v[10:11], off
	v_add_u32_e32 v8, -1, v8
	v_cmp_eq_u32_e32 vcc, 0, v8
	s_or_b64 s[22:23], vcc, s[22:23]
	v_add_u32_e32 v4, 1, v4
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, v1, v5
	s_andn2_b64 exec, exec, s[22:23]
	s_cbranch_execnz .LBB0_6
	s_or_b64 exec, exec, s[22:23]
	s_branch .LBB0_3
.LBB0_8:
	s_or_b64 exec, exec, s[6:7]
.LBB0_9:
	s_or_b64 exec, exec, s[4:5]
	v_lshlrev_b32_e32 v2, 2, v0
	v_cmp_gt_u32_e32 vcc, 64, v0
	ds_write_b32 v2, v1
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_11
	v_mad_u32_u24 v1, v0, 12, v2
	ds_read2_b32 v[4:5], v1 offset1:1
	ds_read2_b32 v[6:7], v1 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v3, 0, v4
	v_add_f32_e32 v3, v3, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v3, v3, v6
	v_add_f32_e32 v3, v3, v7
	ds_write_b32 v1, v3
.LBB0_11:
	s_or_b64 exec, exec, s[4:5]
	v_cmp_gt_u32_e32 vcc, 16, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_13
	v_mad_u32_u24 v1, v0, 60, v2
	ds_read2_b32 v[2:3], v1 offset1:4
	ds_read2_b32 v[4:5], v1 offset0:8 offset1:12
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, 0, v2
	v_add_f32_e32 v2, v2, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v4
	v_add_f32_e32 v2, v2, v5
	ds_write_b32 v1, v2
.LBB0_13:
	s_or_b64 exec, exec, s[4:5]
	s_mov_b32 s4, 0
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_15
	v_mov_b32_e32 v1, 0
	ds_read2_b32 v[2:3], v1 offset1:16
	ds_read2_b32 v[4:5], v1 offset0:32 offset1:48
	ds_read2_b32 v[6:7], v1 offset0:64 offset1:80
	ds_read2_b32 v[8:9], v1 offset0:96 offset1:112
	ds_read2_b32 v[10:11], v1 offset0:128 offset1:144
	s_waitcnt lgkmcnt(4)
	v_add_f32_e32 v2, 0, v2
	v_add_f32_e32 v2, v2, v3
	s_waitcnt lgkmcnt(3)
	v_add_f32_e32 v2, v2, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v2, v6
	v_add_f32_e32 v2, v2, v7
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, v2, v8
	v_add_f32_e32 v4, v2, v9
	ds_read2_b32 v[2:3], v1 offset0:160 offset1:176
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v6, v4, v10
	ds_read2_b32 v[4:5], v1 offset0:192 offset1:208
	v_add_f32_e32 v8, v6, v11
	ds_read2_b32 v[6:7], v1 offset0:224 offset1:240
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v8, v2
	v_add_f32_e32 v2, v2, v3
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, v2, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v6
	v_add_f32_e32 v2, v2, v7
	ds_write_b32 v1, v2
.LBB0_15:
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v2, v1
	s_mov_b32 s5, s3
	s_ashr_i64 s[4:5], s[4:5], 30
	s_add_u32 s4, s10, s4
	s_addc_u32 s5, s11, s5
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v2, s[4:5]
.LBB0_16:
	s_load_dword s2, s[0:1], 0x3c
	s_load_dword s0, s[0:1], 0x2c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s1, s2, 0xffff
	s_add_i32 s30, s0, s1
	s_add_u32 s18, s3, s30
	s_addc_u32 s19, 0, 0
	s_cmp_le_u32 s12, s18
	s_cbranch_scc1 .LBB0_33
	v_cvt_f32_u32_e32 v2, s15
	s_and_b32 s31, s15, 0xffffff
	s_cmp_eq_u32 s16, 0
	s_cselect_b64 s[20:21], -1, 0
	v_rcp_iflag_f32_e32 v2, v2
	s_sub_i32 s6, 0, s15
	v_lshlrev_b32_e32 v1, 2, v0
	v_mad_u32_u24 v3, v0, 12, v1
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	v_mul_u32_u24_e32 v4, 48, v0
	v_cmp_gt_u32_e32 vcc, s17, v0
	s_add_i32 s33, s15, -1
	v_mul_lo_u32 v5, s6, v2
	v_mul_hi_u32 v5, v2, v5
	v_cmp_gt_u32_e64 s[0:1], 64, v0
	v_cmp_gt_u32_e64 s[2:3], 16, v0
	v_cmp_eq_u32_e64 s[4:5], 0, v0
	v_add_u32_e32 v6, v2, v5
	v_mov_b32_e32 v7, 0
	v_add_u32_e32 v8, v3, v4
	s_branch .LBB0_19
.LBB0_18:
	s_or_b64 exec, exec, s[6:7]
	s_bfe_i64 s[6:7], s[18:19], 0x200000
	s_lshl_b64 s[18:19], s[6:7], 2
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v2, v7
	s_add_u32 s22, s10, s18
	s_addc_u32 s23, s11, s19
	s_add_u32 s18, s6, s30
	s_addc_u32 s19, s7, 0
	s_cmp_gt_u32 s12, s18
	s_waitcnt lgkmcnt(0)
	global_store_dword v7, v2, s[22:23]
	s_cbranch_scc0 .LBB0_33
.LBB0_19:
	v_mov_b32_e32 v9, 0
	s_and_saveexec_b64 s[22:23], vcc
	s_cbranch_execz .LBB0_27
	s_mul_i32 s6, s18, s13
	v_add_u32_e32 v2, s6, v1
	v_mov_b32_e32 v9, 0
	s_mov_b64 s[24:25], 0
	v_mov_b32_e32 v10, v0
	s_branch .LBB0_22
.LBB0_21:
	s_or_b64 exec, exec, s[26:27]
	v_add_u32_e32 v10, 0x100, v10
	v_cmp_le_u32_e64 s[6:7], s17, v10
	s_or_b64 s[24:25], s[6:7], s[24:25]
	v_add_u32_e32 v2, 0x400, v2
	s_andn2_b64 exec, exec, s[24:25]
	s_cbranch_execz .LBB0_26
.LBB0_22:
	v_mul_hi_u32 v4, v10, v6
	v_mul_lo_u32 v5, v4, s15
	v_sub_u32_e32 v5, v10, v5
	v_add_u32_e32 v11, 1, v4
	v_cmp_le_u32_e64 s[6:7], s15, v5
	v_mov_b32_e32 v12, s16
	s_nop 0
	v_cndmask_b32_e64 v4, v4, v11, s[6:7]
	v_subrev_u32_e32 v11, s15, v5
	v_cndmask_b32_e64 v5, v5, v11, s[6:7]
	v_add_u32_e32 v11, 1, v4
	v_cmp_le_u32_e64 s[6:7], s15, v5
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v11, s[6:7]
	v_mul_u32_u24_e32 v5, s31, v4
	v_sub_u32_e32 v11, v10, v5
	v_cmp_eq_u32_e64 s[6:7], s33, v11
	s_nop 1
	v_cndmask_b32_e64 v11, 4, v12, s[6:7]
	v_cndmask_b32_e64 v11, v11, 4, s[20:21]
	v_cmp_lt_i32_e64 s[6:7], 0, v11
	s_and_saveexec_b64 s[26:27], s[6:7]
	s_cbranch_execz .LBB0_21
	v_mad_u64_u32 v[12:13], s[6:7], v4, s14, v[2:3]
	v_lshlrev_b32_e32 v4, 2, v5
	v_sub_u32_e32 v4, v12, v4
	s_mov_b64 s[28:29], 0
.LBB0_24:
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[12:13], v[4:5], 2, s[8:9]
	global_load_dword v5, v[12:13], off
	v_add_u32_e32 v11, -1, v11
	v_cmp_eq_u32_e64 s[6:7], 0, v11
	s_or_b64 s[28:29], s[6:7], s[28:29]
	v_add_u32_e32 v4, 1, v4
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v9, v9, v5
	s_andn2_b64 exec, exec, s[28:29]
	s_cbranch_execnz .LBB0_24
	s_or_b64 exec, exec, s[28:29]
	s_branch .LBB0_21
.LBB0_26:
	s_or_b64 exec, exec, s[24:25]
.LBB0_27:
	s_or_b64 exec, exec, s[22:23]
	s_barrier
	ds_write_b32 v1, v9
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[0:1]
	s_cbranch_execz .LBB0_29
	ds_read2_b32 v[4:5], v3 offset1:1
	ds_read2_b32 v[10:11], v3 offset0:2 offset1:3
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, 0, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v10
	v_add_f32_e32 v2, v2, v11
	ds_write_b32 v3, v2
.LBB0_29:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_31
	ds_read2_b32 v[4:5], v8 offset1:4
	ds_read2_b32 v[10:11], v8 offset0:8 offset1:12
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, 0, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v10
	v_add_f32_e32 v2, v2, v11
	ds_write_b32 v8, v2
.LBB0_31:
	s_or_b64 exec, exec, s[6:7]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_18
	ds_read2_b32 v[4:5], v7 offset1:16
	ds_read2_b32 v[10:11], v7 offset0:32 offset1:48
	ds_read2_b32 v[12:13], v7 offset0:64 offset1:80
	ds_read2_b32 v[14:15], v7 offset0:96 offset1:112
	ds_read2_b32 v[16:17], v7 offset0:128 offset1:144
	s_waitcnt lgkmcnt(4)
	v_add_f32_e32 v2, 0, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(3)
	v_add_f32_e32 v2, v2, v10
	v_add_f32_e32 v2, v2, v11
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v2, v12
	v_add_f32_e32 v2, v2, v13
	ds_read2_b32 v[4:5], v7 offset0:160 offset1:176
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v2, v14
	v_add_f32_e32 v2, v2, v15
	ds_read2_b32 v[10:11], v7 offset0:192 offset1:208
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v2, v16
	v_add_f32_e32 v2, v2, v17
	ds_read2_b32 v[12:13], v7 offset0:224 offset1:240
	s_waitcnt lgkmcnt(2)
	v_add_f32_e32 v2, v2, v4
	v_add_f32_e32 v2, v2, v5
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v2, v2, v10
	v_add_f32_e32 v2, v2, v11
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v12
	v_add_f32_e32 v2, v2, v13
	ds_write_b32 v7, v2
	s_branch .LBB0_18
.LBB0_33:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel MIOpenConvBwdB
		.amdhsa_group_segment_fixed_size 1024
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 296
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
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 34
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
	.size	MIOpenConvBwdB, .Lfunc_end0-MIOpenConvBwdB

	.set MIOpenConvBwdB.num_vgpr, 18
	.set MIOpenConvBwdB.num_agpr, 0
	.set MIOpenConvBwdB.numbered_sgpr, 34
	.set MIOpenConvBwdB.private_seg_size, 0
	.set MIOpenConvBwdB.uses_vcc, 1
	.set MIOpenConvBwdB.uses_flat_scratch, 0
	.set MIOpenConvBwdB.has_dyn_sized_stack, 0
	.set MIOpenConvBwdB.has_recursion, 0
	.set MIOpenConvBwdB.has_indirect_call, 0
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
        .is_const:       true
        .name:           top_df
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           bias_df
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           bias_c
        .offset:         16
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           top_str_c
        .offset:         20
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           top_str_b
        .offset:         24
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           num_spatial_work
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           off_pix
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           total_work
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         44
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         52
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         54
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         56
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         58
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         60
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         62
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         104
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 1024
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           MIOpenConvBwdB
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     40
    .sgpr_spill_count: 0
    .symbol:         MIOpenConvBwdB.kd
    .uses_dynamic_stack: false
    .vgpr_count:     18
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
