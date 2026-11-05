// Normalize each row independently, subtracting its maximum before exponentiation.
dim R;
dim C;
array input[R, C];
array output[R, C];

output[i, j] = exp(input[i, j] - max(k in 0..C, input[i, k]))
             / sum(k in 0..C, exp(input[i, k] - max(m in 0..C, input[i, m])));
