// Workgroup 0's partial dot product: the blocks of B elements starting at 0, S, 2S, ... below N
// (here two: [0, B) and [S, S + B)).
dim N; dim B; dim S; dim R;
array x[N]; array y[N];
array partial[R];
partial[p] = sum(i in 0..B, x[i] * y[i]) + sum(i in 0..B, x[S + i] * y[S + i]);
