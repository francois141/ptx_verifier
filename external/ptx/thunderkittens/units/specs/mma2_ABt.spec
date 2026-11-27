// c = 2 (ABt): the product accumulated twice into a zeroed accumulator; a [M, K], b [N, K].
dim M; dim N; dim K;
array a[M, K];
array b[N, K];
array c[M, N];
c[i, j] = 2 * sum(k in 0..K, a[i, k] * b[j, k]);
