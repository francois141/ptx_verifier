// vLLM's expandInputRowsKernel (csrc/moe/permute_unpermute_kernels/...kernel.inl:4) on
// expanded dest row P, whose expanded source row is S (token SR = S / topk): the row is
// copied and permuted_idx[P] = S when it is routed to a local expert (V = 1), and
// inv_permuted_idx[S] = P always.
dim N; dim R; dim D; dim P; dim S; dim SR; dim V;
array input[N, D];
array permuted_input[R, D];
array inv_permuted_idx[R];
array permuted_idx[R];
permuted_input[r, c] = where(r == P, where(V == 1, input[SR, c], unwritten), unwritten);
inv_permuted_idx[i] = where(i == S, P, unwritten);
permuted_idx[r] = where(r == P, where(V == 1, S, unwritten), unwritten);
