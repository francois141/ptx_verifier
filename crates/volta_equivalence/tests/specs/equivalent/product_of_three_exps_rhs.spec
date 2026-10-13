// e^a e^b e^c = e^(a + b + c). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = exp(a[i] + b[i] + c[i]);
