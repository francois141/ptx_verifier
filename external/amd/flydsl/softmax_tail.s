; FlyDSL 304d441202a3 kernels/norm/softmax_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case softmax_tail).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	softmax_kernel_0
	.p2align	8
	.type	softmax_kernel_0,@function
softmax_kernel_0:
	s_load_dwordx2 s[12:13], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	s_load_dwordx2 s[8:9], s[0:1], 0x48
	v_or_b32_e32 v2, 0x100, v0
	s_movk_i32 s4, 0x12c
	v_cmp_gt_u32_e64 s[4:5], s4, v2
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, -1
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s2, s3
	v_cndmask_b32_e64 v2, 0, v2, s[4:5]
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	v_add_lshl_u32 v3, s3, v2, 2
	v_add_lshl_u32 v1, s3, v0, 2
	buffer_load_dword v4, v3, s[12:15], 0 offen
	buffer_load_dword v2, v1, s[12:15], 0 offen
	v_mov_b32_e32 v1, 0xff800000
	v_and_b32_e32 v3, 63, v0
	v_cmp_eq_u32_e32 vcc, 0, v3
	v_mov_b32_e32 v5, 0xff800000
	v_mov_b32_e32 v6, 0xff800000
	v_mov_b32_e32 v7, 0xff800000
	v_mov_b32_e32 v8, 0xff800000
	v_mov_b32_e32 v9, 0xff800000
	v_lshrrev_b32_e32 v10, 6, v0
	s_and_b32 s9, s9, 0xffff
	s_barrier
	s_waitcnt vmcnt(1)
	v_cndmask_b32_e64 v3, v1, v4, s[4:5]
	s_waitcnt vmcnt(0)
	v_maximum3_f32 v4, v2, v3, v3
	s_nop 1
	v_mov_b32_dpp v5, v4 row_shr:1 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v4, v4, v5, v5
	s_nop 1
	v_mov_b32_dpp v6, v4 row_shr:2 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v4, v4, v6, v6
	s_nop 1
	v_mov_b32_dpp v7, v4 row_shr:4 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v4, v4, v7, v7
	s_nop 1
	v_mov_b32_dpp v8, v4 row_shr:8 row_mask:0xf bank_mask:0xf
	v_maximum3_f32 v4, v4, v8, v8
	s_nop 1
	v_mov_b32_dpp v9, v4 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_maximum3_f32 v4, v4, v9, v9
	s_nop 1
	v_mov_b32_dpp v1, v4 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_maximum3_f32 v1, v4, v1, v1
	v_lshlrev_b32_e32 v4, 2, v10
	v_readlane_b32 s3, v1, 63
	s_and_saveexec_b64 s[6:7], vcc
	s_nop 0
	v_mov_b32_e32 v1, s3
	ds_write_b32 v4, v1
	s_or_b64 exec, exec, s[6:7]
	v_mov_b32_e32 v5, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[6:9], v5 offset1:1
	s_mov_b32 s6, 0x3fb8aa3b
	s_waitcnt lgkmcnt(0)
	s_barrier
	v_maximum3_f32 v1, v6, v7, v7
	v_maximum3_f32 v6, v1, v8, v9
	v_pk_add_f32 v[2:3], v[2:3], v[6:7] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mov_b32_e32 v6, 0
	v_pk_mul_f32 v[2:3], v[2:3], s[6:7] op_sel_hi:[1,0]
	s_nop 0
	v_exp_f32_e32 v1, v3
	v_exp_f32_e32 v2, v2
	v_cndmask_b32_e64 v3, 0, v1, s[4:5]
	v_add_f32_e32 v3, v2, v3
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v3, v3, v3 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_mov_b32_dpp v6, v3 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_add_f32_e32 v3, v3, v6
	v_mov_b32_e32 v6, 0
	s_nop 1
	v_mov_b32_dpp v6, v3 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_add_f32_e32 v3, v3, v6
	s_nop 0
	v_readlane_b32 s3, v3, 63
	s_and_saveexec_b64 s[6:7], vcc
	s_nop 0
	v_mov_b32_e32 v3, s3
	ds_write_b32 v4, v3
	s_or_b64 exec, exec, s[6:7]
	s_load_dword s3, s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[4:7], v5
	s_mul_i32 s2, s2, s3
	v_add_u32_e32 v0, s2, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[6:7]
	s_nop 0
	v_add_f32_e32 v3, v4, v5
	v_div_scale_f32 v4, s[0:1], v3, v3, 1.0
	v_rcp_f32_e32 v5, v4
	v_div_scale_f32 v6, vcc, 1.0, v3, 1.0
	v_fma_f32 v7, -v4, v5, 1.0
	v_fmac_f32_e32 v5, v7, v5
	v_mul_f32_e32 v7, v6, v5
	v_fma_f32 v8, -v4, v7, v6
	v_fmac_f32_e32 v7, v8, v5
	v_fma_f32 v4, -v4, v7, v6
	v_div_fmas_f32 v4, v4, v5, v7
	v_div_fixup_f32 v3, v4, v3, 1.0
	v_mul_f32_e32 v2, v2, v3
	buffer_store_dword v2, v0, s[8:11], 0 offen
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_6
	v_mul_f32_e32 v1, v1, v3
	buffer_store_dword v1, v0, s[8:11], 0 offen offset:1024
.LBB0_6:
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
		.amdhsa_next_free_vgpr 11
		.amdhsa_next_free_sgpr 16
		.amdhsa_accum_offset 12
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

	.set .Lsoftmax_kernel_0.num_vgpr, 11
	.set .Lsoftmax_kernel_0.num_agpr, 0
	.set .Lsoftmax_kernel_0.numbered_sgpr, 16
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
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         softmax_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     11
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
