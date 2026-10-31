__kernel void add(__global const float *a, __global const float *b, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = a[i] + b[i];
}
