// nkilib experimental conv3d (no batch norm, no activation), from conv3d_torch.py (nn.Conv3d,
// asymmetric padding by F.pad): conv_out[b, co, d, h, w] = bias[co] + the sum over input channels
// and taps of filters[kd, kh, kw, ci, co] times the zero-padded input. Filters are
// [Kd, Kh, Kw, C_in, C_out]; PD, PH, PW are the leading (left/top) paddings. y_out is the
// same convolution under conv3d_temporal_unroll's output name.
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
dim SD;
dim SH;
dim SW;
dim DD;
dim DH;
dim DW;
dim PD;
dim PH;
dim PW;
array x_in[B, CI, D, H, W] padded;
array filters[KD, KH, KW, CI, CO];
array bias[CO];
array conv_out[B, CO, OD, OH, OW];
array y_out[B, CO, OD, OH, OW];

conv_out[b, co, d, h, w] = bias[co] + sum(ci in 0..CI, sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    filters[i, j, k, ci, co]
        * x_in[b, ci, d * SD + i * DD - PD, h * SH + j * DH - PH, w * SW + k * DW - PW]))));
y_out[b, co, d, h, w] = bias[co] + sum(ci in 0..CI, sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    filters[i, j, k, ci, co]
        * x_in[b, ci, d * SD + i * DD - PD, h * SH + j * DH - PH, w * SW + k * DW - PW]))));
