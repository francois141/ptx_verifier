// FlashInfer QKRMSNormKernel (norm.cuh:303): job j = b H + h normalizes head h of batch b of a
// [BT, HS, D] input (the first H of HS heads, e.g. q of a fused qkv) into a contiguous
// [BT, H, D] output; the analyzed block's warps take jobs [J0, J1). eps = f32(1e-6).
dim BT; dim HS; dim H; dim D; dim J0; dim J1;
array input[BT, HS, D];
array weight[D];
array out[BT, H, D];
out[b, h, c] = where(b * H + h < J0, unwritten, where(b * H + h < J1,
    input[b, h, c] * weight[c]
        / sqrt(sum(k in 0..D, input[b, h, k] * input[b, h, k]) / D + 0.0000009999999974752427078783512115478515625),
    unwritten));
