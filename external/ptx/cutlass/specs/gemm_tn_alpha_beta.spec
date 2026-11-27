// D = 1.5 A B + 0.5 C (A [M, K] row-major, B stored [N, K], C and D [M, N] row-major).
dim M; dim N; dim K;
array A[M, K]; array B[N, K]; array C[M, N];
array D[M, N];
D[m, n] = 1.5 * sum(k in 0..K, A[m, k] * B[n, k]) + 0.5 * C[m, n];
