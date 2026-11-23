; AKLR 766a200e367f aklr/ops/gemm/impls/triton/gemm_n6144_k2048/8307d207feb8e734.json, compiled for gfx950 by
; external/amd/aklr/build.py (case gemm_n6144_m24).
; dynamic LDS: 101120 bytes
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
	.file	1 "/work/build/gemm_n6144_m24" "kernel.py"
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
	s_ashr_i32 s1, s15, 31
	s_lshr_b32 s2, s1, 29
	v_and_b32_e32 v3, 0x3ff, v0
	s_add_i32 s2, s15, s2
	.loc	1 107 13                        ; kernel.py:107:13
	v_readfirstlane_b32 s34, v3
	.loc	1 90 16                         ; kernel.py:90:16
	s_ashr_i32 s7, s2, 3
	.loc	1 113 9                         ; kernel.py:113:9
	s_bfe_u32 s6, s34, 0x20006
	.loc	1 93 60                         ; kernel.py:93:60
	s_lshr_b32 s3, s7, 29
	.loc	1 94 14                         ; kernel.py:94:14
	v_lshrrev_b32_e32 v1, 1, v0
	.loc	1 93 60                         ; kernel.py:93:60
	s_add_i32 s3, s7, s3
	.loc	1 94 14                         ; kernel.py:94:14
	v_and_or_b32 v4, v1, 28, s6
	.loc	1 98 36                         ; kernel.py:98:36
	v_lshlrev_b32_e32 v1, 3, v3
	s_mov_b32 s0, s14
	.loc	1 93 12                         ; kernel.py:93:12
	s_lshr_b32 s1, s1, 26
	.loc	1 93 37 is_stmt 0               ; kernel.py:93:37
	s_and_b32 s2, s2, 0x1ffffff8
	.loc	1 93 60                         ; kernel.py:93:60
	s_and_b32 s3, s3, -8
	.loc	1 98 36 is_stmt 1               ; kernel.py:98:36
	v_and_b32_e32 v1, 56, v1
	.loc	1 102 14                        ; kernel.py:102:14
	s_lshl_b32 s14, s7, 6
	.loc	1 93 12                         ; kernel.py:93:12
	s_add_i32 s1, s15, s1
	.loc	1 93 37 is_stmt 0               ; kernel.py:93:37
	s_sub_i32 s2, s15, s2
	.loc	1 93 60                         ; kernel.py:93:60
	s_sub_i32 s3, s7, s3
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_and_b32 s33, s14, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_lshl_or_b32 v2, v4, 11, v1
	.loc	1 93 11                         ; kernel.py:93:11
	s_andn2_b32 s1, s1, 63
	s_lshl3_add_u32 s2, s2, s3
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v12, s33, v2
	.loc	1 93 11                         ; kernel.py:93:11
	s_add_i32 s1, s2, s1
	.loc	1 106 17                        ; kernel.py:106:17
	s_mul_i32 s26, s6, 0x420
	v_lshlrev_b32_e32 v5, 1, v12
	v_bfrev_b32_e32 v1, 1
	.loc	1 97 14                         ; kernel.py:97:14
	v_cmp_gt_i32_e32 vcc, s0, v4
	s_mov_b64 s[4:5], s[10:11]
	.loc	1 106 17                        ; kernel.py:106:17
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x7ffffffe
	v_cndmask_b32_e32 v4, v1, v5, vcc
	s_mov_b32 m0, s26
	.loc	1 107 21                        ; kernel.py:107:21
	s_lshl_b32 s15, s1, 16
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v4, s[8:11], 0 offen lds
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v12
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s31, s26, 0x3160
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 64
	.loc	1 94 14                         ; kernel.py:94:14
	s_lshl_b32 s2, s6, 6
	.loc	1 107 13                        ; kernel.py:107:13
	s_and_b32 s5, s5, 0xffff
	s_mov_b32 s6, s10
	s_mov_b32 s7, s11
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s31
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s29, s26, 0x62c0
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s29
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s30, s26, 0x9420
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0x80
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s30
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s27, s26, 0xc580
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s27
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s28, s26, 0xf6e0
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0xc0
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s28
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s24, s26, 0x12840
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s24
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s25, s26, 0x159a0
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0x100
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s25
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s22, s25, 0xfffeb6e0
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s22
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s23, s25, 0xfffee840
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0x140
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s23
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s20, s25, 0xffff19a0
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s20
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s21, s25, 0xffff4b00
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0x180
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s21
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s18, s25, 0xffff7c60
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s18
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s19, s26, 0x10760
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s16, s14, 0x1c0
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s19
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s16, s16, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v4, s16, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s16, s26, 0x138c0
	v_lshlrev_b32_e32 v5, 1, v4
	v_cndmask_b32_e32 v5, v1, v5, vcc
	s_mov_b32 m0, s16
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v4, s15, v4
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s17, s26, 0x16a20
	; asyncmark
	.loc	1 106 17 is_stmt 1              ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v4, 1, v4
	s_mov_b32 m0, s17
	v_lshlrev_b32_e32 v3, 10, v3
	.loc	1 97 14                         ; kernel.py:97:14
	s_and_b32 s3, s2, 0x80
	.loc	1 102 14                        ; kernel.py:102:14
	s_movk_i32 s35, 0x180
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v4, s[4:7], 0 offen sc0 nt lds
	v_and_b32_e32 v4, 0xc00, v3
	v_lshlrev_b32_e32 v5, 5, v0
	v_and_b32_e32 v3, 48, v0
	s_lshl_b32 s34, s34, 3
	s_lshl_b32 s36, s3, 2
	v_and_or_b32 v5, v5, s35, v3
	s_and_b32 s34, s34, 0x200
	v_lshrrev_b32_e32 v6, 5, v4
	v_or3_b32 v7, v4, s36, v5
	v_or3_b32 v4, v4, s34, v5
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s34, s14, 0x200
	s_and_b32 s34, s34, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v5, s34, v2
	v_add_u32_e32 v14, v4, v6
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s34, s17, 0xfffeb6e0
	v_lshlrev_b32_e32 v4, 1, v5
	v_cndmask_b32_e32 v4, v1, v4, vcc
	s_mov_b32 m0, s34
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v5, s15, v5
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s36, s17, 0xfffee840
	; asyncmark
	; wait_asyncmark(8)
	.loc	1 106 17 is_stmt 1              ; kernel.py:106:17
	s_waitcnt vmcnt(8)
	s_barrier
	v_add_u32_e32 v15, v7, v6
	buffer_load_dwordx4 v4, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v5, 1, v5
	s_mov_b32 m0, s36
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	v_add_u32_e32 v4, 0, v15
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v5, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v5, 0, v14
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[6:9], v4
	ds_read_b128 v[16:19], v4 offset:64
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v5 offset:12640
	ds_read_b128 v[24:27], v5 offset:12704
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s35, s14, 0x240
	s_and_b32 s35, s35, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[20:23], v[6:9], 0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v10, s35, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s35, s17, 0xffff19a0
	v_lshlrev_b32_e32 v11, 1, v10
	v_cndmask_b32_e32 v11, v1, v11, vcc
	s_mov_b32 m0, s35
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v10, s15, v10
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s37, s17, 0xffff4b00
	.loc	1 102 14 is_stmt 1              ; kernel.py:102:14
	s_add_i32 s38, s14, 0x280
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v11, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v10, 1, v10
	s_mov_b32 m0, s37
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s38, s38, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[24:27], v[16:19], v[6:9]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[16:19], v4 offset:25280
	ds_read_b128 v[20:23], v4 offset:25344
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[24:27], v5 offset:37920
	ds_read_b128 v[28:31], v5 offset:37984
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v10, s38, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s38, s17, 0xffff7c60
	v_lshlrev_b32_e32 v11, 1, v10
	v_cndmask_b32_e32 v11, v1, v11, vcc
	s_mov_b32 m0, s38
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v10, s15, v10
	.loc	1 107 13 is_stmt 0              ; kernel.py:107:13
	s_add_i32 s39, s26, 0x117e0
	.loc	1 106 17 is_stmt 1              ; kernel.py:106:17
	buffer_load_dwordx4 v11, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v10, 1, v10
	s_mov_b32 m0, s39
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[24:27], v[16:19], v[6:9]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[16:19], v4 offset:50560
	ds_read_b128 v[24:27], v4 offset:50624
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v10, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v5 offset:63200
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[28:31], v[20:23], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v5 offset:63264
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s40, s14, 0x2c0
	s_and_b32 s40, s40, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[6:9], v[32:35], v[16:19], v[6:9]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v5, s40, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	s_add_i32 s40, s26, 0x14940
	s_mov_b32 m0, s40
	.loc	1 108 15 is_stmt 1              ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[8:11], v[20:23], v[24:27], v[6:9]
	.loc	1 107 13                        ; kernel.py:107:13
	s_add_i32 s41, s26, 0x17aa0
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s42, s14, 0x300
	s_and_b32 s42, s42, 0x7c0
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v6, 1, v5
	v_cndmask_b32_e32 v6, v1, v6, vcc
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v5, s15, v5
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v6, s[8:11], 0 offen lds
	v_add_u32_e32 v6, 0x12840, v15
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v5, 1, v5
	s_mov_b32 m0, s41
	v_add_u32_e32 v7, 0x159a0, v14
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[16:19], v6
	ds_read_b128 v[20:23], v6 offset:64
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v5, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[24:27], v7
	ds_read_b128 v[28:31], v7 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[24:27], v[16:19], v[8:11]
	.loc	1 106 17                        ; kernel.py:106:17
	s_mov_b32 m0, s26
	; wait_asyncmark(8)
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	.loc	1 106 25 is_stmt 0              ; kernel.py:106:25
	v_or_b32_e32 v8, s42, v2
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v5, 1, v8
	v_cndmask_b32_e32 v5, v1, v5, vcc
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v8, s15, v8
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v5, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v8, 1, v8
	s_mov_b32 m0, s31
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	v_add_u32_e32 v5, 0xfffed7c0, v6
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v8, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v8, 0xfffea660, v7
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:4224
	ds_read_b128 v[32:35], v5 offset:4288
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[36:39], v8 offset:16864
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[20:23], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v8 offset:16928
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s42, s14, 0x340
	s_and_b32 s42, s42, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v9, s42, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[24:27], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v10, 1, v9
	v_cndmask_b32_e32 v10, v1, v10, vcc
	s_mov_b32 m0, s29
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v9, s15, v9
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s42, s14, 0x380
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v10, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v9, 1, v9
	s_mov_b32 m0, s30
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s42, s42, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v9, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v9, s42, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[20:23], v[32:35], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[20:23], v5 offset:29504
	ds_read_b128 v[24:27], v5 offset:29568
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v8 offset:42144
	ds_read_b128 v[32:35], v8 offset:42208
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v10, 1, v9
	v_cndmask_b32_e32 v10, v1, v10, vcc
	s_mov_b32 m0, s27
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v9, s15, v9
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v10, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v9, 1, v9
	s_mov_b32 m0, s28
	; asyncmark
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[20:23], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v9, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v9, 0x10760, v14
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[20:23], v5 offset:54784
	ds_read_b128 v[28:31], v5 offset:54848
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[36:39], v9
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v9 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s42, s14, 0x3c0
	s_and_b32 s42, s42, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v11, s42, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[20:23], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v10, 1, v11
	v_cndmask_b32_e32 v10, v1, v10, vcc
	s_mov_b32 m0, s24
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v11, s15, v11
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v10, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v11, 1, v11
	s_mov_b32 m0, s25
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	v_add_u32_e32 v10, 0x138c0, v15
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v11, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v11, 0x16a20, v14
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[24:27], v[28:31], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[20:23], v10
	ds_read_b128 v[24:27], v10 offset:64
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v11
	ds_read_b128 v[32:35], v11 offset:64
	.loc	1 106 25                        ; kernel.py:106:25
	s_movk_i32 s42, 0x400
	v_mov_b32_e32 v13, s33
	v_bitop3_b32 v13, v2, s42, v13 bitop3:0x36
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[20:23], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v13, 1, v13
	.loc	1 107 21                        ; kernel.py:107:21
	v_mov_b32_e32 v20, 0x400
	.loc	1 106 17                        ; kernel.py:106:17
	v_cndmask_b32_e32 v13, v1, v13, vcc
	s_mov_b32 m0, s22
	.loc	1 107 21                        ; kernel.py:107:21
	v_bitop3_b32 v12, v12, s15, v20 bitop3:0xde
	; wait_asyncmark(8)
	.loc	1 106 17                        ; kernel.py:106:17
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v13, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v12, 1, v12
	s_mov_b32 m0, s23
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	v_add_u32_e32 v13, 0xfffec740, v10
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v12, 0xfffe95e0, v11
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[28:31], v13 offset:8448
	ds_read_b128 v[36:39], v13 offset:8512
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v12 offset:21088
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v12 offset:21152
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x440
	s_and_b32 s33, s33, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[20:23], v[28:31], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v20, s33, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v21, 1, v20
	v_cndmask_b32_e32 v21, v1, v21, vcc
	s_mov_b32 m0, s20
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v20, s15, v20
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x480
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v21, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v20, 1, v20
	s_mov_b32 m0, s21
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s33, s33, 0x7c0
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v20, s[4:7], 0 offen sc0 nt lds
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v20, s33, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[24:27], v[36:39], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[22:25], v13 offset:33728
	ds_read_b128 v[26:29], v13 offset:33792
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[30:33], v12 offset:46368
	ds_read_b128 v[34:37], v12 offset:46432
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v21, 1, v20
	v_cndmask_b32_e32 v21, v1, v21, vcc
	s_mov_b32 m0, s18
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v20, s15, v20
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v21, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v20, 1, v20
	s_mov_b32 m0, s19
	; asyncmark
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[30:33], v[22:25], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v20, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v20, 0x117e0, v14
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[22:25], v13 offset:59008
	ds_read_b128 v[30:33], v13 offset:59072
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[38:41], v20
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[34:37], v[26:29], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v20 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x4c0
	s_and_b32 s33, s33, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v21, s33, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[38:41], v[22:25], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v22, 1, v21
	v_cndmask_b32_e32 v22, v1, v22, vcc
	s_mov_b32 m0, s16
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v21, s15, v21
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v22, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v21, 1, v21
	s_mov_b32 m0, s17
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	v_add_u32_e32 v15, 0x14940, v15
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v21, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v21, 0x17aa0, v14
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[26:29], v[30:33], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[22:25], v15
	ds_read_b128 v[26:29], v15 offset:64
	; asyncmark
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[30:33], v21
	ds_read_b128 v[34:37], v21 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x500
	s_and_b32 s33, s33, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v14, s33, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[30:33], v[22:25], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v22, 1, v14
	v_cndmask_b32_e32 v22, v1, v22, vcc
	s_mov_b32 m0, s34
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v14, s15, v14
	; wait_asyncmark(8)
	.loc	1 106 17                        ; kernel.py:106:17
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v22, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v14, 1, v14
	s_mov_b32 m0, s36
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[22:25], v4
	ds_read_b128 v[30:33], v4 offset:64
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v14, s[4:7], 0 offen sc0 nt lds
	v_add_u32_e32 v14, 0xfffe8560, v21
	; asyncmark
	ds_read_b128 v[38:41], v14 offset:12640
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[34:37], v[26:29], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[26:29], v14 offset:12704
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x540
	s_and_b32 s33, s33, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[38:41], v[22:25], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s33, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v23, 1, v22
	v_cndmask_b32_e32 v23, v1, v23, vcc
	s_mov_b32 m0, s35
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v23, s[8:11], 0 offen lds
	v_add_u32_e32 v23, 0xfffeb6c0, v15
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s37
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[26:29], v[30:33], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v23 offset:25280
	ds_read_b128 v[28:31], v23 offset:25344
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v14 offset:37920
	ds_read_b128 v[36:39], v14 offset:37984
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x580
	s_and_b32 s33, s33, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s33, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s38
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s39
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v23 offset:50560
	ds_read_b128 v[32:35], v23 offset:50624
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[40:43], v14 offset:63200
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v14 offset:63264
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x5c0
	s_and_b32 s33, s33, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[40:43], v[24:27], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s33, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s40
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s41
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[32:35], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v6
	ds_read_b128 v[28:31], v6 offset:64
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v7
	ds_read_b128 v[36:39], v7 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s33, s14, 0x600
	s_and_b32 s33, s33, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s33, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s26
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	; wait_asyncmark(8)
	.loc	1 106 17                        ; kernel.py:106:17
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s31
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:4224
	ds_read_b128 v[32:35], v5 offset:4288
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[40:43], v8 offset:16864
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v8 offset:16928
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s26, s14, 0x640
	s_and_b32 s26, s26, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[40:43], v[24:27], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s26, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s29
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s30
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[32:35], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:29504
	ds_read_b128 v[28:31], v5 offset:29568
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v8 offset:42144
	ds_read_b128 v[36:39], v8 offset:42208
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s26, s14, 0x680
	s_and_b32 s26, s26, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s26, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s27
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s28
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:54784
	ds_read_b128 v[32:35], v5 offset:54848
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[40:43], v9
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v9 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s26, s14, 0x6c0
	s_and_b32 s26, s26, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[40:43], v[24:27], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s26, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s24
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s25
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[32:35], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v10
	ds_read_b128 v[28:31], v10 offset:64
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v11
	ds_read_b128 v[36:39], v11 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s24, s14, 0x700
	s_and_b32 s24, s24, 0x7c0
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s24, v2
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	.loc	1 106 17                        ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s22
	.loc	1 107 21                        ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	; wait_asyncmark(8)
	.loc	1 106 17                        ; kernel.py:106:17
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s23
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v13 offset:8448
	ds_read_b128 v[32:35], v13 offset:8512
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[40:43], v12 offset:21088
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v12 offset:21152
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s22, s14, 0x740
	s_and_b32 s22, s22, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[40:43], v[24:27], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v22, s22, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v24, 1, v22
	v_cndmask_b32_e32 v24, v1, v24, vcc
	s_mov_b32 m0, s20
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v22, s15, v22
	.loc	1 102 14                        ; kernel.py:102:14
	s_add_i32 s20, s14, 0x780
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v24, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v22, 1, v22
	s_mov_b32 m0, s21
	.loc	1 102 14                        ; kernel.py:102:14
	s_and_b32 s20, s20, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[32:35], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v13 offset:33728
	ds_read_b128 v[28:31], v13 offset:33792
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v22, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v12 offset:46368
	ds_read_b128 v[36:39], v12 offset:46432
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v12, s20, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v22, 1, v12
	v_cndmask_b32_e32 v22, v1, v22, vcc
	s_mov_b32 m0, s18
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v12, s15, v12
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v22, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v12, 1, v12
	s_mov_b32 m0, s19
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v13 offset:59008
	ds_read_b128 v[32:35], v13 offset:59072
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v12, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[40:43], v20
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v20 offset:64
	.loc	1 102 14                        ; kernel.py:102:14
	s_addk_i32 s14, 0x7c0
	s_and_b32 s14, s14, 0x7c0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[40:43], v[24:27], v[16:19]
	.loc	1 106 25                        ; kernel.py:106:25
	v_or_b32_e32 v2, s14, v2
	.loc	1 106 17 is_stmt 0              ; kernel.py:106:17
	v_lshlrev_b32_e32 v12, 1, v2
	v_cndmask_b32_e32 v12, v1, v12, vcc
	s_mov_b32 m0, s16
	.loc	1 107 21 is_stmt 1              ; kernel.py:107:21
	v_or_b32_e32 v2, s15, v2
	.loc	1 106 17                        ; kernel.py:106:17
	buffer_load_dwordx4 v12, s[8:11], 0 offen lds
	.loc	1 107 13                        ; kernel.py:107:13
	v_lshlrev_b32_e32 v2, 1, v2
	s_mov_b32 m0, s17
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[32:35], v[16:19]
	; asyncmark
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v15
	ds_read_b128 v[28:31], v15 offset:64
	.loc	1 107 13                        ; kernel.py:107:13
	buffer_load_dwordx4 v2, s[4:7], 0 offen sc0 nt lds
	; asyncmark
	ds_read_b128 v[32:35], v21
	ds_read_b128 v[36:39], v21 offset:64
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[32:35], v[24:27], v[16:19]
	; wait_asyncmark(8)
	.loc	1 106 17                        ; kernel.py:106:17
	s_waitcnt vmcnt(8) lgkmcnt(0)
	s_barrier
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v14 offset:12640
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[16:19], v[36:39], v[28:31], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v14 offset:12704
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[32:35], v4
	ds_read_b128 v[36:39], v4 offset:64
	.loc	1 113 9                         ; kernel.py:113:9
	s_lshl_b32 s1, s1, 6
	s_and_b32 s13, s13, 0xffff
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[24:27], v[32:35], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v14 offset:37920
	.loc	1 113 9                         ; kernel.py:113:9
	s_mov_b32 s14, s10
	s_mov_b32 s15, s11
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[36:39], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v14 offset:37984
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[32:35], v23 offset:25280
	ds_read_b128 v[36:39], v23 offset:25344
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[24:27], v[32:35], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v14 offset:63200
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[16:19], v[28:31], v[36:39], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[28:31], v14 offset:63264
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[12:15], v23 offset:50560
	ds_read_b128 v[20:23], v23 offset:50624
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[24:27], v[12:15], v[16:19]
	.loc	1 107 13                        ; kernel.py:107:13
	s_nop 2
	ds_read_b128 v[16:19], v7
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[28:31], v[20:23], v[12:15]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[20:23], v6
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[24:27], v7 offset:64
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[28:31], v6 offset:64
	; wait_asyncmark(0)
	s_waitcnt vmcnt(0) lgkmcnt(0)
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[12:15], v[16:19], v[20:23], v[12:15]
	.loc	1 106 17                        ; kernel.py:106:17
	s_barrier
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[16:19], v8 offset:16864
	.loc	1 108 15                        ; kernel.py:108:15
	v_mfma_f32_16x16x32_bf16 v[12:15], v[24:27], v[28:31], v[12:15]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v8 offset:16928
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:4224
	ds_read_b128 v[28:31], v5 offset:4288
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[16:19], v[24:27], v[12:15]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[16:19], v8 offset:42144
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[20:23], v[28:31], v[12:15]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v8 offset:42208
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v5 offset:29504
	ds_read_b128 v[28:31], v5 offset:29568
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[16:19], v[24:27], v[12:15]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[16:19], v9
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[12:15], v[20:23], v[28:31], v[12:15]
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v9 offset:64
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[6:9], v5 offset:54784
	ds_read_b128 v[24:27], v5 offset:54848
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[16:19], v[6:9], v[12:15]
	.loc	1 94 14                         ; kernel.py:94:14
	v_or_b32_e32 v8, s2, v3
	.loc	1 97 14                         ; kernel.py:97:14
	s_lshr_b32 s2, s3, 3
	v_and_or_b32 v0, v0, 15, s2
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[12:15], v11
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[20:23], v[24:27], v[4:7]
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[16:19], v10
	.loc	1 107 13                        ; kernel.py:107:13
	ds_read_b128 v[20:23], v11 offset:64
	.loc	1 106 17                        ; kernel.py:106:17
	ds_read_b128 v[24:27], v10 offset:64
	.loc	1 97 14                         ; kernel.py:97:14
	v_cmp_gt_i32_e32 vcc, s0, v0
	.loc	1 108 15                        ; kernel.py:108:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[12:15], v[16:19], v[4:7]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[2:5], v[20:23], v[24:27], v[2:5]
	.loc	1 94 14                         ; kernel.py:94:14
	s_nop 0
	v_lshrrev_b32_e32 v6, 2, v8
	.loc	1 109 14                        ; kernel.py:109:14
	v_mul_u32_u24_e32 v7, 0x1800, v0
	v_and_or_b32 v6, v6, 28, v7
	.loc	1 113 26                        ; kernel.py:113:26
	s_nop 3
	v_cvt_pk_bf16_f32 v2, v2, v3
	v_cvt_pk_bf16_f32 v3, v4, v5
	.loc	1 113 9 is_stmt 0               ; kernel.py:113:9
	v_lshl_add_u32 v4, v6, 1, s1
	v_cndmask_b32_e32 v0, v1, v4, vcc
	buffer_store_dwordx2 v[2:3], v0, s[12:15], 0 offen
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
		.amdhsa_accum_offset 44
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
	.set .L_gemm_xcd_kernel.num_vgpr, 44
	.set .L_gemm_xcd_kernel.num_agpr, 0
	.set .L_gemm_xcd_kernel.numbered_sgpr, 43
	.set .L_gemm_xcd_kernel.num_named_barrier, 0
	.set .L_gemm_xcd_kernel.private_seg_size, 0
	.set .L_gemm_xcd_kernel.uses_vcc, 1
	.set .L_gemm_xcd_kernel.uses_flat_scratch, 0
	.set .L_gemm_xcd_kernel.has_dyn_sized_stack, 0
	.set .L_gemm_xcd_kernel.has_recursion, 0
	.set .L_gemm_xcd_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 4680
; TotalNumSgprs: 49
; NumVgprs: 44
; NumAgprs: 0
; TotalNumVgprs: 44
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 21
; NumSGPRsForWavesPerEU: 102
; NumVGPRsForWavesPerEU: 169
; AccumOffset: 44
; Occupancy: 2
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 2
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 10
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
	.asciz	"/work/build/gemm_n6144_m24"    ; string offset=17 ; /work/build/gemm_n6144_m24
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
    .sgpr_count:     49
    .sgpr_spill_count: 0
    .symbol:         _gemm_xcd_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     44
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
