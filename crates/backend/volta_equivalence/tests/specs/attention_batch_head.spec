// One batch/head of softmax(Q K^T / 8) V, with inputs stored as [batch, head, sequence, dimension].
// O uses local indices; the caller separately checks the workgroup's global output footprint.
dim B;
dim G;
dim N;
dim H;
dim Batch;
dim Head;
array Q[B, G, N, H];
array K[B, G, N, H];
array V[B, G, N, H];
array O[N, H];

O[i, j] = sum(k in 0..N, exp(sum(d in 0..H, Q[Batch, Head, i, d] * K[Batch, Head, k, d]) / 8) * V[Batch, Head, k, j])
        / sum(k in 0..N, exp(sum(d in 0..H, Q[Batch, Head, i, d] * K[Batch, Head, k, d]) / 8));
