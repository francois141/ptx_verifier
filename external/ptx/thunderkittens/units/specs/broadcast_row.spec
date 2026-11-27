// Each row's sum, in every element of the row.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = sum(k in 0..C, input[i, k]);
