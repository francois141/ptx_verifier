// gemm_a16w16 with bias and activation="relu": y = max(0, x @ w^T + bias), whole output.
dim M; dim N; dim K;
array x[M, K];
array w[N, K];
array bias[N];
array y[M, N];
y[m, n] = max(0, sum(k in 0..K, x[m, k] * w[n, k]) + bias[n]);
