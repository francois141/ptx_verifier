// vLLM's gelu_quick: out = x sigmoid(1.702 x) = x / (1 + exp(-1.702 x)), 1.702 as an f32.
dim T; dim D;
array input[T, D];
array out[T, D];
out[t, i] = input[t, i] / (1 + exp(-1.70200002193450927734375 * input[t, i]));
