// D = A B + bias[n] (A [M, K] row-major, B stored [N, K], D [M, N] row-major).
dim M; dim N; dim K;
array A[M, K]; array B[N, K]; array bias[N];
array D[M, N];
D[m, n] = sum(k in 0..K, A[m, k] * B[n, k]) + bias[n];
