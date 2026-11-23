// Aiter's _layernorm_kernel (norm.py::layer_norm) on workgroup 0's R rows of an M x N input:
// mean, biased variance, rstd = 1 / sqrt(var + eps) with eps = f32(1e-5), y = (x - mean) * rstd * w + b.
dim M; dim R; dim N;
array x[M, N];
array w[N];
array b[N];
array y[R, N];
array mean[R];
array rstd[R];
mean[r] = sum(j in 0..N, x[r, j]) / N;
rstd[r] = let(mu, sum(j in 0..N, x[r, j]) / N,
              1 / sqrt(sum(j in 0..N, (x[r, j] - mu) * (x[r, j] - mu)) / N + 0.00000999999974737875163555145263671875));
y[r, c] = let(mu, sum(j in 0..N, x[r, j]) / N,
              let(rs, 1 / sqrt(sum(j in 0..N, (x[r, j] - mu) * (x[r, j] - mu)) / N + 0.00000999999974737875163555145263671875),
                  (x[r, c] - mu) * rs * w[c] + b[c]));
