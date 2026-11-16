// out = a_t.T @ b, the M x N tile, K the contraction length (Trainium; a_t is A transposed)
dim M; dim N; dim K;
array a_t[K, M];
array b[K, N];
array out[M, N];
out[i, j] = sum(k in 0..K, a_t[k, i] * b[k, j]);
