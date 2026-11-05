// Each work-item writes one row of vector integer results. Inline assembly keeps each
// instruction's operand form, with scalar sources taken from the kernel arguments.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))
#define SCALAR64(value) (SCALAR32(value) | ((ulong)SCALAR32((value) >> 32) << 32))

// Write 1 to a column when the scalar is below 0x7fffffff as a signed 64-bit integer, else 0.
#define BELOW_BOUND(value, column) do { \
    ulong scalar = SCALAR64(value), bound; \
    unsigned below; \
    __asm__ volatile( \
        "v_mov_b64_e32 %1, 0x7fffffff\n\t" \
        "v_cmp_lt_i64_e32 vcc, %2, %1\n\t" \
        "v_cndmask_b32_e64 %0, 0, 1, vcc" \
        : "=&v"(below), "=&v"(bound) : "s"(scalar) : "vcc"); \
    row[column] = below; \
} while (0)

__kernel void vector_int_ops(__global unsigned *out, unsigned factor, unsigned mask,
                             ulong high_decides, ulong low_decides, ulong below_bound,
                             ulong negative, ulong equal) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 32 * i;
    unsigned scalar_factor = SCALAR32(factor), scalar_mask = SCALAR32(mask);

    // The product exceeds 32 bits, so only its low word remains. Either source may be the SGPR.
    unsigned value = i + 0x10000, product;
    __asm__ volatile("v_mul_lo_u32 %0, %1, %2" : "=v"(product) : "v"(value), "s"(scalar_factor));
    row[0] = product;
    __asm__ volatile("v_mul_lo_u32 %0, %1, %2" : "=v"(product) : "s"(scalar_factor), "v"(value));
    row[1] = product;

    // With a full mask, the low count stops at 32 and adding the high count gives the lane.
    unsigned low_count, lane;
    __asm__ volatile("v_mbcnt_lo_u32_b32 %0, -1, 0" : "=v"(low_count));
    __asm__ volatile("v_mbcnt_hi_u32_b32 %0, -1, %1" : "=v"(lane) : "v"(low_count));
    row[2] = low_count;
    row[3] = lane;

    // A partial mask and a nonzero addend show which mask bits each half examines.
    unsigned masked_low, masked_total;
    __asm__ volatile("v_mbcnt_lo_u32_b32 %0, %1, 7" : "=v"(masked_low) : "s"(scalar_mask));
    __asm__ volatile("v_mbcnt_hi_u32_b32 %0, %1, %2"
                     : "=v"(masked_total) : "s"(scalar_mask), "v"(masked_low));
    row[4] = masked_low;
    row[5] = masked_total;

    // A literal, a sign-extended inline constant and an SGPR pair, each written low word first.
    ulong moved, scalar_pair = SCALAR64(high_decides);
    __asm__ volatile("v_mov_b64_e32 %0, 0x7fffffff" : "=v"(moved));
    row[6] = (unsigned)moved;
    row[7] = (unsigned)(moved >> 32);
    __asm__ volatile("v_mov_b64_e32 %0, -1" : "=v"(moved));
    row[8] = (unsigned)moved;
    row[9] = (unsigned)(moved >> 32);
    __asm__ volatile("v_mov_b64_e32 %0, %1" : "=v"(moved) : "s"(scalar_pair));
    row[10] = (unsigned)moved;
    row[11] = (unsigned)(moved >> 32);

    BELOW_BOUND(high_decides, 12);
    BELOW_BOUND(low_decides, 13);
    BELOW_BOUND(below_bound, 14);
    BELOW_BOUND(negative, 15);
    BELOW_BOUND(equal, 16);
}
