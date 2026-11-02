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
	v_mul_u32_u24_e32 v2, 0x100001, v0
	v_lshlrev_b32_e32 v37, 8, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v28, v1, s[4:5]
	global_load_dword v17, v1, s[6:7]
	global_load_dword v1, v1, s[4:5] offset:256
	v_xor_b32_e32 v38, s6, v2
	v_lshlrev_b32_e32 v2, 8, v38
	v_add_u32_e32 v2, 0x12345600, v2
	v_bfe_i32 v39, v38, 0, 24
	v_ashrrev_i32_e32 v42, 8, v2
	v_xor_b32_e32 v40, 0xf0f0f0f0, v38
	v_xor_b32_e32 v41, 0x5a5a5a, v39
	s_waitcnt vmcnt(2)
	v_lshrrev_b32_e32 v27, 2, v28
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v2, v17, v28
	v_or_b32_e32 v3, v17, v28
	v_xor_b32_e32 v4, v17, v28
	v_lshlrev_b32_e32 v5, v17, v28
	v_and_b32_e32 v7, 0xf0, v17
	v_mul_f32_e32 v10, v17, v28
	v_min_f32_e32 v11, v28, v17
	v_max_f32_e32 v12, v28, v17
	s_waitcnt vmcnt(0)
	v_add_u32_e32 v13, v1, v28
	v_and_or_b32 v43, v1, v28, v17
	v_lshrrev_b32_e32 v44, 1, v17
	v_min3_f32 v30, v28, v1, v17
	v_max3_f32 v31, v28, v1, v17
	v_med3_f32 v32, v28, v17, v1
	v_minimum3_f32 v33, v17, v1, v28
	v_lshrrev_b32_e32 v34, v17, v28
	v_add_lshl_u32 v35, v17, v28, 3
	v_bfe_u32 v36, v28, 5, 8
	v_lshl_or_b32 v6, v28, 4, v17
	v_sub_f32_e32 v9, v28, v17
	v_add_f32_e32 v8, v28, v17
	v_sub_u32_e32 v14, v1, v17
	v_subrev_u32_e32 v15, s6, v28
	v_lshl_add_u32 v16, v1, 3, v17
	v_subrev_f32_e32 v18, s6, v28
	v_xnor_b32_e32 v19, v17, v1
	v_min_u32_e32 v20, v28, v17
	v_max_u32_e32 v21, v28, v17
	v_xad_u32 v22, v1, v28, v17
	v_bfi_b32 v23, v28, v17, v1
	v_alignbit_b32 v24, v28, v17, v1
	v_alignbyte_b32 v25, v28, v17, v1
	v_sad_u32 v26, v28, v17, v1
	v_med3_u32 v29, v28, 3, 60
	v_maximum3_f32 v45, v17, v1, v28
	global_store_dwordx4 v37, v[2:5], s[0:1]
	global_store_dwordx3 v37, v[34:36], s[0:1] offset:16
	v_or3_b32 v7, v7, v28, v1
	global_store_dwordx4 v37, v[10:13], s[0:1] offset:44
	v_add3_u32 v17, v27, v17, v1
	global_store_dword v37, v43, s[0:1] offset:76
	global_store_dwordx4 v37, v[18:21], s[0:1] offset:84
	global_store_dwordx4 v37, v[22:25], s[0:1] offset:100
	v_min3_u32 v27, v28, v1, v44
	v_max3_u32 v28, v1, v44, v28
	global_store_dwordx4 v37, v[30:33], s[0:1] offset:132
	global_store_dwordx4 v37, v[6:9], s[0:1] offset:28
	global_store_dwordx4 v37, v[14:17], s[0:1] offset:60
	global_store_dwordx4 v37, v[26:29], s[0:1] offset:116
	global_store_dword v37, v45, s[0:1] offset:148
	v_lshrrev_b32_e32 v1, 1, v0
	v_lshrrev_b32_e32 v2, 2, v0
	v_bitop3_b32 v1, v1, v2, v0 bitop3:0x48
	v_and_b32_e32 v0, 7, v0
	v_lshrrev_b32_e32 v3, 3, v38
	global_store_dword v37, v1, s[0:1] offset:80
	v_ashrrev_i32_e32 v0, v0, v40
	v_min_i32_e32 v1, v39, v41
	v_max_i32_e32 v2, v39, v41
	v_mul_u32_u24_e32 v3, v3, v38
	v_lshrrev_b32_e32 v4, 8, v38
	global_store_dwordx4 v37, v[0:3], s[0:1] offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v38, v4
	v_mul_i32_i24_e32 v1, v41, v38
	v_mul_hi_i32_i24_e32 v2, v42, v38
	v_bfe_i32 v3, v40, 12, 12
	global_store_dwordx4 v37, v[0:3], s[0:1] offset:168
	s_nop 1
	v_mad_u32_u24 v0, v38, v4, v40
	v_mad_i32_i24 v1, v41, v42, v40
	v_min3_i32 v2, v39, v42, v40
	v_max3_i32 v3, v41, v40, v42
	global_store_dwordx4 v37, v[0:3], s[0:1] offset:184
	s_nop 1
	v_med3_i32 v0, v39, 2, 9
	global_store_dword v37, v0, s[0:1] offset:200
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
		.amdhsa_next_free_vgpr 46
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 48
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

	.set bit_ops.num_vgpr, 46
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
	v_and_b32_e32 v35, 0x3ff, v31
	v_lshlrev_b32_e32 v6, 2, v35
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[8:9], v[2:3], 0, v[6:7]
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[6:7]
	global_load_dword v19, v[8:9], off
	global_load_dword v26, v[0:1], off
	global_load_dword v38, v[0:1], off offset:256
	v_mul_u32_u24_e32 v0, 0x100001, v35
	v_xor_b32_e32 v39, v0, v2
	v_lshlrev_b32_e32 v6, 8, v35
	v_lshlrev_b32_e32 v0, 8, v39
	v_bfe_i32 v48, v39, 0, 24
	v_lshl_add_u64 v[36:37], v[4:5], 0, v[6:7]
	v_add_u32_e32 v0, 0x12345600, v0
	v_xor_b32_e32 v49, 0xf0f0f0f0, v39
	v_xor_b32_e32 v50, 0x5a5a5a, v48
	v_ashrrev_i32_e32 v51, 8, v0
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v9, 0xf0, v19
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v4, v19, v26
	v_or_b32_e32 v5, v19, v26
	v_xor_b32_e32 v6, v19, v26
	v_lshlrev_b32_e32 v7, v19, v26
	v_mul_f32_e32 v12, v19, v26
	v_min_f32_e32 v13, v26, v19
	v_max_f32_e32 v14, v26, v19
	s_waitcnt vmcnt(0)
	v_add_u32_e32 v15, v38, v26
	v_lshrrev_b32_e32 v25, 2, v26
	v_and_or_b32 v52, v38, v26, v19
	v_lshrrev_b32_e32 v53, 1, v19
	v_min3_f32 v28, v26, v38, v19
	v_max3_f32 v29, v26, v38, v19
	v_med3_f32 v30, v26, v19, v38
	v_minimum3_f32 v31, v19, v38, v26
	v_lshrrev_b32_e32 v32, v19, v26
	v_add_lshl_u32 v33, v19, v26, 3
	v_bfe_u32 v34, v26, 5, 8
	v_lshl_or_b32 v8, v26, 4, v19
	v_sub_f32_e32 v11, v26, v19
	v_add_f32_e32 v10, v26, v19
	v_sub_u32_e32 v16, v38, v19
	v_sub_u32_e32 v17, v26, v2
	v_lshl_add_u32 v18, v38, 3, v19
	v_sub_f32_e32 v0, v26, v2
	v_xnor_b32_e32 v1, v19, v38
	v_min_u32_e32 v2, v26, v19
	v_max_u32_e32 v3, v26, v19
	v_xad_u32 v20, v38, v26, v19
	v_bfi_b32 v21, v26, v19, v38
	v_alignbit_b32 v22, v26, v19, v38
	v_alignbyte_b32 v23, v26, v19, v38
	v_sad_u32 v24, v26, v19, v38
	v_med3_u32 v27, v26, 3, 60
	v_maximum3_f32 v54, v19, v38, v26
	global_store_dwordx4 v[36:37], v[4:7], off
	global_store_dwordx3 v[36:37], v[32:34], off offset:16
	v_or3_b32 v9, v9, v26, v38
	global_store_dwordx4 v[36:37], v[12:15], off offset:44
	v_add3_u32 v19, v25, v19, v38
	global_store_dword v[36:37], v52, off offset:76
	global_store_dwordx4 v[36:37], v[0:3], off offset:84
	global_store_dwordx4 v[36:37], v[20:23], off offset:100
	v_min3_u32 v25, v26, v38, v53
	v_max3_u32 v26, v38, v53, v26
	global_store_dwordx4 v[36:37], v[28:31], off offset:132
	global_store_dwordx4 v[36:37], v[8:11], off offset:28
	global_store_dwordx4 v[36:37], v[16:19], off offset:60
	global_store_dwordx4 v[36:37], v[24:27], off offset:116
	global_store_dword v[36:37], v54, off offset:148
	v_lshrrev_b32_e32 v0, 1, v35
	v_lshrrev_b32_e32 v1, 2, v35
	v_bitop3_b32 v0, v0, v1, v35 bitop3:0x48
	global_store_dword v[36:37], v0, off offset:80
	v_and_b32_e32 v0, 7, v35
	v_lshrrev_b32_e32 v3, 3, v39
	v_ashrrev_i32_e32 v0, v0, v49
	v_min_i32_e32 v1, v48, v50
	v_max_i32_e32 v2, v48, v50
	v_mul_u32_u24_e32 v3, v3, v39
	v_lshrrev_b32_e32 v4, 8, v39
	global_store_dwordx4 v[36:37], v[0:3], off offset:152
	s_nop 1
	v_mul_hi_u32_u24_e32 v0, v39, v4
	v_mul_i32_i24_e32 v1, v50, v39
	v_mul_hi_i32_i24_e32 v2, v51, v39
	v_bfe_i32 v3, v49, 12, 12
	global_store_dwordx4 v[36:37], v[0:3], off offset:168
	s_nop 1
	v_mad_u32_u24 v0, v39, v4, v49
	v_mad_i32_i24 v1, v50, v51, v49
	v_min3_i32 v2, v48, v51, v49
	v_max3_i32 v3, v50, v49, v51
	global_store_dwordx4 v[36:37], v[0:3], off offset:184
	s_nop 1
	v_med3_i32 v0, v48, 2, 9
	global_store_dword v[36:37], v0, off offset:200
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_bit_ops, .Lfunc_end1-__clang_ocl_kern_imp_bit_ops

	.set __clang_ocl_kern_imp_bit_ops.num_vgpr, 55
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
	.set amdgpu.max_num_vgpr, 55
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
    .vgpr_count:     46
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
