	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	bit_ops
	.globl	bit_ops
	.p2align	8
	.type	bit_ops,@function
bit_ops:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[0:1], s[0:1], 0x10
	v_lshlrev_b32_e32 v1, 2, v0
	v_mul_u32_u24_e32 v3, 0x100001, v0
	s_mov_b32 s2, 0x5a5a5a
	s_waitcnt lgkmcnt(0)
	global_load_dword v29, v1, s[4:5]
	global_load_dword v30, v1, s[6:7]
	global_load_dword v1, v1, s[4:5] offset:256
	v_xor_b32_e32 v32, s6, v3
	s_mov_b32 s3, 0xffa5a5a5
	v_mov_b32_e32 v5, s6
	v_xor_b32_e32 v33, 0x5a5a5a, v32
	v_mov_b32_e32 v4, 0x5a5a5a
	v_lshlrev_b32_e32 v31, 8, v0
	v_add_u32_e32 v34, 0x123456, v32
	v_bitop3_b32 v2, v3, s3, v5 bitop3:0x48
	v_bitop3_b32 v3, v3, s2, v5 bitop3:0xde
	v_lshlrev_b32_e32 v9, 4, v32
	v_lshrrev_b32_e32 v13, 2, v32
	v_sub_u32_e32 v14, 0xffedcba9, v32
	v_lshlrev_b32_e32 v5, v33, v32
	v_min_u32_e32 v22, v32, v33
	s_movk_i32 s4, 0x50
	s_waitcnt vmcnt(0)
	v_bfe_u32 v8, v32, 5, 8
	v_subrev_u32_e32 v11, s6, v32
	v_lshrrev_b32_e32 v6, v33, v32
	v_add_lshl_u32 v7, v33, v32, 3
	v_bitop3_b32 v9, v9, v32, s2 bitop3:0xf6
	v_sub_u32_e32 v10, v34, v33
	v_lshl_add_u32 v12, v34, 3, v33
	v_add3_u32 v13, v33, v34, v13
	v_and_or_b32 v17, v34, v32, v33
	v_xor_b32_e32 v21, v14, v33
	v_max_u32_e32 v23, v32, v33
	v_xad_u32 v24, v34, v32, v33
	v_bfi_b32 v25, v32, s3, v34
	v_alignbit_b32 v26, v32, v33, v34
	v_alignbyte_b32 v27, v32, v33, v34
	v_lshrrev_b32_e32 v14, 1, v33
	global_store_dwordx4 v31, v[2:5], s[0:1]
	global_store_dwordx4 v31, v[6:9], s[0:1] offset:16
	global_store_dwordx4 v31, v[10:13], s[0:1] offset:60
	global_store_dword v31, v17, s[0:1] offset:76
	global_store_dwordx4 v31, v[24:27], s[0:1] offset:100
	v_sub_u32_e32 v2, v34, v22
	v_med3_u32 v15, v32, 3, 60
	v_or3_b32 v16, v32, v34, s4
	v_min3_u32 v13, v32, v34, v14
	v_max3_u32 v14, v34, v14, v32
	v_add_u32_e32 v12, v2, v23
	v_bfe_i32 v35, v32, 0, 24
	v_xor_b32_e32 v36, 0xf0f0f0f0, v32
	v_bfe_i32 v37, v33, 0, 24
	v_bfe_i32 v38, v34, 0, 24
	v_add_u32_e32 v28, v34, v32
	global_store_dwordx4 v31, v[12:15], s[0:1] offset:116
	v_subrev_f32_e32 v20, s6, v29
	v_sub_f32_e32 v18, v29, v30
	v_mul_f32_e32 v19, v30, v29
	v_add_f32_e32 v17, v29, v30
	v_min_f32_e32 v26, v29, v30
	v_max_f32_e32 v27, v29, v30
	v_min3_f32 v2, v29, v1, v30
	v_max3_f32 v3, v29, v1, v30
	v_med3_f32 v4, v29, v30, v1
	v_minimum3_f32 v5, v30, v1, v29
	v_maximum3_f32 v1, v30, v1, v29
	global_store_dwordx4 v31, v[16:19], s[0:1] offset:32
	global_store_dwordx3 v31, v[26:28], s[0:1] offset:48
	global_store_dwordx4 v31, v[20:23], s[0:1] offset:84
	global_store_dwordx4 v31, v[2:5], s[0:1] offset:132
	global_store_dword v31, v1, s[0:1] offset:148
	v_lshrrev_b32_e32 v1, 1, v0
	v_lshrrev_b32_e32 v2, 2, v0
	v_bitop3_b32 v1, v1, v2, v0 bitop3:0x48
	v_and_b32_e32 v0, 7, v0
	v_lshrrev_b32_e32 v3, 3, v32
	global_store_dword v31, v1, s[0:1] offset:80
	v_ashrrev_i32_e32 v0, v0, v36
	v_min_i32_e32 v1, v35, v37
	v_max_i32_e32 v2, v35, v37
	v_mul_u32_u24_e32 v3, v3, v32
	v_lshrrev_b32_e32 v4, 8, v32
	global_store_dwordx4 v31, v[0:3], s[0:1] offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v32, v4
	v_mul_i32_i24_e32 v1, v33, v32
	v_mul_hi_i32_i24_e32 v2, v34, v32
	v_bfe_i32 v3, v36, 12, 12
	global_store_dwordx4 v31, v[0:3], s[0:1] offset:168
	s_nop 1
	v_mad_u32_u24 v0, v32, v4, v36
	v_mad_i32_i24 v1, v33, v34, v36
	v_min3_i32 v2, v35, v38, v36
	v_max3_i32 v3, v37, v36, v38
	global_store_dwordx4 v31, v[0:3], s[0:1] offset:184
	s_nop 1
	v_med3_i32 v0, v35, 2, 9
	global_store_dword v31, v0, s[0:1] offset:200
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel bit_ops
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
		.amdhsa_next_free_vgpr 39
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 40
		.amdhsa_reserve_vcc 0
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
	.size	bit_ops, .Lfunc_end0-bit_ops

	.set bit_ops.num_vgpr, 39
	.set bit_ops.num_agpr, 0
	.set bit_ops.numbered_sgpr, 8
	.set bit_ops.private_seg_size, 0
	.set bit_ops.uses_vcc, 0
	.set bit_ops.uses_flat_scratch, 0
	.set bit_ops.has_dyn_sized_stack, 0
	.set bit_ops.has_recursion, 0
	.set bit_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_bit_ops
	.globl	__clang_ocl_kern_imp_bit_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_bit_ops,@function
__clang_ocl_kern_imp_bit_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v29, 0x3ff, v31
	v_lshlrev_b32_e32 v10, 2, v29
	v_mov_b32_e32 v11, 0
	v_lshl_add_u64 v[6:7], v[2:3], 0, v[10:11]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[10:11]
	global_load_dword v32, v[6:7], off
	global_load_dword v33, v[0:1], off
	global_load_dword v34, v[0:1], off offset:256
	v_mul_u32_u24_e32 v0, 0x100001, v29
	s_mov_b32 s0, 0x5a5a5a
	s_mov_b32 s1, 0xffa5a5a5
	v_xor_b32_e32 v35, v0, v2
	v_lshlrev_b32_e32 v10, 8, v29
	v_bitop3_b32 v6, v0, s1, v2 bitop3:0x48
	v_bitop3_b32 v7, v0, s0, v2 bitop3:0xde
	v_xor_b32_e32 v36, 0x5a5a5a, v35
	v_add_u32_e32 v37, 0x123456, v35
	v_lshlrev_b32_e32 v0, 4, v35
	v_mov_b32_e32 v8, 0x5a5a5a
	v_lshl_add_u64 v[30:31], v[4:5], 0, v[10:11]
	v_lshrrev_b32_e32 v1, 2, v35
	v_lshlrev_b32_e32 v9, v36, v35
	v_bitop3_b32 v13, v0, v35, s0 bitop3:0xf6
	v_and_or_b32 v0, v37, v35, v36
	v_min_u32_e32 v22, v35, v36
	s_movk_i32 s2, 0x50
	s_waitcnt vmcnt(0)
	v_bfe_u32 v12, v35, 5, 8
	v_sub_u32_e32 v15, v35, v2
	v_lshrrev_b32_e32 v10, v36, v35
	v_add_lshl_u32 v11, v36, v35, 3
	v_sub_u32_e32 v14, v37, v36
	v_lshl_add_u32 v16, v37, 3, v36
	v_add3_u32 v17, v36, v37, v1
	v_max_u32_e32 v23, v35, v36
	v_xad_u32 v24, v37, v35, v36
	v_bfi_b32 v25, v35, s1, v37
	v_alignbit_b32 v26, v35, v36, v37
	v_alignbyte_b32 v27, v35, v36, v37
	v_lshrrev_b32_e32 v1, 1, v36
	global_store_dwordx4 v[30:31], v[6:9], off
	global_store_dwordx4 v[30:31], v[10:13], off offset:16
	global_store_dwordx4 v[30:31], v[14:17], off offset:60
	global_store_dword v[30:31], v0, off offset:76
	global_store_dwordx4 v[30:31], v[24:27], off offset:100
	v_sub_u32_e32 v0, v37, v22
	v_sub_u32_e32 v3, 0xffedcba9, v35
	v_med3_u32 v19, v35, 3, 60
	v_or3_b32 v4, v35, v37, s2
	v_min3_u32 v17, v35, v37, v1
	v_max3_u32 v18, v37, v1, v35
	v_add_u32_e32 v16, v0, v23
	v_bfe_i32 v38, v35, 0, 24
	v_xor_b32_e32 v39, 0xf0f0f0f0, v35
	v_bfe_i32 v48, v36, 0, 24
	v_bfe_i32 v49, v37, 0, 24
	v_add_u32_e32 v28, v37, v35
	v_xor_b32_e32 v21, v3, v36
	global_store_dwordx4 v[30:31], v[16:19], off offset:116
	v_sub_f32_e32 v6, v33, v32
	v_mul_f32_e32 v7, v32, v33
	v_add_f32_e32 v5, v33, v32
	v_min_f32_e32 v26, v33, v32
	v_max_f32_e32 v27, v33, v32
	v_sub_f32_e32 v20, v33, v2
	v_min3_f32 v0, v33, v34, v32
	v_max3_f32 v1, v33, v34, v32
	v_med3_f32 v2, v33, v32, v34
	v_minimum3_f32 v3, v32, v34, v33
	v_maximum3_f32 v8, v32, v34, v33
	global_store_dwordx4 v[30:31], v[4:7], off offset:32
	global_store_dwordx3 v[30:31], v[26:28], off offset:48
	global_store_dwordx4 v[30:31], v[20:23], off offset:84
	global_store_dwordx4 v[30:31], v[0:3], off offset:132
	global_store_dword v[30:31], v8, off offset:148
	s_nop 0
	v_lshrrev_b32_e32 v0, 1, v29
	v_lshrrev_b32_e32 v1, 2, v29
	v_bitop3_b32 v0, v0, v1, v29 bitop3:0x48
	global_store_dword v[30:31], v0, off offset:80
	v_and_b32_e32 v0, 7, v29
	v_lshrrev_b32_e32 v3, 3, v35
	v_ashrrev_i32_e32 v0, v0, v39
	v_min_i32_e32 v1, v38, v48
	v_max_i32_e32 v2, v38, v48
	v_mul_u32_u24_e32 v3, v3, v35
	v_lshrrev_b32_e32 v4, 8, v35
	global_store_dwordx4 v[30:31], v[0:3], off offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v35, v4
	v_mul_i32_i24_e32 v1, v36, v35
	v_mul_hi_i32_i24_e32 v2, v37, v35
	v_bfe_i32 v3, v39, 12, 12
	global_store_dwordx4 v[30:31], v[0:3], off offset:168
	s_nop 1
	v_mad_u32_u24 v0, v35, v4, v39
	v_mad_i32_i24 v1, v36, v37, v39
	v_min3_i32 v2, v38, v49, v39
	v_max3_i32 v3, v48, v39, v49
	global_store_dwordx4 v[30:31], v[0:3], off offset:184
	s_nop 1
	v_med3_i32 v0, v38, 2, 9
	global_store_dword v[30:31], v0, off offset:200
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_bit_ops, .Lfunc_end1-__clang_ocl_kern_imp_bit_ops

	.set __clang_ocl_kern_imp_bit_ops.num_vgpr, 50
	.set __clang_ocl_kern_imp_bit_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_bit_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_bit_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_bit_ops.uses_vcc, 0
	.set __clang_ocl_kern_imp_bit_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_bit_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_bit_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_bit_ops.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 50
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
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .address_space:  global
        .is_const:       true
        .offset:         8
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .type_name:      'uint*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 24
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           bit_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         bit_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     39
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
