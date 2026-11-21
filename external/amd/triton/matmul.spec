// Triton's matrix multiplication tutorial, C = A @ B with A [M, K] and B [K, N] row-major, on
// workgroup 0's TM x N tile of C.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[K, N];
array c[TM, N];
c[m, n] = sum(k in 0..K, a[m, k] * b[k, n]);
