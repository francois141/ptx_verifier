// max(a, max(b, c)) = max(max(c, a), b). (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = max(a[i], max(b[i], c[i]));
