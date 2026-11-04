// Sigmoid: the formula the AMD and NKI kernels' outputs are stated against.
dim N;
array a[N];
array out[N];

out[i] = 1 / (1 + exp(-a[i]));
