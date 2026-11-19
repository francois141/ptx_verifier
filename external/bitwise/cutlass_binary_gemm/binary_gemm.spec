// CUTLASS OpXorPopc: the number of differing bits between an A row and a B column.
// K=256 bits are packed into KW=8 words. B is column-major in logical [K,N].
dim M; dim N; dim KW; dim TM; dim ROW;
array a[M, KW];
array b[N, KW];
array c[TM, N];
c[m, n] = sum(w in 0..KW, popc(xor(a[ROW + m, w], b[n, w])));
