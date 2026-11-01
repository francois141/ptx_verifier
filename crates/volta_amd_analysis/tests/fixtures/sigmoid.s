	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	sigmoid
	.globl	sigmoid
	.p2align	8
	.type	sigmoid,@function
sigmoid:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_mov_b32 s0, 0x42aeac50
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, 0xc2800000, v1
	v_cmp_lt_f32_e32 vcc, s0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_mul_f32_e32 v1, 0xbfb8aa3b, v1
	v_exp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v2, 0x114b4ea4, v1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_add_f32_e32 v1, 1.0, v1
	v_rcp_f32_e32 v1, v1
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel sigmoid
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
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 4
		.amdhsa_accum_offset 4
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
	.size	sigmoid, .Lfunc_end0-sigmoid

	.set sigmoid.num_vgpr, 3
	.set sigmoid.num_agpr, 0
	.set sigmoid.numbered_sgpr, 4
	.set sigmoid.private_seg_size, 0
	.set sigmoid.uses_vcc, 1
	.set sigmoid.uses_flat_scratch, 0
	.set sigmoid.has_dyn_sized_stack, 0
	.set sigmoid.has_recursion, 0
	.set sigmoid.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_sigmoid
	.globl	__clang_ocl_kern_imp_sigmoid
	.p2align	2
	.type	__clang_ocl_kern_imp_sigmoid,@function
__clang_ocl_kern_imp_sigmoid:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	global_load_dword v0, v[0:1], off
	s_mov_b32 s0, 0x42aeac50
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, 0xc2800000, v0
	v_cmp_lt_f32_e32 vcc, s0, v0
	s_nop 1
	v_cndmask_b32_e32 v0, v0, v1, vcc
	v_mul_f32_e32 v0, 0xbfb8aa3b, v0
	v_exp_f32_e32 v0, v0
	s_nop 0
	v_mul_f32_e32 v1, 0x114b4ea4, v0
	v_cndmask_b32_e32 v0, v0, v1, vcc
	v_add_f32_e32 v0, 1.0, v0
	v_rcp_f32_e32 v6, v0
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[4:5]
	global_store_dword v[0:1], v6, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_sigmoid, .Lfunc_end1-__clang_ocl_kern_imp_sigmoid

	.set __clang_ocl_kern_imp_sigmoid.num_vgpr, 32
	.set __clang_ocl_kern_imp_sigmoid.num_agpr, 0
	.set __clang_ocl_kern_imp_sigmoid.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_sigmoid.private_seg_size, 0
	.set __clang_ocl_kern_imp_sigmoid.uses_vcc, 1
	.set __clang_ocl_kern_imp_sigmoid.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_sigmoid.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_sigmoid.has_recursion, 0
	.set __clang_ocl_kern_imp_sigmoid.has_indirect_call, 0
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
    .name:           sigmoid
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         sigmoid.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
