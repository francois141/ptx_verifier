// D = A B with A [M, K] row-major, B [K, N] column-major (stored [N, K]) and D [M, N] row-major.
dim M; dim N; dim K;
array A[M, K]; array B[N, K];
array D[M, N];
D[m, n] = sum(k in 0..K, A[m, k] * B[n, k]);
