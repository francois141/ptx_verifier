// Causal attention softmax(Q K^T / sqrt(64)) V over one batch and one head, BSHD inputs with
// batch = head = 1: query row i attends keys 0..i. O holds the first R query rows, the ones
// workgroup 0 computes.
dim S;
dim D;
dim R;
array Q[S, D];
array K[S, D];
array V[S, D];
array O[R, D];

O[i, j] = sum(k in 0..i + 1, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8) * V[k, j])
        / sum(k in 0..i + 1, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8));
