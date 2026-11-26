// vLLM's rotary_embedding, GPT-J (interleaved) style, in place on token P: each head viewed as
// [E, TWO], the pair (x[i, 0], x[i, 1]) rotated by cos/sin index i of position P.
dim TWO; dim H; dim KH; dim E; dim PM; dim P;
array query[H, E, TWO];
array key[KH, E, TWO];
array cache[PM, TWO, E];
query[h, i, s] = query[h, i, s] * cache[P, 0, i]
    + (2 * sum(r in 0..s, 1) - 1) * query[h, i, 1 - s] * cache[P, 1, i];
key[h, i, s] = key[h, i, s] * cache[P, 0, i]
    + (2 * sum(r in 0..s, 1) - 1) * key[h, i, 1 - s] * cache[P, 1, i];
