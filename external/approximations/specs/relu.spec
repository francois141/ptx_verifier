// ReLU of C = A @ B^T on block 0's TM x N tile: A is [M, K] row-major and B is stored as N rows
// of K (a column-major K x N matrix); x is the tile element's dot product.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), max(x, 0));
