// Each row's maximum, in every element of the row.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = max(k in 0..C, input[i, k]);
