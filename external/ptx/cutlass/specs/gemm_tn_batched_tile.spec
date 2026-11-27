// D[l] = A[l] B[l] (A [L, M, K], B stored [L, N, K], D [L, M, N]) on batch 0's tile
// [M0, M1) x [N0, N1), the analyzed CTA's.
dim L; dim M; dim N; dim K; dim M0; dim M1; dim N0; dim N1;
array A[L, M, K]; array B[L, N, K];
array D[L, M, N];
D[l, m, n] = where(l < 1, where(m >= M0, where(m < M1, where(n >= N0, where(n < N1,
    sum(k in 0..K, A[l, m, k] * B[l, n, k]), unwritten), unwritten), unwritten), unwritten), unwritten);
