// e^(a - a) b = b. (left side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = exp(a[i] - a[i]) * b[i];
