// nkilib's rmsnorm_tkg on one core with hidden_dim_tp=True, from rmsnorm_torch.py: as
// rmsnorm_tkg.spec, laid out [H0, T, H1] with hidden index h1 * H0 + h0 (H0 = 128).
dim T;
dim H;
dim H0;
dim H1;
dim ONE;
array input[T, H];
array gamma[ONE, H];
array output[H0, T, H1];

output[a, t, b] = input[t, b * H0 + a] * gamma[0, b * H0 + a]
    / sqrt(sum(k in 0..H, input[t, k] * input[t, k]) / H + 0.000001);
