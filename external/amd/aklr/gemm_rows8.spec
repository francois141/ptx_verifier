// out = a @ b.T, a [M, K] and b [N, K] row-major: out<r> holds columns 0..C of row r, the
// tile workgroup 0 computes (8 rows; row_views in cases.py).
dim M; dim N; dim K; dim C;
array a[M, K];
array b[N, K];
array out0[C];
array out1[C];
array out2[C];
array out3[C];
array out4[C];
array out5[C];
array out6[C];
array out7[C];
out0[j] = sum(k in 0..K, a[0, k] * b[j, k]);
out1[j] = sum(k in 0..K, a[1, k] * b[j, k]);
out2[j] = sum(k in 0..K, a[2, k] * b[j, k]);
out3[j] = sum(k in 0..K, a[3, k] * b[j, k]);
out4[j] = sum(k in 0..K, a[4, k] * b[j, k]);
out5[j] = sum(k in 0..K, a[5, k] * b[j, k]);
out6[j] = sum(k in 0..K, a[6, k] * b[j, k]);
out7[j] = sum(k in 0..K, a[7, k] * b[j, k]);
