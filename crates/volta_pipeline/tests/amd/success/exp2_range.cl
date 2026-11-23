// LLVM's denormal-safe exp2: inputs below -126 are shifted up by 64 before `v_exp_f32` and the
// result scaled back by 2^-64 with `v_ldexp_f32`, whose exponent is a select of two words.
__kernel void exp2_range(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_exp2f(a[i]);
}
