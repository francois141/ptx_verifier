// vLLM's per-token-group fp8 quantization scales (csrc/quantization/w8a8/fp8/
// per_token_group_quant.cu): group g of token t (global group t GP + g, S elements) has
// scale max(eps, max |x|) / 448, eps = f32(1e-10); the block writes groups [G0, G1).
dim M; dim H; dim GP; dim S; dim ST; dim G0; dim G1;
array x[M, H];
array x_s[M, GP];
x_s[t, g] = where(t * GP + g < G0, unwritten, where(t * GP + g < G1,
    max(0.000000000100000001335143196001808973960578441619873046875,
        max(i in 0..S, abs(x[t, g * S + i]))) / 448,
    unwritten));
