// tanh(a) = (1 - e^-2a)/(1 + e^-2a). (left side)
dim N;
array a[N];
array out[N];

out[i] = tanh(a[i]);
