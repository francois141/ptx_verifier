// TensorRT-LLM fused_a_gemm_kernel (dsv3FusedAGemm.cu:577) on block (x, y): the weight rows
// [M0, M1) times the token rows [N0, N1) (tokens past num_tokens unwritten), the output
// [tokens, M] row-major: out[n, m] = sum_k w[m, k] x[n, k] (the host swaps its operands, :660).
dim M; dim K; dim N; dim M0; dim M1; dim N0; dim N1;
array w[M, K]; array x[N, K];
array out[N, M];
out[n, m] = where(n >= N0, where(n < N1, where(m >= M0, where(m < M1,
    sum(k in 0..K, w[m, k] * x[n, k]), unwritten), unwritten), unwritten), unwritten);
