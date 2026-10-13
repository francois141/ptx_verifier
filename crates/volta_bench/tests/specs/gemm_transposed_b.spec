// C = A @ B^T: must not match the agent-generated GEMMs.
dim M;
dim N;
dim K;
array A[M, K];
array B[N, K];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[j, k]);
