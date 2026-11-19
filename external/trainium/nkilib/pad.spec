// nkilib experimental pad, as torch.nn.functional.pad on a [N, C, D, H, W] input: each output
// element is the input element its mode maps it to (MD, MH, MW: clamped for replicate,
// mirrored for reflect, wrapped for circular), or -1, a zero of the padded input, for constant.
dim N;
dim C;
dim D;
dim H;
dim W;
dim OD;
dim OH;
dim OW;
array x_ref[N, C, D, H, W] padded;
array MD[OD] index;
array MH[OH] index;
array MW[OW] index;
array out[N, C, OD, OH, OW];

out[n, c, d, h, w] = x_ref[n, c, MD[d], MH[h], MW[w]];
