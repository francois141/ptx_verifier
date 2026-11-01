	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	matmul
	.globl	matmul
	.p2align	8
	.type	matmul,@function
matmul:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_and_b32_e32 v1, 0xf8, v0
	v_lshlrev_b32_e32 v1, 2, v1
	v_and_b32_e32 v9, 7, v0
	s_waitcnt lgkmcnt(0)
	global_load_dwordx3 v[6:8], v1, s[4:5] offset:16
	global_load_dwordx4 v[2:5], v1, s[4:5]
	v_lshlrev_b32_e32 v0, 2, v0
	v_lshlrev_b32_e32 v1, 2, v9
	v_or_b32_e32 v9, 28, v0
	global_load_dword v9, v9, s[4:5]
	global_load_dword v10, v1, s[6:7]
	global_load_dword v11, v1, s[6:7] offset:32
	global_load_dword v12, v1, s[6:7] offset:64
	global_load_dword v13, v1, s[6:7] offset:96
	global_load_dword v14, v1, s[6:7] offset:128
	global_load_dword v15, v1, s[6:7] offset:160
	global_load_dword v16, v1, s[6:7] offset:192
	global_load_dword v1, v1, s[6:7] offset:224
	s_waitcnt vmcnt(7)
	v_fma_f32 v2, v2, v10, 0
	s_waitcnt vmcnt(6)
	v_fmac_f32_e32 v2, v3, v11
	s_waitcnt vmcnt(5)
	v_fmac_f32_e32 v2, v4, v12
	s_waitcnt vmcnt(4)
	v_fmac_f32_e32 v2, v5, v13
	s_waitcnt vmcnt(3)
	v_fmac_f32_e32 v2, v6, v14
	s_waitcnt vmcnt(2)
	v_fmac_f32_e32 v2, v7, v15
	s_waitcnt vmcnt(1)
	v_fmac_f32_e32 v2, v8, v16
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v2, v9, v1
	global_store_dword v0, v2, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel matmul
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
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 20
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
	.size	matmul, .Lfunc_end0-matmul

	.set matmul.num_vgpr, 17
	.set matmul.num_agpr, 0
	.set matmul.numbered_sgpr, 8
	.set matmul.private_seg_size, 0
	.set matmul.uses_vcc, 0
	.set matmul.uses_flat_scratch, 0
	.set matmul.has_dyn_sized_stack, 0
	.set matmul.has_recursion, 0
	.set matmul.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_matmul
	.globl	__clang_ocl_kern_imp_matmul
	.p2align	2
	.type	__clang_ocl_kern_imp_matmul,@function
__clang_ocl_kern_imp_matmul:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v13, 0x3ff, v31
	v_and_b32_e32 v6, 0xf8, v13
	v_lshlrev_b32_e32 v14, 2, v6
	v_mov_b32_e32 v15, 0
	v_lshl_add_u64 v[6:7], v[0:1], 0, v[14:15]
	global_load_dwordx3 v[10:12], v[6:7], off offset:16
	global_load_dwordx4 v[6:9], v[6:7], off
	v_and_b32_e32 v16, 7, v13
	v_lshlrev_b32_e32 v14, 2, v16
	v_lshlrev_b32_e32 v16, 2, v13
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[14:15]
	v_or_b32_e32 v14, 28, v16
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[14:15]
	global_load_dword v13, v[2:3], off
	global_load_dword v14, v[2:3], off offset:32
	global_load_dword v18, v[2:3], off offset:64
	global_load_dword v19, v[2:3], off offset:96
	global_load_dword v20, v[2:3], off offset:128
	global_load_dword v21, v[2:3], off offset:160
	global_load_dword v22, v[2:3], off offset:192
	global_load_dword v2, v[2:3], off offset:224
	global_load_dword v0, v[0:1], off
	v_mov_b32_e32 v17, v15
	s_waitcnt vmcnt(8)
	v_fma_f32 v3, v6, v13, 0
	s_waitcnt vmcnt(7)
	v_fmac_f32_e32 v3, v7, v14
	s_waitcnt vmcnt(6)
	v_fmac_f32_e32 v3, v8, v18
	s_waitcnt vmcnt(5)
	v_fmac_f32_e32 v3, v9, v19
	s_waitcnt vmcnt(4)
	v_fmac_f32_e32 v3, v10, v20
	s_waitcnt vmcnt(3)
	v_fmac_f32_e32 v3, v11, v21
	s_waitcnt vmcnt(2)
	v_fmac_f32_e32 v3, v12, v22
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v3, v0, v2
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[16:17]
	global_store_dword v[0:1], v3, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_matmul, .Lfunc_end1-__clang_ocl_kern_imp_matmul

	.set __clang_ocl_kern_imp_matmul.num_vgpr, 32
	.set __clang_ocl_kern_imp_matmul.num_agpr, 0
	.set __clang_ocl_kern_imp_matmul.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_matmul.private_seg_size, 0
	.set __clang_ocl_kern_imp_matmul.uses_vcc, 0
	.set __clang_ocl_kern_imp_matmul.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_matmul.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_matmul.has_recursion, 0
	.set __clang_ocl_kern_imp_matmul.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 32
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 32
	.text
	.ident	"Homebrew clang version 21.1.1"
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
    .name:           matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         matmul.kd
    .uniform_work_group_size: 1
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
