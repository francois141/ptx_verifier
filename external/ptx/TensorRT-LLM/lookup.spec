// TensorRT-LLM lookup_kernel (a vocab-sharded embedding): out[t, c] = weight[ids[t] - OFFSET, c] when
// the id falls in this shard [OFFSET, OFFSET + SIZE), else 0. Ids are dims I0..I3 (up to 4
// tokens; W_t = 1 when in the shard), out viewed [T, NG, BS] (N = NG BS). Block G of the
// grid-stride loop writes chunk g == G of every token (MODE 0) or token t == G whole (MODE 1).
dim T; dim N; dim SIZE; dim G; dim BS; dim NG; dim MODE;
dim I0; dim I1; dim I2; dim I3; dim W0; dim W1; dim W2; dim W3;
array weight[SIZE, N];
array out[T, NG, BS];
out[t, g, j] = where(MODE == 0,
    where(g == G, where(t == 0, where(W0 == 1, weight[I0, g * BS + j], 0), where(t == 1, where(W1 == 1, weight[I1, g * BS + j], 0), where(t == 2, where(W2 == 1, weight[I2, g * BS + j], 0), where(W3 == 1, weight[I3, g * BS + j], 0)))), unwritten),
    where(t == G, where(t == 0, where(W0 == 1, weight[I0, g * BS + j], 0), where(t == 1, where(W1 == 1, weight[I1, g * BS + j], 0), where(t == 2, where(W2 == 1, weight[I2, g * BS + j], 0), where(W3 == 1, weight[I3, g * BS + j], 0)))), unwritten));
