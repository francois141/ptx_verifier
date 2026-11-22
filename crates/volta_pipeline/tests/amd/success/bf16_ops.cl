// Instruction idioms over a word holding two bf16 halves. Each work-item writes `out[i]` from
// the low half and `out[64 + i]` from the high half.
__kernel void bf16_ops(__global const float *a, __global const float *b, __global float *out) {
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
}
