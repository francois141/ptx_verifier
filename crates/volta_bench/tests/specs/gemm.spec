// What the agent-generated GEMMs compute: C = A @ B (ALPHA = 1, BETA = 0 baked in).
dim M;
dim N;
dim K;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[k, j]);
