	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	bit_ops
	.globl	bit_ops
	.p2align	8
	.type	bit_ops,@function
bit_ops:
	s_load_dwordx8 s[0:7], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 2, v0
	v_mul_u32_u24_e32 v3, 0x100001, v0
	v_mov_b32_e32 v4, 0x5a5a5a
	v_lshlrev_b32_e32 v27, 8, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v25, v1, s[0:1]
	global_load_dword v26, v1, s[2:3]
	global_load_dword v1, v1, s[0:1] offset:256
	v_xor_b32_e32 v28, s2, v3
	s_mov_b32 s0, 0x5a5a5a
	s_mov_b32 s1, 0xffa5a5a5
	v_mov_b32_e32 v5, s2
	v_xor_b32_e32 v29, 0x5a5a5a, v28
	v_add_u32_e32 v30, 0x123456, v28
	v_lshrrev_b32_e32 v14, 2, v28
	v_sub_u32_e32 v15, 0xffedcba9, v28
	s_movk_i32 s3, 0x50
	v_bitop3_b32 v2, v3, s1, v5 bitop3:0x48
	v_bitop3_b32 v3, v3, s0, v5 bitop3:0xde
	v_lshlrev_b32_e32 v9, 4, v28
	v_lshlrev_b32_e32 v5, v29, v28
	v_add3_u32 v22, v29, v30, v14
	v_xor_b32_e32 v14, v15, v29
	v_min_u32_e32 v15, v28, v29
	s_waitcnt vmcnt(0)
	v_bfe_u32 v8, v28, 5, 8
	v_subrev_u32_e32 v12, s2, v28
	v_lshrrev_b32_e32 v6, v29, v28
	v_add_lshl_u32 v7, v29, v28, 3
	v_bitop3_b32 v9, v9, v28, s0 bitop3:0xf6
	v_or3_b32 v21, v28, v30, s3
	v_add_u32_e32 v10, v30, v28
	v_sub_u32_e32 v11, v30, v29
	v_lshl_add_u32 v13, v30, 3, v29
	v_and_or_b32 v23, v30, v28, v29
	v_max_u32_e32 v16, v28, v29
	v_xad_u32 v17, v30, v28, v29
	v_lshrrev_b32_e32 v35, 1, v29
	global_store_dwordx4 v27, v[2:5], s[4:5]
	global_store_dwordx4 v27, v[6:9], s[4:5] offset:16
	global_store_dword v27, v21, s[4:5] offset:32
	global_store_dwordx4 v27, v[10:13], s[4:5] offset:56
	global_store_dwordx2 v27, v[22:23], s[4:5] offset:72
	global_store_dwordx4 v27, v[14:17], s[4:5] offset:88
	v_sub_u32_e32 v2, v30, v15
	v_med3_u32 v24, v28, 3, 60
	v_min3_u32 v22, v28, v30, v35
	v_max3_u32 v23, v30, v35, v28
	v_add_u32_e32 v21, v2, v16
	v_bfe_i32 v31, v28, 0, 24
	v_xor_b32_e32 v32, 0xf0f0f0f0, v28
	v_bfe_i32 v33, v29, 0, 24
	v_bfe_i32 v34, v30, 0, 24
	v_bfi_b32 v18, v28, s1, v30
	v_alignbit_b32 v19, v28, v29, v30
	v_alignbyte_b32 v20, v28, v29, v30
	global_store_dwordx3 v27, v[22:24], s[4:5] offset:120
	global_store_dwordx4 v27, v[18:21], s[4:5] offset:104
	v_subrev_f32_e32 v11, s2, v25
	v_sub_f32_e32 v3, v25, v26
	v_mul_f32_e32 v4, v26, v25
	v_min_f32_e32 v5, v25, v26
	v_add_f32_e32 v2, v25, v26
	v_max_f32_e32 v10, v25, v26
	v_min3_f32 v6, v25, v1, v26
	v_max3_f32 v7, v25, v1, v26
	v_med3_f32 v8, v25, v26, v1
	v_minimum3_f32 v9, v26, v1, v25
	v_maximum3_f32 v1, v26, v1, v25
	global_store_dwordx4 v27, v[2:5], s[6:7] offset:36
	global_store_dword v27, v10, s[6:7] offset:52
	global_store_dword v27, v11, s[6:7] offset:84
	global_store_dwordx4 v27, v[6:9], s[6:7] offset:132
	global_store_dword v27, v1, s[6:7] offset:148
	v_lshrrev_b32_e32 v1, 1, v0
	v_lshrrev_b32_e32 v2, 2, v0
	v_bitop3_b32 v1, v1, v2, v0 bitop3:0x48
	v_and_b32_e32 v0, 7, v0
	v_lshrrev_b32_e32 v3, 3, v28
	global_store_dword v27, v1, s[4:5] offset:80
	v_ashrrev_i32_e32 v0, v0, v32
	v_min_i32_e32 v1, v31, v33
	v_max_i32_e32 v2, v31, v33
	v_mul_u32_u24_e32 v3, v3, v28
	v_lshrrev_b32_e32 v4, 8, v28
	global_store_dwordx4 v27, v[0:3], s[4:5] offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v28, v4
	v_mul_i32_i24_e32 v1, v29, v28
	v_mul_hi_i32_i24_e32 v2, v30, v28
	v_bfe_i32 v3, v32, 12, 12
	global_store_dwordx4 v27, v[0:3], s[4:5] offset:168
	s_nop 1
	v_mad_u32_u24 v0, v28, v4, v32
	v_mad_i32_i24 v1, v29, v30, v32
	v_min3_i32 v2, v31, v34, v32
	v_max3_i32 v3, v33, v32, v34
	global_store_dwordx4 v27, v[0:3], s[4:5] offset:184
	s_nop 1
	v_med3_i32 v0, v31, 2, 9
	global_store_dword v27, v0, s[4:5] offset:200
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel bit_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 32
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
		.amdhsa_next_free_vgpr 36
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 36
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

	.set bit_ops.num_vgpr, 36
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
	v_and_b32_e32 v27, 0x3ff, v31
	v_lshlrev_b32_e32 v12, 2, v27
	v_mov_b32_e32 v13, 0
	v_lshl_add_u64 v[8:9], v[2:3], 0, v[12:13]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[12:13]
	global_load_dword v32, v[8:9], off
	global_load_dword v33, v[0:1], off
	global_load_dword v34, v[0:1], off offset:256
	v_mul_u32_u24_e32 v0, 0x100001, v27
	s_mov_b32 s0, 0x5a5a5a
	s_mov_b32 s1, 0xffa5a5a5
	v_xor_b32_e32 v35, v0, v2
	v_lshlrev_b32_e32 v12, 8, v27
	v_bitop3_b32 v8, v0, s1, v2 bitop3:0x48
	v_bitop3_b32 v9, v0, s0, v2 bitop3:0xde
	v_xor_b32_e32 v36, 0x5a5a5a, v35
	v_add_u32_e32 v37, 0x123456, v35
	v_lshlrev_b32_e32 v0, 4, v35
	v_lshrrev_b32_e32 v1, 2, v35
	v_sub_u32_e32 v3, 0xffedcba9, v35
	v_mov_b32_e32 v10, 0x5a5a5a
	s_movk_i32 s2, 0x50
	v_lshl_add_u64 v[28:29], v[4:5], 0, v[12:13]
	v_lshl_add_u64 v[30:31], v[6:7], 0, v[12:13]
	v_bfe_u32 v6, v35, 5, 8
	v_lshlrev_b32_e32 v11, v36, v35
	v_lshrrev_b32_e32 v4, v36, v35
	v_add_lshl_u32 v5, v36, v35, 3
	v_bitop3_b32 v7, v0, v35, s0 bitop3:0xf6
	v_add3_u32 v0, v36, v37, v1
	v_xor_b32_e32 v16, v3, v36
	v_min_u32_e32 v17, v35, v36
	v_lshrrev_b32_e32 v3, 1, v36
	s_waitcnt vmcnt(0)
	v_sub_u32_e32 v14, v35, v2
	v_med3_u32 v26, v35, 3, 60
	v_or3_b32 v23, v35, v37, s2
	v_add_u32_e32 v12, v37, v35
	v_sub_u32_e32 v13, v37, v36
	v_lshl_add_u32 v15, v37, 3, v36
	v_and_or_b32 v1, v37, v35, v36
	v_max_u32_e32 v18, v35, v36
	v_xad_u32 v19, v37, v35, v36
	global_store_dwordx4 v[28:29], v[8:11], off
	global_store_dwordx4 v[28:29], v[4:7], off offset:16
	global_store_dword v[28:29], v23, off offset:32
	global_store_dwordx4 v[28:29], v[12:15], off offset:56
	global_store_dwordx2 v[28:29], v[0:1], off offset:72
	global_store_dwordx4 v[28:29], v[16:19], off offset:88
	v_sub_u32_e32 v0, v37, v17
	v_min3_u32 v24, v35, v37, v3
	v_max3_u32 v25, v37, v3, v35
	v_bfe_i32 v38, v35, 0, 24
	v_xor_b32_e32 v39, 0xf0f0f0f0, v35
	v_bfe_i32 v48, v36, 0, 24
	v_bfe_i32 v49, v37, 0, 24
	v_bfi_b32 v20, v35, s1, v37
	v_alignbit_b32 v21, v35, v36, v37
	v_alignbyte_b32 v22, v35, v36, v37
	v_add_u32_e32 v23, v0, v18
	global_store_dwordx3 v[28:29], v[24:26], off offset:120
	global_store_dwordx4 v[28:29], v[20:23], off offset:104
	v_sub_f32_e32 v5, v33, v32
	v_mul_f32_e32 v6, v32, v33
	v_min_f32_e32 v7, v33, v32
	v_add_f32_e32 v4, v33, v32
	v_max_f32_e32 v8, v33, v32
	v_sub_f32_e32 v9, v33, v2
	v_min3_f32 v0, v33, v34, v32
	v_max3_f32 v1, v33, v34, v32
	v_med3_f32 v2, v33, v32, v34
	v_minimum3_f32 v3, v32, v34, v33
	v_maximum3_f32 v10, v32, v34, v33
	global_store_dwordx4 v[30:31], v[4:7], off offset:36
	global_store_dword v[30:31], v8, off offset:52
	global_store_dword v[30:31], v9, off offset:84
	global_store_dwordx4 v[30:31], v[0:3], off offset:132
	global_store_dword v[30:31], v10, off offset:148
	s_nop 0
	v_lshrrev_b32_e32 v0, 1, v27
	v_lshrrev_b32_e32 v1, 2, v27
	v_bitop3_b32 v0, v0, v1, v27 bitop3:0x48
	global_store_dword v[28:29], v0, off offset:80
	v_and_b32_e32 v0, 7, v27
	v_lshrrev_b32_e32 v3, 3, v35
	v_ashrrev_i32_e32 v0, v0, v39
	v_min_i32_e32 v1, v38, v48
	v_max_i32_e32 v2, v38, v48
	v_mul_u32_u24_e32 v3, v3, v35
	v_lshrrev_b32_e32 v4, 8, v35
	global_store_dwordx4 v[28:29], v[0:3], off offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v35, v4
	v_mul_i32_i24_e32 v1, v36, v35
	v_mul_hi_i32_i24_e32 v2, v37, v35
	v_bfe_i32 v3, v39, 12, 12
	global_store_dwordx4 v[28:29], v[0:3], off offset:168
	s_nop 1
	v_mad_u32_u24 v0, v35, v4, v39
	v_mad_i32_i24 v1, v36, v37, v39
	v_min3_i32 v2, v38, v49, v39
	v_max3_i32 v3, v48, v39, v49
	global_store_dwordx4 v[28:29], v[0:3], off offset:184
	s_nop 1
	v_med3_i32 v0, v38, 2, 9
	global_store_dword v[28:29], v0, off offset:200
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
      - .address_space:  global
        .offset:         24
        .size:           8
        .type_name:      'float*'
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 32
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
    .vgpr_count:     36
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
