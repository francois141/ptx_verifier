	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	binary_bmm_kernel               ; -- Begin function binary_bmm_kernel
	.p2align	8
	.type	binary_bmm_kernel,@function
binary_bmm_kernel:                      ; @binary_bmm_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.35:
	.file	1 "/work/external/amd/triton/../../bitwise/bitdelta_triton/upstream" "binary_gemm_kernel.py"
	.loc	1 196 0 prologue_end            ; binary_gemm_kernel.py:196:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.36:
.LBB0_0:
.Ltmp1:
	.loc	1 229 22 is_stmt 1              ; binary_gemm_kernel.py:229:22
	s_ashr_i32 s0, s12, 31
	s_lshr_b32 s1, s0, 29
	s_add_i32 s1, s12, s1
	.loc	1 230 29                        ; binary_gemm_kernel.py:230:29
	s_and_b32 s1, s1, -8
	.loc	1 231 35                        ; binary_gemm_kernel.py:231:35
	s_sub_i32 s8, 16, s1
	.loc	1 231 48 is_stmt 0              ; binary_gemm_kernel.py:231:48
	s_min_i32 s8, s8, 8
	.loc	1 232 33 is_stmt 1              ; binary_gemm_kernel.py:232:33
	s_abs_i32 s9, s8
	v_cvt_f32_u32_e32 v1, s9
	s_sub_i32 s11, 0, s9
	s_abs_i32 s10, s12
	.loc	1 245 60                        ; binary_gemm_kernel.py:245:60
	v_and_b32_e32 v8, 63, v0
	.loc	1 232 33                        ; binary_gemm_kernel.py:232:33
	v_rcp_iflag_f32_e32 v1, v1
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_readfirstlane_b32 s14, v1
	s_mul_i32 s11, s11, s14
	s_mul_hi_u32 s11, s14, s11
	s_add_i32 s14, s14, s11
	s_mul_hi_u32 s11, s10, s14
	s_mul_i32 s11, s11, s9
	s_sub_i32 s10, s10, s11
	s_sub_i32 s11, s10, s9
	s_cmp_ge_u32 s10, s9
	s_cselect_b32 s10, s11, s10
	s_sub_i32 s11, s10, s9
	s_cmp_ge_u32 s10, s9
	s_cselect_b32 s10, s11, s10
	.loc	1 233 19                        ; binary_gemm_kernel.py:233:19
	s_sub_i32 s11, s12, s1
	.loc	1 232 33                        ; binary_gemm_kernel.py:232:33
	s_xor_b32 s10, s10, s0
	.loc	1 233 40                        ; binary_gemm_kernel.py:233:40
	s_xor_b32 s8, s11, s8
	.loc	1 232 33                        ; binary_gemm_kernel.py:232:33
	s_sub_i32 s0, s10, s0
	.loc	1 232 27 is_stmt 0              ; binary_gemm_kernel.py:232:27
	s_add_i32 s0, s0, s1
	.loc	1 233 40 is_stmt 1              ; binary_gemm_kernel.py:233:40
	s_ashr_i32 s1, s8, 31
	s_abs_i32 s8, s11
	s_mul_hi_u32 s10, s8, s14
	s_mul_i32 s11, s10, s9
	s_sub_i32 s8, s8, s11
	s_add_i32 s11, s10, 1
	s_sub_i32 s12, s8, s9
	s_cmp_ge_u32 s8, s9
	s_cselect_b32 s10, s11, s10
	s_cselect_b32 s8, s12, s8
	s_add_i32 s11, s10, 1
	s_cmp_ge_u32 s8, s9
	s_cselect_b32 s8, s11, s10
	.loc	1 242 23                        ; binary_gemm_kernel.py:242:23
	s_lshl_b32 s11, s0, 4
	.loc	1 242 51 is_stmt 0              ; binary_gemm_kernel.py:242:51
	v_lshrrev_b32_e32 v1, 6, v0
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	s_bfe_i32 s0, s0, 0x1001b
	.loc	1 242 38                        ; binary_gemm_kernel.py:242:38
	v_or_b32_e32 v1, s11, v1
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	s_lshr_b32 s0, s0, 24
	v_add_u32_e32 v5, s0, v1
	.loc	1 242 38                        ; binary_gemm_kernel.py:242:38
	v_or_b32_e32 v2, 4, v1
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	v_and_b32_e32 v5, 0xffff00, v5
	.loc	1 242 38                        ; binary_gemm_kernel.py:242:38
	v_or_b32_e32 v3, 8, v1
	v_or_b32_e32 v4, 12, v1
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	v_sub_u32_e32 v1, v1, v5
	v_add_u32_e32 v5, s0, v2
	v_and_b32_e32 v5, 0xffff00, v5
	v_sub_u32_e32 v5, v2, v5
	v_add_u32_e32 v2, s0, v3
	v_and_b32_e32 v2, 0xffff00, v2
	.loc	1 233 40 is_stmt 1              ; binary_gemm_kernel.py:233:40
	s_xor_b32 s8, s8, s1
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	v_sub_u32_e32 v3, v3, v2
	v_add_u32_e32 v2, s0, v4
	.loc	1 233 40                        ; binary_gemm_kernel.py:233:40
	s_sub_i32 s1, s8, s1
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	v_and_b32_e32 v2, 0xffff00, v2
	.loc	1 245 96                        ; binary_gemm_kernel.py:245:96
	s_lshl_b32 s8, s13, 16
	.loc	1 242 68                        ; binary_gemm_kernel.py:242:68
	v_sub_u32_e32 v7, v4, v2
	.loc	1 243 68                        ; binary_gemm_kernel.py:243:68
	s_bfe_i32 s0, s1, 0x10017
	.loc	1 245 84                        ; binary_gemm_kernel.py:245:84
	s_ashr_i32 s9, s8, 31
	.loc	1 243 23                        ; binary_gemm_kernel.py:243:23
	s_lshl_b32 s10, s1, 8
	.loc	1 243 68 is_stmt 0              ; binary_gemm_kernel.py:243:68
	s_lshr_b32 s12, s0, 24
	.loc	1 245 53 is_stmt 1              ; binary_gemm_kernel.py:245:53
	v_lshl_or_b32 v2, v1, 8, v8
	v_lshl_or_b32 v4, v5, 8, v8
	v_lshl_or_b32 v6, v3, 8, v8
	v_lshl_or_b32 v8, v7, 8, v8
	.loc	1 245 84 is_stmt 0              ; binary_gemm_kernel.py:245:84
	s_lshl_b64 s[0:1], s[8:9], 2
	.loc	1 245 22                        ; binary_gemm_kernel.py:245:22
	v_ashrrev_i32_e32 v3, 31, v2
	v_ashrrev_i32_e32 v5, 31, v4
	v_ashrrev_i32_e32 v9, 31, v8
	.loc	1 261 22 is_stmt 1              ; binary_gemm_kernel.py:261:22
	s_add_u32 s0, s2, s0
	.loc	1 245 22                        ; binary_gemm_kernel.py:245:22
	v_ashrrev_i32_e32 v7, 31, v6
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_addc_u32 s1, s3, s1
	.loc	1 245 22                        ; binary_gemm_kernel.py:245:22
	v_lshlrev_b64 v[2:3], 2, v[2:3]
	v_lshlrev_b64 v[4:5], 2, v[4:5]
	v_lshlrev_b64 v[8:9], 2, v[8:9]
	.loc	1 245 84 is_stmt 0              ; binary_gemm_kernel.py:245:84
	v_lshl_add_u64 v[10:11], s[0:1], 0, v[2:3]
	v_lshl_add_u64 v[12:13], s[0:1], 0, v[4:5]
	.loc	1 245 22                        ; binary_gemm_kernel.py:245:22
	v_lshlrev_b64 v[6:7], 2, v[6:7]
	.loc	1 245 84                        ; binary_gemm_kernel.py:245:84
	v_lshl_add_u64 v[16:17], s[0:1], 0, v[8:9]
	v_lshl_add_u64 v[14:15], s[0:1], 0, v[6:7]
	.loc	1 264 20 is_stmt 1              ; binary_gemm_kernel.py:264:20
	global_load_dword v18, v[10:11], off
	global_load_dword v19, v[12:13], off
	global_load_dword v20, v[14:15], off
	global_load_dword v21, v[16:17], off
	global_load_dword v22, v[16:17], off offset:256
	global_load_dword v23, v[14:15], off offset:256
	global_load_dword v24, v[12:13], off offset:256
	global_load_dword v25, v[10:11], off offset:256
	.loc	1 242 51                        ; binary_gemm_kernel.py:242:51
	v_and_b32_e32 v12, 0xc0, v0
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_lshlrev_b32_e32 v13, 2, v0
	v_lshrrev_b32_e32 v10, 4, v12
	v_xor_b32_e32 v38, v13, v10
	.loc	1 243 38                        ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v10, s10, v0
	.loc	1 250 108                       ; binary_gemm_kernel.py:250:108
	s_lshl_b32 s2, s13, 11
	.loc	1 243 68                        ; binary_gemm_kernel.py:243:68
	v_add_u32_e32 v11, s12, v10
	.loc	1 250 96                        ; binary_gemm_kernel.py:250:96
	s_ashr_i32 s3, s2, 31
	.loc	1 243 68                        ; binary_gemm_kernel.py:243:68
	v_and_b32_e32 v11, 0xffffff00, v11
	.loc	1 250 96                        ; binary_gemm_kernel.py:250:96
	s_lshl_b64 s[2:3], s[2:3], 2
	.loc	1 243 68                        ; binary_gemm_kernel.py:243:68
	v_sub_u32_e32 v10, v10, v11
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_add_u32 s2, s4, s2
	.loc	1 250 22                        ; binary_gemm_kernel.py:250:22
	v_ashrrev_i32_e32 v11, 31, v10
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_addc_u32 s3, s5, s3
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[2:3]
	.loc	1 266 20                        ; binary_gemm_kernel.py:266:20
	global_load_dword v74, v[10:11], off
	global_load_dword v71, v[10:11], off offset:1024
	global_load_dword v73, v[10:11], off offset:2048
	global_load_dword v62, v[10:11], off offset:3072
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	s_add_i32 s13, 0, 0x10000
	v_xor_b32_e32 v44, 16, v38
	v_xor_b32_e32 v45, 32, v38
	v_add_u32_e32 v14, s13, v38
	v_xor_b32_e32 v49, 48, v38
	v_add_u32_e32 v15, s13, v44
	v_add_u32_e32 v16, s13, v45
	s_add_i32 s12, 0, 0x11000
	.loc	1 242 51                        ; binary_gemm_kernel.py:242:51
	v_and_b32_e32 v1, 15, v0
	v_add_u32_e32 v29, 0, v13
	v_or_b32_e32 v54, 0xc00, v13
	v_or_b32_e32 v55, 0x1c00, v13
	v_or_b32_e32 v56, 0x2c00, v13
	v_or_b32_e32 v57, 0x3c00, v13
	v_or_b32_e32 v58, 0x4c00, v13
	v_or_b32_e32 v59, 0x5c00, v13
	v_or_b32_e32 v60, 0x6c00, v13
	v_or_b32_e32 v61, 0x7c00, v13
	v_or_b32_e32 v63, 0x8c00, v13
	v_or_b32_e32 v64, 0x9c00, v13
	v_or_b32_e32 v65, 0xac00, v13
	v_or_b32_e32 v66, 0xbc00, v13
	v_or_b32_e32 v67, 0xcc00, v13
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	s_waitcnt vmcnt(11)
	ds_write_b32 v14, v18
	s_waitcnt vmcnt(10)
	ds_write_b32 v15, v19 offset:1024
	s_waitcnt vmcnt(9)
	ds_write_b32 v16, v20 offset:2048
	v_add_u32_e32 v14, s13, v49
	s_waitcnt vmcnt(8)
	ds_write_b32 v14, v21 offset:3072
	v_add_u32_e32 v14, s12, v38
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(4)
	ds_write_b32 v14, v25
	v_add_u32_e32 v14, s12, v44
	ds_write_b32 v14, v24 offset:1024
	v_add_u32_e32 v14, s12, v45
	v_and_b32_e32 v16, 48, v0
	ds_write_b32 v14, v23 offset:2048
	v_add_u32_e32 v14, s12, v49
	v_lshlrev_b32_e32 v15, 2, v1
	v_lshrrev_b32_e32 v17, 2, v16
	ds_write_b32 v14, v22 offset:3072
	v_lshlrev_b32_e32 v14, 8, v1
	v_xor_b32_e32 v18, v15, v17
	v_or_b32_e32 v68, 0xdc00, v13
	v_or_b32_e32 v69, 0xec00, v13
	v_or_b32_e32 v70, 0xfc00, v13
	v_lshl_add_u32 v13, v16, 6, 0
	s_mov_b64 s[2:3], 0x1400
	s_mov_b32 s14, 1
	v_bitop3_b32 v33, v15, v14, v17 bitop3:0xde
	v_bitop3_b32 v32, v18, 16, v14 bitop3:0x36
	v_bitop3_b32 v31, v18, 32, v14 bitop3:0x36
	v_bitop3_b32 v30, v18, 48, v14 bitop3:0x36
	v_add3_u32 v28, v13, v15, v12
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[2:3]
	v_or_b32_e32 v8, 0x200, v8
	v_or_b32_e32 v6, 0x200, v6
	v_or_b32_e32 v4, 0x200, v4
	v_or_b32_e32 v2, 0x200, v2
	s_mov_b64 s[4:5], -1
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	s_mov_b64 s[2:3], 0x800
	v_mov_b32_e32 v72, 2
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 0 22 is_stmt 0                ; binary_gemm_kernel.py:0:22
	s_waitcnt vmcnt(3)
	v_mov_b32_e32 v75, v74
	.loc	1 280 18 is_stmt 1              ; binary_gemm_kernel.py:280:18
	v_lshl_add_u64 v[14:15], s[0:1], 0, v[2:3]
	v_lshl_add_u64 v[12:13], s[0:1], 0, v[4:5]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshlrev_b32_e32 v21, 1, v75
	.loc	1 280 18                        ; binary_gemm_kernel.py:280:18
	v_lshl_add_u64 v[18:19], s[0:1], 0, v[6:7]
	.loc	1 282 18                        ; binary_gemm_kernel.py:282:18
	v_lshl_add_u64 v[16:17], s[0:1], 0, v[8:9]
	s_waitcnt vmcnt(2)
	v_mov_b32_e32 v80, v71
	s_waitcnt vmcnt(0)
	v_mov_b32_e32 v71, v62
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	global_load_dword v76, v[14:15], off
	global_load_dword v77, v[12:13], off
	global_load_dword v78, v[18:19], off
	global_load_dword v79, v[16:17], off
	v_add_u32_e32 v12, s13, v33
	v_add_u32_e32 v13, s13, v32
	v_add_u32_e32 v14, s13, v31
	v_add_u32_e32 v62, s13, v30
	.loc	1 270 29                        ; binary_gemm_kernel.py:270:29
	v_and_b32_e32 v20, 2, v75
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v86, 2, v21
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[26:27], v12 offset1:16
	ds_read2_b32 v[18:19], v12 offset0:32 offset1:48
	ds_read2_b32 v[24:25], v13 offset1:16
	ds_read2_b32 v[16:17], v13 offset0:32 offset1:48
	ds_read2_b32 v[22:23], v14 offset1:16
	ds_read2_b32 v[14:15], v14 offset0:32 offset1:48
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v87, -1, v20
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	ds_read2_b32 v[20:21], v62 offset1:16
	ds_read2_b32 v[12:13], v62 offset0:32 offset1:48
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v86
	.loc	1 272 23 is_stmt 0              ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v86, v87
	v_cvt_f32_i32_e32 v62, v62
	v_mov_b32_e32 v74, v73
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 1, v75
	v_lshrrev_b32_e32 v81, 3, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset1:4
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v62, 9, v75
	v_lshrrev_b32_e32 v86, 11, v75
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v86, 2, v86
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v86, -1, v86
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v86, v86
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v73, 2, v73
	v_and_b32_e32 v81, 2, v81
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v73, -1, v73
	v_add_u32_e32 v81, -1, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset0:40 offset1:48
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v62, 20, v75
	v_lshrrev_b32_e32 v86, 21, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v73, v73
	v_cvt_f32_i32_e32 v81, v81
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v86, 2, v86
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v86, -1, v86
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v86, v86
	ds_write2st64_b32 v29, v73, v81 offset0:8 offset1:16
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 12, v75
	v_lshrrev_b32_e32 v81, 13, v75
	v_and_b32_e32 v73, 2, v73
	v_and_b32_e32 v81, 2, v81
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v73, -1, v73
	v_add_u32_e32 v81, -1, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset0:84 offset1:88
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshlrev_b32_e32 v62, 1, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v73, v73
	v_cvt_f32_i32_e32 v81, v81
	.loc	1 270 29 is_stmt 1              ; binary_gemm_kernel.py:270:29
	v_and_b32_e32 v86, 2, v80
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v62
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v86, -1, v86
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 4, v75
	v_lshrrev_b32_e32 v83, 5, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v86, v86
	v_cvt_f32_i32_e32 v62, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v73, v81 offset0:52 offset1:56
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 23, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v81, v75, v72 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	v_and_b32_e32 v73, 2, v73
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v81, -1, v81
	v_add_u32_e32 v73, -1, v73
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset0:128 offset1:132
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v62, 9, v80
	v_lshrrev_b32_e32 v86, 11, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v81, v81
	v_cvt_f32_i32_e32 v73, v73
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v86, 2, v86
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v86, -1, v86
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:20 offset1:24
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 15, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v86, v86
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v83, v75, v72 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_e32 v82, 2, v82
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v83, -1, v83
	v_add_u32_e32 v82, -1, v82
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v73, v81 offset0:96 offset1:100
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 1, v80
	v_lshrrev_b32_e32 v81, 3, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v83, v83
	v_cvt_f32_i32_e32 v82, v82
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v73, 2, v73
	v_and_b32_e32 v81, 2, v81
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v73, -1, v73
	v_add_u32_e32 v81, -1, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset0:168 offset1:176
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v62, 20, v80
	v_lshrrev_b32_e32 v86, 21, v80
	v_lshrrev_b32_e32 v84, 7, v75
	v_lshrrev_b32_e32 v85, 8, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v73, v73
	v_cvt_f32_i32_e32 v81, v81
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v86, 2, v86
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v86, -1, v86
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:64 offset1:68
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 25, v75
	v_lshrrev_b32_e32 v83, 27, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v86, v86
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v73, v81 offset0:136 offset1:144
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 12, v80
	v_lshrrev_b32_e32 v81, 13, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v73, 2, v73
	v_and_b32_e32 v81, 2, v81
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v73, -1, v73
	v_add_u32_e32 v81, -1, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v62, v86 offset0:212 offset1:216
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v62, 2, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v84, v85 offset0:32 offset1:36
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 17, v75
	v_lshrrev_b32_e32 v85, 19, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v73, v73
	v_cvt_f32_i32_e32 v81, v81
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:104 offset1:112
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 4, v80
	v_lshrrev_b32_e32 v83, 5, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v73, v81 offset0:180 offset1:184
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 23, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_add_u32_e32 v34, 0, v54
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v81, v80, v72 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	v_lshrrev_b32_e32 v86, 6, v75
	v_and_b32_e32 v73, 2, v73
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v81, -1, v81
	v_add_u32_e32 v73, -1, v73
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v34, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v86
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v84, v85 offset0:72 offset1:80
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 28, v75
	v_lshrrev_b32_e32 v85, 29, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v81, v81
	v_cvt_f32_i32_e32 v73, v73
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:148 offset1:152
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 15, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v83, v80, v72 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_e32 v82, 2, v82
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_add_u32_e32 v35, 0, v55
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v83, -1, v83
	v_add_u32_e32 v82, -1, v82
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v73, v81 offset0:224 offset1:228
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v73, 10, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v83, v83
	v_cvt_f32_i32_e32 v82, v82
	ds_write_b32 v35, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v73
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v84, v85 offset0:116 offset1:120
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 7, v80
	v_lshrrev_b32_e32 v85, 8, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:192 offset1:196
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 25, v80
	v_lshrrev_b32_e32 v83, 27, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_add_u32_e32 v36, 0, v56
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v81, 14, v75
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v36, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	ds_write2st64_b32 v29, v84, v85 offset0:160 offset1:164
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 17, v80
	v_lshrrev_b32_e32 v85, 19, v80
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_add_u32_e32 v37, 0, v57
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write2st64_b32 v29, v82, v83 offset0:232 offset1:240
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 18, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	ds_write_b32 v37, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v82
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	ds_write2st64_b32 v29, v84, v85 offset0:200 offset1:208
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 28, v80
	v_lshrrev_b32_e32 v85, 29, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_add_u32_e32 v39, 0, v58
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v83, 22, v75
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v39, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_add_u32_e32 v40, 0, v59
	ds_write2st64_b32 v29, v84, v85 offset0:244 offset1:248
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 26, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v40, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v84
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	v_add_u32_e32 v41, 0, v60
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v75, 30, v75
	v_lshrrev_b32_e32 v85, 2, v80
	v_lshrrev_b32_e32 v87, 6, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v41, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v62, 2, v75
	v_and_b32_e32 v75, 2, v85
	v_lshrrev_b32_e32 v86, 10, v80
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v62, -1, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v84, 2, v87
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v75, -1, v75
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v88, 14, v80
	v_lshrrev_b32_e32 v81, 18, v80
	v_lshrrev_b32_e32 v82, 22, v80
	v_lshrrev_b32_e32 v83, 26, v80
	v_lshrrev_b32_e32 v80, 30, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v62, v62
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v85, 2, v86
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v75, v75
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v86, 2, v88
	v_and_b32_e32 v81, 2, v81
	v_and_b32_e32 v80, 2, v80
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v84, v84
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v86, -1, v86
	v_add_u32_e32 v81, -1, v81
	v_add_u32_e32 v80, -1, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v85, v85
	v_add_u32_e32 v42, 0, v61
	v_add_u32_e32 v43, 0, v63
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v86, v86
	v_cvt_f32_i32_e32 v81, v81
	v_cvt_f32_i32_e32 v80, v80
	v_add_u32_e32 v46, 0, v64
	v_add_u32_e32 v47, 0, v65
	v_add_u32_e32 v48, 0, v66
	v_add_u32_e32 v50, 0, v67
	v_add_u32_e32 v51, 0, v68
	v_add_u32_e32 v52, 0, v69
	v_add_u32_e32 v53, 0, v70
	.loc	1 266 20 is_stmt 1              ; binary_gemm_kernel.py:266:20
	global_load_dword v73, v[10:11], off offset:-1024
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_write_b32 v42, v62
	.loc	1 266 20                        ; binary_gemm_kernel.py:266:20
	global_load_dword v62, v[10:11], off
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	ds_write_b32 v43, v75
	ds_write_b32 v46, v84
	ds_write_b32 v47, v85
	ds_write_b32 v48, v86
	ds_write_b32 v50, v81
	ds_write_b32 v51, v82
	ds_write_b32 v52, v83
	ds_write_b32 v53, v80
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[80:81], v28 offset1:1
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v80, v26, a[12:15]
	s_mov_b32 s13, s12
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_add_i32 s12, s14, 1
	s_cmp_lt_i32 s12, 2
	s_cselect_b32 s14, s12, 0
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	s_lshl_b32 s12, s14, 12
	s_add_i32 s12, s12, 0
	s_add_i32 s12, s12, 0x10000
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v26, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:2 offset1:3
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_add_u32 s0, s0, 0x100
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[2:3]
	s_addc_u32 s1, s1, 0
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[4:5], 0
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v26, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v26, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:16 offset1:17
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v80, v24, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v24, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:18 offset1:19
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v24, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v24, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:32 offset1:33
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v80, v22, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v22, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:34 offset1:35
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v22, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v22, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:48 offset1:49
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v80, v20, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v20, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:50 offset1:51
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v20, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v20, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:64 offset1:65
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v80, v27, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v81, v27, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[80:81], v28 offset0:66 offset1:67
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v27, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v27, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[26:27], v28 offset0:80 offset1:81
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v25, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v25, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[26:27], v28 offset0:82 offset1:83
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v26, v25, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v27, v25, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[24:25], v28 offset0:96 offset1:97
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v24, v23, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v25, v23, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[24:25], v28 offset0:98 offset1:99
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v24, v23, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v25, v23, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[22:23], v28 offset0:112 offset1:113
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v22, v21, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v23, v21, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[22:23], v28 offset0:114 offset1:115
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v22, v21, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v23, v21, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:128 offset1:129
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v20, v18, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v18, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:130 offset1:131
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v18, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v18, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:144 offset1:145
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v20, v16, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v16, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:146 offset1:147
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v16, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v16, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:160 offset1:161
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v20, v14, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v14, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:162 offset1:163
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v14, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v14, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:176 offset1:177
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v20, v12, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v12, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:178 offset1:179
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v12, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v12, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:192 offset1:193
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v12, s12, v38
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v20, v19, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v21, v19, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[20:21], v28 offset0:194 offset1:195
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v19, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v19, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[18:19], v28 offset0:208 offset1:209
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v18, v17, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v19, v17, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[18:19], v28 offset0:210 offset1:211
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v18, v17, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v19, v17, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[16:17], v28 offset0:224 offset1:225
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v16, v15, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v17, v15, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[16:17], v28 offset0:226 offset1:227
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v16, v15, a[8:11]
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v16, s12, v45
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v17, v15, a[0:3]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[14:15], v28 offset0:240 offset1:241
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v17, s12, v49
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[12:15], v14, v13, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v15, v13, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[14:15], v28 offset0:242 offset1:243
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[8:11], v14, v13, a[8:11]
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v14, s12, v44
	s_waitcnt vmcnt(5)
	ds_write_b32 v12, v76
	s_waitcnt vmcnt(4)
	ds_write_b32 v14, v77 offset:1024
	s_waitcnt vmcnt(3)
	ds_write_b32 v16, v78 offset:2048
	s_waitcnt vmcnt(2)
	ds_write_b32 v17, v79 offset:3072
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v15, v13, a[0:3]
	.loc	1 261 22                        ; binary_gemm_kernel.py:261:22
	s_cbranch_vccnz .LBB0_1
; %bb.2:
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshlrev_b32_e32 v20, 1, v74
	.loc	1 270 29                        ; binary_gemm_kernel.py:270:29
	v_and_b32_e32 v18, 2, v74
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v20, 2, v20
	v_lshrrev_b32_e32 v22, 2, v74
	v_lshrrev_b32_e32 v21, 1, v74
	v_and_b32_e32 v22, 2, v22
	v_lshrrev_b32_e32 v23, 3, v74
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v20, -1, v20
	v_add_u32_e32 v18, -1, v18
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v21, 2, v21
	v_and_b32_e32 v23, 2, v23
	v_lshrrev_b32_e32 v24, 4, v74
	v_lshrrev_b32_e32 v25, 5, v74
	v_mov_b32_e32 v63, 2
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v22, -1, v22
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v20, v20
	v_cvt_f32_i32_e32 v18, v18
	.loc	1 270 29 is_stmt 1              ; binary_gemm_kernel.py:270:29
	v_and_b32_e32 v19, 2, v71
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v24, 2, v24
	v_and_b32_e32 v25, 2, v25
	v_lshrrev_b32_e32 v26, 6, v74
	v_lshrrev_b32_e32 v27, 7, v74
	v_lshrrev_b32_e32 v38, 8, v74
	v_lshrrev_b32_e32 v44, 9, v74
	v_lshrrev_b32_e32 v45, 10, v74
	v_lshrrev_b32_e32 v49, 11, v74
	v_lshrrev_b32_e32 v54, 12, v74
	v_lshrrev_b32_e32 v55, 13, v74
	v_lshrrev_b32_e32 v56, 14, v74
	v_lshrrev_b32_e32 v57, 15, v74
	v_and_b32_sdwa v58, v74, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_lshrrev_b32_e32 v59, 17, v74
	v_lshrrev_b32_e32 v60, 18, v74
	v_lshrrev_b32_e32 v61, 19, v74
	v_lshrrev_b32_e32 v64, 20, v74
	v_lshrrev_b32_e32 v65, 21, v74
	v_lshrrev_b32_e32 v66, 22, v74
	v_lshrrev_b32_e32 v67, 23, v74
	v_and_b32_sdwa v68, v74, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	v_lshrrev_b32_e32 v69, 25, v74
	v_lshrrev_b32_e32 v70, 26, v74
	v_lshrrev_b32_e32 v72, 27, v74
	v_lshrrev_b32_e32 v75, 28, v74
	v_lshrrev_b32_e32 v76, 29, v74
	v_lshrrev_b32_e32 v74, 30, v74
	v_lshlrev_b32_e32 v77, 1, v71
	v_lshrrev_b32_e32 v78, 1, v71
	v_lshrrev_b32_e32 v79, 2, v71
	v_lshrrev_b32_e32 v80, 3, v71
	v_lshrrev_b32_e32 v81, 4, v71
	v_lshrrev_b32_e32 v82, 5, v71
	v_lshrrev_b32_e32 v83, 6, v71
	v_lshrrev_b32_e32 v84, 7, v71
	v_lshrrev_b32_e32 v85, 8, v71
	v_lshrrev_b32_e32 v86, 9, v71
	v_lshrrev_b32_e32 v87, 10, v71
	v_lshrrev_b32_e32 v88, 11, v71
	v_lshrrev_b32_e32 v89, 12, v71
	v_lshrrev_b32_e32 v90, 13, v71
	v_lshrrev_b32_e32 v91, 14, v71
	v_lshrrev_b32_e32 v92, 15, v71
	v_and_b32_sdwa v93, v71, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_lshrrev_b32_e32 v94, 17, v71
	v_lshrrev_b32_e32 v95, 18, v71
	v_lshrrev_b32_e32 v96, 19, v71
	v_lshrrev_b32_e32 v97, 20, v71
	v_lshrrev_b32_e32 v98, 21, v71
	v_lshrrev_b32_e32 v99, 22, v71
	v_lshrrev_b32_e32 v100, 23, v71
	v_and_b32_sdwa v101, v71, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	v_lshrrev_b32_e32 v102, 25, v71
	v_lshrrev_b32_e32 v103, 26, v71
	v_lshrrev_b32_e32 v104, 27, v71
	v_lshrrev_b32_e32 v105, 28, v71
	v_lshrrev_b32_e32 v106, 29, v71
	v_lshrrev_b32_e32 v71, 30, v71
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v21, -1, v21
	v_add_u32_e32 v23, -1, v23
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v22, v22
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_e32 v26, 2, v26
	v_and_b32_e32 v27, 2, v27
	v_and_b32_e32 v38, 2, v38
	v_and_b32_e32 v44, 2, v44
	v_and_b32_e32 v45, 2, v45
	v_and_b32_e32 v49, 2, v49
	v_and_b32_e32 v54, 2, v54
	v_and_b32_e32 v55, 2, v55
	v_and_b32_e32 v56, 2, v56
	v_and_b32_e32 v57, 2, v57
	v_and_b32_e32 v59, 2, v59
	v_and_b32_e32 v60, 2, v60
	v_and_b32_e32 v61, 2, v61
	v_and_b32_e32 v64, 2, v64
	v_and_b32_e32 v65, 2, v65
	v_and_b32_e32 v66, 2, v66
	v_and_b32_e32 v67, 2, v67
	v_and_b32_e32 v69, 2, v69
	v_and_b32_e32 v70, 2, v70
	v_and_b32_e32 v72, 2, v72
	v_and_b32_e32 v75, 2, v75
	v_and_b32_e32 v76, 2, v76
	v_and_b32_e32 v74, 2, v74
	v_and_b32_e32 v77, 2, v77
	v_and_b32_e32 v78, 2, v78
	v_and_b32_e32 v79, 2, v79
	v_and_b32_e32 v80, 2, v80
	v_and_b32_e32 v81, 2, v81
	v_and_b32_e32 v82, 2, v82
	v_and_b32_e32 v83, 2, v83
	v_and_b32_e32 v84, 2, v84
	v_and_b32_e32 v85, 2, v85
	v_and_b32_e32 v86, 2, v86
	v_and_b32_e32 v87, 2, v87
	v_and_b32_e32 v88, 2, v88
	v_and_b32_e32 v89, 2, v89
	v_and_b32_e32 v90, 2, v90
	v_and_b32_e32 v91, 2, v91
	v_and_b32_e32 v92, 2, v92
	v_and_b32_e32 v94, 2, v94
	v_and_b32_e32 v95, 2, v95
	v_and_b32_e32 v96, 2, v96
	v_and_b32_e32 v97, 2, v97
	v_and_b32_e32 v98, 2, v98
	v_and_b32_e32 v99, 2, v99
	v_and_b32_e32 v100, 2, v100
	v_and_b32_e32 v102, 2, v102
	v_and_b32_e32 v103, 2, v103
	v_and_b32_e32 v104, 2, v104
	v_and_b32_e32 v105, 2, v105
	v_and_b32_e32 v106, 2, v106
	v_and_b32_e32 v71, 2, v71
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v24, -1, v24
	v_add_u32_e32 v25, -1, v25
	v_add_u32_e32 v19, -1, v19
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v21, v21
	v_cvt_f32_i32_e32 v23, v23
	.loc	1 264 20 is_stmt 1              ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v2, s13, v33
	v_add_u32_e32 v4, s13, v32
	v_add_u32_e32 v6, s13, v31
	v_add_u32_e32 v8, s13, v30
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v26, -1, v26
	v_add_u32_e32 v27, -1, v27
	v_add_u32_e32 v38, -1, v38
	v_add_u32_e32 v44, -1, v44
	v_add_u32_e32 v45, -1, v45
	v_add_u32_e32 v49, -1, v49
	v_add_u32_e32 v54, -1, v54
	v_add_u32_e32 v55, -1, v55
	v_add_u32_e32 v56, -1, v56
	v_add_u32_e32 v57, -1, v57
	v_add_u32_e32 v58, -1, v58
	v_add_u32_e32 v59, -1, v59
	v_add_u32_e32 v60, -1, v60
	v_add_u32_e32 v61, -1, v61
	v_add_u32_e32 v64, -1, v64
	v_add_u32_e32 v65, -1, v65
	v_add_u32_e32 v66, -1, v66
	v_add_u32_e32 v67, -1, v67
	v_add_u32_e32 v68, -1, v68
	v_add_u32_e32 v69, -1, v69
	v_add_u32_e32 v70, -1, v70
	v_add_u32_e32 v72, -1, v72
	v_add_u32_e32 v75, -1, v75
	v_add_u32_e32 v76, -1, v76
	v_add_u32_e32 v74, -1, v74
	v_add_u32_e32 v77, -1, v77
	v_add_u32_e32 v78, -1, v78
	v_add_u32_e32 v79, -1, v79
	v_add_u32_e32 v80, -1, v80
	v_add_u32_e32 v81, -1, v81
	v_add_u32_e32 v82, -1, v82
	v_add_u32_e32 v83, -1, v83
	v_add_u32_e32 v84, -1, v84
	v_add_u32_e32 v85, -1, v85
	v_add_u32_e32 v86, -1, v86
	v_add_u32_e32 v87, -1, v87
	v_add_u32_e32 v88, -1, v88
	v_add_u32_e32 v89, -1, v89
	v_add_u32_e32 v90, -1, v90
	v_add_u32_e32 v91, -1, v91
	v_add_u32_e32 v92, -1, v92
	v_add_u32_e32 v93, -1, v93
	v_add_u32_e32 v94, -1, v94
	v_add_u32_e32 v95, -1, v95
	v_add_u32_e32 v96, -1, v96
	v_add_u32_e32 v97, -1, v97
	v_add_u32_e32 v98, -1, v98
	v_add_u32_e32 v99, -1, v99
	v_add_u32_e32 v100, -1, v100
	v_add_u32_e32 v101, -1, v101
	v_add_u32_e32 v102, -1, v102
	v_add_u32_e32 v103, -1, v103
	v_add_u32_e32 v104, -1, v104
	v_add_u32_e32 v105, -1, v105
	v_add_u32_e32 v106, -1, v106
	v_add_u32_e32 v71, -1, v71
	.loc	1 272 23 is_stmt 0              ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v24, v24
	v_cvt_f32_i32_e32 v25, v25
	v_cvt_f32_i32_e32 v19, v19
	.loc	1 264 20 is_stmt 1              ; binary_gemm_kernel.py:264:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[10:11], v2 offset1:16
	ds_read2_b32 v[2:3], v2 offset0:32 offset1:48
	ds_read2_b32 v[12:13], v4 offset1:16
	ds_read2_b32 v[4:5], v4 offset0:32 offset1:48
	ds_read2_b32 v[14:15], v6 offset1:16
	ds_read2_b32 v[6:7], v6 offset0:32 offset1:48
	ds_read2_b32 v[16:17], v8 offset1:16
	ds_read2_b32 v[8:9], v8 offset0:32 offset1:48
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v26, v26
	v_cvt_f32_i32_e32 v27, v27
	v_cvt_f32_i32_e32 v38, v38
	v_cvt_f32_i32_e32 v44, v44
	v_cvt_f32_i32_e32 v45, v45
	v_cvt_f32_i32_e32 v49, v49
	v_cvt_f32_i32_e32 v54, v54
	v_cvt_f32_i32_e32 v55, v55
	v_cvt_f32_i32_e32 v56, v56
	v_cvt_f32_i32_e32 v57, v57
	v_cvt_f32_i32_e32 v58, v58
	v_cvt_f32_i32_e32 v59, v59
	v_cvt_f32_i32_e32 v60, v60
	v_cvt_f32_i32_e32 v61, v61
	v_cvt_f32_i32_e32 v64, v64
	v_cvt_f32_i32_e32 v65, v65
	v_cvt_f32_i32_e32 v66, v66
	v_cvt_f32_i32_e32 v67, v67
	v_cvt_f32_i32_e32 v68, v68
	v_cvt_f32_i32_e32 v69, v69
	v_cvt_f32_i32_e32 v70, v70
	v_cvt_f32_i32_e32 v72, v72
	v_cvt_f32_i32_e32 v75, v75
	v_cvt_f32_i32_e32 v76, v76
	v_cvt_f32_i32_e32 v74, v74
	v_cvt_f32_i32_e32 v77, v77
	v_cvt_f32_i32_e32 v78, v78
	v_cvt_f32_i32_e32 v79, v79
	v_cvt_f32_i32_e32 v80, v80
	v_cvt_f32_i32_e32 v81, v81
	v_cvt_f32_i32_e32 v82, v82
	v_cvt_f32_i32_e32 v83, v83
	v_cvt_f32_i32_e32 v84, v84
	v_cvt_f32_i32_e32 v85, v85
	v_cvt_f32_i32_e32 v86, v86
	v_cvt_f32_i32_e32 v87, v87
	v_cvt_f32_i32_e32 v88, v88
	v_cvt_f32_i32_e32 v89, v89
	v_cvt_f32_i32_e32 v90, v90
	v_cvt_f32_i32_e32 v91, v91
	v_cvt_f32_i32_e32 v92, v92
	v_cvt_f32_i32_e32 v93, v93
	v_cvt_f32_i32_e32 v94, v94
	v_cvt_f32_i32_e32 v95, v95
	v_cvt_f32_i32_e32 v96, v96
	v_cvt_f32_i32_e32 v97, v97
	v_cvt_f32_i32_e32 v98, v98
	v_cvt_f32_i32_e32 v99, v99
	v_cvt_f32_i32_e32 v100, v100
	v_cvt_f32_i32_e32 v101, v101
	v_cvt_f32_i32_e32 v102, v102
	v_cvt_f32_i32_e32 v103, v103
	v_cvt_f32_i32_e32 v104, v104
	v_cvt_f32_i32_e32 v105, v105
	v_cvt_f32_i32_e32 v106, v106
	v_cvt_f32_i32_e32 v71, v71
	ds_write2st64_b32 v29, v20, v18 offset1:4
	ds_write_b32 v34, v22
	ds_write2st64_b32 v29, v21, v23 offset0:8 offset1:16
	ds_write2st64_b32 v29, v24, v25 offset0:20 offset1:24
	ds_write_b32 v35, v26
	ds_write2st64_b32 v29, v27, v38 offset0:32 offset1:36
	ds_write_b32 v36, v45
	ds_write2st64_b32 v29, v44, v49 offset0:40 offset1:48
	ds_write2st64_b32 v29, v54, v55 offset0:52 offset1:56
	ds_write_b32 v37, v56
	ds_write2st64_b32 v29, v57, v58 offset0:64 offset1:68
	ds_write_b32 v39, v60
	ds_write2st64_b32 v29, v59, v61 offset0:72 offset1:80
	ds_write2st64_b32 v29, v64, v65 offset0:84 offset1:88
	ds_write_b32 v40, v66
	ds_write2st64_b32 v29, v67, v68 offset0:96 offset1:100
	ds_write_b32 v41, v70
	ds_write2st64_b32 v29, v69, v72 offset0:104 offset1:112
	ds_write2st64_b32 v29, v75, v76 offset0:116 offset1:120
	ds_write_b32 v42, v74
	ds_write2st64_b32 v29, v77, v19 offset0:128 offset1:132
	ds_write_b32 v43, v79
	ds_write2st64_b32 v29, v78, v80 offset0:136 offset1:144
	ds_write2st64_b32 v29, v81, v82 offset0:148 offset1:152
	ds_write_b32 v46, v83
	ds_write2st64_b32 v29, v84, v85 offset0:160 offset1:164
	ds_write_b32 v47, v87
	ds_write2st64_b32 v29, v86, v88 offset0:168 offset1:176
	ds_write2st64_b32 v29, v89, v90 offset0:180 offset1:184
	ds_write_b32 v48, v91
	ds_write2st64_b32 v29, v92, v93 offset0:192 offset1:196
	ds_write_b32 v50, v95
	ds_write2st64_b32 v29, v94, v96 offset0:200 offset1:208
	ds_write2st64_b32 v29, v97, v98 offset0:212 offset1:216
	ds_write_b32 v51, v99
	ds_write2st64_b32 v29, v100, v101 offset0:224 offset1:228
	ds_write_b32 v52, v103
	ds_write2st64_b32 v29, v102, v104 offset0:232 offset1:240
	ds_write2st64_b32 v29, v105, v106 offset0:244 offset1:248
	ds_write_b32 v53, v71
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[18:19], v28 offset1:1
	ds_read2st64_b32 v[20:21], v28 offset0:18 offset1:19
	ds_read2st64_b32 v[22:23], v28 offset0:2 offset1:3
	ds_read2st64_b32 v[24:25], v28 offset0:16 offset1:17
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 a[12:15], v18, v10, a[12:15]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[26:27], v28 offset0:32 offset1:33
	ds_read2st64_b32 v[44:45], v28 offset0:50 offset1:51
	ds_read2st64_b32 v[54:55], v28 offset0:34 offset1:35
	ds_read2st64_b32 v[56:57], v28 offset0:48 offset1:49
	ds_read2st64_b32 v[58:59], v28 offset0:64 offset1:65
	ds_read2st64_b32 v[60:61], v28 offset0:82 offset1:83
	ds_read2st64_b32 v[64:65], v28 offset0:66 offset1:67
	ds_read2st64_b32 v[66:67], v28 offset0:80 offset1:81
	ds_read2st64_b32 v[68:69], v28 offset0:96 offset1:97
	ds_read2st64_b32 v[70:71], v28 offset0:114 offset1:115
	ds_read2st64_b32 v[74:75], v28 offset0:98 offset1:99
	ds_read2st64_b32 v[76:77], v28 offset0:112 offset1:113
	ds_read2st64_b32 v[78:79], v28 offset0:128 offset1:129
	ds_read2st64_b32 v[80:81], v28 offset0:146 offset1:147
	ds_read2st64_b32 v[82:83], v28 offset0:130 offset1:131
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v19, v10, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[84:85], v28 offset0:144 offset1:145
	ds_read2st64_b32 v[86:87], v28 offset0:160 offset1:161
	ds_read2st64_b32 v[88:89], v28 offset0:178 offset1:179
	ds_read2st64_b32 v[90:91], v28 offset0:162 offset1:163
	ds_read2st64_b32 v[92:93], v28 offset0:176 offset1:177
	ds_read2st64_b32 v[94:95], v28 offset0:192 offset1:193
	ds_read2st64_b32 v[96:97], v28 offset0:210 offset1:211
	ds_read2st64_b32 v[98:99], v28 offset0:194 offset1:195
	ds_read2st64_b32 v[100:101], v28 offset0:208 offset1:209
	ds_read2st64_b32 v[102:103], v28 offset0:224 offset1:225
	ds_read2st64_b32 v[104:105], v28 offset0:242 offset1:243
	ds_read2st64_b32 v[106:107], v28 offset0:226 offset1:227
	ds_read2st64_b32 v[108:109], v28 offset0:240 offset1:241
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[8:11], v22, v10, a[8:11]
	.loc	1 270 29                        ; binary_gemm_kernel.py:270:29
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v18, 2, v73
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v22, 2, v73
	v_and_b32_e32 v22, 2, v22
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v18, -1, v18
	v_add_u32_e32 v22, -1, v22
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v18, v18
	.loc	1 270 29 is_stmt 1              ; binary_gemm_kernel.py:270:29
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v19, 2, v62
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v23, v10, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v23, 3, v73
	v_and_b32_e32 v23, 2, v23
	v_lshrrev_b32_e32 v38, 12, v73
	v_lshrrev_b32_e32 v49, 15, v73
	v_lshrrev_b32_e32 v72, 1, v62
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v23, -1, v23
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v22, v22
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v24, v12, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v24, 4, v73
	v_and_b32_e32 v24, 2, v24
	v_and_b32_e32 v38, 2, v38
	v_and_b32_e32 v49, 2, v49
	v_and_b32_e32 v72, 2, v72
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v24, -1, v24
	v_add_u32_e32 v19, -1, v19
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v25, v12, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v25, 5, v73
	v_and_b32_e32 v25, 2, v25
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v25, -1, v25
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v23, v23
	.loc	1 272 17                        ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v38, -1, v38
	v_add_u32_e32 v49, -1, v49
	v_add_u32_e32 v72, -1, v72
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v20, v12, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshlrev_b32_e32 v20, 1, v73
	v_and_b32_e32 v20, 2, v20
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v20, -1, v20
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v20, v20
	v_cvt_f32_i32_e32 v24, v24
	v_cvt_f32_i32_e32 v25, v25
	v_cvt_f32_i32_e32 v19, v19
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v12, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v21, 1, v73
	v_and_b32_e32 v21, 2, v21
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v21, -1, v21
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v21, v21
	v_cvt_f32_i32_e32 v38, v38
	v_cvt_f32_i32_e32 v49, v49
	v_cvt_f32_i32_e32 v72, v72
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v14, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v26, 6, v73
	v_and_b32_e32 v26, 2, v26
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v26, -1, v26
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v26, v26
	s_movk_i32 s2, 0x100
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v14, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v27, 7, v73
	v_and_b32_e32 v27, 2, v27
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v27, -1, v27
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v27, v27
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v54, v14, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v54, v73, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v54, -1, v54
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v54, v54
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v55, v14, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v55, 17, v73
	v_and_b32_e32 v55, 2, v55
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v55, -1, v55
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v55, v55
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v56, v16, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v56, 18, v73
	v_and_b32_e32 v56, 2, v56
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v56, -1, v56
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v56, v56
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v57, v16, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v57, 19, v73
	v_and_b32_e32 v57, 2, v57
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v57, -1, v57
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v57, v57
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v44, v16, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v44, 13, v73
	v_and_b32_e32 v44, 2, v44
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v44, -1, v44
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v44, v44
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v45, v16, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v45, 14, v73
	v_and_b32_e32 v45, 2, v45
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v45, -1, v45
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v45, v45
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v58, v11, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v58, 20, v73
	v_and_b32_e32 v58, 2, v58
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v58, -1, v58
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v58, v58
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v59, v11, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v59, 21, v73
	v_and_b32_e32 v59, 2, v59
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v59, -1, v59
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v59, v59
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v64, v11, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v64, v73, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v64, -1, v64
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v64, v64
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v65, v11, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v65, 25, v73
	v_and_b32_e32 v65, 2, v65
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v65, -1, v65
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v65, v65
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v66, v13, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v66, 26, v73
	v_and_b32_e32 v66, 2, v66
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v66, -1, v66
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v66, v66
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v67, v13, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v67, 27, v73
	v_and_b32_e32 v67, 2, v67
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v67, -1, v67
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v67, v67
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v60, v13, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v60, 22, v73
	v_and_b32_e32 v60, 2, v60
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v60, -1, v60
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v60, v60
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v61, v13, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v61, 23, v73
	v_and_b32_e32 v61, 2, v61
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v61, -1, v61
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v61, v61
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v68, v15, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v68, 28, v73
	v_and_b32_e32 v68, 2, v68
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v68, -1, v68
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v68, v68
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v69, v15, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v69, 29, v73
	v_and_b32_e32 v69, 2, v69
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v69, -1, v69
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v69, v69
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v74, v15, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v74, 3, v62
	v_and_b32_e32 v74, 2, v74
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v74, -1, v74
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v74, v74
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v75, v15, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v75, 4, v62
	v_and_b32_e32 v75, 2, v75
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v75, -1, v75
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v75, v75
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v76, v17, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v76, 5, v62
	v_and_b32_e32 v76, 2, v76
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v76, -1, v76
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v76, v76
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v77, v17, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v77, 6, v62
	v_and_b32_e32 v77, 2, v77
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v77, -1, v77
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v77, v77
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v70, v17, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v70, 30, v73
	v_and_b32_e32 v70, 2, v70
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v70, -1, v70
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v70, v70
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v71, v17, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshlrev_b32_e32 v71, 1, v62
	v_and_b32_e32 v71, 2, v71
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v71, -1, v71
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v71, v71
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[12:15], v78, v2, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v78, 7, v62
	v_and_b32_e32 v78, 2, v78
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v78, -1, v78
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v78, v78
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v79, v2, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v79, 8, v62
	v_and_b32_e32 v79, 2, v79
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v79, -1, v79
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v79, v79
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(13)
	v_mfma_f32_16x16x4_f32 a[8:11], v82, v2, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v82, 11, v62
	v_and_b32_e32 v82, 2, v82
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v82, -1, v82
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v82, v82
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v83, v2, a[0:3]
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	v_add_u32_e32 v2, s12, v33
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v33, 11, v73
	v_lshrrev_b32_e32 v83, 12, v62
	v_and_b32_e32 v33, 2, v33
	v_and_b32_e32 v83, 2, v83
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v33, -1, v33
	v_add_u32_e32 v83, -1, v83
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(12)
	v_mfma_f32_16x16x4_f32 a[12:15], v84, v4, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v84, 13, v62
	v_and_b32_e32 v84, 2, v84
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v84, -1, v84
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v33, v33
	v_cvt_f32_i32_e32 v83, v83
	v_cvt_f32_i32_e32 v84, v84
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v85, v4, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v85, 14, v62
	v_and_b32_e32 v85, 2, v85
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v85, -1, v85
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v85, v85
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v80, v4, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v80, 9, v62
	v_and_b32_e32 v80, 2, v80
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v80, -1, v80
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v80, v80
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v4, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v81, 10, v62
	v_and_b32_e32 v81, 2, v81
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v81, -1, v81
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v81, v81
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_16x16x4_f32 a[12:15], v86, v6, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v86, 15, v62
	v_and_b32_e32 v86, 2, v86
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v86, -1, v86
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v86, v86
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v87, v6, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_and_b32_sdwa v87, v62, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
	v_and_b32_sdwa v63, v62, v63 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:BYTE_3 src1_sel:DWORD
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v87, -1, v87
	v_add_u32_e32 v63, -1, v63
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v87, v87
	v_cvt_f32_i32_e32 v63, v63
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(9)
	v_mfma_f32_16x16x4_f32 a[8:11], v90, v6, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v90, 19, v62
	v_and_b32_e32 v90, 2, v90
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v90, -1, v90
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v90, v90
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v91, v6, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v91, 20, v62
	v_and_b32_e32 v91, 2, v91
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v91, -1, v91
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v91, v91
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(8)
	v_mfma_f32_16x16x4_f32 a[12:15], v92, v8, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v92, 21, v62
	v_and_b32_e32 v92, 2, v92
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v92, -1, v92
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v92, v92
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v93, v8, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v93, 22, v62
	v_and_b32_e32 v93, 2, v93
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v93, -1, v93
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v93, v93
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[8:11], v88, v8, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v88, 17, v62
	v_and_b32_e32 v88, 2, v88
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v88, -1, v88
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v88, v88
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v89, v8, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v89, 18, v62
	v_and_b32_e32 v89, 2, v89
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v89, -1, v89
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v89, v89
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x4_f32 a[12:15], v94, v3, a[12:15]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v94, 23, v62
	v_and_b32_e32 v94, 2, v94
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v94, -1, v94
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v94, v94
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v95, v3, a[4:7]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v95, 25, v62
	v_and_b32_e32 v95, 2, v95
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v95, -1, v95
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v95, v95
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x4_f32 a[8:11], v98, v3, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v98, 28, v62
	v_and_b32_e32 v98, 2, v98
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v98, -1, v98
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v98, v98
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v99, v3, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v99, 29, v62
	v_and_b32_e32 v99, 2, v99
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v99, -1, v99
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v99, v99
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x4_f32 a[12:15], v100, v5, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v101, v5, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v96, v5, a[8:11]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v96, 26, v62
	v_and_b32_e32 v96, 2, v96
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v96, -1, v96
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v96, v96
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[0:3], v97, v5, a[0:3]
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v97, 27, v62
	v_and_b32_e32 v97, 2, v97
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v97, -1, v97
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v97, v97
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 a[12:15], v102, v7, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v103, v7, a[4:7]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[8:11], v106, v7, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v107, v7, a[0:3]
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	ds_read2_b32 v[10:11], v2 offset1:16
	ds_read2_b32 v[6:7], v2 offset0:32 offset1:48
	v_add_u32_e32 v2, s12, v32
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v32, 10, v73
	v_and_b32_e32 v32, 2, v32
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v32, -1, v32
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v32, v32
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 a[12:15], v108, v9, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v109, v9, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v104, v9, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v105, v9, a[0:3]
	.loc	1 264 20                        ; binary_gemm_kernel.py:264:20
	ds_read2_b32 v[12:13], v2 offset1:16
	ds_read2_b32 v[8:9], v2 offset0:32 offset1:48
	v_add_u32_e32 v2, s12, v31
	ds_read2_b32 v[14:15], v2 offset1:16
	ds_read2_b32 v[4:5], v2 offset0:32 offset1:48
	v_add_u32_e32 v2, s12, v30
	.loc	1 272 15                        ; binary_gemm_kernel.py:272:15
	v_lshrrev_b32_e32 v30, 8, v73
	v_lshrrev_b32_e32 v31, 9, v73
	v_lshrrev_b32_e32 v73, 2, v62
	v_lshrrev_b32_e32 v62, 30, v62
	v_and_b32_e32 v30, 2, v30
	v_and_b32_e32 v31, 2, v31
	v_and_b32_e32 v73, 2, v73
	v_and_b32_e32 v62, 2, v62
	.loc	1 272 17 is_stmt 0              ; binary_gemm_kernel.py:272:17
	v_add_u32_e32 v30, -1, v30
	v_add_u32_e32 v31, -1, v31
	v_add_u32_e32 v73, -1, v73
	v_add_u32_e32 v62, -1, v62
	.loc	1 264 20 is_stmt 1              ; binary_gemm_kernel.py:264:20
	ds_read2_b32 v[16:17], v2 offset1:16
	ds_read2_b32 v[2:3], v2 offset0:32 offset1:48
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	v_cvt_f32_i32_e32 v30, v30
	v_cvt_f32_i32_e32 v31, v31
	v_cvt_f32_i32_e32 v73, v73
	v_cvt_f32_i32_e32 v62, v62
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write2st64_b32 v29, v20, v18 offset1:4
	ds_write_b32 v34, v22
	ds_write2st64_b32 v29, v21, v23 offset0:8 offset1:16
	ds_write2st64_b32 v29, v24, v25 offset0:20 offset1:24
	ds_write_b32 v35, v26
	ds_write2st64_b32 v29, v27, v30 offset0:32 offset1:36
	ds_write_b32 v36, v32
	ds_write2st64_b32 v29, v31, v33 offset0:40 offset1:48
	ds_write2st64_b32 v29, v38, v44 offset0:52 offset1:56
	ds_write_b32 v37, v45
	ds_write2st64_b32 v29, v49, v54 offset0:64 offset1:68
	ds_write_b32 v39, v56
	ds_write2st64_b32 v29, v55, v57 offset0:72 offset1:80
	ds_write2st64_b32 v29, v58, v59 offset0:84 offset1:88
	ds_write_b32 v40, v60
	ds_write2st64_b32 v29, v61, v64 offset0:96 offset1:100
	ds_write_b32 v41, v66
	ds_write2st64_b32 v29, v65, v67 offset0:104 offset1:112
	ds_write2st64_b32 v29, v68, v69 offset0:116 offset1:120
	ds_write_b32 v42, v70
	ds_write2st64_b32 v29, v71, v19 offset0:128 offset1:132
	ds_write_b32 v43, v73
	ds_write2st64_b32 v29, v72, v74 offset0:136 offset1:144
	ds_write2st64_b32 v29, v75, v76 offset0:148 offset1:152
	ds_write_b32 v46, v77
	ds_write2st64_b32 v29, v78, v79 offset0:160 offset1:164
	ds_write_b32 v47, v81
	ds_write2st64_b32 v29, v80, v82 offset0:168 offset1:176
	ds_write2st64_b32 v29, v83, v84 offset0:180 offset1:184
	ds_write_b32 v48, v85
	ds_write2st64_b32 v29, v86, v87 offset0:192 offset1:196
	ds_write_b32 v50, v89
	ds_write2st64_b32 v29, v88, v90 offset0:200 offset1:208
	ds_write2st64_b32 v29, v91, v92 offset0:212 offset1:216
	ds_write_b32 v51, v93
	ds_write2st64_b32 v29, v94, v63 offset0:224 offset1:228
	ds_write_b32 v52, v96
	ds_write2st64_b32 v29, v95, v97 offset0:232 offset1:240
	ds_write2st64_b32 v29, v98, v99 offset0:244 offset1:248
	ds_write_b32 v53, v62
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[18:19], v28 offset1:1
	ds_read2st64_b32 v[20:21], v28 offset0:18 offset1:19
	ds_read2st64_b32 v[22:23], v28 offset0:2 offset1:3
	ds_read2st64_b32 v[24:25], v28 offset0:16 offset1:17
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 a[12:15], v18, v10, a[12:15]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[26:27], v28 offset0:32 offset1:33
	ds_read2st64_b32 v[30:31], v28 offset0:50 offset1:51
	ds_read2st64_b32 v[32:33], v28 offset0:34 offset1:35
	ds_read2st64_b32 v[34:35], v28 offset0:48 offset1:49
	ds_read2st64_b32 v[36:37], v28 offset0:64 offset1:65
	ds_read2st64_b32 v[38:39], v28 offset0:82 offset1:83
	ds_read2st64_b32 v[40:41], v28 offset0:66 offset1:67
	ds_read2st64_b32 v[42:43], v28 offset0:80 offset1:81
	ds_read2st64_b32 v[44:45], v28 offset0:96 offset1:97
	ds_read2st64_b32 v[46:47], v28 offset0:114 offset1:115
	ds_read2st64_b32 v[48:49], v28 offset0:98 offset1:99
	ds_read2st64_b32 v[50:51], v28 offset0:112 offset1:113
	ds_read2st64_b32 v[52:53], v28 offset0:128 offset1:129
	ds_read2st64_b32 v[54:55], v28 offset0:146 offset1:147
	ds_read2st64_b32 v[56:57], v28 offset0:130 offset1:131
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v19, v10, a[4:7]
	.loc	1 272 23                        ; binary_gemm_kernel.py:272:23
	ds_read2st64_b32 v[58:59], v28 offset0:144 offset1:145
	ds_read2st64_b32 v[60:61], v28 offset0:160 offset1:161
	ds_read2st64_b32 v[62:63], v28 offset0:178 offset1:179
	ds_read2st64_b32 v[64:65], v28 offset0:162 offset1:163
	ds_read2st64_b32 v[66:67], v28 offset0:176 offset1:177
	ds_read2st64_b32 v[68:69], v28 offset0:192 offset1:193
	ds_read2st64_b32 v[70:71], v28 offset0:210 offset1:211
	ds_read2st64_b32 v[72:73], v28 offset0:194 offset1:195
	ds_read2st64_b32 v[74:75], v28 offset0:208 offset1:209
	ds_read2st64_b32 v[76:77], v28 offset0:224 offset1:225
	ds_read2st64_b32 v[78:79], v28 offset0:242 offset1:243
	ds_read2st64_b32 v[80:81], v28 offset0:226 offset1:227
	ds_read2st64_b32 v[28:29], v28 offset0:240 offset1:241
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 a[12:15], v24, v12, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v25, v12, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v26, v14, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v27, v14, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v34, v16, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v35, v16, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v36, v11, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v37, v11, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v42, v13, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v43, v13, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v44, v15, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v45, v15, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v50, v17, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v51, v17, a[4:7]
	v_mfma_f32_16x16x4_f32 a[12:15], v52, v6, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v53, v6, a[4:7]
	s_waitcnt lgkmcnt(12)
	v_mfma_f32_16x16x4_f32 a[12:15], v58, v8, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v59, v8, a[4:7]
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_16x16x4_f32 a[12:15], v60, v4, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v61, v4, a[4:7]
	s_waitcnt lgkmcnt(8)
	v_mfma_f32_16x16x4_f32 a[12:15], v66, v2, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v67, v2, a[4:7]
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x4_f32 a[12:15], v68, v7, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v69, v7, a[4:7]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x4_f32 a[12:15], v74, v9, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v75, v9, a[4:7]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 a[12:15], v76, v5, a[12:15]
	v_mfma_f32_16x16x4_f32 a[4:7], v77, v5, a[4:7]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[16:19], v28, v3, a[12:15]
	v_mfma_f32_16x16x4_f32 a[12:15], v29, v3, a[4:7]
	v_mfma_f32_16x16x4_f32 a[4:7], v22, v10, a[8:11]
	v_mfma_f32_16x16x4_f32 a[0:3], v23, v10, a[0:3]
	.loc	1 243 51                        ; binary_gemm_kernel.py:243:51
	v_lshrrev_b32_e32 v10, 2, v0
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	s_nop 5
	v_accvgpr_read_b32 v0, a17
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v20, v12, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v21, v12, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v32, v14, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v33, v14, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v30, v16, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v31, v16, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v40, v11, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v41, v11, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v38, v13, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v39, v13, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v48, v15, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v49, v15, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v46, v17, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v47, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v56, v6, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v57, v6, a[0:3]
	.loc	1 243 38                        ; binary_gemm_kernel.py:243:38
	v_and_or_b32 v6, v10, 60, s10
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v6
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v54, v8, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v55, v8, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v64, v4, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v65, v4, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v62, v2, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v63, v2, a[0:3]
	.loc	1 242 38                        ; binary_gemm_kernel.py:242:38
	v_or_b32_e32 v2, s11, v1
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_accvgpr_read_b32 v1, a16
	v_cvt_pk_f16_f32 v11, v1, v0
	.loc	1 293 33                        ; binary_gemm_kernel.py:293:33
	v_lshlrev_b32_e32 v0, 8, v2
	.loc	1 293 21 is_stmt 0              ; binary_gemm_kernel.py:293:21
	v_ashrrev_i32_e32 v1, 31, v0
	.loc	1 294 33 is_stmt 1              ; binary_gemm_kernel.py:294:33
	v_cmp_gt_i32_e32 vcc, s2, v2
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], vcc, s[0:1]
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v72, v7, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v73, v7, a[0:3]
	.loc	1 293 52                        ; binary_gemm_kernel.py:293:52
	v_ashrrev_i32_e32 v7, 31, v6
	.loc	1 278 33                        ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v70, v9, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v71, v9, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v80, v5, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v81, v5, a[0:3]
	.loc	1 293 21                        ; binary_gemm_kernel.py:293:21
	v_lshl_add_u64 v[4:5], v[0:1], 2, s[6:7]
	.loc	1 293 52 is_stmt 0              ; binary_gemm_kernel.py:293:52
	v_lshl_add_u64 v[0:1], v[6:7], 2, v[4:5]
	.loc	1 293 83                        ; binary_gemm_kernel.py:293:83
	v_lshl_add_u64 v[8:9], s[8:9], 2, v[0:1]
	.loc	1 278 33 is_stmt 1              ; binary_gemm_kernel.py:278:33
	v_mfma_f32_16x16x4_f32 a[4:7], v78, v3, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v79, v3, a[0:3]
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	v_cvt_f32_f16_e32 v0, v11
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	global_store_dword v[8:9], v0, off
.LBB0_4:
	.loc	1 0 21                          ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	v_accvgpr_read_b32 v0, a16
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, 1, v6
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 0 0 is_stmt 0                 ; binary_gemm_kernel.py:0
	v_accvgpr_read_b32 v2, a18
	v_accvgpr_read_b32 v3, a19
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 0 0                           ; binary_gemm_kernel.py:0
	v_accvgpr_read_b32 v1, a17
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_6
; %bb.5:
	v_cvt_f32_f16_sdwa v0, v11 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v0, off offset:4
.LBB0_6:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, 2, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v7, v2, v3
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_8
; %bb.7:
	v_cvt_f32_f16_e32 v0, v7
	global_store_dword v[8:9], v0, off offset:8
.LBB0_8:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v11, 3, v6
	v_accvgpr_read_b32 v0, a12
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v11
	v_accvgpr_read_b32 v1, a13
	v_accvgpr_read_b32 v2, a14
	v_accvgpr_read_b32 v3, a15
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_10
; %bb.9:
	v_cvt_f32_f16_sdwa v7, v7 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v7, off offset:12
.LBB0_10:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v7, 64, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v7
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v0, v0, v1
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_12
; %bb.11:
	v_cvt_f32_f16_e32 v1, v0
	global_store_dword v[8:9], v1, off offset:256
.LBB0_12:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v1, 0x41, v6
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v1
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_14
; %bb.13:
	v_cvt_f32_f16_sdwa v0, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v0, off offset:260
.LBB0_14:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, 0x42, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v7, v2, v3
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_16
; %bb.15:
	v_cvt_f32_f16_e32 v0, v7
	global_store_dword v[8:9], v0, off offset:264
.LBB0_16:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v11, 0x43, v6
	v_accvgpr_read_b32 v0, a4
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v11
	v_accvgpr_read_b32 v1, a5
	v_accvgpr_read_b32 v2, a6
	v_accvgpr_read_b32 v3, a7
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_18
; %bb.17:
	v_cvt_f32_f16_sdwa v7, v7 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v7, off offset:268
.LBB0_18:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v7, 0x80, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v7
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v0, v0, v1
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_20
; %bb.19:
	v_cvt_f32_f16_e32 v1, v0
	global_store_dword v[8:9], v1, off offset:512
.LBB0_20:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v1, 0x81, v6
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v1
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_22
; %bb.21:
	v_cvt_f32_f16_sdwa v0, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v0, off offset:516
.LBB0_22:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, 0x82, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v7, v2, v3
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_24
; %bb.23:
	v_cvt_f32_f16_e32 v0, v7
	global_store_dword v[8:9], v0, off offset:520
.LBB0_24:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v11, 0x83, v6
	v_accvgpr_read_b32 v0, a0
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v11
	v_accvgpr_read_b32 v1, a1
	v_accvgpr_read_b32 v2, a2
	v_accvgpr_read_b32 v3, a3
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_26
; %bb.25:
	v_cvt_f32_f16_sdwa v7, v7 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v7, off offset:524
.LBB0_26:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v7, 0xc0, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v7
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v0, v0, v1
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_28
; %bb.27:
	v_cvt_f32_f16_e32 v1, v0
	global_store_dword v[8:9], v1, off offset:768
.LBB0_28:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v1, 0xc1, v6
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v1
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_30
; %bb.29:
	v_cvt_f32_f16_sdwa v0, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[8:9], v0, off offset:772
.LBB0_30:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, 0xc2, v6
	s_movk_i32 s2, 0x100
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 287 23                        ; binary_gemm_kernel.py:287:23
	v_cvt_pk_f16_f32 v1, v2, v3
	.loc	1 294 39                        ; binary_gemm_kernel.py:294:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 295 21                        ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_32
; %bb.31:
	v_cvt_f32_f16_e32 v0, v1
	global_store_dword v[8:9], v0, off offset:776
.LBB0_32:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 243 38 is_stmt 1              ; binary_gemm_kernel.py:243:38
	v_or_b32_e32 v0, s10, v10
	v_or_b32_e32 v0, 0xc3, v0
	.loc	1 294 58                        ; binary_gemm_kernel.py:294:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 294 39 is_stmt 0              ; binary_gemm_kernel.py:294:39
	s_and_b64 s[0:1], vcc, s[0:1]
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_34
; %bb.33:
	v_cvt_f32_f16_sdwa v2, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	.loc	1 293 52                        ; binary_gemm_kernel.py:293:52
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[4:5]
	.loc	1 293 83 is_stmt 0              ; binary_gemm_kernel.py:293:83
	v_lshl_add_u64 v[0:1], s[8:9], 2, v[0:1]
	.loc	1 295 21 is_stmt 1              ; binary_gemm_kernel.py:295:21
	global_store_dword v[0:1], v2, off
.LBB0_34:
	.loc	1 295 4 is_stmt 0               ; binary_gemm_kernel.py:295:4
	s_endpgm
.Ltmp2:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel binary_bmm_kernel
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
		.amdhsa_next_free_vgpr 132
		.amdhsa_next_free_sgpr 15
		.amdhsa_accum_offset 112
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
	.size	binary_bmm_kernel, .Lfunc_end0-binary_bmm_kernel
	.cfi_endproc
                                        ; -- End function
	.set binary_bmm_kernel.num_vgpr, 110
	.set binary_bmm_kernel.num_agpr, 20
	.set binary_bmm_kernel.numbered_sgpr, 15
	.set binary_bmm_kernel.private_seg_size, 0
	.set binary_bmm_kernel.uses_vcc, 1
	.set binary_bmm_kernel.uses_flat_scratch, 0
	.set binary_bmm_kernel.has_dyn_sized_stack, 0
	.set binary_bmm_kernel.has_recursion, 0
	.set binary_bmm_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 9580
; TotalNumSgprs: 21
; NumVgprs: 110
; NumAgprs: 20
; TotalNumVgprs: 132
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 16
; NumSGPRsForWavesPerEU: 21
; NumVGPRsForWavesPerEU: 132
; AccumOffset: 112
; Occupancy: 3
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 12
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 27
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
	.asciz	"binary_gemm_kernel.py"         ; string offset=7
.Linfo_string2:
	.asciz	"/work/external/amd/triton/../../bitwise/bitdelta_triton/upstream" ; string offset=29
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     20
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
    .name:           binary_bmm_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     21
    .sgpr_spill_count: 0
    .symbol:         binary_bmm_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     132
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
