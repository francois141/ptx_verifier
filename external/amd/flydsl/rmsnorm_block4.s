; FlyDSL 304d441202a3 kernels/norm/rmsnorm_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case rmsnorm_block4).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	rmsnorm_large_m_small_n_kernel_0
	.p2align	8
	.type	rmsnorm_large_m_small_n_kernel_0,@function
rmsnorm_large_m_small_n_kernel_0:
	s_load_dword s3, s[0:1], 0x50
	v_lshrrev_b32_e32 v1, 5, v0
	v_lshl_or_b32 v8, s2, 5, v1
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e32 vcc, s3, v8
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_3
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	s_load_dword s2, s[0:1], 0x10
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	v_and_b32_e32 v9, 31, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	v_mul_lo_u32 v1, s2, v8
	v_lshlrev_b32_e32 v1, 1, v1
	buffer_load_dwordx4 v[10:13], v1, s[4:7], 0 offen
	v_cmp_eq_u32_e32 vcc, 0, v9
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v1, 0xffff0000, v13
	v_lshlrev_b32_e32 v0, 16, v13
	v_and_b32_e32 v3, 0xffff0000, v12
	v_lshlrev_b32_e32 v2, 16, v12
	v_and_b32_e32 v5, 0xffff0000, v11
	v_lshlrev_b32_e32 v4, 16, v11
	v_and_b32_e32 v7, 0xffff0000, v10
	v_lshlrev_b32_e32 v6, 16, v10
	v_pk_mul_f32 v[10:11], v[2:3], v[2:3]
	v_pk_mul_f32 v[12:13], v[6:7], v[6:7]
	v_pk_mul_f32 v[14:15], v[0:1], v[0:1]
	v_pk_mul_f32 v[16:17], v[4:5], v[4:5]
	v_pk_add_f32 v[10:11], v[12:13], v[10:11]
	v_pk_add_f32 v[14:15], v[16:17], v[14:15]
	s_nop 0
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	s_nop 0
	v_add_f32_e32 v10, v10, v11
	v_cndmask_b32_e32 v9, 0, v10, vcc
	s_nop 1
	v_add_f32_dpp v9, v9, v9 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v9, v9, v9 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v9, v9, v9 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v9, v9, v9 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v10, v9
	s_nop 1
	v_permlane16_swap_b32_e32 v9, v10
	s_and_b64 exec, exec, vcc
	s_cbranch_execz .LBB0_3
	s_load_dwordx2 s[8:9], s[0:1], 0x18
	s_load_dwordx2 s[4:5], s[0:1], 0x38
	s_load_dword s2, s[0:1], 0x48
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	buffer_load_dwordx4 v[12:15], off, s[8:11], 0
	v_add_f32_e32 v9, v9, v10
	v_mul_f32_e32 v9, 0x3e000000, v9
	v_add_f32_e32 v9, 0x3727c5ac, v9
	v_rsq_f32_e32 v10, v9
	v_mul_lo_u32 v18, s2, v8
	s_and_b32 s5, s5, 0xffff
	v_pk_mul_f32 v[0:1], v[10:11], v[0:1] op_sel_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[10:11], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[10:11], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[10:11], v[6:7] op_sel_hi:[0,1]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v9, 0xffff0000, v12
	v_lshlrev_b32_e32 v8, 16, v12
	v_and_b32_e32 v11, 0xffff0000, v15
	v_lshlrev_b32_e32 v10, 16, v15
	v_and_b32_e32 v15, 0xffff0000, v14
	v_lshlrev_b32_e32 v14, 16, v14
	v_and_b32_e32 v17, 0xffff0000, v13
	v_lshlrev_b32_e32 v16, 16, v13
	v_pk_mul_f32 v[4:5], v[4:5], v[16:17]
	v_pk_mul_f32 v[12:13], v[2:3], v[14:15]
	v_pk_mul_f32 v[0:1], v[0:1], v[10:11]
	v_pk_mul_f32 v[6:7], v[6:7], v[8:9]
	v_cvt_pk_bf16_f32 v3, v0, v1
	v_cvt_pk_bf16_f32 v2, v12, v13
	v_cvt_pk_bf16_f32 v1, v4, v5
	v_cvt_pk_bf16_f32 v0, v6, v7
	v_lshlrev_b32_e32 v4, 1, v18
	buffer_store_dwordx4 v[0:3], v4, s[4:7], 0 offen
.LBB0_3:
	s_endpgm
.Lfunc_end0:
	.size	rmsnorm_large_m_small_n_kernel_0, .Lfunc_end0-rmsnorm_large_m_small_n_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_large_m_small_n_kernel_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 84
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
		.amdhsa_next_free_vgpr 19
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 20
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

	.set .Lrmsnorm_large_m_small_n_kernel_0.num_vgpr, 19
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_agpr, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.numbered_sgpr, 12
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_named_barrier, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.private_seg_size, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_vcc, 1
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_flat_scratch, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_dyn_sized_stack, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_recursion, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_indirect_call, 0
	.globl	rmsnorm_kernel_1
	.p2align	8
	.type	rmsnorm_kernel_1,@function
rmsnorm_kernel_1:
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	s_lshl_b32 s2, s2, 1
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	s_mul_i32 s3, s2, s3
	v_mov_b32_e32 v1, s3
	buffer_load_dwordx4 v[8:11], v1, s[4:7], 0 offen
	v_cmp_eq_u32_e32 vcc, 0, v0
	v_mov_b32_e32 v1, 0
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v3, 0xffff0000, v11
	v_lshlrev_b32_e32 v2, 16, v11
	v_and_b32_e32 v5, 0xffff0000, v10
	v_lshlrev_b32_e32 v4, 16, v10
	v_and_b32_e32 v7, 0xffff0000, v9
	v_lshlrev_b32_e32 v6, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v8
	v_lshlrev_b32_e32 v8, 16, v8
	v_pk_mul_f32 v[10:11], v[4:5], v[4:5]
	v_pk_mul_f32 v[12:13], v[8:9], v[8:9]
	v_pk_mul_f32 v[14:15], v[2:3], v[2:3]
	v_pk_mul_f32 v[16:17], v[6:7], v[6:7]
	v_pk_add_f32 v[10:11], v[12:13], v[10:11]
	v_pk_add_f32 v[14:15], v[16:17], v[14:15]
	s_nop 0
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	s_nop 0
	v_add_f32_e32 v10, v10, v11
	v_cndmask_b32_e32 v0, 0, v10, vcc
	s_nop 1
	v_add_f32_dpp v0, v0, v0 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_mov_b32_dpp v1, v0 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB1_2
	s_load_dwordx2 s[4:5], s[0:1], 0x18
	s_load_dwordx2 s[8:9], s[0:1], 0x38
	s_load_dword s3, s[0:1], 0x48
	v_add_f32_e32 v0, v0, v1
	v_mul_f32_e32 v0, 0x3e000000, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	buffer_load_dwordx4 v[10:13], off, s[4:7], 0
	v_add_f32_e32 v0, 0x3727c5ac, v0
	v_rsq_f32_e32 v0, v0
	s_mul_i32 s0, s2, s3
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	v_pk_mul_f32 v[2:3], v[0:1], v[2:3] op_sel_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[0:1], v[4:5] op_sel_hi:[0,1]
	v_pk_mul_f32 v[6:7], v[0:1], v[6:7] op_sel_hi:[0,1]
	v_pk_mul_f32 v[0:1], v[0:1], v[8:9] op_sel_hi:[0,1]
	s_and_b32 s9, s9, 0xffff
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v9, 0xffff0000, v10
	v_lshlrev_b32_e32 v8, 16, v10
	v_and_b32_e32 v15, 0xffff0000, v13
	v_lshlrev_b32_e32 v14, 16, v13
	v_and_b32_e32 v13, 0xffff0000, v12
	v_lshlrev_b32_e32 v12, 16, v12
	v_and_b32_e32 v17, 0xffff0000, v11
	v_lshlrev_b32_e32 v16, 16, v11
	v_pk_mul_f32 v[6:7], v[6:7], v[16:17]
	v_pk_mul_f32 v[4:5], v[4:5], v[12:13]
	v_pk_mul_f32 v[2:3], v[2:3], v[14:15]
	v_pk_mul_f32 v[8:9], v[0:1], v[8:9]
	v_cvt_pk_bf16_f32 v3, v2, v3
	v_cvt_pk_bf16_f32 v2, v4, v5
	v_cvt_pk_bf16_f32 v1, v6, v7
	v_cvt_pk_bf16_f32 v0, v8, v9
	v_mov_b32_e32 v4, s0
	buffer_store_dwordx4 v[0:3], v4, s[8:11], 0 offen
.LBB1_2:
	s_endpgm
.Lfunc_end1:
	.size	rmsnorm_kernel_1, .Lfunc_end1-rmsnorm_kernel_1
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_kernel_1
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 80
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
		.amdhsa_next_free_vgpr 18
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 20
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

	.set .Lrmsnorm_kernel_1.num_vgpr, 18
	.set .Lrmsnorm_kernel_1.num_agpr, 0
	.set .Lrmsnorm_kernel_1.numbered_sgpr, 12
	.set .Lrmsnorm_kernel_1.num_named_barrier, 0
	.set .Lrmsnorm_kernel_1.private_seg_size, 0
	.set .Lrmsnorm_kernel_1.uses_vcc, 1
	.set .Lrmsnorm_kernel_1.uses_flat_scratch, 0
	.set .Lrmsnorm_kernel_1.has_dyn_sized_stack, 0
	.set .Lrmsnorm_kernel_1.has_recursion, 0
	.set .Lrmsnorm_kernel_1.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 84
    .max_flat_workgroup_size: 1024
    .name:           rmsnorm_large_m_small_n_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 1024
      - 1
      - 1
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_large_m_small_n_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     19
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 80
    .max_flat_workgroup_size: 4
    .name:           rmsnorm_kernel_1
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 4
      - 1
      - 1
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_kernel_1.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     18
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
