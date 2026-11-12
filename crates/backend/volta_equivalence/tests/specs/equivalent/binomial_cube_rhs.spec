// (a - b)^3 expanded. (right side)
dim N;
array a[N];
array b[N];
array out[N];

out[i] = a[i] * a[i] * a[i] - 3 * a[i] * a[i] * b[i]
       + 3 * a[i] * b[i] * b[i] - b[i] * b[i] * b[i];
