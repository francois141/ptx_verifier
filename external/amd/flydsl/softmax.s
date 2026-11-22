; FlyDSL 304d441202a3 kernels/norm/softmax_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case softmax).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	softmax_kernel_0
	.p2align	8
	.type	softmax_kernel_0,@function
softmax_kernel_0:
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	v_lshlrev_b32_e32 v6, 2, v0
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	s_mul_i32 s3, s2, s3
	v_add_lshl_u32 v1, s3, v6, 2
	buffer_load_dwordx4 v[2:5], v1, s[4:7], 0 offen
	v_and_b32_e32 v12, 63, v0
	v_cmp_eq_u32_e32 vcc, 0, v12
	v_mov_b32_e32 v7, 0xff800000
	v_mov_b32_e32 v8, 0xff800000
	v_mov_b32_e32 v9, 0xff800000
	v_mov_b32_e32 v10, 0xff800000
	v_mov_b32_e32 v11, 0xff800000
	v_mov_b32_e32 v1, 0xff800000
	v_lshrrev_b32_e32 v0, 6, v0
	s_barrier
	s_waitcnt vmcnt(0)
	v_max_f32_e32 v12, v3, v3
	v_max_f32_e32 v13, v2, v2
	v_max_f32_e32 v12, v13, v12
	v_max3_f32 v12, v12, v4, v5
	s_nop 1
	v_mov_b32_dpp v7, v12 row_shr:1 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v7, v12, v7, v7
	s_nop 1
	v_mov_b32_dpp v8, v7 row_shr:2 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v7, v7, v8, v8
	v_lshlrev_b32_e32 v8, 2, v0
	s_nop 0
	v_mov_b32_dpp v9, v7 row_shr:4 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v7, v7, v9, v9
	s_nop 1
	v_mov_b32_dpp v10, v7 row_shr:8 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v7, v7, v10, v10
	s_nop 1
	v_mov_b32_dpp v11, v7 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_maximum3_f32 v7, v7, v11, v11
	s_nop 1
	v_mov_b32_dpp v1, v7 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_maximum3_f32 v1, v7, v1, v1
	s_nop 0
	v_readlane_b32 s3, v1, 63
	s_and_saveexec_b64 s[4:5], vcc
	s_nop 0
	v_mov_b32_e32 v0, s3
	ds_write_b32 v8, v0
	s_or_b64 exec, exec, s[4:5]
	v_mov_b32_e32 v7, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[10:13], v7 offset1:1
	s_mov_b32 s4, 0x3fb8aa3b
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_maximum3_f32 v0, v10, v11, v11
	v_maximum3_f32 v0, v0, v12, v13
	v_pk_add_f32 v[4:5], v[4:5], v[0:1] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[0:1], v[2:3], v[0:1] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[2:3], v[4:5], s[4:5] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], s[4:5] op_sel_hi:[1,0]
	v_exp_f32_e32 v2, v2
	v_exp_f32_e32 v0, v0
	v_exp_f32_e32 v1, v1
	v_exp_f32_e32 v3, v3
	s_nop 0
	v_pk_add_f32 v[4:5], v[0:1], v[2:3]
	s_nop 0
	v_add_f32_e32 v4, v4, v5
	v_add_f32_e32 v5, 0, v4
	s_nop 1
	v_add_f32_dpp v4, v5, v4 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_e32 v5, 0
	s_nop 0
	v_add_f32_dpp v4, v4, v4 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v4, v4, v4 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_mov_b32_dpp v5, v4 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_add_f32_e32 v4, v4, v5
	v_mov_b32_e32 v5, 0
	s_nop 1
	v_mov_b32_dpp v5, v4 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_add_f32_e32 v4, v4, v5
	s_nop 0
	v_readlane_b32 s3, v4, 63
	s_and_saveexec_b64 s[4:5], vcc
	s_nop 0
	v_mov_b32_e32 v4, s3
	ds_write_b32 v8, v4
	s_or_b64 exec, exec, s[4:5]
	s_load_dwordx2 s[4:5], s[0:1], 0x48
	s_load_dword s3, s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[8:11], v7
	s_mul_i32 s2, s2, s3
	s_and_b32 s5, s5, 0xffff
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[8:9], v[10:11]
	s_nop 0
	v_add_f32_e32 v4, v4, v5
	v_div_scale_f32 v5, s[0:1], v4, v4, 1.0
	v_rcp_f32_e32 v7, v5
	s_nop 0
	v_fma_f32 v8, -v5, v7, 1.0
	v_fmac_f32_e32 v7, v8, v7
	v_div_scale_f32 v8, vcc, 1.0, v4, 1.0
	v_mul_f32_e32 v9, v8, v7
	v_fma_f32 v10, -v5, v9, v8
	v_fmac_f32_e32 v9, v10, v7
	v_fma_f32 v5, -v5, v9, v8
	v_div_fmas_f32 v5, v5, v7, v9
	v_div_fixup_f32 v4, v5, v4, 1.0
	v_pk_mul_f32 v[2:3], v[2:3], v[4:5] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[0:1], v[4:5] op_sel_hi:[1,0]
	v_add_lshl_u32 v4, s2, v6, 2
	buffer_store_dwordx4 v[0:3], v4, s[4:7], 0 offen
	s_endpgm
.Lfunc_end0:
	.size	softmax_kernel_0, .Lfunc_end0-softmax_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel softmax_kernel_0
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 100
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
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 8
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

	.set .Lsoftmax_kernel_0.num_vgpr, 14
	.set .Lsoftmax_kernel_0.num_agpr, 0
	.set .Lsoftmax_kernel_0.numbered_sgpr, 8
	.set .Lsoftmax_kernel_0.num_named_barrier, 0
	.set .Lsoftmax_kernel_0.private_seg_size, 0
	.set .Lsoftmax_kernel_0.uses_vcc, 1
	.set .Lsoftmax_kernel_0.uses_flat_scratch, 0
	.set .Lsoftmax_kernel_0.has_dyn_sized_stack, 0
	.set .Lsoftmax_kernel_0.has_recursion, 0
	.set .Lsoftmax_kernel_0.has_indirect_call, 0
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
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .offset:         80
        .size:           16
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 100
    .max_flat_workgroup_size: 256
    .name:           softmax_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         softmax_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
