// Each column's maximum, in every element of the column.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = max(k in 0..R, input[k, j]);
