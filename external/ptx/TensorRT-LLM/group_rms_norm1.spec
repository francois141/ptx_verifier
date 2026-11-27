// TensorRT-LLM GroupRMSNormBaseKernel<n = 1> (groupRmsNormKernels/groupRmsNormKernels.cu:91) on block
// (row BI): out[b, i] = x[b, i] / sqrt(sum_j x[b, j]^2 / D + eps) (w[i] + WB under WEIGHTS), eps = f32(1e-6).
dim B; dim D; dim BI; dim WEIGHTS;
dim WB;
array x[B, D]; array w[D];
array out[B, D];
out[b, i] = where(b == BI, x[b, i] * (1 / sqrt(sum(j in 0..D, x[b, j] * x[b, j]) / D + 0.0000009999999974752427078783512115478515625))
    * where(WEIGHTS == 1, w[i] + WB, 1), unwritten);
