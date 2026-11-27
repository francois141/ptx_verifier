// TensorRT-LLM bmm_chunk_kernel<Q, tileM, tileN, ...> (selectiveScan/bmmchunk.h:55), packed tokens (remove_padding):
// for the analyzed block's chunk CI (a sequence's tokens A0 .. A0 + LEN, LEN <= Q) and group G0, its tile
// rows [M0, M0 + TM), columns [N0, N0 + TN) of CB[c, g, i, j] = sum_n C[A0 + i, g, n] B[A0 + j, g, n] (0 where
// i or j >= LEN), with xBC rows [x (H P), B (G N), C (G N)]: B at column BO + n, C at CO + n.
dim T; dim XW; dim CT; dim G; dim Q; dim NS; dim CI; dim G0; dim A0; dim LEN; dim M0; dim N0; dim TM; dim TN;
dim BO; dim CO;
array x[T, XW]; array cb[CT, G, Q, Q];
cb[c, g, i, j] = where(c == CI, where(g == G0, where(i >= M0, where(i < M0 + TM, where(j >= N0, where(j < N0 + TN,
    where(i < LEN, where(j < LEN, sum(n in 0..NS, x[A0 + i, CO + n] * x[A0 + j, BO + n]), 0), 0), unwritten),
    unwritten), unwritten), unwritten), unwritten), unwritten);
