// Aiter's _fused_add_layernorm_kernel (norm.py::layernorm2d_fwd_with_add) on workgroup 0's R rows:
// s = x + res (stored as res_out), then layer norm of s with eps = f32(1e-5).
dim M; dim R; dim N;
array x[M, N];
array res[M, N];
array w[N];
array b[N];
array y[R, N];
array res_out[R, N];
array mean[R];
array rstd[R];
res_out[r, c] = x[r, c] + res[r, c];
mean[r] = sum(j in 0..N, x[r, j] + res[r, j]) / N;
rstd[r] = let(mu, sum(j in 0..N, x[r, j] + res[r, j]) / N,
              1 / sqrt(sum(j in 0..N, (x[r, j] + res[r, j] - mu) * (x[r, j] + res[r, j] - mu)) / N + 0.00000999999974737875163555145263671875));
y[r, c] = let(mu, sum(j in 0..N, x[r, j] + res[r, j]) / N,
              let(rs, 1 / sqrt(sum(j in 0..N, (x[r, j] + res[r, j] - mu) * (x[r, j] + res[r, j] - mu)) / N + 0.00000999999974737875163555145263671875),
                  (x[r, c] + res[r, c] - mu) * rs * w[c] + b[c]));
