// C = A @ B unrolled for K = 3, terms out of order.
dim M;
dim N;
dim K;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = A[i, 2] * B[2, j] + A[i, 0] * B[0, j] + A[i, 1] * B[1, j];
