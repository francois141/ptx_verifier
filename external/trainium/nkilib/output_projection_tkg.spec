// nkilib's output_projection_tkg, unquantized, from output_projection_tkg_torch.py:
// output_projection.spec with attention laid out [D, B, N, S] and the output [B * S, H],
// viewed as [B, S, H].
dim B;
dim N;
dim D;
dim S;
dim H;
array attention[D, B, N, S];
array weight[N, D, H];
array out[B, S, H];

out[b, s, h] = sum(n in 0..N, sum(d in 0..D, attention[d, b, n, s] * weight[n, d, h]));
