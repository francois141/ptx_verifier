// GroupNorm's second pass over group 0 (channels 0 to CG - 1), from the first pass's sums:
// y = (x - mean) / sqrt(var + eps) * weight[c] + bias[c], mean and var over the group's INNER
// elements, eps = 2^-20.
dim CG; dim P; dim C; dim INNER; dim ONE;
array x[CG, P];
array weight[C];
array bias[C];
array mean_acc[ONE];
array square_mean_acc[ONE];
array y[CG, P];
y[c, p] = (x[c, p] - mean_acc[0] / INNER)
        / sqrt(square_mean_acc[0] / INNER - (mean_acc[0] / INNER) * (mean_acc[0] / INNER)
               + 0.00000095367431640625)
        * weight[c] + bias[c];
