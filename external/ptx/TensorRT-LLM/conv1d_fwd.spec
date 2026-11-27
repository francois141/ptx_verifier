// TensorRT-LLM causal_conv1d_fwd_kernel (causalConv1d.cu:158) on block (sequence BI, channel block):
// channels [C0, C1) of the sequence at x[XB, c, S0 .. S0 + L) (XB = BI, S0 = 0 padded; XB = 0,
// S0 = query_start_loc[BI] varlen). With s(p) = x[XB, c, S0 + p] for p >= 0 and, before the sequence,
// the conv state slot SLOT (INIT, has_initial_state) or 0, token t's output is act(bias[c] +
// sum_j w[c, j] s(t - (W - 1) + j)), act(r) = r / (1 + exp(-r)) under SILU; with STATES the state
// becomes s(L - (W - 1) + i), i < W - 1 (unwritten if L = 0 and INIT).
dim NB; dim D; dim LL; dim W; dim WM1; dim NS; dim BI; dim XB; dim S0; dim L; dim SLOT; dim C0; dim C1;
dim SILU; dim INIT; dim STATES;
array w[D, W]; array bias[D]; array x[NB, D, LL];
array out[NB, D, LL]; array state[NS, D, WM1];
out[b, c, q] = where(b == XB, where(c >= C0, where(c < C1, where(q >= S0, where(q < S0 + L,
    let(r, bias[c] + sum(j in 0..W, w[c, j] * where(q - S0 + j < W - 1,
            where(INIT == 1, state[SLOT, c, q - S0 + j], 0), x[b, c, q + j - (W - 1)])),
        where(SILU == 1, r / (1 + exp(-r)), r)),
    unwritten), unwritten), unwritten), unwritten), unwritten);
state[n, c, i] = where(STATES == 1, where(n == SLOT, where(c >= C0, where(c < C1,
    where(L + i < W - 1, where(INIT == 1, where(L == 0, unwritten, state[n, c, L + i]), 0),
        x[XB, c, S0 + L - (W - 1) + i]),
    unwritten), unwritten), unwritten), unwritten);
