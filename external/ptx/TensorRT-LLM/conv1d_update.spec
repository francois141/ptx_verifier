// TensorRT-LLM causal_conv1d_update_kernel / _sl1 (causalConv1d.cu:1127, :1248), non-circular, on
// block (batch BI, channel block): channels [C0, C1) of batch BI, whose state is slot SLOT. Over the
// sequence s = state[SLOT, c, 0..SL) ++ x[BI, c, 0..L), token t's output, written over x in place
// (causalConv1dOp.cpp:386), is act(bias[c] + sum_j w[c, j] s[SL + t - (W - 1) + j]) with act(r) =
// r / (1 + exp(-r)) under SILU; the state becomes s[L..L + SL).
dim B; dim D; dim L; dim W; dim NS; dim SL; dim BI; dim SLOT; dim C0; dim C1; dim SILU; dim BIAS;
array w[D, W]; array bias[D];
array x[B, D, L]; array state[NS, D, SL];
x[b, c, t] = where(b == BI, where(c >= C0, where(c < C1,
    let(r, where(BIAS == 1, bias[c], 0) + sum(j in 0..W, w[c, j] * where(t + j < W - 1,
            state[SLOT, c, SL + t - (W - 1) + j], x[b, c, t + j - (W - 1)])),
        where(SILU == 1, r / (1 + exp(-r)), r)),
    unwritten), unwritten), unwritten);
state[n, c, p] = where(n == SLOT, where(c >= C0, where(c < C1,
    where(p + L < SL, state[n, c, p + L], x[BI, c, p + L - SL]), unwritten), unwritten), unwritten);
