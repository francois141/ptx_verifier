	.amdgcn_target "amdgcn-amd-amdhsa--gfx950"
	.amdhsa_code_object_version 5
	.text
	.globl	_fused_add_layernorm_kernel_BLOCK_SIZE_128 ; -- Begin function _fused_add_layernorm_kernel_BLOCK_SIZE_128
	.p2align	8
	.type	_fused_add_layernorm_kernel_BLOCK_SIZE_128,@function
_fused_add_layernorm_kernel_BLOCK_SIZE_128: ; @_fused_add_layernorm_kernel_BLOCK_SIZE_128
.Lfunc_begin0:
	.cfi_sections .debug_frame
	.cfi_startproc
; %bb.44:
	.file	1 "/work/aiter/aiter/ops/triton/_triton_kernels/normalization" "norm.py"
	.loc	1 151 0 prologue_end            ; norm.py:151:0
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx8 s[4:11], s[0:1], 0x8
	s_load_dwordx4 s[12:15], s[0:1], 0x28
	s_waitcnt lgkmcnt(0)
	s_branch .LBB0_0
	.loc	1 0 0 is_stmt 0                 ; :0:0
.Ltmp0:
	.p2align	8
; %bb.45:
.LBB0_0:
	s_load_dword s17, s[0:1], 0x40
	s_load_dword s35, s[0:1], 0x4c
	s_load_dwordx2 s[24:25], s[0:1], 0x38
	v_mov_b32_e32 v7, 0
.Ltmp1:
	.loc	1 191 33 is_stmt 1              ; norm.py:191:33
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s18, s17, s16
.Ltmp2:
	.file	2 "/usr/local/lib/python3.12/site-packages/triton/language" "standard.py"
	.loc	2 41 22                         ; standard.py:41:22 @[ norm.py:196:31 ]
	s_add_i32 s17, s35, 0x7f
	.loc	2 41 28 is_stmt 0               ; standard.py:41:28 @[ norm.py:196:31 ]
	s_ashr_i32 s20, s17, 31
	s_lshr_b32 s20, s20, 25
	s_add_i32 s20, s17, s20
	s_ashr_i32 s33, s20, 7
.Ltmp3:
	.loc	1 191 27 is_stmt 1              ; norm.py:191:27
	s_ashr_i32 s19, s18, 31
	.loc	1 196 45                        ; norm.py:196:45
	s_add_i32 s33, s33, -1
	.loc	1 202 19                        ; norm.py:202:19
	s_cmpk_gt_i32 s17, 0xff
	s_cselect_b64 s[30:31], -1, 0
	s_cmpk_lt_i32 s17, 0x100
	s_cbranch_scc1 .LBB0_5
; %bb.1:                                ; %.lr.ph
	.loc	1 0 19 is_stmt 0                ; norm.py:0:19
	v_and_b32_e32 v1, 0x80, v0
	v_cmp_eq_u32_e32 vcc, 0, v1
	.loc	1 202 19                        ; norm.py:202:19
	v_and_b32_e32 v1, 0x7f, v0
	v_lshlrev_b32_e32 v6, 2, v1
	v_mov_b32_e32 v7, 0
	v_lshl_add_u64 v[8:9], s[18:19], 2, v[6:7]
	s_max_i32 s17, s33, 1
	v_lshl_add_u64 v[2:3], s[8:9], 0, v[8:9]
	v_lshl_add_u64 v[4:5], s[6:7], 0, v[8:9]
	v_lshl_add_u64 v[8:9], s[2:3], 0, v[8:9]
	s_mov_b64 s[20:21], 0x200
	s_branch .LBB0_3
.LBB0_2:                                ;   in Loop: Header=BB0_3 Depth=1
	.loc	1 0 19                          ; norm.py:0:19
	s_or_b64 exec, exec, s[22:23]
	.loc	1 202 19 is_stmt 1              ; norm.py:202:19
	s_add_i32 s17, s17, -1
	.loc	1 208 17                        ; norm.py:208:17
	v_add_f32_e32 v7, v7, v1
	.loc	1 202 19                        ; norm.py:202:19
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[20:21]
	v_lshl_add_u64 v[4:5], v[4:5], 0, s[20:21]
	s_cmp_lg_u32 s17, 0
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[20:21]
	s_cbranch_scc0 .LBB0_5
.LBB0_3:                                ; =>This Inner Loop Header: Depth=1
	.loc	1 204 27                        ; norm.py:204:27
	global_load_dword v1, v[8:9], off
	.loc	1 205 31                        ; norm.py:205:31
	global_load_dword v6, v[4:5], off
	.loc	1 206 20                        ; norm.py:206:20
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, v1, v6
	.loc	1 207 50                        ; norm.py:207:50
	s_and_saveexec_b64 s[22:23], vcc
	s_cbranch_execz .LBB0_2
; %bb.4:                                ;   in Loop: Header=BB0_3 Depth=1
	global_store_dword v[2:3], v1, off
	s_branch .LBB0_2
.LBB0_5:                                ; %Flow35
	.loc	1 0 50 is_stmt 0                ; norm.py:0:50
	s_load_dword s34, s[0:1], 0x44
	s_load_dword s17, s[0:1], 0x50
	.loc	1 203 52 is_stmt 1              ; norm.py:203:52
	v_and_b32_e32 v1, 0x7f, v0
	.loc	1 211 44                        ; norm.py:211:44
	v_lshl_or_b32 v2, s33, 7, v1
	.loc	1 212 69                        ; norm.py:212:69
	v_cmp_gt_i32_e64 s[0:1], s35, v2
	v_cmp_le_i32_e32 vcc, s35, v2
	v_ashrrev_i32_e32 v3, 31, v2
	.loc	1 212 23 is_stmt 0              ; norm.py:212:23
	s_and_saveexec_b64 s[20:21], vcc
	s_xor_b64 s[20:21], exec, s[20:21]
	s_or_saveexec_b64 s[20:21], s[20:21]
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v4, 0
	s_xor_b64 exec, exec, s[20:21]
	s_cbranch_execz .LBB0_7
; %bb.6:
	.loc	1 191 27 is_stmt 1              ; norm.py:191:27
	s_lshl_b64 s[22:23], s[18:19], 2
	s_add_u32 s2, s2, s22
	s_addc_u32 s3, s3, s23
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[2:3]
	.loc	1 212 23                        ; norm.py:212:23
	global_load_dword v4, v[4:5], off
.LBB0_7:
	.loc	1 0 23 is_stmt 0                ; norm.py:0:23
	s_or_b64 exec, exec, s[20:21]
	.loc	1 214 8 is_stmt 1               ; norm.py:214:8
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_9
; %bb.8:
	.loc	1 193 37                        ; norm.py:193:37
	s_lshl_b64 s[20:21], s[18:19], 2
	s_add_u32 s6, s6, s20
	s_addc_u32 s7, s7, s21
	v_lshl_add_u64 v[8:9], v[2:3], 2, s[6:7]
	.loc	1 214 8                         ; norm.py:214:8
	global_load_dword v1, v[8:9], off
.LBB0_9:                                ; %._crit_edge17
	.loc	1 0 8 is_stmt 0                 ; norm.py:0:8
	s_or_b64 exec, exec, s[2:3]
	.loc	1 194 39 is_stmt 1              ; norm.py:194:39
	s_lshl_b64 s[28:29], s[18:19], 2
	s_add_u32 s2, s8, s28
	s_addc_u32 s3, s9, s29
	.loc	1 218 41                        ; norm.py:218:41
	v_and_b32_e32 v6, 0x80, v0
	.loc	1 216 16                        ; norm.py:216:16
	s_waitcnt vmcnt(0)
	v_add_f32_e32 v1, v4, v1
	.loc	1 218 28                        ; norm.py:218:28
	v_lshl_add_u64 v[4:5], v[2:3], 2, s[2:3]
	.loc	1 218 41 is_stmt 0              ; norm.py:218:41
	v_cmp_eq_u32_e64 s[2:3], 0, v6
	s_and_b64 s[26:27], s[2:3], s[0:1]
	s_and_saveexec_b64 s[6:7], s[26:27]
	s_cbranch_execz .LBB0_11
; %bb.10:
	global_store_dword v[4:5], v1, off
.LBB0_11:
	.loc	1 0 41                          ; norm.py:0:41
	s_or_b64 exec, exec, s[6:7]
	.loc	1 220 13 is_stmt 1              ; norm.py:220:13
	v_add_f32_e32 v1, v7, v1
.Ltmp4:
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:221:18 ]
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	v_mov_b32_e32 v6, v1
	s_nop 1
	v_mov_b32_dpp v6, v6 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:221:18 ]
	v_add_f32_e32 v1, v1, v6
	s_nop 1
	v_add_f32_dpp v1, v1, v1 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	s_nop 0
	v_readlane_b32 s18, v1, 63
	v_and_b32_e32 v1, 0xbf, v0
	v_cmp_eq_u32_e64 s[20:21], 0, v1
	v_lshrrev_b32_e32 v1, 4, v0
	v_and_b32_e32 v1, 4, v1
	v_add_u32_e32 v11, 0, v1
	s_and_saveexec_b64 s[6:7], s[20:21]
; %bb.12:
	v_mov_b32_e32 v1, s18
	ds_write_b32 v11, v1
; %bb.13:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	v_cmp_gt_u32_e64 s[22:23], 2, v0
	v_lshl_add_u32 v1, v0, 2, 0
	v_mov_b32_e32 v6, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], s[22:23]
; %bb.14:
	ds_read_b32 v6, v1
; %bb.15:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[6:7]
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v7, v6
	v_cmp_eq_u32_e64 s[6:7], 0, v0
	s_nop 0
	v_mov_b32_dpp v7, v7 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[18:19], s[6:7]
; %bb.16:
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v6, v6, v7
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	ds_write_b32 v1, v6
; %bb.17:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[18:19]
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:221:18 ]
	v_mov_b32_e32 v7, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v6, v7
.Ltmp5:
	.loc	1 221 35 is_stmt 1              ; norm.py:221:35
	v_cvt_f32_i32_e32 v10, s35
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v8, s[18:19], v10, v10, v6
	v_rcp_f32_e32 v9, v8
	v_div_scale_f32 v12, vcc, v6, v10, v6
	v_fma_f32 v13, -v8, v9, 1.0
	v_fmac_f32_e32 v9, v13, v9
	v_mul_f32_e32 v13, v12, v9
	v_fma_f32 v14, -v8, v13, v12
	v_fmac_f32_e32 v13, v14, v9
	v_fma_f32 v8, -v8, v13, v12
	v_div_fmas_f32 v8, v8, v9, v13
	.loc	1 226 19                        ; norm.py:226:19
	v_cndmask_b32_e64 v9, 0, 1, s[30:31]
	v_cmp_ne_u32_e64 s[18:19], 1, v9
	s_andn2_b64 vcc, exec, s[30:31]
	.loc	1 221 35                        ; norm.py:221:35
	v_div_fixup_f32 v12, v8, v10, v6
	.loc	1 226 19                        ; norm.py:226:19
	s_cbranch_vccnz .LBB0_20
; %bb.18:                               ; %.lr.ph6.preheader
	s_max_i32 s35, s33, 1
	v_and_b32_e32 v6, 0x7f, v0
	s_add_u32 s30, s8, s28
	v_lshlrev_b32_e32 v6, 2, v6
	v_mov_b32_e32 v7, 0
	s_addc_u32 s31, s9, s29
	v_lshl_add_u64 v[8:9], s[30:31], 0, v[6:7]
	s_mov_b64 s[30:31], 0x200
.LBB0_19:                               ; %.lr.ph6
                                        ; =>This Inner Loop Header: Depth=1
	.loc	1 228 26                        ; norm.py:228:26
	global_load_dword v6, v[8:9], off
	.loc	1 226 19                        ; norm.py:226:19
	s_add_i32 s35, s35, -1
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[30:31]
	s_cmp_lg_u32 s35, 0
	.loc	1 231 28                        ; norm.py:231:28
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v6, v6, v12
	.loc	1 232 16                        ; norm.py:232:16
	v_fmac_f32_e32 v7, v6, v6
	.loc	1 226 19                        ; norm.py:226:19
	s_cbranch_scc1 .LBB0_19
.LBB0_20:                               ; %._crit_edge7
	.loc	1 0 19 is_stmt 0                ; norm.py:0:19
	v_mov_b32_e32 v6, 0
	.loc	1 237 8 is_stmt 1               ; norm.py:237:8
	s_and_saveexec_b64 s[30:31], s[0:1]
	s_cbranch_execz .LBB0_22
; %bb.21:
	global_load_dword v6, v[4:5], off
.LBB0_22:
	.loc	1 0 8 is_stmt 0                 ; norm.py:0:8
	s_or_b64 exec, exec, s[30:31]
	.loc	1 239 55 is_stmt 1              ; norm.py:239:55
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v6, v6, v12
	.loc	1 239 61 is_stmt 0              ; norm.py:239:61
	v_cndmask_b32_e64 v6, 0, v6, s[0:1]
	.loc	1 240 12 is_stmt 1              ; norm.py:240:12
	v_fmac_f32_e32 v7, v6, v6
.Ltmp6:
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	s_barrier
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:242:17 ]
	s_nop 0
	v_add_f32_dpp v6, v7, v7 row_shr:8 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:4 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:2 row_mask:0xf bank_mask:0xf bound_ctrl:1
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_shr:1 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	v_mov_b32_e32 v7, v6
	s_nop 1
	v_mov_b32_dpp v7, v7 row_bcast:15 row_mask:0xa bank_mask:0xf bound_ctrl:1
	.loc	2 261 15                        ; standard.py:261:15 @[ norm.py:242:17 ]
	v_add_f32_e32 v6, v7, v6
	s_nop 1
	v_add_f32_dpp v6, v6, v6 row_bcast:31 row_mask:0xf bank_mask:0xf bound_ctrl:1
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	s_nop 0
	v_readlane_b32 s35, v6, 63
	s_and_saveexec_b64 s[30:31], s[20:21]
; %bb.23:
	s_nop 0
	v_mov_b32_e32 v6, s35
	ds_write_b32 v11, v6
; %bb.24:
	.loc	2 0 36 is_stmt 0                ; standard.py:0:36
	s_or_b64 exec, exec, s[30:31]
	v_mov_b32_e32 v6, 0
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	s_waitcnt lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[20:21], s[22:23]
; %bb.25:
	ds_read_b32 v6, v1
; %bb.26:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[20:21]
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v7, v6
	s_nop 1
	v_mov_b32_dpp v7, v7 quad_perm:[1,0,3,2] row_mask:0xf bank_mask:0xf
	s_and_saveexec_b64 s[20:21], s[6:7]
; %bb.27:
	.loc	2 0 36                          ; standard.py:0:36
	v_add_f32_e32 v6, v6, v7
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	ds_write_b32 v1, v6
; %bb.28:
	.loc	2 0 36                          ; standard.py:0:36
	s_or_b64 exec, exec, s[20:21]
	.loc	2 291 36                        ; standard.py:291:36 @[ norm.py:242:17 ]
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b32 v6, v1
.Ltmp7:
	.loc	1 242 33 is_stmt 1              ; norm.py:242:33
	s_waitcnt lgkmcnt(0)
	v_div_scale_f32 v7, s[20:21], v10, v10, v6
	v_rcp_f32_e32 v8, v7
	v_div_scale_f32 v9, vcc, v6, v10, v6
	v_fma_f32 v11, -v7, v8, 1.0
	v_fmac_f32_e32 v8, v11, v8
	v_mul_f32_e32 v11, v9, v8
	v_fma_f32 v13, -v7, v11, v9
	v_fmac_f32_e32 v11, v13, v8
	v_fma_f32 v7, -v7, v11, v9
	v_div_fmas_f32 v7, v7, v8, v11
	v_div_fixup_f32 v6, v7, v10, v6
	.loc	1 243 26                        ; norm.py:243:26
	v_add_f32_e32 v6, s17, v6
	.loc	1 243 20 is_stmt 0              ; norm.py:243:20
	v_rsq_f32_e32 v13, v6
	.loc	1 246 29 is_stmt 1              ; norm.py:246:29
	s_and_saveexec_b64 s[20:21], s[6:7]
	s_cbranch_execz .LBB0_30
; %bb.29:
	.loc	1 0 29 is_stmt 0                ; norm.py:0:29
	s_ashr_i32 s17, s16, 31
	s_lshl_b64 s[6:7], s[16:17], 2
	s_add_u32 s22, s24, s6
	s_addc_u32 s23, s25, s7
	s_add_u32 s6, s14, s6
	s_addc_u32 s7, s15, s7
	.loc	1 246 29                        ; norm.py:246:29
	global_store_dword v1, v12, s[6:7]
	.loc	1 247 29 is_stmt 1              ; norm.py:247:29
	global_store_dword v1, v13, s[22:23]
.LBB0_30:                               ; %.critedge
	.loc	1 0 29 is_stmt 0                ; norm.py:0:29
	s_or_b64 exec, exec, s[20:21]
	.loc	1 192 33 is_stmt 1              ; norm.py:192:33
	s_mul_i32 s6, s34, s16
	.loc	1 251 19                        ; norm.py:251:19
	s_and_b64 vcc, exec, s[18:19]
	.loc	1 192 27                        ; norm.py:192:27
	s_ashr_i32 s7, s6, 31
	.loc	1 251 19                        ; norm.py:251:19
	s_cbranch_vccnz .LBB0_35
; %bb.31:                               ; %.lr.ph9.preheader
	.loc	1 258 44                        ; norm.py:258:44
	s_max_i32 s16, s33, 1
	s_lshl_b64 s[14:15], s[6:7], 2
	s_add_u32 s14, s4, s14
	s_addc_u32 s15, s5, s15
	v_and_b32_e32 v0, 0x7f, v0
	s_add_u32 s8, s8, s28
	v_lshlrev_b32_e32 v10, 2, v0
	v_mov_b32_e32 v11, 0
	s_addc_u32 s9, s9, s29
	v_lshl_add_u64 v[0:1], s[14:15], 0, v[10:11]
	v_lshl_add_u64 v[6:7], s[12:13], 0, v[10:11]
	v_lshl_add_u64 v[8:9], s[10:11], 0, v[10:11]
	v_lshl_add_u64 v[10:11], s[8:9], 0, v[10:11]
	s_mov_b64 s[8:9], 0x200
	s_branch .LBB0_33
.LBB0_32:                               ;   in Loop: Header=BB0_33 Depth=1
	.loc	1 0 44 is_stmt 0                ; norm.py:0:44
	s_or_b64 exec, exec, s[14:15]
	.loc	1 251 19 is_stmt 1              ; norm.py:251:19
	s_add_i32 s16, s16, -1
	v_lshl_add_u64 v[0:1], v[0:1], 0, s[8:9]
	v_lshl_add_u64 v[6:7], v[6:7], 0, s[8:9]
	v_lshl_add_u64 v[8:9], v[8:9], 0, s[8:9]
	s_cmp_lg_u32 s16, 0
	v_lshl_add_u64 v[10:11], v[10:11], 0, s[8:9]
	s_cbranch_scc0 .LBB0_35
.LBB0_33:                               ; %.lr.ph9
                                        ; =>This Inner Loop Header: Depth=1
	.loc	1 258 44                        ; norm.py:258:44
	s_and_saveexec_b64 s[14:15], s[2:3]
	s_cbranch_execz .LBB0_32
; %bb.34:                               ;   in Loop: Header=BB0_33 Depth=1
	.loc	1 255 26                        ; norm.py:255:26
	global_load_dword v14, v[10:11], off
	.loc	1 253 26                        ; norm.py:253:26
	global_load_dword v15, v[8:9], off
	.loc	1 254 26                        ; norm.py:254:26
	global_load_dword v16, v[6:7], off
	.loc	1 256 29                        ; norm.py:256:29
	s_waitcnt vmcnt(2)
	v_sub_f32_e32 v14, v14, v12
	.loc	1 256 37 is_stmt 0              ; norm.py:256:37
	v_mul_f32_e32 v14, v13, v14
	.loc	1 257 38 is_stmt 1              ; norm.py:257:38
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v16, v15, v14
	.loc	1 258 44                        ; norm.py:258:44
	global_store_dword v[0:1], v16, off
	s_branch .LBB0_32
.LBB0_35:                               ; %._crit_edge10
	.loc	1 0 44 is_stmt 0                ; norm.py:0:44
	v_mov_b32_e32 v0, 0
	v_mov_b32_e32 v1, 0
	.loc	1 263 22 is_stmt 1              ; norm.py:263:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_40
; %bb.36:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	.loc	1 264 22 is_stmt 1              ; norm.py:264:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_41
.LBB0_37:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v6, 0
	.loc	1 265 22 is_stmt 1              ; norm.py:265:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_42
.LBB0_38:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	s_or_b64 exec, exec, s[2:3]
	.loc	1 270 40 is_stmt 1              ; norm.py:270:40
	s_and_saveexec_b64 s[0:1], s[26:27]
	s_cbranch_execnz .LBB0_43
.LBB0_39:
	.loc	1 270 4 is_stmt 0               ; norm.py:270:4
	s_endpgm
.LBB0_40:
	.loc	1 0 4                           ; norm.py:0:4
	v_lshl_add_u64 v[6:7], v[2:3], 2, s[10:11]
	.loc	1 263 22 is_stmt 1              ; norm.py:263:22
	global_load_dword v1, v[6:7], off
	s_or_b64 exec, exec, s[2:3]
	.loc	1 264 22                        ; norm.py:264:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_37
.LBB0_41:
	.loc	1 0 22 is_stmt 0                ; norm.py:0:22
	v_lshl_add_u64 v[6:7], v[2:3], 2, s[12:13]
	.loc	1 264 22                        ; norm.py:264:22
	global_load_dword v0, v[6:7], off
	s_or_b64 exec, exec, s[2:3]
	v_mov_b32_e32 v6, 0
	.loc	1 265 22 is_stmt 1              ; norm.py:265:22
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_38
.LBB0_42:
	global_load_dword v6, v[4:5], off
	s_or_b64 exec, exec, s[2:3]
	.loc	1 270 40                        ; norm.py:270:40
	s_and_saveexec_b64 s[0:1], s[26:27]
	s_cbranch_execz .LBB0_39
.LBB0_43:
	.loc	1 192 27                        ; norm.py:192:27
	s_lshl_b64 s[0:1], s[6:7], 2
	s_add_u32 s0, s4, s0
	s_waitcnt vmcnt(0)
	v_sub_f32_e32 v4, v6, v12
	s_addc_u32 s1, s5, s1
	v_mul_f32_e32 v4, v13, v4
	v_lshl_add_u64 v[2:3], v[2:3], 2, s[0:1]
	v_fmac_f32_e32 v0, v1, v4
	.loc	1 270 40                        ; norm.py:270:40
	global_store_dword v[2:3], v0, off
	.loc	1 270 4 is_stmt 0               ; norm.py:270:4
	s_endpgm
.Ltmp8:
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _fused_add_layernorm_kernel_BLOCK_SIZE_128
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 104
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
		.amdhsa_next_free_vgpr 17
		.amdhsa_next_free_sgpr 36
		.amdhsa_accum_offset 20
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
	.size	_fused_add_layernorm_kernel_BLOCK_SIZE_128, .Lfunc_end0-_fused_add_layernorm_kernel_BLOCK_SIZE_128
	.cfi_endproc
                                        ; -- End function
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.num_vgpr, 17
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.num_agpr, 0
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.numbered_sgpr, 36
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.private_seg_size, 0
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.uses_vcc, 1
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.uses_flat_scratch, 0
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.has_dyn_sized_stack, 0
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.has_recursion, 0
	.set _fused_add_layernorm_kernel_BLOCK_SIZE_128.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 1952
; TotalNumSgprs: 42
; NumVgprs: 17
; NumAgprs: 0
; TotalNumVgprs: 17
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 5
; VGPRBlocks: 2
; NumSGPRsForWavesPerEU: 42
; NumVGPRsForWavesPerEU: 17
; AccumOffset: 20
; Occupancy: 8
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 16
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
; COMPUTE_PGM_RSRC3_GFX90A:ACCUM_OFFSET: 4
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
	.byte	0                               ; EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 ; Length of Unit
.Ldebug_info_start0:
	.short	4                               ; DWARF version number
	.long	.debug_abbrev                   ; Offset Into Abbrev. Section
	.byte	8                               ; Address Size (in bytes)
	.byte	1                               ; Abbrev [1] 0xb:0x74 DW_TAG_compile_unit
	.long	.Linfo_string0                  ; DW_AT_producer
	.short	2                               ; DW_AT_language
	.long	.Linfo_string1                  ; DW_AT_name
	.long	.Lline_table_start0             ; DW_AT_stmt_list
	.long	.Linfo_string2                  ; DW_AT_comp_dir
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.byte	2                               ; Abbrev [2] 0x2a:0x6 DW_TAG_subprogram
	.long	.Linfo_string3                  ; DW_AT_name
	.byte	1                               ; DW_AT_inline
	.byte	3                               ; Abbrev [3] 0x30:0x4e DW_TAG_subprogram
	.quad	.Lfunc_begin0                   ; DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       ; DW_AT_high_pc
	.long	42                              ; DW_AT_abstract_origin
	.byte	4                               ; Abbrev [4] 0x41:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp2                          ; DW_AT_low_pc
	.long	.Ltmp3-.Ltmp2                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	196                             ; DW_AT_call_line
	.byte	31                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x55:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp4                          ; DW_AT_low_pc
	.long	.Ltmp5-.Ltmp4                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	221                             ; DW_AT_call_line
	.byte	18                              ; DW_AT_call_column
	.byte	4                               ; Abbrev [4] 0x69:0x14 DW_TAG_inlined_subroutine
	.long	42                              ; DW_AT_abstract_origin
	.quad	.Ltmp6                          ; DW_AT_low_pc
	.long	.Ltmp7-.Ltmp6                   ; DW_AT_high_pc
	.byte	1                               ; DW_AT_call_file
	.byte	242                             ; DW_AT_call_line
	.byte	17                              ; DW_AT_call_column
	.byte	0                               ; End Of Children Mark
	.byte	0                               ; End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"triton"                        ; string offset=0
.Linfo_string1:
	.asciz	"norm.py"                       ; string offset=7
.Linfo_string2:
	.asciz	"/work/aiter/aiter/ops/triton/_triton_kernels/normalization" ; string offset=15
.Linfo_string3:
	.asciz	"_fused_add_layernorm_kernel_BLOCK_SIZE_128" ; string offset=74
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
      - .address_space:  global
        .offset:         88
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 104
    .max_flat_workgroup_size: 256
    .name:           _fused_add_layernorm_kernel_BLOCK_SIZE_128
    .private_segment_fixed_size: 0
    .sgpr_count:     42
    .sgpr_spill_count: 0
    .symbol:         _fused_add_layernorm_kernel_BLOCK_SIZE_128.kd
    .uses_dynamic_stack: false
    .vgpr_count:     17
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
