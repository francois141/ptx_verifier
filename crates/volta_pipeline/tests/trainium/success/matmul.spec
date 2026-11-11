// out = a_t.T @ b, the product nc_matmul computes: a_t is A transposed, [K, M].
dim M;
dim N;
dim K;
array a_t[K, M];
array b[K, N];
array out[M, N];

out[i, j] = sum(k in 0..K, a_t[k, i] * b[k, j]);
