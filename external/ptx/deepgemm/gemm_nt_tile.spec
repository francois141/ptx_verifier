// DeepGEMM's normal GEMM, D = A @ B^T (A [M, K], B [N, K] K-major), on the BN columns from N0
// the analyzed block's tile covers; its other elements are another block's.
dim M; dim N; dim K; dim N0; dim BN;
array tensor_map_a[M, K];
array tensor_map_b[N, K];
array tensor_map_cd[M, N];
tensor_map_cd[m, n] = where(n < N0, unwritten,
    where(n < N0 + BN, sum(k in 0..K, tensor_map_a[m, k] * tensor_map_b[n, k]), unwritten));
