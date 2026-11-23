// A convolution's bias added to each channel, c = a + b[channel], over image 0's channel 0 (R = 1)
// or every image's channel 0, the outputs workgroup 0 computes.
dim N; dim C; dim H; dim W; dim R;
array a[N, C, H, W];
array b[C];
array c[R, H, W];
c[n, h, w] = a[n, 0, h, w] + b[0];
