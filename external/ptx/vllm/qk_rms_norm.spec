// vLLM's rms_norm on one head of q, a strided view of qkv [rows, S]: head H of batch B is
// qkv[B, H * D + c], normalized into the analyzed block's output row; eps = f32(1e-6).
dim R; dim S; dim D; dim B; dim H;
array qkv[R, S];
array weight[D];
array out[D];
out[c] = qkv[B, H * D + c] * weight[c]
        / sqrt(sum(k in 0..D, qkv[B, H * D + k] * qkv[B, H * D + k]) / D
               + 0.0000009999999974752427078783512115478515625);
