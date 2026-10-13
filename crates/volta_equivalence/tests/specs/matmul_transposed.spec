// C = A @ B^T (B indexed [j, k]): needs N = K.
dim M;
dim N;
dim K;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[j, k]);
