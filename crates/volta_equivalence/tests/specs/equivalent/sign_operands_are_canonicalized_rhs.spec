// sign(2a) b = b sign(2a), operands reordered. (right side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = b[i] * sign(2 * a[i]);
