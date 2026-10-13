// Row maxima for N = 3 as nested binary max.
dim M;
dim N;
array A[M, N];
array m[M];

m[i] = max(max(A[i, 1], A[i, 0]), A[i, 2]);
