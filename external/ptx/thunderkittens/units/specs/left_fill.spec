// The input on the columns from D, zero elsewhere.
dim R; dim C; dim D;
array input[R, C];
array output[R, C];
output[i, j] = where(j >= D, input[i, j], 0);
