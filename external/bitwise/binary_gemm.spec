// c = A @ B^T over +-1 sign matrices, K = 32 * KW bits per row: K minus twice the number of
// differing bits, with xor, popc and shl the opaque word operations the kernel performs
dim M; dim N; dim KW;
array a[M, KW];
array b[N, KW];
array c[M, N];
c[r, n] = 32 * KW - shl(sum(w in 0..KW, popc(xor(a[r, w], b[n, w]))), 1);
