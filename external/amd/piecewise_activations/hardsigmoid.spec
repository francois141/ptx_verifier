// Hardsigmoid: min(max(x + 3, 0), 6) / 6, the 1/6 PyTorch's kernel multiplies by as its f32 value.
dim N;
array x[N];
array y[N];
y[i] = min(max(x[i] + 3, 0), 6) * 0.16666667163372039794921875;
