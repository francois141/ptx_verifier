// tanh(a) = 2 sigmoid(2a) - 1. (right side)
dim N;
array a[N];
array out[N];

out[i] = 2 / (1 + exp(-2 * a[i])) - 1;
