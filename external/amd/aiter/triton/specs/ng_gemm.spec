// gemm_a16w16: y = relu?(x @ w^T + bias?) on the TM x TN tile at the origin (workgroup 0).
dim M; dim N; dim K; dim TM; dim TN;
array x[M, K];
array w[N, K];
array y[TM, TN];
y[m, n] = sum(k in 0..K, x[m, k] * w[n, k]);
