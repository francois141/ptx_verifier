// Batch normalization's gradients per channel from the saved mean m and inverse deviation s:
// x_hat = (x - m) s, dbias = sum dy, dscale = sum x_hat dy, and
// dx = scale s / NHW (NHW dy - dbias - x_hat dscale).
dim N; dim C; dim H; dim W;
array x[N, C, H, W]; array dy[N, C, H, W];
array scale[C]; array bias[C]; array saved_mean[C]; array saved_inv_variance[C];
array dx[N, C, H, W]; array dscale[C]; array dbias[C];
dbias[c] = sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, dy[n, c, h, w])));
dscale[c] = sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, (x[n, c, h, w] - saved_mean[c]) * saved_inv_variance[c] * dy[n, c, h, w])));
dx[n, c, h, w] = scale[c] * saved_inv_variance[c] / (N * H * W) * ((N * H * W) * dy[n, c, h, w]
    - sum(k in 0..N, sum(i in 0..H, sum(j in 0..W, dy[k, c, i, j])))
    - (x[n, c, h, w] - saved_mean[c]) * saved_inv_variance[c]
      * sum(k in 0..N, sum(i in 0..H, sum(j in 0..W, (x[k, c, i, j] - saved_mean[c]) * saved_inv_variance[c] * dy[k, c, i, j]))));
