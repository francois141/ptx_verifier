// |a - b| + c = c + |-b + a|. (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = abs(a[i] - b[i]) + c[i];
