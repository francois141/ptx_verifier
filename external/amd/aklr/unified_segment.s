; AKLR 766a200e367f aklr/ops/attention/impls/triton/unified_attention_max_q8_kv_split_pages_n_heads16_n_kv_heads2_head_dim64_block_size16/6a75fb72aaa797fc.json, compiled for gfx950 by
; external/amd/aklr/build.py (case unified_segment).
; dynamic LDS: 8192 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_attn_segment                   ; -- Begin function _attn_segment
	.p2align	8
	.type	_attn_segment,@function
_attn_segment:                          ; @_attn_segment
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.8:
	.file	1 "/work/build/unified_segment" "kernel.py"
	.loc	1 48 0 prologue_end             ; kernel.py:48:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.9:
.LBB0_0:
	.cfi_escape 0x0f, 0x04, 0x30, 0x36, 0xe9, 0x02 ; CFA is 0 in private_wave aspace
	.cfi_undefined 16
	s_mov_b32 s8, s17
.Ltmp1:
	.loc	1 61 15 is_stmt 1               ; kernel.py:61:15
	s_ashr_i32 s17, s16, 31
	s_mov_b64 s[20:21], s[2:3]
	s_lshl_b64 s[2:3], s[16:17], 2
	s_mov_b64 s[88:89], s[6:7]
	s_add_u32 s6, s14, s2
	s_mov_b64 s[84:85], s[10:11]
	s_addc_u32 s7, s15, s3
	.loc	1 62 20                         ; kernel.py:62:20
	s_add_i32 s10, s16, 1
	.loc	1 62 12 is_stmt 0               ; kernel.py:62:12
	s_ashr_i32 s11, s10, 31
	s_lshl_b64 s[10:11], s[10:11], 2
	s_add_u32 s10, s14, s10
	s_addc_u32 s11, s15, s11
	.loc	1 61 15 is_stmt 1               ; kernel.py:61:15
	s_load_dword s19, s[6:7], 0x0
	.loc	1 62 12                         ; kernel.py:62:12
	s_load_dword s9, s[10:11], 0x0
	.loc	1 118 9                         ; kernel.py:118:9
	v_readfirstlane_b32 s6, v0
	.loc	1 62 12                         ; kernel.py:62:12
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s92, s9, s19
	.loc	1 63 8                          ; kernel.py:63:8
	s_cmp_gt_i32 s92, 0
	s_cbranch_scc0 .LBB0_7
; %bb.1:
	.loc	1 0 8 is_stmt 0                 ; kernel.py:0:8
	s_load_dwordx2 s[10:11], s[0:1], 0x38
	.loc	1 65 9 is_stmt 1                ; kernel.py:65:9
	s_waitcnt lgkmcnt(0)
	s_add_u32 s2, s10, s2
	s_addc_u32 s3, s11, s3
	s_load_dword s2, s[2:3], 0x0
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 43 13                         ; standard.py:43:13 @[ kernel.py:71:16 ]
	s_waitcnt lgkmcnt(0)
	s_add_i32 s3, s2, 63
	.loc	2 43 12 is_stmt 0               ; standard.py:43:12 @[ kernel.py:71:16 ]
	s_ashr_i32 s7, s3, 31
	s_lshr_b32 s7, s7, 26
	s_add_i32 s3, s3, s7
	s_ashr_i32 s3, s3, 6
.Ltmp3:
	.loc	2 43 13                         ; standard.py:43:13 @[ kernel.py:72:15 ]
	s_addk_i32 s3, 0x7f
	.loc	2 43 12                         ; standard.py:43:12 @[ kernel.py:72:15 ]
	s_ashr_i32 s7, s3, 31
	s_lshr_b32 s7, s7, 25
	s_add_i32 s3, s3, s7
	s_ashr_i32 s3, s3, 7
.Ltmp4:
	.loc	1 73 19 is_stmt 1               ; kernel.py:73:19
	s_mul_i32 s7, s3, s18
	s_lshl_b32 s9, s7, 6
	.loc	1 74 25                         ; kernel.py:74:25
	s_add_i32 s7, s7, s3
	s_lshl_b32 s3, s7, 6
	.loc	1 74 14 is_stmt 0               ; kernel.py:74:14
	s_min_i32 s94, s3, s2
	.loc	1 75 8 is_stmt 1                ; kernel.py:75:8
	s_cmp_ge_i32 s9, s94
	s_cbranch_scc1 .LBB0_7
; %bb.2:
	.loc	1 118 9                         ; kernel.py:118:9
	s_bfe_u32 s33, s6, 0x20006
	s_load_dwordx8 s[76:83], s[0:1], 0x40
	.loc	1 66 13                         ; kernel.py:66:13
	s_sub_i32 s7, s2, s92
	.loc	1 78 12                         ; kernel.py:78:12
	v_and_b32_e32 v33, 63, v0
	s_lshl_b32 s2, s33, 6
	v_or_b32_e32 v1, s2, v33
	v_lshrrev_b32_e32 v35, 3, v1
	v_or_b32_e32 v36, 32, v35
	s_and_b32 s93, s2, 0x80
	s_and_b32 s10, s2, 64
	s_bfe_i32 s6, s6, 0x10006
	s_lshr_b32 s11, s10, 1
	.loc	1 79 10                         ; kernel.py:79:10
	v_lshrrev_b32_e32 v3, 3, v36
	s_lshr_b32 s14, s93, 5
	.loc	1 80 12                         ; kernel.py:80:12
	s_lshl_b32 s95, s8, 3
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[74:75], s[78:79]
	.loc	1 80 24 is_stmt 0               ; kernel.py:80:24
	v_and_b32_e32 v37, 7, v0
	.loc	1 81 14 is_stmt 1               ; kernel.py:81:14
	s_cmp_lt_u32 s33, s92
	.loc	1 83 12                         ; kernel.py:83:12
	v_add_u32_e32 v2, s19, v3
	.loc	1 80 12                         ; kernel.py:80:12
	v_and_or_b32 v4, v35, 7, s95
	.loc	1 81 14                         ; kernel.py:81:14
	s_cselect_b64 vcc, -1, 0
	.loc	1 83 12                         ; kernel.py:83:12
	s_add_i32 s2, s19, s33
	.loc	1 84 17                         ; kernel.py:84:17
	v_mul_lo_u32 v6, v2, s75
	.loc	1 84 61 is_stmt 0               ; kernel.py:84:61
	v_lshlrev_b32_e32 v2, 3, v37
	.loc	1 84 17                         ; kernel.py:84:17
	s_mul_i32 s15, s2, s75
	v_mad_u64_u32 v[4:5], s[2:3], v4, s80, v[2:3]
	.loc	1 84 9                          ; kernel.py:84:9
	v_bfrev_b32_e32 v38, 1
	s_mov_b32 s79, 0x27000
	s_mov_b32 s78, 0x7ffffffe
	v_add_lshl_u32 v5, v4, s15, 1
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s78
	s_mov_b32 s23, s79
	v_cndmask_b32_e32 v5, v38, v5, vcc
	v_add_lshl_u32 v4, v4, v6, 1
	.loc	1 81 14 is_stmt 1               ; kernel.py:81:14
	v_cmp_gt_u32_e32 vcc, s92, v3
	s_load_dwordx2 s[86:87], s[0:1], 0x60
	s_load_dword s2, s[0:1], 0x68
	s_load_dword s80, s[0:1], 0x74
	.loc	1 84 9                          ; kernel.py:84:9
	v_cndmask_b32_e32 v3, v38, v4, vcc
	buffer_load_dwordx4 v[12:15], v5, s[20:23], 0 offen
	buffer_load_dwordx4 v[16:19], v3, s[20:23], 0 offen
	.loc	1 78 12                         ; kernel.py:78:12
	v_and_b32_e32 v3, 31, v0
	v_and_b32_e32 v4, 32, v0
	.loc	1 84 9                          ; kernel.py:84:9
	s_movk_i32 s0, 0x70
	v_lshlrev_b32_e32 v7, 3, v0
	v_lshlrev_b32_e32 v9, 7, v3
	v_lshrrev_b32_e32 v10, 1, v4
	.loc	1 79 10                         ; kernel.py:79:10
	v_bfe_u32 v6, v0, 3, 2
	.loc	1 84 9                          ; kernel.py:84:9
	v_bitop3_b32 v10, v7, v10, s0 bitop3:0x6c
	v_lshlrev_b32_e32 v11, 4, v1
	v_lshl_or_b32 v9, s93, 5, v9
	s_movk_i32 s1, 0x60
	.loc	1 78 12                         ; kernel.py:78:12
	v_lshrrev_b32_e32 v8, 3, v4
	.loc	1 79 10                         ; kernel.py:79:10
	v_or_b32_e32 v39, s14, v6
	.loc	1 84 9                          ; kernel.py:84:9
	v_bitop3_b32 v6, v11, v1, s0 bitop3:0x78
	v_or_b32_e32 v11, v9, v10
	v_bitop3_b32 v9, v9, s1, v10 bitop3:0x36
	.loc	1 78 12                         ; kernel.py:78:12
	v_or_b32_e32 v40, s11, v8
	.loc	1 84 9                          ; kernel.py:84:9
	v_add_u32_e32 v41, 0, v6
	v_add_u32_e32 v6, 0, v11
	v_xad_u32 v8, v11, 32, 0
	.loc	1 78 12                         ; kernel.py:78:12
	v_bfe_i32 v5, v0, 5, 1
	.loc	1 84 9                          ; kernel.py:84:9
	v_xad_u32 v10, v11, 64, 0
	v_add_u32_e32 v9, 0, v9
	v_lshlrev_b32_e32 v1, 1, v1
	s_and_b32 s1, s6, 0x19c0
	s_movk_i32 s3, 0x110
.Ltmp5:
	.loc	1 30 52                         ; kernel.py:30:52 @[ kernel.py:100:25 ]
	s_mul_i32 s0, s83, s8
	v_add_u32_e32 v32, s0, v2
	s_movk_i32 s0, 0x420
	.loc	1 31 52                         ; kernel.py:31:52 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s2, s2, s8
	v_add_u32_e32 v34, s2, v2
	v_lshl_add_u32 v55, v3, 2, 0
	v_lshlrev_b32_e32 v2, 1, v3
	v_and_b32_e32 v3, 0x220, v5
	v_and_b32_e32 v7, 24, v7
.Ltmp6:
	.loc	1 85 10                         ; kernel.py:85:10
	v_add_u32_e32 v44, s7, v39
	.loc	1 87 26                         ; kernel.py:87:26
	s_add_i32 s7, s7, 1
	.loc	1 95 23                         ; kernel.py:95:23
	s_mul_i32 s80, s80, s16
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v46, 26, v40
	.loc	1 78 12                         ; kernel.py:78:12
	v_or_b32_e32 v47, 25, v40
	v_or_b32_e32 v42, 24, v40
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v48, 19, v40
	v_or_b32_e32 v49, 18, v40
	.loc	1 78 12                         ; kernel.py:78:12
	v_or_b32_e32 v50, 17, v40
	v_or_b32_e32 v45, 16, v40
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v51, 11, v40
	v_or_b32_e32 v52, 10, v40
	.loc	1 78 12                         ; kernel.py:78:12
	v_or_b32_e32 v53, 9, v40
	v_or_b32_e32 v54, 8, v40
	.loc	1 87 15                         ; kernel.py:87:15
	s_min_i32 s83, s7, s94
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v56, 3, v40
	v_or_b32_e32 v57, 2, v40
	.loc	1 84 9                          ; kernel.py:84:9
	s_waitcnt vmcnt(1)
	ds_write_b128 v41, v[12:15]
	s_waitcnt vmcnt(0)
	ds_write_b128 v41, v[16:19] offset:4096
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[80:83], v6
	ds_read_b128 v[84:87], v8
	ds_read_b128 v[88:91], v10
	ds_read_b128 v[92:95], v9
	v_bfe_i32 v8, v0, 4, 1
	v_lshlrev_b32_e32 v6, 5, v37
	v_and_b32_e32 v8, 0x420, v8
	v_and_b32_e32 v9, 0x1180, v5
	v_and_or_b32 v1, v1, s3, v6
	v_bitop3_b32 v6, v8, s1, v9 bitop3:0x36
	v_xor_b32_e32 v1, v6, v1
	v_lshlrev_b32_e32 v6, 4, v0
	v_bfe_i32 v9, v0, 2, 1
	v_bfe_i32 v10, v0, 3, 1
	v_and_b32_e32 v6, 0x110, v6
	v_bfe_i32 v8, v0, 1, 1
	v_and_b32_e32 v9, 0x1180, v9
	v_and_b32_e32 v10, 0x19c0, v10
	v_and_or_b32 v6, v8, s0, v6
	v_bitop3_b32 v4, v10, v9, v4 bitop3:0x36
	s_lshl_b32 s1, s10, 3
	v_xor_b32_e32 v8, v4, v6
	v_mov_b32_e32 v9, 0x80
	v_mov_b32_e32 v10, 0xc0
	v_bitop3_b32 v4, s1, v4, v6 bitop3:0xf6
	v_bitop3_b32 v6, s1, 64, v8 bitop3:0x36
	v_bitop3_b32 v9, s1, v9, v8 bitop3:0x36
	v_bitop3_b32 v8, s1, v10, v8 bitop3:0x36
	s_lshl_b32 s0, s10, 6
	s_lshr_b32 s1, s93, 1
	v_bitop3_b32 v2, s0, v3, v2 bitop3:0xf6
	v_mov_b32_e32 v5, s1
	s_movk_i32 s0, 0x50
	v_or_b32_e32 v3, s1, v2
	v_bitop3_b32 v10, v2, 16, s1 bitop3:0x36
	v_bitop3_b32 v11, v2, 64, s1 bitop3:0x36
	v_bitop3_b32 v2, v2, s0, v5 bitop3:0x36
	v_lshlrev_b32_e32 v5, 5, v0
	v_lshlrev_b32_e32 v0, 1, v0
	v_and_b32_e32 v5, 0x580, v5
	v_and_b32_e32 v0, 0x70, v0
	v_bitop3_b32 v0, v5, v0, v7 bitop3:0x36
	v_xor_b32_e32 v5, s1, v0
	v_xor_b32_e32 v0, s10, v0
	v_xor_b32_e32 v7, 32, v5
	v_xor_b32_e32 v12, 32, v0
	v_mov_b32_e32 v14, 0
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v58, 1, v40
	s_and_b32 s77, s77, 0xffff
	s_and_b32 s5, s5, 0xffff
	s_and_b32 s89, s89, 0xffff
	s_lshl_b32 s96, s33, 7
	s_lshl_b32 s97, s93, 1
	v_lshl_add_u32 v43, v33, 2, 0
.Ltmp7:
	.loc	1 40 22                         ; kernel.py:40:22 @[ kernel.py:100:25 ]
	s_mov_b32 s75, s74
	v_mov_b32_e32 v72, 0
	v_add_u32_e32 v59, 0, v1
	v_add_u32_e32 v60, 0, v4
	v_add_u32_e32 v61, 0, v6
	v_add_u32_e32 v62, 0, v9
	v_add_u32_e32 v63, 0, v8
	s_mov_b32 s98, 0xff800000
	v_add_u32_e32 v64, 0, v3
	v_add_u32_e32 v65, 0, v10
	v_add_u32_e32 v66, 0, v11
	v_add_u32_e32 v67, 0, v2
	v_add_u32_e32 v68, 0, v5
	v_add_u32_e32 v69, 0, v7
	v_add_u32_e32 v70, 0, v0
	v_add_u32_e32 v71, 0, v12
	v_mov_b32_e32 v15, v14
	v_mov_b32_e32 v12, v14
	v_mov_b32_e32 v13, v14
	v_mov_b32_e32 v10, v14
	v_mov_b32_e32 v11, v14
	v_mov_b32_e32 v8, v14
	v_mov_b32_e32 v9, v14
	v_mov_b32_e32 v6, v14
	v_mov_b32_e32 v7, v14
	v_mov_b32_e32 v4, v14
	v_mov_b32_e32 v5, v14
	v_mov_b32_e32 v2, v14
	v_mov_b32_e32 v3, v14
	v_mov_b32_e32 v0, v14
	v_mov_b32_e32 v1, v14
	v_mov_b32_e32 v74, 0xff800000
	v_mov_b32_e32 v73, 0xff800000
	s_branch .LBB0_4
.LBB0_3:                                ;   in Loop: Header=BB0_4 Depth=1
	.loc	1 0 0 is_stmt 0                 ; kernel.py:0 @[ kernel.py:100:25 ]
	v_mul_lo_u32 v75, v75, s86
	v_mul_lo_u32 v96, v76, s86
	v_mad_u64_u32 v[76:77], s[6:7], v77, s87, v[34:35]
	v_mad_u64_u32 v[78:79], s[6:7], v78, s87, v[34:35]
	v_add_lshl_u32 v75, v76, v75, 1
	v_cndmask_b32_e64 v75, v38, v75, s[0:1]
	s_mov_b32 s90, s78
	s_mov_b32 s91, s79
	v_add_lshl_u32 v76, v78, v96, 1
	v_cndmask_b32_e64 v76, v38, v76, s[2:3]
	buffer_load_dwordx4 v[102:105], v75, s[88:91], 0 offen
	buffer_load_dwordx4 v[106:109], v76, s[88:91], 0 offen
.Ltmp8:
	.loc	2 196 12 is_stmt 1              ; standard.py:196:12 @[ standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ] ]
	v_max_f32_e32 v75, v17, v17
	v_max_f32_e32 v76, v16, v16
	v_max_f32_e32 v75, v76, v75
	v_max3_f32 v76, v19, v20, v21
	v_max3_f32 v78, v25, v26, v27
	v_max3_f32 v79, v28, v29, v30
	v_max3_f32 v77, v22, v23, v24
	v_max3_f32 v75, v75, v18, v76
	v_max3_f32 v76, v78, v79, v31
	v_max3_f32 v75, v75, v77, v76
.Ltmp9:
	.loc	2 216 16                        ; standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ]
	v_mov_b32_e32 v76, v75
	s_nop 1
	v_permlane32_swap_b32_e32 v75, v76
.Ltmp10:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ] ]
	v_max_f32_e32 v76, v76, v76
	v_max_f32_e32 v75, v75, v75
	v_max_f32_e32 v75, v75, v76
.Ltmp11:
	.loc	2 216 16                        ; standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ]
	v_add_u32_e32 v100, s96, v55
	v_add_u32_e32 v101, s97, v43
	s_barrier
	ds_write_b32 v100, v75
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v75, v101
.Ltmp12:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	s_waitcnt lgkmcnt(0)
	s_barrier
.Ltmp13:
	.loc	1 99 5                          ; kernel.py:99:5
	s_cmp_lt_i32 s99, s94
.Ltmp14:
	.loc	2 216 16                        ; standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ]
	v_mov_b32_e32 v76, v75
	s_nop 1
	v_permlane32_swap_b32_e32 v75, v76
.Ltmp15:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ kernel.py:38:29 @[ kernel.py:100:25 ] ] ]
	v_max_f32_e32 v76, v76, v76
	v_max_f32_e32 v75, v75, v75
	v_max_f32_e32 v75, v75, v76
.Ltmp16:
	.loc	1 38 29                         ; kernel.py:38:29 @[ kernel.py:100:25 ]
	v_mul_f32_e32 v75, s74, v75
	.loc	1 38 13 is_stmt 0               ; kernel.py:38:13 @[ kernel.py:100:25 ]
	v_max_f32_e32 v76, v74, v74
	v_max_f32_e32 v75, v76, v75
	.loc	1 39 14 is_stmt 1               ; kernel.py:39:14 @[ kernel.py:100:25 ]
	v_cmp_neq_f32_e32 vcc, s98, v75
	s_mov_b32 s9, s99
	s_nop 0
	v_cndmask_b32_e32 v76, 0, v75, vcc
	.loc	1 40 22                         ; kernel.py:40:22 @[ kernel.py:100:25 ]
	v_pk_fma_f32 v[16:17], s[74:75], v[16:17], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[18:19], s[74:75], v[18:19], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[20:21], s[74:75], v[20:21], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[22:23], s[74:75], v[22:23], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[24:25], s[74:75], v[24:25], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[26:27], s[74:75], v[26:27], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[28:29], s[74:75], v[28:29], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	v_pk_fma_f32 v[30:31], s[74:75], v[30:31], v[76:77] op_sel_hi:[1,1,0] neg_lo:[0,0,1] neg_hi:[0,0,1]
	.loc	1 40 9 is_stmt 0                ; kernel.py:40:9 @[ kernel.py:100:25 ]
	v_exp_f32_e32 v16, v16
	v_exp_f32_e32 v17, v17
	v_exp_f32_e32 v18, v18
	v_exp_f32_e32 v19, v19
	v_exp_f32_e32 v20, v20
	v_exp_f32_e32 v21, v21
	v_exp_f32_e32 v22, v22
	v_exp_f32_e32 v23, v23
	v_exp_f32_e32 v24, v24
	v_exp_f32_e32 v25, v25
	v_exp_f32_e32 v26, v26
	v_exp_f32_e32 v27, v27
	v_exp_f32_e32 v28, v28
	v_exp_f32_e32 v29, v29
	v_exp_f32_e32 v30, v30
	v_exp_f32_e32 v31, v31
	.loc	1 41 26 is_stmt 1               ; kernel.py:41:26 @[ kernel.py:100:25 ]
	v_sub_f32_e32 v74, v74, v76
.Ltmp17:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	v_pk_add_f32 v[76:77], v[16:17], v[18:19]
	v_pk_add_f32 v[78:79], v[20:21], v[22:23]
	v_pk_add_f32 v[96:97], v[24:25], v[26:27]
	v_pk_add_f32 v[98:99], v[28:29], v[30:31]
	v_pk_add_f32 v[76:77], v[76:77], v[78:79]
	v_pk_add_f32 v[78:79], v[96:97], v[98:99]
.Ltmp18:
	.loc	1 43 41                         ; kernel.py:43:41 @[ kernel.py:100:25 ]
	v_cvt_pk_bf16_f32 v16, v16, v17
.Ltmp19:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	v_pk_add_f32 v[76:77], v[76:77], v[78:79]
.Ltmp20:
	.loc	1 43 41                         ; kernel.py:43:41 @[ kernel.py:100:25 ]
	v_cvt_pk_bf16_f32 v17, v18, v19
.Ltmp21:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ] ]
	v_add_f32_e32 v76, v76, v77
.Ltmp22:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	v_mov_b32_e32 v77, v76
	s_nop 1
	v_permlane32_swap_b32_e32 v76, v77
.Ltmp23:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ] ]
	v_add_f32_e32 v76, v76, v77
.Ltmp24:
	.loc	1 43 41                         ; kernel.py:43:41 @[ kernel.py:100:25 ]
	v_cvt_pk_bf16_f32 v18, v20, v21
	v_cvt_pk_bf16_f32 v19, v22, v23
	v_cvt_pk_bf16_f32 v20, v24, v25
	v_cvt_pk_bf16_f32 v21, v26, v27
	v_cvt_pk_bf16_f32 v22, v28, v29
	v_cvt_pk_bf16_f32 v23, v30, v31
	.loc	1 41 13                         ; kernel.py:41:13 @[ kernel.py:100:25 ]
	v_exp_f32_e32 v74, v74
.Ltmp25:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	ds_write_b32 v100, v76
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v76, v101
.Ltmp26:
	.loc	1 43 41                         ; kernel.py:43:41 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b16 v64, v16
	ds_write_b16_d16_hi v64, v16 offset:128
	ds_write_b16 v64, v20 offset:2048
	ds_write_b16_d16_hi v64, v20 offset:2176
	ds_write_b16 v65, v17 offset:256
	ds_write_b16_d16_hi v65, v17 offset:384
	ds_write_b16 v65, v21 offset:2304
	ds_write_b16_d16_hi v65, v21 offset:2432
	ds_write_b16 v66, v18 offset:1024
	ds_write_b16_d16_hi v66, v18 offset:1152
	ds_write_b16 v66, v22 offset:3072
	ds_write_b16_d16_hi v66, v22 offset:3200
	ds_write_b16 v67, v19 offset:1280
	ds_write_b16_d16_hi v67, v19 offset:1408
	ds_write_b16 v67, v23 offset:3328
	ds_write_b16_d16_hi v67, v23 offset:3456
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[16:17], v68
	ds_read_b64_tr_b16 v[20:21], v68 offset:2048
	ds_read_b64_tr_b16 v[24:25], v68 offset:4096
	ds_read_b64_tr_b16 v[28:29], v68 offset:6144
	ds_read_b64_tr_b16 v[18:19], v69 offset:512
	ds_read_b64_tr_b16 v[22:23], v69 offset:2560
	ds_read_b64_tr_b16 v[26:27], v69 offset:4608
	ds_read_b64_tr_b16 v[30:31], v69 offset:6656
	.loc	1 31 10                         ; kernel.py:31:10 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(1)
	ds_write_b128 v41, v[102:105]
	s_waitcnt vmcnt(0)
	ds_write_b128 v41, v[106:109] offset:4096
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[96:97], v70
	ds_read_b64_tr_b16 v[98:99], v71 offset:512
	.loc	1 43 11                         ; kernel.py:43:11 @[ kernel.py:100:25 ]
	v_pk_mul_f32 v[0:1], v[0:1], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[74:75] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[74:75] op_sel_hi:[1,0]
	.loc	1 31 10                         ; kernel.py:31:10 @[ kernel.py:100:25 ]
	ds_read_b64_tr_b16 v[100:101], v70 offset:2048
	ds_read_b64_tr_b16 v[104:105], v70 offset:4096
	ds_read_b64_tr_b16 v[108:109], v70 offset:6144
	ds_read_b64_tr_b16 v[102:103], v71 offset:2560
	ds_read_b64_tr_b16 v[106:107], v71 offset:4608
	ds_read_b64_tr_b16 v[110:111], v71 offset:6656
	.loc	1 43 34                         ; kernel.py:43:34 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[96:99], v[16:19], v[0:15]
.Ltmp27:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ]
	v_mov_b32_e32 v16, v76
	s_nop 1
	v_permlane32_swap_b32_e32 v76, v16
.Ltmp28:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:42:25 @[ kernel.py:100:25 ] ] ]
	v_add_f32_e32 v16, v76, v16
.Ltmp29:
	.loc	1 42 11                         ; kernel.py:42:11 @[ kernel.py:100:25 ]
	v_fmac_f32_e32 v16, v72, v74
	v_mov_b32_e32 v72, v16
	v_mov_b32_e32 v74, v75
	.loc	1 43 34                         ; kernel.py:43:34 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[100:103], v[20:23], v[0:15]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[104:107], v[24:27], v[0:15]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[0:15], v[108:111], v[28:31], v[0:15]
.Ltmp30:
	.loc	1 99 5                          ; kernel.py:99:5
	s_cbranch_scc0 .LBB0_6
.LBB0_4:                                ; =>This Inner Loop Header: Depth=1
.Ltmp31:
	.loc	1 26 11                         ; kernel.py:26:11 @[ kernel.py:100:25 ]
	v_add_u32_e32 v16, s9, v35
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_add_u32_e32 v17, s9, v36
	.loc	1 28 28                         ; kernel.py:28:28 @[ kernel.py:100:25 ]
	v_ashrrev_i32_e32 v18, 31, v16
	v_lshrrev_b32_e32 v18, 28, v18
	v_ashrrev_i32_e32 v20, 31, v17
	v_add_u32_e32 v18, v16, v18
	v_lshrrev_b32_e32 v20, 28, v20
	v_ashrrev_i32_e32 v19, 4, v18
	v_add_u32_e32 v20, v17, v20
	v_ashrrev_i32_e32 v21, 4, v20
	.loc	1 28 11 is_stmt 0               ; kernel.py:28:11 @[ kernel.py:100:25 ]
	v_add_lshl_u32 v19, v19, s80, 2
	.loc	1 27 14 is_stmt 1               ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[0:1], s94, v16
	.loc	1 28 11                         ; kernel.py:28:11 @[ kernel.py:100:25 ]
	v_add_lshl_u32 v21, v21, s80, 2
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[2:3], s94, v17
	.loc	1 28 11                         ; kernel.py:28:11 @[ kernel.py:100:25 ]
	v_cndmask_b32_e64 v19, v38, v19, s[0:1]
	.loc	1 29 12                         ; kernel.py:29:12 @[ kernel.py:100:25 ]
	v_and_b32_e32 v18, -16, v18
	.loc	1 28 11                         ; kernel.py:28:11 @[ kernel.py:100:25 ]
	v_cndmask_b32_e64 v21, v38, v21, s[2:3]
	buffer_load_dword v75, v19, s[76:79], 0 offen
	buffer_load_dword v76, v21, s[76:79], 0 offen
	.loc	1 29 12                         ; kernel.py:29:12 @[ kernel.py:100:25 ]
	v_and_b32_e32 v19, -16, v20
	v_sub_u32_e32 v77, v16, v18
	v_sub_u32_e32 v78, v17, v19
	.loc	1 30 18                         ; kernel.py:30:18 @[ kernel.py:100:25 ]
	v_mad_u64_u32 v[16:17], s[10:11], v77, s82, v[32:33]
	v_mad_u64_u32 v[18:19], s[10:11], v78, s82, v[32:33]
	.loc	1 30 10 is_stmt 0               ; kernel.py:30:10 @[ kernel.py:100:25 ]
	s_mov_b32 s6, s78
	s_mov_b32 s7, s79
	.loc	1 33 9 is_stmt 1                ; kernel.py:33:9 @[ kernel.py:100:25 ]
	s_cmp_gt_i32 s9, -1
	.loc	1 30 18                         ; kernel.py:30:18 @[ kernel.py:100:25 ]
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v17, v75, s81
	s_waitcnt vmcnt(0)
	v_mul_lo_u32 v19, v76, s81
	.loc	1 30 10 is_stmt 0               ; kernel.py:30:10 @[ kernel.py:100:25 ]
	v_add_lshl_u32 v16, v16, v17, 1
	v_add_lshl_u32 v17, v18, v19, 1
	v_cndmask_b32_e64 v16, v38, v16, s[0:1]
	v_cndmask_b32_e64 v17, v38, v17, s[2:3]
	buffer_load_dwordx4 v[18:21], v16, s[4:7], 0 offen
	buffer_load_dwordx4 v[22:25], v17, s[4:7], 0 offen
	.loc	1 32 20 is_stmt 1               ; kernel.py:32:20 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 33 9                          ; kernel.py:33:9 @[ kernel.py:100:25 ]
	s_cselect_b64 s[6:7], -1, 0
	.loc	1 33 29 is_stmt 0               ; kernel.py:33:29 @[ kernel.py:100:25 ]
	s_add_i32 s99, s9, 64
	s_cmp_le_i32 s99, s83
	s_cselect_b64 s[10:11], -1, 0
	.loc	1 33 5                          ; kernel.py:33:5 @[ kernel.py:100:25 ]
	s_and_b64 s[6:7], s[6:7], s[10:11]
	s_and_b64 vcc, exec, s[6:7]
	.loc	1 32 20 is_stmt 1               ; kernel.py:32:20 @[ kernel.py:100:25 ]
	s_waitcnt vmcnt(1)
	ds_write_b128 v59, v[18:21]
	s_waitcnt vmcnt(0)
	ds_write_b128 v59, v[22:25] offset:512
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[96:99], v60
	ds_read_b128 v[100:103], v61
	.loc	1 32 10 is_stmt 0               ; kernel.py:32:10 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[96:99], v[80:83], 0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[84:87], v[16:31]
	.loc	1 32 20                         ; kernel.py:32:20 @[ kernel.py:100:25 ]
	ds_read_b128 v[96:99], v62
	ds_read_b128 v[100:103], v63
	.loc	1 32 10                         ; kernel.py:32:10 @[ kernel.py:100:25 ]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[96:99], v[88:91], v[16:31]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[16:31], v[100:103], v[92:95], v[16:31]
	.loc	1 33 5 is_stmt 1                ; kernel.py:33:5 @[ kernel.py:100:25 ]
	s_cbranch_vccnz .LBB0_3
.Ltmp32:
; %bb.5:                                ;   in Loop: Header=BB0_4 Depth=1
	.loc	1 99 5                          ; kernel.py:99:5
	v_or_b32_e32 v79, 27, v40
.Ltmp33:
	.loc	1 26 11                         ; kernel.py:26:11 @[ kernel.py:100:25 ]
	v_or_b32_e32 v110, s9, v40
	v_or_b32_e32 v79, s9, v79
	v_or_b32_e32 v96, s9, v46
	v_or_b32_e32 v97, s9, v47
	v_or_b32_e32 v98, s9, v42
	v_or_b32_e32 v99, s9, v48
	v_or_b32_e32 v100, s9, v49
	v_or_b32_e32 v101, s9, v50
	v_or_b32_e32 v102, s9, v45
	v_or_b32_e32 v103, s9, v51
	v_or_b32_e32 v104, s9, v52
	v_or_b32_e32 v105, s9, v53
	v_or_b32_e32 v106, s9, v54
	v_or_b32_e32 v107, s9, v56
	v_or_b32_e32 v108, s9, v57
	v_or_b32_e32 v109, s9, v58
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e32 vcc, s94, v110
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[8:9], v110, v44
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[6:7], s94, v109
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[10:11], v109, v44
	.loc	1 34 15 is_stmt 0               ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[8:9], vcc
	.loc	1 27 14 is_stmt 1               ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[14:15], s94, v108
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[20:21], v108, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v16, v73, v16, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[10:11], s[6:7]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[16:17], s94, v107
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[22:23], v107, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v17, v73, v17, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[20:21], s[14:15]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[24:25], s94, v106
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[28:29], v106, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v18, v73, v18, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[22:23], s[16:17]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[26:27], s94, v105
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[30:31], v105, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v19, v73, v19, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[28:29], s[24:25]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[34:35], s94, v104
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[38:39], v104, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v20, v73, v20, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[30:31], s[26:27]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[36:37], s94, v103
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[40:41], v103, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v21, v73, v21, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[38:39], s[34:35]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[42:43], s94, v102
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[46:47], v102, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v22, v73, v22, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[40:41], s[36:37]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[44:45], s94, v101
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[48:49], v101, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v23, v73, v23, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[46:47], s[42:43]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[50:51], s94, v100
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[54:55], v100, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v24, v73, v24, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[48:49], s[44:45]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[52:53], s94, v99
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[56:57], v99, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v25, v73, v25, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[54:55], s[50:51]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[58:59], s94, v98
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[62:63], v98, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v26, v73, v26, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[56:57], s[52:53]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[60:61], s94, v97
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[64:65], v97, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v27, v73, v27, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[62:63], s[58:59]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[66:67], s94, v96
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[70:71], v96, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v28, v73, v28, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[64:65], s[60:61]
	.loc	1 27 14                         ; kernel.py:27:14 @[ kernel.py:100:25 ]
	v_cmp_gt_i32_e64 s[68:69], s94, v79
	.loc	1 34 16                         ; kernel.py:34:16 @[ kernel.py:100:25 ]
	v_cmp_le_i32_e64 s[72:73], v79, v44
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v29, v73, v29, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[70:71], s[66:67]
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v30, v73, v30, vcc
	.loc	1 34 15                         ; kernel.py:34:15 @[ kernel.py:100:25 ]
	s_and_b64 vcc, s[72:73], s[68:69]
	.loc	1 37 14                         ; kernel.py:37:14 @[ kernel.py:100:25 ]
	v_cndmask_b32_e32 v31, v73, v31, vcc
	s_branch .LBB0_3
.Ltmp34:
.LBB0_6:
	.loc	1 80 12                         ; kernel.py:80:12
	v_or_b32_e32 v18, s95, v37
	.loc	1 116 18                        ; kernel.py:116:18
	v_add_lshl_u32 v19, v39, s19, 17
	v_lshlrev_b32_e32 v20, 13, v18
	s_lshl_b32 s0, s18, 6
	v_add3_u32 v19, v20, s0, v19
	v_or_b32_e32 v20, v19, v40
	.loc	1 116 9 is_stmt 0               ; kernel.py:116:9
	v_lshlrev_b32_e32 v20, 2, v20
	v_bfrev_b32_e32 v23, 1
	.loc	1 81 14 is_stmt 1               ; kernel.py:81:14
	v_cmp_gt_u32_e64 s[0:1], s92, v39
	.loc	1 116 18                        ; kernel.py:116:18
	v_or_b32_e32 v21, v19, v54
	.loc	1 116 9 is_stmt 0               ; kernel.py:116:9
	s_and_b32 s85, s85, 0xffff
	s_mov_b32 s87, 0x27000
	s_mov_b32 s86, 0x7ffffffe
	v_cndmask_b32_e64 v20, v23, v20, s[0:1]
	buffer_store_dwordx4 v[0:3], v20, s[84:87], 0 offen
	.loc	1 116 18                        ; kernel.py:116:18
	v_or_b32_e32 v22, v19, v45
	v_or_b32_e32 v19, v19, v42
	.loc	1 116 9                         ; kernel.py:116:9
	v_lshlrev_b32_e32 v0, 2, v21
	v_cndmask_b32_e64 v0, v23, v0, s[0:1]
	buffer_store_dwordx4 v[4:7], v0, s[84:87], 0 offen
	v_lshlrev_b32_e32 v0, 2, v22
	v_cndmask_b32_e64 v0, v23, v0, s[0:1]
	buffer_store_dwordx4 v[8:11], v0, s[84:87], 0 offen
	v_lshlrev_b32_e32 v0, 2, v19
	.loc	1 79 10 is_stmt 1               ; kernel.py:79:10
	v_lshrrev_b32_e32 v17, 3, v33
	.loc	1 116 9                         ; kernel.py:116:9
	v_cndmask_b32_e64 v0, v23, v0, s[0:1]
	buffer_store_dwordx4 v[12:15], v0, s[84:87], 0 offen
	.loc	1 117 18                        ; kernel.py:117:18
	v_add_lshl_u32 v0, s19, v17, 14
	v_lshlrev_b32_e32 v1, 10, v18
	s_lshl_b32 s0, s18, 3
	v_add3_u32 v0, v1, s0, v0
	.loc	1 117 9 is_stmt 0               ; kernel.py:117:9
	v_add_u32_e32 v1, s93, v55
	s_barrier
	ds_write_b32 v1, v75
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v3, v43
	s_and_b32 s13, s13, 0xffff
	s_cmp_eq_u32 s33, 0
	.loc	1 81 14 is_stmt 1               ; kernel.py:81:14
	v_cmp_gt_u32_e32 vcc, s92, v17
	.loc	1 117 9                         ; kernel.py:117:9
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 vcc, s[0:1], vcc
	s_mov_b32 s14, s86
	s_mov_b32 s15, s87
	v_cndmask_b32_e32 v2, v23, v0, vcc
	s_waitcnt lgkmcnt(0)
	buffer_store_dword v3, v2, s[12:15], 0 offen
	.loc	1 118 9                         ; kernel.py:118:9
	s_barrier
	ds_write_b32 v1, v16
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v1, v43
	v_or_b32_e32 v0, 4, v0
	v_cndmask_b32_e32 v0, v23, v0, vcc
	s_waitcnt lgkmcnt(0)
	buffer_store_dword v1, v0, s[12:15], 0 offen
.LBB0_7:                                ; %common.ret
	.loc	1 0 0 is_stmt 0                 ; kernel.py:0
	s_endpgm
.Ltmp35:
.Lfunc_end0:
	.size	_attn_segment, .Lfunc_end0-_attn_segment
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _attn_segment
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 136
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
		.amdhsa_next_free_vgpr 112
		.amdhsa_next_free_sgpr 100
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
                                        ; -- End function
	.set .L_attn_segment.num_vgpr, 112
	.set .L_attn_segment.num_agpr, 0
	.set .L_attn_segment.numbered_sgpr, 100
	.set .L_attn_segment.num_named_barrier, 0
	.set .L_attn_segment.private_seg_size, 0
	.set .L_attn_segment.uses_vcc, 1
	.set .L_attn_segment.uses_flat_scratch, 0
	.set .L_attn_segment.has_dyn_sized_stack, 0
	.set .L_attn_segment.has_recursion, 0
	.set .L_attn_segment.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 3648
; TotalNumSgprs: 106
; NumVgprs: 112
; NumAgprs: 0
; TotalNumVgprs: 112
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 13
; VGPRBlocks: 13
; NumSGPRsForWavesPerEU: 106
; NumVGPRsForWavesPerEU: 112
; AccumOffset: 112
; Occupancy: 4
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 1
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
	.byte	11                              ; DW_FORM_data1
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	5                               ; Abbreviation Code
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
	.byte	6                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	0                               ; DW_CHILDREN_no
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
	.byte	7                               ; Abbreviation Code
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
	.byte	1                               ; Abbrev [1] 0xb:0xa0 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x7a DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	71                              ; DW_AT_call_line
	.byte	16                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x55:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp3                          ; DW_AT_low_pc
	.long	.Ltmp4-.Ltmp3                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	72                              ; DW_AT_call_line
	.byte	15                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x69:0x40 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	100                             ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x75:0x19 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	38                              ; DW_AT_call_line
	.byte	29                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x81:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.byte	216                             ; DW_AT_call_line
	.byte	16                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	5                               ; Abbrev [5] 0x8e:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges3                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	42                              ; DW_AT_call_line
	.byte	25                              ; DW_AT_call_column
	.byte	7                               ; Abbrev [7] 0x9a:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges4                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp30-.Lfunc_begin0
	.quad	.Ltmp31-.Lfunc_begin0
	.quad	.Ltmp32-.Lfunc_begin0
	.quad	.Ltmp33-.Lfunc_begin0
	.quad	.Ltmp34-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges3:
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	.Ltmp26-.Lfunc_begin0
	.quad	.Ltmp27-.Lfunc_begin0
	.quad	.Ltmp29-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges4:
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp28-.Lfunc_begin0
	.quad	.Ltmp29-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/unified_segment"   ; string offset=17 ; /work/build/unified_segment
.Linfo_string3:
	.asciz	"_attn_segment"                 ; string offset=45 ; _attn_segment
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
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     global_buffer
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
      - .address_space:  global
        .offset:         120
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         128
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 136
    .max_flat_workgroup_size: 256
    .name:           _attn_segment
    .private_segment_fixed_size: 0
    .sgpr_count:     106
    .sgpr_spill_count: 0
    .symbol:         _attn_segment.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     112
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
