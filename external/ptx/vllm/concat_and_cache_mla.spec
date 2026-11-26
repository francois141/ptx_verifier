// vLLM's concat_and_cache_mla ("auto" cache dtype): token P's latent kv_c[P, :R] and rope key
// k_pe[P, :E] (row strides KCS, KPS) concatenated into slot P (slot_mapping[P] = P) of the
// cache [NB, BS, R + E]: block B = P / BS, offset S = P % BS; the rest unwritten.
dim T; dim KCS; dim KPS; dim NB; dim BS; dim RE; dim R; dim P; dim B; dim S;
array kv_c[T, KCS];
array k_pe[T, KPS];
array kv_cache[NB, BS, RE];
kv_cache[b, s, e] = where(b != B, unwritten, where(s != S, unwritten,
    where(e < R, kv_c[P, e], k_pe[P, e - R])));
