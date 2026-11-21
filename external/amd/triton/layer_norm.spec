// Triton's layer normalization tutorial, forward pass, on workgroup 0's R rows of the M x N
// input: each row's mean, its reciprocal standard deviation with eps f32(1e-5) under the root,
// and the normalized row scaled by w and shifted by b.
dim M; dim R; dim N;
array x[M, N];
array w[N];
array b[N];
array y[R, N];
array mean[R];
array rstd[R];
mean[r] = sum(j in 0..N, x[r, j]) / N;
rstd[r] = let(mu, sum(j in 0..N, x[r, j]) / N,
              1 / sqrt(sum(j in 0..N, (x[r, j] - mu) * (x[r, j] - mu)) / N
                       + 0.00000999999974737875163555145263671875));
y[r, c] = let(mu, sum(j in 0..N, x[r, j]) / N,
              let(rs, 1 / sqrt(sum(j in 0..N, (x[r, j] - mu) * (x[r, j] - mu)) / N
                               + 0.00000999999974737875163555145263671875),
                  (x[r, c] - mu) * rs * w[c] + b[c]));
