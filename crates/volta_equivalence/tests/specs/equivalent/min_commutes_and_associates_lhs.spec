// min(a, min(b, c)) = min(min(c, a), b). (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = min(a[i], min(b[i], c[i]));
