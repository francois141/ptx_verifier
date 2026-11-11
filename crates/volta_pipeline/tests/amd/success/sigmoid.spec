// The formula sigmoid.cl computes: the baseline of its Lean challenge.
dim N;
array a[N];
array out[N];

out[i] = 1 / (1 + exp(-a[i]));
