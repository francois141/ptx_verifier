	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	convert_ops
	.globl	convert_ops
	.p2align	8
	.type	convert_ops,@function
convert_ops:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_subrev_u32_e32 v3, 32, v0
	v_lshlrev_b32_e32 v2, 4, v0
	v_lshlrev_b32_e32 v0, 8, v3
	;;#ASMSTART
	v_cvt_f32_i32_e32 v1, v0
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	global_store_dword v2, v1, s[0:1]
	v_readfirstlane_b32 s4, v0
	;;#ASMSTART
	v_cvt_f32_u32_e32 v0, v0
	;;#ASMEND
	global_store_dword v2, v0, s[0:1] offset:4
	;;#ASMSTART
	v_cvt_f32_i32_e32 v0, s4
	;;#ASMEND
	global_store_dword v2, v0, s[0:1] offset:8
	;;#ASMSTART
	v_cvt_f32_u32_e32 v0, s4
	;;#ASMEND
	global_store_dword v2, v0, s[0:1] offset:12
	;;#ASMSTART
	v_cvt_f32_i32_e32 v4, v3
	v_mul_f32_e32 v4, 0.5, v4
	v_cvt_i32_f32_e32 v0, v4
	v_cvt_u32_f32_e32 v1, v4
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[2:3]
	;;#ASMSTART
	v_cvt_f32_i32_e32 v4, v3
	v_mul_f32_e32 v5, 0x4d800000, v4
	v_mul_f32_e32 v4, 0x4d000000, v4
	v_cvt_i32_f32_e32 v0, v4
	v_cvt_u32_f32_e32 v1, v5
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:8
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel convert_ops
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
		.amdhsa_next_free_vgpr 6
		.amdhsa_next_free_sgpr 5
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
	.size	convert_ops, .Lfunc_end0-convert_ops

	.set convert_ops.num_vgpr, 6
	.set convert_ops.num_agpr, 0
	.set convert_ops.numbered_sgpr, 5
	.set convert_ops.private_seg_size, 0
	.set convert_ops.uses_vcc, 0
	.set convert_ops.uses_flat_scratch, 0
	.set convert_ops.has_dyn_sized_stack, 0
	.set convert_ops.has_recursion, 0
	.set convert_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_convert_ops
	.globl	__clang_ocl_kern_imp_convert_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_convert_ops,@function
__clang_ocl_kern_imp_convert_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v6, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 4, v6
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[4:5]
	v_subrev_u32_e32 v4, 32, v6
	v_lshlrev_b32_e32 v5, 8, v4
	;;#ASMSTART
	v_cvt_f32_i32_e32 v6, v5
	;;#ASMEND
	global_store_dword v[0:1], v6, off
	v_readfirstlane_b32 s0, v5
	;;#ASMSTART
	v_cvt_f32_u32_e32 v5, v5
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:4
	;;#ASMSTART
	v_cvt_f32_i32_e32 v5, s0
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:8
	;;#ASMSTART
	v_cvt_f32_u32_e32 v5, s0
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:12
	;;#ASMSTART
	v_cvt_f32_i32_e32 v5, v4
	v_mul_f32_e32 v5, 0.5, v5
	v_cvt_i32_f32_e32 v0, v5
	v_cvt_u32_f32_e32 v1, v5
	;;#ASMEND
	global_store_dwordx2 v[2:3], v[0:1], off
	;;#ASMSTART
	v_cvt_f32_i32_e32 v5, v4
	v_mul_f32_e32 v6, 0x4d800000, v5
	v_mul_f32_e32 v5, 0x4d000000, v5
	v_cvt_i32_f32_e32 v0, v5
	v_cvt_u32_f32_e32 v1, v6
	;;#ASMEND
	global_store_dwordx2 v[2:3], v[0:1], off offset:8
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_convert_ops, .Lfunc_end1-__clang_ocl_kern_imp_convert_ops

	.set __clang_ocl_kern_imp_convert_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_convert_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_convert_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_convert_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_convert_ops.uses_vcc, 0
	.set __clang_ocl_kern_imp_convert_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_convert_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_convert_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_convert_ops.has_indirect_call, 0
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
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           convert_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         convert_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     6
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
