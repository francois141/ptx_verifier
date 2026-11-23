; AKLR 766a200e367f aklr/ops/gemm/impls/triton/gemm_n6144_k2048/8307d207feb8e734.json, compiled for gfx950 by
; external/amd/aklr/build.py (case gemm_n6144_m64).
; dynamic LDS: 152000 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_gemm_xcd_kernel                ; -- Begin function _gemm_xcd_kernel
	.p2align	8
	.type	_gemm_xcd_kernel,@function
_gemm_xcd_kernel:                       ; @_gemm_xcd_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.1:
	.file	1 "/work/build/gemm_n6144_m64" "kernel.py"
	.loc	1 72 0 prologue_end             ; kernel.py:72:0
	s_load_dwordx4 s[8:11], s[4:5], 0x0
	s_load_dwordx2 s[12:13], s[4:5], 0x10
	s_load_dword s14, s[4:5], 0x18
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.2:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
.Ltmp1:
	.loc	1 90 16 is_stmt 1               ; kernel.py:90:16
	s_ashr_i32 s3, s15, 31
	s_lshr_b32 s4, s3, 29
	s_add_i32 s4, s15, s4
	s_ashr_i32 s7, s4, 3
	v_and_b32_e32 v2, 0x3ff, v0
	.loc	1 93 60                         ; kernel.py:93:60
	s_lshr_b32 s5, s7, 29
	.loc	1 107 13                        ; kernel.py:107:13
	v_readfirstlane_b32 s42, v2
	.loc	1 93 60                         ; kernel.py:93:60
	s_add_i32 s5, s7, s5
	.loc	1 111 9                         ; kernel.py:111:9
	s_bfe_u32 s2, s42, 0x20006
	.loc	1 93 60                         ; kernel.py:93:60
	s_and_b32 s5, s5, -8
	.loc	1 95 30                         ; kernel.py:95:30
	v_lshrrev_b32_e32 v1, 1, v0
	.loc	1 98 36                         ; kernel.py:98:36
	v_lshlrev_b32_e32 v2, 3, v2
	.loc	1 93 60                         ; kernel.py:93:60
	s_sub_i32 s5, s7, s5
	.loc	1 95 30                         ; kernel.py:95:30
	v_and_or_b32 v3, v1, 16, s2
	.loc	1 98 36                         ; kernel.py:98:36
	v_and_b32_e32 v2, 0xf8, v2
	.loc	1 102 14                        ; kernel.py:102:14
	s_lshl_b32 s7, s7, 8
	s_and_b32 s41, s7, 0x700
	.loc	1 104 25                        ; kernel.py:104:25
	v_lshl_or_b32 v2, v3, 11, v2
	v_or_b32_e32 v3, 0x2000, v2
	v_or_b32_e32 v10, s41, v2
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	s_mul_i32 s30, s2, 0x420
	s_mov_b64 s[0:1], s[10:11]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v4, 0x4000, v2
	v_or_b32_e32 v11, s41, v3
	.loc	1 104 17                        ; kernel.py:104:17
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x7ffffffe
	v_lshlrev_b32_e32 v18, 1, v10
	s_mov_b32 m0, s30
	s_add_i32 s34, s30, 0x1080
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v5, 0x6000, v2
	v_or_b32_e32 v12, s41, v4
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v11
	s_mov_b32 m0, s34
	s_add_i32 s35, s30, 0x2100
	.loc	1 93 12 is_stmt 1               ; kernel.py:93:12
	s_lshr_b32 s3, s3, 26
	.loc	1 93 37 is_stmt 0               ; kernel.py:93:37
	s_and_b32 s4, s4, 0x1ffffff8
	.loc	1 104 25 is_stmt 1              ; kernel.py:104:25
	v_or_b32_e32 v6, 0x10000, v2
	v_or_b32_e32 v13, s41, v5
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v12
	s_mov_b32 m0, s35
	s_add_i32 s36, s30, 0x3180
	.loc	1 93 12 is_stmt 1               ; kernel.py:93:12
	s_add_i32 s3, s15, s3
	.loc	1 93 37 is_stmt 0               ; kernel.py:93:37
	s_sub_i32 s4, s15, s4
	.loc	1 104 25 is_stmt 1              ; kernel.py:104:25
	v_or_b32_e32 v7, 0x12000, v2
	v_or_b32_e32 v14, s41, v6
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v13
	s_mov_b32 m0, s36
	s_add_i32 s37, s30, 0x4200
	.loc	1 93 11 is_stmt 1               ; kernel.py:93:11
	s_andn2_b32 s3, s3, 63
	s_lshl3_add_u32 s4, s4, s5
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v8, 0x14000, v2
	v_or_b32_e32 v15, s41, v7
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v14
	s_mov_b32 m0, s37
	s_add_i32 s38, s30, 0x5280
	.loc	1 93 11 is_stmt 1               ; kernel.py:93:11
	s_add_i32 s4, s4, s3
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v9, 0x16000, v2
	v_or_b32_e32 v16, s41, v8
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v15
	s_mov_b32 m0, s38
	s_add_i32 s39, s30, 0x6300
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v17, s41, v9
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v16
	s_mov_b32 m0, s39
	s_add_i32 s40, s30, 0x7380
	.loc	1 0 0                           ; kernel.py:0
	s_lshl_b32 s14, s4, 16
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v17
	s_mov_b32 m0, s40
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v10, s14, v10
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s28, s30, 0x18be0
	.loc	1 95 30 is_stmt 1               ; kernel.py:95:30
	s_lshl_b32 s5, s2, 6
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v11, s14, v11
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_and_b32 s1, s1, 0xffff
	s_mov_b32 s2, s10
	s_mov_b32 s3, s11
	v_lshlrev_b32_e32 v10, 1, v10
	s_mov_b32 m0, s28
	s_add_i32 s29, s28, 0x1080
	; asyncmark
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v12, s14, v12
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v11
	s_mov_b32 m0, s29
	s_add_i32 s31, s28, 0x2100
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v13, s14, v13
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v12
	s_mov_b32 m0, s31
	s_add_i32 s33, s28, 0x3180
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s15, s7, 0x100
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v13
	s_mov_b32 m0, s33
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s15, s15, 0x700
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v10, s15, v2
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	s_add_i32 s20, s28, 0xfffef820
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v11, s15, v3
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v18, 1, v10
	s_mov_b32 m0, s20
	s_add_i32 s21, s28, 0xffff08a0
	; asyncmark
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v12, s15, v4
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v11
	s_mov_b32 m0, s21
	s_add_i32 s22, s28, 0xffff1920
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v13, s15, v5
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v12
	s_mov_b32 m0, s22
	s_add_i32 s23, s28, 0xffff29a0
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v14, s15, v6
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v18, 1, v13
	s_mov_b32 m0, s23
	s_add_i32 s24, s28, 0xffff3a20
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v15, s15, v7
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v18, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v14
	s_mov_b32 m0, s24
	s_add_i32 s25, s28, 0xffff4aa0
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v16, s15, v8
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v15
	s_mov_b32 m0, s25
	s_add_i32 s26, s28, 0xffff5b20
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v17, s15, v9
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v16
	s_mov_b32 m0, s26
	s_add_i32 s27, s28, 0xffff6ba0
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v14, 1, v17
	s_mov_b32 m0, s27
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v10, s14, v10
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s16, s30, 0x1cde0
	.loc	1 104 17 is_stmt 1              ; kernel.py:104:17
	buffer_load_dwordx4 v14, s[8:11], 0 offen lds
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v11, s14, v11
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	v_lshlrev_b32_e32 v10, 1, v10
	s_mov_b32 m0, s16
	s_add_i32 s17, s16, 0x1080
	; asyncmark
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v12, s14, v12
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v11
	s_mov_b32 m0, s17
	s_add_i32 s18, s16, 0x2100
	s_lshl_b32 s15, s42, 3
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s42, s7, 0x200
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v13, s14, v13
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v12
	s_mov_b32 m0, s18
	s_add_i32 s19, s16, 0x3180
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_and_b32 s42, s42, 0x700
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v10, 1, v13
	s_mov_b32 m0, s19
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v13, s42, v2
	v_or_b32_e32 v14, s42, v3
	v_or_b32_e32 v15, s42, v4
	v_or_b32_e32 v16, s42, v5
	v_or_b32_e32 v12, s42, v6
	v_or_b32_e32 v17, s42, v7
	v_or_b32_e32 v18, s42, v8
	v_or_b32_e32 v19, s42, v9
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	s_add_i32 s42, s30, 0x10800
	.loc	1 107 13 is_stmt 1              ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[0:3], 0 offen sc0 nt lds
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v20, 1, v13
	s_mov_b32 m0, s42
	s_add_i32 s43, s42, 0x1080
	; asyncmark
	; wait_asyncmark(2)
	s_waitcnt vmcnt(12)
	s_barrier
	buffer_load_dwordx4 v20, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v20, 1, v14
	s_mov_b32 m0, s43
	s_add_i32 s44, s42, 0x2100
	buffer_load_dwordx4 v20, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v20, 1, v15
	s_mov_b32 m0, s44
	s_add_i32 s45, s42, 0x3180
	buffer_load_dwordx4 v20, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v20, 1, v16
	s_mov_b32 m0, s45
	s_add_i32 s46, s42, 0x4200
	buffer_load_dwordx4 v20, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v12
	s_mov_b32 m0, s46
	s_add_i32 s47, s42, 0x5280
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v17
	s_mov_b32 m0, s47
	s_add_i32 s48, s42, 0x6300
	.loc	1 98 14                         ; kernel.py:98:14
	s_and_b32 s6, s5, 0x80
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v18
	s_mov_b32 m0, s48
	s_add_i32 s49, s42, 0x7380
	.loc	1 98 14                         ; kernel.py:98:14
	v_and_b32_e32 v1, 15, v0
	v_and_b32_e32 v0, 48, v0
	s_lshl_b32 s54, s6, 2
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v19
	s_mov_b32 m0, s49
	v_lshlrev_b32_e32 v10, 10, v1
	v_lshlrev_b32_e32 v11, 5, v1
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_add_u32_e32 v12, s54, v0
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v13, s14, v13
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s50, s30, 0x20fe0
	.loc	1 104 17 is_stmt 1              ; kernel.py:104:17
	v_add3_u32 v12, v12, v10, v11
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v14, s14, v14
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	v_lshlrev_b32_e32 v13, 1, v13
	s_mov_b32 m0, s50
	s_add_i32 s51, s50, 0x1080
	; asyncmark
	.loc	1 104 17 is_stmt 1              ; kernel.py:104:17
	ds_read_b128 v[18:21], v12
	ds_read_b128 v[22:25], v12 offset:64
	ds_read_b128 v[26:29], v12 offset:128
	ds_read_b128 v[30:33], v12 offset:192
	ds_read_b128 v[34:37], v12 offset:256
	ds_read_b128 v[38:41], v12 offset:320
	ds_read_b128 v[42:45], v12 offset:384
	ds_read_b128 v[46:49], v12 offset:448
	ds_read_b128 v[50:53], v12 offset:16896
	ds_read_b128 v[54:57], v12 offset:16960
	ds_read_b128 v[58:61], v12 offset:17024
	ds_read_b128 v[62:65], v12 offset:17088
	ds_read_b128 v[66:69], v12 offset:17152
	ds_read_b128 v[70:73], v12 offset:17216
	ds_read_b128 v[74:77], v12 offset:17280
	ds_read_b128 v[78:81], v12 offset:17344
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v15, s14, v15
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v14
	s_mov_b32 m0, s51
	s_add_i32 s52, s50, 0x2100
	s_and_b32 s15, s15, 0x200
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v16, s14, v16
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v15
	s_mov_b32 m0, s52
	s_add_i32 s53, s50, 0x3180
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v16
	s_mov_b32 m0, s53
	s_add_i32 s55, s15, 0x18be0
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_add_u32_e32 v13, s55, v10
	v_add3_u32 v13, v13, v0, v11
	; asyncmark
	ds_read_b128 v[82:85], v13
	ds_read_b128 v[86:89], v13 offset:64
	ds_read_b128 v[90:93], v13 offset:128
	ds_read_b128 v[94:97], v13 offset:192
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[82:85], v[18:21], 0
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s55, s7, 0x300
	s_and_b32 s55, s55, 0x700
	.loc	1 104 17                        ; kernel.py:104:17
	s_mov_b32 m0, s30
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[86:89], v[22:25], v[14:17]
	.loc	1 102 14                        ; kernel.py:102:14
	s_xor_b32 s41, s41, 0x400
	.loc	1 104 17                        ; kernel.py:104:17
	s_add_i32 s54, s54, 0x10800
	.loc	1 111 9                         ; kernel.py:111:9
	s_and_b32 s13, s13, 0xffff
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[90:93], v[26:29], v[14:17]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v13 offset:256
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[82:85], v[50:53], 0
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[94:97], v[30:33], v[14:17]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v13 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[86:89], v[54:57], v[20:23]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[24:27], v[34:37], v[14:17]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[32:35], v13 offset:384
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[90:93], v[58:61], v[20:23]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[14:17], v[28:31], v[38:41], v[14:17]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[36:39], v13 offset:448
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[94:97], v[62:65], v[20:23]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[14:17], v[32:35], v[42:45], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[20:23], v[24:27], v[66:69], v[20:23]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v24, s55, v4
	v_or_b32_e32 v25, s55, v5
	v_or_b32_e32 v26, s55, v6
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[46:49], v[14:17]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v27, s55, v7
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v26, 1, v26
	.loc	1 104 25                        ; kernel.py:104:25
	s_nop 0
	v_or_b32_e32 v14, s55, v2
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[28:31], v[70:73], v[20:23]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v15, s55, v3
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v30, 1, v14
	buffer_load_dwordx4 v30, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v30, 1, v15
	s_mov_b32 m0, s34
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v28, s55, v8
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v30, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v30, 1, v24
	s_mov_b32 m0, s35
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v29, s55, v9
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v30, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v30, 1, v25
	s_mov_b32 m0, s36
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v14, s14, v14
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v30, s[8:11], 0 offen lds
	s_mov_b32 m0, s37
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v15, s14, v15
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v26, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v26, 1, v27
	s_mov_b32 m0, s38
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v14, 1, v14
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v26, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v26, 1, v28
	s_mov_b32 m0, s39
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[32:35], v[74:77], v[20:23]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v26, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v26, 1, v29
	s_mov_b32 m0, s40
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v24, s14, v24
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v26, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	s_mov_b32 m0, s28
	; asyncmark
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[26:29], v12 offset:33792
	ds_read_b128 v[30:33], v12 offset:33856
	ds_read_b128 v[40:43], v12 offset:33920
	ds_read_b128 v[44:47], v12 offset:33984
	ds_read_b128 v[48:51], v12 offset:34048
	ds_read_b128 v[52:55], v12 offset:34112
	ds_read_b128 v[56:59], v12 offset:34176
	ds_read_b128 v[60:63], v12 offset:34240
	ds_read_b128 v[64:67], v12 offset:50688
	ds_read_b128 v[68:71], v12 offset:50752
	ds_read_b128 v[72:75], v12 offset:50816
	ds_read_b128 v[82:85], v12 offset:50880
	ds_read_b128 v[86:89], v12 offset:50944
	ds_read_b128 v[90:93], v12 offset:51008
	ds_read_b128 v[94:97], v12 offset:51072
	ds_read_b128 v[98:101], v12 offset:51136
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v14, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v14, 1, v15
	s_mov_b32 m0, s29
	.loc	1 107 21 is_stmt 0              ; kernel.py:107:21
	v_or_b32_e32 v25, s14, v25
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v14, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v14, 1, v24
	s_mov_b32 m0, s31
	s_add_i32 s55, s15, 0x1cde0
	buffer_load_dwordx4 v14, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v14, 1, v25
	s_mov_b32 m0, s33
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[20:23], v[36:39], v[78:81], v[20:23]
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v14, s[0:3], 0 offen sc0 nt lds
	v_add_u32_e32 v14, s55, v10
	v_add3_u32 v14, v14, v0, v11
	; asyncmark
	ds_read_b128 v[102:105], v14
	ds_read_b128 v[34:37], v14 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[102:105], v[26:29], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[76:79], v14 offset:128
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v15, s41, v2
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	s_mov_b32 m0, s20
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[34:37], v[30:33], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v14 offset:192
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[76:79], v[40:43], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[38:41], v14 offset:256
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[44:47], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[42:45], v14 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[38:41], v[48:51], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[46:49], v14 offset:384
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[42:45], v[52:55], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[50:53], v14 offset:448
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[46:49], v[56:59], v[16:19]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[24:27], v[50:53], v[60:63], v[16:19]
	v_mfma_f32_16x16x32_bf16 v[16:19], v[102:105], v[64:67], v[20:23]
	v_mfma_f32_16x16x32_bf16 v[16:19], v[34:37], v[68:71], v[16:19]
	.loc	1 104 25                        ; kernel.py:104:25
	s_nop 1
	v_or_b32_e32 v22, s41, v4
	v_or_b32_e32 v23, s41, v5
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[76:79], v[72:75], v[16:19]
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[82:85], v[16:19]
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v31, 1, v15
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	s_mov_b32 m0, s21
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[38:41], v[86:89], v[16:19]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v28, s41, v7
	v_or_b32_e32 v29, s41, v8
	v_or_b32_e32 v30, s41, v9
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[42:45], v[90:93], v[16:19]
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v15, s14, v15
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	v_lshlrev_b32_e32 v15, 1, v15
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[46:49], v[94:97], v[16:19]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[50:53], v[98:101], v[18:21]
	.loc	1 104 25                        ; kernel.py:104:25
	s_nop 3
	v_or_b32_e32 v17, s41, v3
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v31, 1, v17
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v31, 1, v22
	s_mov_b32 m0, s22
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v16, s41, v6
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v31, 1, v23
	s_mov_b32 m0, s23
	v_lshlrev_b32_e32 v16, 1, v16
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	s_mov_b32 m0, s24
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v17, s14, v17
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v16, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v16, 1, v28
	s_mov_b32 m0, s25
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v22, s14, v22
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v16, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v16, 1, v29
	s_mov_b32 m0, s26
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v23, s14, v23
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v16, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v16, 1, v30
	s_mov_b32 m0, s27
	.loc	1 107 13                        ; kernel.py:107:13
	s_add_i32 s41, s15, 0x20fe0
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v16, s[8:11], 0 offen lds
	v_add_u32_e32 v16, s54, v0
	v_add3_u32 v16, v16, v10, v11
	.loc	1 107 13                        ; kernel.py:107:13
	s_mov_b32 m0, s16
	; asyncmark
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[28:31], v16
	ds_read_b128 v[32:35], v16 offset:64
	ds_read_b128 v[36:39], v16 offset:128
	ds_read_b128 v[40:43], v16 offset:192
	ds_read_b128 v[44:47], v16 offset:256
	ds_read_b128 v[54:57], v16 offset:320
	ds_read_b128 v[58:61], v16 offset:384
	ds_read_b128 v[62:65], v16 offset:448
	ds_read_b128 v[66:69], v16 offset:16896
	ds_read_b128 v[70:73], v16 offset:16960
	ds_read_b128 v[74:77], v16 offset:17024
	ds_read_b128 v[78:81], v16 offset:17088
	ds_read_b128 v[82:85], v16 offset:17152
	ds_read_b128 v[86:89], v16 offset:17216
	ds_read_b128 v[90:93], v16 offset:17280
	ds_read_b128 v[94:97], v16 offset:17344
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v15, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v15, 1, v17
	s_mov_b32 m0, s17
	s_nop 0
	buffer_load_dwordx4 v15, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v15, 1, v22
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v15, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v15, 1, v23
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v15, s[0:3], 0 offen sc0 nt lds
	v_add_u32_e32 v15, s41, v10
	v_add3_u32 v15, v15, v0, v11
	; asyncmark
	ds_read_b128 v[102:105], v15
	ds_read_b128 v[48:51], v15 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[102:105], v[28:31], v[24:27]
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s41, s7, 0x500
	s_and_b32 s41, s41, 0x700
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v17, s41, v2
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v15 offset:128
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[48:51], v[32:35], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[30:33], v15 offset:192
	.loc	1 104 17                        ; kernel.py:104:17
	s_mov_b32 m0, s42
	.loc	1 107 13                        ; kernel.py:107:13
	v_or3_b32 v10, v0, s15, v10
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[102:105], v[66:69], v[18:21]
	.loc	1 107 13                        ; kernel.py:107:13
	v_add_u32_e32 v10, v10, v11
	v_add_u32_e32 v11, 0x18be0, v10
	v_add_u32_e32 v10, 0x1cde0, v10
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[26:29], v[36:39], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[34:37], v15 offset:256
	.loc	1 111 9                         ; kernel.py:111:9
	s_mov_b32 s15, s11
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[48:51], v[70:73], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[30:33], v[40:43], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[38:41], v15 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[26:29], v[74:77], v[18:21]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v26, s41, v3
	v_or_b32_e32 v27, s41, v4
	v_or_b32_e32 v28, s41, v5
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[34:37], v[44:47], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[42:45], v15 offset:384
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v29, s41, v6
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v29, 1, v29
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[30:33], v[78:81], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v33, 1, v17
	.loc	1 104 25 is_stmt 0              ; kernel.py:104:25
	v_or_b32_e32 v30, s41, v7
	v_or_b32_e32 v31, s41, v8
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[38:41], v[54:57], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[52:55], v15 offset:448
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[34:37], v[82:85], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	buffer_load_dwordx4 v33, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v33, 1, v26
	s_mov_b32 m0, s43
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[42:45], v[58:61], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v33, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v33, 1, v27
	s_mov_b32 m0, s44
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[38:41], v[86:89], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v33, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v33, 1, v28
	s_mov_b32 m0, s45
	.loc	1 104 25 is_stmt 0              ; kernel.py:104:25
	v_or_b32_e32 v32, s41, v9
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v33, s[8:11], 0 offen lds
	s_mov_b32 m0, s46
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[52:55], v[62:65], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v29, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v29, 1, v30
	s_mov_b32 m0, s47
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[42:45], v[90:93], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v29, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v29, 1, v31
	s_mov_b32 m0, s48
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[52:55], v[94:97], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v29, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v29, 1, v32
	s_mov_b32 m0, s49
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s41, s7, 0x600
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v29, s[8:11], 0 offen lds
	; asyncmark
	ds_read_b128 v[30:33], v12
	ds_read_b128 v[34:37], v12 offset:64
	ds_read_b128 v[38:41], v12 offset:128
	ds_read_b128 v[42:45], v12 offset:192
	ds_read_b128 v[46:49], v12 offset:256
	ds_read_b128 v[56:59], v12 offset:320
	ds_read_b128 v[60:63], v12 offset:384
	ds_read_b128 v[64:67], v12 offset:448
	ds_read_b128 v[68:71], v12 offset:16896
	ds_read_b128 v[72:75], v12 offset:16960
	ds_read_b128 v[76:79], v12 offset:17024
	ds_read_b128 v[80:83], v12 offset:17088
	ds_read_b128 v[84:87], v12 offset:17152
	ds_read_b128 v[88:91], v12 offset:17216
	ds_read_b128 v[98:101], v12 offset:17280
	ds_read_b128 v[102:105], v12 offset:17344
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v12, s14, v17
	v_or_b32_e32 v17, s14, v26
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	v_lshlrev_b32_e32 v12, 1, v12
	s_mov_b32 m0, s50
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v26, s14, v27
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v12, 1, v17
	s_mov_b32 m0, s51
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v27, s14, v28
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v12, 1, v26
	s_mov_b32 m0, s52
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_and_b32 s41, s41, 0x700
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v12, 1, v27
	s_mov_b32 m0, s53
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v17, s41, v3
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[0:3], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[26:29], v13
	ds_read_b128 v[50:53], v13 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[26:29], v[30:33], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[30:33], v13 offset:128
	.loc	1 104 17                        ; kernel.py:104:17
	s_mov_b32 m0, s30
	.loc	1 104 25 is_stmt 0              ; kernel.py:104:25
	v_or_b32_e32 v12, s41, v6
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[50:53], v[34:37], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[34:37], v13 offset:192
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v12, 1, v12
	.loc	1 102 14                        ; kernel.py:102:14
	s_addk_i32 s7, 0x700
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[26:29], v[68:71], v[18:21]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v26, s41, v4
	v_or_b32_e32 v27, s41, v5
	v_or_b32_e32 v28, s41, v7
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[30:33], v[38:41], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[38:41], v13 offset:256
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v29, s41, v8
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s7, s7, 0x700
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[50:53], v[72:75], v[18:21]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v3, s7, v3
	v_or_b32_e32 v4, s7, v4
	v_or_b32_e32 v5, s7, v5
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[34:37], v[42:45], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[42:45], v13 offset:320
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v6, s7, v6
	v_or_b32_e32 v7, s7, v7
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[30:33], v[76:79], v[18:21]
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v30, s41, v9
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v6, 1, v6
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v8, s7, v8
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[38:41], v[46:49], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[46:49], v13 offset:384
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v9, s7, v9
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[34:37], v[80:83], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[42:45], v[56:59], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[54:57], v13 offset:448
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v13, s41, v2
	.loc	1 104 17 is_stmt 0              ; kernel.py:104:17
	v_lshlrev_b32_e32 v31, 1, v13
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[38:41], v[84:87], v[18:21]
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v31, 1, v17
	s_mov_b32 m0, s34
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[46:49], v[60:63], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v31, 1, v26
	s_mov_b32 m0, s35
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[42:45], v[88:91], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v31, 1, v27
	s_mov_b32 m0, s36
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v13, s14, v13
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v31, s[8:11], 0 offen lds
	s_mov_b32 m0, s37
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v17, s14, v17
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v28
	s_mov_b32 m0, s38
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v13, 1, v13
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v29
	s_mov_b32 m0, s39
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[54:57], v[64:67], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v12, 1, v30
	s_mov_b32 m0, s40
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[46:49], v[98:101], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	v_add_u32_e32 v12, 0xfffef800, v16
	.loc	1 107 13                        ; kernel.py:107:13
	s_mov_b32 m0, s28
	; asyncmark
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[28:31], v12 offset:33792
	ds_read_b128 v[32:35], v12 offset:33856
	ds_read_b128 v[36:39], v12 offset:33920
	ds_read_b128 v[40:43], v12 offset:33984
	ds_read_b128 v[44:47], v12 offset:34048
	ds_read_b128 v[48:51], v12 offset:34112
	ds_read_b128 v[58:61], v12 offset:34176
	ds_read_b128 v[62:65], v12 offset:34240
	ds_read_b128 v[66:69], v12 offset:50688
	ds_read_b128 v[70:73], v12 offset:50752
	ds_read_b128 v[74:77], v12 offset:50816
	ds_read_b128 v[78:81], v12 offset:50880
	ds_read_b128 v[82:85], v12 offset:50944
	ds_read_b128 v[86:89], v12 offset:51008
	ds_read_b128 v[90:93], v12 offset:51072
	ds_read_b128 v[94:97], v12 offset:51136
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v26, s14, v26
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v17
	s_mov_b32 m0, s29
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v27, s14, v27
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v26
	s_mov_b32 m0, s31
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[54:57], v[102:105], v[18:21]
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v13, 1, v27
	s_mov_b32 m0, s33
	.loc	1 104 25                        ; kernel.py:104:25
	v_or_b32_e32 v2, s7, v2
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v13, s[0:3], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[98:101], v14
	ds_read_b128 v[52:55], v14 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[98:101], v[28:31], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v14 offset:128
	.loc	1 104 17                        ; kernel.py:104:17
	v_lshlrev_b32_e32 v13, 1, v2
	s_mov_b32 m0, s20
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[52:55], v[32:35], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[30:33], v14 offset:192
	.loc	1 107 21 is_stmt 0              ; kernel.py:107:21
	v_or_b32_e32 v2, s14, v2
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v2, 1, v2
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[98:101], v[66:69], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[26:29], v[36:39], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[34:37], v14 offset:256
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[52:55], v[70:73], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[30:33], v[40:43], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[38:41], v14 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[26:29], v[74:77], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[34:37], v[44:47], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[42:45], v14 offset:384
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[30:33], v[78:81], v[18:21]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[22:25], v[38:41], v[48:51], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[46:49], v14 offset:448
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[34:37], v[82:85], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	buffer_load_dwordx4 v13, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v13, 1, v3
	s_mov_b32 m0, s21
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[42:45], v[58:61], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v13, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v13, 1, v4
	s_mov_b32 m0, s22
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[38:41], v[86:89], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v13, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v13, 1, v5
	s_mov_b32 m0, s23
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v3, s14, v3
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v13, s[8:11], 0 offen lds
	s_mov_b32 m0, s24
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[22:25], v[46:49], v[62:65], v[22:25]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v6, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v6, 1, v7
	s_mov_b32 m0, s25
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[18:21], v[42:45], v[90:93], v[18:21]
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v6, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v6, 1, v8
	s_mov_b32 m0, s26
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v4, s14, v4
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v6, s[8:11], 0 offen lds
	v_lshlrev_b32_e32 v6, 1, v9
	s_mov_b32 m0, s27
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v5, s14, v5
	.loc	1 104 17                        ; kernel.py:104:17
	buffer_load_dwordx4 v6, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	s_mov_b32 m0, s16
	; asyncmark
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[6:9], v16
	ds_read_b128 v[26:29], v16 offset:64
	ds_read_b128 v[30:33], v16 offset:128
	ds_read_b128 v[34:37], v16 offset:192
	ds_read_b128 v[38:41], v16 offset:256
	ds_read_b128 v[42:45], v16 offset:320
	ds_read_b128 v[50:53], v16 offset:384
	ds_read_b128 v[54:57], v16 offset:448
	ds_read_b128 v[58:61], v16 offset:16896
	ds_read_b128 v[62:65], v16 offset:16960
	ds_read_b128 v[66:69], v16 offset:17024
	ds_read_b128 v[70:73], v16 offset:17088
	ds_read_b128 v[74:77], v16 offset:17152
	ds_read_b128 v[78:81], v16 offset:17216
	ds_read_b128 v[82:85], v16 offset:17280
	ds_read_b128 v[86:89], v16 offset:17344
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v2, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v2, 1, v3
	s_mov_b32 m0, s17
	.loc	1 111 9                         ; kernel.py:111:9
	s_mov_b32 s14, s10
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v2, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v2, 1, v4
	s_mov_b32 m0, s18
	s_nop 0
	buffer_load_dwordx4 v2, s[0:3], 0 offen sc0 nt lds
	v_lshlrev_b32_e32 v2, 1, v5
	s_mov_b32 m0, s19
	s_nop 0
	buffer_load_dwordx4 v2, s[0:3], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[90:93], v15
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[94:97], v[18:21]
	.loc	1 98 14                         ; kernel.py:98:14
	s_lshr_b32 s0, s6, 3
	.loc	1 107 13                        ; kernel.py:107:13
	s_nop 1
	ds_read_b128 v[16:19], v15 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[90:93], v[6:9], v[22:25]
	.loc	1 107 13                        ; kernel.py:107:13
	s_nop 2
	ds_read_b128 v[20:23], v15 offset:128
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[16:19], v[26:29], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v15 offset:192
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[20:23], v[30:33], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v15 offset:256
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[24:27], v[34:37], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[32:35], v15 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[90:93], v[58:61], v[2:5]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[28:31], v[38:41], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[36:39], v15 offset:384
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[16:19], v[62:65], v[2:5]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[42:45], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[40:43], v15 offset:448
	; wait_asyncmark(2)
	.loc	1 104 17                        ; kernel.py:104:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[20:23], v[66:69], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[14:17], v11
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[6:9], v[36:39], v[50:53], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[24:27], v[70:73], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[40:43], v[54:57], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[28:31], v[74:77], v[2:5]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[18:21], v11 offset:64
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[22:25], v12
	ds_read_b128 v[26:29], v12 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[32:35], v[78:81], v[2:5]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[14:17], v[22:25], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[22:25], v11 offset:128
	ds_read_b128 v[30:33], v11 offset:192
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[36:39], v[82:85], v[2:5]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[18:21], v[26:29], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[26:29], v12 offset:128
	ds_read_b128 v[34:37], v12 offset:192
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[22:25], v[26:29], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[40:43], v[86:89], v[2:5]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v11 offset:256
	ds_read_b128 v[38:41], v11 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[30:33], v[34:37], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[34:37], v12 offset:256
	ds_read_b128 v[42:45], v12 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[26:29], v[34:37], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[34:37], v11 offset:384
	ds_read_b128 v[46:49], v11 offset:448
	.loc	1 98 14                         ; kernel.py:98:14
	v_or_b32_e32 v11, s0, v1
	.loc	1 95 14                         ; kernel.py:95:14
	s_lshl_b32 s0, s4, 5
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[38:41], v[42:45], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[42:45], v12 offset:384
	ds_read_b128 v[50:53], v12 offset:448
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[34:37], v[42:45], v[6:9]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[46:49], v[50:53], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[42:45], v12 offset:16896
	ds_read_b128 v[50:53], v12 offset:16960
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[14:17], v[42:45], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[18:21], v[50:53], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:17024
	ds_read_b128 v[18:21], v12 offset:17088
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[14:17], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[18:21], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:17152
	ds_read_b128 v[18:21], v12 offset:17216
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[14:17], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[18:21], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:17280
	ds_read_b128 v[18:21], v12 offset:17344
	; wait_asyncmark(0)
	s_waitcnt vmcnt(0) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[34:37], v[14:17], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	s_barrier
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[14:17], v10
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[2:5], v[46:49], v[18:21], v[2:5]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[18:21], v10 offset:64
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[22:25], v12 offset:33792
	ds_read_b128 v[26:29], v12 offset:33856
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[14:17], v[22:25], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[22:25], v10 offset:128
	ds_read_b128 v[30:33], v10 offset:192
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[18:21], v[26:29], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[26:29], v12 offset:33920
	ds_read_b128 v[34:37], v12 offset:33984
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[22:25], v[26:29], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v10 offset:256
	ds_read_b128 v[38:41], v10 offset:320
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[30:33], v[34:37], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[34:37], v12 offset:34048
	ds_read_b128 v[42:45], v12 offset:34112
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[26:29], v[34:37], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[34:37], v10 offset:384
	ds_read_b128 v[46:49], v10 offset:448
	.loc	1 95 30                         ; kernel.py:95:30
	v_or_b32_e32 v10, s5, v0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[38:41], v[42:45], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[42:45], v12 offset:34176
	ds_read_b128 v[50:53], v12 offset:34240
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[34:37], v[42:45], v[6:9]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[46:49], v[50:53], v[6:9]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[42:45], v12 offset:50688
	ds_read_b128 v[50:53], v12 offset:50752
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[14:17], v[42:45], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[18:21], v[50:53], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:50816
	ds_read_b128 v[18:21], v12 offset:50880
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[22:25], v[14:17], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[18:21], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:50944
	ds_read_b128 v[18:21], v12 offset:51008
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[26:29], v[14:17], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[14:17], v12 offset:51072
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[38:41], v[18:21], v[2:5]
	.loc	1 104 17                        ; kernel.py:104:17
	ds_read_b128 v[18:21], v12 offset:51136
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[34:37], v[14:17], v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[46:49], v[18:21], v[0:3]
	.loc	1 95 30                         ; kernel.py:95:30
	s_nop 2
	v_lshrrev_b32_e32 v4, 2, v10
	v_and_b32_e32 v4, 28, v4
	.loc	1 109 14                        ; kernel.py:109:14
	v_mul_u32_u24_e32 v10, 0x1800, v11
	v_or_b32_e32 v11, s0, v4
	s_add_i32 s0, s0, 0x30000
	v_or_b32_e32 v12, s0, v4
	.loc	1 111 26                        ; kernel.py:111:26
	v_cvt_pk_bf16_f32 v4, v6, v7
	v_cvt_pk_bf16_f32 v5, v8, v9
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	.loc	1 111 9 is_stmt 0               ; kernel.py:111:9
	v_add_lshl_u32 v2, v11, v10, 1
	buffer_store_dwordx2 v[4:5], v2, s[12:15], 0 offen
	v_add_lshl_u32 v2, v12, v10, 1
	buffer_store_dwordx2 v[0:1], v2, s[12:15], 0 offen
	.loc	1 72 1 is_stmt 1                ; kernel.py:72:1
	s_endpgm
.Ltmp2:
.Lfunc_end0:
	.size	_gemm_xcd_kernel, .Lfunc_end0-_gemm_xcd_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _gemm_xcd_kernel
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 304
		.amdhsa_user_sgpr_count 15
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 1
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 1
		.amdhsa_user_sgpr_kernarg_preload_length 7
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 2
		.amdhsa_next_free_vgpr 169
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 108
		.amdhsa_reserve_vcc 0
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
	.set .L_gemm_xcd_kernel.num_vgpr, 106
	.set .L_gemm_xcd_kernel.num_agpr, 0
	.set .L_gemm_xcd_kernel.numbered_sgpr, 56
	.set .L_gemm_xcd_kernel.num_named_barrier, 0
	.set .L_gemm_xcd_kernel.private_seg_size, 0
	.set .L_gemm_xcd_kernel.uses_vcc, 0
	.set .L_gemm_xcd_kernel.uses_flat_scratch, 0
	.set .L_gemm_xcd_kernel.has_dyn_sized_stack, 0
	.set .L_gemm_xcd_kernel.has_recursion, 0
	.set .L_gemm_xcd_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 6032
; TotalNumSgprs: 62
; NumVgprs: 106
; NumAgprs: 0
; TotalNumVgprs: 106
; ScratchSize: 0
; MemoryBound: 1
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 21
; NumSGPRsForWavesPerEU: 102
; NumVGPRsForWavesPerEU: 169
; AccumOffset: 108
; Occupancy: 2
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 2
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 26
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
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/gemm_n6144_m64"    ; string offset=17 ; /work/build/gemm_n6144_m64
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
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     global_buffer
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
      - .offset:         128
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .offset:         136
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
      - .offset:         144
        .size:           8
        .value_kind:     hidden_heap_v1
      - .offset:         152
        .size:           8
        .value_kind:     hidden_default_queue
      - .offset:         160
        .size:           8
        .value_kind:     hidden_completion_action
      - .offset:         168
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
      - .offset:         248
        .size:           8
        .value_kind:     hidden_queue_ptr
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 304
    .max_flat_workgroup_size: 256
    .name:           _gemm_xcd_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     62
    .sgpr_spill_count: 0
    .symbol:         _gemm_xcd_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     106
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
