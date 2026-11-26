// TensorRT-LLM mlaRoPEInplaceKernel, interleaved (GPT-J): data [T, H, HS2, 2], pairs q >= NOPE2
// (= NOPE / 2) rotated by pair index i = q - NOPE2: (x c - y s, y c + x s), c = cache[POS, 0, i],
// s = SGN cache[POS, 1, i]; only token P's heads [H0, H1) are written.
dim TWO; dim T; dim H; dim HS2; dim NOPE2; dim HALF; dim PM; dim P; dim POS; dim H0; dim H1; dim INV;
array cache[PM, TWO, HALF];
array data[T, H, HS2, TWO];
data[t, h, q, s] = where(t == P, where(h >= H0, where(h < H1, where(q >= NOPE2,
    data[t, h, q, s] * cache[POS, 0, q - NOPE2]
      + (2 * sum(r in 0..s, 1) - 1) * (1 - 2 * INV) * data[t, h, q, 1 - s] * cache[POS, 1, q - NOPE2],
    unwritten), unwritten), unwritten), unwritten);
