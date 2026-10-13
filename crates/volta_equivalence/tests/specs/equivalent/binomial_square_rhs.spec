// (a + b)^2 = a^2 + 2ab + b^2. (right side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = a[i] * a[i] + 2 * a[i] * b[i] + b[i] * b[i];
