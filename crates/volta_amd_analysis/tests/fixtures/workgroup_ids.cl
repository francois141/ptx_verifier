// Store the selected workgroup coordinates from kernels using one axis or all three.
// The single-axis kernels also exercise descriptors with unused workgroup-ID inputs.
__kernel void workgroup_x(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_x();
}

__kernel void workgroup_y(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_y();
}

__kernel void workgroup_z(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_z();
}

__kernel void workgroup_xyz(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_x();
    out[i + 64] = __builtin_amdgcn_workgroup_id_y();
    out[i + 128] = __builtin_amdgcn_workgroup_id_z();
}

// Keep global stores in the supported SGPR-base form. Reading each base word from
// lane 0 also keeps it scalar in Clang's callable helper; kernel arguments are uniform.
#define STORE_WORD(base, index, value) do { \
    ulong store_address = (ulong)(base); \
    ulong store_base = (unsigned)__builtin_amdgcn_readfirstlane((unsigned)store_address); \
    store_base |= (ulong)(unsigned)__builtin_amdgcn_readfirstlane((unsigned)(store_address >> 32)) << 32; \
    __asm__ volatile("global_store_dword %0, %1, %2" \
        : : "v"(4u * (index)), "v"(value), "s"(store_base) : "memory"); \
} while (0)

// Workgroup-dependent words keep their integer bits across LDS and lane exchanges. The
// address calculation reads the workgroup ID but produces the same LDS addresses in each.
__kernel void grid_lds_words(__global unsigned *out, __global float *converted) {
    __local unsigned shared[64];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned group = __builtin_amdgcn_workgroup_id_x(), zero;
    __asm__ volatile("s_and_b32 %0, %1, 0" : "=s"(zero) : "s"(group) : "scc");
    shared[i + zero] = 64 * group + i + 1;
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");

    unsigned word, bits, exchanged;
    float value;
    __asm__ volatile(
        "ds_read_b32 %0, %4\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "v_xor_b32_e32 %1, 85, %0\n\t"
        "v_cvt_f32_u32_e32 %2, %0\n\t"
        "ds_bpermute_b32 %3, %5, %0\n\t"
        "s_waitcnt lgkmcnt(0)"
        : "=&v"(word), "=&v"(bits), "=&v"(value), "=&v"(exchanged)
        : "v"((unsigned)&shared[i ^ 1]), "v"(4 * (i ^ 2)) : "memory");
    STORE_WORD(out, 192 * group + i, word);
    STORE_WORD(out, 192 * group + 64 + i, bits);
    STORE_WORD(out, 192 * group + 128 + i, exchanged);
    STORE_WORD(converted, 64 * group + i, value);
}

// Both workgroups take the same branch, although their VCC masks select different lanes.
__kernel void grid_vcc_branch(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned group = __builtin_amdgcn_workgroup_id_x(), result;
    __asm__ volatile(
        "v_cmp_eq_u32_e32 vcc, %1, %2\n\t"
        "v_mov_b32_e32 %0, 0\n\t"
        "s_cbranch_vccz .Lgrid_vcc_done_%=\n\t"
        "v_cndmask_b32_e32 %0, 0, %3, vcc\n"
        ".Lgrid_vcc_done_%=:"
        : "=&v"(result) : "s"(group), "v"(i), "v"(17) : "vcc");
    STORE_WORD(out, 64 * group + i, result);
}

// The same instruction writes different LDS addresses in the two workgroups.
__kernel void grid_lds_addresses(__global unsigned *out) {
    __local unsigned shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned group = __builtin_amdgcn_workgroup_id_x();
    __asm__ volatile(
        "ds_write_b32 %0, %1\n\t"
        "s_waitcnt lgkmcnt(0)"
        : : "v"((unsigned)&shared[64 * group + i]), "v"(i) : "memory");
    STORE_WORD(out, 64 * group + i, i);
}

// Workgroup 1 reads a NaN from LDS. Multiplication by zero must still validate that source.
__kernel void grid_lds_nan(__global float *out) {
    __local unsigned shared[64];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned group = __builtin_amdgcn_workgroup_id_x();
    shared[i] = 0x3fc00000u | (group << 30);
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");
    float result;
    __asm__ volatile(
        "ds_read_b32 %0, %1\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "v_mul_f32_e32 %0, 0, %0"
        : "=&v"(result) : "v"((unsigned)&shared[i]) : "memory");
    STORE_WORD(out, 64 * group + i, result);
}
