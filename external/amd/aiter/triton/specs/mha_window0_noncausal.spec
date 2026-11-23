// flash_attn_func(q, k, v, causal=False, window_size=(0, -1)) as its docstring states, seqlen_q =
// seqlen_k = S: query i attends keys in [i + seqlen_k - seqlen_q - 0, inf) = [i, S).
dim S; dim D;
array q[S, D];
array k[S, D];
array v[S, D];
array o[S, D];
o[i, c] = let(m, max(l in i..S, sum(e in 0..D, q[i, e] * k[l, e]) / 8),
              sum(j in i..S, exp(sum(e in 0..D, q[i, e] * k[j, e]) / 8 - m) * v[j, c])
              / sum(j in i..S, exp(sum(e in 0..D, q[i, e] * k[j, e]) / 8 - m)));
