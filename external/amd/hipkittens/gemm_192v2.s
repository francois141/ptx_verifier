	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_Z8micro_tk13micro_globals
	.globl	_Z8micro_tk13micro_globals
	.p2align	8
	.type	_Z8micro_tk13micro_globals,@function
_Z8micro_tk13micro_globals:
	s_load_dwordx2 s[6:7], s[0:1], 0x90
	s_load_dwordx2 s[12:13], s[0:1], 0x0
	s_load_dwordx2 s[16:17], s[0:1], 0x20
	s_load_dwordx2 s[14:15], s[0:1], 0x30
	s_load_dwordx2 s[4:5], s[0:1], 0x50
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s6, s3
	s_add_i32 s2, s3, s2
	s_mul_i32 s3, s7, s6
	s_ashr_i32 s6, s3, 31
	s_lshr_b32 s6, s6, 23
	s_add_i32 s3, s3, s6
	s_and_b32 s3, s3, 0xfffffe00
	s_cmp_gt_i32 s2, s3
	s_cbranch_scc1 .LBB0_2
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s6, s3, 29
	s_add_i32 s6, s2, s6
	s_and_b32 s8, s6, 0x3fffff8
	s_lshr_b32 s3, s3, 23
	s_sub_i32 s8, s2, s8
	s_add_i32 s2, s2, s3
	s_ashr_i32 s3, s6, 31
	s_ashr_i32 s7, s6, 3
	s_lshr_b32 s3, s3, 26
	s_add_i32 s3, s7, s3
	s_andn2_b32 s3, s3, 63
	s_and_b32 s2, s2, 0xfffffe00
	s_lshl_b32 s6, s8, 6
	s_sub_i32 s3, s7, s3
	s_add_i32 s2, s2, s6
	s_add_i32 s2, s2, s3
.LBB0_2:
	s_mov_b64 s[6:7], src_shared_base
	s_cmp_lg_u32 0, -1
	s_cselect_b32 s6, 0, 0
	s_cselect_b32 s3, s7, 0
	s_and_b32 s8, s6, 15
	s_and_b32 s7, s6, -16
	s_add_u32 s7, s7, 16
	s_mov_b32 s9, 0
	s_addc_u32 s10, s3, 0
	s_cmp_eq_u64 s[8:9], 0
	s_cselect_b32 s28, s6, s7
	s_cselect_b32 s29, s3, s10
	s_add_u32 s3, s28, 0xc000
	s_and_b32 s6, s3, -16
	s_and_b32 s8, s3, 15
	s_add_u32 s6, s6, 16
	s_cmp_eq_u64 s[8:9], 0
	s_cselect_b32 s24, s3, s6
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 29
	s_add_i32 s3, s2, s3
	s_and_b32 s3, s3, -8
	s_sub_i32 s6, 2, s3
	s_min_i32 s6, s6, 8
	s_abs_i32 s7, s6
	v_cvt_f32_u32_e32 v1, s7
	s_sub_i32 s9, 0, s7
	s_sub_i32 s3, s2, s3
	s_xor_b32 s8, s3, s6
	v_rcp_iflag_f32_e32 v1, v1
	s_abs_i32 s3, s3
	s_ashr_i32 s8, s8, 31
	v_bfe_u32 v2, v0, 2, 4
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_lshrrev_b32_e32 v3, 3, v0
	v_and_or_b32 v3, v3, 48, v2
	v_lshrrev_b32_e32 v2, 1, v0
	v_readfirstlane_b32 s10, v1
	s_mul_i32 s9, s9, s10
	s_mul_hi_u32 s9, s10, s9
	s_add_i32 s10, s10, s9
	s_mul_hi_u32 s9, s3, s10
	s_mul_i32 s10, s9, s7
	s_sub_i32 s3, s3, s10
	s_add_i32 s10, s9, 1
	s_sub_i32 s11, s3, s7
	s_cmp_ge_u32 s3, s7
	s_cselect_b32 s9, s10, s9
	s_cselect_b32 s3, s11, s3
	s_add_i32 s10, s9, 1
	s_cmp_ge_u32 s3, s7
	s_cselect_b32 s3, s10, s9
	v_lshlrev_b32_e32 v1, 4, v0
	s_xor_b32 s3, s3, s8
	v_bitop3_b32 v1, v1, v0, 32 bitop3:0x78
	s_sub_i32 s7, s3, s8
	v_lshrrev_b32_e32 v1, 1, v1
	v_and_b32_e32 v2, 32, v2
	s_mul_i32 s3, s7, s6
	v_and_or_b32 v2, v1, 24, v2
	s_sub_i32 s30, s2, s3
	v_mad_u64_u32 v[6:7], s[2:3], v3, s16, v[2:3]
	v_mad_u64_u32 v[2:3], s[2:3], v3, s4, v[2:3]
	s_lshl_b32 s31, s7, 8
	s_lshl_b32 s2, s4, 6
	s_mul_hi_i32 s7, s4, s31
	s_mul_i32 s6, s4, s31
	v_lshlrev_b32_e32 v1, 3, v0
	s_lshl_b32 s18, s16, 6
	v_add_lshl_u32 v160, v2, s2, 1
	s_bfe_i64 s[2:3], s[4:5], 0x200000
	s_lshl_b64 s[6:7], s[6:7], 1
	v_and_b32_e32 v5, 0xe00, v1
	s_add_u32 s8, s14, s6
	v_lshl_add_u32 v26, v5, 1, s24
	s_addc_u32 s9, s15, s7
	s_mov_b32 s7, 0x110000
	v_readfirstlane_b32 s3, v26
	v_add_u32_e32 v27, 0x2000, v26
	v_lshlrev_b32_e32 v161, 1, v2
	s_lshl_b32 s10, s4, 8
	s_mov_b32 s11, s7
	s_mov_b32 m0, s3
	v_readfirstlane_b32 s3, v27
	v_lshrrev_b32_e32 v4, 6, v0
	buffer_load_dwordx4 v161, s[8:11], 0 offen lds
	s_mov_b32 m0, s3
	s_mul_i32 s3, s30, 0xc0
	v_mov_b32_e32 v155, 0
	s_mul_hi_i32 s5, s16, s3
	s_mul_i32 s4, s16, s3
	v_lshlrev_b32_e32 v154, 10, v4
	s_bfe_i64 s[20:21], s[16:17], 0x200000
	s_lshl_b64 s[4:5], s[4:5], 1
	v_lshl_add_u64 v[122:123], s[28:29], 0, v[154:155]
	buffer_load_dwordx4 v160, s[8:11], 0 offen lds
	s_add_u32 s4, s12, s4
	v_readfirstlane_b32 s11, v122
	v_lshlrev_b32_e32 v158, 1, v6
	s_addc_u32 s5, s13, s5
	s_mul_i32 s6, s16, 0xc0
	s_mov_b32 m0, s11
	v_and_b32_e32 v1, 0x100, v0
	buffer_load_dwordx4 v158, s[4:7], 0 offen lds
	v_add_lshl_u32 v2, v6, s18, 1
	v_cmp_eq_u32_e32 vcc, 0, v1
	v_lshlrev_b32_e32 v1, 9, v4
	s_nop 0
	v_cndmask_b32_e32 v159, 0, v2, vcc
	v_cmp_gt_u32_e32 vcc, 4, v4
	s_and_saveexec_b64 s[16:17], vcc
	s_cbranch_execz .LBB0_4
	v_add_u32_e32 v2, 0x2000, v122
	s_nop 0
	v_readfirstlane_b32 s11, v2
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v159, s[4:7], 0 offen lds
.LBB0_4:
	s_or_b64 exec, exec, s[16:17]
	s_or_b32 s11, s31, 0x80
	s_add_u32 s33, s24, 0x4000
	s_mul_hi_i32 s17, s2, s11
	s_mul_i32 s16, s2, s11
	s_lshl_b64 s[16:17], s[16:17], 1
	v_lshl_add_u32 v123, v5, 1, s33
	s_add_u32 s16, s14, s16
	v_readfirstlane_b32 s2, v123
	v_add_u32_e32 v124, 0x2000, v123
	s_addc_u32 s17, s15, s17
	s_mov_b32 s18, s10
	s_mov_b32 s19, s7
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v124
	buffer_load_dwordx4 v161, s[16:19], 0 offen lds
	s_mov_b32 m0, s2
	v_lshlrev_b32_e32 v154, 1, v1
	buffer_load_dwordx4 v160, s[16:19], 0 offen lds
	s_add_u32 s18, s28, 0x3000
	s_addc_u32 s19, s29, 0
	s_add_i32 s2, s3, 0x60
	s_mul_hi_i32 s3, s20, s2
	s_mul_i32 s2, s20, s2
	s_lshl_b64 s[2:3], s[2:3], 1
	v_lshl_add_u64 v[2:3], s[18:19], 0, v[154:155]
	s_add_u32 s12, s12, s2
	v_readfirstlane_b32 s2, v2
	s_addc_u32 s13, s13, s3
	s_mov_b32 s14, s6
	s_mov_b32 s15, s7
	s_mov_b32 m0, s2
	s_nop 0
	buffer_load_dwordx4 v158, s[12:15], 0 offen lds
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_6
	v_add_u32_e32 v1, 0x2000, v2
	s_nop 0
	v_readfirstlane_b32 s7, v1
	s_mov_b32 m0, s7
	s_nop 0
	buffer_load_dwordx4 v159, s[12:15], 0 offen lds
.LBB0_6:
	s_or_b64 exec, exec, s[2:3]
	v_lshrrev_b32_e32 v1, 8, v0
	v_cmp_eq_u32_e64 s[2:3], 1, v1
	s_and_saveexec_b64 s[14:15], s[2:3]
	s_cbranch_execz .LBB0_8
	s_barrier
.LBB0_8:
	s_or_b64 exec, exec, s[14:15]
	s_add_u32 s11, s24, 0x8000
	v_lshl_add_u32 v169, v5, 1, s11
	s_add_u32 s20, s8, 0x80
	v_readfirstlane_b32 s2, v169
	v_add_u32_e32 v170, 0x2000, v169
	s_addc_u32 s21, s9, 0
	s_mov_b32 s23, 0x110000
	s_mov_b32 s22, s10
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v170
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	buffer_load_dwordx4 v161, s[20:23], 0 offen lds
	s_mov_b32 m0, s2
	s_add_u32 s2, s28, 0x6000
	s_addc_u32 s3, s29, 0
	v_mov_b32_e32 v155, 0
	v_lshl_add_u64 v[156:157], s[2:3], 0, v[154:155]
	buffer_load_dwordx4 v160, s[20:23], 0 offen lds
	s_add_u32 s20, s4, 0x80
	v_readfirstlane_b32 s3, v156
	s_addc_u32 s21, s5, 0
	s_mov_b32 s22, s6
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v158, s[20:23], 0 offen lds
	s_and_saveexec_b64 s[14:15], vcc
	s_cbranch_execz .LBB0_10
	v_add_u32_e32 v2, 0x2000, v156
	s_nop 0
	v_readfirstlane_b32 s3, v2
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v159, s[20:23], 0 offen lds
.LBB0_10:
	s_or_b64 exec, exec, s[14:15]
	s_add_u32 s7, s24, 0xc000
	v_lshl_add_u32 v165, v5, 1, s7
	v_and_b32_e32 v157, 3, v4
	s_add_u32 s20, s16, 0x80
	v_readfirstlane_b32 s3, v165
	v_add_u32_e32 v166, 0x2000, v165
	v_lshlrev_b32_e32 v3, 6, v0
	v_lshlrev_b32_e32 v4, 2, v0
	s_addc_u32 s21, s17, 0
	s_mov_b32 s22, s10
	s_mov_b32 m0, s3
	v_readfirstlane_b32 s3, v166
	v_and_b32_e32 v2, 48, v0
	v_and_b32_e32 v3, 0x3c0, v3
	v_and_b32_e32 v4, 32, v4
	buffer_load_dwordx4 v161, s[20:23], 0 offen lds
	s_mov_b32 m0, s3
	v_bitop3_b32 v172, v3, v4, v2 bitop3:0x36
	v_lshlrev_b32_e32 v3, 12, v157
	buffer_load_dwordx4 v160, s[20:23], 0 offen lds
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	v_add3_u32 v164, s24, v3, v172
	;;#ASMSTART
	ds_read_b128 v[78:81], v164 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[66:69], v164 offset:0x400

	;;#ASMEND
	v_mul_u32_u24_e32 v2, 0xc00, v1
	;;#ASMSTART
	ds_read_b128 v[74:77], v164 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[70:73], v164 offset:0xc00

	;;#ASMEND
	v_lshlrev_b32_e32 v173, 1, v2
	v_add3_u32 v155, s28, v173, v172
	;;#ASMSTART
	ds_read_b128 v[34:37], v155 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[30:33], v155 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[42:45], v155 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[38:41], v155 offset:0xc00

	;;#ASMEND
	v_add_u32_e32 v2, 0x9000, v122
	;;#ASMSTART
	ds_read_b128 v[50:53], v155 offset:0x1000

	;;#ASMEND
	s_add_u32 s20, s12, 0x80
	v_readfirstlane_b32 s3, v2
	;;#ASMSTART
	ds_read_b128 v[46:49], v155 offset:0x1400

	;;#ASMEND
	s_addc_u32 s21, s13, 0
	s_mov_b32 s22, s6
	s_mov_b32 m0, s3
	v_lshlrev_b32_e32 v28, 11, v157
	buffer_load_dwordx4 v158, s[20:23], 0 offen lds
	s_mov_b32 s24, 0
	s_and_saveexec_b64 s[14:15], vcc
	s_cbranch_execz .LBB0_12
	v_add_u32_e32 v2, 0xb000, v122
	s_nop 0
	v_readfirstlane_b32 s3, v2
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v159, s[20:23], 0 offen lds
.LBB0_12:
	s_or_b64 exec, exec, s[14:15]
	;;#ASMSTART
	s_waitcnt lgkmcnt(8)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_mov_b32 s26, s24
	s_mov_b32 s27, s24
	s_mov_b32 s25, s24
	v_mov_b64_e32 v[56:57], s[26:27]
	v_mov_b64_e32 v[54:55], s[24:25]
	s_nop 1
	v_mfma_f32_16x16x32_bf16 v[2:5], v[34:37], v[78:81], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[34:37], v[74:77], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[42:45], v[78:81], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[42:45], v[74:77], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[50:53], v[78:81], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[50:53], v[74:77], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[30:33], v[66:69], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[30:33], v[70:73], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[38:41], v[66:69], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[38:41], v[70:73], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[46:49], v[66:69], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[46:49], v[70:73], v[22:25]
	s_setprio 0
	s_barrier
	v_lshlrev_b32_e32 v125, 1, v28
	v_add3_u32 v162, s33, v125, v172
	;;#ASMSTART
	ds_read_b128 v[90:93], v162 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[94:97], v162 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[98:101], v162 offset:0x800

	;;#ASMEND
	s_add_u32 s20, s8, 0x100
	v_readfirstlane_b32 s3, v26
	;;#ASMSTART
	ds_read_b128 v[102:105], v162 offset:0xc00

	;;#ASMEND
	s_addc_u32 s21, s9, 0
	s_mov_b32 s22, s10
	s_mov_b32 m0, s3
	v_readfirstlane_b32 s3, v27
	buffer_load_dwordx4 v161, s[20:23], 0 offen lds
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v160, s[20:23], 0 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[26:29], v[34:37], v[90:93], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[34:37], v[98:101], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[30:33], v[94:97], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[30:33], v[102:105], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[42:45], v[90:93], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[42:45], v[98:101], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[38:41], v[94:97], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[38:41], v[102:105], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[50:53], v[90:93], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[50:53], v[98:101], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[46:49], v[94:97], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[46:49], v[102:105], v[50:53]
	s_setprio 0
	s_barrier
	v_add3_u32 v163, s18, v173, v172
	;;#ASMSTART
	ds_read_b128 v[118:121], v163 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[82:85], v163 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[114:117], v163 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[86:89], v163 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[110:113], v163 offset:0x1000

	;;#ASMEND
	s_add_u32 s20, s4, 0x100
	v_readfirstlane_b32 s3, v122
	;;#ASMSTART
	ds_read_b128 v[106:109], v163 offset:0x1400

	;;#ASMEND
	s_addc_u32 s21, s5, 0
	s_mov_b32 s22, s6
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v158, s[20:23], 0 offen lds
	s_and_saveexec_b64 s[14:15], vcc
	s_cbranch_execz .LBB0_14
	v_add_u32_e32 v50, 0x2000, v122
	s_nop 0
	v_readfirstlane_b32 s3, v50
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v159, s[20:23], 0 offen lds
.LBB0_14:
	s_or_b64 exec, exec, s[14:15]
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_mov_b32 s26, s24
	s_mov_b32 s27, s24
	s_mov_b32 s25, s24
	v_mov_b64_e32 v[128:129], s[26:27]
	v_mov_b64_e32 v[126:127], s[24:25]
	s_nop 1
	v_mfma_f32_16x16x32_bf16 v[50:53], v[118:121], v[78:81], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[118:121], v[74:77], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[114:117], v[78:81], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[114:117], v[74:77], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[110:113], v[78:81], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[110:113], v[74:77], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[82:85], v[66:69], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[82:85], v[70:73], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[86:89], v[66:69], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[86:89], v[70:73], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[106:109], v[66:69], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[106:109], v[70:73], v[74:77]
	s_setprio 0
	s_barrier
	s_add_u32 s20, s16, 0x100
	v_readfirstlane_b32 s3, v123
	s_addc_u32 s21, s17, 0
	s_mov_b32 s22, s10
	s_mov_b32 m0, s3
	v_readfirstlane_b32 s3, v124
	buffer_load_dwordx4 v161, s[20:23], 0 offen lds
	s_mov_b32 m0, s3
	s_nop 0
	buffer_load_dwordx4 v160, s[20:23], 0 offen lds
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[74:77], v[118:121], v[90:93], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[118:121], v[98:101], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[82:85], v[94:97], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[82:85], v[102:105], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[114:117], v[90:93], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[110:113], v[90:93], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[86:89], v[94:97], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[114:117], v[98:101], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[106:109], v[94:97], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[110:113], v[98:101], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[86:89], v[102:105], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[106:109], v[102:105], v[94:97]
	s_setprio 0
	s_barrier
	v_add3_u32 v168, s11, v125, v172
	;;#ASMSTART
	ds_read_b128 v[110:113], v168 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[106:109], v168 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[102:105], v168 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[98:101], v168 offset:0xc00

	;;#ASMEND
	v_add3_u32 v167, s2, v173, v172
	;;#ASMSTART
	ds_read_b128 v[150:153], v167 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v167 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v167 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[138:141], v167 offset:0xc00

	;;#ASMEND
	v_add_u32_e32 v114, 0x3000, v122
	;;#ASMSTART
	ds_read_b128 v[134:137], v167 offset:0x1000

	;;#ASMEND
	s_add_u32 s20, s12, 0x100
	v_readfirstlane_b32 s2, v114
	;;#ASMSTART
	ds_read_b128 v[130:133], v167 offset:0x1400

	;;#ASMEND
	s_addc_u32 s21, s13, 0
	s_mov_b32 s22, s6
	s_mov_b32 m0, s2
	s_nop 0
	buffer_load_dwordx4 v158, s[20:23], 0 offen lds
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_16
	v_add_u32_e32 v114, 0x5000, v122
	s_nop 0
	v_readfirstlane_b32 s11, v114
	s_mov_b32 m0, s11
	s_nop 0
	buffer_load_dwordx4 v159, s[20:23], 0 offen lds
.LBB0_16:
	s_or_b64 exec, exec, s[2:3]
	;;#ASMSTART
	s_waitcnt lgkmcnt(8)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[2:5], v[150:153], v[110:113], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[150:153], v[102:105], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[142:145], v[110:113], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[142:145], v[102:105], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[134:137], v[110:113], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[134:137], v[102:105], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[146:149], v[106:109], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[146:149], v[98:101], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[138:141], v[106:109], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[138:141], v[98:101], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[130:133], v[106:109], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[130:133], v[98:101], v[22:25]
	s_setprio 0
	s_barrier
	v_add3_u32 v171, s7, v125, v172
	;;#ASMSTART
	ds_read_b128 v[114:117], v171 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[118:121], v171 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[122:125], v171 offset:0x800

	;;#ASMEND
	s_add_u32 s8, s8, 0x180
	s_mov_b32 s7, 0x110000
	v_readfirstlane_b32 s2, v169
	;;#ASMSTART
	ds_read_b128 v[126:129], v171 offset:0xc00

	;;#ASMEND
	s_addc_u32 s9, s9, 0
	s_mov_b32 s11, s7
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v170
	buffer_load_dwordx4 v161, s[8:11], 0 offen lds
	s_mov_b32 m0, s2
	s_nop 0
	buffer_load_dwordx4 v160, s[8:11], 0 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[26:29], v[150:153], v[114:117], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[150:153], v[122:125], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[142:145], v[114:117], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[142:145], v[122:125], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[134:137], v[114:117], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[134:137], v[122:125], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[146:149], v[118:121], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[146:149], v[126:129], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[138:141], v[118:121], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[138:141], v[126:129], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[130:133], v[118:121], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[130:133], v[126:129], v[46:49]
	s_setprio 0
	s_add_u32 s14, s28, 0x9000
	s_barrier
	v_add3_u32 v169, s14, v173, v172
	;;#ASMSTART
	ds_read_b128 v[150:153], v169 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v169 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v169 offset:0x800

	;;#ASMEND
	s_addc_u32 s15, s29, 0
	;;#ASMSTART
	ds_read_b128 v[138:141], v169 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[134:137], v169 offset:0x1000

	;;#ASMEND
	s_add_u32 s4, s4, 0x180
	v_readfirstlane_b32 s2, v156
	;;#ASMSTART
	ds_read_b128 v[130:133], v169 offset:0x1400

	;;#ASMEND
	s_addc_u32 s5, s5, 0
	s_mov_b32 m0, s2
	s_nop 0
	buffer_load_dwordx4 v158, s[4:7], 0 offen lds
	s_and_saveexec_b64 s[2:3], vcc
	s_cbranch_execz .LBB0_18
	v_add_u32_e32 v156, 0x2000, v156
	s_nop 0
	v_readfirstlane_b32 s8, v156
	s_mov_b32 m0, s8
	s_nop 0
	buffer_load_dwordx4 v159, s[4:7], 0 offen lds
.LBB0_18:
	s_or_b64 exec, exec, s[2:3]
	s_load_dwordx2 s[2:3], s[0:1], 0x60
	s_load_dwordx2 s[0:1], s[0:1], 0x80
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[50:53], v[150:153], v[110:113], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[150:153], v[102:105], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[142:145], v[110:113], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[142:145], v[102:105], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[134:137], v[110:113], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[134:137], v[102:105], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[146:149], v[106:109], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[146:149], v[98:101], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[138:141], v[106:109], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[138:141], v[98:101], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[130:133], v[106:109], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[130:133], v[98:101], v[70:73]
	s_setprio 0
	s_barrier
	s_add_u32 s8, s16, 0x180
	s_waitcnt lgkmcnt(0)
	v_readfirstlane_b32 s1, v165
	s_addc_u32 s9, s17, 0
	s_mov_b32 s11, s7
	s_mov_b32 m0, s1
	v_readfirstlane_b32 s1, v166
	buffer_load_dwordx4 v161, s[8:11], 0 offen lds
	s_mov_b32 m0, s1
	s_nop 0
	buffer_load_dwordx4 v160, s[8:11], 0 offen lds
	;;#ASMSTART
	s_waitcnt vmcnt(6)
	;;#ASMEND
	s_barrier
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[74:77], v[150:153], v[114:117], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[150:153], v[122:125], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[142:145], v[114:117], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[142:145], v[122:125], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[134:137], v[114:117], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[134:137], v[122:125], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[146:149], v[118:121], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[146:149], v[126:129], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[138:141], v[118:121], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[138:141], v[126:129], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[130:133], v[118:121], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[130:133], v[126:129], v[94:97]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[98:101], v164 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[102:105], v164 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[106:109], v164 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[110:113], v164 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[114:117], v155 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[118:121], v155 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[122:125], v155 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[126:129], v155 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[130:133], v155 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[134:137], v155 offset:0x1400

	;;#ASMEND
	v_mov_b32_e32 v155, 0
	v_lshl_add_u64 v[138:139], s[14:15], 0, v[154:155]
	s_add_u32 s4, s12, 0x180
	v_readfirstlane_b32 s1, v138
	s_addc_u32 s5, s13, 0
	s_mov_b32 m0, s1
	s_nop 0
	buffer_load_dwordx4 v158, s[4:7], 0 offen lds
	s_and_saveexec_b64 s[8:9], vcc
	s_xor_b64 s[8:9], exec, s[8:9]
	s_cbranch_execz .LBB0_20
	v_add_u32_e32 v138, 0x2000, v138
	s_nop 0
	v_readfirstlane_b32 s1, v138
	s_mov_b32 m0, s1
	s_nop 0
	buffer_load_dwordx4 v159, s[4:7], 0 offen lds
.LBB0_20:
	s_or_b64 exec, exec, s[8:9]
	v_lshrrev_b32_e32 v138, 2, v0
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[2:5], v[114:117], v[98:101], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[114:117], v[106:109], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[122:125], v[98:101], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[122:125], v[106:109], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[130:133], v[98:101], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[130:133], v[106:109], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[118:121], v[102:105], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[118:121], v[110:113], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[126:129], v[102:105], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[126:129], v[110:113], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[134:137], v[102:105], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[134:137], v[110:113], v[22:25]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[140:143], v162 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[144:147], v162 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[148:151], v162 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v162 offset:0xc00

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[26:29], v[114:117], v[140:143], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[114:117], v[148:151], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[122:125], v[140:143], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[122:125], v[148:151], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[130:133], v[140:143], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[130:133], v[148:151], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[118:121], v[144:147], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[118:121], v[152:155], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[126:129], v[144:147], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[126:129], v[152:155], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[134:137], v[144:147], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[134:137], v[152:155], v[46:49]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[114:117], v163 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[118:121], v163 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[122:125], v163 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[126:129], v163 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[130:133], v163 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[134:137], v163 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(4)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_16x16x32_bf16 v[54:57], v[114:117], v[106:109], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[158:161], v[118:121], v[110:113], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[122:125], v[98:101], v[58:61]
	v_mfma_f32_16x16x32_bf16 v[162:165], v[126:129], v[102:105], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[122:125], v[106:109], v[62:65]
	v_mfma_f32_16x16x32_bf16 v[172:175], v[126:129], v[110:113], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[130:133], v[98:101], v[66:69]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[114:117], v[98:101], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[98:101], v[134:137], v[102:105], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[130:133], v[106:109], v[70:73]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[118:121], v[102:105], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[102:105], v[134:137], v[110:113], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[114:117], v[140:143], v[74:77]
	v_mfma_f32_16x16x32_bf16 v[106:109], v[118:121], v[144:147], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[114:117], v[148:151], v[78:81]
	v_mfma_f32_16x16x32_bf16 v[110:113], v[118:121], v[152:155], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[122:125], v[140:143], v[82:85]
	v_mfma_f32_16x16x32_bf16 v[114:117], v[126:129], v[144:147], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[122:125], v[148:151], v[86:89]
	v_mfma_f32_16x16x32_bf16 v[118:121], v[126:129], v[152:155], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[130:133], v[140:143], v[90:93]
	v_mfma_f32_16x16x32_bf16 v[122:125], v[134:137], v[144:147], v[54:57]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[130:133], v[148:151], v[94:97]
	v_mfma_f32_16x16x32_bf16 v[126:129], v[134:137], v[152:155], v[54:57]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[130:133], v168 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[134:137], v168 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[140:143], v168 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[144:147], v168 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[54:57], v167 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[58:61], v167 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[148:151], v167 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v167 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[176:179], v167 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[180:183], v167 offset:0x1400

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(2)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_nop 2
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[130:133], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[94:97], v[58:61], v[134:137], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[54:57], v[140:143], v[6:9]
	v_mfma_f32_16x16x32_bf16 v[90:93], v[58:61], v[144:147], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[148:151], v[130:133], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[86:89], v[152:155], v[134:137], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[148:151], v[140:143], v[14:17]
	v_mfma_f32_16x16x32_bf16 v[82:85], v[152:155], v[144:147], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[176:179], v[130:133], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[66:69], v[180:183], v[134:137], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[176:179], v[140:143], v[22:25]
	v_mfma_f32_16x16x32_bf16 v[62:65], v[180:183], v[144:147], v[2:5]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[2:5], v171 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[6:9], v171 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[184:187], v171 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[188:191], v171 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	s_waitcnt vmcnt(0)
	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_nop 2
	v_mfma_f32_16x16x32_bf16 v[10:13], v[54:57], v[2:5], v[26:29]
	v_mfma_f32_16x16x32_bf16 v[78:81], v[58:61], v[6:9], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[54:57], v[184:187], v[30:33]
	v_mfma_f32_16x16x32_bf16 v[74:77], v[58:61], v[188:191], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[148:151], v[2:5], v[34:37]
	v_mfma_f32_16x16x32_bf16 v[70:73], v[152:155], v[6:9], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[148:151], v[184:187], v[38:41]
	v_mfma_f32_16x16x32_bf16 v[58:61], v[152:155], v[188:191], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[176:179], v[2:5], v[42:45]
	v_mfma_f32_16x16x32_bf16 v[54:57], v[180:183], v[6:9], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[176:179], v[184:187], v[46:49]
	v_mfma_f32_16x16x32_bf16 v[42:45], v[180:183], v[188:191], v[10:13]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[10:13], v169 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[14:17], v169 offset:0x400

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[148:151], v169 offset:0x800

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v169 offset:0xc00

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[176:179], v169 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v169 offset:0x1400

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_nop 2
	v_mfma_f32_16x16x32_bf16 v[18:21], v[10:13], v[130:133], v[50:53]
	v_mfma_f32_16x16x32_bf16 v[50:53], v[14:17], v[134:137], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[10:13], v[140:143], v[158:161]
	v_mfma_f32_16x16x32_bf16 v[46:49], v[14:17], v[144:147], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[148:151], v[130:133], v[162:165]
	v_mfma_f32_16x16x32_bf16 v[38:41], v[152:155], v[134:137], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[148:151], v[140:143], v[172:175]
	v_mfma_f32_16x16x32_bf16 v[34:37], v[152:155], v[144:147], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[176:179], v[130:133], v[98:101]
	v_mfma_f32_16x16x32_bf16 v[30:33], v[166:169], v[134:137], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[176:179], v[140:143], v[102:105]
	v_mfma_f32_16x16x32_bf16 v[26:29], v[166:169], v[144:147], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[10:13], v[2:5], v[106:109]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[10:13], v[184:187], v[110:113]
	v_mfma_f32_16x16x32_bf16 v[22:25], v[14:17], v[6:9], v[18:21]
	v_mfma_f32_16x16x32_bf16 v[18:21], v[14:17], v[188:191], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[148:151], v[2:5], v[114:117]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[176:179], v[2:5], v[122:125]
	v_mfma_f32_16x16x32_bf16 v[14:17], v[152:155], v[6:9], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[148:151], v[184:187], v[118:121]
	v_mfma_f32_16x16x32_bf16 v[6:9], v[166:169], v[6:9], v[2:5]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[176:179], v[184:187], v[126:129]
	v_mfma_f32_16x16x32_bf16 v[10:13], v[152:155], v[188:191], v[10:13]
	v_mfma_f32_16x16x32_bf16 v[2:5], v[166:169], v[188:191], v[2:5]
	s_setprio 0
	s_movk_i32 s1, 0x100
	v_cmp_gt_u32_e32 vcc, s1, v0
	s_barrier
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_22
	s_barrier
.LBB0_22:
	s_or_b64 exec, exec, s[4:5]
	v_lshl_or_b32 v130, s30, 2, v1
	v_mul_lo_u32 v1, v130, 48
	v_mad_i64_i32 v[100:101], s[4:5], s0, v1, 0
	v_and_b32_e32 v1, 12, v138
	v_and_b32_e32 v0, 15, v0
	v_mad_u64_u32 v[0:1], s[4:5], v1, s0, v[0:1]
	v_lshl_or_b32 v98, v157, 5, s31
	v_ashrrev_i32_e32 v1, 31, v0
	v_ashrrev_i32_e32 v99, 31, v98
	v_lshlrev_b64 v[102:103], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[100:101], v[100:101], 1, s[2:3]
	v_lshlrev_b64 v[98:99], 1, v[98:99]
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[100:101], v[100:101], 0, v[98:99]
	v_lshlrev_b64 v[106:107], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[104:105], v[100:101], 0, v[102:103]
	v_lshl_add_u64 v[108:109], v[100:101], 0, v[106:107]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[104:105], v94, off
	global_store_short_d16_hi v[108:109], v95, off
	v_lshlrev_b64 v[94:95], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	s_mul_i32 s1, s0, 13
	v_lshlrev_b64 v[112:113], 1, v[0:1]
	v_add_u32_e32 v0, s1, v0
	v_lshl_add_u64 v[110:111], v[100:101], 0, v[94:95]
	v_lshl_add_u64 v[114:115], v[100:101], 0, v[112:113]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[110:111], v96, off
	global_store_short_d16_hi v[114:115], v97, off
	global_store_short_d16_hi v[104:105], v90, off offset:32
	global_store_short_d16_hi v[108:109], v91, off offset:32
	global_store_short_d16_hi v[110:111], v92, off offset:32
	global_store_short_d16_hi v[114:115], v93, off offset:32
	v_lshlrev_b64 v[90:91], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[96:97], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[92:93], v[100:101], 0, v[90:91]
	v_lshl_add_u64 v[116:117], v[100:101], 0, v[96:97]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[92:93], v86, off
	global_store_short_d16_hi v[116:117], v87, off
	v_lshlrev_b64 v[86:87], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[120:121], 1, v[0:1]
	v_add_u32_e32 v0, s1, v0
	v_lshl_add_u64 v[118:119], v[100:101], 0, v[86:87]
	v_lshl_add_u64 v[122:123], v[100:101], 0, v[120:121]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[118:119], v88, off
	global_store_short_d16_hi v[122:123], v89, off
	global_store_short_d16_hi v[92:93], v82, off offset:32
	global_store_short_d16_hi v[116:117], v83, off offset:32
	global_store_short_d16_hi v[118:119], v84, off offset:32
	global_store_short_d16_hi v[122:123], v85, off offset:32
	v_lshlrev_b64 v[82:83], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[88:89], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_lshl_add_u64 v[84:85], v[100:101], 0, v[82:83]
	v_lshl_add_u64 v[124:125], v[100:101], 0, v[88:89]
	v_ashrrev_i32_e32 v1, 31, v0
	global_store_short_d16_hi v[84:85], v66, off
	global_store_short_d16_hi v[124:125], v67, off
	v_lshlrev_b64 v[66:67], 1, v[0:1]
	v_add_u32_e32 v0, s0, v0
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 1, v[0:1]
	v_lshl_add_u64 v[126:127], v[100:101], 0, v[66:67]
	v_lshl_add_u64 v[128:129], v[100:101], 0, v[0:1]
	s_mov_b64 s[4:5], 0x100
	global_store_short_d16_hi v[126:127], v68, off
	global_store_short_d16_hi v[128:129], v69, off
	global_store_short_d16_hi v[84:85], v62, off offset:32
	global_store_short_d16_hi v[124:125], v63, off offset:32
	global_store_short_d16_hi v[126:127], v64, off offset:32
	global_store_short_d16_hi v[128:129], v65, off offset:32
	v_lshl_add_u64 v[62:63], v[100:101], 0, s[4:5]
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[102:103]
	global_store_short_d16_hi v[104:105], v78, off offset:256
	global_store_short_d16_hi v[108:109], v79, off offset:256
	global_store_short_d16_hi v[110:111], v80, off offset:256
	global_store_short_d16_hi v[114:115], v81, off offset:256
	global_store_short_d16_hi v[64:65], v74, off offset:32
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[106:107]
	global_store_short_d16_hi v[64:65], v75, off offset:32
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[94:95]
	global_store_short_d16_hi v[64:65], v76, off offset:32
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[112:113]
	global_store_short_d16_hi v[64:65], v77, off offset:32
	global_store_short_d16_hi v[92:93], v70, off offset:256
	global_store_short_d16_hi v[116:117], v71, off offset:256
	global_store_short_d16_hi v[118:119], v72, off offset:256
	global_store_short_d16_hi v[122:123], v73, off offset:256
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[90:91]
	global_store_short_d16_hi v[64:65], v58, off offset:32
	v_lshl_add_u64 v[64:65], v[62:63], 0, v[96:97]
	global_store_short_d16_hi v[64:65], v59, off offset:32
	v_lshl_add_u64 v[58:59], v[62:63], 0, v[86:87]
	global_store_short_d16_hi v[58:59], v60, off offset:32
	v_lshl_add_u64 v[58:59], v[62:63], 0, v[120:121]
	global_store_short_d16_hi v[58:59], v61, off offset:32
	global_store_short_d16_hi v[84:85], v54, off offset:256
	global_store_short_d16_hi v[124:125], v55, off offset:256
	global_store_short_d16_hi v[126:127], v56, off offset:256
	global_store_short_d16_hi v[128:129], v57, off offset:256
	v_lshl_add_u64 v[54:55], v[62:63], 0, v[82:83]
	global_store_short_d16_hi v[54:55], v42, off offset:32
	v_lshl_add_u64 v[54:55], v[62:63], 0, v[88:89]
	global_store_short_d16_hi v[54:55], v43, off offset:32
	v_lshl_add_u64 v[42:43], v[62:63], 0, v[66:67]
	global_store_short_d16_hi v[42:43], v44, off offset:32
	v_lshl_add_u64 v[42:43], v[62:63], 0, v[0:1]
	global_store_short_d16_hi v[42:43], v45, off offset:32
	v_or_b32_e32 v42, 2, v130
	v_mul_lo_u32 v42, v42, 48
	v_mad_i64_i32 v[42:43], s[0:1], s0, v42, 0
	v_lshl_add_u64 v[42:43], v[42:43], 1, s[2:3]
	v_lshl_add_u64 v[42:43], v[42:43], 0, v[98:99]
	v_lshl_add_u64 v[44:45], v[42:43], 0, v[102:103]
	v_lshl_add_u64 v[54:55], v[42:43], 0, v[106:107]
	global_store_short_d16_hi v[44:45], v50, off
	global_store_short_d16_hi v[54:55], v51, off
	v_lshl_add_u64 v[50:51], v[42:43], 0, v[94:95]
	v_lshl_add_u64 v[56:57], v[42:43], 0, v[112:113]
	global_store_short_d16_hi v[50:51], v52, off
	global_store_short_d16_hi v[56:57], v53, off
	global_store_short_d16_hi v[44:45], v46, off offset:32
	global_store_short_d16_hi v[54:55], v47, off offset:32
	global_store_short_d16_hi v[50:51], v48, off offset:32
	global_store_short_d16_hi v[56:57], v49, off offset:32
	v_lshl_add_u64 v[46:47], v[42:43], 0, v[90:91]
	v_lshl_add_u64 v[48:49], v[42:43], 0, v[96:97]
	global_store_short_d16_hi v[46:47], v38, off
	global_store_short_d16_hi v[48:49], v39, off
	v_lshl_add_u64 v[38:39], v[42:43], 0, v[86:87]
	v_lshl_add_u64 v[52:53], v[42:43], 0, v[120:121]
	global_store_short_d16_hi v[38:39], v40, off
	global_store_short_d16_hi v[52:53], v41, off
	global_store_short_d16_hi v[46:47], v34, off offset:32
	global_store_short_d16_hi v[48:49], v35, off offset:32
	global_store_short_d16_hi v[38:39], v36, off offset:32
	global_store_short_d16_hi v[52:53], v37, off offset:32
	v_lshl_add_u64 v[34:35], v[42:43], 0, v[82:83]
	v_lshl_add_u64 v[36:37], v[42:43], 0, v[88:89]
	global_store_short_d16_hi v[34:35], v30, off
	global_store_short_d16_hi v[36:37], v31, off
	v_lshl_add_u64 v[30:31], v[42:43], 0, v[66:67]
	v_lshl_add_u64 v[40:41], v[42:43], 0, v[0:1]
	global_store_short_d16_hi v[30:31], v32, off
	global_store_short_d16_hi v[40:41], v33, off
	global_store_short_d16_hi v[34:35], v26, off offset:32
	global_store_short_d16_hi v[36:37], v27, off offset:32
	global_store_short_d16_hi v[30:31], v28, off offset:32
	global_store_short_d16_hi v[40:41], v29, off offset:32
	v_lshl_add_u64 v[26:27], v[42:43], 0, s[4:5]
	global_store_short_d16_hi v[44:45], v22, off offset:256
	global_store_short_d16_hi v[54:55], v23, off offset:256
	global_store_short_d16_hi v[50:51], v24, off offset:256
	global_store_short_d16_hi v[56:57], v25, off offset:256
	v_lshl_add_u64 v[22:23], v[26:27], 0, v[102:103]
	global_store_short_d16_hi v[22:23], v18, off offset:32
	v_lshl_add_u64 v[22:23], v[26:27], 0, v[106:107]
	global_store_short_d16_hi v[22:23], v19, off offset:32
	v_lshl_add_u64 v[18:19], v[26:27], 0, v[94:95]
	global_store_short_d16_hi v[18:19], v20, off offset:32
	v_lshl_add_u64 v[18:19], v[26:27], 0, v[112:113]
	global_store_short_d16_hi v[18:19], v21, off offset:32
	global_store_short_d16_hi v[46:47], v14, off offset:256
	global_store_short_d16_hi v[48:49], v15, off offset:256
	global_store_short_d16_hi v[38:39], v16, off offset:256
	global_store_short_d16_hi v[52:53], v17, off offset:256
	v_lshl_add_u64 v[14:15], v[26:27], 0, v[90:91]
	global_store_short_d16_hi v[14:15], v10, off offset:32
	v_lshl_add_u64 v[14:15], v[26:27], 0, v[96:97]
	global_store_short_d16_hi v[14:15], v11, off offset:32
	v_lshl_add_u64 v[10:11], v[26:27], 0, v[86:87]
	global_store_short_d16_hi v[10:11], v12, off offset:32
	v_lshl_add_u64 v[10:11], v[26:27], 0, v[120:121]
	global_store_short_d16_hi v[10:11], v13, off offset:32
	global_store_short_d16_hi v[34:35], v6, off offset:256
	global_store_short_d16_hi v[36:37], v7, off offset:256
	global_store_short_d16_hi v[30:31], v8, off offset:256
	global_store_short_d16_hi v[40:41], v9, off offset:256
	v_lshl_add_u64 v[6:7], v[26:27], 0, v[82:83]
	global_store_short_d16_hi v[6:7], v2, off offset:32
	v_lshl_add_u64 v[6:7], v[26:27], 0, v[88:89]
	global_store_short_d16_hi v[6:7], v3, off offset:32
	v_lshl_add_u64 v[2:3], v[26:27], 0, v[66:67]
	v_lshl_add_u64 v[0:1], v[26:27], 0, v[0:1]
	global_store_short_d16_hi v[2:3], v4, off offset:32
	global_store_short_d16_hi v[0:1], v5, off offset:32
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z8micro_tk13micro_globals
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 400
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
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 192
		.amdhsa_next_free_sgpr 34
		.amdhsa_accum_offset 192
		.amdhsa_reserve_vcc 1
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
	.size	_Z8micro_tk13micro_globals, .Lfunc_end0-_Z8micro_tk13micro_globals

	.set _Z8micro_tk13micro_globals.num_vgpr, 192
	.set _Z8micro_tk13micro_globals.num_agpr, 0
	.set _Z8micro_tk13micro_globals.numbered_sgpr, 34
	.set _Z8micro_tk13micro_globals.private_seg_size, 0
	.set _Z8micro_tk13micro_globals.uses_vcc, 1
	.set _Z8micro_tk13micro_globals.uses_flat_scratch, 0
	.set _Z8micro_tk13micro_globals.has_dyn_sized_stack, 0
	.set _Z8micro_tk13micro_globals.has_recursion, 0
	.set _Z8micro_tk13micro_globals.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_3c3d6d6a98db8b33,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_3c3d6d6a98db8b33
__hip_cuid_3c3d6d6a98db8b33:
	.byte	0
	.size	__hip_cuid_3c3d6d6a98db8b33, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_3c3d6d6a98db8b33
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           144
        .value_kind:     by_value
      - .offset:         144
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         148
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         152
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         156
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         158
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         160
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         162
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         164
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         166
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         184
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         192
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         200
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         208
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         264
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 400
    .max_flat_workgroup_size: 512
    .name:           _Z8micro_tk13micro_globals
    .private_segment_fixed_size: 0
    .sgpr_count:     40
    .sgpr_spill_count: 0
    .symbol:         _Z8micro_tk13micro_globals.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     192
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
