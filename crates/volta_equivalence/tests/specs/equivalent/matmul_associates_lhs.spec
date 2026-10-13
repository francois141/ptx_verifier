// (AB)C = A(BC). (left side)
dim N;
array A[N, N];
array B[N, N];
array C[N, N];
array D[N, N];

D[i, j] = sum(l in 0..N, sum(k in 0..N, A[i, k] * B[k, l]) * C[l, j]);
