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

// Keep the read, optional wait, barrier and overwrite in one assembly block so Clang cannot
// insert a wait before the barrier. The final wait makes the read result usable by the store.
#define READ_THEN_REUSE(name, wait_before_barrier)                                                \
    __kernel void name(__global const float *input, __global float *output) {                     \
        __local float shared[128];                                                                \
        unsigned i = __builtin_amdgcn_workitem_id_x();                                            \
        float value = input[i];                                                                   \
        shared[i] = value;                                                                        \
        SYNC();                                                                                   \
        float other;                                                                              \
        __asm__ volatile("ds_read_b32 %0, %1\n"                                                   \
                         wait_before_barrier                                                      \
                         "s_barrier\n"                                                            \
                         "ds_write_b32 %2, %3\n"                                                  \
                         "s_waitcnt lgkmcnt(0)"                                                   \
                         : "=&v"(other)                                                           \
                         : "v"((unsigned)&shared[i ^ 64]), "v"((unsigned)&shared[i]), "v"(value)  \
                         : "memory");                                                             \
        output[i] = other;                                                                        \
    }

// Each wave overwrites its words while the other wave's read remains in flight.
READ_THEN_REUSE(read_pending_across_reuse_barrier, "")
// Completing both waves' reads before the barrier makes the overwrites safe.
READ_THEN_REUSE(read_wait_before_reuse_barrier, "s_waitcnt lgkmcnt(0)\n")
