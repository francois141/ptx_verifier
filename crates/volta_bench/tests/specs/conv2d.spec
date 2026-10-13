// What Conv2D-ref/opt compute: AlexNet conv1 (stride 4, zero padding 2) plus a
// per-channel bias, NCHW in and out.
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
array bias[CO];
array output[NB, CO, HO, WO];

output[n, o, y, x] = bias[o]
    + sum(c in 0..CI, sum(p in 0..KH, sum(q in 0..KW,
          input[n, c, 4 * y + p - 2, 4 * x + q - 2] * weight[o, c, p, q])));
