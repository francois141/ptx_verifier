// nkilib experimental avg_pooling_3d_backward, from avg_pooling_3d_backward_torch.py (the
// gradient of F.avg_pool3d with count_include_pad=True) for a 3 x 3 x 3 window: each input
// position's gradient is the sum, over the windows containing it, of the output gradient
// scaled by the kernel's 1/27 rounded to a double; a position in no window gets 0. Windows
// containing position x along an axis are outputs o in [L[x], H[x]), clamped to the output
// (`nkilib_tests` computes them). NCDHW.
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
array LD[D] index;
array HD[D] index;
array LH[H] index;
array HH[H] index;
array LW[W] index;
array HW[W] index;
array grad_output[B, C, OD, OH, OW];
array grad_input[B, C, D, H, W];

grad_input[b, c, d, h, w] = sum(i in LD[d]..HD[d], sum(j in LH[h]..HH[h], sum(k in LW[w]..HW[w],
    grad_output[b, c, i, j, k]))) * 0.037037037037037035;
