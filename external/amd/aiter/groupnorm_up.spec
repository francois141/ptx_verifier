// GroupNorm's first pass over the one block of group 0: the sum and the sum of squares of its
// CG channels of P elements.
dim CG; dim P; dim ONE;
array x[CG, P];
array mean_acc[ONE];
array square_mean_acc[ONE];
mean_acc[i] = sum(c in 0..CG, sum(p in 0..P, x[c, p]));
square_mean_acc[i] = sum(c in 0..CG, sum(p in 0..P, x[c, p] * x[c, p]));
