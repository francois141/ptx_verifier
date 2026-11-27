// Layer norm of each row of X (layer_norm_liger.py's forward, eps = 0.5):
// Y = (x - mean) / sqrt(var + eps) * W + B, var the mean of (x - mean)^2 over the row's N columns.
dim R; dim N;
array X_ptr[R, N];
array W_ptr[N];
array B_ptr[N];
array Y_ptr[R, N];
Y_ptr[r, c] = let(mean, sum(k in 0..N, X_ptr[r, k]) / N,
    (X_ptr[r, c] - mean) / sqrt(sum(k in 0..N, (X_ptr[r, k] - mean) * (X_ptr[r, k] - mean)) / N + 0.5)
        * W_ptr[c] + B_ptr[c]);
