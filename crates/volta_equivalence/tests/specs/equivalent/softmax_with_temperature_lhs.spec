// softmax(x/2), naive vs max-subtracted. (left side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] / 2) / sum(k in 0..N, exp(x[k] / 2));
