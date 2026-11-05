// Scaled dot-product attention: O = softmax(Q K^T / 8) V, over one batch and one head.
dim N;
dim H;
array Q[N, H];
array K[N, H];
array V[N, H];
array O[N, H];

O[i, j] = sum(k in 0..N, exp(sum(d in 0..H, Q[i, d] * K[k, d]) / 8) * V[k, j])
        / sum(k in 0..N, exp(sum(d in 0..H, Q[i, d] * K[k, d]) / 8));
