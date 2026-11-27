// The product AtBt (t: transposed operand): c = sum over k of the two operands.
dim M; dim N; dim K;
array a[K, M];
array b[N, K];
array c[M, N];
c[i, j] = sum(k in 0..K, a[k, i] * b[j, k]);
