// Aiter's cat_and_cache_mla (bf16, non-shuffled): token 0's slot row of the cache is
// [k_nope[0, 0, :] | k_pe[0, 0, :]] / k_scale, split at the nope/pe boundary into two arrays.
dim B; dim DN; dim DP; dim ONE;
array k_nope[B, DN];
array k_pe[B, DP];
array ks[ONE];
array kv_nope[DN];
array kv_pe[DP];
kv_nope[j] = k_nope[0, j] * (1 / ks[0]);
kv_pe[j] = k_pe[0, j] * (1 / ks[0]);
