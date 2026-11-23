// Residual add, then RMSNorm: s = x + residual, residual_out = s,
// normalized = s w / sqrt(mean(s^2) + eps), eps = f32(1e-5).
dim R; dim N;
array x[R, N];
array residual[R, N];
array weight[N];
array normalized[R, N];
array residual_out[R, N];
residual_out[r, c] = x[r, c] + residual[r, c];
normalized[r, c] = (x[r, c] + residual[r, c]) * weight[c]
        / sqrt(sum(k in 0..N, (x[r, k] + residual[r, k]) * (x[r, k] + residual[r, k])) / N
               + 0.00000999999974737875163555145263671875);
