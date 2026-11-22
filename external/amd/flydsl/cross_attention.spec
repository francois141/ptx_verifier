// Non-causal attention softmax(Q K^T / sqrt(64)) V of S query rows over SKV keys, one batch and
// one head in BSHD layout.
dim S;
dim SKV;
dim D;
array Q[S, D];
array K[SKV, D];
array V[SKV, D];
array O[S, D];

O[i, j] = sum(k in 0..SKV, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8) * V[k, j])
        / sum(k in 0..SKV, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8));
