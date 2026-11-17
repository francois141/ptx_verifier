// ELU with alpha = 1: x above 0, alpha * (exp(x) - 1) below, written max(x, 0) +
// alpha * (exp(min(x, 0)) - 1), the same function since both pieces are 0 at 0.
dim N;
array x[N];
array y[N];
y[i] = max(x[i], 0) + (exp(min(x[i], 0)) - 1);
