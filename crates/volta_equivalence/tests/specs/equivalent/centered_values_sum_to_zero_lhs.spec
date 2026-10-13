// sum (x_k - mean) = 0. (left side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = sum(k in 0..N, x[k] - sum(m in 0..N, x[m]) / N);
