// A convolution's bias gradient: db[k] = sum of dy[n, k, h, w] over n, h and w, for the first R
// channels (the outputs workgroup 0 computes).
dim N; dim K; dim H; dim W; dim R;
array dy[N, K, H, W];
array db[R];
db[k] = sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, dy[n, k, h, w])));
