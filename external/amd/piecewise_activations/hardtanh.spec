// Hardtanh with min_val = -1, max_val = 1: x clamped to [-1, 1].
dim N;
array x[N];
array y[N];
y[i] = min(max(x[i], -1), 1);
