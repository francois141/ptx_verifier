// 2(AB) + 3C with the 2 moved into the sum. (right side)
dim N;
array A[N, N];
array B[N, N];
array C[N, N];
array D[N, N];

D[i, j] = sum(k in 0..N, 2 * A[i, k] * B[k, j]) + C[i, j] * 3;
