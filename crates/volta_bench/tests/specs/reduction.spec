// What every Harris reduction kernel (Red-1..4) computes: the sum of the
// first N inputs into out[0]. The benchmarks reduce N = 128 values.
dim N;
dim O;
array in[N];
array out[O];

out[o] = sum(k in 0..N, in[k]);
