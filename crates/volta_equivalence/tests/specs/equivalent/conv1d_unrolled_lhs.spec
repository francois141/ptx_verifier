// A 3-tap convolution as a reduction vs unrolled out of order. (left side)
dim N;
dim K;
dim M;
array x[M];
array w[K];
array out[N];

out[i] = sum(k in 0..K, x[i + k] * w[k]);
