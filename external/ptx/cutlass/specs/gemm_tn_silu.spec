// D = silu(A B) = x / (1 + e^-x) (A [M, K] row-major, B stored [N, K], D [M, N] row-major).
dim M; dim N; dim K;
array A[M, K]; array B[N, K];
array D[M, N];
D[m, n] = let(x, sum(k in 0..K, A[m, k] * B[n, k]), x / (1 + exp(-x)));
