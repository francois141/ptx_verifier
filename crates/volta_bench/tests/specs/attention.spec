// What the attention kernels compute: O = softmax(scale * Q @ K^T) @ V, with
// scale = 1/sqrt(64) = 0.125 (concrete in the benchmark configs).
dim LQ;
dim LK;
dim D;
array Q[LQ, D];
array K[LK, D];
array V[LK, D];
array O[LQ, D];

O[i, e] = sum(j in 0..LK, exp(0.125 * sum(d in 0..D, Q[i, d] * K[j, d])) * V[j, e])
        / sum(j in 0..LK, exp(0.125 * sum(d in 0..D, Q[i, d] * K[j, d])));
