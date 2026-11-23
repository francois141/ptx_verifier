// rmsnorm2d_fwd_with_add as documented, on workgroup 0's rows 0 and 1024 (grid 1024): x is
// xbuf[:, :N], residual_in res and residual_out contiguous [M, N]; eps = f32(1e-6).
dim M; dim N; dim W; dim O;
array xbuf[M, W];
array res[M, N];
array g[N];
array y0[N];
array y1024[N];
array res_out0[N];
array res_out1024[N];
array rsigma0[O];
array rsigma1024[O];
res_out0[c] = xbuf[0, c] + res[0, c];
res_out1024[c] = xbuf[1024, c] + res[1024, c];
rsigma0[i] = 1 / sqrt(sum(j in 0..N, (xbuf[0, j] + res[0, j]) * (xbuf[0, j] + res[0, j])) / N + 0.0000009999999974752427078783512115478515625);
rsigma1024[i] = 1 / sqrt(sum(j in 0..N, (xbuf[1024, j] + res[1024, j]) * (xbuf[1024, j] + res[1024, j])) / N + 0.0000009999999974752427078783512115478515625);
y0[c] = (xbuf[0, c] + res[0, c]) * (1 / sqrt(sum(j in 0..N, (xbuf[0, j] + res[0, j]) * (xbuf[0, j] + res[0, j])) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
y1024[c] = (xbuf[1024, c] + res[1024, c]) * (1 / sqrt(sum(j in 0..N, (xbuf[1024, j] + res[1024, j]) * (xbuf[1024, j] + res[1024, j])) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
