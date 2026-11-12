// Sigmoid over 4096 elements in one 1024-work-item workgroup, each work-item computing four
// elements 1024 apart. sigmoid_4096.s is its gfx950 assembly from Homebrew clang 21.1.8, with
// volta_amd_analysis's README's flags plus -cl-fast-relaxed-math.
__kernel void sigmoid_4096(__global const float *a, __global float *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    for (unsigned k = 0; k < 4; ++k) {
        unsigned j = i + 1024 * k;
        out[j] = 1.0f / (1.0f + exp(-a[j]));
    }
}
