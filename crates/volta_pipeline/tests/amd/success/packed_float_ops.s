	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	packed_float_ops
	.globl	packed_float_ops
	.p2align	8
	.type	packed_float_ops,@function
packed_float_ops:
	s_load_dwordx8 s[0:7], s[0:1], 0x0
	v_lshlrev_b32_e32 v1, 3, v0
	v_lshlrev_b32_e32 v10, 7, v0
	s_waitcnt lgkmcnt(0)
	global_load_dword v2, v1, s[0:1]
	global_load_dword v4, v1, s[2:3]
	global_load_dword v6, v1, s[4:5]
	;;#ASMSTART
	;;#ASMEND
	global_load_dword v3, v1, s[0:1] offset:4
	global_load_dword v5, v1, s[2:3] offset:4
	global_load_dword v7, v1, s[4:5] offset:4
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_pk_fma_f32 v[0:1], v[2:3], v[4:5], v[6:7]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:16
	;;#ASMSTART
	v_pk_add_f32 v[0:1], v[2:3], v[4:5]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7]
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], v[2:3], v[4:5]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:8
	;;#ASMSTART
	v_pk_add_f32 v[0:1], v[2:3], v[4:5] op_sel:[1,0] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:24
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], v[2:3], v[4:5] op_sel_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:32
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], v[2:3], v[4:5] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:40
	;;#ASMSTART
	v_pk_fma_f32 v[0:1], v[2:3], v[4:5], v[6:7] op_sel:[1,0,0] op_sel_hi:[0,1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:48
	;;#ASMSTART
	v_pk_add_f32 v[0:1], v[2:3], v[4:5] neg_lo:[1,0] neg_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:56
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], v[2:3], v[4:5] neg_lo:[0,1] neg_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:64
	;;#ASMSTART
	v_pk_fma_f32 v[0:1], v[2:3], v[4:5], v[6:7] neg_lo:[1,0,0] neg_hi:[0,1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:72
	;;#ASMSTART
	v_pk_fma_f32 v[0:1], v[2:3], v[4:5], v[6:7] neg_lo:[0,0,1] neg_hi:[1,1,1]
	;;#ASMEND
	v_readfirstlane_b32 s0, v2
	v_readfirstlane_b32 s1, v3
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:80
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], s[0:1], v[4:5]
	;;#ASMEND
	v_mov_b64_e32 v[8:9], v[2:3]
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:88
	;;#ASMSTART
	v_pk_add_f32 v[0:1], v[2:3], 2.0 op_sel_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:96
	;;#ASMSTART
	v_pk_fma_f32 v[0:1], v[2:3], 2.0, v[6:7]
	;;#ASMEND
	global_store_dwordx2 v10, v[0:1], s[6:7] offset:104
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[8:9], v[4:5] op_sel:[1,0] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v10, v[8:9], s[6:7] offset:112
	;;#ASMSTART
	v_pk_fma_f32 v[6:7], v[2:3], v[4:5], v[6:7] op_sel_hi:[1,1,0]
	;;#ASMEND
	global_store_dwordx2 v10, v[6:7], s[6:7] offset:120
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel packed_float_ops
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
		.amdhsa_next_free_vgpr 11
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 12
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
	.size	packed_float_ops, .Lfunc_end0-packed_float_ops

	.set packed_float_ops.num_vgpr, 11
	.set packed_float_ops.num_agpr, 0
	.set packed_float_ops.numbered_sgpr, 8
	.set packed_float_ops.private_seg_size, 0
	.set packed_float_ops.uses_vcc, 0
	.set packed_float_ops.uses_flat_scratch, 0
	.set packed_float_ops.has_dyn_sized_stack, 0
	.set packed_float_ops.has_recursion, 0
	.set packed_float_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_packed_float_ops
	.globl	__clang_ocl_kern_imp_packed_float_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_packed_float_ops,@function
__clang_ocl_kern_imp_packed_float_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v16, 0x3ff, v31
	v_lshlrev_b32_e32 v8, 3, v16
	v_mov_b32_e32 v9, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[8:9]
	v_lshl_add_u64 v[2:3], v[2:3], 0, v[8:9]
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[8:9]
	global_load_dword v10, v[0:1], off
	global_load_dword v12, v[2:3], off
	global_load_dword v14, v[4:5], off
	;;#ASMSTART
	;;#ASMEND
	global_load_dword v11, v[0:1], off offset:4
	global_load_dword v13, v[2:3], off offset:4
	global_load_dword v15, v[4:5], off offset:4
	v_lshlrev_b32_e32 v8, 7, v16
	v_lshl_add_u64 v[0:1], v[6:7], 0, v[8:9]
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_pk_fma_f32 v[2:3], v[10:11], v[12:13], v[14:15]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:16
	;;#ASMSTART
	v_pk_add_f32 v[2:3], v[10:11], v[12:13]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[10:11], v[12:13]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:8
	;;#ASMSTART
	v_pk_add_f32 v[2:3], v[10:11], v[12:13] op_sel:[1,0] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:24
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[10:11], v[12:13] op_sel_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:32
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[10:11], v[12:13] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:40
	;;#ASMSTART
	v_pk_fma_f32 v[2:3], v[10:11], v[12:13], v[14:15] op_sel:[1,0,0] op_sel_hi:[0,1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:48
	;;#ASMSTART
	v_pk_add_f32 v[2:3], v[10:11], v[12:13] neg_lo:[1,0] neg_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:56
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[10:11], v[12:13] neg_lo:[0,1] neg_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:64
	;;#ASMSTART
	v_pk_fma_f32 v[2:3], v[10:11], v[12:13], v[14:15] neg_lo:[1,0,0] neg_hi:[0,1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:72
	;;#ASMSTART
	v_pk_fma_f32 v[2:3], v[10:11], v[12:13], v[14:15] neg_lo:[0,0,1] neg_hi:[1,1,1]
	;;#ASMEND
	v_readfirstlane_b32 s0, v10
	v_readfirstlane_b32 s1, v11
	global_store_dwordx2 v[0:1], v[2:3], off offset:80
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], s[0:1], v[12:13]
	;;#ASMEND
	v_mov_b64_e32 v[4:5], v[10:11]
	global_store_dwordx2 v[0:1], v[2:3], off offset:88
	;;#ASMSTART
	v_pk_add_f32 v[2:3], v[10:11], 2.0 op_sel_hi:[1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:96
	;;#ASMSTART
	v_pk_fma_f32 v[2:3], v[10:11], 2.0, v[14:15]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:104
	;;#ASMSTART
	v_pk_mul_f32 v[4:5], v[4:5], v[12:13] op_sel:[1,0] op_sel_hi:[0,1]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[4:5], off offset:112
	;;#ASMSTART
	v_pk_fma_f32 v[14:15], v[10:11], v[12:13], v[14:15] op_sel_hi:[1,1,0]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[14:15], off offset:120
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_packed_float_ops, .Lfunc_end1-__clang_ocl_kern_imp_packed_float_ops

	.set __clang_ocl_kern_imp_packed_float_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_packed_float_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_packed_float_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_packed_float_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_packed_float_ops.uses_vcc, 0
	.set __clang_ocl_kern_imp_packed_float_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_packed_float_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_packed_float_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_packed_float_ops.has_indirect_call, 0
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
        .is_const:       true
        .offset:         16
        .size:           8
        .type_name:      'float*'
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
    .name:           packed_float_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         packed_float_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     11
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
