// `v_bfe_{u,i}32` of 16 bits at offset 0 or 16 moves one bf16 half of `p = (a, b)` to the low
// half, read back with `v_lshlrev_b32 16`. Above it the unsigned form leaves zeros, so an OR can
// add `q = (c, d)`'s low half there.
__kernel void bf16_extract(__global const float *a, __global const float *b,
                           __global const float *c, __global const float *d,
                           __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned p, q, x, y;
    float r[5];
    __asm__ volatile(
        "v_cvt_pk_bf16_f32 %0, %2, %3\n\t"
        "v_cvt_pk_bf16_f32 %1, %4, %5"
        : "=&v"(p), "=&v"(q) : "v"(a[i]), "v"(b[i]), "v"(c[i]), "v"(d[i]));
    // `a`, `b` and, through the signed form, `b`.
    __asm__ volatile(
        "v_bfe_u32 %1, %2, 0, 16\n\t"
        "v_lshlrev_b32_e32 %0, 16, %1"
        : "=v"(r[0]), "=&v"(x) : "v"(p));
    __asm__ volatile(
        "v_bfe_u32 %1, %2, 16, 16\n\t"
        "v_lshlrev_b32_e32 %0, 16, %1"
        : "=v"(r[1]), "=&v"(x) : "v"(p));
    __asm__ volatile(
        "v_bfe_i32 %1, %2, 16, 16\n\t"
        "v_lshlrev_b32_e32 %0, 16, %1"
        : "=v"(r[2]), "=&v"(x) : "v"(p));
    // `(b, c)`, its halves `b` and `c`.
    __asm__ volatile(
        "v_bfe_u32 %2, %4, 16, 16\n\t"
        "v_lshlrev_b32_e32 %3, 16, %5\n\t"
        "v_or_b32_e32 %3, %2, %3\n\t"
        "v_lshlrev_b32_e32 %0, 16, %3\n\t"
        "v_and_b32_e32 %1, 0xffff0000, %3"
        : "=&v"(r[3]), "=&v"(r[4]), "=&v"(x), "=&v"(y) : "v"(p), "v"(q));
    for (int k = 0; k < 5; ++k)
        out[64 * k + i] = r[k];
}
