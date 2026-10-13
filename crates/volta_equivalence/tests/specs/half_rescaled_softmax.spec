// Softmax with the max subtracted in the numerator only.
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] - max(k in 0..N, x[k])) / sum(k in 0..N, exp(x[k]));
