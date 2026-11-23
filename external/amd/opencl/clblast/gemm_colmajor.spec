// Column-major C = A B: a[k, i] is A's element (i, k), b[j, k] is B's (k, j), c[j, i] is C's (i, j).
dim M; dim N; dim K;
array a[K, M]; array b[N, K];
array c[N, M];
c[j, i] = sum(k in 0..K, a[k, i] * b[j, k]);
