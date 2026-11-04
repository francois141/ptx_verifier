// ReLU: the formula the PTX kernel's outputs are stated against.
dim N;
array x[N];
array out[N];

out[i] = max(x[i], 0);
