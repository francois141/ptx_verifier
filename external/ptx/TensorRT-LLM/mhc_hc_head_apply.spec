// TensorRT-LLM mhcHcHeadApplyKernel (mhcKernels/mhcKernels.cu:885) on one CTA (token T): mix_j = sigmoid(mixes[t, j]
// rsqrt(sqrsum[t] / K + norm_eps) scale + base[j]) + eps; out[t, h] = sum_j mix_j x[t, j, h]. norm_eps = eps = f32(1e-6).
dim M; dim J; dim HS; dim K; dim T; dim ONE;
array mixes[M, J]; array sqrsum[M]; array x[M, J, HS]; array scale[ONE]; array base[J]; array out[M, HS];
out[t, h] = where(t == T, sum(j in 0..J, (1 / (1 + exp(-(mixes[t, j] / sqrt(sqrsum[t] / K + 0.0000009999999974752427078783512115478515625) * scale[0] + base[j]))) + 0.0000009999999974752427078783512115478515625) * x[t, j, h]), unwritten);
