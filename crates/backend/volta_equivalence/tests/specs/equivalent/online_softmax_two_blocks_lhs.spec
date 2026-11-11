// FlashAttention's online softmax: two blocks of two, the first rescaled by e^(m1 - m). (left side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i]) / sum(k in 0..N, exp(x[k]));
