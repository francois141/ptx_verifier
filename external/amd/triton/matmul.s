	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	matmul_kernel                   ; -- Begin function matmul_kernel
	.p2align	8
	.type	matmul_kernel,@function
matmul_kernel:                          ; @matmul_kernel
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.17:
	.file	1 "/work" "kernels.py"
	.loc	1 53 0 prologue_end             ; kernels.py:53:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.18:
.LBB0_0:
.Ltmp1:
	.loc	1 64 22 is_stmt 1               ; kernels.py:64:22
	s_ashr_i32 s0, s12, 31
	s_lshr_b32 s0, s0, 29
	s_add_i32 s0, s12, s0
	.loc	1 65 29                         ; kernels.py:65:29
	s_and_b32 s0, s0, -8
	.loc	1 66 35                         ; kernels.py:66:35
	s_sub_i32 s1, 4, s0
	.loc	1 66 48 is_stmt 0               ; kernels.py:66:48
	s_min_i32 s1, s1, 8
	.loc	1 68 40 is_stmt 1               ; kernels.py:68:40
	s_abs_i32 s8, s1
	v_cvt_f32_u32_e32 v1, s8
	.loc	1 67 34                         ; kernels.py:67:34
	s_sub_i32 s9, s12, s0
	.loc	1 68 40                         ; kernels.py:68:40
	s_sub_i32 s12, 0, s8
	s_abs_i32 s10, s9
	v_rcp_iflag_f32_e32 v1, v1
	s_xor_b32 s11, s9, s1
	s_ashr_i32 s11, s11, 31
	.loc	1 70 51                         ; kernels.py:70:51
	v_and_b32_e32 v28, 15, v0
	.loc	1 68 40                         ; kernels.py:68:40
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	.loc	1 74 22                         ; kernels.py:74:22
	v_mov_b32_e32 v9, 0
	v_mov_b32_e32 v11, v9
	v_mov_b32_e32 v13, v9
	.loc	1 68 40                         ; kernels.py:68:40
	v_readfirstlane_b32 s13, v1
	s_mul_i32 s12, s12, s13
	s_mul_hi_u32 s12, s13, s12
	s_add_i32 s13, s13, s12
	s_mul_hi_u32 s12, s10, s13
	s_mul_i32 s13, s12, s8
	s_sub_i32 s10, s10, s13
	s_add_i32 s13, s12, 1
	s_sub_i32 s14, s10, s8
	s_cmp_ge_u32 s10, s8
	s_cselect_b32 s12, s13, s12
	s_cselect_b32 s10, s14, s10
	s_add_i32 s13, s12, 1
	s_cmp_ge_u32 s10, s8
	s_cselect_b32 s8, s13, s12
	s_xor_b32 s8, s8, s11
	s_sub_i32 s8, s8, s11
	.loc	1 67 54                         ; kernels.py:67:54
	s_mul_i32 s1, s8, s1
	s_sub_i32 s1, s9, s1
	.loc	1 67 27 is_stmt 0               ; kernels.py:67:27
	s_add_i32 s1, s1, s0
	.loc	1 70 23 is_stmt 1               ; kernels.py:70:23
	s_lshl_b32 s0, s1, 5
	.loc	1 70 51 is_stmt 0               ; kernels.py:70:51
	v_lshrrev_b32_e32 v1, 4, v0
	.loc	1 70 68                         ; kernels.py:70:68
	s_bfe_i32 s1, s1, 0x1001a
	.loc	1 70 38                         ; kernels.py:70:38
	v_or_b32_e32 v1, s0, v1
	.loc	1 70 68                         ; kernels.py:70:68
	s_lshr_b32 s1, s1, 25
	v_add_u32_e32 v3, s1, v1
	.loc	1 70 38                         ; kernels.py:70:38
	v_or_b32_e32 v2, 16, v1
	.loc	1 70 68                         ; kernels.py:70:68
	v_and_b32_e32 v3, 0x3ffff80, v3
	v_sub_u32_e32 v1, v1, v3
	v_add_u32_e32 v3, s1, v2
	v_and_b32_e32 v3, 0x3ffff80, v3
	.loc	1 71 23 is_stmt 1               ; kernels.py:71:23
	s_lshl_b32 s1, s8, 6
	.loc	1 71 68 is_stmt 0               ; kernels.py:71:68
	s_bfe_i32 s8, s8, 0x10019
	.loc	1 70 68 is_stmt 1               ; kernels.py:70:68
	v_sub_u32_e32 v3, v2, v3
	.loc	1 71 38                         ; kernels.py:71:38
	v_or_b32_e32 v2, s1, v0
	.loc	1 71 68 is_stmt 0               ; kernels.py:71:68
	s_lshr_b32 s8, s8, 26
	v_add_u32_e32 v4, s8, v2
	v_and_b32_e32 v4, 0xffffffc0, v4
	v_sub_u32_e32 v6, v2, v4
	.loc	1 73 53 is_stmt 1               ; kernels.py:73:53
	v_lshl_or_b32 v2, v1, 6, v28
	.loc	1 74 29                         ; kernels.py:74:29
	v_and_b32_e32 v1, 0xc0, v0
	.loc	1 74 52 is_stmt 0               ; kernels.py:74:52
	v_add_u32_e32 v6, v6, v1
	.loc	1 73 53 is_stmt 1               ; kernels.py:73:53
	v_lshl_or_b32 v4, v3, 6, v28
	.loc	1 74 22                         ; kernels.py:74:22
	v_ashrrev_i32_e32 v7, 31, v6
	.loc	1 73 22                         ; kernels.py:73:22
	v_ashrrev_i32_e32 v3, 31, v2
	v_ashrrev_i32_e32 v5, 31, v4
	.loc	1 74 52                         ; kernels.py:74:52
	v_add_u32_e32 v8, 0x100, v6
	v_add_u32_e32 v10, 0x200, v6
	v_add_u32_e32 v12, 0x300, v6
	.loc	1 74 22 is_stmt 0               ; kernels.py:74:22
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[4:5]
	.loc	1 73 22 is_stmt 1               ; kernels.py:73:22
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[2:3]
	v_lshl_add_u64 v[4:5], v[4:5], 2, s[2:3]
	.loc	1 74 22                         ; kernels.py:74:22
	v_lshl_add_u64 v[14:15], v[8:9], 2, s[4:5]
	v_lshl_add_u64 v[10:11], v[10:11], 2, s[4:5]
	v_lshl_add_u64 v[8:9], v[12:13], 2, s[4:5]
	.loc	1 79 20                         ; kernels.py:79:20
	global_load_dword v12, v[6:7], off
	global_load_dword v13, v[14:15], off
	global_load_dword v16, v[10:11], off
	global_load_dword v17, v[8:9], off
	.loc	1 78 20                         ; kernels.py:78:20
	global_load_dword v18, v[2:3], off
	global_load_dword v19, v[4:5], off
	v_and_b32_e32 v22, 48, v0
	v_lshlrev_b32_e32 v20, 2, v0
	v_lshrrev_b32_e32 v24, 2, v22
	v_lshlrev_b32_e32 v25, 2, v28
	v_lshl_add_u32 v22, v22, 4, 0
	v_lshrrev_b32_e32 v23, 4, v1
	.loc	1 79 20                         ; kernels.py:79:20
	v_add_u32_e32 v29, 0, v20
	v_add3_u32 v1, v22, v25, v1
	v_and_b32_e32 v21, 12, v0
	.loc	1 78 20                         ; kernels.py:78:20
	v_xad_u32 v30, v20, v23, 0
	global_load_dword v31, v[4:5], off offset:64
	global_load_dword v32, v[2:3], off offset:64
	.loc	1 79 20                         ; kernels.py:79:20
	s_movk_i32 s2, 0x2000
	.loc	1 70 51                         ; kernels.py:70:51
	v_and_b32_e32 v0, 0xf0, v0
	.loc	1 71 51                         ; kernels.py:71:51
	v_lshrrev_b32_e32 v0, 2, v0
	.loc	1 79 20                         ; kernels.py:79:20
	s_waitcnt vmcnt(6)
	ds_write2st64_b32 v29, v12, v13 offset1:4
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v29, v16, v17 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	s_waitcnt vmcnt(2)
	ds_write2st64_b32 v30, v18, v19 offset0:16 offset1:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[12:13], v1 offset1:4
	v_lshl_or_b32 v16, v28, 6, v21
	.loc	1 78 20                         ; kernels.py:78:20
	v_xad_u32 v18, v16, v24, 0
	v_add_u32_e32 v33, 0x1000, v18
	ds_read2_b32 v[16:17], v33 offset1:4
	v_add_u32_e32 v34, 0x1400, v18
	ds_read2_b32 v[18:19], v34 offset1:4
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v12, v16, 0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v12, v18, 0
	.loc	1 79 20                         ; kernels.py:79:20
	v_add_co_u32_e32 v18, vcc, s2, v6
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[0:3], v13, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v13, v19, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[12:13], v1 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[16:17], v33 offset0:8 offset1:12
	.loc	1 79 20                         ; kernels.py:79:20
	v_addc_co_u32_e32 v19, vcc, 0, v7, vcc
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[20:21], v34 offset0:8 offset1:12
	.loc	1 79 20                         ; kernels.py:79:20
	v_add_co_u32_e32 v22, vcc, s2, v14
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v12, v16, a[0:3]
	.loc	1 79 20                         ; kernels.py:79:20
	v_addc_co_u32_e32 v23, vcc, 0, v15, vcc
	v_add_co_u32_e32 v24, vcc, s2, v10
	s_nop 1
	v_addc_co_u32_e32 v25, vcc, 0, v11, vcc
	v_add_co_u32_e32 v26, vcc, s2, v8
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v12, v20, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	v_addc_co_u32_e32 v27, vcc, 0, v9, vcc
	s_movk_i32 s2, 0x3000
	v_add_co_u32_e32 v6, vcc, s2, v6
	s_nop 1
	v_addc_co_u32_e32 v7, vcc, 0, v7, vcc
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[0:3], v13, v17, a[0:3]
	.loc	1 79 20                         ; kernels.py:79:20
	global_load_dword v12, v[18:19], off offset:-4096
	global_load_dword v16, v[22:23], off offset:-4096
	global_load_dword v17, v[24:25], off offset:-4096
	global_load_dword v20, v[26:27], off offset:-4096
	.loc	1 78 20                         ; kernels.py:78:20
	s_barrier
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v30, v32, v31 offset0:16 offset1:20
	global_load_dword v31, v[2:3], off offset:128
	global_load_dword v32, v[4:5], off offset:128
	.loc	1 79 20                         ; kernels.py:79:20
	v_add_co_u32_e32 v14, vcc, s2, v14
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[4:7], v13, v21, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	s_nop 0
	v_addc_co_u32_e32 v15, vcc, 0, v15, vcc
	v_add_co_u32_e32 v10, vcc, s2, v10
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v29, v12, v16 offset1:4
	s_waitcnt vmcnt(2)
	ds_write2st64_b32 v29, v17, v20 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[12:13], v1 offset1:4
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[16:17], v33 offset1:4
	ds_read2_b32 v[20:21], v34 offset1:4
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v12, v16, a[0:3]
	.loc	1 79 20                         ; kernels.py:79:20
	v_addc_co_u32_e32 v11, vcc, 0, v11, vcc
	v_add_co_u32_e32 v8, vcc, s2, v8
	s_movk_i32 s2, 0x80
	s_nop 0
	v_addc_co_u32_e32 v9, vcc, 0, v9, vcc
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v12, v20, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v13, v17, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v13, v21, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[12:13], v1 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[16:17], v33 offset0:8 offset1:12
	ds_read2_b32 v[20:21], v34 offset0:8 offset1:12
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v12, v16, a[0:3]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v12, v20, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v13, v17, a[0:3]
	.loc	1 79 20                         ; kernels.py:79:20
	global_load_dword v12, v[18:19], off
	global_load_dword v16, v[22:23], off
	global_load_dword v17, v[24:25], off
	global_load_dword v20, v[26:27], off
	.loc	1 78 20                         ; kernels.py:78:20
	s_barrier
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v30, v31, v32 offset0:16 offset1:20
	global_load_dword v18, v[2:3], off offset:192
	global_load_dword v19, v[4:5], off offset:192
	.loc	1 79 20                         ; kernels.py:79:20
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v29, v12, v16 offset1:4
	s_waitcnt vmcnt(2)
	ds_write2st64_b32 v29, v17, v20 offset0:8 offset1:12
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[4:7], v13, v21, a[4:7]
	.loc	1 78 20                         ; kernels.py:78:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[2:3], v1 offset1:4
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[4:5], v33 offset1:4
	ds_read2_b32 v[12:13], v34 offset1:4
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v4, a[0:3]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v12, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v5, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v13, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[2:3], v1 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[4:5], v33 offset0:8 offset1:12
	ds_read2_b32 v[12:13], v34 offset0:8 offset1:12
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v4, a[0:3]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v12, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v5, a[0:3]
	.loc	1 79 20                         ; kernels.py:79:20
	global_load_dword v2, v[6:7], off
	global_load_dword v4, v[14:15], off
	global_load_dword v5, v[10:11], off
	global_load_dword v12, v[8:9], off
	.loc	1 78 20                         ; kernels.py:78:20
	s_barrier
	s_waitcnt vmcnt(4)
	ds_write2st64_b32 v30, v18, v19 offset0:16 offset1:20
	.loc	1 79 20                         ; kernels.py:79:20
	s_waitcnt vmcnt(2)
	ds_write2st64_b32 v29, v2, v4 offset1:4
	s_waitcnt vmcnt(0)
	ds_write2st64_b32 v29, v5, v12 offset0:8 offset1:12
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v13, a[4:7]
	.loc	1 78 20                         ; kernels.py:78:20
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[2:3], v1 offset1:4
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[4:5], v33 offset1:4
	ds_read2_b32 v[6:7], v34 offset1:4
	.loc	1 70 38                         ; kernels.py:70:38
	v_or_b32_e32 v8, s0, v28
	.loc	1 90 33                         ; kernels.py:90:33
	v_cmp_gt_i32_e64 s[8:9], s2, v8
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v4, a[0:3]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v6, a[4:7]
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v5, a[0:3]
	v_mfma_f32_16x16x4_f32 a[4:7], v3, v7, a[4:7]
	.loc	1 79 20                         ; kernels.py:79:20
	ds_read2st64_b32 v[2:3], v1 offset0:8 offset1:12
	.loc	1 78 20                         ; kernels.py:78:20
	ds_read2_b32 v[4:5], v33 offset0:8 offset1:12
	ds_read2_b32 v[6:7], v34 offset0:8 offset1:12
	.loc	1 80 35                         ; kernels.py:80:35
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x4_f32 a[0:3], v2, v4, a[0:3]
	.loc	1 71 38                         ; kernels.py:71:38
	v_or_b32_e32 v4, s1, v0
	.loc	1 89 33                         ; kernels.py:89:33
	v_lshlrev_b32_e32 v0, 6, v8
	.loc	1 89 21 is_stmt 0               ; kernels.py:89:21
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[0:1], v[0:1], 2, s[6:7]
	.loc	1 90 58 is_stmt 1               ; kernels.py:90:58
	v_cmp_gt_i32_e32 vcc, 64, v4
	.loc	1 90 39 is_stmt 0               ; kernels.py:90:39
	s_and_b64 s[2:3], s[8:9], vcc
	.loc	1 80 35 is_stmt 1               ; kernels.py:80:35
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x4_f32 a[4:7], v2, v6, a[4:7]
	v_mfma_f32_16x16x4_f32 a[8:11], v3, v5, a[0:3]
	.loc	1 89 52                         ; kernels.py:89:52
	v_ashrrev_i32_e32 v5, 31, v4
	.loc	1 80 35                         ; kernels.py:80:35
	v_mfma_f32_16x16x4_f32 a[0:3], v3, v7, a[4:7]
	.loc	1 89 52                         ; kernels.py:89:52
	v_lshl_add_u64 v[6:7], v[4:5], 2, v[0:1]
	.loc	1 80 35                         ; kernels.py:80:35
	s_nop 6
	v_accvgpr_read_b32 v0, a8
	v_accvgpr_read_b32 v1, a9
	v_accvgpr_read_b32 v2, a10
	v_accvgpr_read_b32 v3, a11
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_2
; %bb.1:
	global_store_dword v[6:7], v0, off
.LBB0_2:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 71 38 is_stmt 1               ; kernels.py:71:38
	v_or_b32_e32 v0, 1, v4
	.loc	1 90 58                         ; kernels.py:90:58
	v_cmp_gt_i32_e64 s[0:1], 64, v0
	.loc	1 90 39 is_stmt 0               ; kernels.py:90:39
	s_and_b64 s[4:5], s[0:1], s[8:9]
	.loc	1 91 21 is_stmt 1               ; kernels.py:91:21
	s_and_saveexec_b64 s[2:3], s[4:5]
	s_cbranch_execz .LBB0_4
; %bb.3:
	global_store_dword v[6:7], v1, off offset:4
.LBB0_4:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[2:3]
	.loc	1 71 38 is_stmt 1               ; kernels.py:71:38
	v_or_b32_e32 v0, 2, v4
	.loc	1 90 58                         ; kernels.py:90:58
	v_cmp_gt_i32_e64 s[2:3], 64, v0
	.loc	1 90 39 is_stmt 0               ; kernels.py:90:39
	s_and_b64 s[10:11], s[2:3], s[8:9]
	.loc	1 91 21 is_stmt 1               ; kernels.py:91:21
	s_and_saveexec_b64 s[4:5], s[10:11]
	s_cbranch_execz .LBB0_6
; %bb.5:
	global_store_dword v[6:7], v2, off offset:8
.LBB0_6:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[4:5]
	.loc	1 71 38 is_stmt 1               ; kernels.py:71:38
	v_or_b32_e32 v0, 3, v4
	.loc	1 90 58                         ; kernels.py:90:58
	v_cmp_gt_i32_e64 s[4:5], 64, v0
	.loc	1 90 39 is_stmt 0               ; kernels.py:90:39
	s_and_b64 s[10:11], s[4:5], s[8:9]
	.loc	1 91 21 is_stmt 1               ; kernels.py:91:21
	s_and_saveexec_b64 s[8:9], s[10:11]
	s_cbranch_execz .LBB0_8
; %bb.7:
	global_store_dword v[6:7], v3, off offset:12
.LBB0_8:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[8:9]
	.loc	1 70 38 is_stmt 1               ; kernels.py:70:38
	v_or_b32_e32 v8, 16, v8
	.loc	1 89 33                         ; kernels.py:89:33
	v_lshlrev_b32_e32 v6, 6, v8
	.loc	1 89 21 is_stmt 0               ; kernels.py:89:21
	v_ashrrev_i32_e32 v7, 31, v6
	v_lshl_add_u64 v[6:7], v[6:7], 2, s[6:7]
	s_movk_i32 s6, 0x80
	v_accvgpr_read_b32 v0, a0
	.loc	1 90 33 is_stmt 1               ; kernels.py:90:33
	v_cmp_gt_i32_e64 s[6:7], s6, v8
	v_accvgpr_read_b32 v1, a1
	v_accvgpr_read_b32 v2, a2
	v_accvgpr_read_b32 v3, a3
	.loc	1 89 52                         ; kernels.py:89:52
	v_lshl_add_u64 v[4:5], v[4:5], 2, v[6:7]
	.loc	1 90 39                         ; kernels.py:90:39
	s_and_b64 s[10:11], s[6:7], vcc
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[8:9], s[10:11]
	s_cbranch_execnz .LBB0_13
; %bb.9:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[8:9]
	.loc	1 90 39 is_stmt 1               ; kernels.py:90:39
	s_and_b64 s[8:9], s[6:7], s[0:1]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execnz .LBB0_14
.LBB0_10:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 90 39 is_stmt 1               ; kernels.py:90:39
	s_and_b64 s[2:3], s[6:7], s[2:3]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execnz .LBB0_15
.LBB0_11:
	.loc	1 0 21 is_stmt 0                ; kernels.py:0:21
	s_or_b64 exec, exec, s[0:1]
	.loc	1 90 39 is_stmt 1               ; kernels.py:90:39
	s_and_b64 s[0:1], s[6:7], s[4:5]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_16
.LBB0_12:
	.loc	1 91 4 is_stmt 0                ; kernels.py:91:4
	s_endpgm
.LBB0_13:
	.loc	1 91 21                         ; kernels.py:91:21
	global_store_dword v[4:5], v0, off
	s_or_b64 exec, exec, s[8:9]
	.loc	1 90 39 is_stmt 1               ; kernels.py:90:39
	s_and_b64 s[8:9], s[6:7], s[0:1]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_10
.LBB0_14:
	global_store_dword v[4:5], v1, off offset:4
	s_or_b64 exec, exec, s[0:1]
	.loc	1 90 39                         ; kernels.py:90:39
	s_and_b64 s[2:3], s[6:7], s[2:3]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_11
.LBB0_15:
	global_store_dword v[4:5], v2, off offset:8
	s_or_b64 exec, exec, s[0:1]
	.loc	1 90 39                         ; kernels.py:90:39
	s_and_b64 s[0:1], s[6:7], s[4:5]
	.loc	1 91 21                         ; kernels.py:91:21
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_12
.LBB0_16:
	global_store_dword v[4:5], v3, off offset:12
	.loc	1 91 4 is_stmt 0                ; kernels.py:91:4
	s_endpgm
.Ltmp2:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel matmul_kernel
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
		.amdhsa_next_free_vgpr 48
		.amdhsa_next_free_sgpr 15
		.amdhsa_accum_offset 36
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
	.size	matmul_kernel, .Lfunc_end0-matmul_kernel
	.cfi_endproc
                                        ; -- End function
	.set matmul_kernel.num_vgpr, 35
	.set matmul_kernel.num_agpr, 12
	.set matmul_kernel.numbered_sgpr, 15
	.set matmul_kernel.private_seg_size, 0
	.set matmul_kernel.uses_vcc, 1
	.set matmul_kernel.uses_flat_scratch, 0
	.set matmul_kernel.has_dyn_sized_stack, 0
	.set matmul_kernel.has_recursion, 0
	.set matmul_kernel.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 2144
; TotalNumSgprs: 21
; NumVgprs: 35
; NumAgprs: 12
; TotalNumVgprs: 48
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 2
; VGPRBlocks: 5
; NumSGPRsForWavesPerEU: 21
; NumVGPRsForWavesPerEU: 48
; AccumOffset: 36
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 12
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 8
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
	.asciz	"/work"                         ; string offset=18
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     12
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
    .name:           matmul_kernel
    .private_segment_fixed_size: 0
    .sgpr_count:     21
    .sgpr_spill_count: 0
    .symbol:         matmul_kernel.kd
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
