// mean((x - mean)^2) = mean(x^2) - mean^2. (right side)
dim N;
dim O;
array x[N];
array out[O];

out[o] = sum(k in 0..N, x[k] * x[k]) / N - pow(sum(m in 0..N, x[m]) / N, 2);
