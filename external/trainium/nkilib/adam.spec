// nkilib experimental fused_adam, elementwise over flat tensors, beta1 0.9, beta2 0.999, eps 1e-8
// and the per-partition scalars step_size = inv_bc2_sqrt = wd_factor = 1 (constant fills), with
// Python's doubles for 1 - beta1 and 1 - beta2. Adam adds wd * p to the gradient; AdamW scales p.
dim N;
array p[N];
array g[N];
array m[N];
array v[N];
array weights[N];
array first_moment[N];
array second_moment[N];

first_moment[i] = 0.9 * m[i] + 0.09999999999999998 * (g[i] + p[i]);
second_moment[i] = 0.999 * v[i] + 0.0010000000000000009 * (g[i] + p[i]) * (g[i] + p[i]);
weights[i] = p[i] - (0.9 * m[i] + 0.09999999999999998 * (g[i] + p[i]))
    / (sqrt(0.999 * v[i] + 0.0010000000000000009 * (g[i] + p[i]) * (g[i] + p[i])) + 0.00000001);
