	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_i4_to_f8x4
	.globl	ck_i4_to_f8x4
	.p2align	8
	.type	ck_i4_to_f8x4,@function
ck_i4_to_f8x4:
	s_load_dword s8, s[0:1], 0x0
	v_mov_b32_e32 v1, 0xf000f
	v_mov_b32_e32 v2, 0xf000f0
	s_load_dwordx8 s[0:7], s[0:1], 0x8
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v3, s8
	;;#ASMSTART
	v_and_b32 v1, v3, v1
	;;#ASMEND
	;;#ASMSTART
	v_and_b32 v2, v3, v2
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_cvt_off_f32_i4 v3, v1
	;;#ASMEND
	v_ashrrev_i32_e32 v1, 16, v1
	;;#ASMSTART
	v_cvt_off_f32_i4 v1, v1
	;;#ASMEND
	;;#ASMSTART
	v_cvt_off_f32_i4 v4, v2
	;;#ASMEND
	v_ashrrev_i32_e32 v2, 16, v2
	;;#ASMSTART
	v_cvt_off_f32_i4 v2, v2
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_cvt_pk_fp8_f32 v1, v3, v1
v_cvt_pk_fp8_f32 v1, v4, v2, op_sel:[0, 0, 1]

	;;#ASMEND
	s_nop 0
	v_cvt_f32_ubyte0_e32 v2, v1
	global_store_dword v0, v2, s[0:1]
	v_cvt_f32_ubyte1_e32 v2, v1
	global_store_dword v0, v2, s[2:3]
	v_cvt_f32_ubyte2_e32 v2, v1
	v_cvt_f32_ubyte3_e32 v1, v1
	global_store_dword v0, v2, s[4:5]
	global_store_dword v0, v1, s[6:7]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_i4_to_f8x4
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
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
		.amdhsa_next_free_sgpr 9
		.amdhsa_accum_offset 8
		.amdhsa_reserve_vcc 0
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
	.size	ck_i4_to_f8x4, .Lfunc_end0-ck_i4_to_f8x4

	.set ck_i4_to_f8x4.num_vgpr, 5
	.set ck_i4_to_f8x4.num_agpr, 0
	.set ck_i4_to_f8x4.numbered_sgpr, 9
	.set ck_i4_to_f8x4.private_seg_size, 0
	.set ck_i4_to_f8x4.uses_vcc, 0
	.set ck_i4_to_f8x4.uses_flat_scratch, 0
	.set ck_i4_to_f8x4.has_dyn_sized_stack, 0
	.set ck_i4_to_f8x4.has_recursion, 0
	.set ck_i4_to_f8x4.has_indirect_call, 0
	.protected	ck_i4_to_f8x4_fixed
	.globl	ck_i4_to_f8x4_fixed
	.p2align	8
	.type	ck_i4_to_f8x4_fixed,@function
ck_i4_to_f8x4_fixed:
	s_load_dword s2, s[0:1], 0x0
	v_mov_b32_e32 v4, 0
	v_lshlrev_b32_e32 v0, 2, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s3, s2, 0xf000f
	s_lshr_b32 s4, s2, 4
	s_bfe_u32 s2, s2, 0x40010
	v_mov_b32_e32 v1, s3
	v_mov_b32_e32 v2, s2
	;;#ASMSTART
	v_cvt_off_f32_i4 v1, v1
	;;#ASMEND
	;;#ASMSTART
	v_cvt_off_f32_i4 v2, v2
	;;#ASMEND
	s_and_b32 s5, s4, 0xf000f
	v_cvt_pk_fp8_f32 v4, v1, v2
	s_bfe_u32 s2, s4, 0x40010
	v_mov_b32_e32 v3, s5
	v_mov_b32_e32 v1, s2
	;;#ASMSTART
	v_cvt_off_f32_i4 v3, v3
	;;#ASMEND
	;;#ASMSTART
	v_cvt_off_f32_i4 v1, v1
	;;#ASMEND
	s_load_dwordx8 s[0:7], s[0:1], 0x8
	v_cvt_pk_fp8_f32 v4, v3, v1 op_sel:[0,0,1]
	s_nop 0
	v_cvt_f32_ubyte0_e32 v1, v4
	s_waitcnt lgkmcnt(0)
	global_store_dword v0, v1, s[0:1]
	v_cvt_f32_ubyte1_e32 v1, v4
	global_store_dword v0, v1, s[2:3]
	v_cvt_f32_ubyte2_e32 v1, v4
	global_store_dword v0, v1, s[4:5]
	v_cvt_f32_ubyte3_e32 v1, v4
	global_store_dword v0, v1, s[6:7]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_i4_to_f8x4_fixed
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
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
		.amdhsa_next_free_sgpr 8
		.amdhsa_accum_offset 8
		.amdhsa_reserve_vcc 0
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
.Lfunc_end1:
	.size	ck_i4_to_f8x4_fixed, .Lfunc_end1-ck_i4_to_f8x4_fixed

	.set ck_i4_to_f8x4_fixed.num_vgpr, 5
	.set ck_i4_to_f8x4_fixed.num_agpr, 0
	.set ck_i4_to_f8x4_fixed.numbered_sgpr, 8
	.set ck_i4_to_f8x4_fixed.private_seg_size, 0
	.set ck_i4_to_f8x4_fixed.uses_vcc, 0
	.set ck_i4_to_f8x4_fixed.uses_flat_scratch, 0
	.set ck_i4_to_f8x4_fixed.has_dyn_sized_stack, 0
	.set ck_i4_to_f8x4_fixed.has_recursion, 0
	.set ck_i4_to_f8x4_fixed.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_7aade72d0112e76c,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_7aade72d0112e76c
__hip_cuid_7aade72d0112e76c:
	.byte	0
	.size	__hip_cuid_7aade72d0112e76c, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_7aade72d0112e76c
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .max_flat_workgroup_size: 1024
    .name:           ck_i4_to_f8x4
    .private_segment_fixed_size: 0
    .sgpr_count:     15
    .sgpr_spill_count: 0
    .symbol:         ck_i4_to_f8x4.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     5
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           4
        .value_kind:     by_value
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .max_flat_workgroup_size: 1024
    .name:           ck_i4_to_f8x4_fixed
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         ck_i4_to_f8x4_fixed.kd
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
