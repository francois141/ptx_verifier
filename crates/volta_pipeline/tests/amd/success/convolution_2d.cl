#define OUTPUT_WIDTH 8
#define FILTER_WIDTH 3
#define INPUT_WIDTH (OUTPUT_WIDTH + FILTER_WIDTH - 1)

// Each work-item computes one valid output of an 8 x 8 image; input includes the filter halo.
__kernel void convolution_2d(__global const float *input,
                             __global const float *filter,
                             __global float *output) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    unsigned y = i / OUTPUT_WIDTH, x = i % OUTPUT_WIDTH;
    float sum = 0.0f;
    for (unsigned ky = 0; ky < FILTER_WIDTH; ky++)
        for (unsigned kx = 0; kx < FILTER_WIDTH; kx++)
            sum += input[(y + ky) * INPUT_WIDTH + x + kx] * filter[ky * FILTER_WIDTH + kx];
    output[i] = sum;
}
