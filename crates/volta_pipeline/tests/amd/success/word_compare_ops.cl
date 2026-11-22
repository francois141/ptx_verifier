// Integer word comparisons of f32 values: with no NaN and no signed zero, two words hold the
// same bits exactly when they hold the same real. Each row selects `x * y` where the
// comparison holds and `x` elsewhere, one comparison per column.

// Select between `x` and `x * y` on `v_cmp_<op>_u32 x, rhs`.
#define WORD_CMP(op, rhs, column) do { \
    ulong mask; \
    float result; \
    __asm__ volatile( \
        "v_cmp_" op "_u32_e64 %1, %2, %3\n\t" \
        "v_cndmask_b32_e64 %0, %2, %4, %1" \
        : "=&v"(result), "=&s"(mask) : "v"(x), "v"(rhs), "v"(x * y)); \
    out[4 * i + column] = result; \
} while (0)

__kernel void word_compare_ops(__global const float *a, __global const float *b,
                               __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i];
    WORD_CMP("eq", y, 0);
    WORD_CMP("ne", y, 1);
    // Zero's word is the real 0.
    WORD_CMP("eq", 0.0f, 2);
    // A word always equals itself.
    WORD_CMP("eq", x, 3);
}
