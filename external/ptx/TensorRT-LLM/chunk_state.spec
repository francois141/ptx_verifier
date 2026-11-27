// TensorRT-LLM chunk_state_kernel (selectiveScan/chunkstate.h:55), packed tokens: for the analyzed block's chunk CI
// (tokens A0 .. A0 + LEN) and head H0 (group BO's B columns), rows [M0, M0 + TM) (state n) and columns
// [P0, P0 + TN) (head channel p) of St[c, h, n, p] = sum_{t < LEN} B[A0 + t, n] exp(dA[c, h, Q - 1] - dA[c, h, t])
// dc[c, h, t] x[A0 + t, h, p] (x at column XO + p, B at BO + n).
dim T; dim XW; dim CT; dim H; dim N; dim P; dim Q; dim QM1; dim CI; dim H0; dim A0; dim LEN; dim M0; dim P0; dim TM;
dim TN; dim BO; dim XO;
array x[T, XW]; array dc[CT, H, Q]; array da[CT, H, Q]; array st[CT, H, N, P];
st[c, h, n, p] = where(c == CI, where(h == H0, where(n >= M0, where(n < M0 + TM, where(p >= P0, where(p < P0 + TN,
    sum(t in 0..LEN, x[A0 + t, BO + n] * exp(da[c, h, QM1] - da[c, h, t]) * dc[c, h, t] * x[A0 + t, XO + p]),
    unwritten), unwritten), unwritten), unwritten), unwritten), unwritten);
