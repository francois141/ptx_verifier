	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib,"axG",@progbits,_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib,comdat
	.protected	_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib
	.globl	_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib
	.p2align	8
	.type	_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib,@function
_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib:
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.p2align	8
.LBB0_0:
	s_load_dwordx8 s[20:27], s[0:1], 0x58
	s_waitcnt lgkmcnt(0)
	v_cvt_f32_u32_e32 v1, s26
	s_load_dwordx2 s[40:41], s[0:1], 0x9c
	v_rcp_iflag_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_bitcmp1_b32 s41, 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_cselect_b64 s[18:19], -1, 0
	s_mov_b32 s37, 0
	s_sub_i32 s17, 0, s26
	v_readfirstlane_b32 s28, v1
	s_mul_i32 s17, s17, s28
	s_mul_hi_u32 s17, s28, s17
	s_add_i32 s28, s28, s17
	s_mul_hi_u32 s17, s16, s28
	s_mul_i32 s28, s17, s26
	s_sub_i32 s28, s16, s28
	s_add_i32 s29, s17, 1
	s_sub_i32 s30, s28, s26
	s_cmp_ge_u32 s28, s26
	s_cselect_b32 s17, s29, s17
	s_cselect_b32 s28, s30, s28
	s_add_i32 s29, s17, 1
	s_cmp_ge_u32 s28, s26
	s_cselect_b32 s36, s29, s17
	s_lshl_b64 s[42:43], s[36:37], 3
	s_add_u32 s14, s14, s42
	s_addc_u32 s15, s15, s43
	s_load_dwordx2 s[34:35], s[14:15], 0x0
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i64_e64 s[38:39], s[34:35], -1
	s_or_b64 s[14:15], s[18:19], s[38:39]
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_12
	s_load_dwordx4 s[28:31], s[0:1], 0x78
	s_mul_i32 s14, s36, s26
	s_sub_i32 s26, s16, s14
	s_ashr_i32 s14, s20, 31
	s_mul_hi_u32 s15, s36, s20
	s_mul_i32 s14, s36, s14
	s_add_i32 s15, s15, s14
	s_mul_i32 s14, s36, s20
	s_lshl_b64 s[14:15], s[14:15], 2
	s_add_u32 s14, s2, s14
	s_addc_u32 s15, s3, s15
	s_ashr_i32 s2, s21, 31
	s_mul_i32 s2, s26, s2
	s_mul_hi_u32 s3, s26, s21
	s_add_i32 s3, s3, s2
	s_mul_i32 s2, s26, s21
	s_lshl_b64 s[2:3], s[2:3], 2
	s_add_u32 s16, s14, s2
	s_addc_u32 s2, s15, s3
	s_waitcnt lgkmcnt(0)
	s_lshl_b32 s18, s29, 2
	s_and_b32 s17, s2, 0xffff
	s_mov_b32 s19, 0x20000
	v_lshlrev_b32_e32 v10, 4, v0
	buffer_load_dwordx4 v[2:5], v10, s[16:19], 0 offen
	s_mov_b32 s14, s29
	v_cmp_gt_u32_e64 s[2:3], 32, v0
	v_mov_b64_e32 v[6:7], 0
	v_mov_b64_e32 v[8:9], 0
	s_and_saveexec_b64 s[16:17], s[2:3]
	s_cbranch_execz .LBB0_3
	s_load_dwordx4 s[44:47], s[0:1], 0x38
	s_load_dwordx2 s[20:21], s[0:1], 0x48
	v_mov_b32_e32 v6, s40
	s_waitcnt lgkmcnt(0)
	s_add_u32 s42, s44, s42
	s_addc_u32 s43, s45, s43
	s_load_dwordx2 s[42:43], s[42:43], 0x0
	s_ashr_i32 s15, s40, 31
	s_add_i32 s31, s40, -1
	v_mov_b32_e32 v7, s15
	s_ashr_i32 s15, s31, 31
	s_waitcnt lgkmcnt(0)
	v_cmp_lt_i64_e32 vcc, s[42:43], v[6:7]
	v_cmp_gt_i64_e64 s[40:41], s[42:43], -1
	s_and_b64 s[44:45], vcc, exec
	s_cselect_b32 s43, s43, s15
	s_cselect_b32 s42, s42, s31
	s_lshl_b64 s[42:43], s[42:43], 5
	s_and_b64 s[40:41], s[40:41], exec
	s_cselect_b32 s41, s43, 0
	s_cselect_b32 s40, s42, 0
	s_lshl_b64 s[40:41], s[40:41], 2
	s_add_u32 s20, s20, s40
	s_addc_u32 s21, s21, s41
	s_add_u32 s40, s46, s40
	s_addc_u32 s41, s47, s41
	v_lshlrev_b32_e32 v1, 2, v0
	s_ashr_i32 s15, s22, 31
	s_mul_hi_u32 s31, s36, s22
	s_mul_i32 s15, s36, s15
	s_add_i32 s43, s31, s15
	s_mul_i32 s42, s36, s22
	s_ashr_i32 s15, s23, 31
	s_mul_hi_u32 s22, s26, s23
	s_mul_i32 s15, s26, s15
	s_add_i32 s45, s22, s15
	s_mul_i32 s44, s26, s23
	s_lshl_b64 s[22:23], s[42:43], 2
	s_add_u32 s15, s4, s22
	s_addc_u32 s22, s5, s23
	s_lshl_b64 s[4:5], s[44:45], 2
	s_add_u32 s4, s15, s4
	s_addc_u32 s5, s22, s5
	global_load_dword v7, v1, s[40:41]
	global_load_dword v11, v1, s[4:5]
	global_load_dword v12, v1, s[4:5] offset:128
	global_load_dword v13, v1, s[20:21]
	v_or_b32_e32 v6, 32, v0
	v_mov_b64_e32 v[8:9], v[0:1]
.LBB0_3:
	s_or_b64 exec, exec, s[16:17]
	s_ashr_i32 s4, s24, 31
	s_mul_hi_u32 s5, s36, s24
	s_mul_i32 s4, s36, s4
	s_add_i32 s5, s5, s4
	s_mul_i32 s4, s36, s24
	s_lshl_b64 s[4:5], s[4:5], 2
	s_add_u32 s15, s12, s4
	s_addc_u32 s22, s13, s5
	s_ashr_i32 s16, s25, 31
	s_mul_hi_u32 s17, s26, s25
	s_mul_i32 s16, s26, s16
	s_add_i32 s17, s17, s16
	s_mul_i32 s16, s26, s25
	s_lshl_b64 s[20:21], s[16:17], 2
	s_add_u32 s16, s15, s20
	s_addc_u32 s17, s22, s21
	s_ashr_i32 s15, s29, 31
	s_and_b32 s17, s17, 0xffff
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[2:5], v10, s[16:19], 0 offen
	s_cmp_eq_u32 s26, 0
	s_cselect_b64 s[16:17], -1, 0
	s_and_b64 s[16:17], s[16:17], s[38:39]
	s_andn2_b64 vcc, exec, s[16:17]
	s_mov_b64 s[16:17], -1
	s_cbranch_vccnz .LBB0_9
	s_ashr_i32 s16, s27, 31
	s_mul_hi_u32 s17, s36, s27
	s_mul_i32 s16, s36, s16
	s_add_i32 s17, s17, s16
	s_mul_i32 s16, s36, s27
	s_lshl_b64 s[16:17], s[16:17], 2
	s_add_u32 s16, s6, s16
	s_addc_u32 s6, s7, s17
	s_and_b32 s17, s6, 0xffff
	buffer_load_dwordx4 v[0:3], v10, s[16:19], 0 offen
	s_and_saveexec_b64 s[6:7], s[2:3]
	s_cbranch_execz .LBB0_6
	s_ashr_i32 s16, s28, 31
	s_mul_hi_u32 s17, s36, s28
	s_mul_i32 s16, s36, s16
	s_add_i32 s17, s17, s16
	s_mul_i32 s16, s36, s28
	s_lshl_b64 s[16:17], s[16:17], 2
	s_add_u32 s8, s8, s16
	s_addc_u32 s9, s9, s17
	v_lshlrev_b32_e32 v4, 2, v8
	v_lshlrev_b32_e32 v5, 2, v6
	global_load_dword v4, v4, s[8:9]
	global_load_dword v5, v5, s[8:9]
.LBB0_6:
	s_or_b64 exec, exec, s[6:7]
	s_load_dword s0, s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s1, s0, 31
	s_mul_hi_u32 s6, s34, s0
	s_mul_i32 s7, s35, s0
	s_mul_i32 s0, s34, s0
	s_mul_i32 s1, s34, s1
	s_add_i32 s1, s6, s1
	s_add_i32 s1, s1, s7
	s_lshl_b64 s[6:7], s[0:1], 2
	s_add_u32 s16, s10, s6
	s_addc_u32 s0, s11, s7
	s_and_b32 s17, s0, 0xffff
	s_waitcnt vmcnt(0)
	buffer_store_dwordx4 v[0:3], v10, s[16:19], 0 offen
	s_mov_b64 s[16:17], 0
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_8
	s_mov_b64 s[16:17], exec
	s_lshl_b64 s[8:9], s[14:15], 2
	s_add_u32 s8, s10, s8
	s_addc_u32 s9, s11, s9
	s_add_u32 s6, s8, s6
	s_addc_u32 s7, s9, s7
	v_lshlrev_b32_e32 v0, 2, v6
	v_mul_f32_e32 v1, v13, v4
	v_fmac_f32_e32 v1, v7, v5
	v_lshlrev_b32_e32 v2, 2, v8
	v_mul_f32_e32 v3, v13, v5
	v_fma_f32 v3, v7, v4, -v3
	global_store_dword v2, v3, s[6:7]
	global_store_dword v0, v1, s[6:7]
.LBB0_8:
	s_or_b64 exec, exec, s[0:1]
.LBB0_9:
	s_and_saveexec_b64 s[0:1], s[16:17]
	s_cbranch_execz .LBB0_12
	s_and_b64 exec, exec, s[2:3]
	s_cbranch_execz .LBB0_12
	s_ashr_i32 s1, s30, 31
	s_sub_u32 s0, s14, s30
	s_subb_u32 s1, s15, s1
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s12, s0
	s_addc_u32 s1, s13, s1
	s_add_u32 s0, s0, s4
	s_addc_u32 s1, s1, s5
	s_add_u32 s0, s0, s20
	s_addc_u32 s1, s1, s21
	v_lshlrev_b32_e32 v0, 2, v6
	v_mul_f32_e32 v1, v12, v7
	v_fmac_f32_e32 v1, v11, v13
	v_lshlrev_b32_e32 v2, 2, v8
	v_mul_f32_e32 v3, v12, v13
	v_fma_f32 v3, v11, v7, -v3
	global_store_dword v2, v3, s[0:1] offset:256
	global_store_dword v0, v1, s[0:1] offset:256
.LBB0_12:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 164
		.amdhsa_user_sgpr_count 16
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 14
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 14
		.amdhsa_next_free_sgpr 48
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
	.section	.text._ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib,"axG",@progbits,_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib,comdat
.Lfunc_end0:
	.size	_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib, .Lfunc_end0-_ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib

	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.num_vgpr, 14
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.num_agpr, 0
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.numbered_sgpr, 48
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.private_seg_size, 0
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.uses_vcc, 1
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.uses_flat_scratch, 0
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.has_dyn_sized_stack, 0
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.has_recursion, 0
	.set _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_b02a186e994ca32e,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_b02a186e994ca32e
__hip_cuid_b02a186e994ca32e:
	.byte	0
	.size	__hip_cuid_b02a186e994ca32e, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_b02a186e994ca32e
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .actual_access:  read_only
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
      - .actual_access:  write_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .offset:         80
        .size:           4
        .value_kind:     by_value
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     by_value
      - .offset:         92
        .size:           4
        .value_kind:     by_value
      - .offset:         96
        .size:           4
        .value_kind:     by_value
      - .offset:         100
        .size:           4
        .value_kind:     by_value
      - .offset:         104
        .size:           4
        .value_kind:     by_value
      - .offset:         108
        .size:           4
        .value_kind:     by_value
      - .offset:         112
        .size:           4
        .value_kind:     by_value
      - .offset:         116
        .size:           4
        .value_kind:     by_value
      - .offset:         120
        .size:           4
        .value_kind:     by_value
      - .offset:         124
        .size:           4
        .value_kind:     by_value
      - .offset:         128
        .size:           4
        .value_kind:     by_value
      - .offset:         132
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         136
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         144
        .size:           8
        .value_kind:     global_buffer
      - .offset:         152
        .size:           1
        .value_kind:     by_value
      - .offset:         153
        .size:           1
        .value_kind:     by_value
      - .offset:         156
        .size:           4
        .value_kind:     by_value
      - .offset:         160
        .size:           1
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 164
    .max_flat_workgroup_size: 1024
    .name:           _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         _ZN5aiter49fuse_qk_rope_concat_and_cache_mla_per_head_kernelIfffLN4vllm18Fp8KVCacheDataTypeE0ELS2_0ELi4EEEvPKT_S5_S5_S5_PT0_PT1_PKxSB_S5_S5_iiiiiiiiiiiiiiPKfSD_bbib.kd
    .uses_dynamic_stack: false
    .vgpr_count:     14
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
