	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	binary_matmul_kernel            ; -- Begin function binary_matmul_kernel
	.p2align	8
	.type	binary_matmul_kernel,@function
binary_matmul_kernel:                   ; @binary_matmul_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.19:
	.file	1 "/work/external/amd/triton/../../bitwise/bitdelta_triton/upstream" "binary_gemm_kernel.py"
	.loc	1 58 0 prologue_end             ; binary_gemm_kernel.py:58:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.20:
.LBB0_0:
.Ltmp1:
	.loc	1 88 22 is_stmt 1               ; binary_gemm_kernel.py:88:22
	s_ashr_i32 s0, s12, 31
	s_lshr_b32 s1, s0, 29
	s_add_i32 s1, s12, s1
	.loc	1 89 29                         ; binary_gemm_kernel.py:89:29
	s_and_b32 s1, s1, -8
	.loc	1 90 35                         ; binary_gemm_kernel.py:90:35
	s_sub_i32 s8, 16, s1
	.loc	1 90 48 is_stmt 0               ; binary_gemm_kernel.py:90:48
	s_min_i32 s8, s8, 8
	.loc	1 91 33 is_stmt 1               ; binary_gemm_kernel.py:91:33
	s_abs_i32 s9, s8
	v_cvt_f32_u32_e32 v1, s9
	s_sub_i32 s11, 0, s9
	s_abs_i32 s10, s12
	.loc	1 104 60                        ; binary_gemm_kernel.py:104:60
	v_and_b32_e32 v4, 63, v0
	.loc	1 91 33                         ; binary_gemm_kernel.py:91:33
	v_rcp_iflag_f32_e32 v1, v1
	.loc	1 101 51                        ; binary_gemm_kernel.py:101:51
	v_and_b32_e32 v12, 0x1c0, v0
	v_and_b32_e32 v13, 48, v0
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_lshlrev_b32_e32 v48, 2, v0
	.loc	1 91 33                         ; binary_gemm_kernel.py:91:33
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_lshrrev_b32_e32 v14, 4, v12
	v_lshrrev_b32_e32 v17, 2, v13
	v_xor_b32_e32 v52, v48, v14
	.loc	1 91 33                         ; binary_gemm_kernel.py:91:33
	v_readfirstlane_b32 s13, v1
	s_mul_i32 s11, s11, s13
	s_mul_hi_u32 s11, s13, s11
	s_add_i32 s13, s13, s11
	s_mul_hi_u32 s11, s10, s13
	s_mul_i32 s11, s11, s9
	s_sub_i32 s10, s10, s11
	s_sub_i32 s11, s10, s9
	s_cmp_ge_u32 s10, s9
	s_cselect_b32 s10, s11, s10
	s_sub_i32 s11, s10, s9
	s_cmp_ge_u32 s10, s9
	s_cselect_b32 s10, s11, s10
	s_xor_b32 s10, s10, s0
	.loc	1 92 19                         ; binary_gemm_kernel.py:92:19
	s_sub_i32 s11, s12, s1
	.loc	1 91 33                         ; binary_gemm_kernel.py:91:33
	s_sub_i32 s0, s10, s0
	.loc	1 91 27 is_stmt 0               ; binary_gemm_kernel.py:91:27
	s_add_i32 s0, s0, s1
	.loc	1 92 40 is_stmt 1               ; binary_gemm_kernel.py:92:40
	s_abs_i32 s1, s11
	s_mul_hi_u32 s10, s1, s13
	s_xor_b32 s8, s11, s8
	s_mul_i32 s11, s10, s9
	s_sub_i32 s1, s1, s11
	s_ashr_i32 s8, s8, 31
	s_add_i32 s11, s10, 1
	s_sub_i32 s12, s1, s9
	s_cmp_ge_u32 s1, s9
	s_cselect_b32 s10, s11, s10
	s_cselect_b32 s1, s12, s1
	s_add_i32 s11, s10, 1
	s_cmp_ge_u32 s1, s9
	s_cselect_b32 s1, s11, s10
	.loc	1 101 23                        ; binary_gemm_kernel.py:101:23
	s_lshl_b32 s9, s0, 4
	.loc	1 101 51 is_stmt 0              ; binary_gemm_kernel.py:101:51
	v_lshrrev_b32_e32 v1, 6, v0
	.loc	1 101 68                        ; binary_gemm_kernel.py:101:68
	s_bfe_i32 s0, s0, 0x1001b
	.loc	1 101 38                        ; binary_gemm_kernel.py:101:38
	v_or_b32_e32 v1, s9, v1
	.loc	1 101 68                        ; binary_gemm_kernel.py:101:68
	s_lshr_b32 s0, s0, 24
	v_add_u32_e32 v3, s0, v1
	.loc	1 101 38                        ; binary_gemm_kernel.py:101:38
	v_or_b32_e32 v2, 8, v1
	.loc	1 101 68                        ; binary_gemm_kernel.py:101:68
	v_and_b32_e32 v3, 0xffff00, v3
	v_sub_u32_e32 v1, v1, v3
	v_add_u32_e32 v3, s0, v2
	.loc	1 92 40 is_stmt 1               ; binary_gemm_kernel.py:92:40
	s_xor_b32 s0, s1, s8
	s_sub_i32 s0, s0, s8
	.loc	1 102 23                        ; binary_gemm_kernel.py:102:23
	s_lshl_b32 s8, s0, 8
	.loc	1 102 68 is_stmt 0              ; binary_gemm_kernel.py:102:68
	s_bfe_i32 s0, s0, 0x10017
	.loc	1 102 38                        ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v6, s8, v0
	.loc	1 102 68                        ; binary_gemm_kernel.py:102:68
	s_lshr_b32 s0, s0, 24
	v_add_u32_e32 v7, s0, v6
	.loc	1 101 68 is_stmt 1              ; binary_gemm_kernel.py:101:68
	v_and_b32_e32 v3, 0xffff00, v3
	.loc	1 102 68                        ; binary_gemm_kernel.py:102:68
	v_and_b32_e32 v7, 0xffffff00, v7
	.loc	1 101 68                        ; binary_gemm_kernel.py:101:68
	v_sub_u32_e32 v3, v2, v3
	.loc	1 104 53                        ; binary_gemm_kernel.py:104:53
	v_lshl_or_b32 v2, v1, 8, v4
	.loc	1 102 68                        ; binary_gemm_kernel.py:102:68
	v_sub_u32_e32 v6, v6, v7
	.loc	1 104 53                        ; binary_gemm_kernel.py:104:53
	v_lshl_or_b32 v4, v3, 8, v4
	.loc	1 104 22 is_stmt 0              ; binary_gemm_kernel.py:104:22
	v_ashrrev_i32_e32 v3, 31, v2
	.loc	1 109 22 is_stmt 1              ; binary_gemm_kernel.py:109:22
	v_ashrrev_i32_e32 v7, 31, v6
	.loc	1 104 22                        ; binary_gemm_kernel.py:104:22
	v_ashrrev_i32_e32 v5, 31, v4
	.loc	1 119 22                        ; binary_gemm_kernel.py:119:22
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[2:3]
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[4:5]
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	global_load_dword v8, v[2:3], off
	global_load_dword v9, v[4:5], off
	global_load_dword v10, v[4:5], off offset:256
	global_load_dword v11, v[2:3], off offset:256
	.loc	1 124 20                        ; binary_gemm_kernel.py:124:20
	global_load_dword v82, v[6:7], off
	global_load_dword v81, v[6:7], off offset:1024
	global_load_dword v23, v[6:7], off offset:2048
	global_load_dword v22, v[6:7], off offset:3072
	.loc	1 101 51                        ; binary_gemm_kernel.py:101:51
	v_and_b32_e32 v1, 15, v0
	v_lshlrev_b32_e32 v16, 2, v1
	v_lshlrev_b32_e32 v15, 8, v1
	v_xor_b32_e32 v14, v16, v17
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	s_add_i32 s12, 0, 0x10000
	s_add_i32 s10, 0, 0x11000
	v_bitop3_b32 v42, v16, v15, v17 bitop3:0xde
	v_xor_b32_e32 v53, 32, v52
	v_bitop3_b32 v41, v14, 16, v15 bitop3:0x36
	v_bitop3_b32 v40, v14, 32, v15 bitop3:0x36
	v_bitop3_b32 v39, v14, 48, v15 bitop3:0x36
	v_add_u32_e32 v14, s12, v52
	v_add_u32_e32 v17, s10, v52
	s_mov_b64 s[0:1], 0x1400
	.loc	1 103 26                        ; binary_gemm_kernel.py:103:26
	v_lshrrev_b32_e32 v21, 8, v0
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v15, s12, v53
	v_add_u32_e32 v18, s10, v53
	s_mov_b32 s11, 1
	.loc	1 103 26                        ; binary_gemm_kernel.py:103:26
	v_or_b32_e32 v24, 2, v21
	v_or_b32_e32 v25, 4, v21
	v_or_b32_e32 v26, 6, v21
	v_or_b32_e32 v27, 8, v21
	v_or_b32_e32 v28, 10, v21
	v_or_b32_e32 v29, 12, v21
	v_or_b32_e32 v30, 14, v21
	v_or_b32_e32 v31, 16, v21
	v_or_b32_e32 v32, 18, v21
	v_or_b32_e32 v33, 20, v21
	v_or_b32_e32 v34, 22, v21
	v_or_b32_e32 v35, 24, v21
	v_or_b32_e32 v36, 26, v21
	v_or_b32_e32 v37, 28, v21
	v_or_b32_e32 v38, 30, v21
	v_or_b32_e32 v51, 0x800, v48
	v_or_b32_e32 v54, 0x1800, v48
	v_or_b32_e32 v55, 0x2800, v48
	v_or_b32_e32 v56, 0x3800, v48
	v_or_b32_e32 v57, 0x4800, v48
	v_or_b32_e32 v58, 0x5800, v48
	v_or_b32_e32 v59, 0x6800, v48
	v_or_b32_e32 v60, 0x7800, v48
	v_or_b32_e32 v61, 0x8800, v48
	v_or_b32_e32 v62, 0x9800, v48
	v_or_b32_e32 v63, 0xa800, v48
	v_or_b32_e32 v64, 0xb800, v48
	v_or_b32_e32 v65, 0xc800, v48
	v_or_b32_e32 v66, 0xd800, v48
	v_or_b32_e32 v67, 0xe800, v48
	v_or_b32_e32 v68, 0xf800, v48
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	s_waitcnt vmcnt(7)
	ds_write_b32 v14, v8
	s_waitcnt vmcnt(6)
	ds_write_b32 v15, v9 offset:2048
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(4)
	ds_write_b32 v17, v11
	ds_write_b32 v18, v10 offset:2048
	v_lshl_add_u32 v8, v13, 6, 0
	.loc	1 119 22                        ; binary_gemm_kernel.py:119:22
	v_lshl_add_u64 v[10:11], v[6:7], 0, s[0:1]
	s_mov_b64 s[0:1], 0x200
	v_mov_b32_e32 v6, 0
	v_add3_u32 v20, v8, v16, v12
	v_lshl_add_u64 v[12:13], v[4:5], 0, s[0:1]
	v_lshl_add_u64 v[14:15], v[2:3], 0, s[0:1]
	s_mov_b64 s[4:5], -1
	s_mov_b64 s[0:1], 0x800
	s_mov_b64 s[2:3], 0x100
	v_mov_b32_e32 v7, v6
	v_mov_b32_e32 v8, v6
	v_mov_b32_e32 v9, v6
	v_mov_b32_e32 v2, v6
	v_mov_b32_e32 v3, v6
	v_mov_b32_e32 v4, v6
	v_mov_b32_e32 v5, v6
.LBB0_1:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 0 22 is_stmt 0                ; binary_gemm_kernel.py:0:22
	s_waitcnt vmcnt(3)
	v_mov_b32_e32 v16, v82
	.loc	1 128 18 is_stmt 1              ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v17, v21, v16
	v_lshrrev_b32_e32 v18, v25, v16
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v19, s12, v42
	v_add_u32_e32 v90, s12, v41
	v_add_u32_e32 v94, s12, v40
	v_add_u32_e32 v96, s12, v39
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v125, 1, v17
	v_lshlrev_b32_e32 v126, 1, v18
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	global_load_dword v70, v[14:15], off
	global_load_dword v71, v[12:13], off
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(4)
	v_mov_b32_e32 v83, v81
	s_waitcnt vmcnt(3)
	v_mov_b32_e32 v82, v23
	s_waitcnt vmcnt(2)
	v_mov_b32_e32 v81, v22
	.loc	1 124 20                        ; binary_gemm_kernel.py:124:20
	global_load_dword v23, v[10:11], off offset:-1024
	global_load_dword v22, v[10:11], off
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v97, v27, v16
	v_lshrrev_b32_e32 v98, v29, v16
	v_lshrrev_b32_e32 v99, v31, v16
	v_lshrrev_b32_e32 v100, v33, v16
	v_lshrrev_b32_e32 v101, v35, v16
	v_lshrrev_b32_e32 v102, v37, v16
	v_lshrrev_b32_e32 v111, v24, v16
	v_lshrrev_b32_e32 v112, v26, v16
	v_lshrrev_b32_e32 v113, v28, v16
	v_lshrrev_b32_e32 v114, v30, v16
	v_lshrrev_b32_e32 v115, v32, v16
	v_lshrrev_b32_e32 v116, v34, v16
	v_lshrrev_b32_e32 v117, v36, v16
	v_lshrrev_b32_e32 v118, v38, v16
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	ds_read2_b32 v[84:85], v19 offset1:16
	ds_read2_b32 v[86:87], v19 offset0:32 offset1:48
	ds_read2_b32 v[88:89], v90 offset1:16
	ds_read2_b32 v[90:91], v90 offset0:32 offset1:48
	ds_read2_b32 v[92:93], v94 offset1:16
	ds_read2_b32 v[18:19], v94 offset0:32 offset1:48
	ds_read2_b32 v[94:95], v96 offset1:16
	ds_read2_b32 v[16:17], v96 offset0:32 offset1:48
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v96, 2, v125
	v_and_b32_e32 v125, 2, v126
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v96, -1, v96
	v_add_u32_e32 v125, -1, v125
	v_cvt_f32_i32_e32 v96, v96
	v_cvt_f32_i32_e32 v125, v125
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v97, 1, v97
	v_lshlrev_b32_e32 v98, 1, v98
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v43, 0, v48
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v99, 1, v99
	v_lshlrev_b32_e32 v100, 1, v100
	v_and_b32_e32 v97, 2, v97
	v_and_b32_e32 v98, 2, v98
	.loc	1 128 18 is_stmt 1              ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v103, v21, v83
	v_lshrrev_b32_e32 v104, v25, v83
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_write2st64_b32 v43, v96, v125 offset1:16
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v96, v36, v83
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v101, 1, v101
	v_lshlrev_b32_e32 v102, 1, v102
	v_and_b32_e32 v99, 2, v99
	v_and_b32_e32 v100, 2, v100
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v97, -1, v97
	v_add_u32_e32 v98, -1, v98
	.loc	1 128 18 is_stmt 1              ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v105, v27, v83
	v_lshrrev_b32_e32 v106, v29, v83
	v_lshrrev_b32_e32 v107, v31, v83
	v_lshrrev_b32_e32 v108, v33, v83
	v_lshrrev_b32_e32 v109, v35, v83
	v_lshrrev_b32_e32 v110, v37, v83
	v_lshrrev_b32_e32 v119, v24, v83
	v_lshrrev_b32_e32 v120, v26, v83
	v_lshrrev_b32_e32 v121, v28, v83
	v_lshrrev_b32_e32 v122, v30, v83
	v_lshrrev_b32_e32 v123, v32, v83
	v_lshrrev_b32_e32 v124, v34, v83
	v_lshrrev_b32_e32 v83, v38, v83
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v103, 1, v103
	v_lshlrev_b32_e32 v104, 1, v104
	v_lshlrev_b32_e32 v96, 1, v96
	v_and_b32_e32 v101, 2, v101
	v_and_b32_e32 v102, 2, v102
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v99, -1, v99
	v_add_u32_e32 v100, -1, v100
	v_cvt_f32_i32_e32 v97, v97
	v_cvt_f32_i32_e32 v98, v98
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v105, 1, v105
	v_lshlrev_b32_e32 v106, 1, v106
	v_lshlrev_b32_e32 v107, 1, v107
	v_lshlrev_b32_e32 v108, 1, v108
	v_lshlrev_b32_e32 v109, 1, v109
	v_lshlrev_b32_e32 v110, 1, v110
	v_lshlrev_b32_e32 v111, 1, v111
	v_lshlrev_b32_e32 v112, 1, v112
	v_lshlrev_b32_e32 v113, 1, v113
	v_lshlrev_b32_e32 v114, 1, v114
	v_lshlrev_b32_e32 v115, 1, v115
	v_lshlrev_b32_e32 v116, 1, v116
	v_lshlrev_b32_e32 v117, 1, v117
	v_lshlrev_b32_e32 v118, 1, v118
	v_lshlrev_b32_e32 v119, 1, v119
	v_lshlrev_b32_e32 v120, 1, v120
	v_lshlrev_b32_e32 v121, 1, v121
	v_lshlrev_b32_e32 v122, 1, v122
	v_lshlrev_b32_e32 v123, 1, v123
	v_lshlrev_b32_e32 v124, 1, v124
	v_lshlrev_b32_e32 v83, 1, v83
	v_and_b32_e32 v103, 2, v103
	v_and_b32_e32 v104, 2, v104
	v_and_b32_e32 v96, 2, v96
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v101, -1, v101
	v_add_u32_e32 v102, -1, v102
	v_cvt_f32_i32_e32 v99, v99
	v_cvt_f32_i32_e32 v100, v100
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v105, 2, v105
	v_and_b32_e32 v106, 2, v106
	v_and_b32_e32 v107, 2, v107
	v_and_b32_e32 v108, 2, v108
	v_and_b32_e32 v109, 2, v109
	v_and_b32_e32 v110, 2, v110
	v_and_b32_e32 v111, 2, v111
	v_and_b32_e32 v112, 2, v112
	v_and_b32_e32 v113, 2, v113
	v_and_b32_e32 v114, 2, v114
	v_and_b32_e32 v115, 2, v115
	v_and_b32_e32 v116, 2, v116
	v_and_b32_e32 v117, 2, v117
	v_and_b32_e32 v118, 2, v118
	v_and_b32_e32 v119, 2, v119
	v_and_b32_e32 v120, 2, v120
	v_and_b32_e32 v121, 2, v121
	v_and_b32_e32 v122, 2, v122
	v_and_b32_e32 v123, 2, v123
	v_and_b32_e32 v124, 2, v124
	v_and_b32_e32 v83, 2, v83
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v103, -1, v103
	v_add_u32_e32 v104, -1, v104
	v_add_u32_e32 v96, -1, v96
	v_cvt_f32_i32_e32 v101, v101
	v_cvt_f32_i32_e32 v102, v102
	v_add_u32_e32 v105, -1, v105
	v_add_u32_e32 v106, -1, v106
	v_add_u32_e32 v107, -1, v107
	v_add_u32_e32 v108, -1, v108
	v_add_u32_e32 v109, -1, v109
	v_add_u32_e32 v110, -1, v110
	v_add_u32_e32 v111, -1, v111
	v_add_u32_e32 v112, -1, v112
	v_add_u32_e32 v113, -1, v113
	v_add_u32_e32 v114, -1, v114
	v_add_u32_e32 v115, -1, v115
	v_add_u32_e32 v116, -1, v116
	v_add_u32_e32 v117, -1, v117
	v_add_u32_e32 v118, -1, v118
	v_add_u32_e32 v119, -1, v119
	v_add_u32_e32 v120, -1, v120
	v_add_u32_e32 v121, -1, v121
	v_add_u32_e32 v122, -1, v122
	v_add_u32_e32 v123, -1, v123
	v_add_u32_e32 v124, -1, v124
	v_add_u32_e32 v83, -1, v83
	v_cvt_f32_i32_e32 v103, v103
	v_cvt_f32_i32_e32 v104, v104
	v_cvt_f32_i32_e32 v96, v96
	v_add_u32_e32 v44, 0, v51
	v_add_u32_e32 v45, 0, v54
	v_add_u32_e32 v46, 0, v55
	v_add_u32_e32 v47, 0, v56
	v_add_u32_e32 v49, 0, v57
	v_add_u32_e32 v50, 0, v58
	v_add_u32_e32 v69, 0, v59
	v_add_u32_e32 v72, 0, v60
	v_add_u32_e32 v73, 0, v61
	v_add_u32_e32 v74, 0, v62
	v_add_u32_e32 v75, 0, v63
	v_add_u32_e32 v76, 0, v64
	v_add_u32_e32 v77, 0, v65
	v_add_u32_e32 v78, 0, v66
	v_add_u32_e32 v79, 0, v67
	v_add_u32_e32 v80, 0, v68
	v_cvt_f32_i32_e32 v105, v105
	v_cvt_f32_i32_e32 v106, v106
	v_cvt_f32_i32_e32 v107, v107
	v_cvt_f32_i32_e32 v108, v108
	v_cvt_f32_i32_e32 v109, v109
	v_cvt_f32_i32_e32 v110, v110
	v_cvt_f32_i32_e32 v111, v111
	v_cvt_f32_i32_e32 v112, v112
	v_cvt_f32_i32_e32 v113, v113
	v_cvt_f32_i32_e32 v114, v114
	v_cvt_f32_i32_e32 v115, v115
	v_cvt_f32_i32_e32 v116, v116
	v_cvt_f32_i32_e32 v117, v117
	v_cvt_f32_i32_e32 v118, v118
	v_cvt_f32_i32_e32 v119, v119
	v_cvt_f32_i32_e32 v120, v120
	v_cvt_f32_i32_e32 v121, v121
	v_cvt_f32_i32_e32 v122, v122
	v_cvt_f32_i32_e32 v123, v123
	v_cvt_f32_i32_e32 v124, v124
	v_cvt_f32_i32_e32 v83, v83
	ds_write2st64_b32 v43, v97, v98 offset0:32 offset1:48
	ds_write2st64_b32 v43, v99, v100 offset0:64 offset1:80
	ds_write2st64_b32 v43, v101, v102 offset0:96 offset1:112
	ds_write2st64_b32 v43, v103, v104 offset0:128 offset1:144
	ds_write2st64_b32 v43, v105, v106 offset0:160 offset1:176
	ds_write2st64_b32 v43, v107, v108 offset0:192 offset1:208
	ds_write2st64_b32 v43, v109, v110 offset0:224 offset1:240
	ds_write_b32 v44, v111
	ds_write_b32 v45, v112
	ds_write_b32 v46, v113
	ds_write_b32 v47, v114
	ds_write_b32 v49, v115
	ds_write_b32 v50, v116
	ds_write_b32 v69, v117
	ds_write_b32 v72, v118
	ds_write_b32 v73, v119
	ds_write_b32 v74, v120
	ds_write_b32 v75, v121
	ds_write_b32 v76, v122
	ds_write_b32 v77, v123
	ds_write_b32 v78, v124
	ds_write_b32 v79, v96
	ds_write_b32 v80, v83
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[96:97], v20 offset1:2
	.loc	1 134 33 is_stmt 1              ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v84, v[6:9]
	s_mov_b32 s12, s10
	.loc	1 119 22                        ; binary_gemm_kernel.py:119:22
	s_add_i32 s10, s11, 1
	s_cmp_lt_i32 s10, 2
	s_cselect_b32 s11, s10, 0
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	s_lshl_b32 s10, s11, 12
	s_add_i32 s10, s10, 0
	s_add_i32 s10, s10, 0x10000
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v84, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[96:97], v20 offset0:16 offset1:18
	.loc	1 119 22                        ; binary_gemm_kernel.py:119:22
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[0:1]
	v_lshl_add_u64 v[12:13], v[12:13], 0, s[2:3]
	v_lshl_add_u64 v[14:15], v[14:15], 0, s[2:3]
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[4:5], 0
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v88, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v88, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[96:97], v20 offset0:32 offset1:34
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v92, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v92, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[96:97], v20 offset0:48 offset1:50
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v94, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v94, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[96:97], v20 offset0:64 offset1:66
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v85, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v85, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:80 offset1:82
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v89, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v89, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:96 offset1:98
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v93, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v93, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:112 offset1:114
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v95, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v95, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:128 offset1:130
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v86, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v86, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:144 offset1:146
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v90, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v90, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:160 offset1:162
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v18, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v18, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:176 offset1:178
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v16, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v16, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:192 offset1:194
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v16, s10, v52
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v87, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v87, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:208 offset1:210
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v91, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v91, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[84:85], v20 offset0:224 offset1:226
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v19, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v19, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[18:19], v20 offset0:240 offset1:242
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[6:9], v18, v17, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v19, v17, v[2:5]
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v17, s10, v53
	s_waitcnt vmcnt(3)
	ds_write_b32 v16, v70
	s_waitcnt vmcnt(2)
	ds_write_b32 v17, v71 offset:2048
	.loc	1 119 22                        ; binary_gemm_kernel.py:119:22
	s_cbranch_vccnz .LBB0_1
; %bb.2:
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v12, s12, v42
	v_add_u32_e32 v14, s12, v41
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[10:11], v12 offset1:16
	ds_read2_b32 v[12:13], v12 offset0:32 offset1:48
	ds_read2_b32 v[18:19], v14 offset1:16
	ds_read2_b32 v[52:53], v14 offset0:32 offset1:48
	v_add_u32_e32 v14, s12, v40
	ds_read2_b32 v[54:55], v14 offset1:16
	ds_read2_b32 v[56:57], v14 offset0:32 offset1:48
	v_add_u32_e32 v14, s12, v39
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v15, v24, v82
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	ds_read2_b32 v[58:59], v14 offset1:16
	ds_read2_b32 v[60:61], v14 offset0:32 offset1:48
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v14, v21, v82
	v_lshrrev_b32_e32 v16, v25, v82
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v15, 1, v15
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v17, v26, v82
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v14, 1, v14
	v_and_b32_e32 v15, 2, v15
	v_lshlrev_b32_e32 v16, 1, v16
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v51, v28, v82
	v_lshrrev_b32_e32 v62, v29, v82
	v_lshrrev_b32_e32 v63, v30, v82
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v14, 2, v14
	v_and_b32_e32 v16, 2, v16
	v_lshlrev_b32_e32 v17, 1, v17
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v15, -1, v15
	.loc	1 128 18 is_stmt 1              ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v48, v27, v82
	v_lshrrev_b32_e32 v64, v31, v82
	v_lshrrev_b32_e32 v65, v32, v82
	v_lshrrev_b32_e32 v66, v33, v82
	v_lshrrev_b32_e32 v67, v34, v82
	v_lshrrev_b32_e32 v68, v35, v82
	v_lshrrev_b32_e32 v70, v36, v82
	v_lshrrev_b32_e32 v71, v37, v82
	v_lshrrev_b32_e32 v82, v38, v82
	v_lshrrev_b32_e32 v83, v21, v81
	v_lshrrev_b32_e32 v84, v24, v81
	v_lshrrev_b32_e32 v85, v25, v81
	v_lshrrev_b32_e32 v86, v26, v81
	v_lshrrev_b32_e32 v87, v27, v81
	v_lshrrev_b32_e32 v88, v28, v81
	v_lshrrev_b32_e32 v89, v29, v81
	v_lshrrev_b32_e32 v90, v30, v81
	v_lshrrev_b32_e32 v91, v31, v81
	v_lshrrev_b32_e32 v92, v32, v81
	v_lshrrev_b32_e32 v93, v33, v81
	v_lshrrev_b32_e32 v94, v34, v81
	v_lshrrev_b32_e32 v95, v35, v81
	v_lshrrev_b32_e32 v96, v36, v81
	v_lshrrev_b32_e32 v97, v37, v81
	v_lshrrev_b32_e32 v81, v38, v81
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v17, 2, v17
	v_lshlrev_b32_e32 v51, 1, v51
	v_lshlrev_b32_e32 v62, 1, v62
	v_lshlrev_b32_e32 v63, 1, v63
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v14, -1, v14
	v_cvt_f32_i32_e32 v15, v15
	v_add_u32_e32 v16, -1, v16
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v48, 1, v48
	v_and_b32_e32 v51, 2, v51
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v63, 2, v63
	v_lshlrev_b32_e32 v64, 1, v64
	v_lshlrev_b32_e32 v65, 1, v65
	v_lshlrev_b32_e32 v66, 1, v66
	v_lshlrev_b32_e32 v67, 1, v67
	v_lshlrev_b32_e32 v68, 1, v68
	v_lshlrev_b32_e32 v70, 1, v70
	v_lshlrev_b32_e32 v71, 1, v71
	v_lshlrev_b32_e32 v82, 1, v82
	v_lshlrev_b32_e32 v83, 1, v83
	v_lshlrev_b32_e32 v84, 1, v84
	v_lshlrev_b32_e32 v85, 1, v85
	v_lshlrev_b32_e32 v86, 1, v86
	v_lshlrev_b32_e32 v87, 1, v87
	v_lshlrev_b32_e32 v88, 1, v88
	v_lshlrev_b32_e32 v89, 1, v89
	v_lshlrev_b32_e32 v90, 1, v90
	v_lshlrev_b32_e32 v91, 1, v91
	v_lshlrev_b32_e32 v92, 1, v92
	v_lshlrev_b32_e32 v93, 1, v93
	v_lshlrev_b32_e32 v94, 1, v94
	v_lshlrev_b32_e32 v95, 1, v95
	v_lshlrev_b32_e32 v96, 1, v96
	v_lshlrev_b32_e32 v97, 1, v97
	v_lshlrev_b32_e32 v81, 1, v81
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_cvt_f32_i32_e32 v14, v14
	v_cvt_f32_i32_e32 v16, v16
	v_add_u32_e32 v17, -1, v17
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v48, 2, v48
	v_and_b32_e32 v64, 2, v64
	v_and_b32_e32 v65, 2, v65
	v_and_b32_e32 v66, 2, v66
	v_and_b32_e32 v67, 2, v67
	v_and_b32_e32 v68, 2, v68
	v_and_b32_e32 v70, 2, v70
	v_and_b32_e32 v71, 2, v71
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
	v_and_b32_e32 v93, 2, v93
	v_and_b32_e32 v94, 2, v94
	v_and_b32_e32 v95, 2, v95
	v_and_b32_e32 v96, 2, v96
	v_and_b32_e32 v97, 2, v97
	v_and_b32_e32 v81, 2, v81
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_cvt_f32_i32_e32 v17, v17
	v_add_u32_e32 v51, -1, v51
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v63, -1, v63
	v_add_u32_e32 v48, -1, v48
	v_cvt_f32_i32_e32 v51, v51
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v63, v63
	v_add_u32_e32 v64, -1, v64
	v_add_u32_e32 v65, -1, v65
	v_add_u32_e32 v66, -1, v66
	v_add_u32_e32 v67, -1, v67
	v_add_u32_e32 v68, -1, v68
	v_add_u32_e32 v70, -1, v70
	v_add_u32_e32 v71, -1, v71
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
	v_add_u32_e32 v81, -1, v81
	v_cvt_f32_i32_e32 v48, v48
	v_cvt_f32_i32_e32 v64, v64
	v_cvt_f32_i32_e32 v65, v65
	v_cvt_f32_i32_e32 v66, v66
	v_cvt_f32_i32_e32 v67, v67
	v_cvt_f32_i32_e32 v68, v68
	v_cvt_f32_i32_e32 v70, v70
	v_cvt_f32_i32_e32 v71, v71
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
	v_cvt_f32_i32_e32 v81, v81
	ds_write_b32 v44, v15
	ds_write2st64_b32 v43, v14, v16 offset1:16
	ds_write_b32 v45, v17
	ds_write_b32 v46, v51
	ds_write2st64_b32 v43, v48, v62 offset0:32 offset1:48
	ds_write_b32 v47, v63
	ds_write_b32 v49, v65
	ds_write2st64_b32 v43, v64, v66 offset0:64 offset1:80
	ds_write_b32 v50, v67
	ds_write_b32 v69, v70
	ds_write2st64_b32 v43, v68, v71 offset0:96 offset1:112
	ds_write_b32 v72, v82
	ds_write_b32 v73, v84
	ds_write2st64_b32 v43, v83, v85 offset0:128 offset1:144
	ds_write_b32 v74, v86
	ds_write_b32 v75, v88
	ds_write2st64_b32 v43, v87, v89 offset0:160 offset1:176
	ds_write_b32 v76, v90
	ds_write_b32 v77, v92
	ds_write2st64_b32 v43, v91, v93 offset0:192 offset1:208
	ds_write_b32 v78, v94
	ds_write_b32 v79, v96
	ds_write2st64_b32 v43, v95, v97 offset0:224 offset1:240
	ds_write_b32 v80, v81
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[62:63], v20 offset1:2
	ds_read2st64_b32 v[64:65], v20 offset0:16 offset1:18
	.loc	1 134 33 is_stmt 1              ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[6:9], v62, v10, v[6:9]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[66:67], v20 offset0:32 offset1:34
	ds_read2st64_b32 v[70:71], v20 offset0:48 offset1:50
	ds_read2st64_b32 v[82:83], v20 offset0:64 offset1:66
	ds_read2st64_b32 v[84:85], v20 offset0:80 offset1:82
	ds_read2st64_b32 v[86:87], v20 offset0:96 offset1:98
	ds_read2st64_b32 v[88:89], v20 offset0:112 offset1:114
	ds_read2st64_b32 v[90:91], v20 offset0:128 offset1:130
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[2:5], v63, v10, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[92:93], v20 offset0:144 offset1:146
	ds_read2st64_b32 v[94:95], v20 offset0:160 offset1:162
	ds_read2st64_b32 v[96:97], v20 offset0:176 offset1:178
	ds_read2st64_b32 v[98:99], v20 offset0:192 offset1:194
	ds_read2st64_b32 v[100:101], v20 offset0:208 offset1:210
	ds_read2st64_b32 v[102:103], v20 offset0:224 offset1:226
	ds_read2st64_b32 v[104:105], v20 offset0:240 offset1:242
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x4_f32 v[6:9], v64, v18, v[6:9]
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	s_waitcnt vmcnt(1)
	v_lshrrev_b32_e32 v48, v29, v23
	v_lshrrev_b32_e32 v51, v30, v23
	v_lshrrev_b32_e32 v62, v33, v23
	v_lshrrev_b32_e32 v63, v34, v23
	v_lshrrev_b32_e32 v64, v35, v23
	s_waitcnt vmcnt(0)
	v_lshrrev_b32_e32 v29, v29, v22
	v_lshrrev_b32_e32 v30, v30, v22
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[2:5], v65, v18, v[2:5]
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v65, v36, v23
	v_lshrrev_b32_e32 v33, v33, v22
	v_lshrrev_b32_e32 v34, v34, v22
	v_lshrrev_b32_e32 v35, v35, v22
	v_lshrrev_b32_e32 v36, v36, v22
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v29, 1, v29
	v_lshlrev_b32_e32 v30, 1, v30
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(13)
	v_mfma_f32_16x16x4_f32 v[6:9], v66, v54, v[6:9]
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v66, v37, v23
	v_lshrrev_b32_e32 v37, v37, v22
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v33, 1, v33
	v_lshlrev_b32_e32 v34, 1, v34
	v_lshlrev_b32_e32 v35, 1, v35
	v_lshlrev_b32_e32 v36, 1, v36
	v_lshlrev_b32_e32 v37, 1, v37
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[2:5], v67, v54, v[2:5]
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v29, 2, v29
	v_and_b32_e32 v30, 2, v30
	v_and_b32_e32 v33, 2, v33
	v_and_b32_e32 v34, 2, v34
	v_and_b32_e32 v35, 2, v35
	v_and_b32_e32 v36, 2, v36
	v_and_b32_e32 v37, 2, v37
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(12)
	v_mfma_f32_16x16x4_f32 v[6:9], v70, v58, v[6:9]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v29, -1, v29
	v_add_u32_e32 v30, -1, v30
	v_add_u32_e32 v33, -1, v33
	v_add_u32_e32 v34, -1, v34
	v_add_u32_e32 v35, -1, v35
	v_add_u32_e32 v36, -1, v36
	v_add_u32_e32 v37, -1, v37
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[2:5], v71, v58, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_cvt_f32_i32_e32 v29, v29
	v_cvt_f32_i32_e32 v30, v30
	v_cvt_f32_i32_e32 v33, v33
	v_cvt_f32_i32_e32 v34, v34
	v_cvt_f32_i32_e32 v35, v35
	v_cvt_f32_i32_e32 v36, v36
	v_cvt_f32_i32_e32 v37, v37
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_16x16x4_f32 v[6:9], v82, v11, v[6:9]
	s_movk_i32 s2, 0x100
	v_mfma_f32_16x16x4_f32 v[2:5], v83, v11, v[2:5]
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_16x16x4_f32 v[6:9], v84, v19, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v85, v19, v[2:5]
	s_waitcnt lgkmcnt(9)
	v_mfma_f32_16x16x4_f32 v[6:9], v86, v55, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v87, v55, v[2:5]
	s_waitcnt lgkmcnt(8)
	v_mfma_f32_16x16x4_f32 v[6:9], v88, v59, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v89, v59, v[2:5]
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x4_f32 v[6:9], v90, v12, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v91, v12, v[2:5]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x4_f32 v[6:9], v92, v52, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v93, v52, v[2:5]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x4_f32 v[6:9], v94, v56, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v95, v56, v[2:5]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x4_f32 v[6:9], v96, v60, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v97, v60, v[2:5]
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v60, v31, v23
	v_lshrrev_b32_e32 v31, v31, v22
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v31, 1, v31
	v_and_b32_e32 v31, 2, v31
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v31, -1, v31
	v_cvt_f32_i32_e32 v31, v31
	.loc	1 134 33 is_stmt 1              ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 v[6:9], v98, v13, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v99, v13, v[2:5]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 v[6:9], v100, v53, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v101, v53, v[2:5]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[6:9], v102, v57, v[6:9]
	v_mfma_f32_16x16x4_f32 v[2:5], v103, v57, v[2:5]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[14:17], v104, v61, v[6:9]
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	s_nop 6
	v_add_u32_e32 v6, s10, v42
	ds_read2_b32 v[18:19], v6 offset1:16
	ds_read2_b32 v[8:9], v6 offset0:32 offset1:48
	v_add_u32_e32 v6, s10, v41
	ds_read2_b32 v[56:57], v6 offset1:16
	ds_read2_b32 v[12:13], v6 offset0:32 offset1:48
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v42, v28, v23
	v_lshrrev_b32_e32 v28, v28, v22
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[52:55], v105, v61, v[2:5]
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	v_add_u32_e32 v2, s10, v40
	ds_read2_b32 v[40:41], v2 offset1:16
	ds_read2_b32 v[10:11], v2 offset0:32 offset1:48
	v_add_u32_e32 v2, s10, v39
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v3, v24, v23
	.loc	1 122 20                        ; binary_gemm_kernel.py:122:20
	ds_read2_b32 v[58:59], v2 offset1:16
	ds_read2_b32 v[6:7], v2 offset0:32 offset1:48
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v2, v21, v23
	v_lshrrev_b32_e32 v4, v25, v23
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v3, 1, v3
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v5, v26, v23
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_lshlrev_b32_e32 v2, 1, v2
	v_and_b32_e32 v3, 2, v3
	v_lshlrev_b32_e32 v4, 1, v4
	.loc	1 128 18                        ; binary_gemm_kernel.py:128:18
	v_lshrrev_b32_e32 v39, v27, v23
	v_lshrrev_b32_e32 v61, v32, v23
	v_lshrrev_b32_e32 v23, v38, v23
	v_lshrrev_b32_e32 v21, v21, v22
	v_lshrrev_b32_e32 v24, v24, v22
	v_lshrrev_b32_e32 v25, v25, v22
	v_lshrrev_b32_e32 v26, v26, v22
	v_lshrrev_b32_e32 v27, v27, v22
	v_lshrrev_b32_e32 v32, v32, v22
	v_lshrrev_b32_e32 v22, v38, v22
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v2, 2, v2
	v_and_b32_e32 v4, 2, v4
	v_lshlrev_b32_e32 v5, 1, v5
	.loc	1 129 32 is_stmt 0              ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v3, -1, v3
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v5, 2, v5
	v_lshlrev_b32_e32 v38, 1, v39
	v_lshlrev_b32_e32 v39, 1, v42
	v_lshlrev_b32_e32 v23, 1, v23
	v_lshlrev_b32_e32 v22, 1, v22
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_add_u32_e32 v2, -1, v2
	v_cvt_f32_i32_e32 v3, v3
	v_add_u32_e32 v4, -1, v4
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v39, 2, v39
	v_lshlrev_b32_e32 v42, 1, v48
	v_lshlrev_b32_e32 v48, 1, v51
	v_lshlrev_b32_e32 v51, 1, v60
	v_lshlrev_b32_e32 v60, 1, v61
	v_lshlrev_b32_e32 v61, 1, v62
	v_lshlrev_b32_e32 v62, 1, v63
	v_lshlrev_b32_e32 v63, 1, v64
	v_lshlrev_b32_e32 v64, 1, v65
	v_lshlrev_b32_e32 v65, 1, v66
	v_and_b32_e32 v23, 2, v23
	v_lshlrev_b32_e32 v21, 1, v21
	v_lshlrev_b32_e32 v24, 1, v24
	v_lshlrev_b32_e32 v25, 1, v25
	v_lshlrev_b32_e32 v26, 1, v26
	v_lshlrev_b32_e32 v27, 1, v27
	v_lshlrev_b32_e32 v28, 1, v28
	v_lshlrev_b32_e32 v32, 1, v32
	v_and_b32_e32 v22, 2, v22
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_cvt_f32_i32_e32 v2, v2
	v_cvt_f32_i32_e32 v4, v4
	v_add_u32_e32 v5, -1, v5
	.loc	1 129 28                        ; binary_gemm_kernel.py:129:28
	v_and_b32_e32 v38, 2, v38
	v_and_b32_e32 v42, 2, v42
	v_and_b32_e32 v48, 2, v48
	v_and_b32_e32 v51, 2, v51
	v_and_b32_e32 v60, 2, v60
	v_and_b32_e32 v61, 2, v61
	v_and_b32_e32 v62, 2, v62
	v_and_b32_e32 v63, 2, v63
	v_and_b32_e32 v64, 2, v64
	v_and_b32_e32 v65, 2, v65
	v_and_b32_e32 v21, 2, v21
	v_and_b32_e32 v24, 2, v24
	v_and_b32_e32 v25, 2, v25
	v_and_b32_e32 v26, 2, v26
	v_and_b32_e32 v27, 2, v27
	v_and_b32_e32 v28, 2, v28
	v_and_b32_e32 v32, 2, v32
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	v_cvt_f32_i32_e32 v5, v5
	v_add_u32_e32 v39, -1, v39
	v_add_u32_e32 v23, -1, v23
	v_add_u32_e32 v22, -1, v22
	v_add_u32_e32 v38, -1, v38
	v_cvt_f32_i32_e32 v39, v39
	v_add_u32_e32 v42, -1, v42
	v_add_u32_e32 v48, -1, v48
	v_add_u32_e32 v51, -1, v51
	v_add_u32_e32 v60, -1, v60
	v_add_u32_e32 v61, -1, v61
	v_add_u32_e32 v62, -1, v62
	v_add_u32_e32 v63, -1, v63
	v_add_u32_e32 v64, -1, v64
	v_add_u32_e32 v65, -1, v65
	v_cvt_f32_i32_e32 v23, v23
	v_add_u32_e32 v21, -1, v21
	v_add_u32_e32 v24, -1, v24
	v_add_u32_e32 v25, -1, v25
	v_add_u32_e32 v26, -1, v26
	v_add_u32_e32 v27, -1, v27
	v_add_u32_e32 v28, -1, v28
	v_add_u32_e32 v32, -1, v32
	v_cvt_f32_i32_e32 v22, v22
	v_cvt_f32_i32_e32 v38, v38
	v_cvt_f32_i32_e32 v42, v42
	v_cvt_f32_i32_e32 v48, v48
	v_cvt_f32_i32_e32 v51, v51
	v_cvt_f32_i32_e32 v60, v60
	v_cvt_f32_i32_e32 v61, v61
	v_cvt_f32_i32_e32 v62, v62
	v_cvt_f32_i32_e32 v63, v63
	v_cvt_f32_i32_e32 v64, v64
	v_cvt_f32_i32_e32 v65, v65
	v_cvt_f32_i32_e32 v21, v21
	v_cvt_f32_i32_e32 v24, v24
	v_cvt_f32_i32_e32 v25, v25
	v_cvt_f32_i32_e32 v26, v26
	v_cvt_f32_i32_e32 v27, v27
	v_cvt_f32_i32_e32 v28, v28
	v_cvt_f32_i32_e32 v32, v32
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b32 v44, v3
	ds_write2st64_b32 v43, v2, v4 offset1:16
	ds_write_b32 v45, v5
	ds_write_b32 v46, v39
	ds_write2st64_b32 v43, v38, v42 offset0:32 offset1:48
	ds_write_b32 v47, v48
	ds_write_b32 v49, v60
	ds_write2st64_b32 v43, v51, v61 offset0:64 offset1:80
	ds_write_b32 v50, v62
	ds_write_b32 v69, v64
	ds_write2st64_b32 v43, v63, v65 offset0:96 offset1:112
	ds_write_b32 v72, v23
	ds_write_b32 v73, v24
	ds_write2st64_b32 v43, v21, v25 offset0:128 offset1:144
	ds_write_b32 v74, v26
	ds_write_b32 v75, v28
	ds_write2st64_b32 v43, v27, v29 offset0:160 offset1:176
	ds_write_b32 v76, v30
	ds_write_b32 v77, v32
	ds_write2st64_b32 v43, v31, v33 offset0:192 offset1:208
	ds_write_b32 v78, v34
	ds_write_b32 v79, v36
	ds_write2st64_b32 v43, v35, v37 offset0:224 offset1:240
	ds_write_b32 v80, v22
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2st64_b32 v[22:23], v20 offset1:2
	ds_read2st64_b32 v[24:25], v20 offset0:16 offset1:18
	.loc	1 134 33 is_stmt 1              ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[2:5], v22, v18, v[14:17]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[26:27], v20 offset0:32 offset1:34
	ds_read2st64_b32 v[28:29], v20 offset0:48 offset1:50
	ds_read2st64_b32 v[30:31], v20 offset0:64 offset1:66
	ds_read2st64_b32 v[32:33], v20 offset0:80 offset1:82
	ds_read2st64_b32 v[34:35], v20 offset0:96 offset1:98
	ds_read2st64_b32 v[36:37], v20 offset0:112 offset1:114
	ds_read2st64_b32 v[38:39], v20 offset0:128 offset1:130
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x4_f32 v[2:5], v24, v56, v[2:5]
	.loc	1 129 32                        ; binary_gemm_kernel.py:129:32
	ds_read2st64_b32 v[42:43], v20 offset0:144 offset1:146
	ds_read2st64_b32 v[44:45], v20 offset0:160 offset1:162
	ds_read2st64_b32 v[46:47], v20 offset0:176 offset1:178
	ds_read2st64_b32 v[48:49], v20 offset0:192 offset1:194
	ds_read2st64_b32 v[50:51], v20 offset0:208 offset1:210
	ds_read2st64_b32 v[60:61], v20 offset0:224 offset1:226
	ds_read2st64_b32 v[20:21], v20 offset0:240 offset1:242
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[14:17], v23, v18, v[52:55]
	s_waitcnt lgkmcnt(13)
	v_mfma_f32_16x16x4_f32 v[2:5], v26, v40, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v25, v56, v[14:17]
	s_waitcnt lgkmcnt(12)
	v_mfma_f32_16x16x4_f32 v[2:5], v28, v58, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v27, v40, v[14:17]
	s_waitcnt lgkmcnt(11)
	v_mfma_f32_16x16x4_f32 v[2:5], v30, v19, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v29, v58, v[14:17]
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_16x16x4_f32 v[2:5], v32, v57, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v31, v19, v[14:17]
	s_waitcnt lgkmcnt(9)
	v_mfma_f32_16x16x4_f32 v[2:5], v34, v41, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v33, v57, v[14:17]
	s_waitcnt lgkmcnt(8)
	v_mfma_f32_16x16x4_f32 v[2:5], v36, v59, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v35, v41, v[14:17]
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x4_f32 v[2:5], v38, v8, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v37, v59, v[14:17]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x4_f32 v[2:5], v42, v12, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v39, v8, v[14:17]
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_16x16x4_f32 v[2:5], v44, v10, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v43, v12, v[14:17]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x4_f32 v[2:5], v46, v6, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v45, v10, v[14:17]
	s_waitcnt lgkmcnt(3)
	v_mfma_f32_16x16x4_f32 v[2:5], v48, v9, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v47, v6, v[14:17]
	.loc	1 102 51                        ; binary_gemm_kernel.py:102:51
	v_lshrrev_b32_e32 v6, 2, v0
	v_and_b32_e32 v0, 0x7c, v6
	.loc	1 102 38 is_stmt 0              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v12, s8, v0
	.loc	1 150 58 is_stmt 1              ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v12
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x4_f32 v[2:5], v50, v13, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v49, v9, v[14:17]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 v[2:5], v60, v11, v[2:5]
	v_mfma_f32_16x16x4_f32 v[14:17], v51, v13, v[14:17]
	.loc	1 149 52                        ; binary_gemm_kernel.py:149:52
	v_ashrrev_i32_e32 v13, 31, v12
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 v[2:5], v20, v7, v[2:5]
	.loc	1 101 38                        ; binary_gemm_kernel.py:101:38
	v_or_b32_e32 v20, s9, v1
	.loc	1 149 33                        ; binary_gemm_kernel.py:149:33
	v_lshlrev_b32_e32 v0, 8, v20
	.loc	1 149 21 is_stmt 0              ; binary_gemm_kernel.py:149:21
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[8:9], v[0:1], 2, s[6:7]
	.loc	1 150 33 is_stmt 1              ; binary_gemm_kernel.py:150:33
	v_cmp_gt_i32_e32 vcc, s2, v20
	.loc	1 150 39 is_stmt 0              ; binary_gemm_kernel.py:150:39
	s_and_b64 s[4:5], vcc, s[0:1]
	.loc	1 134 33 is_stmt 1              ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[16:19], v61, v11, v[14:17]
	.loc	1 143 23                        ; binary_gemm_kernel.py:143:23
	s_nop 2
	v_cvt_pk_f16_f32 v14, v2, v3
	.loc	1 149 52                        ; binary_gemm_kernel.py:149:52
	v_lshl_add_u64 v[10:11], v[12:13], 2, v[8:9]
	.loc	1 134 33                        ; binary_gemm_kernel.py:134:33
	v_mfma_f32_16x16x4_f32 v[0:3], v21, v7, v[16:19]
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_4
; %bb.3:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	v_cvt_f32_f16_e32 v7, v14
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	global_store_dword v[10:11], v7, off
.LBB0_4:
	.loc	1 0 21                          ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v7, 1, v12
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v7
	.loc	1 150 39 is_stmt 0              ; binary_gemm_kernel.py:150:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 151 21 is_stmt 1              ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_6
; %bb.5:
	v_cvt_f32_f16_sdwa v7, v14 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[10:11], v7, off offset:4
.LBB0_6:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v7, 2, v12
	s_movk_i32 s2, 0x100
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v7
	.loc	1 143 23                        ; binary_gemm_kernel.py:143:23
	v_cvt_pk_f16_f32 v4, v4, v5
	.loc	1 150 39                        ; binary_gemm_kernel.py:150:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_8
; %bb.7:
	v_cvt_f32_f16_e32 v5, v4
	global_store_dword v[10:11], v5, off offset:8
.LBB0_8:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v5, 3, v12
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v5
	.loc	1 150 39 is_stmt 0              ; binary_gemm_kernel.py:150:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 151 21 is_stmt 1              ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_10
; %bb.9:
	v_cvt_f32_f16_sdwa v4, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[10:11], v4, off offset:12
.LBB0_10:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v4, 0x80, v12
	s_movk_i32 s2, 0x100
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v4
	.loc	1 143 23                        ; binary_gemm_kernel.py:143:23
	v_cvt_pk_f16_f32 v0, v0, v1
	.loc	1 150 39                        ; binary_gemm_kernel.py:150:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_12
; %bb.11:
	v_cvt_f32_f16_e32 v1, v0
	global_store_dword v[10:11], v1, off offset:512
.LBB0_12:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v1, 0x81, v12
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v1
	.loc	1 150 39 is_stmt 0              ; binary_gemm_kernel.py:150:39
	s_and_b64 s[2:3], s[0:1], vcc
	.loc	1 151 21 is_stmt 1              ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_14
; %bb.13:
	v_cvt_f32_f16_sdwa v0, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	global_store_dword v[10:11], v0, off offset:516
.LBB0_14:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v0, 0x82, v12
	s_movk_i32 s2, 0x100
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 143 23                        ; binary_gemm_kernel.py:143:23
	v_cvt_pk_f16_f32 v1, v2, v3
	.loc	1 150 39                        ; binary_gemm_kernel.py:150:39
	s_and_b64 s[4:5], s[0:1], vcc
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[0:1], s[4:5]
	s_cbranch_execz .LBB0_16
; %bb.15:
	v_cvt_f32_f16_e32 v0, v1
	global_store_dword v[10:11], v0, off offset:520
.LBB0_16:
	.loc	1 0 21 is_stmt 0                ; binary_gemm_kernel.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 102 38 is_stmt 1              ; binary_gemm_kernel.py:102:38
	v_or_b32_e32 v0, s8, v6
	v_or_b32_e32 v0, 0x83, v0
	.loc	1 150 58                        ; binary_gemm_kernel.py:150:58
	v_cmp_gt_i32_e64 s[0:1], s2, v0
	.loc	1 150 39 is_stmt 0              ; binary_gemm_kernel.py:150:39
	s_and_b64 s[0:1], vcc, s[0:1]
	.loc	1 151 21 is_stmt 1              ; binary_gemm_kernel.py:151:21
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_18
; %bb.17:
	v_cvt_f32_f16_sdwa v2, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1
	.loc	1 149 52                        ; binary_gemm_kernel.py:149:52
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 2, v[8:9]
	.loc	1 151 21                        ; binary_gemm_kernel.py:151:21
	global_store_dword v[0:1], v2, off
.LBB0_18:
	.loc	1 151 4 is_stmt 0               ; binary_gemm_kernel.py:151:4
	s_endpgm
.Ltmp2:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel binary_matmul_kernel
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 127
		.amdhsa_next_free_sgpr 14
		.amdhsa_accum_offset 128
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
	.size	binary_matmul_kernel, .Lfunc_end0-binary_matmul_kernel
	.cfi_endproc
                                        ; -- End function
	.set binary_matmul_kernel.num_vgpr, 127
	.set binary_matmul_kernel.num_agpr, 0
	.set binary_matmul_kernel.numbered_sgpr, 14
	.set binary_matmul_kernel.private_seg_size, 0
	.set binary_matmul_kernel.uses_vcc, 1
	.set binary_matmul_kernel.uses_flat_scratch, 0
	.set binary_matmul_kernel.has_dyn_sized_stack, 0
	.set binary_matmul_kernel.has_recursion, 0
	.set binary_matmul_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 5968
; TotalNumSgprs: 20
; NumVgprs: 127
; NumAgprs: 0
; TotalNumVgprs: 127
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 15
; NumSGPRsForWavesPerEU: 20
; NumVGPRsForWavesPerEU: 127
; AccumOffset: 128
; Occupancy: 4
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 12
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 31
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
    .max_flat_workgroup_size: 512
    .name:           binary_matmul_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     20
    .sgpr_spill_count: 0
    .symbol:         binary_matmul_kernel.kd
    .uses_dynamic_stack: false
    .vgpr_count:     127
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
