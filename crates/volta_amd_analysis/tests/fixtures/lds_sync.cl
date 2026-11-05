// Two waves exchange LDS words: work-item i writes word i, then reads the other wave's word.

// The release fence's s_waitcnt lgkmcnt(0) completes each wave's write before the barrier.
__kernel void exchange(__global const float *input, __global float *output) {
    __local float shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i] = input[i];
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");
    output[i] = shared[(i + 64) % 128];
}
