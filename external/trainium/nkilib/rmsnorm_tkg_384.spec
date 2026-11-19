// rmsnorm_tkg.spec at H = 384, the mean taken as the kernel takes it: times the double
// nearest 1/384, which is not 1/384.
dim T;
dim H;
dim H0;
dim H1;
dim ONE;
array input[T, H];
array gamma[ONE, H];
array output[H0, T, H1];

output[a, t, b] = input[t, a * H1 + b] * gamma[0, a * H1 + b]
    / sqrt(sum(k in 0..H, input[t, k] * input[t, k]) * 0.0026041666666666665 + 0.000001);
