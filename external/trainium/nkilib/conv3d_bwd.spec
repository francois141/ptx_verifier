// nkilib experimental conv3d_bwd, the gradients of conv3d.spec's convolution (no bias in the
// forward pass; db is dy's per-channel sum). dy is [B, CO, OD, OH, OW]; x_in zero-padded by
// PD, PH, PW on the leading side. dx scatters dy back through each tap: MD/MH/MW map
// q = coordinate + leading pad + (K - 1) * dilation - tap * dilation to the output position
// (q - (K - 1) * dilation) / stride, or -1 (a zero of the padded dy) where none lands.
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
dim ZD;
dim ZH;
dim ZW;
array dy[B, CO, OD, OH, OW] padded;
array x_in[B, CI, D, H, W] padded;
array filters[KD, KH, KW, CI, CO];
array MD[ZD] index;
array MH[ZH] index;
array MW[ZW] index;
array dx[B, CI, D, H, W];
array dw[KD, KH, KW, CI, CO];
array db[CO];

db[co] = sum(b in 0..B, sum(d in 0..OD, sum(h in 0..OH, sum(w in 0..OW, dy[b, co, d, h, w]))));
dw[i, j, k, ci, co] = sum(b in 0..B, sum(d in 0..OD, sum(h in 0..OH, sum(w in 0..OW,
    dy[b, co, d, h, w] * x_in[b, ci, d * SD + i * DD - PD, h * SH + j * DH - PH, w * SW + k * DW - PW]))));
dx[b, ci, d, h, w] = sum(co in 0..CO, sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    filters[i, j, k, ci, co] * dy[b, co, MD[d + PD + (KD - 1) * DD - i * DD],
        MH[h + PH + (KH - 1) * DH - j * DH], MW[w + PW + (KW - 1) * DW - k * DW]]))));
