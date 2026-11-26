// TensorRT-LLM generalRmsNorm without beta: y = x gamma / sqrt(mean(x^2) + eps), eps = f32(1e-6).
dim T; dim N;
array input[T, N];
array gamma[N];
array out[T, N];
out[t, c] = input[t, c] * gamma[c]
        / sqrt(sum(k in 0..N, input[t, k] * input[t, k]) / N + 0.0000009999999974752427078783512115478515625);
