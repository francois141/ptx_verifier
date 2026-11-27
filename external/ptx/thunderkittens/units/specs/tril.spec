// The input on the lower triangle from diagonal D, zero elsewhere.
dim R; dim C; dim D;
array input[R, C];
array output[R, C];
output[i, j] = where(j <= i + D, input[i, j], 0);
