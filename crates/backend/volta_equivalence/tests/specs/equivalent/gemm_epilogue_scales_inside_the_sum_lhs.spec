// 2(AB) + 3C with the 2 moved into the sum. (left side)
dim N;
array A[N, N];
array B[N, N];
array C[N, N];
array D[N, N];

D[i, j] = 2 * sum(k in 0..N, A[i, k] * B[k, j]) + 3 * C[i, j];
