	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	dpp_ops
	.globl	dpp_ops
	.p2align	8
	.type	dpp_ops,@function
dpp_ops:
	s_load_dwordx2 s[0:1], s[0:1], 0x0
	v_mov_b32_e32 v3, 7
	v_lshlrev_b32_e32 v1, 7, v0
	v_add_u32_e32 v4, 0x64, v0
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 quad_perm:[2,0,3,1] row_mask:0xf bank_mask:0xf
	;;#ASMEND
	s_waitcnt lgkmcnt(0)
	global_store_dword v1, v3, s[0:1]
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_shl:3 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:4
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_shr:5 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:8
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_ror:7 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:12
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 wave_shl:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:16
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 wave_rol:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:20
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 wave_shr:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:24
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 wave_ror:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:28
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_mirror row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:32
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_half_mirror row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:36
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_bcast:15 row_mask:0xa bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:40
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_bcast:31 row_mask:0xc bank_mask:0xf
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:44
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_shr:5 row_mask:0xf bank_mask:0xf bound_ctrl:1
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:48
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	v_mov_b32_dpp v3, v4 row_shl:1 row_mask:0x5 bank_mask:0xa
	;;#ASMEND
	global_store_dword v1, v3, s[0:1] offset:52
	v_mul_u32_u24_e32 v3, 0x3e8, v0
	;;#ASMSTART
	v_add_u32_dpp v3, v4, v3 row_ror:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	v_mov_b32_e32 v2, 7
	global_store_dword v1, v3, s[0:1] offset:56
	v_mov_b32_e32 v3, 7
	v_and_b32_e32 v0, 1, v0
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[2:3], 0, v0
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	s_mov_b64 s[4:5], exec
	s_mov_b64 exec, s[2:3]
	v_mov_b32_dpp v2, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_mov_b32_dpp v3, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mov_b64 exec, s[4:5]
	;;#ASMEND
	global_store_dwordx2 v1, v[2:3], s[0:1] offset:60
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel dpp_ops
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 8
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
		.amdhsa_next_free_vgpr 5
		.amdhsa_next_free_sgpr 6
		.amdhsa_accum_offset 8
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
	.size	dpp_ops, .Lfunc_end0-dpp_ops

	.set dpp_ops.num_vgpr, 5
	.set dpp_ops.num_agpr, 0
	.set dpp_ops.numbered_sgpr, 6
	.set dpp_ops.private_seg_size, 0
	.set dpp_ops.uses_vcc, 0
	.set dpp_ops.uses_flat_scratch, 0
	.set dpp_ops.has_dyn_sized_stack, 0
	.set dpp_ops.has_recursion, 0
	.set dpp_ops.has_indirect_call, 0
	.protected	__clang_ocl_kern_imp_dpp_ops
	.globl	__clang_ocl_kern_imp_dpp_ops
	.p2align	2
	.type	__clang_ocl_kern_imp_dpp_ops,@function
__clang_ocl_kern_imp_dpp_ops:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	v_and_b32_e32 v3, 0x3ff, v31
	v_lshlrev_b32_e32 v4, 7, v3
	v_mov_b32_e32 v5, 0
	v_lshl_add_u64 v[0:1], v[0:1], 0, v[4:5]
	v_mov_b32_e32 v5, 7
	v_add_u32_e32 v4, 0x64, v3
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 quad_perm:[2,0,3,1] row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_shl:3 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:4
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_shr:5 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:8
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_ror:7 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:12
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 wave_shl:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:16
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 wave_rol:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:20
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 wave_shr:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:24
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 wave_ror:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:28
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_mirror row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:32
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_half_mirror row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:36
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_bcast:15 row_mask:0xa bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:40
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_bcast:31 row_mask:0xc bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:44
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_shr:5 row_mask:0xf bank_mask:0xf bound_ctrl:1
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:48
	v_mov_b32_e32 v5, 7
	;;#ASMSTART
	v_mov_b32_dpp v5, v4 row_shl:1 row_mask:0x5 bank_mask:0xa
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:52
	v_mul_u32_u24_e32 v5, 0x3e8, v3
	v_and_b32_e32 v3, 1, v3
	v_mov_b32_e32 v2, 7
	;;#ASMSTART
	v_add_u32_dpp v5, v4, v5 row_ror:1 row_mask:0xf bank_mask:0xf
	;;#ASMEND
	global_store_dword v[0:1], v5, off offset:56
	;;#ASMSTART
	v_cmp_ne_u32_e64 s[0:1], 0, v3
	;;#ASMEND
	v_mov_b32_e32 v3, 7
	;;#ASMSTART
	s_mov_b64 s[2:3], exec
	s_mov_b64 exec, s[0:1]
	v_mov_b32_dpp v2, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	v_mov_b32_dpp v3, v4 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_mov_b64 exec, s[2:3]
	;;#ASMEND
	global_store_dwordx2 v[0:1], v[2:3], off offset:60
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end1:
	.size	__clang_ocl_kern_imp_dpp_ops, .Lfunc_end1-__clang_ocl_kern_imp_dpp_ops

	.set __clang_ocl_kern_imp_dpp_ops.num_vgpr, 32
	.set __clang_ocl_kern_imp_dpp_ops.num_agpr, 0
	.set __clang_ocl_kern_imp_dpp_ops.numbered_sgpr, 32
	.set __clang_ocl_kern_imp_dpp_ops.private_seg_size, 0
	.set __clang_ocl_kern_imp_dpp_ops.uses_vcc, 0
	.set __clang_ocl_kern_imp_dpp_ops.uses_flat_scratch, 0
	.set __clang_ocl_kern_imp_dpp_ops.has_dyn_sized_stack, 0
	.set __clang_ocl_kern_imp_dpp_ops.has_recursion, 0
	.set __clang_ocl_kern_imp_dpp_ops.has_indirect_call, 0
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 8
    .language:       OpenCL C
    .language_version:
      - 1
      - 2
    .max_flat_workgroup_size: 256
    .name:           dpp_ops
    .private_segment_fixed_size: 0
    .sgpr_count:     12
    .sgpr_spill_count: 0
    .symbol:         dpp_ops.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
