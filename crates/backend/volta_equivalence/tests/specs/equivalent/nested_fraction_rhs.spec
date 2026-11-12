// (a/b)/(c/d) = (ad)/(bc). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array d[N];
array out[N];

out[i] = (a[i] * d[i]) / (b[i] * c[i]);
