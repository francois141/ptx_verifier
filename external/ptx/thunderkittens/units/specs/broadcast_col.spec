// Each column's sum, in every element of the column.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = sum(k in 0..R, input[k, j]);
