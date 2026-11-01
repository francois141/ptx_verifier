__kernel void relu(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = fmax(a[i], 0.0f);
}
