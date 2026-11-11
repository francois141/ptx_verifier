// Each work-item writes one row of results from the scalar operations that write EXEC and copy
// it to a destination. Inline assembly keeps each opcode, and every block restores EXEC, so
// the compiled code around the blocks runs in every lane.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))
#define SCALAR64(value) (SCALAR32(value) | ((ulong)SCALAR32((value) >> 32) << 32))

// Store a word at a byte offset into the row, in the global store's SGPR-base form. Across a
// branch, the compiler's own store addresses the row through a VGPR pair, which is not supported.
#define STORE_AT(offset, value) \
    __asm__ volatile("global_store_dword %0, %1, %2 offset:" #offset \
        : : "v"(320 * i), "v"(value), "s"(out_base) : "memory")

// Run `op` on `source` while EXEC holds the lanes below 48. Write the destination's two words,
// the two words of the EXEC the operation leaves, and its SCC.
#define EXEC_OP(op, source, column) do { \
    ulong copied, left, saved; \
    unsigned scc; \
    __asm__ volatile( \
        "s_mov_b64 %3, exec\n\t" \
        "s_mov_b64 exec, %5\n\t" \
        #op " %0, %4\n\t" \
        "s_cselect_b32 %2, 1, 0\n\t" \
        "s_mov_b64 %1, exec\n\t" \
        "s_mov_b64 exec, %3" \
        : "=&s"(copied), "=&s"(left), "=&s"(scc), "=&s"(saved) : "s"(source), "s"(low) \
        : "scc"); \
    row[column] = (unsigned)copied; \
    row[(column) + 1] = (unsigned)(copied >> 32); \
    row[(column) + 2] = (unsigned)left; \
    row[(column) + 3] = (unsigned)(left >> 32); \
    row[(column) + 4] = scc; \
} while (0)

__kernel void saveexec_ops(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 80 * i;
    ulong out_base = SCALAR64((ulong)out);

    // The odd lanes and the lanes below 48, as concrete masks in SGPR pairs. The two masks
    // give each operation, and each operand order, a different result.
    ulong odd, low, none = 0;
    __asm__ volatile("v_cmp_ne_u32_e64 %0, 0, %1" : "=s"(odd) : "v"(i & 1));
    __asm__ volatile("v_cmp_gt_u32_e64 %0, 48, %1" : "=s"(low) : "v"(i));

    // The destination receives EXEC as it was before the operation.
    EXEC_OP(s_and_saveexec_b64, odd, 0);
    EXEC_OP(s_or_saveexec_b64, odd, 5);
    EXEC_OP(s_xor_saveexec_b64, odd, 10);
    EXEC_OP(s_andn2_saveexec_b64, odd, 15);
    EXEC_OP(s_orn2_saveexec_b64, odd, 20);
    EXEC_OP(s_nand_saveexec_b64, odd, 25);
    EXEC_OP(s_nor_saveexec_b64, odd, 30);
    EXEC_OP(s_xnor_saveexec_b64, odd, 35);
    EXEC_OP(s_andn1_saveexec_b64, odd, 40);
    EXEC_OP(s_orn1_saveexec_b64, odd, 45);

    // The destination receives EXEC as the operation leaves it.
    EXEC_OP(s_andn1_wrexec_b64, odd, 50);
    EXEC_OP(s_andn2_wrexec_b64, odd, 55);

    // No lane stays active, so SCC is clear.
    EXEC_OP(s_and_saveexec_b64, none, 60);

    // The compiler's own masking: only the odd lanes take the branch and store row[70], and
    // every lane stores row[71] after it.
    if (i & 1)
        STORE_AT(280, i);
    STORE_AT(284, i);
}
