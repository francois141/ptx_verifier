// Triton's fused softmax tutorial: softmax along each of the R rows of C columns, max-subtracted.
dim R; dim C;
array x[R, C];
array output[R, C];
output[r, c] = exp(x[r, c] - max(k in 0..C, x[r, k]))
             / sum(k in 0..C, exp(x[r, k] - max(j in 0..C, x[r, j])));
