// The input on the rows before D, zero elsewhere.
dim R; dim C; dim D;
array input[R, C];
array output[R, C];
output[i, j] = where(i < D, input[i, j], 0);
