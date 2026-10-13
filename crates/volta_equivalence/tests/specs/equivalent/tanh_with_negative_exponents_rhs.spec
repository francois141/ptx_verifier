// tanh(a) = (1 - e^-2a)/(1 + e^-2a). (right side)
dim N;
array a[N];
array out[N];

out[i] = (1 - exp(-2 * a[i])) / (1 + exp(-2 * a[i]));
