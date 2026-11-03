	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	softmax
	.globl	softmax
	.p2align	8
	.type	softmax,@function
softmax:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_and_b32_e32 v0, 63, v0
	v_lshlrev_b32_e32 v0, 2, v0
	v_xor_b32_e32 v3, 4, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	v_xor_b32_e32 v5, 8, v0
	v_xor_b32_e32 v7, 16, v0
	v_xor_b32_e32 v0, 32, v0
	s_waitcnt vmcnt(0)
	ds_bpermute_b32 v4, v3, v2
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v4, v2, v4
	ds_bpermute_b32 v6, v5, v4
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v4, v4, v6
	ds_bpermute_b32 v6, v7, v4
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v4, v4, v6
	ds_bpermute_b32 v6, v0, v4
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v4, v4, v6
	v_sub_f32_e32 v2, v2, v4
	v_mul_f32_e32 v2, 0x3fb8aa3b, v2
	v_exp_f32_e32 v2, v2
	ds_bpermute_b32 v3, v3, v2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v3, v2, v3
	ds_bpermute_b32 v4, v5, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v3, v3, v4
	ds_bpermute_b32 v4, v7, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v3, v3, v4
	ds_bpermute_b32 v0, v0, v3
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v3, v0
	v_rcp_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v0, v0, v2
	global_store_dword v1, v0, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel softmax
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_sgpr 4
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
	.size	softmax, .Lfunc_end0-softmax

	.set softmax.num_vgpr, 8
	.set softmax.num_agpr, 0
	.set softmax.numbered_sgpr, 4
	.set softmax.private_seg_size, 0
	.set softmax.uses_vcc, 0
	.set softmax.uses_flat_scratch, 0
	.set softmax.has_dyn_sized_stack, 0
	.set softmax.has_recursion, 0
	.set softmax.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_softmax
	.globl	__clang_ocl_kern_imp_softmax
	.p2align	2
	.type	__clang_ocl_kern_imp_softmax,@function
__clang_ocl_kern_imp_softmax:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v6
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	v_and_b32_e32 v1, 63, v6
	v_lshlrev_b32_e32 v1, 2, v1
	v_xor_b32_e32 v6, 4, v1
	v_xor_b32_e32 v8, 8, v1
	v_xor_b32_e32 v10, 16, v1
	v_xor_b32_e32 v1, 32, v1
	s_waitcnt vmcnt(0)
	ds_bpermute_b32 v7, v6, v0
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v0, v7
	ds_bpermute_b32 v9, v8, v7
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v7, v9
	ds_bpermute_b32 v9, v10, v7
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v7, v9
	ds_bpermute_b32 v9, v1, v7
	s_waitcnt lgkmcnt(0)
	v_max_f32_e32 v7, v7, v9
	v_sub_f32_e32 v0, v0, v7
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
	v_exp_f32_e32 v0, v0
	ds_bpermute_b32 v6, v6, v0
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, v0, v6
	ds_bpermute_b32 v7, v8, v6
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, v6, v7
	ds_bpermute_b32 v7, v10, v6
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v6, v6, v7
	ds_bpermute_b32 v1, v1, v6
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v6, v1
	v_rcp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v6, v1, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_softmax, .Lfunc_end1-__clang_ocl_kern_imp_softmax

	.set __clang_ocl_kern_imp_softmax.num_vgpr, 32
	.set __clang_ocl_kern_imp_softmax.num_agpr, 0
	.set __clang_ocl_kern_imp_softmax.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_softmax.private_seg_size, 0
	.set __clang_ocl_kern_imp_softmax.uses_vcc, 0
	.set __clang_ocl_kern_imp_softmax.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_softmax.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_softmax.has_recursion, 0
	.set __clang_ocl_kern_imp_softmax.has_indirect_call, 0
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
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           softmax
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         softmax.kd
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
