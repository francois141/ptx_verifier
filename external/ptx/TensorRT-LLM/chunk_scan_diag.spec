// TensorRT-LLM chunk_scan_kernel (selectiveScan/chunkscan.h:55), packed tokens, no z gate: for the analyzed block's
// chunk CI (first token A0), head H0 (group G0, C at column CO + n, x at XO + p), token rows [R0, R1) of
// y[t, h, p] = sum_n C[t, n] exp(dA[i]) Os[CI, h, n, p] + sum_{s <= i} CB[CI, G0, i, s] exp(dA[i] - dA[s]) dc[s]
// x[A0 + s, h, p] + D[h] x[t, h, p], i = t - A0 (dA, dc of chunk CI, head h). The diagonal s = i's decay
// exp(dA[i] - dA[i]) = 1 is spelled as Volta lowers CUDA's accurate expf of it (the fma.rm range reduction by
// 0x4B400001, n = 252 clamp(0.00572 z + 0.5) - 126 = 0 at z = 0): exactly 1, stated so the canonicalizer
// matches the kernel's unfolded form (chunk_scan.spec states it as exp(0)).
dim T; dim XW; dim CT; dim H; dim G; dim NS; dim P; dim Q; dim CI; dim H0; dim G0; dim A0; dim R0; dim R1; dim CO;
dim XO;
array x[T, XW]; array os[CT, H, NS, P]; array dc[CT, H, Q]; array da[CT, H, Q]; array cb[CT, G, Q, Q]; array d[H];
array y[T, H, P];
y[t, h, p] = where(h == H0, where(t >= R0, where(t < R1,
    sum(n in 0..NS, x[t, CO + n] * exp(da[CI, h, t - A0]) * os[CI, h, n, p])
    + cb[CI, G0, t - A0, t - A0] * exp((((da[CI, h, t - A0] - da[CI, h, t - A0]) * 0.00000001925963033500011) + (((da[CI, h, t - A0] - da[CI, h, t - A0]) * 1.4426950216293335) - ((min(max(((da[CI, h, t - A0] - da[CI, h, t - A0]) * 0.005724980030208826) + 0.5, 0), 1) * 252) + 12582913 - 12583039))) * 8388608 / 12102203) * exp(((min(max(((da[CI, h, t - A0] - da[CI, h, t - A0]) * 0.005724980030208826) + 0.5, 0), 1) * 252) + 12582913 - 12583039) * log(2)) * dc[CI, h, t - A0] * x[t, XO + p] + sum(s in 0..t - A0, cb[CI, G0, t - A0, s] * exp(da[CI, h, t - A0] - da[CI, h, s]) * dc[CI, h, s]
        * x[A0 + s, XO + p])
    + d[h] * x[t, XO + p], unwritten), unwritten), unwritten);
