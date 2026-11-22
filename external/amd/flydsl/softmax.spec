// Softmax along each of the R rows of N columns, max-subtracted.
dim R; dim N;
array x[R, N];
array y[R, N];
y[r, c] = exp(x[r, c] - max(k in 0..N, x[r, k])) / sum(k in 0..N, exp(x[r, k] - max(j in 0..N, x[r, j])));
