// Instructions over words holding two bf16 halves. Each work-item writes `out[i]` from the
// low half and `out[64 + i]` from the high half, then the same for an LDS word at `128 + i`.
__kernel void bf16_ops(__global const float *a, __global const float *b, __global float *out) {
    __local ushort shared[64];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i], low, high;

    // XOR with 0x80008000 flips both halves' sign bits, negating each real.
    unsigned packed;
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %3, %4\n\t"
        "v_xor_b32_e32 %0, 0x80008000, %0\n\t"
        "v_lshlrev_b32_e32 %1, 16, %0\n\t"
        "v_and_b32_e32 %2, 0xffff0000, %0"
        : "=&v"(packed), "=&v"(low), "=&v"(high) : "v"(x), "v"(y));
    out[i] = low;
    out[64 + i] = high;

    // A 16-bit LDS store writes x as element `i`, one half of a word, keeping the other: each
    // lane then reads the word of elements `2k` and `2k + 1`, for `k = i / 2`.
    unsigned pair;
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %4, %4\n\t"
        "ds_write_b16 %5, %0\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "ds_read_b32 %1, %6\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "v_lshlrev_b32_e32 %2, 16, %1\n\t"
        "v_and_b32_e32 %3, 0xffff0000, %1"
        : "=&v"(packed), "=&v"(pair), "=&v"(low), "=&v"(high)
        : "v"(x), "v"((unsigned)&shared[i]), "v"((unsigned)&shared[i & ~1u])
        : "memory");
    out[128 + i] = low;
    out[192 + i] = high;
}
