	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_reduce2d_cross_warp
	.globl	ck_reduce2d_cross_warp
	.p2align	8
	.type	ck_reduce2d_cross_warp,@function
ck_reduce2d_cross_warp:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	v_mbcnt_lo_u32_b32 v1, -1, 0
	v_readfirstlane_b32 s8, v0
	v_mbcnt_hi_u32_b32 v4, -1, v1
	v_lshrrev_b32_e32 v1, 2, v4
	s_lshr_b32 s0, s8, 3
	s_and_b32 s1, s0, 8
	v_lshlrev_b32_e32 v2, 1, v4
	s_and_b32 s9, s0, 0x3fffff0
	v_lshl_add_u32 v1, s2, 4, v1
	v_and_or_b32 v2, v2, 6, s1
	v_add_lshl_u32 v3, v1, s9, 6
	s_mov_b32 s3, 0x20000
	s_movk_i32 s2, 0x400
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s0, s4
	s_mov_b32 s1, s5
	v_lshl_or_b32 v2, v2, 2, v3
	buffer_load_dwordx2 v[2:3], v2, s[0:3], 0 offen
	v_lshlrev_b32_e32 v5, 2, v4
	v_xor_b32_e32 v6, 4, v5
	v_cmp_eq_u32_e32 vcc, 0, v4
	s_lshr_b32 s2, s8, 6
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v2, 0, v2
	v_add_f32_e32 v2, v2, v3
	ds_bpermute_b32 v3, v6, v2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	v_xor_b32_e32 v3, 8, v5
	ds_bpermute_b32 v3, v3, v2
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_2
	s_lshl_b32 s4, s2, 2
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v2, v2, v3
	v_mov_b32_e32 v3, s4
	ds_write_b32 v3, v2
.LBB0_2:
	s_or_b64 exec, exec, s[0:1]
	s_and_b32 s0, s2, 0x3fffffe
	s_lshl_b32 s0, s0, 2
	v_mov_b32_e32 v2, s0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[2:3], v2 offset1:1
	v_readfirstlane_b32 s0, v0
	s_lshr_b32 s0, s0, 3
	s_and_b32 s4, s0, 0x1ffffff0
	s_mov_b32 s2, 64
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v0, v2, v3
	s_mov_b32 s0, s6
	s_mov_b32 s1, s7
	v_add_lshl_u32 v1, v1, s4, 2
	buffer_store_dword v0, v1, s[0:3], 0 offen
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_reduce2d_cross_warp
		.amdhsa_group_segment_fixed_size 8
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
		.amdhsa_next_free_vgpr 7
		.amdhsa_next_free_sgpr 10
		.amdhsa_accum_offset 8
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
	.size	ck_reduce2d_cross_warp, .Lfunc_end0-ck_reduce2d_cross_warp

	.set ck_reduce2d_cross_warp.num_vgpr, 7
	.set ck_reduce2d_cross_warp.num_agpr, 0
	.set ck_reduce2d_cross_warp.numbered_sgpr, 10
	.set ck_reduce2d_cross_warp.private_seg_size, 0
	.set ck_reduce2d_cross_warp.uses_vcc, 1
	.set ck_reduce2d_cross_warp.uses_flat_scratch, 0
	.set ck_reduce2d_cross_warp.has_dyn_sized_stack, 0
	.set ck_reduce2d_cross_warp.has_recursion, 0
	.set ck_reduce2d_cross_warp.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_a5ce1efe47f9e8ba,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_a5ce1efe47f9e8ba
__hip_cuid_a5ce1efe47f9e8ba:
	.byte	0
	.size	__hip_cuid_a5ce1efe47f9e8ba, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_a5ce1efe47f9e8ba
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
    .group_segment_fixed_size: 8
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .max_flat_workgroup_size: 1024
    .name:           ck_reduce2d_cross_warp
    .private_segment_fixed_size: 0
    .sgpr_count:     16
    .sgpr_spill_count: 0
    .symbol:         ck_reduce2d_cross_warp.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     7
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
