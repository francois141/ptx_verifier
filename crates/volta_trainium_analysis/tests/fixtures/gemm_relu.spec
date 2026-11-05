// out = relu(a_t.T @ b), with a_t A transposed, [K, M].
dim M;
dim N;
dim K;
array a_t[K, M];
array b[K, N];
array out[M, N];

out[i, j] = max(sum(k in 0..K, a_t[k, i] * b[k, j]), 0.0);
