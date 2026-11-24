// Packing bf16 halves by OR: `v_and_b32` and the 16-bit shifts leave one half zero, and OR joins
// two such words. `p` packs `(a, b)` and `q` packs `(c, d)`, low half first; output `k` holds
// `out[64k + i]`.
__kernel void bf16_pack(__global const float *a, __global const float *b,
                        __global const float *c, __global const float *d,
                        __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned p, q, x, y, r;
    float low, high;
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %2, %3\n\t"
        "v_cvt_pk_bf16_f32 %1, %4, %5"
        : "=&v"(p), "=&v"(q) : "v"(a[i]), "v"(b[i]), "v"(c[i]), "v"(d[i]));

#define HALVES(k)                                                                          \
    __asm__ volatile(                                                                      \
        "v_lshlrev_b32_e32 %0, 16, %2\n\t"                                                 \
        "v_and_b32_e32 %1, 0xffff0000, %2"                                                 \
        : "=&v"(low), "=&v"(high) : "v"(r));                                               \
    out[64 * (k) + i] = low;                                                               \
    out[64 * (k) + 64 + i] = high;

    // Swapping `p`'s halves: `(b, a)`.
    __asm__ volatile(
        "v_lshrrev_b32_e32 %1, 16, %3\n\t"
        "v_lshlrev_b32_e32 %2, 16, %3\n\t"
        "v_or_b32_e32 %0, %1, %2"
        : "=v"(r), "=&v"(x), "=&v"(y) : "v"(p));
    HALVES(0)
    // The low halves of `p` and `q`: `(a, c)`.
    __asm__ volatile(
        "v_and_b32_e32 %1, 0xffff, %3\n\t"
        "v_lshlrev_b32_e32 %2, 16, %4\n\t"
        "v_or_b32_e32 %0, %2, %1"
        : "=v"(r), "=&v"(x), "=&v"(y) : "v"(p), "v"(q));
    HALVES(2)
    // Three words joined by `v_or3_b32`: `(d, b)`.
    __asm__ volatile(
        "v_and_b32_e32 %1, 0xffff0000, %3\n\t"
        "v_lshrrev_b32_e32 %2, 16, %4\n\t"
        "v_or3_b32 %0, %1, %2, 0"
        : "=v"(r), "=&v"(x), "=&v"(y) : "v"(p), "v"(q));
    HALVES(4)
    // A concrete word's half, bf16 1.0, below `b`: `(1, b)`.
    __asm__ volatile(
        "v_and_b32_e32 %1, 0xffff0000, %2\n\t"
        "v_or_b32_e32 %0, 0x3f80, %1"
        : "=v"(r), "=&v"(x) : "v"(p));
    HALVES(6)
    // A word whose low half is zero is the f32 of its high half: `b + c`.
    float sum;
    __asm__ volatile(
        "v_and_b32_e32 %1, 0xffff0000, %2\n\t"
        "v_add_f32_e32 %0, %1, %3"
        : "=v"(sum), "=&v"(x) : "v"(p), "v"(c[i]));
    out[512 + i] = sum;
}
