// vLLM's concat_and_cache_mla_rope_fused, NeoX style (csrc/cache_kernels_fused.cu:24), token
// P (position P, slot P = block B entry S): q_pe [T, H, QH] and k_pe [T, KPS] rotated in place
// over their first R = 2E columns by cos_sin_cache[P] = [cos | sin]; the cache entry is kv_c's
// first L columns, then the rotated k_pe.
dim T; dim H; dim QH; dim R; dim E; dim PM; dim P; dim KPS; dim KCS; dim L; dim L2; dim NB;
dim BS; dim RE; dim B; dim S;
array q_pe[T, H, QH];
array k_pe[T, KPS];
array kv_c[T, KCS];
array cos_sin_cache[PM, R];
array kv_cache[NB, BS, RE];
q_pe[t, h, c] = where(t != P, unwritten, where(c < E,
    q_pe[t, h, c] * cos_sin_cache[P, c] - q_pe[t, h, c + E] * cos_sin_cache[P, E + c],
    where(c < R,
        q_pe[t, h, c] * cos_sin_cache[P, c - E] + q_pe[t, h, c - E] * cos_sin_cache[P, c],
        unwritten)));
k_pe[t, c] = where(t != P, unwritten, where(c < E,
    k_pe[t, c] * cos_sin_cache[P, c] - k_pe[t, c + E] * cos_sin_cache[P, E + c],
    where(c < R, k_pe[t, c] * cos_sin_cache[P, c - E] + k_pe[t, c - E] * cos_sin_cache[P, c],
        unwritten)));
kv_cache[b, s, e] = where(b != B, unwritten, where(s != S, unwritten, where(e < L, kv_c[P, e],
    where(e < L + E,
        k_pe[P, e - L] * cos_sin_cache[P, e - L] - k_pe[P, e - L + E] * cos_sin_cache[P, e - L + E],
        k_pe[P, e - L] * cos_sin_cache[P, e - L - E] + k_pe[P, e - L - E] * cos_sin_cache[P, e - L]))));
