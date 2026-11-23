// Aiter's cached thd RoPE, NEOX style with reuse_freqs_front_part (cos/sin [PM, HALF]), on
// the tokens 0..TO-1 and heads 0..HO-1 / 0..HOY-1 a workgroup writes; position of token t is
// t + P. A head is viewed as [2, HALF]: out[s=0] = x0*c - x1*s, out[s=1] = x1*c + x0*s, the sign
// written as sum(r in 0..s, 2 * v) - v (-v at s = 0, +v at s = 1).
dim TWO; dim T; dim H; dim KH; dim HALF; dim P; dim PM; dim TO; dim HO; dim HOY;
array x[T, H, TWO, HALF];
array y[T, KH, TWO, HALF];
array cs[PM, HALF];
array sn[PM, HALF];
array out_x[TO, HO, TWO, HALF];
array out_y[TO, HOY, TWO, HALF];
out_x[t, h, s, i] = x[t, h, s, i] * cs[t + P, i]
    + sum(r in 0..s, 2 * x[t, h, 1 - s, i] * sn[t + P, i]) - x[t, h, 1 - s, i] * sn[t + P, i];
out_y[t, h, s, i] = y[t, h, s, i] * cs[t + P, i]
    + sum(r in 0..s, 2 * y[t, h, 1 - s, i] * sn[t + P, i]) - y[t, h, 1 - s, i] * sn[t + P, i];
