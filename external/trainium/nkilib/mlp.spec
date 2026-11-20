// nkilib's mlp, unquantized and unnormalized, with its default SiLU gate, from mlp_torch.py's
// _mlp_ref_standard: down(silu(x @ gate_w) * (x @ up_w)), silu(g) = g / (1 + e^-g) per
// intermediate element, for each of the T = B * S tokens.
dim T;
dim H;
dim I;
array hidden[T, H];
array gate_w[H, I];
array up_w[H, I];
array down_w[I, H];
array out[T, H];

out[t, h] = sum(i in 0..I,
    let(g, sum(k in 0..H, hidden[t, k] * gate_w[k, i]),
        g / (1 + exp(-g)))
    * sum(k in 0..H, hidden[t, k] * up_w[k, i])
    * down_w[i, h]);
