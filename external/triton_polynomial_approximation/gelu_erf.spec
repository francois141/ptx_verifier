// The exact GELU, 0.5 * x * (1 + erf(x / sqrt(2))).
dim N;
array x[N];
array y[N];
y[i] = 0.5 * x[i] * (1 + erf(x[i] * 0.7071067811865476));
