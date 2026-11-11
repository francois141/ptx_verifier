// Softmax without max subtraction.
dim N;
array x[N];
array y[N];

y[i] = exp(x[i]) / sum(k in 0..N, exp(x[k]));
