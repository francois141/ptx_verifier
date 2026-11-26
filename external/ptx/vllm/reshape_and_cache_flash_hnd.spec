// vLLM's reshape_and_cache_flash, HND cache [NB, H, BS, D] (heads strided by BS D): token P's key and value rows
// (row strides KS and VS, viewed [T, KS]) written to slot P (slot_mapping[P] = P), i.e. block
// B = P / BS, offset S = P % BS; the rest of the caches unwritten.
dim T; dim KS; dim VS; dim NB; dim BS; dim H; dim D; dim P; dim B; dim S;
array key[T, KS];
array value[T, VS];
array key_cache[NB, H, BS, D];
array value_cache[NB, H, BS, D];
key_cache[b, h, s, d] = where(b != B, unwritten, where(s != S, unwritten, key[P, h * D + d]));
value_cache[b, h, s, d] = where(b != B, unwritten, where(s != S, unwritten, value[P, h * D + d]));
