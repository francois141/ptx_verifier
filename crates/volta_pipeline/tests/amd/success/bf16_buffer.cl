// 16-bit buffer accesses over bf16 arrays: each lane loads element `i` of `a`, the high half of
// a word in the odd lanes, and stores it as element `63 - i` of `out`, reversing the array.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))

__kernel void bf16_buffer(__global const ushort *a, __global ushort *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    ulong in_base = (ulong)a, out_base = (ulong)out;
    uint4 in_rsrc = (uint4)(SCALAR32(in_base), SCALAR32(in_base >> 32) & 0xffff, 128, 0x00020000);
    uint4 out_rsrc =
        (uint4)(SCALAR32(out_base), SCALAR32(out_base >> 32) & 0xffff, 128, 0x00020000);
    unsigned element;
    __asm__ volatile(
        "buffer_load_ushort %0, %1, %2, 0 offen\n\t"
        "s_waitcnt vmcnt(0)\n\t"
        "buffer_store_short %0, %3, %4, 0 offen"
        : "=&v"(element) : "v"(2 * i), "s"(in_rsrc), "v"(2 * (63 - i)), "s"(out_rsrc)
        : "memory");
}
