// HipKittens' softmax: each row of x (B x D x R x C, here the R x C rows of batch 0, depth 0)
// normalized over its C columns, the row's maximum subtracted before exponentiation.
dim R;
dim C;
array x[R, C];
array o[R, C];

o[r, c] = exp(x[r, c] - max(k in 0..C, x[r, k]))
        / sum(k in 0..C, exp(x[r, k] - max(m in 0..C, x[r, m])));
