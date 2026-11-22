; FlyDSL 304d441202a3 kernels/norm/layernorm_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case layernorm).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	layernorm_kernel_0
	.p2align	8
	.type	layernorm_kernel_0,@function
layernorm_kernel_0:
	s_load_dwordx8 s[4:11], s[0:1], 0x0
	s_ashr_i32 s3, s2, 31
	s_lshl_b64 s[0:1], s[2:3], 9
	v_lshlrev_b32_e32 v1, 2, v0
	s_mov_b32 s15, 0x27000
	s_waitcnt lgkmcnt(0)
	s_add_u32 s12, s4, s0
	s_addc_u32 s0, s5, s1
	s_and_b32 s13, s0, 0xffff
	s_movk_i32 s0, 0x80
	v_cmp_gt_u32_e32 vcc, s0, v0
	s_mov_b32 s14, -1
	v_and_b32_e32 v8, 63, v0
	v_cndmask_b32_e32 v2, 0, v1, vcc
	buffer_load_dword v2, v2, s[12:15], 0 offen
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v3, v2
	v_add_f32_e32 v4, 0, v2
	v_pk_mul_f32 v[2:3], v[2:3], v[2:3] op_sel_hi:[0,1]
	v_cndmask_b32_e32 v2, 0, v4, vcc
	v_cndmask_b32_e32 v3, 0, v3, vcc
	ds_swizzle_b32 v4, v2 offset:swizzle(SWAP,1)
	ds_swizzle_b32 v5, v3 offset:swizzle(SWAP,1)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_swizzle_b32 v4, v2 offset:swizzle(SWAP,2)
	ds_swizzle_b32 v5, v3 offset:swizzle(SWAP,2)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_swizzle_b32 v4, v2 offset:swizzle(SWAP,4)
	ds_swizzle_b32 v5, v3 offset:swizzle(SWAP,4)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_swizzle_b32 v4, v2 offset:swizzle(SWAP,8)
	ds_swizzle_b32 v5, v3 offset:swizzle(SWAP,8)
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	s_nop 0
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	s_nop 1
	v_permlane16_swap_b32_e32 v4, v5
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v7, v3
	s_nop 1
	v_permlane16_swap_b32_e32 v6, v7
	v_cmp_eq_u32_e64 s[0:1], v4, v2
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v5, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], v6, v3
	s_nop 1
	v_cndmask_b32_e64 v5, v6, v7, s[0:1]
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	v_cmp_eq_u32_e64 s[0:1], 0, v8
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v7, v3
	v_permlane32_swap_b32_e32 v4, v5
	s_nop 0
	v_permlane32_swap_b32_e32 v6, v7
	s_and_saveexec_b64 s[4:5], s[0:1]
	s_cbranch_execz .LBB0_2
	v_cmp_eq_u32_e64 s[0:1], v4, v2
	v_lshrrev_b32_e32 v0, 3, v0
	s_nop 0
	v_cndmask_b32_e64 v4, v4, v5, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], v6, v3
	s_nop 1
	v_cndmask_b32_e64 v5, v6, v7, s[0:1]
	v_pk_add_f32 v[2:3], v[2:3], v[4:5]
	ds_write2_b32 v0, v2, v3 offset1:1
.LBB0_2:
	s_or_b64 exec, exec, s[4:5]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_4
	buffer_load_dword v0, v1, s[12:15], 0 offen
	s_and_b32 s17, s7, 0xffff
	s_mov_b32 s19, 0x27000
	s_mov_b32 s18, -1
	s_mov_b32 s16, s6
	s_and_b32 s5, s9, 0xffff
	s_mov_b32 s4, s8
	s_mov_b32 s6, s18
	s_mov_b32 s7, s19
	buffer_load_dword v10, v1, s[16:19], 0 offen
	buffer_load_dword v11, v1, s[4:7], 0 offen
	v_mov_b32_e32 v6, 0
	ds_read2_b64 v[2:5], v6 offset1:1
	ds_read2_b64 v[6:9], v6 offset0:2 offset1:3
	s_lshl_b64 s[0:1], s[2:3], 7
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s16, s10, s0
	s_waitcnt lgkmcnt(1)
	v_pk_add_f32 v[2:3], v[4:5], v[2:3]
	s_addc_u32 s0, s11, s1
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[2:3], v[2:3], v[6:7]
	s_and_b32 s17, s0, 0xffff
	v_pk_add_f32 v[2:3], v[2:3], v[8:9]
	s_brev_b32 s0, 60
	v_pk_mul_f32 v[2:3], v[2:3], s[0:1] op_sel_hi:[1,0]
	s_nop 0
	v_mul_f32_e32 v4, v2, v2
	v_sub_f32_e32 v3, v3, v4
	v_cmp_ngt_f32_e32 vcc, 0, v3
	s_waitcnt vmcnt(2)
	v_sub_f32_e32 v0, v0, v2
	v_cndmask_b32_e32 v3, 0, v3, vcc
	v_add_f32_e32 v3, 0x3727c5ac, v3
	v_rsq_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v0, v0, v3
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v0, v10, v0
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v0, v11, v0
	buffer_store_dword v0, v1, s[16:19], 0 offen
.LBB0_4:
	s_endpgm
.Lfunc_end0:
	.size	layernorm_kernel_0, .Lfunc_end0-layernorm_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel layernorm_kernel_0
		.amdhsa_group_segment_fixed_size 32
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 48
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
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 20
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

	.set .Llayernorm_kernel_0.num_vgpr, 12
	.set .Llayernorm_kernel_0.num_agpr, 0
	.set .Llayernorm_kernel_0.numbered_sgpr, 20
	.set .Llayernorm_kernel_0.num_named_barrier, 0
	.set .Llayernorm_kernel_0.private_seg_size, 0
	.set .Llayernorm_kernel_0.uses_vcc, 1
	.set .Llayernorm_kernel_0.uses_flat_scratch, 0
	.set .Llayernorm_kernel_0.has_dyn_sized_stack, 0
	.set .Llayernorm_kernel_0.has_recursion, 0
	.set .Llayernorm_kernel_0.has_indirect_call, 0
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
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 32
    .kernarg_segment_align: 8
    .kernarg_segment_size: 48
    .max_flat_workgroup_size: 256
    .name:           layernorm_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         layernorm_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
