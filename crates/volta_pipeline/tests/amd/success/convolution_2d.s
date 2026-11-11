	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	convolution_2d
	.globl	convolution_2d
	.p2align	8
	.type	convolution_2d,@function
convolution_2d:
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[12:13], s[0:1], 0x10
	v_lshrrev_b32_e32 v1, 3, v0
	v_and_b32_e32 v2, 7, v0
	v_mul_u32_u24_e32 v1, 10, v1
	v_add_lshl_u32 v1, v1, v2, 2
	s_waitcnt lgkmcnt(0)
	global_load_dwordx3 v[2:4], v1, s[8:9]
	global_load_dwordx3 v[6:8], v1, s[8:9] offset:40
	global_load_dwordx3 v[10:12], v1, s[8:9] offset:80
	s_load_dwordx8 s[0:7], s[10:11], 0x0
	s_load_dword s8, s[10:11], 0x20
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt vmcnt(2) lgkmcnt(0)
	v_fma_f32 v1, v2, s0, 0
	v_fmac_f32_e32 v1, s1, v3
	v_fmac_f32_e32 v1, s2, v4
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v1, s3, v6
	v_fmac_f32_e32 v1, s4, v7
	v_fmac_f32_e32 v1, s5, v8
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v1, s6, v10
	v_fmac_f32_e32 v1, s7, v11
	v_fmac_f32_e32 v1, s8, v12
	global_store_dword v0, v1, s[12:13]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel convolution_2d
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 24
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
		.amdhsa_next_free_sgpr 14
		.amdhsa_accum_offset 16
		.amdhsa_reserve_vcc 0
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
	.size	convolution_2d, .Lfunc_end0-convolution_2d

	.set convolution_2d.num_vgpr, 13
	.set convolution_2d.num_agpr, 0
	.set convolution_2d.numbered_sgpr, 14
	.set convolution_2d.private_seg_size, 0
	.set convolution_2d.uses_vcc, 0
	.set convolution_2d.uses_flat_scratch, 0
	.set convolution_2d.has_dyn_sized_stack, 0
	.set convolution_2d.has_recursion, 0
	.set convolution_2d.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_convolution_2d
	.globl	__clang_ocl_kern_imp_convolution_2d
	.p2align	2
	.type	__clang_ocl_kern_imp_convolution_2d,@function
__clang_ocl_kern_imp_convolution_2d:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v17, 0x3ff, v31
	v_lshrrev_b32_e32 v6, 3, v17
	v_and_b32_e32 v7, 7, v17
	v_mul_u32_u24_e32 v6, 10, v6
	v_add_lshl_u32 v26, v6, v7, 2
	v_mov_b32_e32 v27, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[26:27]
	global_load_dwordx4 v[6:9], v[2:3], off
	global_load_dwordx3 v[14:16], v[0:1], off
	global_load_dwordx3 v[18:20], v[0:1], off offset:40
	global_load_dwordx4 v[10:13], v[2:3], off offset:16
	global_load_dwordx3 v[22:24], v[0:1], off offset:80
	global_load_dword v0, v[2:3], off offset:32
	v_lshlrev_b32_e32 v26, 2, v17
	s_waitcnt vmcnt(4)
	v_fma_f32 v2, v14, v6, 0
	v_fmac_f32_e32 v2, v15, v7
	v_fmac_f32_e32 v2, v16, v8
	s_waitcnt vmcnt(3)
	v_fmac_f32_e32 v2, v18, v9
	s_waitcnt vmcnt(2)
	v_fmac_f32_e32 v2, v19, v10
	v_fmac_f32_e32 v2, v20, v11
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v2, v22, v12
	v_fmac_f32_e32 v2, v23, v13
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v2, v24, v0
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[26:27]
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_convolution_2d, .Lfunc_end1-__clang_ocl_kern_imp_convolution_2d

	.set __clang_ocl_kern_imp_convolution_2d.num_vgpr, 32
	.set __clang_ocl_kern_imp_convolution_2d.num_agpr, 0
	.set __clang_ocl_kern_imp_convolution_2d.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_convolution_2d.private_seg_size, 0
	.set __clang_ocl_kern_imp_convolution_2d.uses_vcc, 0
	.set __clang_ocl_kern_imp_convolution_2d.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_convolution_2d.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_convolution_2d.has_recursion, 0
	.set __clang_ocl_kern_imp_convolution_2d.has_indirect_call, 0
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           convolution_2d
    .private_segment_fixed_size: 0
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         convolution_2d.kd
    .uniform_work_group_size: 1
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
