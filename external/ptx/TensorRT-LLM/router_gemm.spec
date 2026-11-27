// TensorRT-LLM router_gemm_kernel / router_gemm_mma_kernel (dsv3RouterGemm.cu:53, :366) on one
// block: f32 logits of the expert columns [N0, N1) for tokens [M0, M1), out[m, n] = sum_k a[m, k]
// w[n, k] (the router weight column-major: expert n's K values contiguous).
dim T; dim E; dim K; dim N0; dim N1; dim M0; dim M1;
array a[T, K]; array w[E, K];
array out[T, E];
out[m, n] = where(m >= M0, where(m < M1, where(n >= N0, where(n < N1, sum(k in 0..K, a[m, k] * w[n, k]),
    unwritten), unwritten), unwritten), unwritten);
