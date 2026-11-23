	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	_Z8micro_tk13micro_globals
	.globl	_Z8micro_tk13micro_globals
	.p2align	8
	.type	_Z8micro_tk13micro_globals,@function
_Z8micro_tk13micro_globals:
	s_mov_b64 s[6:7], src_shared_base
	s_cmp_lg_u32 0, -1
	s_cselect_b32 s6, s7, 0
	s_cselect_b32 s7, 0, 0
	s_and_b32 s4, s7, 15
	s_and_b32 s8, s7, -16
	s_add_u32 s8, s8, 16
	s_mov_b32 s5, 0
	s_addc_u32 s9, s6, 0
	s_cmp_eq_u64 s[4:5], 0
	s_cselect_b32 s30, s7, s8
	s_cselect_b32 s31, s6, s9
	s_add_u32 s8, s30, 0x10000
	s_addc_u32 s9, s31, 0
	s_and_b32 s4, s8, 15
	s_and_b32 s6, s8, -16
	s_add_u32 s10, s6, 16
	s_load_dwordx2 s[6:7], s[0:1], 0x98
	s_addc_u32 s11, s9, 0
	s_cmp_eq_u64 s[4:5], 0
	s_cselect_b32 s29, s9, s11
	s_cselect_b32 s28, s8, s10
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s3, s6, s3
	s_add_i32 s2, s3, s2
	s_ashr_i32 s4, s2, 31
	s_lshr_b32 s4, s4, 29
	s_add_i32 s4, s2, s4
	s_mul_i32 s3, s7, s6
	s_ashr_i32 s6, s4, 3
	s_and_b32 s4, s4, -8
	s_sub_i32 s2, s2, s4
	s_ashr_i32 s4, s3, 31
	s_lshr_b32 s4, s4, 29
	s_add_i32 s3, s3, s4
	s_ashr_i32 s3, s3, 3
	s_mul_i32 s2, s2, s3
	s_add_i32 s2, s2, s6
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 28
	s_add_i32 s3, s2, s3
	s_ashr_i32 s4, s3, 4
	s_lshl_b32 s4, s4, 3
	s_sub_i32 s6, 2, s4
	s_min_i32 s6, s6, 8
	s_abs_i32 s7, s6
	v_cvt_f32_u32_e32 v1, s7
	s_sub_i32 s9, 0, s7
	s_and_b32 s3, s3, -16
	s_sub_i32 s2, s2, s3
	v_rcp_iflag_f32_e32 v1, v1
	s_abs_i32 s8, s2
	s_xor_b32 s3, s2, s6
	s_ashr_i32 s3, s3, 31
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_lshrrev_b32_e32 v3, 2, v0
	v_lshlrev_b32_e32 v6, 4, v0
	v_and_b32_e32 v2, 16, v3
	v_readfirstlane_b32 s10, v1
	s_mul_i32 s9, s9, s10
	s_mul_hi_u32 s9, s10, s9
	s_add_i32 s10, s10, s9
	s_mul_hi_u32 s9, s8, s10
	s_mul_i32 s10, s9, s7
	s_sub_i32 s8, s8, s10
	s_add_i32 s10, s9, 1
	s_sub_i32 s11, s8, s7
	s_cmp_ge_u32 s8, s7
	s_cselect_b32 s9, s10, s9
	s_cselect_b32 s8, s11, s8
	s_add_i32 s10, s9, 1
	s_cmp_ge_u32 s8, s7
	s_cselect_b32 s7, s10, s9
	s_xor_b32 s7, s7, s3
	v_and_b32_e32 v1, 32, v0
	s_sub_i32 s10, s7, s3
	v_bitop3_b32 v1, v2, v6, v1 bitop3:0x36
	s_mul_i32 s3, s10, s6
	v_lshrrev_b32_e32 v1, 1, v1
	v_and_b32_e32 v2, 32, v3
	s_sub_i32 s2, s2, s3
	v_and_or_b32 v2, v1, 24, v2
	v_lshrrev_b32_e32 v1, 3, v0
	s_add_i32 s4, s4, s2
	v_and_b32_e32 v4, 32, v1
	s_load_dword s11, s[0:1], 0x20
	s_load_dwordx2 s[2:3], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x30
	s_load_dword s12, s[0:1], 0x50
	v_and_or_b32 v3, v3, 31, v4
	s_waitcnt lgkmcnt(0)
	v_mad_u64_u32 v[4:5], s[8:9], v3, s11, v[2:3]
	s_lshl_b32 s8, s11, 6
	v_lshlrev_b32_e32 v138, 1, v4
	v_add_u32_e32 v4, s8, v4
	v_lshlrev_b32_e32 v140, 1, v4
	v_add_u32_e32 v4, s8, v4
	v_add_lshl_u32 v139, v4, s8, 1
	v_mad_u64_u32 v[2:3], s[8:9], v3, s12, v[2:3]
	s_lshl_b32 s8, s12, 6
	v_lshlrev_b32_e32 v134, 1, v2
	v_add_u32_e32 v2, s8, v2
	v_lshlrev_b32_e32 v136, 1, v2
	v_add_u32_e32 v2, s8, v2
	s_lshl_b32 s33, s4, 8
	v_lshlrev_b32_e32 v137, 1, v2
	v_add_lshl_u32 v135, v2, s8, 1
	s_mul_hi_i32 s9, s11, s33
	s_mul_i32 s8, s11, s33
	v_and_b32_e32 v2, 0x1c00, v6
	v_mov_b32_e32 v3, 0
	s_lshl_b64 s[8:9], s[8:9], 1
	v_lshl_add_u64 v[130:131], s[30:31], 0, v[2:3]
	s_add_u32 s20, s2, s8
	v_readfirstlane_b32 s2, v130
	v_add_u32_e32 v142, 0x2000, v130
	s_addc_u32 s21, s3, s9
	s_lshl_b32 s22, s11, 9
	s_mov_b32 s23, 0x110000
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v142
	v_add_u32_e32 v143, 0x4000, v130
	buffer_load_dwordx4 v138, s[20:23], 0 offen lds
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v143
	v_add_u32_e32 v145, 0x6000, v130
	v_lshlrev_b32_e32 v141, 1, v4
	buffer_load_dwordx4 v140, s[20:23], 0 offen lds
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v145
	s_lshl_b32 s31, s10, 8
	buffer_load_dwordx4 v141, s[20:23], 0 offen lds
	s_mov_b32 m0, s2
	s_mul_hi_i32 s3, s12, s31
	s_mul_i32 s2, s12, s31
	s_lshl_b64 s[2:3], s[2:3], 1
	v_lshl_add_u64 v[132:133], s[28:29], 0, v[2:3]
	s_add_u32 s24, s6, s2
	v_readfirstlane_b32 s2, v132
	v_add_u32_e32 v144, 0x2000, v132
	buffer_load_dwordx4 v139, s[20:23], 0 offen lds
	s_addc_u32 s25, s7, s3
	s_lshl_b32 s26, s12, 9
	s_mov_b32 s27, s23
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v144
	v_add_u32_e32 v146, 0x4000, v132
	buffer_load_dwordx4 v134, s[24:27], 0 offen lds
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v146
	v_add_u32_e32 v147, 0x6000, v132
	buffer_load_dwordx4 v136, s[24:27], 0 offen lds
	s_mov_b32 m0, s2
	v_readfirstlane_b32 s2, v147
	buffer_load_dwordx4 v137, s[24:27], 0 offen lds
	s_mov_b32 m0, s2
	v_lshrrev_b32_e32 v131, 8, v0
	buffer_load_dwordx4 v135, s[24:27], 0 offen lds
	s_load_dwordx2 s[2:3], s[0:1], 0x60
	s_load_dwordx2 s[0:1], s[0:1], 0x80
	v_cmp_eq_u32_e32 vcc, 1, v131
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_barrier
	s_and_saveexec_b64 s[6:7], vcc
	s_cbranch_execz .LBB0_2
	s_barrier
.LBB0_2:
	s_or_b64 exec, exec, s[6:7]
	v_lshlrev_b32_e32 v2, 6, v0
	v_lshrrev_b32_e32 v3, 1, v0
	v_lshlrev_b32_e32 v5, 2, v0
	v_and_b32_e32 v6, 16, v0
	v_and_b32_e32 v2, 0x7c0, v2
	v_and_b32_e32 v3, 16, v3
	v_and_or_b32 v5, v5, 32, v6
	v_lshlrev_b32_e32 v198, 14, v131
	v_bitop3_b32 v196, v3, v5, v2 bitop3:0x36
	v_add_u32_e32 v176, s30, v198
	v_add_u32_e32 v199, v196, v176
	;;#ASMSTART
	ds_read_b128 v[18:21], v199 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[22:25], v199 offset:0x1000

	;;#ASMEND
	v_or_b32_e32 v4, v3, v2
	;;#ASMSTART
	ds_read_b128 v[26:29], v199 offset:0x2000

	;;#ASMEND
	v_bitop3_b32 v197, v4, v5, 32 bitop3:0x36
	;;#ASMSTART
	ds_read_b128 v[148:151], v199 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v200, v197, v176
	;;#ASMSTART
	ds_read_b128 v[30:33], v200 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[34:37], v200 offset:0x1000

	;;#ASMEND
	v_add_u32_e32 v2, 0x8000, v130
	;;#ASMSTART
	ds_read_b128 v[152:155], v200 offset:0x2000

	;;#ASMEND
	s_add_u32 s8, s20, 0x80
	v_readfirstlane_b32 s36, v2
	v_add_u32_e32 v2, 0xa000, v130
	;;#ASMSTART
	ds_read_b128 v[156:159], v200 offset:0x3000

	;;#ASMEND
	s_addc_u32 s9, s21, 0
	s_mov_b32 s10, s22
	s_mov_b32 s11, s23
	s_mov_b32 m0, s36
	v_readfirstlane_b32 s1, v2
	v_add_u32_e32 v2, 0xc000, v130
	buffer_load_dwordx4 v138, s[8:11], 0 offen lds
	s_mov_b32 m0, s1
	v_readfirstlane_b32 s27, v2
	v_add_u32_e32 v2, 0xe000, v130
	v_bfe_u32 v133, v0, 6, 2
	buffer_load_dwordx4 v140, s[8:11], 0 offen lds
	s_mov_b32 m0, s27
	v_readfirstlane_b32 s29, v2
	buffer_load_dwordx4 v141, s[8:11], 0 offen lds
	s_mov_b32 m0, s29
	v_lshlrev_b32_e32 v201, 13, v133
	buffer_load_dwordx4 v139, s[8:11], 0 offen lds
	v_add_u32_e32 v180, s28, v201
	v_add_u32_e32 v202, v196, v180
	;;#ASMSTART
	ds_read_b128 v[160:163], v202 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[164:167], v202 offset:0x1000

	;;#ASMEND
	v_add_u32_e32 v2, 0x8000, v132
	v_add_u32_e32 v203, v197, v180
	;;#ASMSTART
	ds_read_b128 v[168:171], v203 offset:0

	;;#ASMEND
	s_add_u32 s8, s24, 0x80
	v_readfirstlane_b32 s34, v2
	v_add_u32_e32 v2, 0xa000, v132
	;;#ASMSTART
	ds_read_b128 v[172:175], v203 offset:0x1000

	;;#ASMEND
	s_addc_u32 s9, s25, 0
	s_mov_b32 s10, s26
	s_mov_b32 m0, s34
	v_readfirstlane_b32 s35, v2
	v_add_u32_e32 v2, 0xc000, v132
	buffer_load_dwordx4 v134, s[8:11], 0 offen lds
	s_mov_b32 m0, s35
	v_readfirstlane_b32 s37, v2
	v_add_u32_e32 v2, 0xe000, v132
	buffer_load_dwordx4 v136, s[8:11], 0 offen lds
	s_mov_b32 m0, s37
	v_readfirstlane_b32 s38, v2
	buffer_load_dwordx4 v137, s[8:11], 0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v135, s[8:11], 0 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	s_mov_b32 s4, s5
	s_mov_b32 s6, s5
	s_mov_b32 s7, s5
	s_mov_b32 s8, s5
	s_mov_b32 s9, s5
	s_mov_b32 s10, s5
	s_mov_b32 s11, s5
	s_mov_b32 s12, s5
	s_mov_b32 s13, s5
	s_mov_b32 s14, s5
	s_mov_b32 s15, s5
	s_mov_b32 s16, s5
	s_mov_b32 s17, s5
	s_mov_b32 s18, s5
	s_mov_b32 s19, s5
	v_mov_b64_e32 v[2:3], s[4:5]
	v_mov_b64_e32 v[4:5], s[6:7]
	v_mov_b64_e32 v[6:7], s[8:9]
	v_mov_b64_e32 v[8:9], s[10:11]
	v_mov_b64_e32 v[10:11], s[12:13]
	v_mov_b64_e32 v[12:13], s[14:15]
	v_mov_b64_e32 v[14:15], s[16:17]
	v_mov_b64_e32 v[16:17], s[18:19]
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[18:21], v[160:163], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[18:21], v[164:167], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[22:25], v[160:163], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[22:25], v[164:167], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[30:33], v[168:171], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[30:33], v[172:175], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[34:37], v[168:171], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[34:37], v[172:175], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[26:29], v[160:163], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[26:29], v[164:167], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[148:151], v[160:163], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[148:151], v[164:167], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[152:155], v[168:171], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[152:155], v[172:175], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[156:159], v[168:171], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[156:159], v[172:175], v[2:17]
	s_setprio 0
	v_add_u32_e32 v164, 0x800, v176
	s_barrier
	v_add_u32_e32 v204, v196, v164
	;;#ASMSTART
	ds_read_b128 v[148:151], v204 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v204 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v204 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v204 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v205, v197, v164
	;;#ASMSTART
	ds_read_b128 v[164:167], v205 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v205 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[172:175], v205 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[176:179], v205 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v188, 0x800, v180
	v_add_u32_e32 v206, v196, v188
	;;#ASMSTART
	ds_read_b128 v[180:183], v206 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[184:187], v206 offset:0x1000

	;;#ASMEND
	v_add_u32_e32 v207, v197, v188
	;;#ASMSTART
	ds_read_b128 v[188:191], v207 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[192:195], v207 offset:0x1000

	;;#ASMEND
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[148:151], v[180:183], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[148:151], v[184:187], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[152:155], v[180:183], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[152:155], v[184:187], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[156:159], v[180:183], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[156:159], v[184:187], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[160:163], v[180:183], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[160:163], v[184:187], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[164:167], v[188:191], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[164:167], v[192:195], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[168:171], v[188:191], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[168:171], v[192:195], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[172:175], v[188:191], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[172:175], v[192:195], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[176:179], v[188:191], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[176:179], v[192:195], v[2:17]
	s_setprio 0
	s_add_i32 s4, s30, 0x8000
	v_add_u32_e32 v198, s4, v198
	s_barrier
	v_add_u32_e32 v208, v196, v198
	;;#ASMSTART
	ds_read_b128 v[148:151], v208 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[152:155], v208 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[156:159], v208 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[160:163], v208 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v209, v197, v198
	;;#ASMSTART
	ds_read_b128 v[164:167], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[168:171], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[172:175], v209 offset:0x2000

	;;#ASMEND
	s_add_u32 s4, s20, 0x100
	v_readfirstlane_b32 s8, v130
	;;#ASMSTART
	ds_read_b128 v[176:179], v209 offset:0x3000

	;;#ASMEND
	s_addc_u32 s5, s21, 0
	s_mov_b32 s6, s22
	s_mov_b32 s7, s23
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v142
	buffer_load_dwordx4 v138, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v143
	buffer_load_dwordx4 v140, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v145
	buffer_load_dwordx4 v141, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v132
	buffer_load_dwordx4 v139, s[4:7], 0 offen lds
	s_add_i32 s4, s28, 0x8000
	v_add_u32_e32 v130, s4, v201
	v_add_u32_e32 v201, v196, v130
	;;#ASMSTART
	ds_read_b128 v[180:183], v201 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[184:187], v201 offset:0x1000

	;;#ASMEND
	v_add_u32_e32 v210, v197, v130
	;;#ASMSTART
	ds_read_b128 v[188:191], v210 offset:0

	;;#ASMEND
	s_add_u32 s4, s24, 0x100
	;;#ASMSTART
	ds_read_b128 v[192:195], v210 offset:0x1000

	;;#ASMEND
	s_addc_u32 s5, s25, 0
	s_mov_b32 s6, s26
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v144
	buffer_load_dwordx4 v134, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v146
	buffer_load_dwordx4 v136, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	v_readfirstlane_b32 s8, v147
	buffer_load_dwordx4 v137, s[4:7], 0 offen lds
	s_mov_b32 m0, s8
	s_nop 0
	buffer_load_dwordx4 v135, s[4:7], 0 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[148:151], v[180:183], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[148:151], v[184:187], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[152:155], v[180:183], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[152:155], v[184:187], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[156:159], v[180:183], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[156:159], v[184:187], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[160:163], v[180:183], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[160:163], v[184:187], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[164:167], v[188:191], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[164:167], v[192:195], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[168:171], v[188:191], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[168:171], v[192:195], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[172:175], v[188:191], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[172:175], v[192:195], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[176:179], v[188:191], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[176:179], v[192:195], v[2:17]
	s_setprio 0
	v_add_u32_e32 v132, 0x800, v198
	s_barrier
	v_add_u32_e32 v190, v196, v132
	;;#ASMSTART
	ds_read_b128 v[142:145], v190 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v190 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v190 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v190 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v132, v197, v132
	;;#ASMSTART
	ds_read_b128 v[158:161], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v132 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v132 offset:0x3000

	;;#ASMEND
	v_add_u32_e32 v130, 0x800, v130
	v_add_u32_e32 v191, v196, v130
	;;#ASMSTART
	ds_read_b128 v[174:177], v191 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v191 offset:0x1000

	;;#ASMEND
	v_add_u32_e32 v130, v197, v130
	;;#ASMSTART
	ds_read_b128 v[182:185], v130 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[186:189], v130 offset:0x1000

	;;#ASMEND
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[142:145], v[174:177], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[142:145], v[178:181], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[174:177], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[178:181], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[150:153], v[174:177], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[150:153], v[178:181], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[154:157], v[174:177], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[154:157], v[178:181], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[158:161], v[182:185], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[158:161], v[186:189], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[162:165], v[182:185], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[162:165], v[186:189], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[166:169], v[182:185], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[166:169], v[186:189], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[170:173], v[182:185], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[170:173], v[186:189], v[2:17]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[142:145], v199 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v199 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v199 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v199 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v200 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v200 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v200 offset:0x2000

	;;#ASMEND
	s_add_u32 s20, s20, 0x180
	s_mov_b32 m0, s36
	;;#ASMSTART
	ds_read_b128 v[170:173], v200 offset:0x3000

	;;#ASMEND
	s_addc_u32 s21, s21, 0
	buffer_load_dwordx4 v138, s[20:23], 0 offen lds
	s_mov_b32 m0, s1
	s_add_u32 s24, s24, 0x180
	buffer_load_dwordx4 v140, s[20:23], 0 offen lds
	s_mov_b32 m0, s27
	s_addc_u32 s25, s25, 0
	buffer_load_dwordx4 v141, s[20:23], 0 offen lds
	s_mov_b32 m0, s29
	s_mov_b32 s27, s23
	buffer_load_dwordx4 v139, s[20:23], 0 offen lds
	;;#ASMSTART
	ds_read_b128 v[138:141], v202 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v202 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v203 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[182:185], v203 offset:0x1000

	;;#ASMEND
	s_mov_b32 m0, s34
	s_nop 0
	buffer_load_dwordx4 v134, s[24:27], 0 offen lds
	s_mov_b32 m0, s35
	s_nop 0
	buffer_load_dwordx4 v136, s[24:27], 0 offen lds
	s_mov_b32 m0, s37
	s_nop 0
	buffer_load_dwordx4 v137, s[24:27], 0 offen lds
	s_mov_b32 m0, s38
	s_nop 0
	buffer_load_dwordx4 v135, s[24:27], 0 offen lds
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[142:145], v[138:141], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[142:145], v[174:177], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[138:141], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[174:177], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[150:153], v[138:141], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[150:153], v[174:177], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[154:157], v[138:141], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[154:157], v[174:177], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[158:161], v[178:181], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[158:161], v[182:185], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[162:165], v[178:181], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[162:165], v[182:185], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[166:169], v[178:181], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[166:169], v[182:185], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[170:173], v[178:181], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[170:173], v[182:185], v[2:17]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[134:137], v204 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[138:141], v204 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v204 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v204 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v205 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v205 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v205 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v205 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v206 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v206 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v207 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v207 offset:0x1000

	;;#ASMEND
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[134:137], v[166:169], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[134:137], v[170:173], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[138:141], v[166:169], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[138:141], v[170:173], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[142:145], v[166:169], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[142:145], v[170:173], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[146:149], v[166:169], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[146:149], v[170:173], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[150:153], v[174:177], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[150:153], v[178:181], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[154:157], v[174:177], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[154:157], v[178:181], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[158:161], v[174:177], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[158:161], v[178:181], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[162:165], v[174:177], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[162:165], v[178:181], v[2:17]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[134:137], v208 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[138:141], v208 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v208 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v208 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v209 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v209 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v209 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v209 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v201 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v201 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v210 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v210 offset:0x1000

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[134:137], v[166:169], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[134:137], v[170:173], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[138:141], v[166:169], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[138:141], v[170:173], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[142:145], v[166:169], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[142:145], v[170:173], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[146:149], v[166:169], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[146:149], v[170:173], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[150:153], v[174:177], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[150:153], v[178:181], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[154:157], v[174:177], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[154:157], v[178:181], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[158:161], v[174:177], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[158:161], v[178:181], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[162:165], v[174:177], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[162:165], v[178:181], v[2:17]
	s_setprio 0
	s_barrier
	;;#ASMSTART
	ds_read_b128 v[134:137], v190 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[138:141], v190 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[142:145], v190 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[146:149], v190 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[150:153], v132 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[154:157], v132 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[158:161], v132 offset:0x2000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[162:165], v132 offset:0x3000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[166:169], v191 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[170:173], v191 offset:0x1000

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[174:177], v130 offset:0

	;;#ASMEND
	;;#ASMSTART
	ds_read_b128 v[178:181], v130 offset:0x1000

	;;#ASMEND
	s_barrier
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	;;#ASMEND
	s_setprio 1
	v_mfma_f32_32x32x16_bf16 v[114:129], v[134:137], v[166:169], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[134:137], v[170:173], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[138:141], v[166:169], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[138:141], v[170:173], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[142:145], v[166:169], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[142:145], v[170:173], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[146:149], v[166:169], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[146:149], v[170:173], v[2:17]
	v_mfma_f32_32x32x16_bf16 v[114:129], v[150:153], v[174:177], v[114:129]
	v_mfma_f32_32x32x16_bf16 v[98:113], v[150:153], v[178:181], v[98:113]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[154:157], v[174:177], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[154:157], v[178:181], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[158:161], v[174:177], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[158:161], v[178:181], v[34:49]
	v_mfma_f32_32x32x16_bf16 v[18:33], v[162:165], v[174:177], v[18:33]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[162:165], v[178:181], v[2:17]
	s_setprio 0
	v_lshl_add_u32 v132, v131, 7, s33
	v_lshl_or_b32 v130, v133, 6, s31
	v_mad_i64_i32 v[132:133], s[4:5], s0, v132, 0
	v_ashrrev_i32_e32 v131, 31, v130
	v_lshl_add_u64 v[132:133], v[132:133], 1, s[2:3]
	v_and_b32_e32 v150, 4, v1
	v_and_b32_e32 v0, 31, v0
	v_lshl_add_u64 v[130:131], v[130:131], 1, v[132:133]
	v_mad_u64_u32 v[132:133], s[2:3], v150, s0, v[0:1]
	v_ashrrev_i32_e32 v133, 31, v132
	v_lshl_add_u64 v[134:135], v[132:133], 1, v[130:131]
	v_add_u32_e32 v132, s0, v132
	v_ashrrev_i32_e32 v133, 31, v132
	s_barrier
	global_store_short_d16_hi v[134:135], v114, off
	v_lshl_add_u64 v[136:137], v[132:133], 1, v[130:131]
	v_add_u32_e32 v114, s0, v132
	global_store_short_d16_hi v[136:137], v115, off
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[132:133], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	s_mul_i32 s1, s0, 5
	v_lshl_add_u64 v[138:139], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s1, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[132:133], v116, off
	global_store_short_d16_hi v[138:139], v117, off
	v_lshl_add_u64 v[116:117], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[140:141], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[116:117], v118, off
	global_store_short_d16_hi v[140:141], v119, off
	v_lshl_add_u64 v[118:119], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[142:143], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s1, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[118:119], v120, off
	global_store_short_d16_hi v[142:143], v121, off
	v_lshl_add_u64 v[120:121], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[144:145], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[120:121], v122, off
	global_store_short_d16_hi v[144:145], v123, off
	v_lshl_add_u64 v[122:123], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[146:147], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s1, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[122:123], v124, off
	global_store_short_d16_hi v[146:147], v125, off
	v_lshl_add_u64 v[124:125], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[148:149], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	global_store_short_d16_hi v[124:125], v126, off
	global_store_short_d16_hi v[148:149], v127, off
	v_lshl_add_u64 v[126:127], v[114:115], 1, v[130:131]
	v_add_u32_e32 v114, s0, v114
	v_ashrrev_i32_e32 v115, 31, v114
	v_lshl_add_u64 v[114:115], v[114:115], 1, v[130:131]
	global_store_short_d16_hi v[126:127], v128, off
	global_store_short_d16_hi v[114:115], v129, off
	global_store_short_d16_hi v[134:135], v98, off offset:64
	global_store_short_d16_hi v[136:137], v99, off offset:64
	global_store_short_d16_hi v[132:133], v100, off offset:64
	global_store_short_d16_hi v[138:139], v101, off offset:64
	global_store_short_d16_hi v[116:117], v102, off offset:64
	global_store_short_d16_hi v[140:141], v103, off offset:64
	global_store_short_d16_hi v[118:119], v104, off offset:64
	global_store_short_d16_hi v[142:143], v105, off offset:64
	global_store_short_d16_hi v[120:121], v106, off offset:64
	global_store_short_d16_hi v[144:145], v107, off offset:64
	global_store_short_d16_hi v[122:123], v108, off offset:64
	global_store_short_d16_hi v[146:147], v109, off offset:64
	global_store_short_d16_hi v[124:125], v110, off offset:64
	global_store_short_d16_hi v[148:149], v111, off offset:64
	global_store_short_d16_hi v[126:127], v112, off offset:64
	global_store_short_d16_hi v[114:115], v113, off offset:64
	v_or_b32_e32 v98, 32, v150
	v_mad_u64_u32 v[98:99], s[2:3], v98, s0, v[0:1]
	v_ashrrev_i32_e32 v99, 31, v98
	v_lshl_add_u64 v[100:101], v[98:99], 1, v[130:131]
	v_add_u32_e32 v98, s0, v98
	v_ashrrev_i32_e32 v99, 31, v98
	global_store_short_d16_hi v[100:101], v82, off
	v_lshl_add_u64 v[102:103], v[98:99], 1, v[130:131]
	v_add_u32_e32 v82, s0, v98
	global_store_short_d16_hi v[102:103], v83, off
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[98:99], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[104:105], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s1, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[98:99], v84, off
	global_store_short_d16_hi v[104:105], v85, off
	v_lshl_add_u64 v[84:85], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[106:107], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[84:85], v86, off
	global_store_short_d16_hi v[106:107], v87, off
	v_lshl_add_u64 v[86:87], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[108:109], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s1, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[86:87], v88, off
	global_store_short_d16_hi v[108:109], v89, off
	v_lshl_add_u64 v[88:89], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[110:111], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[88:89], v90, off
	global_store_short_d16_hi v[110:111], v91, off
	v_lshl_add_u64 v[90:91], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[112:113], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s1, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[90:91], v92, off
	global_store_short_d16_hi v[112:113], v93, off
	v_lshl_add_u64 v[92:93], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[114:115], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	global_store_short_d16_hi v[92:93], v94, off
	global_store_short_d16_hi v[114:115], v95, off
	v_lshl_add_u64 v[94:95], v[82:83], 1, v[130:131]
	v_add_u32_e32 v82, s0, v82
	v_ashrrev_i32_e32 v83, 31, v82
	v_lshl_add_u64 v[82:83], v[82:83], 1, v[130:131]
	global_store_short_d16_hi v[94:95], v96, off
	global_store_short_d16_hi v[82:83], v97, off
	global_store_short_d16_hi v[100:101], v66, off offset:64
	global_store_short_d16_hi v[102:103], v67, off offset:64
	global_store_short_d16_hi v[98:99], v68, off offset:64
	global_store_short_d16_hi v[104:105], v69, off offset:64
	global_store_short_d16_hi v[84:85], v70, off offset:64
	global_store_short_d16_hi v[106:107], v71, off offset:64
	global_store_short_d16_hi v[86:87], v72, off offset:64
	global_store_short_d16_hi v[108:109], v73, off offset:64
	global_store_short_d16_hi v[88:89], v74, off offset:64
	global_store_short_d16_hi v[110:111], v75, off offset:64
	global_store_short_d16_hi v[90:91], v76, off offset:64
	global_store_short_d16_hi v[112:113], v77, off offset:64
	global_store_short_d16_hi v[92:93], v78, off offset:64
	global_store_short_d16_hi v[114:115], v79, off offset:64
	global_store_short_d16_hi v[94:95], v80, off offset:64
	global_store_short_d16_hi v[82:83], v81, off offset:64
	v_or_b32_e32 v66, 64, v150
	v_mad_u64_u32 v[66:67], s[2:3], v66, s0, v[0:1]
	v_ashrrev_i32_e32 v67, 31, v66
	v_lshl_add_u64 v[68:69], v[66:67], 1, v[130:131]
	v_add_u32_e32 v66, s0, v66
	v_ashrrev_i32_e32 v67, 31, v66
	global_store_short_d16_hi v[68:69], v50, off
	v_lshl_add_u64 v[70:71], v[66:67], 1, v[130:131]
	v_add_u32_e32 v50, s0, v66
	global_store_short_d16_hi v[70:71], v51, off
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[66:67], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[72:73], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s1, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[66:67], v52, off
	global_store_short_d16_hi v[72:73], v53, off
	v_lshl_add_u64 v[52:53], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[74:75], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[52:53], v54, off
	global_store_short_d16_hi v[74:75], v55, off
	v_lshl_add_u64 v[54:55], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[76:77], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s1, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[54:55], v56, off
	global_store_short_d16_hi v[76:77], v57, off
	v_lshl_add_u64 v[56:57], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[78:79], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[56:57], v58, off
	global_store_short_d16_hi v[78:79], v59, off
	v_lshl_add_u64 v[58:59], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[80:81], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s1, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[58:59], v60, off
	global_store_short_d16_hi v[80:81], v61, off
	v_lshl_add_u64 v[60:61], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[82:83], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	global_store_short_d16_hi v[60:61], v62, off
	global_store_short_d16_hi v[82:83], v63, off
	v_lshl_add_u64 v[62:63], v[50:51], 1, v[130:131]
	v_add_u32_e32 v50, s0, v50
	v_ashrrev_i32_e32 v51, 31, v50
	v_lshl_add_u64 v[50:51], v[50:51], 1, v[130:131]
	global_store_short_d16_hi v[62:63], v64, off
	global_store_short_d16_hi v[50:51], v65, off
	global_store_short_d16_hi v[68:69], v34, off offset:64
	global_store_short_d16_hi v[70:71], v35, off offset:64
	global_store_short_d16_hi v[66:67], v36, off offset:64
	global_store_short_d16_hi v[72:73], v37, off offset:64
	global_store_short_d16_hi v[52:53], v38, off offset:64
	global_store_short_d16_hi v[74:75], v39, off offset:64
	global_store_short_d16_hi v[54:55], v40, off offset:64
	global_store_short_d16_hi v[76:77], v41, off offset:64
	global_store_short_d16_hi v[56:57], v42, off offset:64
	global_store_short_d16_hi v[78:79], v43, off offset:64
	global_store_short_d16_hi v[58:59], v44, off offset:64
	global_store_short_d16_hi v[80:81], v45, off offset:64
	global_store_short_d16_hi v[60:61], v46, off offset:64
	global_store_short_d16_hi v[82:83], v47, off offset:64
	global_store_short_d16_hi v[62:63], v48, off offset:64
	global_store_short_d16_hi v[50:51], v49, off offset:64
	v_or_b32_e32 v34, 0x60, v150
	v_mad_u64_u32 v[34:35], s[2:3], v34, s0, v[0:1]
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[36:37], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[38:39], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[40:41], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[42:43], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s1, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[44:45], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[46:47], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[48:49], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[50:51], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s1, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[52:53], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[54:55], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[56:57], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[58:59], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s1, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_lshl_add_u64 v[60:61], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_or_b32_e32 v1, 0x7b, v1
	v_ashrrev_i32_e32 v35, 31, v34
	v_mad_u64_u32 v[0:1], s[2:3], v1, s0, v[0:1]
	v_lshl_add_u64 v[62:63], v[34:35], 1, v[130:131]
	v_add_u32_e32 v34, s0, v34
	v_ashrrev_i32_e32 v35, 31, v34
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshl_add_u64 v[34:35], v[34:35], 1, v[130:131]
	v_lshl_add_u64 v[0:1], v[0:1], 1, v[130:131]
	global_store_short_d16_hi v[36:37], v18, off
	global_store_short_d16_hi v[38:39], v19, off
	global_store_short_d16_hi v[40:41], v20, off
	global_store_short_d16_hi v[42:43], v21, off
	global_store_short_d16_hi v[44:45], v22, off
	global_store_short_d16_hi v[46:47], v23, off
	global_store_short_d16_hi v[48:49], v24, off
	global_store_short_d16_hi v[50:51], v25, off
	global_store_short_d16_hi v[52:53], v26, off
	global_store_short_d16_hi v[54:55], v27, off
	global_store_short_d16_hi v[56:57], v28, off
	global_store_short_d16_hi v[58:59], v29, off
	global_store_short_d16_hi v[60:61], v30, off
	global_store_short_d16_hi v[62:63], v31, off
	global_store_short_d16_hi v[34:35], v32, off
	global_store_short_d16_hi v[0:1], v33, off
	global_store_short_d16_hi v[36:37], v2, off offset:64
	global_store_short_d16_hi v[38:39], v3, off offset:64
	global_store_short_d16_hi v[40:41], v4, off offset:64
	global_store_short_d16_hi v[42:43], v5, off offset:64
	global_store_short_d16_hi v[44:45], v6, off offset:64
	global_store_short_d16_hi v[46:47], v7, off offset:64
	global_store_short_d16_hi v[48:49], v8, off offset:64
	global_store_short_d16_hi v[50:51], v9, off offset:64
	global_store_short_d16_hi v[52:53], v10, off offset:64
	global_store_short_d16_hi v[54:55], v11, off offset:64
	global_store_short_d16_hi v[56:57], v12, off offset:64
	global_store_short_d16_hi v[58:59], v13, off offset:64
	global_store_short_d16_hi v[60:61], v14, off offset:64
	global_store_short_d16_hi v[62:63], v15, off offset:64
	global_store_short_d16_hi v[34:35], v16, off offset:64
	global_store_short_d16_hi v[0:1], v17, off offset:64
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z8micro_tk13micro_globals
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 408
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
		.amdhsa_next_free_vgpr 211
		.amdhsa_next_free_sgpr 39
		.amdhsa_accum_offset 212
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

	.set _Z8micro_tk13micro_globals.num_vgpr, 211
	.set _Z8micro_tk13micro_globals.num_agpr, 0
	.set _Z8micro_tk13micro_globals.numbered_sgpr, 39
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
	.type	__hip_cuid_31119acd060a65a9,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_31119acd060a65a9
__hip_cuid_31119acd060a65a9:
	.byte	0
	.size	__hip_cuid_31119acd060a65a9, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __shm
	.addrsig_sym __hip_cuid_31119acd060a65a9
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .offset:         0
        .size:           152
        .value_kind:     by_value
      - .offset:         152
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         156
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         160
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         164
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         166
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         168
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         170
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         172
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         174
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         192
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         200
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         208
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         216
        .size:           2
        .value_kind:     hidden_grid_dims
      - .offset:         272
        .size:           4
        .value_kind:     hidden_dynamic_lds_size
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 408
    .max_flat_workgroup_size: 512
    .name:           _Z8micro_tk13micro_globals
    .private_segment_fixed_size: 0
    .sgpr_count:     45
    .sgpr_spill_count: 0
    .symbol:         _Z8micro_tk13micro_globals.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     211
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
