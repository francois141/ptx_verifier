// TensorRT-LLM cudaCoreGemm / cudaCoreGemmV2 (cudaCoreGemm/cudaCoreGemm.cu:144, :134) on block x:
// output columns [N0, N0 + 2) of all M rows, out[m, n] = alpha sum_k act[m, k] w[n, k] (weight
// [N, K] K-major), alpha = 1 or, under SCALED, scale_a[0] scale_b[0].
dim M; dim N; dim K; dim N0; dim N1; dim SCALED; dim ONE;
array act[M, K]; array w[N, K]; array sa[ONE]; array sb[ONE];
array out[M, N];
out[m, n] = where(n >= N0, where(n < N1,
    sum(k in 0..K, act[m, k] * w[n, k]) * where(SCALED == 1, sa[0] * sb[0], 1), unwritten), unwritten);
