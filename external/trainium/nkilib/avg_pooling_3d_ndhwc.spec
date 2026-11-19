// nkilib experimental avg_pooling_3d, from avg_pooling_3d_torch.py (F.avg_pool3d with
// count_include_pad=True): each window's sum over the zero-padded input, divided by the
// full window volume; NDHWC in and out.
dim B;
dim C;
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
dim PD;
dim PH;
dim PW;
array src_tensor[B, D, H, W, C] padded;
array out[B, OD, OH, OW, C];

out[b, d, h, w, c] = sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    src_tensor[b, d * SD + i - PD, h * SH + j - PH, w * SW + k - PW, c]))) / (KD * KH * KW);
