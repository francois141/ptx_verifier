// Test unsupported bitwise operations and divergence, with symbolic addition as a control.

__kernel void symbolic_shift(__global const float *input, __global unsigned *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    output[i] = as_uint(input[i]) >> 16;
}

__kernel void symbolic_negation(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    output[i] = -input[i];
}

__kernel void symbolic_add(__global const unsigned *input, __global unsigned *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    output[i] = input[i] + 1;
}

// Only odd lanes store, requiring a change to the wave's active-lane mask.
__kernel void divergent_store(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i & 1)
        output[i] = input[i];
}
