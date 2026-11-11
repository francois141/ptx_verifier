// A row's max as the max of its two tiles' maxes, as NKI kernels reduce it; needs F = 4. (right side)
dim N;
dim F;
array A[N, F];
array m[N];

m[i] = max(j in 0..F, A[i, j]);
