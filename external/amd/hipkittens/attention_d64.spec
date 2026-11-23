// Non-causal attention softmax(Q K^T / 8) V over one batch and head, laid out [batch, sequence,
// head, dimension] with batch = head = 1. O holds the first R query rows, the ones workgroup 0
// computes; its indices coincide with the [1, S, 1, D] output's. HipKittens scales Q by 0.125
// f32(log2(e)) and takes exp2 of the scores, which over the reals is exp(Q K^T / 8) exactly.
dim S;
dim D;
dim R;
array Q[S, D];
array K[S, D];
array V[S, D];
array O[R, D];

O[i, j] = sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8) * V[k, j])
        / sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) / 8));
