	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	matmul
	.globl	matmul
	.p2align	8
	.type	matmul,@function
matmul:
	s_load_dwordx8 s[4:11], s[0:1], 0x0
	v_and_b32_e32 v1, 0x3ff, v0
	s_lshl_b32 s3, s3, 8
	v_bfe_u32 v0, v0, 10, 10
	v_lshlrev_b32_e32 v112, 4, v0
	s_mov_b32 s0, 0
	s_waitcnt lgkmcnt(0)
	s_cmp_lg_u32 s11, 0
	v_lshlrev_b32_e32 v114, 2, v1
	s_cbranch_scc0 .LBB0_6
	v_add_u32_e32 v0, v112, v1
	v_and_b32_e32 v2, 15, v1
	v_lshrrev_b32_e32 v4, 4, v0
	v_lshlrev_b32_e32 v115, 2, v2
	v_add_u32_e32 v2, 0x100, v0
	v_add_u32_e32 v5, s3, v4
	v_lshl_or_b32 v116, v4, 6, v115
	v_lshrrev_b32_e32 v4, 4, v2
	v_add_u32_e32 v6, s3, v4
	v_lshl_or_b32 v117, v4, 6, v115
	v_add_u32_e32 v4, 0x200, v0
	v_lshrrev_b32_e32 v7, 4, v4
	v_add_u32_e32 v8, s3, v7
	v_lshl_or_b32 v118, v7, 6, v115
	v_add_u32_e32 v7, 0x300, v0
	v_lshrrev_b32_e32 v9, 4, v7
	v_add_u32_e32 v10, s3, v9
	v_lshl_or_b32 v119, v9, 6, v115
	v_add_u32_e32 v9, 0x400, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v11, s3, v9
	v_lshl_or_b32 v120, v9, 6, v115
	v_add_u32_e32 v9, 0x500, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v12, s3, v9
	v_lshl_or_b32 v121, v9, 6, v115
	v_add_u32_e32 v9, 0x600, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v13, s3, v9
	v_lshl_or_b32 v122, v9, 6, v115
	v_add_u32_e32 v9, 0x700, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v14, s3, v9
	v_lshl_or_b32 v123, v9, 6, v115
	v_add_u32_e32 v9, 0x800, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v15, s3, v9
	v_lshl_or_b32 v124, v9, 6, v115
	v_add_u32_e32 v9, 0x900, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v16, s3, v9
	v_lshl_or_b32 v125, v9, 6, v115
	v_add_u32_e32 v9, 0xa00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v17, s3, v9
	v_lshl_or_b32 v126, v9, 6, v115
	v_add_u32_e32 v9, 0xb00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v18, s3, v9
	v_lshl_or_b32 v127, v9, 6, v115
	v_add_u32_e32 v9, 0xc00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v19, s3, v9
	v_lshl_or_b32 v128, v9, 6, v115
	v_add_u32_e32 v9, 0xd00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_add_u32_e32 v20, s3, v9
	v_lshl_or_b32 v129, v9, 6, v115
	v_add_u32_e32 v9, 0xe00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_and_b32_e32 v3, 63, v0
	v_add_u32_e32 v21, s3, v9
	v_lshl_or_b32 v130, v9, 6, v115
	v_add_u32_e32 v9, 0xf00, v0
	v_lshrrev_b32_e32 v9, 4, v9
	v_lshrrev_b32_e32 v0, 6, v0
	v_lshlrev_b32_e32 v3, 2, v3
	v_add_u32_e32 v22, s3, v9
	v_lshl_or_b32 v131, v9, 6, v115
	v_lshl_or_b32 v9, v0, 8, v3
	v_lshrrev_b32_e32 v2, 6, v2
	v_add_u32_e32 v132, 0x4000, v9
	v_lshl_or_b32 v9, v2, 8, v3
	v_lshrrev_b32_e32 v4, 6, v4
	v_add_u32_e32 v133, 0x4000, v9
	v_lshl_or_b32 v9, v4, 8, v3
	v_lshrrev_b32_e32 v7, 6, v7
	v_add_u32_e32 v134, 0x4000, v9
	v_lshl_or_b32 v9, v7, 8, v3
	v_add_u32_e32 v135, 0x4000, v9
	v_mov_b32_e32 v9, 0x4000
	v_lshlrev_b32_e32 v113, 2, v1
	v_lshl_or_b32 v136, v1, 4, v9
	v_mul_lo_u32 v1, s10, v7
	v_lshlrev_b32_e32 v137, 2, v1
	v_mul_lo_u32 v1, s10, v4
	v_lshlrev_b32_e32 v139, 2, v1
	v_mul_lo_u32 v1, s10, v2
	v_lshlrev_b32_e32 v140, 2, v1
	v_mul_lo_u32 v1, s11, v22
	v_lshlrev_b32_e32 v141, 2, v1
	v_mul_lo_u32 v1, s11, v21
	v_lshlrev_b32_e32 v142, 2, v1
	v_mul_lo_u32 v1, s11, v20
	v_lshlrev_b32_e32 v143, 2, v1
	v_mul_lo_u32 v1, s11, v19
	v_lshlrev_b32_e32 v144, 2, v1
	v_mul_lo_u32 v1, s11, v18
	v_lshlrev_b32_e32 v145, 2, v1
	v_mul_lo_u32 v1, s11, v17
	v_lshlrev_b32_e32 v146, 2, v1
	v_mul_lo_u32 v1, s11, v16
	v_lshlrev_b32_e32 v147, 2, v1
	v_mul_lo_u32 v1, s11, v15
	v_lshlrev_b32_e32 v148, 2, v1
	v_mul_lo_u32 v1, s11, v14
	v_lshlrev_b32_e32 v149, 2, v1
	v_mul_lo_u32 v1, s11, v13
	v_lshlrev_b32_e32 v150, 2, v1
	v_mul_lo_u32 v1, s11, v12
	v_lshlrev_b32_e32 v151, 2, v1
	v_mul_lo_u32 v1, s11, v11
	v_lshlrev_b32_e32 v152, 2, v1
	v_mul_lo_u32 v1, s11, v10
	v_lshlrev_b32_e32 v153, 2, v1
	v_mul_lo_u32 v1, s11, v8
	v_lshlrev_b32_e32 v154, 2, v1
	v_mul_lo_u32 v1, s11, v6
	v_lshlrev_b32_e32 v155, 2, v1
	v_mul_lo_u32 v1, s11, v5
	v_mul_lo_u32 v0, s10, v0
	v_mov_b32_e32 v4, 0
	v_lshl_or_b32 v138, s2, 8, v3
	s_lshl_b32 s1, s10, 6
	v_lshlrev_b32_e32 v156, 2, v1
	v_lshlrev_b32_e32 v157, 2, v0
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v12, v4
	v_mov_b32_e32 v13, v4
	v_mov_b32_e32 v8, v4
	v_mov_b32_e32 v9, v4
	v_mov_b32_e32 v6, v4
	v_mov_b32_e32 v7, v4
	v_mov_b32_e32 v14, v4
	v_mov_b32_e32 v15, v4
	v_mov_b32_e32 v10, v4
	v_mov_b32_e32 v11, v4
	v_mov_b32_e32 v20, v4
	v_mov_b32_e32 v21, v4
	v_mov_b32_e32 v16, v4
	v_mov_b32_e32 v17, v4
	v_mov_b32_e32 v24, v4
	v_mov_b32_e32 v25, v4
	v_mov_b32_e32 v18, v4
	v_mov_b32_e32 v19, v4
	v_mov_b32_e32 v28, v4
	v_mov_b32_e32 v29, v4
	v_mov_b32_e32 v26, v4
	v_mov_b32_e32 v27, v4
	v_mov_b32_e32 v32, v4
	v_mov_b32_e32 v33, v4
	v_mov_b32_e32 v30, v4
	v_mov_b32_e32 v31, v4
	v_mov_b32_e32 v36, v4
	v_mov_b32_e32 v37, v4
	v_mov_b32_e32 v34, v4
	v_mov_b32_e32 v35, v4
	v_mov_b32_e32 v40, v4
	v_mov_b32_e32 v41, v4
	v_mov_b32_e32 v44, v4
	v_mov_b32_e32 v45, v4
	v_mov_b32_e32 v38, v4
	v_mov_b32_e32 v39, v4
	v_mov_b32_e32 v48, v4
	v_mov_b32_e32 v49, v4
	v_mov_b32_e32 v46, v4
	v_mov_b32_e32 v47, v4
	v_mov_b32_e32 v54, v4
	v_mov_b32_e32 v55, v4
	v_mov_b32_e32 v50, v4
	v_mov_b32_e32 v51, v4
	v_mov_b32_e32 v56, v4
	v_mov_b32_e32 v57, v4
	v_mov_b32_e32 v52, v4
	v_mov_b32_e32 v53, v4
	v_mov_b32_e32 v60, v4
	v_mov_b32_e32 v61, v4
	v_mov_b32_e32 v58, v4
	v_mov_b32_e32 v59, v4
	v_mov_b32_e32 v62, v4
	v_mov_b32_e32 v63, v4
	v_mov_b32_e32 v2, v4
	v_mov_b32_e32 v3, v4
	v_mov_b32_e32 v0, v4
	v_mov_b32_e32 v1, v4
	v_mov_b32_e32 v42, v4
	v_mov_b32_e32 v43, v4
	v_mov_b32_e32 v22, v4
	v_mov_b32_e32 v23, v4
	v_lshlrev_b32_e32 v158, 6, v112
.LBB0_2:
	v_add_u32_e32 v64, v115, v156
	v_add_u32_e32 v65, v115, v155
	v_add_u32_e32 v72, v115, v154
	v_add_u32_e32 v73, v115, v153
	v_add_u32_e32 v74, v115, v152
	v_add_u32_e32 v75, v115, v151
	v_add_u32_e32 v76, v115, v150
	v_add_u32_e32 v77, v115, v149
	v_add_u32_e32 v78, v115, v148
	v_add_u32_e32 v79, v115, v147
	v_add_u32_e32 v80, v115, v146
	v_add_u32_e32 v81, v115, v145
	v_add_u32_e32 v82, v115, v144
	v_add_u32_e32 v83, v115, v143
	v_add_u32_e32 v84, v115, v142
	v_add_u32_e32 v85, v115, v141
	v_add_u32_e32 v86, v157, v138
	v_add_u32_e32 v87, v140, v138
	v_add_u32_e32 v88, v139, v138
	v_add_u32_e32 v89, v137, v138
	global_load_dword v64, v64, s[4:5]
	global_load_dword v65, v65, s[4:5]
	global_load_dword v72, v72, s[4:5]
	global_load_dword v73, v73, s[4:5]
	global_load_dword v74, v74, s[4:5]
	global_load_dword v75, v75, s[4:5]
	global_load_dword v76, v76, s[4:5]
	global_load_dword v77, v77, s[4:5]
	global_load_dword v78, v78, s[4:5]
	global_load_dword v79, v79, s[4:5]
	global_load_dword v80, v80, s[4:5]
	global_load_dword v81, v81, s[4:5]
	global_load_dword v82, v82, s[4:5]
	global_load_dword v83, v83, s[4:5]
	global_load_dword v84, v84, s[4:5]
	global_load_dword v85, v85, s[4:5]
	global_load_dword v86, v86, s[6:7]
	global_load_dword v87, v87, s[6:7]
	global_load_dword v88, v88, s[6:7]
	global_load_dword v89, v89, s[6:7]
	v_add_u32_e32 v71, 0x400, v136
	v_add_u32_e32 v70, 0x408, v136
	v_add_u32_e32 v67, 0x500, v136
	v_add_u32_e32 v69, 0x508, v136
	v_add_u32_e32 v66, 0x600, v136
	v_add_u32_e32 v68, 0x608, v136
	v_add_u32_e32 v101, 0x700, v136
	v_add_u32_e32 v102, 0x708, v136
	v_add_u32_e32 v100, 0x800, v136
	v_add_u32_e32 v98, 0x900, v136
	v_add_u32_e32 v99, 0x808, v136
	v_add_u32_e32 v97, 0x908, v136
	v_add_u32_e32 v96, 0xa08, v136
	v_add_u32_e32 v104, 0xb08, v136
	v_add_u32_e32 v105, 0xa00, v136
	v_add_u32_e32 v103, 0xc08, v136
	v_add_u32_e32 v159, 0xf08, v136
	s_add_i32 s0, s0, 16
	v_add_u32_e32 v138, s1, v138
	v_add_u32_e32 v141, 64, v141
	v_add_u32_e32 v142, 64, v142
	v_add_u32_e32 v143, 64, v143
	v_add_u32_e32 v144, 64, v144
	v_add_u32_e32 v145, 64, v145
	v_add_u32_e32 v146, 64, v146
	v_add_u32_e32 v147, 64, v147
	v_add_u32_e32 v148, 64, v148
	v_add_u32_e32 v149, 64, v149
	v_add_u32_e32 v150, 64, v150
	v_add_u32_e32 v151, 64, v151
	v_add_u32_e32 v152, 64, v152
	v_add_u32_e32 v153, 64, v153
	v_add_u32_e32 v154, 64, v154
	v_add_u32_e32 v155, 64, v155
	v_add_u32_e32 v156, 64, v156
	s_cmp_lt_u32 s0, s11
	s_waitcnt vmcnt(19)
	ds_write_b32 v116, v64
	s_waitcnt vmcnt(18)
	ds_write_b32 v117, v65
	s_waitcnt vmcnt(17)
	ds_write_b32 v118, v72
	s_waitcnt vmcnt(16)
	ds_write_b32 v119, v73
	s_waitcnt vmcnt(15)
	ds_write_b32 v120, v74
	s_waitcnt vmcnt(14)
	ds_write_b32 v121, v75
	s_waitcnt vmcnt(13)
	ds_write_b32 v122, v76
	s_waitcnt vmcnt(12)
	ds_write_b32 v123, v77
	s_waitcnt vmcnt(11)
	ds_write_b32 v124, v78
	s_waitcnt vmcnt(10)
	ds_write_b32 v125, v79
	s_waitcnt vmcnt(9)
	ds_write_b32 v126, v80
	s_waitcnt vmcnt(8)
	ds_write_b32 v127, v81
	s_waitcnt vmcnt(7)
	ds_write_b32 v128, v82
	s_waitcnt vmcnt(6)
	ds_write_b32 v129, v83
	s_waitcnt vmcnt(5)
	ds_write_b32 v130, v84
	s_waitcnt vmcnt(4)
	ds_write_b32 v131, v85
	s_waitcnt vmcnt(3)
	ds_write_b32 v132, v86
	s_waitcnt vmcnt(2)
	ds_write_b32 v133, v87
	s_waitcnt vmcnt(1)
	ds_write_b32 v134, v88
	s_waitcnt vmcnt(0)
	ds_write_b32 v135, v89
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b32 v[64:65], v158 offset0:128 offset1:129
	ds_read2_b32 v[72:73], v158 offset0:240 offset1:241
	ds_read2_b32 v[74:75], v136 offset1:1
	ds_read2_b32 v[76:77], v136 offset0:2 offset1:3
	ds_read2_b32 v[78:79], v158 offset0:16 offset1:17
	ds_read2_b32 v[80:81], v158 offset0:32 offset1:33
	ds_read2_b32 v[82:83], v158 offset0:48 offset1:49
	ds_read2_b32 v[84:85], v158 offset0:64 offset1:65
	ds_read2_b32 v[86:87], v158 offset0:80 offset1:81
	ds_read2_b32 v[88:89], v158 offset0:96 offset1:97
	ds_read2_b32 v[90:91], v158 offset0:112 offset1:113
	ds_read2_b32 v[92:93], v158 offset0:144 offset1:145
	ds_read2_b32 v[94:95], v158 offset0:160 offset1:161
	ds_read2_b32 v[106:107], v158 offset0:176 offset1:177
	ds_read2_b32 v[108:109], v158 offset0:192 offset1:193
	ds_read2_b32 v[110:111], v158 offset0:208 offset1:209
	ds_read2_b32 v[160:161], v158 offset0:224 offset1:225
	ds_read2_b32 v[162:163], v158 offset1:1
	s_waitcnt lgkmcnt(14)
	v_pk_fma_f32 v[12:13], v[72:73], v[74:75], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[64:65], v[74:75], v[36:37] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(13)
	v_pk_fma_f32 v[62:63], v[78:79], v[74:75], v[62:63] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(12)
	v_pk_fma_f32 v[60:61], v[80:81], v[74:75], v[60:61] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(11)
	v_pk_fma_f32 v[56:57], v[82:83], v[74:75], v[56:57] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(10)
	v_pk_fma_f32 v[54:55], v[84:85], v[74:75], v[54:55] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(9)
	v_pk_fma_f32 v[48:49], v[86:87], v[74:75], v[48:49] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(8)
	v_pk_fma_f32 v[44:45], v[88:89], v[74:75], v[44:45] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(7)
	v_pk_fma_f32 v[40:41], v[90:91], v[74:75], v[40:41] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(6)
	v_pk_fma_f32 v[32:33], v[92:93], v[74:75], v[32:33] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[28:29], v[94:95], v[74:75], v[28:29] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(4)
	v_pk_fma_f32 v[24:25], v[106:107], v[74:75], v[24:25] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[20:21], v[108:109], v[74:75], v[20:21] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[14:15], v[110:111], v[74:75], v[14:15] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[8:9], v[160:161], v[74:75], v[8:9] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[0:1], v[162:163], v[74:75], v[0:1] op_sel_hi:[0,1,1]
	ds_read2_b32 v[74:75], v136 offset0:64 offset1:65
	v_pk_fma_f32 v[2:3], v[162:163], v[76:77], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[72:73], v[76:77], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[30:31], v[64:65], v[76:77], v[30:31] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[58:59], v[78:79], v[76:77], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[82:83], v[76:77], v[50:51] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[46:47], v[84:85], v[76:77], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[38:39], v[86:87], v[76:77], v[38:39] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[90:91], v[76:77], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[26:27], v[92:93], v[76:77], v[26:27] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[16:17], v[106:107], v[76:77], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[108:109], v[76:77], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[6:7], v[110:111], v[76:77], v[6:7] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[80:81], v[76:77], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[88:89], v[76:77], v[42:43] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[18:19], v[94:95], v[76:77], v[18:19] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[160:161], v[76:77], v[22:23] op_sel_hi:[0,1,1]
	ds_read2_b32 v[76:77], v158 offset0:18 offset1:19
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[12:13], v[72:73], v[74:75], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[64:65], v[74:75], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[0:1], v[162:163], v[74:75], v[0:1] op_sel:[1,0,0]
	v_pk_fma_f32 v[62:63], v[78:79], v[74:75], v[62:63] op_sel:[1,0,0]
	v_pk_fma_f32 v[60:61], v[80:81], v[74:75], v[60:61] op_sel:[1,0,0]
	v_pk_fma_f32 v[56:57], v[82:83], v[74:75], v[56:57] op_sel:[1,0,0]
	v_pk_fma_f32 v[54:55], v[84:85], v[74:75], v[54:55] op_sel:[1,0,0]
	v_pk_fma_f32 v[48:49], v[86:87], v[74:75], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[44:45], v[88:89], v[74:75], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[40:41], v[90:91], v[74:75], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[32:33], v[92:93], v[74:75], v[32:33] op_sel:[1,0,0]
	v_pk_fma_f32 v[28:29], v[94:95], v[74:75], v[28:29] op_sel:[1,0,0]
	v_pk_fma_f32 v[24:25], v[106:107], v[74:75], v[24:25] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[108:109], v[74:75], v[20:21] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[110:111], v[74:75], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[160:161], v[74:75], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v136 offset0:66 offset1:67
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[4:5], v[72:73], v[74:75], v[4:5] op_sel:[1,0,0]
	ds_read2_b32 v[72:73], v158 offset0:242 offset1:243
	v_pk_fma_f32 v[30:31], v[64:65], v[74:75], v[30:31] op_sel:[1,0,0]
	ds_read2_b32 v[64:65], v158 offset0:130 offset1:131
	v_pk_fma_f32 v[2:3], v[162:163], v[74:75], v[2:3] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[78:79], v[74:75], v[58:59] op_sel:[1,0,0]
	ds_read2_b32 v[78:79], v158 offset0:34 offset1:35
	v_pk_fma_f32 v[50:51], v[82:83], v[74:75], v[50:51] op_sel:[1,0,0]
	ds_read2_b32 v[82:83], v158 offset0:50 offset1:51
	v_pk_fma_f32 v[46:47], v[84:85], v[74:75], v[46:47] op_sel:[1,0,0]
	ds_read2_b32 v[84:85], v158 offset0:66 offset1:67
	v_pk_fma_f32 v[38:39], v[86:87], v[74:75], v[38:39] op_sel:[1,0,0]
	ds_read2_b32 v[86:87], v158 offset0:82 offset1:83
	v_pk_fma_f32 v[34:35], v[90:91], v[74:75], v[34:35] op_sel:[1,0,0]
	ds_read2_b32 v[90:91], v158 offset0:98 offset1:99
	v_pk_fma_f32 v[26:27], v[92:93], v[74:75], v[26:27] op_sel:[1,0,0]
	ds_read2_b32 v[92:93], v158 offset0:114 offset1:115
	v_pk_fma_f32 v[16:17], v[106:107], v[74:75], v[16:17] op_sel:[1,0,0]
	ds_read2_b32 v[106:107], v158 offset0:146 offset1:147
	v_pk_fma_f32 v[10:11], v[108:109], v[74:75], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[108:109], v158 offset0:162 offset1:163
	v_pk_fma_f32 v[6:7], v[110:111], v[74:75], v[6:7] op_sel:[1,0,0]
	ds_read2_b32 v[110:111], v158 offset0:178 offset1:179
	v_pk_fma_f32 v[52:53], v[80:81], v[74:75], v[52:53] op_sel:[1,0,0]
	ds_read2_b32 v[80:81], v158 offset0:194 offset1:195
	v_pk_fma_f32 v[42:43], v[88:89], v[74:75], v[42:43] op_sel:[1,0,0]
	ds_read2_b32 v[88:89], v136 offset0:128 offset1:129
	v_pk_fma_f32 v[18:19], v[94:95], v[74:75], v[18:19] op_sel:[1,0,0]
	ds_read2_b32 v[94:95], v158 offset0:2 offset1:3
	v_pk_fma_f32 v[22:23], v[160:161], v[74:75], v[22:23] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v158 offset0:210 offset1:211
	ds_read2_b32 v[160:161], v158 offset0:226 offset1:227
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[12:13], v[72:73], v[88:89], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[64:65], v[88:89], v[36:37] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[0:1], v[94:95], v[88:89], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[62:63], v[76:77], v[88:89], v[62:63] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[60:61], v[78:79], v[88:89], v[60:61] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[56:57], v[82:83], v[88:89], v[56:57] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[54:55], v[84:85], v[88:89], v[54:55] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[48:49], v[86:87], v[88:89], v[48:49] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[44:45], v[90:91], v[88:89], v[44:45] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[40:41], v[92:93], v[88:89], v[40:41] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[32:33], v[106:107], v[88:89], v[32:33] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[28:29], v[108:109], v[88:89], v[28:29] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[110:111], v[88:89], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[20:21], v[80:81], v[88:89], v[20:21] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[14:15], v[74:75], v[88:89], v[14:15] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[8:9], v[160:161], v[88:89], v[8:9] op_sel_hi:[0,1,1]
	ds_read2_b32 v[88:89], v136 offset0:130 offset1:131
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[162:163], v[74:75], v[88:89], v[6:7] op_sel_hi:[0,1,1]
	ds_read2_b32 v[6:7], v136 offset0:192 offset1:193
	v_pk_fma_f32 v[164:165], v[108:109], v[88:89], v[18:19] op_sel_hi:[0,1,1]
	ds_read2_b32 v[18:19], v158 offset0:180 offset1:181
	v_pk_fma_f32 v[4:5], v[72:73], v[88:89], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[30:31], v[64:65], v[88:89], v[30:31] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[166:167], v[110:111], v[6:7], v[24:25] op_sel:[1,0,0]
	ds_read2_b32 v[24:25], v136 offset0:194 offset1:195
	v_pk_fma_f32 v[2:3], v[94:95], v[88:89], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[82:83], v[88:89], v[50:51] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[46:47], v[84:85], v[88:89], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[38:39], v[86:87], v[88:89], v[38:39] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[92:93], v[88:89], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[26:27], v[106:107], v[88:89], v[26:27] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[80:81], v[88:89], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[58:59], v[76:77], v[88:89], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[16:17], v[110:111], v[88:89], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[78:79], v[88:89], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[90:91], v[88:89], v[42:43] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[160:161], v[88:89], v[22:23] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[88:89], v[72:73], v[6:7], v[12:13] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[64:65], v[6:7], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[0:1], v[94:95], v[6:7], v[0:1] op_sel:[1,0,0]
	v_pk_fma_f32 v[62:63], v[76:77], v[6:7], v[62:63] op_sel:[1,0,0]
	v_pk_fma_f32 v[60:61], v[78:79], v[6:7], v[60:61] op_sel:[1,0,0]
	v_pk_fma_f32 v[56:57], v[82:83], v[6:7], v[56:57] op_sel:[1,0,0]
	v_pk_fma_f32 v[54:55], v[84:85], v[6:7], v[54:55] op_sel:[1,0,0]
	v_pk_fma_f32 v[48:49], v[86:87], v[6:7], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[44:45], v[90:91], v[6:7], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[40:41], v[92:93], v[6:7], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[32:33], v[106:107], v[6:7], v[32:33] op_sel:[1,0,0]
	v_pk_fma_f32 v[28:29], v[108:109], v[6:7], v[28:29] op_sel:[1,0,0]
	v_pk_fma_f32 v[168:169], v[80:81], v[6:7], v[20:21] op_sel:[1,0,0]
	v_pk_fma_f32 v[170:171], v[74:75], v[6:7], v[14:15] op_sel:[1,0,0]
	v_pk_fma_f32 v[172:173], v[160:161], v[6:7], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[12:13], v158 offset0:244 offset1:245
	ds_read2_b32 v[6:7], v158 offset0:116 offset1:117
	ds_read2_b32 v[14:15], v158 offset0:164 offset1:165
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[72:73], v[72:73], v[24:25], v[4:5] op_sel:[1,0,0]
	v_pk_fma_f32 v[30:31], v[64:65], v[24:25], v[30:31] op_sel:[1,0,0]
	v_pk_fma_f32 v[2:3], v[94:95], v[24:25], v[2:3] op_sel:[1,0,0]
	ds_read2_b32 v[8:9], v158 offset0:132 offset1:133
	ds_read2_b32 v[64:65], v158 offset0:84 offset1:85
	ds_read2_b32 v[94:95], v158 offset0:20 offset1:21
	v_pk_fma_f32 v[50:51], v[82:83], v[24:25], v[50:51] op_sel:[1,0,0]
	ds_read2_b32 v[82:83], v158 offset0:36 offset1:37
	v_pk_fma_f32 v[46:47], v[84:85], v[24:25], v[46:47] op_sel:[1,0,0]
	ds_read2_b32 v[84:85], v158 offset0:52 offset1:53
	v_pk_fma_f32 v[38:39], v[86:87], v[24:25], v[38:39] op_sel:[1,0,0]
	ds_read2_b32 v[86:87], v158 offset0:68 offset1:69
	v_pk_fma_f32 v[34:35], v[92:93], v[24:25], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[92:93], v[106:107], v[24:25], v[26:27] op_sel:[1,0,0]
	v_pk_fma_f32 v[80:81], v[80:81], v[24:25], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[10:11], v158 offset0:148 offset1:149
	ds_read2_b32 v[4:5], v158 offset0:100 offset1:101
	ds_read2_b32 v[106:107], v158 offset0:4 offset1:5
	ds_read2_b32 v[26:27], v71 offset1:1
	v_pk_fma_f32 v[76:77], v[76:77], v[24:25], v[58:59] op_sel:[1,0,0]
	v_pk_fma_f32 v[16:17], v[110:111], v[24:25], v[16:17] op_sel:[1,0,0]
	v_pk_fma_f32 v[74:75], v[74:75], v[24:25], v[162:163] op_sel:[1,0,0]
	v_pk_fma_f32 v[78:79], v[78:79], v[24:25], v[52:53] op_sel:[1,0,0]
	v_pk_fma_f32 v[90:91], v[90:91], v[24:25], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[110:111], v[108:109], v[24:25], v[164:165] op_sel:[1,0,0]
	ds_read2_b32 v[20:21], v158 offset0:196 offset1:197
	v_pk_fma_f32 v[160:161], v[160:161], v[24:25], v[22:23] op_sel:[1,0,0]
	ds_read2_b32 v[22:23], v158 offset0:212 offset1:213
	ds_read2_b32 v[24:25], v158 offset0:228 offset1:229
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[162:163], v[94:95], v[26:27], v[62:63] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[62:63], v[10:11], v[26:27], v[32:33] op_sel_hi:[0,1,1]
	ds_read2_b32 v[32:33], v70 offset1:1
	v_pk_fma_f32 v[0:1], v[106:107], v[26:27], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[164:165], v[82:83], v[26:27], v[60:61] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[174:175], v[84:85], v[26:27], v[56:57] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[176:177], v[86:87], v[26:27], v[54:55] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[178:179], v[64:65], v[26:27], v[48:49] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[180:181], v[4:5], v[26:27], v[44:45] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[182:183], v[6:7], v[26:27], v[40:41] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[184:185], v[8:9], v[26:27], v[36:37] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[58:59], v[14:15], v[26:27], v[28:29] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[54:55], v[18:19], v[26:27], v[166:167] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[42:43], v[20:21], v[26:27], v[168:169] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[40:41], v[22:23], v[26:27], v[170:171] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[28:29], v[24:25], v[26:27], v[172:173] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[26:27], v[12:13], v[26:27], v[88:89] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[88:89], v[64:65], v[32:33], v[38:39] op_sel_hi:[0,1,1]
	ds_read2_b32 v[44:45], v67 offset1:1
	ds_read2_b32 v[38:39], v69 offset1:1
	v_pk_fma_f32 v[2:3], v[106:107], v[32:33], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[94:95], v[32:33], v[76:77] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[70:71], v[84:85], v[32:33], v[50:51] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[76:77], v[86:87], v[32:33], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[166:167], v[6:7], v[32:33], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[168:169], v[8:9], v[32:33], v[30:31] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[92:93], v[10:11], v[32:33], v[92:93] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[60:61], v[18:19], v[32:33], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[56:57], v[20:21], v[32:33], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[22:23], v[32:33], v[74:75] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[12:13], v[32:33], v[72:73] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[72:73], v[4:5], v[32:33], v[90:91] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[74:75], v[14:15], v[32:33], v[110:111] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[82:83], v[32:33], v[78:79] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[48:49], v[24:25], v[32:33], v[160:161] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[30:31], v[106:107], v[44:45], v[0:1] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[16:17], v[106:107], v[38:39], v[2:3] op_sel:[1,0,0]
	v_pk_fma_f32 v[32:33], v[94:95], v[44:45], v[162:163] op_sel:[1,0,0]
	v_pk_fma_f32 v[46:47], v[94:95], v[38:39], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[82:83], v[44:45], v[164:165] op_sel:[1,0,0]
	ds_read2_b32 v[0:1], v158 offset0:246 offset1:247
	v_pk_fma_f32 v[78:79], v[84:85], v[44:45], v[174:175] op_sel:[1,0,0]
	v_pk_fma_f32 v[70:71], v[84:85], v[38:39], v[70:71] op_sel:[1,0,0]
	ds_read2_b32 v[2:3], v158 offset0:134 offset1:135
	v_pk_fma_f32 v[80:81], v[86:87], v[44:45], v[176:177] op_sel:[1,0,0]
	v_pk_fma_f32 v[84:85], v[86:87], v[38:39], v[76:77] op_sel:[1,0,0]
	ds_read2_b32 v[160:161], v158 offset0:22 offset1:23
	ds_read2_b32 v[90:91], v158 offset0:38 offset1:39
	v_pk_fma_f32 v[86:87], v[64:65], v[44:45], v[178:179] op_sel:[1,0,0]
	v_pk_fma_f32 v[64:65], v[64:65], v[38:39], v[88:89] op_sel:[1,0,0]
	v_pk_fma_f32 v[72:73], v[4:5], v[38:39], v[72:73] op_sel:[1,0,0]
	v_pk_fma_f32 v[88:89], v[4:5], v[44:45], v[180:181] op_sel:[1,0,0]
	ds_read2_b32 v[4:5], v158 offset0:54 offset1:55
	v_pk_fma_f32 v[94:95], v[6:7], v[44:45], v[182:183] op_sel:[1,0,0]
	v_pk_fma_f32 v[162:163], v[6:7], v[38:39], v[166:167] op_sel:[1,0,0]
	ds_read2_b32 v[6:7], v158 offset0:70 offset1:71
	v_pk_fma_f32 v[110:111], v[8:9], v[44:45], v[184:185] op_sel:[1,0,0]
	v_pk_fma_f32 v[164:165], v[8:9], v[38:39], v[168:169] op_sel:[1,0,0]
	ds_read2_b32 v[8:9], v158 offset0:86 offset1:87
	v_pk_fma_f32 v[62:63], v[10:11], v[44:45], v[62:63] op_sel:[1,0,0]
	v_pk_fma_f32 v[166:167], v[10:11], v[38:39], v[92:93] op_sel:[1,0,0]
	ds_read2_b32 v[10:11], v158 offset0:102 offset1:103
	v_pk_fma_f32 v[168:169], v[14:15], v[38:39], v[74:75] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[14:15], v[44:45], v[58:59] op_sel:[1,0,0]
	ds_read2_b32 v[14:15], v158 offset0:118 offset1:119
	v_pk_fma_f32 v[54:55], v[18:19], v[44:45], v[54:55] op_sel:[1,0,0]
	v_pk_fma_f32 v[170:171], v[18:19], v[38:39], v[60:61] op_sel:[1,0,0]
	ds_read2_b32 v[18:19], v158 offset0:150 offset1:151
	v_pk_fma_f32 v[74:75], v[20:21], v[44:45], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[56:57], v[20:21], v[38:39], v[56:57] op_sel:[1,0,0]
	ds_read2_b32 v[20:21], v158 offset0:166 offset1:167
	v_pk_fma_f32 v[172:173], v[22:23], v[44:45], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[174:175], v[22:23], v[38:39], v[52:53] op_sel:[1,0,0]
	ds_read2_b32 v[22:23], v158 offset0:182 offset1:183
	ds_read2_b32 v[178:179], v158 offset0:6 offset1:7
	ds_read2_b32 v[180:181], v66 offset1:1
	v_pk_fma_f32 v[52:53], v[24:25], v[38:39], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[176:177], v[24:25], v[44:45], v[28:29] op_sel:[1,0,0]
	v_pk_fma_f32 v[182:183], v[12:13], v[44:45], v[26:27] op_sel:[1,0,0]
	ds_read2_b32 v[24:25], v158 offset0:198 offset1:199
	ds_read2_b32 v[26:27], v158 offset0:214 offset1:215
	ds_read2_b32 v[28:29], v158 offset0:230 offset1:231
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[40:41], v[22:23], v[180:181], v[54:55] op_sel_hi:[0,1,1]
	ds_read2_b32 v[54:55], v68 offset1:1
	v_pk_fma_f32 v[50:51], v[82:83], v[38:39], v[50:51] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[12:13], v[38:39], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[92:93], v[90:91], v[180:181], v[36:37] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[82:83], v[4:5], v[180:181], v[78:79] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[76:77], v[6:7], v[180:181], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[8:9], v[180:181], v[86:87] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[60:61], v[10:11], v[180:181], v[88:89] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[48:49], v[14:15], v[180:181], v[94:95] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[18:19], v[180:181], v[62:63] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[36:37], v[24:25], v[180:181], v[74:75] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[34:35], v[26:27], v[180:181], v[172:173] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[16:17], v[178:179], v[54:55], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[80:81], v[10:11], v[54:55], v[72:73] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[172:173], v[160:161], v[54:55], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[94:95], v[90:91], v[54:55], v[50:51] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[88:89], v[4:5], v[54:55], v[70:71] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[86:87], v[6:7], v[54:55], v[84:85] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[84:85], v[8:9], v[54:55], v[64:65] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[78:79], v[14:15], v[54:55], v[162:163] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[74:75], v[2:3], v[54:55], v[164:165] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[72:73], v[18:19], v[54:55], v[166:167] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[70:71], v[22:23], v[54:55], v[170:171] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[28:29], v[54:55], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[68:69], v[20:21], v[54:55], v[168:169] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[64:65], v[24:25], v[54:55], v[56:57] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[62:63], v[26:27], v[54:55], v[174:175] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[0:1], v[54:55], v[12:13] op_sel_hi:[0,1,1]
	ds_read2_b32 v[56:57], v101 offset1:1
	ds_read2_b32 v[54:55], v102 offset1:1
	v_pk_fma_f32 v[184:185], v[178:179], v[180:181], v[30:31] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[186:187], v[160:161], v[180:181], v[32:33] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[44:45], v[2:3], v[180:181], v[110:111] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[38:39], v[20:21], v[180:181], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[32:33], v[28:29], v[180:181], v[176:177] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[30:31], v[0:1], v[180:181], v[182:183] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[46:47], v[178:179], v[56:57], v[184:185] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[12:13], v[178:179], v[54:55], v[16:17] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[160:161], v[56:57], v[186:187] op_sel:[1,0,0]
	v_pk_fma_f32 v[16:17], v[160:161], v[54:55], v[172:173] op_sel:[1,0,0]
	ds_read2_b32 v[100:101], v100 offset1:1
	v_pk_fma_f32 v[92:93], v[90:91], v[56:57], v[92:93] op_sel:[1,0,0]
	v_pk_fma_f32 v[90:91], v[90:91], v[54:55], v[94:95] op_sel:[1,0,0]
	ds_read2_b32 v[94:95], v158 offset0:8 offset1:9
	v_pk_fma_f32 v[82:83], v[4:5], v[56:57], v[82:83] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[4:5], v[54:55], v[88:89] op_sel:[1,0,0]
	ds_read2_b32 v[88:89], v158 offset0:24 offset1:25
	v_pk_fma_f32 v[76:77], v[6:7], v[56:57], v[76:77] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[6:7], v[54:55], v[86:87] op_sel:[1,0,0]
	ds_read2_b32 v[86:87], v158 offset0:40 offset1:41
	v_pk_fma_f32 v[66:67], v[8:9], v[56:57], v[66:67] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[8:9], v[54:55], v[84:85] op_sel:[1,0,0]
	ds_read2_b32 v[84:85], v158 offset0:56 offset1:57
	v_pk_fma_f32 v[80:81], v[10:11], v[54:55], v[80:81] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[10:11], v[56:57], v[60:61] op_sel:[1,0,0]
	ds_read2_b32 v[60:61], v158 offset0:72 offset1:73
	v_pk_fma_f32 v[48:49], v[14:15], v[56:57], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[14:15], v[54:55], v[78:79] op_sel:[1,0,0]
	ds_read2_b32 v[78:79], v158 offset0:88 offset1:89
	v_pk_fma_f32 v[44:45], v[2:3], v[56:57], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[2:3], v[2:3], v[54:55], v[74:75] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v158 offset0:104 offset1:105
	v_pk_fma_f32 v[42:43], v[18:19], v[56:57], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[18:19], v[18:19], v[54:55], v[72:73] op_sel:[1,0,0]
	ds_read2_b32 v[72:73], v158 offset0:120 offset1:121
	v_pk_fma_f32 v[40:41], v[22:23], v[56:57], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[22:23], v[22:23], v[54:55], v[70:71] op_sel:[1,0,0]
	ds_read2_b32 v[70:71], v158 offset0:136 offset1:137
	v_pk_fma_f32 v[38:39], v[20:21], v[56:57], v[38:39] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[20:21], v[54:55], v[68:69] op_sel:[1,0,0]
	ds_read2_b32 v[68:69], v158 offset0:152 offset1:153
	v_pk_fma_f32 v[36:37], v[24:25], v[56:57], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[24:25], v[24:25], v[54:55], v[64:65] op_sel:[1,0,0]
	ds_read2_b32 v[64:65], v158 offset0:168 offset1:169
	v_pk_fma_f32 v[34:35], v[26:27], v[56:57], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[26:27], v[26:27], v[54:55], v[62:63] op_sel:[1,0,0]
	ds_read2_b32 v[62:63], v158 offset0:184 offset1:185
	v_pk_fma_f32 v[52:53], v[28:29], v[54:55], v[52:53] op_sel:[1,0,0]
	v_pk_fma_f32 v[28:29], v[28:29], v[56:57], v[32:33] op_sel:[1,0,0]
	ds_read2_b32 v[32:33], v158 offset0:200 offset1:201
	v_pk_fma_f32 v[30:31], v[0:1], v[56:57], v[30:31] op_sel:[1,0,0]
	ds_read2_b32 v[56:57], v158 offset0:216 offset1:217
	v_pk_fma_f32 v[0:1], v[0:1], v[54:55], v[50:51] op_sel:[1,0,0]
	ds_read2_b32 v[50:51], v158 offset0:232 offset1:233
	ds_read2_b32 v[54:55], v158 offset0:248 offset1:249
	s_waitcnt lgkmcnt(14)
	v_pk_fma_f32 v[46:47], v[94:95], v[100:101], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[58:59], v[88:89], v[100:101], v[58:59] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(13)
	v_pk_fma_f32 v[92:93], v[86:87], v[100:101], v[92:93] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(12)
	v_pk_fma_f32 v[82:83], v[84:85], v[100:101], v[82:83] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(11)
	v_pk_fma_f32 v[76:77], v[60:61], v[100:101], v[76:77] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(10)
	v_pk_fma_f32 v[66:67], v[78:79], v[100:101], v[66:67] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(9)
	v_pk_fma_f32 v[10:11], v[74:75], v[100:101], v[10:11] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(8)
	v_pk_fma_f32 v[48:49], v[72:73], v[100:101], v[48:49] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(7)
	v_pk_fma_f32 v[44:45], v[70:71], v[100:101], v[44:45] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(6)
	v_pk_fma_f32 v[42:43], v[68:69], v[100:101], v[42:43] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[38:39], v[64:65], v[100:101], v[38:39] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(4)
	v_pk_fma_f32 v[40:41], v[62:63], v[100:101], v[40:41] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[36:37], v[32:33], v[100:101], v[36:37] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[34:35], v[56:57], v[100:101], v[34:35] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[28:29], v[50:51], v[100:101], v[28:29] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[30:31], v[54:55], v[100:101], v[30:31] op_sel_hi:[0,1,1]
	ds_read2_b32 v[100:101], v99 offset1:1
	ds_read2_b32 v[98:99], v98 offset1:1
	v_add_u32_e32 v109, 0xb00, v136
	v_add_u32_e32 v108, 0xc00, v136
	v_add_u32_e32 v106, 0xd08, v136
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[12:13], v[94:95], v[100:101], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[80:81], v[74:75], v[100:101], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[16:17], v[88:89], v[100:101], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[90:91], v[86:87], v[100:101], v[90:91] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[4:5], v[84:85], v[100:101], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[6:7], v[60:61], v[100:101], v[6:7] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[8:9], v[78:79], v[100:101], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[14:15], v[72:73], v[100:101], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[2:3], v[70:71], v[100:101], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[18:19], v[68:69], v[100:101], v[18:19] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[62:63], v[100:101], v[22:23] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[50:51], v[100:101], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[20:21], v[64:65], v[100:101], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[32:33], v[100:101], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[26:27], v[56:57], v[100:101], v[26:27] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[0:1], v[54:55], v[100:101], v[0:1] op_sel_hi:[0,1,1]
	ds_read2_b32 v[100:101], v97 offset1:1
	s_waitcnt lgkmcnt(1)
	v_pk_fma_f32 v[46:47], v[94:95], v[98:99], v[46:47] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[88:89], v[98:99], v[58:59] op_sel:[1,0,0]
	v_pk_fma_f32 v[92:93], v[86:87], v[98:99], v[92:93] op_sel:[1,0,0]
	v_pk_fma_f32 v[82:83], v[84:85], v[98:99], v[82:83] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[12:13], v[94:95], v[100:101], v[12:13] op_sel:[1,0,0]
	ds_read2_b32 v[94:95], v158 offset0:10 offset1:11
	v_pk_fma_f32 v[16:17], v[88:89], v[100:101], v[16:17] op_sel:[1,0,0]
	ds_read2_b32 v[88:89], v158 offset0:12 offset1:13
	v_pk_fma_f32 v[86:87], v[86:87], v[100:101], v[90:91] op_sel:[1,0,0]
	ds_read2_b32 v[90:91], v158 offset0:26 offset1:27
	v_pk_fma_f32 v[4:5], v[84:85], v[100:101], v[4:5] op_sel:[1,0,0]
	ds_read2_b32 v[84:85], v158 offset0:42 offset1:43
	v_pk_fma_f32 v[76:77], v[60:61], v[98:99], v[76:77] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[60:61], v[100:101], v[6:7] op_sel:[1,0,0]
	ds_read2_b32 v[60:61], v158 offset0:58 offset1:59
	v_pk_fma_f32 v[66:67], v[78:79], v[98:99], v[66:67] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[78:79], v[100:101], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[78:79], v158 offset0:74 offset1:75
	v_pk_fma_f32 v[80:81], v[74:75], v[100:101], v[80:81] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[74:75], v[98:99], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v158 offset0:90 offset1:91
	v_pk_fma_f32 v[48:49], v[72:73], v[98:99], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[72:73], v[100:101], v[14:15] op_sel:[1,0,0]
	ds_read2_b32 v[72:73], v158 offset0:106 offset1:107
	v_pk_fma_f32 v[44:45], v[70:71], v[98:99], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[2:3], v[70:71], v[100:101], v[2:3] op_sel:[1,0,0]
	ds_read2_b32 v[70:71], v158 offset0:122 offset1:123
	v_pk_fma_f32 v[42:43], v[68:69], v[98:99], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[18:19], v[68:69], v[100:101], v[18:19] op_sel:[1,0,0]
	ds_read2_b32 v[68:69], v158 offset0:138 offset1:139
	v_pk_fma_f32 v[40:41], v[62:63], v[98:99], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[22:23], v[62:63], v[100:101], v[22:23] op_sel:[1,0,0]
	ds_read2_b32 v[62:63], v158 offset0:154 offset1:155
	v_pk_fma_f32 v[38:39], v[64:65], v[98:99], v[38:39] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[64:65], v[100:101], v[20:21] op_sel:[1,0,0]
	ds_read2_b32 v[64:65], v158 offset0:170 offset1:171
	v_pk_fma_f32 v[36:37], v[32:33], v[98:99], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[24:25], v[32:33], v[100:101], v[24:25] op_sel:[1,0,0]
	ds_read2_b32 v[32:33], v158 offset0:186 offset1:187
	v_pk_fma_f32 v[34:35], v[56:57], v[98:99], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[26:27], v[56:57], v[100:101], v[26:27] op_sel:[1,0,0]
	ds_read2_b32 v[56:57], v158 offset0:202 offset1:203
	v_pk_fma_f32 v[52:53], v[50:51], v[100:101], v[52:53] op_sel:[1,0,0]
	v_pk_fma_f32 v[28:29], v[50:51], v[98:99], v[28:29] op_sel:[1,0,0]
	ds_read2_b32 v[50:51], v158 offset0:218 offset1:219
	v_pk_fma_f32 v[30:31], v[54:55], v[98:99], v[30:31] op_sel:[1,0,0]
	ds_read2_b32 v[98:99], v158 offset0:234 offset1:235
	ds_read2_b32 v[162:163], v105 offset1:1
	v_pk_fma_f32 v[0:1], v[54:55], v[100:101], v[0:1] op_sel:[1,0,0]
	ds_read2_b32 v[54:55], v158 offset0:250 offset1:251
	ds_read2_b32 v[96:97], v96 offset1:1
	ds_read2_b32 v[100:101], v104 offset1:1
	ds_read2_b32 v[104:105], v109 offset1:1
	ds_read2_b32 v[168:169], v158 offset0:172 offset1:173
	ds_read2_b32 v[170:171], v158 offset0:188 offset1:189
	ds_read2_b32 v[172:173], v158 offset0:204 offset1:205
	s_waitcnt lgkmcnt(7)
	v_pk_fma_f32 v[46:47], v[94:95], v[162:163], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[58:59], v[90:91], v[162:163], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[92:93], v[84:85], v[162:163], v[92:93] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[82:83], v[60:61], v[162:163], v[82:83] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[76:77], v[78:79], v[162:163], v[76:77] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[74:75], v[162:163], v[66:67] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[10:11], v[72:73], v[162:163], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[48:49], v[70:71], v[162:163], v[48:49] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[44:45], v[68:69], v[162:163], v[44:45] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[62:63], v[162:163], v[42:43] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[38:39], v[64:65], v[162:163], v[38:39] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[40:41], v[32:33], v[162:163], v[40:41] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[56:57], v[162:163], v[36:37] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[50:51], v[162:163], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[28:29], v[98:99], v[162:163], v[28:29] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(6)
	v_pk_fma_f32 v[30:31], v[54:55], v[162:163], v[30:31] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(5)
	v_pk_fma_f32 v[12:13], v[94:95], v[96:97], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[80:81], v[72:73], v[96:97], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[86:87], v[84:85], v[96:97], v[86:87] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[162:163], v[60:61], v[96:97], v[4:5] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[164:165], v[78:79], v[96:97], v[6:7] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[8:9], v[74:75], v[96:97], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[14:15], v[70:71], v[96:97], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[166:167], v[68:69], v[96:97], v[2:3] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[18:19], v[62:63], v[96:97], v[18:19] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[22:23], v[32:33], v[96:97], v[22:23] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[56:57], v[96:97], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[16:17], v[90:91], v[96:97], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[52:53], v[98:99], v[96:97], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[20:21], v[64:65], v[96:97], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[26:27], v[50:51], v[96:97], v[26:27] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[96:97], v[54:55], v[96:97], v[0:1] op_sel_hi:[0,1,1]
	ds_read2_b32 v[2:3], v158 offset0:14 offset1:15
	ds_read2_b32 v[4:5], v158 offset0:30 offset1:31
	ds_read2_b32 v[6:7], v158 offset0:46 offset1:47
	s_waitcnt lgkmcnt(6)
	v_pk_fma_f32 v[46:47], v[94:95], v[104:105], v[46:47] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[94:95], v[100:101], v[12:13] op_sel:[1,0,0]
	ds_read2_b32 v[94:95], v158 offset0:28 offset1:29
	v_pk_fma_f32 v[92:93], v[84:85], v[104:105], v[92:93] op_sel:[1,0,0]
	v_pk_fma_f32 v[84:85], v[84:85], v[100:101], v[86:87] op_sel:[1,0,0]
	ds_read2_b32 v[86:87], v158 offset0:44 offset1:45
	v_pk_fma_f32 v[82:83], v[60:61], v[104:105], v[82:83] op_sel:[1,0,0]
	v_pk_fma_f32 v[60:61], v[60:61], v[100:101], v[162:163] op_sel:[1,0,0]
	v_pk_fma_f32 v[76:77], v[78:79], v[104:105], v[76:77] op_sel:[1,0,0]
	v_pk_fma_f32 v[78:79], v[78:79], v[100:101], v[164:165] op_sel:[1,0,0]
	ds_read2_b32 v[162:163], v158 offset0:60 offset1:61
	v_pk_fma_f32 v[66:67], v[74:75], v[104:105], v[66:67] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[74:75], v[100:101], v[8:9] op_sel:[1,0,0]
	ds_read2_b32 v[74:75], v158 offset0:76 offset1:77
	v_pk_fma_f32 v[80:81], v[72:73], v[100:101], v[80:81] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[72:73], v[104:105], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[72:73], v158 offset0:92 offset1:93
	ds_read2_b32 v[164:165], v158 offset0:124 offset1:125
	v_pk_fma_f32 v[48:49], v[70:71], v[104:105], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[70:71], v[100:101], v[14:15] op_sel:[1,0,0]
	ds_read2_b32 v[70:71], v158 offset0:108 offset1:109
	v_pk_fma_f32 v[44:45], v[68:69], v[104:105], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[68:69], v[68:69], v[100:101], v[166:167] op_sel:[1,0,0]
	v_pk_fma_f32 v[42:43], v[62:63], v[104:105], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[18:19], v[62:63], v[100:101], v[18:19] op_sel:[1,0,0]
	ds_read2_b32 v[62:63], v158 offset0:140 offset1:141
	v_pk_fma_f32 v[40:41], v[32:33], v[104:105], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[22:23], v[32:33], v[100:101], v[22:23] op_sel:[1,0,0]
	ds_read2_b32 v[166:167], v158 offset0:156 offset1:157
	v_pk_fma_f32 v[32:33], v[64:65], v[104:105], v[38:39] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[56:57], v[104:105], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[38:39], v[56:57], v[100:101], v[24:25] op_sel:[1,0,0]
	ds_read2_b32 v[174:175], v158 offset0:220 offset1:221
	ds_read2_b32 v[0:1], v158 offset0:236 offset1:237
	ds_read2_b32 v[56:57], v108 offset1:1
	v_pk_fma_f32 v[34:35], v[50:51], v[104:105], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[50:51], v[50:51], v[100:101], v[26:27] op_sel:[1,0,0]
	v_pk_fma_f32 v[26:27], v[98:99], v[104:105], v[28:29] op_sel:[1,0,0]
	v_add_u32_e32 v107, 0xd00, v136
	v_pk_fma_f32 v[58:59], v[90:91], v[104:105], v[58:59] op_sel:[1,0,0]
	v_pk_fma_f32 v[90:91], v[90:91], v[100:101], v[16:17] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[64:65], v[100:101], v[20:21] op_sel:[1,0,0]
	ds_read2_b32 v[16:17], v158 offset0:252 offset1:253
	ds_read2_b32 v[64:65], v103 offset1:1
	ds_read2_b32 v[24:25], v107 offset1:1
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[28:29], v[0:1], v[56:57], v[26:27] op_sel_hi:[0,1,1]
	ds_read2_b32 v[26:27], v106 offset1:1
	v_add_u32_e32 v110, 0xe08, v136
	v_add_u32_e32 v111, 0xf00, v136
	v_add_u32_e32 v160, 0xe00, v136
	v_pk_fma_f32 v[52:53], v[98:99], v[100:101], v[52:53] op_sel:[1,0,0]
	v_pk_fma_f32 v[30:31], v[54:55], v[104:105], v[30:31] op_sel:[1,0,0]
	v_pk_fma_f32 v[54:55], v[54:55], v[100:101], v[96:97] op_sel:[1,0,0]
	v_pk_fma_f32 v[46:47], v[88:89], v[56:57], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[92:93], v[86:87], v[56:57], v[92:93] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[76:77], v[74:75], v[56:57], v[76:77] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[66:67], v[72:73], v[56:57], v[66:67] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[96:97], v[70:71], v[56:57], v[10:11] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[48:49], v[164:165], v[56:57], v[48:49] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[98:99], v[62:63], v[56:57], v[44:45] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[100:101], v[166:167], v[56:57], v[42:43] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[102:103], v[170:171], v[56:57], v[40:41] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(2)
	v_pk_fma_f32 v[10:11], v[88:89], v[64:65], v[12:13] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[70:71], v[64:65], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[12:13], v[94:95], v[64:65], v[90:91] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[40:41], v[74:75], v[64:65], v[78:79] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[78:79], v[72:73], v[64:65], v[8:9] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[68:69], v[62:63], v[64:65], v[68:69] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[104:105], v[168:169], v[56:57], v[32:33] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[108:109], v[172:173], v[56:57], v[36:37] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[176:177], v[174:175], v[56:57], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[86:87], v[64:65], v[84:85] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[162:163], v[64:65], v[60:61] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[90:91], v[164:165], v[64:65], v[14:15] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[178:179], v[170:171], v[64:65], v[22:23] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[44:45], v[0:1], v[64:65], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[180:181], v[168:169], v[64:65], v[20:21] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[182:183], v[172:173], v[64:65], v[38:39] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[184:185], v[174:175], v[64:65], v[50:51] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[16:17], v[64:65], v[54:55] op_sel_hi:[0,1,1]
	ds_read2_b32 v[8:9], v158 offset0:62 offset1:63
	ds_read2_b32 v[14:15], v158 offset0:110 offset1:111
	ds_read2_b32 v[20:21], v158 offset0:142 offset1:143
	v_pk_fma_f32 v[106:107], v[166:167], v[64:65], v[18:19] op_sel_hi:[0,1,1]
	s_waitcnt lgkmcnt(4)
	v_pk_fma_f32 v[52:53], v[88:89], v[24:25], v[46:47] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(3)
	v_pk_fma_f32 v[54:55], v[88:89], v[26:27], v[10:11] op_sel:[1,0,0]
	ds_read2_b32 v[10:11], v158 offset0:78 offset1:79
	ds_read2_b32 v[18:19], v158 offset0:126 offset1:127
	ds_read2_b32 v[22:23], v158 offset0:158 offset1:159
	v_pk_fma_f32 v[32:33], v[94:95], v[26:27], v[12:13] op_sel:[1,0,0]
	ds_read2_b32 v[12:13], v158 offset0:94 offset1:95
	v_pk_fma_f32 v[60:61], v[86:87], v[24:25], v[92:93] op_sel:[1,0,0]
	v_pk_fma_f32 v[84:85], v[74:75], v[24:25], v[76:77] op_sel:[1,0,0]
	v_pk_fma_f32 v[38:39], v[74:75], v[26:27], v[40:41] op_sel:[1,0,0]
	v_pk_fma_f32 v[88:89], v[72:73], v[24:25], v[66:67] op_sel:[1,0,0]
	v_pk_fma_f32 v[40:41], v[72:73], v[26:27], v[78:79] op_sel:[1,0,0]
	v_pk_fma_f32 v[42:43], v[70:71], v[26:27], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[92:93], v[70:71], v[24:25], v[96:97] op_sel:[1,0,0]
	ds_read2_b32 v[64:65], v158 offset0:174 offset1:175
	ds_read2_b32 v[66:67], v158 offset0:190 offset1:191
	ds_read2_b32 v[70:71], v158 offset0:222 offset1:223
	v_pk_fma_f32 v[96:97], v[164:165], v[24:25], v[48:49] op_sel:[1,0,0]
	v_pk_fma_f32 v[98:99], v[62:63], v[24:25], v[98:99] op_sel:[1,0,0]
	v_pk_fma_f32 v[48:49], v[62:63], v[26:27], v[68:69] op_sel:[1,0,0]
	ds_read2_b32 v[68:69], v158 offset0:206 offset1:207
	ds_read2_b32 v[72:73], v158 offset0:238 offset1:239
	ds_read2_b32 v[74:75], v158 offset0:254 offset1:255
	ds_read2_b32 v[62:63], v110 offset1:1
	ds_read2_b32 v[76:77], v111 offset1:1
	ds_read2_b32 v[78:79], v159 offset1:1
	ds_read2_b32 v[110:111], v160 offset1:1
	v_pk_fma_f32 v[58:59], v[94:95], v[56:57], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[82:83], v[162:163], v[56:57], v[82:83] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[30:31], v[16:17], v[56:57], v[30:31] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[56:57], v[94:95], v[24:25], v[58:59] op_sel:[1,0,0]
	v_pk_fma_f32 v[34:35], v[86:87], v[26:27], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[80:81], v[162:163], v[24:25], v[82:83] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[162:163], v[26:27], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[46:47], v[164:165], v[26:27], v[90:91] op_sel:[1,0,0]
	v_pk_fma_f32 v[100:101], v[166:167], v[24:25], v[100:101] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[166:167], v[26:27], v[106:107] op_sel:[1,0,0]
	v_pk_fma_f32 v[102:103], v[170:171], v[24:25], v[102:103] op_sel:[1,0,0]
	v_pk_fma_f32 v[86:87], v[170:171], v[26:27], v[178:179] op_sel:[1,0,0]
	v_pk_fma_f32 v[104:105], v[168:169], v[24:25], v[104:105] op_sel:[1,0,0]
	v_pk_fma_f32 v[82:83], v[168:169], v[26:27], v[180:181] op_sel:[1,0,0]
	v_pk_fma_f32 v[106:107], v[172:173], v[24:25], v[108:109] op_sel:[1,0,0]
	v_pk_fma_f32 v[90:91], v[172:173], v[26:27], v[182:183] op_sel:[1,0,0]
	v_pk_fma_f32 v[108:109], v[174:175], v[24:25], v[176:177] op_sel:[1,0,0]
	v_pk_fma_f32 v[94:95], v[174:175], v[26:27], v[184:185] op_sel:[1,0,0]
	v_pk_fma_f32 v[44:45], v[0:1], v[26:27], v[44:45] op_sel:[1,0,0]
	v_pk_fma_f32 v[0:1], v[0:1], v[24:25], v[28:29] op_sel:[1,0,0]
	v_pk_fma_f32 v[24:25], v[16:17], v[24:25], v[30:31] op_sel:[1,0,0]
	v_pk_fma_f32 v[16:17], v[16:17], v[26:27], v[50:51] op_sel:[1,0,0]
	s_waitcnt lgkmcnt(0)
	v_pk_fma_f32 v[26:27], v[2:3], v[110:111], v[52:53] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[28:29], v[2:3], v[62:63], v[54:55] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[30:31], v[4:5], v[110:111], v[56:57] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[50:51], v[6:7], v[110:111], v[60:61] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[54:55], v[8:9], v[110:111], v[80:81] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[80:81], v[10:11], v[110:111], v[84:85] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[84:85], v[12:13], v[110:111], v[88:89] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[88:89], v[14:15], v[110:111], v[92:93] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[92:93], v[18:19], v[110:111], v[96:97] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[96:97], v[64:65], v[110:111], v[104:105] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[98:99], v[20:21], v[110:111], v[98:99] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[100:101], v[22:23], v[110:111], v[100:101] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[102:103], v[66:67], v[110:111], v[102:103] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[104:105], v[68:69], v[110:111], v[106:107] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[106:107], v[70:71], v[110:111], v[108:109] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[108:109], v[72:73], v[110:111], v[0:1] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[110:111], v[74:75], v[110:111], v[24:25] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[24:25], v[4:5], v[62:63], v[32:33] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[32:33], v[6:7], v[62:63], v[34:35] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[34:35], v[8:9], v[62:63], v[36:37] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[36:37], v[10:11], v[62:63], v[38:39] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[42:43], v[14:15], v[62:63], v[42:43] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[38:39], v[12:13], v[62:63], v[40:41] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[160:161], v[18:19], v[62:63], v[46:47] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[86:87], v[66:67], v[62:63], v[86:87] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[162:163], v[72:73], v[62:63], v[44:45] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[164:165], v[20:21], v[62:63], v[48:49] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[166:167], v[22:23], v[62:63], v[58:59] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[82:83], v[64:65], v[62:63], v[82:83] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[90:91], v[68:69], v[62:63], v[90:91] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[94:95], v[70:71], v[62:63], v[94:95] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[168:169], v[74:75], v[62:63], v[16:17] op_sel_hi:[0,1,1]
	v_pk_fma_f32 v[0:1], v[2:3], v[76:77], v[26:27] op_sel:[1,0,0]
	v_pk_fma_f32 v[2:3], v[2:3], v[78:79], v[28:29] op_sel:[1,0,0]
	v_pk_fma_f32 v[62:63], v[4:5], v[76:77], v[30:31] op_sel:[1,0,0]
	v_pk_fma_f32 v[58:59], v[4:5], v[78:79], v[24:25] op_sel:[1,0,0]
	v_pk_fma_f32 v[60:61], v[6:7], v[76:77], v[50:51] op_sel:[1,0,0]
	v_pk_fma_f32 v[52:53], v[6:7], v[78:79], v[32:33] op_sel:[1,0,0]
	v_pk_fma_f32 v[56:57], v[8:9], v[76:77], v[54:55] op_sel:[1,0,0]
	v_pk_fma_f32 v[50:51], v[8:9], v[78:79], v[34:35] op_sel:[1,0,0]
	v_pk_fma_f32 v[54:55], v[10:11], v[76:77], v[80:81] op_sel:[1,0,0]
	v_pk_fma_f32 v[46:47], v[10:11], v[78:79], v[36:37] op_sel:[1,0,0]
	v_pk_fma_f32 v[48:49], v[12:13], v[76:77], v[84:85] op_sel:[1,0,0]
	v_pk_fma_f32 v[38:39], v[12:13], v[78:79], v[38:39] op_sel:[1,0,0]
	v_pk_fma_f32 v[44:45], v[14:15], v[76:77], v[88:89] op_sel:[1,0,0]
	v_pk_fma_f32 v[42:43], v[14:15], v[78:79], v[42:43] op_sel:[1,0,0]
	v_pk_fma_f32 v[40:41], v[18:19], v[76:77], v[92:93] op_sel:[1,0,0]
	v_pk_fma_f32 v[34:35], v[18:19], v[78:79], v[160:161] op_sel:[1,0,0]
	v_pk_fma_f32 v[36:37], v[20:21], v[76:77], v[98:99] op_sel:[1,0,0]
	v_pk_fma_f32 v[30:31], v[20:21], v[78:79], v[164:165] op_sel:[1,0,0]
	v_pk_fma_f32 v[32:33], v[22:23], v[76:77], v[100:101] op_sel:[1,0,0]
	v_pk_fma_f32 v[26:27], v[22:23], v[78:79], v[166:167] op_sel:[1,0,0]
	v_pk_fma_f32 v[28:29], v[64:65], v[76:77], v[96:97] op_sel:[1,0,0]
	v_pk_fma_f32 v[18:19], v[64:65], v[78:79], v[82:83] op_sel:[1,0,0]
	v_pk_fma_f32 v[24:25], v[66:67], v[76:77], v[102:103] op_sel:[1,0,0]
	v_pk_fma_f32 v[16:17], v[66:67], v[78:79], v[86:87] op_sel:[1,0,0]
	v_pk_fma_f32 v[20:21], v[68:69], v[76:77], v[104:105] op_sel:[1,0,0]
	v_pk_fma_f32 v[10:11], v[68:69], v[78:79], v[90:91] op_sel:[1,0,0]
	v_pk_fma_f32 v[14:15], v[70:71], v[76:77], v[106:107] op_sel:[1,0,0]
	v_pk_fma_f32 v[6:7], v[70:71], v[78:79], v[94:95] op_sel:[1,0,0]
	v_pk_fma_f32 v[8:9], v[72:73], v[76:77], v[108:109] op_sel:[1,0,0]
	v_pk_fma_f32 v[22:23], v[72:73], v[78:79], v[162:163] op_sel:[1,0,0]
	v_pk_fma_f32 v[12:13], v[74:75], v[76:77], v[110:111] op_sel:[1,0,0]
	v_pk_fma_f32 v[4:5], v[74:75], v[78:79], v[168:169] op_sel:[1,0,0]
	s_barrier
	s_cbranch_scc1 .LBB0_2
	s_branch .LBB0_5
.LBB0_4:
	v_mov_b32_e32 v22, 0
	v_mov_b32_e32 v113, v114
	v_mov_b32_e32 v23, v22
	v_mov_b32_e32 v18, v22
	v_mov_b32_e32 v19, v22
	v_mov_b32_e32 v42, v22
	v_mov_b32_e32 v43, v22
	v_mov_b32_e32 v52, v22
	v_mov_b32_e32 v53, v22
	v_mov_b32_e32 v0, v22
	v_mov_b32_e32 v1, v22
	v_mov_b32_e32 v2, v22
	v_mov_b32_e32 v3, v22
	v_mov_b32_e32 v62, v22
	v_mov_b32_e32 v63, v22
	v_mov_b32_e32 v58, v22
	v_mov_b32_e32 v59, v22
	v_mov_b32_e32 v60, v22
	v_mov_b32_e32 v61, v22
	v_mov_b32_e32 v56, v22
	v_mov_b32_e32 v57, v22
	v_mov_b32_e32 v50, v22
	v_mov_b32_e32 v51, v22
	v_mov_b32_e32 v54, v22
	v_mov_b32_e32 v55, v22
	v_mov_b32_e32 v46, v22
	v_mov_b32_e32 v47, v22
	v_mov_b32_e32 v48, v22
	v_mov_b32_e32 v49, v22
	v_mov_b32_e32 v38, v22
	v_mov_b32_e32 v39, v22
	v_mov_b32_e32 v44, v22
	v_mov_b32_e32 v45, v22
	v_mov_b32_e32 v40, v22
	v_mov_b32_e32 v41, v22
	v_mov_b32_e32 v34, v22
	v_mov_b32_e32 v35, v22
	v_mov_b32_e32 v36, v22
	v_mov_b32_e32 v37, v22
	v_mov_b32_e32 v30, v22
	v_mov_b32_e32 v31, v22
	v_mov_b32_e32 v32, v22
	v_mov_b32_e32 v33, v22
	v_mov_b32_e32 v26, v22
	v_mov_b32_e32 v27, v22
	v_mov_b32_e32 v28, v22
	v_mov_b32_e32 v29, v22
	v_mov_b32_e32 v24, v22
	v_mov_b32_e32 v25, v22
	v_mov_b32_e32 v16, v22
	v_mov_b32_e32 v17, v22
	v_mov_b32_e32 v20, v22
	v_mov_b32_e32 v21, v22
	v_mov_b32_e32 v10, v22
	v_mov_b32_e32 v11, v22
	v_mov_b32_e32 v14, v22
	v_mov_b32_e32 v15, v22
	v_mov_b32_e32 v6, v22
	v_mov_b32_e32 v7, v22
	v_mov_b32_e32 v8, v22
	v_mov_b32_e32 v9, v22
	v_mov_b32_e32 v12, v22
	v_mov_b32_e32 v13, v22
	v_mov_b32_e32 v4, v22
	v_mov_b32_e32 v5, v22
.LBB0_5:
	v_add_u32_e32 v64, s3, v112
	s_lshl_b32 s0, s2, 6
	v_mul_lo_u32 v64, v64, s10
	v_add3_u32 v64, v113, s0, v64
	v_lshlrev_b32_e32 v65, 2, v64
	global_store_dwordx4 v65, v[0:3], s[8:9]
	s_nop 1
	v_add_u32_e32 v0, s10, v64
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v62, s[8:9]
	global_store_dword v2, v63, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v59, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v58, s[8:9]
	global_store_dword v1, v60, s[8:9]
	v_or_b32_e32 v2, 4, v1
	v_add_u32_e32 v1, 8, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v61, s[8:9]
	global_store_dwordx2 v1, v[52:53], s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v56, s[8:9]
	global_store_dword v2, v57, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v51, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v50, s[8:9]
	v_or_b32_e32 v2, 4, v1
	global_store_dword v1, v54, s[8:9]
	global_store_dword v2, v55, s[8:9]
	v_or_b32_e32 v2, 8, v1
	v_or_b32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v46, s[8:9]
	global_store_dword v1, v47, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v48, s[8:9]
	global_store_dword v2, v49, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v39, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v38, s[8:9]
	global_store_dword v1, v44, s[8:9]
	v_or_b32_e32 v2, 4, v1
	v_add_u32_e32 v1, 8, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v45, s[8:9]
	global_store_dwordx2 v1, v[42:43], s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v40, s[8:9]
	global_store_dword v2, v41, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v35, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v34, s[8:9]
	v_or_b32_e32 v2, 4, v1
	global_store_dword v1, v36, s[8:9]
	global_store_dword v2, v37, s[8:9]
	v_or_b32_e32 v2, 8, v1
	v_or_b32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v30, s[8:9]
	global_store_dword v1, v31, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v32, s[8:9]
	global_store_dword v2, v33, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v27, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v26, s[8:9]
	global_store_dword v1, v28, s[8:9]
	v_or_b32_e32 v2, 4, v1
	v_add_u32_e32 v1, 8, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v29, s[8:9]
	global_store_dwordx2 v1, v[18:19], s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v24, s[8:9]
	global_store_dword v2, v25, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v17, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v16, s[8:9]
	v_or_b32_e32 v2, 4, v1
	global_store_dword v1, v20, s[8:9]
	global_store_dword v2, v21, s[8:9]
	v_or_b32_e32 v2, 8, v1
	v_or_b32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v2, v10, s[8:9]
	global_store_dword v1, v11, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	v_add_u32_e32 v2, 4, v1
	global_store_dword v1, v14, s[8:9]
	global_store_dword v2, v15, s[8:9]
	v_add_u32_e32 v2, 8, v1
	v_add_u32_e32 v1, 12, v1
	v_add_u32_e32 v0, s10, v0
	global_store_dword v1, v7, s[8:9]
	v_lshlrev_b32_e32 v1, 2, v0
	global_store_dword v2, v6, s[8:9]
	global_store_dword v1, v8, s[8:9]
	v_or_b32_e32 v2, 4, v1
	v_add_u32_e32 v1, 8, v1
	v_add_lshl_u32 v0, v0, s10, 2
	global_store_dword v2, v9, s[8:9]
	global_store_dwordx2 v1, v[22:23], s[8:9]
	v_add_u32_e32 v1, 4, v0
	global_store_dword v0, v12, s[8:9]
	global_store_dword v1, v13, s[8:9]
	v_add_u32_e32 v1, 8, v0
	v_add_u32_e32 v0, 12, v0
	global_store_dword v1, v4, s[8:9]
	global_store_dword v0, v5, s[8:9]
	s_endpgm
.LBB0_6:
	s_cbranch_execnz .LBB0_4
	s_branch .LBB0_5
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel matmul
		.amdhsa_group_segment_fixed_size 20480
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 32
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
		.amdhsa_next_free_vgpr 188
		.amdhsa_next_free_sgpr 12
		.amdhsa_accum_offset 188
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

	.set matmul.num_vgpr, 188
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
      - .offset:         28
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 20480
    .kernarg_segment_align: 8
    .kernarg_segment_size: 32
    .max_flat_workgroup_size: 256
    .name:           matmul
    .private_segment_fixed_size: 0
    .sgpr_count:     18
    .sgpr_spill_count: 0
    .symbol:         matmul.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     188
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
