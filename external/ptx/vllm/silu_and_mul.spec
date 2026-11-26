// vLLM's silu_and_mul: each input row is [x | y] (viewed as [T, 2, D]); out = silu(x) * y.
dim T; dim S; dim D;
array input[T, S, D];
array out[T, D];
out[t, i] = input[t, 0, i] / (1 + exp(-input[t, 0, i])) * input[t, 1, i];
