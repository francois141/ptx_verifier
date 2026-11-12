// max(a + b, c) = max(c, b + a). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = max(c[i], b[i] + a[i]);
