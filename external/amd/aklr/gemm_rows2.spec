// out = a @ b.T, a [M, K] and b [N, K] row-major: out<r> holds columns 0..C of row r, the
// tile workgroup 0 computes (2 rows; row_views in cases.py).
dim M; dim N; dim K; dim C;
array a[M, K];
array b[N, K];
array out0[C];
array out1[C];
out0[j] = sum(k in 0..K, a[0, k] * b[j, k]);
out1[j] = sum(k in 0..K, a[1, k] * b[j, k]);
