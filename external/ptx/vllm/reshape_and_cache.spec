// vLLM's reshape_and_cache (paged-attention layout, "auto" dtype): token P's key and value
// rows (row strides KS, VS) written to slot P (slot_mapping[P] = P; block B = P / BS, offset
// S = P % BS) of key_cache [NB, H, D / X, BS, X] and value_cache [NB, H, D, BS].
dim T; dim KS; dim VS; dim NB; dim H; dim DX; dim X; dim D; dim BS; dim P; dim B; dim S;
array key[T, KS];
array value[T, VS];
array key_cache[NB, H, DX, BS, X];
array value_cache[NB, H, D, BS];
key_cache[b, h, j, s, i] = where(b != B, unwritten, where(s != S, unwritten,
    key[P, h * D + j * X + i]));
value_cache[b, h, d, s] = where(b != B, unwritten, where(s != S, unwritten,
    value[P, h * D + d]));
