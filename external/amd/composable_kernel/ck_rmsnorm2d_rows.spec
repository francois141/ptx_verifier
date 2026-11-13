// RMSNorm of the rows one workgroup owns: each element scaled by gamma over its row's root mean
// square, with epsilon 2^-20 under the root.
dim M;
dim N;
array x[M, N];
array gamma[N];
array y[M, N];

y[i, j] = x[i, j] * gamma[j]
        / sqrt(sum(k in 0..N, x[i, k] * x[i, k]) / N + 0.00000095367431640625);
