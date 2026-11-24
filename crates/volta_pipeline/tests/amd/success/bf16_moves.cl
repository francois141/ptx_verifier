// Instructions that move whole bf16 halves between words. `p` packs `(a, b)` and `q` packs
// `(c, d)`, low half first; each case writes its result's low half to `out[128k + i]` and its
// high half to `out[128k + 64 + i]`.
__kernel void bf16_moves(__global const float *a, __global const float *b,
                         __global const float *c, __global const float *d,
                         __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned p, q, r;
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
    out[128 * (k) + i] = low;                                                              \
    out[128 * (k) + 64 + i] = high;

    // The middle word of `p:q`: `(d, a)`.
    __asm__ volatile("v_alignbit_b32 %0, %1, %2, 16" : "=v"(r) : "v"(p), "v"(q));
    HALVES(0)
    // The low half from `p`, the high half from `q`: `(a, d)`.
    __asm__ volatile("v_bfi_b32 %0, %1, %2, %3" : "=v"(r) : "s"(0xffffu), "v"(p), "v"(q));
    HALVES(1)
    // The high half from `p`, the low half from `q`: `(c, b)`.
    __asm__ volatile("v_bfi_b32 %0, %1, %2, %3" : "=v"(r) : "s"(0xffff0000u), "v"(p), "v"(q));
    HALVES(2)
    // Bytes 0-1 of `q` and 4-5 of `p`: the low halves `(c, a)`.
    __asm__ volatile("v_perm_b32 %0, %1, %2, %3" : "=v"(r) : "v"(p), "v"(q), "s"(0x05040100u));
    HALVES(3)
    // A concrete word supplies its halves too: 1.0's high half above `a`, `(a, 1)`.
    __asm__ volatile("v_bfi_b32 %0, %1, %2, %3" : "=v"(r) : "s"(0xffffu), "v"(p), "v"(0x3f800000u));
    HALVES(4)
}
