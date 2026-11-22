// C = A B for FlyDSL's `tn` layout: A [M, K] stored column-major, B [K, N] stored row-major.
dim M; dim N; dim K;
array a[K, M];
array b[K, N];
array out[M, N];
out[i, j] = sum(k in 0..K, a[k, i] * b[k, j]);
