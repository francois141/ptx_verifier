	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_rmsnorm2d_rows
	.globl	ck_rmsnorm2d_rows
	.p2align	8
	.type	ck_rmsnorm2d_rows,@function
ck_rmsnorm2d_rows:
	s_load_dwordx4 s[4:7], s[0:1], 0x48
	v_mbcnt_lo_u32_b32 v1, -1, 0
	s_waitcnt lgkmcnt(0)
	s_lshl_b32 s7, s2, 2
	v_mbcnt_hi_u32_b32 v2, -1, v1
	v_lshlrev_b32_e32 v11, 2, v2
	s_add_i32 s2, s6, -1
	s_ashr_i32 s3, s2, 31
	s_add_u32 s13, s2, 1
	v_and_b32_e32 v10, 60, v11
	s_addc_u32 s12, s3, 0
	s_add_i32 s5, s5, -1
	v_readfirstlane_b32 s10, v0
	v_lshrrev_b32_e32 v1, 4, v2
	v_cmp_gt_i32_e32 vcc, s6, v10
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	s_and_saveexec_b64 s[8:9], vcc
	s_cbranch_execz .LBB0_2
	s_load_dword s11, s[0:1], 0x54
	s_load_dwordx2 s[16:17], s[0:1], 0x0
	v_mov_b64_e32 v[4:5], 0x7fffffff
	s_mov_b32 s19, 0x20000
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s5, s11
	s_mul_hi_i32 s2, s5, s11
	s_add_u32 s14, s3, s13
	s_addc_u32 s15, s2, s12
	v_cmp_lt_i64_e64 s[2:3], s[14:15], v[4:5]
	s_and_b64 s[2:3], s[2:3], exec
	s_cselect_b32 s2, s14, 0x7fffffff
	s_lshl_b32 s18, s2, 2
	s_lshr_b32 s2, s10, 6
	s_add_i32 s2, s2, s7
	v_add_u32_e32 v3, s2, v1
	v_mul_lo_u32 v3, s11, v3
	v_add_lshl_u32 v3, v3, v10, 2
	buffer_load_dwordx4 v[6:9], v3, s[16:19], 0 offen
.LBB0_2:
	s_or_b64 exec, exec, s[8:9]
	s_load_dwordx4 s[8:11], s[0:1], 0x18
	s_load_dword s2, s[0:1], 0x5c
	v_bfrev_b32_e32 v12, 1
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, 0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_4
	s_lshl_b32 s3, s6, 2
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[18:19], s[10:11]
	s_mov_b64 s[16:17], s[8:9]
	s_mov_b32 s18, s3
	s_mov_b32 s19, 0x20000
	v_lshlrev_b32_e32 v2, 2, v10
	buffer_load_dwordx4 v[2:5], v2, s[16:19], 0 offen
	v_mov_b32_e32 v12, 0
.LBB0_4:
	s_or_b64 exec, exec, s[0:1]
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[16:17], v[6:7], v[6:7]
	v_pk_mul_f32 v[14:15], v[8:9], v[8:9]
	v_add_f32_e32 v13, v16, v17
	v_add_f32_e32 v13, v14, v13
	v_add_f32_e32 v13, v15, v13
	v_xor_b32_e32 v14, 4, v11
	ds_bpermute_b32 v14, v14, v13
	v_xor_b32_e32 v15, 8, v11
	s_mov_b32 s3, 0x6f800000
	v_mov_b32_e32 v16, 0x2f800000
	s_waitcnt lgkmcnt(0)
	s_mul_hi_i32 s1, s5, s2
	v_add_f32_e32 v13, v13, v14
	ds_bpermute_b32 v14, v15, v13
	v_xor_b32_e32 v15, 16, v11
	v_xor_b32_e32 v11, 32, v11
	s_mul_i32 s5, s5, s2
	s_add_u32 s0, s13, s5
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v13, v13, v14
	ds_bpermute_b32 v14, v15, v13
	v_cvt_f32_i32_e32 v15, s6
	s_addc_u32 s1, s12, s1
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v13, v13, v14
	v_cmp_gt_f32_e64 vcc, |v15|, s3
	ds_bpermute_b32 v11, v11, v13
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v11, v13, v11
	v_cndmask_b32_e32 v16, 1.0, v16, vcc
	v_mul_f32_e32 v14, v15, v16
	v_rcp_f32_e32 v17, v14
	v_mov_b64_e32 v[14:15], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[14:15]
	v_mul_f32_e32 v11, v11, v17
	v_fma_f32 v11, v16, v11, s4
	s_and_b64 s[4:5], vcc, exec
	v_rsq_f32_e32 v16, v11
	s_cselect_b32 s3, s0, 0x7fffffff
	v_readfirstlane_b32 s0, v0
	s_lshr_b32 s0, s0, 6
	s_add_i32 s0, s0, s7
	v_add_u32_e32 v0, s0, v1
	v_pk_mul_f32 v[6:7], v[6:7], v[16:17] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[16:17] op_sel_hi:[1,0]
	v_mad_u64_u32 v[0:1], s[0:1], v0, s2, v[10:11]
	v_pk_mul_f32 v[4:5], v[4:5], v[8:9]
	v_pk_mul_f32 v[2:3], v[2:3], v[6:7]
	s_lshl_b32 s2, s3, 2
	s_mov_b32 s3, 0x20000
	s_mov_b32 s0, s10
	s_mov_b32 s1, s11
	v_lshl_add_u32 v0, v0, 2, v12
	buffer_store_dwordx4 v[2:5], v0, s[0:3], 0 offen
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_rmsnorm2d_rows
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 104
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
		.amdhsa_next_free_sgpr 20
		.amdhsa_accum_offset 20
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
	.size	ck_rmsnorm2d_rows, .Lfunc_end0-ck_rmsnorm2d_rows

	.set ck_rmsnorm2d_rows.num_vgpr, 18
	.set ck_rmsnorm2d_rows.num_agpr, 0
	.set ck_rmsnorm2d_rows.numbered_sgpr, 20
	.set ck_rmsnorm2d_rows.private_seg_size, 0
	.set ck_rmsnorm2d_rows.uses_vcc, 1
	.set ck_rmsnorm2d_rows.uses_flat_scratch, 0
	.set ck_rmsnorm2d_rows.has_dyn_sized_stack, 0
	.set ck_rmsnorm2d_rows.has_recursion, 0
	.set ck_rmsnorm2d_rows.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_d673d1700337864c,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_d673d1700337864c
__hip_cuid_d673d1700337864c:
	.byte	0
	.size	__hip_cuid_d673d1700337864c, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_d673d1700337864c
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           104
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 104
    .max_flat_workgroup_size: 1024
    .name:           ck_rmsnorm2d_rows
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         ck_rmsnorm2d_rows.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     18
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
