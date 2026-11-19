// nkilib experimental conv3d_transpose (taps as stored: flip_filter_taps_in_kernel=False), as
// conv3d_transpose_torch.py's nn.ConvTranspose3d with filters[K - 1 - k] as its weight: a
// stride-1 convolution of filters over the input with stride - 1 zeros inserted and padding
// dilation * (K - 1) - pad. MD/MH/MW map a zero-inserted coordinate shifted by that padding to
// its input coordinate, or to -1 (a zero of the padded input) where no input lands.
dim B;
dim CI;
dim CO;
dim D;
dim H;
dim W;
dim OD;
dim OH;
dim OW;
dim KD;
dim KH;
dim KW;
dim DD;
dim DH;
dim DW;
dim ZD;
dim ZH;
dim ZW;
array x_in[B, CI, D, H, W] padded;
array filters[KD, KH, KW, CI, CO];
array bias[CO];
array MD[ZD] index;
array MH[ZH] index;
array MW[ZW] index;
array core_out[B, CO, OD, OH, OW];

core_out[b, co, d, h, w] = bias[co] + sum(ci in 0..CI, sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    filters[i, j, k, ci, co] * x_in[b, ci, MD[d + i * DD], MH[h + j * DH], MW[w + k * DW]]))));
