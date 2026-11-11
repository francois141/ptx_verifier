// s/4 = s * 0.25. (right side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = sum(k in 0..N, x[k]) * 0.25;
