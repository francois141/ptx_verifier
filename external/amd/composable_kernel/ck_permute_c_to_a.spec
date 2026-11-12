// The four input words of PermuteWarpGemmCToA's model, each written twice: out[2 i + j] = in[i].
// The buffers are larger (16 and 32 words), so any other written output is an overflow.
dim N;
dim COPIES;
array in[N];
array out[N, COPIES];

out[i, j] = in[i];
