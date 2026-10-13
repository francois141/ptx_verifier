// Attention without the 0.125 score scale: must not match the attention kernels.
dim LQ;
dim LK;
dim D;
array Q[LQ, D];
array K[LK, D];
array V[LK, D];
array O[LQ, D];

O[i, e] = sum(j in 0..LK, exp(sum(d in 0..D, Q[i, d] * K[j, d])) * V[j, e])
        / sum(j in 0..LK, exp(sum(d in 0..D, Q[i, d] * K[j, d])));
