// Batch normalization's gradients per activation from the saved mean m and inverse deviation s,
// over the N images: x_hat = (x - m) s, dbias = sum dy, dscale = sum x_hat dy, and
// dx = s / N (N scale dy - sum scale dy - x_hat sum scale dy x_hat).
dim N; dim C; dim H; dim W;
array x[N, C, H, W]; array dy[N, C, H, W];
array scale[C, H, W]; array saved_mean[C, H, W]; array saved_inv_variance[C, H, W];
array dx[N, C, H, W]; array dscale[C, H, W]; array dbias[C, H, W];
dbias[c, h, w] = sum(n in 0..N, dy[n, c, h, w]);
dscale[c, h, w] = sum(n in 0..N, (x[n, c, h, w] - saved_mean[c, h, w]) * saved_inv_variance[c, h, w] * dy[n, c, h, w]);
dx[n, c, h, w] = saved_inv_variance[c, h, w] / N * (N * scale[c, h, w] * dy[n, c, h, w]
    - sum(k in 0..N, scale[c, h, w] * dy[k, c, h, w])
    - (x[n, c, h, w] - saved_mean[c, h, w]) * saved_inv_variance[c, h, w]
      * sum(k in 0..N, scale[c, h, w] * dy[k, c, h, w] * (x[k, c, h, w] - saved_mean[c, h, w]) * saved_inv_variance[c, h, w]));
