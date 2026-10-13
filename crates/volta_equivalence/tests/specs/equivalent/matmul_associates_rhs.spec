// (AB)C = A(BC). (right side)
dim N;
array A[N, N];
array B[N, N];
array C[N, N];
array D[N, N];

D[i, j] = sum(k in 0..N, A[i, k] * sum(l in 0..N, B[k, l] * C[l, j]));
