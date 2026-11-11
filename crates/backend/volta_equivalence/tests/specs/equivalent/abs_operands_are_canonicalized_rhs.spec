// |a - b| + c = c + |-b + a|. (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = c[i] + abs(-b[i] + a[i]);
