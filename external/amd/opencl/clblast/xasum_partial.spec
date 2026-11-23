// Workgroup 0's partial absolute sum: the blocks of B elements starting at 0 and S (below N).
dim N; dim B; dim S; dim R;
array x[N];
array partial[R];
partial[p] = sum(i in 0..B, abs(x[i])) + sum(i in 0..B, abs(x[S + i]));
