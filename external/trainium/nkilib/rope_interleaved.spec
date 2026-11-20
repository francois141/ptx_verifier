// rope.spec in RoPE's interleaved layout (`contiguous_layout=False`): each head dimension
// viewed as [HALF, TWO], the pair (x[i, 0], x[i, 1]) rotated by angle i.
dim TWO;
dim HALF;
dim B;
dim N;
dim S;
array x_in[HALF, TWO, B, N, S];
array cos[HALF, B, S];
array sin[HALF, B, S];
array x_out[HALF, TWO, B, N, S];

x_out[i, j, b, n, s] = x_in[i, j, b, n, s] * cos[i, b, s]
    + (2 * sum(k in 0..j, 1) - 1) * x_in[i, 1 - j, b, n, s] * sin[i, b, s];
