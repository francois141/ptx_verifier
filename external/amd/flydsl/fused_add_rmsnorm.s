; FlyDSL 304d441202a3 kernels/norm/rmsnorm_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case fused_add_rmsnorm).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	fused_add_rmsnorm_kernel_0
	.p2align	8
	.type	fused_add_rmsnorm_kernel_0,@function
fused_add_rmsnorm_kernel_0:
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	s_load_dwordx2 s[12:13], s[0:1], 0x18
	s_load_dword s4, s[0:1], 0x28
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s2, s3
	v_add_lshl_u32 v2, s3, v0, 2
	s_mul_i32 s3, s2, s4
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	v_add_lshl_u32 v6, s3, v0, 2
	buffer_load_dword v3, v2, s[8:11], 0 offen
	buffer_load_dword v4, v6, s[12:15], 0 offen
	s_load_dwordx2 s[4:5], s[0:1], 0x58
	s_load_dword s3, s[0:1], 0x68
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	s_mul_i32 s3, s2, s3
	v_add_lshl_u32 v1, s3, v0, 2
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v3, v4
	buffer_store_dword v4, v1, s[4:7], 0 offen
	buffer_load_dword v3, v2, s[8:11], 0 offen offset:1024
	buffer_load_dword v5, v6, s[12:15], 0 offen offset:1024
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v5, v3, v5
	buffer_store_dword v5, v1, s[4:7], 0 offen offset:1024
	buffer_load_dword v3, v2, s[8:11], 0 offen offset:2048
	buffer_load_dword v7, v6, s[12:15], 0 offen offset:2048
	v_pk_mul_f32 v[4:5], v[4:5], v[4:5]
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v12, v3, v7
	buffer_store_dword v12, v1, s[4:7], 0 offen offset:2048
	buffer_load_dword v8, v2, s[8:11], 0 offen offset:3072
	buffer_load_dword v9, v6, s[12:15], 0 offen offset:3072
	v_add_f32_e32 v2, v4, v5
	v_mov_b32_e32 v3, 0
	ds_swizzle_b32 v7, v3 offset:swizzle(SWAP,1)
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v13, v8, v9
	v_pk_mul_f32 v[4:5], v[12:13], v[12:13]
	v_and_b32_e32 v12, 63, v0
	v_add_f32_e32 v2, v2, v4
	v_add_f32_e32 v2, v2, v5
	ds_swizzle_b32 v6, v2 offset:swizzle(SWAP,1)
	buffer_store_dword v13, v1, s[4:7], 0 offen offset:3072
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[2:3], v[6:7]
	ds_swizzle_b32 v6, v4 offset:swizzle(SWAP,2)
	ds_swizzle_b32 v7, v5 offset:swizzle(SWAP,2)
	v_add_u32_e32 v2, 0xc00, v1
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[6:7]
	ds_swizzle_b32 v6, v4 offset:swizzle(SWAP,4)
	ds_swizzle_b32 v7, v5 offset:swizzle(SWAP,4)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[6:7]
	ds_swizzle_b32 v6, v4 offset:swizzle(SWAP,8)
	ds_swizzle_b32 v7, v5 offset:swizzle(SWAP,8)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[6:7]
	v_add_u32_e32 v7, 0x400, v1
	v_mov_b32_e32 v8, v4
	v_mov_b32_e32 v9, v4
	s_nop 1
	v_permlane16_swap_b32_e32 v8, v9
	v_mov_b32_e32 v10, v5
	v_mov_b32_e32 v11, v5
	s_nop 1
	v_permlane16_swap_b32_e32 v10, v11
	v_cmp_eq_u32_e32 vcc, v8, v4
	v_add_u32_e32 v6, 0x800, v1
	s_nop 0
	v_cndmask_b32_e32 v8, v8, v9, vcc
	v_cmp_eq_u32_e32 vcc, v10, v5
	s_nop 1
	v_cndmask_b32_e32 v9, v10, v11, vcc
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	v_cmp_eq_u32_e32 vcc, 0, v12
	v_mov_b32_e32 v8, v4
	v_mov_b32_e32 v9, v4
	v_mov_b32_e32 v10, v5
	v_mov_b32_e32 v11, v5
	v_permlane32_swap_b32_e32 v8, v9
	s_nop 0
	v_permlane32_swap_b32_e32 v10, v11
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_2
	v_cmp_eq_u32_e32 vcc, v8, v4
	v_lshrrev_b32_e32 v12, 3, v0
	s_nop 0
	v_cndmask_b32_e32 v8, v8, v9, vcc
	v_cmp_eq_u32_e32 vcc, v10, v5
	s_nop 1
	v_cndmask_b32_e32 v9, v10, v11, vcc
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	ds_write2_b32 v12, v4, v5 offset1:1
.LBB0_2:
	s_or_b64 exec, exec, s[8:9]
	s_load_dwordx2 s[12:13], s[0:1], 0x30
	s_load_dwordx2 s[8:9], s[0:1], 0x40
	s_load_dword s3, s[0:1], 0x50
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	s_waitcnt lgkmcnt(0)
	s_and_b32 s13, s13, 0xffff
	s_barrier
	v_lshlrev_b32_e32 v4, 2, v0
	buffer_load_dword v5, v1, s[4:7], 0 offen
	buffer_load_dword v16, v4, s[12:15], 0 offen
	ds_read2_b64 v[8:11], v3 offset1:1
	ds_read2_b64 v[12:15], v3 offset0:2 offset1:3
	s_mul_i32 s2, s2, s3
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_waitcnt lgkmcnt(1)
	v_add_f32_e32 v1, v10, v8
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v1, v1, v12
	v_add_f32_e32 v1, v1, v14
	v_mul_f32_e32 v1, 0x3a800000, v1
	v_add_f32_e32 v1, 0x3727c5ac, v1
	v_rsq_f32_e32 v1, v1
	s_and_b32 s9, s9, 0xffff
	v_add_lshl_u32 v0, s2, v0, 2
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v3, v5, v1
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, v16, v3
	buffer_store_dword v3, v0, s[8:11], 0 offen
	buffer_load_dword v3, v7, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v5, v4, s[12:15], 0 offen offset:1024
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v3, v3, v1
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, v5, v3
	buffer_store_dword v3, v0, s[8:11], 0 offen offset:1024
	buffer_load_dword v3, v6, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v5, v4, s[12:15], 0 offen offset:2048
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v3, v1, v3
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v3, v5, v3
	buffer_store_dword v3, v0, s[8:11], 0 offen offset:2048
	buffer_load_dword v3, v2, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v5, v4, s[12:15], 0 offen offset:3072
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v1, v1, v3
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, v5, v1
	buffer_store_dword v1, v0, s[8:11], 0 offen offset:3072
	s_endpgm
.Lfunc_end0:
	.size	fused_add_rmsnorm_kernel_0, .Lfunc_end0-fused_add_rmsnorm_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel fused_add_rmsnorm_kernel_0
		.amdhsa_group_segment_fixed_size 32
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 124
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
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 16
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

	.set .Lfused_add_rmsnorm_kernel_0.num_vgpr, 17
	.set .Lfused_add_rmsnorm_kernel_0.num_agpr, 0
	.set .Lfused_add_rmsnorm_kernel_0.numbered_sgpr, 16
	.set .Lfused_add_rmsnorm_kernel_0.num_named_barrier, 0
	.set .Lfused_add_rmsnorm_kernel_0.private_seg_size, 0
	.set .Lfused_add_rmsnorm_kernel_0.uses_vcc, 1
	.set .Lfused_add_rmsnorm_kernel_0.uses_flat_scratch, 0
	.set .Lfused_add_rmsnorm_kernel_0.has_dyn_sized_stack, 0
	.set .Lfused_add_rmsnorm_kernel_0.has_recursion, 0
	.set .Lfused_add_rmsnorm_kernel_0.has_indirect_call, 0
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
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .offset:         72
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     global_buffer
      - .offset:         96
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         112
        .size:           8
        .value_kind:     global_buffer
      - .offset:         120
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 32
    .kernarg_segment_align: 8
    .kernarg_segment_size: 124
    .max_flat_workgroup_size: 256
    .name:           fused_add_rmsnorm_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         fused_add_rmsnorm_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     17
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
