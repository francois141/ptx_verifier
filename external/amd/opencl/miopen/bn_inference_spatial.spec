// Batch normalization with estimated statistics, per channel:
// y = scale (x - mean) / sqrt(|var + eps|) + bias, eps = the double 1e-5, which the kernel converts to f32 (exactly, over the reals).
dim N; dim C; dim H; dim W;
array x[N, C, H, W];
array mean[C]; array variance[C]; array scale[C]; array bias[C];
array y[N, C, H, W];
y[n, c, h, w] = scale[c] * (x[n, c, h, w] - mean[c]) / sqrt(abs(variance[c] + 0.000010000000000000000818030539140313095458623138256371021270751953125)) + bias[c];
