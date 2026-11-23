; Aiter 183a6ce66ebb csrc/kernels/topk_softmax_kernels.cu:772 (moe_sum_kernel), dispatch :1570, compiled for gfx950 by
; external/amd/aiter/build.py (case moe_sum).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i
	.globl	_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i
	.p2align	8
	.type	_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i,@function
_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	v_cmp_gt_i32_e32 vcc, s6, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_14
	s_ashr_i32 s7, s6, 31
	s_and_b32 s8, s11, 0xffff
	s_mov_b32 s9, 0
	v_add_u32_e32 v4, s8, v0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v1, s7
	v_cmp_lt_i64_e32 vcc, s[6:7], v[4:5]
	s_nop 1
	v_cndmask_b32_e64 v3, v1, 0, vcc
	v_mov_b32_e32 v1, s6
	v_cndmask_b32_e32 v1, v1, v4, vcc
	v_cmp_gt_i64_e32 vcc, s[6:7], v[4:5]
	s_nop 1
	v_cndmask_b32_e64 v2, 0, 1, vcc
	v_mov_b32_e32 v4, s8
	v_addc_co_u32_e32 v4, vcc, v0, v4, vcc
	v_sub_co_u32_e32 v1, vcc, v1, v4
	s_nop 1
	v_subbrev_co_u32_e32 v7, vcc, 0, v3, vcc
	v_mov_b32_e32 v6, v5
	v_cmp_ne_u64_e32 vcc, 0, v[6:7]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[10:11], exec, s[0:1]
	s_cbranch_execz .LBB0_3
	v_cvt_f32_u32_e32 v3, s8
	v_mov_b32_e32 v4, 0x4f800000
	v_fmac_f32_e32 v3, 0, v4
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v4, 0x2f800000, v3
	v_trunc_f32_e32 v4, v4
	v_fmamk_f32 v3, v4, 0xcf800000, v3
	v_cvt_u32_f32_e32 v6, v4
	v_cvt_u32_f32_e32 v3, v3
	s_sub_u32 s0, 0, s8
	s_subb_u32 s1, 0, 0
	v_mul_lo_u32 v4, s0, v6
	v_mul_lo_u32 v8, s1, v3
	v_mul_hi_u32 v9, s0, v3
	v_mul_lo_u32 v10, s0, v3
	v_add_u32_e32 v9, v9, v4
	v_mul_hi_u32 v4, v3, v10
	v_add_u32_e32 v11, v9, v8
	v_mul_hi_u32 v9, v3, v11
	v_mul_lo_u32 v8, v3, v11
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_mul_hi_u32 v12, v6, v11
	v_mul_hi_u32 v4, v6, v10
	v_mul_lo_u32 v10, v6, v10
	v_add_co_u32_e32 v8, vcc, v8, v10
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v4, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v12, vcc
	v_mul_lo_u32 v8, v6, v11
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v3, v8
	s_nop 1
	v_addc_co_u32_e32 v6, vcc, v6, v9, vcc
	v_mul_lo_u32 v4, s0, v6
	v_mul_hi_u32 v8, s0, v3
	v_add_u32_e32 v4, v8, v4
	v_mul_lo_u32 v8, s1, v3
	v_add_u32_e32 v10, v4, v8
	v_mul_hi_u32 v11, v6, v10
	v_mul_lo_u32 v4, s0, v3
	v_mul_hi_u32 v12, v6, v4
	v_mul_lo_u32 v13, v6, v4
	v_mul_hi_u32 v9, v3, v10
	v_mul_lo_u32 v8, v3, v10
	v_mul_hi_u32 v4, v3, v4
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v4, vcc, v8, v13
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v12, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v11, vcc
	v_mul_lo_u32 v8, v6, v10
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v3, v8
	s_nop 1
	v_addc_co_u32_e32 v6, vcc, v6, v9, vcc
	v_mad_u64_u32 v[8:9], s[0:1], v1, v6, 0
	v_mul_hi_u32 v4, v1, v3
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_mad_u64_u32 v[10:11], s[0:1], v7, v6, 0
	v_mad_u64_u32 v[12:13], s[0:1], v7, v3, 0
	v_add_co_u32_e32 v3, vcc, v8, v12
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v13, vcc
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, 0, v11, vcc
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[10:11]
	v_mad_u64_u32 v[8:9], s[0:1], s8, v4, 0
	v_mov_b32_e32 v6, v9
	v_mad_u64_u32 v[10:11], s[0:1], s8, v5, v[6:7]
	v_sub_co_u32_e32 v1, vcc, v1, v8
	s_nop 1
	v_subb_co_u32_e32 v3, vcc, v7, v10, vcc
	v_subrev_co_u32_e32 v6, vcc, s8, v1
	s_nop 1
	v_subbrev_co_u32_e32 v7, vcc, 0, v3, vcc
	v_cmp_le_u32_e32 vcc, s8, v6
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v7
	s_nop 1
	v_cndmask_b32_e32 v10, -1, v6, vcc
	v_lshl_add_u64 v[6:7], v[4:5], 0, 2
	v_lshl_add_u64 v[8:9], v[4:5], 0, 1
	v_cmp_ne_u32_e32 vcc, 0, v10
	s_nop 1
	v_cndmask_b32_e32 v7, v9, v7, vcc
	v_cmp_le_u32_e64 s[0:1], s8, v1
	s_nop 1
	v_cndmask_b32_e64 v1, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], 0, v3
	s_nop 1
	v_cndmask_b32_e64 v1, -1, v1, s[0:1]
	v_cmp_ne_u32_e64 s[0:1], 0, v1
	s_nop 1
	v_cndmask_b32_e64 v9, v5, v7, s[0:1]
	v_cndmask_b32_e32 v1, v8, v6, vcc
	v_cndmask_b32_e64 v8, v4, v1, s[0:1]
.LBB0_3:
	s_or_saveexec_b64 s[0:1], s[10:11]
	v_mov_b32_e32 v3, s9
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB0_5
	v_cvt_f32_u32_e32 v4, s8
	v_rcp_iflag_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	s_sub_i32 s10, 0, s8
	v_mul_lo_u32 v5, s10, v4
	v_mul_hi_u32 v5, v4, v5
	v_add_u32_e32 v4, v4, v5
	v_mul_hi_u32 v4, v1, v4
	v_mul_lo_u32 v5, v4, s8
	v_add_u32_e32 v6, 1, v4
	v_sub_u32_e32 v1, v1, v5
	v_subrev_u32_e32 v5, s8, v1
	v_cmp_le_u32_e32 vcc, s8, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v5, vcc
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_add_u32_e32 v5, 1, v4
	v_cmp_le_u32_e32 vcc, s8, v1
	s_nop 1
	v_cndmask_b32_e32 v8, v4, v5, vcc
	v_mov_b32_e32 v9, 0
.LBB0_5:
	s_or_b64 exec, exec, s[0:1]
	s_mov_b32 s13, 0
	v_mov_b32_e32 v1, 0
	s_mul_i32 s0, s12, s7
	s_mul_hi_u32 s1, s12, s6
	s_add_i32 s11, s1, s0
	s_mul_i32 s10, s12, s6
	s_lshl_b64 s[0:1], s[10:11], 3
	s_add_u32 s0, s4, s0
	s_addc_u32 s1, s5, s1
	s_lshl_b64 s[10:11], s[10:11], 2
	s_add_u32 s2, s2, s10
	s_addc_u32 s3, s3, s11
	v_lshl_add_u64 v[2:3], v[8:9], 0, v[2:3]
	v_lshl_add_u64 v[2:3], v[2:3], 0, 1
	v_cmp_gt_u64_e32 vcc, 4, v[2:3]
	s_cmp_lg_u32 s8, 1
	s_cselect_b64 s[10:11], -1, 0
	s_or_b64 s[14:15], vcc, s[10:11]
	s_mov_b64 s[10:11], 0
	s_and_saveexec_b64 s[18:19], s[14:15]
	s_xor_b64 s[14:15], exec, s[18:19]
	s_cbranch_execnz .LBB0_8
	s_or_saveexec_b64 s[14:15], s[14:15]
	v_mov_b64_e32 v[4:5], s[16:17]
	s_xor_b64 exec, exec, s[14:15]
	s_cbranch_execnz .LBB0_9
.LBB0_7:
	s_or_b64 exec, exec, s[14:15]
	s_and_b64 exec, exec, s[10:11]
	s_cbranch_execnz .LBB0_12
	s_branch .LBB0_14
.LBB0_8:
	s_mov_b64 s[10:11], exec
	s_lshl_b64 s[16:17], s[12:13], 3
	s_or_b32 s16, s16, 4
	s_mul_i32 s18, s16, s7
	s_mul_hi_u32 s19, s16, s6
	s_add_i32 s18, s19, s18
	s_mul_i32 s17, s17, s6
	s_add_i32 s17, s18, s17
	s_mul_i32 s16, s16, s6
	s_or_saveexec_b64 s[14:15], s[14:15]
	v_mov_b64_e32 v[4:5], s[16:17]
	s_xor_b64 exec, exec, s[14:15]
	s_cbranch_execz .LBB0_7
.LBB0_9:
	v_and_b32_e32 v4, -4, v2
	v_mov_b32_e32 v5, v3
	s_lshl_b64 s[12:13], s[12:13], 3
	s_or_b32 s12, s12, 4
	s_mul_i32 s16, s12, s7
	s_mul_hi_u32 s17, s12, s6
	s_add_i32 s16, s17, s16
	s_mul_i32 s13, s13, s6
	s_add_i32 s13, s16, s13
	s_mul_i32 s12, s12, s6
	s_add_u32 s16, s12, s4
	s_addc_u32 s17, s13, s5
	s_add_u32 s16, s16, 8
	s_addc_u32 s17, s17, 0
	v_lshlrev_b32_e32 v6, 2, v0
	s_mov_b32 s19, 0
	v_mov_b32_e32 v7, 0
	s_lshl_b32 s18, s8, 4
	s_mov_b64 s[20:21], 0
	v_mov_b64_e32 v[8:9], v[4:5]
.LBB0_10:
	v_lshl_add_u64 v[10:11], s[0:1], 0, v[6:7]
	v_lshl_add_u64 v[14:15], s[16:17], 0, v[6:7]
	global_load_dwordx4 v[10:13], v[10:11], off
	global_load_dwordx4 v[14:17], v[14:15], off offset:-8
	v_lshl_add_u64 v[18:19], s[2:3], 0, v[6:7]
	v_lshl_add_u64 v[8:9], v[8:9], 0, -4
	v_lshl_add_u64 v[6:7], v[6:7], 0, s[18:19]
	v_cmp_eq_u64_e32 vcc, 0, v[8:9]
	s_or_b64 s[20:21], vcc, s[20:21]
	s_waitcnt vmcnt(1)
	v_pk_add_f32 v[10:11], v[10:11], 0 op_sel_hi:[1,0]
	v_pk_add_f32 v[12:13], v[12:13], 0 op_sel_hi:[1,0]
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	v_pk_add_f32 v[12:13], v[12:13], v[16:17]
	global_store_dwordx4 v[18:19], v[10:13], off
	s_andn2_b64 exec, exec, s[20:21]
	s_cbranch_execnz .LBB0_10
	s_or_b64 exec, exec, s[20:21]
	v_mad_u64_u32 v[0:1], s[16:17], v4, s8, v[0:1]
	v_mov_b32_e32 v6, v1
	v_mad_u64_u32 v[6:7], s[16:17], v5, s8, v[6:7]
	v_mov_b32_e32 v1, v6
	v_cmp_ne_u64_e32 vcc, v[2:3], v[4:5]
	v_mov_b64_e32 v[4:5], s[12:13]
	s_andn2_b64 s[10:11], s[10:11], exec
	s_and_b64 s[12:13], vcc, exec
	s_or_b64 s[10:11], s[10:11], s[12:13]
	s_or_b64 exec, exec, s[14:15]
	s_and_b64 exec, exec, s[10:11]
	s_cbranch_execz .LBB0_14
.LBB0_12:
	v_lshlrev_b64 v[2:3], 2, v[0:1]
	s_lshl_b32 s10, s8, 2
	s_mov_b32 s11, 0
	v_lshl_add_u64 v[4:5], s[4:5], 0, v[4:5]
	s_mov_b64 s[4:5], 0
.LBB0_13:
	v_lshl_add_u64 v[6:7], s[0:1], 0, v[2:3]
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[2:3]
	global_load_dword v10, v[6:7], off
	global_load_dword v8, v[8:9], off
	v_lshl_add_u64 v[6:7], s[2:3], 0, v[2:3]
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[8:9]
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[10:11]
	v_cmp_le_i64_e32 vcc, s[6:7], v[0:1]
	s_or_b64 s[4:5], vcc, s[4:5]
	s_waitcnt vmcnt(1)
	v_add_f32_e32 v9, 0, v10
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v8, v9, v8
	global_store_dword v[6:7], v8, off
	s_andn2_b64 exec, exec, s[4:5]
	s_cbranch_execnz .LBB0_13
.LBB0_14:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i
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
		.amdhsa_next_free_vgpr 20
		.amdhsa_next_free_sgpr 22
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
	.size	_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i, .Lfunc_end0-_ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i

	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.num_vgpr, 20
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.num_agpr, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.numbered_sgpr, 22
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.private_seg_size, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.uses_vcc, 1
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.uses_flat_scratch, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.has_dyn_sized_stack, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.has_recursion, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.has_indirect_call, 0
	.protected	_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i
	.globl	_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i
	.p2align	8
	.type	_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i,@function
_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB1_0
	.p2align	8
.LBB1_0:
	v_cmp_gt_i32_e32 vcc, s6, v0
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB1_12
	s_ashr_i32 s7, s6, 31
	s_and_b32 s8, s11, 0xffff
	s_mov_b32 s9, 0
	v_add_u32_e32 v4, s8, v0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v1, s7
	v_cmp_lt_i64_e32 vcc, s[6:7], v[4:5]
	s_nop 1
	v_cndmask_b32_e64 v3, v1, 0, vcc
	v_mov_b32_e32 v1, s6
	v_cndmask_b32_e32 v1, v1, v4, vcc
	v_cmp_gt_i64_e32 vcc, s[6:7], v[4:5]
	s_nop 1
	v_cndmask_b32_e64 v2, 0, 1, vcc
	v_mov_b32_e32 v4, s8
	v_addc_co_u32_e32 v4, vcc, v0, v4, vcc
	v_sub_co_u32_e32 v1, vcc, v1, v4
	s_nop 1
	v_subbrev_co_u32_e32 v7, vcc, 0, v3, vcc
	v_mov_b32_e32 v6, v5
	v_cmp_ne_u64_e32 vcc, 0, v[6:7]
	s_and_saveexec_b64 s[0:1], vcc
	s_xor_b64 s[10:11], exec, s[0:1]
	s_cbranch_execz .LBB1_3
	v_cvt_f32_u32_e32 v3, s8
	v_mov_b32_e32 v4, 0x4f800000
	v_fmac_f32_e32 v3, 0, v4
	v_rcp_f32_e32 v3, v3
	s_nop 0
	v_mul_f32_e32 v3, 0x5f7ffffc, v3
	v_mul_f32_e32 v4, 0x2f800000, v3
	v_trunc_f32_e32 v4, v4
	v_fmamk_f32 v3, v4, 0xcf800000, v3
	v_cvt_u32_f32_e32 v6, v4
	v_cvt_u32_f32_e32 v3, v3
	s_sub_u32 s0, 0, s8
	s_subb_u32 s1, 0, 0
	v_mul_lo_u32 v4, s0, v6
	v_mul_lo_u32 v8, s1, v3
	v_mul_hi_u32 v9, s0, v3
	v_mul_lo_u32 v10, s0, v3
	v_add_u32_e32 v9, v9, v4
	v_mul_hi_u32 v4, v3, v10
	v_add_u32_e32 v11, v9, v8
	v_mul_hi_u32 v9, v3, v11
	v_mul_lo_u32 v8, v3, v11
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_mul_hi_u32 v12, v6, v11
	v_mul_hi_u32 v4, v6, v10
	v_mul_lo_u32 v10, v6, v10
	v_add_co_u32_e32 v8, vcc, v8, v10
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v4, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v12, vcc
	v_mul_lo_u32 v8, v6, v11
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v3, v8
	s_nop 1
	v_addc_co_u32_e32 v6, vcc, v6, v9, vcc
	v_mul_lo_u32 v4, s0, v6
	v_mul_hi_u32 v8, s0, v3
	v_add_u32_e32 v4, v8, v4
	v_mul_lo_u32 v8, s1, v3
	v_add_u32_e32 v10, v4, v8
	v_mul_hi_u32 v11, v6, v10
	v_mul_lo_u32 v4, s0, v3
	v_mul_hi_u32 v12, v6, v4
	v_mul_lo_u32 v13, v6, v4
	v_mul_hi_u32 v9, v3, v10
	v_mul_lo_u32 v8, v3, v10
	v_mul_hi_u32 v4, v3, v4
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v4, vcc, v8, v13
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v12, vcc
	s_nop 1
	v_addc_co_u32_e32 v9, vcc, 0, v11, vcc
	v_mul_lo_u32 v8, v6, v10
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_add_co_u32_e32 v3, vcc, v3, v8
	s_nop 1
	v_addc_co_u32_e32 v6, vcc, v6, v9, vcc
	v_mad_u64_u32 v[8:9], s[0:1], v1, v6, 0
	v_mul_hi_u32 v4, v1, v3
	v_lshl_add_u64 v[8:9], v[4:5], 0, v[8:9]
	v_mad_u64_u32 v[10:11], s[0:1], v7, v6, 0
	v_mad_u64_u32 v[12:13], s[0:1], v7, v3, 0
	v_add_co_u32_e32 v3, vcc, v8, v12
	s_nop 1
	v_addc_co_u32_e32 v4, vcc, v9, v13, vcc
	s_nop 1
	v_addc_co_u32_e32 v11, vcc, 0, v11, vcc
	v_lshl_add_u64 v[4:5], v[4:5], 0, v[10:11]
	v_mad_u64_u32 v[8:9], s[0:1], s8, v4, 0
	v_mov_b32_e32 v6, v9
	v_mad_u64_u32 v[10:11], s[0:1], s8, v5, v[6:7]
	v_sub_co_u32_e32 v1, vcc, v1, v8
	s_nop 1
	v_subb_co_u32_e32 v3, vcc, v7, v10, vcc
	v_subrev_co_u32_e32 v6, vcc, s8, v1
	s_nop 1
	v_subbrev_co_u32_e32 v7, vcc, 0, v3, vcc
	v_cmp_le_u32_e32 vcc, s8, v6
	s_nop 1
	v_cndmask_b32_e64 v6, 0, -1, vcc
	v_cmp_eq_u32_e32 vcc, 0, v7
	s_nop 1
	v_cndmask_b32_e32 v10, -1, v6, vcc
	v_lshl_add_u64 v[6:7], v[4:5], 0, 2
	v_lshl_add_u64 v[8:9], v[4:5], 0, 1
	v_cmp_ne_u32_e32 vcc, 0, v10
	s_nop 1
	v_cndmask_b32_e32 v7, v9, v7, vcc
	v_cmp_le_u32_e64 s[0:1], s8, v1
	s_nop 1
	v_cndmask_b32_e64 v1, 0, -1, s[0:1]
	v_cmp_eq_u32_e64 s[0:1], 0, v3
	s_nop 1
	v_cndmask_b32_e64 v1, -1, v1, s[0:1]
	v_cmp_ne_u32_e64 s[0:1], 0, v1
	s_nop 1
	v_cndmask_b32_e64 v9, v5, v7, s[0:1]
	v_cndmask_b32_e32 v1, v8, v6, vcc
	v_cndmask_b32_e64 v8, v4, v1, s[0:1]
.LBB1_3:
	s_or_saveexec_b64 s[0:1], s[10:11]
	v_mov_b32_e32 v3, s9
	s_xor_b64 exec, exec, s[0:1]
	s_cbranch_execz .LBB1_5
	v_cvt_f32_u32_e32 v4, s8
	v_rcp_iflag_f32_e32 v4, v4
	s_nop 0
	v_mul_f32_e32 v4, 0x4f7ffffe, v4
	v_cvt_u32_f32_e32 v4, v4
	s_sub_i32 s10, 0, s8
	v_mul_lo_u32 v5, s10, v4
	v_mul_hi_u32 v5, v4, v5
	v_add_u32_e32 v4, v4, v5
	v_mul_hi_u32 v4, v1, v4
	v_mul_lo_u32 v5, v4, s8
	v_add_u32_e32 v6, 1, v4
	v_sub_u32_e32 v1, v1, v5
	v_subrev_u32_e32 v5, s8, v1
	v_cmp_le_u32_e32 vcc, s8, v1
	s_nop 1
	v_cndmask_b32_e32 v1, v1, v5, vcc
	v_cndmask_b32_e32 v4, v4, v6, vcc
	v_add_u32_e32 v5, 1, v4
	v_cmp_le_u32_e32 vcc, s8, v1
	s_nop 1
	v_cndmask_b32_e32 v8, v4, v5, vcc
	v_mov_b32_e32 v9, 0
.LBB1_5:
	s_or_b64 exec, exec, s[0:1]
	s_mov_b32 s1, 0
	v_mov_b32_e32 v1, 0
	s_mul_i32 s0, s12, s7
	s_mul_hi_u32 s10, s12, s6
	s_add_i32 s11, s10, s0
	s_mul_i32 s10, s12, s6
	s_lshl_b64 s[12:13], s[10:11], 4
	s_add_u32 s4, s4, s12
	s_addc_u32 s5, s5, s13
	s_lshl_b64 s[10:11], s[10:11], 2
	s_add_u32 s2, s2, s10
	s_addc_u32 s3, s3, s11
	s_lshl_b32 s0, s6, 1
	s_mul_i32 s10, s6, 3
	s_mov_b32 s11, s1
	v_lshl_add_u64 v[2:3], v[8:9], 0, v[2:3]
	v_lshl_add_u64 v[2:3], v[2:3], 0, 1
	v_cmp_lt_u64_e32 vcc, 1, v[2:3]
	s_cmp_eq_u32 s8, 1
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[16:17], vcc, s[12:13]
	s_mov_b64 s[14:15], -1
	s_and_saveexec_b64 s[12:13], s[16:17]
	s_cbranch_execz .LBB1_9
	v_and_b32_e32 v4, -2, v2
	v_mov_b32_e32 v5, v3
	s_mov_b64 s[14:15], 0
	v_mov_b32_e32 v6, s8
	s_mov_b64 s[16:17], 0
.LBB1_7:
	v_mad_u64_u32 v[8:9], s[18:19], s16, v6, v[0:1]
	s_mul_i32 s18, s17, s8
	s_nop 0
	v_add_u32_e32 v9, s18, v9
	v_lshlrev_b64 v[8:9], 2, v[8:9]
	v_lshl_add_u64 v[10:11], s[4:5], 0, v[8:9]
	v_lshl_add_u64 v[12:13], s[6:7], 2, v[10:11]
	v_lshl_add_u64 v[14:15], s[0:1], 2, v[10:11]
	v_lshl_add_u64 v[16:17], s[10:11], 2, v[10:11]
	global_load_dwordx2 v[10:11], v[10:11], off
	global_load_dwordx2 v[12:13], v[12:13], off
	global_load_dwordx2 v[14:15], v[14:15], off
	global_load_dwordx2 v[16:17], v[16:17], off
	s_add_u32 s16, s16, 2
	s_addc_u32 s17, s17, 0
	v_cmp_eq_u64_e32 vcc, s[16:17], v[4:5]
	v_lshl_add_u64 v[8:9], s[2:3], 0, v[8:9]
	s_or_b64 s[14:15], vcc, s[14:15]
	s_waitcnt vmcnt(3)
	v_pk_add_f32 v[10:11], v[10:11], 0 op_sel_hi:[1,0]
	s_waitcnt vmcnt(2)
	v_pk_add_f32 v[10:11], v[10:11], v[12:13]
	s_waitcnt vmcnt(1)
	v_pk_add_f32 v[10:11], v[10:11], v[14:15]
	s_waitcnt vmcnt(0)
	v_pk_add_f32 v[10:11], v[10:11], v[16:17]
	global_store_dwordx2 v[8:9], v[10:11], off
	s_andn2_b64 exec, exec, s[14:15]
	s_cbranch_execnz .LBB1_7
	s_or_b64 exec, exec, s[14:15]
	v_mad_u64_u32 v[0:1], s[14:15], v4, s8, v[0:1]
	v_mov_b32_e32 v6, v1
	v_mad_u64_u32 v[6:7], s[14:15], v5, s8, v[6:7]
	v_mov_b32_e32 v1, v6
	v_cmp_ne_u64_e32 vcc, v[2:3], v[4:5]
	s_orn2_b64 s[14:15], vcc, exec
.LBB1_9:
	s_or_b64 exec, exec, s[12:13]
	s_and_b64 exec, exec, s[14:15]
	s_cbranch_execz .LBB1_12
	s_mov_b64 s[12:13], 0
.LBB1_11:
	v_lshlrev_b64 v[2:3], 2, v[0:1]
	v_lshl_add_u64 v[4:5], s[4:5], 0, v[2:3]
	v_lshl_add_u64 v[6:7], s[6:7], 2, v[4:5]
	v_lshl_add_u64 v[8:9], s[0:1], 2, v[4:5]
	v_lshl_add_u64 v[10:11], s[10:11], 2, v[4:5]
	global_load_dword v4, v[4:5], off
	global_load_dword v5, v[6:7], off
	global_load_dword v6, v[8:9], off
	global_load_dword v7, v[10:11], off
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[8:9]
	v_lshl_add_u64 v[2:3], s[2:3], 0, v[2:3]
	v_cmp_le_i64_e32 vcc, s[6:7], v[0:1]
	s_or_b64 s[12:13], vcc, s[12:13]
	s_waitcnt vmcnt(3)
	v_add_f32_e32 v4, 0, v4
	s_waitcnt vmcnt(2)
	v_add_f32_e32 v4, v4, v5
	s_waitcnt vmcnt(1)
	v_add_f32_e32 v4, v4, v6
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v4, v4, v7
	global_store_dword v[2:3], v4, off
	s_andn2_b64 exec, exec, s[12:13]
	s_cbranch_execnz .LBB1_11
.LBB1_12:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i
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
.Lfunc_end1:
	.size	_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i, .Lfunc_end1-_ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i

	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.num_vgpr, 18
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.num_agpr, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.numbered_sgpr, 20
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.private_seg_size, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.uses_vcc, 1
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.uses_flat_scratch, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.has_dyn_sized_stack, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.has_recursion, 0
	.set _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_6773fa27a5ceb4af,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_6773fa27a5ceb4af
__hip_cuid_6773fa27a5ceb4af:
	.byte	0
	.size	__hip_cuid_6773fa27a5ceb4af, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_6773fa27a5ceb4af
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
    .name:           _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i
    .private_segment_fixed_size: 0
    .sgpr_count:     28
    .sgpr_spill_count: 0
    .symbol:         _ZN4vllm3moe14moe_sum_kernelIfLi2EEEvPT_PKS2_i.kd
    .uses_dynamic_stack: false
    .vgpr_count:     20
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
    .name:           _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i
    .private_segment_fixed_size: 0
    .sgpr_count:     26
    .sgpr_spill_count: 0
    .symbol:         _ZN4vllm3moe14moe_sum_kernelIfLi4EEEvPT_PKS2_i.kd
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
