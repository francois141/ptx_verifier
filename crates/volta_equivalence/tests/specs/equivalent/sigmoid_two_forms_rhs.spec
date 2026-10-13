// 1/(1 + e^-a) = e^a/(e^a + 1). (right side)
dim N;
array a[N];
array out[N];

out[i] = exp(a[i]) / (exp(a[i]) + 1);
