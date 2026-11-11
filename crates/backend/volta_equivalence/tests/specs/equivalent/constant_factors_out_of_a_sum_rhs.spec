// sum 2x_k = 2 sum x_k. (right side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = 2 * sum(k in 0..N, x[k]);
