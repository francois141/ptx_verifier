	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21 ; -- Begin function _rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21
	.p2align	8
	.type	_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21,@function
_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21: ; @_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.7:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/rope" "rope.py"
	.loc	1 2181 0 prologue_end           ; rope.py:2181:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.8:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b64 s[36:37], s[6:7]
	s_load_dword s6, s[0:1], 0x38
.Ltmp1:
	.loc	1 2227 14 is_stmt 1             ; rope.py:2227:14
	s_cmp_lt_i32 s17, 1
	s_mov_b64 s[24:25], s[10:11]
	s_mov_b64 s[28:29], s[2:3]
	.loc	1 2231 27                       ; rope.py:2231:27
	v_readfirstlane_b32 s10, v0
	.loc	1 2227 14                       ; rope.py:2227:14
	s_cselect_b64 s[2:3], -1, 0
	s_mov_b32 s19, 0
	s_cmp_gt_i32 s17, 0
	.loc	1 2235 26                       ; rope.py:2235:26
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s6, s6, s16
	s_mov_b32 s11, 0
	.loc	1 2234 14                       ; rope.py:2234:14
	s_cbranch_scc0 .LBB0_5
; %bb.1:
	.loc	1 2237 14                       ; rope.py:2237:14
	s_and_b64 s[20:21], s[2:3], exec
	s_cselect_b32 s7, 1, 0
	s_cmp_lg_u32 s7, 1
	s_cbranch_scc0 .LBB0_6
.LBB0_2:
	.loc	1 0 14 is_stmt 0                ; rope.py:0:14
	s_load_dwordx2 s[26:27], s[0:1], 0x3c
	s_load_dword s33, s[0:1], 0x44
	.loc	1 2240 14 is_stmt 1             ; rope.py:2240:14
	s_and_b64 s[0:1], s[2:3], exec
	s_cselect_b32 s0, 1, 0
	s_cmp_lg_u32 s0, 1
	s_mov_b32 s7, 0
	s_cbranch_scc1 .LBB0_4
; %bb.3:
	.loc	1 0 14 is_stmt 0                ; rope.py:0:14
	s_add_i32 s0, s6, 2
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s8, s0
	s_addc_u32 s1, s9, s1
	.loc	1 2240 14                       ; rope.py:2240:14
	s_load_dword s7, s[0:1], 0x0
.LBB0_4:
	.loc	1 2243 11 is_stmt 1             ; rope.py:2243:11
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s39, s7, s19
	.loc	1 2249 40                       ; rope.py:2249:40
	s_abs_i32 s41, s39
	v_cvt_f32_u32_e32 v1, s41
	s_bfe_i32 s45, s18, 0x1001a
	s_ashr_i32 s0, s39, 31
	.loc	1 2219 15                       ; rope.py:2219:15
	s_lshl_b32 s34, s18, 5
	.loc	1 2249 40                       ; rope.py:2249:40
	v_rcp_f32_e32 v1, v1
	.loc	1 2220 23                       ; rope.py:2220:23
	s_bfe_u32 s35, s10, 0x20006
	.loc	1 2249 40                       ; rope.py:2249:40
	s_xor_b32 s42, s45, s0
	s_sub_i32 s0, 0, s41
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	.loc	1 2220 23                       ; rope.py:2220:23
	s_or_b32 s6, s35, s34
	.loc	1 2220 13 is_stmt 0             ; rope.py:2220:13
	s_or_b32 s8, s6, 28
	.loc	1 2246 37 is_stmt 1             ; rope.py:2246:37
	s_mul_i32 s38, s39, s11
	.loc	1 2249 40                       ; rope.py:2249:40
	v_readfirstlane_b32 s47, v1
	s_mul_i32 s0, s0, s47
	s_mul_hi_u32 s0, s47, s0
	s_add_i32 s47, s47, s0
	s_add_i32 s0, s8, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s9, s1, s41
	s_sub_i32 s0, s0, s9
	s_add_i32 s9, s1, 1
	s_sub_i32 s10, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s9, s1
	s_cselect_b32 s0, s10, s0
	s_add_i32 s9, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s9, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s9, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s9, s39
	s_sub_i32 s10, s8, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s10, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s46, s7
	v_cvt_f32_u32_e32 v1, s46
	s_sub_i32 s1, 0, s46
	s_ashr_i32 s48, s7, 31
	s_ashr_i32 s10, s0, 31
	v_rcp_f32_e32 v1, v1
	s_xor_b32 s10, s10, s48
	.loc	1 2220 23                       ; rope.py:2220:23
	v_and_b32_e32 v0, 63, v0
	.loc	1 2254 51                       ; rope.py:2254:51
	v_cmp_gt_u32_e32 vcc, 43, v0
	.loc	1 2251 40                       ; rope.py:2251:40
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	.loc	1 2261 14                       ; rope.py:2261:14
	v_bfrev_b32_e32 v48, 1
	.loc	1 2264 18                       ; rope.py:2264:18
	s_mul_i32 s12, s12, s16
	.loc	1 2268 19                       ; rope.py:2268:19
	v_lshlrev_b32_e32 v49, 1, v0
	.loc	1 2251 40                       ; rope.py:2251:40
	v_readfirstlane_b32 s50, v1
	s_mul_i32 s1, s1, s50
	s_mul_hi_u32 s1, s50, s1
	s_add_i32 s50, s50, s1
	s_abs_i32 s1, s0
	s_mul_hi_u32 s11, s1, s50
	s_mul_i32 s18, s11, s46
	s_sub_i32 s1, s1, s18
	s_add_i32 s18, s11, 1
	s_sub_i32 s19, s1, s46
	s_cmp_ge_u32 s1, s46
	s_cselect_b32 s11, s18, s11
	s_cselect_b32 s1, s19, s1
	s_add_i32 s18, s11, 1
	s_cmp_ge_u32 s1, s46
	s_cselect_b32 s1, s18, s11
	s_xor_b32 s1, s1, s10
	s_sub_i32 s10, s1, s10
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s10, s7
	s_sub_i32 s11, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[18:19], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[18:19], exec
	s_cselect_b32 s40, s9, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s43, s10, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s44, s11, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s51, s6, 24
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s51, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s8, s1, s41
	s_sub_i32 s0, s0, s8
	s_add_i32 s8, s1, 1
	s_sub_i32 s9, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s8, s1
	s_cselect_b32 s0, s9, s0
	s_add_i32 s8, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s8, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s8, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s8, s39
	s_sub_i32 s9, s51, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s51, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s9, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s9, s0
	s_mul_hi_u32 s10, s9, s50
	s_mul_i32 s11, s10, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s9, s9, s11
	s_xor_b32 s1, s1, s48
	s_add_i32 s11, s10, 1
	s_sub_i32 s20, s9, s46
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s10, s11, s10
	s_cselect_b32 s9, s20, s9
	s_add_i32 s11, s10, 1
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s9, s11, s10
	s_xor_b32 s9, s9, s1
	s_sub_i32 s9, s9, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s9, s7
	s_sub_i32 s10, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s51, s38
	s_cselect_b64 s[22:23], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[22:23], exec
	s_cselect_b32 s49, s8, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s52, s9, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s53, s10, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s8, s6, 20
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s8, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s9, s1, s41
	s_sub_i32 s0, s0, s9
	s_add_i32 s9, s1, 1
	s_sub_i32 s10, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s9, s1
	s_cselect_b32 s0, s10, s0
	s_add_i32 s9, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s9, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s9, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s9, s39
	s_sub_i32 s10, s8, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s10, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s10, s0
	s_mul_hi_u32 s11, s10, s50
	s_mul_i32 s20, s11, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s10, s10, s20
	s_xor_b32 s1, s1, s48
	s_add_i32 s20, s11, 1
	s_sub_i32 s21, s10, s46
	s_cmp_ge_u32 s10, s46
	s_cselect_b32 s11, s20, s11
	s_cselect_b32 s10, s21, s10
	s_add_i32 s20, s11, 1
	s_cmp_ge_u32 s10, s46
	s_cselect_b32 s10, s20, s11
	s_xor_b32 s10, s10, s1
	s_sub_i32 s10, s10, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s10, s7
	s_sub_i32 s11, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[20:21], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[20:21], exec
	s_cselect_b32 s54, s9, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s55, s10, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s56, s11, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s57, s6, 16
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s57, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s8, s1, s41
	s_sub_i32 s0, s0, s8
	s_add_i32 s8, s1, 1
	s_sub_i32 s9, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s8, s1
	s_cselect_b32 s0, s9, s0
	s_add_i32 s8, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s8, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s8, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s8, s39
	s_sub_i32 s9, s57, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s57, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s9, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s9, s0
	s_mul_hi_u32 s10, s9, s50
	s_mul_i32 s11, s10, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s9, s9, s11
	s_xor_b32 s1, s1, s48
	s_add_i32 s11, s10, 1
	s_sub_i32 s30, s9, s46
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s10, s11, s10
	s_cselect_b32 s9, s30, s9
	s_add_i32 s11, s10, 1
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s9, s11, s10
	s_xor_b32 s9, s9, s1
	s_sub_i32 s9, s9, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s9, s7
	s_sub_i32 s30, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s57, s38
	s_cselect_b64 s[10:11], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[10:11], exec
	s_cselect_b32 s58, s8, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s59, s9, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s60, s30, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s8, s6, 12
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s8, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s9, s1, s41
	s_sub_i32 s0, s0, s9
	s_add_i32 s9, s1, 1
	s_sub_i32 s30, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s9, s1
	s_cselect_b32 s0, s30, s0
	s_add_i32 s9, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s9, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s30, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s30, s39
	s_sub_i32 s9, s8, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s9, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s9, s0
	s_mul_hi_u32 s31, s9, s50
	s_mul_i32 s61, s31, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s9, s9, s61
	s_xor_b32 s1, s1, s48
	s_add_i32 s61, s31, 1
	s_sub_i32 s62, s9, s46
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s31, s61, s31
	s_cselect_b32 s9, s62, s9
	s_add_i32 s61, s31, 1
	s_cmp_ge_u32 s9, s46
	s_cselect_b32 s9, s61, s31
	s_xor_b32 s9, s9, s1
	s_sub_i32 s31, s9, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s31, s7
	s_sub_i32 s61, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s8, s38
	s_cselect_b64 s[8:9], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[8:9], exec
	s_cselect_b32 s64, s30, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s65, s31, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s61, s61, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s66, s6, 8
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s66, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s30, s1, s41
	s_sub_i32 s0, s0, s30
	s_add_i32 s30, s1, 1
	s_sub_i32 s31, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s30, s1
	s_cselect_b32 s0, s31, s0
	s_add_i32 s30, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s30, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s62, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s62, s39
	s_sub_i32 s30, s66, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s66, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s30, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s30, s0
	s_mul_hi_u32 s31, s30, s50
	s_mul_i32 s63, s31, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s30, s30, s63
	s_xor_b32 s1, s1, s48
	s_add_i32 s63, s31, 1
	s_sub_i32 s67, s30, s46
	s_cmp_ge_u32 s30, s46
	s_cselect_b32 s31, s63, s31
	s_cselect_b32 s30, s67, s30
	s_add_i32 s63, s31, 1
	s_cmp_ge_u32 s30, s46
	s_cselect_b32 s30, s63, s31
	s_xor_b32 s30, s30, s1
	s_sub_i32 s63, s30, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s63, s7
	s_sub_i32 s67, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s66, s38
	s_cselect_b64 s[30:31], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[0:1], s[30:31], exec
	s_cselect_b32 s68, s62, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s69, s63, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s67, s67, 0
	.loc	1 2220 13                       ; rope.py:2220:13
	s_or_b32 s62, s6, 4
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s0, s62, s45
	s_xor_b32 s0, s0, s45
	s_mul_hi_u32 s1, s0, s47
	s_mul_i32 s63, s1, s41
	s_sub_i32 s0, s0, s63
	s_add_i32 s63, s1, 1
	s_sub_i32 s70, s0, s41
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s1, s63, s1
	s_cselect_b32 s0, s70, s0
	s_add_i32 s63, s1, 1
	s_cmp_ge_u32 s0, s41
	s_cselect_b32 s0, s63, s1
	s_xor_b32 s0, s0, s42
	s_sub_i32 s70, s0, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s0, s70, s39
	s_sub_i32 s63, s62, s0
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s62, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[0:1], s[0:1], exec
	s_cselect_b32 s0, s63, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s63, s0
	s_mul_hi_u32 s71, s63, s50
	s_mul_i32 s72, s71, s46
	s_ashr_i32 s1, s0, 31
	s_sub_i32 s63, s63, s72
	s_xor_b32 s1, s1, s48
	s_add_i32 s72, s71, 1
	s_sub_i32 s73, s63, s46
	s_cmp_ge_u32 s63, s46
	s_cselect_b32 s71, s72, s71
	s_cselect_b32 s63, s73, s63
	s_add_i32 s72, s71, 1
	s_cmp_ge_u32 s63, s46
	s_cselect_b32 s63, s72, s71
	s_xor_b32 s63, s63, s1
	s_sub_i32 s71, s63, s1
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s1, s71, s7
	s_sub_i32 s72, s0, s1
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s62, s38
	s_cselect_b64 s[0:1], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[62:63], s[0:1], exec
	s_cselect_b32 s70, s70, 0
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s71, s71, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s72, s72, 0
	.loc	1 2249 40                       ; rope.py:2249:40
	s_add_i32 s62, s6, s45
	s_xor_b32 s45, s62, s45
	s_mul_hi_u32 s47, s45, s47
	s_mul_i32 s62, s47, s41
	s_sub_i32 s45, s45, s62
	s_add_i32 s62, s47, 1
	s_sub_i32 s63, s45, s41
	s_cmp_ge_u32 s45, s41
	s_cselect_b32 s47, s62, s47
	s_cselect_b32 s45, s63, s45
	s_add_i32 s62, s47, 1
	s_cmp_ge_u32 s45, s41
	s_cselect_b32 s41, s62, s47
	s_xor_b32 s41, s41, s42
	s_sub_i32 s41, s41, s42
	.loc	1 2250 38                       ; rope.py:2250:38
	s_mul_i32 s39, s41, s39
	s_sub_i32 s39, s6, s39
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s6, s38
	s_cselect_b64 s[62:63], -1, 0
	.loc	1 2250 11                       ; rope.py:2250:11
	s_and_b64 s[62:63], s[62:63], exec
	s_cselect_b32 s39, s39, 0
	.loc	1 2251 40                       ; rope.py:2251:40
	s_abs_i32 s45, s39
	s_ashr_i32 s42, s39, 31
	s_mul_hi_u32 s47, s45, s50
	s_xor_b32 s42, s42, s48
	s_mul_i32 s48, s47, s46
	s_sub_i32 s45, s45, s48
	s_add_i32 s48, s47, 1
	s_sub_i32 s50, s45, s46
	s_cmp_ge_u32 s45, s46
	s_cselect_b32 s47, s48, s47
	s_cselect_b32 s45, s50, s45
	s_add_i32 s48, s47, 1
	s_cmp_ge_u32 s45, s46
	s_cselect_b32 s45, s48, s47
	s_xor_b32 s45, s45, s42
	s_sub_i32 s42, s45, s42
	.loc	1 2252 40                       ; rope.py:2252:40
	s_mul_i32 s7, s42, s7
	s_sub_i32 s7, s39, s7
	.loc	1 2246 24                       ; rope.py:2246:24
	s_cmp_lt_i32 s6, s38
	s_cselect_b64 s[38:39], -1, 0
	.loc	1 2249 13                       ; rope.py:2249:13
	s_and_b64 s[46:47], s[38:39], exec
	.loc	1 2251 13                       ; rope.py:2251:13
	s_cselect_b32 s42, s42, 0
	.loc	1 2252 13                       ; rope.py:2252:13
	s_cselect_b32 s45, s7, 0
	.loc	1 2254 42                       ; rope.py:2254:42
	v_mov_b32_e32 v1, s45
	v_mov_b32_e32 v2, s42
	v_cndmask_b32_e32 v1, v1, v2, vcc
	v_mov_b32_e32 v2, s72
	v_mov_b32_e32 v3, s71
	v_cndmask_b32_e32 v2, v2, v3, vcc
	v_mov_b32_e32 v3, s67
	v_mov_b32_e32 v4, s69
	v_cndmask_b32_e32 v3, v3, v4, vcc
	v_mov_b32_e32 v4, s61
	v_mov_b32_e32 v5, s65
	v_cndmask_b32_e32 v4, v4, v5, vcc
	v_mov_b32_e32 v5, s60
	v_mov_b32_e32 v6, s59
	v_cndmask_b32_e32 v5, v5, v6, vcc
	v_mov_b32_e32 v6, s56
	v_mov_b32_e32 v7, s55
	v_cndmask_b32_e32 v6, v6, v7, vcc
	v_mov_b32_e32 v7, s53
	v_mov_b32_e32 v8, s52
	.loc	1 2249 13                       ; rope.py:2249:13
	s_cselect_b32 s41, s41, 0
	.loc	1 2254 42                       ; rope.py:2254:42
	v_cndmask_b32_e32 v7, v7, v8, vcc
	v_mov_b32_e32 v8, s44
	v_mov_b32_e32 v9, s43
	v_cndmask_b32_e32 v8, v8, v9, vcc
	.loc	1 2254 16 is_stmt 0             ; rope.py:2254:16
	v_mov_b32_e32 v9, s41
	.loc	1 2254 25                       ; rope.py:2254:25
	v_cmp_gt_u32_e32 vcc, 22, v0
	.loc	1 2221 14 is_stmt 1             ; rope.py:2221:14
	s_cmp_lt_i32 s51, 40
	s_cselect_b64 s[46:47], -1, 0
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v1, v1, v9, vcc
	v_mov_b32_e32 v9, s70
	v_cndmask_b32_e32 v2, v2, v9, vcc
	v_mov_b32_e32 v9, s68
	.loc	1 2221 14                       ; rope.py:2221:14
	s_cmp_lt_i32 s57, 40
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v3, v3, v9, vcc
	v_mov_b32_e32 v9, s64
	.loc	1 2221 14                       ; rope.py:2221:14
	s_cselect_b64 s[50:51], -1, 0
	s_cmp_lt_i32 s66, 40
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v4, v4, v9, vcc
	v_mov_b32_e32 v9, s58
	.loc	1 2221 14                       ; rope.py:2221:14
	s_cselect_b64 s[62:63], -1, 0
	s_cmp_lt_i32 s6, 40
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v5, v5, v9, vcc
	v_mov_b32_e32 v9, s54
	.loc	1 2221 14                       ; rope.py:2221:14
	s_cselect_b64 s[6:7], -1, 0
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v6, v6, v9, vcc
	v_mov_b32_e32 v9, s49
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v1, 7, v1
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v7, v7, v9, vcc
	v_mov_b32_e32 v9, s40
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v2, 7, v2
	.loc	1 2257 17                       ; rope.py:2257:17
	s_and_b64 s[40:41], s[2:3], s[6:7]
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v1, v1, s15
	.loc	1 2254 16                       ; rope.py:2254:16
	v_cndmask_b32_e32 v8, v8, v9, vcc
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v3, 7, v3
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v2, v2, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_add_lshl_u32 v1, v1, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 vcc, s[40:41], s[38:39]
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v4, 7, v4
	.loc	1 2257 17                       ; rope.py:2257:17
	s_and_b64 s[42:43], s[2:3], s[62:63]
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v3, v3, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_cndmask_b32_e32 v10, v48, v1, vcc
	v_add_lshl_u32 v1, v2, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[0:1], s[40:41], s[0:1]
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v5, 7, v5
	.loc	1 2257 17                       ; rope.py:2257:17
	s_and_b64 s[44:45], s[2:3], s[50:51]
	s_and_b64 s[46:47], s[2:3], s[46:47]
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v4, v4, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_cndmask_b32_e64 v2, v48, v1, s[0:1]
	v_add_lshl_u32 v1, v3, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[2:3], s[42:43], s[30:31]
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v6, 7, v6
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v5, v5, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_cndmask_b32_e64 v12, v48, v1, s[2:3]
	v_add_lshl_u32 v1, v4, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[8:9], s[42:43], s[8:9]
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v7, 7, v7
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v6, v6, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_cndmask_b32_e64 v4, v48, v1, s[8:9]
	v_add_lshl_u32 v1, v5, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[10:11], s[44:45], s[10:11]
	.loc	1 2255 16                       ; rope.py:2255:16
	v_min_i32_e32 v8, 7, v8
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v7, v7, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	v_cndmask_b32_e64 v14, v48, v1, s[10:11]
	v_add_lshl_u32 v1, v6, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[20:21], s[44:45], s[20:21]
	.loc	1 2261 22                       ; rope.py:2261:22
	v_mul_lo_u32 v8, v8, s15
	.loc	1 2261 14 is_stmt 0             ; rope.py:2261:14
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	v_cndmask_b32_e64 v6, v48, v1, s[20:21]
	v_add_lshl_u32 v1, v7, v0, 2
	.loc	1 2257 17 is_stmt 1             ; rope.py:2257:17
	s_and_b64 s[22:23], s[46:47], s[22:23]
	.loc	1 2261 14                       ; rope.py:2261:14
	v_cndmask_b32_e64 v16, v48, v1, s[22:23]
	v_add_lshl_u32 v1, v8, v0, 2
	.loc	1 2257 17                       ; rope.py:2257:17
	s_and_b64 s[18:19], s[46:47], s[18:19]
	.loc	1 2262 14                       ; rope.py:2262:14
	s_and_b32 s37, s37, 0xffff
	s_mov_b32 s38, s6
	s_mov_b32 s39, s7
	.loc	1 2261 14                       ; rope.py:2261:14
	v_cndmask_b32_e64 v8, v48, v1, s[18:19]
	.loc	1 2262 14                       ; rope.py:2262:14
	buffer_load_dword v1, v10, s[36:39], 0 offen
	buffer_load_dword v3, v2, s[36:39], 0 offen
	buffer_load_dword v5, v12, s[36:39], 0 offen
	buffer_load_dword v7, v4, s[36:39], 0 offen
	buffer_load_dword v9, v14, s[36:39], 0 offen
	buffer_load_dword v11, v6, s[36:39], 0 offen
	buffer_load_dword v13, v16, s[36:39], 0 offen
	buffer_load_dword v15, v8, s[36:39], 0 offen
	.loc	1 2261 14                       ; rope.py:2261:14
	s_and_b32 s5, s5, 0xffff
	buffer_load_dword v40, v10, s[4:7], 0 offen
	buffer_load_dword v41, v2, s[4:7], 0 offen
	buffer_load_dword v42, v12, s[4:7], 0 offen
	buffer_load_dword v43, v4, s[4:7], 0 offen
	buffer_load_dword v44, v14, s[4:7], 0 offen
	buffer_load_dword v45, v6, s[4:7], 0 offen
	buffer_load_dword v46, v16, s[4:7], 0 offen
	buffer_load_dword v47, v8, s[4:7], 0 offen
	.loc	1 2268 19                       ; rope.py:2268:19
	s_mul_i32 s4, s13, s34
	s_mul_i32 s5, s35, s13
	.loc	1 2264 39                       ; rope.py:2264:39
	s_mul_i32 s14, s14, s17
	.loc	1 2264 18 is_stmt 0             ; rope.py:2264:18
	s_add_i32 s4, s4, s12
	.loc	1 2268 19 is_stmt 1             ; rope.py:2268:19
	v_add_u32_e32 v0, s5, v49
	s_add_i32 s12, s4, s14
	v_lshl_add_u32 v2, s13, 2, v0
	v_lshl_add_u32 v4, s13, 3, v0
	v_lshl_add_u32 v6, s13, 4, v0
	.loc	1 2268 11 is_stmt 0             ; rope.py:2268:11
	v_add_lshl_u32 v8, v0, s12, 2
	v_add_lshl_u32 v10, v2, s12, 2
	v_add_lshl_u32 v12, v4, s12, 2
	s_and_b32 s29, s29, 0xffff
	s_mov_b32 s30, s6
	s_mov_b32 s31, s7
	v_cndmask_b32_e32 v8, v48, v8, vcc
	v_cndmask_b32_e64 v10, v48, v10, s[0:1]
	v_cndmask_b32_e64 v12, v48, v12, s[2:3]
	.loc	1 2280 14 is_stmt 1             ; rope.py:2280:14
	s_mul_i32 s35, s35, s27
	.loc	1 2276 43                       ; rope.py:2276:43
	s_mul_i32 s33, s33, s17
	.loc	1 2280 5                        ; rope.py:2280:5
	s_and_b32 s25, s25, 0xffff
	.loc	1 2268 19                       ; rope.py:2268:19
	s_waitcnt vmcnt(15)
	v_mad_u64_u32 v[16:17], s[4:5], s13, 12, v[0:1]
	v_mad_u64_u32 v[18:19], s[4:5], s13, 20, v[0:1]
	v_mad_u64_u32 v[20:21], s[4:5], s13, 24, v[0:1]
	v_mad_u64_u32 v[22:23], s[4:5], s13, 28, v[0:1]
	.loc	1 2268 11 is_stmt 0             ; rope.py:2268:11
	v_add_lshl_u32 v14, v16, s12, 2
	v_add_lshl_u32 v17, v6, s12, 2
	v_add_lshl_u32 v19, v18, s12, 2
	v_add_lshl_u32 v21, v20, s12, 2
	v_add_lshl_u32 v23, v22, s12, 2
	.loc	1 2269 19 is_stmt 1             ; rope.py:2269:19
	s_add_i32 s12, s12, 1
	.loc	1 2268 11                       ; rope.py:2268:11
	v_cndmask_b32_e64 v14, v48, v14, s[8:9]
	.loc	1 2269 11                       ; rope.py:2269:11
	v_add_lshl_u32 v0, v0, s12, 2
	.loc	1 2268 11                       ; rope.py:2268:11
	v_cndmask_b32_e64 v17, v48, v17, s[10:11]
	v_cndmask_b32_e64 v19, v48, v19, s[20:21]
	v_cndmask_b32_e64 v21, v48, v21, s[22:23]
	v_cndmask_b32_e64 v23, v48, v23, s[18:19]
	buffer_load_dword v24, v8, s[28:31], 0 offen
	buffer_load_dword v26, v10, s[28:31], 0 offen
	buffer_load_dword v28, v12, s[28:31], 0 offen
	buffer_load_dword v30, v14, s[28:31], 0 offen
	buffer_load_dword v32, v17, s[28:31], 0 offen
	buffer_load_dword v34, v19, s[28:31], 0 offen
	buffer_load_dword v36, v21, s[28:31], 0 offen
	buffer_load_dword v38, v23, s[28:31], 0 offen
	.loc	1 2269 11                       ; rope.py:2269:11
	v_cndmask_b32_e32 v0, v48, v0, vcc
	v_add_lshl_u32 v2, v2, s12, 2
	v_add_lshl_u32 v4, v4, s12, 2
	v_add_lshl_u32 v8, v16, s12, 2
	v_add_lshl_u32 v6, v6, s12, 2
	v_add_lshl_u32 v10, v18, s12, 2
	v_add_lshl_u32 v12, v20, s12, 2
	v_add_lshl_u32 v14, v22, s12, 2
	v_cndmask_b32_e64 v2, v48, v2, s[0:1]
	v_cndmask_b32_e64 v4, v48, v4, s[2:3]
	v_cndmask_b32_e64 v8, v48, v8, s[8:9]
	v_cndmask_b32_e64 v6, v48, v6, s[10:11]
	v_cndmask_b32_e64 v10, v48, v10, s[20:21]
	v_cndmask_b32_e64 v12, v48, v12, s[22:23]
	v_cndmask_b32_e64 v14, v48, v14, s[18:19]
	buffer_load_dword v25, v0, s[28:31], 0 offen
	buffer_load_dword v27, v2, s[28:31], 0 offen
	buffer_load_dword v29, v4, s[28:31], 0 offen
	buffer_load_dword v31, v8, s[28:31], 0 offen
	buffer_load_dword v33, v6, s[28:31], 0 offen
	buffer_load_dword v35, v10, s[28:31], 0 offen
	buffer_load_dword v37, v12, s[28:31], 0 offen
	buffer_load_dword v39, v14, s[28:31], 0 offen
	.loc	1 2261 14                       ; rope.py:2261:14
	s_waitcnt vmcnt(23)
	v_cndmask_b32_e32 v0, 1.0, v40, vcc
	s_waitcnt vmcnt(22)
	v_cndmask_b32_e64 v2, 1.0, v41, s[0:1]
	s_waitcnt vmcnt(21)
	v_cndmask_b32_e64 v4, 1.0, v42, s[2:3]
	s_waitcnt vmcnt(20)
	v_cndmask_b32_e64 v6, 1.0, v43, s[8:9]
	s_waitcnt vmcnt(19)
	v_cndmask_b32_e64 v8, 1.0, v44, s[10:11]
	s_waitcnt vmcnt(18)
	v_cndmask_b32_e64 v10, 1.0, v45, s[20:21]
	s_waitcnt vmcnt(17)
	v_cndmask_b32_e64 v12, 1.0, v46, s[22:23]
	s_waitcnt vmcnt(16)
	v_cndmask_b32_e64 v14, 1.0, v47, s[18:19]
	.loc	1 2276 20                       ; rope.py:2276:20
	s_mul_i32 s4, s26, s16
	.loc	1 2280 14                       ; rope.py:2280:14
	s_mul_i32 s5, s27, s34
	.loc	1 2276 20                       ; rope.py:2276:20
	s_add_i32 s4, s5, s4
	.loc	1 2280 14                       ; rope.py:2280:14
	s_add_i32 s12, s4, s33
	.loc	1 2280 5 is_stmt 0              ; rope.py:2280:5
	s_mov_b32 s26, s6
	.loc	1 2272 13 is_stmt 1             ; rope.py:2272:13
	s_waitcnt vmcnt(7)
	v_pk_mul_f32 v[16:17], v[0:1], v[24:25]
	s_waitcnt vmcnt(6)
	v_pk_mul_f32 v[18:19], v[2:3], v[26:27]
	v_sub_f32_e32 v50, v16, v17
	.loc	1 2273 13                       ; rope.py:2273:13
	v_mov_b32_e32 v16, v1
	v_mov_b32_e32 v17, v0
	v_pk_mul_f32 v[0:1], v[16:17], v[24:25]
	v_mov_b32_e32 v16, v3
	v_mov_b32_e32 v17, v2
	v_pk_mul_f32 v[2:3], v[16:17], v[26:27]
	v_mov_b32_e32 v16, v5
	v_mov_b32_e32 v17, v4
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(5)
	v_pk_mul_f32 v[20:21], v[4:5], v[28:29]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[4:5], v[16:17], v[28:29]
	v_mov_b32_e32 v16, v7
	v_mov_b32_e32 v17, v6
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(4)
	v_pk_mul_f32 v[22:23], v[6:7], v[30:31]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[6:7], v[16:17], v[30:31]
	v_mov_b32_e32 v16, v9
	v_mov_b32_e32 v17, v8
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(3)
	v_pk_mul_f32 v[40:41], v[8:9], v[32:33]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[8:9], v[16:17], v[32:33]
	v_mov_b32_e32 v16, v11
	v_mov_b32_e32 v17, v10
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(2)
	v_pk_mul_f32 v[42:43], v[10:11], v[34:35]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[10:11], v[16:17], v[34:35]
	v_mov_b32_e32 v16, v13
	v_mov_b32_e32 v17, v12
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(1)
	v_pk_mul_f32 v[44:45], v[12:13], v[36:37]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[12:13], v[16:17], v[36:37]
	v_mov_b32_e32 v16, v15
	v_mov_b32_e32 v17, v14
	v_add_f32_e32 v1, v0, v1
	.loc	1 2280 14                       ; rope.py:2280:14
	v_add_u32_e32 v0, s35, v49
	.loc	1 2272 13                       ; rope.py:2272:13
	s_waitcnt vmcnt(0)
	v_pk_mul_f32 v[46:47], v[14:15], v[38:39]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_pk_mul_f32 v[14:15], v[16:17], v[38:39]
	v_add_f32_e32 v17, v4, v5
	.loc	1 2280 14                       ; rope.py:2280:14
	v_mad_u64_u32 v[4:5], s[4:5], s27, 20, v[0:1]
	.loc	1 2273 13                       ; rope.py:2273:13
	v_add_f32_e32 v16, v2, v3
	.loc	1 2280 14                       ; rope.py:2280:14
	v_mad_u64_u32 v[2:3], s[4:5], s27, 12, v[0:1]
	.loc	1 2280 5 is_stmt 0              ; rope.py:2280:5
	v_add_lshl_u32 v5, v0, s12, 2
	.loc	1 2273 13 is_stmt 1             ; rope.py:2273:13
	v_add_f32_e32 v24, v6, v7
	v_add_f32_e32 v25, v8, v9
	v_add_f32_e32 v10, v10, v11
	v_add_f32_e32 v11, v12, v13
	v_add_f32_e32 v12, v14, v15
	.loc	1 2280 14                       ; rope.py:2280:14
	v_lshl_add_u32 v13, s27, 2, v0
	v_lshl_add_u32 v14, s27, 3, v0
	v_lshl_add_u32 v3, s27, 4, v0
	v_mad_u64_u32 v[6:7], s[4:5], s27, 24, v[0:1]
	v_mad_u64_u32 v[8:9], s[4:5], s27, 28, v[0:1]
	.loc	1 2280 5 is_stmt 0              ; rope.py:2280:5
	s_mov_b32 s27, s7
	v_cndmask_b32_e32 v5, v48, v5, vcc
	buffer_store_dword v50, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v13, s12, 2
	.loc	1 2272 13 is_stmt 1             ; rope.py:2272:13
	v_sub_f32_e32 v18, v18, v19
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[0:1]
	buffer_store_dword v18, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v14, s12, 2
	.loc	1 2272 13                       ; rope.py:2272:13
	v_sub_f32_e32 v19, v20, v21
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[2:3]
	buffer_store_dword v19, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v2, s12, 2
	.loc	1 2272 13                       ; rope.py:2272:13
	v_sub_f32_e32 v20, v22, v23
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[8:9]
	buffer_store_dword v20, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v3, s12, 2
	.loc	1 2272 13                       ; rope.py:2272:13
	v_sub_f32_e32 v21, v40, v41
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[10:11]
	buffer_store_dword v21, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v4, s12, 2
	.loc	1 2272 13                       ; rope.py:2272:13
	v_sub_f32_e32 v22, v42, v43
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[20:21]
	buffer_store_dword v22, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v6, s12, 2
	.loc	1 2272 13                       ; rope.py:2272:13
	v_sub_f32_e32 v23, v44, v45
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[22:23]
	buffer_store_dword v23, v5, s[24:27], 0 offen
	v_add_lshl_u32 v5, v8, s12, 2
	.loc	1 2281 14                       ; rope.py:2281:14
	s_add_i32 s12, s12, 1
	.loc	1 2281 5 is_stmt 0              ; rope.py:2281:5
	v_add_lshl_u32 v0, v0, s12, 2
	.loc	1 2272 13 is_stmt 1             ; rope.py:2272:13
	v_sub_f32_e32 v40, v46, v47
	.loc	1 2280 5                        ; rope.py:2280:5
	v_cndmask_b32_e64 v5, v48, v5, s[18:19]
	.loc	1 2281 5                        ; rope.py:2281:5
	v_cndmask_b32_e32 v0, v48, v0, vcc
	.loc	1 2280 5                        ; rope.py:2280:5
	buffer_store_dword v40, v5, s[24:27], 0 offen
	.loc	1 2281 5                        ; rope.py:2281:5
	buffer_store_dword v1, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v13, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[0:1]
	buffer_store_dword v16, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v14, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[2:3]
	buffer_store_dword v17, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v2, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[8:9]
	buffer_store_dword v24, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v3, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[10:11]
	buffer_store_dword v25, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v4, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[20:21]
	buffer_store_dword v10, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v6, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[22:23]
	buffer_store_dword v11, v0, s[24:27], 0 offen
	v_add_lshl_u32 v0, v8, s12, 2
	v_cndmask_b32_e64 v0, v48, v0, s[18:19]
	buffer_store_dword v12, v0, s[24:27], 0 offen
	.loc	1 2181 1                        ; rope.py:2181:1
	s_endpgm
.LBB0_5:
	.loc	1 0 1 is_stmt 0                 ; rope.py:0:1
	s_ashr_i32 s7, s6, 31
	s_lshl_b64 s[20:21], s[6:7], 2
	s_add_u32 s20, s8, s20
	s_addc_u32 s21, s9, s21
	.loc	1 2234 14 is_stmt 1             ; rope.py:2234:14
	s_load_dword s11, s[20:21], 0x0
	.loc	1 2237 14                       ; rope.py:2237:14
	s_and_b64 s[20:21], s[2:3], exec
	s_cselect_b32 s7, 1, 0
	s_cmp_lg_u32 s7, 1
	s_cbranch_scc1 .LBB0_2
.LBB0_6:
	.loc	1 0 14 is_stmt 0                ; rope.py:0:14
	s_add_i32 s20, s6, 1
	s_ashr_i32 s21, s20, 31
	s_lshl_b64 s[20:21], s[20:21], 2
	s_add_u32 s20, s8, s20
	s_addc_u32 s21, s9, s21
	.loc	1 2237 14                       ; rope.py:2237:14
	s_load_dword s19, s[20:21], 0x0
	s_branch .LBB0_2
.Ltmp2:
.Lfunc_end0:
	.size	_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21, .Lfunc_end0-_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 88
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
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 257
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 52
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
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.num_vgpr, 51
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.num_agpr, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.numbered_sgpr, 74
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.num_named_barrier, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.private_seg_size, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.uses_vcc, 1
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.uses_flat_scratch, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.has_dyn_sized_stack, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.has_recursion, 0
	.set .L_rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 4064
; TotalNumSgprs: 80
; NumVgprs: 51
; NumAgprs: 0
; TotalNumVgprs: 51
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 32
; NumSGPRsForWavesPerEU: 102
; NumVGPRsForWavesPerEU: 257
; AccumOffset: 52
; Occupancy: 1
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 12
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
	.byte	0                               ; DW_CHILDREN_no
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x1f DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
                                        ; DW_AT_APPLE_optimized
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"rope.py"                       ; string offset=7 ; rope.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/rope" ; string offset=15 ; /work/aiter/aiter/ops/triton/_triton_kernels/rope
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
      - .address_space:  global
        .offset:         72
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         80
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 88
    .max_flat_workgroup_size: 256
    .name:           _rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21
    .private_segment_fixed_size: 0
    .sgpr_count:     80
    .sgpr_spill_count: 0
    .symbol:         _rope_fwd_3d_L_40_N_HEADS_1_C_128_c_total_64_sp_size_1_sp_rank_0_max_freq_seq_len_8_s_per_rank_40_pad_freq_val_r_1_pad_freq_val_i_0_BLOCK_L_32_BLOCK_N_4_BLOCK_C_64_C1_22_C2_21.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     51
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
