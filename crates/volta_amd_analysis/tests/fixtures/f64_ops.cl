// Each work-item writes one row of f64 results converted back to f32, and one row of integer
// conversions. Inline assembly keeps each form; `constant_bits` holds the bits of an f64.

// Convert x, y and z to f64 in %1, %2 and %3, run `body`, and write %1 converted back to f32.
#define F64(body, column) do { \
    float result; \
    ulong p, q, r; \
    __asm__ volatile( \
        "v_cvt_f64_f32_e32 %1, %4\n\t" \
        "v_cvt_f64_f32_e32 %2, %5\n\t" \
        "v_cvt_f64_f32_e32 %3, %6\n\t" \
        body "\n\t" \
        "v_cvt_f32_f64_e32 %0, %1" \
        : "=&v"(result), "=&v"(p), "=&v"(q), "=&v"(r) : "v"(x), "v"(y), "v"(z)); \
    row[column] = result; \
} while (0)

// Select between x and y on one comparison in both encodings, the e64 form with |x|.
#define COMPARE(predicate, column) do { \
    float e32, e64; \
    ulong p, q, mask; \
    __asm__ volatile( \
        "v_cvt_f64_f32_e32 %2, %5\n\t" \
        "v_cvt_f64_f32_e32 %3, %6\n\t" \
        "v_cmp_" #predicate "_f64_e32 vcc, %2, %3\n\t" \
        "v_cndmask_b32_e64 %0, %5, %6, vcc\n\t" \
        "v_cmp_" #predicate "_f64_e64 %4, |%2|, %3\n\t" \
        "v_cndmask_b32_e64 %1, %5, %6, %4" \
        : "=&v"(e32), "=&v"(e64), "=&v"(p), "=&v"(q), "=&s"(mask) : "v"(x), "v"(y) : "vcc"); \
    row[column] = e32; \
    row[(column) + 1] = e64; \
} while (0)

__kernel void f64_ops(__global const float *a, __global const float *b, __global const float *c,
                      __global float *out, __global unsigned *int_out, ulong constant_bits) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i], z = c[i];
    __global float *row = out + 64 * i;
    __global unsigned *int_row = int_out + 8 * i;

    // Keep the constant scalar in both the kernel entry and Clang's callable helper.
    ulong scalar_constant = (unsigned)__builtin_amdgcn_readfirstlane((unsigned)constant_bits);
    scalar_constant |=
        (ulong)(unsigned)__builtin_amdgcn_readfirstlane((unsigned)(constant_bits >> 32)) << 32;

    F64("v_add_f64 %1, %1, %2", 0);
    F64("v_mul_f64 %1, %1, %2", 1);
    F64("v_min_f64 %1, %1, %2", 2);
    F64("v_max_f64 %1, %1, %2", 3);
    F64("v_fma_f64 %1, %1, %2, %3", 4);
    F64("v_rcp_f64_e32 %1, %1", 5);
    F64("v_sqrt_f64_e32 %1, %1", 6);
    F64("v_rsq_f64_e32 %1, %1", 7);

    // Input modifiers apply to any source of a 64-bit encoding.
    F64("v_rcp_f64_e64 %1, -%1", 8);
    F64("v_add_f64 %1, -|%1|, |%2|", 9);
    F64("v_fma_f64 %1, -%1, |%2|, -|%3|", 10);

    // Moves keep an f64 whole.
    F64("v_mov_b64_e32 %3, %1\n\tv_mov_b64_e32 %1, %3", 11);
    F64("v_pk_mov_b32 %3, %1, %1 op_sel:[0,1]\n\tv_mov_b64_e32 %1, %3", 12);

    // An inline float keeps its value, and an inline integer gives its bits.
    F64("v_mul_f64 %1, %1, 2.0", 13);
    F64("v_add_f64 %1, %1, 0", 14);

    // Conversions take modifiers in their 64-bit encodings.
    float result;
    ulong pair;
    __asm__ volatile(
        "v_cvt_f64_f32_e64 %1, -|%2|\n\t"
        "v_cvt_f32_f64_e64 %0, -%1"
        : "=&v"(result), "=&v"(pair) : "v"(x));
    row[15] = result;

    // A destination may overlap its source, and an SGPR pair holds an f64's bits.
    __asm__ volatile(
        "v_mov_b32_e32 v2, %1\n\t"
        "v_cvt_f64_f32_e32 v[2:3], v2\n\t"
        "v_mul_f64 v[2:3], v[2:3], %2\n\t"
        "v_cvt_f32_f64_e32 v2, v[2:3]\n\t"
        "v_mov_b32_e32 %0, v2"
        : "=&v"(result) : "v"(x), "s"(scalar_constant) : "v2", "v3");
    row[16] = result;

    // Concrete words convert exactly, including an infinity.
    __asm__ volatile(
        "v_mov_b32_e32 v2, 0xff800000\n\t"
        "v_cvt_f64_f32_e32 v[2:3], v2\n\t"
        "v_mul_f64 v[2:3], v[2:3], %1\n\t"
        "v_cvt_f32_f64_e32 %0, v[2:3]"
        : "=&v"(result) : "s"(scalar_constant) : "v2", "v3");
    row[17] = result;

    // A literal supplies an f64's high word.
    __asm__ volatile("v_cvt_f32_f64_e32 %0, 0x40000000" : "=v"(result));
    row[18] = result;

    // Two concrete words in a VGPR pair encode an f64.
    __asm__ volatile(
        "v_mov_b64_e32 %1, %2\n\t"
        "v_cvt_f32_f64_e32 %0, %1"
        : "=&v"(result), "=&v"(pair) : "s"(scalar_constant));
    row[19] = result;

    COMPARE(lt, 20);
    COMPARE(eq, 22);
    COMPARE(le, 24);
    COMPARE(gt, 26);
    COMPARE(lg, 28);
    COMPARE(ge, 30);
    COMPARE(nge, 32);
    COMPARE(nlg, 34);
    COMPARE(ngt, 36);
    COMPARE(nle, 38);
    COMPARE(neq, 40);
    COMPARE(nlt, 42);

    // Integer conversions round-trip, truncate toward zero and clamp to their result's range.
    int value = (int)i - 32;
    unsigned word;
    __asm__ volatile(
        "v_cvt_f64_i32_e32 %1, %2\n\t"
        "v_cvt_i32_f64_e32 %0, %1"
        : "=&v"(word), "=&v"(pair) : "v"(value));
    int_row[0] = word;
    unsigned positive = i + 7;
    __asm__ volatile(
        "v_cvt_f64_u32_e32 %1, %2\n\t"
        "v_cvt_u32_f64_e32 %0, %1"
        : "=&v"(word), "=&v"(pair) : "v"(positive));
    int_row[1] = word;
    __asm__ volatile("v_cvt_i32_f64_e32 %0, 0x40040000" : "=v"(word));
    int_row[2] = word;
    __asm__ volatile("v_cvt_u32_f64_e32 %0, -4.0" : "=v"(word));
    int_row[3] = word;
    __asm__ volatile(
        "v_cvt_f64_i32_e64 %1, %2\n\t"
        "v_cvt_i32_f64_e64 %0, -%1"
        : "=&v"(word), "=&v"(pair) : "v"(value));
    int_row[4] = word;

    // The literals are the high words of 2^32 and -2^32.
    __asm__ volatile("v_cvt_i32_f64_e32 %0, 0x41f00000" : "=v"(word));
    int_row[5] = word;
    __asm__ volatile("v_cvt_i32_f64_e32 %0, 0xc1f00000" : "=v"(word));
    int_row[6] = word;
    __asm__ volatile("v_cvt_u32_f64_e32 %0, 0x41f00000" : "=v"(word));
    int_row[7] = word;
}
