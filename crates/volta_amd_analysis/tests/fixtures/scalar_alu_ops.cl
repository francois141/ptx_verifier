// Each work-item writes one row of scalar results. Inline assembly keeps each opcode, and
// `s_cselect_b32` copies the SCC it leaves into a result word.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))
#define SCALAR64(value) (SCALAR32(value) | ((ulong)SCALAR32((value) >> 32) << 32))

// Write `op a, b` and its SCC. `setup` prepares the SCC an operation reads.
#define OP32(setup, op, column) do { \
    unsigned result, scc; \
    __asm__ volatile( \
        setup #op " %0, %2, %3\n\t" \
        "s_cselect_b32 %1, 1, 0" \
        : "=&s"(result), "=&s"(scc) : "s"(scalar_a), "s"(scalar_b) : "scc"); \
    row[column] = result; \
    row[(column) + 1] = scc; \
} while (0)

// Write the words of `op src0, src1` and its SCC.
#define OP64(op, src0, src1, column) do { \
    ulong result; \
    unsigned scc; \
    __asm__ volatile( \
        #op " %0, %2, %3\n\t" \
        "s_cselect_b32 %1, 1, 0" \
        : "=&s"(result), "=&s"(scc) : "s"(src0), "s"(src1) : "scc"); \
    row[column] = (unsigned)result; \
    row[(column) + 1] = (unsigned)(result >> 32); \
    row[(column) + 2] = scc; \
} while (0)

// Write whether `first op second`, `first op first` and `second op first` hold.
#define CMP(op, first, second, column) do { \
    unsigned less, equal, greater; \
    __asm__ volatile( \
        #op " %3, %4\n\t" \
        "s_cselect_b32 %0, 1, 0\n\t" \
        #op " %3, %3\n\t" \
        "s_cselect_b32 %1, 1, 0\n\t" \
        #op " %4, %3\n\t" \
        "s_cselect_b32 %2, 1, 0" \
        : "=&s"(less), "=&s"(equal), "=&s"(greater) : "s"(first), "s"(second) : "scc"); \
    row[column] = less; \
    row[(column) + 1] = equal; \
    row[(column) + 2] = greater; \
} while (0)

// Write the SCC of a bit comparison at two indices, one on a set bit and one on a clear bit.
#define BITCMP(op, src, column) do { \
    unsigned first, second; \
    __asm__ volatile( \
        #op " %2, %3\n\t" \
        "s_cselect_b32 %0, 1, 0\n\t" \
        #op " %2, %4\n\t" \
        "s_cselect_b32 %1, 1, 0" \
        : "=&s"(first), "=&s"(second) : "s"(src), "s"(scalar_c), "s"(scalar_d) : "scc"); \
    row[column] = first; \
    row[(column) + 1] = second; \
} while (0)

// Write 1 when a branch is taken after `setup`, else 0.
#define BRANCH(setup, branch, column) do { \
    unsigned taken; \
    __asm__ volatile( \
        "s_mov_b32 %0, 1\n\t" \
        setup "\n\t" \
        #branch " .Lbranch_taken_%=\n\t" \
        "s_mov_b32 %0, 0\n" \
        ".Lbranch_taken_%=:" \
        : "=&s"(taken) : : "vcc", "scc"); \
    row[column] = taken; \
} while (0)

__kernel void scalar_alu_ops(__global unsigned *out, unsigned a, unsigned b, unsigned c,
                             unsigned d, ulong x, ulong y) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 128 * i;
    unsigned scalar_a = SCALAR32(a), scalar_b = SCALAR32(b);
    unsigned scalar_c = SCALAR32(c), scalar_d = SCALAR32(d);
    ulong scalar_x = SCALAR64(x), scalar_y = SCALAR64(y);

    OP32("", s_sub_u32, 0);
    OP32("s_cmp_eq_u32 %2, %2\n\t", s_subb_u32, 2);
    OP32("", s_min_i32, 4);
    OP32("", s_min_u32, 6);
    OP32("", s_max_u32, 8);
    OP32("", s_or_b32, 10);
    OP32("", s_andn2_b32, 12);
    OP32("", s_orn2_b32, 14);
    OP32("", s_nand_b32, 16);
    OP32("", s_nor_b32, 18);
    OP32("", s_xnor_b32, 20);

    CMP(s_cmp_lt_i32, scalar_a, scalar_b, 22);
    CMP(s_cmp_eq_i32, scalar_a, scalar_b, 25);
    CMP(s_cmp_le_i32, scalar_a, scalar_b, 28);
    CMP(s_cmp_gt_i32, scalar_a, scalar_b, 31);
    CMP(s_cmp_lg_i32, scalar_a, scalar_b, 34);
    CMP(s_cmp_ge_i32, scalar_a, scalar_b, 37);
    CMP(s_cmp_lt_u32, scalar_a, scalar_b, 40);
    CMP(s_cmp_eq_u32, scalar_a, scalar_b, 43);
    CMP(s_cmp_le_u32, scalar_a, scalar_b, 46);
    CMP(s_cmp_gt_u32, scalar_a, scalar_b, 49);
    CMP(s_cmp_lg_u32, scalar_a, scalar_b, 52);
    CMP(s_cmp_ge_u32, scalar_a, scalar_b, 55);

    BITCMP(s_bitcmp0_b32, scalar_a, 58);
    BITCMP(s_bitcmp1_b32, scalar_a, 60);

    OP64(s_xor_b64, scalar_x, scalar_y, 62);
    OP64(s_orn2_b64, scalar_x, scalar_y, 65);
    OP64(s_nand_b64, scalar_x, scalar_y, 68);
    OP64(s_nor_b64, scalar_x, scalar_y, 71);
    OP64(s_xnor_b64, scalar_x, scalar_y, 74);

    OP64(s_lshl_b64, scalar_x, scalar_c, 77);
    OP64(s_lshr_b64, scalar_x, scalar_c, 80);
    OP64(s_ashr_i64, scalar_x, scalar_c, 83);

    CMP(s_cmp_eq_u64, scalar_x, scalar_y, 86);
    CMP(s_cmp_lg_u64, scalar_x, scalar_y, 89);

    BITCMP(s_bitcmp0_b64, scalar_x, 92);
    BITCMP(s_bitcmp1_b64, scalar_x, 94);

    BRANCH("s_mov_b64 vcc, 0", s_cbranch_vccz, 96);
    BRANCH("s_mov_b64 vcc, -1", s_cbranch_vccz, 97);
    BRANCH("s_mov_b64 vcc, 0", s_cbranch_vccnz, 98);
    BRANCH("s_mov_b64 vcc, -1", s_cbranch_vccnz, 99);
    BRANCH("s_nop 0", s_cbranch_execz, 100);
    BRANCH("s_nop 0", s_cbranch_execnz, 101);

    // 64-bit sources also take a 32-bit literal with a clear sign bit.
    ulong literal;
    __asm__ volatile("s_mov_b64 %0, 0x7fffffff" : "=s"(literal));
    row[102] = (unsigned)literal;
    row[103] = (unsigned)(literal >> 32);
    __asm__ volatile("s_and_b64 %0, %1, 0xffff00" : "=&s"(literal) : "s"(scalar_x) : "scc");
    row[104] = (unsigned)literal;
    row[105] = (unsigned)(literal >> 32);
}
