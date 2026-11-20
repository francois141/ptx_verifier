// PyTorch's Hardtanh (-1, 1) of C = A @ B^T on block 0's TM x N tile: A is [M, K] row-major, B
// is stored as N rows of K, and x is the element's dot product.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), min(max(x, -1), 1));
