// C = A B for FlyDSL's `nn` layout: A [M, K] stored row-major, B [K, N] stored row-major.
dim M; dim N; dim K;
array a[M, K];
array b[K, N];
array out[M, N];
out[i, j] = sum(k in 0..K, a[i, k] * b[k, j]);
