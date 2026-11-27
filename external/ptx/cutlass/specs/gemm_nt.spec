// D = A B with A [M, K] column-major (stored [K, M], M-major), B [K, N] column-major (stored
// [N, K]) and D [M, N] row-major.
dim M; dim N; dim K;
array A[K, M]; array B[N, K];
array D[M, N];
D[m, n] = sum(k in 0..K, A[k, m] * B[n, k]);
