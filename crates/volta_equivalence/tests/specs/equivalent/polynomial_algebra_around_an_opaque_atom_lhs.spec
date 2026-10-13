// sqrt(a)(b + c) = c sqrt(a) + sqrt(a) b. (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = sqrt(a[i]) * (b[i] + c[i]);
