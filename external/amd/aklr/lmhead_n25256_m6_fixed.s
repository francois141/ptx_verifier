; AKLR 766a200e367f aklr/ops/gemm/impls/hip/gemm_n25256_k8192/a435fa6cead5c1be.json, compiled for gfx950 by
; external/amd/aklr/build.py (case lmhead_n25256_m6_fixed).
	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.section	.text._ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,"axG",@progbits,_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,comdat
	.protected	_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
	.globl	_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
	.p2align	8
	.type	_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,@function
_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi:
	s_load_dwordx4 s[8:11], s[0:1], 0x0
	s_load_dwordx2 s[6:7], s[0:1], 0x10
	s_load_dword s22, s[0:1], 0x28
	v_readfirstlane_b32 s13, v0
	s_cmp_gt_u32 s13, 63
	s_cselect_b64 s[0:1], -1, 0
	s_and_b64 s[0:1], s[0:1], exec
	s_waitcnt lgkmcnt(0)
	s_cselect_b32 s9, s9, s11
	s_cselect_b32 s8, s8, s10
	s_cselect_b32 s24, 2, 4
	s_lshl_b32 s3, s22, 14
	s_cmp_gt_u32 s13, 63
	s_cselect_b64 s[4:5], -1, 0
	s_and_b64 s[0:1], s[4:5], exec
	s_mul_i32 s0, s2, 0xc55
	s_mul_hi_i32 s1, s0, 0x86d90545
	s_cselect_b32 s10, s3, 0x18aa0000
	s_add_i32 s1, s1, s0
	s_lshr_b32 s3, s1, 31
	s_ashr_i32 s1, s1, 7
	s_addk_i32 s0, 0xc55
	s_add_i32 s1, s1, s3
	s_mul_hi_i32 s3, s0, 0x86d90545
	s_add_i32 s3, s3, s0
	s_lshr_b32 s0, s3, 31
	s_ashr_i32 s3, s3, 7
	s_add_i32 s3, s3, s0
	s_sub_i32 s0, s3, s1
	s_lshr_b32 s16, s13, 6
	s_lshl_b32 s12, s1, 3
	s_lshl_b32 s23, s0, 3
	s_cmp_lt_u32 s13, 64
	s_cselect_b64 s[0:1], -1, 0
	s_cmp_lg_u64 s[4:5], 0
	s_subb_u32 s17, s16, 0
	v_and_b32_e32 v1, 63, v0
	s_lshl_b32 s14, s17, 6
	v_or_b32_e32 v2, s14, v1
	v_ashrrev_i32_e32 v3, 31, v2
	v_lshrrev_b32_e32 v3, 29, v3
	v_add_u32_e32 v3, v2, v3
	s_add_i32 s3, s23, -1
	v_ashrrev_i32_e32 v4, 3, v3
	v_and_b32_e32 v3, 0xffffff8, v3
	s_add_i32 s11, s22, -1
	v_sub_u32_e32 v2, v2, v3
	v_min_i32_e32 v3, s3, v4
	v_bitop3_b32 v2, v4, v2, 7 bitop3:0x6c
	v_add_u32_e32 v3, s12, v3
	v_min_i32_e32 v4, s11, v4
	v_cndmask_b32_e64 v3, v3, v4, s[4:5]
	v_lshlrev_b32_e32 v2, 4, v2
	s_add_i32 s15, s14, 64
	v_lshl_add_u32 v32, v3, 14, v2
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x80
	v_lshl_or_b32 v33, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0xc0
	v_lshl_or_b32 v34, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x100
	v_lshl_or_b32 v35, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x140
	v_lshl_or_b32 v36, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x180
	v_lshl_or_b32 v37, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x1c0
	v_lshl_or_b32 v38, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x200
	v_lshl_or_b32 v39, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x240
	v_lshl_or_b32 v40, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x280
	v_lshl_or_b32 v41, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x2c0
	v_lshl_or_b32 v42, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x300
	v_lshl_or_b32 v43, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x340
	v_lshl_or_b32 v44, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_add_i32 s15, s14, 0x380
	v_lshl_or_b32 v45, v2, 14, v3
	v_or_b32_e32 v2, s15, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_xor_b32_e32 v3, v2, v0
	v_min_i32_e32 v4, s3, v2
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_addk_i32 s14, 0x3c0
	v_lshl_or_b32 v46, v2, 14, v3
	v_or_b32_e32 v2, s14, v1
	v_lshrrev_b32_e32 v2, 3, v2
	v_min_i32_e32 v4, s3, v2
	s_ashr_i32 s3, s2, 31
	s_lshr_b32 s3, s3, 25
	s_add_i32 s3, s2, s3
	v_xor_b32_e32 v3, v2, v0
	s_and_b32 s3, s3, 0xffffff80
	v_add_u32_e32 v4, s12, v4
	v_min_i32_e32 v2, s11, v2
	v_lshlrev_b32_e32 v3, 4, v3
	s_sub_i32 s19, s2, s3
	s_lshl_b32 s25, s17, 10
	v_cndmask_b32_e64 v2, v4, v2, s[4:5]
	v_and_b32_e32 v3, 0x70, v3
	s_cmp_lt_i32 s17, 1
	v_lshl_or_b32 v47, v2, 14, v3
	v_cndmask_b32_e64 v2, 0, 1, s[0:1]
	s_cselect_b64 s[2:3], -1, 0
	v_cmp_ne_u32_e64 s[0:1], 1, v2
	v_cndmask_b32_e64 v2, 0, 1, s[2:3]
	s_mov_b32 s18, 0
	s_mov_b32 s11, 0x20000
	v_cmp_ne_u32_e64 s[2:3], 1, v2
	s_mov_b32 s20, s25
	s_mov_b32 s21, s25
	s_branch .LBB0_2
.LBB0_1:
	s_add_i32 s18, s18, 1
	s_addk_i32 s21, 0x1000
	s_addk_i32 s20, 0x4000
	s_cmp_eq_u32 s24, s18
	s_cbranch_scc1 .LBB0_9
.LBB0_2:
	s_add_i32 s14, s19, s18
	s_add_i32 s15, s14, 0xffffff80
	s_cmpk_gt_i32 s14, 0x7f
	s_cselect_b32 s14, s15, s14
	s_lshl_b32 s26, s14, 7
	s_and_b64 vcc, exec, s[0:1]
	s_mov_b64 s[14:15], -1
	s_cbranch_vccnz .LBB0_6
	;;#ASMSTART
	s_mov_b32 m0, s20
	s_nop 0
	buffer_load_dwordx4 v32, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x400
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v33, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x800
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v34, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0xc00
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v35, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x1000
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v36, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x1400
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v37, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x1800
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v38, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x1c00
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v39, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x2000
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v40, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x2400
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v41, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x2800
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v42, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x2c00
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v43, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x3000
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v44, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x3400
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v45, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_add_i32 s14, s20, 0x3800
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v46, s[8:11], s26 offen nt lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_5
	s_add_i32 s14, s20, 0x3c00
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v47, s[8:11], s26 offen nt lds
	;;#ASMEND
.LBB0_5:
	s_mov_b64 s[14:15], 0
.LBB0_6:
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_1
	s_add_i32 s14, s21, 0x14000
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v32, s[8:11], s26 offen lds
	;;#ASMEND
	s_add_i32 s14, s21, 0x14400
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v33, s[8:11], s26 offen lds
	;;#ASMEND
	s_add_i32 s14, s21, 0x14800
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v34, s[8:11], s26 offen lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_1
	s_add_i32 s14, s21, 0x14c00
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v35, s[8:11], s26 offen lds
	;;#ASMEND
	s_branch .LBB0_1
.LBB0_9:
	s_add_i32 s26, s25, 0x400
	s_add_i32 s27, s25, 0x800
	s_add_i32 s28, s25, 0xc00
	s_add_i32 s29, s25, 0x1000
	s_add_i32 s30, s25, 0x1400
	s_add_i32 s31, s25, 0x1800
	s_add_i32 s33, s25, 0x1c00
	s_add_i32 s34, s25, 0x2000
	s_add_i32 s35, s25, 0x2400
	s_add_i32 s36, s25, 0x2800
	s_add_i32 s37, s25, 0x2c00
	s_add_i32 s38, s25, 0x3000
	s_add_i32 s39, s25, 0x3400
	s_add_i32 s40, s25, 0x3800
	s_add_i32 s41, s25, 0x3c00
	s_and_b64 s[14:15], s[4:5], exec
	s_cselect_b32 s14, 4, 16
	s_add_i32 s15, s14, s17
	s_add_i32 s15, s15, -1
	v_lshrrev_b32_e32 v49, 4, v1
	s_cmp_ge_u32 s15, s14
	v_and_b32_e32 v48, 15, v0
	v_and_b32_e32 v1, 7, v0
	v_bitop3_b32 v0, v49, v0, 7 bitop3:0x78
	s_cselect_b64 s[14:15], -1, 0
	v_lshlrev_b32_e32 v51, 4, v0
	v_bitop3_b32 v0, v49, v1, 4 bitop3:0x36
	v_lshlrev_b32_e32 v2, 7, v48
	s_and_b64 s[4:5], s[4:5], exec
	v_lshlrev_b32_e32 v50, 4, v0
	v_cndmask_b32_e64 v0, 0, 1, s[14:15]
	s_cselect_b32 s42, 3, 5
	s_add_i32 s43, s24, s19
	v_lshl_or_b32 v52, s16, 13, v2
	v_or_b32_e32 v53, 0x14000, v2
	s_sub_i32 s44, 0x80, s24
	v_accvgpr_write_b32 a3, 0
	v_accvgpr_write_b32 a2, 0
	v_accvgpr_write_b32 a1, 0
	v_accvgpr_write_b32 a0, 0
	v_accvgpr_write_b32 a7, 0
	v_accvgpr_write_b32 a6, 0
	v_accvgpr_write_b32 a5, 0
	v_accvgpr_write_b32 a4, 0
	v_accvgpr_write_b32 a11, 0
	v_accvgpr_write_b32 a10, 0
	v_accvgpr_write_b32 a9, 0
	v_accvgpr_write_b32 a8, 0
	v_accvgpr_write_b32 a15, 0
	v_accvgpr_write_b32 a14, 0
	v_accvgpr_write_b32 a13, 0
	v_accvgpr_write_b32 a12, 0
	v_accvgpr_write_b32 a19, 0
	v_accvgpr_write_b32 a18, 0
	v_accvgpr_write_b32 a17, 0
	v_accvgpr_write_b32 a16, 0
	v_accvgpr_write_b32 a23, 0
	v_accvgpr_write_b32 a22, 0
	v_accvgpr_write_b32 a21, 0
	v_accvgpr_write_b32 a20, 0
	v_accvgpr_write_b32 a27, 0
	v_accvgpr_write_b32 a26, 0
	v_accvgpr_write_b32 a25, 0
	v_accvgpr_write_b32 a24, 0
	v_accvgpr_write_b32 a31, 0
	v_accvgpr_write_b32 a30, 0
	v_accvgpr_write_b32 a29, 0
	v_accvgpr_write_b32 a28, 0
	s_mov_b32 s45, 0
	v_cmp_ne_u32_e64 s[4:5], 1, v0
	s_mov_b32 s46, 0
	s_mov_b32 s47, 0
	s_branch .LBB0_11
.LBB0_10:
	v_lshl_add_u32 v78, s45, 14, v52
	v_lshl_add_u32 v94, s46, 12, v53
	v_add_u32_e32 v66, v78, v51
	v_add_u32_e32 v74, v94, v51
	v_add_u32_e32 v90, v78, v50
	ds_read_b128 v[54:57], v66
	ds_read_b128 v[58:61], v66 offset:2048
	ds_read_b128 v[62:65], v66 offset:4096
	ds_read_b128 v[66:69], v66 offset:6144
	ds_read_b128 v[70:73], v74
	ds_read_b128 v[74:77], v74 offset:2048
	ds_read_b128 v[78:81], v90
	ds_read_b128 v[82:85], v90 offset:2048
	ds_read_b128 v[86:89], v90 offset:4096
	ds_read_b128 v[90:93], v90 offset:6144
	v_add_u32_e32 v98, v94, v50
	ds_read_b128 v[94:97], v98
	ds_read_b128 v[98:101], v98 offset:2048
	v_accvgpr_write_b32 a0, v0
	v_accvgpr_write_b32 a4, v4
	v_accvgpr_write_b32 a8, v8
	v_accvgpr_write_b32 a12, v12
	v_accvgpr_write_b32 a16, v16
	v_accvgpr_write_b32 a20, v20
	v_accvgpr_write_b32 a24, v24
	v_accvgpr_write_b32 a28, v28
	v_accvgpr_write_b32 a1, v1
	v_accvgpr_write_b32 a2, v2
	v_accvgpr_write_b32 a3, v3
	v_accvgpr_write_b32 a5, v5
	v_accvgpr_write_b32 a6, v6
	v_accvgpr_write_b32 a7, v7
	v_accvgpr_write_b32 a9, v9
	v_accvgpr_write_b32 a10, v10
	v_accvgpr_write_b32 a11, v11
	v_accvgpr_write_b32 a13, v13
	v_accvgpr_write_b32 a14, v14
	v_accvgpr_write_b32 a15, v15
	v_accvgpr_write_b32 a17, v17
	v_accvgpr_write_b32 a18, v18
	v_accvgpr_write_b32 a19, v19
	v_accvgpr_write_b32 a21, v21
	v_accvgpr_write_b32 a22, v22
	v_accvgpr_write_b32 a23, v23
	v_accvgpr_write_b32 a25, v25
	v_accvgpr_write_b32 a26, v26
	v_accvgpr_write_b32 a27, v27
	v_accvgpr_write_b32 a29, v29
	v_accvgpr_write_b32 a30, v30
	v_accvgpr_write_b32 a31, v31
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 a[0:3], v[54:57], v[70:73], a[0:3]
	s_add_i32 s14, s24, 1
	s_cmp_lg_u32 s14, s42
	s_cselect_b32 s24, s14, 0
	v_mfma_f32_16x16x32_bf16 a[4:7], v[58:61], v[70:73], a[4:7]
	s_add_i32 s14, s45, 1
	s_cmp_lg_u32 s14, 5
	s_cselect_b32 s45, s14, 0
	v_mfma_f32_16x16x32_bf16 a[8:11], v[62:65], v[70:73], a[8:11]
	s_add_i32 s14, s46, 1
	s_cmp_lg_u32 s14, 3
	s_cselect_b32 s46, s14, 0
	v_mfma_f32_16x16x32_bf16 a[12:15], v[66:69], v[70:73], a[12:15]
	s_add_i32 s47, s47, 1
	s_cmpk_eq_i32 s47, 0x7f
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 a[16:19], v[54:57], v[74:77], a[16:19]
	v_mfma_f32_16x16x32_bf16 a[20:23], v[58:61], v[74:77], a[20:23]
	v_mfma_f32_16x16x32_bf16 a[24:27], v[62:65], v[74:77], a[24:27]
	v_mfma_f32_16x16x32_bf16 a[28:31], v[66:69], v[74:77], a[28:31]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 a[0:3], v[78:81], v[94:97], a[0:3]
	v_mfma_f32_16x16x32_bf16 a[4:7], v[82:85], v[94:97], a[4:7]
	v_mfma_f32_16x16x32_bf16 a[8:11], v[86:89], v[94:97], a[8:11]
	v_mfma_f32_16x16x32_bf16 a[12:15], v[90:93], v[94:97], a[12:15]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 a[16:19], v[78:81], v[98:101], a[16:19]
	v_mfma_f32_16x16x32_bf16 a[20:23], v[82:85], v[98:101], a[20:23]
	v_mfma_f32_16x16x32_bf16 a[24:27], v[86:89], v[98:101], a[24:27]
	v_mfma_f32_16x16x32_bf16 a[28:31], v[90:93], v[98:101], a[28:31]
	s_cbranch_scc1 .LBB0_57
.LBB0_11:
	v_accvgpr_read_b32 v3, a3
	v_accvgpr_read_b32 v2, a2
	v_accvgpr_read_b32 v1, a1
	v_accvgpr_read_b32 v0, a0
	v_accvgpr_read_b32 v7, a7
	v_accvgpr_read_b32 v6, a6
	v_accvgpr_read_b32 v5, a5
	v_accvgpr_read_b32 v4, a4
	v_accvgpr_read_b32 v11, a11
	v_accvgpr_read_b32 v10, a10
	v_accvgpr_read_b32 v9, a9
	v_accvgpr_read_b32 v8, a8
	v_accvgpr_read_b32 v15, a15
	v_accvgpr_read_b32 v14, a14
	v_accvgpr_read_b32 v13, a13
	v_accvgpr_read_b32 v12, a12
	v_accvgpr_read_b32 v19, a19
	v_accvgpr_read_b32 v18, a18
	v_accvgpr_read_b32 v17, a17
	v_accvgpr_read_b32 v16, a16
	v_accvgpr_read_b32 v23, a23
	v_accvgpr_read_b32 v22, a22
	v_accvgpr_read_b32 v21, a21
	v_accvgpr_read_b32 v20, a20
	v_accvgpr_read_b32 v27, a27
	v_accvgpr_read_b32 v26, a26
	v_accvgpr_read_b32 v25, a25
	v_accvgpr_read_b32 v24, a24
	v_accvgpr_read_b32 v31, a31
	v_accvgpr_read_b32 v30, a30
	v_accvgpr_read_b32 v29, a29
	v_accvgpr_read_b32 v28, a28
	s_and_b64 vcc, exec, s[0:1]
	s_mov_b64 s[14:15], -1
	s_cbranch_vccnz .LBB0_34
	s_cmpk_gt_u32 s47, 0x7c
	s_cselect_b64 s[14:15], -1, 0
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[16:17], -1
	s_cbranch_vccnz .LBB0_23
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_20
	s_mov_b64 s[20:21], -1
	s_mov_b64 s[16:17], 0
	s_cmpk_lt_i32 s47, 0x7f
	s_mov_b64 s[18:19], 0
	s_cbranch_scc0 .LBB0_47
	s_and_b64 vcc, exec, s[20:21]
	s_cbranch_vccnz .LBB0_50
.LBB0_16:
	s_andn2_b64 vcc, exec, s[18:19]
	s_cbranch_vccz .LBB0_51
.LBB0_17:
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_19
.LBB0_18:
	s_waitcnt vmcnt(30)
.LBB0_19:
	s_mov_b64 s[16:17], 0
.LBB0_20:
	s_and_b64 vcc, exec, s[16:17]
	s_cbranch_vccz .LBB0_22
	s_waitcnt vmcnt(45)
.LBB0_22:
	s_mov_b64 s[16:17], 0
.LBB0_23:
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_33
	s_mov_b64 s[16:17], -1
	s_and_b64 vcc, exec, s[14:15]
	s_cbranch_vccz .LBB0_31
	s_mov_b64 s[18:19], -1
	s_mov_b64 s[14:15], 0
	s_cmpk_lt_i32 s47, 0x7f
	s_mov_b64 s[16:17], 0
	s_cbranch_scc0 .LBB0_52
	s_and_b64 vcc, exec, s[18:19]
	s_cbranch_vccnz .LBB0_55
.LBB0_27:
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccz .LBB0_56
.LBB0_28:
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_30
.LBB0_29:
	s_waitcnt vmcnt(32)
.LBB0_30:
	s_mov_b64 s[16:17], 0
.LBB0_31:
	s_and_b64 vcc, exec, s[16:17]
	s_cbranch_vccz .LBB0_33
	s_waitcnt vmcnt(48)
.LBB0_33:
	s_mov_b64 s[14:15], 0
.LBB0_34:
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_39
	s_and_b64 vcc, exec, s[4:5]
	s_mov_b64 s[14:15], -1
	s_cbranch_vccnz .LBB0_37
	s_mov_b64 s[14:15], 0
	s_waitcnt vmcnt(3)
.LBB0_37:
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_39
	s_waitcnt vmcnt(4)
.LBB0_39:
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMEND
	s_cmp_ge_u32 s47, s44
	s_cbranch_scc1 .LBB0_10
	s_add_i32 s14, s43, s47
	s_add_i32 s15, s14, 0xffffff80
	s_cmpk_gt_i32 s14, 0x7f
	s_cselect_b32 s14, s15, s14
	s_lshl_b32 s16, s14, 7
	s_and_b64 vcc, exec, s[0:1]
	s_mov_b64 s[14:15], -1
	s_cbranch_vccnz .LBB0_44
	s_lshl_b32 s14, s24, 14
	s_add_i32 s15, s14, s25
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v32, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s26, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v33, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s27, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v34, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s28, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v35, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s29, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v36, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s30, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v37, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s31, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v38, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s33, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v39, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s34, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v40, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s35, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v41, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s36, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v42, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s37, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v43, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s38, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v44, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s39, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v45, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_add_i32 s15, s40, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v46, s[8:11], s16 offen nt lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_43
	s_add_i32 s14, s41, s14
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v47, s[8:11], s16 offen nt lds
	;;#ASMEND
.LBB0_43:
	s_mov_b64 s[14:15], 0
.LBB0_44:
	s_andn2_b64 vcc, exec, s[14:15]
	s_cbranch_vccnz .LBB0_10
	s_lshl_b32 s14, s24, 12
	s_add_i32 s14, s14, 0x14000
	s_add_i32 s15, s14, s25
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v32, s[8:11], s16 offen lds
	;;#ASMEND
	s_add_i32 s15, s26, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v33, s[8:11], s16 offen lds
	;;#ASMEND
	s_add_i32 s15, s27, s14
	;;#ASMSTART
	s_mov_b32 m0, s15
	s_nop 0
	buffer_load_dwordx4 v34, s[8:11], s16 offen lds
	;;#ASMEND
	s_and_b64 vcc, exec, s[2:3]
	s_cbranch_vccnz .LBB0_10
	s_add_i32 s14, s28, s14
	;;#ASMSTART
	s_mov_b32 m0, s14
	s_nop 0
	buffer_load_dwordx4 v35, s[8:11], s16 offen lds
	;;#ASMEND
	s_branch .LBB0_10
.LBB0_47:
	s_cmpk_eq_i32 s47, 0x7f
	s_mov_b64 s[18:19], -1
	s_cbranch_scc0 .LBB0_49
	s_waitcnt vmcnt(0)
	s_mov_b64 s[18:19], 0
.LBB0_49:
	s_branch .LBB0_16
.LBB0_50:
	s_cmpk_lg_i32 s47, 0x7d
	s_mov_b64 s[16:17], -1
	s_cselect_b64 s[18:19], -1, 0
	s_andn2_b64 vcc, exec, s[18:19]
	s_cbranch_vccnz .LBB0_17
.LBB0_51:
	s_waitcnt vmcnt(15)
	s_cbranch_execz .LBB0_18
	s_branch .LBB0_19
.LBB0_52:
	s_cmpk_eq_i32 s47, 0x7f
	s_mov_b64 s[16:17], -1
	s_cbranch_scc0 .LBB0_54
	s_waitcnt vmcnt(0)
	s_mov_b64 s[16:17], 0
.LBB0_54:
	s_branch .LBB0_27
.LBB0_55:
	s_cmpk_lg_i32 s47, 0x7d
	s_mov_b64 s[14:15], -1
	s_cselect_b64 s[16:17], -1, 0
	s_andn2_b64 vcc, exec, s[16:17]
	s_cbranch_vccnz .LBB0_28
.LBB0_56:
	s_waitcnt vmcnt(16)
	s_cbranch_execz .LBB0_29
	s_branch .LBB0_30
.LBB0_57:
	v_lshl_add_u32 v24, s45, 14, v52
	v_lshl_add_u32 v40, s46, 12, v53
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	s_waitcnt lgkmcnt(0)
	s_barrier
	;;#ASMEND
	v_add_u32_e32 v12, v24, v51
	v_add_u32_e32 v20, v40, v51
	v_add_u32_e32 v36, v24, v50
	ds_read_b128 v[0:3], v12
	ds_read_b128 v[4:7], v12 offset:2048
	ds_read_b128 v[8:11], v12 offset:4096
	ds_read_b128 v[12:15], v12 offset:6144
	ds_read_b128 v[16:19], v20
	ds_read_b128 v[20:23], v20 offset:2048
	ds_read_b128 v[24:27], v36
	ds_read_b128 v[28:31], v36 offset:2048
	ds_read_b128 v[32:35], v36 offset:4096
	ds_read_b128 v[36:39], v36 offset:6144
	v_add_u32_e32 v44, v40, v50
	ds_read_b128 v[40:43], v44
	ds_read_b128 v[44:47], v44 offset:2048
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_16x16x32_bf16 a[0:3], v[0:3], v[16:19], a[0:3]
	s_andn2_b32 s13, s13, 63
	v_mfma_f32_16x16x32_bf16 a[4:7], v[4:7], v[16:19], a[4:7]
	v_mfma_f32_16x16x32_bf16 a[8:11], v[8:11], v[16:19], a[8:11]
	v_mfma_f32_16x16x32_bf16 a[12:15], v[12:15], v[16:19], a[12:15]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_16x16x32_bf16 a[32:35], v[0:3], v[20:23], a[16:19]
	v_lshl_or_b32 v0, v49, 2, s13
	s_ashr_i32 s13, s12, 31
	s_lshl_b64 s[0:1], s[12:13], 1
	v_mfma_f32_16x16x32_bf16 a[36:39], v[4:7], v[20:23], a[20:23]
	s_add_u32 s0, s6, s0
	s_addc_u32 s1, s7, s1
	v_cmp_gt_i32_e64 s[6:7], s22, v48
	v_mfma_f32_16x16x32_bf16 a[40:43], v[8:11], v[20:23], a[24:27]
	v_mul_u32_u24_e32 v2, 0xc550, v48
	v_mov_b32_e32 v3, 0
	v_cmp_gt_i32_e32 vcc, s23, v0
	v_mfma_f32_16x16x32_bf16 a[44:47], v[12:15], v[20:23], a[28:31]
	v_lshl_add_u64 v[2:3], s[0:1], 0, v[2:3]
	s_and_b64 s[2:3], s[6:7], vcc
	v_ashrrev_i32_e32 v1, 31, v0
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_16x16x32_bf16 a[28:31], v[24:27], v[40:43], a[0:3]
	v_mfma_f32_16x16x32_bf16 a[24:27], v[28:31], v[40:43], a[4:7]
	v_mfma_f32_16x16x32_bf16 a[20:23], v[32:35], v[40:43], a[8:11]
	v_mfma_f32_16x16x32_bf16 a[16:19], v[36:39], v[40:43], a[12:15]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_16x16x32_bf16 a[12:15], v[24:27], v[44:47], a[32:35]
	v_mfma_f32_16x16x32_bf16 a[8:11], v[28:31], v[44:47], a[36:39]
	v_mfma_f32_16x16x32_bf16 a[4:7], v[32:35], v[44:47], a[40:43]
	v_mfma_f32_16x16x32_bf16 a[0:3], v[36:39], v[44:47], a[44:47]
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_59
	v_accvgpr_read_b32 v4, a28
	v_accvgpr_read_b32 v5, a29
	v_accvgpr_read_b32 v6, a30
	v_accvgpr_read_b32 v7, a31
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off
.LBB0_59:
	s_or_b64 exec, exec, s[0:1]
	v_or_b32_e32 v4, 16, v0
	v_cmp_gt_i32_e64 s[0:1], s23, v4
	s_and_b64 s[4:5], s[6:7], s[0:1]
	s_and_saveexec_b64 s[2:3], s[4:5]
	s_cbranch_execz .LBB0_61
	v_accvgpr_read_b32 v4, a24
	v_accvgpr_read_b32 v5, a25
	v_accvgpr_read_b32 v6, a26
	v_accvgpr_read_b32 v7, a27
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off offset:32
.LBB0_61:
	s_or_b64 exec, exec, s[2:3]
	v_or_b32_e32 v4, 32, v0
	v_cmp_gt_i32_e64 s[2:3], s23, v4
	s_and_b64 s[8:9], s[6:7], s[2:3]
	s_and_saveexec_b64 s[4:5], s[8:9]
	s_cbranch_execz .LBB0_63
	v_accvgpr_read_b32 v4, a20
	v_accvgpr_read_b32 v5, a21
	v_accvgpr_read_b32 v6, a22
	v_accvgpr_read_b32 v7, a23
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off offset:64
.LBB0_63:
	s_or_b64 exec, exec, s[4:5]
	v_or_b32_e32 v4, 48, v0
	v_cmp_gt_i32_e64 s[4:5], s23, v4
	s_and_b64 s[8:9], s[6:7], s[4:5]
	s_and_saveexec_b64 s[6:7], s[8:9]
	s_cbranch_execz .LBB0_65
	v_accvgpr_read_b32 v4, a16
	v_accvgpr_read_b32 v5, a17
	v_accvgpr_read_b32 v6, a18
	v_accvgpr_read_b32 v7, a19
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off offset:96
.LBB0_65:
	s_or_b64 exec, exec, s[6:7]
	v_or_b32_e32 v4, 16, v48
	v_cmp_gt_i32_e64 s[6:7], s22, v4
	s_mov_b64 s[8:9], 0xc5500
	v_lshl_add_u64 v[2:3], v[2:3], 0, s[8:9]
	s_and_b64 s[10:11], s[6:7], vcc
	s_and_saveexec_b64 s[8:9], s[10:11]
	s_cbranch_execnz .LBB0_70
	s_or_b64 exec, exec, s[8:9]
	s_and_b64 s[8:9], s[6:7], s[0:1]
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execnz .LBB0_71
.LBB0_67:
	s_or_b64 exec, exec, s[0:1]
	s_and_b64 s[2:3], s[6:7], s[2:3]
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execnz .LBB0_72
.LBB0_68:
	s_or_b64 exec, exec, s[0:1]
	s_and_b64 s[0:1], s[6:7], s[4:5]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execnz .LBB0_73
.LBB0_69:
	s_endpgm
.LBB0_70:
	v_accvgpr_read_b32 v4, a12
	v_accvgpr_read_b32 v5, a13
	v_accvgpr_read_b32 v6, a14
	v_accvgpr_read_b32 v7, a15
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off
	s_or_b64 exec, exec, s[8:9]
	s_and_b64 s[8:9], s[6:7], s[0:1]
	s_and_saveexec_b64 s[0:1], s[8:9]
	s_cbranch_execz .LBB0_67
.LBB0_71:
	v_accvgpr_read_b32 v4, a8
	v_accvgpr_read_b32 v5, a9
	v_accvgpr_read_b32 v6, a10
	v_accvgpr_read_b32 v7, a11
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off offset:32
	s_or_b64 exec, exec, s[0:1]
	s_and_b64 s[2:3], s[6:7], s[2:3]
	s_and_saveexec_b64 s[0:1], s[2:3]
	s_cbranch_execz .LBB0_68
.LBB0_72:
	v_accvgpr_read_b32 v4, a4
	v_accvgpr_read_b32 v5, a5
	v_accvgpr_read_b32 v6, a6
	v_accvgpr_read_b32 v7, a7
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[6:7], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[6:7], v[4:5], off offset:64
	s_or_b64 exec, exec, s[0:1]
	s_and_b64 s[0:1], s[6:7], s[4:5]
	s_and_saveexec_b64 s[2:3], s[0:1]
	s_cbranch_execz .LBB0_69
.LBB0_73:
	v_accvgpr_read_b32 v7, a3
	v_accvgpr_read_b32 v6, a2
	v_accvgpr_read_b32 v5, a1
	v_accvgpr_read_b32 v4, a0
	v_cvt_pk_bf16_f32 v4, v4, v5
	v_cvt_pk_bf16_f32 v5, v6, v7
	v_lshl_add_u64 v[0:1], v[0:1], 1, v[2:3]
	global_store_dwordx2 v[0:1], v[4:5], off offset:96
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
		.amdhsa_group_segment_fixed_size 94208
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 44
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
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 257
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 104
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 0
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
	.section	.text._ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,"axG",@progbits,_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi,comdat
.Lfunc_end0:
	.size	_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi, .Lfunc_end0-_ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi

	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.num_vgpr, 102
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.num_agpr, 48
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.numbered_sgpr, 48
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.private_seg_size, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.uses_vcc, 1
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.uses_flat_scratch, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_dyn_sized_stack, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_recursion, 0
	.set _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.has_indirect_call, 0
	.text
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_b2a38cc62e3d3b44,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_b2a38cc62e3d3b44
__hip_cuid_b2a38cc62e3d3b44:
	.byte	0
	.size	__hip_cuid_b2a38cc62e3d3b44, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_b2a38cc62e3d3b44
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     48
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  write_only
        .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         24
        .size:           8
        .value_kind:     global_buffer
      - .actual_access:  read_only
        .address_space:  global
        .offset:         32
        .size:           8
        .value_kind:     global_buffer
      - .offset:         40
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 94208
    .kernarg_segment_align: 8
    .kernarg_segment_size: 44
    .max_flat_workgroup_size: 128
    .name:           _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi
    .private_segment_fixed_size: 0
    .sgpr_count:     54
    .sgpr_spill_count: 0
    .symbol:         _ZN6lmhead11gemm_kernelINS_3CfgILi25256ELi8192ELi32ELi243ELi1ELi5ELi3ELi1ELi2ELi1ELi8EEEEEvPKDF16bS4_PDF16bPDv4_fPyi.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     152
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
