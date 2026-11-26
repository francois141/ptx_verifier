// vLLM's fused_qk_norm_rope (TensorRT-LLM's fusedQKNormRopeKernel), NeoX style, rot = head_dim =
// 2E, in place on token P's q heads [HQ, TWO, E] and k heads [HK, TWO, E] of qkv: each head
// RMS-normalized with its weight (w viewed [TWO, E]), then rotated by position P's cos/sin.
dim TWO; dim HQ; dim HK; dim E; dim D; dim PM; dim P;
array q[HQ, TWO, E];
array k[HK, TWO, E];
array qw[TWO, E];
array kw[TWO, E];
array cache[PM, TWO, E];
q[h, s, i] = (q[h, s, i] * qw[s, i] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * q[h, 1 - s, i] * qw[1 - s, i] * cache[P, 1, i])
    / sqrt(sum(a in 0..TWO, sum(b in 0..E, q[h, a, b] * q[h, a, b])) / D
           + 0.0000009999999974752427078783512115478515625);
k[h, s, i] = (k[h, s, i] * kw[s, i] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * k[h, 1 - s, i] * kw[1 - s, i] * cache[P, 1, i])
    / sqrt(sum(a in 0..TWO, sum(b in 0..E, k[h, a, b] * k[h, a, b])) / D
           + 0.0000009999999974752427078783512115478515625);
