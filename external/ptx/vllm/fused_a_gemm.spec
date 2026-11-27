// vLLM's DeepSeek-V3 fused-A GEMM (csrc/dsv3_fused_a_gemm.cu): output = mat_a w^T, mat_a
// [T, K] with row stride S, w [O, K]; the block writes outputs [O0, O1) of tokens [N0, N1).
dim T; dim S; dim K; dim O; dim O0; dim O1; dim N0; dim N1;
array mat_a[T, S];
array weight[O, K];
array output[T, O];
output[t, o] = where(t < N0, unwritten, where(t >= N1, unwritten, where(o < O0, unwritten,
    where(o >= O1, unwritten, sum(k in 0..K, mat_a[t, k] * weight[o, k])))));
