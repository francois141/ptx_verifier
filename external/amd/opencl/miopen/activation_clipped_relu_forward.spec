// ReLU clipped at alpha = 6 (ReLU6).
dim N;
array x[N];
array y[N];
y[i] = min(6, max(x[i], 0));
