// ad^2 + bd + c in Horner form. (right side)
dim N;
array a[N];
array b[N];
array c[N];
array d[N];
array out[N];

out[i] = c[i] + d[i] * (b[i] + d[i] * a[i]);
