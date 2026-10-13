// max(a, max(b, c)) = max(max(c, a), b). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = max(max(c[i], a[i]), b[i]);
