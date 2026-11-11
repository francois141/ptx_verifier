// Store identical words to float and integer outputs; their mathematical values differ.
__kernel void output_constants(__global float *floats, __global unsigned *words) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    floats[i] = 1.0f;
    words[i] = 0x3f800000u;
}

// A NaN bit pattern cannot be exported as a mathematical real.
__kernel void nan_output(__global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = as_float(0x7fc00000u);
}
