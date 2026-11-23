// A tensor scaled per image, c = a * b[n], over the first R images (the outputs workgroup 0
// computes).
dim N; dim C; dim H; dim W; dim R;
array a[N, C, H, W];
array b[N];
array c[R, C, H, W];
c[n, k, h, w] = a[n, k, h, w] * b[n];
