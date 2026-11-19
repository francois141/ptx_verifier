// rmsnorm_tkg.spec with hidden_actual = 200: the sum of squares over all of H (a caller pads
// with zeros past 200) times the double nearest 1/200.
dim T;
dim H;
dim H0;
dim H1;
dim ONE;
array input[T, H];
array gamma[ONE, H];
array output[H0, T, H1];

output[a, t, b] = input[t, a * H1 + b] * gamma[0, a * H1 + b]
    / sqrt(sum(k in 0..H, input[t, k] * input[t, k]) * 0.005 + 0.000001);
