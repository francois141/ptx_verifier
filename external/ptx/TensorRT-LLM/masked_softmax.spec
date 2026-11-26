// TensorRT-LLM softmax_kernel (unfused masked softmax): x = qk / 8 (qk_scale 0.125, head size 64) + (1 - mask) (-10000) over
// row (B, H, Q) of qk [BS, HN, QL, KL], mask [BS, QL, KL]; out = exp(x - m) / (sum exp(x - m)
// + 1e-6) with m = max(-1e20, max x) (the kernel's seed and epsilon, f32); only that row written.
dim BS; dim HN; dim QL; dim KL; dim B; dim H; dim Q;
array qk[BS, HN, QL, KL];
array mask[BS, QL, KL];
array out[BS, HN, QL, KL];
out[b, h, q, k] = where(b == B, where(h == H, where(q == Q,
    let(m, max(-100000002004.087734272 * 1000000000, max(j in 0..KL, 0.125 * qk[b, h, q, j] + (1 - mask[b, q, j]) * -10000)),
      exp(0.125 * qk[b, h, q, k] + (1 - mask[b, q, k]) * -10000 - m)
      / (sum(j in 0..KL, exp(0.125 * qk[b, h, q, j] + (1 - mask[b, q, j]) * -10000 - m))
         + 0.0000009999999974752427078783512115478515625)),
    unwritten), unwritten), unwritten);
