// concat_and_cache_mla, one token in slot 0: kv_cache[slot] = [kv_c | k_pe] (padded reads give the concatenation).
dim T; dim R; dim P; dim E;
array kv_c[T, R] padded;
array k_pe[T, P] padded;
array kv_cache[T, E];
kv_cache[t, j] = kv_c[t, j] + k_pe[t, j - R];
