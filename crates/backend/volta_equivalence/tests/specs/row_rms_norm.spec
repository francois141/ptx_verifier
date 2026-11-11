// Scale each element of one row by gamma over the row's root mean square, with epsilon 2^-20
// under the root. y uses local indices; the caller checks the row's global output footprint.
dim M;
dim N;
dim Row;
array x[M, N];
array gamma[N];
array y[N];

y[j] = x[Row, j] * gamma[j]
     / sqrt(sum(k in 0..N, x[Row, k] * x[Row, k]) / N + 0.00000095367431640625);
