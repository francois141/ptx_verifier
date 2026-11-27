// TensorRT-LLM fusedDiTQKNormRopeKernel<D, true> (fusedDiTQKNormRopeKernel.cu:44), in place on qkv
// [T, NH, D] viewed as [T, NH, D / 2, 2] (interleaved RoPE pairs (2i, 2i + 1)), on one block: token T0, packed heads
// [H0, H1) (q heads below HQ, then k). x <- x rsqrt(|x|^2 / D + eps) w (q_w / k_w, the add weights where ADD,
// the dual-stream text tokens), then (x0, x1) <- (x0 cos0 - x1 sin0, x1 cos1 + x0 sin1) with cos/sin row CR. eps = f32(1e-6).
dim T; dim NH; dim D; dim D2; dim TWO; dim CROWS; dim T0; dim H0; dim H1; dim HQ; dim ADD; dim CR;
array qkv[T, NH, D2, TWO]; array cos_emb[CROWS, D2, TWO]; array sin_emb[CROWS, D2, TWO];
array q_w[D2, TWO]; array k_w[D2, TWO]; array q_add[D2, TWO]; array k_add[D2, TWO];
qkv[t, h, i, c] = where(t == T0, where(h >= H0, where(h < H1, let(r, 1 / sqrt(sum(a in 0..D2, sum(b in 0..2, qkv[t, h, a, b] * qkv[t, h, a, b])) / D + 0.0000009999999974752427078783512115478515625), where(c == 0, (qkv[t, h, i, 0] * r * where(h < HQ, where(ADD == 1, q_add[i, 0], q_w[i, 0]), where(ADD == 1, k_add[i, 0], k_w[i, 0]))) * cos_emb[CR, i, 0] - (qkv[t, h, i, 1] * r * where(h < HQ, where(ADD == 1, q_add[i, 1], q_w[i, 1]), where(ADD == 1, k_add[i, 1], k_w[i, 1]))) * sin_emb[CR, i, 0], (qkv[t, h, i, 1] * r * where(h < HQ, where(ADD == 1, q_add[i, 1], q_w[i, 1]), where(ADD == 1, k_add[i, 1], k_w[i, 1]))) * cos_emb[CR, i, 1] + (qkv[t, h, i, 0] * r * where(h < HQ, where(ADD == 1, q_add[i, 0], q_w[i, 0]), where(ADD == 1, k_add[i, 0], k_w[i, 0]))) * sin_emb[CR, i, 1])), unwritten), unwritten), unwritten);
