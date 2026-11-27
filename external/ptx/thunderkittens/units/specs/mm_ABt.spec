// The product ABt (t: transposed operand): c = sum over k of the two operands.
dim M; dim N; dim K;
array a[M, K];
array b[N, K];
array c[M, N];
c[i, j] = sum(k in 0..K, a[i, k] * b[j, k]);
