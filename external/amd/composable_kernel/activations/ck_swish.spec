// CK Tile's Swish with its default beta = 1: y = x / (1 + exp(-beta * x)).
dim N;
array x[N];
array y[N];

y[i] = x[i] / (1 + exp(-x[i]));
