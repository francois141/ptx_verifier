	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8 ; -- Begin function _fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
	.p2align	8
	.type	_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8,@function
_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8: ; @_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.8:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/attention" "extend_attention.py"
	.loc	1 54 0 prologue_end             ; extend_attention.py:54:0
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
.Ltmp1:
	.loc	1 307 9 is_stmt 1               ; extend_attention.py:307:9
	v_readfirstlane_b32 s33, v0
	.loc	1 106 32                        ; extend_attention.py:106:32
	s_ashr_i32 s17, s16, 31
	s_mov_b64 s[40:41], s[2:3]
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_and_b32 s69, s33, 0xc0
	.loc	1 106 32                        ; extend_attention.py:106:32
	s_lshl_b64 s[2:3], s[16:17], 2
	s_mov_b64 s[64:65], s[6:7]
	s_add_u32 s6, s14, s2
	s_mov_b64 s[36:37], s[10:11]
	s_addc_u32 s7, s15, s3
	.loc	1 107 34                        ; extend_attention.py:107:34
	s_add_i32 s10, s16, 1
	.loc	1 107 26 is_stmt 0              ; extend_attention.py:107:26
	s_ashr_i32 s11, s10, 31
	s_lshl_b64 s[10:11], s[10:11], 2
	s_add_u32 s14, s14, s10
	s_addc_u32 s15, s15, s11
	.loc	1 106 32 is_stmt 1              ; extend_attention.py:106:32
	s_load_dword s70, s[6:7], 0x0
	.loc	1 107 26                        ; extend_attention.py:107:26
	s_load_dword s18, s[14:15], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x38
	s_load_dwordx2 s[62:63], s[0:1], 0x48
	.loc	1 115 14                        ; extend_attention.py:115:14
	v_and_b32_e32 v2, 63, v0
	v_or_b32_e32 v64, s69, v2
	.loc	1 107 26                        ; extend_attention.py:107:26
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s31, s18, s70
	.loc	1 127 11                        ; extend_attention.py:127:11
	v_lshlrev_b32_e32 v3, 3, v0
	.loc	1 108 28                        ; extend_attention.py:108:28
	s_add_u32 s6, s16, s2
	.loc	1 115 14                        ; extend_attention.py:115:14
	v_lshrrev_b32_e32 v65, 3, v64
	.loc	1 127 11                        ; extend_attention.py:127:11
	v_and_b32_e32 v1, 56, v3
	.loc	1 130 9                         ; extend_attention.py:130:9
	s_mul_i32 s2, s70, s63
	.loc	1 108 28                        ; extend_attention.py:108:28
	s_addc_u32 s7, s17, s3
	.loc	1 115 14                        ; extend_attention.py:115:14
	v_or_b32_e32 v66, 32, v65
	.loc	1 130 9                         ; extend_attention.py:130:9
	v_mul_lo_u32 v4, v65, s63
	v_add_u32_e32 v8, s2, v1
	.loc	1 109 26                        ; extend_attention.py:109:26
	s_add_u32 s10, s16, s10
	.loc	1 117 14                        ; extend_attention.py:117:14
	v_or_b32_e32 v67, 64, v65
	.loc	1 130 9                         ; extend_attention.py:130:9
	v_mul_lo_u32 v5, v66, s63
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_add_lshl_u32 v4, v8, v4, 1
	v_bfrev_b32_e32 v44, 1
	.loc	1 118 14                        ; extend_attention.py:118:14
	v_cmp_gt_i32_e64 s[18:19], s31, v65
	.loc	1 109 26                        ; extend_attention.py:109:26
	s_addc_u32 s11, s17, s11
	.loc	1 117 14                        ; extend_attention.py:117:14
	v_or_b32_e32 v68, 0x60, v65
	.loc	1 130 9                         ; extend_attention.py:130:9
	v_mul_lo_u32 v6, v67, s63
	.loc	1 129 9                         ; extend_attention.py:129:9
	s_and_b32 s41, s41, 0xffff
	s_mov_b32 s43, 0x27000
	s_mov_b32 s42, 0x7ffffffe
	v_cndmask_b32_e64 v4, v44, v4, s[18:19]
	v_add_lshl_u32 v5, v8, v5, 1
	.loc	1 118 14                        ; extend_attention.py:118:14
	v_cmp_gt_i32_e64 s[2:3], s31, v66
	.loc	1 130 9                         ; extend_attention.py:130:9
	v_mul_lo_u32 v7, v68, s63
	.loc	1 118 14                        ; extend_attention.py:118:14
	v_cmp_gt_i32_e64 s[16:17], s31, v67
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_cndmask_b32_e64 v5, v44, v5, s[2:3]
	buffer_load_dwordx4 v[12:15], v4, s[40:43], 0 offen
	buffer_load_dwordx4 v[16:19], v5, s[40:43], 0 offen
	v_add_lshl_u32 v4, v8, v6, 1
	v_cndmask_b32_e64 v4, v44, v4, s[16:17]
	v_add_lshl_u32 v5, v8, v7, 1
	.loc	1 118 14                        ; extend_attention.py:118:14
	v_cmp_gt_i32_e64 s[20:21], s31, v68
	.loc	1 129 9                         ; extend_attention.py:129:9
	s_movk_i32 s14, 0x70
	.loc	1 117 14                        ; extend_attention.py:117:14
	v_and_b32_e32 v6, 15, v0
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_cndmask_b32_e64 v5, v44, v5, s[20:21]
	buffer_load_dwordx4 v[20:23], v4, s[40:43], 0 offen
	buffer_load_dwordx4 v[24:27], v5, s[40:43], 0 offen
	.loc	1 115 14                        ; extend_attention.py:115:14
	v_and_b32_e32 v5, 48, v0
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_lshlrev_b32_e32 v7, 7, v6
	v_bitop3_b32 v9, v3, v5, s14 bitop3:0x6c
	v_lshlrev_b32_e32 v38, 4, v64
	.loc	1 117 14                        ; extend_attention.py:117:14
	s_lshr_b32 s15, s69, 2
	.loc	1 129 9                         ; extend_attention.py:129:9
	s_lshl_b32 s22, s69, 5
	v_bitop3_b32 v10, v38, v64, s14 bitop3:0x78
	.loc	1 117 14                        ; extend_attention.py:117:14
	v_or_b32_e32 v71, s15, v6
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_or3_b32 v6, s22, v9, v7
	v_add_u32_e32 v70, 0, v10
	v_add_u32_e32 v9, 0, v6
	.loc	1 108 28                        ; extend_attention.py:108:28
	s_load_dword s14, s[6:7], 0x0
	.loc	1 109 26                        ; extend_attention.py:109:26
	s_load_dword s23, s[10:11], 0x0
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_xad_u32 v6, v6, 64, 0
	v_mov_b32_e32 v4, 0x70
	v_and_b32_e32 v8, 0x70, v3
	.loc	1 115 14                        ; extend_attention.py:115:14
	v_lshrrev_b32_e32 v69, 2, v5
	.loc	1 129 9                         ; extend_attention.py:129:9
	v_bitop3_b32 v4, s69, v4, v2 bitop3:0xc8
	.loc	1 117 14                        ; extend_attention.py:117:14
	v_or_b32_e32 v72, 64, v71
	.loc	1 109 26                        ; extend_attention.py:109:26
	s_waitcnt lgkmcnt(0)
	s_sub_i32 s35, s23, s14
	v_bitop3_b32 v5, v7, v5, v8 bitop3:0x36
	v_add_u32_e32 v2, s69, v2
	s_mov_b32 s34, 0
	.loc	1 118 14                        ; extend_attention.py:118:14
	v_cmp_gt_i32_e32 vcc, s31, v71
	v_cmp_gt_i32_e64 s[10:11], s31, v72
	.loc	1 150 5                         ; extend_attention.py:150:5
	s_cmp_lt_i32 s35, 1
	v_xor_b32_e32 v39, 64, v5
	v_lshrrev_b32_e32 v42, 1, v4
	v_lshlrev_b32_e32 v40, 5, v0
	v_and_b32_e32 v41, 24, v3
	v_and_b32_e32 v43, 56, v0
	v_lshrrev_b32_e32 v73, 3, v2
	v_add_u32_e32 v74, 0, v5
	.loc	1 129 9                         ; extend_attention.py:129:9
	s_waitcnt vmcnt(3)
	ds_write_b128 v70, v[12:15]
	s_waitcnt vmcnt(2)
	ds_write_b128 v70, v[16:19] offset:4096
	s_waitcnt vmcnt(1)
	ds_write_b128 v70, v[20:23] offset:8192
	s_waitcnt vmcnt(0)
	ds_write_b128 v70, v[24:27] offset:12288
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[88:91], v9
	ds_read_b128 v[92:95], v9 offset:8192
	ds_read_b128 v[96:99], v6
	ds_read_b128 v[100:103], v6 offset:8192
	.loc	1 150 5                         ; extend_attention.py:150:5
	s_cbranch_scc1 .LBB0_3
; %bb.1:                                ; %.lr.ph
	.loc	1 0 5 is_stmt 0                 ; extend_attention.py:0:5
	s_load_dwordx2 s[40:41], s[0:1], 0x40
	s_load_dword s44, s[0:1], 0x6c
	s_load_dword s45, s[0:1], 0x74
	v_and_b32_e32 v4, 0x780, v40
	v_xor_b32_e32 v2, v42, v38
	v_bitop3_b32 v4, v4, v43, v41 bitop3:0x36
	v_xor_b32_e32 v3, 8, v2
	v_xor_b32_e32 v5, 32, v4
	.loc	1 150 5                         ; extend_attention.py:150:5
	v_add_lshl_u32 v45, s14, v73, 2
	v_mov_b32_e32 v32, 0
	.loc	1 152 19 is_stmt 1              ; extend_attention.py:152:19
	v_mov_b32_e32 v47, 0xff800000
	s_and_b32 s37, s37, 0xffff
	s_and_b32 s13, s13, 0xffff
	s_waitcnt lgkmcnt(0)
	s_and_b32 s41, s41, 0xffff
	.loc	1 181 9                         ; extend_attention.py:181:9
	s_mov_b32 s63, s62
	.loc	1 150 5                         ; extend_attention.py:150:5
	v_add_u32_e32 v46, 0x80, v45
	v_add_u32_e32 v48, 0, v39
	s_mov_b32 s30, 0x3fb8aa3b
	s_mov_b32 s46, 0xc2fc0000
	v_add_u32_e32 v49, 0, v2
	v_add_u32_e32 v50, 0, v3
	v_add_u32_e32 v51, 0, v4
	v_add_u32_e32 v52, 0, v5
	v_mov_b32_e32 v53, 0x42800000
	v_not_b32_e32 v54, 63
	v_mov_b32_e32 v33, v32
	v_mov_b32_e32 v30, v32
	v_mov_b32_e32 v31, v32
	v_mov_b32_e32 v28, v32
	v_mov_b32_e32 v29, v32
	v_mov_b32_e32 v26, v32
	v_mov_b32_e32 v27, v32
	v_mov_b32_e32 v24, v32
	v_mov_b32_e32 v25, v32
	v_mov_b32_e32 v22, v32
	v_mov_b32_e32 v23, v32
	v_mov_b32_e32 v20, v32
	v_mov_b32_e32 v21, v32
	v_mov_b32_e32 v18, v32
	v_mov_b32_e32 v19, v32
	v_mov_b32_e32 v16, v32
	v_mov_b32_e32 v17, v32
	v_mov_b32_e32 v14, v32
	v_mov_b32_e32 v15, v32
	v_mov_b32_e32 v12, v32
	v_mov_b32_e32 v13, v32
	v_mov_b32_e32 v10, v32
	v_mov_b32_e32 v11, v32
	v_mov_b32_e32 v8, v32
	v_mov_b32_e32 v9, v32
	v_mov_b32_e32 v6, v32
	v_mov_b32_e32 v7, v32
	v_mov_b32_e32 v4, v32
	v_mov_b32_e32 v5, v32
	v_mov_b32_e32 v2, v32
	v_mov_b32_e32 v3, v32
	v_mov_b32_e32 v36, 0xff800000
	v_mov_b32_e32 v37, v47
	v_mov_b32_e32 v58, v32
	v_mov_b32_e32 v59, v32
.LBB0_2:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 152 19                        ; extend_attention.py:152:19
	v_add_u32_e32 v34, s34, v73
	.loc	1 152 18 is_stmt 0              ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[14:15], s35, v34
	.loc	1 152 19                        ; extend_attention.py:152:19
	v_add_u32_e32 v35, 32, v34
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[6:7], s35, v35
	.loc	1 154 23 is_stmt 1              ; extend_attention.py:154:23
	v_cndmask_b32_e64 v34, v44, v45, s[14:15]
	buffer_load_dword v134, v34, s[40:43], 0 offen
	v_cndmask_b32_e64 v34, v44, v46, s[6:7]
	buffer_load_dword v135, v34, s[40:43], 0 offen
	.loc	1 164 13                        ; extend_attention.py:164:13
	s_mov_b32 s38, s42
	s_mov_b32 s39, s43
	.loc	1 152 19                        ; extend_attention.py:152:19
	v_add_u32_e32 v55, s34, v69
	v_add_u32_e32 v132, 50, v55
	.loc	1 152 18 is_stmt 0              ; extend_attention.py:152:18
	v_add_u32_e32 v133, 51, v55
	v_cmp_gt_i32_e64 s[22:23], s35, v133
	v_cmp_gt_i32_e64 s[24:25], s35, v132
	.loc	1 152 19                        ; extend_attention.py:152:19
	v_add_u32_e32 v130, 48, v55
	v_add_u32_e32 v131, 49, v55
	.loc	1 199 27 is_stmt 1              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 152 19                        ; extend_attention.py:152:19
	v_add_u32_e32 v128, 34, v55
	v_add_u32_e32 v129, 35, v55
	v_add_u32_e32 v126, 32, v55
	v_add_u32_e32 v127, 33, v55
	v_add_u32_e32 v124, 18, v55
	v_add_u32_e32 v125, 19, v55
	v_add_u32_e32 v122, 16, v55
	v_add_u32_e32 v123, 17, v55
	v_add_u32_e32 v120, 2, v55
	v_add_u32_e32 v121, 3, v55
	v_add_u32_e32 v75, 1, v55
	.loc	1 150 5                         ; extend_attention.py:150:5
	s_add_i32 s34, s34, 64
	v_add_u32_e32 v46, 0x100, v46
	v_add_u32_e32 v45, 0x100, v45
	.loc	1 165 13                        ; extend_attention.py:165:13
	s_waitcnt vmcnt(1)
	v_mul_lo_u32 v34, v134, s44
	.loc	1 164 13                        ; extend_attention.py:164:13
	v_add_lshl_u32 v34, v34, v1, 1
	.loc	1 165 13                        ; extend_attention.py:165:13
	s_waitcnt vmcnt(0)
	v_mul_lo_u32 v35, v135, s44
	.loc	1 164 13                        ; extend_attention.py:164:13
	v_cndmask_b32_e64 v34, v44, v34, s[14:15]
	buffer_load_dwordx4 v[60:63], v34, s[36:39], 0 offen
	v_add_lshl_u32 v34, v35, v1, 1
	v_cndmask_b32_e64 v34, v44, v34, s[6:7]
	buffer_load_dwordx4 v[76:79], v34, s[36:39], 0 offen
	s_barrier
	s_waitcnt vmcnt(1)
	ds_write_b128 v70, v[60:63]
	s_waitcnt vmcnt(0)
	ds_write_b128 v70, v[76:79] offset:4096
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[104:107], v74
	ds_read_b128 v[108:111], v74 offset:2048
	ds_read_b128 v[112:115], v74 offset:4096
	ds_read_b128 v[116:119], v74 offset:6144
	ds_read_b128 v[136:139], v48
	ds_read_b128 v[140:143], v48 offset:2048
	ds_read_b128 v[144:147], v48 offset:4096
	ds_read_b128 v[148:151], v48 offset:6144
	.loc	1 168 14                        ; extend_attention.py:168:14
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[84:87], v[116:119], v[88:91], 0
	v_mfma_f32_16x16x32_bf16 v[116:119], v[116:119], v[92:95], 0
	v_mfma_f32_16x16x32_bf16 v[80:83], v[112:115], v[88:91], 0
	v_mfma_f32_16x16x32_bf16 v[112:115], v[112:115], v[92:95], 0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[116:119], v[148:151], v[100:103], v[116:119]
	v_mfma_f32_16x16x32_bf16 v[84:87], v[148:151], v[96:99], v[84:87]
	v_mfma_f32_16x16x32_bf16 v[76:79], v[108:111], v[88:91], 0
	.loc	1 181 9                         ; extend_attention.py:181:9
	s_nop 5
	v_mul_f32_e64 v34, s62, v118
	v_mul_f32_e64 v35, s63, v119
	v_pk_mul_f32 v[56:57], s[62:63], v[116:117]
	v_pk_mul_f32 v[86:87], s[62:63], v[86:87]
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[108:111], v[108:111], v[92:95], 0
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v117, v47, v35, s[22:23]
	v_cndmask_b32_e64 v116, v47, v34, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v131
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[112:115], v[144:147], v[100:103], v[112:115]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[24:25], s35, v130
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v87, v47, v87, s[26:27]
	v_cndmask_b32_e64 v86, v47, v86, s[28:29]
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[80:83], v[144:147], v[96:99], v[80:83]
	.loc	1 199 27                        ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[84:85]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v57, v47, v57, s[22:23]
	v_cndmask_b32_e64 v56, v47, v56, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v129
	v_cmp_gt_i32_e64 s[24:25], s35, v128
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[60:63], v[104:107], v[88:91], 0
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_mul_f32_e64 v114, s62, v114
	v_mul_f32_e64 v115, s63, v115
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v85, v47, v35, s[26:27]
	v_cndmask_b32_e64 v84, v47, v34, s[28:29]
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[104:107], v[104:107], v[92:95], 0
	.loc	1 199 27                        ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[108:111], v[140:143], v[100:103], v[108:111]
	.loc	1 199 27                        ; extend_attention.py:199:27
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[82:83]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v115, v47, v115, s[22:23]
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[76:79], v[140:143], v[96:99], v[76:79]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v114, v47, v114, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v127
	v_cmp_gt_i32_e64 s[24:25], s35, v126
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[112:113], s[62:63], v[112:113]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v83, v47, v35, s[26:27]
	v_cndmask_b32_e64 v82, v47, v34, s[28:29]
	.loc	1 199 27 is_stmt 0              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9 is_stmt 1               ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[80:81]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v113, v47, v113, s[22:23]
	v_cndmask_b32_e64 v112, v47, v112, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v125
	v_cmp_gt_i32_e64 s[24:25], s35, v124
	.loc	1 168 14                        ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[104:107], v[136:139], v[100:103], v[104:107]
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_mul_f32_e64 v110, s62, v110
	v_mul_f32_e64 v111, s63, v111
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v81, v47, v35, s[26:27]
	v_cndmask_b32_e64 v80, v47, v34, s[28:29]
	.loc	1 199 27 is_stmt 0              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 168 14 is_stmt 1              ; extend_attention.py:168:14
	v_mfma_f32_16x16x32_bf16 v[60:63], v[136:139], v[96:99], v[60:63]
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_mul_f32_e64 v34, s62, v78
	v_mul_f32_e64 v35, s63, v79
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v111, v47, v111, s[22:23]
	v_cndmask_b32_e64 v110, v47, v110, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v123
	v_cmp_gt_i32_e64 s[24:25], s35, v122
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[108:109], s[62:63], v[108:109]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v79, v47, v35, s[26:27]
	v_cndmask_b32_e64 v78, v47, v34, s[28:29]
	.loc	1 199 27 is_stmt 0              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9 is_stmt 1               ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[76:77]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v109, v47, v109, s[22:23]
	v_cndmask_b32_e64 v108, v47, v108, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v121
	v_cmp_gt_i32_e64 s[24:25], s35, v120
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[106:107], s[62:63], v[106:107]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v77, v47, v35, s[26:27]
	v_cndmask_b32_e64 v76, v47, v34, s[28:29]
	.loc	1 199 27 is_stmt 0              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9 is_stmt 1               ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[62:63]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v107, v47, v107, s[22:23]
	v_cndmask_b32_e64 v106, v47, v106, s[24:25]
	.loc	1 152 18                        ; extend_attention.py:152:18
	v_cmp_gt_i32_e64 s[22:23], s35, v75
	v_cmp_gt_i32_e64 s[24:25], s35, v55
	.loc	1 181 9                         ; extend_attention.py:181:9
	v_pk_mul_f32 v[104:105], s[62:63], v[104:105]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v63, v47, v35, s[26:27]
	v_cndmask_b32_e64 v62, v47, v34, s[28:29]
	.loc	1 199 27 is_stmt 0              ; extend_attention.py:199:27
	s_and_b64 s[26:27], vcc, s[22:23]
	s_and_b64 s[28:29], vcc, s[24:25]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	s_and_b64 s[24:25], s[10:11], s[24:25]
	.loc	1 181 9 is_stmt 1               ; extend_attention.py:181:9
	v_pk_mul_f32 v[34:35], s[62:63], v[60:61]
	.loc	1 199 18                        ; extend_attention.py:199:18
	v_cndmask_b32_e64 v105, v47, v105, s[22:23]
	v_cndmask_b32_e64 v104, v47, v104, s[24:25]
	v_cndmask_b32_e64 v61, v47, v35, s[26:27]
	v_cndmask_b32_e64 v60, v47, v34, s[28:29]
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ extend_attention.py:201:30 ] ]
	v_max_f32_e32 v120, v105, v105
	v_max_f32_e32 v121, v104, v104
	v_max_f32_e32 v120, v121, v120
	v_max_f32_e32 v121, v61, v61
	v_max_f32_e32 v122, v60, v60
	v_max3_f32 v34, v56, v57, v116
	v_max3_f32 v35, v84, v85, v86
	v_max3_f32 v55, v113, v114, v115
	v_max3_f32 v75, v81, v82, v83
	v_max3_f32 v118, v107, v108, v109
	v_max3_f32 v119, v63, v76, v77
	v_max_f32_e32 v121, v122, v121
	v_max3_f32 v35, v75, v35, v87
	v_max3_f32 v34, v55, v34, v117
	v_max3_f32 v55, v78, v79, v80
	v_max3_f32 v75, v110, v111, v112
	v_max3_f32 v119, v121, v62, v119
	v_max3_f32 v118, v120, v106, v118
	v_max3_f32 v34, v118, v75, v34
	v_max3_f32 v35, v119, v55, v35
.Ltmp3:
	.loc	2 216 16                        ; standard.py:216:16 @[ extend_attention.py:201:30 ]
	v_mov_b32_e32 v55, v35
	v_mov_b32_e32 v75, v34
	s_nop 0
	v_permlane32_swap_b32_e32 v35, v55
	v_permlane32_swap_b32_e32 v34, v75
.Ltmp4:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ extend_attention.py:201:30 ] ]
	v_max_f32_e32 v75, v75, v75
	v_max_f32_e32 v34, v34, v34
	v_max_f32_e32 v55, v55, v55
	v_max_f32_e32 v35, v35, v35
	v_max_f32_e32 v34, v34, v75
	v_max_f32_e32 v55, v35, v55
.Ltmp5:
	.loc	2 216 16                        ; standard.py:216:16 @[ extend_attention.py:201:30 ]
	v_mov_b32_e32 v75, v55
	v_mov_b32_e32 v35, v34
	s_nop 0
	v_permlane16_swap_b32_e32 v55, v75
	v_permlane16_swap_b32_e32 v34, v35
.Ltmp6:
	.loc	1 201 19                        ; extend_attention.py:201:19
	v_max3_f32 v35, v34, v35, v37
	v_max3_f32 v34, v55, v75, v36
	.loc	1 202 27                        ; extend_attention.py:202:27
	v_pk_add_f32 v[36:37], v[36:37], v[34:35] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[60:61], v[60:61], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 202 20                        ; extend_attention.py:202:20
	v_pk_mul_f32 v[36:37], v[36:37], s[30:31] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_pk_mul_f32 v[60:61], v[60:61], s[30:31] op_sel_hi:[1,0]
	.loc	1 202 20                        ; extend_attention.py:202:20
	v_cmp_gt_f32_e64 s[22:23], s46, v37
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_mov_b32_e32 v118, v35
	v_pk_add_f32 v[104:105], v[104:105], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 202 20                        ; extend_attention.py:202:20
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v37, v37, v55
	v_exp_f32_e32 v37, v37
	v_cndmask_b32_e64 v55, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v36
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[106:107], v[106:107], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 202 20                        ; extend_attention.py:202:20
	v_ldexp_f32 v37, v37, v55
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v36, v36, v55
	v_exp_f32_e32 v36, v36
	v_cndmask_b32_e64 v55, 0, v54, s[22:23]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 203 20 is_stmt 0              ; extend_attention.py:203:20
	v_pk_add_f32 v[108:109], v[108:109], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 202 20 is_stmt 1              ; extend_attention.py:202:20
	v_ldexp_f32 v36, v36, v55
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	.loc	1 203 20 is_stmt 0              ; extend_attention.py:203:20
	v_pk_add_f32 v[110:111], v[110:111], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[112:113], v[112:113], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[114:115], v[114:115], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[56:57], v[56:57], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[116:117], v[116:117], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v119, v55, v61
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[62:63], v[62:63], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[76:77], v[76:77], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v118, v55, v60
	v_pk_mul_f32 v[60:61], v[62:63], s[30:31] op_sel_hi:[1,0]
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[78:79], v[78:79], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[80:81], v[80:81], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[82:83], v[82:83], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[84:85], v[84:85], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v121, v55, v61
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	.loc	1 203 20                        ; extend_attention.py:203:20
	v_pk_add_f32 v[86:87], v[86:87], v[34:35] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_pk_mul_f32 v[56:57], v[56:57], s[30:31] op_sel_hi:[1,0]
	v_ldexp_f32 v120, v55, v60
	v_pk_mul_f32 v[60:61], v[76:77], s[30:31] op_sel_hi:[1,0]
	.loc	1 212 13 is_stmt 1              ; extend_attention.py:212:13
	v_mul_lo_u32 v75, v135, s45
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_pk_mul_f32 v[30:31], v[30:31], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[36:37] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_pk_mul_f32 v[26:27], v[26:27], v[36:37] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v123, v55, v61
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_pk_mul_f32 v[28:29], v[28:29], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[36:37] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v122, v55, v60
	v_pk_mul_f32 v[60:61], v[78:79], s[30:31] op_sel_hi:[1,0]
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_pk_mul_f32 v[24:25], v[24:25], v[36:37] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_pk_mul_f32 v[18:19], v[18:19], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[36:37] op_sel_hi:[1,0]
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	.loc	1 150 5                         ; extend_attention.py:150:5
	s_cmp_lt_i32 s34, s35
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_ldexp_f32 v125, v55, v61
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v124, v55, v60
	v_pk_mul_f32 v[60:61], v[80:81], s[30:31] op_sel_hi:[1,0]
.Ltmp7:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_pk_add_f32 v[62:63], v[122:123], v[124:125]
.Ltmp8:
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v127, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v126, v55, v60
	v_pk_mul_f32 v[60:61], v[82:83], s[30:31] op_sel_hi:[1,0]
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v82, v122, v123
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v83, v124, v125
	.loc	1 203 13                        ; extend_attention.py:203:13
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v129, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v128, v55, v60
	v_pk_mul_f32 v[60:61], v[84:85], s[30:31] op_sel_hi:[1,0]
.Ltmp9:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_pk_add_f32 v[76:77], v[126:127], v[128:129]
.Ltmp10:
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v84, v126, v127
	v_cvt_pk_bf16_f32 v85, v128, v129
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v131, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v130, v55, v60
	v_pk_mul_f32 v[60:61], v[86:87], s[30:31] op_sel_hi:[1,0]
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v86, v130, v131
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v133, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v132, v55, v60
	v_pk_mul_f32 v[60:61], v[104:105], s[30:31] op_sel_hi:[1,0]
.Ltmp11:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_pk_add_f32 v[78:79], v[130:131], v[132:133]
.Ltmp12:
	.loc	1 203 13                        ; extend_attention.py:203:13
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v87, v132, v133
	.loc	1 203 13                        ; extend_attention.py:203:13
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v105, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v104, v55, v60
	v_pk_mul_f32 v[60:61], v[106:107], s[30:31] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v107, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v106, v55, v60
	v_pk_mul_f32 v[60:61], v[108:109], s[30:31] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v109, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v108, v55, v60
	v_pk_mul_f32 v[60:61], v[110:111], s[30:31] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v111, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v110, v55, v60
	v_pk_mul_f32 v[60:61], v[112:113], s[30:31] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v113, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v112, v55, v60
	v_pk_mul_f32 v[60:61], v[114:115], s[30:31] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	s_nop 1
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v115, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v57
	v_ldexp_f32 v114, v55, v60
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v57, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v57, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v56
	v_pk_mul_f32 v[60:61], v[116:117], s[30:31] op_sel_hi:[1,0]
	v_ldexp_f32 v57, v55, v57
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v56, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v56, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v61
	v_ldexp_f32 v56, v55, v56
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v61, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v61, 0, v54, s[22:23]
	v_cmp_gt_f32_e64 s[22:23], s46, v60
	v_ldexp_f32 v117, v55, v61
	s_nop 0
	v_cndmask_b32_e64 v55, 0, v53, s[22:23]
	v_add_f32_e32 v55, v60, v55
	v_exp_f32_e32 v55, v55
	v_cndmask_b32_e64 v60, 0, v54, s[22:23]
	v_ldexp_f32 v116, v55, v60
.Ltmp13:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_pk_add_f32 v[60:61], v[118:119], v[120:121]
	v_pk_add_f32 v[80:81], v[56:57], v[116:117]
	v_pk_add_f32 v[60:61], v[60:61], v[62:63]
	v_pk_add_f32 v[62:63], v[76:77], v[78:79]
	v_pk_add_f32 v[76:77], v[108:109], v[110:111]
	v_pk_add_f32 v[60:61], v[60:61], v[62:63]
	v_pk_add_f32 v[62:63], v[104:105], v[106:107]
	v_pk_add_f32 v[78:79], v[112:113], v[114:115]
	v_pk_add_f32 v[62:63], v[62:63], v[76:77]
	v_pk_add_f32 v[76:77], v[78:79], v[80:81]
.Ltmp14:
	.loc	1 212 13                        ; extend_attention.py:212:13
	v_mul_lo_u32 v55, v134, s45
.Ltmp15:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_pk_add_f32 v[62:63], v[62:63], v[76:77]
.Ltmp16:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:204:34 ] ]
	v_mov_b32_e32 v76, v60
	v_mov_b32_e32 v77, v62
	v_mov_b32_e32 v62, v61
	v_pk_add_f32 v[60:61], v[76:77], v[62:63]
.Ltmp17:
	.loc	1 211 13                        ; extend_attention.py:211:13
	v_add_lshl_u32 v55, v55, v1, 1
.Ltmp18:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_mov_b32_e32 v62, v60
	v_mov_b32_e32 v63, v61
	s_nop 0
	v_permlane32_swap_b32_e32 v60, v62
	v_permlane32_swap_b32_e32 v61, v63
.Ltmp19:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:204:34 ] ]
	v_pk_add_f32 v[60:61], v[60:61], v[62:63]
.Ltmp20:
	.loc	1 211 13                        ; extend_attention.py:211:13
	v_cndmask_b32_e64 v55, v44, v55, s[14:15]
.Ltmp21:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:204:34 ]
	v_mov_b32_e32 v62, v60
	v_mov_b32_e32 v63, v61
	s_nop 0
	v_permlane16_swap_b32_e32 v60, v62
	v_permlane16_swap_b32_e32 v61, v63
.Ltmp22:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:204:34 ] ]
	v_pk_add_f32 v[60:61], v[60:61], v[62:63]
.Ltmp23:
	.loc	1 211 13                        ; extend_attention.py:211:13
	s_mov_b32 s14, s42
	s_mov_b32 s15, s43
	.loc	1 204 16                        ; extend_attention.py:204:16
	v_pk_fma_f32 v[58:59], v[58:59], v[36:37], v[60:61]
	.loc	1 211 13                        ; extend_attention.py:211:13
	buffer_load_dwordx4 v[60:63], v55, s[12:15], 0 offen
	v_add_lshl_u32 v55, v75, v1, 1
	v_cndmask_b32_e64 v55, v44, v55, s[6:7]
	buffer_load_dwordx4 v[76:79], v55, s[12:15], 0 offen
	.loc	1 214 13                        ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v80, v118, v119
	v_cvt_pk_bf16_f32 v81, v120, v121
	v_cvt_pk_bf16_f32 v104, v104, v105
	v_cvt_pk_bf16_f32 v105, v106, v107
	v_cvt_pk_bf16_f32 v106, v108, v109
	v_cvt_pk_bf16_f32 v107, v110, v111
	v_cvt_pk_bf16_f32 v108, v112, v113
	v_cvt_pk_bf16_f32 v109, v114, v115
	v_cvt_pk_bf16_f32 v111, v116, v117
	.loc	1 211 13                        ; extend_attention.py:211:13
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write2st64_b64 v49, v[60:61], v[76:77] offset1:8
	ds_write2st64_b64 v50, v[62:63], v[78:79] offset1:8
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[60:61], v51
	ds_read_b64_tr_b16 v[62:63], v51 offset:2048
	ds_read_b64_tr_b16 v[76:77], v51 offset:4096
	ds_read_b64_tr_b16 v[78:79], v51 offset:6144
	ds_read_b64_tr_b16 v[112:113], v51 offset:64
	ds_read_b64_tr_b16 v[114:115], v51 offset:2112
	ds_read_b64_tr_b16 v[116:117], v51 offset:4160
	ds_read_b64_tr_b16 v[118:119], v51 offset:6208
	ds_read_b64_tr_b16 v[120:121], v52
	ds_read_b64_tr_b16 v[122:123], v52 offset:2048
	ds_read_b64_tr_b16 v[124:125], v52 offset:4096
	ds_read_b64_tr_b16 v[126:127], v52 offset:6144
	ds_read_b64_tr_b16 v[128:129], v52 offset:64
	ds_read_b64_tr_b16 v[130:131], v52 offset:2112
	ds_read_b64_tr_b16 v[132:133], v52 offset:4160
	ds_read_b64_tr_b16 v[134:135], v52 offset:6208
	.loc	1 215 15                        ; extend_attention.py:215:15
	v_mov_b32_e32 v36, v37
	v_pk_mul_f32 v[14:15], v[14:15], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[36:37] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[36:37] op_sel_hi:[1,0]
	.loc	1 215 41 is_stmt 0              ; extend_attention.py:215:41
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[60:63], v[80:83], v[30:33]
	.loc	1 214 13 is_stmt 1              ; extend_attention.py:214:13
	v_cvt_pk_bf16_f32 v110, v56, v57
	v_mov_b32_e32 v36, v34
	v_mov_b32_e32 v37, v35
	.loc	1 215 41                        ; extend_attention.py:215:41
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[26:29], v[120:123], v[80:83], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[112:115], v[80:83], v[22:25]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[18:21], v[128:131], v[80:83], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[60:63], v[104:107], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[120:123], v[104:107], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[112:115], v[104:107], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[128:131], v[104:107], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[76:79], v[84:87], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[124:127], v[84:87], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[116:119], v[84:87], v[22:25]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[18:21], v[132:135], v[84:87], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[76:79], v[108:111], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[124:127], v[108:111], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[116:119], v[108:111], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[132:135], v[108:111], v[2:5]
	.loc	1 150 5                         ; extend_attention.py:150:5
	s_cbranch_scc1 .LBB0_2
	s_branch .LBB0_4
.LBB0_3:
	.loc	1 0 5 is_stmt 0                 ; extend_attention.py:0:5
	v_mov_b32_e32 v58, 0
	v_mov_b32_e32 v34, 0xff800000
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v59, v58
	v_mov_b32_e32 v35, v34
	v_mov_b32_e32 v2, v3
	v_mov_b32_e32 v5, v3
	v_mov_b32_e32 v4, v3
	v_mov_b32_e32 v7, v3
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v9, v3
	v_mov_b32_e32 v8, v3
	v_mov_b32_e32 v11, v3
	v_mov_b32_e32 v10, v3
	v_mov_b32_e32 v13, v3
	v_mov_b32_e32 v12, v3
	v_mov_b32_e32 v15, v3
	v_mov_b32_e32 v14, v3
	v_mov_b32_e32 v17, v3
	v_mov_b32_e32 v16, v3
	v_mov_b32_e32 v19, v3
	v_mov_b32_e32 v18, v3
	v_mov_b32_e32 v21, v3
	v_mov_b32_e32 v20, v3
	v_mov_b32_e32 v23, v3
	v_mov_b32_e32 v22, v3
	v_mov_b32_e32 v25, v3
	v_mov_b32_e32 v24, v3
	v_mov_b32_e32 v27, v3
	v_mov_b32_e32 v26, v3
	v_mov_b32_e32 v29, v3
	v_mov_b32_e32 v28, v3
	v_mov_b32_e32 v31, v3
	v_mov_b32_e32 v30, v3
	v_mov_b32_e32 v33, v3
	v_mov_b32_e32 v32, v3
.LBB0_4:                                ; %Flow385
	s_load_dword s12, s[0:1], 0x54
	s_load_dword s13, s[0:1], 0x5c
	s_load_dword s71, s[0:1], 0x64
	.loc	1 226 5 is_stmt 1               ; extend_attention.py:226:5
	s_cmp_lt_i32 s31, 1
	s_cbranch_scc1 .LBB0_7
; %bb.5:                                ; %.lr.ph11
	.loc	1 0 5 is_stmt 0                 ; extend_attention.py:0:5
	v_xor_b32_e32 v36, v42, v38
	v_and_b32_e32 v38, 0x780, v40
	v_bitop3_b32 v38, v38, v43, v41 bitop3:0x36
	.loc	1 226 5                         ; extend_attention.py:226:5
	v_add_u32_e32 v41, s70, v73
	v_add_u32_e32 v42, 32, v41
	v_and_b32_e32 v44, 7, v0
	s_waitcnt lgkmcnt(0)
	v_mul_lo_u32 v43, s13, v42
	v_lshlrev_b32_e32 v44, 4, v44
	s_mov_b32 s7, 0x27000
	s_mov_b32 s6, 0x7ffffffe
	v_xor_b32_e32 v37, 8, v36
	v_xor_b32_e32 v40, 32, v38
	v_lshl_add_u32 v75, v43, 1, v44
	v_mul_lo_u32 v43, s13, v41
	v_mul_lo_u32 v42, s12, v42
	v_mul_lo_u32 v41, s12, v41
	.loc	1 224 14 is_stmt 1              ; extend_attention.py:224:14
	s_min_i32 s72, s31, 0x80
	s_and_b32 s5, s5, 0xffff
	s_and_b32 s65, s65, 0xffff
	.loc	1 254 9                         ; extend_attention.py:254:9
	s_mov_b32 s63, s62
	.loc	1 226 5                         ; extend_attention.py:226:5
	s_lshl_b32 s73, s13, 7
	v_lshl_add_u32 v76, v43, 1, v44
	v_lshl_add_u32 v77, v42, 1, v44
	s_lshl_b32 s74, s12, 7
	v_lshl_add_u32 v78, v41, 1, v44
	s_mov_b32 s75, 0
	v_bfrev_b32_e32 v79, 1
	v_add_u32_e32 v80, 0, v39
	s_mov_b32 s68, 0x3fb8aa3b
	s_mov_b32 s76, 0xc2fc0000
	v_add_u32_e32 v81, 0, v36
	v_add_u32_e32 v82, 0, v37
	v_add_u32_e32 v83, 0, v38
	v_add_u32_e32 v84, 0, v40
	v_mov_b32_e32 v85, 0xff800000
	v_mov_b32_e32 v86, 0x42800000
	v_not_b32_e32 v87, 63
	s_mov_b32 s66, s6
	s_mov_b32 s67, s7
.LBB0_6:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v36, s75, v73
	v_add_u32_e32 v37, 32, v36
	.loc	1 228 18 is_stmt 0              ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[12:13], s72, v36
	v_cmp_gt_i32_e64 s[0:1], s72, v37
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v114, s75, v69
	.loc	1 236 13 is_stmt 1              ; extend_attention.py:236:13
	v_cndmask_b32_e64 v36, v79, v78, s[12:13]
	buffer_load_dwordx4 v[38:41], v36, s[4:7], 0 offen
	v_cndmask_b32_e64 v36, v79, v77, s[0:1]
	buffer_load_dwordx4 v[42:45], v36, s[4:7], 0 offen
	s_barrier
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v126, 50, v114
	.loc	1 228 18 is_stmt 0              ; extend_attention.py:228:18
	v_add_u32_e32 v127, 51, v114
	.loc	1 273 28 is_stmt 1              ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v72, v127
	v_cmp_ge_u32_e64 s[36:37], v72, v126
	v_cmp_ge_u32_e64 s[54:55], v71, v127
	v_cmp_ge_u32_e64 s[56:57], v71, v126
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[58:59], s72, v127
	v_cmp_gt_i32_e64 s[60:61], s72, v126
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[54:55], s[58:59], s[54:55]
	s_and_b64 s[56:57], s[60:61], s[56:57]
	s_and_b64 s[34:35], s[58:59], s[34:35]
	s_and_b64 s[36:37], s[60:61], s[36:37]
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v124, 48, v114
	v_add_u32_e32 v125, 49, v114
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[54:55], vcc, s[54:55]
	s_and_b64 s[56:57], vcc, s[56:57]
	s_and_b64 s[34:35], s[10:11], s[34:35]
	s_and_b64 s[36:37], s[10:11], s[36:37]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[38:39], v72, v125
	v_cmp_ge_u32_e64 s[40:41], v72, v124
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v122, 34, v114
	v_add_u32_e32 v123, 35, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[42:43], v72, v123
	v_cmp_ge_u32_e64 s[44:45], v72, v122
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v120, 32, v114
	v_add_u32_e32 v121, 33, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[46:47], v72, v121
	v_cmp_ge_u32_e64 s[48:49], v72, v120
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v118, 18, v114
	v_add_u32_e32 v119, 19, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[50:51], v72, v119
	v_cmp_ge_u32_e64 s[52:53], v72, v118
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v112, 16, v114
	v_add_u32_e32 v113, 17, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[28:29], v72, v113
	v_cmp_ge_u32_e64 s[30:31], v72, v112
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v116, 2, v114
	v_add_u32_e32 v117, 3, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[24:25], v72, v117
	v_cmp_ge_u32_e64 s[26:27], v72, v116
	.loc	1 228 19                        ; extend_attention.py:228:19
	v_add_u32_e32 v115, 1, v114
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[14:15], v72, v115
	v_cmp_ge_u32_e64 s[22:23], v72, v114
	.loc	1 226 5                         ; extend_attention.py:226:5
	s_add_i32 s75, s75, 64
	v_add_u32_e32 v77, s74, v77
	v_add_u32_e32 v78, s74, v78
	.loc	1 236 13                        ; extend_attention.py:236:13
	s_waitcnt vmcnt(1)
	ds_write_b128 v70, v[38:41]
	s_waitcnt vmcnt(0)
	ds_write_b128 v70, v[42:45] offset:4096
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[52:55], v74
	ds_read_b128 v[60:63], v74 offset:2048
	ds_read_b128 v[104:107], v74 offset:4096
	ds_read_b128 v[108:111], v74 offset:6144
	ds_read_b128 v[128:131], v80
	ds_read_b128 v[132:135], v80 offset:2048
	ds_read_b128 v[136:139], v80 offset:4096
	ds_read_b128 v[140:143], v80 offset:6144
	.loc	1 240 14                        ; extend_attention.py:240:14
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_16x16x32_bf16 v[48:51], v[108:111], v[88:91], 0
	v_mfma_f32_16x16x32_bf16 v[108:111], v[108:111], v[92:95], 0
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[48:51], v[140:143], v[96:99], v[48:51]
	v_mfma_f32_16x16x32_bf16 v[108:111], v[140:143], v[100:103], v[108:111]
	v_mfma_f32_16x16x32_bf16 v[44:47], v[104:107], v[88:91], 0
	.loc	1 254 9                         ; extend_attention.py:254:9
	s_nop 5
	v_mul_f32_e64 v50, s62, v50
	v_mul_f32_e64 v51, s63, v51
	v_pk_mul_f32 v[56:57], s[62:63], v[110:111]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v51, v85, v51, s[54:55]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[104:107], v[104:107], v[92:95], 0
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v50, v85, v50, s[56:57]
	v_cndmask_b32_e64 v57, v85, v57, s[34:35]
	v_cndmask_b32_e64 v56, v85, v56, s[36:37]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v71, v125
	v_cmp_ge_u32_e64 s[36:37], v71, v124
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[54:55], s72, v125
	v_cmp_gt_i32_e64 s[56:57], s72, v124
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[44:47], v[136:139], v[96:99], v[44:47]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], s[54:55], s[34:35]
	s_and_b64 s[36:37], s[56:57], s[36:37]
	s_and_b64 s[38:39], s[54:55], s[38:39]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[104:107], v[136:139], v[100:103], v[104:107]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[40:41], s[56:57], s[40:41]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[108:109], s[62:63], v[108:109]
	v_pk_mul_f32 v[48:49], s[62:63], v[48:49]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], vcc, s[34:35]
	s_and_b64 s[36:37], vcc, s[36:37]
	s_and_b64 s[38:39], s[10:11], s[38:39]
	s_and_b64 s[40:41], s[10:11], s[40:41]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[40:43], v[60:63], v[88:91], 0
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v49, v85, v49, s[34:35]
	v_cndmask_b32_e64 v48, v85, v48, s[36:37]
	v_cndmask_b32_e64 v109, v85, v109, s[38:39]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[60:63], v[60:63], v[92:95], 0
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v108, v85, v108, s[40:41]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v71, v123
	v_cmp_ge_u32_e64 s[36:37], v71, v122
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[38:39], s72, v123
	v_cmp_gt_i32_e64 s[40:41], s72, v122
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], s[38:39], s[34:35]
	s_and_b64 s[36:37], s[40:41], s[36:37]
	s_and_b64 s[38:39], s[38:39], s[42:43]
	s_and_b64 s[40:41], s[40:41], s[44:45]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[106:107], s[62:63], v[106:107]
	v_pk_mul_f32 v[46:47], s[62:63], v[46:47]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], vcc, s[34:35]
	s_and_b64 s[36:37], vcc, s[36:37]
	s_and_b64 s[38:39], s[10:11], s[38:39]
	s_and_b64 s[40:41], s[10:11], s[40:41]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v47, v85, v47, s[34:35]
	v_cndmask_b32_e64 v46, v85, v46, s[36:37]
	v_cndmask_b32_e64 v107, v85, v107, s[38:39]
	v_cndmask_b32_e64 v106, v85, v106, s[40:41]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v71, v121
	v_cmp_ge_u32_e64 s[36:37], v71, v120
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[38:39], s72, v121
	v_cmp_gt_i32_e64 s[40:41], s72, v120
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[40:43], v[132:135], v[96:99], v[40:43]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], s[38:39], s[34:35]
	s_and_b64 s[36:37], s[40:41], s[36:37]
	s_and_b64 s[38:39], s[38:39], s[46:47]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[60:63], v[132:135], v[100:103], v[60:63]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[40:41], s[40:41], s[48:49]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[104:105], s[62:63], v[104:105]
	v_pk_mul_f32 v[44:45], s[62:63], v[44:45]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], vcc, s[34:35]
	s_and_b64 s[36:37], vcc, s[36:37]
	s_and_b64 s[38:39], s[10:11], s[38:39]
	s_and_b64 s[40:41], s[10:11], s[40:41]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[36:39], v[52:55], v[88:91], 0
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v45, v85, v45, s[34:35]
	v_cndmask_b32_e64 v44, v85, v44, s[36:37]
	v_cndmask_b32_e64 v105, v85, v105, s[38:39]
	v_cndmask_b32_e64 v104, v85, v104, s[40:41]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v71, v119
	v_cmp_ge_u32_e64 s[36:37], v71, v118
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[38:39], s72, v119
	v_cmp_gt_i32_e64 s[40:41], s72, v118
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[52:55], v[52:55], v[92:95], 0
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], s[38:39], s[34:35]
	s_and_b64 s[36:37], s[40:41], s[36:37]
	s_and_b64 s[38:39], s[38:39], s[50:51]
	s_and_b64 s[40:41], s[40:41], s[52:53]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[62:63], s[62:63], v[62:63]
	v_pk_mul_f32 v[42:43], s[62:63], v[42:43]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], vcc, s[34:35]
	s_and_b64 s[36:37], vcc, s[36:37]
	s_and_b64 s[38:39], s[10:11], s[38:39]
	s_and_b64 s[40:41], s[10:11], s[40:41]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v43, v85, v43, s[34:35]
	v_cndmask_b32_e64 v42, v85, v42, s[36:37]
	v_cndmask_b32_e64 v111, v85, v63, s[38:39]
	v_cndmask_b32_e64 v110, v85, v62, s[40:41]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[34:35], v71, v113
	v_cmp_ge_u32_e64 s[36:37], v71, v112
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[38:39], s72, v113
	v_cmp_gt_i32_e64 s[40:41], s72, v112
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[36:39], v[128:131], v[96:99], v[36:39]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], s[38:39], s[34:35]
	s_and_b64 s[36:37], s[40:41], s[36:37]
	s_and_b64 s[28:29], s[38:39], s[28:29]
	s_and_b64 s[30:31], s[40:41], s[30:31]
	.loc	1 240 14                        ; extend_attention.py:240:14
	v_mfma_f32_16x16x32_bf16 v[52:55], v[128:131], v[100:103], v[52:55]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_mul_f32_e64 v60, s62, v60
	v_mul_f32_e64 v61, s63, v61
	v_pk_mul_f32 v[40:41], s[62:63], v[40:41]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[34:35], vcc, s[34:35]
	s_and_b64 s[36:37], vcc, s[36:37]
	s_and_b64 s[28:29], s[10:11], s[28:29]
	s_and_b64 s[30:31], s[10:11], s[30:31]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v41, v85, v41, s[34:35]
	v_cndmask_b32_e64 v40, v85, v40, s[36:37]
	v_cndmask_b32_e64 v113, v85, v61, s[28:29]
	v_cndmask_b32_e64 v112, v85, v60, s[30:31]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[28:29], v71, v117
	v_cmp_ge_u32_e64 s[30:31], v71, v116
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[34:35], s72, v117
	v_cmp_gt_i32_e64 s[36:37], s72, v116
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[28:29], s[34:35], s[28:29]
	s_and_b64 s[30:31], s[36:37], s[30:31]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[38:39], s[62:63], v[38:39]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[28:29], vcc, s[28:29]
	s_and_b64 s[30:31], vcc, s[30:31]
	s_and_b64 s[24:25], s[34:35], s[24:25]
	s_and_b64 s[26:27], s[36:37], s[26:27]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[54:55], s[62:63], v[54:55]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[24:25], s[10:11], s[24:25]
	s_and_b64 s[26:27], s[10:11], s[26:27]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v39, v85, v39, s[28:29]
	v_cndmask_b32_e64 v38, v85, v38, s[30:31]
	.loc	1 228 18                        ; extend_attention.py:228:18
	v_cmp_gt_i32_e64 s[28:29], s72, v115
	v_cmp_gt_i32_e64 s[30:31], s72, v114
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v55, v85, v55, s[24:25]
	v_cndmask_b32_e64 v54, v85, v54, s[26:27]
	.loc	1 273 28                        ; extend_attention.py:273:28
	v_cmp_ge_u32_e64 s[24:25], v71, v115
	v_cmp_ge_u32_e64 s[26:27], v71, v114
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[14:15], s[28:29], s[14:15]
	s_and_b64 s[22:23], s[30:31], s[22:23]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[52:53], s[62:63], v[52:53]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[24:25], s[28:29], s[24:25]
	s_and_b64 s[26:27], s[30:31], s[26:27]
	s_and_b64 s[14:15], s[10:11], s[14:15]
	s_and_b64 s[22:23], s[10:11], s[22:23]
	.loc	1 254 9                         ; extend_attention.py:254:9
	v_pk_mul_f32 v[36:37], s[62:63], v[36:37]
	.loc	1 276 13                        ; extend_attention.py:276:13
	s_and_b64 s[24:25], vcc, s[24:25]
	s_and_b64 s[26:27], vcc, s[26:27]
	.loc	1 277 18                        ; extend_attention.py:277:18
	v_cndmask_b32_e64 v53, v85, v53, s[14:15]
	v_cndmask_b32_e64 v52, v85, v52, s[22:23]
	v_cndmask_b32_e64 v37, v85, v37, s[24:25]
	v_cndmask_b32_e64 v36, v85, v36, s[26:27]
.Ltmp24:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ extend_attention.py:282:30 ] ]
	v_max_f32_e32 v116, v53, v53
	v_max_f32_e32 v117, v52, v52
	v_max_f32_e32 v116, v117, v116
	v_max_f32_e32 v117, v37, v37
	v_max_f32_e32 v118, v36, v36
	v_max3_f32 v60, v108, v109, v56
	v_max3_f32 v61, v48, v49, v50
	v_max3_f32 v62, v105, v106, v107
	v_max3_f32 v63, v45, v46, v47
	v_max3_f32 v114, v55, v112, v113
	v_max3_f32 v115, v39, v40, v41
	v_max_f32_e32 v117, v118, v117
	v_max3_f32 v61, v63, v61, v51
	v_max3_f32 v60, v62, v60, v57
	v_max3_f32 v62, v42, v43, v44
	v_max3_f32 v63, v110, v111, v104
	v_max3_f32 v115, v117, v38, v115
	v_max3_f32 v114, v116, v54, v114
	v_max3_f32 v60, v114, v63, v60
	v_max3_f32 v61, v115, v62, v61
.Ltmp25:
	.loc	2 216 16                        ; standard.py:216:16 @[ extend_attention.py:282:30 ]
	v_mov_b32_e32 v62, v61
	v_mov_b32_e32 v63, v60
	s_nop 0
	v_permlane32_swap_b32_e32 v61, v62
	v_permlane32_swap_b32_e32 v60, v63
.Ltmp26:
	.loc	2 196 12                        ; standard.py:196:12 @[ standard.py:216:16 @[ extend_attention.py:282:30 ] ]
	v_max_f32_e32 v63, v63, v63
	v_max_f32_e32 v60, v60, v60
	v_max_f32_e32 v62, v62, v62
	v_max_f32_e32 v61, v61, v61
	v_max_f32_e32 v60, v60, v63
	v_max_f32_e32 v62, v61, v62
.Ltmp27:
	.loc	2 216 16                        ; standard.py:216:16 @[ extend_attention.py:282:30 ]
	v_mov_b32_e32 v63, v62
	v_mov_b32_e32 v61, v60
	s_nop 0
	v_permlane16_swap_b32_e32 v62, v63
	v_permlane16_swap_b32_e32 v60, v61
.Ltmp28:
	.loc	1 282 19                        ; extend_attention.py:282:19
	v_max3_f32 v61, v60, v61, v35
	v_max3_f32 v60, v62, v63, v34
	.loc	1 283 27                        ; extend_attention.py:283:27
	v_pk_add_f32 v[34:35], v[34:35], v[60:61] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 226 5                         ; extend_attention.py:226:5
	s_cmp_lt_i32 s75, s72
	.loc	1 283 20                        ; extend_attention.py:283:20
	v_pk_mul_f32 v[34:35], v[34:35], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v35
	s_nop 1
	v_cndmask_b32_e64 v62, 0, v86, s[14:15]
	v_add_f32_e32 v35, v35, v62
	v_exp_f32_e32 v35, v35
	v_cndmask_b32_e64 v62, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v34
	v_ldexp_f32 v63, v35, v62
	s_nop 0
	v_cndmask_b32_e64 v35, 0, v86, s[14:15]
	v_add_f32_e32 v34, v34, v35
	v_exp_f32_e32 v34, v34
	v_cndmask_b32_e64 v35, 0, v87, s[14:15]
	v_ldexp_f32 v62, v34, v35
	.loc	1 284 20                        ; extend_attention.py:284:20
	v_pk_add_f32 v[34:35], v[36:37], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[36:37], v[38:39], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 284 13 is_stmt 0              ; extend_attention.py:284:13
	v_pk_mul_f32 v[34:35], v[34:35], s[68:69] op_sel_hi:[1,0]
	.loc	1 284 20                        ; extend_attention.py:284:20
	v_pk_add_f32 v[38:39], v[40:41], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[40:41], v[42:43], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[42:43], v[44:45], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[44:45], v[46:47], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[46:47], v[48:49], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[48:49], v[50:51], v[60:61] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mov_b32_e32 v50, v61
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_cmp_gt_f32_e64 s[14:15], s76, v35
	.loc	1 284 20                        ; extend_attention.py:284:20
	v_pk_add_f32 v[52:53], v[52:53], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[54:55], v[54:55], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[112:113], v[112:113], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[110:111], v[110:111], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[104:105], v[104:105], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[106:107], v[106:107], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[108:109], v[108:109], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[50:51], v[56:57], v[50:51] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v35, v35, v56
	v_exp_f32_e32 v35, v35
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v34
	v_pk_mul_f32 v[36:37], v[36:37], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v35, v35, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v34, v34, v56
	v_exp_f32_e32 v34, v34
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v37
	v_pk_mul_f32 v[38:39], v[38:39], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v34, v34, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v37, v37, v56
	v_exp_f32_e32 v37, v37
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v36
	v_pk_mul_f32 v[40:41], v[40:41], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v37, v37, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v36, v36, v56
	v_exp_f32_e32 v36, v36
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v39
	v_pk_mul_f32 v[42:43], v[42:43], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v36, v36, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v39, v39, v56
	v_exp_f32_e32 v39, v39
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v38
	v_pk_mul_f32 v[44:45], v[44:45], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v39, v39, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v38, v38, v56
	v_exp_f32_e32 v38, v38
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v41
	v_pk_mul_f32 v[46:47], v[46:47], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v38, v38, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v41, v41, v56
	v_exp_f32_e32 v41, v41
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v40
	v_pk_mul_f32 v[48:49], v[48:49], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v41, v41, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v40, v40, v56
	v_exp_f32_e32 v40, v40
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v43
	v_pk_mul_f32 v[52:53], v[52:53], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v40, v40, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v43, v43, v56
	v_exp_f32_e32 v43, v43
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v42
	v_pk_mul_f32 v[50:51], v[50:51], s[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v43, v43, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v42, v42, v56
	v_exp_f32_e32 v42, v42
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v45
	.loc	1 296 15 is_stmt 1              ; extend_attention.py:296:15
	v_pk_mul_f32 v[30:31], v[30:31], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v42, v42, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v45, v45, v56
	v_exp_f32_e32 v45, v45
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v44
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[32:33], v[32:33], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v45, v45, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v44, v44, v56
	v_exp_f32_e32 v44, v44
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v47
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[26:27], v[26:27], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v44, v44, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v47, v47, v56
	v_exp_f32_e32 v47, v47
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v46
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[28:29], v[28:29], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v47, v47, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v46, v46, v56
	v_exp_f32_e32 v46, v46
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v49
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[22:23], v[22:23], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v46, v46, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v49, v49, v56
	v_exp_f32_e32 v49, v49
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v48
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[24:25], v[24:25], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v49, v49, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v48, v48, v56
	v_exp_f32_e32 v48, v48
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[18:19], v[18:19], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v48, v48, v56
	v_cndmask_b32_e64 v56, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v56
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v56, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_pk_mul_f32 v[20:21], v[20:21], v[62:63] op_sel_hi:[1,0]
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v115, v53, v56
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
.Ltmp29:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_pk_add_f32 v[56:57], v[46:47], v[48:49]
.Ltmp30:
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v114, v52, v53
	v_pk_mul_f32 v[52:53], v[54:55], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v117, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_ldexp_f32 v116, v52, v53
	v_pk_mul_f32 v[52:53], v[112:113], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v113, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_ldexp_f32 v112, v52, v53
	v_pk_mul_f32 v[52:53], v[110:111], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v111, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_ldexp_f32 v110, v52, v53
	v_pk_mul_f32 v[52:53], v[104:105], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v105, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_ldexp_f32 v104, v52, v53
	v_pk_mul_f32 v[52:53], v[106:107], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v107, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_ldexp_f32 v106, v52, v53
	v_pk_mul_f32 v[52:53], v[108:109], s[68:69] op_sel_hi:[1,0]
	s_nop 0
	v_cmp_gt_f32_e64 s[14:15], s76, v53
	s_nop 1
	v_cndmask_b32_e64 v54, 0, v86, s[14:15]
	v_add_f32_e32 v53, v53, v54
	v_exp_f32_e32 v53, v53
	v_cndmask_b32_e64 v54, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v52
	v_ldexp_f32 v109, v53, v54
	s_nop 0
	v_cndmask_b32_e64 v53, 0, v86, s[14:15]
	v_add_f32_e32 v52, v52, v53
	v_exp_f32_e32 v52, v52
	v_cndmask_b32_e64 v53, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v51
.Ltmp31:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_pk_add_f32 v[54:55], v[42:43], v[44:45]
.Ltmp32:
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v108, v52, v53
	v_cndmask_b32_e64 v52, 0, v86, s[14:15]
	v_add_f32_e32 v51, v51, v52
	v_exp_f32_e32 v51, v51
	v_cndmask_b32_e64 v52, 0, v87, s[14:15]
	v_cmp_gt_f32_e64 s[14:15], s76, v50
	.loc	1 295 13                        ; extend_attention.py:295:13
	v_cvt_pk_bf16_f32 v42, v42, v43
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v119, v51, v52
	v_cndmask_b32_e64 v51, 0, v86, s[14:15]
	v_add_f32_e32 v50, v50, v51
	v_exp_f32_e32 v50, v50
	v_cndmask_b32_e64 v51, 0, v87, s[14:15]
.Ltmp33:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_pk_add_f32 v[52:53], v[38:39], v[40:41]
.Ltmp34:
	.loc	1 295 13                        ; extend_attention.py:295:13
	v_cvt_pk_bf16_f32 v43, v44, v45
	.loc	1 284 13                        ; extend_attention.py:284:13
	v_ldexp_f32 v118, v50, v51
.Ltmp35:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_pk_add_f32 v[50:51], v[34:35], v[36:37]
	v_pk_add_f32 v[120:121], v[108:109], v[118:119]
	v_pk_add_f32 v[50:51], v[50:51], v[52:53]
	v_pk_add_f32 v[52:53], v[54:55], v[56:57]
	v_pk_add_f32 v[54:55], v[112:113], v[110:111]
	v_pk_add_f32 v[50:51], v[50:51], v[52:53]
	v_pk_add_f32 v[52:53], v[114:115], v[116:117]
	v_pk_add_f32 v[56:57], v[104:105], v[106:107]
	v_pk_add_f32 v[52:53], v[52:53], v[54:55]
	v_pk_add_f32 v[54:55], v[56:57], v[120:121]
.Ltmp36:
	.loc	1 295 13                        ; extend_attention.py:295:13
	v_cvt_pk_bf16_f32 v34, v34, v35
.Ltmp37:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_pk_add_f32 v[52:53], v[52:53], v[54:55]
.Ltmp38:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:285:34 ] ]
	v_mov_b32_e32 v54, v50
	v_mov_b32_e32 v55, v52
	v_mov_b32_e32 v52, v51
	v_pk_add_f32 v[50:51], v[54:55], v[52:53]
.Ltmp39:
	.loc	1 292 13                        ; extend_attention.py:292:13
	v_cndmask_b32_e64 v54, v79, v75, s[0:1]
.Ltmp40:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_mov_b32_e32 v52, v50
	v_mov_b32_e32 v53, v51
	s_nop 0
	v_permlane32_swap_b32_e32 v50, v52
	v_permlane32_swap_b32_e32 v51, v53
.Ltmp41:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:285:34 ] ]
	v_pk_add_f32 v[50:51], v[50:51], v[52:53]
.Ltmp42:
	.loc	1 292 13                        ; extend_attention.py:292:13
	buffer_load_dwordx4 v[54:57], v54, s[64:67], 0 offen
.Ltmp43:
	.loc	2 314 12                        ; standard.py:314:12 @[ extend_attention.py:285:34 ]
	v_mov_b32_e32 v52, v50
	v_mov_b32_e32 v53, v51
	s_nop 0
	v_permlane16_swap_b32_e32 v50, v52
	v_permlane16_swap_b32_e32 v51, v53
.Ltmp44:
	.loc	2 287 12                        ; standard.py:287:12 @[ standard.py:314:12 @[ extend_attention.py:285:34 ] ]
	v_pk_add_f32 v[50:51], v[50:51], v[52:53]
.Ltmp45:
	.loc	1 295 13                        ; extend_attention.py:295:13
	v_cvt_pk_bf16_f32 v35, v36, v37
	.loc	1 285 16                        ; extend_attention.py:285:16
	v_pk_fma_f32 v[58:59], v[58:59], v[62:63], v[50:51]
	.loc	1 292 13                        ; extend_attention.py:292:13
	v_cndmask_b32_e64 v50, v79, v76, s[12:13]
	buffer_load_dwordx4 v[50:53], v50, s[64:67], 0 offen
	.loc	1 295 13                        ; extend_attention.py:295:13
	v_cvt_pk_bf16_f32 v36, v38, v39
	v_cvt_pk_bf16_f32 v37, v40, v41
	v_cvt_pk_bf16_f32 v44, v46, v47
	v_cvt_pk_bf16_f32 v45, v48, v49
	v_cvt_pk_bf16_f32 v38, v114, v115
	v_cvt_pk_bf16_f32 v39, v116, v117
	v_cvt_pk_bf16_f32 v40, v112, v113
	v_cvt_pk_bf16_f32 v41, v110, v111
	v_cvt_pk_bf16_f32 v46, v104, v105
	v_cvt_pk_bf16_f32 v47, v106, v107
	v_cvt_pk_bf16_f32 v48, v108, v109
	v_cvt_pk_bf16_f32 v49, v118, v119
	.loc	1 292 13                        ; extend_attention.py:292:13
	s_barrier
	s_waitcnt vmcnt(0)
	ds_write2st64_b64 v81, v[50:51], v[54:55] offset1:8
	ds_write2st64_b64 v82, v[52:53], v[56:57] offset1:8
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b64_tr_b16 v[50:51], v83
	ds_read_b64_tr_b16 v[52:53], v83 offset:2048
	ds_read_b64_tr_b16 v[104:105], v83 offset:4096
	ds_read_b64_tr_b16 v[106:107], v83 offset:6144
	ds_read_b64_tr_b16 v[54:55], v83 offset:64
	ds_read_b64_tr_b16 v[56:57], v83 offset:2112
	ds_read_b64_tr_b16 v[108:109], v83 offset:4160
	ds_read_b64_tr_b16 v[110:111], v83 offset:6208
	ds_read_b64_tr_b16 v[112:113], v84
	ds_read_b64_tr_b16 v[114:115], v84 offset:2048
	ds_read_b64_tr_b16 v[120:121], v84 offset:4096
	ds_read_b64_tr_b16 v[122:123], v84 offset:6144
	ds_read_b64_tr_b16 v[116:117], v84 offset:64
	ds_read_b64_tr_b16 v[118:119], v84 offset:2112
	ds_read_b64_tr_b16 v[124:125], v84 offset:4160
	ds_read_b64_tr_b16 v[126:127], v84 offset:6208
	.loc	1 296 15                        ; extend_attention.py:296:15
	v_mov_b32_e32 v62, v63
	v_pk_mul_f32 v[14:15], v[14:15], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[62:63] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[62:63] op_sel_hi:[1,0]
	.loc	1 296 41 is_stmt 0              ; extend_attention.py:296:41
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_16x16x32_bf16 v[30:33], v[50:53], v[34:37], v[30:33]
	.loc	1 226 5 is_stmt 1               ; extend_attention.py:226:5
	v_add_u32_e32 v75, s73, v75
	v_add_u32_e32 v76, s73, v76
	.loc	1 296 41                        ; extend_attention.py:296:41
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 v[26:29], v[112:115], v[34:37], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[54:57], v[34:37], v[22:25]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_16x16x32_bf16 v[18:21], v[116:119], v[34:37], v[18:21]
	v_mov_b64_e32 v[34:35], v[60:61]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[50:53], v[38:41], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[112:115], v[38:41], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[54:57], v[38:41], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[116:119], v[38:41], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[104:107], v[42:45], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[120:123], v[42:45], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[108:111], v[42:45], v[22:25]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 v[18:21], v[124:127], v[42:45], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[104:107], v[46:49], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[120:123], v[46:49], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[108:111], v[46:49], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[124:127], v[46:49], v[2:5]
	s_cbranch_scc1 .LBB0_6
.LBB0_7:                                ; %._crit_edge12
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_div_scale_f32 v38, s[0:1], v58, v58, v30
	v_rcp_f32_e32 v39, v38
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_waitcnt lgkmcnt(0)
	s_barrier
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v40, -v38, v39, 1.0
	v_fmac_f32_e32 v39, v40, v39
	v_div_scale_f32 v40, vcc, v30, v58, v30
	v_mul_f32_e32 v41, v40, v39
	v_fma_f32 v42, -v38, v41, v40
	v_fmac_f32_e32 v41, v42, v39
	v_fma_f32 v38, -v38, v41, v40
	v_div_scale_f32 v40, s[0:1], v58, v58, v31
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v39, v41
	v_div_fixup_f32 v30, v38, v58, v30
	.loc	1 124 10                        ; extend_attention.py:124:10
	v_add_u32_e32 v37, s70, v65
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v31, v58, v31
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v32
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v31, v38, v58, v31
	.loc	1 301 9                         ; extend_attention.py:301:9
	v_mul_lo_u32 v37, v37, s71
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v32, v58, v32
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v33
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v32, v38, v58, v32
	.loc	1 124 10                        ; extend_attention.py:124:10
	v_add_u32_e32 v36, s70, v66
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v33, v58, v33
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v26
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v33, v38, v58, v33
	.loc	1 301 9                         ; extend_attention.py:301:9
	v_mul_lo_u32 v36, v36, s71
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v26, v58, v26
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v27
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v26, v38, v58, v26
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_and_b32 s9, s9, 0xffff
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v27, v58, v27
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v28
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v27, v38, v58, v27
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_mov_b32 s11, 0x27000
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v28, v58, v28
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v29
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v28, v38, v58, v28
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_mov_b32 s10, 0x7ffffffe
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v29, v58, v29
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v22
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v29, v38, v58, v29
	.loc	1 124 10                        ; extend_attention.py:124:10
	v_add_u32_e32 v35, s70, v67
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v22, v58, v22
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v23
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v22, v38, v58, v22
	.loc	1 301 9                         ; extend_attention.py:301:9
	v_mul_lo_u32 v35, v35, s71
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v23, v58, v23
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v24
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v23, v38, v58, v23
	.loc	1 124 10                        ; extend_attention.py:124:10
	v_add_u32_e32 v34, s70, v68
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v24, v58, v24
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v25
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v24, v38, v58, v24
	.loc	1 301 9                         ; extend_attention.py:301:9
	v_mul_lo_u32 v34, v34, s71
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v25, v58, v25
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v18
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v25, v38, v58, v25
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v18, v58, v18
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v19
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v18, v38, v58, v18
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v19, v58, v19
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v20
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v19, v38, v58, v19
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v20, v58, v20
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v58, v58, v21
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v20, v38, v58, v20
	v_fma_f32 v38, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v38, v42
	v_div_scale_f32 v38, vcc, v21, v58, v21
	v_mul_f32_e32 v39, v38, v42
	v_fma_f32 v41, -v40, v39, v38
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v59, v59, v14
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v38, v38, v42, v39
	v_div_fixup_f32 v21, v38, v58, v21
	v_fma_f32 v38, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v38, v41
	v_div_scale_f32 v38, vcc, v14, v59, v14
	v_mul_f32_e32 v39, v38, v41
	v_fma_f32 v42, -v40, v39, v38
	v_fmac_f32_e32 v39, v42, v41
	v_fma_f32 v38, -v40, v39, v38
	v_div_scale_f32 v40, s[0:1], v59, v59, v15
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v38, v38, v41, v39
	v_div_fixup_f32 v38, v38, v59, v14
	v_fma_f32 v14, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v14, v42
	v_div_scale_f32 v14, vcc, v15, v59, v15
	v_mul_f32_e32 v39, v14, v42
	v_fma_f32 v41, -v40, v39, v14
	v_fmac_f32_e32 v39, v41, v42
	v_fma_f32 v14, -v40, v39, v14
	v_div_scale_f32 v40, s[0:1], v59, v59, v16
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v14, v14, v42, v39
	v_div_fixup_f32 v39, v14, v59, v15
	v_fma_f32 v14, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v14, v41
	v_div_scale_f32 v14, vcc, v16, v59, v16
	v_mul_f32_e32 v15, v14, v41
	v_fma_f32 v42, -v40, v15, v14
	v_fmac_f32_e32 v15, v42, v41
	v_fma_f32 v14, -v40, v15, v14
	v_div_scale_f32 v40, s[0:1], v59, v59, v17
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v14, v14, v41, v15
	v_div_fixup_f32 v16, v14, v59, v16
	v_fma_f32 v14, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v14, v42
	v_div_scale_f32 v14, vcc, v17, v59, v17
	v_mul_f32_e32 v15, v14, v42
	v_fma_f32 v41, -v40, v15, v14
	v_fmac_f32_e32 v15, v41, v42
	v_fma_f32 v14, -v40, v15, v14
	v_div_scale_f32 v40, s[0:1], v59, v59, v10
	v_rcp_f32_e32 v41, v40
	v_div_fmas_f32 v14, v14, v42, v15
	v_div_fixup_f32 v17, v14, v59, v17
	v_fma_f32 v14, -v40, v41, 1.0
	v_fmac_f32_e32 v41, v14, v41
	v_div_scale_f32 v14, vcc, v10, v59, v10
	v_mul_f32_e32 v15, v14, v41
	v_fma_f32 v42, -v40, v15, v14
	v_fmac_f32_e32 v15, v42, v41
	v_fma_f32 v14, -v40, v15, v14
	v_div_scale_f32 v40, s[0:1], v59, v59, v11
	v_rcp_f32_e32 v42, v40
	v_div_fmas_f32 v14, v14, v41, v15
	v_div_fixup_f32 v41, v14, v59, v10
	v_fma_f32 v10, -v40, v42, 1.0
	v_fmac_f32_e32 v42, v10, v42
	v_div_scale_f32 v10, vcc, v11, v59, v11
	v_mul_f32_e32 v14, v10, v42
	v_fma_f32 v15, -v40, v14, v10
	v_fmac_f32_e32 v14, v15, v42
	v_div_scale_f32 v15, s[0:1], v59, v59, v12
	v_fma_f32 v10, -v40, v14, v10
	v_rcp_f32_e32 v40, v15
	v_div_fmas_f32 v10, v10, v42, v14
	v_div_fixup_f32 v42, v10, v59, v11
	v_fma_f32 v10, -v15, v40, 1.0
	v_fmac_f32_e32 v40, v10, v40
	v_div_scale_f32 v10, vcc, v12, v59, v12
	v_mul_f32_e32 v11, v10, v40
	v_fma_f32 v14, -v15, v11, v10
	v_fmac_f32_e32 v11, v14, v40
	v_div_scale_f32 v14, s[0:1], v59, v59, v13
	v_fma_f32 v10, -v15, v11, v10
	v_rcp_f32_e32 v15, v14
	v_div_fmas_f32 v10, v10, v40, v11
	v_div_fixup_f32 v12, v10, v59, v12
	v_fma_f32 v10, -v14, v15, 1.0
	v_fmac_f32_e32 v15, v10, v15
	v_div_scale_f32 v10, vcc, v13, v59, v13
	v_mul_f32_e32 v11, v10, v15
	v_fma_f32 v40, -v14, v11, v10
	v_fmac_f32_e32 v11, v40, v15
	v_fma_f32 v10, -v14, v11, v10
	v_div_scale_f32 v14, s[0:1], v59, v59, v6
	v_rcp_f32_e32 v40, v14
	v_div_fmas_f32 v10, v10, v15, v11
	v_div_fixup_f32 v13, v10, v59, v13
	v_fma_f32 v10, -v14, v40, 1.0
	v_fmac_f32_e32 v40, v10, v40
	v_div_scale_f32 v10, vcc, v6, v59, v6
	v_mul_f32_e32 v11, v10, v40
	v_fma_f32 v15, -v14, v11, v10
	v_fmac_f32_e32 v11, v15, v40
	v_fma_f32 v10, -v14, v11, v10
	v_div_scale_f32 v14, s[0:1], v59, v59, v7
	v_rcp_f32_e32 v15, v14
	v_div_fmas_f32 v10, v10, v40, v11
	v_div_fixup_f32 v40, v10, v59, v6
	v_fma_f32 v6, -v14, v15, 1.0
	v_fmac_f32_e32 v15, v6, v15
	v_div_scale_f32 v6, vcc, v7, v59, v7
	v_mul_f32_e32 v10, v6, v15
	v_fma_f32 v11, -v14, v10, v6
	v_fmac_f32_e32 v10, v11, v15
	v_div_scale_f32 v11, s[0:1], v59, v59, v8
	v_fma_f32 v6, -v14, v10, v6
	v_rcp_f32_e32 v14, v11
	v_div_fmas_f32 v6, v6, v15, v10
	v_div_fixup_f32 v43, v6, v59, v7
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_cvt_pk_bf16_f32 v15, v20, v21
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v6, -v11, v14, 1.0
	v_fmac_f32_e32 v14, v6, v14
	v_div_scale_f32 v6, vcc, v8, v59, v8
	v_mul_f32_e32 v7, v6, v14
	v_fma_f32 v10, -v11, v7, v6
	v_fmac_f32_e32 v7, v10, v14
	v_div_scale_f32 v10, s[0:1], v59, v59, v9
	v_fma_f32 v6, -v11, v7, v6
	v_rcp_f32_e32 v11, v10
	v_div_fmas_f32 v6, v6, v14, v7
	v_div_fixup_f32 v44, v6, v59, v8
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_cvt_pk_bf16_f32 v14, v18, v19
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v6, -v10, v11, 1.0
	v_fmac_f32_e32 v11, v6, v11
	v_div_scale_f32 v6, vcc, v9, v59, v9
	v_mul_f32_e32 v7, v6, v11
	v_fma_f32 v8, -v10, v7, v6
	v_fmac_f32_e32 v7, v8, v11
	v_div_scale_f32 v8, s[0:1], v59, v59, v2
	v_fma_f32 v6, -v10, v7, v6
	v_rcp_f32_e32 v10, v8
	v_div_fmas_f32 v6, v6, v11, v7
	v_div_fixup_f32 v45, v6, v59, v9
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_lshlrev_b32_e32 v18, 4, v0
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v6, -v8, v10, 1.0
	v_fmac_f32_e32 v10, v6, v10
	v_div_scale_f32 v6, vcc, v2, v59, v2
	v_mul_f32_e32 v7, v6, v10
	v_fma_f32 v9, -v8, v7, v6
	v_fmac_f32_e32 v7, v9, v10
	v_fma_f32 v6, -v8, v7, v6
	v_div_scale_f32 v8, s[0:1], v59, v59, v3
	v_rcp_f32_e32 v9, v8
	v_div_fmas_f32 v6, v6, v10, v7
	v_div_fixup_f32 v46, v6, v59, v2
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_bfe_i32 v19, v0, 5, 1
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v2, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v2, v9
	v_div_scale_f32 v2, vcc, v3, v59, v3
	v_mul_f32_e32 v6, v2, v9
	v_fma_f32 v7, -v8, v6, v2
	v_fmac_f32_e32 v6, v7, v9
	v_div_scale_f32 v7, s[0:1], v59, v59, v4
	v_fma_f32 v2, -v8, v6, v2
	v_rcp_f32_e32 v8, v7
	v_div_fmas_f32 v2, v2, v9, v6
	v_div_fixup_f32 v47, v2, v59, v3
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_and_b32_e32 v18, 0x1f0, v18
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v2, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v2, v8
	v_div_scale_f32 v2, vcc, v4, v59, v4
	v_mul_f32_e32 v3, v2, v8
	v_fma_f32 v6, -v7, v3, v2
	v_fmac_f32_e32 v3, v6, v8
	v_div_scale_f32 v6, s[0:1], v59, v59, v5
	v_fma_f32 v2, -v7, v3, v2
	v_rcp_f32_e32 v7, v6
	v_div_fmas_f32 v2, v2, v8, v3
	v_div_fixup_f32 v48, v2, v59, v4
	.loc	1 307 9                         ; extend_attention.py:307:9
	s_lshl_b32 s0, s69, 3
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_fma_f32 v2, -v6, v7, 1.0
	v_fmac_f32_e32 v7, v2, v7
	v_div_scale_f32 v2, vcc, v5, v59, v5
	v_mul_f32_e32 v3, v2, v7
	v_fma_f32 v4, -v6, v3, v2
	v_fmac_f32_e32 v3, v4, v7
	v_fma_f32 v2, -v6, v3, v2
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_and_b32_e32 v19, 0x820, v19
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_div_fmas_f32 v2, v2, v7, v3
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_bitop3_b32 v18, s0, v19, v18 bitop3:0x36
	.loc	1 309 14                        ; extend_attention.py:309:14
	v_div_fixup_f32 v49, v2, v59, v5
	.loc	1 307 9                         ; extend_attention.py:307:9
	v_cvt_pk_bf16_f32 v2, v30, v31
	v_cvt_pk_bf16_f32 v3, v32, v33
	v_cvt_pk_bf16_f32 v4, v38, v39
	v_cvt_pk_bf16_f32 v5, v16, v17
	v_add_u32_e32 v19, 0, v18
	v_cvt_pk_bf16_f32 v6, v26, v27
	v_cvt_pk_bf16_f32 v7, v28, v29
	v_cvt_pk_bf16_f32 v8, v41, v42
	v_cvt_pk_bf16_f32 v9, v12, v13
	ds_write_b128 v19, v[2:5]
	v_xad_u32 v2, v18, 64, 0
	ds_write_b128 v2, v[6:9] offset:4096
	v_xor_b32_e32 v2, 0xa0, v18
	v_cvt_pk_bf16_f32 v10, v22, v23
	v_cvt_pk_bf16_f32 v11, v24, v25
	v_cvt_pk_bf16_f32 v12, v40, v43
	v_cvt_pk_bf16_f32 v13, v44, v45
	v_add_u32_e32 v2, 0, v2
	ds_write_b128 v2, v[10:13] offset:8192
	v_xor_b32_e32 v2, 0xe0, v18
	v_cvt_pk_bf16_f32 v16, v46, v47
	v_cvt_pk_bf16_f32 v17, v48, v49
	v_add_u32_e32 v2, 0, v2
	ds_write_b128 v2, v[14:17] offset:12288
	v_and_b32_e32 v2, 3, v0
	v_lshlrev_b32_e32 v3, 11, v2
	v_lshlrev_b32_e32 v2, 5, v2
	v_lshlrev_b32_e32 v4, 1, v64
	v_bfe_i32 v0, v0, 2, 1
	s_movk_i32 s1, 0x20a0
	v_and_b32_e32 v4, 0xf0, v4
	s_lshl_b32 s0, s33, 2
	v_bitop3_b32 v0, v0, v2, s1 bitop3:0x6c
	s_and_b32 s0, s0, 0x200
	v_xor_b32_e32 v0, v0, v4
	v_add3_u32 v0, s0, v3, v0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[2:5], v0
	ds_read_b128 v[8:11], v0 offset:256
	ds_read_b128 v[12:15], v0 offset:1024
	ds_read_b128 v[18:21], v0 offset:1280
	v_add_lshl_u32 v0, v37, v1, 1
	s_waitcnt lgkmcnt(3)
	v_mov_b32_e32 v6, v2
	v_bfrev_b32_e32 v2, 1
	v_mov_b32_e32 v7, v3
	v_cndmask_b32_e64 v0, v2, v0, s[18:19]
	s_waitcnt lgkmcnt(2)
	buffer_store_dwordx4 v[6:9], v0, s[8:11], 0 offen
	v_add_lshl_u32 v0, v36, v1, 1
	s_waitcnt lgkmcnt(1)
	v_mov_b32_e32 v16, v12
	v_mov_b32_e32 v17, v13
	v_cndmask_b32_e64 v0, v2, v0, s[2:3]
	s_waitcnt lgkmcnt(0)
	buffer_store_dwordx4 v[16:19], v0, s[8:11], 0 offen
	v_add_lshl_u32 v0, v35, v1, 1
	v_mov_b32_e32 v6, v10
	v_mov_b32_e32 v7, v11
	v_cndmask_b32_e64 v0, v2, v0, s[16:17]
	buffer_store_dwordx4 v[4:7], v0, s[8:11], 0 offen
	v_add_lshl_u32 v0, v34, v1, 1
	v_mov_b32_e32 v16, v20
	v_mov_b32_e32 v17, v21
	v_cndmask_b32_e64 v0, v2, v0, s[20:21]
	buffer_store_dwordx4 v[14:17], v0, s[8:11], 0 offen
	.loc	1 54 1                          ; extend_attention.py:54:1
	s_endpgm
.Ltmp46:
.Lfunc_end0:
	.size	_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8, .Lfunc_end0-_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
	.cfi_endproc
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 144
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 169
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 152
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
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.num_vgpr, 152
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.num_agpr, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.numbered_sgpr, 77
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.num_named_barrier, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.private_seg_size, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.uses_vcc, 1
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.uses_flat_scratch, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.has_dyn_sized_stack, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.has_recursion, 0
	.set .L_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 12588
; TotalNumSgprs: 83
; NumVgprs: 152
; NumAgprs: 0
; TotalNumVgprs: 152
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 12
; VGPRBlocks: 21
; NumSGPRsForWavesPerEU: 102
; NumVGPRsForWavesPerEU: 169
; AccumOffset: 152
; Occupancy: 2
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 37
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
	.byte	5                               ; Abbreviation Code
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
	.byte	6                               ; Abbreviation Code
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
	.byte	8                               ; Abbreviation Code
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
	.byte	5                               ; DW_FORM_data2
	.byte	87                              ; DW_AT_call_column
	.byte	11                              ; DW_FORM_data1
	.byte	0                               ; EOM(1)
	.byte	0                               ; EOM(2)
	.byte	9                               ; Abbreviation Code
	.byte	29                              ; DW_TAG_inlined_subroutine
	.byte	1                               ; DW_CHILDREN_yes
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
	.byte	1                               ; Abbrev [1] 0xb:0xb0 DW_TAG_compile_unit
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
	.byte	3                               ; Abbrev [3] 0x30:0x8a DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x21 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp6-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	201                             ; DW_AT_call_line
	.byte	30                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x55:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges0                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.byte	216                             ; DW_AT_call_line
	.byte	16                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	6                               ; Abbrev [6] 0x62:0x1a DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges1                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.byte	204                             ; DW_AT_call_line
	.byte	34                              ; DW_AT_call_column
	.byte	7                               ; Abbrev [7] 0x6e:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges2                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	8                               ; Abbrev [8] 0x7c:0x22 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp24                         ; DW_AT_low_pc
	.long	.Ltmp28-.Ltmp24                 ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.short	282                             ; DW_AT_call_line
	.byte	30                              ; DW_AT_call_column
	.byte	5                               ; Abbrev [5] 0x91:0xc DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges3                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.byte	216                             ; DW_AT_call_line
	.byte	16                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	9                               ; Abbrev [9] 0x9e:0x1b DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges4                 ; DW_AT_ranges
	.byte	1                               ; DW_AT_call_file
	.short	285                             ; DW_AT_call_line
	.byte	34                              ; DW_AT_call_column
	.byte	7                               ; Abbrev [7] 0xab:0xd DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.long	.Ldebug_ranges5                 ; DW_AT_ranges
	.byte	2                               ; DW_AT_call_file
	.short	314                             ; DW_AT_call_line
	.byte	12                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_ranges,"",@progbits
.Ldebug_ranges0:
	.quad	.Ltmp2-.Lfunc_begin0
	.quad	.Ltmp3-.Lfunc_begin0
	.quad	.Ltmp4-.Lfunc_begin0
	.quad	.Ltmp5-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges1:
	.quad	.Ltmp7-.Lfunc_begin0
	.quad	.Ltmp8-.Lfunc_begin0
	.quad	.Ltmp9-.Lfunc_begin0
	.quad	.Ltmp10-.Lfunc_begin0
	.quad	.Ltmp11-.Lfunc_begin0
	.quad	.Ltmp12-.Lfunc_begin0
	.quad	.Ltmp13-.Lfunc_begin0
	.quad	.Ltmp14-.Lfunc_begin0
	.quad	.Ltmp15-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp18-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp21-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges2:
	.quad	.Ltmp16-.Lfunc_begin0
	.quad	.Ltmp17-.Lfunc_begin0
	.quad	.Ltmp19-.Lfunc_begin0
	.quad	.Ltmp20-.Lfunc_begin0
	.quad	.Ltmp22-.Lfunc_begin0
	.quad	.Ltmp23-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges3:
	.quad	.Ltmp24-.Lfunc_begin0
	.quad	.Ltmp25-.Lfunc_begin0
	.quad	.Ltmp26-.Lfunc_begin0
	.quad	.Ltmp27-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges4:
	.quad	.Ltmp29-.Lfunc_begin0
	.quad	.Ltmp30-.Lfunc_begin0
	.quad	.Ltmp31-.Lfunc_begin0
	.quad	.Ltmp32-.Lfunc_begin0
	.quad	.Ltmp33-.Lfunc_begin0
	.quad	.Ltmp34-.Lfunc_begin0
	.quad	.Ltmp35-.Lfunc_begin0
	.quad	.Ltmp36-.Lfunc_begin0
	.quad	.Ltmp37-.Lfunc_begin0
	.quad	.Ltmp39-.Lfunc_begin0
	.quad	.Ltmp40-.Lfunc_begin0
	.quad	.Ltmp42-.Lfunc_begin0
	.quad	.Ltmp43-.Lfunc_begin0
	.quad	.Ltmp45-.Lfunc_begin0
	.quad	0
	.quad	0
.Ldebug_ranges5:
	.quad	.Ltmp38-.Lfunc_begin0
	.quad	.Ltmp39-.Lfunc_begin0
	.quad	.Ltmp41-.Lfunc_begin0
	.quad	.Ltmp42-.Lfunc_begin0
	.quad	.Ltmp44-.Lfunc_begin0
	.quad	.Ltmp45-.Lfunc_begin0
	.quad	0
	.quad	0
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0 ; triton
.Linfo_string1:
	.asciz	"extend_attention.py"           ; string offset=7 ; extend_attention.py
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/attention" ; string offset=27 ; /work/aiter/aiter/ops/triton/_triton_kernels/attention
.Linfo_string3:
	.asciz	"_fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8" ; string offset=82 ; _fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
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
      - .offset:         120
        .size:           4
        .value_kind:     by_value
      - .address_space:  global
        .offset:         128
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         136
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 144
    .max_flat_workgroup_size: 256
    .name:           _fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8
    .private_segment_fixed_size: 0
    .sgpr_count:     83
    .sgpr_spill_count: 0
    .symbol:         _fwd_kernel_logit_cap_0_Lq_64_Lv_64_BLOCK_DMODEL_64_BLOCK_DPE_0_BLOCK_DV_64_BLOCK_M_128_BLOCK_N_64_USE_CUSTOM_MASK_0_IS_CAUSAL_1_SKIP_PREFIX_CUSTOM_MASK_1_STORE_TRANSPOSE_1_NUM_Q_HEADS_1_NUM_BLOCKS_1_NUM_XCDS_8.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     152
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
