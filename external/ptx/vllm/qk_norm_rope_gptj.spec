// fused_qk_norm_rope, GPT-J (interleaved) style, rot = head_dim = 2E: heads viewed [E, TWO]
// (weights likewise), each pair (x[i, 0], x[i, 1]) of the normalized head rotated by angle i.
dim TWO; dim HQ; dim HK; dim E; dim D; dim PM; dim P;
array q[HQ, E, TWO];
array k[HK, E, TWO];
array qw[E, TWO];
array kw[E, TWO];
array cache[PM, TWO, E];
q[h, i, s] = (q[h, i, s] * qw[i, s] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * q[h, i, 1 - s] * qw[i, 1 - s] * cache[P, 1, i])
    / sqrt(sum(a in 0..E, sum(b in 0..TWO, q[h, a, b] * q[h, a, b])) / D
           + 0.0000009999999974752427078783512115478515625);
k[h, i, s] = (k[h, i, s] * kw[i, s] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * k[h, i, 1 - s] * kw[i, 1 - s] * cache[P, 1, i])
    / sqrt(sum(a in 0..E, sum(b in 0..TWO, k[h, a, b] * k[h, a, b])) / D
           + 0.0000009999999974752427078783512115478515625);
