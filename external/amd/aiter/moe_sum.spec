// moe_sum: each token's top-k expert outputs summed.
dim T; dim K; dim H;
array input[T, K, H];
array out[T, H];
out[t, h] = sum(k in 0..K, input[t, k, h]);
