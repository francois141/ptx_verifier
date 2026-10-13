// sum 2x_k = 2 sum x_k. (left side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = sum(k in 0..N, 2 * x[k]);
