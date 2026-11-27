// FlashInfer FusedAddRMSNormKernel (norm.cuh:426) with weight_bias 1 (GemmaFusedAddRMSNorm,
// norm.cuh:877), in place on row B: s = input + residual, residual = s,
// input = s (1 + w) / sqrt(mean(s^2) + eps), eps = f32(1e-6).
dim T; dim N; dim B;
array input[T, N];
array residual[T, N];
array weight[N];
residual[t, c] = where(t != B, unwritten, input[t, c] + residual[t, c]);
input[t, c] = where(t != B, unwritten, (input[t, c] + residual[t, c]) * (1 + weight[c])
        / sqrt(sum(k in 0..N, (input[t, k] + residual[t, k]) * (input[t, k] + residual[t, k])) / N
               + 0.0000009999999974752427078783512115478515625));
