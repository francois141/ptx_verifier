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

// `exchange`'s release fence, barrier and acquire fence.
#define SYNC()                                                                                     \
    do {                                                                                           \
        __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");                                     \
        __builtin_amdgcn_s_barrier();                                                              \
        __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");                                     \
    } while (0)

// The second barrier keeps each wave's overwrite after the other wave's first read.
__kernel void two_rounds(__global const float *input, __global float *output) {
    __local float shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i] = input[i];
    SYNC();
    float other = shared[(i + 64) % 128];
    SYNC();
    shared[i] = 2.0f * other;
    SYNC();
    output[i] = shared[(i + 64) % 128];
}

// Wave 1 reads the words wave 0 writes, with no barrier between them.
__kernel void no_barrier(__global const float *input, __global float *output) {
    __local float shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i] = input[i];
    output[i] = shared[i % 64];
}

// A bare s_barrier leaves each write in flight: no s_waitcnt lgkmcnt(0) completes it first.
__kernel void barrier_without_wait(__global const float *input, __global float *output) {
    __local float shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i] = input[i];
    __asm__ volatile("s_barrier" ::: "memory");
    output[i] = shared[(i + 64) % 128];
}

// Without the second barrier, each wave overwrites a word the other wave may still be reading.
__kernel void overwrite_without_barrier(__global const float *input, __global float *output) {
    __local float shared[128];
    unsigned i = __builtin_amdgcn_workitem_id_x();
    shared[i] = input[i];
    SYNC();
    float other = shared[(i + 64) % 128];
    shared[i] = 2.0f * other;
    SYNC();
    output[i] = shared[(i + 64) % 128];
}
