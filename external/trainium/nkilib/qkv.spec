// nkilib's qkv, unfused and unquantized, from qkv_tkg_torch.py in its BSD layout: the
// input's tokens multiplied by the fused Q, K and V weights.
dim B;
dim S;
dim H;
dim I;
array input[B, S, H];
array fused_qkv_weights[H, I];
array out[B, S, I];

out[b, s, i] = sum(h in 0..H, input[b, s, h] * fused_qkv_weights[h, i]);
