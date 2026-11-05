	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	vector_int_ops
	.globl	vector_int_ops
	.p2align	8
	.type	vector_int_ops,@function
vector_int_ops:
	s_load_dwordx4 s[12:15], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x10
	s_load_dwordx2 s[0:1], s[0:1], 0x30
	v_lshlrev_b32_e32 v2, 7, v0
	v_or_b32_e32 v0, 0x10000, v0
	s_waitcnt lgkmcnt(0)
	;;#ASMSTART
	v_mul_lo_u32 v1, v0, s14
	;;#ASMEND
	global_store_dword v2, v1, s[12:13]
	;;#ASMSTART
	v_mul_lo_u32 v0, s14, v0
	;;#ASMEND
	global_store_dword v2, v0, s[12:13] offset:4
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v0, -1, 0
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v1, -1, v0
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[12:13] offset:8
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v0, s15, 7
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v1, s15, v0
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[12:13] offset:16
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[12:13] offset:24
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], -1
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[12:13] offset:32
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], s[4:5]
	;;#ASMEND
	global_store_dwordx2 v2, v[0:1], s[12:13] offset:40
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[4:5], v[0:1]
	v_cndmask_b32_e64 v3, 0, 1, vcc
	;;#ASMEND
	global_store_dword v2, v3, s[12:13] offset:48
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[6:7], v[0:1]
	v_cndmask_b32_e64 v3, 0, 1, vcc
	;;#ASMEND
	global_store_dword v2, v3, s[12:13] offset:52
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[8:9], v[0:1]
	v_cndmask_b32_e64 v3, 0, 1, vcc
	;;#ASMEND
	global_store_dword v2, v3, s[12:13] offset:56
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[10:11], v[0:1]
	v_cndmask_b32_e64 v3, 0, 1, vcc
	;;#ASMEND
	global_store_dword v2, v3, s[12:13] offset:60
	;;#ASMSTART
	v_mov_b64_e32 v[0:1], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[0:1]
	v_cndmask_b32_e64 v3, 0, 1, vcc
	;;#ASMEND
	global_store_dword v2, v3, s[12:13] offset:64
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel vector_int_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 56
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 16
		.amdhsa_accum_offset 4
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
	.size	vector_int_ops, .Lfunc_end0-vector_int_ops

	.set vector_int_ops.num_vgpr, 4
	.set vector_int_ops.num_agpr, 0
	.set vector_int_ops.numbered_sgpr, 16
	.set vector_int_ops.private_seg_size, 0
	.set vector_int_ops.uses_vcc, 1
	.set vector_int_ops.uses_flat_scratch, 0
	.set vector_int_ops.has_dyn_sized_stack, 0
	.set vector_int_ops.has_recursion, 0
	.set vector_int_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_vector_int_ops
	.globl	__clang_ocl_kern_imp_vector_int_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_vector_int_ops,@function
__clang_ocl_kern_imp_vector_int_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v16, 0x3ff, v31
	v_lshlrev_b32_e32 v14, 7, v16
	v_mov_b32_e32 v15, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[14:15]
	v_readfirstlane_b32 s0, v2
	v_or_b32_e32 v2, 0x10000, v16
	v_readfirstlane_b32 s1, v3
	;;#ASMSTART
	v_mul_lo_u32 v3, v2, s0
	;;#ASMEND
	global_store_dword v[0:1], v3, off
	;;#ASMSTART
	v_mul_lo_u32 v2, s0, v2
	;;#ASMEND
	global_store_dword v[0:1], v2, off offset:4
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v2, -1, 0
	;;#ASMEND
	v_readfirstlane_b32 s0, v4
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v3, -1, v2
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:8
	;;#ASMSTART
	v_mbcnt_lo_u32_b32 v2, s1, 7
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_mbcnt_hi_u32_b32 v3, s1, v2
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:16
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:24
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], -1
	;;#ASMEND
	v_readfirstlane_b32 s1, v5
	global_store_dwordx2 v[0:1], v[2:3], off offset:32
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], s[0:1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:40
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:48
	v_readfirstlane_b32 s1, v7
	v_readfirstlane_b32 s0, v6
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:52
	v_readfirstlane_b32 s1, v9
	v_readfirstlane_b32 s0, v8
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:56
	v_readfirstlane_b32 s1, v11
	v_readfirstlane_b32 s0, v10
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:60
	v_readfirstlane_b32 s1, v13
	v_readfirstlane_b32 s0, v12
	;;#ASMSTART
	v_mov_b64_e32 v[2:3], 0x7fffffff
	v_cmp_lt_i64_e32 vcc, s[0:1], v[2:3]
	v_cndmask_b32_e64 v4, 0, 1, vcc
	;;#ASMEND
	global_store_dword v[0:1], v4, off offset:64
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_vector_int_ops, .Lfunc_end1-__clang_ocl_kern_imp_vector_int_ops

	.set __clang_ocl_kern_imp_vector_int_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_vector_int_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_vector_int_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_vector_int_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_vector_int_ops.uses_vcc, 1
	.set __clang_ocl_kern_imp_vector_int_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_vector_int_ops.has_indirect_call, 0
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
        .offset:         0
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .offset:         8
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         12
        .size:           4
        .type_name:      uint
        .value_kind:     by_value
      - .offset:         16
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         24
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         32
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         40
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
      - .offset:         48
        .size:           8
        .type_name:      ulong
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 56
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           vector_int_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         vector_int_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
