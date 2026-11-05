	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	float_ops
	.globl	float_ops
	.p2align	8
	.type	float_ops,@function
float_ops:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_lshlrev_b32_e32 v1, 2, v0
	v_lshlrev_b32_e32 v20, 7, v0
	s_mov_b32 s2, -2.0
	s_waitcnt lgkmcnt(0)
	global_load_dword v18, v1, s[4:5]
	global_load_dword v19, v1, s[6:7]
	s_mov_b32 s4, 0x7f800000
	s_waitcnt vmcnt(1)
	v_sqrt_f32_e32 v4, v18
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, v18, v19
	v_mul_f32_e32 v3, v19, v18
	v_rcp_f32_e32 v8, v19
	v_cndmask_b32_e32 v12, 2.0, v18, vcc
	v_cmp_lt_f32_e32 vcc, v19, v18
	v_rsq_f32_e32 v5, v18
	v_exp_f32_e32 v6, v18
	v_log_f32_e32 v7, v18
	v_cndmask_b32_e32 v13, v3, v18, vcc
	v_cmp_le_f32_e32 vcc, v19, v18
	v_rcp_f32_e32 v0, v18
	v_sub_f32_e32 v2, v18, v19
	v_cndmask_b32_e32 v15, v3, v18, vcc
	v_cmp_le_f32_e32 vcc, v18, v19
	v_add_f32_e32 v1, v18, v19
	v_min_f32_e32 v9, v18, v19
	v_cndmask_b32_e32 v14, v3, v18, vcc
	v_cmp_eq_f32_e32 vcc, v18, v19
	v_max_f32_e32 v10, v18, v19
	v_fma_f32 v11, v18, v19, v18
	v_cndmask_b32_e32 v16, v3, v18, vcc
	v_cmp_lg_f32_e32 vcc, v18, v19
	v_mul_f32_e32 v8, v8, v18
	v_readfirstlane_b32 s5, v18
	v_cndmask_b32_e32 v17, v3, v18, vcc
	global_store_dwordx4 v20, v[12:15], s[0:1] offset:56
	global_store_dwordx2 v20, v[16:17], s[0:1] offset:72
	global_store_dwordx4 v20, v[4:7], s[0:1] offset:8
	global_store_dwordx4 v20, v[0:3], s[0:1] offset:24
	global_store_dwordx4 v20, v[8:11], s[0:1] offset:40
	s_nop 0
	;;#ASMSTART
	v_cmp_gt_f32_e64 vcc, |s2|, v18
	v_cndmask_b32_e32 v0, v18, v19, vcc
	;;#ASMEND
	global_store_dword v20, v0, s[0:1]
	;;#ASMSTART
	v_cmp_neq_f32_e64 s[2:3], |v18|, s5
	v_cndmask_b32_e64 v0, v18, v19, s[2:3]
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:80
	;;#ASMSTART
	v_cmp_gt_f32_e64 vcc, v18, |v19|
	v_cndmask_b32_e32 v0, v18, v19, vcc
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:84
	;;#ASMSTART
	v_mov_b32_e32 v0, 0xff800000
	v_cmp_neq_f32_e64 s[2:3], |v0|, s4
	s_or_b64 s[2:3], s[2:3], 0
	v_cndmask_b32_e64 v0, v18, v19, s[2:3]
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:4
	;;#ASMSTART
	v_fma_f32 v0, -v18, v19, v18
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:88
	;;#ASMSTART
	v_fma_f32 v0, v18, -v19, v18
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:92
	;;#ASMSTART
	v_fma_f32 v0, s5, v18, -v19
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:96
	;;#ASMSTART
	v_fma_f32 v0, -|v18|, v19, |v19|
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:100
	;;#ASMSTART
	v_cmp_lt_f32_e64 vcc, -v18, -|v19|
	v_cndmask_b32_e32 v0, v18, v19, vcc
	;;#ASMEND
	global_store_dword v20, v0, s[0:1] offset:104
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel float_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 24
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
		.amdhsa_next_free_vgpr 21
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 24
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
.Lfunc_end0:
	.size	float_ops, .Lfunc_end0-float_ops

	.set float_ops.num_vgpr, 21
	.set float_ops.num_agpr, 0
	.set float_ops.numbered_sgpr, 8
	.set float_ops.private_seg_size, 0
	.set float_ops.uses_vcc, 1
	.set float_ops.uses_flat_scratch, 0
	.set float_ops.has_dyn_sized_stack, 0
	.set float_ops.has_recursion, 0
	.set float_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_float_ops
	.globl	__clang_ocl_kern_imp_float_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_float_ops,@function
__clang_ocl_kern_imp_float_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v8, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v8
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	global_load_dword v20, v[0:1], off
	v_lshl_add_u64 v[0:1], v[2:3], 0, v[6:7]
	global_load_dword v21, v[0:1], off
	v_lshlrev_b32_e32 v6, 7, v8
	v_lshl_add_u64 v[16:17], v[4:5], 0, v[6:7]
	s_mov_b32 s0, -2.0
	s_mov_b32 s2, 0x7f800000
	s_waitcnt vmcnt(1)
	v_sqrt_f32_e32 v4, v20
	v_rsq_f32_e32 v5, v20
	s_waitcnt vmcnt(0)
	v_cmp_lt_f32_e32 vcc, v20, v21
	v_mul_f32_e32 v3, v21, v20
	v_rcp_f32_e32 v8, v21
	v_cndmask_b32_e32 v12, 2.0, v20, vcc
	v_cmp_lt_f32_e32 vcc, v21, v20
	v_exp_f32_e32 v6, v20
	v_log_f32_e32 v7, v20
	v_cndmask_b32_e32 v13, v3, v20, vcc
	v_cmp_le_f32_e32 vcc, v21, v20
	v_rcp_f32_e32 v0, v20
	v_sub_f32_e32 v2, v20, v21
	v_cndmask_b32_e32 v15, v3, v20, vcc
	v_cmp_le_f32_e32 vcc, v20, v21
	v_add_f32_e32 v1, v20, v21
	v_min_f32_e32 v9, v20, v21
	v_cndmask_b32_e32 v14, v3, v20, vcc
	v_cmp_eq_f32_e32 vcc, v20, v21
	v_max_f32_e32 v10, v20, v21
	v_fma_f32 v11, v20, v21, v20
	v_cndmask_b32_e32 v18, v3, v20, vcc
	v_cmp_lg_f32_e32 vcc, v20, v21
	v_mul_f32_e32 v8, v8, v20
	v_readfirstlane_b32 s3, v20
	v_cndmask_b32_e32 v19, v3, v20, vcc
	global_store_dwordx4 v[16:17], v[12:15], off offset:56
	global_store_dwordx2 v[16:17], v[18:19], off offset:72
	global_store_dwordx4 v[16:17], v[4:7], off offset:8
	global_store_dwordx4 v[16:17], v[0:3], off offset:24
	global_store_dwordx4 v[16:17], v[8:11], off offset:40
	s_nop 0
	;;#ASMSTART
	v_cmp_gt_f32_e64 vcc, |s0|, v20
	v_cndmask_b32_e32 v0, v20, v21, vcc
	;;#ASMEND
	global_store_dword v[16:17], v0, off
	;;#ASMSTART
	v_cmp_neq_f32_e64 s[0:1], |v20|, s3
	v_cndmask_b32_e64 v0, v20, v21, s[0:1]
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:80
	;;#ASMSTART
	v_cmp_gt_f32_e64 vcc, v20, |v21|
	v_cndmask_b32_e32 v0, v20, v21, vcc
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:84
	;;#ASMSTART
	v_mov_b32_e32 v0, 0xff800000
	v_cmp_neq_f32_e64 s[0:1], |v0|, s2
	s_or_b64 s[0:1], s[0:1], 0
	v_cndmask_b32_e64 v0, v20, v21, s[0:1]
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:4
	;;#ASMSTART
	v_fma_f32 v0, -v20, v21, v20
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:88
	;;#ASMSTART
	v_fma_f32 v0, v20, -v21, v20
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:92
	;;#ASMSTART
	v_fma_f32 v0, s3, v20, -v21
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:96
	;;#ASMSTART
	v_fma_f32 v0, -|v20|, v21, |v21|
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:100
	;;#ASMSTART
	v_cmp_lt_f32_e64 vcc, -v20, -|v21|
	v_cndmask_b32_e32 v0, v20, v21, vcc
	;;#ASMEND
	global_store_dword v[16:17], v0, off offset:104
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_float_ops, .Lfunc_end1-__clang_ocl_kern_imp_float_ops

	.set __clang_ocl_kern_imp_float_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_float_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_float_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_float_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_float_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_float_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_float_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_float_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_float_ops.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 32
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 32
	.text
	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .is_const:       true
        .offset:         0
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .offset:         8
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           float_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         float_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     21
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
