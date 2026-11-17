// nkilib experimental max_pooling_3d, from max_pooling_3d_torch.py (F.max_pool3d): each
// window's maximum, -inf padding being taps left out. Window bounds per output position are
// index arrays, clamped to the input: LD[d] = max(0, d * SD - PD), HD[d] = min(D, d * SD -
// PD + KD), likewise for H and W (`nkilib_tests.rs` computes them). NCDHW in and out.
dim B;
dim C;
dim D;
dim H;
dim W;
dim OD;
dim OH;
dim OW;
array LD[OD] index;
array HD[OD] index;
array LH[OH] index;
array HH[OH] index;
array LW[OW] index;
array HW[OW] index;
array src_tensor[B, C, D, H, W];
array out[B, C, OD, OH, OW];

out[b, c, d, h, w] = max(i in LD[d]..HD[d], max(j in LH[h]..HH[h], max(k in LW[w]..HW[w],
    src_tensor[b, c, i, j, k])));
