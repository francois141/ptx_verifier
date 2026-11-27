// FlashInfer RMSNormKernel (norm.cuh:65) with weight_bias 1 (GemmaRMSNorm, norm.cuh:842):
// out = x (1 + w) / sqrt(mean(x^2) + eps) on row B, eps = f32(1e-6).
dim T; dim S; dim N; dim B;
array input[T, S];
array weight[N];
array out[T, N];
out[t, c] = where(t != B, unwritten, input[t, c] * (1 + weight[c])
        / sqrt(sum(k in 0..N, input[t, k] * input[t, k]) / N + 0.0000009999999974752427078783512115478515625));
