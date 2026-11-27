// TensorRT-LLM GroupRMSNormBaseKernel<n = 2> (groupRmsNormKernels/groupRmsNormKernels.cu:91) on block
// (row BI): each input normalized by its own row's RMS, out_k[b, i] = x_k[b, i] / sqrt(sum_j
// x_k[b, j]^2 / D_k + eps) (w_k[i] + WB under WEIGHTS).
dim B; dim DA; dim DB; dim BI; dim WEIGHTS;
dim WB;
array xa[B, DA]; array wa[DA]; array xb[B, DB]; array wb[DB];
array outa[B, DA]; array outb[B, DB];
outa[b, i] = where(b == BI, xa[b, i] * (1 / sqrt(sum(j in 0..DA, xa[b, j] * xa[b, j]) / DA + 0.0000009999999974752427078783512115478515625))
    * where(WEIGHTS == 1, wa[i] + WB, 1), unwritten);
outb[b, i] = where(b == BI, xb[b, i] * (1 / sqrt(sum(j in 0..DB, xb[b, j] * xb[b, j]) / DB + 0.0000009999999974752427078783512115478515625))
    * where(WEIGHTS == 1, wb[i] + WB, 1), unwritten);
