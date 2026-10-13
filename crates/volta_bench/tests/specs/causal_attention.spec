// What the causal attention kernels compute: attention where query i only
// attends to keys 0..=i (fused kernels skip the rest, naive ones multiply by 0).
// (1 + sign(2 * (i - j) + 1)) / 2 is the mask [j <= i]; it folds away at unfold time.
dim LQ;
dim LK;
dim D;
array Q[LQ, D];
array K[LK, D];
array V[LK, D];
array O[LQ, D];

O[i, e] = sum(j in 0..LK, (1 + sign(2 * (i - j) + 1)) / 2
                          * exp(0.125 * sum(d in 0..D, Q[i, d] * K[j, d])) * V[j, e])
        / sum(j in 0..LK, (1 + sign(2 * (i - j) + 1)) / 2
                          * exp(0.125 * sum(d in 0..D, Q[i, d] * K[j, d])));
