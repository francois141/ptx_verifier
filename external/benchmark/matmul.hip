// C = A @ B over row-major f32 matrices, A M x K, B K x N; one 16 x 16 workgroup computes one 256 x 64
// tile of C, each work-item a 16 x 4 sub-tile, staging A and B through LDS 16 columns at a time.
// Header-free so LLVM's clang compiles it without ROCm; K must be a multiple of 16.

#define __global__ __attribute__((global))
#define __shared__ __attribute__((shared))

#define BM 256
#define BN 64
#define BK 16
#define TM 16
#define TN 4
#define THREADS 256

// A 32-bit byte offset from a uniform base lowers to the scalar-base global_load/store form.
static inline __attribute__((device)) float *at(const float *base, unsigned index) {
    return (float *)((const char *)base + index * 4u);
}

static inline __attribute__((device)) void sync_workgroup() {
    __builtin_amdgcn_fence(__ATOMIC_RELEASE, "workgroup");
    __builtin_amdgcn_s_barrier();
    __builtin_amdgcn_fence(__ATOMIC_ACQUIRE, "workgroup");
}

extern "C" __global__ __attribute__((amdgpu_flat_work_group_size(THREADS, THREADS))) void
matmul(const float *A, const float *B, float *C, unsigned N, unsigned K) {
    __shared__ float As[BM][BK];
    __shared__ float Bs[BK][BN];

    const unsigned tx = __builtin_amdgcn_workitem_id_x();
    const unsigned ty = __builtin_amdgcn_workitem_id_y();
    const unsigned tile_row = __builtin_amdgcn_workgroup_id_y() * BM;
    const unsigned tile_col = __builtin_amdgcn_workgroup_id_x() * BN;
    const unsigned tid = ty * 16 + tx;

    float acc[TM][TN] = {};
    for (unsigned k0 = 0; k0 < K; k0 += BK) {
        #pragma unroll
        for (int i = 0; i < BM * BK / THREADS; i++) {
            const unsigned e = tid + i * THREADS;
            As[e / BK][e % BK] = *at(A, (tile_row + e / BK) * K + k0 + e % BK);
        }
        #pragma unroll
        for (int i = 0; i < BK * BN / THREADS; i++) {
            const unsigned e = tid + i * THREADS;
            Bs[e / BN][e % BN] = *at(B, (k0 + e / BN) * N + tile_col + e % BN);
        }
        sync_workgroup();
        #pragma unroll
        for (int k = 0; k < BK; k++)
            #pragma unroll
            for (int i = 0; i < TM; i++)
                #pragma unroll
                for (int j = 0; j < TN; j++)
                    acc[i][j] += As[ty * TM + i][k] * Bs[k][tx * TN + j];
        sync_workgroup();
    }
    #pragma unroll
    for (int i = 0; i < TM; i++)
        #pragma unroll
        for (int j = 0; j < TN; j++)
            *at(C, (tile_row + ty * TM + i) * N + tile_col + tx * TN + j) = acc[i][j];
}
