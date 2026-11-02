// Compiled with -cl-fast-relaxed-math in addition to the copy fixture's flags. Each work-item
// writes one result per operation to its own 32-float row of `out`.
__kernel void float_ops(__global const float *a, __global const float *b, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i];
    __global float *row = out + 32 * i;
    row[0] = -x;
    row[1] = fabs(x);
    row[2] = sqrt(x);
    row[3] = __builtin_amdgcn_rsqf(x);
    row[4] = __builtin_amdgcn_exp2f(x);
    row[5] = __builtin_amdgcn_logf(x);
    row[6] = 1.0f / x;
    row[7] = x + y;
    row[8] = x - y;
    row[9] = x * y;
    row[10] = x / y;
    row[11] = fmin(x, y);
    row[12] = fmax(x, y);
    row[13] = fma(x, y, x);
    row[14] = x < y ? x : 2.0f;
    row[15] = x > y ? x : x * y;
    row[16] = x <= y ? x : x * y;
    row[17] = x >= y ? x : x * y;
    row[18] = x == y ? x : x * y;
    row[19] = x != y ? x : x * y;
    row[20] = -fabs(x);
}
