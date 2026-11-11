// softmax(x/2), naive vs max-subtracted. (right side)
dim N;
array x[N];
array y[N];

y[i] = exp(0.5 * x[i] - 0.5 * max(k in 0..N, x[k]))
     / sum(k in 0..N, exp(0.5 * x[k] - 0.5 * max(m in 0..N, x[m])));
