// Non-causal attention softmax(Q K^T / sqrt(64)) V over one batch and one head, inputs laid out
// [batch, sequence, head, dimension] (BSHD) with batch = head = 1. O holds the first R query rows,
// the ones workgroup 0 computes; its indices coincide with the BSHD output's.
dim S;
dim D;
dim R;
array Q[S, D];
array K[S, D];
array V[S, D];
array O[R, D];

O[i, j] = sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8) * V[k, j])
        / sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8));
