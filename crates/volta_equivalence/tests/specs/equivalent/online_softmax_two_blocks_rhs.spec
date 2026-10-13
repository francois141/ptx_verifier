// FlashAttention's online softmax: two blocks of two, the first rescaled by e^(m1 - m). (right side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] - max(max(x[0], x[1]), max(x[2], x[3])))
     / (exp(max(x[0], x[1]) - max(max(x[0], x[1]), max(x[2], x[3])))
          * (exp(x[0] - max(x[0], x[1])) + exp(x[1] - max(x[0], x[1])))
        + exp(x[2] - max(max(x[0], x[1]), max(x[2], x[3])))
        + exp(x[3] - max(max(x[0], x[1]), max(x[2], x[3]))));
