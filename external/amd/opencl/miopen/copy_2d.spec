// A [R, C] view of a buffer with rows S apart, copied into a packed tensor.
dim R; dim C; dim S;
array x[R, S];
array y[R, C];
y[r, c] = x[r, c];
