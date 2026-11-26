// vLLM's mul_and_silu: the SiLU applies to the second half; out = x * silu(y).
dim T; dim S; dim D;
array input[T, S, D];
array out[T, D];
out[t, i] = input[t, 0, i] * (input[t, 1, i] / (1 + exp(-input[t, 1, i])));
