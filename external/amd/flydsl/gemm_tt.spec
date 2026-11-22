// C = A B for FlyDSL's `tt` layout: A [M, K] stored column-major, B [K, N] stored column-major.
dim M; dim N; dim K;
array a[K, M];
array b[N, K];
array out[M, N];
out[i, j] = sum(k in 0..K, a[k, i] * b[j, k]);
