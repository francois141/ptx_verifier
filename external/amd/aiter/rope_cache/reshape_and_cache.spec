// reshape_and_cache, one token in slot 0 (block 0, offset 0): key_cache [nb, H, D/x, bs, x], value_cache [nb, H, D, bs].
dim T; dim H; dim D; dim X; dim DX; dim BS; dim NB;
array key[T, H, D];
array value[T, H, D];
array key_cache[NB, H, DX, BS, X];
array value_cache[NB, H, D, BS];
key_cache[n, h, xi, o, xo] = key[n, h, xi * X + xo];
value_cache[n, h, d, o] = value[n, h, d];
