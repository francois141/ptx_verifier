// Row maxima as a max reduction (identity -inf).
dim M;
dim N;
array A[M, N];
array m[M];

m[i] = max(j in 0..N, A[i, j]);
