// CK Tile's Relu: y = x > 0 ? x : 0.
dim N;
array x[N];
array y[N];

y[i] = max(x[i], 0);
