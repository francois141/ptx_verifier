	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	relu
	.globl	relu
	.p2align	8
	.type	relu,@function
relu:
	s_load_dwordx4 s[4:7], s[0:1], 0x18
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s7, 0
	s_cmp_eq_u32 s4, 0
	s_cbranch_scc1 .LBB0_11
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x10
	s_cmp_lg_u32 s5, 0
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lg_u32 s6, 0
	s_cselect_b64 s[2:3], -1, 0
	v_cndmask_b32_e64 v2, 0, 1, s[0:1]
	v_mul_lo_u32 v1, v0, s6
	v_cmp_ne_u32_e64 s[0:1], 1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[2:3]
	s_lshl_b32 s16, s6, 2
	v_lshlrev_b32_e32 v1, 2, v1
	s_lshl_b32 s17, s6, 8
	v_cmp_ne_u32_e64 s[2:3], 1, v2
	s_mov_b32 s18, 0
	s_branch .LBB0_3
.LBB0_2:
	s_add_i32 s18, s18, 1
	s_add_i32 s7, s7, s16
	s_cmp_eq_u32 s18, s4
	s_cbranch_scc1 .LBB0_11
.LBB0_3:
	s_and_b64 vcc, exec, s[0:1]
	s_cbranch_vccnz .LBB0_2
	s_mul_i32 s19, s18, s5
	s_mov_b32 s20, 0
	v_mov_b32_e32 v2, v1
	s_branch .LBB0_7
.LBB0_5:
	v_max_f32_e32 v4, 0, v4
	v_add_lshl_u32 v3, v3, s19, 2
	s_waitcnt lgkmcnt(0)
	global_store_dword v3, v4, s[12:13]
.LBB0_6:
	s_or_b64 exec, exec, s[14:15]
	s_add_i32 s20, s20, 64
	s_cmp_ge_u32 s20, s5
	v_add_u32_e32 v2, s17, v2
	s_cbranch_scc1 .LBB0_2
.LBB0_7:
	v_add_u32_e32 v3, s20, v0
	v_cmp_gt_u32_e32 vcc, s5, v3
	s_and_saveexec_b64 s[14:15], vcc
	s_cbranch_execz .LBB0_6
	v_mov_b32_e32 v4, 0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_5
	s_mov_b32 s21, s6
	v_mov_b32_e32 v5, v2
	s_mov_b32 s22, s7
.LBB0_10:
	v_mov_b32_e32 v6, s22
	s_waitcnt lgkmcnt(0)
	global_load_dword v7, v5, s[10:11]
	global_load_dword v6, v6, s[8:9]
	s_add_i32 s22, s22, 4
	s_add_i32 s21, s21, -1
	v_add_u32_e32 v5, 4, v5
	s_cmp_eq_u32 s21, 0
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v4, v6, v7
	s_cbranch_scc0 .LBB0_10
	s_branch .LBB0_5
.LBB0_11:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel relu
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 36
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
		.amdhsa_next_free_sgpr 23
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
	.size	relu, .Lfunc_end0-relu

	.set relu.num_vgpr, 8
	.set relu.num_agpr, 0
	.set relu.numbered_sgpr, 23
	.set relu.private_seg_size, 0
	.set relu.uses_vcc, 1
	.set relu.uses_flat_scratch, 0
	.set relu.has_dyn_sized_stack, 0
	.set relu.has_recursion, 0
	.set relu.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_relu
	.globl	__clang_ocl_kern_imp_relu
	.p2align	2
	.type	__clang_ocl_kern_imp_relu,@function
__clang_ocl_kern_imp_relu:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_mov_b32 s18, 0
	v_cmp_ne_u32_e32 vcc, 0, v6
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_12
	v_and_b32_e32 v9, 0x3ff, v31
	v_mul_lo_u32 v10, v9, v8
	v_mov_b32_e32 v11, 0
	v_cmp_ne_u32_e32 vcc, 0, v7
	v_cmp_ne_u32_e64 s[0:1], 0, v8
	v_lshlrev_b32_e32 v14, 2, v10
	v_lshlrev_b32_e32 v15, 8, v8
	v_lshlrev_b32_e32 v16, 2, v8
	s_mov_b64 s[6:7], 0
	v_mov_b32_e32 v17, 0
	s_branch .LBB1_3
.LBB1_2:
	s_or_b64 exec, exec, s[8:9]
	s_add_i32 s18, s18, 1
	v_cmp_eq_u32_e64 s[2:3], s18, v6
	s_or_b64 s[6:7], s[2:3], s[6:7]
	v_add_u32_e32 v17, v17, v16
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execz .LBB1_12
.LBB1_3:
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB1_2
	v_mul_lo_u32 v18, s18, v7
	s_mov_b32 s19, 0
	s_mov_b64 s[10:11], 0
	v_mov_b32_e32 v19, v14
	s_branch .LBB1_7
.LBB1_5:
	s_or_b64 exec, exec, s[14:15]
	v_add_lshl_u32 v10, v20, v18, 2
	v_max_f32_e32 v21, 0, v21
	v_lshl_add_u64 v[12:13], v[4:5], 0, v[10:11]
	global_store_dword v[12:13], v21, off
.LBB1_6:
	s_or_b64 exec, exec, s[12:13]
	s_add_i32 s19, s19, 64
	v_cmp_ge_u32_e64 s[2:3], s19, v7
	s_or_b64 s[10:11], s[2:3], s[10:11]
	v_add_u32_e32 v19, v19, v15
	s_andn2_b64 exec, exec, s[10:11]
	s_cbranch_execz .LBB1_2
.LBB1_7:
	v_add_u32_e32 v20, s19, v9
	v_cmp_lt_u32_e64 s[2:3], v20, v7
	s_and_saveexec_b64 s[12:13], s[2:3]
	s_cbranch_execz .LBB1_6
	v_mov_b32_e32 v21, 0
	s_and_saveexec_b64 s[14:15], s[0:1]
	s_cbranch_execz .LBB1_5
	v_mov_b32_e32 v21, 0
	s_mov_b64 s[16:17], 0
	v_mov_b32_e32 v10, v17
	v_mov_b32_e32 v12, v19
	v_mov_b32_e32 v22, v8
.LBB1_10:
	v_lshl_add_u64 v[24:25], v[0:1], 0, v[10:11]
	v_mov_b32_e32 v13, v11
	global_load_dword v23, v[24:25], off
	v_lshl_add_u64 v[24:25], v[2:3], 0, v[12:13]
	global_load_dword v13, v[24:25], off
	v_add_u32_e32 v22, -1, v22
	v_cmp_eq_u32_e64 s[2:3], 0, v22
	v_add_u32_e32 v10, 4, v10
	v_add_u32_e32 v12, 4, v12
	s_or_b64 s[16:17], s[2:3], s[16:17]
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v21, v23, v13
	s_andn2_b64 exec, exec, s[16:17]
	s_cbranch_execnz .LBB1_10
	s_or_b64 exec, exec, s[16:17]
	s_branch .LBB1_5
.LBB1_12:
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_relu, .Lfunc_end1-__clang_ocl_kern_imp_relu

	.set __clang_ocl_kern_imp_relu.num_vgpr, 32
	.set __clang_ocl_kern_imp_relu.num_agpr, 0
	.set __clang_ocl_kern_imp_relu.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_relu.private_seg_size, 0
	.set __clang_ocl_kern_imp_relu.uses_vcc, 1
	.set __clang_ocl_kern_imp_relu.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_relu.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_relu.has_recursion, 0
	.set __clang_ocl_kern_imp_relu.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 32
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 32
	.text
	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         28
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 36
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 64
    .name:           relu
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 64
      - 1
      - 1
    .sgpr_count:     29
    .sgpr_spill_count: 0
    .symbol:         relu.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     8
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
