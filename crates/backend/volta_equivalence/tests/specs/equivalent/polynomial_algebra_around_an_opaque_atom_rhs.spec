// sqrt(a)(b + c) = c sqrt(a) + sqrt(a) b. (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = c[i] * sqrt(a[i]) + sqrt(a[i]) * b[i];
