// Compiled with -cl-fast-relaxed-math in addition to the copy fixture's flags. Each work-item
// writes one result per operation to its own 32-float row of `out`.
__kernel void float_ops(__global const float *a, __global const float *b, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i];
    __global float *row = out + 32 * i;
    row[2] = sqrt(x);
    row[3] = __builtin_amdgcn_rsqf(x);
    row[4] = __builtin_amdgcn_exp2f(x);
    row[5] = __builtin_amdgcn_logf(x);
    row[6] = 1.0f / x;
    row[7] = x + y;
    row[8] = x - y;
    row[9] = x * y;
    row[10] = x / y;
    row[11] = fmin(x, y);
    row[12] = fmax(x, y);
    row[13] = fma(x, y, x);
    row[14] = x < y ? x : 2.0f;
    row[15] = x > y ? x : x * y;
    row[16] = x <= y ? x : x * y;
    row[17] = x >= y ? x : x * y;
    row[18] = x == y ? x : x * y;
    row[19] = x != y ? x : x * y;

    // An absolute-value comparison reads a concrete float from a scalar register.
    unsigned negative = __builtin_amdgcn_readfirstlane(as_uint(-2.0f));
    unsigned uniform = __builtin_amdgcn_readfirstlane(as_uint(x));
    float result;
    __asm__ volatile(
        "v_cmp_gt_f32_e64 vcc, |%1|, %2\n\t"
        "v_cndmask_b32_e32 %0, %2, %3, vcc"
        : "=&v"(result) : "s"(negative), "v"(x), "v"(y) : "vcc");
    row[0] = result;

    // Vector sources can also use absolute value, with predicates in an SGPR pair or VCC.
    ulong mask;
    __asm__ volatile(
        "v_cmp_neq_f32_e64 %1, |%2|, %4\n\t"
        "v_cndmask_b32_e64 %0, %2, %3, %1"
        : "=&v"(result), "=&s"(mask) : "v"(x), "v"(y), "s"(uniform));
    row[20] = result;
    __asm__ volatile(
        "v_cmp_gt_f32_e64 vcc, %1, |%2|\n\t"
        "v_cndmask_b32_e32 %0, %1, %2, vcc"
        : "=&v"(result) : "v"(x), "v"(y) : "vcc");
    row[21] = result;

    // A comparison of concrete infinities folds to a word mask that a scalar instruction reads.
    unsigned positive_infinity = __builtin_amdgcn_readfirstlane(0x7f800000);
    __asm__ volatile(
        "v_mov_b32_e32 %0, 0xff800000\n\t"
        "v_cmp_neq_f32_e64 %1, |%0|, %2\n\t"
        "s_or_b64 %1, %1, 0\n\t"
        "v_cndmask_b32_e64 %0, %3, %4, %1"
        : "=&v"(result), "=&s"(mask) : "s"(positive_infinity), "v"(x), "v"(y) : "scc");
    row[1] = result;

    // Negate each FMA source in turn; the negated addend also reads a scalar first source.
    __asm__ volatile("v_fma_f32 %0, -%1, %2, %1"
                     : "=v"(result) : "v"(x), "v"(y));
    row[22] = result;
    __asm__ volatile("v_fma_f32 %0, %1, -%2, %1"
                     : "=v"(result) : "v"(x), "v"(y));
    row[23] = result;
    __asm__ volatile("v_fma_f32 %0, %1, %2, -%3"
                     : "=v"(result) : "s"(uniform), "v"(x), "v"(y));
    row[24] = result;

    // Either modifier applies to any source: the absolute value first, then the negation.
    __asm__ volatile("v_fma_f32 %0, -|%1|, %2, |%2|"
                     : "=v"(result) : "v"(x), "v"(y));
    row[25] = result;
    __asm__ volatile(
        "v_cmp_lt_f32_e64 vcc, -%1, -|%2|\n\t"
        "v_cndmask_b32_e32 %0, %1, %2, vcc"
        : "=&v"(result) : "v"(x), "v"(y) : "vcc");
    row[26] = result;

    // E64 selects and three-source operations accept the same modifiers.
    __asm__ volatile(
        "v_cmp_lt_f32_e64 %1, %2, %3\n\t"
        "v_cndmask_b32_e64 %0, |%2|, -|%3|, %1"
        : "=&v"(result), "=&s"(mask) : "v"(x), "v"(y));
    row[27] = result;
    __asm__ volatile("v_max3_f32 %0, -%1, |%2|, %1"
                     : "=v"(result) : "v"(x), "v"(y));
    row[28] = result;

    // LLVM's IEEE division sequence for x / y, which over the reals scales nothing: the
    // scales are their first source and clear VCC, so its corrections cancel to x / y.
    float scaled_y, scaled_x, reciprocal, quotient, error;
    ulong scaled;
    __asm__ volatile(
        "v_div_scale_f32 %1, %6, %8, %8, %7\n\t"
        "v_div_scale_f32 %2, vcc, %7, %8, %7\n\t"
        "v_rcp_f32_e32 %3, %1\n\t"
        "v_fma_f32 %5, -%1, %3, 1.0\n\t"
        "v_fma_f32 %3, %5, %3, %3\n\t"
        "v_mul_f32_e32 %4, %2, %3\n\t"
        "v_fma_f32 %5, -%1, %4, %2\n\t"
        "v_fma_f32 %4, %5, %3, %4\n\t"
        "v_fma_f32 %5, -%1, %4, %2\n\t"
        "v_div_fmas_f32 %4, %5, %3, %4\n\t"
        "v_div_fixup_f32 %0, %4, %8, %7"
        : "=&v"(result), "=&v"(scaled_y), "=&v"(scaled_x), "=&v"(reciprocal),
          "=&v"(quotient), "=&v"(error), "=&s"(scaled)
        : "v"(x), "v"(y) : "vcc");
    row[29] = result;

    // A packed half whose source is no f32, here a NaN pattern, is undefined, which only a
    // result that uses it rejects: the low half read back as an f32 is x.
    unsigned nan_bits;
    __asm__ volatile(
        "v_mov_b32_e32 %1, -1\n\t"
        "v_cvt_pk_bf16_f32 %0, %2, %1\n\t"
        "v_lshlrev_b32_e32 %0, 16, %0"
        : "=&v"(result), "=&v"(nan_bits) : "v"(x));
    row[30] = result;
}
