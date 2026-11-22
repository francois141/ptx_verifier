// RMSNorm along each row, eps f32(1e-5) under the root: y = x gamma / sqrt(mean(x^2) + eps).
dim R; dim N;
array x[R, N];
array gamma[N];
array y[R, N];
y[r, c] = x[r, c] * gamma[c] / sqrt(sum(k in 0..N, x[r, k] * x[r, k]) / N + 0.00000999999974737875163555145263671875);
