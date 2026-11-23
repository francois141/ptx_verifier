// C = A B^T, as HipKittens' mma_ABt multiplies its tiles: A [M, K] and B [N, K] row-major. C holds
// the first R rows, the ones workgroup 0 computes; its indices coincide with the [M, N] output's.
dim M;
dim N;
dim K;
dim R;
array a[M, K];
array b[N, K];
array c[R, N];

c[i, j] = sum(k in 0..K, a[i, k] * b[j, k]);
