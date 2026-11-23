// Aiter's rms_norm output on workgroup 0's R rows (no rsigma: the inference path passes RSIGMA=None).
dim M; dim R; dim N;
array x[M, N];
array g[N];
array y[R, N];
y[r, c] = x[r, c] * (1 / sqrt(sum(j in 0..N, x[r, j] * x[r, j]) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
