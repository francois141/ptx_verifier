// Softmax scaled by the reciprocal of a sum of two tiles' sums, vs one division; needs N = 4. (right side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] - max(m in 0..N, x[m])) / sum(k in 0..N, exp(x[k] - max(m in 0..N, x[m])));
