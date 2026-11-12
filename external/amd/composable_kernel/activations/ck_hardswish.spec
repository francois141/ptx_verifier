// CK's AddHardswish with its constant 0.166667f (0x3e2aaac1) as an exact real: a = x0 + x1,
// y = (a + 3 > 0) * min(a + 3, 6) * a * 0.166667f.
dim N;
array x0[N];
array x1[N];
array y[N];

y[i] = (x0[i] + x1[i]) * min(max(x0[i] + x1[i] + 3, 0), 6) * 0.16666699945926666;
