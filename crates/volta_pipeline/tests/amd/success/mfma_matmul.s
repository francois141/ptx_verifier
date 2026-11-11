	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	mfma_matmul
	.globl	mfma_matmul
	.p2align	8
	.type	mfma_matmul,@function
mfma_matmul:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_lshrrev_b32_e32 v1, 3, v0
	v_and_b32_e32 v1, 16, v1
	v_lshrrev_b32_e32 v2, 2, v0
	v_and_b32_e32 v3, 15, v0
	v_bfe_u32 v0, v0, 4, 2
	v_or_b32_e32 v4, v1, v3
	v_lshlrev_b32_e32 v5, 2, v0
	v_lshl_or_b32 v4, v4, 5, v5
	s_waitcnt lgkmcnt(0)
	global_load_dword v5, v4, s[4:5]
	v_and_b32_e32 v2, 16, v2
	v_lshlrev_b32_e32 v6, 5, v0
	v_or3_b32 v6, v3, v6, v2
	v_lshlrev_b32_e32 v6, 2, v6
	global_load_dword v7, v6, s[6:7]
	global_load_dword v4, v4, s[4:5] offset:16
	global_load_dword v6, v6, s[6:7] offset:512
	v_lshlrev_b32_e32 v1, 5, v1
	v_lshl_or_b32 v0, v0, 7, v1
	v_or3_b32 v0, v3, v0, v2
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt vmcnt(2)
	v_mfma_f32_16x16x4_f32 a[0:3], v5, v7, 0
	s_waitcnt vmcnt(0)
	v_mfma_f32_16x16x4_f32 a[0:3], v4, v6, a[0:3]
	s_nop 7
	s_nop 1
	global_store_dword v0, a0, s[0:1]
	global_store_dword v0, a1, s[0:1] offset:128
	global_store_dword v0, a2, s[0:1] offset:256
	global_store_dword v0, a3, s[0:1] offset:384
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel mfma_matmul
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
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 8
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
	.size	mfma_matmul, .Lfunc_end0-mfma_matmul

	.set mfma_matmul.num_vgpr, 8
	.set mfma_matmul.num_agpr, 4
	.set mfma_matmul.numbered_sgpr, 8
	.set mfma_matmul.private_seg_size, 0
	.set mfma_matmul.uses_vcc, 0
	.set mfma_matmul.uses_flat_scratch, 0
	.set mfma_matmul.has_dyn_sized_stack, 0
	.set mfma_matmul.has_recursion, 0
	.set mfma_matmul.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_mfma_matmul
	.globl	__clang_ocl_kern_imp_mfma_matmul
	.p2align	2
	.type	__clang_ocl_kern_imp_mfma_matmul,@function
__clang_ocl_kern_imp_mfma_matmul:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_lshrrev_b32_e32 v7, 3, v6
	v_and_b32_e32 v8, 16, v7
	v_lshrrev_b32_e32 v7, 2, v6
	v_and_b32_e32 v10, 15, v6
	v_bfe_u32 v11, v6, 4, 2
	v_and_b32_e32 v9, 16, v7
	v_or_b32_e32 v6, v8, v10
	v_lshlrev_b32_e32 v7, 2, v11
	v_lshl_or_b32 v6, v6, 5, v7
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	global_load_dword v12, v[0:1], off
	v_lshlrev_b32_e32 v6, 5, v11
	v_or3_b32 v6, v10, v6, v9
	v_lshlrev_b32_e32 v6, 2, v6
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[6:7]
	global_load_dword v6, v[2:3], off
	global_load_dword v0, v[0:1], off offset:16
	global_load_dword v1, v[2:3], off offset:512
	v_lshlrev_b32_e32 v2, 5, v8
	s_waitcnt vmcnt(2)
	v_mfma_f32_16x16x4_f32 a[0:3], v12, v6, 0
	s_waitcnt vmcnt(0)
	v_mfma_f32_16x16x4_f32 a[0:3], v0, v1, a[0:3]
	v_lshl_or_b32 v0, v11, 7, v2
	v_or3_b32 v0, v10, v0, v9
	v_lshlrev_b32_e32 v6, 2, v0
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[6:7]
	s_nop 5
	global_store_dword v[0:1], a0, off
	global_store_dword v[0:1], a1, off offset:128
	global_store_dword v[0:1], a2, off offset:256
	global_store_dword v[0:1], a3, off offset:384
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_mfma_matmul, .Lfunc_end1-__clang_ocl_kern_imp_mfma_matmul

	.set __clang_ocl_kern_imp_mfma_matmul.num_vgpr, 32
	.set __clang_ocl_kern_imp_mfma_matmul.num_agpr, 4
	.set __clang_ocl_kern_imp_mfma_matmul.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_mfma_matmul.private_seg_size, 0
	.set __clang_ocl_kern_imp_mfma_matmul.uses_vcc, 0
	.set __clang_ocl_kern_imp_mfma_matmul.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_mfma_matmul.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_mfma_matmul.has_recursion, 0
	.set __clang_ocl_kern_imp_mfma_matmul.has_indirect_call, 0
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
    .name:           mfma_matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         mfma_matmul.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
