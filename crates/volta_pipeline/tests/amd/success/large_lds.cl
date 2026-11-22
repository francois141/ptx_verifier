// A workgroup of 156 KiB of LDS, past the 64 KiB of earlier generations: each lane stores to
// a word near its end, and after a barrier reads its neighbor's.
#define WORDS 40000
#define BASE (WORDS - 64)

__kernel void large_lds(__global unsigned *out) {
    __local unsigned shared[WORDS];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[BASE + i] = i + 1;
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");
    out[i] = shared[BASE + (i ^ 1)];
}
