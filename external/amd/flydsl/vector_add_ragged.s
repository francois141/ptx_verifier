; FlyDSL 304d441202a3 examples/01-vectorAdd.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case vector_add_ragged).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	vector_add_kernel_0
	.p2align	8
	.type	vector_add_kernel_0,@function
vector_add_kernel_0:
	s_load_dwordx2 s[4:5], s[0:1], 0x8
	v_lshrrev_b32_e32 v1, 4, v0
	v_lshlrev_b32_e32 v0, 2, v0
	s_lshl_b32 s12, s3, 6
	v_and_b32_e32 v0, 60, v0
	v_lshl_or_b32 v2, s2, 3, v1
	v_or_b32_e32 v3, s12, v0
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e32 vcc, s5, v3
	v_cmp_gt_i32_e64 s[4:5], s4, v2
	s_and_b64 s[4:5], s[4:5], vcc
	s_and_saveexec_b64 s[6:7], s[4:5]
	s_cbranch_execz .LBB0_2
	s_load_dwordx4 s[8:11], s[0:1], 0x28
	s_load_dwordx2 s[14:15], s[0:1], 0x40
	s_load_dwordx4 s[4:7], s[0:1], 0x10
	s_load_dwordx2 s[16:17], s[0:1], 0x0
	s_lshl_b32 s18, s2, 3
	s_ashr_i32 s3, s2, 31
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s18, s15
	s_mul_hi_u32 s1, s18, s14
	s_add_i32 s19, s1, s0
	s_lshr_b64 s[0:1], s[2:3], 29
	s_mul_i32 s1, s0, s14
	s_add_i32 s3, s19, s1
	s_mul_i32 s2, s18, s14
	s_ashr_i32 s13, s12, 31
	s_lshl_b64 s[2:3], s[2:3], 2
	s_add_u32 s1, s10, s2
	s_addc_u32 s11, s11, s3
	s_lshl_b64 s[2:3], s[12:13], 2
	v_mad_u64_u32 v[2:3], s[12:13], s8, v1, 0
	v_lshlrev_b32_e32 v10, 2, v0
	v_mov_b32_e32 v0, v3
	s_add_u32 s10, s1, s2
	v_mad_u64_u32 v[4:5], s[12:13], s9, v1, v[0:1]
	s_mul_i32 s1, s18, s9
	s_mul_hi_u32 s9, s18, s8
	s_addc_u32 s11, s11, s3
	s_add_i32 s1, s9, s1
	s_mul_i32 s9, s0, s8
	s_add_i32 s9, s1, s9
	s_mul_i32 s8, s18, s8
	s_lshl_b64 s[8:9], s[8:9], 2
	s_add_u32 s1, s6, s8
	s_addc_u32 s7, s7, s9
	s_add_u32 s6, s1, s2
	v_mov_b32_e32 v3, v4
	s_addc_u32 s7, s7, s3
	v_mov_b32_e32 v11, 0
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[6:7]
	v_lshl_add_u64 v[12:13], v[2:3], 0, v[10:11]
	v_mad_u64_u32 v[2:3], s[6:7], s4, v1, 0
	v_mov_b32_e32 v0, v3
	v_mad_u64_u32 v[4:5], s[6:7], s5, v1, v[0:1]
	s_mul_i32 s1, s18, s5
	s_mul_hi_u32 s5, s18, s4
	s_add_i32 s1, s5, s1
	s_mul_i32 s0, s0, s4
	s_add_i32 s1, s1, s0
	s_mul_i32 s0, s18, s4
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s16, s0
	s_addc_u32 s1, s17, s1
	s_add_u32 s0, s0, s2
	v_mov_b32_e32 v3, v4
	s_addc_u32 s1, s1, s3
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[0:1]
	v_lshl_add_u64 v[14:15], v[2:3], 0, v[10:11]
	global_load_dwordx4 v[2:5], v[12:13], off
	global_load_dwordx4 v[6:9], v[14:15], off
	v_mad_u64_u32 v[12:13], s[0:1], s14, v1, 0
	v_mov_b32_e32 v0, v13
	v_mad_u64_u32 v[0:1], s[0:1], s15, v1, v[0:1]
	v_mov_b32_e32 v13, v0
	v_lshl_add_u64 v[0:1], v[12:13], 2, s[10:11]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[10:11]
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[4:5], v[8:9], v[4:5]
	v_pk_add_f32 v[2:3], v[6:7], v[2:3]
	global_store_dwordx4 v[0:1], v[2:5], off
.LBB0_2:
	s_endpgm
.Lfunc_end0:
	.size	vector_add_kernel_0, .Lfunc_end0-vector_add_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel vector_add_kernel_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 72
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
		.amdhsa_next_free_vgpr 16
		.amdhsa_next_free_sgpr 20
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

	.set .Lvector_add_kernel_0.num_vgpr, 16
	.set .Lvector_add_kernel_0.num_agpr, 0
	.set .Lvector_add_kernel_0.numbered_sgpr, 20
	.set .Lvector_add_kernel_0.num_named_barrier, 0
	.set .Lvector_add_kernel_0.private_seg_size, 0
	.set .Lvector_add_kernel_0.uses_vcc, 1
	.set .Lvector_add_kernel_0.uses_flat_scratch, 0
	.set .Lvector_add_kernel_0.has_dyn_sized_stack, 0
	.set .Lvector_add_kernel_0.has_recursion, 0
	.set .Lvector_add_kernel_0.has_indirect_call, 0
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 72
    .max_flat_workgroup_size: 128
    .name:           vector_add_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 128
      - 1
      - 1
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         vector_add_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     16
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
