// RMSNorm of each row, eps under the root: y = x w / sqrt(mean(x^2) + eps), eps = f32(1e-6).
// Input rows are S elements apart (S = N unless the input is a row-strided view).
dim R; dim N; dim S;
array x[R, S];
array weight[N];
array y[R, N];
y[r, c] = x[r, c] * weight[c] / sqrt(sum(k in 0..N, x[r, k] * x[r, k]) / N + 0.0000009999999974752427078783512115478515625);
