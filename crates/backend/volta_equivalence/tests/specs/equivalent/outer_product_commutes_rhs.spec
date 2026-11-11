// x_i y_j = y_j x_i. (right side)
dim N;
array x[N];
array y[N];
array P[N, N];

P[i, j] = y[j] * x[i];
