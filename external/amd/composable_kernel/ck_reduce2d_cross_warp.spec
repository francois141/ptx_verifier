// The sum of each row of x.
dim M;
dim N;
array x[M, N];
array y[M];

y[i] = sum(j in 0..N, x[i, j]);
