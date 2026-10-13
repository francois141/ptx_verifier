// min(a, min(b, c)) = min(min(c, a), b). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = min(min(c[i], a[i]), b[i]);
