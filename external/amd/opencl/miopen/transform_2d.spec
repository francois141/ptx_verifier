// y = alpha x with alpha = 0.5, from a [R, C] view of a buffer with rows S apart.
dim R; dim C; dim S;
array x[R, S];
array y[R, C];
y[r, c] = 0.5 * x[r, c];
