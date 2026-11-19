// c = a @ W with W[k, n] = +1 where bit k % 32 of b[k / 32, n] is set, else -1: the sign
// matrix BitDelta packs 32 K values per i32 word, its K / 32 rows by N columns (NB wide)
dim M; dim N; dim K; dim KW; dim NB;
array a[M, K];
array b[KW, NB];
array c[M, N];
c[m, n] = sum(w in 0..KW, sum(i in 0..32, a[m, 32 * w + i] * (2 * and(shr(b[w, n], i), 1) - 1)));
