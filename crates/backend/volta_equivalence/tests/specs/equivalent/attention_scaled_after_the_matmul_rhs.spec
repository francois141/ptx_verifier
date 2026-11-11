// Attention's 1/rowsum applied to each score before the matmul with v, or once after it. (right side)
dim D;
dim N;
array s[N, N];
array v[D, N];
array o[N, D];

o[i, e] = sum(j in 0..N, exp(s[i, j] - max(m in 0..N, s[i, m])) * v[e, j])
        * (1 / sum(l in 0..N, exp(s[i, l] - max(m in 0..N, s[i, m]))));
