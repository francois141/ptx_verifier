// TensorRT-LLM mamba_conv1d_generation_kernel<T, 4, 4> (mambaConv1dKernels.cu:1193), one decode
// step of the causal depthwise conv1d on block (x, sample S): channels [C0, C1) of sample S, whose
// state slot is SLOT: out = silu?(sum_k w[k, c] window[k] + bias[c]) over the window (the 3 state
// rows, then x[S, PRE + c]); silu(r) = r * (r < -20 ? 0 : 1 / (1 + exp(-r))). The state shifts by
// one: row i becomes row i + 1, the last row the input. Paged state, in place (mambaConv1dOp.cpp:106).
dim B; dim D; dim DIN; dim PRE; dim NS; dim K; dim KM1; dim S; dim SLOT; dim C0; dim C1; dim SILU;
array x[B, DIN]; array w[K, D]; array bias[D]; array st[NS, KM1, D]; 
array out[B, D];
out[s, c] = where(s == S, where(c >= C0, where(c < C1,
    let(r, w[0, c] * st[SLOT, 0, c] + w[1, c] * st[SLOT, 1, c] + w[2, c] * st[SLOT, 2, c]
        + w[3, c] * x[s, PRE + c] + bias[c],
      where(SILU == 1, r * where(r < -20, 0, 1 / (1 + exp(-r))), r)),
    unwritten), unwritten), unwritten);
st[n, i, c] = where(n == SLOT, where(c >= C0, where(c < C1,
    where(i < 2, st[n, i + 1, c], x[S, PRE + c]), unwritten), unwritten), unwritten);
