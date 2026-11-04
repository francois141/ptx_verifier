// Lanes i and i + 32 of one wave write the same LDS word in one instruction; the barrier orders
// only the reads after them.
__kernel void write_write_race(__global const float *input, __global float *output) {
    __local float shared[32];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i % 32] = input[i];
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");
    output[i] = shared[i % 32];
}
