// Softmax backward along each row: dx = y (dy - sum_j dy_j y_j).
dim R; dim N;
array dy[R, N];
array y[R, N];
array dx[R, N];
dx[r, c] = y[r, c] * (dy[r, c] - sum(k in 0..N, dy[r, k] * y[r, k]));
