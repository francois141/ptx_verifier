// What the TileLang GEMMs compute: C = A @ B^T, B stored [N, K] (TileLang's
// transpose_B layout, read off the PTX's address math).
dim M;
dim N;
dim K;
array A[M, K];
array B[N, K];
array C[M, N];

C[i, j] = sum(k in 0..K, A[i, k] * B[j, k]);
