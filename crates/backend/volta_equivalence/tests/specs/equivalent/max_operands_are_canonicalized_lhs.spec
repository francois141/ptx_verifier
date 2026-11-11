// max(a + b, c) = max(c, b + a). (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = max(a[i] + b[i], c[i]);
