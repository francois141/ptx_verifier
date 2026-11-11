// ReLU(a * b + c).
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = max(a[i] * b[i] + c[i], 0.0);
