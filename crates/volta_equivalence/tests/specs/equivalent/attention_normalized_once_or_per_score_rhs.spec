// softmax(QK^T)V: safe softmax with one division vs naive weights each divided. (right side)
dim N;
dim D;
array Q[N, D];
array K[N, D];
array V[N, D];
array O[N, D];

O[i, e] = sum(j in 0..N, exp(sum(d in 0..D, Q[i, d] * K[j, d]))
                        / sum(l in 0..N, exp(sum(d in 0..D, Q[i, d] * K[l, d]))) * V[j, e]);
