// C = A @ B as a reduction over k.
dim M;
dim N;
dim K;
array A[M, K];
array B[K, N];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[k, j]);
