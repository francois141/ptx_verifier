// ad^2 + bd + c in Horner form. (left side)
dim N;
array a[N];
array b[N];
array c[N];
array d[N];
array out[N];

out[i] = a[i] * d[i] * d[i] + b[i] * d[i] + c[i];
