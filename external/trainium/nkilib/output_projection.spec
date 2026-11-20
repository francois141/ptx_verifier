// nkilib's output projection, unquantized, from output_projection_cte_torch.py: each token's
// heads concatenated and multiplied by the weight, out[b, s, h] = sum over n, d of
// attention[b, n, d, s] * weight[n * D + d, h], the weight viewed as [N, D, H].
dim B;
dim N;
dim D;
dim S;
dim H;
array attention[B, N, D, S];
array weight[N, D, H];
array out[B, S, H];

out[b, s, h] = sum(n in 0..N, sum(d in 0..D, attention[b, n, d, s] * weight[n, d, h]));
