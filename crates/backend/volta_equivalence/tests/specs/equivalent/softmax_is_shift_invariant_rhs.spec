// Shifting every logit by the same c leaves softmax unchanged. (right side)
dim N;
dim C;
array x[N];
array c[C];
array y[N];

y[i] = exp(x[i]) / sum(k in 0..N, exp(x[k]));
