// C = A @ B over row-major f32 matrices, A M x K, B K x N; one 16 x 16 block computes one 256 x 64
// tile of C, each thread a 16 x 4 sub-tile, staging A and B through shared memory 16 columns at a
// time. Header-free so LLVM's clang compiles it without the CUDA toolkit; K must be a multiple of 16.

#define __global__ __attribute__((global))
#define __shared__ __attribute__((shared))

#define BM 256
#define BN 64
#define BK 16
#define TM 16
#define TN 4
#define THREADS 256

extern "C" __global__ void matmul(const float *A, const float *B, float *C, unsigned N, unsigned K) {
    __shared__ float As[BM][BK];
    __shared__ float Bs[BK][BN];

    const unsigned tx = __nvvm_read_ptx_sreg_tid_x();
    const unsigned ty = __nvvm_read_ptx_sreg_tid_y();
    const unsigned tile_row = __nvvm_read_ptx_sreg_ctaid_y() * BM;
    const unsigned tile_col = __nvvm_read_ptx_sreg_ctaid_x() * BN;
    const unsigned tid = ty * 16 + tx;

    float acc[TM][TN] = {};
    for (unsigned k0 = 0; k0 < K; k0 += BK) {
        #pragma unroll
        for (int i = 0; i < BM * BK / THREADS; i++) {
            const unsigned e = tid + i * THREADS;
            As[e / BK][e % BK] = A[(tile_row + e / BK) * K + k0 + e % BK];
        }
        #pragma unroll
        for (int i = 0; i < BK * BN / THREADS; i++) {
            const unsigned e = tid + i * THREADS;
            Bs[e / BN][e % BN] = B[(k0 + e / BN) * N + tile_col + e % BN];
        }
        __syncthreads();
        #pragma unroll
        for (int k = 0; k < BK; k++)
            #pragma unroll
            for (int i = 0; i < TM; i++)
                #pragma unroll
                for (int j = 0; j < TN; j++)
                    acc[i][j] += As[ty * TM + i][k] * Bs[k][tx * TN + j];
        __syncthreads();
    }
    #pragma unroll
    for (int i = 0; i < TM; i++)
        #pragma unroll
        for (int j = 0; j < TN; j++)
            C[(tile_row + ty * TM + i) * N + tile_col + tx * TN + j] = acc[i][j];
}
