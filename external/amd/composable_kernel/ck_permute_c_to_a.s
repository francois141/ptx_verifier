	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_permute_c_to_a
	.globl	ck_permute_c_to_a
	.p2align	8
	.type	ck_permute_c_to_a,@function
ck_permute_c_to_a:
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_2
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_mov_b32_e32 v2, 0
	s_waitcnt lgkmcnt(0)
	s_load_dword s4, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v0, s4
	v_mov_b32_e32 v1, s4
	global_store_dwordx2 v2, v[0:1], s[2:3]
	global_load_dword v0, v2, s[0:1] offset:4
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:8
	global_load_dword v0, v2, s[0:1] offset:8
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:16
	global_load_dword v0, v2, s[0:1] offset:12
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:24
	global_load_dword v0, v2, s[0:1] offset:16
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:32
	global_load_dword v0, v2, s[0:1] offset:20
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:40
	global_load_dword v0, v2, s[0:1] offset:24
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:48
	global_load_dword v0, v2, s[0:1] offset:28
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:56
	global_load_dword v0, v2, s[0:1] offset:32
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:64
	global_load_dword v0, v2, s[0:1] offset:36
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:72
	global_load_dword v0, v2, s[0:1] offset:40
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:80
	global_load_dword v0, v2, s[0:1] offset:44
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:88
	global_load_dword v0, v2, s[0:1] offset:48
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:96
	global_load_dword v0, v2, s[0:1] offset:52
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:104
	global_load_dword v0, v2, s[0:1] offset:56
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:112
	global_load_dword v0, v2, s[0:1] offset:60
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:120
.LBB0_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_permute_c_to_a
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
		.amdhsa_next_free_sgpr 5
		.amdhsa_accum_offset 4
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
	.size	ck_permute_c_to_a, .Lfunc_end0-ck_permute_c_to_a

	.set ck_permute_c_to_a.num_vgpr, 3
	.set ck_permute_c_to_a.num_agpr, 0
	.set ck_permute_c_to_a.numbered_sgpr, 5
	.set ck_permute_c_to_a.private_seg_size, 0
	.set ck_permute_c_to_a.uses_vcc, 1
	.set ck_permute_c_to_a.uses_flat_scratch, 0
	.set ck_permute_c_to_a.has_dyn_sized_stack, 0
	.set ck_permute_c_to_a.has_recursion, 0
	.set ck_permute_c_to_a.has_indirect_call, 0
	.protected	ck_permute_c_to_a_fixed
	.globl	ck_permute_c_to_a_fixed
	.p2align	8
	.type	ck_permute_c_to_a_fixed,@function
ck_permute_c_to_a_fixed:
	v_cmp_eq_u32_e32 vcc, 0, v0
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB1_2
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_mov_b32_e32 v2, 0
	s_waitcnt lgkmcnt(0)
	s_load_dword s4, s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v0, s4
	v_mov_b32_e32 v1, s4
	global_store_dwordx2 v2, v[0:1], s[2:3]
	global_load_dword v0, v2, s[0:1] offset:4
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:8
	global_load_dword v0, v2, s[0:1] offset:8
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:16
	global_load_dword v0, v2, s[0:1] offset:12
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v1, v0
	global_store_dwordx2 v2, v[0:1], s[2:3] offset:24
.LBB1_2:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_permute_c_to_a_fixed
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
		.amdhsa_next_free_sgpr 5
		.amdhsa_accum_offset 4
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
.Lfunc_end1:
	.size	ck_permute_c_to_a_fixed, .Lfunc_end1-ck_permute_c_to_a_fixed

	.set ck_permute_c_to_a_fixed.num_vgpr, 3
	.set ck_permute_c_to_a_fixed.num_agpr, 0
	.set ck_permute_c_to_a_fixed.numbered_sgpr, 5
	.set ck_permute_c_to_a_fixed.private_seg_size, 0
	.set ck_permute_c_to_a_fixed.uses_vcc, 1
	.set ck_permute_c_to_a_fixed.uses_flat_scratch, 0
	.set ck_permute_c_to_a_fixed.has_dyn_sized_stack, 0
	.set ck_permute_c_to_a_fixed.has_recursion, 0
	.set ck_permute_c_to_a_fixed.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_58937c46d22ea602,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_58937c46d22ea602
__hip_cuid_58937c46d22ea602:
	.byte	0
	.size	__hip_cuid_58937c46d22ea602, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_58937c46d22ea602
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .max_flat_workgroup_size: 1024
    .name:           ck_permute_c_to_a
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         ck_permute_c_to_a.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .max_flat_workgroup_size: 1024
    .name:           ck_permute_c_to_a_fixed
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         ck_permute_c_to_a_fixed.kd
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
