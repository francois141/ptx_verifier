// An NHWC tensor in NCHW layout.
dim N; dim C; dim H; dim W;
array x[N, H, W, C];
array y[N, C, H, W];
y[n, c, h, w] = x[n, h, w, c];
