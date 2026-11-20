// PyTorch's SELU of C = A @ B^T on block 0's TM x N tile, scale * max(x, 0) + f32(alpha * scale) *
// (exp(min(x, 0)) - 1) with PyTorch's f32 constants: A is [M, K] row-major, B is N rows of K.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), 1.05070102214813232421875 * max(x, 0) + 1.7580993175506591796875 * (exp(min(x, 0)) - 1));
