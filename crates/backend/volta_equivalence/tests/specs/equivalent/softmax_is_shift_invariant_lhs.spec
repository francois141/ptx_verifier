// Shifting every logit by the same c leaves softmax unchanged. (left side)
dim N;
dim C;
array x[N];
array c[C];
array y[N];

y[i] = exp(x[i] - c[0]) / sum(k in 0..N, exp(x[k] - c[0]));
