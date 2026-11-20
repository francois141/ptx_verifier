// nkilib's attention_cte, causal, scale 1, from attention_cte_torch.py: each query row's
// softmax over its scores q . k, applied to V. As the kernel masks, a key past the query
// scores `low`, the double of nkilib's _FLOAT32_MIN = -3.4028235e38 (its 53-bit mantissa
// times 2^75), not -inf: its exp is 0 in float32 but not over the reals, so the spec keeps
// those terms. The row maximum's masked part is an empty max (the identity) on the last row.
dim B;
dim S;
dim D;
array q[B, S, D];
array k[B, D, S];
array v[B, S, D];
array out[B, S, D];

out[b, i, d] =
    let(low, -(9007198806847480.0 * pow(2.0, 75)),
    let(m, max(max(j in 0..i + 1, sum(e in 0..D, q[b, i, e] * k[b, e, j])),
               max(j in i + 1..S, low)),
    (sum(j in 0..i + 1, exp(sum(e in 0..D, q[b, i, e] * k[b, e, j]) - m) * v[b, j, d])
     + sum(j in i + 1..S, exp(low - m) * v[b, j, d]))
    / (sum(j in 0..i + 1, exp(sum(e in 0..D, q[b, i, e] * k[b, e, j]) - m))
       + sum(j in i + 1..S, exp(low - m)))));
