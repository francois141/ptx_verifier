// A row's max as the max of its two tiles' maxes, as NKI kernels reduce it; needs F = 4. (left side)
dim N;
dim F;
array A[N, F];
array m[N];

m[i] = max(max(A[i, 0], A[i, 1]), max(A[i, 2], A[i, 3]));
