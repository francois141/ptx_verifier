// vLLM's concat_and_cache_mla_rope_fused, GPT-J style (csrc/cache_kernels_fused.cu:24), token
// P (position P, slot P = block B entry S), every array viewed as (pair x, element s): pair x
// < E of each q_pe head and of k_pe rotated in place by cos_sin_cache[P, x] and [P, E + x];
// the cache entry is kv_c's first L = 2 L2 columns, then the rotated k_pe pairs.
dim T; dim H; dim QH; dim R; dim E; dim PM; dim P; dim KPS; dim KCS; dim L; dim L2; dim NB;
dim BS; dim RE; dim B; dim S; dim TWO;
array q_pe[T, H, QH, TWO];
array k_pe[T, KPS, TWO];
array kv_c[T, KCS];
array cos_sin_cache[PM, R];
array kv_cache[NB, BS, RE, TWO];
q_pe[t, h, x, s] = where(t != P, unwritten, where(x < E,
    q_pe[t, h, x, s] * cos_sin_cache[P, x]
        + (2 * sum(r in 0..s, 1) - 1) * q_pe[t, h, x, 1 - s] * cos_sin_cache[P, E + x],
    unwritten));
k_pe[t, x, s] = where(t != P, unwritten, where(x < E,
    k_pe[t, x, s] * cos_sin_cache[P, x]
        + (2 * sum(r in 0..s, 1) - 1) * k_pe[t, x, 1 - s] * cos_sin_cache[P, E + x],
    unwritten));
kv_cache[b, n, x, s] = where(b != B, unwritten, where(n != S, unwritten, where(x < L2,
    kv_c[P, 2 * x + s],
    k_pe[P, x - L2, s] * cos_sin_cache[P, x - L2]
        + (2 * sum(r in 0..s, 1) - 1) * k_pe[P, x - L2, 1 - s] * cos_sin_cache[P, E + x - L2])));
