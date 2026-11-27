// c = 2 (AB): the product accumulated twice into a zeroed accumulator; a [M, K], b [K, N].
dim M; dim N; dim K;
array a[M, K];
array b[K, N];
array c[M, N];
c[i, j] = 2 * sum(k in 0..K, a[i, k] * b[k, j]);
