// What MatMul-1..7 compute: C = alpha * A @ B + beta * C (each CTA one tile).
dim M;
dim N;
dim K;
param alpha;
param beta;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = alpha * sum(k in 0..K, A[i, k] * B[k, j]) + beta * C[i, j];
