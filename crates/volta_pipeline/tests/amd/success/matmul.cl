#define N 8

__kernel void matmul(__global const float *a, __global const float *b, __global float *c) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned row = i / N, col = i % N;
    float sum = 0.0f;
    for (unsigned k = 0; k < N; k++)
        sum += a[row * N + k] * b[k * N + col];
    c[i] = sum;
}
