// TensorRT-LLM mamba2MTPSSMCacheKernel (mamba2MTPSSMCacheKernel.cuh:290) on block (x, head HI, batch
// BI): head dims [D0, D1) of head HI over T draft steps from state slot SLOT. With dt_u = dt[BI, u, h]
// (+ dt_bias[h] under BIAS), the selective-scan recurrence s_u = s_{u-1} exp(A[h] dt_u) +
// B[BI, u, g, i] x[BI, u, h, d] dt_u (g = GI) has the closed form below; step t's state goes to
// intermediate slot ISLOT, its output is sum_i s_t[i] C[BI, t, g, i] (+ x D[h] under HASD, times
// silu(z) under HASZ), and with UPDATE the last state replaces the slot's.
dim NS; dim NI; dim B; dim T; dim H; dim HD; dim N; dim G; dim RATIO; dim SLOT; dim ISLOT; dim BI; dim HI;
dim GI; dim D0; dim D1; dim BIAS; dim HASD; dim HASZ; dim UPDATE; dim TM1;
array x[B, T, H, HD]; array dt[B, T, H]; array A[H]; array Bm[B, T, G, N]; array Cm[B, T, G, N];
array Dv[H]; array z[B, T, H, HD]; array dt_bias[H];
array state[NS, H, HD, N]; array inter[NI, T, H, HD, N]; array out[B, T, H, HD];
inter[n, t, h, d, i] = where(n == ISLOT, where(h == HI, where(d >= D0, where(d < D1,
    state[SLOT, h, d, i] * exp(A[h] * sum(v in 0..t + 1, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0)))
    + sum(u in 0..t + 1, Bm[BI, u, GI, i] * (x[BI, u, h, d] * (dt[BI, u, h] + where(BIAS == 1, dt_bias[h], 0)))
        * exp(A[h] * sum(v in u + 1..t + 1, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0)))),
    unwritten), unwritten), unwritten), unwritten);
out[b, t, h, d] = where(b == BI, where(h == HI, where(d >= D0, where(d < D1,
    let(y, sum(i in 0..N, (state[SLOT, h, d, i] * exp(A[h] * sum(v in 0..t + 1, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0)))
        + sum(u in 0..t + 1, Bm[BI, u, GI, i] * (x[BI, u, h, d] * (dt[BI, u, h] + where(BIAS == 1, dt_bias[h], 0)))
            * exp(A[h] * sum(v in u + 1..t + 1, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0))))) * Cm[BI, t, GI, i])
        + where(HASD == 1, x[BI, t, h, d] * Dv[h], 0),
      where(HASZ == 1, y * (z[BI, t, h, d] / (1 + exp(-z[BI, t, h, d]))), y)),
    unwritten), unwritten), unwritten), unwritten);
state[n, h, d, i] = where(UPDATE == 1, where(n == SLOT, where(h == HI, where(d >= D0, where(d < D1,
    state[n, h, d, i] * exp(A[h] * sum(v in 0..T, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0)))
    + sum(u in 0..T, Bm[BI, u, GI, i] * (x[BI, u, h, d] * (dt[BI, u, h] + where(BIAS == 1, dt_bias[h], 0)))
        * exp(A[h] * sum(v in u + 1..T, dt[BI, v, h] + where(BIAS == 1, dt_bias[h], 0)))),
    unwritten), unwritten), unwritten), unwritten), unwritten);
