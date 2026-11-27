// TensorRT-LLM causal_conv1d_update_kernel<kIsCircularBuffer> (causalConv1d.cu:1127) on block (batch
// BI, channel block): channels [C0, C1) of batch BI, state slot SLOT, a ring of SL positions with the
// next write at cache_seqlens[BI] % SL. The window's first W - 1 values are the ring positions P0..P2
// (the W - 1 before the write position), then the L tokens; token t's output (over x in place) is
// act(bias[c] + sum_j w[c, j] v(t + j)). Ring position Qk takes token Ik (the last token landing there).
dim B; dim D; dim L; dim W; dim NS; dim SL; dim BI; dim SLOT; dim C0; dim C1; dim SILU;
dim P0; dim P1; dim P2; dim Q0; dim I0; dim Q1; dim I1; dim Q2; dim I2; dim Q3; dim I3;
array w[D, W]; array bias[D];
array x[B, D, L]; array state[NS, D, SL];
x[b, c, t] = where(b == BI, where(c >= C0, where(c < C1,
    let(r, bias[c] + sum(j in 0..W, w[c, j] * where(t + j == 0, state[SLOT, c, P0],
            where(t + j == 1, where(W > 2, state[SLOT, c, P1], x[b, c, t + j - (W - 1)]),
            where(t + j == 2, where(W > 3, state[SLOT, c, P2], x[b, c, t + j - (W - 1)]),
            x[b, c, t + j - (W - 1)])))),
        where(SILU == 1, r / (1 + exp(-r)), r)),
    unwritten), unwritten), unwritten);
state[n, c, p] = where(n == SLOT, where(c >= C0, where(c < C1,
    where(p == Q0, x[BI, c, I0], where(p == Q1, x[BI, c, I1], where(p == Q2, x[BI, c, I2],
    where(p == Q3, x[BI, c, I3], unwritten)))), unwritten), unwritten), unwritten);
