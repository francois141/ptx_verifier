// LayerNorm along each row, eps f32(1e-5) under the root: (x - mean) / sqrt(var + eps) gamma + beta,
// the variance E[x^2] - mean^2 clamped at 0 as the kernel computes it (over the reals it is >= 0).
dim R; dim N;
array x[R, N];
array gamma[N];
array beta[N];
array y[R, N];
y[r, c] = let(mu, sum(j in 0..N, x[r, j]) / N,
              (x[r, c] - mu) * gamma[c]
              / sqrt(max(sum(j in 0..N, x[r, j] * x[r, j]) / N - mu * mu, 0)
                     + 0.00000999999974737875163555145263671875)
              + beta[c]);
