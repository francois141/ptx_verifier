// Batch normalization with estimated statistics, per activation (each (c, h, w) its own):
// y = scale (x - mean) / sqrt(|var + eps|) + bias, eps = the double 1e-5, which the kernel converts to f32 (exactly, over the reals).
dim N; dim C; dim H; dim W;
array x[N, C, H, W];
array mean[C, H, W]; array variance[C, H, W]; array scale[C, H, W]; array bias[C, H, W];
array y[N, C, H, W];
y[n, c, h, w] = scale[c, h, w] * (x[n, c, h, w] - mean[c, h, w]) / sqrt(abs(variance[c, h, w] + 0.000010000000000000000818030539140313095458623138256371021270751953125)) + bias[c, h, w];
