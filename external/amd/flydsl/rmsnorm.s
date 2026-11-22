; FlyDSL 304d441202a3 kernels/norm/rmsnorm_kernel.py, compiled for gfx950 by
; external/amd/flydsl/extract.py (case rmsnorm).
	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	rmsnorm_large_m_small_n_kernel_0
	.p2align	8
	.type	rmsnorm_large_m_small_n_kernel_0,@function
rmsnorm_large_m_small_n_kernel_0:
	s_load_dword s3, s[0:1], 0x50
	v_lshrrev_b32_e32 v1, 6, v0
	v_lshl_or_b32 v1, s2, 4, v1
	s_waitcnt lgkmcnt(0)
	v_cmp_le_i32_e32 vcc, s3, v1
	s_and_b64 s[2:3], vcc, exec
	s_cbranch_scc1 .LBB0_2
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s2, s[0:1], 0x10
	s_load_dwordx2 s[12:13], s[0:1], 0x18
	s_load_dwordx2 s[4:5], s[0:1], 0x38
	v_and_b32_e32 v2, 63, v0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	v_mul_lo_u32 v3, v1, s2
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, -1
	v_add_lshl_u32 v4, v3, v2, 2
	buffer_load_dword v5, v4, s[8:11], 0 offen
	buffer_load_dword v6, v4, s[8:11], 0 offen offset:256
	buffer_load_dword v7, v4, s[8:11], 0 offen offset:512
	buffer_load_dword v8, v4, s[8:11], 0 offen offset:768
	buffer_load_dword v9, v4, s[8:11], 0 offen offset:1024
	buffer_load_dword v10, v4, s[8:11], 0 offen offset:1280
	buffer_load_dword v11, v4, s[8:11], 0 offen offset:1536
	buffer_load_dword v12, v4, s[8:11], 0 offen offset:1792
	v_or_b32_e32 v0, 0x3c0, v0
	v_add_lshl_u32 v3, v3, v0, 2
	buffer_load_dword v13, v4, s[8:11], 0 offen offset:2048
	buffer_load_dword v14, v4, s[8:11], 0 offen offset:2304
	buffer_load_dword v15, v4, s[8:11], 0 offen offset:2560
	buffer_load_dword v16, v4, s[8:11], 0 offen offset:2816
	buffer_load_dword v17, v4, s[8:11], 0 offen offset:3072
	buffer_load_dword v18, v4, s[8:11], 0 offen offset:3328
	buffer_load_dword v19, v4, s[8:11], 0 offen offset:3584
	buffer_load_dword v20, v3, s[8:11], 0 offen
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	v_lshlrev_b32_e32 v21, 2, v2
	s_and_b32 s13, s13, 0xffff
	buffer_load_dword v22, v21, s[12:15], 0 offen
	v_mov_b32_e32 v24, 0
	v_mov_b32_e32 v23, 0
	s_load_dword s0, s[0:1], 0x48
	v_mov_b32_e32 v25, 0x3a800000
	s_mov_b32 s6, s10
	s_mov_b32 s7, s11
	s_and_b32 s5, s5, 0xffff
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v1, v1, s0
	v_add_lshl_u32 v2, v1, v2, 2
	s_waitcnt vmcnt(16)
	v_mul_f32_e32 v26, v5, v5
	s_waitcnt vmcnt(15)
	v_mul_f32_e32 v6, v6, v6
	s_waitcnt vmcnt(14)
	v_mul_f32_e32 v7, v7, v7
	v_add_f32_e32 v6, v26, v6
	s_waitcnt vmcnt(13)
	v_mul_f32_e32 v8, v8, v8
	v_add_f32_e32 v6, v6, v7
	s_waitcnt vmcnt(12)
	v_mul_f32_e32 v9, v9, v9
	v_add_f32_e32 v6, v6, v8
	s_waitcnt vmcnt(11)
	v_mul_f32_e32 v10, v10, v10
	v_add_f32_e32 v6, v6, v9
	s_waitcnt vmcnt(10)
	v_mul_f32_e32 v11, v11, v11
	v_add_f32_e32 v6, v6, v10
	s_waitcnt vmcnt(9)
	v_mul_f32_e32 v12, v12, v12
	v_add_f32_e32 v6, v6, v11
	s_waitcnt vmcnt(8)
	v_mul_f32_e32 v13, v13, v13
	v_add_f32_e32 v6, v6, v12
	s_waitcnt vmcnt(7)
	v_mul_f32_e32 v14, v14, v14
	v_add_f32_e32 v6, v6, v13
	s_waitcnt vmcnt(6)
	v_mul_f32_e32 v15, v15, v15
	v_add_f32_e32 v6, v6, v14
	s_waitcnt vmcnt(5)
	v_mul_f32_e32 v16, v16, v16
	v_add_f32_e32 v6, v6, v15
	s_waitcnt vmcnt(4)
	v_mul_f32_e32 v17, v17, v17
	v_add_f32_e32 v6, v6, v16
	s_waitcnt vmcnt(3)
	v_mul_f32_e32 v18, v18, v18
	v_add_f32_e32 v6, v6, v17
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v19, v19, v19
	v_add_f32_e32 v6, v6, v18
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v20, v20, v20
	v_add_f32_e32 v6, v6, v19
	v_add_f32_e32 v6, v6, v20
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_mov_b32_dpp v24, v6 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_add_f32_e32 v6, v6, v24
	s_nop 1
	v_mov_b32_dpp v23, v6 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_add_f32_e32 v6, v6, v23
	s_nop 0
	v_readlane_b32 s1, v6, 63
	s_nop 1
	v_mul_f32_e32 v6, s1, v25
	v_add_f32_e32 v6, 0x3727c5ac, v6
	v_rsq_f32_e32 v6, v6
	s_nop 0
	v_mul_f32_e32 v5, v5, v6
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v22, v5
	buffer_store_dword v5, v2, s[4:7], 0 offen
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:256
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:256
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v5, v6
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v7, v5
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:256
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:512
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:512
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:512
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:768
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:768
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:768
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:1024
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:1024
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:1024
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:1280
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:1280
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:1280
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:1536
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:1536
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:1536
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:1792
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:1792
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:1792
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:2048
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:2048
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:2048
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:2304
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:2304
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:2304
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:2560
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:2560
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:2560
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:2816
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:2816
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:2816
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:3072
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:3072
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:3072
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:3328
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:3328
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:3328
	buffer_load_dword v5, v4, s[8:11], 0 offen offset:3584
	s_nop 0
	buffer_load_dword v7, v21, s[12:15], 0 offen offset:3584
	v_lshlrev_b32_e32 v4, 2, v0
	v_add_lshl_u32 v0, v1, v0, 2
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v5, v6, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v5, v5, v7
	buffer_store_dword v5, v2, s[4:7], 0 offen offset:3584
	buffer_load_dword v2, v3, s[8:11], 0 offen
	s_nop 0
	buffer_load_dword v5, v4, s[12:15], 0 offen
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v2, v6, v2
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v2, v5
	buffer_store_dword v2, v0, s[4:7], 0 offen
.LBB0_2:
	s_endpgm
.Lfunc_end0:
	.size	rmsnorm_large_m_small_n_kernel_0, .Lfunc_end0-rmsnorm_large_m_small_n_kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_large_m_small_n_kernel_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 84
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
		.amdhsa_next_free_vgpr 27
		.amdhsa_next_free_sgpr 16
		.amdhsa_accum_offset 28
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

	.set .Lrmsnorm_large_m_small_n_kernel_0.num_vgpr, 27
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_agpr, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.numbered_sgpr, 16
	.set .Lrmsnorm_large_m_small_n_kernel_0.num_named_barrier, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.private_seg_size, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_vcc, 1
	.set .Lrmsnorm_large_m_small_n_kernel_0.uses_flat_scratch, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_dyn_sized_stack, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_recursion, 0
	.set .Lrmsnorm_large_m_small_n_kernel_0.has_indirect_call, 0
	.globl	rmsnorm_kernel_1
	.p2align	8
	.type	rmsnorm_kernel_1,@function
rmsnorm_kernel_1:
	s_load_dwordx2 s[4:5], s[0:1], 0x0
	s_load_dword s3, s[0:1], 0x10
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, -1
	v_mov_b32_e32 v10, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	s_mul_i32 s3, s2, s3
	v_add_lshl_u32 v2, s3, v0, 2
	buffer_load_dword v6, v2, s[4:7], 0 offen
	buffer_load_dword v7, v2, s[4:7], 0 offen offset:1024
	buffer_load_dword v8, v2, s[4:7], 0 offen offset:2048
	buffer_load_dword v9, v2, s[4:7], 0 offen offset:3072
	v_mov_b32_e32 v11, 0
	v_and_b32_e32 v12, 63, v0
	v_mov_b32_e32 v5, 0
	v_add_u32_e32 v4, 0x400, v2
	v_add_u32_e32 v3, 0x800, v2
	v_add_u32_e32 v1, 0xc00, v2
	v_cmp_eq_u32_e32 vcc, 0, v12
	s_waitcnt vmcnt(3)
	v_mul_f32_e32 v6, v6, v6
	s_waitcnt vmcnt(2)
	v_mul_f32_e32 v7, v7, v7
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v8, v8, v8
	v_add_f32_e32 v6, v6, v7
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v9, v9, v9
	v_add_f32_e32 v6, v6, v8
	v_add_f32_e32 v6, v6, v9
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_mov_b32_dpp v10, v6 row_bcast:15 row_mask:0xa bank_mask:0xf
	v_add_f32_e32 v6, v6, v10
	s_nop 1
	v_mov_b32_dpp v11, v6 row_bcast:31 row_mask:0xc bank_mask:0xf
	v_add_f32_e32 v6, v6, v11
	s_nop 0
	v_readlane_b32 s3, v6, 63
	s_and_saveexec_b64 s[8:9], vcc
	v_lshrrev_b32_e32 v6, 4, v0
	v_mov_b32_e32 v7, s3
	ds_write_b32 v6, v7
	s_or_b64 exec, exec, s[8:9]
	s_load_dwordx2 s[12:13], s[0:1], 0x18
	s_load_dwordx2 s[8:9], s[0:1], 0x38
	s_load_dword s3, s[0:1], 0x48
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	s_waitcnt lgkmcnt(0)
	s_and_b32 s13, s13, 0xffff
	s_barrier
	buffer_load_dword v2, v2, s[4:7], 0 offen
	v_lshlrev_b32_e32 v10, 2, v0
	buffer_load_dword v11, v10, s[12:15], 0 offen
	ds_read_b128 v[6:9], v5
	s_mul_i32 s2, s2, s3
	s_mov_b32 s10, s6
	s_mov_b32 s11, s7
	s_and_b32 s9, s9, 0xffff
	s_waitcnt lgkmcnt(0)
	v_pk_add_f32 v[6:7], v[6:7], v[8:9]
	v_add_lshl_u32 v0, s2, v0, 2
	v_add_f32_e32 v5, v6, v7
	v_mul_f32_e32 v5, 0x3a800000, v5
	v_add_f32_e32 v5, 0x3727c5ac, v5
	v_rsq_f32_e32 v5, v5
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v2, v2, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v11, v2
	buffer_store_dword v2, v0, s[8:11], 0 offen
	buffer_load_dword v2, v4, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v6, v10, s[12:15], 0 offen offset:1024
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v2, v2, v5
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v6, v2
	buffer_store_dword v2, v0, s[8:11], 0 offen offset:1024
	buffer_load_dword v2, v3, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v4, v10, s[12:15], 0 offen offset:2048
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v2, v5, v2
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v2, v2, v4
	buffer_store_dword v2, v0, s[8:11], 0 offen offset:2048
	buffer_load_dword v2, v1, s[4:7], 0 offen
	s_nop 0
	buffer_load_dword v3, v10, s[12:15], 0 offen offset:3072
	s_waitcnt vmcnt(1)
	v_mul_f32_e32 v1, v5, v2
	s_waitcnt vmcnt(0)
	v_mul_f32_e32 v1, v1, v3
	buffer_store_dword v1, v0, s[8:11], 0 offen offset:3072
	s_endpgm
.Lfunc_end1:
	.size	rmsnorm_kernel_1, .Lfunc_end1-rmsnorm_kernel_1
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel rmsnorm_kernel_1
		.amdhsa_group_segment_fixed_size 16
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 80
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
		.amdhsa_next_free_vgpr 13
		.amdhsa_next_free_sgpr 16
		.amdhsa_accum_offset 16
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

	.set .Lrmsnorm_kernel_1.num_vgpr, 13
	.set .Lrmsnorm_kernel_1.num_agpr, 0
	.set .Lrmsnorm_kernel_1.numbered_sgpr, 16
	.set .Lrmsnorm_kernel_1.num_named_barrier, 0
	.set .Lrmsnorm_kernel_1.private_seg_size, 0
	.set .Lrmsnorm_kernel_1.uses_vcc, 1
	.set .Lrmsnorm_kernel_1.uses_flat_scratch, 0
	.set .Lrmsnorm_kernel_1.has_dyn_sized_stack, 0
	.set .Lrmsnorm_kernel_1.has_recursion, 0
	.set .Lrmsnorm_kernel_1.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 84
    .max_flat_workgroup_size: 1024
    .name:           rmsnorm_large_m_small_n_kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 1024
      - 1
      - 1
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_large_m_small_n_kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     27
    .vgpr_spill_count: 0
    .wavefront_size: 64
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           16
        .value_kind:     by_value
      - .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .offset:         64
        .size:           16
        .value_kind:     by_value
    .group_segment_fixed_size: 16
    .kernarg_segment_align: 8
    .kernarg_segment_size: 80
    .max_flat_workgroup_size: 256
    .name:           rmsnorm_kernel_1
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     22
    .sgpr_spill_count: 0
    .symbol:         rmsnorm_kernel_1.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     13
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
