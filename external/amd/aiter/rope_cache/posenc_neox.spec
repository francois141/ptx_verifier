// vLLM rotary_embedding, NEOX, rot_dim = head_size = 64, one token at position 3: element 32 q + j of a head.
dim H; dim K; dim Q; dim J; dim P;
array q[H, Q, J]; array k[K, Q, J]; array c[P, J]; array sn[P, J];
array qo[H, Q, J]; array ko[K, Q, J];
qo[h, s, j] = q[h, s, j] * c[3, j] + (2 * s - 1) * q[h, 1 - s, j] * sn[3, j];
ko[h, s, j] = k[h, s, j] * c[3, j] + (2 * s - 1) * k[h, 1 - s, j] * sn[3, j];
