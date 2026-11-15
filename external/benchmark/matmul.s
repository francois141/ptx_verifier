	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	matmul
	.globl	matmul
	.p2align	8
	.type	matmul,@function
matmul:
	s_load_dwordx4 s[4:7], s[0:1], 0x0
	s_load_dwordx2 s[8:9], s[0:1], 0x10
	s_load_dword s10, s[0:1], 0x18
	v_and_b32_e32 v1, 0x3ff, v0
	v_bfe_u32 v0, v0, 10, 10
	s_lshl_b32 s3, s3, 6
	s_mov_b32 s0, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s10, 0
	v_lshlrev_b32_e32 v28, 2, v0
	v_lshlrev_b32_e32 v29, 2, v1
	s_cbranch_scc0 .LBB0_6
	v_lshl_add_u32 v2, v0, 4, v1
	v_and_b32_e32 v3, 15, v1
	v_lshrrev_b32_e32 v5, 4, v2
	v_lshlrev_b32_e32 v3, 2, v3
	v_add_u32_e32 v6, s3, v5
	v_lshl_or_b32 v30, v5, 6, v3
	v_add_u32_e32 v5, 0x100, v2
	v_lshrrev_b32_e32 v7, 4, v5
	v_add_u32_e32 v8, s3, v7
	v_lshl_or_b32 v31, v7, 6, v3
	v_add_u32_e32 v7, 0x200, v2
	v_and_b32_e32 v4, 63, v2
	v_lshrrev_b32_e32 v9, 4, v7
	v_add_u32_e32 v10, s3, v9
	v_lshl_or_b32 v32, v9, 6, v3
	v_add_u32_e32 v9, 0x300, v2
	v_lshrrev_b32_e32 v2, 6, v2
	v_lshlrev_b32_e32 v34, 2, v4
	v_lshl_or_b32 v4, v2, 8, v34
	v_add_u32_e32 v35, 0x1000, v4
	v_lshrrev_b32_e32 v4, 6, v5
	v_lshl_or_b32 v5, v4, 8, v34
	v_add_u32_e32 v36, 0x1000, v5
	v_lshrrev_b32_e32 v5, 6, v7
	v_lshl_or_b32 v7, v5, 8, v34
	v_add_u32_e32 v37, 0x1000, v7
	v_lshrrev_b32_e32 v7, 6, v9
	v_lshlrev_b32_e32 v27, 2, v0
	v_lshlrev_b32_e32 v40, 8, v0
	v_mul_lo_u32 v0, s10, v7
	s_lshl_b32 s11, s2, 8
	v_lshrrev_b32_e32 v11, 4, v9
	v_lshl_add_u32 v41, v0, 2, s11
	v_mul_lo_u32 v0, s10, v5
	v_add_u32_e32 v12, s3, v11
	v_lshl_add_u32 v42, v0, 2, s11
	v_mul_lo_u32 v0, s10, v4
	v_lshl_add_u32 v43, v0, 2, s11
	v_mul_lo_u32 v0, s10, v12
	v_lshl_add_u32 v44, v0, 2, v3
	v_mul_lo_u32 v0, s10, v10
	v_lshl_add_u32 v45, v0, 2, v3
	v_mul_lo_u32 v0, s10, v8
	v_lshl_or_b32 v9, v7, 8, v34
	v_lshl_add_u32 v46, v0, 2, v3
	v_mul_lo_u32 v0, s10, v6
	v_add_u32_e32 v38, 0x1000, v9
	v_mov_b32_e32 v9, 0x1000
	v_lshl_add_u32 v47, v0, 2, v3
	v_mul_lo_u32 v0, s10, v2
	v_lshl_add_u32 v39, v1, 4, v9
	v_lshl_add_u32 v48, v0, 2, s11
	v_mov_b32_e32 v0, 0
	v_lshlrev_b32_e32 v26, 2, v1
	v_lshl_or_b32 v33, v11, 6, v3
	s_lshl_b32 s1, s10, 6
	v_add_u32_e32 v49, 0xd00, v39
	v_add_u32_e32 v50, 0xe00, v39
	v_add_u32_e32 v51, 0xf00, v39
	v_add_u32_e32 v52, 0x708, v39
	v_add_u32_e32 v53, 0x808, v39
	v_add_u32_e32 v54, 0x908, v39
	v_add_u32_e32 v55, 0xa08, v39
	v_add_u32_e32 v56, 0xb08, v39
	v_add_u32_e32 v57, 0xc08, v39
	v_add_u32_e32 v58, 0xd08, v39
	v_add_u32_e32 v59, 0xe08, v39
	v_add_u32_e32 v60, 0xf08, v39
	v_mov_b32_e32 v1, v0
	v_mov_b32_e32 v6, v0
	v_mov_b32_e32 v7, v0
	v_mov_b32_e32 v4, v0
	v_mov_b32_e32 v5, v0
	v_mov_b32_e32 v8, v0
	v_mov_b32_e32 v9, v0
	v_mov_b32_e32 v2, v0
	v_mov_b32_e32 v3, v0
	v_mov_b32_e32 v10, v0
	v_mov_b32_e32 v11, v0
	v_mov_b32_e32 v12, v0
	v_mov_b32_e32 v13, v0
	v_mov_b32_e32 v14, v0
	v_mov_b32_e32 v15, v0
	v_add_u32_e32 v61, 0x608, v39
.LBB0_2:
	v_add_u32_e32 v20, v34, v48
	v_add_u32_e32 v21, v34, v43
	v_add_u32_e32 v22, v34, v42
	v_add_u32_e32 v23, v34, v41
	global_load_dword v16, v47, s[4:5]
	global_load_dword v17, v46, s[4:5]
	global_load_dword v18, v45, s[4:5]
	global_load_dword v19, v44, s[4:5]
	global_load_dword v20, v20, s[6:7]
	global_load_dword v21, v21, s[6:7]
	global_load_dword v22, v22, s[6:7]
	global_load_dword v23, v23, s[6:7]
	s_add_i32 s0, s0, 16
	v_add_u32_e32 v41, s1, v41
	v_add_u32_e32 v42, s1, v42
	v_add_u32_e32 v43, s1, v43
	v_add_u32_e32 v44, 64, v44
	v_add_u32_e32 v45, 64, v45
	v_add_u32_e32 v46, 64, v46
	v_add_u32_e32 v47, 64, v47
	v_add_u32_e32 v48, s1, v48
	s_cmp_lt_u32 s0, s10
	s_waitcnt vmcnt(7)
	ds_write_b32 v30, v16
	s_waitcnt vmcnt(6)
	ds_write_b32 v31, v17
	s_waitcnt vmcnt(5)
	ds_write_b32 v32, v18
	s_waitcnt vmcnt(4)
	ds_write_b32 v33, v19
	s_waitcnt vmcnt(3)
	ds_write_b32 v35, v20
	s_waitcnt vmcnt(2)
	ds_write_b32 v36, v21
	s_waitcnt vmcnt(1)
	ds_write_b32 v37, v22
	s_waitcnt vmcnt(0)
	ds_write_b32 v38, v23
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[24:25], v40 offset0:48 offset1:49
	ds_read2_b32 v[62:63], v39 offset1:1
	ds_read2_b32 v[64:65], v39 offset0:66 offset1:67
	ds_read2_b32 v[66:67], v39 offset0:2 offset1:3
	ds_read2_b32 v[68:69], v40 offset0:50 offset1:51
	ds_read2_b32 v[20:21], v40 offset0:52 offset1:53
	ds_read2_b32 v[16:17], v40 offset0:54 offset1:55
	ds_read2_b32 v[70:71], v40 offset1:1
	ds_read2_b32 v[72:73], v40 offset0:2 offset1:3
	ds_read2_b32 v[22:23], v40 offset0:4 offset1:5
	ds_read2_b32 v[74:75], v40 offset0:16 offset1:17
	ds_read2_b32 v[76:77], v40 offset0:32 offset1:33
	ds_read2_b32 v[18:19], v40 offset0:6 offset1:7
	s_waitcnt lgkmcnt(11)
	v_pk_fma_f32 v[6:7], v[24:25], v[62:63], v[6:7] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[14:15], v[70:71], v[62:63], v[14:15] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[12:13], v[74:75], v[62:63], v[12:13] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[10:11], v[76:77], v[62:63], v[10:11] op_sel_hi:[0,1,1]
	ds_read2_b32 v[62:63], v39 offset0:64 offset1:65
	ds_read2_b32 v[78:79], v40 offset0:18 offset1:19
	v_pk_fma_f32 v[0:1], v[24:25], v[66:67], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[8:9], v[70:71], v[66:67], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[74:75], v[66:67], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[76:77], v[66:67], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[0:1], v[24:25], v[64:65], v[0:1] op_sel:[1,0,0]
	ds_read2_b32 v[2:3], v40 offset0:22 offset1:23
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[6:7], v[24:25], v[62:63], v[6:7] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[70:71], v[62:63], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[74:75], v[62:63], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[76:77], v[62:63], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[62:63], v40 offset0:20 offset1:21
	v_pk_fma_f32 v[8:9], v[70:71], v[64:65], v[8:9] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[74:75], v[64:65], v[4:5] op_sel:[1,0,0]
	ds_read2_b32 v[70:71], v40 offset0:34 offset1:35
	ds_read2_b32 v[24:25], v39 offset0:128 offset1:129
	v_pk_fma_f32 v[64:65], v[76:77], v[64:65], v[66:67] op_sel:[1,0,0]
	ds_read2_b32 v[66:67], v40 offset0:36 offset1:37
	ds_read2_b32 v[74:75], v39 offset0:130 offset1:131
	v_add_u32_e32 v76, 0x500, v39
	ds_read2_b32 v[76:77], v76 offset1:1
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[6:7], v[68:69], v[24:25], v[6:7] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[14:15], v[72:73], v[24:25], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[12:13], v[78:79], v[24:25], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[70:71], v[24:25], v[10:11] op_sel_hi:[0,1,1]
	ds_read2_b32 v[24:25], v39 offset0:192 offset1:193
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[0:1], v[68:69], v[74:75], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[8:9], v[72:73], v[74:75], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[78:79], v[74:75], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[64:65], v[70:71], v[74:75], v[64:65] op_sel_hi:[0,1,1]
	ds_read2_b32 v[74:75], v39 offset0:194 offset1:195
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[6:7], v[68:69], v[24:25], v[6:7] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[72:73], v[24:25], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[70:71], v[24:25], v[10:11] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[78:79], v[24:25], v[12:13] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[0:1], v[68:69], v[74:75], v[0:1] op_sel:[1,0,0]
	v_add_u32_e32 v68, 0x400, v39
	ds_read2_b32 v[68:69], v68 offset1:1
	v_pk_fma_f32 v[8:9], v[72:73], v[74:75], v[8:9] op_sel:[1,0,0]
	v_add_u32_e32 v72, 0x408, v39
	ds_read2_b32 v[72:73], v72 offset1:1
	v_pk_fma_f32 v[64:65], v[70:71], v[74:75], v[64:65] op_sel:[1,0,0]
	v_add_u32_e32 v70, 0x508, v39
	ds_read2_b32 v[70:71], v70 offset1:1
	v_pk_fma_f32 v[4:5], v[78:79], v[74:75], v[4:5] op_sel:[1,0,0]
	v_add_u32_e32 v74, 0x600, v39
	ds_read2_b32 v[74:75], v74 offset1:1
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[14:15], v[22:23], v[68:69], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[12:13], v[62:63], v[68:69], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[66:67], v[68:69], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[6:7], v[20:21], v[68:69], v[6:7] op_sel_hi:[0,1,1]
	v_add_u32_e32 v68, 0x700, v39
	ds_read2_b32 v[68:69], v68 offset1:1
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[8:9], v[22:23], v[72:73], v[8:9] op_sel_hi:[0,1,1]
	ds_read2_b32 v[24:25], v40 offset0:38 offset1:39
	v_pk_fma_f32 v[4:5], v[62:63], v[72:73], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[14:15], v[22:23], v[76:77], v[14:15] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[8:9], v[22:23], v[70:71], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[22:23], v61 offset1:1
	v_pk_fma_f32 v[12:13], v[62:63], v[76:77], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[62:63], v[70:71], v[4:5] op_sel:[1,0,0]
	ds_read2_b32 v[62:63], v52 offset1:1
	v_pk_fma_f32 v[0:1], v[20:21], v[72:73], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[64:65], v[66:67], v[72:73], v[64:65] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[66:67], v[76:77], v[10:11] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[20:21], v[76:77], v[6:7] op_sel:[1,0,0]
	v_add_u32_e32 v72, 0x800, v39
	v_pk_fma_f32 v[64:65], v[66:67], v[70:71], v[64:65] op_sel:[1,0,0]
	v_add_u32_e32 v66, 0x900, v39
	ds_read2_b32 v[76:77], v53 offset1:1
	v_pk_fma_f32 v[0:1], v[20:21], v[70:71], v[0:1] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[14:15], v[18:19], v[74:75], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[12:13], v[2:3], v[74:75], v[12:13] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[10:11], v[24:25], v[74:75], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[6:7], v[16:17], v[74:75], v[6:7] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[8:9], v[18:19], v[22:23], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[2:3], v[22:23], v[4:5] op_sel_hi:[0,1,1]
	ds_read2_b32 v[72:73], v72 offset1:1
	ds_read2_b32 v[66:67], v66 offset1:1
	ds_read2_b32 v[20:21], v40 offset0:8 offset1:9
	ds_read2_b32 v[70:71], v40 offset0:10 offset1:11
	ds_read2_b32 v[74:75], v40 offset0:12 offset1:13
	v_pk_fma_f32 v[64:65], v[24:25], v[22:23], v[64:65] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[16:17], v[22:23], v[0:1] op_sel_hi:[0,1,1]
	ds_read2_b32 v[0:1], v40 offset0:14 offset1:15
	v_pk_fma_f32 v[14:15], v[18:19], v[68:69], v[14:15] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(7)
	v_pk_fma_f32 v[8:9], v[18:19], v[62:63], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[18:19], v40 offset0:24 offset1:25
	v_pk_fma_f32 v[10:11], v[24:25], v[68:69], v[10:11] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[2:3], v[68:69], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[78:79], v[2:3], v[62:63], v[4:5] op_sel:[1,0,0]
	ds_read2_b32 v[4:5], v40 offset0:28 offset1:29
	v_pk_fma_f32 v[6:7], v[16:17], v[68:69], v[6:7] op_sel:[1,0,0]
	ds_read2_b32 v[68:69], v40 offset0:40 offset1:41
	v_pk_fma_f32 v[24:25], v[24:25], v[62:63], v[64:65] op_sel:[1,0,0]
	ds_read2_b32 v[64:65], v40 offset0:26 offset1:27
	v_pk_fma_f32 v[16:17], v[16:17], v[62:63], v[22:23] op_sel:[1,0,0]
	ds_read2_b32 v[22:23], v40 offset0:56 offset1:57
	ds_read2_b32 v[2:3], v40 offset0:30 offset1:31
	s_waitcnt lgkmcnt(9)
	v_pk_fma_f32 v[14:15], v[20:21], v[72:73], v[14:15] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[12:13], v[18:19], v[72:73], v[12:13] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[10:11], v[68:69], v[72:73], v[10:11] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[62:63], v[22:23], v[72:73], v[6:7] op_sel_hi:[0,1,1]
	ds_read2_b32 v[72:73], v54 offset1:1
	v_pk_fma_f32 v[24:25], v[68:69], v[76:77], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[68:69], v[66:67], v[10:11] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[20:21], v[76:77], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[78:79], v[18:19], v[76:77], v[78:79] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[24:25], v[68:69], v[72:73], v[24:25] op_sel:[1,0,0]
	v_add_u32_e32 v68, 0xa00, v39
	v_pk_fma_f32 v[16:17], v[22:23], v[76:77], v[16:17] op_sel_hi:[0,1,1]
	ds_read2_b32 v[76:77], v40 offset0:42 offset1:43
	ds_read2_b32 v[8:9], v40 offset0:44 offset1:45
	ds_read2_b32 v[68:69], v68 offset1:1
	v_pk_fma_f32 v[14:15], v[20:21], v[66:67], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[20:21], v[72:73], v[6:7] op_sel:[1,0,0]
	ds_read2_b32 v[6:7], v40 offset0:46 offset1:47
	v_pk_fma_f32 v[12:13], v[18:19], v[66:67], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[62:63], v[22:23], v[66:67], v[62:63] op_sel:[1,0,0]
	ds_read2_b32 v[66:67], v40 offset0:58 offset1:59
	v_pk_fma_f32 v[18:19], v[18:19], v[72:73], v[78:79] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[78:79], v[76:77], v[68:69], v[10:11] op_sel_hi:[0,1,1]
	v_add_u32_e32 v10, 0xb00, v39
	v_pk_fma_f32 v[16:17], v[22:23], v[72:73], v[16:17] op_sel:[1,0,0]
	ds_read2_b32 v[22:23], v55 offset1:1
	ds_read2_b32 v[72:73], v56 offset1:1
	v_pk_fma_f32 v[14:15], v[70:71], v[68:69], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[12:13], v[64:65], v[68:69], v[12:13] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[62:63], v[66:67], v[68:69], v[62:63] op_sel_hi:[0,1,1]
	ds_read2_b32 v[68:69], v10 offset1:1
	ds_read2_b32 v[82:83], v57 offset1:1
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[20:21], v[70:71], v[22:23], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[76:77], v[22:23], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[18:19], v[64:65], v[22:23], v[18:19] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[66:67], v[22:23], v[16:17] op_sel_hi:[0,1,1]
	ds_read2_b32 v[16:17], v40 offset0:62 offset1:63
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[80:81], v[70:71], v[68:69], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[70:71], v[70:71], v[72:73], v[20:21] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[64:65], v[68:69], v[12:13] op_sel:[1,0,0]
	v_add_u32_e32 v12, 0xc00, v39
	ds_read2_b32 v[10:11], v40 offset0:60 offset1:61
	ds_read2_b32 v[14:15], v49 offset1:1
	ds_read2_b32 v[84:85], v12 offset1:1
	v_pk_fma_f32 v[64:65], v[64:65], v[72:73], v[18:19] op_sel:[1,0,0]
	ds_read2_b32 v[18:19], v58 offset1:1
	ds_read2_b32 v[12:13], v59 offset1:1
	v_pk_fma_f32 v[78:79], v[76:77], v[68:69], v[78:79] op_sel:[1,0,0]
	v_pk_fma_f32 v[76:77], v[76:77], v[72:73], v[24:25] op_sel:[1,0,0]
	v_pk_fma_f32 v[62:63], v[66:67], v[68:69], v[62:63] op_sel:[1,0,0]
	v_pk_fma_f32 v[66:67], v[66:67], v[72:73], v[22:23] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[68:69], v[74:75], v[84:85], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[70:71], v[74:75], v[82:83], v[70:71] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[72:73], v[8:9], v[82:83], v[76:77] op_sel_hi:[0,1,1]
	ds_read2_b32 v[76:77], v50 offset1:1
	v_pk_fma_f32 v[22:23], v[10:11], v[84:85], v[62:63] op_sel_hi:[0,1,1]
	ds_read2_b32 v[62:63], v60 offset1:1
	v_pk_fma_f32 v[68:69], v[74:75], v[14:15], v[68:69] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[70:71], v[74:75], v[18:19], v[70:71] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v51 offset1:1
	v_pk_fma_f32 v[20:21], v[4:5], v[84:85], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[8:9], v[84:85], v[78:79] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[64:65], v[4:5], v[82:83], v[64:65] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[10:11], v[82:83], v[66:67] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[8:9], v[14:15], v[24:25] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[8:9], v[18:19], v[72:73] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[4:5], v[14:15], v[20:21] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[4:5], v[18:19], v[64:65] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[10:11], v[14:15], v[22:23] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[10:11], v[18:19], v[66:67] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[18:19], v[0:1], v[76:77], v[68:69] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[20:21], v[2:3], v[76:77], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[6:7], v[76:77], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[16:17], v[76:77], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[64:65], v[0:1], v[12:13], v[70:71] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[6:7], v[12:13], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[2:3], v[12:13], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[68:69], v[16:17], v[12:13], v[10:11] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[14:15], v[0:1], v[74:75], v[18:19] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[0:1], v[62:63], v[64:65] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[2:3], v[74:75], v[20:21] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[2:3], v[62:63], v[4:5] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[6:7], v[74:75], v[22:23] op_sel:[1,0,0]
	v_pk_fma_f32 v[2:3], v[6:7], v[62:63], v[66:67] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[16:17], v[74:75], v[24:25] op_sel:[1,0,0]
	v_pk_fma_f32 v[0:1], v[16:17], v[62:63], v[68:69] op_sel:[1,0,0]
	s_barrier
	s_cbranch_scc1 .LBB0_2
	s_branch .LBB0_5
.LBB0_4:
	v_mov_b32_e32 v2, 0
	v_mov_b32_e32 v26, v29
	v_mov_b32_e32 v27, v28
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v0, v2
	v_mov_b32_e32 v1, v2
.LBB0_5:
	v_add_u32_e32 v16, s3, v27
	s_lshl_b32 s0, s2, 6
	v_mul_lo_u32 v16, v16, s10
	v_add3_u32 v16, v26, s0, v16
	v_lshlrev_b32_e32 v17, 2, v16
	global_store_dword v17, v14, s[8:9]
	v_or_b32_e32 v14, 4, v17
	global_store_dword v14, v15, s[8:9]
	v_or_b32_e32 v14, 8, v17
	global_store_dword v14, v8, s[8:9]
	v_or_b32_e32 v8, 12, v17
	global_store_dword v8, v9, s[8:9]
	v_add_u32_e32 v8, s10, v16
	v_lshlrev_b32_e32 v9, 2, v8
	global_store_dword v9, v12, s[8:9]
	v_add_u32_e32 v12, 4, v9
	global_store_dword v12, v13, s[8:9]
	v_add_u32_e32 v12, 8, v9
	global_store_dword v12, v4, s[8:9]
	v_add_u32_e32 v4, 12, v9
	global_store_dword v4, v5, s[8:9]
	v_add_u32_e32 v4, s10, v8
	v_lshlrev_b32_e32 v5, 2, v4
	global_store_dword v5, v10, s[8:9]
	v_or_b32_e32 v8, 4, v5
	v_add_u32_e32 v5, 8, v5
	global_store_dword v8, v11, s[8:9]
	global_store_dwordx2 v5, v[2:3], s[8:9]
	v_add_lshl_u32 v2, v4, s10, 2
	v_add_u32_e32 v3, 4, v2
	global_store_dword v3, v7, s[8:9]
	v_add_u32_e32 v3, 8, v2
	global_store_dword v3, v0, s[8:9]
	v_add_u32_e32 v0, 12, v2
	global_store_dword v2, v6, s[8:9]
	global_store_dword v0, v1, s[8:9]
	s_endpgm
.LBB0_6:
	s_cbranch_execnz .LBB0_4
	s_branch .LBB0_5
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel matmul
		.amdhsa_group_segment_fixed_size 8192
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 28
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 0
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 86
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 88
		.amdhsa_reserve_vcc 0
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
	.size	matmul, .Lfunc_end0-matmul

	.set matmul.num_vgpr, 86
	.set matmul.num_agpr, 0
	.set matmul.numbered_sgpr, 12
	.set matmul.private_seg_size, 0
	.set matmul.uses_vcc, 0
	.set matmul.uses_flat_scratch, 0
	.set matmul.has_dyn_sized_stack, 0
	.set matmul.has_recursion, 0
	.set matmul.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_b38c488ace96d9e4,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_b38c488ace96d9e4
__hip_cuid_b38c488ace96d9e4:
	.byte	0
	.size	__hip_cuid_b38c488ace96d9e4, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_b38c488ace96d9e4
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
    .group_segment_fixed_size: 8192
    .kernarg_segment_align: 8
    .kernarg_segment_size: 28
    .max_flat_workgroup_size: 256
    .name:           matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         matmul.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     86
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
