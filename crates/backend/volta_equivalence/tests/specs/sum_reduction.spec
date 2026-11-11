// Sum of x[0..K] as a reduction.
dim N;
dim K;
array x[K];
array out[N];

out[i] = sum(k in 0..K, x[k]);
