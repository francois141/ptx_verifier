// TensorRT-LLM prepareAttentionMask (attentionMask.cu:112): batch y's mask rows start at row OFF of
// mask [R, KV] (OFF = cuQSeqLens[y] packed, y * maxQSeqLen padded); the analyzed block x = BX of a
// grid G wide writes mask rows OFF + BX and OFF + BX + G when below NR (actualQSeqLens[y] packed,
// maxQSeqLen padded), every column. A row r's element (row = r - OFF, col = c) is 1 when the
// pair is attended under mask type TYPE, else 0, for a sequence of QL queries and KL keys:
//   0 PADDING                row < QL and col < KL
//   1 CAUSAL                 PADDING and col <= row
//   2 SLIDING_WINDOW_CAUSAL  CAUSAL and col > row - W ("only attend to the previous tokens in a
//                            fixed-length window", gptKernels.h:38)
//   3 BIDIRECTIONAL          (row < QL - 1 and col < KL - 1) or (row == QL - 1 and col < KL)
//   4 BIDIRECTIONALGLM       col < KL - 1 or (row == QL - 1 and col == KL - 1)
//   5 BLOCKSPARSE            CAUSAL and (col >= LOC or col in [VA0, VB0) or [VA1, VB1)): the
//                            block-local window and vertical stripes of the one analyzed row
//                            (gptKernels.h:91 computeMask, its block-granular bounds computed by
//                            the case for that row).
dim R; dim KV; dim OFF; dim NR; dim BX; dim G; dim QL; dim KL; dim W; dim TYPE;
dim LOC; dim VA0; dim VB0; dim VA1; dim VB1;
array mask[R, KV];
mask[r, c] = where(r == OFF + BX, where(BX < NR,
    where(TYPE == 0, where(r < OFF + QL, where(c < KL, 1, 0), 0),
    where(TYPE == 1, where(r < OFF + QL, where(c < KL, where(c + OFF <= r, 1, 0), 0), 0),
    where(TYPE == 2, where(r < OFF + QL, where(c < KL, where(c + OFF <= r, where(c + W + OFF > r, 1, 0), 0), 0), 0),
    where(TYPE == 3, where(r + 1 < OFF + QL, where(c + 1 < KL, 1, 0), where(r + 1 == OFF + QL, where(c < KL, 1, 0), 0)),
    where(TYPE == 4, where(c + 1 < KL, 1, where(r + 1 == OFF + QL, where(c + 1 == KL, 1, 0), 0)),
    where(r < OFF + QL, where(c < KL, where(c + OFF <= r,
        where(c >= LOC, 1, where(c >= VA0, where(c < VB0, 1, where(c >= VA1, where(c < VB1, 1, 0), 0)), 0)),
        0), 0), 0)))))), unwritten),
    where(r == OFF + BX + G, where(BX + G < NR,
    where(TYPE == 0, where(r < OFF + QL, where(c < KL, 1, 0), 0),
    where(TYPE == 1, where(r < OFF + QL, where(c < KL, where(c + OFF <= r, 1, 0), 0), 0),
    where(TYPE == 2, where(r < OFF + QL, where(c < KL, where(c + OFF <= r, where(c + W + OFF > r, 1, 0), 0), 0), 0),
    where(TYPE == 3, where(r + 1 < OFF + QL, where(c + 1 < KL, 1, 0), where(r + 1 == OFF + QL, where(c < KL, 1, 0), 0)),
    where(c + 1 < KL, 1, where(r + 1 == OFF + QL, where(c + 1 == KL, 1, 0), 0)))))), unwritten), unwritten));
