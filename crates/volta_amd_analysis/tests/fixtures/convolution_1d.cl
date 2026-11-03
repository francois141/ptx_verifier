#define FILTER_WIDTH 25

// Each work-item computes one valid convolution output; input includes the filter halo.
__kernel void convolution_1d(__global const float *input,
                             __global const float *filter,
                             __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    float sum = 0.0f;
    for (unsigned k = 0; k < FILTER_WIDTH; k++)
        sum += input[i + k] * filter[k];
    output[i] = sum;
}
