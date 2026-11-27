// ThunderKittens' fused residual add + LayerNorm over rows of D = 1024 (dropout p = 0):
// o_resid = residual + x, o = (r - mean) / sqrt(var + f32(1e-5)) * w + b with r = o_resid.
dim B; dim N; dim D;
array x[B, N, D];
array residual[B, N, D];
array norm_weight[D];
array norm_bias[D];
array o[B, N, D];
array o_resid[B, N, D];
o_resid[b, n, d] = residual[b, n, d] + x[b, n, d];
o[b, n, d] = let(mean, sum(k in 0..D, residual[b, n, k] + x[b, n, k]) / 1024,
    (residual[b, n, d] + x[b, n, d] - mean)
    / sqrt(sum(k in 0..D, (residual[b, n, k] + x[b, n, k] - mean) * (residual[b, n, k] + x[b, n, k] - mean)) / 1024
           + 0.00000999999974752427)
    * norm_weight[d] + norm_bias[d]);
