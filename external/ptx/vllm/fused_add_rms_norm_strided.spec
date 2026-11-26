// vLLM's fused_add_rms_norm on strided rows: input [T, IS] and residual [T, RS] (row strides
// IS, RS >= N), in place on token P's first N columns: s = input + residual, residual = s,
// input = s w / sqrt(mean(s^2) + eps). Other rows and the trailing columns are unwritten.
dim T; dim N; dim IS; dim RS; dim P;
array input[T, IS];
array residual[T, RS];
array weight[N];
residual[t, c] = where(t != P, unwritten, where(c >= N, unwritten, input[t, c] + residual[t, c]));
input[t, c] = where(t != P, unwritten, where(c >= N, unwritten,
    (input[t, c] + residual[t, c]) * weight[c]
    / sqrt(sum(k in 0..N, (input[t, k] + residual[t, k]) * (input[t, k] + residual[t, k])) / N
           + 0.0000009999999974752427078783512115478515625)));
