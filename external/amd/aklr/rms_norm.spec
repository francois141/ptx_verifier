// RMSNorm of each row, eps under the root: y = x w / sqrt(mean(x^2) + eps), eps = f32(1e-5).
// Input rows are S elements apart; the output holds the R rows workgroup 0 normalizes.
dim R; dim N; dim S;
array x[R, S];
array weight[N];
array normalized[R, N];
normalized[r, c] = x[r, c] * weight[c] / sqrt(sum(k in 0..N, x[r, k] * x[r, k]) / N + 0.00000999999974737875163555145263671875);
