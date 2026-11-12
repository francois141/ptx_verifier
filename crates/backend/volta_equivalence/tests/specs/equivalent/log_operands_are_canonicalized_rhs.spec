// log(a + b) c = c log(b + a). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = c[i] * log(b[i] + a[i]);
