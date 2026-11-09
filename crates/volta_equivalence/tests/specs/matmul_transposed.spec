// C = A @ B^T, with B stored as N rows of K elements.
dim M;
dim N;
dim K;
array A[M, K];
array B[N, K];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[j, k]);
