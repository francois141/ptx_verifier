// sign(2a) b = b sign(2a), operands reordered. (left side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = sign(a[i] * 2) * b[i];
