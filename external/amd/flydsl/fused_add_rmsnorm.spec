// The residual add, stored, then RMSNorm of the sum, eps f32(1e-5).
dim R; dim N;
array x[R, N];
array residual[R, N];
array gamma[N];
array y[R, N];
array residual_out[R, N];
residual_out[r, c] = x[r, c] + residual[r, c];
y[r, c] = (x[r, c] + residual[r, c]) * gamma[c]
        / sqrt(sum(k in 0..N, (x[r, k] + residual[r, k]) * (x[r, k] + residual[r, k])) / N + 0.00000999999974737875163555145263671875);
