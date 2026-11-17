// CELU with alpha = 2: max(0, x) + min(0, alpha * (exp(x / alpha) - 1)), written max(x, 0) +
// alpha * (exp(min(x, 0) / alpha) - 1), the same function since exp increases.
dim N;
array x[N];
array y[N];
y[i] = max(x[i], 0) + 2 * (exp(min(x[i], 0) / 2) - 1);
