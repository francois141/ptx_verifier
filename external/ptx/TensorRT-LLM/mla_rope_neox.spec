// TensorRT-LLM mlaRoPEInplaceKernel, NeoX: in place on data [T, H, NOPE + 2 HALF]; the block at
// (token P at position POS, heads HB * HPB ..) rotates the last 2 HALF dims of each of its heads: x1 = d[NOPE + i],
// x2 = d[NOPE + HALF + i], (x1 c - x2 s, x2 c + x1 s) with c = cache[POS, 0, i],
// s = SGN cache[POS, 1, i] (SGN = -1 inverse); every other element is unwritten.
dim TWO; dim T; dim H; dim HS; dim NOPE; dim HALF; dim PM; dim P; dim POS; dim H0; dim H1; dim INV;
array cache[PM, TWO, HALF];
array data[T, H, HS];
data[t, h, j] = where(t == P, where(h >= H0, where(h < H1, where(j >= NOPE,
    where(j < NOPE + HALF,
        data[t, h, j] * cache[POS, 0, j - NOPE]
          - (1 - 2 * INV) * data[t, h, j + HALF] * cache[POS, 1, j - NOPE],
        data[t, h, j] * cache[POS, 0, j - NOPE - HALF]
          + (1 - 2 * INV) * data[t, h, j - HALF] * cache[POS, 1, j - NOPE - HALF]),
    unwritten), unwritten), unwritten), unwritten);
