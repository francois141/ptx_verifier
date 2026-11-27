// The token_expert_indices of a fused top-k block: rows [R0, R1), entry j of token t is
// j * T + t (csrc/moe/topk_softmax_kernels.cu:673).
dim T; dim K; dim R0; dim R1;
array token_expert_indices[T, K];
token_expert_indices[t, j] = where(t < R0, unwritten, where(t < R1, j * T + t, unwritten));
