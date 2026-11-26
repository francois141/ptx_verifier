// vLLM's vocab_parallel_embedding: token P's output row is local weight row ROW when its id
// is in this rank's original or added vocab range (IN = 1), else zeros (IN = 0). The analyzed
// block writes columns [C0, C1) of row P; everything else is unwritten.
dim T; dim NR; dim H; dim P; dim ROW; dim IN; dim C0; dim C1;
array weight[NR, H];
array out[T, H];
out[t, c] = where(t != P, unwritten, where(c < C0, unwritten, where(c >= C1, unwritten,
    where(IN == 0, 0, weight[ROW, c]))));
