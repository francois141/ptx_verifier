// 1/(1 + e^-a) = e^a/(e^a + 1). (left side)
dim N;
array a[N];
array out[N];

out[i] = 1 / (1 + exp(-a[i]));
