// TensorRT-LLM fusedDiTQKNormRopeKernel<D, false> (fusedDiTQKNormRopeKernel.cu:44), in place on qkv
// [T, NH, D] viewed as [T, NH, 2, D / 2] (rotate_half: d pairs with d + D / 2), on one block: token T0, packed heads
// [H0, H1) (q heads below HQ, then k). x <- x rsqrt(|x|^2 / D + eps) w (q_w / k_w, the add weights where ADD,
// the dual-stream text tokens), then (x0, x1) <- (x0 cos0 - x1 sin0, x1 cos1 + x0 sin1) with cos/sin row CR. eps = f32(1e-6).
dim T; dim NH; dim D; dim D2; dim TWO; dim CROWS; dim T0; dim H0; dim H1; dim HQ; dim ADD; dim CR;
array qkv[T, NH, TWO, D2]; array cos_emb[CROWS, TWO, D2]; array sin_emb[CROWS, TWO, D2];
array q_w[TWO, D2]; array k_w[TWO, D2]; array q_add[TWO, D2]; array k_add[TWO, D2];
qkv[t, h, c, i] = where(t == T0, where(h >= H0, where(h < H1, let(r, 1 / sqrt(sum(a in 0..D2, sum(b in 0..2, qkv[t, h, b, a] * qkv[t, h, b, a])) / D + 0.0000009999999974752427078783512115478515625), where(c == 0, (qkv[t, h, 0, i] * r * where(h < HQ, where(ADD == 1, q_add[0, i], q_w[0, i]), where(ADD == 1, k_add[0, i], k_w[0, i]))) * cos_emb[CR, 0, i] - (qkv[t, h, 1, i] * r * where(h < HQ, where(ADD == 1, q_add[1, i], q_w[1, i]), where(ADD == 1, k_add[1, i], k_w[1, i]))) * sin_emb[CR, 0, i], (qkv[t, h, 1, i] * r * where(h < HQ, where(ADD == 1, q_add[1, i], q_w[1, i]), where(ADD == 1, k_add[1, i], k_w[1, i]))) * cos_emb[CR, 1, i] + (qkv[t, h, 0, i] * r * where(h < HQ, where(ADD == 1, q_add[0, i], q_w[0, i]), where(ADD == 1, k_add[0, i], k_w[0, i]))) * sin_emb[CR, 1, i])), unwritten), unwritten), unwritten);
