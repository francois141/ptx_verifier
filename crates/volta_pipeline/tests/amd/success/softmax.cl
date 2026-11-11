// Compiled with -cl-fast-relaxed-math in addition to the copy fixture's flags.
// Each group of 16 lanes computes one softmax row, exchanging values to reduce its maximum
// and sum. The XOR exchanges stay within that group of lanes.
#define WIDTH 16

static inline float shuffle_xor(float value, unsigned lane, unsigned mask) {
    return as_float(__builtin_amdgcn_ds_bpermute(4 * (lane ^ mask), as_int(value)));
}

__kernel void softmax(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned lane = i % 64;
    float x = input[i];
    float maximum = x;
#pragma unroll
    for (unsigned mask = 1; mask < WIDTH; mask <<= 1)
        maximum = fmax(maximum, shuffle_xor(maximum, lane, mask));

    float numerator = __builtin_amdgcn_exp2f((x - maximum) * M_LOG2E_F);
    float sum = numerator;
#pragma unroll
    for (unsigned mask = 1; mask < WIDTH; mask <<= 1)
        sum += shuffle_xor(sum, lane, mask);

    output[i] = numerator / sum;
}
