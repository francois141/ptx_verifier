// FlashInfer FusedAddRMSNormKernel (norm.cuh:426), in place on row B with weight_bias 0:
// s = input + residual, residual = s, input = s w / sqrt(mean(s^2) + eps), eps = f32(1e-6).
dim T; dim N; dim B;
array input[T, N];
array residual[T, N];
array weight[N];
residual[t, c] = where(t != B, unwritten, input[t, c] + residual[t, c]);
input[t, c] = where(t != B, unwritten, (input[t, c] + residual[t, c]) * weight[c]
        / sqrt(sum(k in 0..N, (input[t, k] + residual[t, k]) * (input[t, k] + residual[t, k])) / N
               + 0.0000009999999974752427078783512115478515625));
