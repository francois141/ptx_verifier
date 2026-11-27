// Each column divided by its sum.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = input[i, j] / sum(k in 0..R, input[k, j]);
