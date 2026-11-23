// rms_norm of x = a[:, ::2] (a is [M, 2N] contiguous) as documented: workgroup 0's R rows.
dim M; dim R; dim N; dim W;
array a[M, W];
array g[N];
array y[R, N];
array rsigma[R];
rsigma[r] = 1 / sqrt(sum(j in 0..N, a[r, 2 * j] * a[r, 2 * j]) / N + 0.0000009999999974752427078783512115478515625);
y[r, c] = a[r, 2 * c] * (1 / sqrt(sum(j in 0..N, a[r, 2 * j] * a[r, 2 * j]) / N + 0.0000009999999974752427078783512115478515625)) * g[c];
