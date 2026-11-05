// Each work-item writes one row of vector integer results. Inline assembly keeps each
// instruction's operand form, with scalar sources taken from the kernel arguments.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))
#define SCALAR64(value) (SCALAR32(value) | ((ulong)SCALAR32((value) >> 32) << 32))

// Compare the scalar with 0x7fffffff as signed 64-bit integers, writing 1 or 0.
#define COMPARE_BOUND(op, value, column) do { \
    ulong scalar = SCALAR64(value), bound; \
    unsigned result; \
    __asm__ volatile( \
        "v_mov_b64_e32 %1, 0x7fffffff\n\t" \
        "v_cmp_" #op "_i64_e32 vcc, %2, %1\n\t" \
        "v_cndmask_b32_e64 %0, 0, 1, vcc" \
        : "=&v"(result), "=&v"(bound) : "s"(scalar) : "vcc"); \
    row[column] = result; \
} while (0)

__kernel void vector_int_ops(__global unsigned *out, unsigned factor, unsigned mask,
                             ulong high_decides, ulong low_decides, ulong below_bound,
                             ulong negative, ulong equal) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 64 * i;
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

    COMPARE_BOUND(lt, high_decides, 12);
    COMPARE_BOUND(lt, low_decides, 13);
    COMPARE_BOUND(lt, below_bound, 14);
    COMPARE_BOUND(lt, negative, 15);
    COMPARE_BOUND(lt, equal, 16);

    // Each remaining relation is checked below, at and above the bound.
    COMPARE_BOUND(eq, below_bound, 17);
    COMPARE_BOUND(eq, equal, 18);
    COMPARE_BOUND(eq, high_decides, 19);
    COMPARE_BOUND(le, below_bound, 20);
    COMPARE_BOUND(le, equal, 21);
    COMPARE_BOUND(le, high_decides, 22);
    COMPARE_BOUND(gt, below_bound, 23);
    COMPARE_BOUND(gt, equal, 24);
    COMPARE_BOUND(gt, high_decides, 25);
    COMPARE_BOUND(ne, below_bound, 26);
    COMPARE_BOUND(ne, equal, 27);
    COMPARE_BOUND(ne, high_decides, 28);
    COMPARE_BOUND(ge, below_bound, 29);
    COMPARE_BOUND(ge, equal, 30);
    COMPARE_BOUND(ge, high_decides, 31);

    // The high word of a product depends on signedness, and a bit count adds its second source.
    unsigned high_word;
    __asm__ volatile("v_mul_hi_u32 %0, %1, %2" : "=v"(high_word) : "v"(value), "s"(scalar_mask));
    row[32] = high_word;
    __asm__ volatile("v_mul_hi_i32 %0, %1, %2" : "=v"(high_word) : "v"(value), "s"(scalar_mask));
    row[33] = high_word;
    unsigned bit_count;
    __asm__ volatile("v_bcnt_u32_b32 %0, %1, 7" : "=v"(bit_count) : "v"(value));
    row[34] = bit_count;
}
