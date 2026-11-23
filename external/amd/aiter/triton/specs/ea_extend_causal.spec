// Aiter extend_attention_fwd, one sequence, one head: E extend queries attend every one of the P
// prefix keys (k_buffer/v_buffer slots kv_indices[j] = NB - 1 - j) and, causally, extend keys
// 0..i. Scale 1/sqrt(64) = 1/8.
dim E; dim P; dim NB; dim D; dim ONE;
array q[E, ONE, D];
array k_extend[E, ONE, D];
array v_extend[E, ONE, D];
array k_buffer[NB, ONE, D];
array v_buffer[NB, ONE, D];
array o[E, ONE, D];
o[i, h, d] = (sum(j in 0..P, exp(sum(c in 0..D, q[i, 0, c] * k_buffer[NB - 1 - j, 0, c]) / 8) * v_buffer[NB - 1 - j, 0, d])
              + sum(j in 0..i + 1, exp(sum(c in 0..D, q[i, 0, c] * k_extend[j, 0, c]) / 8) * v_extend[j, 0, d]))
           / (sum(j in 0..P, exp(sum(c in 0..D, q[i, 0, c] * k_buffer[NB - 1 - j, 0, c]) / 8))
              + sum(j in 0..i + 1, exp(sum(c in 0..D, q[i, 0, c] * k_extend[j, 0, c]) / 8)));
