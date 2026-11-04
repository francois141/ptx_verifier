// Each row selects between symbolic inputs on one f32 comparison. Inline assembly keeps the
// comparison in e64 form, with its per-lane predicates in an SGPR mask.
#define SELECT(predicate, row) do { \
    ulong mask; \
    float result; \
    __asm__ volatile( \
        "v_cmp_" #predicate "_f32_e64 %1, %2, %3\n\t" \
        "v_cndmask_b32_e64 %0, %2, %3, %1" \
        : "=&v"(result), "=&s"(mask) : "v"(x), "v"(y)); \
    out[12 * i + row] = result; \
} while (0)

__kernel void compare_ops(__global const float *a, __global const float *b, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float x = a[i], y = b[i];
    SELECT(lt, 0);
    SELECT(eq, 1);
    SELECT(le, 2);
    SELECT(gt, 3);
    SELECT(lg, 4);
    SELECT(ge, 5);
    SELECT(nge, 6);
    SELECT(nlg, 7);
    SELECT(ngt, 8);
    SELECT(nle, 9);
    SELECT(neq, 10);
    SELECT(nlt, 11);
}
