// C = A * B for a 16 x 32 bf16 A and a 32 x 16 bf16 B, stored transposed as `[N, K]`, with one
// v_mfma_f32_16x16x32_bf16. Lane `l` holds row `l % 16` of A and of B's transpose over the eight
// K elements from `8 * (l / 16)`, and receives rows `4 * (l / 16)` to `4 * (l / 16) + 3` of C's
// column `l % 16`.
#define N 16
#define K 32

typedef __bf16 bf16x8 __attribute__((ext_vector_type(8)));
typedef float floatx4 __attribute__((ext_vector_type(4)));

__kernel void mfma_bf16_matmul(__global const bf16x8 *a, __global const bf16x8 *b_t,
                               __global float *c) {
    unsigned lane = __builtin_amdgcn_workitem_id_x();
    unsigned x = lane % N, block = lane / N;
    bf16x8 row = a[x * (K / 8) + block], column = b_t[x * (K / 8) + block];
    floatx4 acc = __builtin_amdgcn_mfma_f32_16x16x32_bf16(row, column, (floatx4)(0.0f), 0, 0, 0);
    for (unsigned r = 0; r < 4; r++)
        c[(4 * block + r) * N + x] = acc[r];
}
