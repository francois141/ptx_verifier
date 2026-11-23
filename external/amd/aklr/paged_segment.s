; AKLR 766a200e367f aklr/ops/attention/impls/triton/paged_attention_decode_kv_split_pages_n_heads16_n_kv_heads2_head_dim64_block_size16/6070d2d9cef49ec6.json, compiled for gfx950 by
; external/amd/aklr/build.py (case paged_segment).
; dynamic LDS: 8192 bytes
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_segment                        ; -- Begin function _segment
	.p2align	8
	.type	_segment,@function
_segment:                               ; @_segment
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.7:
	.file	1 "/work/build/paged_segment" "kernel.py"
	.loc	1 39 0 prologue_end             ; kernel.py:39:0
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
	s_mov_b32 s18, s17
.Ltmp1:
	.loc	1 49 9 is_stmt 1                ; kernel.py:49:9
	s_ashr_i32 s17, s16, 31
	s_mov_b64 s[20:21], s[2:3]
	s_lshl_b64 s[2:3], s[16:17], 2
	s_add_u32 s2, s12, s2
	s_addc_u32 s3, s13, s3
	s_mov_b64 s[52:53], s[6:7]
	s_load_dword s6, s[0:1], 0x3c
	s_load_dword s7, s[2:3], 0x0
	s_mov_b64 s[44:45], s[10:11]
.Ltmp2:
	.loc	1 28 5                          ; kernel.py:28:5 @[ kernel.py:50:19 ]
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s17, s7, s6
	s_max_i32 s2, s17, 0
	.loc	1 30 10                         ; kernel.py:30:10 @[ kernel.py:50:19 ]
	s_and_b32 s10, s2, 0x7fffffe0
	.loc	1 28 8                          ; kernel.py:28:8 @[ kernel.py:50:19 ]
	s_cmp_gt_i32 s6, 0
	s_cselect_b64 s[46:47], -1, 0
	.loc	1 28 5 is_stmt 0                ; kernel.py:28:5 @[ kernel.py:50:19 ]
	s_and_b64 s[2:3], s[46:47], exec
	s_cselect_b32 s33, s10, 0
.Ltmp3:
	.loc	1 51 19 is_stmt 1               ; kernel.py:51:19
	s_lshl_b32 s2, s18, 6
	.loc	1 51 14 is_stmt 0               ; kernel.py:51:14
	s_add_i32 s90, s33, s2
	.loc	1 52 25 is_stmt 1               ; kernel.py:52:25
	s_add_i32 s2, s90, 64
	.loc	1 52 14 is_stmt 0               ; kernel.py:52:14
	s_min_i32 s91, s2, s7
	.loc	1 53 8 is_stmt 1                ; kernel.py:53:8
	s_cmp_lt_i32 s90, s91
	.loc	1 89 5                          ; kernel.py:89:5
	v_readfirstlane_b32 s2, v0
	.loc	1 53 8                          ; kernel.py:53:8
	s_cbranch_scc0 .LBB0_6
; %bb.1:
	.loc	1 0 8 is_stmt 0                 ; kernel.py:0:8
	s_load_dwordx8 s[36:43], s[0:1], 0x40
	.loc	1 89 5 is_stmt 1                ; kernel.py:89:5
	s_bfe_u32 s19, s2, 0x10006
	.loc	1 56 12                         ; kernel.py:56:12
	v_and_b32_e32 v1, 63, v0
	s_lshl_b32 s3, s19, 6
	v_or_b32_e32 v3, s3, v1
	.loc	1 58 70                         ; kernel.py:58:70
	v_and_b32_e32 v4, 7, v0
	.loc	1 57 9                          ; kernel.py:57:9
	v_lshrrev_b32_e32 v40, 3, v3
	.loc	1 58 25                         ; kernel.py:58:25
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s6, s36, s16
	.loc	1 58 70 is_stmt 0               ; kernel.py:58:70
	v_lshlrev_b32_e32 v42, 3, v4
	.loc	1 58 17                         ; kernel.py:58:17
	v_mul_lo_u32 v2, v40, s37
	v_add_u32_e32 v5, s6, v42
	.loc	1 58 9                          ; kernel.py:58:9
	s_mov_b32 s51, 0x27000
	s_mov_b32 s50, 0x7ffffffe
	s_and_b32 s21, s21, 0xffff
	s_mov_b32 s22, s50
	s_mov_b32 s23, s51
	v_add_lshl_u32 v2, v5, v2, 1
	buffer_load_dwordx4 v[20:23], v2, s[20:23], 0 offen
	.loc	1 56 12 is_stmt 1               ; kernel.py:56:12
	v_and_b32_e32 v43, 15, v0
	.loc	1 58 9                          ; kernel.py:58:9
	v_lshlrev_b32_e32 v6, 3, v0
	.loc	1 57 9                          ; kernel.py:57:9
	v_and_b32_e32 v41, 48, v0
	.loc	1 58 70                         ; kernel.py:58:70
	v_mov_b32_e32 v5, 0x70
	.loc	1 62 12                         ; kernel.py:62:12
	v_bfe_u32 v7, v0, 3, 1
	v_bfe_i32 v10, v0, 4, 1
	v_bfe_i32 v11, v0, 5, 1
	v_lshlrev_b32_e32 v16, 5, v0
	s_movk_i32 s10, 0x780
	.loc	1 58 9                          ; kernel.py:58:9
	v_lshlrev_b32_e32 v17, 7, v43
	v_and_b32_e32 v18, 0x70, v6
	v_and_b32_e32 v6, 24, v6
	s_lshl_b32 s11, s19, 5
	s_load_dword s36, s[0:1], 0x38
	s_load_dword s92, s[0:1], 0x60
	v_and_b32_e32 v8, 8, v0
	v_bfe_i32 v9, v0, 3, 1
	s_movk_i32 s6, 0x120
	v_lshlrev_b32_e32 v13, 4, v0
	v_bfe_i32 v14, v0, 1, 1
	v_bfe_i32 v15, v0, 2, 1
	.loc	1 62 11                         ; kernel.py:62:11
	v_cmp_eq_u32_e32 vcc, 0, v7
	v_cmp_ne_u32_e64 s[0:1], 0, v7
	v_and_b32_e32 v7, 0x120, v10
	v_and_b32_e32 v10, 0x4a0, v11
	v_lshlrev_b32_e32 v11, 1, v41
	.loc	1 58 70                         ; kernel.py:58:70
	v_bitop3_b32 v46, s3, v5, v1 bitop3:0xc8
	.loc	1 58 9 is_stmt 0                ; kernel.py:58:9
	v_bitop3_b32 v1, v18, v17, v41 bitop3:0xde
	v_and_or_b32 v6, v16, s10, v6
	v_bitop3_b32 v0, v0, s11, 56 bitop3:0x6c
	v_lshlrev_b32_e32 v3, 4, v3
	.loc	1 89 5 is_stmt 1                ; kernel.py:89:5
	s_bfe_i32 s2, s2, 0x10006
	v_mov_b32_e32 v12, 0x6e0
	v_lshlrev_b32_e32 v4, 5, v4
	v_bitop3_b32 v5, v14, v11, s6 bitop3:0x6c
	.loc	1 58 9                          ; kernel.py:58:9
	v_add_u32_e32 v11, 0, v1
	v_xor_b32_e32 v0, v0, v6
	v_xad_u32 v6, v3, v46, 0
	v_and_b32_e32 v9, 0x6e0, v9
	v_bitop3_b32 v4, v4, s2, v12 bitop3:0x78
	v_xad_u32 v1, v1, 64, 0
	v_and_b32_e32 v15, 0x4a0, v15
	v_xor_b32_e32 v4, v4, v7
	v_xor_b32_e32 v5, v5, v9
	v_lshrrev_b32_e32 v7, 1, v46
	s_movk_i32 s7, 0x80
	v_and_b32_e32 v13, 16, v13
	v_xor_b32_e32 v5, v5, v15
	v_xor_b32_e32 v3, v7, v3
	s_mov_b64 s[48:49], s[14:15]
	v_mov_b32_e32 v2, 0
	v_lshl_add_u32 v8, v8, 1, 0
	v_xor_b32_e32 v4, v4, v10
	v_or_b32_e32 v7, v5, v13
	v_bitop3_b32 v5, v5, s7, v13 bitop3:0x36
	v_xor_b32_e32 v9, 8, v3
	s_and_b32 s49, s49, 0xffff
	s_and_b32 s5, s5, 0xffff
	s_and_b32 s53, s53, 0xffff
	v_mov_b32_e32 v47, 0
	v_mov_b32_e32 v55, 0xff800000
	v_bfrev_b32_e32 v44, 1
	.loc	1 57 9                          ; kernel.py:57:9
	v_lshrrev_b32_e32 v45, 2, v41
	.loc	1 63 23                         ; kernel.py:63:23
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s92, s92, s16
	.loc	1 77 44                         ; kernel.py:77:44
	s_mov_b32 s37, s36
	v_add_u32_e32 v48, v8, v4
	v_add_u32_e32 v49, 0, v7
	v_add_u32_e32 v50, 0, v5
	s_mov_b32 s93, 0xff800000
	v_mov_b32_e32 v51, 0xff800000
	v_add_u32_e32 v52, 0, v3
	v_add_u32_e32 v53, 0, v9
	v_add_u32_e32 v54, 0, v0
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
                                        ; implicit-def: $sgpr56_sgpr57
                                        ; implicit-def: $sgpr58_sgpr59
                                        ; implicit-def: $sgpr60_sgpr61
                                        ; implicit-def: $sgpr62_sgpr63
                                        ; implicit-def: $sgpr64_sgpr65
                                        ; implicit-def: $sgpr66_sgpr67
                                        ; implicit-def: $sgpr68_sgpr69
                                        ; implicit-def: $sgpr70_sgpr71
                                        ; implicit-def: $sgpr72_sgpr73
                                        ; implicit-def: $sgpr74_sgpr75
	.loc	1 58 9                          ; kernel.py:58:9
	s_waitcnt vmcnt(0)
	ds_write_b128 v6, v[20:23]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[56:59], v11
	ds_read_b128 v[60:63], v1
	v_mov_b32_e32 v1, v2
	v_mov_b32_e32 v6, v2
	s_branch .LBB0_3
.LBB0_2:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 72 32                         ; kernel.py:72:32
	v_ashrrev_i32_e32 v10, 31, v9
	v_lshrrev_b32_e32 v10, 28, v10
	v_add_u32_e32 v10, v9, v10
	v_ashrrev_i32_e32 v11, 4, v10
	.loc	1 72 15 is_stmt 0               ; kernel.py:72:15
	v_add_lshl_u32 v11, v11, s92, 2
	.loc	1 72 32                         ; kernel.py:72:32
	v_ashrrev_i32_e32 v12, 31, v8
	.loc	1 72 15                         ; kernel.py:72:15
	v_cndmask_b32_e64 v11, v44, v11, s[74:75]
	.loc	1 72 32                         ; kernel.py:72:32
	v_lshrrev_b32_e32 v12, 28, v12
	.loc	1 72 15                         ; kernel.py:72:15
	buffer_load_dword v11, v11, s[48:51], 0 offen
	.loc	1 72 32                         ; kernel.py:72:32
	v_add_u32_e32 v12, v8, v12
	v_ashrrev_i32_e32 v13, 4, v12
	.loc	1 72 15                         ; kernel.py:72:15
	v_add_lshl_u32 v13, v13, s92, 2
	v_cndmask_b32_e64 v13, v44, v13, s[72:73]
	buffer_load_dword v16, v13, s[48:51], 0 offen
	.loc	1 73 16 is_stmt 1               ; kernel.py:73:16
	v_and_b32_e32 v10, -16, v10
	v_sub_u32_e32 v9, v9, v10
	.loc	1 74 43                         ; kernel.py:74:43
	v_mul_lo_u32 v10, v9, s39
	.loc	1 73 16                         ; kernel.py:73:16
	v_and_b32_e32 v12, -16, v12
	.loc	1 74 14                         ; kernel.py:74:14
	s_mov_b32 s6, s50
	s_mov_b32 s7, s51
	.loc	1 73 16                         ; kernel.py:73:16
	v_sub_u32_e32 v8, v8, v12
	.loc	1 74 43                         ; kernel.py:74:43
	v_mul_lo_u32 v12, v8, s39
	.loc	1 75 43                         ; kernel.py:75:43
	v_mul_lo_u32 v17, v9, s42
	v_mul_lo_u32 v18, v8, s42
	.loc	1 75 14 is_stmt 0               ; kernel.py:75:14
	s_mov_b32 s54, s50
	s_mov_b32 s55, s51
	.loc	1 77 23 is_stmt 1               ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[68:69]
	.loc	1 67 5                          ; kernel.py:67:5
	s_add_i32 s90, s90, 32
	.loc	1 74 22                         ; kernel.py:74:22
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v13, v11, s38
	v_add3_u32 v10, v10, v42, v13
	.loc	1 74 14 is_stmt 0               ; kernel.py:74:14
	v_lshlrev_b32_e32 v13, 1, v10
	v_add_lshl_u32 v10, v10, s40, 1
	v_cndmask_b32_e64 v13, v44, v13, s[74:75]
	v_cndmask_b32_e64 v10, v44, v10, s[74:75]
	buffer_load_dwordx4 v[20:23], v13, s[4:7], 0 offen
	buffer_load_dwordx4 v[28:31], v10, s[4:7], 0 offen
	.loc	1 74 22                         ; kernel.py:74:22
	s_waitcnt vmcnt(2)
	v_mul_lo_u32 v13, v16, s38
	v_add3_u32 v12, v12, v42, v13
	.loc	1 74 14                         ; kernel.py:74:14
	v_lshlrev_b32_e32 v13, 1, v12
	v_add_lshl_u32 v10, v12, s40, 1
	v_cndmask_b32_e64 v13, v44, v13, s[72:73]
	v_cndmask_b32_e64 v10, v44, v10, s[72:73]
	buffer_load_dwordx4 v[24:27], v13, s[4:7], 0 offen
	.loc	1 75 22 is_stmt 1               ; kernel.py:75:22
	v_mul_lo_u32 v19, v11, s41
	.loc	1 74 14                         ; kernel.py:74:14
	buffer_load_dwordx4 v[12:15], v10, s[4:7], 0 offen
	.loc	1 76 24                         ; kernel.py:76:24
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 75 22                         ; kernel.py:75:22
	v_mul_lo_u32 v16, v16, s41
	v_add3_u32 v17, v17, v42, v19
	v_add3_u32 v16, v18, v42, v16
	.loc	1 75 14 is_stmt 0               ; kernel.py:75:14
	v_lshlrev_b32_e32 v18, 1, v17
	v_lshlrev_b32_e32 v19, 1, v16
	v_add_lshl_u32 v17, v17, s43, 1
	v_add_lshl_u32 v16, v16, s43, 1
	v_cndmask_b32_e64 v18, v44, v18, s[74:75]
	v_cndmask_b32_e64 v36, v44, v16, s[72:73]
	.loc	1 76 24 is_stmt 1               ; kernel.py:76:24
	s_waitcnt vmcnt(3)
	ds_write_b128 v48, v[20:23]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[8:11], v49
	ds_read_b128 v[20:23], v50
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(1)
	ds_write_b128 v48, v[24:27]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[24:27], v49
	ds_read_b128 v[64:67], v50
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_write_b128 v48, v[28:31]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[28:31], v49
	ds_read_b128 v[68:71], v50
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write_b128 v48, v[12:15]
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[32:35], v49
	ds_read_b128 v[72:75], v50
	.loc	1 76 14 is_stmt 0               ; kernel.py:76:14
	v_mfma_f32_16x16x32_bf16 v[8:11], v[8:11], v[56:59], 0
	v_mfma_f32_16x16x32_bf16 v[12:15], v[24:27], v[56:59], 0
	v_mfma_f32_16x16x32_bf16 v[24:27], v[28:31], v[56:59], 0
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 v[28:31], v[32:35], v[56:59], 0
	v_mfma_f32_16x16x32_bf16 v[32:35], v[20:23], v[60:63], v[8:11]
	.loc	1 75 14 is_stmt 1               ; kernel.py:75:14
	s_nop 2
	v_cndmask_b32_e64 v8, v44, v19, s[72:73]
	v_cndmask_b32_e64 v9, v44, v17, s[74:75]
	.loc	1 76 14                         ; kernel.py:76:14
	v_mfma_f32_16x16x32_bf16 v[64:67], v[64:67], v[60:63], v[12:15]
	.loc	1 75 14                         ; kernel.py:75:14
	buffer_load_dwordx4 v[16:19], v18, s[52:55], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[20:23], v8, s[52:55], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[8:11], v9, s[52:55], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[12:15], v36, s[52:55], 0 offen
	.loc	1 77 44                         ; kernel.py:77:44
	v_pk_mul_f32 v[38:39], s[36:37], v[32:33]
	v_pk_mul_f32 v[36:37], s[36:37], v[34:35]
	.loc	1 77 14 is_stmt 0               ; kernel.py:77:14
	v_cndmask_b32_e64 v39, v51, v39, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[70:71]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v38, v51, v38, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[64:65]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v37, v51, v37, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[66:67]
	.loc	1 76 14 is_stmt 1               ; kernel.py:76:14
	v_mfma_f32_16x16x32_bf16 v[24:27], v[68:71], v[60:63], v[24:27]
	.loc	1 77 44                         ; kernel.py:77:44
	v_mul_f32_e64 v34, s36, v64
	v_mul_f32_e64 v35, s37, v65
	.loc	1 77 14 is_stmt 0               ; kernel.py:77:14
	v_cndmask_b32_e64 v36, v51, v36, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[60:61]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v35, v51, v35, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[62:63]
	.loc	1 77 44                         ; kernel.py:77:44
	v_pk_mul_f32 v[32:33], s[36:37], v[66:67]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v34, v51, v34, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[56:57]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v33, v51, v33, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], vcc, s[58:59]
	.loc	1 76 14 is_stmt 1               ; kernel.py:76:14
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[68:71], v[72:75], v[60:63], v[28:31]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v32, v51, v32, s[2:3]
	.loc	1 77 23 is_stmt 0               ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[68:69]
	.loc	1 77 44                         ; kernel.py:77:44
	s_nop 0
	v_pk_mul_f32 v[30:31], s[36:37], v[24:25]
	v_pk_mul_f32 v[28:29], s[36:37], v[26:27]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v31, v51, v31, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[70:71]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v30, v51, v30, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[64:65]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v29, v51, v29, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[66:67]
	.loc	1 77 44                         ; kernel.py:77:44
	v_pk_mul_f32 v[26:27], s[36:37], v[68:69]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v28, v51, v28, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[60:61]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v27, v51, v27, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[62:63]
	.loc	1 77 44                         ; kernel.py:77:44
	v_pk_mul_f32 v[24:25], s[36:37], v[70:71]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v26, v51, v26, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[56:57]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v65, v51, v25, s[2:3]
	.loc	1 77 23                         ; kernel.py:77:23
	s_and_b64 s[2:3], s[0:1], s[58:59]
	.loc	1 77 14                         ; kernel.py:77:14
	v_cndmask_b32_e64 v64, v51, v24, s[2:3]
.Ltmp4:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 196 12 is_stmt 1              ; standard.py:196:12 @[ standard.py:216:16 @[ kernel.py:78:33 ] ]
	v_max_f32_e32 v24, v38, v39
	v_max3_f32 v25, v37, v34, v35
	v_max3_f32 v67, v31, v28, v29
	v_max3_f32 v68, v26, v27, v64
	v_max3_f32 v66, v32, v33, v30
	v_max3_f32 v24, v24, v36, v25
	v_max3_f32 v25, v67, v68, v65
	v_max3_f32 v24, v24, v66, v25
.Ltmp5:
	.loc	2 216 16                        ; standard.py:216:16 @[ kernel.py:78:33 ]
	v_mov_b32_e32 v25, v24
	s_nop 1
	v_permlane32_swap_b32_e32 v24, v25
.Ltmp6:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ kernel.py:78:33 ] ]
	v_max_f32_e32 v25, v25, v25
	v_max_f32_e32 v24, v24, v24
	v_max_f32_e32 v24, v24, v25
.Ltmp7:
	.loc	2 216 16                        ; standard.py:216:16 @[ kernel.py:78:33 ]
	v_mov_b32_e32 v25, v24
	s_nop 1
	v_permlane16_swap_b32_e32 v24, v25
.Ltmp8:
	.loc	1 78 17                         ; kernel.py:78:17
	v_max3_f32 v24, v55, v24, v25
	.loc	1 79 18                         ; kernel.py:79:18
	v_cmp_neq_f32_e64 s[2:3], s93, v24
	.loc	1 75 14                         ; kernel.py:75:14
	s_barrier
	.loc	1 79 18                         ; kernel.py:79:18
	s_nop 0
	v_cndmask_b32_e64 v66, 0, v24, s[2:3]
	.loc	1 80 26                         ; kernel.py:80:26
	v_pk_add_f32 v[38:39], v[38:39], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[36:37], v[36:37], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[34:35], v[34:35], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[32:33], v[32:33], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[30:31], v[30:31], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[28:29], v[28:29], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[26:27], v[26:27], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[64:65], v[64:65], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 81 30                         ; kernel.py:81:30
	v_sub_f32_e32 v25, v55, v66
	.loc	1 80 13                         ; kernel.py:80:13
	v_exp_f32_e32 v38, v38
	v_exp_f32_e32 v39, v39
	v_exp_f32_e32 v36, v36
	v_exp_f32_e32 v37, v37
	v_exp_f32_e32 v34, v34
	v_exp_f32_e32 v35, v35
	v_exp_f32_e32 v32, v32
	v_exp_f32_e32 v33, v33
	v_exp_f32_e32 v30, v30
	v_exp_f32_e32 v31, v31
	v_exp_f32_e32 v66, v28
	v_exp_f32_e32 v67, v29
	v_exp_f32_e32 v68, v26
	v_exp_f32_e32 v69, v27
	v_exp_f32_e32 v64, v64
	v_exp_f32_e32 v65, v65
	.loc	1 81 17                         ; kernel.py:81:17
	v_exp_f32_e32 v70, v25
	.loc	1 75 14                         ; kernel.py:75:14
	s_waitcnt vmcnt(2)
	ds_write2st64_b64 v52, v[16:17], v[20:21] offset1:4
	s_waitcnt vmcnt(0)
	ds_write2st64_b64 v52, v[8:9], v[12:13] offset0:8 offset1:12
	ds_write2st64_b64 v53, v[18:19], v[22:23] offset1:4
	ds_write2st64_b64 v53, v[10:11], v[14:15] offset0:8 offset1:12
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[12:13], v54
	ds_read_b64_tr_b16 v[14:15], v54 offset:2048
	ds_read_b64_tr_b16 v[18:19], v54 offset:2112
	ds_read_b64_tr_b16 v[16:17], v54 offset:64
.Ltmp9:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:82:29 ]
	v_pk_add_f32 v[72:73], v[38:39], v[36:37]
	v_pk_add_f32 v[74:75], v[34:35], v[32:33]
	v_pk_add_f32 v[76:77], v[30:31], v[66:67]
	v_pk_add_f32 v[78:79], v[68:69], v[64:65]
	v_pk_add_f32 v[8:9], v[72:73], v[74:75]
	v_pk_add_f32 v[10:11], v[76:77], v[78:79]
.Ltmp10:
	.loc	1 83 15                         ; kernel.py:83:15
	v_pk_mul_f32 v[0:1], v[0:1], v[70:71] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[70:71] op_sel_hi:[1,0]
	.loc	1 83 45 is_stmt 0               ; kernel.py:83:45
	v_cvt_pk_bf16_f32 v26, v38, v39
	v_cvt_pk_bf16_f32 v27, v36, v37
	v_cvt_pk_bf16_f32 v28, v34, v35
	v_cvt_pk_bf16_f32 v29, v32, v33
.Ltmp11:
	.loc	2 314 12 is_stmt 1              ; standard.py:314:12 @[ kernel.py:82:29 ]
	v_pk_add_f32 v[8:9], v[8:9], v[10:11]
.Ltmp12:
	.loc	1 83 15                         ; kernel.py:83:15
	v_pk_mul_f32 v[4:5], v[4:5], v[70:71] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[70:71] op_sel_hi:[1,0]
.Ltmp13:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:82:29 ] ]
	v_add_f32_e32 v8, v8, v9
.Ltmp14:
	.loc	1 75 14                         ; kernel.py:75:14
	ds_read_b64_tr_b16 v[20:21], v54 offset:4096
	ds_read_b64_tr_b16 v[22:23], v54 offset:6144
	.loc	1 83 38                         ; kernel.py:83:38
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[12:15], v[26:29], v[0:3]
	.loc	1 75 14                         ; kernel.py:75:14
	ds_read_b64_tr_b16 v[12:13], v54 offset:6208
	ds_read_b64_tr_b16 v[10:11], v54 offset:4160
.Ltmp15:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:82:29 ]
	v_mov_b32_e32 v9, v8
	s_nop 1
	v_permlane32_swap_b32_e32 v8, v9
.Ltmp16:
	.loc	1 83 38                         ; kernel.py:83:38
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[16:19], v[26:29], v[4:7]
.Ltmp17:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:82:29 ] ]
	v_add_f32_e32 v8, v8, v9
.Ltmp18:
	.loc	1 83 45                         ; kernel.py:83:45
	v_cvt_pk_bf16_f32 v30, v30, v31
	v_cvt_pk_bf16_f32 v31, v66, v67
	v_cvt_pk_bf16_f32 v32, v68, v69
	v_cvt_pk_bf16_f32 v33, v64, v65
.Ltmp19:
	.loc	2 314 12                        ; standard.py:314:12 @[ kernel.py:82:29 ]
	v_mov_b32_e32 v9, v8
	s_nop 1
	v_permlane16_swap_b32_e32 v8, v9
.Ltmp20:
	.loc	1 83 38                         ; kernel.py:83:38
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[0:3], v[20:23], v[30:33], v[0:3]
.Ltmp21:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ kernel.py:82:29 ] ]
	v_add_f32_e32 v8, v8, v9
.Ltmp22:
	.loc	1 82 15                         ; kernel.py:82:15
	v_fmac_f32_e32 v8, v47, v70
	.loc	1 67 5                          ; kernel.py:67:5
	s_cmp_lt_i32 s90, s91
	.loc	1 83 38                         ; kernel.py:83:38
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[4:7], v[10:13], v[30:33], v[4:7]
	v_mov_b32_e32 v47, v8
	v_mov_b32_e32 v55, v24
	.loc	1 67 5                          ; kernel.py:67:5
	s_cbranch_scc0 .LBB0_5
.LBB0_3:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 0 5 is_stmt 0                 ; kernel.py:0:5
	v_add_u32_e32 v9, s90, v40
	v_add_u32_e32 v10, s90, v45
	.loc	1 68 15 is_stmt 1               ; kernel.py:68:15
	v_add_u32_e32 v8, 16, v9
	v_add_u32_e32 v11, 1, v10
	v_add_u32_e32 v12, 2, v10
	v_add_u32_e32 v13, 3, v10
	v_add_u32_e32 v14, 16, v10
	v_add_u32_e32 v15, 17, v10
	v_add_u32_e32 v16, 18, v10
	.loc	1 69 17                         ; kernel.py:69:17
	v_add_u32_e32 v17, 19, v10
	v_cmp_gt_i32_e64 s[2:3], s91, v9
	v_cmp_gt_i32_e64 s[6:7], s91, v8
	v_cmp_gt_i32_e64 s[10:11], s91, v11
	v_cmp_gt_i32_e64 s[12:13], s91, v10
	v_cmp_gt_i32_e64 s[14:15], s91, v13
	v_cmp_gt_i32_e64 s[20:21], s91, v12
	v_cmp_gt_i32_e64 s[22:23], s91, v15
	v_cmp_gt_i32_e64 s[24:25], s91, v14
	v_cmp_gt_i32_e64 s[26:27], s91, v17
	v_cmp_gt_i32_e64 s[28:29], s91, v16
	.loc	1 69 34 is_stmt 0               ; kernel.py:69:34
	v_cmp_le_i32_e64 s[30:31], s33, v9
	v_cmp_le_i32_e64 s[34:35], s33, v10
	.loc	1 69 16                         ; kernel.py:69:16
	s_and_b64 s[54:55], s[2:3], s[30:31]
	s_and_b64 s[30:31], s[6:7], s[30:31]
	s_and_b64 s[76:77], s[12:13], s[34:35]
	s_and_b64 s[78:79], s[10:11], s[34:35]
	s_and_b64 s[80:81], s[20:21], s[34:35]
	s_and_b64 s[82:83], s[14:15], s[34:35]
	s_and_b64 s[84:85], s[24:25], s[34:35]
	s_and_b64 s[86:87], s[22:23], s[34:35]
	s_and_b64 s[88:89], s[28:29], s[34:35]
	s_and_b64 s[34:35], s[26:27], s[34:35]
	.loc	1 70 9 is_stmt 1                ; kernel.py:70:9
	s_and_b64 s[2:3], s[46:47], exec
	s_cselect_b32 s10, 1, 0
	s_andn2_b64 s[2:3], s[74:75], exec
	s_and_b64 s[6:7], s[54:55], exec
	s_or_b64 s[74:75], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[72:73], exec
	s_and_b64 s[6:7], s[30:31], exec
	s_or_b64 s[72:73], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[70:71], exec
	s_and_b64 s[6:7], s[76:77], exec
	s_or_b64 s[70:71], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[68:69], exec
	s_and_b64 s[6:7], s[78:79], exec
	s_or_b64 s[68:69], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[66:67], exec
	s_and_b64 s[6:7], s[80:81], exec
	s_or_b64 s[66:67], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[64:65], exec
	s_and_b64 s[6:7], s[82:83], exec
	s_or_b64 s[64:65], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[62:63], exec
	s_and_b64 s[6:7], s[84:85], exec
	s_or_b64 s[62:63], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[60:61], exec
	s_and_b64 s[6:7], s[86:87], exec
	s_or_b64 s[60:61], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[58:59], exec
	s_and_b64 s[6:7], s[88:89], exec
	s_or_b64 s[58:59], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[56:57], exec
	s_and_b64 s[6:7], s[34:35], exec
	s_or_b64 s[56:57], s[2:3], s[6:7]
	s_cmp_lg_u32 s10, 1
	s_cbranch_scc1 .LBB0_2
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[2:3], s17, v9
	v_cmp_le_i32_e64 s[6:7], s17, v8
	.loc	1 71 20 is_stmt 0               ; kernel.py:71:20
	s_and_b64 s[2:3], s[2:3], s[54:55]
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[10:11], s17, v10
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[6:7], s[6:7], s[30:31]
	s_andn2_b64 s[30:31], s[74:75], exec
	s_and_b64 s[2:3], s[2:3], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[12:13], s17, v11
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[10:11], s[10:11], s[76:77]
	s_or_b64 s[74:75], s[30:31], s[2:3]
	s_andn2_b64 s[2:3], s[72:73], exec
	s_and_b64 s[6:7], s[6:7], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[14:15], s17, v12
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[12:13], s[12:13], s[78:79]
	s_or_b64 s[72:73], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[70:71], exec
	s_and_b64 s[6:7], s[10:11], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[20:21], s17, v13
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[14:15], s[14:15], s[80:81]
	s_or_b64 s[70:71], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[68:69], exec
	s_and_b64 s[6:7], s[12:13], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[22:23], s17, v14
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[20:21], s[20:21], s[82:83]
	s_or_b64 s[68:69], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[66:67], exec
	s_and_b64 s[6:7], s[14:15], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[24:25], s17, v15
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[22:23], s[22:23], s[84:85]
	s_or_b64 s[66:67], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[64:65], exec
	s_and_b64 s[6:7], s[20:21], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[26:27], s17, v16
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[24:25], s[24:25], s[86:87]
	s_or_b64 s[64:65], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[62:63], exec
	s_and_b64 s[6:7], s[22:23], exec
	.loc	1 71 28                         ; kernel.py:71:28
	v_cmp_le_i32_e64 s[28:29], s17, v17
	.loc	1 71 20                         ; kernel.py:71:20
	s_and_b64 s[26:27], s[26:27], s[88:89]
	s_or_b64 s[62:63], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[60:61], exec
	s_and_b64 s[6:7], s[24:25], exec
	s_and_b64 s[28:29], s[28:29], s[34:35]
	s_or_b64 s[60:61], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[58:59], exec
	s_and_b64 s[6:7], s[26:27], exec
	s_or_b64 s[58:59], s[2:3], s[6:7]
	s_andn2_b64 s[2:3], s[56:57], exec
	s_and_b64 s[6:7], s[28:29], exec
	s_or_b64 s[56:57], s[2:3], s[6:7]
	s_branch .LBB0_2
.LBB0_5:
	.loc	1 87 14 is_stmt 1               ; kernel.py:87:14
	s_lshl_b32 s0, s16, 9
	s_add_i32 s0, s0, s18
	v_lshlrev_b32_e32 v9, 13, v43
	v_lshl_add_u32 v9, s0, 8, v9
	v_or_b32_e32 v9, v46, v9
	.loc	1 87 5 is_stmt 0                ; kernel.py:87:5
	s_and_b32 s9, s9, 0xffff
	s_mov_b32 s11, 0x27000
	s_mov_b32 s10, 0x7ffffffe
	buffer_store_dwordx4 v[0:3], v9, s[8:11], 0 offen
	buffer_store_dwordx4 v[4:7], v9, s[8:11], 0 offen offset:128
	.loc	1 88 5 is_stmt 1                ; kernel.py:88:5
	s_and_b32 s45, s45, 0xffff
	.loc	1 88 14 is_stmt 0               ; kernel.py:88:14
	v_lshlrev_b32_e32 v0, 8, v43
	.loc	1 88 5                          ; kernel.py:88:5
	v_or_b32_e32 v1, s19, v41
	.loc	1 88 14                         ; kernel.py:88:14
	v_lshl_add_u32 v0, s0, 3, v0
	.loc	1 88 5                          ; kernel.py:88:5
	v_bfrev_b32_e32 v2, 1
	v_cmp_eq_u32_e32 vcc, 0, v1
	s_mov_b32 s46, s10
	s_mov_b32 s47, s11
	v_cndmask_b32_e32 v1, v2, v0, vcc
	.loc	1 89 5 is_stmt 1                ; kernel.py:89:5
	v_or_b32_e32 v0, 4, v0
	v_cndmask_b32_e32 v0, v2, v0, vcc
	.loc	1 88 5                          ; kernel.py:88:5
	buffer_store_dword v24, v1, s[44:47], 0 offen
	.loc	1 89 5                          ; kernel.py:89:5
	buffer_store_dword v8, v0, s[44:47], 0 offen
.LBB0_6:                                ; %common.ret
	.loc	1 0 0 is_stmt 0                 ; kernel.py:0
	s_endpgm
.Ltmp23:
.Lfunc_end0:
	.size	_segment, .Lfunc_end0-_segment
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _segment
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 120
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
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 80
		.amdhsa_next_free_sgpr 94
		.amdhsa_accum_offset 80
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
	.set .L_segment.num_vgpr, 80
	.set .L_segment.num_agpr, 0
	.set .L_segment.numbered_sgpr, 94
	.set .L_segment.num_named_barrier, 0
	.set .L_segment.private_seg_size, 0
	.set .L_segment.uses_vcc, 1
	.set .L_segment.uses_flat_scratch, 0
	.set .L_segment.has_dyn_sized_stack, 0
	.set .L_segment.has_recursion, 0
	.set .L_segment.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 3220
; TotalNumSgprs: 100
; NumVgprs: 80
; NumAgprs: 0
; TotalNumVgprs: 80
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 9
; NumSGPRsForWavesPerEU: 100
; NumVGPRsForWavesPerEU: 80
; AccumOffset: 80
; Occupancy: 6
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 19
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
	.byte	8                               ; Abbreviation Code
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
	.byte	1                               ; Abbrev [1] 0xb:0x87 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x61 DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	50                              ; DW_AT_call_line
	.byte	19                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x55:0x21 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp8-.Ltmp4                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	78                              ; DW_AT_call_line
	.byte	33                              ; DW_AT_call_column
	.byte	6                               ; Abbrev [6] 0x69:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.byte	216                             ; DW_AT_call_line
	.byte	16                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	7                               ; Abbrev [7] 0x76:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	82                              ; DW_AT_call_line
	.byte	29                              ; DW_AT_call_column
	.byte	8                               ; Abbrev [8] 0x82:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	.Ltmp6-.Lfunc_begin0
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
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
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"kernel.py"                     ; string offset=7 ; kernel.py
.Linfo_string2:
	.asciz	"/work/build/paged_segment"     ; string offset=17 ; /work/build/paged_segment
.Linfo_string3:
	.asciz	"_segment"                      ; string offset=43 ; _segment
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
      - .address_space:  global
        .offset:         104
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         112
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 120
    .max_flat_workgroup_size: 128
    .name:           _segment
    .private_segment_fixed_size: 0
    .sgpr_count:     100
    .sgpr_spill_count: 0
    .symbol:         _segment.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     80
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
