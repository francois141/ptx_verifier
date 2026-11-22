// C = A B for FlyDSL's `nt` layout: A [M, K] stored row-major, B [K, N] stored column-major.
dim M; dim N; dim K;
array a[M, K];
array b[N, K];
array out[M, N];
out[i, j] = sum(k in 0..K, a[i, k] * b[j, k]);
