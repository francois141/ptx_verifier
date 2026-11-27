// TensorRT-LLM mhcGemmSqrsumFmaKernel<TN> (mhcKernels/mhcKernels.cu:580) on one CTA: token row ROW, columns
// [N0, N1) of Y = X W^T (W_T [N, K] fp32), and, for the first column tile only (SQ = 1), R = sum_k X^2.
dim M; dim N; dim K; dim ROW; dim N0; dim N1; dim SQ;
array x[M, K]; array w[N, K]; array y[M, N]; array r[M];
y[m, n] = where(m == ROW, where(n >= N0, where(n < N1, sum(k in 0..K, x[m, k] * w[n, k]), unwritten), unwritten),
    unwritten);
r[m] = where(m == ROW, where(SQ == 1, sum(k in 0..K, x[m, k] * x[m, k]), unwritten), unwritten);
