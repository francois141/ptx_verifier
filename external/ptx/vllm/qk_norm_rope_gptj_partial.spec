// fused_qk_norm_rope, GPT-J (interleaved) style, rotary dim R of head_dim D: heads viewed
// [D2, TWO], pairs i < RH = R / 2 rotated by cos/sin index i of position P (cache [PM, TWO, RH]),
// the other pairs normalized only.
dim TWO; dim HQ; dim HK; dim D; dim D2; dim RH; dim PM; dim P;
array q[HQ, D2, TWO];
array k[HK, D2, TWO];
array qw[D2, TWO];
array kw[D2, TWO];
array cache[PM, TWO, RH];
q[h, i, s] = where(i < RH, q[h, i, s] * qw[i, s] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * q[h, i, 1 - s] * qw[i, 1 - s] * cache[P, 1, i],
        q[h, i, s] * qw[i, s])
    / sqrt(sum(a in 0..D2, sum(b in 0..TWO, q[h, a, b] * q[h, a, b])) / D + 0.0000009999999974752427078783512115478515625);
k[h, i, s] = where(i < RH, k[h, i, s] * kw[i, s] * cache[P, 0, i]
        + (2 * sum(r in 0..s, 1) - 1) * k[h, i, 1 - s] * kw[i, 1 - s] * cache[P, 1, i],
        k[h, i, s] * kw[i, s])
    / sqrt(sum(a in 0..D2, sum(b in 0..TWO, k[h, a, b] * k[h, a, b])) / D + 0.0000009999999974752427078783512115478515625);
