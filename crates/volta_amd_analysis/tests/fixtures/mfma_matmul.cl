// C = A * B for a 32 x 8 A and an 8 x 32 B on the matrix cores, tiled as in Composable
// Kernel's block GEMM: each of the workgroup's four waves owns a 16 x 16 tile of C and
// accumulates it with one v_mfma_f32_16x16x4_f32 per four columns of A.
#define M 32
#define N 32
#define K 8
#define TILE 16

__kernel void mfma_matmul(__global const float *a, __global const float *b, __global float *c) {
    unsigned id = __builtin_amdgcn_workitem_id_x();
    unsigned wave = id / 64, lane = id % 64;
    unsigned tile_row = TILE * (wave / 2), tile_col = TILE * (wave % 2);
    unsigned i = lane % TILE, kq = lane / TILE;
    float4 acc = 0.0f;
    for (unsigned k = 0; k < K; k += 4) {
        float x = a[(tile_row + i) * K + k + kq];
        float y = b[(k + kq) * N + tile_col + i];
        acc = __builtin_amdgcn_mfma_f32_16x16x4f32(x, y, acc, 0, 0, 0);
    }
    for (unsigned r = 0; r < 4; r++)
        c[(tile_row + 4 * kq + r) * N + tile_col + i] = acc[r];
}
