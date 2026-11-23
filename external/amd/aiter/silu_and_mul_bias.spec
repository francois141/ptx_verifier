// silu_and_mul_bias: token t's row [x | y] (viewed as [T, 2, D]) and its expert's fp32 bias,
// expert 1 for token 0: out = silu(x + bias[1, 0]) * (y + bias[1, 1]).
dim T; dim S; dim D; dim E;
array input[T, S, D];
array bias[E, S, D];
array out[T, D];
out[t, i] = (input[t, 0, i] + bias[1, 0, i]) / (1 + exp(-(input[t, 0, i] + bias[1, 0, i])))
          * (input[t, 1, i] + bias[1, 1, i]);
