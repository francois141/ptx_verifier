// Compiled with -cl-fast-relaxed-math in addition to the copy fixture's flags.
__kernel void sigmoid(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = 1.0f / (1.0f + exp(-a[i]));
}
