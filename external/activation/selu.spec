// SELU: scale * (max(0, x) + min(0, alpha * (exp(x) - 1))), written scale * max(x, 0) +
// negcoef * (exp(min(x, 0)) - 1), the same function since exp increases; scale is its f32 value
// and negcoef PyTorch's f32 alpha * scale, the product rounded as its host computes it.
dim N;
array x[N];
array y[N];
y[i] = 1.05070102214813232421875 * max(x[i], 0) + 1.7580993175506591796875 * (exp(min(x[i], 0)) - 1);
