// Residual add, then RMSNorm (rmsnorm2d_fwd_with_add): s = x + residual, residual_out = s,
// y = s w / sqrt(mean(s^2) + eps), eps = f32(1e-6).
dim R; dim N; dim S;
array x[R, S];
array residual[R, N];
array weight[N];
array y[R, N];
array residual_out[R, N];
residual_out[r, c] = x[r, c] + residual[r, c];
y[r, c] = (x[r, c] + residual[r, c]) * weight[c]
        / sqrt(sum(k in 0..N, (x[r, k] + residual[r, k]) * (x[r, k] + residual[r, k])) / N
               + 0.0000009999999974752427078783512115478515625);
