// The NKI samples' matrix multiplication tutorial, transcribing its torch driver's
// `torch.matmul(lhs, rhs)` over its kernels' names: they take `lhsT`, lhs transposed.
dim M;
dim N;
dim K;
array lhsT[K, M];
array rhs[K, N];
array result[M, N];

result[i, j] = sum(k in 0..K, lhsT[k, i] * rhs[k, j]);
