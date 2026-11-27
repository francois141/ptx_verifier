// TensorRT-LLM buildCuQSeqLens (attentionMask.cu:59): the last block (LAST = 1) stores the exclusive
// prefix sums cu[i] = q_lens[0] + ... + q_lens[i - 1], i in 0..B (cu[B] the total). SHIFT is 0
// (a negative case's offset).
dim B; dim B1; dim LAST; dim SHIFT;
array q_lens[B];
array cu[B1];
cu[i] = where(LAST == 1, sum(k in 0..i, q_lens[k]) + SHIFT, unwritten);
