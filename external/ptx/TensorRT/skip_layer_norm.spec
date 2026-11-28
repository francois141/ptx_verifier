// TensorRT skipLayerNorm: x = input + skip + bias, y = gamma (x - mean) / sqrt(E[x^2] - mean^2) + beta.
// layerNorm (common.cuh), which skipLayerNormKernel{,Small} call, adds no epsilon.
dim T; dim N;
array input[T, N];
array skip[T, N];
array bias[N];
array gamma[N];
array beta[N];
array output[T, N];
output[t, c] = let(m, sum(k in 0..N, input[t, k] + skip[t, k] + bias[k]) / N,
    gamma[c] * (input[t, c] + skip[t, c] + bias[c] - m)
    / sqrt(sum(k in 0..N, (input[t, k] + skip[t, k] + bias[k]) * (input[t, k] + skip[t, k] + bias[k])) / N - m * m)
    + beta[c]);
