// sum x_k = sum x_(N-1-k). (right side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = sum(k in 0..N, x[N - 1 - k]);
