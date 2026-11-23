// The logistic sigmoid of each element.
dim N;
array x[N];
array y[N];
y[i] = 1 / (1 + exp(-x[i]));
