// e^a / e^b = e^(a - b). (right side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = exp(a[i] - b[i]);
