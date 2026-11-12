// The example's own check, `ref_c = a @ b`: C = A @ B, run with M = N = 128, K = 64.
dim M;
dim N;
dim K;

array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[k, j]);
