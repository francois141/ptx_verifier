// TensorRT-LLM fused_pmap_gemm_fma_ksplit<TN, KS, 0, true> (mhcKernels/mhc_fused_fma.cuh:54), hc_mult 4, N 24, on one
// CTA (token T, column tile [N0, N1), hidden slice [H0, H1) of split S0): the post-mapped residual
// r[t, j, h] = post[t, j] x[t, h] + sum_k comb[t, k, j] residual_in[t, k, h], written (to residual_out) only by the
// first column tile (SQ = 1); Yp[S0, t, n] = sum_j sum_{h in slice} r[t, j, h] w[n, j, h]; Rp[S0, t] = sum r^2 (SQ = 1).
dim M; dim J; dim HS; dim N; dim KS; dim T; dim N0; dim N1; dim H0; dim H1; dim S0; dim SQ;
array residual_in[M, J, HS]; array x[M, HS]; array post[M, J]; array comb[M, J, J]; array w[N, J, HS];
array yp[KS, M, N]; array rp[KS, M]; array residual_out[M, J, HS];
residual_out[t, j, h] = where(t == T, where(SQ == 1, where(h >= H0, where(h < H1, post[t, j] * x[t, h]
    + sum(k in 0..J, comb[t, k, j] * residual_in[t, k, h]), unwritten), unwritten), unwritten), unwritten);
yp[s, t, n] = where(s == S0, where(t == T, where(n >= N0, where(n < N1, sum(j in 0..J, sum(h in H0..H1,
    (post[t, j] * x[t, h] + sum(k in 0..J, comb[t, k, j] * residual_in[t, k, h])) * w[n, j, h])), unwritten),
    unwritten), unwritten), unwritten);
rp[s, t] = where(s == S0, where(t == T, where(SQ == 1, sum(j in 0..J, sum(h in H0..H1,
    (post[t, j] * x[t, h] + sum(k in 0..J, comb[t, k, j] * residual_in[t, k, h]))
    * (post[t, j] * x[t, h] + sum(k in 0..J, comb[t, k, j] * residual_in[t, k, h])))), unwritten), unwritten),
    unwritten);
