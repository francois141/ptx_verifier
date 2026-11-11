// A 3-tap convolution as a reduction vs unrolled out of order. (right side)
dim N;
dim K;
dim M;
array x[M];
array w[K];
array out[N];

out[i] = w[2] * x[i + 2] + w[0] * x[i] + x[i + 1] * w[1];
