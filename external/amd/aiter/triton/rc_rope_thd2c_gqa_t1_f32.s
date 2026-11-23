	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32 ; -- Begin function _rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
	.p2align	8
	.type	_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32,@function
_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32: ; @_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.3:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/rope" "rope.py"
	.loc	1 1474 0 prologue_end           ; rope.py:1474:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.4:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[36:37], s[2:3]
.Ltmp1:
	.loc	1 1531 14 is_stmt 1             ; rope.py:1531:14
	v_readfirstlane_b32 s2, v0
	.loc	1 1633 9                        ; rope.py:1633:9
	s_and_b32 s2, s2, 0xc0
	s_mov_b64 s[24:25], s[10:11]
	.loc	1 1530 32                       ; rope.py:1530:32
	v_and_or_b32 v1, v0, 48, s2
	v_lshrrev_b32_e32 v1, 4, v1
	.loc	1 1530 14 is_stmt 0             ; rope.py:1530:14
	v_lshl_or_b32 v9, s16, 4, v1
	.loc	1 1536 15 is_stmt 1             ; rope.py:1536:15
	v_lshlrev_b32_e32 v1, 2, v9
	v_bfrev_b32_e32 v8, 1
	.loc	1 1532 14                       ; rope.py:1532:14
	v_cmp_gt_i32_e32 vcc, 1, v9
	.loc	1 1536 15                       ; rope.py:1536:15
	s_and_b32 s25, s25, 0xffff
	s_mov_b32 s27, 0x27000
	s_mov_b32 s26, 0x7ffffffe
	v_cndmask_b32_e32 v1, v8, v1, vcc
	buffer_load_dword v1, v1, s[24:27], 0 offen
	s_mov_b64 s[28:29], s[6:7]
	s_load_dwordx2 s[2:3], s[0:1], 0x38
	s_load_dwordx2 s[6:7], s[0:1], 0x48
	s_load_dword s16, s[0:1], 0x50
	.loc	1 1531 14                       ; rope.py:1531:14
	v_lshlrev_b32_e32 v0, 2, v0
	v_and_b32_e32 v10, 60, v0
	.loc	1 1579 71                       ; rope.py:1579:71
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s3, s17
	.loc	1 1581 17                       ; rope.py:1581:17
	v_mul_lo_u32 v0, v9, s2
	v_add_u32_e32 v2, s3, v10
	.loc	1 1581 9 is_stmt 0              ; rope.py:1581:9
	v_add_lshl_u32 v0, v2, v0, 2
	s_and_b32 s37, s37, 0xffff
	s_mov_b32 s38, s26
	s_mov_b32 s39, s27
	v_cndmask_b32_e32 v0, v8, v0, vcc
	buffer_load_dwordx4 v[12:15], v0, s[36:39], 0 offen
	.loc	1 1551 17 is_stmt 1             ; rope.py:1551:17
	v_add_u32_e32 v0, 0x3fffffe0, v10
	.loc	1 1549 18                       ; rope.py:1549:18
	v_cmp_gt_u32_e64 s[2:3], 32, v10
	.loc	1 1564 11                       ; rope.py:1564:11
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s10, s26
	.loc	1 1548 26                       ; rope.py:1548:26
	v_cndmask_b32_e64 v0, v0, v10, s[2:3]
	.loc	1 1564 11                       ; rope.py:1564:11
	s_mov_b32 s11, s27
	.loc	1 1563 11                       ; rope.py:1563:11
	s_and_b32 s29, s29, 0xffff
	s_mov_b32 s30, s26
	s_mov_b32 s31, s27
	.loc	1 1595 11                       ; rope.py:1595:11
	s_mul_i32 s16, s16, s17
	.loc	1 1599 14                       ; rope.py:1599:14
	v_mul_lo_u32 v11, v9, s7
	v_add_u32_e32 v16, s16, v10
	.loc	1 1599 5 is_stmt 0              ; rope.py:1599:5
	v_add_lshl_u32 v11, v16, v11, 2
	s_and_b32 s13, s13, 0xffff
	s_mov_b64 s[20:21], s[14:15]
	s_mov_b32 s14, s26
	s_mov_b32 s15, s27
	v_cndmask_b32_e32 v11, v8, v11, vcc
	.loc	1 1609 8 is_stmt 1              ; rope.py:1609:8
	s_cmp_gt_i32 s17, 1
	.loc	1 1563 19                       ; rope.py:1563:19
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v1, v1, s6
	.loc	1 1563 11 is_stmt 0             ; rope.py:1563:11
	v_add_lshl_u32 v0, v1, v0, 2
	v_cndmask_b32_e32 v0, v8, v0, vcc
	.loc	1 1564 11 is_stmt 1             ; rope.py:1564:11
	buffer_load_dwordx4 v[4:7], v0, s[8:11], 0 offen
.Ltmp2:
	.loc	1 51 21                         ; rope.py:51:21 @[ rope.py:1584:21 ]
	s_waitcnt vmcnt(1)
	v_cndmask_b32_e64 v16, -v13, v13, s[2:3]
.Ltmp3:
	.loc	1 1563 11                       ; rope.py:1563:11
	buffer_load_dwordx4 v[0:3], v0, s[28:31], 0 offen
.Ltmp4:
	.loc	1 51 21                         ; rope.py:51:21 @[ rope.py:1584:21 ]
	v_cndmask_b32_e64 v17, -v12, v12, s[2:3]
	v_cndmask_b32_e64 v18, -v15, v15, s[2:3]
	v_cndmask_b32_e64 v19, -v14, v14, s[2:3]
.Ltmp5:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1584:21 ] ] ]
	v_mov_b32_dpp v17, v17 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp6:
	.loc	2 330 12 is_stmt 0              ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1584:21 ] ] ]
	v_mov_b32_dpp v16, v16 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v18 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v19 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v20, v16 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v21, v17 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v18 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v19 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v20 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v21 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp7:
	.loc	1 1597 23 is_stmt 1             ; rope.py:1597:23
	s_waitcnt vmcnt(1)
	v_pk_mul_f32 v[18:19], v[4:5], v[18:19]
	v_pk_mul_f32 v[16:17], v[6:7], v[16:17]
	.loc	1 1597 13 is_stmt 0             ; rope.py:1597:13
	s_waitcnt vmcnt(0)
	v_pk_fma_f32 v[12:13], v[0:1], v[12:13], v[18:19]
	v_pk_fma_f32 v[14:15], v[2:3], v[14:15], v[16:17]
	.loc	1 1599 5 is_stmt 1              ; rope.py:1599:5
	buffer_store_dwordx4 v[12:15], v11, s[12:15], 0 offen
	.loc	1 1609 5                        ; rope.py:1609:5
	s_cbranch_scc1 .LBB0_2
; %bb.1:
	.loc	1 0 5 is_stmt 0                 ; rope.py:0:5
	s_load_dwordx2 s[8:9], s[0:1], 0x40
	s_load_dwordx2 s[10:11], s[0:1], 0x54
	.loc	1 1615 13 is_stmt 1             ; rope.py:1615:13
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s26
	s_mov_b32 s7, s27
	.loc	1 1613 15                       ; rope.py:1613:15
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s9, s17
	.loc	1 1615 21                       ; rope.py:1615:21
	v_mul_lo_u32 v11, v9, s8
	v_add_u32_e32 v12, s0, v10
	.loc	1 1615 13 is_stmt 0             ; rope.py:1615:13
	v_add_lshl_u32 v11, v12, v11, 2
	v_cndmask_b32_e32 v11, v8, v11, vcc
	buffer_load_dwordx4 v[12:15], v11, s[4:7], 0 offen
	.loc	1 1629 15 is_stmt 1             ; rope.py:1629:15
	s_mul_i32 s0, s11, s17
	.loc	1 1633 18                       ; rope.py:1633:18
	v_mul_lo_u32 v9, v9, s10
	v_add_u32_e32 v10, s0, v10
	.loc	1 1633 9 is_stmt 0              ; rope.py:1633:9
	v_add_lshl_u32 v9, v10, v9, 2
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s26
	s_mov_b32 s23, s27
.Ltmp8:
	.loc	1 51 21 is_stmt 1               ; rope.py:51:21 @[ rope.py:1618:25 ]
	s_waitcnt vmcnt(0)
	v_cndmask_b32_e64 v10, -v13, v13, s[2:3]
	v_cndmask_b32_e64 v11, -v12, v12, s[2:3]
	v_cndmask_b32_e64 v16, -v15, v15, s[2:3]
	v_cndmask_b32_e64 v17, -v14, v14, s[2:3]
.Ltmp9:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1618:25 ] ] ]
	v_mov_b32_dpp v11, v11 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp10:
	.loc	2 330 12 is_stmt 0              ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1618:25 ] ] ]
	v_mov_b32_dpp v10, v10 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v10 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v11 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v16 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v17 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v18, v10 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v19, v11 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v11, v16 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v10, v17 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v17, v18 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v16, v19 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp11:
	.loc	1 1631 27 is_stmt 1             ; rope.py:1631:27
	v_pk_mul_f32 v[4:5], v[4:5], v[16:17]
	v_pk_mul_f32 v[6:7], v[6:7], v[10:11]
	.loc	1 1631 17 is_stmt 0             ; rope.py:1631:17
	v_pk_fma_f32 v[0:1], v[0:1], v[12:13], v[4:5]
	v_pk_fma_f32 v[2:3], v[2:3], v[14:15], v[6:7]
	.loc	1 1633 9 is_stmt 1              ; rope.py:1633:9
	v_cndmask_b32_e32 v4, v8, v9, vcc
	buffer_store_dwordx4 v[0:3], v4, s[20:23], 0 offen
.LBB0_2:
	.loc	1 1474 1                        ; rope.py:1474:1
	s_endpgm
.Ltmp12:
.Lfunc_end0:
	.size	_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32, .Lfunc_end0-_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 112
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 22
		.amdhsa_next_free_sgpr 40
		.amdhsa_accum_offset 24
		.amdhsa_reserve_vcc 1
		.amdhsa_reserve_xnack_mask 1
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
                                        ; -- End function
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.num_vgpr, 22
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.num_agpr, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.numbered_sgpr, 40
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.num_named_barrier, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.private_seg_size, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.uses_vcc, 1
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.uses_flat_scratch, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.has_dyn_sized_stack, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.has_recursion, 0
	.set .L_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1444
; TotalNumSgprs: 46
; NumVgprs: 22
; NumAgprs: 0
; TotalNumVgprs: 22
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 5
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 46
; NumVGPRsForWavesPerEU: 22
; AccumOffset: 24
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 5
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	.debug_abbrev,"",@progbits
	.byte	1                               ; Abbreviation Code
	.byte	17                              ; DW_TAG_compile_unit
	.byte	1                               ; DW_CHILDREN_yes
	.byte	37                              ; DW_AT_producer
	.byte	14                              ; DW_FORM_strp
	.byte	19                              ; DW_AT_language
	.byte	5                               ; DW_FORM_data2
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	16                              ; DW_AT_stmt_list
	.byte	23                              ; DW_FORM_sec_offset
	.byte	27                              ; DW_AT_comp_dir
	.byte	14                              ; DW_FORM_strp
	.ascii	"\341\177"                      ; DW_AT_APPLE_optimized
	.byte	25                              ; DW_FORM_flag_present
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	2                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	0                               ; DW_CHILDREN_no
	.byte	3                               ; DW_AT_name
	.byte	14                              ; DW_FORM_strp
	.byte	32                              ; DW_AT_inline
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	3                               ; Abbreviation Code
	.byte	46                              ; DW_TAG_subprogram
	.byte	1                               ; DW_CHILDREN_yes
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	4                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	5                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	11                              ; DW_FORM_data1
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	6                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	0                               ; DW_CHILDREN_no
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	7                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	17                              ; DW_AT_low_pc
	.byte	1                               ; DW_FORM_addr
	.byte	18                              ; DW_AT_high_pc
	.byte	6                               ; DW_FORM_data4
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x104 DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
                                        ; DW_AT_APPLE_optimized
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0xde DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x62 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	1584                            ; DW_AT_call_line
	.byte	21                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x4e:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp5                          ; DW_AT_low_pc
	.long	.Ltmp6-.Ltmp5                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	54                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x62:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp5                          ; DW_AT_low_pc
	.long	.Ltmp6-.Ltmp5                   ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	5                               ; Abbrev [5] 0x78:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp6                          ; DW_AT_low_pc
	.long	.Ltmp7-.Ltmp6                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	62                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x8c:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp6                          ; DW_AT_low_pc
	.long	.Ltmp7-.Ltmp6                   ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	7                               ; Abbrev [7] 0xa3:0x6a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp8                          ; DW_AT_low_pc
	.long	.Ltmp11-.Ltmp8                  ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.short	1618                            ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0xb8:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp9                          ; DW_AT_low_pc
	.long	.Ltmp10-.Ltmp9                  ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	54                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0xcc:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp9                          ; DW_AT_low_pc
	.long	.Ltmp10-.Ltmp9                  ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	5                               ; Abbrev [5] 0xe2:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp10                         ; DW_AT_low_pc
	.long	.Ltmp11-.Ltmp10                 ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	62                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0xf6:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp10                         ; DW_AT_low_pc
	.long	.Ltmp11-.Ltmp10                 ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"rope.py"                       ; string offset=7 ; rope.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/rope" ; string offset=15 ; /work/aiter/aiter/ops/triton/_triton_kernels/rope
.Linfo_string3:
	.asciz	"_rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32" ; string offset=65 ; _rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
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
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           4
        .value_kind:     by_value
      - .offset:         60
        .size:           4
        .value_kind:     by_value
      - .offset:         64
        .size:           4
        .value_kind:     by_value
      - .offset:         68
        .size:           4
        .value_kind:     by_value
      - .offset:         72
        .size:           4
        .value_kind:     by_value
      - .offset:         76
        .size:           4
        .value_kind:     by_value
      - .offset:         80
        .size:           4
        .value_kind:     by_value
      - .offset:         84
        .size:           4
        .value_kind:     by_value
      - .offset:         88
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         104
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 112
    .max_flat_workgroup_size: 256
    .name:           _rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32
    .private_segment_fixed_size: 0
    .sgpr_count:     46
    .sgpr_spill_count: 0
    .symbol:         _rope_kernel_cached_thd_2c_gqa_onehead_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_16_G_2_BLOCK_D_64_BLOCK_D_HALF_32.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     22
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa--gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
	.section	.debug_line,"",@progbits
.Lline_table_start0:
