// fused_qk_rope_concat_and_cache_mla, NeoX, nope first, slot_mapping = positions = token index (one row cos/sin):
// q_out[t, h] = [q_nope | rope(q_pe)], kv_cache[slot] = [kv_c | rope(k_pe)].
// Concatenation via padded reads: an out-of-shape (including negative) subscript reads 0.
dim T; dim H; dim R; dim P; dim HALF; dim E; dim ONE;
array q_nope[T, H, R] padded;
array q_pe[T, H, P] padded;
array kv_c[T, R] padded;
array k_pe[T, P] padded;
array cos[ONE, HALF] padded;
array sin[ONE, HALF] padded;
array q_out[T, H, E];
array kv_cache[T, E];
q_out[t, h, j] = q_nope[t, h, j]
    + q_pe[t, h, j - R] * (cos[0, j - R] + cos[0, j - R - HALF])
    - q_pe[t, h, j - R + HALF] * sin[0, j - R]
    + q_pe[t, h, j - R - HALF] * sin[0, j - R - HALF];
kv_cache[t, j] = kv_c[t, j]
    + k_pe[t, j - R] * (cos[0, j - R] + cos[0, j - R - HALF])
    - k_pe[t, j - R + HALF] * sin[0, j - R]
    + k_pe[t, j - R - HALF] * sin[0, j - R - HALF];
