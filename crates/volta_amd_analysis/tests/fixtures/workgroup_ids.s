	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	workgroup_x
	.globl	workgroup_x
	.p2align	8
	.type	workgroup_x,@function
workgroup_x:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s2
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_x
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 3
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
	.size	workgroup_x, .Lfunc_end0-workgroup_x

	.set workgroup_x.num_vgpr, 2
	.set workgroup_x.num_agpr, 0
	.set workgroup_x.numbered_sgpr, 3
	.set workgroup_x.private_seg_size, 0
	.set workgroup_x.uses_vcc, 0
	.set workgroup_x.uses_flat_scratch, 0
	.set workgroup_x.has_dyn_sized_stack, 0
	.set workgroup_x.has_recursion, 0
	.set workgroup_x.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_x
	.globl	__clang_ocl_kern_imp_workgroup_x
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_x,@function
__clang_ocl_kern_imp_workgroup_x:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s12
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_workgroup_x, .Lfunc_end1-__clang_ocl_kern_imp_workgroup_x

	.set __clang_ocl_kern_imp_workgroup_x.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_x.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_x.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_x.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_x.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_x.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_x.has_indirect_call, 0
	.protected	workgroup_y
	.globl	workgroup_y
	.p2align	8
	.type	workgroup_y,@function
workgroup_y:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s3
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_y
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end2:
	.size	workgroup_y, .Lfunc_end2-workgroup_y

	.set workgroup_y.num_vgpr, 2
	.set workgroup_y.num_agpr, 0
	.set workgroup_y.numbered_sgpr, 4
	.set workgroup_y.private_seg_size, 0
	.set workgroup_y.uses_vcc, 0
	.set workgroup_y.uses_flat_scratch, 0
	.set workgroup_y.has_dyn_sized_stack, 0
	.set workgroup_y.has_recursion, 0
	.set workgroup_y.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_y
	.globl	__clang_ocl_kern_imp_workgroup_y
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_y,@function
__clang_ocl_kern_imp_workgroup_y:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s13
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end3:
	.size	__clang_ocl_kern_imp_workgroup_y, .Lfunc_end3-__clang_ocl_kern_imp_workgroup_y

	.set __clang_ocl_kern_imp_workgroup_y.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_y.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_y.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_y.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_y.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_y.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_y.has_indirect_call, 0
	.protected	workgroup_z
	.globl	workgroup_z
	.p2align	8
	.type	workgroup_z,@function
workgroup_z:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s3
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_z
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 4
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
.Lfunc_end4:
	.size	workgroup_z, .Lfunc_end4-workgroup_z

	.set workgroup_z.num_vgpr, 2
	.set workgroup_z.num_agpr, 0
	.set workgroup_z.numbered_sgpr, 4
	.set workgroup_z.private_seg_size, 0
	.set workgroup_z.uses_vcc, 0
	.set workgroup_z.uses_flat_scratch, 0
	.set workgroup_z.has_dyn_sized_stack, 0
	.set workgroup_z.has_recursion, 0
	.set workgroup_z.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_z
	.globl	__clang_ocl_kern_imp_workgroup_z
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_z,@function
__clang_ocl_kern_imp_workgroup_z:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s14
	global_store_dword v[0:1], v2, off
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end5:
	.size	__clang_ocl_kern_imp_workgroup_z, .Lfunc_end5-__clang_ocl_kern_imp_workgroup_z

	.set __clang_ocl_kern_imp_workgroup_z.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_z.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_z.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_z.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_z.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_z.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_z.has_indirect_call, 0
	.protected	workgroup_xyz
	.globl	workgroup_xyz
	.p2align	8
	.type	workgroup_xyz,@function
workgroup_xyz:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v1, s2
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	v_mov_b32_e32 v1, s3
	global_store_dword v0, v1, s[0:1] offset:256
	v_mov_b32_e32 v1, s4
	global_store_dword v0, v1, s[0:1] offset:512
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel workgroup_xyz
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 2
		.amdhsa_next_free_sgpr 5
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
.Lfunc_end6:
	.size	workgroup_xyz, .Lfunc_end6-workgroup_xyz

	.set workgroup_xyz.num_vgpr, 2
	.set workgroup_xyz.num_agpr, 0
	.set workgroup_xyz.numbered_sgpr, 5
	.set workgroup_xyz.private_seg_size, 0
	.set workgroup_xyz.uses_vcc, 0
	.set workgroup_xyz.uses_flat_scratch, 0
	.set workgroup_xyz.has_dyn_sized_stack, 0
	.set workgroup_xyz.has_recursion, 0
	.set workgroup_xyz.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_workgroup_xyz
	.globl	__clang_ocl_kern_imp_workgroup_xyz
	.p2align	2
	.type	__clang_ocl_kern_imp_workgroup_xyz,@function
__clang_ocl_kern_imp_workgroup_xyz:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v2, 0x3ff, v31
	v_lshlrev_b32_e32 v2, 2, v2
	v_mov_b32_e32 v3, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[2:3]
	v_mov_b32_e32 v2, s12
	global_store_dword v[0:1], v2, off
	v_mov_b32_e32 v2, s13
	global_store_dword v[0:1], v2, off offset:256
	v_mov_b32_e32 v2, s14
	global_store_dword v[0:1], v2, off offset:512
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end7:
	.size	__clang_ocl_kern_imp_workgroup_xyz, .Lfunc_end7-__clang_ocl_kern_imp_workgroup_xyz

	.set __clang_ocl_kern_imp_workgroup_xyz.num_vgpr, 32
	.set __clang_ocl_kern_imp_workgroup_xyz.num_agpr, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_workgroup_xyz.private_seg_size, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.uses_vcc, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_recursion, 0
	.set __clang_ocl_kern_imp_workgroup_xyz.has_indirect_call, 0
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
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           workgroup_x
    .private_segment_fixed_size: 0
    .sgpr_count:     9
    .sgpr_spill_count: 0
    .symbol:         workgroup_x.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           workgroup_y
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         workgroup_y.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           workgroup_z
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         workgroup_z.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           workgroup_xyz
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         workgroup_xyz.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     2
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
