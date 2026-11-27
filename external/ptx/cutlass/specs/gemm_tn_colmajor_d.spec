// D = A B (A [M, K] row-major, B stored [N, K]) with D [M, N] column-major, stored [N, M].
dim M; dim N; dim K;
array A[M, K]; array B[N, K];
array D[N, M];
D[n, m] = sum(k in 0..K, A[m, k] * B[n, k]);
