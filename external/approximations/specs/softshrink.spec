// PyTorch's Softshrink (lambd 0.5) of C = A @ B^T on block 0's TM x N tile, written
// max(x - lambd, 0) + min(x + lambd, 0): A is [M, K] row-major, B is stored as N rows of K.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), max(x - 0.5, 0) + min(x + 0.5, 0));
