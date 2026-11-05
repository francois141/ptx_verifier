// Uniform kernel arguments exercise scalar arithmetic, 64-bit comparisons and control flow.
// Each work-item writes its results to a separate row.
__kernel void scalar_ops(__global unsigned *out, int a, int b,
                         ulong x, ulong y, ulong expected, int count) {
    // Repeat the recurrence count times; the caller supplies a positive count.
    unsigned value = 3;
    do {
        value = value * value + 17;
    } while (--count);

    // Keep x scalar in both the kernel entry and Clang's callable helper.
    ulong scalar_x = (unsigned)__builtin_amdgcn_readfirstlane((unsigned)x);
    scalar_x |= (ulong)(unsigned)__builtin_amdgcn_readfirstlane((unsigned)(x >> 32)) << 32;
    // Inline assembly keeps the zero comparison and SCC0 branch in the compiled fixture.
    unsigned is_zero;
    __asm__ volatile(
        "s_mov_b32 %0, 0\n\t"
        "s_cmp_eq_u64 %1, 0\n\t"
        "s_cbranch_scc0 .Lscalar_nonzero_%=\n\t"
        "s_mov_b32 %0, 1\n"
        ".Lscalar_nonzero_%=:"
        : "=&s"(is_zero) : "s"(scalar_x) : "scc");

    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 8 * i;
    row[0] = (unsigned)(((long)a * b) >> 32);
    row[1] = (unsigned)(((long)a * -b) >> 32);
    row[2] = (unsigned)(a > -b ? a : -b);
    row[3] = (x | y) == expected;
    row[4] = x == y;
    row[5] = value + is_zero;
}
