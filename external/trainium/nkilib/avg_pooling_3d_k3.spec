// nkilib experimental avg_pooling_3d, from avg_pooling_3d_torch.py (F.avg_pool3d with
// count_include_pad=True) for a 3 x 3 x 3 window: each window's sum over the zero-padded
// input, scaled by the kernel's 1/27 rounded to a double. NCDHW in and out.
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
array src_tensor[B, C, D, H, W] padded;
array out[B, C, OD, OH, OW];

out[b, c, d, h, w] = sum(i in 0..KD, sum(j in 0..KH, sum(k in 0..KW,
    src_tensor[b, c, d * SD + i - PD, h * SH + j - PH, w * SW + k - PW]))) * 0.037037037037037035;
