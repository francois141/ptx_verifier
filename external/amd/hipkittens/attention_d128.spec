// Non-causal attention softmax(c Q K^T) V over one batch and head, laid out [batch, sequence,
// head, dimension] with batch = head = 1. O holds the first R query rows, the ones workgroup 0
// computes; its indices coincide with the [1, S, 1, D] output's. HipKittens scales Q by the f32
// constant 0.08838834764f * 1.44269504089f and takes exp2 of the scores: exp(c Q K^T) for c that
// constant over f32(log2(e)), 1/sqrt(128) to f32 precision, which the spec states exactly.
dim S;
dim D;
dim R;
array Q[S, D];
array K[S, D];
array V[S, D];
array O[R, D];

O[i, j] = sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) * 0.1275174319744110107421875 / 1.44269502162933349609375) * V[k, j])
        / sum(k in 0..S, exp(sum(d in 0..D, Q[i, d] * K[k, d]) * 0.1275174319744110107421875 / 1.44269502162933349609375));
