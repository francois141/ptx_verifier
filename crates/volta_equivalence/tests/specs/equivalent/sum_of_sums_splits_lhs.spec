// sum (a_k + b_k) = sum a_k + sum b_k. (left side)
dim N;
dim O;
array a[N];
array b[N];
array out[O];

out[o] = sum(k in 0..N, a[k] + b[k]);
