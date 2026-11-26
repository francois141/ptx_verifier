// vLLM's rms_norm on a strided rank-2/3/4 input viewed [B, S, H, D] (row (b, s, h) at
// b SB + s SS + h SH of the flat input), weight row b at b WS (WS = 0: one weight [D]);
// out [B, S, H, D] contiguous. Block (CB, CS, CH) normalizes that row; the rest unwritten.
dim B; dim S; dim H; dim D; dim NIN; dim NW; dim SB; dim SS; dim SH; dim WS; dim CB; dim CS; dim CH;
array input[NIN];
array weight[NW];
array out[B, S, H, D];
out[b, s, h, d] = where(b != CB, unwritten, where(s != CS, unwritten, where(h != CH, unwritten,
    input[b * SB + s * SS + h * SH + d] * weight[b * WS + d]
    / sqrt(sum(k in 0..D, input[b * SB + s * SS + h * SH + k] * input[b * SB + s * SS + h * SH + k]) / D
           + 0.0000009999999974752427078783512115478515625))));
