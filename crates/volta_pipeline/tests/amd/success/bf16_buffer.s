	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	bf16_buffer
	.globl	bf16_buffer
	.p2align	8
	.type	bf16_buffer,@function
bf16_buffer:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	s_mov_b32 s7, 0x20000
	s_movk_i32 s6, 0x80
	v_lshlrev_b32_e32 v0, 1, v0
	v_sub_u32_e32 v1, 0x7e, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s1, 0xffff
	s_mov_b32 s4, s0
	s_mov_b64 s[10:11], s[6:7]
	s_and_b32 s0, s3, 0xffff
	s_mov_b64 s[8:9], s[4:5]
	s_mov_b32 s8, s2
	s_mov_b32 s9, s0
	;;#ASMSTART
	buffer_load_ushort v2, v0, s[4:7], 0 offen
	s_waitcnt vmcnt(0)
	buffer_store_short v2, v1, s[8:11], 0 offen
	;;#ASMEND
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel bf16_buffer
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
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 4
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
	.size	bf16_buffer, .Lfunc_end0-bf16_buffer

	.set bf16_buffer.num_vgpr, 3
	.set bf16_buffer.num_agpr, 0
	.set bf16_buffer.numbered_sgpr, 12
	.set bf16_buffer.private_seg_size, 0
	.set bf16_buffer.uses_vcc, 0
	.set bf16_buffer.uses_flat_scratch, 0
	.set bf16_buffer.has_dyn_sized_stack, 0
	.set bf16_buffer.has_recursion, 0
	.set bf16_buffer.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_bf16_buffer
	.globl	__clang_ocl_kern_imp_bf16_buffer
	.p2align	2
	.type	__clang_ocl_kern_imp_bf16_buffer,@function
__clang_ocl_kern_imp_bf16_buffer:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_readfirstlane_b32 s1, v1
	s_mov_b32 s3, 0x20000
	s_movk_i32 s2, 0x80
	v_readfirstlane_b32 s4, v3
	v_readfirstlane_b32 s0, v0
	s_and_b32 s1, s1, 0xffff
	s_and_b32 s9, s4, 0xffff
	s_mov_b64 s[6:7], s[2:3]
	v_and_b32_e32 v0, 0x3ff, v31
	v_readfirstlane_b32 s8, v2
	s_mov_b64 s[4:5], s[0:1]
	v_lshlrev_b32_e32 v0, 1, v0
	s_mov_b32 s4, s8
	s_mov_b32 s5, s9
	v_sub_u32_e32 v1, 0x7e, v0
	;;#ASMSTART
	buffer_load_ushort v2, v0, s[0:3], 0 offen
	s_waitcnt vmcnt(0)
	buffer_store_short v2, v1, s[4:7], 0 offen
	;;#ASMEND
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_bf16_buffer, .Lfunc_end1-__clang_ocl_kern_imp_bf16_buffer

	.set __clang_ocl_kern_imp_bf16_buffer.num_vgpr, 32
	.set __clang_ocl_kern_imp_bf16_buffer.num_agpr, 0
	.set __clang_ocl_kern_imp_bf16_buffer.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_bf16_buffer.private_seg_size, 0
	.set __clang_ocl_kern_imp_bf16_buffer.uses_vcc, 0
	.set __clang_ocl_kern_imp_bf16_buffer.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_bf16_buffer.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_bf16_buffer.has_recursion, 0
	.set __clang_ocl_kern_imp_bf16_buffer.has_indirect_call, 0
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
        .type_name:      'ushort*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .type_name:      'ushort*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           bf16_buffer
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         bf16_buffer.kd
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
