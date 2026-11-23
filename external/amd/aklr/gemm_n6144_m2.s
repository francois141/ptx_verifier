; AKLR 766a200e367f aklr/ops/gemm/impls/triton/gemm_n6144_k2048/8307d207feb8e734.json, compiled for gfx950 by
; external/amd/aklr/build.py (case gemm_n6144_m2).
; dynamic LDS: 75968 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_gemm_m16_kernel                ; -- Begin function _gemm_m16_kernel
	.p2align	8
	.type	_gemm_m16_kernel,@function
_gemm_m16_kernel:                       ; @_gemm_m16_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.3:
	.file	1 "/work/build/gemm_n6144_m2" "kernel.py"
	.loc	1 30 0 prologue_end             ; kernel.py:30:0
	s_load_dwordx4 s[8:11], s[4:5], 0x0
	s_load_dwordx2 s[12:13], s[4:5], 0x10
	s_load_dword s14, s[4:5], 0x18
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.4:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	v_and_b32_e32 v1, 0x3ff, v0
	s_mov_b64 s[16:17], s[10:11]
.Ltmp1:
	.loc	1 60 13 is_stmt 1               ; kernel.py:60:13
	v_readfirstlane_b32 s1, v1
	.loc	1 68 9                          ; kernel.py:68:9
	s_bfe_u32 s10, s1, 0x10006
	.loc	1 45 47                         ; kernel.py:45:47
	s_ashr_i32 s1, s15, 31
	s_lshr_b32 s1, s1, 29
	s_add_i32 s1, s15, s1
	s_ashr_i32 s1, s1, 3
	.loc	1 46 14                         ; kernel.py:46:14
	v_and_b32_e32 v2, 32, v0
	.loc	1 45 11                         ; kernel.py:45:11
	s_mul_i32 s15, s15, 24
	s_mulk_i32 s1, 0xff41
	.loc	1 46 14                         ; kernel.py:46:14
	v_lshrrev_b32_e32 v3, 2, v2
	.loc	1 47 30                         ; kernel.py:47:30
	v_lshrrev_b32_e32 v2, 1, v2
	.loc	1 45 11                         ; kernel.py:45:11
	s_add_i32 s1, s1, s15
	.loc	1 47 30                         ; kernel.py:47:30
	v_or_b32_e32 v2, s10, v2
	.loc	1 51 40                         ; kernel.py:51:40
	v_lshlrev_b32_e32 v7, 3, v1
	v_and_b32_e32 v7, 0xf8, v7
	.loc	1 0 0 is_stmt 0                 ; kernel.py:0
	s_lshl_b32 s2, s1, 16
	.loc	1 52 14 is_stmt 1               ; kernel.py:52:14
	v_lshlrev_b32_e32 v2, 11, v2
	s_mov_b32 s0, s14
	.loc	1 46 14                         ; kernel.py:46:14
	v_or_b32_e32 v3, s10, v3
	.loc	1 52 14                         ; kernel.py:52:14
	v_or3_b32 v2, v2, s2, v7
	.loc	1 59 17                         ; kernel.py:59:17
	v_lshlrev_b32_e32 v7, 1, v7
	s_mul_i32 s11, s10, 0x420
	v_lshl_or_b32 v14, v3, 12, v7
	v_bfrev_b32_e32 v17, 1
	.loc	1 53 14                         ; kernel.py:53:14
	v_cmp_gt_i32_e32 vcc, s0, v3
	.loc	1 46 14                         ; kernel.py:46:14
	v_or_b32_e32 v4, 2, v3
	v_or_b32_e32 v5, 4, v3
	v_or_b32_e32 v6, 6, v3
	.loc	1 59 17                         ; kernel.py:59:17
	s_and_b32 s21, s9, 0xffff
	s_mov_b32 s23, 0x27000
	s_mov_b32 s22, 0x7ffffffe
	s_mov_b32 s20, s8
	s_add_i32 m0, s11, 0xc5e0
	v_cndmask_b32_e32 v3, v17, v14, vcc
	buffer_load_dwordx4 v3, s[20:23], 0 offen lds
	v_lshl_or_b32 v3, v4, 12, v7
	.loc	1 53 14                         ; kernel.py:53:14
	v_cmp_gt_i32_e64 s[2:3], s0, v4
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 m0, s11, 0xce20
	.loc	1 53 14                         ; kernel.py:53:14
	v_cmp_gt_i32_e64 s[4:5], s0, v5
	.loc	1 59 17                         ; kernel.py:59:17
	v_cndmask_b32_e64 v4, v17, v3, s[2:3]
	buffer_load_dwordx4 v4, s[20:23], 0 offen lds
	v_lshl_or_b32 v4, v5, 12, v7
	s_add_i32 m0, s11, 0xd660
	v_cndmask_b32_e64 v5, v17, v4, s[4:5]
	buffer_load_dwordx4 v5, s[20:23], 0 offen lds
	v_lshl_or_b32 v5, v6, 12, v7
	.loc	1 53 14                         ; kernel.py:53:14
	v_cmp_gt_i32_e64 s[6:7], s0, v6
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 m0, s11, 0xdea0
	.loc	1 60 13                         ; kernel.py:60:13
	s_and_b32 s17, s17, 0xffff
	.loc	1 59 17                         ; kernel.py:59:17
	v_cndmask_b32_e64 v6, v17, v5, s[6:7]
	buffer_load_dwordx4 v6, s[20:23], 0 offen lds
	.loc	1 60 13                         ; kernel.py:60:13
	s_mov_b32 s18, s22
	s_mov_b32 s19, s23
	v_lshlrev_b32_e32 v6, 1, v2
	s_mov_b32 m0, s11
	; asyncmark
	v_or_b32_e32 v7, 0x2000, v6
	buffer_load_dwordx4 v6, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x840
	.loc	1 63 9                          ; kernel.py:63:9
	v_or_b32_e32 v8, 0x2100, v2
	.loc	1 60 13                         ; kernel.py:60:13
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x1080
	v_or_b32_e32 v7, 0x4000, v6
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x18c0
	v_or_b32_e32 v7, 0x6000, v6
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x2100
	v_or_b32_e32 v7, 0x8000, v6
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x2940
	v_or_b32_e32 v7, 0xa000, v6
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x3180
	v_or_b32_e32 v7, 0xc000, v6
	buffer_load_dwordx4 v7, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x39c0
	v_or_b32_e32 v6, 0xe000, v6
	buffer_load_dwordx4 v6, s[16:19], 0 offen sc0 nt lds
	.loc	1 63 9                          ; kernel.py:63:9
	v_or_b32_e32 v6, 0x100, v2
	v_or_b32_e32 v7, 0x1100, v2
	v_or_b32_e32 v9, 0x3100, v2
	v_or_b32_e32 v10, 0x4100, v2
	v_or_b32_e32 v11, 0x5100, v2
	v_or_b32_e32 v12, 0x6100, v2
	v_or_b32_e32 v13, 0x7100, v2
	.loc	1 59 17                         ; kernel.py:59:17
	v_or_b32_e32 v2, 0x200, v14
	s_add_i32 m0, s11, 0xe6e0
	v_cndmask_b32_e32 v14, v17, v2, vcc
	v_or_b32_e32 v2, 0x200, v3
	; asyncmark
	buffer_load_dwordx4 v14, s[20:23], 0 offen lds
	s_add_i32 m0, s11, 0xef20
	v_cndmask_b32_e64 v15, v17, v2, s[2:3]
	v_or_b32_e32 v2, 0x200, v4
	buffer_load_dwordx4 v15, s[20:23], 0 offen lds
	s_add_i32 m0, s11, 0xf760
	v_cndmask_b32_e64 v16, v17, v2, s[4:5]
	v_or_b32_e32 v2, 0x200, v5
	buffer_load_dwordx4 v16, s[20:23], 0 offen lds
	s_add_i32 m0, s11, 0xffa0
	v_cndmask_b32_e64 v17, v17, v2, s[6:7]
	buffer_load_dwordx4 v17, s[20:23], 0 offen lds
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 m0, s11, 0x4200
	v_lshlrev_b32_e32 v2, 1, v6
	; asyncmark
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x4a40
	v_lshlrev_b32_e32 v2, 1, v7
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x5280
	v_lshlrev_b32_e32 v2, 1, v8
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x5ac0
	v_lshlrev_b32_e32 v2, 1, v9
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x6300
	v_lshlrev_b32_e32 v2, 1, v10
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x6b40
	v_lshlrev_b32_e32 v2, 1, v11
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x7380
	v_lshlrev_b32_e32 v2, 1, v12
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s11, 0x7bc0
	v_lshlrev_b32_e32 v2, 1, v13
	buffer_load_dwordx4 v2, s[16:19], 0 offen sc0 nt lds
	.loc	1 46 14                         ; kernel.py:46:14
	v_and_b32_e32 v4, 15, v0
	v_lshlrev_b32_e32 v2, 10, v1
	v_and_b32_e32 v5, 48, v0
	v_lshlrev_b32_e32 v0, 6, v1
	v_and_b32_e32 v18, 0x1c00, v2
	v_and_b32_e32 v19, 0x200, v0
	v_mov_b32_e32 v0, 0
	s_mov_b32 s5, 1
	.loc	1 59 17                         ; kernel.py:59:17
	s_mov_b32 s7, 0
	v_lshrrev_b32_e32 v20, 5, v18
	v_lshlrev_b32_e32 v21, 10, v4
	s_lshl_b32 s2, s10, 9
	s_mov_b32 s21, 0xc5e0
	s_mov_b32 s4, 0xe6e0
	s_movk_i32 s14, 0x4200
	v_lshlrev_b32_e32 v22, 5, v4
	v_mov_b32_e32 v23, 0x200
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	s_mov_b32 s3, 0
	; asyncmark
	; wait_asyncmark(2)
	s_waitcnt vmcnt(12)
	s_barrier
	.loc	1 0 17 is_stmt 0                ; :0:17
.Ltmp2:
	.p2align	5, , 4
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 62 9 is_stmt 1                ; kernel.py:62:9
	s_add_u32 s20, s8, 0x200
	s_mov_b32 s6, s14
	s_addc_u32 s14, s9, 0
	.loc	1 55 5                          ; kernel.py:55:5
	s_add_i32 s5, s5, 1
	s_cmp_lt_i32 s5, 3
	s_cselect_b32 s5, s5, 0
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s7, s2, s7
	.loc	1 59 17                         ; kernel.py:59:17
	s_lshl_b32 s15, s5, 8
	v_add3_u32 v24, s21, v18, v19
	s_and_b32 s21, s14, 0xffff
	s_lshl_b32 s14, s5, 13
	.loc	1 60 13                         ; kernel.py:60:13
	v_add_u32_e32 v41, s7, v21
	.loc	1 59 17                         ; kernel.py:59:17
	s_and_b32 s7, s15, 0xfffff00
	s_add_i32 s15, s14, s7
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s25, s14, s14
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 s14, s15, s11
	.loc	1 60 13                         ; kernel.py:60:13
	s_lshl_b32 s24, s5, 9
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 m0, s14, 0xc5e0
	.loc	1 60 13                         ; kernel.py:60:13
	s_and_b32 s24, s24, 0xffffe00
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v14, s[20:23], 0 offen lds
	s_add_i32 m0, s14, 0xce20
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s7, s25, s24
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v15, s[20:23], 0 offen lds
	s_add_i32 m0, s14, 0xd660
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s24, s7, s11
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v16, s[20:23], 0 offen lds
	s_add_i32 m0, s14, 0xdea0
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshl_add_u32 v25, v6, 1, v23
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v17, s[20:23], 0 offen lds
	.loc	1 60 13                         ; kernel.py:60:13
	s_mov_b32 m0, s24
	v_lshl_add_u32 v26, v7, 1, v23
	; asyncmark
	buffer_load_dwordx4 v25, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x840
	v_lshl_add_u32 v27, v8, 1, v23
	buffer_load_dwordx4 v26, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x1080
	v_lshl_add_u32 v28, v9, 1, v23
	buffer_load_dwordx4 v27, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x18c0
	v_lshl_add_u32 v29, v10, 1, v23
	buffer_load_dwordx4 v28, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x2100
	v_lshl_add_u32 v30, v11, 1, v23
	buffer_load_dwordx4 v29, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x2940
	v_lshl_add_u32 v31, v12, 1, v23
	buffer_load_dwordx4 v30, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x3180
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 s25, s15, 0xc5e0
	.loc	1 60 13                         ; kernel.py:60:13
	buffer_load_dwordx4 v31, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s24, 0x39c0
	.loc	1 62 9                          ; kernel.py:62:9
	s_add_u32 s8, s8, 0x400
	s_addc_u32 s9, s9, 0
	.loc	1 55 5                          ; kernel.py:55:5
	s_add_i32 s5, s5, 1
	s_cmp_lt_i32 s5, 3
	s_cselect_b32 s5, s5, 0
	.loc	1 59 17                         ; kernel.py:59:17
	s_lshl_b32 s24, s5, 8
	s_lshl_b32 s14, s5, 13
	.loc	1 60 13                         ; kernel.py:60:13
	s_lshl_b32 s26, s5, 9
	.loc	1 59 17                         ; kernel.py:59:17
	s_and_b32 s24, s24, 0xfffff00
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s27, s14, s14
	s_and_b32 s26, s26, 0xffffe00
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 s24, s14, s24
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshl_add_u32 v32, v13, 1, v23
	s_add_i32 s14, s27, s26
	.loc	1 59 17                         ; kernel.py:59:17
	s_add_i32 s26, s24, s11
	v_add3_u32 v24, v24, v5, v20
	.loc	1 60 13                         ; kernel.py:60:13
	v_add3_u32 v41, v41, v5, v22
	buffer_load_dwordx4 v32, s[16:19], 0 offen sc0 nt lds
	.loc	1 59 17                         ; kernel.py:59:17
	s_mov_b32 s20, s8
	s_and_b32 s21, s9, 0xffff
	s_add_i32 m0, s26, 0xc5e0
	ds_read_b128 v[42:45], v24
	ds_read_b128 v[46:49], v24 offset:64
	ds_read_b128 v[50:53], v24 offset:128
	ds_read_b128 v[54:57], v24 offset:192
	ds_read_b128 v[58:61], v24 offset:256
	ds_read_b128 v[62:65], v24 offset:320
	ds_read_b128 v[66:69], v24 offset:384
	ds_read_b128 v[70:73], v24 offset:448
	; asyncmark
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[24:27], v41
	ds_read_b128 v[28:31], v41 offset:64
	ds_read_b128 v[74:77], v41 offset:128
	ds_read_b128 v[78:81], v41 offset:192
	ds_read_b128 v[82:85], v41 offset:256
	ds_read_b128 v[86:89], v41 offset:320
	ds_read_b128 v[90:93], v41 offset:384
	ds_read_b128 v[94:97], v41 offset:448
	; wait_asyncmark(2)
	.loc	1 59 17                         ; kernel.py:59:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	s_barrier
	buffer_load_dwordx4 v14, s[20:23], 0 offen lds
	s_add_i32 m0, s26, 0xce20
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v6, 0x200, v6
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v15, s[20:23], 0 offen lds
	s_add_i32 m0, s26, 0xd660
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s27, s14, s11
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v16, s[20:23], 0 offen lds
	s_add_i32 m0, s26, 0xdea0
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v7, 0x200, v7
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v33, 1, v6
	.loc	1 59 17                         ; kernel.py:59:17
	buffer_load_dwordx4 v17, s[20:23], 0 offen lds
	.loc	1 60 13                         ; kernel.py:60:13
	s_mov_b32 m0, s27
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v8, 0x200, v8
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v34, 1, v7
	; asyncmark
	buffer_load_dwordx4 v33, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x840
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v9, 0x200, v9
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v35, 1, v8
	buffer_load_dwordx4 v34, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x1080
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v10, 0x200, v10
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v36, 1, v9
	buffer_load_dwordx4 v35, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x18c0
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v11, 0x200, v11
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v37, 1, v10
	buffer_load_dwordx4 v36, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x2100
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v12, 0x200, v12
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v38, 1, v11
	buffer_load_dwordx4 v37, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x2940
	.loc	1 63 9                          ; kernel.py:63:9
	v_add_u32_e32 v13, 0x200, v13
	.loc	1 60 13                         ; kernel.py:60:13
	v_lshlrev_b32_e32 v39, 1, v12
	buffer_load_dwordx4 v38, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x3180
	v_lshlrev_b32_e32 v40, 1, v13
	buffer_load_dwordx4 v39, s[16:19], 0 offen sc0 nt lds
	s_add_i32 m0, s27, 0x39c0
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[24:27], v[42:45], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	buffer_load_dwordx4 v40, s[16:19], 0 offen sc0 nt lds
	.loc	1 59 17                         ; kernel.py:59:17
	v_add3_u32 v24, s4, v18, v19
	.loc	1 60 13                         ; kernel.py:60:13
	s_add_i32 s4, s2, s6
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[28:31], v[46:49], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	v_add_u32_e32 v25, s4, v21
	.loc	1 59 17                         ; kernel.py:59:17
	v_add3_u32 v24, v24, v5, v20
	.loc	1 60 13                         ; kernel.py:60:13
	v_add3_u32 v25, v25, v5, v22
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[74:77], v[50:53], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[26:29], v24
	ds_read_b128 v[30:33], v24 offset:64
	ds_read_b128 v[34:37], v24 offset:128
	ds_read_b128 v[38:41], v24 offset:192
	ds_read_b128 v[42:45], v24 offset:256
	ds_read_b128 v[46:49], v24 offset:320
	.loc	1 55 5                          ; kernel.py:55:5
	s_add_i32 s3, s3, 2
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[78:81], v[54:57], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[50:53], v24 offset:384
	ds_read_b128 v[54:57], v24 offset:448
	; asyncmark
	s_add_i32 s4, s24, 0xc5e0
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[82:85], v[58:61], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[58:61], v25
	s_mov_b32 s21, s25
	.loc	1 55 5                          ; kernel.py:55:5
	s_cmp_lg_u32 s3, 6
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[86:89], v[62:65], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[62:65], v25 offset:64
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[90:93], v[66:69], v[0:3]
	v_mfma_f32_16x16x32_bf16 v[0:3], v[94:97], v[70:73], v[0:3]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[58:61], v[26:29], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v25 offset:128
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[62:65], v[30:33], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[30:33], v25 offset:192
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[34:37], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v25 offset:256
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[30:33], v[38:41], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[30:33], v25 offset:320
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[42:45], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v25 offset:384
	ds_read_b128 v[34:37], v25 offset:448
	; wait_asyncmark(2)
	.loc	1 59 17                         ; kernel.py:59:17
	s_waitcnt vmcnt(12) lgkmcnt(0)
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[30:33], v[46:49], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	s_barrier
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[50:53], v[0:3]
	v_mfma_f32_16x16x32_bf16 v[0:3], v[34:37], v[54:57], v[0:3]
	.loc	1 55 5                          ; kernel.py:55:5
	s_cbranch_scc1 .LBB0_1
; %bb.2:
	.loc	1 60 13                         ; kernel.py:60:13
	v_or3_b32 v6, s2, v21, v5
	v_add_u32_e32 v6, v6, v22
	v_add_u32_e32 v7, s7, v6
	ds_read_b128 v[10:13], v7
	.loc	1 59 17                         ; kernel.py:59:17
	v_or3_b32 v8, v19, v5, v18
	v_add_u32_e32 v8, v8, v20
	v_add_u32_e32 v9, s15, v8
	ds_read_b128 v[14:17], v9 offset:50656
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[18:21], v7 offset:64
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[22:25], v9 offset:50720
	.loc	1 60 13                         ; kernel.py:60:13
	v_add_u32_e32 v6, s14, v6
	.loc	1 46 14                         ; kernel.py:46:14
	v_lshl_or_b32 v5, s10, 6, v5
	.loc	1 47 30                         ; kernel.py:47:30
	v_lshrrev_b32_e32 v5, 2, v5
	.loc	1 68 9                          ; kernel.py:68:9
	s_lshl_b32 s1, s1, 6
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[10:13], v7 offset:128
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[14:17], v9 offset:50784
	.loc	1 53 14                         ; kernel.py:53:14
	v_cmp_gt_i32_e32 vcc, s0, v4
	.loc	1 68 9                          ; kernel.py:68:9
	s_and_b32 s13, s13, 0xffff
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[18:21], v7 offset:192
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[22:25], v9 offset:50848
	.loc	1 68 9                          ; kernel.py:68:9
	s_mov_b32 s15, 0x27000
	s_mov_b32 s14, 0x7ffffffe
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[10:13], v7 offset:256
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[14:17], v9 offset:50912
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v7 offset:320
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[18:21], v9 offset:50976
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[22:25], v7 offset:384
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[10:13], v9 offset:51040
	ds_read_b128 v[14:17], v9 offset:51104
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[30:33], v7 offset:448
	; wait_asyncmark(0)
	.loc	1 59 17                         ; kernel.py:59:17
	s_waitcnt vmcnt(0) lgkmcnt(0)
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[18:21], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	s_barrier
	v_add_u32_e32 v7, s24, v8
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[10:13], v[0:3]
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[10:13], v6
	ds_read_b128 v[18:21], v6 offset:64
	.loc	1 64 14                         ; kernel.py:64:14
	v_mul_u32_u24_e32 v8, 0x1800, v4
	.loc	1 61 15                         ; kernel.py:61:15
	v_mfma_f32_16x16x32_bf16 v[0:3], v[30:33], v[14:17], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[14:17], v7 offset:50656
	ds_read_b128 v[22:25], v7 offset:50720
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v6 offset:128
	.loc	1 64 14                         ; kernel.py:64:14
	v_or_b32_e32 v5, v5, v8
	.loc	1 68 9                          ; kernel.py:68:9
	v_lshl_add_u32 v5, v5, 1, s1
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[10:13], v[14:17], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[10:13], v7 offset:50784
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[14:17], v6 offset:192
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[22:25], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[18:21], v7 offset:50848
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[22:25], v6 offset:256
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[10:13], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[10:13], v7 offset:50912
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[26:29], v6 offset:320
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[14:17], v[18:21], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[14:17], v7 offset:50976
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[18:21], v6 offset:384
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[10:13], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[10:13], v7 offset:51040
	.loc	1 60 13                         ; kernel.py:60:13
	ds_read_b128 v[22:25], v6 offset:448
	.loc	1 68 9                          ; kernel.py:68:9
	v_bfrev_b32_e32 v6, 1
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[26:29], v[14:17], v[0:3]
	.loc	1 59 17                         ; kernel.py:59:17
	ds_read_b128 v[14:17], v7 offset:51104
	.loc	1 61 15                         ; kernel.py:61:15
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[18:21], v[10:13], v[0:3]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[22:25], v[14:17], v[0:3]
	.loc	1 68 26                         ; kernel.py:68:26
	s_nop 7
	v_cvt_pk_bf16_f32 v0, v0, v1
	v_cvt_pk_bf16_f32 v1, v2, v3
	.loc	1 68 9 is_stmt 0                ; kernel.py:68:9
	v_cndmask_b32_e32 v2, v6, v5, vcc
	buffer_store_dwordx2 v[0:1], v2, s[12:15], 0 offen
	.loc	1 30 1 is_stmt 1                ; kernel.py:30:1
	s_endpgm
.Ltmp3:
.Lfunc_end0:
	.size	_gemm_m16_kernel, .Lfunc_end0-_gemm_m16_kernel
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _gemm_m16_kernel
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
		.amdhsa_accum_offset 100
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
	.set .L_gemm_m16_kernel.num_vgpr, 98
	.set .L_gemm_m16_kernel.num_agpr, 0
	.set .L_gemm_m16_kernel.numbered_sgpr, 28
	.set .L_gemm_m16_kernel.num_named_barrier, 0
	.set .L_gemm_m16_kernel.private_seg_size, 0
	.set .L_gemm_m16_kernel.uses_vcc, 1
	.set .L_gemm_m16_kernel.uses_flat_scratch, 0
	.set .L_gemm_m16_kernel.has_dyn_sized_stack, 0
	.set .L_gemm_m16_kernel.has_recursion, 0
	.set .L_gemm_m16_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 3056
; TotalNumSgprs: 34
; NumVgprs: 98
; NumAgprs: 0
; TotalNumVgprs: 98
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 21
; NumSGPRsForWavesPerEU: 102
; NumVGPRsForWavesPerEU: 169
; AccumOffset: 100
; Occupancy: 2
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 15
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 2
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 24
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
	.asciz	"/work/build/gemm_n6144_m2"     ; string offset=17 ; /work/build/gemm_n6144_m2
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
    .max_flat_workgroup_size: 128
    .name:           _gemm_m16_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     34
    .sgpr_spill_count: 0
    .symbol:         _gemm_m16_kernel.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     98
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
