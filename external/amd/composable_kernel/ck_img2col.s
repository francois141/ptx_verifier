	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_img2col
	.globl	ck_img2col
	.p2align	8
	.type	ck_img2col,@function
ck_img2col:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	v_readfirstlane_b32 s1, v0
	v_mbcnt_lo_u32_b32 v0, -1, 0
	v_mbcnt_hi_u32_b32 v0, -1, v0
	s_lshl_b32 s0, s2, 6
	v_lshlrev_b32_e32 v1, 2, v0
	s_andn2_b32 s1, s1, 63
	v_and_b32_e32 v16, 12, v1
	v_and_b32_e32 v0, 0x7c, v0
	s_add_i32 s1, s1, s0
	s_mov_b32 s2, 0x55555556
	v_add_u32_e32 v18, s1, v0
	v_mul_hi_u32 v0, v16, s2
	v_add_u32_e32 v0, v16, v0
	v_lshrrev_b32_e32 v1, 2, v0
	v_lshrrev_b32_e32 v13, 3, v0
	v_mul_hi_u32 v0, v18, s2
	v_add_u32_e32 v0, v18, v0
	v_lshlrev_b32_e32 v4, 1, v13
	v_lshrrev_b32_e32 v0, 2, v0
	v_sub_u32_e32 v14, v1, v4
	v_mul_hi_u32 v1, v0, s2
	v_add_u32_e32 v1, v0, v1
	v_lshrrev_b32_e32 v1, 2, v1
	v_mad_u64_u32 v[10:11], s[0:1], v0, -3, v[18:19]
	v_mad_u64_u32 v[2:3], s[0:1], v1, -3, v[0:1]
	v_add_u32_e32 v0, v14, v10
	v_add_u32_e32 v6, v2, v13
	v_sub_u32_e32 v4, v10, v4
	v_mad_u64_u32 v[4:5], s[0:1], v4, 3, v[16:17]
	v_or_b32_e32 v0, v6, v0
	v_mul_lo_u32 v3, v1, 48
	v_mul_lo_u32 v7, v6, 12
	v_cmp_ne_u32_e32 vcc, 12, v16
	v_cmp_gt_u32_e64 s[0:1], 4, v0
	v_add3_u32 v3, v4, v3, v7
	s_and_b64 s[8:9], vcc, s[0:1]
	v_mov_b32_e32 v0, 0
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_2
	v_lshlrev_b32_e32 v4, 2, v3
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0xc0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s8, s4
	s_mov_b32 s9, s5
	buffer_load_dwordx4 v[4:7], v4, s[8:11], 0 offen
.LBB0_2:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v8, 1, v18
	v_mul_hi_u32 v9, v8, s2
	v_add_u32_e32 v9, v8, v9
	v_lshrrev_b32_e32 v12, 2, v9
	v_mad_u64_u32 v[8:9], s[0:1], v12, -3, v[8:9]
	v_mul_hi_u32 v9, v12, s2
	v_add_u32_e32 v9, v12, v9
	v_lshrrev_b32_e32 v9, 2, v9
	v_sub_u32_e32 v15, v8, v10
	v_mad_u64_u32 v[10:11], s[0:1], v9, -3, v[12:13]
	v_sub_u32_e32 v2, v10, v2
	v_sub_u32_e32 v1, v9, v1
	v_add_u32_e32 v12, v14, v8
	v_add_u32_e32 v17, v10, v13
	v_mul_lo_u32 v11, v2, 12
	v_lshl_add_u32 v2, v15, 1, v15
	v_mad_u64_u32 v[20:21], s[0:1], v1, 48, v[2:3]
	v_or_b32_e32 v1, v17, v12
	v_cmp_gt_u32_e64 s[0:1], 4, v1
	v_add3_u32 v11, v20, v11, v3
	s_and_b64 s[2:3], vcc, s[0:1]
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v3, 0
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_4
	v_lshlrev_b32_e32 v0, 2, v11
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0xc0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s8, s4
	s_mov_b32 s9, s5
	buffer_load_dwordx4 v[0:3], v0, s[8:11], 0 offen
.LBB0_4:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v12, 2, v18
	s_mov_b32 s2, 0x55555556
	v_mul_hi_u32 v15, v12, s2
	v_add_u32_e32 v15, v12, v15
	v_lshrrev_b32_e32 v22, 2, v15
	v_mad_u64_u32 v[20:21], s[0:1], v22, -3, v[12:13]
	v_mul_hi_u32 v12, v22, s2
	v_add_u32_e32 v12, v22, v12
	v_lshrrev_b32_e32 v17, 2, v12
	v_sub_u32_e32 v8, v20, v8
	v_mad_u64_u32 v[22:23], s[0:1], v17, -3, v[22:23]
	v_sub_u32_e32 v10, v22, v10
	v_sub_u32_e32 v9, v17, v9
	v_lshl_add_u32 v8, v8, 1, v8
	v_add_u32_e32 v12, v14, v20
	v_add_u32_e32 v15, v22, v13
	v_mul_lo_u32 v10, v10, 12
	v_mad_u64_u32 v[8:9], s[0:1], v9, 48, v[8:9]
	v_add3_u32 v19, v8, v10, v11
	v_or_b32_e32 v8, v15, v12
	v_cmp_gt_u32_e64 s[0:1], 4, v8
	s_and_b64 s[8:9], vcc, s[0:1]
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_6
	v_lshlrev_b32_e32 v8, 2, v19
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0xc0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s8, s4
	s_mov_b32 s9, s5
	buffer_load_dwordx4 v[8:11], v8, s[8:11], 0 offen
.LBB0_6:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v24, 3, v18
	v_mul_hi_u32 v15, v24, s2
	v_add_u32_e32 v15, v24, v15
	v_lshrrev_b32_e32 v26, 2, v15
	v_mul_hi_u32 v15, v26, s2
	v_add_u32_e32 v15, v26, v15
	v_lshrrev_b32_e32 v21, 2, v15
	v_mad_u64_u32 v[24:25], s[0:1], v26, -3, v[24:25]
	v_mad_u64_u32 v[26:27], s[0:1], v21, -3, v[26:27]
	v_add_u32_e32 v14, v14, v24
	v_add_u32_e32 v13, v26, v13
	v_or_b32_e32 v13, v13, v14
	v_cmp_gt_u32_e64 s[0:1], 4, v13
	s_and_b64 s[2:3], vcc, s[0:1]
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_8
	v_sub_u32_e32 v12, v26, v22
	v_sub_u32_e32 v13, v24, v20
	v_sub_u32_e32 v14, v21, v17
	v_mul_lo_u32 v14, v14, 48
	v_lshl_add_u32 v13, v13, 1, v13
	v_mul_lo_u32 v12, v12, 12
	v_add3_u32 v12, v14, v13, v12
	s_mov_b32 s11, 0x20000
	s_movk_i32 s10, 0xc0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s8, s4
	s_mov_b32 s9, s5
	v_add_lshl_u32 v12, v12, v19, 2
	buffer_load_dwordx4 v[12:15], v12, s[8:11], 0 offen
.LBB0_8:
	s_or_b64 exec, exec, s[0:1]
	v_mul_lo_u32 v17, v18, 12
	v_bfrev_b32_e32 v18, 1
	v_cmp_eq_u32_e32 vcc, 12, v16
	v_or_b32_e32 v17, v17, v16
	s_mov_b32 s3, 0x20000
	v_cndmask_b32_e32 v16, 0, v18, vcc
	s_movk_i32 s2, 0x1b0
	s_waitcnt lgkmcnt(0)
	s_mov_b32 s0, s6
	s_mov_b32 s1, s7
	v_lshl_add_u32 v16, v17, 2, v16
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[4:7], v16, s[0:3], 0 offen
	buffer_store_dwordx4 v[0:3], v16, s[0:3], 0 offen offset:48
	buffer_store_dwordx4 v[8:11], v16, s[0:3], 0 offen offset:96
	buffer_store_dwordx4 v[12:15], v16, s[0:3], 0 offen offset:144
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_img2col
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
		.amdhsa_next_free_vgpr 28
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 28
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
	.size	ck_img2col, .Lfunc_end0-ck_img2col

	.set ck_img2col.num_vgpr, 28
	.set ck_img2col.num_agpr, 0
	.set ck_img2col.numbered_sgpr, 12
	.set ck_img2col.private_seg_size, 0
	.set ck_img2col.uses_vcc, 1
	.set ck_img2col.uses_flat_scratch, 0
	.set ck_img2col.has_dyn_sized_stack, 0
	.set ck_img2col.has_recursion, 0
	.set ck_img2col.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_dc632b53a6e48bf,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_dc632b53a6e48bf
__hip_cuid_dc632b53a6e48bf:
	.byte	0
	.size	__hip_cuid_dc632b53a6e48bf, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_dc632b53a6e48bf
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
    .name:           ck_img2col
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         ck_img2col.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     28
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
