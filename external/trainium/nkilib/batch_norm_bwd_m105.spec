// nkilib experimental batch_norm_bwd (no ReLU, no residual), the standard batchnorm backward
// in terms of the saved per-channel statistics the kernel takes (batch_norm_bwd_torch.py
// differentiates the forward pass, whose statistics are these when they are the batch's):
// xhat = (x - mean) / sqrt(var + eps), dbeta = sum dy, dgamma = sum dy * xhat, and
// dx = gamma / sqrt(var + eps) * (dy - dbeta / M - xhat * dgamma / M), M = B * D * H * W.
dim B;
dim C;
dim D;
dim H;
dim W;
dim M;
dim ONE;
array dy[B, C, D, H, W];
array x_in[B, C, D, H, W];
array means[C];
array variances[C];
array gamma[C, ONE];
array beta[C, ONE];
array dx[B, C, D, H, W];
array dgamma[C, ONE];
array dbeta[C, ONE];

dbeta[c, o] = sum(b in 0..B, sum(d in 0..D, sum(h in 0..H, sum(w in 0..W, dy[b, c, d, h, w]))));
dgamma[c, o] = sum(b in 0..B, sum(d in 0..D, sum(h in 0..H, sum(w in 0..W,
    dy[b, c, d, h, w] * (x_in[b, c, d, h, w] - means[c]) / sqrt(variances[c] + 0.00001)))));
dx[b, c, d, h, w] = gamma[c, 0] / sqrt(variances[c] + 0.00001) * (dy[b, c, d, h, w]
    - sum(i in 0..B, sum(j in 0..D, sum(k in 0..H, sum(l in 0..W, dy[i, c, j, k, l])))) * 0.009523809523809525
    - (x_in[b, c, d, h, w] - means[c]) / sqrt(variances[c] + 0.00001)
      * sum(i in 0..B, sum(j in 0..D, sum(k in 0..H, sum(l in 0..W,
          dy[i, c, j, k, l] * (x_in[i, c, j, k, l] - means[c]) / sqrt(variances[c] + 0.00001)))))
      * 0.009523809523809525);
