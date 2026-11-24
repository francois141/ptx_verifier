// The SDWA forms beyond `v_and` and `v_cndmask` of a first-source half: `v_or`, `v_xor` and
// `v_lshlrev`, a half of the second source, and `sext()`. `p` packs `(a, b)` and `q` packs
// `(c, d)`; output `k` holds `out[64k + i]`.
__kernel void sdwa_forms(__global const float *a, __global const float *b,
                         __global const float *c, __global const float *d,
                         __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], z = c[i];
    unsigned p, q, high, w[3];
    float h[8];
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %3, %4\n\t"
        "v_cvt_pk_bf16_f32 %1, %5, %6\n\t"
        "v_and_b32_e32 %2, 0xffff0000, %1"
        : "=&v"(p), "=&v"(q), "=&v"(high) : "v"(x), "v"(b[i]), "v"(z), "v"(d[i]));
    // `p`'s high half below `q`'s, as either source: `(b, d)` twice.
    __asm__ volatile(
        "v_or_b32_sdwa %0, %1, %2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD"
        : "=v"(w[0]) : "v"(p), "v"(high));
    __asm__ volatile(
        "v_or_b32_sdwa %0, %1, %2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1"
        : "=v"(w[1]) : "v"(high), "v"(p));
    // `a <= c ? (a, 0) : q`, `v_cndmask` selecting its second source's low half:
    // `(min(a, c), a <= c ? 0 : d)`.
    __asm__ volatile(
        "v_cmp_le_f32_e32 vcc, %1, %2\n\t"
        "v_cndmask_b32_sdwa %0, %3, %4, vcc dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_0"
        : "=v"(w[2]) : "v"(x), "v"(z), "v"(q), "v"(p) : "vcc");
    for (int k = 0; k < 3; ++k)
        __asm__ volatile(
            "v_lshlrev_b32_e32 %0, 16, %2\n\t"
            "v_and_b32_e32 %1, 0xffff0000, %2"
            : "=&v"(h[2 * k]), "=&v"(h[2 * k + 1]) : "v"(w[k]));
    // `p`'s high half shifted to the top: `b`.
    __asm__ volatile(
        "v_lshlrev_b32_sdwa %0, 16, %1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1"
        : "=v"(h[6]) : "v"(p));
    // `sext(0xbf80)` is `0xffffbf80`, which `0xc07fbf80` flips to `0x3f800000`: `1`. Zero
    // extension would give `0xc07f0000` instead.
    __asm__ volatile(
        "v_xor_b32_sdwa %0, sext(%1), %2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD"
        : "=v"(h[7]) : "v"(0xbf800000u), "v"(0xc07fbf80u));
    for (int k = 0; k < 8; ++k)
        out[64 * k + i] = h[k];
}
