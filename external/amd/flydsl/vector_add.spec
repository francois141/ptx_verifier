// C = A + B elementwise over an M x N f32 matrix.
dim M; dim N;
array A[M, N];
array B[M, N];
array C[M, N];
C[i, j] = A[i, j] + B[i, j];
