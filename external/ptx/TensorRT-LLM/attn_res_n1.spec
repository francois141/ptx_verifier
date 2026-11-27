// TensorRT-LLM attn_res_fwd_n1_ttile_kernel (kimiK3AttnRes/attnResFwd.cu:819), N = 1 (the softmax is
// degenerate), on one CTA: its token rows [R0, R1), [R2, R3), [R4, R5) (its tiles, in order; an absent
// one is [0, 0)): output = the layer residual row; rsigma = 1 / sqrt(sum_h v^2 / H + eps); logits =
// sum_h v (rms_w res_w) rsigma; probs = 1. eps = f32(1e-6).
dim TB; dim H; dim R0; dim R1; dim R2; dim R3; dim R4; dim R5;
array layer[TB, H]; array res_w[H]; array rms_w[H];
array output[TB, H]; array rsigma[TB]; array probs[TB]; array logits[TB];
output[t, h] = where(t < R1, where(t >= R0, layer[t, h], unwritten), where(t < R3, where(t >= R2, layer[t, h],
    unwritten), where(t < R5, where(t >= R4, layer[t, h], unwritten), unwritten)));
rsigma[t] = where(t < R1, where(t >= R0, 1 / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten), where(t < R3, where(t >= R2, 1 / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten),
    where(t < R5, where(t >= R4, 1 / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten), unwritten)));
logits[t] = where(t < R1, where(t >= R0, sum(h in 0..H, layer[t, h] * (rms_w[h] * res_w[h])) / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten), where(t < R3, where(t >= R2, sum(h in 0..H, layer[t, h] * (rms_w[h] * res_w[h])) / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten),
    where(t < R5, where(t >= R4, sum(h in 0..H, layer[t, h] * (rms_w[h] * res_w[h])) / sqrt(sum(h in 0..H, layer[t, h] * layer[t, h]) / H + 0.0000009999999974752427078783512115478515625), unwritten), unwritten)));
probs[t] = where(t < R1, where(t >= R0, 1, unwritten), where(t < R3, where(t >= R2, 1, unwritten),
    where(t < R5, where(t >= R4, 1, unwritten), unwritten)));
