	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1 ; -- Begin function _rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
	.p2align	8
	.type	_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1,@function
_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1: ; @_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/rope" "rope.py"
	.loc	1 883 0 prologue_end            ; rope.py:883:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.2:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[28:29], s[14:15]
	s_load_dwordx8 s[20:27], s[0:1], 0x38
	s_load_dwordx2 s[14:15], s[0:1], 0x58
.Ltmp1:
	.loc	1 941 14 is_stmt 1              ; rope.py:941:14
	v_readfirstlane_b32 s0, v0
	.loc	1 1036 9                        ; rope.py:1036:9
	s_and_b32 s0, s0, 0xc0
	.loc	1 940 14                        ; rope.py:940:14
	s_lshl_b32 s17, s17, 5
	.loc	1 940 32 is_stmt 0              ; rope.py:940:32
	v_and_or_b32 v1, v0, 48, s0
	v_lshrrev_b32_e32 v48, 4, v1
	v_or_b32_e32 v49, 16, v48
	.loc	1 940 14                        ; rope.py:940:14
	v_or_b32_e32 v1, s17, v48
	.loc	1 941 14 is_stmt 1              ; rope.py:941:14
	v_lshlrev_b32_e32 v0, 2, v0
	s_mov_b64 s[36:37], s[10:11]
	.loc	1 940 14                        ; rope.py:940:14
	v_or_b32_e32 v2, s17, v49
	.loc	1 941 14                        ; rope.py:941:14
	v_and_b32_e32 v50, 60, v0
	.loc	1 946 15                        ; rope.py:946:15
	v_lshlrev_b32_e32 v0, 2, v1
	v_bfrev_b32_e32 v51, 1
	.loc	1 942 14                        ; rope.py:942:14
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_i32_e64 s[0:1], s15, v1
	.loc	1 946 15                        ; rope.py:946:15
	s_and_b32 s37, s37, 0xffff
	s_mov_b32 s39, 0x27000
	s_mov_b32 s38, 0x7ffffffe
	v_cndmask_b32_e64 v0, v51, v0, s[0:1]
	v_lshlrev_b32_e32 v1, 2, v2
	.loc	1 942 14                        ; rope.py:942:14
	v_cmp_gt_i32_e32 vcc, s15, v2
	s_mov_b64 s[44:45], s[2:3]
	.loc	1 994 15                        ; rope.py:994:15
	s_mul_i32 s2, s21, s16
	.loc	1 946 15                        ; rope.py:946:15
	v_cndmask_b32_e32 v1, v51, v1, vcc
	buffer_load_dword v16, v0, s[36:39], 0 offen
	buffer_load_dword v17, v1, s[36:39], 0 offen
	.loc	1 1002 21                       ; rope.py:1002:21
	s_mul_i32 s3, s20, s17
	s_add_i32 s2, s2, s3
	v_mul_lo_u32 v0, v48, s20
	v_add_u32_e32 v4, s2, v50
	v_mul_lo_u32 v5, v49, s20
	.loc	1 1002 13 is_stmt 0             ; rope.py:1002:13
	v_add_lshl_u32 v0, v4, v0, 2
	v_add_lshl_u32 v4, v4, v5, 2
	s_and_b32 s45, s45, 0xffff
	s_mov_b32 s46, s38
	s_mov_b32 s47, s39
	v_cndmask_b32_e64 v0, v51, v0, s[0:1]
	v_cndmask_b32_e32 v4, v51, v4, vcc
	buffer_load_dwordx4 v[0:3], v0, s[44:47], 0 offen
	.loc	1 999 15 is_stmt 1              ; rope.py:999:15
	s_mul_i32 s15, s23, s16
	.loc	1 1002 13                       ; rope.py:1002:13
	buffer_load_dwordx4 v[4:7], v4, s[44:47], 0 offen
	.loc	1 1003 21                       ; rope.py:1003:21
	s_mul_i32 s18, s22, s17
	.loc	1 959 18                        ; rope.py:959:18
	v_subrev_co_u32_e64 v8, s[2:3], 32, v50
	.loc	1 1003 21                       ; rope.py:1003:21
	s_add_i32 s15, s15, s18
	.loc	1 958 26                        ; rope.py:958:26
	s_nop 0
	v_cndmask_b32_e64 v18, v8, v50, s[2:3]
	.loc	1 1003 21                       ; rope.py:1003:21
	v_mul_lo_u32 v8, v48, s22
	v_add_u32_e32 v10, s15, v50
	v_mul_lo_u32 v9, v49, s22
	.loc	1 1003 13 is_stmt 0             ; rope.py:1003:13
	v_add_lshl_u32 v8, v10, v8, 2
	s_mov_b64 s[40:41], s[6:7]
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s38
	s_mov_b32 s7, s39
	v_add_lshl_u32 v9, v10, v9, 2
	v_cndmask_b32_e64 v19, v51, v8, s[0:1]
	v_cndmask_b32_e32 v20, v51, v9, vcc
	buffer_load_dwordx4 v[8:11], v19, s[4:7], 0 offen
	buffer_load_dwordx4 v[12:15], v20, s[4:7], 0 offen
	.loc	1 973 11 is_stmt 1              ; rope.py:973:11
	s_and_b32 s41, s41, 0xffff
	s_mov_b32 s42, s38
	s_mov_b32 s43, s39
	.loc	1 974 11                        ; rope.py:974:11
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s10, s38
	s_mov_b32 s11, s39
	.loc	1 1035 18                       ; rope.py:1035:18
	s_mul_i32 s4, s25, s17
	.loc	1 1035 9 is_stmt 0              ; rope.py:1035:9
	s_and_b32 s13, s13, 0xffff
	s_mov_b32 s15, s39
	.loc	1 1036 9 is_stmt 1              ; rope.py:1036:9
	s_and_b32 s29, s29, 0xffff
	s_mov_b32 s30, s38
	s_mov_b32 s31, s39
	.loc	1 973 19                        ; rope.py:973:19
	s_waitcnt vmcnt(5)
	v_mul_lo_u32 v16, v16, s24
	s_waitcnt vmcnt(4)
	v_mul_lo_u32 v17, v17, s24
	.loc	1 973 11 is_stmt 0              ; rope.py:973:11
	v_add_lshl_u32 v16, v16, v18, 2
	v_cndmask_b32_e64 v32, v51, v16, s[0:1]
	v_add_lshl_u32 v16, v17, v18, 2
	v_cndmask_b32_e32 v33, v51, v16, vcc
	buffer_load_dwordx4 v[16:19], v32, s[40:43], 0 offen
	buffer_load_dwordx4 v[20:23], v33, s[40:43], 0 offen
	.loc	1 974 11 is_stmt 1              ; rope.py:974:11
	buffer_load_dwordx4 v[24:27], v32, s[8:11], 0 offen
	buffer_load_dwordx4 v[28:31], v33, s[8:11], 0 offen
.Ltmp2:
	.loc	1 51 21                         ; rope.py:51:21 @[ rope.py:1006:25 ]
	s_waitcnt vmcnt(7)
	v_cndmask_b32_e64 v34, -v1, v1, s[2:3]
	v_cndmask_b32_e64 v35, -v0, v0, s[2:3]
	v_cndmask_b32_e64 v36, -v3, v3, s[2:3]
	v_cndmask_b32_e64 v37, -v2, v2, s[2:3]
	s_waitcnt vmcnt(6)
	v_cndmask_b32_e64 v38, -v5, v5, s[2:3]
	v_cndmask_b32_e64 v39, -v4, v4, s[2:3]
	v_cndmask_b32_e64 v40, -v7, v7, s[2:3]
	v_cndmask_b32_e64 v41, -v6, v6, s[2:3]
.Ltmp3:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1006:25 ] ] ]
	v_mov_b32_dpp v32, v35 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v34 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v37 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v36 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v39 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v38 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v41 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v40 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp4:
	.loc	2 330 12 is_stmt 0              ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1006:25 ] ] ]
	v_mov_b32_dpp v35, v35 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v33 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v32 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v37 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v36 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v35 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v34 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v33 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v32 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v39 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v38 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v37 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v36 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v33, v35 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v32, v34 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v35, v40 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v34, v41 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v37, v39 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v36, v38 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v39, v42 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v38, v43 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp5:
	.loc	1 51 21 is_stmt 1               ; rope.py:51:21 @[ rope.py:1009:25 ]
	s_waitcnt vmcnt(5)
	v_cndmask_b32_e64 v40, -v9, v9, s[2:3]
	v_cndmask_b32_e64 v41, -v8, v8, s[2:3]
	v_cndmask_b32_e64 v42, -v11, v11, s[2:3]
	v_cndmask_b32_e64 v43, -v10, v10, s[2:3]
.Ltmp6:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v41, v41 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp7:
	.loc	1 51 21                         ; rope.py:51:21 @[ rope.py:1009:25 ]
	s_waitcnt vmcnt(4)
	v_cndmask_b32_e64 v44, -v13, v13, s[2:3]
	v_cndmask_b32_e64 v45, -v12, v12, s[2:3]
	v_cndmask_b32_e64 v46, -v15, v15, s[2:3]
	v_cndmask_b32_e64 v47, -v14, v14, s[2:3]
.Ltmp8:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v41, v41 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v41 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v41 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp9:
	.loc	2 330 12 is_stmt 0              ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v42, v42 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v41 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp10:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:54:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v45, v45 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp11:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v42, v42 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v41 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 row_ror:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v40 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v41 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 row_half_mirror row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v42 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v43 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v52, v40 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v53, v41 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v44 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v45, v45 quad_perm:[3,2,1,0] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v41, v42 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v40, v43 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v43, v52 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v42, v53 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v46 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v47 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v54, v44 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v55, v45 quad_perm:[2,3,0,1] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp12:
	.loc	1 1020 27 is_stmt 1             ; rope.py:1020:27
	s_waitcnt vmcnt(1)
	v_pk_mul_f32 v[34:35], v[24:25], v[34:35]
	.loc	1 1022 27                       ; rope.py:1022:27
	v_pk_mul_f32 v[24:25], v[24:25], v[42:43]
.Ltmp13:
	.loc	2 330 12                        ; standard.py:330:12 @[ standard.py:559:17 @[ rope.py:62:17 @[ rope.py:1009:25 ] ] ]
	v_mov_b32_dpp v45, v46 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v44, v47 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v47, v54 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
	v_mov_b32_dpp v46, v55 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf bound_ctrl:1
.Ltmp14:
	.loc	1 1020 17                       ; rope.py:1020:17
	v_pk_fma_f32 v[0:1], v[16:17], v[0:1], v[34:35]
	.loc	1 1022 17                       ; rope.py:1022:17
	v_pk_fma_f32 v[8:9], v[16:17], v[8:9], v[24:25]
	.loc	1 1022 27 is_stmt 0             ; rope.py:1022:27
	v_pk_mul_f32 v[16:17], v[26:27], v[40:41]
	.loc	1 1028 15 is_stmt 1             ; rope.py:1028:15
	s_mul_i32 s2, s26, s16
	.loc	1 1022 17                       ; rope.py:1022:17
	v_pk_fma_f32 v[10:11], v[18:19], v[10:11], v[16:17]
	.loc	1 1022 27 is_stmt 0             ; rope.py:1022:27
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[16:17], v[28:29], v[46:47]
	.loc	1 1020 27 is_stmt 1             ; rope.py:1020:27
	v_pk_mul_f32 v[32:33], v[26:27], v[32:33]
	.loc	1 1022 17                       ; rope.py:1022:17
	v_pk_fma_f32 v[12:13], v[20:21], v[12:13], v[16:17]
	.loc	1 1022 27 is_stmt 0             ; rope.py:1022:27
	v_pk_mul_f32 v[16:17], v[30:31], v[44:45]
	.loc	1 1035 18 is_stmt 1             ; rope.py:1035:18
	s_add_i32 s2, s2, s4
	.loc	1 1020 17                       ; rope.py:1020:17
	v_pk_fma_f32 v[2:3], v[18:19], v[2:3], v[32:33]
	.loc	1 1022 17                       ; rope.py:1022:17
	v_pk_fma_f32 v[14:15], v[22:23], v[14:15], v[16:17]
	.loc	1 1035 18                       ; rope.py:1035:18
	v_mul_lo_u32 v16, v48, s25
	v_add_u32_e32 v18, s2, v50
	.loc	1 1035 9 is_stmt 0              ; rope.py:1035:9
	v_add_lshl_u32 v16, v18, v16, 2
	.loc	1 1020 27 is_stmt 1             ; rope.py:1020:27
	v_pk_mul_f32 v[32:33], v[28:29], v[38:39]
	.loc	1 1033 15                       ; rope.py:1033:15
	s_mul_i32 s3, s14, s16
	.loc	1 1035 18                       ; rope.py:1035:18
	v_mul_lo_u32 v17, v49, s25
	.loc	1 1035 9 is_stmt 0              ; rope.py:1035:9
	s_mov_b32 s14, s38
	v_cndmask_b32_e64 v16, v51, v16, s[0:1]
	.loc	1 1020 17 is_stmt 1             ; rope.py:1020:17
	v_pk_fma_f32 v[4:5], v[20:21], v[4:5], v[32:33]
	.loc	1 1020 27 is_stmt 0             ; rope.py:1020:27
	v_pk_mul_f32 v[32:33], v[30:31], v[36:37]
	.loc	1 1035 9 is_stmt 1              ; rope.py:1035:9
	buffer_store_dwordx4 v[0:3], v16, s[12:15], 0 offen
	.loc	1 1036 18                       ; rope.py:1036:18
	s_mul_i32 s2, s27, s17
	.loc	1 1020 17                       ; rope.py:1020:17
	v_pk_fma_f32 v[6:7], v[22:23], v[6:7], v[32:33]
	.loc	1 1035 9                        ; rope.py:1035:9
	v_add_lshl_u32 v0, v18, v17, 2
	v_cndmask_b32_e32 v0, v51, v0, vcc
	.loc	1 1036 18                       ; rope.py:1036:18
	s_add_i32 s3, s3, s2
	.loc	1 1035 9                        ; rope.py:1035:9
	buffer_store_dwordx4 v[4:7], v0, s[12:15], 0 offen
	.loc	1 1036 18                       ; rope.py:1036:18
	v_mul_lo_u32 v0, v48, s27
	v_add_u32_e32 v2, s3, v50
	.loc	1 1036 9 is_stmt 0              ; rope.py:1036:9
	v_add_lshl_u32 v0, v2, v0, 2
	.loc	1 1036 18                       ; rope.py:1036:18
	v_mul_lo_u32 v1, v49, s27
	.loc	1 1036 9                        ; rope.py:1036:9
	v_cndmask_b32_e64 v0, v51, v0, s[0:1]
	buffer_store_dwordx4 v[8:11], v0, s[28:31], 0 offen
	v_add_lshl_u32 v0, v2, v1, 2
	v_cndmask_b32_e32 v0, v51, v0, vcc
	buffer_store_dwordx4 v[12:15], v0, s[28:31], 0 offen
	.loc	1 883 1 is_stmt 1               ; rope.py:883:1
	s_endpgm
.Ltmp15:
.Lfunc_end0:
	.size	_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1, .Lfunc_end0-_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
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
		.amdhsa_next_free_vgpr 56
		.amdhsa_next_free_sgpr 48
		.amdhsa_accum_offset 56
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
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.num_vgpr, 56
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.num_agpr, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.numbered_sgpr, 48
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.num_named_barrier, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.private_seg_size, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.uses_vcc, 1
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.uses_flat_scratch, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.has_dyn_sized_stack, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.has_recursion, 0
	.set .L_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 2356
; TotalNumSgprs: 54
; NumVgprs: 56
; NumAgprs: 0
; TotalNumVgprs: 56
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 6
; VGPRBlocks: 6
; NumSGPRsForWavesPerEU: 54
; NumVGPRsForWavesPerEU: 56
; AccumOffset: 56
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 13
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
	.byte	8                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
	.byte	49                              ; DW_AT_abstract_origin
	.byte	19                              ; DW_FORM_ref4
	.byte	85                              ; DW_AT_ranges
	.byte	23                              ; DW_FORM_sec_offset
	.byte	88                              ; DW_AT_call_file
	.byte	11                              ; DW_FORM_data1
	.byte	89                              ; DW_AT_call_line
	.byte	11                              ; DW_FORM_data1
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	9                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	0                               ; DW_CHILDREN_no
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0xe4 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0xbe DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x6a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.short	1006                            ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x56:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp3                          ; DW_AT_low_pc
	.long	.Ltmp4-.Ltmp3                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	54                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x6a:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp3                          ; DW_AT_low_pc
	.long	.Ltmp4-.Ltmp3                   ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	5                               ; Abbrev [5] 0x80:0x2a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp4                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	62                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x94:0x15 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp4                   ; DW_AT_high_pc
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	7                               ; Abbrev [7] 0xab:0x42 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	1009                            ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	8                               ; Abbrev [8] 0xb8:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	54                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	9                               ; Abbrev [9] 0xc4:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	559                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	8                               ; Abbrev [8] 0xd2:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	62                              ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	9                               ; Abbrev [9] 0xde:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
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
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
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
	.asciz	"_rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1" ; string offset=65 ; _rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
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
      - .offset:         92
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
    .name:           _rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         _rope_kernel_thd_cached_2c_fwd_HAVE_NOPE_0_NOPE_FIRST_0_INPLACE_0_REUSE_FREQS_FRONT_PART_1_IS_NEOX_1_HAVE_POS_1_HAVE_OFFS_0_BLOCK_T_32_SPLIT_H_SIZE_1_BLOCK_D_64_BLOCK_D_HALF_32_num_stages_1.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     56
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
