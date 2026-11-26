// vLLM's fused_add_rms_norm, in place: s = input + residual, residual = s,
// input = s w / sqrt(mean(s^2) + eps), eps = f32(1e-6).
dim T; dim N;
array input[T, N];
array residual[T, N];
array weight[N];
residual[t, c] = input[t, c] + residual[t, c];
input[t, c] = (input[t, c] + residual[t, c]) * weight[c]
        / sqrt(sum(k in 0..N, (input[t, k] + residual[t, k]) * (input[t, k] + residual[t, k])) / N
               + 0.0000009999999974752427078783512115478515625);
