// nkilib's rope_hf from rope_hf_torch.py: q * cos + rotate_half(q) * sin, each head dimension
// viewed as [TWO, HALF], where rotate_half gives -x[1, i] in the first half and x[0, i] in the
// second; the sign 2j - 1 is written 2 * (sum over k < j of 1) - 1, likewise for k.
dim B;
dim QH;
dim KH;
dim S;
dim TWO;
dim HALF;
array q[B, QH, S, TWO, HALF];
array k[B, KH, S, TWO, HALF];
array cos[B, S, TWO, HALF];
array sin[B, S, TWO, HALF];
array q_out[B, QH, S, TWO, HALF];
array k_out[B, KH, S, TWO, HALF];

q_out[b, h, s, j, i] = q[b, h, s, j, i] * cos[b, s, j, i]
    + (2 * sum(u in 0..j, 1) - 1) * q[b, h, s, 1 - j, i] * sin[b, s, j, i];
k_out[b, h, s, j, i] = k[b, h, s, j, i] * cos[b, s, j, i]
    + (2 * sum(u in 0..j, 1) - 1) * k[b, h, s, 1 - j, i] * sin[b, s, j, i];
