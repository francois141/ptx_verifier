// CK Tile's ClippedRelu with its default bounds alpha = 0 and beta = 1:
// y = min(beta, max(alpha, x)).
dim N;
array x[N];
array y[N];

y[i] = min(1, max(0, x[i]));
