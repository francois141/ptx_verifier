// The convolution with the bias dropped: must not match Conv2D-ref/opt.
dim NB;
dim CI;
dim H;
dim W;
dim CO;
dim KH;
dim KW;
dim HO;
dim WO;
array input[NB, CI, H, W] padded;
array weight[CO, CI, KH, KW];
array output[NB, CO, HO, WO];

output[n, o, y, x] = sum(c in 0..CI, sum(p in 0..KH, sum(q in 0..KW,
    input[n, c, 4 * y + p - 2, 4 * x + q - 2] * weight[o, c, p, q])));
