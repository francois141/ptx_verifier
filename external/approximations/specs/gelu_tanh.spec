// PyTorch's tanh GELU, 0.5 * x * (1 + tanh(sqrt(2 / pi) * (x + 0.044715 * x^3))), of C = A @ B^T on
// block 0's TM x N tile: A is [M, K] row-major, B is stored as N rows of K, x the dot product.
dim M; dim N; dim K; dim TM;
array a[M, K];
array b[N, K];
array c[TM, N];
c[m, n] = let(x, sum(k in 0..K, a[m, k] * b[n, k]), 0.5 * x * (1 + tanh(0.7978845608028654 * (x + 0.044715 * x * x * x))));
