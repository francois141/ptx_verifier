// CK Tile's LeakyRelu with its default alpha = 0.01f (0x3c23d70a) as an exact real:
// y = x >= 0 ? x : alpha * x.
dim N;
array x[N];
array y[N];

y[i] = max(x[i], 0) + 0.009999999776482582 * min(x[i], 0);
