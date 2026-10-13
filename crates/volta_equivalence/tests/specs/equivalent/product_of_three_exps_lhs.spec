// e^a e^b e^c = e^(a + b + c). (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = exp(a[i]) * exp(b[i]) * exp(c[i]);
