	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0 ; -- Begin function _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0
	.p2align	8
	.type	_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0,@function
_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0: ; @_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.63:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/attention" "mha.py"
	.loc	1 304 0 prologue_end            ; mha.py:304:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.64:
.LBB0_0:
	s_load_dword s33, s[0:1], 0x88
.Ltmp1:
	.loc	1 389 41 is_stmt 1              ; mha.py:389:41
	s_abs_i32 s13, s16
	.loc	1 399 46                        ; mha.py:399:46
	v_lshrrev_b32_e32 v123, 3, v0
	.loc	1 605 17                        ; mha.py:605:17
	v_lshlrev_b32_e32 v19, 3, v0
	v_and_b32_e32 v18, 56, v19
	.loc	1 374 39                        ; mha.py:374:39
	s_waitcnt lgkmcnt(0)
	s_add_i32 s10, s33, 0x7f
	.loc	1 374 45 is_stmt 0              ; mha.py:374:45
	s_ashr_i32 s11, s10, 31
	s_lshr_b32 s11, s11, 25
	s_add_i32 s10, s10, s11
	s_ashr_i32 s10, s10, 7
	.loc	1 389 41 is_stmt 1              ; mha.py:389:41
	s_abs_i32 s10, s10
	v_cvt_f32_u32_e32 v1, s10
	s_ashr_i32 s11, s16, 31
	s_sub_i32 s14, 0, s10
	v_mov_b32_e32 v2, 0
	v_rcp_iflag_f32_e32 v1, v1
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_mov_b32_e32 v9, 0
	v_readfirstlane_b32 s16, v1
	s_mul_i32 s14, s14, s16
	s_mul_hi_u32 s14, s16, s14
	s_add_i32 s16, s16, s14
	s_mul_hi_u32 s14, s13, s16
	s_mul_i32 s14, s14, s10
	s_sub_i32 s13, s13, s14
	s_sub_i32 s14, s13, s10
	s_cmp_ge_u32 s13, s10
	s_cselect_b32 s13, s14, s13
	s_sub_i32 s14, s13, s10
	s_cmp_ge_u32 s13, s10
	s_cselect_b32 s10, s14, s13
	s_xor_b32 s10, s10, s11
	s_sub_i32 s10, s10, s11
	.loc	1 399 23                        ; mha.py:399:23
	s_lshl_b32 s78, s10, 7
	.loc	1 399 33 is_stmt 0              ; mha.py:399:33
	v_or_b32_e32 v1, s78, v123
	.loc	1 690 35 is_stmt 1              ; mha.py:690:35
	v_cmp_gt_i32_e32 vcc, s33, v1
	.loc	1 703 16                        ; mha.py:703:16
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB0_2
; %bb.1:
	.loc	1 0 16 is_stmt 0                ; mha.py:0:16
	v_mad_u64_u32 v[4:5], s[16:17], v1, s12, v[18:19]
	v_ashrrev_i32_e32 v5, 31, v4
	v_lshl_add_u64 v[4:5], v[4:5], 1, s[2:3]
	.loc	1 703 16                        ; mha.py:703:16
	global_load_dwordx4 v[6:9], v[4:5], off nt
.LBB0_2:
	.loc	1 0 16                          ; mha.py:0:16
	s_or_b64 exec, exec, s[10:11]
	.loc	1 399 33 is_stmt 1              ; mha.py:399:33
	v_or3_b32 v10, v123, s78, 32
	.loc	1 690 35                        ; mha.py:690:35
	v_cmp_gt_i32_e32 vcc, s33, v10
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v5, 0
	.loc	1 703 16                        ; mha.py:703:16
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 605 10                        ; mha.py:605:10
	v_mad_u64_u32 v[2:3], s[16:17], v10, s12, v[18:19]
	.loc	1 607 21                        ; mha.py:607:21
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshl_add_u64 v[2:3], v[2:3], 1, s[2:3]
	.loc	1 703 16                        ; mha.py:703:16
	global_load_dwordx4 v[2:5], v[2:3], off nt
.LBB0_4:
	.loc	1 0 16 is_stmt 0                ; mha.py:0:16
	s_or_b64 exec, exec, s[10:11]
	.loc	1 399 33 is_stmt 1              ; mha.py:399:33
	v_or_b32_e32 v11, 64, v1
	.loc	1 690 35                        ; mha.py:690:35
	v_cmp_gt_i32_e32 vcc, s33, v11
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	.loc	1 703 16                        ; mha.py:703:16
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB0_6
; %bb.5:
	.loc	1 605 10                        ; mha.py:605:10
	v_mad_u64_u32 v[12:13], s[16:17], s12, v11, v[18:19]
	.loc	1 607 21                        ; mha.py:607:21
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshl_add_u64 v[12:13], v[12:13], 1, s[2:3]
	.loc	1 703 16                        ; mha.py:703:16
	global_load_dwordx4 v[14:17], v[12:13], off nt
.LBB0_6:
	.loc	1 0 16 is_stmt 0                ; mha.py:0:16
	s_or_b64 exec, exec, s[10:11]
	s_load_dword s79, s[0:1], 0x8c
	s_load_dword s22, s[0:1], 0x40
	.loc	1 399 33 is_stmt 1              ; mha.py:399:33
	v_or_b32_e32 v1, 0x60, v1
	s_movk_i32 s13, 0x60
	.loc	1 690 35                        ; mha.py:690:35
	v_cmp_gt_i32_e32 vcc, s33, v1
	s_mov_b32 s14, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v13, 0
	.loc	1 703 16                        ; mha.py:703:16
	s_and_saveexec_b64 s[10:11], vcc
	s_cbranch_execz .LBB0_8
; %bb.7:
	.loc	1 605 10                        ; mha.py:605:10
	v_mad_u64_u32 v[10:11], s[16:17], v1, s12, v[18:19]
	.loc	1 607 21                        ; mha.py:607:21
	v_ashrrev_i32_e32 v11, 31, v10
	v_lshl_add_u64 v[10:11], v[10:11], 1, s[2:3]
	.loc	1 703 16                        ; mha.py:703:16
	global_load_dwordx4 v[10:13], v[10:11], off nt
.LBB0_8:
	.loc	1 0 16 is_stmt 0                ; mha.py:0:16
	s_or_b64 exec, exec, s[10:11]
.Ltmp2:
	.loc	1 23 20 is_stmt 1               ; mha.py:23:20 @[ mha.py:529:34 ]
	s_waitcnt lgkmcnt(0)
	s_add_i32 s2, s79, 63
	.loc	1 23 26 is_stmt 0               ; mha.py:23:26 @[ mha.py:529:34 ]
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 26
.Ltmp3:
	.loc	1 625 10 is_stmt 1              ; mha.py:625:10
	v_mad_u64_u32 v[114:115], s[10:11], s15, v123, v[18:19]
	.loc	1 645 10                        ; mha.py:645:10
	v_mad_u64_u32 v[118:119], s[10:11], s22, v123, v[18:19]
.Ltmp4:
	.loc	1 23 26                         ; mha.py:23:26 @[ mha.py:529:34 ]
	s_add_i32 s2, s2, s3
.Ltmp5:
	.loc	1 703 16                        ; mha.py:703:16
	v_lshlrev_b32_e32 v1, 4, v0
	s_movk_i32 s10, 0x70
.Ltmp6:
	.loc	1 23 26                         ; mha.py:23:26 @[ mha.py:529:34 ]
	s_ashr_i32 s24, s2, 6
.Ltmp7:
	.loc	1 703 16                        ; mha.py:703:16
	v_bitop3_b32 v90, v1, v0, s10 bitop3:0x78
	.loc	1 399 46                        ; mha.py:399:46
	v_and_b32_e32 v125, 0xc0, v0
	.loc	1 605 17                        ; mha.py:605:17
	v_and_b32_e32 v122, 32, v0
	.loc	1 703 16                        ; mha.py:703:16
	v_add_u32_e32 v126, 0, v90
	.loc	1 712 18                        ; mha.py:712:18
	s_cmp_lt_i32 s79, 64
	.loc	1 399 46                        ; mha.py:399:46
	v_and_b32_e32 v124, 31, v0
	.loc	1 703 16                        ; mha.py:703:16
	s_waitcnt vmcnt(0)
	ds_write_b128 v126, v[6:9]
	ds_write_b128 v126, v[2:5] offset:4096
	ds_write_b128 v126, v[14:17] offset:8192
	ds_write_b128 v126, v[10:13] offset:12288
	v_lshlrev_b32_e32 v2, 6, v125
	v_and_b32_e32 v129, 0x70, v19
	v_lshrrev_b32_e32 v130, 1, v122
	.loc	1 712 18                        ; mha.py:712:18
	s_cselect_b64 s[10:11], -1, 0
	.loc	1 712 7 is_stmt 0               ; mha.py:712:7
	s_and_b32 s12, s79, 63
	.loc	1 703 16 is_stmt 1              ; mha.py:703:16
	v_lshlrev_b32_e32 v128, 7, v124
	v_bitop3_b32 v2, v129, v2, v130 bitop3:0xde
	.loc	1 712 7                         ; mha.py:712:7
	s_cmp_lg_u32 s12, 0
	.loc	1 703 16                        ; mha.py:703:16
	v_or_b32_e32 v3, v2, v128
	v_bitop3_b32 v2, v2, s13, v128 bitop3:0x36
	.loc	1 712 7                         ; mha.py:712:7
	s_cselect_b64 s[12:13], -1, 0
	.loc	1 703 16                        ; mha.py:703:16
	v_add_u32_e32 v4, 0, v3
	v_xad_u32 v5, v3, 32, 0
	v_xad_u32 v3, v3, 64, 0
	v_add_u32_e32 v2, 0, v2
	.loc	1 712 7                         ; mha.py:712:7
	s_or_b64 s[66:67], s[10:11], s[12:13]
	s_load_dword s23, s[0:1], 0x78
	.loc	1 703 16                        ; mha.py:703:16
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[66:69], v4
	ds_read_b128 v[70:73], v5
	ds_read_b128 v[74:77], v3
	ds_read_b128 v[78:81], v2
	.loc	1 739 39                        ; mha.py:739:39
	v_cndmask_b32_e64 v2, 0, 1, s[66:67]
	.loc	1 625 10                        ; mha.py:625:10
	v_lshl_add_u32 v116, s15, 5, v114
	.loc	1 739 39                        ; mha.py:739:39
	v_readfirstlane_b32 s10, v2
	s_min_i32 s26, s10, s24
	.loc	1 645 10                        ; mha.py:645:10
	v_lshl_add_u32 v120, s22, 5, v118
	.loc	1 740 37                        ; mha.py:740:37
	s_sub_i32 s25, s24, s26
	.loc	1 605 17                        ; mha.py:605:17
	v_cmp_eq_u32_e64 s[2:3], 0, v122
	.loc	1 627 21                        ; mha.py:627:21
	v_ashrrev_i32_e32 v115, 31, v114
	v_ashrrev_i32_e32 v117, 31, v116
	.loc	1 647 21                        ; mha.py:647:21
	v_ashrrev_i32_e32 v119, 31, v118
	v_ashrrev_i32_e32 v121, 31, v120
	.loc	1 754 23                        ; mha.py:754:23
	s_cmp_lt_i32 s25, 1
	.loc	1 703 16                        ; mha.py:703:16
	v_and_b32_e32 v131, 0x70, v0
	.loc	1 754 7                         ; mha.py:754:7
	s_cbranch_scc1 .LBB0_11
; %bb.9:
	.loc	1 755 48                        ; mha.py:755:48
	s_lshl_b32 s14, s25, 6
.Ltmp8:
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cmp_gt_i32 s14, 0
	s_cselect_b64 s[12:13], -1, 0
	s_cmp_lt_i32 s14, 1
.Ltmp9:
	.loc	1 627 21                        ; mha.py:627:21
	v_lshl_add_u64 v[82:83], v[114:115], 1, s[4:5]
.Ltmp10:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_scc1 .LBB0_12
; %bb.10:
	global_load_dwordx4 v[2:5], v[82:83], off
	s_branch .LBB0_13
.Ltmp11:
.LBB0_11:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v19, 0
	v_mov_b32_e32 v133, 0xff800000
	v_mov_b32_e32 v127, 1.0
	v_mov_b32_e32 v18, v19
	v_mov_b32_e32 v21, v19
	v_mov_b32_e32 v20, v19
	v_mov_b32_e32 v23, v19
	v_mov_b32_e32 v22, v19
	v_mov_b32_e32 v25, v19
	v_mov_b32_e32 v24, v19
	v_mov_b32_e32 v27, v19
	v_mov_b32_e32 v26, v19
	v_mov_b32_e32 v29, v19
	v_mov_b32_e32 v28, v19
	v_mov_b32_e32 v31, v19
	v_mov_b32_e32 v30, v19
	v_mov_b32_e32 v33, v19
	v_mov_b32_e32 v32, v19
	v_mov_b32_e32 v3, v19
	v_mov_b32_e32 v2, v19
	v_mov_b32_e32 v5, v19
	v_mov_b32_e32 v4, v19
	v_mov_b32_e32 v7, v19
	v_mov_b32_e32 v6, v19
	v_mov_b32_e32 v9, v19
	v_mov_b32_e32 v8, v19
	v_mov_b32_e32 v11, v19
	v_mov_b32_e32 v10, v19
	v_mov_b32_e32 v13, v19
	v_mov_b32_e32 v12, v19
	v_mov_b32_e32 v15, v19
	v_mov_b32_e32 v14, v19
	v_mov_b32_e32 v17, v19
	v_mov_b32_e32 v16, v19
	s_load_dword s80, s[0:1], 0x58
	.loc	1 807 23 is_stmt 1              ; mha.py:807:23
	s_cmp_lt_i32 s26, 1
	.loc	1 807 7 is_stmt 0               ; mha.py:807:7
	s_cbranch_scc0 .LBB0_47
	s_branch .LBB0_60
.LBB0_12:
	.loc	1 0 7                           ; mha.py:0:7
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
.LBB0_13:
.Ltmp12:
	.loc	1 40 25 is_stmt 1               ; mha.py:40:25 @[ mha.py:793:12 ]
	v_cndmask_b32_e64 v6, 0, 1, s[12:13]
	v_cmp_ne_u32_e64 s[10:11], 1, v6
	s_andn2_b64 vcc, exec, s[12:13]
.Ltmp13:
	.loc	1 627 21                        ; mha.py:627:21
	v_lshl_add_u64 v[84:85], v[116:117], 1, s[4:5]
.Ltmp14:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_17
; %bb.14:
	global_load_dwordx4 v[6:9], v[84:85], off
	s_and_b64 vcc, exec, s[10:11]
.Ltmp15:
	.loc	1 647 21                        ; mha.py:647:21
	v_lshl_add_u64 v[86:87], v[118:119], 1, s[6:7]
.Ltmp16:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_18
.LBB0_15:
	global_load_dwordx4 v[10:13], v[86:87], off
	s_and_b64 vcc, exec, s[10:11]
.Ltmp17:
	.loc	1 647 21                        ; mha.py:647:21
	v_lshl_add_u64 v[88:89], v[120:121], 1, s[6:7]
.Ltmp18:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_19
.LBB0_16:
	global_load_dwordx4 v[14:17], v[88:89], off
	s_branch .LBB0_20
.LBB0_17:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[10:11]
.Ltmp19:
	.loc	1 647 21 is_stmt 1              ; mha.py:647:21
	v_lshl_add_u64 v[86:87], v[118:119], 1, s[6:7]
.Ltmp20:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccz .LBB0_15
.LBB0_18:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, v10
	v_mov_b32_e32 v12, v10
	v_mov_b32_e32 v13, v10
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[10:11]
.Ltmp21:
	.loc	1 647 21 is_stmt 1              ; mha.py:647:21
	v_lshl_add_u64 v[88:89], v[120:121], 1, s[6:7]
.Ltmp22:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccz .LBB0_16
.LBB0_19:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, v14
	v_mov_b32_e32 v16, v14
	v_mov_b32_e32 v17, v14
.LBB0_20:
	.loc	1 269 28 is_stmt 1              ; mha.py:269:28 @[ mha.py:793:12 ]
	s_lshl_b32 s20, s15, 6
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write_b128 v126, v[2:5]
	ds_write_b128 v126, v[6:9] offset:4096
	v_lshrrev_b32_e32 v2, 1, v131
	s_add_i32 s31, 0, 0x4000
	v_xor_b32_e32 v91, v1, v2
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cmp_gt_i32 s14, 64
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v2, s31, v91
	v_xor_b32_e32 v92, 8, v91
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cselect_b64 s[16:17], -1, 0
	.loc	1 269 18                        ; mha.py:269:18 @[ mha.py:793:12 ]
	s_ashr_i32 s21, s20, 31
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v18, 0, v91
	ds_write_b64 v2, v[14:15] offset:4096
	v_add_u32_e32 v19, 0, v92
	v_add_u32_e32 v2, s31, v92
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cmpk_lt_i32 s14, 0x41
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_write_b64 v18, v[10:11] offset:16384
	ds_write_b64 v19, v[12:13] offset:16384
	ds_write_b64 v2, v[16:17] offset:4096
	s_cbranch_scc1 .LBB0_24
; %bb.21:
	.loc	1 269 18                        ; mha.py:269:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[2:3], s[20:21], 1, v[82:83]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	global_load_dwordx4 v[2:5], v[2:3], off
	v_cndmask_b32_e64 v6, 0, 1, s[16:17]
	v_cmp_ne_u32_e64 s[12:13], 1, v6
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccz .LBB0_25
.LBB0_22:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	.loc	1 272 28 is_stmt 1              ; mha.py:272:28 @[ mha.py:793:12 ]
	s_lshl_b32 s16, s22, 6
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[12:13]
	.loc	1 272 18                        ; mha.py:272:18 @[ mha.py:793:12 ]
	s_ashr_i32 s17, s16, 31
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccz .LBB0_26
.LBB0_23:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, v10
	v_mov_b32_e32 v12, v10
	v_mov_b32_e32 v13, v10
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_branch .LBB0_27
.LBB0_24:
	.loc	1 0 25                          ; mha.py:0:25
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_cndmask_b32_e64 v6, 0, 1, s[16:17]
	v_cmp_ne_u32_e64 s[12:13], 1, v6
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_22
.LBB0_25:
	.loc	1 269 18 is_stmt 1              ; mha.py:269:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[6:7], s[20:21], 1, v[84:85]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	global_load_dwordx4 v[6:9], v[6:7], off
	.loc	1 272 28                        ; mha.py:272:28 @[ mha.py:793:12 ]
	s_lshl_b32 s16, s22, 6
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[12:13]
	.loc	1 272 18                        ; mha.py:272:18 @[ mha.py:793:12 ]
	s_ashr_i32 s17, s16, 31
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_23
.LBB0_26:
	.loc	1 272 18                        ; mha.py:272:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[10:11], s[16:17], 1, v[86:87]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	global_load_dwordx4 v[10:13], v[10:11], off
.LBB0_27:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	v_mov_b32_e32 v14, 0
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[12:13]
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	s_cbranch_vccnz .LBB0_29
; %bb.28:
	.loc	1 272 18 is_stmt 1              ; mha.py:272:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[14:15], s[16:17], 1, v[88:89]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	global_load_dwordx4 v[14:17], v[14:15], off
.LBB0_29:
	s_add_i32 s27, 0, 0x2000
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write_b128 v126, v[2:5] offset:8192
	v_add_u32_e32 v2, s27, v90
	s_add_i32 s28, 0, 0x6000
	ds_write_b128 v2, v[6:9] offset:4096
	ds_write_b64 v18, v[10:11] offset:24576
	v_add_u32_e32 v2, s28, v91
	ds_write_b64 v2, v[14:15] offset:4096
	ds_write_b64 v19, v[12:13] offset:24576
	v_add_u32_e32 v2, s28, v92
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_add_i32 s29, s14, 0xffffff80
	v_and_b32_e32 v3, 64, v1
	.loc	1 180 30                        ; mha.py:180:30 @[ mha.py:793:12 ]
	v_mov_b32_e32 v20, 0x3fb8aa3b
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_write_b64 v2, v[16:17] offset:4096
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cmp_gt_i32 s29, 0
	v_bitop3_b32 v133, v128, v130, v129 bitop3:0x36
	v_lshlrev_b32_e32 v2, 2, v0
	v_and_or_b32 v96, v0, 16, v3
	s_cbranch_scc1 .LBB0_31
; %bb.30:                               ; %.._crit_edge_crit_edge
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_mov_b32_e32 v4, 0x108
	v_cndmask_b32_e64 v93, v4, 0, s[2:3]
	v_and_or_b32 v34, v0, 16, v3
	s_mov_b64 s[12:13], 0
	s_branch .LBB0_32
.LBB0_31:
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	s_mov_b64 s[12:13], -1
                                        ; implicit-def: $vgpr93
                                        ; implicit-def: $vgpr34
.LBB0_32:                               ; %Flow856
	v_and_b32_e32 v95, 8, v0
	v_mul_f32_e32 v132, s23, v20
	v_xor_b32_e32 v136, 32, v133
	v_xor_b32_e32 v135, 64, v133
	v_xor_b32_e32 v134, 0x60, v133
	v_and_b32_e32 v94, 12, v2
	s_mov_b32 s34, 1
	s_andn2_b64 vcc, exec, s[12:13]
	v_cmp_eq_u32_e64 s[12:13], 0, v95
	s_mov_b32 s35, 0
	s_cbranch_vccnz .LBB0_36
; %bb.33:                               ; %.lr.ph
	v_mov_b32_e32 v2, 0x84
	v_cndmask_b32_e64 v2, v2, 0, s[12:13]
	v_mov_b32_e32 v3, 0x108
	v_cndmask_b32_e64 v93, v3, 0, s[2:3]
	v_xor_b32_e32 v2, v2, v94
	v_xor_b32_e32 v2, v2, v93
	v_or_b32_e32 v97, v96, v2
	v_bitop3_b32 v98, v96, 16, v2 bitop3:0x36
	v_mov_b32_e32 v2, 0
	.loc	1 135 59 is_stmt 1              ; mha.py:135:59 @[ mha.py:793:12 ]
	s_lshl_b64 s[12:13], s[16:17], 2
	s_lshl_b64 s[16:17], s[16:17], 1
	s_lshl_b64 s[18:19], s[20:21], 2
	s_add_i32 s27, 0, 0x2000
	s_add_i32 s31, 0, 0x4000
	s_add_i32 s28, 0, 0x6000
	s_lshl_b64 s[20:21], s[20:21], 1
	v_mov_b32_e32 v127, 1.0
	v_mov_b32_e32 v137, 0xff800000
	s_mov_b32 s30, 0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v18, v2
	v_mov_b32_e32 v19, v2
	v_mov_b32_e32 v20, v2
	v_mov_b32_e32 v21, v2
	v_mov_b32_e32 v22, v2
	v_mov_b32_e32 v23, v2
	v_mov_b32_e32 v24, v2
	v_mov_b32_e32 v25, v2
	v_mov_b32_e32 v26, v2
	v_mov_b32_e32 v27, v2
	v_mov_b32_e32 v28, v2
	v_mov_b32_e32 v29, v2
	v_mov_b32_e32 v30, v2
	v_mov_b32_e32 v31, v2
	v_mov_b32_e32 v32, v2
	v_mov_b32_e32 v33, v2
.LBB0_34:                               ; =>This Inner Loop Header: Depth=1
	.loc	1 0 59 is_stmt 0                ; mha.py:0:59
	s_mov_b32 s36, s35
	.loc	1 269 18 is_stmt 1              ; mha.py:269:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[34:35], v[82:83], 0, s[18:19]
	.loc	1 272 18                        ; mha.py:272:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[36:37], v[84:85], 0, s[18:19]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v38, s36, v133
	global_load_dwordx4 v[100:103], v[34:35], off
	global_load_dwordx4 v[104:107], v[36:37], off
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[34:37], v38
	ds_read_b128 v[38:41], v38 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[34:37], v[66:69], 0
	.loc	1 272 18                        ; mha.py:272:18 @[ mha.py:793:12 ]
	v_lshl_add_u64 v[42:43], v[86:87], 0, s[12:13]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v113, s36, v136
	v_mov_b32_e32 v99, v137
	v_lshl_add_u64 v[44:45], v[88:89], 0, s[12:13]
	v_mov_b32_e32 v112, v127
	v_add_u32_e32 v127, s36, v135
	v_add_u32_e32 v137, s36, v134
	global_load_dwordx4 v[108:111], v[42:43], off
	global_load_dwordx4 v[138:141], v[44:45], off
	ds_read_b128 v[142:145], v113
	ds_read_b128 v[146:149], v113 offset:4096
	ds_read_b128 v[150:153], v127
	ds_read_b128 v[154:157], v127 offset:4096
	ds_read_b128 v[158:161], v137
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[38:41], v[66:69], 0
	s_mov_b32 s37, s31
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_lshl_add_u32 v180, v97, 1, s37
	v_lshl_add_u32 v188, v98, 1, s37
	s_mov_b32 s35, s27
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_add_i32 s27, s34, 1
	s_cmp_lt_i32 s27, 2
	s_cselect_b32 s34, s27, 0
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[142:145], v[70:73], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[142:145], v137 offset:4096
	ds_read_b64_tr_b16 v[164:165], v188 offset:1024
	ds_read_b64_tr_b16 v[168:169], v188 offset:3136
	ds_read_b64_tr_b16 v[162:163], v180
	ds_read_b64_tr_b16 v[166:167], v180 offset:2112
	ds_read_b64_tr_b16 v[170:171], v180 offset:64
	ds_read_b64_tr_b16 v[174:175], v180 offset:2048
	s_lshl_b32 s27, s34, 13
	s_add_i32 s27, s27, 0
	s_mov_b32 s31, s28
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_add_i32 s30, s30, 64
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_add_i32 s28, s27, 0x4000
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_add_u32 s12, s12, s16
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[146:149], v[70:73], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b64_tr_b16 v[172:173], v188 offset:1088
	ds_read_b64_tr_b16 v[176:177], v188 offset:3072
	ds_read_b64_tr_b16 v[148:149], v188 offset:5120
	ds_read_b64_tr_b16 v[146:147], v180 offset:4096
	ds_read_b64_tr_b16 v[178:179], v180 offset:6208
	ds_read_b64_tr_b16 v[182:183], v180 offset:4160
	ds_read_b64_tr_b16 v[186:187], v180 offset:6144
	ds_read_b64_tr_b16 v[180:181], v188 offset:7232
	ds_read_b64_tr_b16 v[184:185], v188 offset:5184
	ds_read_b64_tr_b16 v[188:189], v188 offset:7168
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_addc_u32 s13, s13, s17
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v113, s27, v90
	v_add_u32_e32 v127, s27, v91
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_add_u32 s18, s18, s20
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[150:153], v[74:77], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_barrier
	v_add_u32_e32 v150, s27, v92
	v_add_u32_e32 v151, s28, v91
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_addc_u32 s19, s19, s21
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v152, s28, v92
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cmp_lt_i32 s30, s29
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[154:157], v[74:77], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	s_waitcnt vmcnt(3)
	ds_write_b128 v113, v[100:103]
	s_waitcnt vmcnt(2)
	ds_write_b128 v113, v[104:107] offset:4096
	s_waitcnt vmcnt(1)
	ds_write_b64 v127, v[108:109] offset:16384
	ds_write_b64 v150, v[110:111] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b64 v151, v[138:139] offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[158:161], v[78:81], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_write_b64 v152, v[140:141] offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[142:145], v[78:81], v[34:49]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	s_nop 7
	s_nop 1
	v_mul_f32_e32 v137, v132, v50
	v_mul_f32_e32 v142, v132, v51
	v_mul_f32_e32 v143, v132, v52
	v_mul_f32_e32 v144, v132, v53
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max_f32_e32 v137, v137, v142
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v145, v132, v54
	v_mul_f32_e32 v153, v132, v55
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v143, v144
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v154, v132, v56
	v_mul_f32_e32 v155, v132, v57
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v145, v153
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v156, v132, v58
	v_mul_f32_e32 v157, v132, v59
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v154, v155
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v158, v132, v60
	v_mul_f32_e32 v159, v132, v61
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v156, v157
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v160, v132, v62
	v_mul_f32_e32 v161, v132, v63
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v158, v159
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v190, v132, v64
	v_mul_f32_e32 v191, v132, v65
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v160, v161
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v192, v132, v34
	v_mul_f32_e32 v193, v132, v35
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v190, v191
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v194, v132, v36
	v_mul_f32_e32 v195, v132, v37
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v192, v193
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v196, v132, v38
	v_mul_f32_e32 v197, v132, v39
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v194, v195
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v198, v132, v40
	v_mul_f32_e32 v199, v132, v41
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v196, v197
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v200, v132, v42
	v_mul_f32_e32 v201, v132, v43
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v198, v199
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v202, v132, v44
	v_mul_f32_e32 v203, v132, v45
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v200, v201
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v204, v132, v46
	v_mul_f32_e32 v205, v132, v47
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v202, v203
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v206, v132, v48
	v_mul_f32_e32 v207, v132, v49
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v137, v137, v204, v205
	v_max3_f32 v137, v137, v206, v207
	.loc	2 189 40                        ; standard.py:189:40 @[ mha.py:793:12 ]
	v_mov_b32_e32 v142, v137
	s_nop 1
	v_permlane32_swap_b32_e32 v137, v142
	.loc	1 212 31                        ; mha.py:212:31 @[ mha.py:793:12 ]
	v_max3_f32 v137, v99, v137, v142
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v50, v132, v50, -v137
	v_fma_f32 v51, v132, v51, -v137
	v_fma_f32 v52, v132, v52, -v137
	v_fma_f32 v53, v132, v53, -v137
	v_fma_f32 v54, v132, v54, -v137
	v_fma_f32 v55, v132, v55, -v137
	v_fma_f32 v56, v132, v56, -v137
	v_fma_f32 v57, v132, v57, -v137
	.loc	1 249 35                        ; mha.py:249:35 @[ mha.py:793:12 ]
	v_sub_f32_e32 v99, v99, v137
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v47, v132, v47, -v137
	v_fma_f32 v142, v132, v46, -v137
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v50, v50
	v_exp_f32_e32 v51, v51
	v_exp_f32_e32 v52, v52
	v_exp_f32_e32 v53, v53
	v_exp_f32_e32 v54, v54
	v_exp_f32_e32 v55, v55
	v_exp_f32_e32 v56, v56
	v_exp_f32_e32 v57, v57
	.loc	1 249 29 is_stmt 1              ; mha.py:249:29 @[ mha.py:793:12 ]
	v_exp_f32_e32 v46, v99
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v47, v47
	.loc	1 215 30 is_stmt 0              ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v34, v132, v34, -v137
	v_fma_f32 v35, v132, v35, -v137
	v_fma_f32 v36, v132, v36, -v137
	v_fma_f32 v37, v132, v37, -v137
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v99, v34
	v_exp_f32_e32 v143, v35
	v_exp_f32_e32 v144, v36
	v_exp_f32_e32 v145, v37
	.loc	1 267 30 is_stmt 1              ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v34, v50, v51
	v_cvt_pk_bf16_f32 v35, v52, v53
	v_cvt_pk_bf16_f32 v36, v54, v55
	v_cvt_pk_bf16_f32 v37, v56, v57
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_pk_mul_f32 v[32:33], v[32:33], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[46:47] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[46:47] op_sel_hi:[1,0]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[162:165], v[34:37], v[18:33]
	.loc	1 215 30 is_stmt 1              ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v58, v132, v58, -v137
	v_fma_f32 v59, v132, v59, -v137
	v_fma_f32 v60, v132, v60, -v137
	v_fma_f32 v61, v132, v61, -v137
	v_fma_f32 v62, v132, v62, -v137
	v_fma_f32 v63, v132, v63, -v137
	v_fma_f32 v64, v132, v64, -v137
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[170:173], v[34:37], v[2:17]
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v65, v132, v65, -v137
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v58, v58
	v_exp_f32_e32 v59, v59
	v_exp_f32_e32 v60, v60
	v_exp_f32_e32 v61, v61
	v_exp_f32_e32 v62, v62
	v_exp_f32_e32 v63, v63
	v_exp_f32_e32 v64, v64
	v_exp_f32_e32 v65, v65
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v50, v50, v51
	v_add_f32_e32 v50, v52, v50
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v38, v132, v38, -v137
	v_fma_f32 v39, v132, v39, -v137
	v_fma_f32 v40, v132, v40, -v137
	v_fma_f32 v41, v132, v41, -v137
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v50, v53, v50
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v153, v38
	v_exp_f32_e32 v154, v39
	v_exp_f32_e32 v155, v40
	v_exp_f32_e32 v156, v41
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v38, v58, v59
	v_cvt_pk_bf16_f32 v39, v60, v61
	v_cvt_pk_bf16_f32 v40, v62, v63
	v_cvt_pk_bf16_f32 v41, v64, v65
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v50, v54, v50
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v34, v99, v143
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[174:177], v[38:41], v[18:33]
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v35, v144, v145
	v_cvt_pk_bf16_f32 v36, v153, v154
	v_cvt_pk_bf16_f32 v37, v155, v156
	.loc	1 215 30 is_stmt 1              ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v42, v132, v42, -v137
	v_fma_f32 v43, v132, v43, -v137
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v157, v42
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v44, v132, v44, -v137
	.loc	1 267 50 is_stmt 1              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[166:169], v[38:41], v[2:17]
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v38, v55, v50
	v_add_f32_e32 v38, v56, v38
	v_add_f32_e32 v38, v57, v38
	v_add_f32_e32 v38, v58, v38
	v_add_f32_e32 v38, v59, v38
	v_add_f32_e32 v38, v60, v38
	v_add_f32_e32 v38, v61, v38
	v_add_f32_e32 v38, v62, v38
	v_add_f32_e32 v38, v63, v38
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[146:149], v[34:37], v[18:33]
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v158, v43
	.loc	1 215 30 is_stmt 0              ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v45, v132, v45, -v137
	v_fma_f32 v48, v132, v48, -v137
	v_fma_f32 v49, v132, v49, -v137
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v159, v44
	v_exp_f32_e32 v160, v45
	v_exp_f32_e32 v142, v142
	.loc	1 267 50 is_stmt 1              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[182:185], v[34:37], v[2:17]
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v64, v38
	v_add_f32_e32 v34, v65, v34
	v_add_f32_e32 v34, v99, v34
	v_add_f32_e32 v34, v143, v34
	v_add_f32_e32 v34, v144, v34
	v_add_f32_e32 v34, v145, v34
	v_add_f32_e32 v34, v153, v34
	v_add_f32_e32 v34, v154, v34
	v_add_f32_e32 v34, v155, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v48, v48
	v_exp_f32_e32 v49, v49
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v156, v34
	v_add_f32_e32 v34, v157, v34
	v_add_f32_e32 v34, v158, v34
	v_add_f32_e32 v34, v159, v34
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v42, v157, v158
	v_cvt_pk_bf16_f32 v43, v159, v160
	v_cvt_pk_bf16_f32 v44, v142, v47
	v_cvt_pk_bf16_f32 v45, v48, v49
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v160, v34
	v_add_f32_e32 v34, v142, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[186:189], v[42:45], v[18:33]
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v47, v34
	v_add_f32_e32 v34, v48, v34
	v_add_f32_e32 v34, v49, v34
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:793:12 ]
	v_mov_b32_e32 v35, v34
	s_nop 1
	v_permlane32_swap_b32_e32 v34, v35
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v127, v34, v35
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[178:181], v[42:45], v[2:17]
	.loc	1 256 28                        ; mha.py:256:28 @[ mha.py:793:12 ]
	v_fmac_f32_e32 v127, v112, v46
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_cbranch_scc1 .LBB0_34
; %bb.35:                               ; %Flow855
	.loc	1 0 59 is_stmt 0                ; mha.py:0:59
	v_mov_b32_e32 v34, v96
	s_branch .LBB0_37
.LBB0_36:
	v_mov_b32_e32 v19, 0
	v_mov_b32_e32 v127, 1.0
	v_mov_b32_e32 v137, 0xff800000
	v_mov_b32_e32 v18, v19
	v_mov_b32_e32 v21, v19
	v_mov_b32_e32 v20, v19
	v_mov_b32_e32 v23, v19
	v_mov_b32_e32 v22, v19
	v_mov_b32_e32 v25, v19
	v_mov_b32_e32 v24, v19
	v_mov_b32_e32 v27, v19
	v_mov_b32_e32 v26, v19
	v_mov_b32_e32 v29, v19
	v_mov_b32_e32 v28, v19
	v_mov_b32_e32 v31, v19
	v_mov_b32_e32 v30, v19
	v_mov_b32_e32 v33, v19
	v_mov_b32_e32 v32, v19
	v_mov_b32_e32 v3, v19
	v_mov_b32_e32 v2, v19
	v_mov_b32_e32 v5, v19
	v_mov_b32_e32 v4, v19
	v_mov_b32_e32 v7, v19
	v_mov_b32_e32 v6, v19
	v_mov_b32_e32 v9, v19
	v_mov_b32_e32 v8, v19
	v_mov_b32_e32 v11, v19
	v_mov_b32_e32 v10, v19
	v_mov_b32_e32 v13, v19
	v_mov_b32_e32 v12, v19
	v_mov_b32_e32 v15, v19
	v_mov_b32_e32 v14, v19
	v_mov_b32_e32 v17, v19
	v_mov_b32_e32 v16, v19
.LBB0_37:                               ; %._crit_edge
	.loc	1 40 25 is_stmt 1               ; mha.py:40:25 @[ mha.py:793:12 ]
	v_mov_b32_e32 v35, 0x84
	v_cmp_eq_u32_e32 vcc, 0, v95
	s_movk_i32 s12, 0x210
	s_waitcnt lgkmcnt(0)
	v_cndmask_b32_e64 v35, v35, 0, vcc
	v_or_b32_e32 v36, v35, v93
	v_bitop3_b32 v35, v35, v94, v93 bitop3:0x36
	v_bitop3_b32 v139, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0x610
	v_bitop3_b32 v140, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0xa10
	v_bitop3_b32 v141, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0xe10
	v_bitop3_b32 v142, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0x230
	v_bitop3_b32 v143, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0x630
	v_bitop3_b32 v144, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0xa30
	v_bitop3_b32 v145, v34, s12, v35 bitop3:0x36
	s_movk_i32 s12, 0xe30
	v_bitop3_b32 v138, v34, v36, v94 bitop3:0xf6
	v_bitop3_b32 v146, v34, s12, v35 bitop3:0x36
	v_lshl_add_u32 v35, v139, 1, s31
	s_barrier
	v_lshl_add_u32 v34, v138, 1, s31
	v_lshl_add_u32 v36, v140, 1, s31
	v_lshl_add_u32 v37, v141, 1, s31
	v_lshl_add_u32 v38, v142, 1, s31
	v_lshl_add_u32 v39, v143, 1, s31
	v_lshl_add_u32 v40, v144, 1, s31
	v_lshl_add_u32 v41, v145, 1, s31
	v_lshl_add_u32 v42, v146, 1, s31
	ds_read_b64_tr_b16 v[112:113], v35
	ds_read_b64_tr_b16 v[108:109], v36
	ds_read_b64_tr_b16 v[104:105], v37
	ds_read_b64_tr_b16 v[100:101], v38
	ds_read_b64_tr_b16 v[110:111], v34
	ds_read_b64_tr_b16 v[106:107], v34 offset:2048
	ds_read_b64_tr_b16 v[86:87], v34 offset:2112
	ds_read_b64_tr_b16 v[90:91], v34 offset:64
	ds_read_b64_tr_b16 v[102:103], v34 offset:4096
	ds_read_b64_tr_b16 v[98:99], v34 offset:6144
	ds_read_b64_tr_b16 v[82:83], v34 offset:6208
	ds_read_b64_tr_b16 v[94:95], v34 offset:4160
	ds_read_b64_tr_b16 v[92:93], v39
	ds_read_b64_tr_b16 v[88:89], v40
	ds_read_b64_tr_b16 v[96:97], v41
	ds_read_b64_tr_b16 v[84:85], v42
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[10:11]
	s_cbranch_vccnz .LBB0_39
; %bb.38:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v54, s35, v133
	ds_read_b128 v[34:37], v54
	v_add_u32_e32 v147, s35, v136
	ds_read_b128 v[50:53], v147
	v_add_u32_e32 v152, s35, v135
	v_add_u32_e32 v153, s35, v134
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[34:37], v[66:69], 0
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[148:151], v147 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[70:73], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v152
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[74:77], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v153
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[78:81], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v54 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[50:53], v[66:69], 0
	v_mfma_f32_32x32x16_bf16 v[50:65], v[148:151], v[70:73], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[148:151], v152 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[148:151], v[74:77], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[148:151], v153 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[148:151], v[78:81], v[50:65]
	s_branch .LBB0_40
.LBB0_39:
	.loc	1 0 23 is_stmt 0                ; mha.py:0:23
	v_mov_b32_e32 v34, 0
	v_mov_b32_e32 v35, 0
	v_mov_b32_e32 v36, 0
	v_mov_b32_e32 v37, 0
	v_mov_b32_e32 v38, 0
	v_mov_b32_e32 v39, 0
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v42, 0
	v_mov_b32_e32 v43, 0
	v_mov_b32_e32 v44, 0
	v_mov_b32_e32 v45, 0
	v_mov_b32_e32 v46, 0
	v_mov_b32_e32 v47, 0
	v_mov_b32_e32 v48, 0
	v_mov_b32_e32 v49, 0
	v_mov_b32_e32 v50, 0
	v_mov_b32_e32 v51, 0
	v_mov_b32_e32 v52, 0
	v_mov_b32_e32 v53, 0
	v_mov_b32_e32 v54, 0
	v_mov_b32_e32 v55, 0
	v_mov_b32_e32 v56, 0
	v_mov_b32_e32 v57, 0
	v_mov_b32_e32 v58, 0
	v_mov_b32_e32 v59, 0
	v_mov_b32_e32 v60, 0
	v_mov_b32_e32 v61, 0
	v_mov_b32_e32 v62, 0
	v_mov_b32_e32 v63, 0
	v_mov_b32_e32 v64, 0
	v_mov_b32_e32 v65, 0
.LBB0_40:
	.loc	1 189 22 is_stmt 1              ; mha.py:189:22 @[ mha.py:793:12 ]
	s_nop 0
	v_mul_f32_e32 v147, v132, v34
	v_mul_f32_e32 v148, v132, v35
	v_mul_f32_e32 v149, v132, v36
	v_mul_f32_e32 v150, v132, v37
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max_f32_e32 v147, v147, v148
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v151, v132, v38
	v_mul_f32_e32 v152, v132, v39
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v149, v150
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v153, v132, v40
	v_mul_f32_e32 v154, v132, v41
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v151, v152
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v155, v132, v42
	v_mul_f32_e32 v156, v132, v43
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v153, v154
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v157, v132, v44
	v_mul_f32_e32 v158, v132, v45
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v155, v156
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v159, v132, v46
	v_mul_f32_e32 v160, v132, v47
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v157, v158
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v161, v132, v48
	v_mul_f32_e32 v162, v132, v49
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v159, v160
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v163, v132, v50
	v_mul_f32_e32 v164, v132, v51
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v161, v162
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v165, v132, v52
	v_mul_f32_e32 v166, v132, v53
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v163, v164
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v167, v132, v54
	v_mul_f32_e32 v168, v132, v55
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v165, v166
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v169, v132, v56
	v_mul_f32_e32 v170, v132, v57
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v167, v168
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v171, v132, v58
	v_mul_f32_e32 v172, v132, v59
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v169, v170
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v173, v132, v60
	v_mul_f32_e32 v174, v132, v61
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v171, v172
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v175, v132, v62
	v_mul_f32_e32 v176, v132, v63
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v173, v174
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v177, v132, v64
	v_mul_f32_e32 v178, v132, v65
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v147, v147, v175, v176
	v_max3_f32 v147, v147, v177, v178
	.loc	2 189 40                        ; standard.py:189:40 @[ mha.py:793:12 ]
	v_mov_b32_e32 v148, v147
	s_nop 1
	v_permlane32_swap_b32_e32 v147, v148
	.loc	1 212 31                        ; mha.py:212:31 @[ mha.py:793:12 ]
	v_max3_f32 v147, v137, v147, v148
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v34, v132, v34, -v147
	v_fma_f32 v35, v132, v35, -v147
	v_fma_f32 v36, v132, v36, -v147
	v_fma_f32 v152, v132, v60, -v147
	v_fma_f32 v153, v132, v61, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v60, v34
	v_exp_f32_e32 v61, v35
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v37, v132, v37, -v147
	v_fma_f32 v154, v132, v62, -v147
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v62, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v38, v132, v38, -v147
	v_fma_f32 v155, v132, v63, -v147
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v63, v37
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v39, v132, v39, -v147
	v_fma_f32 v156, v132, v64, -v147
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v64, v38
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v40, v132, v40, -v147
	v_fma_f32 v157, v132, v65, -v147
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v65, v39
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v60, v61
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v41, v132, v41, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v148, v40
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v62, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v42, v132, v42, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v149, v41
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v63, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v43, v132, v43, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v36, v42
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v64, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v44, v132, v44, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v37, v43
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v65, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v45, v132, v45, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v39, v44
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v148, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v46, v132, v46, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v41, v45
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v149, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v47, v132, v47, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v45, v46
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v36, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v48, v132, v48, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v47, v47
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v37, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v49, v132, v49, -v147
	v_fma_f32 v150, v132, v51, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v51, v48
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v39, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v50, v132, v50, -v147
	v_fma_f32 v151, v132, v53, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v53, v49
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v41, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v38, v50
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v45, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v52, v132, v52, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v40, v150
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v47, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v43, v52
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v51, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v54, v132, v54, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v46, v151
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v53, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v55, v132, v55, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v49, v54
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v38, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v56, v132, v56, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v52, v55
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v40, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v57, v132, v57, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v55, v56
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v43, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v58, v132, v58, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v57, v57
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v46, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v59, v132, v59, -v147
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v42, v58
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v49, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v44, v59
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v52, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v48, v152
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v55, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v50, v153
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v57, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v54, v154
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v42, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v56, v155
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v44, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v58, v156
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v48, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v59, v157
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v50, v34
	v_add_f32_e32 v34, v54, v34
	v_add_f32_e32 v34, v56, v34
	v_add_f32_e32 v34, v58, v34
	v_add_f32_e32 v34, v59, v34
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:793:12 ]
	v_mov_b32_e32 v35, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_and_b64 vcc, exec, s[10:11]
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:793:12 ]
	s_nop 0
	v_permlane32_swap_b32_e32 v34, v35
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_42
; %bb.41:
	.loc	1 249 35                        ; mha.py:249:35 @[ mha.py:793:12 ]
	v_sub_f32_e32 v137, v137, v147
	.loc	1 249 29 is_stmt 0              ; mha.py:249:29 @[ mha.py:793:12 ]
	v_exp_f32_e32 v152, v137
	.loc	1 267 30 is_stmt 1              ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v151, v148, v149
	v_cvt_pk_bf16_f32 v150, v64, v65
	v_cvt_pk_bf16_f32 v149, v62, v63
	v_cvt_pk_bf16_f32 v148, v60, v61
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_pk_mul_f32 v[32:33], v[32:33], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[152:153] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[152:153] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[110:113], v[148:151], v[18:33]
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v63, v51, v53
	v_cvt_pk_bf16_f32 v62, v45, v47
	v_cvt_pk_bf16_f32 v61, v39, v41
	v_cvt_pk_bf16_f32 v60, v36, v37
	v_cvt_pk_bf16_f32 v39, v58, v59
	v_cvt_pk_bf16_f32 v37, v48, v50
	v_cvt_pk_bf16_f32 v36, v42, v44
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[90:93], v[148:151], v[2:17]
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v34, v35
	.loc	1 256 28                        ; mha.py:256:28 @[ mha.py:793:12 ]
	v_fmac_f32_e32 v34, v127, v152
	v_mov_b32_e32 v137, v147
	v_mov_b32_e32 v127, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[106:109], v[60:63], v[18:33]
	.loc	1 267 30 is_stmt 0              ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v109, v55, v57
	v_cvt_pk_bf16_f32 v108, v49, v52
	v_cvt_pk_bf16_f32 v107, v43, v46
	v_cvt_pk_bf16_f32 v106, v38, v40
	v_cvt_pk_bf16_f32 v38, v54, v56
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[86:89], v[60:63], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[102:105], v[106:109], v[18:33]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[94:97], v[106:109], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[98:101], v[36:39], v[18:33]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[82:85], v[36:39], v[2:17]
.LBB0_42:
	.loc	1 40 25 is_stmt 1               ; mha.py:40:25 @[ mha.py:793:12 ]
	v_lshl_add_u32 v35, v139, 1, s28
	v_lshl_add_u32 v34, v138, 1, s28
	v_lshl_add_u32 v36, v140, 1, s28
	v_lshl_add_u32 v37, v141, 1, s28
	v_lshl_add_u32 v38, v142, 1, s28
	v_lshl_add_u32 v39, v143, 1, s28
	v_lshl_add_u32 v40, v144, 1, s28
	v_lshl_add_u32 v41, v145, 1, s28
	v_lshl_add_u32 v42, v146, 1, s28
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[112:113], v35
	ds_read_b64_tr_b16 v[108:109], v36
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[104:105], v37
	ds_read_b64_tr_b16 v[100:101], v38
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[110:111], v34
	ds_read_b64_tr_b16 v[106:107], v34 offset:2048
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[86:87], v34 offset:2112
	ds_read_b64_tr_b16 v[90:91], v34 offset:64
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[102:103], v34 offset:4096
	ds_read_b64_tr_b16 v[98:99], v34 offset:6144
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[82:83], v34 offset:6208
	ds_read_b64_tr_b16 v[94:95], v34 offset:4160
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[92:93], v39
	ds_read_b64_tr_b16 v[88:89], v40
	s_waitcnt lgkmcnt(14)
	ds_read_b64_tr_b16 v[96:97], v41
	ds_read_b64_tr_b16 v[84:85], v42
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:793:12 ]
	s_or_b32 s12, s14, 63
	s_cmpk_gt_i32 s12, 0x7f
	s_cselect_b64 s[10:11], -1, 0
	s_cmpk_lt_i32 s12, 0x80
	v_mov_b32_e32 v34, 0
	v_mov_b32_e32 v35, 0
	v_mov_b32_e32 v36, 0
	v_mov_b32_e32 v37, 0
	v_mov_b32_e32 v38, 0
	v_mov_b32_e32 v39, 0
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	v_mov_b32_e32 v42, 0
	v_mov_b32_e32 v43, 0
	v_mov_b32_e32 v44, 0
	v_mov_b32_e32 v45, 0
	v_mov_b32_e32 v46, 0
	v_mov_b32_e32 v47, 0
	v_mov_b32_e32 v48, 0
	v_mov_b32_e32 v49, 0
	v_mov_b32_e32 v50, 0
	v_mov_b32_e32 v51, 0
	v_mov_b32_e32 v52, 0
	v_mov_b32_e32 v53, 0
	v_mov_b32_e32 v54, 0
	v_mov_b32_e32 v55, 0
	v_mov_b32_e32 v56, 0
	v_mov_b32_e32 v57, 0
	v_mov_b32_e32 v58, 0
	v_mov_b32_e32 v59, 0
	v_mov_b32_e32 v60, 0
	v_mov_b32_e32 v61, 0
	v_mov_b32_e32 v62, 0
	v_mov_b32_e32 v63, 0
	v_mov_b32_e32 v64, 0
	v_mov_b32_e32 v65, 0
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_cbranch_scc1 .LBB0_44
; %bb.43:
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	v_add_u32_e32 v54, s27, v133
	ds_read_b128 v[34:37], v54
	v_add_u32_e32 v133, s27, v136
	ds_read_b128 v[50:53], v133
	v_add_u32_e32 v135, s27, v135
	v_add_u32_e32 v134, s27, v134
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[34:37], v[66:69], 0
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[138:141], v133 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[70:73], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v135
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[74:77], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v134
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[50:53], v[78:81], v[34:49]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[50:53], v54 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[50:53], v[66:69], 0
	v_mfma_f32_32x32x16_bf16 v[50:65], v[138:141], v[70:73], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[138:141], v135 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[138:141], v[74:77], v[50:65]
	.loc	1 40 25                         ; mha.py:40:25 @[ mha.py:793:12 ]
	ds_read_b128 v[138:141], v134 offset:4096
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[138:141], v[78:81], v[50:65]
.LBB0_44:
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	s_nop 1
	v_mul_f32_e32 v133, v132, v34
	v_mul_f32_e32 v134, v132, v35
	v_mul_f32_e32 v135, v132, v36
	v_mul_f32_e32 v136, v132, v37
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max_f32_e32 v133, v133, v134
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v138, v132, v38
	v_mul_f32_e32 v139, v132, v39
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v135, v136
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v140, v132, v40
	v_mul_f32_e32 v141, v132, v41
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v138, v139
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v142, v132, v42
	v_mul_f32_e32 v143, v132, v43
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v140, v141
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v144, v132, v44
	v_mul_f32_e32 v145, v132, v45
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v142, v143
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v146, v132, v46
	v_mul_f32_e32 v147, v132, v47
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v144, v145
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v148, v132, v48
	v_mul_f32_e32 v149, v132, v49
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v146, v147
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v150, v132, v50
	v_mul_f32_e32 v151, v132, v51
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v148, v149
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v152, v132, v52
	v_mul_f32_e32 v153, v132, v53
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v150, v151
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v154, v132, v54
	v_mul_f32_e32 v155, v132, v55
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v152, v153
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v156, v132, v56
	v_mul_f32_e32 v157, v132, v57
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v154, v155
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v158, v132, v58
	v_mul_f32_e32 v159, v132, v59
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v156, v157
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v160, v132, v60
	v_mul_f32_e32 v161, v132, v61
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v158, v159
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v162, v132, v62
	v_mul_f32_e32 v163, v132, v63
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v160, v161
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:793:12 ]
	v_mul_f32_e32 v164, v132, v64
	v_mul_f32_e32 v165, v132, v65
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:793:12 ]
	v_max3_f32 v133, v133, v162, v163
	v_max3_f32 v133, v133, v164, v165
	.loc	2 189 40                        ; standard.py:189:40 @[ mha.py:793:12 ]
	v_mov_b32_e32 v134, v133
	s_nop 1
	v_permlane32_swap_b32_e32 v133, v134
	.loc	1 212 31                        ; mha.py:212:31 @[ mha.py:793:12 ]
	v_max3_f32 v133, v137, v133, v134
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v34, v132, v34, -v133
	v_fma_f32 v35, v132, v35, -v133
	v_fma_f32 v36, v132, v36, -v133
	v_fma_f32 v138, v132, v60, -v133
	v_fma_f32 v139, v132, v61, -v133
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v60, v34
	v_exp_f32_e32 v61, v35
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v37, v132, v37, -v133
	v_fma_f32 v140, v132, v62, -v133
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v62, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v38, v132, v38, -v133
	v_fma_f32 v141, v132, v63, -v133
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v63, v37
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v39, v132, v39, -v133
	v_fma_f32 v142, v132, v64, -v133
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v64, v38
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v40, v132, v40, -v133
	v_fma_f32 v143, v132, v65, -v133
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v65, v39
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v60, v61
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:793:12 ]
	v_fma_f32 v41, v132, v41, -v133
	v_fma_f32 v42, v132, v42, -v133
	v_fma_f32 v43, v132, v43, -v133
	v_fma_f32 v44, v132, v44, -v133
	v_fma_f32 v45, v132, v45, -v133
	v_fma_f32 v46, v132, v46, -v133
	v_fma_f32 v47, v132, v47, -v133
	v_fma_f32 v48, v132, v48, -v133
	v_fma_f32 v49, v132, v49, -v133
	v_fma_f32 v50, v132, v50, -v133
	v_fma_f32 v135, v132, v51, -v133
	v_fma_f32 v52, v132, v52, -v133
	v_fma_f32 v136, v132, v53, -v133
	v_fma_f32 v54, v132, v54, -v133
	v_fma_f32 v55, v132, v55, -v133
	v_fma_f32 v56, v132, v56, -v133
	v_fma_f32 v57, v132, v57, -v133
	v_fma_f32 v58, v132, v58, -v133
	v_fma_f32 v59, v132, v59, -v133
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v132, v40
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v62, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v134, v41
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v63, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v36, v42
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v64, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v37, v43
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v65, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v39, v44
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v132, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v41, v45
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v134, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v45, v46
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v36, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v47, v47
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v37, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v51, v48
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v39, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v53, v49
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v41, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v38, v50
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v45, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v40, v135
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v47, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v43, v52
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v51, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v46, v136
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v53, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v49, v54
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v38, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v52, v55
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v40, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v55, v56
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v43, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v57, v57
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v46, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v42, v58
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v49, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v44, v59
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v52, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v48, v138
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v55, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v50, v139
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v57, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v54, v140
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v42, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v56, v141
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v44, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v58, v142
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v48, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:793:12 ]
	v_exp_f32_e32 v59, v143
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v50, v34
	v_add_f32_e32 v34, v54, v34
	v_add_f32_e32 v34, v56, v34
	v_add_f32_e32 v34, v58, v34
	v_add_f32_e32 v34, v59, v34
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:793:12 ]
	v_mov_b32_e32 v35, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_andn2_b64 vcc, exec, s[10:11]
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:793:12 ]
	s_nop 0
	v_permlane32_swap_b32_e32 v34, v35
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_cbranch_vccnz .LBB0_46
; %bb.45:
	.loc	1 249 35                        ; mha.py:249:35 @[ mha.py:793:12 ]
	v_sub_f32_e32 v135, v137, v133
	.loc	1 249 29 is_stmt 0              ; mha.py:249:29 @[ mha.py:793:12 ]
	v_exp_f32_e32 v138, v135
	.loc	1 267 30 is_stmt 1              ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v137, v132, v134
	v_cvt_pk_bf16_f32 v136, v64, v65
	v_cvt_pk_bf16_f32 v135, v62, v63
	v_cvt_pk_bf16_f32 v134, v60, v61
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:793:12 ]
	v_pk_mul_f32 v[32:33], v[32:33], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[138:139] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[138:139] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[110:113], v[134:137], v[18:33]
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v63, v51, v53
	v_cvt_pk_bf16_f32 v62, v45, v47
	v_cvt_pk_bf16_f32 v61, v39, v41
	v_cvt_pk_bf16_f32 v60, v36, v37
	v_cvt_pk_bf16_f32 v39, v58, v59
	v_cvt_pk_bf16_f32 v37, v48, v50
	v_cvt_pk_bf16_f32 v36, v42, v44
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[90:93], v[134:137], v[2:17]
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:793:12 ]
	v_add_f32_e32 v34, v34, v35
	.loc	1 256 28                        ; mha.py:256:28 @[ mha.py:793:12 ]
	v_fmac_f32_e32 v34, v127, v138
	v_mov_b32_e32 v127, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[106:109], v[60:63], v[18:33]
	.loc	1 267 30 is_stmt 0              ; mha.py:267:30 @[ mha.py:793:12 ]
	v_cvt_pk_bf16_f32 v109, v55, v57
	v_cvt_pk_bf16_f32 v108, v49, v52
	v_cvt_pk_bf16_f32 v107, v43, v46
	v_cvt_pk_bf16_f32 v106, v38, v40
	v_cvt_pk_bf16_f32 v38, v54, v56
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:793:12 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[86:89], v[60:63], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[102:105], v[106:109], v[18:33]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[94:97], v[106:109], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[98:101], v[36:39], v[18:33]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[82:85], v[36:39], v[2:17]
	s_load_dword s80, s[0:1], 0x58
.Ltmp23:
	.loc	1 807 23 is_stmt 1              ; mha.py:807:23
	s_cmp_lt_i32 s26, 1
	.loc	1 807 7 is_stmt 0               ; mha.py:807:7
	s_cbranch_scc0 .LBB0_47
	s_branch .LBB0_60
.LBB0_46:
	.loc	1 0 7                           ; mha.py:0:7
	v_mov_b32_e32 v133, v137
	s_load_dword s80, s[0:1], 0x58
	.loc	1 807 23 is_stmt 1              ; mha.py:807:23
	s_cmp_lt_i32 s26, 1
	.loc	1 807 7 is_stmt 0               ; mha.py:807:7
	s_cbranch_scc1 .LBB0_60
.LBB0_47:
	.loc	1 742 27 is_stmt 1              ; mha.py:742:27
	s_lshl_b32 s81, s24, 6
.Ltmp24:
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_cmp_ge_i32 s14, s81
	s_cbranch_scc1 .LBB0_60
.Ltmp25:
; %bb.48:                               ; %.lr.ph319
	.loc	1 812 34                        ; mha.py:812:34
	s_lshl_b32 s1, s25, 6
	.loc	1 815 44                        ; mha.py:815:44
	s_mul_i32 s12, s1, s22
	v_lshlrev_b32_e32 v38, 2, v0
.Ltmp26:
	.loc	1 272 28                        ; mha.py:272:28 @[ mha.py:857:12 ]
	s_lshl_b32 s0, s22, 6
	.loc	1 269 28                        ; mha.py:269:28 @[ mha.py:857:12 ]
	s_lshl_b32 s10, s15, 6
.Ltmp27:
	.loc	1 815 18                        ; mha.py:815:18
	s_ashr_i32 s13, s12, 31
	.loc	1 812 44                        ; mha.py:812:44
	s_mul_i32 s16, s1, s15
	v_lshrrev_b32_e32 v37, 1, v131
	v_and_b32_e32 v38, 12, v38
	v_bfe_i32 v39, v0, 3, 1
	v_and_b32_e32 v0, 16, v0
	v_mov_b32_e32 v40, 0x108
	s_movk_i32 s1, 0x84
	.loc	1 812 18 is_stmt 0              ; mha.py:812:18
	s_ashr_i32 s17, s16, 31
	s_waitcnt lgkmcnt(0)
	v_xor_b32_e32 v99, v1, v37
	v_cndmask_b32_e64 v40, v40, 0, s[2:3]
	v_and_or_b32 v0, v1, 64, v0
	v_bitop3_b32 v1, v39, v38, s1 bitop3:0x6c
	s_ashr_i32 s11, s10, 31
	s_ashr_i32 s1, s0, 31
.Ltmp28:
	.loc	1 135 59 is_stmt 1              ; mha.py:135:59 @[ mha.py:857:12 ]
	s_lshl_b64 s[2:3], s[12:13], 1
	s_add_u32 s68, s6, s2
	.loc	1 180 30                        ; mha.py:180:30 @[ mha.py:857:12 ]
	v_mov_b32_e32 v34, 0x3fb8aa3b
	v_bitop3_b32 v98, v128, v130, v129 bitop3:0x36
	v_xor_b32_e32 v1, v1, v40
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_addc_u32 s69, s7, s3
	s_lshl_b64 s[70:71], s[0:1], 1
	s_lshl_b64 s[0:1], s[16:17], 1
	.loc	1 180 30                        ; mha.py:180:30 @[ mha.py:857:12 ]
	v_mul_f32_e32 v96, s23, v34
	v_xor_b32_e32 v34, 32, v98
	v_xor_b32_e32 v35, 64, v98
	v_xor_b32_e32 v36, 0x60, v98
	v_xor_b32_e32 v37, 8, v99
	v_or_b32_e32 v38, v0, v1
	v_bitop3_b32 v0, v0, 16, v1 bitop3:0x36
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_add_u32 s72, s4, s0
.Ltmp29:
	.loc	1 605 17                        ; mha.py:605:17
	v_lshrrev_b32_e32 v97, 3, v122
	v_lshl_add_u32 v100, v38, 1, 0
	v_lshl_add_u32 v101, v0, 1, 0
.Ltmp30:
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	v_lshlrev_b64 v[0:1], 1, v[120:121]
	v_lshlrev_b64 v[90:91], 1, v[118:119]
	v_lshlrev_b64 v[92:93], 1, v[116:117]
	s_addc_u32 s73, s5, s1
	s_lshl_b64 s[74:75], s[10:11], 1
	v_lshlrev_b64 v[94:95], 1, v[114:115]
	s_sub_i32 s82, s81, 64
	v_add_u32_e32 v102, 0, v34
	v_add_u32_e32 v103, 0, v35
	v_add_u32_e32 v104, 0, v36
	v_add_u32_e32 v105, 0, v37
	v_mov_b32_e32 v106, 0xff800000
.LBB0_49:                               ; =>This Inner Loop Header: Depth=1
	.loc	1 139 33                        ; mha.py:139:33 @[ mha.py:857:12 ]
	v_add_u32_e32 v35, s14, v123
	.loc	1 37 40                         ; mha.py:37:40 @[ mha.py:857:12 ]
	v_cmp_gt_i32_e32 vcc, s79, v35
	v_mov_b32_e32 v34, 0
	v_mov_b32_e32 v38, 0
	v_mov_b32_e32 v39, 0
	v_mov_b32_e32 v40, 0
	v_mov_b32_e32 v41, 0
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	s_and_saveexec_b64 s[0:1], vcc
	s_cbranch_execz .LBB0_51
; %bb.50:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 139 33                        ; mha.py:139:33 @[ mha.py:857:12 ]
	v_lshl_add_u64 v[36:37], s[72:73], 0, v[94:95]
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	global_load_dwordx4 v[38:41], v[36:37], off
.LBB0_51:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	s_or_b64 exec, exec, s[0:1]
	.loc	1 37 40 is_stmt 1               ; mha.py:37:40 @[ mha.py:857:12 ]
	v_add_u32_e32 v35, 32, v35
	v_cmp_gt_i32_e64 s[0:1], s79, v35
	v_mov_b32_e32 v35, 0
	v_mov_b32_e32 v36, 0
	v_mov_b32_e32 v37, 0
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_53
; %bb.52:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 139 33                        ; mha.py:139:33 @[ mha.py:857:12 ]
	v_lshl_add_u64 v[34:35], s[72:73], 0, v[92:93]
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	global_load_dwordx4 v[34:37], v[34:35], off
.LBB0_53:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v82, 0
	v_mov_b32_e32 v86, 0
	v_mov_b32_e32 v87, 0
	v_mov_b32_e32 v88, 0
	v_mov_b32_e32 v89, 0
	.loc	1 35 25 is_stmt 1               ; mha.py:35:25 @[ mha.py:857:12 ]
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_55
; %bb.54:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 139 33                        ; mha.py:139:33 @[ mha.py:857:12 ]
	v_lshl_add_u64 v[42:43], s[68:69], 0, v[90:91]
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	global_load_dwordx4 v[86:89], v[42:43], off
.LBB0_55:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v83, 0
	v_mov_b32_e32 v84, 0
	v_mov_b32_e32 v85, 0
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_57
; %bb.56:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 139 33 is_stmt 1              ; mha.py:139:33 @[ mha.py:857:12 ]
	v_lshl_add_u64 v[42:43], s[68:69], 0, v[0:1]
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	global_load_dwordx4 v[82:85], v[42:43], off
.LBB0_57:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 0 25 is_stmt 0                ; mha.py:0:25
	s_or_b64 exec, exec, s[2:3]
	.loc	1 38 25 is_stmt 1               ; mha.py:38:25 @[ mha.py:857:12 ]
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write_b128 v126, v[38:41]
	ds_write_b128 v126, v[34:37] offset:4096
	v_add_u32_e32 v38, 0, v98
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[34:37], v38
	ds_read_b128 v[50:53], v38 offset:4096
	ds_read_b128 v[54:57], v102
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[34:37], v[66:69], 0
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	ds_read_b128 v[108:111], v102 offset:4096
	ds_read_b128 v[58:61], v103
	.loc	1 171 36                        ; mha.py:171:36 @[ mha.py:857:12 ]
	s_add_i32 s83, s14, 64
	.loc	1 171 47 is_stmt 0              ; mha.py:171:47 @[ mha.py:857:12 ]
	s_cmp_eq_u32 s82, s14
	.loc	1 172 31 is_stmt 1              ; mha.py:172:31 @[ mha.py:857:12 ]
	v_add_u32_e32 v62, s14, v97
	.loc	1 171 47                        ; mha.py:171:47 @[ mha.py:857:12 ]
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 172 31                        ; mha.py:172:31 @[ mha.py:857:12 ]
	v_add_u32_e32 v63, 1, v62
	v_add_u32_e32 v64, 2, v62
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[54:57], v[70:73], v[34:49]
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	ds_read_b128 v[112:115], v103 offset:4096
	ds_read_b128 v[54:57], v104
	.loc	1 172 31                        ; mha.py:172:31 @[ mha.py:857:12 ]
	v_add_u32_e32 v65, 3, v62
	.loc	1 171 63                        ; mha.py:171:63 @[ mha.py:857:12 ]
	s_and_b64 s[76:77], s[66:67], s[0:1]
	.loc	1 172 31                        ; mha.py:172:31 @[ mha.py:857:12 ]
	v_add_u32_e32 v107, 8, v62
	v_add_u32_e32 v120, 9, v62
	v_add_u32_e32 v121, 10, v62
	v_add_u32_e32 v128, 11, v62
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[58:61], v[74:77], v[34:49]
	.loc	1 172 31                        ; mha.py:172:31 @[ mha.py:857:12 ]
	v_add_u32_e32 v129, 16, v62
	v_add_u32_e32 v130, 17, v62
	v_add_u32_e32 v131, 18, v62
	v_add_u32_e32 v132, 19, v62
	v_add_u32_e32 v134, 24, v62
	v_add_u32_e32 v135, 25, v62
	v_add_u32_e32 v136, 26, v62
	v_add_u32_e32 v137, 27, v62
	v_add_u32_e32 v138, 32, v62
	v_add_u32_e32 v139, 33, v62
	v_add_u32_e32 v140, 34, v62
	v_add_u32_e32 v141, 35, v62
	v_add_u32_e32 v142, 40, v62
	v_add_u32_e32 v143, 41, v62
	v_add_u32_e32 v144, 42, v62
	v_add_u32_e32 v145, 43, v62
	v_add_u32_e32 v146, 48, v62
	v_add_u32_e32 v147, 49, v62
	v_add_u32_e32 v148, 50, v62
	v_add_u32_e32 v149, 51, v62
	v_add_u32_e32 v150, 56, v62
	v_add_u32_e32 v151, 57, v62
	v_add_u32_e32 v152, 58, v62
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_add_u32_e32 v153, 59, v62
	v_cmp_le_i32_e32 vcc, s79, v62
	v_cmp_le_i32_e64 s[0:1], s79, v63
	v_cmp_le_i32_e64 s[2:3], s79, v64
	v_cmp_le_i32_e64 s[4:5], s79, v65
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[54:57], v[78:81], v[34:49]
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	ds_read_b128 v[116:119], v104 offset:4096
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], vcc
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[6:7], s79, v107
	v_cmp_le_i32_e64 s[10:11], s79, v120
	v_cmp_le_i32_e64 s[12:13], s79, v121
	v_cmp_le_i32_e64 s[14:15], s79, v128
	v_cmp_le_i32_e64 s[16:17], s79, v129
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[50:53], v[66:69], 0
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	s_nop 3
	v_mul_f32_e32 v34, v96, v34
	v_mul_f32_e32 v35, v96, v35
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v107, v34, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[0:1]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v36, v96, v36
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v35, v35, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[2:3]
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[108:111], v[70:73], v[50:65]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v37, v96, v37
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v36, v36, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[4:5]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v38, v96, v38
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v37, v37, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[6:7]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v39, v96, v39
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[112:115], v[74:77], v[50:65]
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v38, v38, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[10:11]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v40, v96, v40
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v39, v39, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[12:13]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v41, v96, v41
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v40, v40, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[14:15]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[18:19], s79, v130
	.loc	1 185 23                        ; mha.py:185:23 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[116:119], v[78:81], v[50:65]
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v42, v96, v42
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v41, v41, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[16:17]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[20:21], s79, v131
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v43, v96, v43
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v42, v42, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[18:19]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[22:23], s79, v132
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v44, v96, v44
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v43, v43, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[20:21]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[24:25], s79, v134
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v45, v96, v45
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v44, v44, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[22:23]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[26:27], s79, v135
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v46, v96, v46
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v45, v45, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[24:25]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[28:29], s79, v136
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v47, v96, v47
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v46, v46, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[26:27]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[30:31], s79, v137
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v48, v96, v48
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v47, v47, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[28:29]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[34:35], s79, v138
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v49, v96, v49
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v48, v48, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[30:31]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[36:37], s79, v139
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v50, v96, v50
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v49, v49, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[34:35]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[38:39], s79, v140
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v51, v96, v51
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v50, v50, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[36:37]
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[40:41], s79, v141
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v52, v96, v52
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v51, v51, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[38:39]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max_f32_e32 v34, v107, v35
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[42:43], s79, v142
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v53, v96, v53
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v52, v52, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[40:41]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v36, v37
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[44:45], s79, v143
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v54, v96, v54
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v53, v53, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[42:43]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v38, v39
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[46:47], s79, v144
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v55, v96, v55
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v54, v54, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[44:45]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v40, v41
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[48:49], s79, v145
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v56, v96, v56
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v55, v55, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[46:47]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v42, v43
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[50:51], s79, v146
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v57, v96, v57
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v56, v56, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[48:49]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v44, v45
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[52:53], s79, v147
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v58, v96, v58
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v57, v57, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[50:51]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v46, v47
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[54:55], s79, v148
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v59, v96, v59
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v58, v58, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[52:53]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v48, v49
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[56:57], s79, v149
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v60, v96, v60
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v59, v59, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[54:55]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v50, v51
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[58:59], s79, v150
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v61, v96, v61
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v60, v60, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[56:57]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v52, v53
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[60:61], s79, v151
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v62, v96, v62
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v61, v61, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[58:59]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v54, v55
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[62:63], s79, v152
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v63, v96, v63
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v62, v62, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[60:61]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v56, v57
	.loc	1 173 36                        ; mha.py:173:36 @[ mha.py:857:12 ]
	v_cmp_le_i32_e64 s[64:65], s79, v153
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v64, v96, v64
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v63, v63, v106, vcc
	.loc	1 174 54                        ; mha.py:174:54 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[62:63]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v58, v59
	.loc	1 189 22                        ; mha.py:189:22 @[ mha.py:857:12 ]
	v_mul_f32_e32 v65, v96, v65
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v64, v64, v106, vcc
	.loc	1 38 25                         ; mha.py:38:25 @[ mha.py:857:12 ]
	s_and_b64 vcc, s[76:77], s[64:65]
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v60, v61
	.loc	1 201 32                        ; mha.py:201:32 @[ mha.py:857:12 ]
	v_cndmask_b32_e32 v65, v65, v106, vcc
	.loc	2 168 27                        ; standard.py:168:27 @[ mha.py:857:12 ]
	v_max3_f32 v34, v34, v62, v63
	v_max3_f32 v34, v34, v64, v65
	.loc	2 189 40                        ; standard.py:189:40 @[ mha.py:857:12 ]
	v_mov_b32_e32 v108, v34
	s_nop 1
	v_permlane32_swap_b32_e32 v34, v108
	.loc	1 212 31                        ; mha.py:212:31 @[ mha.py:857:12 ]
	v_max3_f32 v34, v133, v34, v108
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v107, v107, v34
	v_sub_f32_e32 v35, v35, v34
	v_sub_f32_e32 v36, v36, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v107, v107
	v_exp_f32_e32 v35, v35
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v37, v37, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v109, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v38, v38, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v37, v37
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v39, v39, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v38, v38
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v40, v40, v34
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v39, v39
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v107, v35
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v41, v41, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v40, v40
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v109, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v42, v42, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v41, v41
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v37, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v43, v43, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v42, v42
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v38, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v44, v44, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v43, v43
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v39, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v45, v45, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v44, v44
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v40, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v46, v46, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v45, v45
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v41, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v47, v47, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v110, v46
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v42, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v48, v48, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v111, v47
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v43, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v49, v49, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v112, v48
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v44, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v50, v50, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v113, v49
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v45, v36
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v51, v51, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v114, v50
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v110, v36
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v115, v51
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v36, v111, v36
	v_add_f32_e32 v36, v112, v36
	v_add_f32_e32 v36, v113, v36
	v_add_f32_e32 v36, v114, v36
	v_add_f32_e32 v137, v115, v36
	.loc	1 249 35                        ; mha.py:249:35 @[ mha.py:857:12 ]
	v_sub_f32_e32 v36, v133, v34
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v52, v52, v34
	v_sub_f32_e32 v53, v53, v34
	v_sub_f32_e32 v54, v54, v34
	v_sub_f32_e32 v55, v55, v34
	v_sub_f32_e32 v56, v56, v34
	v_sub_f32_e32 v57, v57, v34
	.loc	1 249 29                        ; mha.py:249:29 @[ mha.py:857:12 ]
	v_exp_f32_e32 v108, v36
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v36, v107, v35
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	v_add_u32_e32 v35, 0, v99
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v116, v52
	v_exp_f32_e32 v117, v53
	v_exp_f32_e32 v118, v54
	v_exp_f32_e32 v119, v55
	v_exp_f32_e32 v120, v56
	v_exp_f32_e32 v121, v57
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v38, v38, v39
	v_cvt_pk_bf16_f32 v39, v40, v41
	v_cvt_pk_bf16_f32 v40, v42, v43
	v_cvt_pk_bf16_f32 v41, v44, v45
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	s_barrier
	ds_write2st64_b64 v35, v[86:87], v[82:83] offset1:8
	ds_write2st64_b64 v105, v[88:89], v[84:85] offset1:8
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[42:43], v100
	ds_read_b64_tr_b16 v[46:47], v100 offset:2048
	ds_read_b64_tr_b16 v[50:51], v100 offset:2112
	ds_read_b64_tr_b16 v[54:55], v100 offset:64
	ds_read_b64_tr_b16 v[44:45], v101 offset:1024
	ds_read_b64_tr_b16 v[48:49], v101 offset:3072
	ds_read_b64_tr_b16 v[52:53], v101 offset:3136
	ds_read_b64_tr_b16 v[56:57], v101 offset:1088
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v37, v109, v37
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:857:12 ]
	v_pk_mul_f32 v[32:33], v[32:33], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[108:109] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[42:45], v[36:39], v[18:33]
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v42, v110, v111
	v_cvt_pk_bf16_f32 v43, v112, v113
	.loc	1 215 30 is_stmt 1              ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v62, v62, v34
	v_sub_f32_e32 v63, v63, v34
	v_sub_f32_e32 v64, v64, v34
	v_sub_f32_e32 v65, v65, v34
	.loc	1 215 25 is_stmt 0              ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v132, v62
	.loc	1 267 50 is_stmt 1              ; mha.py:267:50 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[54:57], v[36:39], v[2:17]
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v134, v63
	v_exp_f32_e32 v135, v64
	v_exp_f32_e32 v136, v65
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	ds_read_b64_tr_b16 v[62:63], v100 offset:4096
	ds_read_b64_tr_b16 v[64:65], v101 offset:5120
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v58, v58, v34
	v_sub_f32_e32 v59, v59, v34
	v_sub_f32_e32 v60, v60, v34
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[46:49], v[40:43], v[18:33]
	.loc	1 35 25                         ; mha.py:35:25 @[ mha.py:857:12 ]
	ds_read_b64_tr_b16 v[44:45], v100 offset:6144
	ds_read_b64_tr_b16 v[82:83], v100 offset:6208
	ds_read_b64_tr_b16 v[86:87], v100 offset:4160
	ds_read_b64_tr_b16 v[46:47], v101 offset:7168
	ds_read_b64_tr_b16 v[84:85], v101 offset:7232
	ds_read_b64_tr_b16 v[88:89], v101 offset:5184
	.loc	1 215 30                        ; mha.py:215:30 @[ mha.py:857:12 ]
	v_sub_f32_e32 v61, v61, v34
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v35, v116, v137
	.loc	1 215 25                        ; mha.py:215:25 @[ mha.py:857:12 ]
	v_exp_f32_e32 v128, v58
	v_exp_f32_e32 v129, v59
	v_exp_f32_e32 v130, v60
	v_exp_f32_e32 v131, v61
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[50:53], v[40:43], v[2:17]
	.loc	1 267 30 is_stmt 0              ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v58, v114, v115
	v_cvt_pk_bf16_f32 v59, v116, v117
	v_cvt_pk_bf16_f32 v60, v118, v119
	v_cvt_pk_bf16_f32 v61, v120, v121
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v35, v117, v35
	v_add_f32_e32 v35, v118, v35
	v_add_f32_e32 v35, v119, v35
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[62:65], v[58:61], v[18:33]
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v35, v120, v35
	v_add_f32_e32 v35, v121, v35
	v_add_f32_e32 v35, v128, v35
	v_add_f32_e32 v35, v129, v35
	v_add_f32_e32 v35, v130, v35
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v62, v128, v129
	v_cvt_pk_bf16_f32 v63, v130, v131
	.loc	1 267 50 is_stmt 0              ; mha.py:267:50 @[ mha.py:857:12 ]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[86:89], v[58:61], v[2:17]
	.loc	1 267 30                        ; mha.py:267:30 @[ mha.py:857:12 ]
	v_cvt_pk_bf16_f32 v64, v132, v134
	v_cvt_pk_bf16_f32 v65, v135, v136
	.loc	2 261 15 is_stmt 1              ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v35, v131, v35
	v_add_f32_e32 v35, v132, v35
	v_add_f32_e32 v35, v134, v35
	v_add_f32_e32 v35, v135, v35
	v_add_f32_e32 v35, v136, v35
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[44:47], v[62:65], v[18:33]
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_add_u32 s68, s68, s70
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:857:12 ]
	v_mov_b32_e32 v36, v35
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_addc_u32 s69, s69, s71
	.loc	2 291 36                        ; standard.py:291:36 @[ mha.py:857:12 ]
	s_nop 0
	v_permlane32_swap_b32_e32 v35, v36
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_add_u32 s72, s72, s74
	.loc	2 261 15                        ; standard.py:261:15 @[ mha.py:857:12 ]
	v_add_f32_e32 v35, v35, v36
	.loc	1 267 50                        ; mha.py:267:50 @[ mha.py:857:12 ]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[82:85], v[62:65], v[2:17]
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_addc_u32 s73, s73, s75
	.loc	1 256 28                        ; mha.py:256:28 @[ mha.py:857:12 ]
	v_fmac_f32_e32 v35, v127, v108
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_cmp_lt_i32 s83, s81
	s_cbranch_scc0 .LBB0_59
; %bb.58:                               ;   in Loop: Header=BB0_49 Depth=1
	.loc	1 0 59 is_stmt 0                ; mha.py:0:59
	v_mov_b32_e32 v133, v34
	v_mov_b32_e32 v127, v35
	s_mov_b32 s14, s83
	.loc	1 135 59                        ; mha.py:135:59 @[ mha.py:857:12 ]
	s_branch .LBB0_49
.Ltmp31:
.LBB0_59:                               ; %.loopexit.loopexit
	.loc	1 0 59                          ; mha.py:0:59
	v_mov_b32_e32 v127, v35
.LBB0_60:                               ; %.loopexit
	.loc	1 869 18 is_stmt 1              ; mha.py:869:18
	v_div_scale_f32 v1, s[0:1], v127, v127, 1.0
	v_rcp_f32_e32 v35, v1
	.loc	1 399 46                        ; mha.py:399:46
	v_lshrrev_b32_e32 v0, 1, v125
	v_or_b32_e32 v0, v0, v124
	.loc	1 399 33 is_stmt 0              ; mha.py:399:33
	v_or_b32_e32 v34, s78, v0
	.loc	1 869 18 is_stmt 1              ; mha.py:869:18
	v_fma_f32 v0, -v1, v35, 1.0
	v_fmac_f32_e32 v35, v0, v35
	v_div_scale_f32 v0, vcc, 1.0, v127, 1.0
	v_mul_f32_e32 v36, v0, v35
	v_fma_f32 v37, -v1, v36, v0
	v_fmac_f32_e32 v36, v37, v35
	v_fma_f32 v0, -v1, v36, v0
	v_div_fmas_f32 v0, v0, v35, v36
	.loc	1 891 32                        ; mha.py:891:32
	s_sub_i32 s2, s78, s33
	.loc	1 869 18                        ; mha.py:869:18
	v_div_fixup_f32 v0, v0, v127, 1.0
	.loc	1 891 32                        ; mha.py:891:32
	s_addk_i32 s2, 0x80
	.loc	1 870 16                        ; mha.py:870:16
	v_pk_mul_f32 v[18:19], v[18:19], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[4:5], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[8:9], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[10:11], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[12:13], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[14:15], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[0:1] op_sel_hi:[1,0]
	.loc	1 932 23                        ; mha.py:932:23
	s_cmp_lt_i32 s2, 1
	.loc	1 690 35                        ; mha.py:690:35
	v_cmp_gt_i32_e64 s[0:1], s33, v34
	.loc	1 932 23                        ; mha.py:932:23
	s_cselect_b64 s[2:3], -1, 0
	.loc	1 936 16                        ; mha.py:936:16
	v_cvt_pk_bf16_f32 v12, v18, v19
	v_cvt_pk_bf16_f32 v13, v20, v21
	v_cvt_pk_bf16_f32 v14, v22, v23
	v_cvt_pk_bf16_f32 v15, v24, v25
	v_cvt_pk_bf16_f32 v8, v26, v27
	v_cvt_pk_bf16_f32 v9, v28, v29
	v_cvt_pk_bf16_f32 v10, v30, v31
	v_cvt_pk_bf16_f32 v11, v32, v33
	v_cvt_pk_bf16_f32 v4, v2, v3
	v_cvt_pk_bf16_f32 v5, v36, v37
	v_cvt_pk_bf16_f32 v6, v6, v7
	v_cvt_pk_bf16_f32 v7, v38, v39
	v_cvt_pk_bf16_f32 v0, v40, v41
	v_cvt_pk_bf16_f32 v1, v42, v43
	v_cvt_pk_bf16_f32 v2, v44, v45
	v_cvt_pk_bf16_f32 v3, v16, v17
	.loc	1 932 7                         ; mha.py:932:7
	s_or_b64 s[0:1], s[2:3], s[0:1]
	.loc	1 936 16                        ; mha.py:936:16
	v_permlane32_swap_b32_e32 v12, v14
	v_permlane32_swap_b32_e32 v13, v15
	v_permlane32_swap_b32_e32 v8, v10
	v_permlane32_swap_b32_e32 v9, v11
	v_permlane32_swap_b32_e32 v4, v6
	v_permlane32_swap_b32_e32 v5, v7
	v_permlane32_swap_b32_e32 v0, v2
	v_permlane32_swap_b32_e32 v1, v3
	.loc	1 937 33                        ; mha.py:937:33
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_62
; %bb.61:                               ; %.critedge
	.loc	1 605 17                        ; mha.py:605:17
	v_lshrrev_b32_e32 v16, 2, v122
	.loc	1 929 10                        ; mha.py:929:10
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[16:17], s[0:1], v34, s80, v[16:17]
	v_add_u32_e32 v18, 48, v16
	v_add_u32_e32 v20, 32, v16
	v_add_u32_e32 v22, 16, v16
	.loc	1 937 23                        ; mha.py:937:23
	v_ashrrev_i32_e32 v17, 31, v16
	v_ashrrev_i32_e32 v19, 31, v18
	v_ashrrev_i32_e32 v21, 31, v20
	v_ashrrev_i32_e32 v23, 31, v22
	v_lshl_add_u64 v[16:17], v[16:17], 1, s[8:9]
	v_lshl_add_u64 v[18:19], v[18:19], 1, s[8:9]
	v_lshl_add_u64 v[20:21], v[20:21], 1, s[8:9]
	v_lshl_add_u64 v[22:23], v[22:23], 1, s[8:9]
	.loc	1 937 33 is_stmt 0              ; mha.py:937:33
	global_store_dwordx4 v[16:17], v[12:15], off
	global_store_dwordx4 v[22:23], v[8:11], off
	global_store_dwordx4 v[20:21], v[4:7], off
	global_store_dwordx4 v[18:19], v[0:3], off
.LBB0_62:                               ; %.critedge4
	.loc	1 937 4                         ; mha.py:937:4
	s_endpgm
.Ltmp32:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 160
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
		.amdhsa_next_free_vgpr 208
		.amdhsa_next_free_sgpr 84
		.amdhsa_accum_offset 208
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
.Lfunc_end0:
	.size	_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0, .Lfunc_end0-_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0
	.cfi_endproc
                                        ; -- End function
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.num_vgpr, 208
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.num_agpr, 0
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.numbered_sgpr, 84
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.private_seg_size, 0
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.uses_vcc, 1
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.uses_flat_scratch, 0
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.has_dyn_sized_stack, 0
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.has_recursion, 0
	.set _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 10676
; TotalNumSgprs: 90
; NumVgprs: 208
; NumAgprs: 0
; TotalNumVgprs: 208
; ScratchSize: 0
; MemoryBound: 1
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 11
; VGPRBlocks: 25
; NumSGPRsForWavesPerEU: 90
; NumVGPRsForWavesPerEU: 208
; AccumOffset: 208
; Occupancy: 2
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 51
; COMPUTE_PGM_RSRC3_GFX90A:TG_SPLIT: 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
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
	.byte	1                               ; Abbrev [1] 0xb:0x5f DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x39 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	529                             ; DW_AT_call_line
	.byte	34                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x4e:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	793                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x5b:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	857                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	.Ltmp26-.Lfunc_begin0
	.quad	.Ltmp27-.Lfunc_begin0
	.quad	.Ltmp28-.Lfunc_begin0
	.quad	.Ltmp29-.Lfunc_begin0
	.quad	.Ltmp30-.Lfunc_begin0
	.quad	.Ltmp31-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"mha.py"                        ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/attention" ; string offset=14
.Linfo_string3:
	.asciz	"_attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0" ; string offset=69
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
      - .offset:         32
        .size:           4
        .value_kind:     by_value
      - .offset:         36
        .size:           4
        .value_kind:     by_value
      - .offset:         40
        .size:           4
        .value_kind:     by_value
      - .offset:         44
        .size:           4
        .value_kind:     by_value
      - .offset:         48
        .size:           4
        .value_kind:     by_value
      - .offset:         52
        .size:           4
        .value_kind:     by_value
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
      - .offset:         136
        .size:           4
        .value_kind:     by_value
      - .offset:         140
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         144
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         152
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 160
    .max_flat_workgroup_size: 256
    .name:           _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0
    .private_segment_fixed_size: 0
    .sgpr_count:     90
    .sgpr_spill_count: 0
    .symbol:         _attn_fwd_IS_CAUSAL_0_NUM_Q_HEADS_1_NUM_K_HEADS_1_BLOCK_M_128_BLOCK_N_64_BLOCK_DMODEL_64_RETURN_SCORES_0_ENABLE_DROPOUT_0_IS_FP8_0_VARLEN_0_NUM_XCD_8_USE_INT64_STRIDES_0_ENABLE_SINK_0_SLIDING_WINDOW_0.kd
    .uses_dynamic_stack: false
    .vgpr_count:     208
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
