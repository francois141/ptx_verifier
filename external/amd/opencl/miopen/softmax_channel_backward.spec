// The gradient of softmax over the channels from its output y: dx = y (dy - sum_k y_k dy_k).
dim N; dim C; dim H; dim W;
array y[N, C, H, W]; array dy[N, C, H, W];
array dx[N, C, H, W];
dx[n, c, h, w] = (dy[n, c, h, w] - sum(k in 0..C, y[n, k, h, w] * dy[n, k, h, w])) * y[n, c, h, w];
