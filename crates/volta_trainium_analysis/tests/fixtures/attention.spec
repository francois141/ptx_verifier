// Attention in the NKI samples' layout, transcribing test_attention.py's numpy_attention:
// q, k and v are [D, N] (d_head by seqlen), and row i of the output is softmax(q.T @ k)[i] @ v.T.
dim D;
dim N;
array q[D, N];
array k[D, N];
array v[D, N];
array kernel_out[N, D];

kernel_out[i, e] = sum(j in 0..N,
        exp(sum(d in 0..D, q[d, i] * k[d, j]) - max(m in 0..N, sum(d in 0..D, q[d, i] * k[d, m])))
      / sum(l in 0..N,
            exp(sum(d in 0..D, q[d, i] * k[d, l]) - max(m in 0..N, sum(d in 0..D, q[d, i] * k[d, m]))))
      * v[e, j]);
