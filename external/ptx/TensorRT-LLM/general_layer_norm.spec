// TensorRT-LLM generalLayerNorm: y = (x - mean) / sqrt(var + eps) gamma + beta, var = E[(x - mean)^2].
dim T; dim N;
array input[T, N];
array gamma[N];
array beta[N];
array out[T, N];
out[t, c] = let(m, sum(k in 0..N, input[t, k]) / N,
        (input[t, c] - m) * gamma[c]
        / sqrt(sum(k in 0..N, (input[t, k] - m) * (input[t, k] - m)) / N + 0.0000009999999974752427078783512115478515625) + beta[c]);
