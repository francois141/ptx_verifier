// 2-D fprop cross-correlation, NHWC: out[n, p, q, k] sums act[n, p + r - 1, q + s - 1, c]
// flt[k, r, s, c] over an R x S filter at stride 1, one zero row and column of padding each side.
dim N; dim H; dim W; dim C; dim K; dim R; dim S; dim P; dim Q;
array act[N, H, W, C] padded; array flt[K, R, S, C];
array out[N, P, Q, K];
out[n, p, q, k] = sum(r in 0..R, sum(s in 0..S, sum(c in 0..C,
    act[n, p + r - 1, q + s - 1, c] * flt[k, r, s, c])));
