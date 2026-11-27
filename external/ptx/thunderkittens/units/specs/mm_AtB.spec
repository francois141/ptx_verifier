// The product AtB (t: transposed operand): c = sum over k of the two operands.
dim M; dim N; dim K;
array a[K, M];
array b[K, N];
array c[M, N];
c[i, j] = sum(k in 0..K, a[k, i] * b[k, j]);
