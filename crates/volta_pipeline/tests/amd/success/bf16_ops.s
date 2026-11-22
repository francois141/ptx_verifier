	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	bf16_ops
	.globl	bf16_ops
	.p2align	8
	.type	bf16_ops,@function
bf16_ops:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshlrev_b32_e32 v4, 1, v0
	v_and_b32_e32 v0, 0xfe, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[4:5]
	global_load_dword v3, v1, s[6:7]
	v_lshlrev_b32_e32 v0, 1, v0
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v5, v2, v3
	v_xor_b32_e32 v5, 0x80008000, v5
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v7, 0xffff0000, v5
	;;#ASMEND
	global_store_dword v1, v6, s[0:1]
	global_store_dword v1, v7, s[0:1] offset:256
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v3, v2, v2
	ds_write_b16 v4, v3
	s_waitcnt lgkmcnt(0)
	ds_read_b32 v5, v0
	s_waitcnt lgkmcnt(0)
	v_lshlrev_b32_e32 v6, 16, v5
	v_and_b32_e32 v7, 0xffff0000, v5
	;;#ASMEND
	global_store_dword v1, v6, s[0:1] offset:512
	global_store_dword v1, v7, s[0:1] offset:768
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel bf16_ops
		.amdhsa_group_segment_fixed_size 128
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
		.amdhsa_next_free_vgpr 8
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
	.size	bf16_ops, .Lfunc_end0-bf16_ops

	.set bf16_ops.num_vgpr, 8
	.set bf16_ops.num_agpr, 0
	.set bf16_ops.numbered_sgpr, 8
	.set bf16_ops.private_seg_size, 0
	.set bf16_ops.uses_vcc, 0
	.set bf16_ops.uses_flat_scratch, 0
	.set bf16_ops.has_dyn_sized_stack, 0
	.set bf16_ops.has_recursion, 0
	.set bf16_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_bf16_ops
	.globl	__clang_ocl_kern_imp_bf16_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_bf16_ops,@function
__clang_ocl_kern_imp_bf16_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v6
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[6:7]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	global_load_dword v2, v[2:3], off
	global_load_dword v3, v[0:1], off
	v_lshl_add_u64 v[0:1], v[4:5], 0, v[6:7]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v4, v3, v2
	v_xor_b32_e32 v4, 0x80008000, v4
	v_lshlrev_b32_e32 v5, 16, v4
	v_and_b32_e32 v6, 0xffff0000, v4
	;;#ASMEND
	global_store_dword v[0:1], v5, off
	global_store_dword v[0:1], v6, off offset:256
	s_trap 2
	;;#ASMSTART
	v_cvt_pk_bf16_f32 v2, v3, v3
	ds_write_b16 v0, v2
	s_waitcnt lgkmcnt(0)
	ds_read_b32 v4, v0
	s_waitcnt lgkmcnt(0)
	v_lshlrev_b32_e32 v5, 16, v4
	v_and_b32_e32 v6, 0xffff0000, v4
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:512
	global_store_dword v[0:1], v6, off offset:768
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_bf16_ops, .Lfunc_end1-__clang_ocl_kern_imp_bf16_ops

	.set __clang_ocl_kern_imp_bf16_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_bf16_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_bf16_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_bf16_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_bf16_ops.uses_vcc, 0
	.set __clang_ocl_kern_imp_bf16_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_bf16_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_bf16_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_bf16_ops.has_indirect_call, 0
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
	.addrsig_sym bf16_ops.shared
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
    .group_segment_fixed_size: 128
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           bf16_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         bf16_ops.kd
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
