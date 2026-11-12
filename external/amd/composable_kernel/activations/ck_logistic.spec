// CK Tile's Logistic with its default alpha = 1: y = alpha / (1 + exp(-x) * alpha).
dim N;
array x[N];
array y[N];

y[i] = 1 / (1 + exp(-x[i]));
