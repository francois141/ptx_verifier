// Selects whose condition orders their two sources, one a constant, are clamps: each is the max
// or min of the two. Each work-item writes one row of results, one clamp per column.
__kernel void clamp_ops(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], result;
    __global float *row = out + 4 * i;
    ulong mask;

    // x > 0 ? x : 0, a ReLU, is max(0, x).
    __asm__ volatile(
        "v_cmp_gt_f32_e64 %1, %2, 0\n\t"
        "v_cndmask_b32_e64 %0, 0, %2, %1"
        : "=&v"(result), "=&s"(mask) : "v"(x));
    row[0] = result;

    // x < 0 ? x : 0 is min(0, x).
    __asm__ volatile(
        "v_cmp_lt_f32_e64 %1, %2, 0\n\t"
        "v_cndmask_b32_e64 %0, 0, %2, %1"
        : "=&v"(result), "=&s"(mask) : "v"(x));
    row[1] = result;

    // x <= 4 ? x : 4 is min(4, x).
    __asm__ volatile(
        "v_cmp_le_f32_e64 %1, %2, 4.0\n\t"
        "v_cndmask_b32_e64 %0, 4.0, %2, %1"
        : "=&v"(result), "=&s"(mask) : "v"(x));
    row[2] = result;

    // The e32 form, through VCC: 0 <= x ? x : 0 is max(0, x).
    __asm__ volatile(
        "v_cmp_le_f32_e32 vcc, 0, %1\n\t"
        "v_cndmask_b32_e32 %0, 0, %1, vcc"
        : "=&v"(result) : "v"(x) : "vcc");
    row[3] = result;
}
