// vLLM's shuffle_rows (csrc/moe/moe_permute_unpermute_op.cu:252) on destination row P:
// source row S when it is in [0, N) (V = 1), else zeros.
dim N; dim M; dim D; dim P; dim S; dim V;
array input[N, D];
array output[M, D];
output[r, c] = where(r == P, where(V == 1, input[S, c], 0), unwritten);
