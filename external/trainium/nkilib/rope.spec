// nkilib's RoPE in its contiguous layout, from rope_torch.py with the rotary dimension the
// whole head: each head dimension viewed as [TWO, HALF], the pair (x[0, i], x[1, i]) rotated
// by angle i, so x_out[j, i] = x[j, i] * cos[i] + (2j - 1) * x[1 - j, i] * sin[i]. The sign
// is written 2 * (sum over k < j of 1) - 1, as a spec reads indices only in subscripts.
dim TWO;
dim HALF;
dim B;
dim N;
dim S;
array x_in[TWO, HALF, B, N, S];
array cos[HALF, B, S];
array sin[HALF, B, S];
array x_out[TWO, HALF, B, N, S];

x_out[j, i, b, n, s] = x_in[j, i, b, n, s] * cos[i, b, s]
    + (2 * sum(k in 0..j, 1) - 1) * x_in[1 - j, i, b, n, s] * sin[i, b, s];
