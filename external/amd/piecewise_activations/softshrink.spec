// Softshrink with lambd = 0.5: x - lambd above lambd, x + lambd below -lambd, 0 between.
dim N;
array x[N];
array y[N];
y[i] = max(x[i] - 0.5, 0) + min(x[i] + 0.5, 0);
