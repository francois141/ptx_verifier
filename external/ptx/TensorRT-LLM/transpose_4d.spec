// TensorRT-LLM transpose_4d: src [B0, H, S, D] to dst [S, BL, H, D] at batch offset ITE * B0;
// block G copies the flat source elements [G * CH, G * CH + CH) only.
dim B0; dim H; dim S; dim D; dim BL; dim ITE; dim G; dim CH;
array src[B0, H, S, D];
array dst[S, BL, H, D];
dst[s, b, h, d] = where(b >= ITE * B0, where(b < ITE * B0 + B0,
    where(((b - ITE * B0) * H + h) * S * D + s * D + d >= G * CH,
    where(((b - ITE * B0) * H + h) * S * D + s * D + d < G * CH + CH,
        src[b - ITE * B0, h, s, d], unwritten), unwritten), unwritten), unwritten);
