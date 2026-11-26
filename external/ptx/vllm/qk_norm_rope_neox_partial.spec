// fused_qk_norm_rope, NeoX style, rotary dim R of head_dim D (RH = R / 2): each head of token P
// RMS-normalized with its weight; dims j < R rotated against j +- RH by cos/sin of position P
// (cache [PM, R]: cos at [0, RH), sin at [RH, R)), dims j >= R normalized only.
dim HQ; dim HK; dim D; dim R; dim RH; dim PM; dim P;
array q[HQ, D];
array k[HK, D];
array qw[D];
array kw[D];
array cache[PM, R];
q[h, j] = where(j < RH, q[h, j] * qw[j] * cache[P, j] - q[h, j + RH] * qw[j + RH] * cache[P, RH + j],
          where(j < R, q[h, j] * qw[j] * cache[P, j - RH] + q[h, j - RH] * qw[j - RH] * cache[P, j],
                q[h, j] * qw[j]))
    / sqrt(sum(b in 0..D, q[h, b] * q[h, b]) / D + 0.0000009999999974752427078783512115478515625);
k[h, j] = where(j < RH, k[h, j] * kw[j] * cache[P, j] - k[h, j + RH] * kw[j + RH] * cache[P, RH + j],
          where(j < R, k[h, j] * kw[j] * cache[P, j - RH] + k[h, j - RH] * kw[j - RH] * cache[P, j],
                k[h, j] * kw[j]))
    / sqrt(sum(b in 0..D, k[h, b] * k[h, b]) / D + 0.0000009999999974752427078783512115478515625);
