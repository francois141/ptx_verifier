// vLLM's relu_squared: out = max(x, 0)^2.
dim T; dim D;
array input[T, D];
array out[T, D];
out[t, i] = max(input[t, i], 0) * max(input[t, i], 0);
