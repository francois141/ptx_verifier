// `off` in place of an address register. A global load takes its whole 64-bit address from a
// VGPR pair, and a buffer load has no per-lane offset, so every lane reads the same word.

// Keep an argument scalar in both the kernel entry and Clang's callable helper.
#define SCALAR32(value) ((unsigned)__builtin_amdgcn_readfirstlane((unsigned)(value)))

__kernel void off_addresses(__global const float *input, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();

    // Each lane's address is one element past input[i], and the negative offset steps back.
    float own;
    __asm__ volatile(
        "global_load_dword %0, %1, off offset:-4\n\t"
        "s_waitcnt vmcnt(0)"
        : "=v"(own) : "v"(input + i + 1) : "memory");

    // A raw buffer over the input's first 64 words: byte 4 (soffset) + 8 (offset) is input[3].
    ulong base = (ulong)input;
    unsigned low = SCALAR32(base), high = SCALAR32(base >> 32);
    uint4 rsrc = (uint4)(low, high & 0xffff, 256, 0x00020000);
    float shared_word;
    __asm__ volatile(
        "buffer_load_dword %0, off, %1, %2 offset:8\n\t"
        "s_waitcnt vmcnt(0)"
        : "=v"(shared_word) : "s"(rsrc), "s"(4u) : "memory");

    out[i] = own;
    out[64 + i] = shared_word;
}
