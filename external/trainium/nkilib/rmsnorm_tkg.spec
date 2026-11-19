// nkilib's rmsnorm_tkg on one core, from rmsnorm_torch.py: each of the T = B * S tokens
// normalized by the root of its mean square plus eps, scaled by gamma, and laid out
// [H0, T, H1] with hidden index h0 * H1 + h1 (H0 = 128).
dim T;
dim H;
dim H0;
dim H1;
dim ONE;
array input[T, H];
array gamma[ONE, H];
array output[H0, T, H1];

output[a, t, b] = input[t, a * H1 + b] * gamma[0, a * H1 + b]
    / sqrt(sum(k in 0..H, input[t, k] * input[t, k]) / H + 0.000001);
