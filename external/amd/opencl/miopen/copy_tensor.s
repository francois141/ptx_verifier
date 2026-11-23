; MIOpen rocm-7.2.4 src/kernels/MIOpenSubTensorOpWithSubTensorKernel.cl (SubTensorOpWithSubTensor2d), src/tensor.cpp:CopyTensor, compiled for gfx950
; by external/amd/opencl/miopen/extract.py (case copy_tensor).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	SubTensorOpWithSubTensor1d
	.globl	SubTensorOpWithSubTensor1d
	.p2align	8
	.type	SubTensorOpWithSubTensor1d,@function
SubTensorOpWithSubTensor1d:
	s_load_dword s3, s[0:1], 0x34
	s_load_dword s8, s[0:1], 0x50
	s_load_dwordx4 s[4:7], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s8
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v4, 4, v0
	v_cmp_gt_u32_e32 vcc, s6, v4
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_3
	s_load_dwordx4 s[8:11], s[0:1], 0x18
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_mul_lo_u32 v0, s5, v4
	s_lshl_b32 s5, s5, 3
	v_add_u32_e32 v0, s4, v0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v1, s11, v4
	v_add_u32_e32 v2, s10, v1
	s_lshl_b32 s4, s11, 3
	s_mov_b64 s[2:3], 0
	v_mov_b32_e32 v1, 0
.LBB0_2:
	v_lshl_add_u64 v[6:7], v[0:1], 2, s[0:1]
	global_load_dword v5, v[6:7], off
	v_add_u32_e32 v4, 8, v4
	v_mov_b32_e32 v3, v1
	v_cmp_le_u32_e32 vcc, s6, v4
	v_add_u32_e32 v0, s5, v0
	v_lshl_add_u64 v[6:7], v[2:3], 2, s[8:9]
	v_add_u32_e32 v2, s4, v2
	s_or_b64 s[2:3], vcc, s[2:3]
	s_waitcnt vmcnt(0)
	global_store_dword v[6:7], v5, off
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB0_2
.LBB0_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithSubTensor1d
		.amdhsa_group_segment_fixed_size 0
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
	.size	SubTensorOpWithSubTensor1d, .Lfunc_end0-SubTensorOpWithSubTensor1d

	.set SubTensorOpWithSubTensor1d.num_vgpr, 8
	.set SubTensorOpWithSubTensor1d.num_agpr, 0
	.set SubTensorOpWithSubTensor1d.numbered_sgpr, 12
	.set SubTensorOpWithSubTensor1d.private_seg_size, 0
	.set SubTensorOpWithSubTensor1d.uses_vcc, 1
	.set SubTensorOpWithSubTensor1d.uses_flat_scratch, 0
	.set SubTensorOpWithSubTensor1d.has_dyn_sized_stack, 0
	.set SubTensorOpWithSubTensor1d.has_recursion, 0
	.set SubTensorOpWithSubTensor1d.has_indirect_call, 0
	.protected	SubTensorOpWithSubTensor2d
	.globl	SubTensorOpWithSubTensor2d
	.p2align	8
	.type	SubTensorOpWithSubTensor2d,@function
SubTensorOpWithSubTensor2d:
	s_load_dword s3, s[0:1], 0x44
	s_load_dword s8, s[0:1], 0x60
	s_load_dwordx4 s[4:7], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s8
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v4, 4, v0
	v_cmp_gt_u32_e32 vcc, s7, v4
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_6
	s_load_dword s14, s[0:1], 0x18
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx2 s[8:9], s[0:1], 0x20
	s_load_dwordx4 s[16:19], s[0:1], 0x28
	v_and_b32_e32 v5, 15, v0
	v_mul_lo_u32 v0, s5, v4
	v_mul_lo_u32 v1, s6, v5
	v_add3_u32 v6, s4, v0, v1
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v0, s17, v4
	v_mul_lo_u32 v1, s18, v5
	v_cmp_gt_u32_e32 vcc, s14, v5
	s_lshl_b32 s15, s5, 3
	s_lshl_b32 s6, s6, 4
	v_add3_u32 v7, s16, v0, v1
	s_lshl_b32 s16, s17, 3
	s_lshl_b32 s17, s18, 4
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v1, 0
	s_branch .LBB1_3
.LBB1_2:
	s_or_b64 exec, exec, s[10:11]
	v_add_u32_e32 v4, 8, v4
	v_cmp_le_u32_e64 s[0:1], s7, v4
	v_add_u32_e32 v6, s15, v6
	s_or_b64 s[4:5], s[0:1], s[4:5]
	v_add_u32_e32 v7, s16, v7
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB1_6
.LBB1_3:
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB1_2
	s_mov_b64 s[12:13], 0
	v_mov_b32_e32 v2, v7
	v_mov_b32_e32 v0, v6
	v_mov_b32_e32 v8, v5
.LBB1_5:
	v_lshl_add_u64 v[10:11], v[0:1], 2, s[2:3]
	global_load_dword v9, v[10:11], off
	v_add_u32_e32 v8, 16, v8
	v_mov_b32_e32 v3, v1
	v_cmp_le_u32_e64 s[0:1], s14, v8
	v_add_u32_e32 v0, s6, v0
	v_lshl_add_u64 v[10:11], v[2:3], 2, s[8:9]
	v_add_u32_e32 v2, s17, v2
	s_or_b64 s[12:13], s[0:1], s[12:13]
	s_waitcnt vmcnt(0)
	global_store_dword v[10:11], v9, off
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB1_5
	s_branch .LBB1_2
.LBB1_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithSubTensor2d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 312
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
		.amdhsa_next_free_sgpr 20
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
	.size	SubTensorOpWithSubTensor2d, .Lfunc_end1-SubTensorOpWithSubTensor2d

	.set SubTensorOpWithSubTensor2d.num_vgpr, 12
	.set SubTensorOpWithSubTensor2d.num_agpr, 0
	.set SubTensorOpWithSubTensor2d.numbered_sgpr, 20
	.set SubTensorOpWithSubTensor2d.private_seg_size, 0
	.set SubTensorOpWithSubTensor2d.uses_vcc, 1
	.set SubTensorOpWithSubTensor2d.uses_flat_scratch, 0
	.set SubTensorOpWithSubTensor2d.has_dyn_sized_stack, 0
	.set SubTensorOpWithSubTensor2d.has_recursion, 0
	.set SubTensorOpWithSubTensor2d.has_indirect_call, 0
	.protected	SubTensorOpWithSubTensor3d
	.globl	SubTensorOpWithSubTensor3d
	.p2align	8
	.type	SubTensorOpWithSubTensor3d,@function
SubTensorOpWithSubTensor3d:
	s_load_dword s3, s[0:1], 0x4c
	s_load_dword s4, s[0:1], 0x68
	s_load_dwordx4 s[8:11], s[0:1], 0x18
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s8, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB2_17
	s_load_dwordx2 s[20:21], s[0:1], 0x0
	s_load_dwordx4 s[12:15], s[0:1], 0x8
	s_load_dwordx2 s[22:23], s[0:1], 0x28
	s_load_dwordx4 s[16:19], s[0:1], 0x30
	v_and_b32_e32 v5, 15, v0
	s_cmp_lg_u32 s10, 0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v0, s13, v3
	v_mul_lo_u32 v1, s14, v5
	s_cselect_b64 s[2:3], -1, 0
	s_add_i32 s33, s10, -1
	v_add3_u32 v8, s12, v0, v1
	s_lshl_b32 s36, s13, 3
	s_lshl_b32 s14, s14, 4
	v_mul_lo_u32 v1, s18, v5
	s_lshl_b32 s37, s17, 3
	s_lshl_b32 s18, s18, 4
	s_cmp_lt_u32 s10, 8
	s_cselect_b64 s[12:13], -1, 0
	s_cmp_gt_u32 s10, 7
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lg_u32 s15, 1
	v_mul_lo_u32 v0, s17, v3
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s19, 1
	v_add3_u32 v9, s16, v0, v1
	s_cselect_b64 s[16:17], -1, 0
	s_or_b64 s[6:7], s[6:7], s[16:17]
	s_and_b32 s38, s10, -2
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	s_cmp_lg_u32 s10, s38
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	v_cndmask_b32_e64 v0, 0, 1, s[4:5]
	v_cmp_gt_u32_e64 s[0:1], s9, v5
	s_mov_b32 s11, 0
	s_mov_b64 s[16:17], 0
	s_cselect_b64 s[24:25], -1, 0
	v_cmp_ne_u32_e64 s[4:5], 1, v0
	s_xor_b64 s[26:27], s[6:7], -1
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v10, v8
	v_mov_b32_e32 v11, v9
	s_branch .LBB2_3
.LBB2_2:
	s_or_b64 exec, exec, s[28:29]
	v_add_u32_e32 v3, 8, v3
	s_add_i32 s11, s11, 1
	v_cmp_le_u32_e32 vcc, s8, v3
	v_add_u32_e32 v11, s37, v11
	s_or_b64 s[16:17], vcc, s[16:17]
	v_add_u32_e32 v10, s36, v10
	s_andn2_b64 exec, exec, s[16:17]
	s_cbranch_execz .LBB2_17
.LBB2_3:
	s_and_saveexec_b64 s[28:29], s[0:1]
	s_cbranch_execz .LBB2_2
	s_mul_i32 s6, s36, s11
	v_add_u32_e32 v12, s6, v8
	s_mul_i32 s6, s37, s11
	v_add_u32_e32 v13, s6, v9
	s_mov_b32 s39, 0
	s_mov_b64 s[30:31], 0
	v_mov_b32_e32 v2, v10
	v_mov_b32_e32 v4, v11
	v_mov_b32_e32 v14, v5
	s_branch .LBB2_7
.LBB2_5:
	s_or_b64 exec, exec, s[6:7]
.LBB2_6:
	v_add_u32_e32 v14, 16, v14
	s_add_i32 s39, s39, 1
	v_cmp_le_u32_e32 vcc, s9, v14
	v_add_u32_e32 v4, s18, v4
	s_or_b64 s[30:31], vcc, s[30:31]
	v_add_u32_e32 v2, s14, v2
	s_andn2_b64 exec, exec, s[30:31]
	s_cbranch_execz .LBB2_2
.LBB2_7:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB2_6
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[34:35], s[12:13]
	s_cbranch_vccnz .LBB2_14
	s_mul_i32 s6, s14, s39
	v_add_u32_e32 v0, s6, v12
	s_mul_i32 s6, s18, s39
	v_add_u32_e32 v6, s6, v13
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s33, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[6:7], s33, v0
	s_and_b64 s[40:41], vcc, s[26:27]
	s_mov_b64 s[34:35], -1
	s_and_b64 s[40:41], s[40:41], s[6:7]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[6:7], s[40:41]
	s_cbranch_execz .LBB2_13
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s34, s38
.LBB2_11:
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[20:21]
	global_load_dwordx2 v[16:17], v[16:17], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s34, s34, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[18:19], v[6:7], 2, s[22:23]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s34, 0
	s_waitcnt vmcnt(0)
	global_store_dwordx2 v[18:19], v[16:17], off
	s_cbranch_scc1 .LBB2_11
	v_mov_b32_e32 v0, s38
	s_orn2_b64 s[34:35], s[24:25], exec
.LBB2_13:
	s_or_b64 exec, exec, s[6:7]
.LBB2_14:
	s_and_saveexec_b64 s[6:7], s[34:35]
	s_cbranch_execz .LBB2_5
	v_mad_u64_u32 v[16:17], s[34:35], s15, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[34:35], s19, v0, v[4:5]
	v_sub_u32_e32 v15, s10, v0
	s_mov_b64 s[34:35], 0
	v_mov_b32_e32 v0, v16
.LBB2_16:
	v_lshl_add_u64 v[16:17], v[0:1], 2, s[20:21]
	global_load_dword v18, v[16:17], off
	v_add_u32_e32 v15, -1, v15
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v15
	v_add_u32_e32 v0, s15, v0
	v_lshl_add_u64 v[16:17], v[6:7], 2, s[22:23]
	v_add_u32_e32 v6, s19, v6
	s_or_b64 s[34:35], vcc, s[34:35]
	s_waitcnt vmcnt(0)
	global_store_dword v[16:17], v18, off
	s_andn2_b64 exec, exec, s[34:35]
	s_cbranch_execnz .LBB2_16
	s_branch .LBB2_5
.LBB2_17:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithSubTensor3d
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
		.amdhsa_next_free_vgpr 20
		.amdhsa_next_free_sgpr 42
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
	.size	SubTensorOpWithSubTensor3d, .Lfunc_end2-SubTensorOpWithSubTensor3d

	.set SubTensorOpWithSubTensor3d.num_vgpr, 20
	.set SubTensorOpWithSubTensor3d.num_agpr, 0
	.set SubTensorOpWithSubTensor3d.numbered_sgpr, 42
	.set SubTensorOpWithSubTensor3d.private_seg_size, 0
	.set SubTensorOpWithSubTensor3d.uses_vcc, 1
	.set SubTensorOpWithSubTensor3d.uses_flat_scratch, 0
	.set SubTensorOpWithSubTensor3d.has_dyn_sized_stack, 0
	.set SubTensorOpWithSubTensor3d.has_recursion, 0
	.set SubTensorOpWithSubTensor3d.has_indirect_call, 0
	.protected	SubTensorOpWithSubTensor4d
	.globl	SubTensorOpWithSubTensor4d
	.p2align	8
	.type	SubTensorOpWithSubTensor4d,@function
SubTensorOpWithSubTensor4d:
	s_load_dword s3, s[0:1], 0x5c
	s_load_dword s4, s[0:1], 0x78
	s_load_dwordx8 s[8:15], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s13, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB3_20
	s_load_dwordx2 s[20:21], s[0:1], 0x0
	s_load_dword s33, s[0:1], 0x28
	s_load_dwordx2 s[22:23], s[0:1], 0x30
	s_load_dwordx4 s[16:19], s[0:1], 0x38
	s_load_dword s38, s[0:1], 0x48
	v_and_b32_e32 v5, 15, v0
	s_cmp_lg_u32 s15, 0
	s_cselect_b64 s[2:3], -1, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s33, 0
	v_mul_lo_u32 v0, s9, v3
	v_mul_lo_u32 v1, s10, v5
	s_cselect_b64 s[4:5], -1, 0
	s_add_i32 s40, s33, -1
	v_add3_u32 v8, s8, v0, v1
	s_lshl_b32 s41, s9, 3
	s_lshl_b32 s10, s10, 4
	v_mul_lo_u32 v1, s18, v5
	s_lshl_b32 s42, s17, 3
	s_lshl_b32 s18, s18, 4
	v_mul_lo_u32 v0, s17, v3
	s_cmp_lt_u32 s33, 8
	v_add3_u32 v9, s16, v0, v1
	s_cselect_b64 s[16:17], -1, 0
	s_cmp_gt_u32 s33, 7
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lg_u32 s12, 1
	s_cselect_b64 s[8:9], -1, 0
	s_cmp_lg_u32 s38, 1
	s_cselect_b64 s[24:25], -1, 0
	s_or_b64 s[8:9], s[8:9], s[24:25]
	s_and_b32 s43, s33, -2
	s_cmp_lg_u32 s33, s43
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	v_cndmask_b32_e64 v1, 0, 1, s[4:5]
	v_cndmask_b32_e64 v2, 0, 1, s[6:7]
	v_cmp_gt_u32_e64 s[0:1], s14, v5
	s_mov_b32 s39, 0
	s_mov_b64 s[24:25], 0
	s_cselect_b64 s[26:27], -1, 0
	v_cmp_ne_u32_e64 s[2:3], 1, v0
	v_cmp_ne_u32_e64 s[4:5], 1, v1
	v_cmp_ne_u32_e64 s[6:7], 1, v2
	s_xor_b64 s[28:29], s[8:9], -1
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v10, v8
	v_mov_b32_e32 v11, v9
	s_branch .LBB3_3
.LBB3_2:
	s_or_b64 exec, exec, s[30:31]
	v_add_u32_e32 v3, 8, v3
	s_add_i32 s39, s39, 1
	v_cmp_le_u32_e32 vcc, s13, v3
	v_add_u32_e32 v11, s42, v11
	s_or_b64 s[24:25], vcc, s[24:25]
	v_add_u32_e32 v10, s41, v10
	s_andn2_b64 exec, exec, s[24:25]
	s_cbranch_execz .LBB3_20
.LBB3_3:
	s_and_saveexec_b64 s[30:31], s[0:1]
	s_cbranch_execz .LBB3_2
	s_mul_i32 s8, s41, s39
	v_add_u32_e32 v12, s8, v8
	s_mul_i32 s8, s42, s39
	v_add_u32_e32 v13, s8, v9
	s_mov_b32 s44, 0
	s_mov_b64 s[34:35], 0
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v16, v5
	s_branch .LBB3_6
.LBB3_5:
	v_add_u32_e32 v16, 16, v16
	s_add_i32 s44, s44, 1
	v_cmp_le_u32_e32 vcc, s14, v16
	v_add_u32_e32 v15, s18, v15
	s_or_b64 s[34:35], vcc, s[34:35]
	v_add_u32_e32 v14, s10, v14
	s_andn2_b64 exec, exec, s[34:35]
	s_cbranch_execz .LBB3_2
.LBB3_6:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB3_5
	s_mul_i32 s8, s10, s44
	v_add_u32_e32 v17, s8, v12
	s_mul_i32 s8, s18, s44
	v_add_u32_e32 v18, s8, v13
	s_mov_b32 s45, 0
	v_mov_b32_e32 v2, v14
	v_mov_b32_e32 v4, v15
	s_branch .LBB3_10
.LBB3_8:
	s_or_b64 exec, exec, s[8:9]
.LBB3_9:
	s_add_i32 s45, s45, 1
	v_add_u32_e32 v4, s19, v4
	s_cmp_eq_u32 s45, s15
	v_add_u32_e32 v2, s11, v2
	s_cbranch_scc1 .LBB3_5
.LBB3_10:
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB3_9
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[6:7]
	s_mov_b64 s[36:37], s[16:17]
	s_cbranch_vccnz .LBB3_17
	s_mul_i32 s8, s11, s45
	v_add_u32_e32 v0, s8, v17
	s_mul_i32 s8, s19, s45
	v_add_u32_e32 v6, s8, v18
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s40, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[8:9], s40, v0
	s_and_b64 s[46:47], vcc, s[28:29]
	s_mov_b64 s[36:37], -1
	s_and_b64 s[46:47], s[46:47], s[8:9]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[8:9], s[46:47]
	s_cbranch_execz .LBB3_16
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s36, s43
.LBB3_14:
	v_lshl_add_u64 v[20:21], v[0:1], 2, s[20:21]
	global_load_dwordx2 v[20:21], v[20:21], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s36, s36, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[22:23], v[6:7], 2, s[22:23]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s36, 0
	s_waitcnt vmcnt(0)
	global_store_dwordx2 v[22:23], v[20:21], off
	s_cbranch_scc1 .LBB3_14
	v_mov_b32_e32 v0, s43
	s_orn2_b64 s[36:37], s[26:27], exec
.LBB3_16:
	s_or_b64 exec, exec, s[8:9]
.LBB3_17:
	s_and_saveexec_b64 s[8:9], s[36:37]
	s_cbranch_execz .LBB3_8
	v_mad_u64_u32 v[20:21], s[36:37], s12, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[36:37], s38, v0, v[4:5]
	v_sub_u32_e32 v19, s33, v0
	s_mov_b64 s[36:37], 0
	v_mov_b32_e32 v0, v20
.LBB3_19:
	v_lshl_add_u64 v[20:21], v[0:1], 2, s[20:21]
	global_load_dword v22, v[20:21], off
	v_add_u32_e32 v19, -1, v19
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v19
	v_add_u32_e32 v0, s12, v0
	v_lshl_add_u64 v[20:21], v[6:7], 2, s[22:23]
	v_add_u32_e32 v6, s38, v6
	s_or_b64 s[36:37], vcc, s[36:37]
	s_waitcnt vmcnt(0)
	global_store_dword v[20:21], v22, off
	s_andn2_b64 exec, exec, s[36:37]
	s_cbranch_execnz .LBB3_19
	s_branch .LBB3_8
.LBB3_20:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithSubTensor4d
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 24
		.amdhsa_next_free_sgpr 48
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
	.size	SubTensorOpWithSubTensor4d, .Lfunc_end3-SubTensorOpWithSubTensor4d

	.set SubTensorOpWithSubTensor4d.num_vgpr, 24
	.set SubTensorOpWithSubTensor4d.num_agpr, 0
	.set SubTensorOpWithSubTensor4d.numbered_sgpr, 48
	.set SubTensorOpWithSubTensor4d.private_seg_size, 0
	.set SubTensorOpWithSubTensor4d.uses_vcc, 1
	.set SubTensorOpWithSubTensor4d.uses_flat_scratch, 0
	.set SubTensorOpWithSubTensor4d.has_dyn_sized_stack, 0
	.set SubTensorOpWithSubTensor4d.has_recursion, 0
	.set SubTensorOpWithSubTensor4d.has_indirect_call, 0
	.protected	SubTensorOpWithSubTensor5d
	.globl	SubTensorOpWithSubTensor5d
	.p2align	8
	.type	SubTensorOpWithSubTensor5d,@function
SubTensorOpWithSubTensor5d:
	s_load_dword s3, s[0:1], 0x64
	s_load_dword s4, s[0:1], 0x80
	s_load_dwordx8 s[12:19], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s3, 0xffff
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s4
	v_add_u32_e32 v0, s2, v0
	v_lshrrev_b32_e32 v3, 4, v0
	v_cmp_gt_u32_e32 vcc, s18, v3
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB4_23
	s_load_dwordx2 s[28:29], s[0:1], 0x0
	s_load_dwordx4 s[20:23], s[0:1], 0x28
	s_load_dwordx2 s[30:31], s[0:1], 0x38
	s_load_dwordx4 s[24:27], s[0:1], 0x40
	s_load_dwordx2 s[34:35], s[0:1], 0x50
	v_and_b32_e32 v5, 15, v0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s20, 0
	s_cselect_b64 s[2:3], -1, 0
	s_cmp_lg_u32 s21, 0
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lg_u32 s22, 0
	v_mul_lo_u32 v0, s13, v3
	v_mul_lo_u32 v1, s14, v5
	s_cselect_b64 s[6:7], -1, 0
	s_add_i32 s33, s22, -1
	v_add3_u32 v8, s12, v0, v1
	s_lshl_b32 s46, s13, 3
	s_lshl_b32 s14, s14, 4
	v_mul_lo_u32 v1, s26, v5
	s_lshl_b32 s47, s25, 3
	s_lshl_b32 s26, s26, 4
	s_cmp_lt_u32 s22, 8
	s_cselect_b64 s[12:13], -1, 0
	s_cmp_gt_u32 s22, 7
	s_cselect_b64 s[8:9], -1, 0
	s_cmp_lg_u32 s17, 1
	v_mul_lo_u32 v0, s25, v3
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lg_u32 s35, 1
	v_add3_u32 v9, s24, v0, v1
	s_cselect_b64 s[24:25], -1, 0
	s_or_b64 s[10:11], s[10:11], s[24:25]
	s_and_b32 s48, s22, -2
	s_cmp_lg_u32 s22, s48
	v_cndmask_b32_e64 v0, 0, 1, s[2:3]
	v_cndmask_b32_e64 v1, 0, 1, s[4:5]
	v_cndmask_b32_e64 v2, 0, 1, s[6:7]
	v_cndmask_b32_e64 v4, 0, 1, s[8:9]
	v_cmp_gt_u32_e64 s[0:1], s19, v5
	s_mov_b32 s23, 0
	s_mov_b64 s[24:25], 0
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
	s_add_i32 s23, s23, 1
	v_cmp_le_u32_e32 vcc, s18, v3
	v_add_u32_e32 v11, s47, v11
	s_or_b64 s[24:25], vcc, s[24:25]
	v_add_u32_e32 v10, s46, v10
	s_andn2_b64 exec, exec, s[24:25]
	s_cbranch_execz .LBB4_23
.LBB4_3:
	s_and_saveexec_b64 s[40:41], s[0:1]
	s_cbranch_execz .LBB4_2
	s_mul_i32 s10, s46, s23
	v_add_u32_e32 v12, s10, v8
	s_mul_i32 s10, s47, s23
	v_add_u32_e32 v13, s10, v9
	s_mov_b32 s49, 0
	s_mov_b64 s[42:43], 0
	v_mov_b32_e32 v14, v10
	v_mov_b32_e32 v15, v11
	v_mov_b32_e32 v16, v5
	s_branch .LBB4_6
.LBB4_5:
	v_add_u32_e32 v16, 16, v16
	s_add_i32 s49, s49, 1
	v_cmp_le_u32_e32 vcc, s19, v16
	v_add_u32_e32 v15, s26, v15
	s_or_b64 s[42:43], vcc, s[42:43]
	v_add_u32_e32 v14, s14, v14
	s_andn2_b64 exec, exec, s[42:43]
	s_cbranch_execz .LBB4_2
.LBB4_6:
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB4_5
	s_mul_i32 s10, s14, s49
	v_add_u32_e32 v17, s10, v12
	s_mul_i32 s10, s26, s49
	v_add_u32_e32 v18, s10, v13
	s_mov_b32 s50, 0
	v_mov_b32_e32 v19, v14
	v_mov_b32_e32 v20, v15
	s_branch .LBB4_9
.LBB4_8:
	s_add_i32 s50, s50, 1
	v_add_u32_e32 v20, s27, v20
	s_cmp_eq_u32 s50, s20
	v_add_u32_e32 v19, s15, v19
	s_cbranch_scc1 .LBB4_5
.LBB4_9:
	s_and_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz .LBB4_8
	s_mul_i32 s10, s15, s50
	v_add_u32_e32 v21, s10, v17
	s_mul_i32 s10, s27, s50
	v_add_u32_e32 v22, s10, v18
	s_mov_b32 s51, 0
	v_mov_b32_e32 v2, v19
	v_mov_b32_e32 v4, v20
	s_branch .LBB4_13
.LBB4_11:
	s_or_b64 exec, exec, s[10:11]
.LBB4_12:
	s_add_i32 s51, s51, 1
	v_add_u32_e32 v4, s34, v4
	s_cmp_eq_u32 s51, s21
	v_add_u32_e32 v2, s16, v2
	s_cbranch_scc1 .LBB4_8
.LBB4_13:
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz .LBB4_12
	v_mov_b32_e32 v0, 0
	s_and_b64 vcc, exec, s[8:9]
	s_mov_b64 s[44:45], s[12:13]
	s_cbranch_vccnz .LBB4_20
	s_mul_i32 s10, s16, s51
	v_add_u32_e32 v0, s10, v21
	s_mul_i32 s10, s34, s51
	v_add_u32_e32 v6, s10, v22
	v_not_b32_e32 v0, v0
	v_cmp_le_u32_e32 vcc, s33, v0
	v_not_b32_e32 v0, v6
	v_cmp_le_u32_e64 s[10:11], s33, v0
	s_and_b64 s[52:53], vcc, s[38:39]
	s_mov_b64 s[44:45], -1
	s_and_b64 s[52:53], s[52:53], s[10:11]
	v_mov_b32_e32 v0, 0
	s_and_saveexec_b64 s[10:11], s[52:53]
	s_cbranch_execz .LBB4_19
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v6, v4
	s_mov_b32 s44, s48
.LBB4_17:
	v_lshl_add_u64 v[24:25], v[0:1], 2, s[28:29]
	global_load_dwordx2 v[24:25], v[24:25], off
	v_mov_b32_e32 v7, v1
	s_add_i32 s44, s44, -2
	v_add_u32_e32 v0, 2, v0
	v_lshl_add_u64 v[26:27], v[6:7], 2, s[30:31]
	v_add_u32_e32 v6, 2, v6
	s_cmp_lg_u32 s44, 0
	s_waitcnt vmcnt(0)
	global_store_dwordx2 v[26:27], v[24:25], off
	s_cbranch_scc1 .LBB4_17
	v_mov_b32_e32 v0, s48
	s_orn2_b64 s[44:45], s[36:37], exec
.LBB4_19:
	s_or_b64 exec, exec, s[10:11]
.LBB4_20:
	s_and_saveexec_b64 s[10:11], s[44:45]
	s_cbranch_execz .LBB4_11
	v_mad_u64_u32 v[24:25], s[44:45], s17, v0, v[2:3]
	v_mad_u64_u32 v[6:7], s[44:45], s35, v0, v[4:5]
	v_sub_u32_e32 v23, s22, v0
	s_mov_b64 s[44:45], 0
	v_mov_b32_e32 v0, v24
.LBB4_22:
	v_lshl_add_u64 v[24:25], v[0:1], 2, s[28:29]
	global_load_dword v26, v[24:25], off
	v_add_u32_e32 v23, -1, v23
	v_mov_b32_e32 v7, v1
	v_cmp_eq_u32_e32 vcc, 0, v23
	v_add_u32_e32 v0, s17, v0
	v_lshl_add_u64 v[24:25], v[6:7], 2, s[30:31]
	v_add_u32_e32 v6, s35, v6
	s_or_b64 s[44:45], vcc, s[44:45]
	s_waitcnt vmcnt(0)
	global_store_dword v[24:25], v26, off
	s_andn2_b64 exec, exec, s[44:45]
	s_cbranch_execnz .LBB4_22
	s_branch .LBB4_11
.LBB4_23:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel SubTensorOpWithSubTensor5d
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
		.amdhsa_next_free_vgpr 28
		.amdhsa_next_free_sgpr 54
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
	.size	SubTensorOpWithSubTensor5d, .Lfunc_end4-SubTensorOpWithSubTensor5d

	.set SubTensorOpWithSubTensor5d.num_vgpr, 28
	.set SubTensorOpWithSubTensor5d.num_agpr, 0
	.set SubTensorOpWithSubTensor5d.numbered_sgpr, 54
	.set SubTensorOpWithSubTensor5d.private_seg_size, 0
	.set SubTensorOpWithSubTensor5d.uses_vcc, 1
	.set SubTensorOpWithSubTensor5d.uses_flat_scratch, 0
	.set SubTensorOpWithSubTensor5d.has_dyn_sized_stack, 0
	.set SubTensorOpWithSubTensor5d.has_recursion, 0
	.set SubTensorOpWithSubTensor5d.has_indirect_call, 0
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
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           srcOffset
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride0
        .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen0
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           dstOffset
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride0
        .offset:         36
        .size:           4
        .type_name:      int
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 296
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithSubTensor1d
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithSubTensor1d.kd
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
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           srcOffset
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride0
        .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride1
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen0
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen1
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         32
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           dstOffset
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride0
        .offset:         44
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride1
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         60
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         64
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         68
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         70
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         72
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         74
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         76
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         78
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         112
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         120
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 312
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           SubTensorOpWithSubTensor2d
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithSubTensor2d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           srcOffset
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride0
        .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride1
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride2
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen0
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen1
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen2
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         40
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           dstOffset
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride0
        .offset:         52
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride1
        .offset:         56
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride2
        .offset:         60
        .size:           4
        .type_name:      int
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
    .name:           SubTensorOpWithSubTensor3d
    .private_segment_fixed_size: 0
    .sgpr_count:     48
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithSubTensor3d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     20
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           srcOffset
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride0
        .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride1
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride2
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride3
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen0
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen1
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen2
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen3
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         48
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           dstOffset
        .offset:         56
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride0
        .offset:         60
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride1
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride2
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride3
        .offset:         72
        .size:           4
        .type_name:      int
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
    .name:           SubTensorOpWithSubTensor4d
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithSubTensor4d.kd
    .uses_dynamic_stack: false
    .vgpr_count:     24
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
        .address_space:  global
        .is_const:       true
        .is_restrict:    true
        .name:           src
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           srcOffset
        .offset:         8
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride0
        .offset:         12
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride1
        .offset:         16
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride2
        .offset:         20
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride3
        .offset:         24
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcStride4
        .offset:         28
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen0
        .offset:         32
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen1
        .offset:         36
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen2
        .offset:         40
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen3
        .offset:         44
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           srcLen4
        .offset:         48
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .actual_access:  write_only
        .address_space:  global
        .is_restrict:    true
        .name:           dst
        .offset:         56
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .name:           dstOffset
        .offset:         64
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride0
        .offset:         68
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride1
        .offset:         72
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride2
        .offset:         76
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride3
        .offset:         80
        .size:           4
        .type_name:      int
        .value_kind:     by_value
      - .name:           dstStride4
        .offset:         84
        .size:           4
        .type_name:      int
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
    .name:           SubTensorOpWithSubTensor5d
    .private_segment_fixed_size: 0
    .sgpr_count:     60
    .sgpr_spill_count: 0
    .symbol:         SubTensorOpWithSubTensor5d.kd
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
