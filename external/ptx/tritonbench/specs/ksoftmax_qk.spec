// ksoftmax_triton.py's masked softmax, mask_type 'qk', on row R0 of batch B0:
// Y[b, r, k] = softmax_k(X[b, r, k] + M[r, k]), M a [R, K] mask.
dim B; dim R; dim K; dim B0; dim R0;
array X[B, R, K];
array M[R, K];
array Y[B, R, K];
Y[b, r, k] = where(b == B0, where(r == R0,
    exp(X[b, r, k] + M[r, k]) / sum(j in 0..K, exp(X[b, r, j] + M[r, j])), unwritten), unwritten);
