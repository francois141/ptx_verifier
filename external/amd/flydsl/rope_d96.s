; FlyDSL 304d441202a3 kernels/attention/fused_rope_cache_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case rope_d96).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	fused_qk_rope_reshape_and_cache_0
	.p2align	8
	.type	fused_qk_rope_reshape_and_cache_0,@function
fused_qk_rope_reshape_and_cache_0:
	s_cmp_lt_i32 s2, 1
	v_cmp_gt_u32_e32 vcc, 48, v0
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 s[4:5], vcc, s[4:5]
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_3
	s_load_dwordx2 s[8:9], s[0:1], 0x78
	s_load_dwordx2 s[12:13], s[0:1], 0x88
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	s_lshl_b32 s4, s3, 2
	s_mov_b32 s10, s6
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s11, s7
	v_mov_b32_e32 v2, s4
	buffer_load_dword v3, v2, s[8:11], 0 offen
	s_load_dwordx2 s[20:21], s[0:1], 0x0
	s_load_dword s10, s[0:1], 0x14
	s_load_dword s11, s[0:1], 0x1c
	s_load_dwordx2 s[16:17], s[0:1], 0x28
	s_load_dword s18, s[0:1], 0x98
	s_load_dwordx2 s[4:5], s[0:1], 0xa0
	s_load_dword s19, s[0:1], 0xb0
	s_load_dwordx2 s[8:9], s[0:1], 0xb8
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s10, s10, s3
	s_mul_i32 s11, s11, s2
	v_lshlrev_b32_e32 v1, 1, v0
	s_add_i32 s10, s10, s11
	s_mov_b32 s22, s6
	s_mov_b32 s23, s7
	s_and_b32 s21, s21, 0xffff
	v_add_lshl_u32 v5, v1, s10, 1
	buffer_load_dword v5, v5, s[20:23], 0 offen
	v_subrev_u32_e32 v4, 48, v1
	v_cmp_gt_u32_e32 vcc, 24, v0
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s14, s6
	v_cndmask_b32_e32 v4, v4, v1, vcc
	s_mov_b32 s15, s7
	s_and_b32 s13, s13, 0xffff
	v_lshlrev_b32_e32 v0, 2, v0
	v_xor_b32_e32 v0, 0x60, v0
	s_and_b32 s17, s17, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v6, v3, s19
	v_mul_lo_u32 v3, v3, s18
	v_add_lshl_u32 v3, v3, v4, 1
	v_add_lshl_u32 v4, v6, v4, 1
	buffer_load_dword v4, v4, s[4:7], 0 offen
	s_mov_b32 s18, s6
	buffer_load_dword v3, v3, s[12:15], 0 offen
	s_load_dword s4, s[0:1], 0x3c
	s_load_dword s5, s[0:1], 0x44
	s_load_dwordx2 s[20:21], s[0:1], 0x128
	s_load_dword s10, s[0:1], 0x144
	s_load_dwordx2 s[12:13], s[0:1], 0x150
	s_load_dword s11, s[0:1], 0x13c
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s4, s4, s3
	s_mul_i32 s5, s5, s2
	s_waitcnt vmcnt(2)
	ds_bpermute_b32 v6, v0, v5
	v_lshlrev_b32_e32 v9, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v5
	s_mul_i32 s11, s11, s3
	s_mul_i32 s10, s10, s2
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v10, 0xffff0000, v6
	v_lshlrev_b32_e32 v6, 16, v6
	s_add_i32 s11, s11, s10
	s_and_b32 s21, s21, 0xffff
	s_add_i32 s4, s4, s5
	v_add_lshl_u32 v7, v1, s11, 1
	s_mov_b32 s19, s7
	v_add_lshl_u32 v8, v1, s4, 1
	s_load_dword s4, s[0:1], 0x16c
	s_load_dword s5, s[0:1], 0x164
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s4, s4, s2
	s_mul_i32 s5, s5, s3
	s_add_i32 s5, s5, s4
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v12, 0xffff0000, v4
	v_lshlrev_b32_e32 v4, 16, v4
	v_mul_f32_e32 v10, v12, v10
	v_mul_f32_e32 v6, v4, v6
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v11, 16, v3
	v_and_b32_e32 v3, 0xffff0000, v3
	v_cvt_pk_bf16_f32 v6, v6, v10
	v_mul_f32_e32 v9, v11, v9
	v_mul_f32_e32 v5, v3, v5
	v_xor_b32_e32 v10, 0x80008000, v6
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_cvt_pk_bf16_f32 v5, v5, s0
	v_cndmask_b32_e32 v6, v6, v10, vcc
	v_lshlrev_b32_e32 v5, 16, v5
	v_lshlrev_b32_e32 v9, 16, v9
	v_and_b32_e32 v10, 0xffff0000, v6
	v_lshlrev_b32_e32 v6, 16, v6
	v_add_f32_e32 v5, v5, v10
	v_add_f32_e32 v6, v9, v6
	v_cvt_pk_bf16_f32 v5, v6, v5
	buffer_store_dword v5, v7, s[20:23], 0 offen
	buffer_load_dword v5, v8, s[16:19], 0 offen
	v_add_lshl_u32 v6, v1, s5, 1
	s_waitcnt vmcnt(0)
	ds_bpermute_b32 v0, v0, v5
	v_lshlrev_b32_e32 v7, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v5
	v_mul_f32_e32 v7, v11, v7
	v_mul_f32_e32 v3, v3, v5
	v_cvt_pk_bf16_f32 v5, v7, s0
	s_waitcnt lgkmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v0
	v_lshlrev_b32_e32 v0, 16, v0
	v_mul_f32_e32 v7, v12, v7
	v_mul_f32_e32 v0, v4, v0
	v_cvt_pk_bf16_f32 v0, v0, v7
	v_xor_b32_e32 v4, 0x80008000, v0
	v_cvt_pk_bf16_f32 v3, v3, s0
	v_cndmask_b32_e32 v0, v0, v4, vcc
	v_lshlrev_b32_e32 v3, 16, v3
	v_lshlrev_b32_e32 v5, 16, v5
	v_and_b32_e32 v4, 0xffff0000, v0
	v_lshlrev_b32_e32 v0, 16, v0
	v_add_f32_e32 v3, v3, v4
	v_add_f32_e32 v0, v5, v0
	v_cvt_pk_bf16_f32 v0, v0, v3
	buffer_store_dword v0, v6, s[12:15], 0 offen
	buffer_load_dword v2, v2, s[8:11], 0 offen
	s_waitcnt vmcnt(0)
	v_cmp_gt_i32_e32 vcc, 0, v2
	v_readfirstlane_b32 s10, v2
	s_cbranch_vccnz .LBB0_3
	s_load_dwordx2 s[4:5], s[0:1], 0x50
	s_load_dword s11, s[0:1], 0x64
	s_load_dword s12, s[0:1], 0x6c
	s_load_dwordx2 s[8:9], s[0:1], 0xc8
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	s_mul_i32 s3, s11, s3
	s_mul_i32 s12, s12, s2
	s_add_i32 s3, s3, s12
	v_add_lshl_u32 v2, v1, s3, 1
	buffer_load_dword v3, v2, s[4:7], 0 offen
	s_load_dword s3, s[0:1], 0xf0
	s_load_dwordx2 s[4:5], s[0:1], 0xf8
	s_load_dword s12, s[0:1], 0x120
	s_load_dword s13, s[0:1], 0x118
	s_load_dword s14, s[0:1], 0x110
	s_load_dword s15, s[0:1], 0xe8
	s_load_dword s16, s[0:1], 0xe0
	s_and_b32 s1, s10, 15
	s_lshr_b32 s0, s10, 4
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s3, s2
	s_mul_i32 s15, s15, s1
	s_mul_i32 s16, s16, s0
	s_add_i32 s3, s15, s3
	s_mul_i32 s14, s14, s0
	s_mul_i32 s0, s13, s1
	s_mul_i32 s12, s12, s2
	s_add_i32 s3, s3, s16
	s_add_i32 s0, s0, s12
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_add_i32 s0, s0, s14
	v_add_lshl_u32 v2, v1, s3, 1
	s_and_b32 s5, s5, 0xffff
	buffer_store_dword v0, v2, s[8:11], 0 offen
	v_add_lshl_u32 v0, v1, s0, 1
	s_waitcnt vmcnt(1)
	buffer_store_dword v3, v0, s[4:7], 0 offen
.LBB0_3:
	s_endpgm
.Lfunc_end0:
	.size	fused_qk_rope_reshape_and_cache_0, .Lfunc_end0-fused_qk_rope_reshape_and_cache_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fused_qk_rope_reshape_and_cache_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 404
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
		.amdhsa_next_free_vgpr 13
		.amdhsa_next_free_sgpr 24
		.amdhsa_accum_offset 16
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

	.set .Lfused_qk_rope_reshape_and_cache_0.num_vgpr, 13
	.set .Lfused_qk_rope_reshape_and_cache_0.num_agpr, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.numbered_sgpr, 24
	.set .Lfused_qk_rope_reshape_and_cache_0.num_named_barrier, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.private_seg_size, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.uses_vcc, 1
	.set .Lfused_qk_rope_reshape_and_cache_0.uses_flat_scratch, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.has_dyn_sized_stack, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.has_recursion, 0
	.set .Lfused_qk_rope_reshape_and_cache_0.has_indirect_call, 0
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
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     global_buffer
      - .offset:         88
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         120
        .size:           8
        .value_kind:     global_buffer
      - .offset:         128
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         136
        .size:           8
        .value_kind:     global_buffer
      - .offset:         144
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         160
        .size:           8
        .value_kind:     global_buffer
      - .offset:         168
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         184
        .size:           8
        .value_kind:     global_buffer
      - .offset:         192
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         200
        .size:           8
        .value_kind:     global_buffer
      - .offset:         208
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         248
        .size:           8
        .value_kind:     global_buffer
      - .offset:         256
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         296
        .size:           8
        .value_kind:     global_buffer
      - .offset:         304
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         336
        .size:           8
        .value_kind:     global_buffer
      - .offset:         344
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         376
        .size:           8
        .value_kind:     global_buffer
      - .offset:         384
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         392
        .size:           8
        .value_kind:     global_buffer
      - .offset:         400
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 404
    .max_flat_workgroup_size: 64
    .name:           fused_qk_rope_reshape_and_cache_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 64
      - 1
      - 1
    .sgpr_count:     30
    .sgpr_spill_count: 0
    .symbol:         fused_qk_rope_reshape_and_cache_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     13
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
