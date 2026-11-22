	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	binary_gemm_kernel              ; -- Begin function binary_gemm_kernel
	.p2align	8
	.type	binary_gemm_kernel,@function
binary_gemm_kernel:                     ; @binary_gemm_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.39:
	.file	1 "/work/external/amd/triton" "kernels.py"
	.loc	1 140 0 prologue_end            ; kernels.py:140:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.40:
.LBB0_0:
.Ltmp1:
	.loc	1 146 28 is_stmt 1              ; kernels.py:146:28
	s_lshl_b32 s14, s12, 4
	.loc	1 150 58                        ; kernels.py:150:58
	s_cmpk_lt_i32 s14, 0x100
	s_cselect_b64 s[8:9], -1, 0
	.loc	1 150 33 is_stmt 0              ; kernels.py:150:33
	s_lshl_b32 s0, s12, 7
	.loc	1 147 38 is_stmt 1              ; kernels.py:147:38
	v_lshl_or_b32 v2, s13, 8, v0
	.loc	1 150 28                        ; kernels.py:150:28
	s_ashr_i32 s1, s0, 31
	.loc	1 149 19                        ; kernels.py:149:19
	v_lshlrev_b32_e32 v0, 3, v0
	.loc	1 150 28                        ; kernels.py:150:28
	s_lshl_b64 s[0:1], s[0:1], 2
	.loc	1 149 19                        ; kernels.py:149:19
	v_lshl_or_b32 v0, s13, 11, v0
	s_movk_i32 s10, 0x100
	.loc	1 150 28                        ; kernels.py:150:28
	s_add_u32 s15, s2, s0
	.loc	1 149 19                        ; kernels.py:149:19
	v_ashrrev_i32_e32 v1, 31, v0
	v_cndmask_b32_e64 v3, 0, 1, s[8:9]
	.loc	1 150 28                        ; kernels.py:150:28
	s_addc_u32 s16, s3, s1
	.loc	1 151 58                        ; kernels.py:151:58
	v_cmp_gt_i32_e64 s[0:1], s10, v2
	.loc	1 149 19                        ; kernels.py:149:19
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[4:5]
	v_mov_b32_e32 v4, 0
	s_mov_b64 s[4:5], 0
	v_cmp_ne_u32_e64 s[2:3], 1, v3
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v7, 0
	v_mov_b32_e32 v8, 0
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v10, 0
	v_mov_b32_e32 v11, 0
	v_mov_b32_e32 v12, 0
	v_mov_b32_e32 v13, 0
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v18, 0
	v_mov_b32_e32 v19, 0
	s_branch .LBB0_2
.LBB0_1:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 19 is_stmt 0                ; kernels.py:0:19
	s_or_b64 exec, exec, s[10:11]
	.loc	1 149 19 is_stmt 1              ; kernels.py:149:19
	s_add_u32 s4, s4, 4
	.loc	1 152 33                        ; kernels.py:152:33
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_xor_b32_e32 v20, s17, v3
	v_xor_b32_e32 v21, s13, v3
	v_xor_b32_e32 v22, s19, v3
	v_xor_b32_e32 v23, s18, v3
	v_xor_b32_e32 v24, s21, v3
	v_xor_b32_e32 v25, s20, v3
	v_xor_b32_e32 v26, s23, v3
	v_xor_b32_e32 v27, s22, v3
	v_xor_b32_e32 v28, s25, v3
	v_xor_b32_e32 v29, s24, v3
	v_xor_b32_e32 v30, s27, v3
	v_xor_b32_e32 v31, s26, v3
	v_xor_b32_e32 v32, s29, v3
	v_xor_b32_e32 v33, s28, v3
	v_xor_b32_e32 v34, s31, v3
	v_xor_b32_e32 v3, s30, v3
	.loc	1 149 19                        ; kernels.py:149:19
	s_addc_u32 s5, s5, 0
	.loc	1 152 15                        ; kernels.py:152:15
	v_bcnt_u32_b32 v4, v20, v4
	v_bcnt_u32_b32 v5, v21, v5
	v_bcnt_u32_b32 v6, v22, v6
	v_bcnt_u32_b32 v7, v23, v7
	v_bcnt_u32_b32 v8, v24, v8
	v_bcnt_u32_b32 v9, v25, v9
	v_bcnt_u32_b32 v10, v26, v10
	v_bcnt_u32_b32 v11, v27, v11
	v_bcnt_u32_b32 v12, v28, v12
	v_bcnt_u32_b32 v13, v29, v13
	v_bcnt_u32_b32 v14, v30, v14
	v_bcnt_u32_b32 v15, v31, v15
	v_bcnt_u32_b32 v16, v32, v16
	v_bcnt_u32_b32 v17, v33, v17
	v_bcnt_u32_b32 v18, v34, v18
	.loc	1 149 19                        ; kernels.py:149:19
	s_cmp_lg_u32 s4, 32
	.loc	1 152 15                        ; kernels.py:152:15
	v_bcnt_u32_b32 v19, v3, v19
	.loc	1 149 19                        ; kernels.py:149:19
	s_cbranch_scc0 .LBB0_36
.LBB0_2:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 150 45                        ; kernels.py:150:45
	s_add_u32 s10, s15, s4
	s_addc_u32 s11, s16, s5
	s_mov_b32 s13, 0
	.loc	1 150 20 is_stmt 0              ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s17, 0
	s_cbranch_vccz .LBB0_19
; %bb.3:                                ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_20
.LBB0_4:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s18, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s19, 0
	s_cbranch_vccz .LBB0_21
.LBB0_5:                                ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_22
.LBB0_6:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s20, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s21, 0
	s_cbranch_vccz .LBB0_23
.LBB0_7:                                ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_24
.LBB0_8:                                ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s22, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s23, 0
	s_cbranch_vccz .LBB0_25
.LBB0_9:                                ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_26
.LBB0_10:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s24, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s25, 0
	s_cbranch_vccz .LBB0_27
.LBB0_11:                               ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_28
.LBB0_12:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s26, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s27, 0
	s_cbranch_vccz .LBB0_29
.LBB0_13:                               ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_30
.LBB0_14:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s28, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s29, 0
	s_cbranch_vccz .LBB0_31
.LBB0_15:                               ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_32
.LBB0_16:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	s_mov_b32 s30, 0
	.loc	1 150 20                        ; kernels.py:150:20
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s31, 0
	s_cbranch_vccz .LBB0_33
.LBB0_17:                               ;   in Loop: Header=BB0_2 Depth=1
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccz .LBB0_34
.LBB0_18:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 0 20                          ; kernels.py:0:20
	v_mov_b32_e32 v3, 0
	.loc	1 151 20 is_stmt 1              ; kernels.py:151:20
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_1
	s_branch .LBB0_35
.LBB0_19:                               ;   in Loop: Header=BB0_2 Depth=1
	.loc	1 150 20                        ; kernels.py:150:20
	s_load_dword s17, s[10:11], 0x0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_4
.LBB0_20:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s13, s[10:11], 0x20
	s_mov_b32 s18, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s19, 0
	s_cbranch_vccnz .LBB0_5
.LBB0_21:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s19, s[10:11], 0x40
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_6
.LBB0_22:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s18, s[10:11], 0x60
	s_mov_b32 s20, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s21, 0
	s_cbranch_vccnz .LBB0_7
.LBB0_23:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s21, s[10:11], 0x80
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_8
.LBB0_24:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s20, s[10:11], 0xa0
	s_mov_b32 s22, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s23, 0
	s_cbranch_vccnz .LBB0_9
.LBB0_25:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s23, s[10:11], 0xc0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
.LBB0_26:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s22, s[10:11], 0xe0
	s_mov_b32 s24, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s25, 0
	s_cbranch_vccnz .LBB0_11
.LBB0_27:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s25, s[10:11], 0x100
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_12
.LBB0_28:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s24, s[10:11], 0x120
	s_mov_b32 s26, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s27, 0
	s_cbranch_vccnz .LBB0_13
.LBB0_29:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s27, s[10:11], 0x140
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_14
.LBB0_30:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s26, s[10:11], 0x160
	s_mov_b32 s28, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s29, 0
	s_cbranch_vccnz .LBB0_15
.LBB0_31:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s29, s[10:11], 0x180
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_16
.LBB0_32:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s28, s[10:11], 0x1a0
	s_mov_b32 s30, 0
	s_and_b64 vcc, exec, s[2:3]
	s_mov_b32 s31, 0
	s_cbranch_vccnz .LBB0_17
.LBB0_33:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s31, s[10:11], 0x1c0
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_18
.LBB0_34:                               ;   in Loop: Header=BB0_2 Depth=1
	s_load_dword s30, s[10:11], 0x1e0
	v_mov_b32_e32 v3, 0
	.loc	1 151 20                        ; kernels.py:151:20
	s_and_saveexec_b64 s[10:11], s[0:1]
	s_cbranch_execz .LBB0_1
.LBB0_35:                               ;   in Loop: Header=BB0_2 Depth=1
	v_lshl_add_u64 v[20:21], v[0:1], 0, s[4:5]
	global_load_dword v3, v[20:21], off
	s_branch .LBB0_1
.LBB0_36:
	.loc	1 154 47                        ; kernels.py:154:47
	s_and_b64 s[0:1], s[8:9], s[0:1]
	.loc	1 154 16 is_stmt 0              ; kernels.py:154:16
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_38
; %bb.37:                               ; %.critedge
	.loc	1 146 38 is_stmt 1              ; kernels.py:146:38
	s_lshl_b32 s2, s14, 8
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xf00
	.loc	1 153 16 is_stmt 0              ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	.loc	1 153 42                        ; kernels.py:153:42
	v_ashrrev_i32_e32 v3, 31, v2
	.loc	1 153 16                        ; kernels.py:153:16
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshlrev_b64 v[0:1], 2, v[2:3]
	v_lshl_add_u64 v[2:3], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xe00
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[20:21], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xd00
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[22:23], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xc00
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[24:25], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xb00
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[26:27], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0xa00
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[28:29], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x900
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[30:31], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x800
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[32:33], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x700
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[34:35], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x600
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[36:37], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x500
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[38:39], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x400
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[40:41], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x300
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[42:43], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x200
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[44:45], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_or_b32 s0, s2, 0x100
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[46:47], s[0:1], 0, v[0:1]
	.loc	1 153 30                        ; kernels.py:153:30
	s_lshl_b32 s0, s12, 12
	.loc	1 153 16                        ; kernels.py:153:16
	s_ashr_i32 s1, s0, 31
	s_lshl_b64 s[0:1], s[0:1], 2
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	.loc	1 153 42                        ; kernels.py:153:42
	v_lshl_add_u64 v[0:1], s[0:1], 0, v[0:1]
	.loc	1 154 16 is_stmt 1              ; kernels.py:154:16
	global_store_dword v[0:1], v4, off
	global_store_dword v[46:47], v5, off
	global_store_dword v[44:45], v6, off
	global_store_dword v[42:43], v7, off
	global_store_dword v[40:41], v8, off
	global_store_dword v[38:39], v9, off
	global_store_dword v[36:37], v10, off
	global_store_dword v[34:35], v11, off
	global_store_dword v[32:33], v12, off
	global_store_dword v[30:31], v13, off
	global_store_dword v[28:29], v14, off
	global_store_dword v[26:27], v15, off
	global_store_dword v[24:25], v16, off
	global_store_dword v[22:23], v17, off
	global_store_dword v[20:21], v18, off
	global_store_dword v[2:3], v19, off
.LBB0_38:                               ; %.critedge28
	.loc	1 154 4 is_stmt 0               ; kernels.py:154:4
	s_endpgm
.Ltmp2:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel binary_gemm_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 40
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
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 48
		.amdhsa_next_free_sgpr 32
		.amdhsa_accum_offset 48
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
	.size	binary_gemm_kernel, .Lfunc_end0-binary_gemm_kernel
	.cfi_endproc
                                        ; -- End function
	.set binary_gemm_kernel.num_vgpr, 48
	.set binary_gemm_kernel.num_agpr, 0
	.set binary_gemm_kernel.numbered_sgpr, 32
	.set binary_gemm_kernel.private_seg_size, 0
	.set binary_gemm_kernel.uses_vcc, 1
	.set binary_gemm_kernel.uses_flat_scratch, 0
	.set binary_gemm_kernel.has_dyn_sized_stack, 0
	.set binary_gemm_kernel.has_recursion, 0
	.set binary_gemm_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1856
; TotalNumSgprs: 38
; NumVgprs: 48
; NumAgprs: 0
; TotalNumVgprs: 48
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 5
; NumSGPRsForWavesPerEU: 38
; NumVGPRsForWavesPerEU: 48
; AccumOffset: 48
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 12
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 11
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
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"kernels.py"                    ; string offset=7
.Linfo_string2:
	.asciz	"/work/external/amd/triton"     ; string offset=18
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 40
    .max_flat_workgroup_size: 256
    .name:           binary_gemm_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     38
    .sgpr_spill_count: 0
    .symbol:         binary_gemm_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     48
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
