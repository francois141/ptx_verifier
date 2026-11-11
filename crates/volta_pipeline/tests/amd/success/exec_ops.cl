// Each work-item writes one row of results from instructions that run while EXEC holds only
// some lanes. Inline assembly keeps each opcode. Each block saves EXEC before narrowing it and
// restores it after, so the compiled code around the blocks runs in every lane.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))
#define SCALAR64(value) (SCALAR32(value) | ((ulong)SCALAR32((value) >> 32) << 32))

// Write 1 when a branch is taken while EXEC holds `mask`, else 0.
#define BRANCH(mask, branch, column) do { \
    unsigned taken; \
    __asm__ volatile( \
        "s_mov_b32 %0, 1\n\t" \
        "s_mov_b64 %1, exec\n\t" \
        "s_mov_b64 exec, %2\n\t" \
        #branch " .Lbranch_taken_%=\n\t" \
        "s_mov_b32 %0, 0\n" \
        ".Lbranch_taken_%=:\n\t" \
        "s_mov_b64 exec, %1" \
        : "=&s"(taken), "=&s"(saved) : "s"(mask)); \
    row[column] = taken; \
} while (0)

__kernel void exec_ops(__global const float *input, __global unsigned *out,
                       __global float *floats) {
    __local unsigned shared[65];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    __global unsigned *row = out + 32 * i;
    ulong saved, none = 0;
    ulong out_base = SCALAR64((ulong)out), input_base = SCALAR64((ulong)input);

    // The odd lanes, as a concrete mask in an SGPR pair.
    ulong odd;
    __asm__ volatile("v_cmp_ne_u32_e64 %0, 0, %1" : "=s"(odd) : "v"(i & 1));
    row[0] = (unsigned)odd;
    row[1] = (unsigned)(odd >> 32);

    // A move runs in the odd lanes only, so the even lanes keep 7. EXEC, written from VCC,
    // reads back as the mask.
    unsigned moved;
    ulong narrowed;
    __asm__ volatile(
        "v_cmp_ne_u32_e32 vcc, 0, %3\n\t"
        "v_mov_b32_e32 %0, 7\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, vcc\n\t"
        "v_mov_b32_e32 %0, 9\n\t"
        "s_mov_b64 %1, exec\n\t"
        "s_mov_b64 exec, %2"
        : "=&v"(moved), "=&s"(narrowed), "=&s"(saved) : "v"(i & 1) : "vcc");
    row[2] = moved;
    row[3] = (unsigned)narrowed;
    row[4] = (unsigned)(narrowed >> 32);

    // Both sides of a branch, as compiled code masks them: lanes below 16 take the first, the
    // AND-NOT leaves the other lanes for the second, and the OR makes every lane active again.
    unsigned side;
    __asm__ volatile(
        "v_cmp_gt_u32_e32 vcc, 16, %2\n\t"
        "s_mov_b64 %1, exec\n\t"
        "s_and_b64 exec, %1, vcc\n\t"
        "v_mov_b32_e32 %0, 1\n\t"
        "s_andn2_b64 exec, %1, exec\n\t"
        "v_mov_b32_e32 %0, 2\n\t"
        "s_or_b64 exec, exec, %1"
        : "=&v"(side), "=&s"(saved) : "v"(i) : "vcc", "scc");
    row[5] = side;

    // A comparison clears the mask bit of each lane that does not run it, in VCC and in an
    // SGPR pair alike: both held ones before, and the comparison passes wherever it runs.
    unsigned e32_bit, e64_bit;
    ulong e64_mask;
    __asm__ volatile(
        "s_mov_b64 vcc, -1\n\t"
        "s_mov_b64 %2, -1\n\t"
        "s_mov_b64 %3, exec\n\t"
        "s_mov_b64 exec, %5\n\t"
        "v_cmp_eq_u32_e32 vcc, %4, %4\n\t"
        "v_cmp_eq_u32_e64 %2, %4, %4\n\t"
        "s_mov_b64 exec, %3\n\t"
        "v_cndmask_b32_e64 %0, 0, 1, vcc\n\t"
        "v_cndmask_b32_e64 %1, 0, 1, %2"
        : "=&v"(e32_bit), "=&v"(e64_bit), "=&s"(e64_mask), "=&s"(saved)
        : "v"(i), "s"(odd) : "vcc");
    row[6] = e32_bit;
    row[7] = e64_bit;

    // Only the odd lanes store, so the even lanes' row[8] stays unwritten.
    __asm__ volatile(
        "s_mov_b64 %0, exec\n\t"
        "s_mov_b64 exec, %1\n\t"
        "global_store_dword %2, %3, %4 offset:32\n\t"
        "s_mov_b64 exec, %0"
        : "=&s"(saved) : "s"(odd), "v"(128 * i), "v"(i), "s"(out_base) : "memory");

    // Only the odd lanes load. The wait completes their loads, and the even lanes keep 0.5.
    float loaded;
    __asm__ volatile(
        "v_mov_b32_e32 %0, 0.5\n\t"
        "s_mov_b64 %1, exec\n\t"
        "s_mov_b64 exec, %2\n\t"
        "global_load_dword %0, %3, %4\n\t"
        "s_mov_b64 exec, %1\n\t"
        "s_waitcnt vmcnt(0)"
        : "=&v"(loaded), "=&s"(saved) : "s"(odd), "v"(4 * i), "s"(input_base) : "memory");
    floats[i] = loaded;

    // LDS writes reach only the active lanes' words: the odd lanes overwrite their own, and
    // lane 5 alone writes word 64, which every lane addresses, so no two lanes race on it.
    unsigned own, last;
    __asm__ volatile(
        "ds_write_b32 %3, %4\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "v_cmp_eq_u32_e32 vcc, 5, %7\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, %8\n\t"
        "ds_write_b32 %3, %5\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "s_mov_b64 exec, vcc\n\t"
        "ds_write_b32 %6, %5\n\t"
        "s_mov_b64 exec, %2\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "ds_read_b32 %0, %3\n\t"
        "ds_read_b32 %1, %6\n\t"
        "s_waitcnt lgkmcnt(0)"
        : "=&v"(own), "=&v"(last), "=&s"(saved)
        : "v"((unsigned)&shared[i]), "v"(i + 100), "v"(i + 200), "v"((unsigned)&shared[64]),
          "v"(i), "s"(odd)
        : "vcc", "memory");
    row[9] = own;
    row[10] = last;

    // An LDS read loads only the active lanes: the odd lanes read their even neighbor's word,
    // and the even lanes keep 7.
    unsigned neighbor;
    __asm__ volatile(
        "v_mov_b32_e32 %0, 7\n\t"
        "s_mov_b64 %1, exec\n\t"
        "s_mov_b64 exec, %2\n\t"
        "ds_read_b32 %0, %3\n\t"
        "s_mov_b64 exec, %1\n\t"
        "s_waitcnt lgkmcnt(0)"
        : "=&v"(neighbor), "=&s"(saved) : "s"(odd), "v"((unsigned)&shared[i ^ 1]) : "memory");
    row[11] = neighbor;

    // A lane exchange applies EXEC at both ends. The odd lanes receive 0 from their inactive
    // even neighbor, then the word of the odd lane two away; the even lanes keep 7.
    unsigned from_inactive, from_active;
    __asm__ volatile(
        "v_mov_b32_e32 %0, 7\n\t"
        "v_mov_b32_e32 %1, 7\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, %3\n\t"
        "ds_bpermute_b32 %0, %4, %6\n\t"
        "ds_bpermute_b32 %1, %5, %6\n\t"
        "s_mov_b64 exec, %2\n\t"
        "s_waitcnt lgkmcnt(0)"
        : "=&v"(from_inactive), "=&v"(from_active), "=&s"(saved)
        : "s"(odd), "v"(4 * (i ^ 1)), "v"(4 * (i ^ 2)), "v"(i + 400));
    row[12] = from_inactive;
    row[13] = from_active;

    // The first lane read is the lowest active one, lane 5 here, then lane 0 once no lane is
    // active.
    unsigned first_active, first_of_none;
    __asm__ volatile(
        "v_cmp_le_u32_e32 vcc, 5, %3\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, vcc\n\t"
        "v_readfirstlane_b32 %0, %4\n\t"
        "s_mov_b64 exec, 0\n\t"
        "v_readfirstlane_b32 %1, %4\n\t"
        "s_mov_b64 exec, %2"
        : "=&s"(first_active), "=&s"(first_of_none), "=&s"(saved)
        : "v"(i), "v"(i + 500) : "vcc");
    row[14] = first_active;
    row[15] = first_of_none;

    BRANCH(none, s_cbranch_execz, 16);
    BRANCH(none, s_cbranch_execnz, 17);
    BRANCH(odd, s_cbranch_execz, 18);
    BRANCH(odd, s_cbranch_execnz, 19);

    // The multiply-add carries out of 64 bits wherever it runs. Its carry mask held ones
    // before and is fully written, so the even lanes' bits clear; those lanes keep their sum.
    ulong sum, carries;
    __asm__ volatile(
        "v_mov_b64_e32 %0, %4\n\t"
        "s_mov_b64 %1, -1\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, %3\n\t"
        "v_mad_u64_u32 %0, %1, %5, %5, %6\n\t"
        "s_mov_b64 exec, %2"
        : "=&v"(sum), "=&s"(carries), "=&s"(saved)
        : "s"(odd), "v"((ulong)i), "v"(~0u), "v"(~0ul));
    row[20] = (unsigned)sum;
    row[21] = (unsigned)(sum >> 32);
    row[22] = (unsigned)carries;
    row[23] = (unsigned)(carries >> 32);
}

// The odd lanes' global load is still in flight when the wait completes the even lanes' LDS
// read into the same register, so the move after that wait reads a pending value in lane 1.
__kernel void pending_in_other_lanes(__global const float *input, __global float *output) {
    __local float shared[64];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    ulong odd, saved, input_base = SCALAR64((ulong)input);
    float value, copy;
    __asm__ volatile("v_cmp_ne_u32_e64 %0, 0, %1" : "=s"(odd) : "v"(i & 1));
    __asm__ volatile(
        "ds_write_b32 %6, %7\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "s_mov_b64 %2, exec\n\t"
        "s_mov_b64 exec, %3\n\t"
        "global_load_dword %0, %4, %5\n\t"
        "s_andn2_b64 exec, %2, exec\n\t"
        "ds_read_b32 %0, %6\n\t"
        "s_mov_b64 exec, %2\n\t"
        "s_waitcnt lgkmcnt(0)\n\t"
        "v_mov_b32_e32 %1, %0\n\t"
        "s_waitcnt vmcnt(0)"
        : "=&v"(value), "=&v"(copy), "=&s"(saved)
        : "s"(odd), "v"(4 * i), "s"(input_base), "v"((unsigned)&shared[i]), "v"(0.5f)
        : "memory", "scc");
    output[i] = copy;
}

// Workgroup 0 turns every lane off where workgroup 1 keeps them on, so one run cannot follow
// both. The XOR reads EXEC, which each workgroup must find as it was before the instruction.
__kernel void workgroup_exec(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned group = __builtin_amdgcn_workgroup_id_x(), result;
    ulong saved, flipped;
    __asm__ volatile(
        "v_mov_b32_e32 %0, 7\n\t"
        "s_cmp_eq_u32 %3, 0\n\t"
        "s_cselect_b64 %2, -1, 0\n\t"
        "s_mov_b64 %1, exec\n\t"
        "s_xor_b64 exec, exec, %2\n\t"
        "v_mov_b32_e32 %0, 9\n\t"
        "s_mov_b64 exec, %1"
        : "=&v"(result), "=&s"(saved), "=&s"(flipped) : "s"(group) : "scc");
    out[i] = result;
}
