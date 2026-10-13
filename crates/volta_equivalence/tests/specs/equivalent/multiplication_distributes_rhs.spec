// a(b + c) = ab + ca. (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = a[i] * b[i] + c[i] * a[i];
