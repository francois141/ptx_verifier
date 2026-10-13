// e^(a(b + c)) = e^(ab) e^(ca). (left side)
dim N;
array a[N];
array b[N];
array c[N];
array out[N];

out[i] = exp(a[i] * (b[i] + c[i]));
