// TensorRT-LLM cuKVCacheBlockPartialCopy (kvCachePartialCopy.cu:30) on block (x, y, z): every layer
// of a KV block [L, H, TPB, D] copies heads [Z0, Z1), tokens [Y0, Y1) (below the tokens to copy)
// and hidden [X0, X1) from src to dst; nothing else is written.
dim L; dim H; dim TPB; dim D; dim X0; dim X1; dim Y0; dim Y1; dim Z0; dim Z1;
array src[L, H, TPB, D];
array dst[L, H, TPB, D];
dst[l, h, t, d] = where(h >= Z0, where(h < Z1, where(t >= Y0, where(t < Y1, where(d >= X0, where(d < X1,
    src[l, h, t, d], unwritten), unwritten), unwritten), unwritten), unwritten), unwritten);
