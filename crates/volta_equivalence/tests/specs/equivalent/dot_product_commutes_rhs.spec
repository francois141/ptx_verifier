// sum a_k b_k = sum b_k a_k. (right side)
dim N;
dim O;
array a[N];
array b[N];
array out[O];

out[o] = sum(k in 0..N, b[k] * a[k]);
