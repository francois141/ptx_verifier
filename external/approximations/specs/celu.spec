// PyTorch's CELU (alpha 2) of C = A @ B^T on block 0's TM x N tile, written
// max(x, 0) + alpha * (exp(min(x, 0) / alpha) - 1): A is [M, K] row-major, B is N rows of K.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), max(x, 0) + 2 * (exp(min(x, 0) / 2) - 1));
