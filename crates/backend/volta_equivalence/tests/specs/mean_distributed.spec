// Row means: every term divided by N.
dim M;
dim N;
array A[M, N];
array mean[M];

mean[i] = sum(j in 0..N, A[i, j] / N);
