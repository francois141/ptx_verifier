// FlashInfer RMSNormKernel (norm.cuh:65) with weight_bias 0 (RMSNorm): row B of a [T, S]-strided
// input, out = x w / sqrt(mean(x^2) + eps) over its first N elements, eps = f32(1e-6); the
// analyzed block writes only its row.
dim T; dim S; dim N; dim B;
array input[T, S];
array weight[N];
array out[T, N];
out[t, c] = where(t != B, unwritten, input[t, c] * weight[c]
        / sqrt(sum(k in 0..N, input[t, k] * input[t, k]) / N + 0.0000009999999974752427078783512115478515625));
