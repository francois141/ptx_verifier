// vLLM's rotary_embedding, NeoX style, in place on token P of query [H, TWO, E] and key
// [KH, TWO, E] (rot_dim = head_size = 2E): out[s=0] = x0 c - x1 s, out[s=1] = x1 c + x0 s, the
// sign (2s - 1) as 2 * sum(r in 0..s, 1) - 1; cos/sin of position P from cache [PM, TWO, E].
dim TWO; dim H; dim KH; dim E; dim PM; dim P;
array query[H, TWO, E];
array key[KH, TWO, E];
array cache[PM, TWO, E];
query[h, s, i] = query[h, s, i] * cache[P, 0, i]
    + (2 * sum(r in 0..s, 1) - 1) * query[h, 1 - s, i] * cache[P, 1, i];
key[h, s, i] = key[h, s, i] * cache[P, 0, i]
    + (2 * sum(r in 0..s, 1) - 1) * key[h, 1 - s, i] * cache[P, 1, i];
