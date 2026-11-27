// TensorRT-LLM fusedDiTGateResidNormShiftScaleKernelPipelined<4096, 4, 3, no residual, no gate, shift_scale, 1 out>
// (fusedDiTGateResidNormShiftScaleKernel.cu:573) on one CTA: tokens [R0, R1) of batch element BI,
// out[t, d] = x[t, d] rsqrt(|x[t]|^2 / D + eps) (1 + scale[d]) + shift[d], with each modulator its fp32 table
// plus the batch's bf16 timestep row (combine_modulator_chunk, :93). eps = f32(1e-6).
dim T; dim D; dim B; dim R0; dim R1; dim BI;
array x[T, D]; array scale_table[D]; array scale_ts[B, D]; array shift_table[D]; array shift_ts[B, D];
array out[T, D];
out[t, d] = where(t >= R0, where(t < R1, x[t, d] / sqrt(sum(k in 0..D, x[t, k] * x[t, k]) / D
    + 0.0000009999999974752427078783512115478515625) * (1 + (scale_table[d] + scale_ts[BI, d]))
    + (shift_table[d] + shift_ts[BI, d]), unwritten), unwritten);
