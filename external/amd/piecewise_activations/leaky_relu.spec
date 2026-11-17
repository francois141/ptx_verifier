// LeakyReLU: max(0, x) + negative_slope * min(0, x), negative_slope the f32 value of 0.01.
dim N;
array x[N];
array y[N];
y[i] = max(x[i], 0) + 0.00999999977648258209228515625 * min(x[i], 0);
