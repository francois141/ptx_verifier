// flash_attn_func(q, k, v) for one batch and one head (bshd, contiguous), softmax_scale 1/sqrt(64):
// o = softmax(q k^T / 8) v.
dim SQ; dim SK; dim D;
array q[SQ, D];
array k[SK, D];
array v[SK, D];
array o[SQ, D];
o[i, c] = let(m, max(l in 0..SK, sum(e in 0..D, q[i, e] * k[l, e]) / 8),
              sum(j in 0..SK, exp(sum(e in 0..D, q[i, e] * k[j, e]) / 8 - m) * v[j, c])
              / sum(j in 0..SK, exp(sum(e in 0..D, q[i, e] * k[j, e]) / 8 - m)));
