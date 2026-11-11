__kernel void copy(__global const float *in, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = in[i];
}
