// softmax of x = a[:, ::2] (a is [M, 2C] contiguous) as documented: workgroup 0's R rows.
dim M; dim R; dim C; dim W;
array a[M, W];
array y[R, C];
y[r, c] = exp(a[r, 2 * c] - max(k in 0..C, a[r, 2 * k])) / sum(k in 0..C, exp(a[r, 2 * k] - max(j in 0..C, a[r, 2 * j])));
