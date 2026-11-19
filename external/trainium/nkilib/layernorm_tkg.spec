// nkilib's layernorm_tkg on one core, from layernorm_torch.py: each of the T = B * S tokens
// centered by its mean, divided by the root of its (population) variance plus eps, scaled by
// gamma and shifted by beta, laid out [H0, T, H1] with H = H0 * H1 (H0 = 128).
dim T;
dim H;
dim H0;
dim H1;
dim ONE;
array input[T, H];
array gamma[ONE, H];
array beta[ONE, H];
array output[H0, T, H1];

output[a, t, b] = (input[t, a * H1 + b] - sum(k in 0..H, input[t, k]) / H)
    / sqrt(sum(k in 0..H, (input[t, k] - sum(j in 0..H, input[t, j]) / H)
                        * (input[t, k] - sum(j in 0..H, input[t, j]) / H)) / H + 0.000001)
    * gamma[0, a * H1 + b] + beta[0, a * H1 + b];
