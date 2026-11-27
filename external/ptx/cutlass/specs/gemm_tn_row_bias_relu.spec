// D = relu(A B + bias[m]) (A [M, K] row-major, B stored [N, K], D [M, N] row-major).
dim M; dim N; dim K;
array A[M, K]; array B[N, K]; array bias[M];
array D[M, N];
D[m, n] = max(sum(k in 0..K, A[m, k] * B[n, k]) + bias[m], 0);
