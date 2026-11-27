// c = 2 (AtB): the product accumulated twice into a zeroed accumulator; a [K, M], b [K, N].
dim M; dim N; dim K;
array a[K, M];
array b[K, N];
array c[M, N];
c[i, j] = 2 * sum(k in 0..K, a[k, i] * b[k, j]);
