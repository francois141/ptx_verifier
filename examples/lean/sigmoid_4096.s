	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	sigmoid_4096
	.globl	sigmoid_4096
	.p2align	8
	.type	sigmoid_4096,@function
sigmoid_4096:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	s_mov_b32 s4, 0x42aeac50
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v2, 0x42800000, v1
	v_cmp_lt_f32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -v1, v2, vcc
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v2, 0x114b4ea4, v1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_add_f32_e32 v1, 1.0, v1
	v_rcp_f32_e32 v1, v1
	v_or_b32_e32 v2, 0x1000, v0
	global_store_dword v0, v1, s[2:3]
	global_load_dword v1, v2, s[0:1]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v3, 0x42800000, v1
	v_cmp_lt_f32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -v1, v3, vcc
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v3, 0x114b4ea4, v1
	v_cndmask_b32_e32 v1, v1, v3, vcc
	v_add_f32_e32 v1, 1.0, v1
	v_rcp_f32_e32 v1, v1
	v_or_b32_e32 v3, 0x2000, v0
	v_or_b32_e32 v0, 0x3000, v0
	global_store_dword v2, v1, s[2:3]
	global_load_dword v1, v3, s[0:1]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v2, 0x42800000, v1
	v_cmp_lt_f32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -v1, v2, vcc
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
	v_exp_f32_e32 v1, v1
	s_nop 0
	v_mul_f32_e32 v2, 0x114b4ea4, v1
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_add_f32_e32 v1, 1.0, v1
	v_rcp_f32_e32 v1, v1
	global_store_dword v3, v1, s[2:3]
	global_load_dword v1, v0, s[0:1]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v2, 0x42800000, v1
	v_cmp_lt_f32_e32 vcc, s4, v1
	s_nop 1
	v_cndmask_b32_e64 v1, -v1, v2, vcc
	v_mul_f32_e32 v1, 0x3fb8aa3b, v1
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
	.amdhsa_kernel sigmoid_4096
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 5
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
	.size	sigmoid_4096, .Lfunc_end0-sigmoid_4096

	.set sigmoid_4096.num_vgpr, 4
	.set sigmoid_4096.num_agpr, 0
	.set sigmoid_4096.numbered_sgpr, 5
	.set sigmoid_4096.private_seg_size, 0
	.set sigmoid_4096.uses_vcc, 1
	.set sigmoid_4096.uses_flat_scratch, 0
	.set sigmoid_4096.has_dyn_sized_stack, 0
	.set sigmoid_4096.has_recursion, 0
	.set sigmoid_4096.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_sigmoid_4096
	.globl	__clang_ocl_kern_imp_sigmoid_4096
	.p2align	2
	.type	__clang_ocl_kern_imp_sigmoid_4096,@function
__clang_ocl_kern_imp_sigmoid_4096:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v4, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 2, v4
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[6:7], v[0:1], 0, v[4:5]
	global_load_dword v6, v[6:7], off
	s_mov_b32 s0, 0x42aeac50
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v7, 0x42800000, v6
	v_cmp_lt_f32_e32 vcc, s0, v6
	s_nop 1
	v_cndmask_b32_e64 v6, -v6, v7, vcc
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	v_mov_b32_e32 v7, v5
	v_mul_f32_e32 v8, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v8, vcc
	v_add_f32_e32 v6, 1.0, v6
	v_rcp_f32_e32 v12, v6
	v_lshl_add_u64 v[8:9], v[2:3], 0, v[4:5]
	v_or_b32_e32 v6, 0x1000, v4
	v_lshl_add_u64 v[10:11], v[0:1], 0, v[6:7]
	global_store_dword v[8:9], v12, off
	global_load_dword v8, v[10:11], off
	v_lshl_add_u64 v[6:7], v[2:3], 0, v[6:7]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v9, 0x42800000, v8
	v_cmp_lt_f32_e32 vcc, s0, v8
	s_nop 1
	v_cndmask_b32_e64 v8, -v8, v9, vcc
	v_mul_f32_e32 v8, 0x3fb8aa3b, v8
	v_exp_f32_e32 v8, v8
	v_mov_b32_e32 v9, v5
	v_mul_f32_e32 v10, 0x114b4ea4, v8
	v_cndmask_b32_e32 v8, v8, v10, vcc
	v_add_f32_e32 v8, 1.0, v8
	v_rcp_f32_e32 v12, v8
	v_or_b32_e32 v8, 0x2000, v4
	v_lshl_add_u64 v[10:11], v[0:1], 0, v[8:9]
	v_or_b32_e32 v4, 0x3000, v4
	global_store_dword v[6:7], v12, off
	global_load_dword v6, v[10:11], off
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v7, 0x42800000, v6
	v_cmp_lt_f32_e32 vcc, s0, v6
	s_nop 1
	v_cndmask_b32_e64 v6, -v6, v7, vcc
	v_mul_f32_e32 v6, 0x3fb8aa3b, v6
	v_exp_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v7, 0x114b4ea4, v6
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_add_f32_e32 v6, 1.0, v6
	v_rcp_f32_e32 v10, v6
	v_lshl_add_u64 v[6:7], v[2:3], 0, v[8:9]
	global_store_dword v[6:7], v10, off
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v1, 0x42800000, v0
	v_cmp_lt_f32_e32 vcc, s0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, -v0, v1, vcc
	v_mul_f32_e32 v0, 0x3fb8aa3b, v0
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
	.size	__clang_ocl_kern_imp_sigmoid_4096, .Lfunc_end1-__clang_ocl_kern_imp_sigmoid_4096

	.set __clang_ocl_kern_imp_sigmoid_4096.num_vgpr, 32
	.set __clang_ocl_kern_imp_sigmoid_4096.num_agpr, 0
	.set __clang_ocl_kern_imp_sigmoid_4096.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_sigmoid_4096.private_seg_size, 0
	.set __clang_ocl_kern_imp_sigmoid_4096.uses_vcc, 1
	.set __clang_ocl_kern_imp_sigmoid_4096.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_sigmoid_4096.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_sigmoid_4096.has_recursion, 0
	.set __clang_ocl_kern_imp_sigmoid_4096.has_indirect_call, 0
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
    .name:           sigmoid_4096
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         sigmoid_4096.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
