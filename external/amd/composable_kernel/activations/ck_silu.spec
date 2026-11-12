// CK Tile's Silu: y = x * (1 / (1 + exp(-x))).
dim N;
array x[N];
array y[N];

y[i] = x[i] / (1 + exp(-x[i]));
