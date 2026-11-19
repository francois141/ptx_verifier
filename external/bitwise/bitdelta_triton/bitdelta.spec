// Same packed-sign matmul as ../bitdelta_llm/bitdelta.spec.
// The original 256x256 kernel writes a contiguous 16x256 tile per CTA.
dim M; dim N; dim K; dim KW; dim NB; dim MA;
array a[MA, K];
array b[KW, NB];
array c[M, N];
c[m, n] = sum(w in 0..KW, sum(i in 0..32, a[m, 32 * w + i] * (2 * and(shr(b[w, n], i), 1) - 1)));
