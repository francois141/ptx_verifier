// XOR-popcount GEMM: the Hamming distance between a row of A and a row of B.
// K = 32 * KW bits per row; CTA 0 writes the first TM full rows of C.
dim MA; dim N; dim KW; dim TM;
array a[MA, KW];
array b[N, KW];
array c[TM, N];
c[m, n] = sum(w in 0..KW, popc(xor(a[m, w], b[n, w])));
