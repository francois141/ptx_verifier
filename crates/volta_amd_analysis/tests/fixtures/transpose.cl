#define N 8

__kernel void transpose(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned row = i / N, col = i % N;
    out[col * N + row] = a[row * N + col];
}
