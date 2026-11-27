// D = A B with A [M, K] and B [K, N] both row-major (B N-major) and D [M, N] row-major.
dim M; dim N; dim K;
array A[M, K]; array B[K, N];
array D[M, N];
D[m, n] = sum(k in 0..K, A[m, k] * B[k, n]);
