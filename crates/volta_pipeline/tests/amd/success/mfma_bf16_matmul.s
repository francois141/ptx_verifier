	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	mfma_bf16_matmul
	.globl	mfma_bf16_matmul
	.p2align	8
	.type	mfma_bf16_matmul,@function
mfma_bf16_matmul:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_and_b32_e32 v1, 15, v0
	v_lshrrev_b32_e32 v8, 4, v0
	v_lshlrev_b32_e32 v9, 2, v1
	v_add_lshl_u32 v4, v9, v8, 4
	s_waitcnt lgkmcnt(0)
	global_load_dwordx4 v[0:3], v4, s[4:5]
	global_load_dwordx4 v[4:7], v4, s[6:7]
	v_lshl_or_b32 v8, v8, 8, v9
	s_waitcnt vmcnt(0)
	v_mfma_f32_16x16x32_bf16 a[0:3], v[0:3], v[4:7], 0
	s_nop 7
	global_store_dword v8, a0, s[0:1]
	global_store_dword v8, a1, s[0:1] offset:64
	global_store_dword v8, a2, s[0:1] offset:128
	global_store_dword v8, a3, s[0:1] offset:192
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel mfma_bf16_matmul
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
		.amdhsa_next_free_vgpr 16
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 12
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
	.size	mfma_bf16_matmul, .Lfunc_end0-mfma_bf16_matmul

	.set mfma_bf16_matmul.num_vgpr, 10
	.set mfma_bf16_matmul.num_agpr, 4
	.set mfma_bf16_matmul.numbered_sgpr, 8
	.set mfma_bf16_matmul.private_seg_size, 0
	.set mfma_bf16_matmul.uses_vcc, 0
	.set mfma_bf16_matmul.uses_flat_scratch, 0
	.set mfma_bf16_matmul.has_dyn_sized_stack, 0
	.set mfma_bf16_matmul.has_recursion, 0
	.set mfma_bf16_matmul.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_mfma_bf16_matmul
	.globl	__clang_ocl_kern_imp_mfma_bf16_matmul
	.p2align	2
	.type	__clang_ocl_kern_imp_mfma_bf16_matmul,@function
__clang_ocl_kern_imp_mfma_bf16_matmul:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_and_b32_e32 v7, 15, v6
	v_lshrrev_b32_e32 v12, 4, v6
	v_lshlrev_b32_e32 v13, 2, v7
	v_add_lshl_u32 v10, v13, v12, 4
	v_mov_b32_e32 v11, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[10:11]
	global_load_dwordx4 v[6:9], v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[10:11]
	global_load_dwordx4 v[0:3], v[0:1], off
	v_lshl_or_b32 v10, v12, 8, v13
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[10:11]
	s_waitcnt vmcnt(0)
	v_mfma_f32_16x16x32_bf16 a[0:3], v[6:9], v[0:3], 0
	s_nop 7
	global_store_dword v[4:5], a0, off
	global_store_dword v[4:5], a1, off offset:64
	global_store_dword v[4:5], a2, off offset:128
	global_store_dword v[4:5], a3, off offset:192
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_mfma_bf16_matmul, .Lfunc_end1-__clang_ocl_kern_imp_mfma_bf16_matmul

	.set __clang_ocl_kern_imp_mfma_bf16_matmul.num_vgpr, 32
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.num_agpr, 4
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.private_seg_size, 0
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.uses_vcc, 0
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.has_recursion, 0
	.set __clang_ocl_kern_imp_mfma_bf16_matmul.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 32
	.set amdgpu.max_num_agpr, 4
	.set amdgpu.max_num_sgpr, 32
	.text
	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     4
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'bf16x8*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .offset:         8
        .size:           8
        .type_name:      'bf16x8*'
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
    .name:           mfma_bf16_matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         mfma_bf16_matmul.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     16
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
