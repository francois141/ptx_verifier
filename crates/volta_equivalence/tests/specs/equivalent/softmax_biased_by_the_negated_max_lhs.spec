// Softmax with exp(x + b) for the negated max b, as NKI's activation bias applies it. (left side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] + -max(m in 0..N, x[m])) / sum(k in 0..N, exp(x[k] + -max(m in 0..N, x[m])));
