// Each row divided by its sum.
dim R; dim C;
array input[R, C];
array output[R, C];
output[i, j] = input[i, j] / sum(k in 0..C, input[i, k]);
