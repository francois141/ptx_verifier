// e^(a(b + c)) = e^(ab) e^(ca). (right side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = exp(a[i] * b[i]) * exp(c[i] * a[i]);
