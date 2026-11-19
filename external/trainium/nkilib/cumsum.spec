// nkilib's cumsum along the last dimension, from cumsum_torch.py: each row's running sum,
// the input viewed as [R, C] (R the product of the leading dimensions).
dim R;
dim C;
array x[R, C];
array y[R, C];

y[r, c] = sum(k in 0..c + 1, x[r, k]);
