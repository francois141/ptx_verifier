// D = relu(A B) (A [M, K] row-major, B stored [N, K], D [M, N] row-major) on the analyzed CTA's
// tile [M0, M1) x [N0, N1).
dim M; dim N; dim K; dim M0; dim M1; dim N0; dim N1;
array A[M, K]; array B[N, K];
array D[M, N];
D[m, n] = where(m >= M0, where(m < M1, where(n >= N0, where(n < N1,
    max(sum(k in 0..K, A[m, k] * B[n, k]), 0), unwritten), unwritten), unwritten), unwritten);
