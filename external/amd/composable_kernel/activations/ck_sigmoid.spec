// CK Tile's Sigmoid: y = 1 / (1 + exp(-x)).
dim N;
array x[N];
array y[N];

y[i] = 1 / (1 + exp(-x[i]));
