// MatMul with the beta * C term dropped: must not match MatMul-1..7.
dim M;
dim N;
dim K;
param alpha;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = alpha * sum(k in 0..K, A[i, k] * B[k, j]);
