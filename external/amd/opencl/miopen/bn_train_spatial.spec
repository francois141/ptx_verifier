// Batch normalization over a training batch, per channel: the batch mean m and variance
// v = max(E[x^2] - m^2, 0) (the kernel's form), y = scale (x - m) / sqrt(v + eps) + bias, and the
// saved mean and inverse standard deviation. eps is the double 1e-5, converted exactly.
dim N; dim C; dim H; dim W;
array x[N, C, H, W];
array scale[C]; array bias[C];
array y[N, C, H, W];
array save_mean[C]; array save_inv_variance[C];
save_mean[c] = sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, x[n, c, h, w]))) / (N * H * W);
save_inv_variance[c] = let(m, sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, x[n, c, h, w]))) / (N * H * W),
    1 / sqrt(max(sum(n in 0..N, sum(h in 0..H, sum(w in 0..W, x[n, c, h, w] * x[n, c, h, w]))) / (N * H * W) - m * m, 0) + 0.000010000000000000000818030539140313095458623138256371021270751953125));
y[n, c, h, w] = let(m, sum(k in 0..N, sum(i in 0..H, sum(j in 0..W, x[k, c, i, j]))) / (N * H * W),
    scale[c] * (x[n, c, h, w] - m) / sqrt(max(sum(k in 0..N, sum(i in 0..H, sum(j in 0..W, x[k, c, i, j] * x[k, c, i, j]))) / (N * H * W) - m * m, 0) + 0.000010000000000000000818030539140313095458623138256371021270751953125) + bias[c]);
