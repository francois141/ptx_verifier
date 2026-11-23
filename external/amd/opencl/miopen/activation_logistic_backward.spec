// The sigmoid's gradient from its output y: dx = dy y (1 - y).
dim N;
array dy[N]; array x[N]; array y[N];
array dx[N];
dx[i] = dy[i] * y[i] * (1 - y[i]);
