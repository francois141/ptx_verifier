// Softmax scaled by the reciprocal of a sum of two tiles' sums, vs one division; needs N = 4. (left side)
dim N;
array x[N];
array y[N];

y[i] = exp(x[i] - max(m in 0..N, x[m]))
     * (1 / ((exp(x[0] - max(m in 0..N, x[m])) + exp(x[1] - max(m in 0..N, x[m])))
           + (exp(x[2] - max(m in 0..N, x[m])) + exp(x[3] - max(m in 0..N, x[m])))));
