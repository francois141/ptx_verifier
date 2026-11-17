	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	hardsigmoid
	.globl	hardsigmoid
	.p2align	8
	.type	hardsigmoid,@function
hardsigmoid:
	s_load_dword s2, s[0:1], 0x10
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_u32_e32 vcc, s2, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_2
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v2, 0x40c00000
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_mov_b32 s0, 0x40c00000
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, 0x40400000, v1
	v_cmp_ngt_f32_e32 vcc, 0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, 0, v1, vcc
	v_cmp_nlt_f32_e32 vcc, s0, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v2, v1, vcc
	v_mul_f32_e32 v1, 0x3e2aaaab, v1
	global_store_dword v0, v1, s[2:3]
.LBB0_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel hardsigmoid
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 20
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
	.size	hardsigmoid, .Lfunc_end0-hardsigmoid

	.set hardsigmoid.num_vgpr, 3
	.set hardsigmoid.num_agpr, 0
	.set hardsigmoid.numbered_sgpr, 4
	.set hardsigmoid.private_seg_size, 0
	.set hardsigmoid.uses_vcc, 1
	.set hardsigmoid.uses_flat_scratch, 0
	.set hardsigmoid.has_dyn_sized_stack, 0
	.set hardsigmoid.has_recursion, 0
	.set hardsigmoid.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_84b7475906afbe2f,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_84b7475906afbe2f
__hip_cuid_84b7475906afbe2f:
	.byte	0
	.size	__hip_cuid_84b7475906afbe2f, 1

	.ident	"Homebrew clang version 21.1.1"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_84b7475906afbe2f
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 20
    .max_flat_workgroup_size: 64
    .name:           hardsigmoid
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         hardsigmoid.kd
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
