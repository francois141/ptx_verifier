// Aiter's _rms_norm_kernel on workgroup 0's R rows of an M x N input: rsigma[r] is
// rsqrt(mean(x^2) + eps) with eps = f32(1e-6), y[r, c] = x[r, c] * rsigma[r] * g[c].
dim M; dim R; dim N;
array x[M, N];
array g[N];
array y[R, N];
array rsigma[R];
rsigma[r] = 1 / sqrt(sum(j in 0..N, x[r, j] * x[r, j]) / N + 0.0000009999999974752427078783512115478515625);
y[r, c] = x[r, c] * (1 / sqrt(sum(j in 0..N, x[r, j] * x[r, j]) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
