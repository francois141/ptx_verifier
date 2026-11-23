; MIOpen rocm-7.2.4 src/kernels/MIOpenSubTensorOpWithTransformKernel.cl (SubTensorOpWithTransform2d), src/tensor.cpp:TransformTensor, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case transform_tensor).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SubTensorOpWithTransform1d
	.globl	SubTensorOpWithTransform1d
	.p2align	8
	.type	SubTensorOpWithTransform1d,@function
SubTensorOpWithTransform1d:
	s_load_dword s3, s[0:1], 0x3c
	s_load_dword s4, s[0:1], 0x58
	s_load_dword s6, s[0:1], 0x2c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v4, 4, v0
	v_cmp_gt_u32_e32 vcc, s6, v4
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_3
	s_load_dwordx4 s[12:15], s[0:1], 0x1c
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx2 s[4:5], s[0:1], 0x10
	s_load_dword s7, s[0:1], 0x8
	s_mov_b64 s[0:1], 0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v0, s14, v4
	v_mul_lo_u32 v1, s15, v4
	s_lshl_b32 s8, s14, 3
	v_add_u32_e32 v0, s12, v0
	v_add_u32_e32 v2, s13, v1
	s_lshl_b32 s9, s15, 3
	v_mov_b32_e32 v1, 0
.LBB0_2:
	v_lshl_add_u64 v[6:7], v[0:1], 2, s[2:3]
	global_load_dword v5, v[6:7], off
	v_add_u32_e32 v4, 8, v4
	v_mov_b32_e32 v3, v1
	v_cmp_le_u32_e32 vcc, s6, v4
	v_add_u32_e32 v0, s8, v0
	v_lshl_add_u64 v[6:7], v[2:3], 2, s[4:5]
	v_add_u32_e32 v2, s9, v2
	s_or_b64 s[0:1], vcc, s[0:1]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, s7, v5
	global_store_dword v[6:7], v3, off
	s_andn2_b64 exec, exec, s[0:1]
	s_cbranch_execnz .LBB0_2
.LBB0_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithTransform1d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
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
		.amdhsa_next_free_sgpr 16
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
	.size	SubTensorOpWithTransform1d, .Lfunc_end0-SubTensorOpWithTransform1d

	.set SubTensorOpWithTransform1d.num_vgpr, 8
	.set SubTensorOpWithTransform1d.num_agpr, 0
	.set SubTensorOpWithTransform1d.numbered_sgpr, 16
	.set SubTensorOpWithTransform1d.private_seg_size, 0
	.set SubTensorOpWithTransform1d.uses_vcc, 1
	.set SubTensorOpWithTransform1d.uses_flat_scratch, 0
	.set SubTensorOpWithTransform1d.has_dyn_sized_stack, 0
	.set SubTensorOpWithTransform1d.has_recursion, 0
	.set SubTensorOpWithTransform1d.has_indirect_call, 0
	.protected	SubTensorOpWithTransform2d
	.globl	SubTensorOpWithTransform2d
	.p2align	8
	.type	SubTensorOpWithTransform2d,@function
SubTensorOpWithTransform2d:
	s_load_dword s3, s[0:1], 0x4c
	s_load_dword s12, s[0:1], 0x68
	s_load_dwordx8 s[4:11], s[0:1], 0x1c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s12
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v4, 4, v0
	v_cmp_gt_u32_e32 vcc, s10, v4
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_6
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x10
	s_load_dword s14, s[0:1], 0x8
	v_and_b32_e32 v5, 15, v0
	v_mul_lo_u32 v0, s6, v4
	v_mul_lo_u32 v1, s7, v5
	v_add3_u32 v6, s4, v0, v1
	v_mul_lo_u32 v0, s8, v4
	v_mul_lo_u32 v1, s9, v5
	v_cmp_gt_u32_e32 vcc, s11, v5
	s_lshl_b32 s15, s6, 3
	s_lshl_b32 s16, s7, 4
	v_add3_u32 v7, s5, v0, v1
	s_lshl_b32 s17, s8, 3
	s_lshl_b32 s18, s9, 4
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v1, 0
	s_branch .LBB1_3
.LBB1_2:
	s_or_b64 exec, exec, s[6:7]
	v_add_u32_e32 v4, 8, v4
	v_cmp_le_u32_e64 s[0:1], s10, v4
	v_add_u32_e32 v6, s15, v6
	s_or_b64 s[4:5], s[0:1], s[4:5]
	v_add_u32_e32 v7, s17, v7
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB1_6
.LBB1_3:
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB1_2
	s_mov_b64 s[8:9], 0
	v_mov_b32_e32 v2, v7
	v_mov_b32_e32 v0, v6
	v_mov_b32_e32 v8, v5
.LBB1_5:
	s_waitcnt lgkmcnt(0)
	v_lshl_add_u64 v[10:11], v[0:1], 2, s[2:3]
	global_load_dword v9, v[10:11], off
	v_add_u32_e32 v8, 16, v8
	v_mov_b32_e32 v3, v1
	v_cmp_le_u32_e64 s[0:1], s11, v8
	v_add_u32_e32 v0, s16, v0
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[12:13]
	v_add_u32_e32 v2, s18, v2
	s_or_b64 s[8:9], s[0:1], s[8:9]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, s14, v9
	global_store_dword v[10:11], v3, off
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz .LBB1_5
	s_branch .LBB1_2
.LBB1_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithTransform2d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 320
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
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 19
		.amdhsa_accum_offset 12
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
	.size	SubTensorOpWithTransform2d, .Lfunc_end1-SubTensorOpWithTransform2d

	.set SubTensorOpWithTransform2d.num_vgpr, 12
	.set SubTensorOpWithTransform2d.num_agpr, 0
	.set SubTensorOpWithTransform2d.numbered_sgpr, 19
	.set SubTensorOpWithTransform2d.private_seg_size, 0
	.set SubTensorOpWithTransform2d.uses_vcc, 1
	.set SubTensorOpWithTransform2d.uses_flat_scratch, 0
	.set SubTensorOpWithTransform2d.has_dyn_sized_stack, 0
	.set SubTensorOpWithTransform2d.has_recursion, 0
	.set SubTensorOpWithTransform2d.has_indirect_call, 0
	.protected	SubTensorOpWithTransform3d
	.globl	SubTensorOpWithTransform3d
	.p2align	8
	.type	SubTensorOpWithTransform3d,@function
SubTensorOpWithTransform3d:
	s_load_dword s3, s[0:1], 0x54
	s_load_dword s4, s[0:1], 0x70
	s_load_dwordx4 s[12:15], s[0:1], 0x3c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s12, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB2_17
	s_load_dwordx8 s[4:11], s[0:1], 0x1c
	s_load_dwordx2 s[16:17], s[0:1], 0x0
	s_load_dwordx2 s[18:19], s[0:1], 0x10
	s_load_dword s20, s[0:1], 0x8
	v_and_b32_e32 v5, 15, v0
	s_cmp_lg_u32 s14, 0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v0, s6, v3
	v_mul_lo_u32 v1, s7, v5
	s_cselect_b64 s[2:3], -1, 0
	s_add_i32 s33, s14, -1
	v_add3_u32 v8, s4, v0, v1
	s_lshl_b32 s38, s6, 3
	s_lshl_b32 s39, s7, 4
	v_mul_lo_u32 v0, s9, v3
	v_mul_lo_u32 v1, s10, v5
	s_lshl_b32 s9, s9, 3
	s_lshl_b32 s10, s10, 4
	s_cmp_lt_u32 s14, 6
	s_cselect_b64 s[22:23], -1, 0
	s_cmp_gt_u32 s14, 5
	v_add3_u32 v9, s5, v0, v1
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lg_u32 s8, 1
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s11, 1
	s_cselect_b64 s[24:25], -1, 0
	s_or_b64 s[6:7], s[6:7], s[24:25]
	s_and_b32 s40, s14, -2
	s_cmp_lg_u32 s14, s40
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	v_cndmask_b32_e64 v1, 0, 1, s[4:5]
	v_cmp_gt_u32_e64 s[0:1], s13, v5
	s_mov_b32 s15, 0
	s_mov_b32 s21, s20
	s_mov_b64 s[24:25], 0
	s_cselect_b64 s[26:27], -1, 0
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	v_cmp_ne_u32_e64 s[4:5], 1, v1
	s_xor_b64 s[28:29], s[6:7], -1
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v10, v8
	v_mov_b32_e32 v11, v9
	s_branch .LBB2_3
.LBB2_2:
	s_or_b64 exec, exec, s[30:31]
	v_add_u32_e32 v3, 8, v3
	s_add_i32 s15, s15, 1
	v_cmp_le_u32_e32 vcc, s12, v3
	v_add_u32_e32 v11, s9, v11
	s_or_b64 s[24:25], vcc, s[24:25]
	v_add_u32_e32 v10, s38, v10
	s_andn2_b64 exec, exec, s[24:25]
	s_cbranch_execz .LBB2_17
.LBB2_3:
	s_and_saveexec_b64 s[30:31], s[0:1]
	s_cbranch_execz .LBB2_2
	s_mul_i32 s6, s38, s15
	v_add_u32_e32 v12, s6, v8
	s_mul_i32 s6, s9, s15
	v_add_u32_e32 v13, s6, v9
	s_mov_b32 s41, 0
	s_mov_b64 s[34:35], 0
	v_mov_b32_e32 v2, v10
	v_mov_b32_e32 v4, v11
	v_mov_b32_e32 v14, v5
	s_branch .LBB2_7
.LBB2_5:
	s_or_b64 exec, exec, s[6:7]
.LBB2_6:
	v_add_u32_e32 v14, 16, v14
	s_add_i32 s41, s41, 1
	v_cmp_le_u32_e32 vcc, s13, v14
	v_add_u32_e32 v4, s10, v4
	s_or_b64 s[34:35], vcc, s[34:35]
	v_add_u32_e32 v2, s39, v2
	s_andn2_b64 exec, exec, s[34:35]
	s_cbranch_execz .LBB2_2
.LBB2_7:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB2_6
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[36:37], s[22:23]
	s_cbranch_vccnz .LBB2_14
	s_mul_i32 s6, s39, s41
	v_add_u32_e32 v0, s6, v12
	s_mul_i32 s6, s10, s41
	v_add_u32_e32 v6, s6, v13
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s33, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[6:7], s33, v0
	s_and_b64 s[42:43], vcc, s[28:29]
	s_mov_b64 s[36:37], -1
	s_and_b64 s[42:43], s[42:43], s[6:7]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[6:7], s[42:43]
	s_cbranch_execz .LBB2_13
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s36, s40
.LBB2_11:
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[16:17]
	global_load_dwordx2 v[16:17], v[16:17], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s36, s36, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[18:19], v[6:7], 2, s[18:19]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s36, 0
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[16:17], s[20:21], v[16:17]
	global_store_dwordx2 v[18:19], v[16:17], off
	s_cbranch_scc1 .LBB2_11
	v_mov_b32_e32 v0, s40
	s_orn2_b64 s[36:37], s[26:27], exec
.LBB2_13:
	s_or_b64 exec, exec, s[6:7]
.LBB2_14:
	s_and_saveexec_b64 s[6:7], s[36:37]
	s_cbranch_execz .LBB2_5
	v_mad_u64_u32 v[16:17], s[36:37], s8, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[36:37], s11, v0, v[4:5]
	v_sub_u32_e32 v15, s14, v0
	s_mov_b64 s[36:37], 0
	v_mov_b32_e32 v0, v16
.LBB2_16:
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[16:17]
	global_load_dword v18, v[16:17], off
	v_add_u32_e32 v15, -1, v15
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v15
	v_add_u32_e32 v0, s8, v0
	v_lshl_add_u64 v[16:17], v[6:7], 2, s[18:19]
	v_add_u32_e32 v6, s11, v6
	s_or_b64 s[36:37], vcc, s[36:37]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v7, s20, v18
	global_store_dword v[16:17], v7, off
	s_andn2_b64 exec, exec, s[36:37]
	s_cbranch_execnz .LBB2_16
	s_branch .LBB2_5
.LBB2_17:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithTransform3d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 328
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
		.amdhsa_next_free_vgpr 20
		.amdhsa_next_free_sgpr 44
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
.Lfunc_end2:
	.size	SubTensorOpWithTransform3d, .Lfunc_end2-SubTensorOpWithTransform3d

	.set SubTensorOpWithTransform3d.num_vgpr, 20
	.set SubTensorOpWithTransform3d.num_agpr, 0
	.set SubTensorOpWithTransform3d.numbered_sgpr, 44
	.set SubTensorOpWithTransform3d.private_seg_size, 0
	.set SubTensorOpWithTransform3d.uses_vcc, 1
	.set SubTensorOpWithTransform3d.uses_flat_scratch, 0
	.set SubTensorOpWithTransform3d.has_dyn_sized_stack, 0
	.set SubTensorOpWithTransform3d.has_recursion, 0
	.set SubTensorOpWithTransform3d.has_indirect_call, 0
	.protected	SubTensorOpWithTransform4d
	.globl	SubTensorOpWithTransform4d
	.p2align	8
	.type	SubTensorOpWithTransform4d,@function
SubTensorOpWithTransform4d:
	s_load_dword s3, s[0:1], 0x64
	s_load_dword s4, s[0:1], 0x80
	s_load_dwordx4 s[16:19], s[0:1], 0x3c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s18, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB3_20
	s_load_dwordx8 s[8:15], s[0:1], 0x1c
	s_load_dwordx2 s[20:21], s[0:1], 0x4c
	s_load_dwordx2 s[22:23], s[0:1], 0x0
	s_load_dwordx2 s[24:25], s[0:1], 0x10
	s_load_dword s26, s[0:1], 0x8
	v_and_b32_e32 v5, 15, v0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s20, 0
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lg_u32 s21, 0
	s_cselect_b64 s[4:5], -1, 0
	s_add_i32 s40, s21, -1
	s_lshl_b32 s41, s10, 3
	s_lshl_b32 s42, s11, 4
	s_lshl_b32 s43, s14, 3
	s_lshl_b32 s44, s15, 4
	s_cmp_lt_u32 s21, 6
	v_mul_lo_u32 v0, s10, v3
	v_mul_lo_u32 v1, s11, v5
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_gt_u32 s21, 5
	v_add3_u32 v8, s8, v0, v1
	v_mul_lo_u32 v0, s14, v3
	v_mul_lo_u32 v1, s15, v5
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s13, 1
	v_add3_u32 v9, s9, v0, v1
	s_cselect_b64 s[8:9], -1, 0
	s_cmp_lg_u32 s17, 1
	s_cselect_b64 s[14:15], -1, 0
	s_or_b64 s[8:9], s[8:9], s[14:15]
	s_and_b32 s45, s21, -2
	s_cmp_lg_u32 s21, s45
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	v_cndmask_b32_e64 v1, 0, 1, s[4:5]
	v_cndmask_b32_e64 v2, 0, 1, s[6:7]
	v_cmp_gt_u32_e64 s[0:1], s19, v5
	s_mov_b32 s33, 0
	s_mov_b32 s27, s26
	s_mov_b64 s[14:15], 0
	s_cselect_b64 s[28:29], -1, 0
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	v_cmp_ne_u32_e64 s[4:5], 1, v1
	v_cmp_ne_u32_e64 s[6:7], 1, v2
	s_xor_b64 s[30:31], s[8:9], -1
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v10, v8
	v_mov_b32_e32 v11, v9
	s_branch .LBB3_3
.LBB3_2:
	s_or_b64 exec, exec, s[34:35]
	v_add_u32_e32 v3, 8, v3
	s_add_i32 s33, s33, 1
	v_cmp_le_u32_e32 vcc, s18, v3
	v_add_u32_e32 v11, s43, v11
	s_or_b64 s[14:15], vcc, s[14:15]
	v_add_u32_e32 v10, s41, v10
	s_andn2_b64 exec, exec, s[14:15]
	s_cbranch_execz .LBB3_20
.LBB3_3:
	s_and_saveexec_b64 s[34:35], s[0:1]
	s_cbranch_execz .LBB3_2
	s_mul_i32 s8, s41, s33
	v_add_u32_e32 v12, s8, v8
	s_mul_i32 s8, s43, s33
	v_add_u32_e32 v13, s8, v9
	s_mov_b32 s46, 0
	s_mov_b64 s[36:37], 0
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v16, v5
	s_branch .LBB3_6
.LBB3_5:
	v_add_u32_e32 v16, 16, v16
	s_add_i32 s46, s46, 1
	v_cmp_le_u32_e32 vcc, s19, v16
	v_add_u32_e32 v15, s44, v15
	s_or_b64 s[36:37], vcc, s[36:37]
	v_add_u32_e32 v14, s42, v14
	s_andn2_b64 exec, exec, s[36:37]
	s_cbranch_execz .LBB3_2
.LBB3_6:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB3_5
	s_mul_i32 s8, s42, s46
	v_add_u32_e32 v17, s8, v12
	s_mul_i32 s8, s44, s46
	v_add_u32_e32 v18, s8, v13
	s_mov_b32 s47, 0
	v_mov_b32_e32 v2, v14
	v_mov_b32_e32 v4, v15
	s_branch .LBB3_10
.LBB3_8:
	s_or_b64 exec, exec, s[8:9]
.LBB3_9:
	s_add_i32 s47, s47, 1
	v_add_u32_e32 v4, s16, v4
	s_cmp_eq_u32 s47, s20
	v_add_u32_e32 v2, s12, v2
	s_cbranch_scc1 .LBB3_5
.LBB3_10:
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB3_9
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b64 s[38:39], s[10:11]
	s_cbranch_vccnz .LBB3_17
	s_mul_i32 s8, s12, s47
	v_add_u32_e32 v0, s8, v17
	s_mul_i32 s8, s16, s47
	v_add_u32_e32 v6, s8, v18
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s40, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[8:9], s40, v0
	s_and_b64 s[48:49], vcc, s[30:31]
	s_mov_b64 s[38:39], -1
	s_and_b64 s[48:49], s[48:49], s[8:9]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[8:9], s[48:49]
	s_cbranch_execz .LBB3_16
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s38, s45
.LBB3_14:
	v_lshl_add_u64 v[20:21], v[0:1], 2, s[22:23]
	global_load_dwordx2 v[20:21], v[20:21], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s38, s38, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[22:23], v[6:7], 2, s[24:25]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s38, 0
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[20:21], s[26:27], v[20:21]
	global_store_dwordx2 v[22:23], v[20:21], off
	s_cbranch_scc1 .LBB3_14
	v_mov_b32_e32 v0, s45
	s_orn2_b64 s[38:39], s[28:29], exec
.LBB3_16:
	s_or_b64 exec, exec, s[8:9]
.LBB3_17:
	s_and_saveexec_b64 s[8:9], s[38:39]
	s_cbranch_execz .LBB3_8
	v_mad_u64_u32 v[20:21], s[38:39], s13, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[38:39], s17, v0, v[4:5]
	v_sub_u32_e32 v19, s21, v0
	s_mov_b64 s[38:39], 0
	v_mov_b32_e32 v0, v20
.LBB3_19:
	v_lshl_add_u64 v[20:21], v[0:1], 2, s[22:23]
	global_load_dword v22, v[20:21], off
	v_add_u32_e32 v19, -1, v19
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v19
	v_add_u32_e32 v0, s13, v0
	v_lshl_add_u64 v[20:21], v[6:7], 2, s[24:25]
	v_add_u32_e32 v6, s17, v6
	s_or_b64 s[38:39], vcc, s[38:39]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v7, s26, v22
	global_store_dword v[20:21], v7, off
	s_andn2_b64 exec, exec, s[38:39]
	s_cbranch_execnz .LBB3_19
	s_branch .LBB3_8
.LBB3_20:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithTransform4d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 344
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
		.amdhsa_next_free_vgpr 24
		.amdhsa_next_free_sgpr 50
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
.Lfunc_end3:
	.size	SubTensorOpWithTransform4d, .Lfunc_end3-SubTensorOpWithTransform4d

	.set SubTensorOpWithTransform4d.num_vgpr, 24
	.set SubTensorOpWithTransform4d.num_agpr, 0
	.set SubTensorOpWithTransform4d.numbered_sgpr, 50
	.set SubTensorOpWithTransform4d.private_seg_size, 0
	.set SubTensorOpWithTransform4d.uses_vcc, 1
	.set SubTensorOpWithTransform4d.uses_flat_scratch, 0
	.set SubTensorOpWithTransform4d.has_dyn_sized_stack, 0
	.set SubTensorOpWithTransform4d.has_recursion, 0
	.set SubTensorOpWithTransform4d.has_indirect_call, 0
	.protected	SubTensorOpWithTransform5d
	.globl	SubTensorOpWithTransform5d
	.p2align	8
	.type	SubTensorOpWithTransform5d,@function
SubTensorOpWithTransform5d:
	s_load_dword s3, s[0:1], 0x6c
	s_load_dword s4, s[0:1], 0x88
	s_load_dwordx16 s[8:23], s[0:1], 0x1c
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s20, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB4_23
	s_load_dwordx2 s[24:25], s[0:1], 0x0
	s_load_dwordx2 s[26:27], s[0:1], 0x10
	s_load_dword s33, s[0:1], 0x5c
	s_load_dword s28, s[0:1], 0x8
	s_cmp_lg_u32 s22, 0
	v_and_b32_e32 v5, 15, v0
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lg_u32 s23, 0
	s_cselect_b64 s[4:5], -1, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s33, 0
	v_mul_lo_u32 v0, s10, v3
	v_mul_lo_u32 v1, s11, v5
	s_cselect_b64 s[6:7], -1, 0
	s_add_i32 s47, s33, -1
	v_add3_u32 v8, s8, v0, v1
	s_lshl_b32 s48, s10, 3
	s_lshl_b32 s49, s11, 4
	v_mul_lo_u32 v0, s15, v3
	v_mul_lo_u32 v1, s16, v5
	s_lshl_b32 s15, s15, 3
	s_lshl_b32 s16, s16, 4
	s_cmp_lt_u32 s33, 6
	s_cselect_b64 s[30:31], -1, 0
	s_cmp_gt_u32 s33, 5
	v_add3_u32 v9, s9, v0, v1
	s_cselect_b64 s[8:9], -1, 0
	s_cmp_lg_u32 s14, 1
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lg_u32 s19, 1
	s_cselect_b64 s[34:35], -1, 0
	s_or_b64 s[10:11], s[10:11], s[34:35]
	s_and_b32 s50, s33, -2
	s_cmp_lg_u32 s33, s50
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	v_cndmask_b32_e64 v1, 0, 1, s[4:5]
	v_cndmask_b32_e64 v2, 0, 1, s[6:7]
	v_cndmask_b32_e64 v4, 0, 1, s[8:9]
	v_cmp_gt_u32_e64 s[0:1], s21, v5
	s_mov_b32 s46, 0
	s_mov_b32 s29, s28
	s_mov_b64 s[34:35], 0
	s_cselect_b64 s[36:37], -1, 0
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	v_cmp_ne_u32_e64 s[4:5], 1, v1
	v_cmp_ne_u32_e64 s[6:7], 1, v2
	v_cmp_ne_u32_e64 s[8:9], 1, v4
	s_xor_b64 s[38:39], s[10:11], -1
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v10, v8
	v_mov_b32_e32 v11, v9
	s_branch .LBB4_3
.LBB4_2:
	s_or_b64 exec, exec, s[40:41]
	v_add_u32_e32 v3, 8, v3
	s_add_i32 s46, s46, 1
	v_cmp_le_u32_e32 vcc, s20, v3
	v_add_u32_e32 v11, s15, v11
	s_or_b64 s[34:35], vcc, s[34:35]
	v_add_u32_e32 v10, s48, v10
	s_andn2_b64 exec, exec, s[34:35]
	s_cbranch_execz .LBB4_23
.LBB4_3:
	s_and_saveexec_b64 s[40:41], s[0:1]
	s_cbranch_execz .LBB4_2
	s_mul_i32 s10, s48, s46
	v_add_u32_e32 v12, s10, v8
	s_mul_i32 s10, s15, s46
	v_add_u32_e32 v13, s10, v9
	s_mov_b32 s51, 0
	s_mov_b64 s[42:43], 0
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v16, v5
	s_branch .LBB4_6
.LBB4_5:
	v_add_u32_e32 v16, 16, v16
	s_add_i32 s51, s51, 1
	v_cmp_le_u32_e32 vcc, s21, v16
	v_add_u32_e32 v15, s16, v15
	s_or_b64 s[42:43], vcc, s[42:43]
	v_add_u32_e32 v14, s49, v14
	s_andn2_b64 exec, exec, s[42:43]
	s_cbranch_execz .LBB4_2
.LBB4_6:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB4_5
	s_mul_i32 s10, s49, s51
	v_add_u32_e32 v17, s10, v12
	s_mul_i32 s10, s16, s51
	v_add_u32_e32 v18, s10, v13
	s_mov_b32 s52, 0
	v_mov_b32_e32 v19, v14
	v_mov_b32_e32 v20, v15
	s_branch .LBB4_9
.LBB4_8:
	s_add_i32 s52, s52, 1
	v_add_u32_e32 v20, s17, v20
	s_cmp_eq_u32 s52, s22
	v_add_u32_e32 v19, s12, v19
	s_cbranch_scc1 .LBB4_5
.LBB4_9:
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB4_8
	s_mul_i32 s10, s12, s52
	v_add_u32_e32 v21, s10, v17
	s_mul_i32 s10, s17, s52
	v_add_u32_e32 v22, s10, v18
	s_mov_b32 s53, 0
	v_mov_b32_e32 v2, v19
	v_mov_b32_e32 v4, v20
	s_branch .LBB4_13
.LBB4_11:
	s_or_b64 exec, exec, s[10:11]
.LBB4_12:
	s_add_i32 s53, s53, 1
	v_add_u32_e32 v4, s18, v4
	s_cmp_eq_u32 s53, s23
	v_add_u32_e32 v2, s13, v2
	s_cbranch_scc1 .LBB4_8
.LBB4_13:
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB4_12
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[8:9]
	s_mov_b64 s[44:45], s[30:31]
	s_cbranch_vccnz .LBB4_20
	s_mul_i32 s10, s13, s53
	v_add_u32_e32 v0, s10, v21
	s_mul_i32 s10, s18, s53
	v_add_u32_e32 v6, s10, v22
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s47, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[10:11], s47, v0
	s_and_b64 s[54:55], vcc, s[38:39]
	s_mov_b64 s[44:45], -1
	s_and_b64 s[54:55], s[54:55], s[10:11]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[10:11], s[54:55]
	s_cbranch_execz .LBB4_19
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s44, s50
.LBB4_17:
	v_lshl_add_u64 v[24:25], v[0:1], 2, s[24:25]
	global_load_dwordx2 v[24:25], v[24:25], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s44, s44, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[26:27], v[6:7], 2, s[26:27]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s44, 0
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[24:25], s[28:29], v[24:25]
	global_store_dwordx2 v[26:27], v[24:25], off
	s_cbranch_scc1 .LBB4_17
	v_mov_b32_e32 v0, s50
	s_orn2_b64 s[44:45], s[36:37], exec
.LBB4_19:
	s_or_b64 exec, exec, s[10:11]
.LBB4_20:
	s_and_saveexec_b64 s[10:11], s[44:45]
	s_cbranch_execz .LBB4_11
	v_mad_u64_u32 v[24:25], s[44:45], s14, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[44:45], s19, v0, v[4:5]
	v_sub_u32_e32 v23, s33, v0
	s_mov_b64 s[44:45], 0
	v_mov_b32_e32 v0, v24
.LBB4_22:
	v_lshl_add_u64 v[24:25], v[0:1], 2, s[24:25]
	global_load_dword v26, v[24:25], off
	v_add_u32_e32 v23, -1, v23
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v23
	v_add_u32_e32 v0, s14, v0
	v_lshl_add_u64 v[24:25], v[6:7], 2, s[26:27]
	v_add_u32_e32 v6, s19, v6
	s_or_b64 s[44:45], vcc, s[44:45]
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v7, s28, v26
	global_store_dword v[24:25], v7, off
	s_andn2_b64 exec, exec, s[44:45]
	s_cbranch_execnz .LBB4_22
	s_branch .LBB4_11
.LBB4_23:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithTransform5d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 352
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
		.amdhsa_next_free_vgpr 28
		.amdhsa_next_free_sgpr 56
		.amdhsa_accum_offset 28
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
.Lfunc_end4:
	.size	SubTensorOpWithTransform5d, .Lfunc_end4-SubTensorOpWithTransform5d

	.set SubTensorOpWithTransform5d.num_vgpr, 28
	.set SubTensorOpWithTransform5d.num_agpr, 0
	.set SubTensorOpWithTransform5d.numbered_sgpr, 56
	.set SubTensorOpWithTransform5d.private_seg_size, 0
	.set SubTensorOpWithTransform5d.uses_vcc, 1
	.set SubTensorOpWithTransform5d.uses_flat_scratch, 0
	.set SubTensorOpWithTransform5d.has_dyn_sized_stack, 0
	.set SubTensorOpWithTransform5d.has_recursion, 0
	.set SubTensorOpWithTransform5d.has_indirect_call, 0
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
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           alpha
        .offset:         8
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           beta
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           src_offset
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_offset
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride0
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride0
        .offset:         40
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len0
        .offset:         44
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithTransform1d
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithTransform1d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           alpha
        .offset:         8
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           beta
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           src_offset
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_offset
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride0
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride1
        .offset:         40
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride0
        .offset:         44
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride1
        .offset:         48
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len0
        .offset:         52
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len1
        .offset:         56
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         68
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         76
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         78
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         80
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         82
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         84
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         86
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         128
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 320
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithTransform2d
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithTransform2d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           alpha
        .offset:         8
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           beta
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           src_offset
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_offset
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride0
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride1
        .offset:         40
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride2
        .offset:         44
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride0
        .offset:         48
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride1
        .offset:         52
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride2
        .offset:         56
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len0
        .offset:         60
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len1
        .offset:         64
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len2
        .offset:         68
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         76
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         80
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         84
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         86
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         88
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         90
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         92
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         94
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         120
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         136
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 328
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithTransform3d
    .private_segment_fixed_size: 0
    .sgpr_count:     50
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithTransform3d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     20
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           alpha
        .offset:         8
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           beta
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           src_offset
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_offset
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride0
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride1
        .offset:         40
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride2
        .offset:         44
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride3
        .offset:         48
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride0
        .offset:         52
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride1
        .offset:         56
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride2
        .offset:         60
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride3
        .offset:         64
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len0
        .offset:         68
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len1
        .offset:         72
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len2
        .offset:         76
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len3
        .offset:         80
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         92
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         100
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         102
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         104
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         106
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         108
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         110
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         128
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         152
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 344
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithTransform4d
    .private_segment_fixed_size: 0
    .sgpr_count:     56
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithTransform4d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     24
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           alpha
        .offset:         8
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           beta
        .offset:         24
        .size:           4
        .type_name:      float
        .value_kind:     by_value
      - .name:           src_offset
        .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_offset
        .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride0
        .offset:         36
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride1
        .offset:         40
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride2
        .offset:         44
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride3
        .offset:         48
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           src_stride4
        .offset:         52
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride0
        .offset:         56
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride1
        .offset:         60
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride2
        .offset:         64
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride3
        .offset:         68
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           dst_stride4
        .offset:         72
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len0
        .offset:         76
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len1
        .offset:         80
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len2
        .offset:         84
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len3
        .offset:         88
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .name:           len4
        .offset:         92
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         100
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         104
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         108
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         110
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         112
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         114
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         116
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         118
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         136
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         144
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         152
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         160
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 352
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithTransform5d
    .private_segment_fixed_size: 0
    .sgpr_count:     62
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithTransform5d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     28
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
