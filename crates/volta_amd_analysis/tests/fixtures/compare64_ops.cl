// Each work-item compares 64-bit integers in both encodings: e32 reads 0 from a VGPR pair and
// compares it with the lane's value, and e64 compares the value with an inline 0. Inline assembly
// keeps each comparison, and a select turns its predicate into a result word.
#define COMPARE(predicate, column) do { \
    unsigned e32, e64; \
    ulong mask; \
    __asm__ volatile( \
        "v_cmp_" #predicate "_e32 vcc, %3, %4\n\t" \
        "v_cndmask_b32_e64 %0, 0, 1, vcc\n\t" \
        "v_cmp_" #predicate "_e64 %2, %4, 0\n\t" \
        "v_cndmask_b32_e64 %1, 0, 1, %2" \
        : "=&v"(e32), "=&v"(e64), "=&s"(mask) : "v"(zero), "v"(value) : "vcc"); \
    row[column] = e32; \
    row[(column) + 1] = e64; \
} while (0)

__kernel void compare64_ops(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 32 * i;
    // Lanes below 32 are negative, which separates the signed comparisons from the unsigned ones.
    ulong zero = 0, value = (ulong)(long)(int)(i - 32);
    COMPARE(lt_i64, 0);
    COMPARE(eq_i64, 2);
    COMPARE(le_i64, 4);
    COMPARE(gt_i64, 6);
    COMPARE(ne_i64, 8);
    COMPARE(ge_i64, 10);
    COMPARE(lt_u64, 12);
    COMPARE(eq_u64, 14);
    COMPARE(le_u64, 16);
    COMPARE(gt_u64, 18);
    COMPARE(ne_u64, 20);
    COMPARE(ge_u64, 22);

    // A 64-bit move also reads a VGPR pair, low word first.
    ulong moved;
    __asm__ volatile("v_mov_b64_e32 %0, %1" : "=v"(moved) : "v"(value));
    row[24] = (unsigned)moved;
    row[25] = (unsigned)(moved >> 32);
}
