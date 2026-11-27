// c = 2 (AtBt): the product accumulated twice into a zeroed accumulator; a [K, M], b [N, K].
dim M; dim N; dim K;
array a[K, M];
array b[N, K];
array c[M, N];
c[i, j] = 2 * sum(k in 0..K, a[k, i] * b[j, k]);
