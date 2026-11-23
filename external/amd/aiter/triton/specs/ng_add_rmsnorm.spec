// Aiter's _fused_add_rmsnorm_kernel (rmsnorm.py::rmsnorm2d_fwd_with_add) on workgroup 0's R rows:
// s = x + res (stored as res_out), rsigma = 1 / sqrt(mean(s^2) + eps), eps = f32(1e-6), y = s * rsigma * g.
dim M; dim R; dim N;
array x[M, N];
array res[M, N];
array g[N];
array y[R, N];
array res_out[R, N];
array rsigma[R];
res_out[r, c] = x[r, c] + res[r, c];
rsigma[r] = 1 / sqrt(sum(j in 0..N, (x[r, j] + res[r, j]) * (x[r, j] + res[r, j])) / N + 0.0000009999999974752427078783512115478515625);
y[r, c] = (x[r, c] + res[r, c]) * (1 / sqrt(sum(j in 0..N, (x[r, j] + res[r, j]) * (x[r, j] + res[r, j])) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
