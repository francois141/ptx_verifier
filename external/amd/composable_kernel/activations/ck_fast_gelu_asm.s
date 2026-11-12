	.amdgcn_target "amdgcn-amd-amdhsa--gfx950:xnack-"
	.amdhsa_code_object_version 6
	.text
	.protected	ck_fast_gelu_asm
	.globl	ck_fast_gelu_asm
	.p2align	8
	.type	ck_fast_gelu_asm,@function
ck_fast_gelu_asm:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v2, 0xbfcc4231
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_mov_b32 s0, 0xbd92220c
	s_mov_b32 s1, 0x3fb8aa3b
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_mul_f32 v2, v1, v1        ; x*x
v_fma_f32 v2, v2, s0, v2  ; c1*x*x+c2
v_mul_f32 v2, v2, v1      ; x*(c1*x*x+c2)
v_mul_f32 v2, v2, s1  ; log2e*x*(c1*x*x+c2)
v_exp_f32 v2, v2              ; emu = exp2(log2e*x*(c1*x*x+c2))
s_nop 0                                   ; hazard for exp
v_add_f32 v2, v2, 1.0         ; emu+1.0f
v_rcp_f32 v2, v2              ; 1/(emu+1.0f)
s_nop 0                                   ; hazard for rcp 
v_mul_f32 v1, v2, v1        ; x * 1/(emu+1f)

	;;#ASMEND
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_fast_gelu_asm
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 3
		.amdhsa_next_free_sgpr 4
		.amdhsa_accum_offset 4
		.amdhsa_reserve_vcc 0
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
	.text
.Lfunc_end0:
	.size	ck_fast_gelu_asm, .Lfunc_end0-ck_fast_gelu_asm

	.set ck_fast_gelu_asm.num_vgpr, 3
	.set ck_fast_gelu_asm.num_agpr, 0
	.set ck_fast_gelu_asm.numbered_sgpr, 4
	.set ck_fast_gelu_asm.private_seg_size, 0
	.set ck_fast_gelu_asm.uses_vcc, 0
	.set ck_fast_gelu_asm.uses_flat_scratch, 0
	.set ck_fast_gelu_asm.has_dyn_sized_stack, 0
	.set ck_fast_gelu_asm.has_recursion, 0
	.set ck_fast_gelu_asm.has_indirect_call, 0
	.protected	ck_fast_gelu_asm_fixed
	.globl	ck_fast_gelu_asm_fixed
	.p2align	8
	.type	ck_fast_gelu_asm_fixed,@function
ck_fast_gelu_asm_fixed:
	s_load_dwordx4 s[0:3], s[0:1], 0x0
	v_lshlrev_b32_e32 v0, 2, v0
	v_mov_b32_e32 v2, 0xbfcc4231
	s_waitcnt lgkmcnt(0)
	global_load_dword v1, v0, s[0:1]
	s_mov_b32 s0, 0xbd92220c
	s_mov_b32 s1, 0x3fb8aa3b
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	v_mul_f32 v3, v1, v1        ; x*x
v_fma_f32 v3, v3, s0, v2  ; c1*x*x+c2
v_mul_f32 v3, v3, v1      ; x*(c1*x*x+c2)
v_mul_f32 v3, v3, s1  ; log2e*x*(c1*x*x+c2)
v_exp_f32 v3, v3              ; emu = exp2(log2e*x*(c1*x*x+c2))
s_nop 0                                   ; hazard for exp
v_add_f32 v3, v3, 1.0         ; emu+1.0f
v_rcp_f32 v3, v3              ; 1/(emu+1.0f)
s_nop 0                                   ; hazard for rcp 
v_mul_f32 v1, v3, v1        ; x * 1/(emu+1f)

	;;#ASMEND
	global_store_dword v0, v1, s[2:3]
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel ck_fast_gelu_asm_fixed
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 16
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
		.amdhsa_next_free_vgpr 4
		.amdhsa_next_free_sgpr 4
		.amdhsa_accum_offset 4
		.amdhsa_reserve_vcc 0
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
	.text
.Lfunc_end1:
	.size	ck_fast_gelu_asm_fixed, .Lfunc_end1-ck_fast_gelu_asm_fixed

	.set ck_fast_gelu_asm_fixed.num_vgpr, 4
	.set ck_fast_gelu_asm_fixed.num_agpr, 0
	.set ck_fast_gelu_asm_fixed.numbered_sgpr, 4
	.set ck_fast_gelu_asm_fixed.private_seg_size, 0
	.set ck_fast_gelu_asm_fixed.uses_vcc, 0
	.set ck_fast_gelu_asm_fixed.uses_flat_scratch, 0
	.set ck_fast_gelu_asm_fixed.has_dyn_sized_stack, 0
	.set ck_fast_gelu_asm_fixed.has_recursion, 0
	.set ck_fast_gelu_asm_fixed.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_d008f26d62dea00e,@object
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_d008f26d62dea00e
__hip_cuid_d008f26d62dea00e:
	.byte	0
	.size	__hip_cuid_d008f26d62dea00e, 1

	.ident	"Homebrew clang version 21.1.8"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_d008f26d62dea00e
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .max_flat_workgroup_size: 1024
    .name:           ck_fast_gelu_asm
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         ck_fast_gelu_asm.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     3
    .vgpr_spill_count: 0
    .wavefront_size: 64
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
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 16
    .max_flat_workgroup_size: 1024
    .name:           ck_fast_gelu_asm_fixed
    .private_segment_fixed_size: 0
    .sgpr_count:     10
    .sgpr_spill_count: 0
    .symbol:         ck_fast_gelu_asm_fixed.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     4
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   'amdgcn-amd-amdhsa--gfx950:xnack-'
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
