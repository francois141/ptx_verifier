// TensorRT-LLM mhcPostMappingKernel (mhcKernels/mhcKernels.cu:773), hc_mult 4, on one CTA (token T):
// out[t, j, h] = post_mix[t, j] x[t, h] + sum_k comb_mix[t, k, j] residual[t, k, h].
dim B; dim J; dim HS; dim T;
array residual[B, J, HS]; array x[B, HS]; array post[B, J]; array comb[B, J, J]; array out[B, J, HS];
out[t, j, h] = where(t == T, post[t, j] * x[t, h] + sum(k in 0..J, comb[t, k, j] * residual[t, k, h]), unwritten);
