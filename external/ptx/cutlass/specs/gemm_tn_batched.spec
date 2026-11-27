// D[l] = A[l] B[l] over L batches (A [L, M, K], B stored [L, N, K], D [L, M, N]).
dim L; dim M; dim N; dim K;
array A[L, M, K]; array B[L, N, K];
array D[L, M, N];
D[l, m, n] = sum(k in 0..K, A[l, m, k] * B[l, n, k]);
