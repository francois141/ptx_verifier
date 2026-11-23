; Aiter 183a6ce66ebb csrc/kernels/activation_kernels.cu:33 (act_and_mul_kernel), dispatch :1150, compiled for gfx950 by
; external/amd/aiter/build.py (case silu_and_mul).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if
	.globl	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if
	.p2align	8
	.type	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if,@function
_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	v_lshlrev_b32_e32 v0, 1, v0
	v_cmp_gt_i32_e32 vcc, s6, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_3
	s_ashr_i32 s7, s6, 31
	s_mul_hi_u32 s0, s6, s12
	s_mul_i32 s1, s7, s12
	s_add_i32 s1, s0, s1
	s_mul_i32 s0, s6, s12
	s_lshl_b64 s[8:9], s[0:1], 1
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s12, s4, s0
	s_addc_u32 s4, s5, s1
	s_lshl_b64 s[0:1], s[6:7], 1
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s4, s1
	s_add_i32 s5, s6, 1
	s_lshr_b32 s10, s5, 31
	s_add_i32 s5, s5, s10
	s_lshl_b32 s5, s5, 1
	s_and_b32 s14, s5, -4
	s_and_b32 s13, s4, 0xffff
	s_mov_b32 s15, 0x20000
	s_and_b32 s1, s1, 0xffff
	s_add_u32 s8, s2, s8
	s_addc_u32 s2, s3, s9
	s_and_b32 s9, s2, 0xffff
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], 0
	s_mov_b32 s17, 0
	s_mov_b32 s2, s14
	s_mov_b32 s3, s15
	s_mov_b32 s18, 0x3fb8aa3b
	s_lshl_b32 s10, s11, 1
	s_and_b32 s16, s10, 0xfffe
	s_mov_b32 s10, s14
	s_mov_b32 s11, s15
.LBB0_2:
	v_lshlrev_b32_e32 v8, 1, v0
	buffer_load_dword v2, v8, s[12:15], 0 offen sc0 nt
	buffer_load_dword v6, v8, s[0:3], 0 offen sc0 nt
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[16:17]
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v3, 0xffff0000, v2
	v_lshlrev_b32_e32 v2, 16, v2
	v_mul_f32_e64 v4, -v3, s18
	v_mul_f32_e64 v5, -v2, s18
	v_exp_f32_e32 v4, v4
	v_exp_f32_e32 v5, v5
	v_cmp_le_i64_e32 vcc, s[6:7], v[0:1]
	v_add_f32_e32 v4, 1.0, v4
	v_add_f32_e32 v7, 1.0, v5
	v_rcp_f32_e32 v5, v4
	v_rcp_f32_e32 v4, v7
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v6
	v_lshlrev_b32_e32 v6, 16, v6
	v_pk_mul_f32 v[2:3], v[4:5], v[2:3]
	s_nop 0
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[2:3], v[6:7]
	;;#ASMEND
	s_nop 0
	v_cvt_pk_bf16_f32 v2, v2, v3
	buffer_store_dword v2, v8, s[8:11], 0 offen
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB0_2
.LBB0_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 9
		.amdhsa_next_free_sgpr 19
		.amdhsa_accum_offset 12
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
	.size	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if, .Lfunc_end0-_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if

	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.num_vgpr, 9
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.num_agpr, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.numbered_sgpr, 19
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.private_seg_size, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.uses_vcc, 1
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.uses_flat_scratch, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.has_dyn_sized_stack, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.has_recursion, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.has_indirect_call, 0
	.protected	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if
	.globl	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if
	.p2align	8
	.type	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if,@function
_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	v_lshlrev_b32_e32 v0, 2, v0
	v_cmp_gt_i32_e32 vcc, s6, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_3
	s_ashr_i32 s7, s6, 31
	s_mul_hi_u32 s0, s6, s12
	s_mul_i32 s1, s7, s12
	s_add_i32 s1, s0, s1
	s_mul_i32 s0, s6, s12
	s_lshl_b64 s[8:9], s[0:1], 1
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s12, s4, s0
	s_addc_u32 s4, s5, s1
	s_lshl_b64 s[0:1], s[6:7], 1
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s4, s1
	s_add_i32 s5, s6, 1
	s_lshr_b32 s10, s5, 31
	s_add_i32 s5, s5, s10
	s_lshl_b32 s5, s5, 1
	s_and_b32 s14, s5, -4
	s_and_b32 s13, s4, 0xffff
	s_mov_b32 s15, 0x20000
	s_and_b32 s1, s1, 0xffff
	s_add_u32 s8, s2, s8
	s_addc_u32 s2, s3, s9
	s_and_b32 s9, s2, 0xffff
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], 0
	s_mov_b32 s17, 0
	s_mov_b32 s2, s14
	s_mov_b32 s3, s15
	s_mov_b32 s18, 0x3fb8aa3b
	s_lshl_b32 s10, s11, 2
	s_and_b32 s16, s10, 0xfffc
	s_mov_b32 s10, s14
	s_mov_b32 s11, s15
.LBB1_2:
	v_lshlrev_b32_e32 v14, 1, v0
	buffer_load_dwordx2 v[2:3], v14, s[12:15], 0 offen sc0 nt
	buffer_load_dwordx2 v[4:5], v14, s[0:3], 0 offen sc0 nt
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[16:17]
	v_cmp_le_i64_e32 vcc, s[6:7], v[0:1]
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v7, 0xffff0000, v4
	v_lshlrev_b32_e32 v6, 16, v4
	v_and_b32_e32 v9, 0xffff0000, v2
	v_lshlrev_b32_e32 v8, 16, v2
	v_and_b32_e32 v11, 0xffff0000, v5
	v_lshlrev_b32_e32 v10, 16, v5
	v_and_b32_e32 v5, 0xffff0000, v3
	v_lshlrev_b32_e32 v4, 16, v3
	v_mul_f32_e64 v2, -v8, s18
	v_mul_f32_e64 v3, -v9, s18
	v_mul_f32_e64 v12, -v4, s18
	v_mul_f32_e64 v13, -v5, s18
	v_exp_f32_e32 v2, v2
	v_exp_f32_e32 v3, v3
	v_exp_f32_e32 v12, v12
	v_exp_f32_e32 v13, v13
	v_add_f32_e32 v2, 1.0, v2
	v_add_f32_e32 v3, 1.0, v3
	v_add_f32_e32 v12, 1.0, v12
	v_add_f32_e32 v13, 1.0, v13
	v_rcp_f32_e32 v2, v2
	v_rcp_f32_e32 v3, v3
	v_rcp_f32_e32 v12, v12
	v_rcp_f32_e32 v13, v13
	v_pk_mul_f32 v[2:3], v[2:3], v[8:9]
	v_pk_mul_f32 v[4:5], v[12:13], v[4:5]
	;;#ASMSTART
	v_pk_mul_f32 v[2:3], v[2:3], v[6:7]
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_pk_mul_f32 v[4:5], v[4:5], v[10:11]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v2, v3
	v_cvt_pk_bf16_f32 v3, v4, v5
	buffer_store_dwordx2 v[2:3], v14, s[8:11], 0 offen
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB1_2
.LBB1_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 15
		.amdhsa_next_free_sgpr 19
		.amdhsa_accum_offset 16
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
.Lfunc_end1:
	.size	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if, .Lfunc_end1-_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if

	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.num_vgpr, 15
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.num_agpr, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.numbered_sgpr, 19
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.private_seg_size, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.uses_vcc, 1
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.uses_flat_scratch, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.has_dyn_sized_stack, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.has_recursion, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.has_indirect_call, 0
	.protected	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if
	.globl	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if
	.p2align	8
	.type	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if,@function
_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB2_0
	.p2align	8
.LBB2_0:
	v_lshlrev_b32_e32 v0, 3, v0
	v_cmp_gt_i32_e32 vcc, s6, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB2_3
	s_ashr_i32 s7, s6, 31
	s_mul_hi_u32 s0, s6, s12
	s_mul_i32 s1, s7, s12
	s_add_i32 s1, s0, s1
	s_mul_i32 s0, s6, s12
	s_lshl_b64 s[8:9], s[0:1], 1
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s12, s4, s0
	s_addc_u32 s4, s5, s1
	s_lshl_b64 s[0:1], s[6:7], 1
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s4, s1
	s_add_i32 s5, s6, 1
	s_lshr_b32 s10, s5, 31
	s_add_i32 s5, s5, s10
	s_lshl_b32 s5, s5, 1
	s_and_b32 s14, s5, -4
	s_and_b32 s13, s4, 0xffff
	s_mov_b32 s15, 0x20000
	s_and_b32 s1, s1, 0xffff
	s_add_u32 s8, s2, s8
	s_addc_u32 s2, s3, s9
	s_and_b32 s9, s2, 0xffff
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], 0
	s_mov_b32 s17, 0
	s_mov_b32 s2, s14
	s_mov_b32 s3, s15
	s_mov_b32 s18, 0x3fb8aa3b
	s_lshl_b32 s10, s11, 3
	s_and_b32 s16, s10, 0xfff8
	s_mov_b32 s10, s14
	s_mov_b32 s11, s15
.LBB2_2:
	v_lshlrev_b32_e32 v26, 1, v0
	buffer_load_dwordx4 v[2:5], v26, s[12:15], 0 offen sc0 nt
	buffer_load_dwordx4 v[6:9], v26, s[0:3], 0 offen sc0 nt
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[16:17]
	v_cmp_le_i64_e32 vcc, s[6:7], v[0:1]
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v11, 0xffff0000, v6
	v_lshlrev_b32_e32 v10, 16, v6
	v_and_b32_e32 v13, 0xffff0000, v2
	v_lshlrev_b32_e32 v12, 16, v2
	v_and_b32_e32 v15, 0xffff0000, v7
	v_lshlrev_b32_e32 v14, 16, v7
	v_and_b32_e32 v7, 0xffff0000, v3
	v_lshlrev_b32_e32 v6, 16, v3
	v_and_b32_e32 v3, 0xffff0000, v8
	v_lshlrev_b32_e32 v2, 16, v8
	v_and_b32_e32 v17, 0xffff0000, v4
	v_lshlrev_b32_e32 v16, 16, v4
	v_and_b32_e32 v19, 0xffff0000, v9
	v_lshlrev_b32_e32 v18, 16, v9
	v_and_b32_e32 v9, 0xffff0000, v5
	v_lshlrev_b32_e32 v8, 16, v5
	v_mul_f32_e64 v4, -v12, s18
	v_mul_f32_e64 v5, -v13, s18
	v_mul_f32_e64 v20, -v6, s18
	v_mul_f32_e64 v21, -v7, s18
	v_mul_f32_e64 v22, -v16, s18
	v_mul_f32_e64 v23, -v17, s18
	v_mul_f32_e64 v24, -v8, s18
	v_mul_f32_e64 v25, -v9, s18
	v_exp_f32_e32 v4, v4
	v_exp_f32_e32 v5, v5
	v_exp_f32_e32 v20, v20
	v_exp_f32_e32 v21, v21
	v_exp_f32_e32 v22, v22
	v_exp_f32_e32 v23, v23
	v_exp_f32_e32 v24, v24
	v_exp_f32_e32 v25, v25
	v_add_f32_e32 v4, 1.0, v4
	v_add_f32_e32 v5, 1.0, v5
	v_add_f32_e32 v20, 1.0, v20
	v_add_f32_e32 v21, 1.0, v21
	v_add_f32_e32 v22, 1.0, v22
	v_add_f32_e32 v23, 1.0, v23
	v_add_f32_e32 v24, 1.0, v24
	v_add_f32_e32 v25, 1.0, v25
	v_rcp_f32_e32 v4, v4
	v_rcp_f32_e32 v5, v5
	v_rcp_f32_e32 v20, v20
	v_rcp_f32_e32 v21, v21
	v_rcp_f32_e32 v22, v22
	v_rcp_f32_e32 v23, v23
	v_rcp_f32_e32 v24, v24
	v_rcp_f32_e32 v25, v25
	v_pk_mul_f32 v[4:5], v[4:5], v[12:13]
	v_pk_mul_f32 v[6:7], v[20:21], v[6:7]
	v_pk_mul_f32 v[12:13], v[22:23], v[16:17]
	v_pk_mul_f32 v[8:9], v[24:25], v[8:9]
	;;#ASMSTART
	v_pk_mul_f32 v[4:5], v[4:5], v[10:11]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[6:7], v[6:7], v[14:15]
	;;#ASMEND
	;;#ASMSTART
	v_pk_mul_f32 v[10:11], v[12:13], v[2:3]
	;;#ASMEND
	s_nop 0
	;;#ASMSTART
	v_pk_mul_f32 v[8:9], v[8:9], v[18:19]
	;;#ASMEND
	v_cvt_pk_bf16_f32 v2, v4, v5
	v_cvt_pk_bf16_f32 v3, v6, v7
	v_cvt_pk_bf16_f32 v4, v10, v11
	v_cvt_pk_bf16_f32 v5, v8, v9
	buffer_store_dwordx4 v[2:5], v26, s[8:11], 0 offen
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB2_2
.LBB2_3:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 27
		.amdhsa_next_free_sgpr 19
		.amdhsa_accum_offset 28
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
.Lfunc_end2:
	.size	_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if, .Lfunc_end2-_ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if

	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.num_vgpr, 27
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.num_agpr, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.numbered_sgpr, 19
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.private_seg_size, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.uses_vcc, 1
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.uses_flat_scratch, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.has_dyn_sized_stack, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.has_recursion, 0
	.set _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.has_indirect_call, 0
	.section	.text._ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix,"axG",@progbits,_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix,comdat
	.protected	_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix
	.globl	_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix
	.p2align	8
	.type	_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix,@function
_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx2 s[12:13], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB3_0
	.p2align	8
.LBB3_0:
	s_mov_b32 s15, 0
	s_lshl_b64 s[16:17], s[14:15], 2
	s_add_u32 s6, s6, s16
	s_addc_u32 s7, s7, s17
	s_load_dword s6, s[6:7], 0x0
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s7, s6, 31
	s_mov_b64 s[20:21], -1
	v_cmp_gt_i64_e64 s[22:23], s[6:7], -1
	s_ashr_i32 s11, s10, 31
	s_add_i32 s15, s10, 1
	s_lshr_b32 s16, s15, 31
	s_add_i32 s15, s15, s16
	s_lshl_b32 s15, s15, 1
	s_and_b32 s18, s15, -4
	s_mul_hi_u32 s15, s10, s14
	s_mul_i32 s16, s11, s14
	s_add_i32 s17, s15, s16
	s_mul_i32 s16, s10, s14
	s_lshl_b64 s[16:17], s[16:17], 1
	s_add_u32 s16, s2, s16
	s_addc_u32 s2, s3, s17
	s_and_b32 s17, s2, 0xffff
	s_mov_b32 s19, 0x20000
	v_mov_b64_e32 v[2:3], s[6:7]
	v_cmp_gt_i64_e32 vcc, s[12:13], v[2:3]
	s_and_b64 s[2:3], s[22:23], vcc
	s_and_b64 vcc, exec, s[2:3]
	v_lshlrev_b32_e32 v2, 1, v0
	s_cbranch_vccnz .LBB3_5
	v_cmp_gt_i32_e32 vcc, s10, v2
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB3_4
	s_load_dword s7, s[0:1], 0x3c
	s_mov_b32 s13, 0
	v_mov_b32_e32 v3, 0
	v_lshlrev_b32_e32 v4, 2, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s7, s7, 0xffff
	s_lshl_b32 s12, s7, 1
	s_lshl_b32 s7, s7, 2
	s_and_b32 s12, s12, 0xffe
	s_mov_b64 s[20:21], 0
	v_mov_b64_e32 v[0:1], v[2:3]
.LBB3_3:
	buffer_store_dword v3, v4, s[16:19], 0 offen
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[12:13]
	v_cmp_le_i64_e32 vcc, s[10:11], v[0:1]
	s_or_b64 s[20:21], vcc, s[20:21]
	v_add_u32_e32 v4, s7, v4
	s_andn2_b64 exec, exec, s[20:21]
	s_cbranch_execnz .LBB3_3
.LBB3_4:
	s_or_b64 exec, exec, s[2:3]
	s_mov_b64 s[20:21], 0
.LBB3_5:
	s_andn2_b64 vcc, exec, s[20:21]
	s_cbranch_vccnz .LBB3_9
	v_cmp_gt_i32_e32 vcc, s10, v2
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB3_9
	s_mul_hi_i32 s3, s10, s6
	s_mul_i32 s2, s10, s6
	s_lshl_b64 s[2:3], s[2:3], 3
	s_add_u32 s20, s8, s2
	s_addc_u32 s6, s9, s3
	s_lshl_b64 s[2:3], s[10:11], 2
	s_add_u32 s12, s20, s2
	s_addc_u32 s2, s6, s3
	s_lshl_b32 s22, s10, 2
	s_and_b32 s21, s6, 0xffff
	s_mov_b32 s23, 0x20000
	s_and_b32 s13, s2, 0xffff
	s_mul_i32 s2, s14, s11
	s_mul_hi_u32 s3, s14, s10
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s14, s10
	s_lshl_b64 s[2:3], s[2:3], 2
	s_add_u32 s4, s4, s2
	s_addc_u32 s5, s5, s3
	s_lshl_b64 s[2:3], s[10:11], 1
	s_add_u32 s24, s4, s2
	s_addc_u32 s2, s5, s3
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s18
	s_mov_b32 s7, s23
	s_and_b32 s25, s2, 0xffff
	v_mov_b32_e32 v3, 0
	s_add_u32 s0, s0, 48
	s_addc_u32 s1, s1, 0
	s_mov_b64 s[2:3], 0
	s_mov_b32 s9, 0
	s_mov_b32 s28, 0x3fb8aa3b
	s_mov_b32 s26, s18
	s_mov_b32 s27, s23
	s_mov_b32 s14, s22
	s_mov_b32 s15, s23
.LBB3_8:
	v_lshlrev_b32_e32 v10, 1, v2
	v_lshlrev_b32_e32 v4, 2, v2
	buffer_load_dwordx2 v[0:1], v4, s[20:23], 0 offen
	buffer_load_dword v6, v10, s[4:7], 0 offen
	buffer_load_dword v8, v10, s[24:27], 0 offen
	buffer_load_dwordx2 v[4:5], v4, s[12:15], 0 offen
	s_waitcnt vmcnt(2)
	v_and_b32_e32 v7, 0xffff0000, v6
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v9, 0xffff0000, v8
	v_lshlrev_b32_e32 v6, 16, v6
	v_pk_add_f32 v[0:1], v[0:1], v[6:7]
	s_nop 0
	v_mul_f32_e64 v6, -v1, s28
	v_mul_f32_e64 v7, -v0, s28
	v_exp_f32_e32 v6, v6
	v_exp_f32_e32 v7, v7
	v_add_f32_e32 v6, 1.0, v6
	v_add_f32_e32 v11, 1.0, v7
	v_rcp_f32_e32 v7, v6
	v_rcp_f32_e32 v6, v11
	v_lshlrev_b32_e32 v8, 16, v8
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[4:5], v[4:5], v[8:9]
	v_pk_mul_f32 v[0:1], v[6:7], v[0:1]
	s_nop 0
	;;#ASMSTART
	v_pk_mul_f32 v[0:1], v[0:1], v[4:5]
	;;#ASMEND
	s_load_dword s8, s[0:1], 0xc
	v_cvt_pk_bf16_f32 v0, v0, v1
	s_waitcnt lgkmcnt(0)
	s_lshl_b32 s8, s8, 1
	s_and_b32 s8, s8, 0xfffe
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[8:9]
	v_cmp_le_i64_e32 vcc, s[10:11], v[2:3]
	s_or_b64 s[2:3], vcc, s[2:3]
	buffer_store_dword v0, v10, s[16:19], 0 offen
	s_andn2_b64 exec, exec, s[2:3]
	s_cbranch_execnz .LBB3_8
.LBB3_9:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
		.amdhsa_user_sgpr_count 14
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 12
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 12
		.amdhsa_next_free_sgpr 29
		.amdhsa_accum_offset 12
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
	.section	.text._ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix,"axG",@progbits,_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix,comdat
.Lfunc_end3:
	.size	_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix, .Lfunc_end3-_ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix

	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.num_vgpr, 12
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.num_agpr, 0
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.numbered_sgpr, 29
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.private_seg_size, 0
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.uses_vcc, 1
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.uses_flat_scratch, 0
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.has_dyn_sized_stack, 0
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.has_recursion, 0
	.set _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.has_indirect_call, 0
	.text
	.protected	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x
	.globl	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x
	.p2align	8
	.type	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x,@function
_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB4_0
	.p2align	8
.LBB4_0:
	s_mov_b32 s16, 0xffff
	s_and_b32 s0, s11, 0xffff
	s_mul_i32 s12, s12, s0
	v_add_lshl_u32 v0, s12, v0, 2
	v_mov_b32_e32 v1, 0
	v_cmp_gt_i64_e32 vcc, s[6:7], v[0:1]
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB4_27
	s_mul_i32 s8, s8, s0
	s_lshl_b32 s0, s8, 2
	s_mov_b32 s1, 0
	v_lshl_add_u64 v[2:3], v[0:1], 1, 4
	s_lshl_b64 s[8:9], s[0:1], 1
	s_mov_b64 s[10:11], 0
	s_mov_b32 s17, 0x40733333
	s_brev_b32 s18, -2
	v_mov_b32_e32 v8, 0x4544e000
	s_mov_b32 s19, 0x5040100
	v_mov_b64_e32 v[4:5], v[0:1]
	s_branch .LBB4_3
.LBB4_2:
	s_or_b64 exec, exec, s[12:13]
	v_lshl_add_u64 v[4:5], v[4:5], 0, s[0:1]
	v_cmp_le_i64_e32 vcc, s[6:7], v[4:5]
	s_or_b64 s[10:11], vcc, s[10:11]
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[8:9]
	s_andn2_b64 exec, exec, s[10:11]
	s_cbranch_execz .LBB4_27
.LBB4_3:
	v_lshl_add_u64 v[6:7], s[4:5], 0, v[2:3]
	global_load_dword v0, v[6:7], off offset:-4
	v_lshl_add_u64 v[10:11], v[4:5], 0, 2
	v_cmp_gt_i64_e32 vcc, s[6:7], v[10:11]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB4_5
	global_load_dword v1, v[6:7], off
.LBB4_5:
	s_or_b64 exec, exec, s[12:13]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v6, 16, v0
	v_mul_f32_e32 v7, v6, v6
	v_mul_f32_e32 v7, v7, v6
	v_mul_f32_e32 v9, 0x3f4c422a, v6
	v_fmac_f32_e32 v9, 0x3d122279, v7
	v_cmp_ge_f32_e64 s[12:13], |v9|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB4_8
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB4_9
.LBB4_7:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB4_10
	s_branch .LBB4_15
.LBB4_8:
	v_bfi_b32 v7, s18, 1.0, v9
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB4_7
.LBB4_9:
	v_mul_f32_e32 v7, v9, v9
	v_fmaak_f32 v10, v9, v9, 0x43bd0000
	v_fmamk_f32 v11, v7, 0x41e00000, v8
	v_fmaak_f32 v11, v7, v11, 0x4773a200
	v_fmaak_f32 v11, v7, v11, 0x4803f7c0
	v_rcp_f32_e32 v11, v11
	v_fmaak_f32 v10, v7, v10, 0x46875a00
	v_fmaak_f32 v7, v7, v10, 0x4803f7c0
	v_mul_f32_e32 v7, v7, v9
	v_mul_f32_e32 v7, v11, v7
	v_med3_f32 v7, v7, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB4_15
.LBB4_10:
	v_lshlrev_b32_e32 v9, 16, v1
	v_mul_f32_e32 v10, v9, v9
	v_mul_f32_e32 v11, v10, v9
	v_mul_f32_e32 v10, 0x3f4c422a, v9
	v_fmac_f32_e32 v10, 0x3d122279, v11
	v_cmp_ge_f32_e64 s[14:15], |v10|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v11, s18, 1.0, v10
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB4_14
	v_mul_f32_e32 v11, v10, v10
	v_fmaak_f32 v12, v10, v10, 0x43bd0000
	v_fmamk_f32 v13, v11, 0x41e00000, v8
	v_fmaak_f32 v13, v11, v13, 0x4773a200
	v_fmaak_f32 v13, v11, v13, 0x4803f7c0
	v_rcp_f32_e32 v13, v13
	v_fmaak_f32 v12, v11, v12, 0x46875a00
	v_fmaak_f32 v11, v11, v12, 0x4803f7c0
	v_mul_f32_e32 v10, v11, v10
	v_mul_f32_e32 v10, v13, v10
	v_med3_f32 v11, v10, -1.0, 1.0
.LBB4_14:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v9, v9, v11
	v_mul_f32_e32 v9, 0.5, v9
	v_cvt_pk_bf16_f32 v9, v9, s0
	v_bfi_b32 v1, s16, v9, v1
.LBB4_15:
	s_or_b64 exec, exec, s[12:13]
	v_and_b32_e32 v9, 0xffff0000, v0
	v_mul_f32_e32 v10, v9, v9
	v_mul_f32_e32 v10, v10, v9
	v_mul_f32_e32 v11, 0x3f4c422a, v9
	v_fmac_f32_e32 v11, 0x3d122279, v10
	v_cmp_ge_f32_e64 s[12:13], |v11|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB4_18
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB4_19
.LBB4_17:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB4_20
	s_branch .LBB4_25
.LBB4_18:
	v_bfi_b32 v10, s18, 1.0, v11
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB4_17
.LBB4_19:
	v_mul_f32_e32 v10, v11, v11
	v_fmaak_f32 v12, v11, v11, 0x43bd0000
	v_fmamk_f32 v13, v10, 0x41e00000, v8
	v_fmaak_f32 v13, v10, v13, 0x4773a200
	v_fmaak_f32 v13, v10, v13, 0x4803f7c0
	v_rcp_f32_e32 v13, v13
	v_fmaak_f32 v12, v10, v12, 0x46875a00
	v_fmaak_f32 v10, v10, v12, 0x4803f7c0
	v_mul_f32_e32 v10, v10, v11
	v_mul_f32_e32 v10, v13, v10
	v_med3_f32 v10, v10, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB4_25
.LBB4_20:
	v_and_b32_e32 v11, 0xffff0000, v1
	v_mul_f32_e32 v12, v11, v11
	v_mul_f32_e32 v13, v12, v11
	v_mul_f32_e32 v12, 0x3f4c422a, v11
	v_fmac_f32_e32 v12, 0x3d122279, v13
	v_cmp_ge_f32_e64 s[14:15], |v12|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v13, s18, 1.0, v12
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB4_24
	v_mul_f32_e32 v13, v12, v12
	v_fmaak_f32 v14, v12, v12, 0x43bd0000
	v_fmamk_f32 v15, v13, 0x41e00000, v8
	v_fmaak_f32 v15, v13, v15, 0x4773a200
	v_fmaak_f32 v15, v13, v15, 0x4803f7c0
	v_rcp_f32_e32 v15, v15
	v_fmaak_f32 v14, v13, v14, 0x46875a00
	v_fmaak_f32 v13, v13, v14, 0x4803f7c0
	v_mul_f32_e32 v12, v13, v12
	v_mul_f32_e32 v12, v15, v12
	v_med3_f32 v13, v12, -1.0, 1.0
.LBB4_24:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v11, v11, v13
	v_mul_f32_e32 v11, 0.5, v11
	v_cvt_pk_bf16_f32 v11, v11, s0
	v_perm_b32 v1, v11, v1, s19
.LBB4_25:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v6, v6, v7
	v_mul_f32_e32 v6, 0.5, v6
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_bfi_b32 v0, s16, v6, v0
	v_fmac_f32_e32 v9, v9, v10
	v_mul_f32_e32 v6, 0.5, v9
	v_cvt_pk_bf16_f32 v6, v6, s0
	v_perm_b32 v0, v6, v0, s19
	v_lshl_add_u64 v[6:7], s[2:3], 0, v[2:3]
	global_store_dword v[6:7], v0, off offset:-4
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB4_2
	global_store_dword v[6:7], v1, off
	s_branch .LBB4_2
.LBB4_27:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 16
		.amdhsa_next_free_sgpr 22
		.amdhsa_accum_offset 16
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
.Lfunc_end4:
	.size	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x, .Lfunc_end4-_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x

	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.num_vgpr, 16
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.num_agpr, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.numbered_sgpr, 22
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.private_seg_size, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.uses_vcc, 1
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.uses_flat_scratch, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.has_dyn_sized_stack, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.has_recursion, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.has_indirect_call, 0
	.protected	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x
	.globl	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x
	.p2align	8
	.type	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x,@function
_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB5_0
	.p2align	8
.LBB5_0:
	s_mov_b32 s16, 0xffff
	s_and_b32 s0, s11, 0xffff
	s_mul_i32 s12, s12, s0
	v_add_lshl_u32 v8, s12, v0, 4
	v_mov_b32_e32 v9, 0
	v_cmp_gt_i64_e32 vcc, s[6:7], v[8:9]
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB5_87
	s_mul_i32 s8, s8, s0
	s_lshl_b32 s0, s8, 4
	s_mov_b32 s1, 0
	v_lshl_add_u64 v[10:11], v[8:9], 1, 16
	s_lshl_b64 s[8:9], s[0:1], 1
	v_mov_b32_e32 v0, v9
	v_mov_b32_e32 v1, v9
	v_mov_b32_e32 v2, v9
	v_mov_b32_e32 v3, v9
	s_mov_b64 s[10:11], 0
	s_mov_b32 s17, 0x40733333
	s_brev_b32 s18, -2
	v_mov_b32_e32 v14, 0x4544e000
	s_mov_b32 s19, 0x5040100
	s_branch .LBB5_3
.LBB5_2:
	s_or_b64 exec, exec, s[12:13]
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[0:1]
	v_cmp_le_i64_e32 vcc, s[6:7], v[8:9]
	s_or_b64 s[10:11], vcc, s[10:11]
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[8:9]
	s_andn2_b64 exec, exec, s[10:11]
	s_cbranch_execz .LBB5_87
.LBB5_3:
	v_lshl_add_u64 v[12:13], s[4:5], 0, v[10:11]
	global_load_dwordx4 v[4:7], v[12:13], off offset:-16
	v_lshl_add_u64 v[16:17], v[8:9], 0, 8
	v_cmp_gt_i64_e32 vcc, s[6:7], v[16:17]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_5
	global_load_dwordx4 v[0:3], v[12:13], off
.LBB5_5:
	s_or_b64 exec, exec, s[12:13]
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v13, 16, v4
	v_mul_f32_e32 v12, v13, v13
	v_mul_f32_e32 v15, v12, v13
	v_mul_f32_e32 v12, 0x3f4c422a, v13
	v_fmac_f32_e32 v12, 0x3d122279, v15
	v_cmp_ge_f32_e64 s[12:13], |v12|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_8
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_9
.LBB5_7:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_10
	s_branch .LBB5_15
.LBB5_8:
	v_bfi_b32 v16, s18, 1.0, v12
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_7
.LBB5_9:
	v_mul_f32_e32 v15, v12, v12
	v_fmaak_f32 v16, v12, v12, 0x43bd0000
	v_fmamk_f32 v17, v15, 0x41e00000, v14
	v_fmaak_f32 v17, v15, v17, 0x4773a200
	v_fmaak_f32 v17, v15, v17, 0x4803f7c0
	v_rcp_f32_e32 v17, v17
	v_fmaak_f32 v16, v15, v16, 0x46875a00
	v_fmaak_f32 v15, v15, v16, 0x4803f7c0
	v_mul_f32_e32 v12, v15, v12
	v_mul_f32_e32 v12, v17, v12
	v_med3_f32 v16, v12, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_15
.LBB5_10:
	v_lshlrev_b32_e32 v12, 16, v0
	v_mul_f32_e32 v15, v12, v12
	v_mul_f32_e32 v17, v15, v12
	v_mul_f32_e32 v15, 0x3f4c422a, v12
	v_fmac_f32_e32 v15, 0x3d122279, v17
	v_cmp_ge_f32_e64 s[14:15], |v15|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v17, s18, 1.0, v15
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_14
	v_mul_f32_e32 v17, v15, v15
	v_fmaak_f32 v18, v15, v15, 0x43bd0000
	v_fmamk_f32 v19, v17, 0x41e00000, v14
	v_fmaak_f32 v19, v17, v19, 0x4773a200
	v_fmaak_f32 v19, v17, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v17, v18, 0x46875a00
	v_fmaak_f32 v17, v17, v18, 0x4803f7c0
	v_mul_f32_e32 v15, v17, v15
	v_mul_f32_e32 v15, v19, v15
	v_med3_f32 v17, v15, -1.0, 1.0
.LBB5_14:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v12, v12, v17
	v_mul_f32_e32 v12, 0.5, v12
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_bfi_b32 v0, s16, v12, v0
.LBB5_15:
	s_or_b64 exec, exec, s[12:13]
	v_and_b32_e32 v12, 0xffff0000, v4
	v_mul_f32_e32 v15, v12, v12
	v_mul_f32_e32 v15, v15, v12
	v_mul_f32_e32 v17, 0x3f4c422a, v12
	v_fmac_f32_e32 v17, 0x3d122279, v15
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_18
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_19
.LBB5_17:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_20
	s_branch .LBB5_25
.LBB5_18:
	v_bfi_b32 v15, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_17
.LBB5_19:
	v_mul_f32_e32 v15, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v15, 0x41e00000, v14
	v_fmaak_f32 v19, v15, v19, 0x4773a200
	v_fmaak_f32 v19, v15, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v15, v18, 0x46875a00
	v_fmaak_f32 v15, v15, v18, 0x4803f7c0
	v_mul_f32_e32 v15, v15, v17
	v_mul_f32_e32 v15, v19, v15
	v_med3_f32 v15, v15, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_25
.LBB5_20:
	v_and_b32_e32 v17, 0xffff0000, v0
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_24
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_24:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_perm_b32 v0, v17, v0, s19
.LBB5_25:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v13, v13, v16
	v_mul_f32_e32 v13, 0.5, v13
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_bfi_b32 v4, s16, v13, v4
	v_lshlrev_b32_e32 v13, 16, v5
	v_mul_f32_e32 v16, v13, v13
	v_mul_f32_e32 v16, v16, v13
	v_mul_f32_e32 v17, 0x3f4c422a, v13
	v_fmac_f32_e32 v17, 0x3d122279, v16
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_28
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_29
.LBB5_27:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_30
	s_branch .LBB5_35
.LBB5_28:
	v_bfi_b32 v16, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_27
.LBB5_29:
	v_mul_f32_e32 v16, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v16, 0x41e00000, v14
	v_fmaak_f32 v19, v16, v19, 0x4773a200
	v_fmaak_f32 v19, v16, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v16, v18, 0x46875a00
	v_fmaak_f32 v16, v16, v18, 0x4803f7c0
	v_mul_f32_e32 v16, v16, v17
	v_mul_f32_e32 v16, v19, v16
	v_med3_f32 v16, v16, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_35
.LBB5_30:
	v_lshlrev_b32_e32 v17, 16, v1
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_34
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_34:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_bfi_b32 v1, s16, v17, v1
.LBB5_35:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v12, v12, v15
	v_mul_f32_e32 v12, 0.5, v12
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_perm_b32 v4, v12, v4, s19
	v_and_b32_e32 v12, 0xffff0000, v5
	v_mul_f32_e32 v15, v12, v12
	v_mul_f32_e32 v15, v15, v12
	v_mul_f32_e32 v17, 0x3f4c422a, v12
	v_fmac_f32_e32 v17, 0x3d122279, v15
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_38
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_39
.LBB5_37:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_40
	s_branch .LBB5_45
.LBB5_38:
	v_bfi_b32 v15, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_37
.LBB5_39:
	v_mul_f32_e32 v15, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v15, 0x41e00000, v14
	v_fmaak_f32 v19, v15, v19, 0x4773a200
	v_fmaak_f32 v19, v15, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v15, v18, 0x46875a00
	v_fmaak_f32 v15, v15, v18, 0x4803f7c0
	v_mul_f32_e32 v15, v15, v17
	v_mul_f32_e32 v15, v19, v15
	v_med3_f32 v15, v15, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_45
.LBB5_40:
	v_and_b32_e32 v17, 0xffff0000, v1
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_44
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_44:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_perm_b32 v1, v17, v1, s19
.LBB5_45:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v13, v13, v16
	v_mul_f32_e32 v13, 0.5, v13
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_bfi_b32 v5, s16, v13, v5
	v_lshlrev_b32_e32 v13, 16, v6
	v_mul_f32_e32 v16, v13, v13
	v_mul_f32_e32 v16, v16, v13
	v_mul_f32_e32 v17, 0x3f4c422a, v13
	v_fmac_f32_e32 v17, 0x3d122279, v16
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_48
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_49
.LBB5_47:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_50
	s_branch .LBB5_55
.LBB5_48:
	v_bfi_b32 v16, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_47
.LBB5_49:
	v_mul_f32_e32 v16, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v16, 0x41e00000, v14
	v_fmaak_f32 v19, v16, v19, 0x4773a200
	v_fmaak_f32 v19, v16, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v16, v18, 0x46875a00
	v_fmaak_f32 v16, v16, v18, 0x4803f7c0
	v_mul_f32_e32 v16, v16, v17
	v_mul_f32_e32 v16, v19, v16
	v_med3_f32 v16, v16, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_55
.LBB5_50:
	v_lshlrev_b32_e32 v17, 16, v2
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_54
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_54:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_bfi_b32 v2, s16, v17, v2
.LBB5_55:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v12, v12, v15
	v_mul_f32_e32 v12, 0.5, v12
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_perm_b32 v5, v12, v5, s19
	v_and_b32_e32 v12, 0xffff0000, v6
	v_mul_f32_e32 v15, v12, v12
	v_mul_f32_e32 v15, v15, v12
	v_mul_f32_e32 v17, 0x3f4c422a, v12
	v_fmac_f32_e32 v17, 0x3d122279, v15
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_58
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_59
.LBB5_57:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_60
	s_branch .LBB5_65
.LBB5_58:
	v_bfi_b32 v15, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_57
.LBB5_59:
	v_mul_f32_e32 v15, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v15, 0x41e00000, v14
	v_fmaak_f32 v19, v15, v19, 0x4773a200
	v_fmaak_f32 v19, v15, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v15, v18, 0x46875a00
	v_fmaak_f32 v15, v15, v18, 0x4803f7c0
	v_mul_f32_e32 v15, v15, v17
	v_mul_f32_e32 v15, v19, v15
	v_med3_f32 v15, v15, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_65
.LBB5_60:
	v_and_b32_e32 v17, 0xffff0000, v2
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_64
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_64:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_perm_b32 v2, v17, v2, s19
.LBB5_65:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v13, v13, v16
	v_mul_f32_e32 v13, 0.5, v13
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_bfi_b32 v6, s16, v13, v6
	v_lshlrev_b32_e32 v13, 16, v7
	v_mul_f32_e32 v16, v13, v13
	v_mul_f32_e32 v16, v16, v13
	v_mul_f32_e32 v17, 0x3f4c422a, v13
	v_fmac_f32_e32 v17, 0x3d122279, v16
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_68
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_69
.LBB5_67:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_70
	s_branch .LBB5_75
.LBB5_68:
	v_bfi_b32 v16, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_67
.LBB5_69:
	v_mul_f32_e32 v16, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v16, 0x41e00000, v14
	v_fmaak_f32 v19, v16, v19, 0x4773a200
	v_fmaak_f32 v19, v16, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v16, v18, 0x46875a00
	v_fmaak_f32 v16, v16, v18, 0x4803f7c0
	v_mul_f32_e32 v16, v16, v17
	v_mul_f32_e32 v16, v19, v16
	v_med3_f32 v16, v16, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_75
.LBB5_70:
	v_lshlrev_b32_e32 v17, 16, v3
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_74
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_74:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_bfi_b32 v3, s16, v17, v3
.LBB5_75:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v12, v12, v15
	v_mul_f32_e32 v12, 0.5, v12
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_perm_b32 v6, v12, v6, s19
	v_and_b32_e32 v12, 0xffff0000, v7
	v_mul_f32_e32 v15, v12, v12
	v_mul_f32_e32 v15, v15, v12
	v_mul_f32_e32 v17, 0x3f4c422a, v12
	v_fmac_f32_e32 v17, 0x3d122279, v15
	v_cmp_ge_f32_e64 s[12:13], |v17|, s17
	s_and_saveexec_b64 s[14:15], s[12:13]
	s_xor_b64 s[12:13], exec, s[14:15]
	s_cbranch_execnz .LBB5_78
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execnz .LBB5_79
.LBB5_77:
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execnz .LBB5_80
	s_branch .LBB5_85
.LBB5_78:
	v_bfi_b32 v15, s18, 1.0, v17
	s_andn2_saveexec_b64 s[12:13], s[12:13]
	s_cbranch_execz .LBB5_77
.LBB5_79:
	v_mul_f32_e32 v15, v17, v17
	v_fmaak_f32 v18, v17, v17, 0x43bd0000
	v_fmamk_f32 v19, v15, 0x41e00000, v14
	v_fmaak_f32 v19, v15, v19, 0x4773a200
	v_fmaak_f32 v19, v15, v19, 0x4803f7c0
	v_rcp_f32_e32 v19, v19
	v_fmaak_f32 v18, v15, v18, 0x46875a00
	v_fmaak_f32 v15, v15, v18, 0x4803f7c0
	v_mul_f32_e32 v15, v15, v17
	v_mul_f32_e32 v15, v19, v15
	v_med3_f32 v15, v15, -1.0, 1.0
	s_or_b64 exec, exec, s[12:13]
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_85
.LBB5_80:
	v_and_b32_e32 v17, 0xffff0000, v3
	v_mul_f32_e32 v18, v17, v17
	v_mul_f32_e32 v19, v18, v17
	v_mul_f32_e32 v18, 0x3f4c422a, v17
	v_fmac_f32_e32 v18, 0x3d122279, v19
	v_cmp_ge_f32_e64 s[14:15], |v18|, s17
	s_and_saveexec_b64 s[20:21], s[14:15]
	s_xor_b64 s[14:15], exec, s[20:21]
	v_bfi_b32 v19, s18, 1.0, v18
	s_andn2_saveexec_b64 s[14:15], s[14:15]
	s_cbranch_execz .LBB5_84
	v_mul_f32_e32 v19, v18, v18
	v_fmaak_f32 v20, v18, v18, 0x43bd0000
	v_fmamk_f32 v21, v19, 0x41e00000, v14
	v_fmaak_f32 v21, v19, v21, 0x4773a200
	v_fmaak_f32 v21, v19, v21, 0x4803f7c0
	v_rcp_f32_e32 v21, v21
	v_fmaak_f32 v20, v19, v20, 0x46875a00
	v_fmaak_f32 v19, v19, v20, 0x4803f7c0
	v_mul_f32_e32 v18, v19, v18
	v_mul_f32_e32 v18, v21, v18
	v_med3_f32 v19, v18, -1.0, 1.0
.LBB5_84:
	s_or_b64 exec, exec, s[14:15]
	v_fmac_f32_e32 v17, v17, v19
	v_mul_f32_e32 v17, 0.5, v17
	v_cvt_pk_bf16_f32 v17, v17, s0
	v_perm_b32 v3, v17, v3, s19
.LBB5_85:
	s_or_b64 exec, exec, s[12:13]
	v_fmac_f32_e32 v13, v13, v16
	v_mul_f32_e32 v13, 0.5, v13
	v_cvt_pk_bf16_f32 v13, v13, s0
	v_bfi_b32 v7, s16, v13, v7
	v_fmac_f32_e32 v12, v12, v15
	v_mul_f32_e32 v12, 0.5, v12
	v_cvt_pk_bf16_f32 v12, v12, s0
	v_perm_b32 v7, v12, v7, s19
	v_lshl_add_u64 v[12:13], s[2:3], 0, v[10:11]
	global_store_dwordx4 v[12:13], v[4:7], off offset:-16
	s_and_saveexec_b64 s[12:13], vcc
	s_cbranch_execz .LBB5_2
	global_store_dwordx4 v[12:13], v[0:3], off
	s_branch .LBB5_2
.LBB5_87:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 280
		.amdhsa_user_sgpr_count 12
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 10
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 22
		.amdhsa_next_free_sgpr 22
		.amdhsa_accum_offset 24
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
.Lfunc_end5:
	.size	_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x, .Lfunc_end5-_ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x

	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.num_vgpr, 22
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.num_agpr, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.numbered_sgpr, 22
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.private_seg_size, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.uses_vcc, 1
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.uses_flat_scratch, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.has_dyn_sized_stack, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.has_recursion, 0
	.set _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_16007aa28da912c9,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_16007aa28da912c9
__hip_cuid_16007aa28da912c9:
	.byte	0
	.size	__hip_cuid_16007aa28da912c9, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_16007aa28da912c9
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi2ELb0ELi3EEEvPT0_PS2_if.kd
    .uses_dynamic_stack: false
    .vgpr_count:     9
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi4ELb0ELi3EEEvPT0_PS2_if.kd
    .uses_dynamic_stack: false
    .vgpr_count:     15
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           4
        .value_kind:     by_value
      - .offset:         20
        .size:           4
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if
    .private_segment_fixed_size: 0
    .sgpr_count:     25
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter18act_and_mul_kernelIDF16bDF16bTnPFfRKT_EXadL_ZNS_11silu_kernelIDF16bEEfS3_EELi8ELb0ELi3EEEvPT0_PS2_if.kd
    .uses_dynamic_stack: false
    .vgpr_count:     27
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           8
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         52
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         56
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         60
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         62
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         64
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         66
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         68
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         70
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         96
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         104
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         112
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix
    .private_segment_fixed_size: 0
    .sgpr_count:     35
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter23act_and_mul_bias_kernelIDF16bDF16bifTnPFfRKT2_EXadL_ZNS_11silu_kernelIfEEfRKT_EELi2EEEvPT0_PS8_PKT1_PS2_ix.kd
    .uses_dynamic_stack: false
    .vgpr_count:     12
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           8
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x
    .private_segment_fixed_size: 0
    .sgpr_count:     28
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi2EEEvPS1_PS2_x.kd
    .uses_dynamic_stack: false
    .vgpr_count:     16
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .actual_access:  write_only
        .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           8
        .value_kind:     by_value
      - .offset:         24
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         28
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         36
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         38
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         40
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         42
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         44
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         46
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         64
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         88
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 280
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x
    .private_segment_fixed_size: 0
    .sgpr_count:     28
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter21activation_kernel_vecIDF16bTnPFfRKT_EXadL_ZNS_16gelu_fast_kernelIDF16bEEfS3_EELi8EEEvPS1_PS2_x.kd
    .uses_dynamic_stack: false
    .vgpr_count:     22
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
