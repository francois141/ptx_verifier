// fused_qk_rope_concat_and_cache_mla, GQA prefill, NeoX, nope first, slot_mapping = positions = token index:
// q_out[t, h] = [q_nope | rope(q_pe)], kv_cache[slot, g] = [kv_c[t, g] | rope(k_pe[t, g])].
// Concatenation via padded reads: an out-of-shape (including negative) subscript reads 0.
dim T; dim H; dim HK; dim R; dim P; dim HALF; dim E; dim ONE;
array q_nope[T, H, R] padded;
array q_pe[T, H, P] padded;
array kv_c[T, HK, R] padded;
array k_pe[T, HK, P] padded;
array cos[ONE, HALF] padded;
array sin[ONE, HALF] padded;
array q_out[T, H, E];
array kv_cache[T, HK, E];
q_out[t, h, j] = q_nope[t, h, j]
    + q_pe[t, h, j - R] * (cos[0, j - R] + cos[0, j - R - HALF])
    - q_pe[t, h, j - R + HALF] * sin[0, j - R]
    + q_pe[t, h, j - R - HALF] * sin[0, j - R - HALF];
kv_cache[t, g, j] = kv_c[t, g, j]
    + k_pe[t, g, j - R] * (cos[0, j - R] + cos[0, j - R - HALF])
    - k_pe[t, g, j - R + HALF] * sin[0, j - R]
    + k_pe[t, g, j - R - HALF] * sin[0, j - R - HALF];
