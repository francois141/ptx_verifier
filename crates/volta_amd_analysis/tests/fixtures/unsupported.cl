// Test unsupported integer operations and constant selects on symbolic values, and divergence.

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

// A comparison of a symbolic input chooses between the bits of two float constants.
__kernel void symbolic_select(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    output[i] = input[i] > 0.0f ? 1.0f : 2.0f;
}

// Only odd lanes store, requiring a change to the wave's active-lane mask.
__kernel void divergent_store(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    if (i & 1)
        output[i] = input[i];
}

// A word move cannot read one half of an f64 held across a register pair.
__kernel void f64_half_as_word(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float result;
    __asm__ volatile(
        "v_cvt_f64_f32_e32 v[2:3], %1\n\t"
        "v_mov_b32_e32 %0, v2"
        : "=&v"(result) : "v"(input[i]) : "v2", "v3");
    output[i] = result;
}

// Overwriting one half leaves no f64 in the pair.
__kernel void f64_overwritten_half(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = input[i], result;
    __asm__ volatile(
        "v_cvt_f64_f32_e32 v[2:3], %1\n\t"
        "v_mov_b32_e32 v3, %1\n\t"
        "v_cvt_f32_f64_e32 %0, v[2:3]"
        : "=&v"(result) : "v"(x) : "v2", "v3");
    output[i] = result;
}

// Two symbolic f32 words do not encode an f64.
__kernel void f64_from_symbolic_words(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = input[i], result;
    __asm__ volatile(
        "v_mov_b32_e32 v2, %1\n\t"
        "v_mov_b32_e32 v3, %1\n\t"
        "v_cvt_f32_f64_e32 %0, v[2:3]"
        : "=&v"(result) : "v"(x) : "v2", "v3");
    output[i] = result;
}

// A literal supplies an f64's high word, here one that encodes a NaN.
__kernel void f64_nan_constant(__global const float *input, __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float result;
    __asm__ volatile("v_cvt_f32_f64_e32 %0, 0x7ff80000" : "=v"(result));
    output[i] = result + input[i];
}

// Keep the symbolic comparison in SGPRs so the scalar AND must reject its unknown bits.
__kernel void symbolic_mask(__global const float *input, __global unsigned *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    ulong mask;
    __asm__ volatile(
        "v_cmp_lt_f32_e64 %0, %1, 1.0\n\t"
        "s_and_b64 %0, %0, -1"
        : "=&s"(mask) : "v"(input[i]) : "scc");
    output[i] = (unsigned)mask;
}
