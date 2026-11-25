// Softplus without its threshold, log(1 + e^x).
dim N;
array x[N];
array y[N];
y[i] = log(1 + exp(x[i]));
