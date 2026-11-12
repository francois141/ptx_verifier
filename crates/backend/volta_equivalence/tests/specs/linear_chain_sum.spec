// Sum of x[0..4] as a left-leaning chain.
dim N;
dim K;
array x[K];
array out[N];

out[i] = ((x[0] + x[1]) + x[2]) + x[3];
