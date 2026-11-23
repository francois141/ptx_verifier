// Aiter's fused_silu_mul: x[r] = [a | b] (each D wide), out[r, c] = silu(a[c]) * b[c].
dim R; dim TWO; dim D;
array x[R, TWO, D];
array out[R, D];
out[r, c] = x[r, 0, c] / (1 + exp(-x[r, 0, c])) * x[r, 1, c];
