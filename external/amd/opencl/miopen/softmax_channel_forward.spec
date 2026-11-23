// Softmax over the channels of an NCHW tensor, at every (n, h, w).
dim N; dim C; dim H; dim W;
array x[N, C, H, W];
array y[N, C, H, W];
y[n, c, h, w] = exp(x[n, c, h, w]) / sum(k in 0..C, exp(x[n, k, h, w]));
